
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003b:	8b 45 08             	mov    0x8(%ebp),%eax
  80003e:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800040:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800044:	c7 04 24 c0 11 80 00 	movl   $0x8011c0,(%esp)
  80004b:	e8 2a 02 00 00       	call   80027a <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 fa 0b 00 00       	call   800c69 <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 e0 11 80 	movl   $0x8011e0,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 ca 11 80 00 	movl   $0x8011ca,(%esp)
  800092:	e8 e9 00 00 00       	call   800180 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 0c 12 80 	movl   $0x80120c,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 53 07 00 00       	call   800806 <snprintf>
}
  8000b3:	83 c4 24             	add    $0x24,%esp
  8000b6:	5b                   	pop    %ebx
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <umain>:

void
umain(int argc, char **argv)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000bf:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  8000c6:	e8 b5 0d 00 00       	call   800e80 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000cb:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000d2:	de 
  8000d3:	c7 04 24 dc 11 80 00 	movl   $0x8011dc,(%esp)
  8000da:	e8 9b 01 00 00       	call   80027a <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000df:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000e6:	ca 
  8000e7:	c7 04 24 dc 11 80 00 	movl   $0x8011dc,(%esp)
  8000ee:	e8 87 01 00 00       	call   80027a <cprintf>
}
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    
  8000f5:	66 90                	xchg   %ax,%ax
  8000f7:	90                   	nop

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 10             	sub    $0x10,%esp
  800100:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800103:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  800106:	b8 0c 20 80 00       	mov    $0x80200c,%eax
  80010b:	2d 04 20 80 00       	sub    $0x802004,%eax
  800110:	89 44 24 08          	mov    %eax,0x8(%esp)
  800114:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80011b:	00 
  80011c:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  800123:	e8 7f 08 00 00       	call   8009a7 <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  800128:	e8 fe 0a 00 00       	call   800c2b <sys_getenvid>
  80012d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800132:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800139:	c1 e0 07             	shl    $0x7,%eax
  80013c:	29 d0                	sub    %edx,%eax
  80013e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800143:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800148:	85 db                	test   %ebx,%ebx
  80014a:	7e 07                	jle    800153 <libmain+0x5b>
		binaryname = argv[0];
  80014c:	8b 06                	mov    (%esi),%eax
  80014e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800153:	89 74 24 04          	mov    %esi,0x4(%esp)
  800157:	89 1c 24             	mov    %ebx,(%esp)
  80015a:	e8 5a ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  80015f:	e8 08 00 00 00       	call   80016c <exit>
}
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	5b                   	pop    %ebx
  800168:	5e                   	pop    %esi
  800169:	5d                   	pop    %ebp
  80016a:	c3                   	ret    
  80016b:	90                   	nop

0080016c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800172:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800179:	e8 5b 0a 00 00       	call   800bd9 <sys_env_destroy>
}
  80017e:	c9                   	leave  
  80017f:	c3                   	ret    

00800180 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
  800185:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800188:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800191:	e8 95 0a 00 00       	call   800c2b <sys_getenvid>
  800196:	8b 55 0c             	mov    0xc(%ebp),%edx
  800199:	89 54 24 10          	mov    %edx,0x10(%esp)
  80019d:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001a4:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ac:	c7 04 24 38 12 80 00 	movl   $0x801238,(%esp)
  8001b3:	e8 c2 00 00 00       	call   80027a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bf:	89 04 24             	mov    %eax,(%esp)
  8001c2:	e8 52 00 00 00       	call   800219 <vcprintf>
	cprintf("\n");
  8001c7:	c7 04 24 de 11 80 00 	movl   $0x8011de,(%esp)
  8001ce:	e8 a7 00 00 00       	call   80027a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d3:	cc                   	int3   
  8001d4:	eb fd                	jmp    8001d3 <_panic+0x53>
  8001d6:	66 90                	xchg   %ax,%ax

008001d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	53                   	push   %ebx
  8001dc:	83 ec 14             	sub    $0x14,%esp
  8001df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e2:	8b 13                	mov    (%ebx),%edx
  8001e4:	8d 42 01             	lea    0x1(%edx),%eax
  8001e7:	89 03                	mov    %eax,(%ebx)
  8001e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f5:	75 19                	jne    800210 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001f7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001fe:	00 
  8001ff:	8d 43 08             	lea    0x8(%ebx),%eax
  800202:	89 04 24             	mov    %eax,(%esp)
  800205:	e8 92 09 00 00       	call   800b9c <sys_cputs>
		b->idx = 0;
  80020a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800210:	ff 43 04             	incl   0x4(%ebx)
}
  800213:	83 c4 14             	add    $0x14,%esp
  800216:	5b                   	pop    %ebx
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    

00800219 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800222:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800229:	00 00 00 
	b.cnt = 0;
  80022c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800233:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800236:	8b 45 0c             	mov    0xc(%ebp),%eax
  800239:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80023d:	8b 45 08             	mov    0x8(%ebp),%eax
  800240:	89 44 24 08          	mov    %eax,0x8(%esp)
  800244:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024e:	c7 04 24 d8 01 80 00 	movl   $0x8001d8,(%esp)
  800255:	e8 a9 01 00 00       	call   800403 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800260:	89 44 24 04          	mov    %eax,0x4(%esp)
  800264:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026a:	89 04 24             	mov    %eax,(%esp)
  80026d:	e8 2a 09 00 00       	call   800b9c <sys_cputs>

	return b.cnt;
}
  800272:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800278:	c9                   	leave  
  800279:	c3                   	ret    

0080027a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800280:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800283:	89 44 24 04          	mov    %eax,0x4(%esp)
  800287:	8b 45 08             	mov    0x8(%ebp),%eax
  80028a:	89 04 24             	mov    %eax,(%esp)
  80028d:	e8 87 ff ff ff       	call   800219 <vcprintf>
	va_end(ap);

	return cnt;
}
  800292:	c9                   	leave  
  800293:	c3                   	ret    

00800294 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	57                   	push   %edi
  800298:	56                   	push   %esi
  800299:	53                   	push   %ebx
  80029a:	83 ec 3c             	sub    $0x3c,%esp
  80029d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a0:	89 d7                	mov    %edx,%edi
  8002a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ab:	89 c1                	mov    %eax,%ecx
  8002ad:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002b0:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002be:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002c1:	39 ca                	cmp    %ecx,%edx
  8002c3:	72 08                	jb     8002cd <printnum+0x39>
  8002c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002cb:	77 6a                	ja     800337 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002cd:	8b 45 18             	mov    0x18(%ebp),%eax
  8002d0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002d4:	4e                   	dec    %esi
  8002d5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e0:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002e4:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002e8:	89 c3                	mov    %eax,%ebx
  8002ea:	89 d6                	mov    %edx,%esi
  8002ec:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002ef:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002fd:	89 04 24             	mov    %eax,(%esp)
  800300:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800303:	89 44 24 04          	mov    %eax,0x4(%esp)
  800307:	e8 04 0c 00 00       	call   800f10 <__udivdi3>
  80030c:	89 d9                	mov    %ebx,%ecx
  80030e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800312:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800316:	89 04 24             	mov    %eax,(%esp)
  800319:	89 54 24 04          	mov    %edx,0x4(%esp)
  80031d:	89 fa                	mov    %edi,%edx
  80031f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800322:	e8 6d ff ff ff       	call   800294 <printnum>
  800327:	eb 19                	jmp    800342 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800329:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80032d:	8b 45 18             	mov    0x18(%ebp),%eax
  800330:	89 04 24             	mov    %eax,(%esp)
  800333:	ff d3                	call   *%ebx
  800335:	eb 03                	jmp    80033a <printnum+0xa6>
  800337:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033a:	4e                   	dec    %esi
  80033b:	85 f6                	test   %esi,%esi
  80033d:	7f ea                	jg     800329 <printnum+0x95>
  80033f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800342:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800346:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80034a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80034d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800350:	89 44 24 08          	mov    %eax,0x8(%esp)
  800354:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800358:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80035b:	89 04 24             	mov    %eax,(%esp)
  80035e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800361:	89 44 24 04          	mov    %eax,0x4(%esp)
  800365:	e8 d6 0c 00 00       	call   801040 <__umoddi3>
  80036a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80036e:	0f be 80 5c 12 80 00 	movsbl 0x80125c(%eax),%eax
  800375:	89 04 24             	mov    %eax,(%esp)
  800378:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80037b:	ff d0                	call   *%eax
}
  80037d:	83 c4 3c             	add    $0x3c,%esp
  800380:	5b                   	pop    %ebx
  800381:	5e                   	pop    %esi
  800382:	5f                   	pop    %edi
  800383:	5d                   	pop    %ebp
  800384:	c3                   	ret    

00800385 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800388:	83 fa 01             	cmp    $0x1,%edx
  80038b:	7e 0e                	jle    80039b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800392:	89 08                	mov    %ecx,(%eax)
  800394:	8b 02                	mov    (%edx),%eax
  800396:	8b 52 04             	mov    0x4(%edx),%edx
  800399:	eb 22                	jmp    8003bd <getuint+0x38>
	else if (lflag)
  80039b:	85 d2                	test   %edx,%edx
  80039d:	74 10                	je     8003af <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80039f:	8b 10                	mov    (%eax),%edx
  8003a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a4:	89 08                	mov    %ecx,(%eax)
  8003a6:	8b 02                	mov    (%edx),%eax
  8003a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ad:	eb 0e                	jmp    8003bd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003af:	8b 10                	mov    (%eax),%edx
  8003b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b4:	89 08                	mov    %ecx,(%eax)
  8003b6:	8b 02                	mov    (%edx),%eax
  8003b8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    

008003bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c5:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003c8:	8b 10                	mov    (%eax),%edx
  8003ca:	3b 50 04             	cmp    0x4(%eax),%edx
  8003cd:	73 0a                	jae    8003d9 <sprintputch+0x1a>
		*b->buf++ = ch;
  8003cf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003d2:	89 08                	mov    %ecx,(%eax)
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d7:	88 02                	mov    %al,(%edx)
}
  8003d9:	5d                   	pop    %ebp
  8003da:	c3                   	ret    

008003db <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
  8003de:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003e1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8003eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f9:	89 04 24             	mov    %eax,(%esp)
  8003fc:	e8 02 00 00 00       	call   800403 <vprintfmt>
	va_end(ap);
}
  800401:	c9                   	leave  
  800402:	c3                   	ret    

00800403 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	57                   	push   %edi
  800407:	56                   	push   %esi
  800408:	53                   	push   %ebx
  800409:	83 ec 3c             	sub    $0x3c,%esp
  80040c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80040f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800412:	eb 14                	jmp    800428 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800414:	85 c0                	test   %eax,%eax
  800416:	0f 84 8a 03 00 00    	je     8007a6 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  80041c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800420:	89 04 24             	mov    %eax,(%esp)
  800423:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800426:	89 f3                	mov    %esi,%ebx
  800428:	8d 73 01             	lea    0x1(%ebx),%esi
  80042b:	31 c0                	xor    %eax,%eax
  80042d:	8a 03                	mov    (%ebx),%al
  80042f:	83 f8 25             	cmp    $0x25,%eax
  800432:	75 e0                	jne    800414 <vprintfmt+0x11>
  800434:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800438:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80043f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800446:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80044d:	ba 00 00 00 00       	mov    $0x0,%edx
  800452:	eb 1d                	jmp    800471 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800456:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80045a:	eb 15                	jmp    800471 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80045e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800462:	eb 0d                	jmp    800471 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800464:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800467:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80046a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800471:	8d 5e 01             	lea    0x1(%esi),%ebx
  800474:	31 c0                	xor    %eax,%eax
  800476:	8a 06                	mov    (%esi),%al
  800478:	8a 0e                	mov    (%esi),%cl
  80047a:	83 e9 23             	sub    $0x23,%ecx
  80047d:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800480:	80 f9 55             	cmp    $0x55,%cl
  800483:	0f 87 ff 02 00 00    	ja     800788 <vprintfmt+0x385>
  800489:	31 c9                	xor    %ecx,%ecx
  80048b:	8a 4d e0             	mov    -0x20(%ebp),%cl
  80048e:	ff 24 8d 20 13 80 00 	jmp    *0x801320(,%ecx,4)
  800495:	89 de                	mov    %ebx,%esi
  800497:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80049c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80049f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8004a3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004a6:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004a9:	83 fb 09             	cmp    $0x9,%ebx
  8004ac:	77 2f                	ja     8004dd <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ae:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004af:	eb eb                	jmp    80049c <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8d 48 04             	lea    0x4(%eax),%ecx
  8004b7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ba:	8b 00                	mov    (%eax),%eax
  8004bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004c1:	eb 1d                	jmp    8004e0 <vprintfmt+0xdd>
  8004c3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004c6:	f7 d0                	not    %eax
  8004c8:	c1 f8 1f             	sar    $0x1f,%eax
  8004cb:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	89 de                	mov    %ebx,%esi
  8004d0:	eb 9f                	jmp    800471 <vprintfmt+0x6e>
  8004d2:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004d4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004db:	eb 94                	jmp    800471 <vprintfmt+0x6e>
  8004dd:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004e0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004e4:	79 8b                	jns    800471 <vprintfmt+0x6e>
  8004e6:	e9 79 ff ff ff       	jmp    800464 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004eb:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ee:	eb 81                	jmp    800471 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f3:	8d 50 04             	lea    0x4(%eax),%edx
  8004f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004fd:	8b 00                	mov    (%eax),%eax
  8004ff:	89 04 24             	mov    %eax,(%esp)
  800502:	ff 55 08             	call   *0x8(%ebp)
			break;
  800505:	e9 1e ff ff ff       	jmp    800428 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80050a:	8b 45 14             	mov    0x14(%ebp),%eax
  80050d:	8d 50 04             	lea    0x4(%eax),%edx
  800510:	89 55 14             	mov    %edx,0x14(%ebp)
  800513:	8b 00                	mov    (%eax),%eax
  800515:	89 c2                	mov    %eax,%edx
  800517:	c1 fa 1f             	sar    $0x1f,%edx
  80051a:	31 d0                	xor    %edx,%eax
  80051c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051e:	83 f8 09             	cmp    $0x9,%eax
  800521:	7f 0b                	jg     80052e <vprintfmt+0x12b>
  800523:	8b 14 85 80 14 80 00 	mov    0x801480(,%eax,4),%edx
  80052a:	85 d2                	test   %edx,%edx
  80052c:	75 20                	jne    80054e <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  80052e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800532:	c7 44 24 08 74 12 80 	movl   $0x801274,0x8(%esp)
  800539:	00 
  80053a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80053e:	8b 45 08             	mov    0x8(%ebp),%eax
  800541:	89 04 24             	mov    %eax,(%esp)
  800544:	e8 92 fe ff ff       	call   8003db <printfmt>
  800549:	e9 da fe ff ff       	jmp    800428 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80054e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800552:	c7 44 24 08 7d 12 80 	movl   $0x80127d,0x8(%esp)
  800559:	00 
  80055a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80055e:	8b 45 08             	mov    0x8(%ebp),%eax
  800561:	89 04 24             	mov    %eax,(%esp)
  800564:	e8 72 fe ff ff       	call   8003db <printfmt>
  800569:	e9 ba fe ff ff       	jmp    800428 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800571:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800574:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8d 50 04             	lea    0x4(%eax),%edx
  80057d:	89 55 14             	mov    %edx,0x14(%ebp)
  800580:	8b 30                	mov    (%eax),%esi
  800582:	85 f6                	test   %esi,%esi
  800584:	75 05                	jne    80058b <vprintfmt+0x188>
				p = "(null)";
  800586:	be 6d 12 80 00       	mov    $0x80126d,%esi
			if (width > 0 && padc != '-')
  80058b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80058f:	0f 84 8c 00 00 00    	je     800621 <vprintfmt+0x21e>
  800595:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800599:	0f 8e 8a 00 00 00    	jle    800629 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  80059f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005a3:	89 34 24             	mov    %esi,(%esp)
  8005a6:	e8 9b 02 00 00       	call   800846 <strnlen>
  8005ab:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005ae:	29 c1                	sub    %eax,%ecx
  8005b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  8005b3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ba:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8005bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005c3:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c5:	eb 0d                	jmp    8005d4 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8005c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ce:	89 04 24             	mov    %eax,(%esp)
  8005d1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d3:	4b                   	dec    %ebx
  8005d4:	85 db                	test   %ebx,%ebx
  8005d6:	7f ef                	jg     8005c7 <vprintfmt+0x1c4>
  8005d8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005db:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005de:	89 c8                	mov    %ecx,%eax
  8005e0:	f7 d0                	not    %eax
  8005e2:	c1 f8 1f             	sar    $0x1f,%eax
  8005e5:	21 c8                	and    %ecx,%eax
  8005e7:	29 c1                	sub    %eax,%ecx
  8005e9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ec:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005ef:	eb 3e                	jmp    80062f <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f5:	74 1b                	je     800612 <vprintfmt+0x20f>
  8005f7:	0f be d2             	movsbl %dl,%edx
  8005fa:	83 ea 20             	sub    $0x20,%edx
  8005fd:	83 fa 5e             	cmp    $0x5e,%edx
  800600:	76 10                	jbe    800612 <vprintfmt+0x20f>
					putch('?', putdat);
  800602:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800606:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80060d:	ff 55 08             	call   *0x8(%ebp)
  800610:	eb 0a                	jmp    80061c <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800612:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800616:	89 04 24             	mov    %eax,(%esp)
  800619:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061c:	ff 4d dc             	decl   -0x24(%ebp)
  80061f:	eb 0e                	jmp    80062f <vprintfmt+0x22c>
  800621:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800624:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800627:	eb 06                	jmp    80062f <vprintfmt+0x22c>
  800629:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80062c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80062f:	46                   	inc    %esi
  800630:	8a 56 ff             	mov    -0x1(%esi),%dl
  800633:	0f be c2             	movsbl %dl,%eax
  800636:	85 c0                	test   %eax,%eax
  800638:	74 1f                	je     800659 <vprintfmt+0x256>
  80063a:	85 db                	test   %ebx,%ebx
  80063c:	78 b3                	js     8005f1 <vprintfmt+0x1ee>
  80063e:	4b                   	dec    %ebx
  80063f:	79 b0                	jns    8005f1 <vprintfmt+0x1ee>
  800641:	8b 75 08             	mov    0x8(%ebp),%esi
  800644:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800647:	eb 16                	jmp    80065f <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800649:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80064d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800654:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800656:	4b                   	dec    %ebx
  800657:	eb 06                	jmp    80065f <vprintfmt+0x25c>
  800659:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80065c:	8b 75 08             	mov    0x8(%ebp),%esi
  80065f:	85 db                	test   %ebx,%ebx
  800661:	7f e6                	jg     800649 <vprintfmt+0x246>
  800663:	89 75 08             	mov    %esi,0x8(%ebp)
  800666:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800669:	e9 ba fd ff ff       	jmp    800428 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066e:	83 fa 01             	cmp    $0x1,%edx
  800671:	7e 16                	jle    800689 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8d 50 08             	lea    0x8(%eax),%edx
  800679:	89 55 14             	mov    %edx,0x14(%ebp)
  80067c:	8b 50 04             	mov    0x4(%eax),%edx
  80067f:	8b 00                	mov    (%eax),%eax
  800681:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800684:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800687:	eb 32                	jmp    8006bb <vprintfmt+0x2b8>
	else if (lflag)
  800689:	85 d2                	test   %edx,%edx
  80068b:	74 18                	je     8006a5 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8d 50 04             	lea    0x4(%eax),%edx
  800693:	89 55 14             	mov    %edx,0x14(%ebp)
  800696:	8b 30                	mov    (%eax),%esi
  800698:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80069b:	89 f0                	mov    %esi,%eax
  80069d:	c1 f8 1f             	sar    $0x1f,%eax
  8006a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006a3:	eb 16                	jmp    8006bb <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8d 50 04             	lea    0x4(%eax),%edx
  8006ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ae:	8b 30                	mov    (%eax),%esi
  8006b0:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006b3:	89 f0                	mov    %esi,%eax
  8006b5:	c1 f8 1f             	sar    $0x1f,%eax
  8006b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006c6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006ca:	0f 89 80 00 00 00    	jns    800750 <vprintfmt+0x34d>
				putch('-', putdat);
  8006d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006db:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006e4:	f7 d8                	neg    %eax
  8006e6:	83 d2 00             	adc    $0x0,%edx
  8006e9:	f7 da                	neg    %edx
			}
			base = 10;
  8006eb:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006f0:	eb 5e                	jmp    800750 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f5:	e8 8b fc ff ff       	call   800385 <getuint>
			base = 10;
  8006fa:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006ff:	eb 4f                	jmp    800750 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800701:	8d 45 14             	lea    0x14(%ebp),%eax
  800704:	e8 7c fc ff ff       	call   800385 <getuint>
			base = 8;
  800709:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80070e:	eb 40                	jmp    800750 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800710:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800714:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80071b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80071e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800722:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800729:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8d 50 04             	lea    0x4(%eax),%edx
  800732:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800735:	8b 00                	mov    (%eax),%eax
  800737:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80073c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800741:	eb 0d                	jmp    800750 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800743:	8d 45 14             	lea    0x14(%ebp),%eax
  800746:	e8 3a fc ff ff       	call   800385 <getuint>
			base = 16;
  80074b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800750:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800754:	89 74 24 10          	mov    %esi,0x10(%esp)
  800758:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80075b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80075f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800763:	89 04 24             	mov    %eax,(%esp)
  800766:	89 54 24 04          	mov    %edx,0x4(%esp)
  80076a:	89 fa                	mov    %edi,%edx
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	e8 20 fb ff ff       	call   800294 <printnum>
			break;
  800774:	e9 af fc ff ff       	jmp    800428 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800779:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80077d:	89 04 24             	mov    %eax,(%esp)
  800780:	ff 55 08             	call   *0x8(%ebp)
			break;
  800783:	e9 a0 fc ff ff       	jmp    800428 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800788:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80078c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800793:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800796:	89 f3                	mov    %esi,%ebx
  800798:	eb 01                	jmp    80079b <vprintfmt+0x398>
  80079a:	4b                   	dec    %ebx
  80079b:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80079f:	75 f9                	jne    80079a <vprintfmt+0x397>
  8007a1:	e9 82 fc ff ff       	jmp    800428 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007a6:	83 c4 3c             	add    $0x3c,%esp
  8007a9:	5b                   	pop    %ebx
  8007aa:	5e                   	pop    %esi
  8007ab:	5f                   	pop    %edi
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    

008007ae <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	83 ec 28             	sub    $0x28,%esp
  8007b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007bd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	74 30                	je     8007ff <vsnprintf+0x51>
  8007cf:	85 d2                	test   %edx,%edx
  8007d1:	7e 2c                	jle    8007ff <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007da:	8b 45 10             	mov    0x10(%ebp),%eax
  8007dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e8:	c7 04 24 bf 03 80 00 	movl   $0x8003bf,(%esp)
  8007ef:	e8 0f fc ff ff       	call   800403 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007fd:	eb 05                	jmp    800804 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800804:	c9                   	leave  
  800805:	c3                   	ret    

00800806 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80080c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80080f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800813:	8b 45 10             	mov    0x10(%ebp),%eax
  800816:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800821:	8b 45 08             	mov    0x8(%ebp),%eax
  800824:	89 04 24             	mov    %eax,(%esp)
  800827:	e8 82 ff ff ff       	call   8007ae <vsnprintf>
	va_end(ap);

	return rc;
}
  80082c:	c9                   	leave  
  80082d:	c3                   	ret    
  80082e:	66 90                	xchg   %ax,%ax

00800830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
  80083b:	eb 01                	jmp    80083e <strlen+0xe>
		n++;
  80083d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80083e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800842:	75 f9                	jne    80083d <strlen+0xd>
		n++;
	return n;
}
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
  800854:	eb 01                	jmp    800857 <strnlen+0x11>
		n++;
  800856:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800857:	39 d0                	cmp    %edx,%eax
  800859:	74 06                	je     800861 <strnlen+0x1b>
  80085b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80085f:	75 f5                	jne    800856 <strnlen+0x10>
		n++;
	return n;
}
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	53                   	push   %ebx
  800867:	8b 45 08             	mov    0x8(%ebp),%eax
  80086a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80086d:	89 c2                	mov    %eax,%edx
  80086f:	42                   	inc    %edx
  800870:	41                   	inc    %ecx
  800871:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800874:	88 5a ff             	mov    %bl,-0x1(%edx)
  800877:	84 db                	test   %bl,%bl
  800879:	75 f4                	jne    80086f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80087b:	5b                   	pop    %ebx
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	53                   	push   %ebx
  800882:	83 ec 08             	sub    $0x8,%esp
  800885:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800888:	89 1c 24             	mov    %ebx,(%esp)
  80088b:	e8 a0 ff ff ff       	call   800830 <strlen>
	strcpy(dst + len, src);
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
  800893:	89 54 24 04          	mov    %edx,0x4(%esp)
  800897:	01 d8                	add    %ebx,%eax
  800899:	89 04 24             	mov    %eax,(%esp)
  80089c:	e8 c2 ff ff ff       	call   800863 <strcpy>
	return dst;
}
  8008a1:	89 d8                	mov    %ebx,%eax
  8008a3:	83 c4 08             	add    $0x8,%esp
  8008a6:	5b                   	pop    %ebx
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	56                   	push   %esi
  8008ad:	53                   	push   %ebx
  8008ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b4:	89 f3                	mov    %esi,%ebx
  8008b6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b9:	89 f2                	mov    %esi,%edx
  8008bb:	eb 0c                	jmp    8008c9 <strncpy+0x20>
		*dst++ = *src;
  8008bd:	42                   	inc    %edx
  8008be:	8a 01                	mov    (%ecx),%al
  8008c0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c3:	80 39 01             	cmpb   $0x1,(%ecx)
  8008c6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c9:	39 da                	cmp    %ebx,%edx
  8008cb:	75 f0                	jne    8008bd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008cd:	89 f0                	mov    %esi,%eax
  8008cf:	5b                   	pop    %ebx
  8008d0:	5e                   	pop    %esi
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	56                   	push   %esi
  8008d7:	53                   	push   %ebx
  8008d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008e1:	89 f0                	mov    %esi,%eax
  8008e3:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e7:	85 c9                	test   %ecx,%ecx
  8008e9:	75 07                	jne    8008f2 <strlcpy+0x1f>
  8008eb:	eb 18                	jmp    800905 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ed:	40                   	inc    %eax
  8008ee:	42                   	inc    %edx
  8008ef:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008f2:	39 d8                	cmp    %ebx,%eax
  8008f4:	74 0a                	je     800900 <strlcpy+0x2d>
  8008f6:	8a 0a                	mov    (%edx),%cl
  8008f8:	84 c9                	test   %cl,%cl
  8008fa:	75 f1                	jne    8008ed <strlcpy+0x1a>
  8008fc:	89 c2                	mov    %eax,%edx
  8008fe:	eb 02                	jmp    800902 <strlcpy+0x2f>
  800900:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800902:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800905:	29 f0                	sub    %esi,%eax
}
  800907:	5b                   	pop    %ebx
  800908:	5e                   	pop    %esi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800911:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800914:	eb 02                	jmp    800918 <strcmp+0xd>
		p++, q++;
  800916:	41                   	inc    %ecx
  800917:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800918:	8a 01                	mov    (%ecx),%al
  80091a:	84 c0                	test   %al,%al
  80091c:	74 04                	je     800922 <strcmp+0x17>
  80091e:	3a 02                	cmp    (%edx),%al
  800920:	74 f4                	je     800916 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800922:	25 ff 00 00 00       	and    $0xff,%eax
  800927:	8a 0a                	mov    (%edx),%cl
  800929:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  80092f:	29 c8                	sub    %ecx,%eax
}
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	53                   	push   %ebx
  800937:	8b 45 08             	mov    0x8(%ebp),%eax
  80093a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093d:	89 c3                	mov    %eax,%ebx
  80093f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800942:	eb 02                	jmp    800946 <strncmp+0x13>
		n--, p++, q++;
  800944:	40                   	inc    %eax
  800945:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800946:	39 d8                	cmp    %ebx,%eax
  800948:	74 20                	je     80096a <strncmp+0x37>
  80094a:	8a 08                	mov    (%eax),%cl
  80094c:	84 c9                	test   %cl,%cl
  80094e:	74 04                	je     800954 <strncmp+0x21>
  800950:	3a 0a                	cmp    (%edx),%cl
  800952:	74 f0                	je     800944 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800954:	8a 18                	mov    (%eax),%bl
  800956:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80095c:	89 d8                	mov    %ebx,%eax
  80095e:	8a 1a                	mov    (%edx),%bl
  800960:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800966:	29 d8                	sub    %ebx,%eax
  800968:	eb 05                	jmp    80096f <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80096a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80096f:	5b                   	pop    %ebx
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80097b:	eb 05                	jmp    800982 <strchr+0x10>
		if (*s == c)
  80097d:	38 ca                	cmp    %cl,%dl
  80097f:	74 0c                	je     80098d <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800981:	40                   	inc    %eax
  800982:	8a 10                	mov    (%eax),%dl
  800984:	84 d2                	test   %dl,%dl
  800986:	75 f5                	jne    80097d <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800988:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800998:	eb 05                	jmp    80099f <strfind+0x10>
		if (*s == c)
  80099a:	38 ca                	cmp    %cl,%dl
  80099c:	74 07                	je     8009a5 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80099e:	40                   	inc    %eax
  80099f:	8a 10                	mov    (%eax),%dl
  8009a1:	84 d2                	test   %dl,%dl
  8009a3:	75 f5                	jne    80099a <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	57                   	push   %edi
  8009ab:	56                   	push   %esi
  8009ac:	53                   	push   %ebx
  8009ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b3:	85 c9                	test   %ecx,%ecx
  8009b5:	74 37                	je     8009ee <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009bd:	75 29                	jne    8009e8 <memset+0x41>
  8009bf:	f6 c1 03             	test   $0x3,%cl
  8009c2:	75 24                	jne    8009e8 <memset+0x41>
		c &= 0xFF;
  8009c4:	31 d2                	xor    %edx,%edx
  8009c6:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c9:	89 d3                	mov    %edx,%ebx
  8009cb:	c1 e3 08             	shl    $0x8,%ebx
  8009ce:	89 d6                	mov    %edx,%esi
  8009d0:	c1 e6 18             	shl    $0x18,%esi
  8009d3:	89 d0                	mov    %edx,%eax
  8009d5:	c1 e0 10             	shl    $0x10,%eax
  8009d8:	09 f0                	or     %esi,%eax
  8009da:	09 c2                	or     %eax,%edx
  8009dc:	89 d0                	mov    %edx,%eax
  8009de:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009e0:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009e3:	fc                   	cld    
  8009e4:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e6:	eb 06                	jmp    8009ee <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009eb:	fc                   	cld    
  8009ec:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ee:	89 f8                	mov    %edi,%eax
  8009f0:	5b                   	pop    %ebx
  8009f1:	5e                   	pop    %esi
  8009f2:	5f                   	pop    %edi
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	57                   	push   %edi
  8009f9:	56                   	push   %esi
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a03:	39 c6                	cmp    %eax,%esi
  800a05:	73 33                	jae    800a3a <memmove+0x45>
  800a07:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a0a:	39 d0                	cmp    %edx,%eax
  800a0c:	73 2c                	jae    800a3a <memmove+0x45>
		s += n;
		d += n;
  800a0e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a11:	89 d6                	mov    %edx,%esi
  800a13:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a15:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a1b:	75 13                	jne    800a30 <memmove+0x3b>
  800a1d:	f6 c1 03             	test   $0x3,%cl
  800a20:	75 0e                	jne    800a30 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a22:	83 ef 04             	sub    $0x4,%edi
  800a25:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a28:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a2b:	fd                   	std    
  800a2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2e:	eb 07                	jmp    800a37 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a30:	4f                   	dec    %edi
  800a31:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a34:	fd                   	std    
  800a35:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a37:	fc                   	cld    
  800a38:	eb 1d                	jmp    800a57 <memmove+0x62>
  800a3a:	89 f2                	mov    %esi,%edx
  800a3c:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3e:	f6 c2 03             	test   $0x3,%dl
  800a41:	75 0f                	jne    800a52 <memmove+0x5d>
  800a43:	f6 c1 03             	test   $0x3,%cl
  800a46:	75 0a                	jne    800a52 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a48:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a4b:	89 c7                	mov    %eax,%edi
  800a4d:	fc                   	cld    
  800a4e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a50:	eb 05                	jmp    800a57 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a52:	89 c7                	mov    %eax,%edi
  800a54:	fc                   	cld    
  800a55:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a57:	5e                   	pop    %esi
  800a58:	5f                   	pop    %edi
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a61:	8b 45 10             	mov    0x10(%ebp),%eax
  800a64:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a72:	89 04 24             	mov    %eax,(%esp)
  800a75:	e8 7b ff ff ff       	call   8009f5 <memmove>
}
  800a7a:	c9                   	leave  
  800a7b:	c3                   	ret    

00800a7c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	8b 55 08             	mov    0x8(%ebp),%edx
  800a84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a87:	89 d6                	mov    %edx,%esi
  800a89:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8c:	eb 19                	jmp    800aa7 <memcmp+0x2b>
		if (*s1 != *s2)
  800a8e:	8a 02                	mov    (%edx),%al
  800a90:	8a 19                	mov    (%ecx),%bl
  800a92:	38 d8                	cmp    %bl,%al
  800a94:	74 0f                	je     800aa5 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800a96:	25 ff 00 00 00       	and    $0xff,%eax
  800a9b:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800aa1:	29 d8                	sub    %ebx,%eax
  800aa3:	eb 0b                	jmp    800ab0 <memcmp+0x34>
		s1++, s2++;
  800aa5:	42                   	inc    %edx
  800aa6:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa7:	39 f2                	cmp    %esi,%edx
  800aa9:	75 e3                	jne    800a8e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800abd:	89 c2                	mov    %eax,%edx
  800abf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac2:	eb 05                	jmp    800ac9 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac4:	38 08                	cmp    %cl,(%eax)
  800ac6:	74 05                	je     800acd <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ac8:	40                   	inc    %eax
  800ac9:	39 d0                	cmp    %edx,%eax
  800acb:	72 f7                	jb     800ac4 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
  800ad5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800adb:	eb 01                	jmp    800ade <strtol+0xf>
		s++;
  800add:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ade:	8a 02                	mov    (%edx),%al
  800ae0:	3c 09                	cmp    $0x9,%al
  800ae2:	74 f9                	je     800add <strtol+0xe>
  800ae4:	3c 20                	cmp    $0x20,%al
  800ae6:	74 f5                	je     800add <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ae8:	3c 2b                	cmp    $0x2b,%al
  800aea:	75 08                	jne    800af4 <strtol+0x25>
		s++;
  800aec:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aed:	bf 00 00 00 00       	mov    $0x0,%edi
  800af2:	eb 10                	jmp    800b04 <strtol+0x35>
  800af4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800af9:	3c 2d                	cmp    $0x2d,%al
  800afb:	75 07                	jne    800b04 <strtol+0x35>
		s++, neg = 1;
  800afd:	8d 52 01             	lea    0x1(%edx),%edx
  800b00:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b04:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b0a:	75 15                	jne    800b21 <strtol+0x52>
  800b0c:	80 3a 30             	cmpb   $0x30,(%edx)
  800b0f:	75 10                	jne    800b21 <strtol+0x52>
  800b11:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b15:	75 0a                	jne    800b21 <strtol+0x52>
		s += 2, base = 16;
  800b17:	83 c2 02             	add    $0x2,%edx
  800b1a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b1f:	eb 0e                	jmp    800b2f <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800b21:	85 db                	test   %ebx,%ebx
  800b23:	75 0a                	jne    800b2f <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b25:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b27:	80 3a 30             	cmpb   $0x30,(%edx)
  800b2a:	75 03                	jne    800b2f <strtol+0x60>
		s++, base = 8;
  800b2c:	42                   	inc    %edx
  800b2d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b34:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b37:	8a 0a                	mov    (%edx),%cl
  800b39:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b3c:	89 f3                	mov    %esi,%ebx
  800b3e:	80 fb 09             	cmp    $0x9,%bl
  800b41:	77 08                	ja     800b4b <strtol+0x7c>
			dig = *s - '0';
  800b43:	0f be c9             	movsbl %cl,%ecx
  800b46:	83 e9 30             	sub    $0x30,%ecx
  800b49:	eb 22                	jmp    800b6d <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800b4b:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b4e:	89 f3                	mov    %esi,%ebx
  800b50:	80 fb 19             	cmp    $0x19,%bl
  800b53:	77 08                	ja     800b5d <strtol+0x8e>
			dig = *s - 'a' + 10;
  800b55:	0f be c9             	movsbl %cl,%ecx
  800b58:	83 e9 57             	sub    $0x57,%ecx
  800b5b:	eb 10                	jmp    800b6d <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800b5d:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b60:	89 f3                	mov    %esi,%ebx
  800b62:	80 fb 19             	cmp    $0x19,%bl
  800b65:	77 14                	ja     800b7b <strtol+0xac>
			dig = *s - 'A' + 10;
  800b67:	0f be c9             	movsbl %cl,%ecx
  800b6a:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b6d:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b70:	7d 0d                	jge    800b7f <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b72:	42                   	inc    %edx
  800b73:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b77:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b79:	eb bc                	jmp    800b37 <strtol+0x68>
  800b7b:	89 c1                	mov    %eax,%ecx
  800b7d:	eb 02                	jmp    800b81 <strtol+0xb2>
  800b7f:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b81:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b85:	74 05                	je     800b8c <strtol+0xbd>
		*endptr = (char *) s;
  800b87:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b8a:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b8c:	85 ff                	test   %edi,%edi
  800b8e:	74 04                	je     800b94 <strtol+0xc5>
  800b90:	89 c8                	mov    %ecx,%eax
  800b92:	f7 d8                	neg    %eax
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    
  800b99:	66 90                	xchg   %ax,%ax
  800b9b:	90                   	nop

00800b9c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bad:	89 c3                	mov    %eax,%ebx
  800baf:	89 c7                	mov    %eax,%edi
  800bb1:	89 c6                	mov    %eax,%esi
  800bb3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_cgetc>:

int
sys_cgetc(void)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bca:	89 d1                	mov    %edx,%ecx
  800bcc:	89 d3                	mov    %edx,%ebx
  800bce:	89 d7                	mov    %edx,%edi
  800bd0:	89 d6                	mov    %edx,%esi
  800bd2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be7:	b8 03 00 00 00       	mov    $0x3,%eax
  800bec:	8b 55 08             	mov    0x8(%ebp),%edx
  800bef:	89 cb                	mov    %ecx,%ebx
  800bf1:	89 cf                	mov    %ecx,%edi
  800bf3:	89 ce                	mov    %ecx,%esi
  800bf5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf7:	85 c0                	test   %eax,%eax
  800bf9:	7e 28                	jle    800c23 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bff:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c06:	00 
  800c07:	c7 44 24 08 a8 14 80 	movl   $0x8014a8,0x8(%esp)
  800c0e:	00 
  800c0f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c16:	00 
  800c17:	c7 04 24 c5 14 80 00 	movl   $0x8014c5,(%esp)
  800c1e:	e8 5d f5 ff ff       	call   800180 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c23:	83 c4 2c             	add    $0x2c,%esp
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c31:	ba 00 00 00 00       	mov    $0x0,%edx
  800c36:	b8 02 00 00 00       	mov    $0x2,%eax
  800c3b:	89 d1                	mov    %edx,%ecx
  800c3d:	89 d3                	mov    %edx,%ebx
  800c3f:	89 d7                	mov    %edx,%edi
  800c41:	89 d6                	mov    %edx,%esi
  800c43:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <sys_yield>:

void
sys_yield(void)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c50:	ba 00 00 00 00       	mov    $0x0,%edx
  800c55:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c5a:	89 d1                	mov    %edx,%ecx
  800c5c:	89 d3                	mov    %edx,%ebx
  800c5e:	89 d7                	mov    %edx,%edi
  800c60:	89 d6                	mov    %edx,%esi
  800c62:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c72:	be 00 00 00 00       	mov    $0x0,%esi
  800c77:	b8 04 00 00 00       	mov    $0x4,%eax
  800c7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c82:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c85:	89 f7                	mov    %esi,%edi
  800c87:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	7e 28                	jle    800cb5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c91:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c98:	00 
  800c99:	c7 44 24 08 a8 14 80 	movl   $0x8014a8,0x8(%esp)
  800ca0:	00 
  800ca1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca8:	00 
  800ca9:	c7 04 24 c5 14 80 00 	movl   $0x8014c5,(%esp)
  800cb0:	e8 cb f4 ff ff       	call   800180 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb5:	83 c4 2c             	add    $0x2c,%esp
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
  800cc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc6:	b8 05 00 00 00       	mov    $0x5,%eax
  800ccb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd7:	8b 75 18             	mov    0x18(%ebp),%esi
  800cda:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cdc:	85 c0                	test   %eax,%eax
  800cde:	7e 28                	jle    800d08 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ceb:	00 
  800cec:	c7 44 24 08 a8 14 80 	movl   $0x8014a8,0x8(%esp)
  800cf3:	00 
  800cf4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfb:	00 
  800cfc:	c7 04 24 c5 14 80 00 	movl   $0x8014c5,(%esp)
  800d03:	e8 78 f4 ff ff       	call   800180 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d08:	83 c4 2c             	add    $0x2c,%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	57                   	push   %edi
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
  800d16:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	89 df                	mov    %ebx,%edi
  800d2b:	89 de                	mov    %ebx,%esi
  800d2d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2f:	85 c0                	test   %eax,%eax
  800d31:	7e 28                	jle    800d5b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d33:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d37:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d3e:	00 
  800d3f:	c7 44 24 08 a8 14 80 	movl   $0x8014a8,0x8(%esp)
  800d46:	00 
  800d47:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4e:	00 
  800d4f:	c7 04 24 c5 14 80 00 	movl   $0x8014c5,(%esp)
  800d56:	e8 25 f4 ff ff       	call   800180 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d5b:	83 c4 2c             	add    $0x2c,%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d71:	b8 08 00 00 00       	mov    $0x8,%eax
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	89 df                	mov    %ebx,%edi
  800d7e:	89 de                	mov    %ebx,%esi
  800d80:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d82:	85 c0                	test   %eax,%eax
  800d84:	7e 28                	jle    800dae <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d86:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d91:	00 
  800d92:	c7 44 24 08 a8 14 80 	movl   $0x8014a8,0x8(%esp)
  800d99:	00 
  800d9a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da1:	00 
  800da2:	c7 04 24 c5 14 80 00 	movl   $0x8014c5,(%esp)
  800da9:	e8 d2 f3 ff ff       	call   800180 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dae:	83 c4 2c             	add    $0x2c,%esp
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	57                   	push   %edi
  800dba:	56                   	push   %esi
  800dbb:	53                   	push   %ebx
  800dbc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc4:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcf:	89 df                	mov    %ebx,%edi
  800dd1:	89 de                	mov    %ebx,%esi
  800dd3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	7e 28                	jle    800e01 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ddd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800de4:	00 
  800de5:	c7 44 24 08 a8 14 80 	movl   $0x8014a8,0x8(%esp)
  800dec:	00 
  800ded:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df4:	00 
  800df5:	c7 04 24 c5 14 80 00 	movl   $0x8014c5,(%esp)
  800dfc:	e8 7f f3 ff ff       	call   800180 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e01:	83 c4 2c             	add    $0x2c,%esp
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	57                   	push   %edi
  800e0d:	56                   	push   %esi
  800e0e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0f:	be 00 00 00 00       	mov    $0x0,%esi
  800e14:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e22:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e25:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e27:	5b                   	pop    %ebx
  800e28:	5e                   	pop    %esi
  800e29:	5f                   	pop    %edi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	57                   	push   %edi
  800e30:	56                   	push   %esi
  800e31:	53                   	push   %ebx
  800e32:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e3a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	89 cb                	mov    %ecx,%ebx
  800e44:	89 cf                	mov    %ecx,%edi
  800e46:	89 ce                	mov    %ecx,%esi
  800e48:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e4a:	85 c0                	test   %eax,%eax
  800e4c:	7e 28                	jle    800e76 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e52:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e59:	00 
  800e5a:	c7 44 24 08 a8 14 80 	movl   $0x8014a8,0x8(%esp)
  800e61:	00 
  800e62:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e69:	00 
  800e6a:	c7 04 24 c5 14 80 00 	movl   $0x8014c5,(%esp)
  800e71:	e8 0a f3 ff ff       	call   800180 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e76:	83 c4 2c             	add    $0x2c,%esp
  800e79:	5b                   	pop    %ebx
  800e7a:	5e                   	pop    %esi
  800e7b:	5f                   	pop    %edi
  800e7c:	5d                   	pop    %ebp
  800e7d:	c3                   	ret    
  800e7e:	66 90                	xchg   %ax,%ax

00800e80 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e86:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e8d:	75 32                	jne    800ec1 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
    //region_alloc(curenv, (void *)UXSTACKTOP - PGSIZE, PGSIZE);
		//panic("set_pgfault_handler not implemented");
		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  800e8f:	e8 97 fd ff ff       	call   800c2b <sys_getenvid>
  800e94:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e9b:	00 
  800e9c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800ea3:	ee 
  800ea4:	89 04 24             	mov    %eax,(%esp)
  800ea7:	e8 bd fd ff ff       	call   800c69 <sys_page_alloc>
    sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800eac:	e8 7a fd ff ff       	call   800c2b <sys_getenvid>
  800eb1:	c7 44 24 04 cc 0e 80 	movl   $0x800ecc,0x4(%esp)
  800eb8:	00 
  800eb9:	89 04 24             	mov    %eax,(%esp)
  800ebc:	e8 f5 fe ff ff       	call   800db6 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ec1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec4:	a3 08 20 80 00       	mov    %eax,0x802008

}
  800ec9:	c9                   	leave  
  800eca:	c3                   	ret    
  800ecb:	90                   	nop

00800ecc <_pgfault_upcall>:
  800ecc:	54                   	push   %esp
  800ecd:	a1 08 20 80 00       	mov    0x802008,%eax
  800ed2:	ff d0                	call   *%eax
  800ed4:	83 c4 04             	add    $0x4,%esp
  800ed7:	8b 44 24 28          	mov    0x28(%esp),%eax
  800edb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800edf:	89 43 fc             	mov    %eax,-0x4(%ebx)
  800ee2:	83 eb 04             	sub    $0x4,%ebx
  800ee5:	89 5c 24 30          	mov    %ebx,0x30(%esp)
  800ee9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800eed:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800ef1:	8b 6c 24 10          	mov    0x10(%esp),%ebp
  800ef5:	8b 5c 24 18          	mov    0x18(%esp),%ebx
  800ef9:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  800efd:	8b 4c 24 20          	mov    0x20(%esp),%ecx
  800f01:	8b 44 24 24          	mov    0x24(%esp),%eax
  800f05:	ff 74 24 2c          	pushl  0x2c(%esp)
  800f09:	9d                   	popf   
  800f0a:	8b 64 24 30          	mov    0x30(%esp),%esp
  800f0e:	c3                   	ret    
  800f0f:	90                   	nop

00800f10 <__udivdi3>:
  800f10:	55                   	push   %ebp
  800f11:	57                   	push   %edi
  800f12:	56                   	push   %esi
  800f13:	83 ec 0c             	sub    $0xc,%esp
  800f16:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800f1a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800f1e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f22:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f26:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f2a:	89 ea                	mov    %ebp,%edx
  800f2c:	89 0c 24             	mov    %ecx,(%esp)
  800f2f:	85 c0                	test   %eax,%eax
  800f31:	75 2d                	jne    800f60 <__udivdi3+0x50>
  800f33:	39 e9                	cmp    %ebp,%ecx
  800f35:	77 61                	ja     800f98 <__udivdi3+0x88>
  800f37:	89 ce                	mov    %ecx,%esi
  800f39:	85 c9                	test   %ecx,%ecx
  800f3b:	75 0b                	jne    800f48 <__udivdi3+0x38>
  800f3d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f42:	31 d2                	xor    %edx,%edx
  800f44:	f7 f1                	div    %ecx
  800f46:	89 c6                	mov    %eax,%esi
  800f48:	31 d2                	xor    %edx,%edx
  800f4a:	89 e8                	mov    %ebp,%eax
  800f4c:	f7 f6                	div    %esi
  800f4e:	89 c5                	mov    %eax,%ebp
  800f50:	89 f8                	mov    %edi,%eax
  800f52:	f7 f6                	div    %esi
  800f54:	89 ea                	mov    %ebp,%edx
  800f56:	83 c4 0c             	add    $0xc,%esp
  800f59:	5e                   	pop    %esi
  800f5a:	5f                   	pop    %edi
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    
  800f5d:	8d 76 00             	lea    0x0(%esi),%esi
  800f60:	39 e8                	cmp    %ebp,%eax
  800f62:	77 24                	ja     800f88 <__udivdi3+0x78>
  800f64:	0f bd e8             	bsr    %eax,%ebp
  800f67:	83 f5 1f             	xor    $0x1f,%ebp
  800f6a:	75 3c                	jne    800fa8 <__udivdi3+0x98>
  800f6c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f70:	39 34 24             	cmp    %esi,(%esp)
  800f73:	0f 86 9f 00 00 00    	jbe    801018 <__udivdi3+0x108>
  800f79:	39 d0                	cmp    %edx,%eax
  800f7b:	0f 82 97 00 00 00    	jb     801018 <__udivdi3+0x108>
  800f81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f88:	31 d2                	xor    %edx,%edx
  800f8a:	31 c0                	xor    %eax,%eax
  800f8c:	83 c4 0c             	add    $0xc,%esp
  800f8f:	5e                   	pop    %esi
  800f90:	5f                   	pop    %edi
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    
  800f93:	90                   	nop
  800f94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f98:	89 f8                	mov    %edi,%eax
  800f9a:	f7 f1                	div    %ecx
  800f9c:	31 d2                	xor    %edx,%edx
  800f9e:	83 c4 0c             	add    $0xc,%esp
  800fa1:	5e                   	pop    %esi
  800fa2:	5f                   	pop    %edi
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    
  800fa5:	8d 76 00             	lea    0x0(%esi),%esi
  800fa8:	89 e9                	mov    %ebp,%ecx
  800faa:	8b 3c 24             	mov    (%esp),%edi
  800fad:	d3 e0                	shl    %cl,%eax
  800faf:	89 c6                	mov    %eax,%esi
  800fb1:	b8 20 00 00 00       	mov    $0x20,%eax
  800fb6:	29 e8                	sub    %ebp,%eax
  800fb8:	88 c1                	mov    %al,%cl
  800fba:	d3 ef                	shr    %cl,%edi
  800fbc:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fc0:	89 e9                	mov    %ebp,%ecx
  800fc2:	8b 3c 24             	mov    (%esp),%edi
  800fc5:	09 74 24 08          	or     %esi,0x8(%esp)
  800fc9:	d3 e7                	shl    %cl,%edi
  800fcb:	89 d6                	mov    %edx,%esi
  800fcd:	88 c1                	mov    %al,%cl
  800fcf:	d3 ee                	shr    %cl,%esi
  800fd1:	89 e9                	mov    %ebp,%ecx
  800fd3:	89 3c 24             	mov    %edi,(%esp)
  800fd6:	d3 e2                	shl    %cl,%edx
  800fd8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fdc:	88 c1                	mov    %al,%cl
  800fde:	d3 ef                	shr    %cl,%edi
  800fe0:	09 d7                	or     %edx,%edi
  800fe2:	89 f2                	mov    %esi,%edx
  800fe4:	89 f8                	mov    %edi,%eax
  800fe6:	f7 74 24 08          	divl   0x8(%esp)
  800fea:	89 d6                	mov    %edx,%esi
  800fec:	89 c7                	mov    %eax,%edi
  800fee:	f7 24 24             	mull   (%esp)
  800ff1:	89 14 24             	mov    %edx,(%esp)
  800ff4:	39 d6                	cmp    %edx,%esi
  800ff6:	72 30                	jb     801028 <__udivdi3+0x118>
  800ff8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ffc:	89 e9                	mov    %ebp,%ecx
  800ffe:	d3 e2                	shl    %cl,%edx
  801000:	39 c2                	cmp    %eax,%edx
  801002:	73 05                	jae    801009 <__udivdi3+0xf9>
  801004:	3b 34 24             	cmp    (%esp),%esi
  801007:	74 1f                	je     801028 <__udivdi3+0x118>
  801009:	89 f8                	mov    %edi,%eax
  80100b:	31 d2                	xor    %edx,%edx
  80100d:	e9 7a ff ff ff       	jmp    800f8c <__udivdi3+0x7c>
  801012:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801018:	31 d2                	xor    %edx,%edx
  80101a:	b8 01 00 00 00       	mov    $0x1,%eax
  80101f:	e9 68 ff ff ff       	jmp    800f8c <__udivdi3+0x7c>
  801024:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801028:	8d 47 ff             	lea    -0x1(%edi),%eax
  80102b:	31 d2                	xor    %edx,%edx
  80102d:	83 c4 0c             	add    $0xc,%esp
  801030:	5e                   	pop    %esi
  801031:	5f                   	pop    %edi
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    
  801034:	66 90                	xchg   %ax,%ax
  801036:	66 90                	xchg   %ax,%ax
  801038:	66 90                	xchg   %ax,%ax
  80103a:	66 90                	xchg   %ax,%ax
  80103c:	66 90                	xchg   %ax,%ax
  80103e:	66 90                	xchg   %ax,%ax

00801040 <__umoddi3>:
  801040:	55                   	push   %ebp
  801041:	57                   	push   %edi
  801042:	56                   	push   %esi
  801043:	83 ec 14             	sub    $0x14,%esp
  801046:	8b 44 24 28          	mov    0x28(%esp),%eax
  80104a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80104e:	89 c7                	mov    %eax,%edi
  801050:	89 44 24 04          	mov    %eax,0x4(%esp)
  801054:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801058:	8b 44 24 30          	mov    0x30(%esp),%eax
  80105c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801060:	89 34 24             	mov    %esi,(%esp)
  801063:	89 c2                	mov    %eax,%edx
  801065:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801069:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80106d:	85 c0                	test   %eax,%eax
  80106f:	75 17                	jne    801088 <__umoddi3+0x48>
  801071:	39 fe                	cmp    %edi,%esi
  801073:	76 4b                	jbe    8010c0 <__umoddi3+0x80>
  801075:	89 c8                	mov    %ecx,%eax
  801077:	89 fa                	mov    %edi,%edx
  801079:	f7 f6                	div    %esi
  80107b:	89 d0                	mov    %edx,%eax
  80107d:	31 d2                	xor    %edx,%edx
  80107f:	83 c4 14             	add    $0x14,%esp
  801082:	5e                   	pop    %esi
  801083:	5f                   	pop    %edi
  801084:	5d                   	pop    %ebp
  801085:	c3                   	ret    
  801086:	66 90                	xchg   %ax,%ax
  801088:	39 f8                	cmp    %edi,%eax
  80108a:	77 54                	ja     8010e0 <__umoddi3+0xa0>
  80108c:	0f bd e8             	bsr    %eax,%ebp
  80108f:	83 f5 1f             	xor    $0x1f,%ebp
  801092:	75 5c                	jne    8010f0 <__umoddi3+0xb0>
  801094:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801098:	39 3c 24             	cmp    %edi,(%esp)
  80109b:	0f 87 f7 00 00 00    	ja     801198 <__umoddi3+0x158>
  8010a1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010a5:	29 f1                	sub    %esi,%ecx
  8010a7:	19 c7                	sbb    %eax,%edi
  8010a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010ad:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010b1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010b5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8010b9:	83 c4 14             	add    $0x14,%esp
  8010bc:	5e                   	pop    %esi
  8010bd:	5f                   	pop    %edi
  8010be:	5d                   	pop    %ebp
  8010bf:	c3                   	ret    
  8010c0:	89 f5                	mov    %esi,%ebp
  8010c2:	85 f6                	test   %esi,%esi
  8010c4:	75 0b                	jne    8010d1 <__umoddi3+0x91>
  8010c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010cb:	31 d2                	xor    %edx,%edx
  8010cd:	f7 f6                	div    %esi
  8010cf:	89 c5                	mov    %eax,%ebp
  8010d1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010d5:	31 d2                	xor    %edx,%edx
  8010d7:	f7 f5                	div    %ebp
  8010d9:	89 c8                	mov    %ecx,%eax
  8010db:	f7 f5                	div    %ebp
  8010dd:	eb 9c                	jmp    80107b <__umoddi3+0x3b>
  8010df:	90                   	nop
  8010e0:	89 c8                	mov    %ecx,%eax
  8010e2:	89 fa                	mov    %edi,%edx
  8010e4:	83 c4 14             	add    $0x14,%esp
  8010e7:	5e                   	pop    %esi
  8010e8:	5f                   	pop    %edi
  8010e9:	5d                   	pop    %ebp
  8010ea:	c3                   	ret    
  8010eb:	90                   	nop
  8010ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010f0:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8010f7:	00 
  8010f8:	8b 34 24             	mov    (%esp),%esi
  8010fb:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010ff:	89 e9                	mov    %ebp,%ecx
  801101:	29 e8                	sub    %ebp,%eax
  801103:	89 44 24 04          	mov    %eax,0x4(%esp)
  801107:	89 f0                	mov    %esi,%eax
  801109:	d3 e2                	shl    %cl,%edx
  80110b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  80110f:	d3 e8                	shr    %cl,%eax
  801111:	89 04 24             	mov    %eax,(%esp)
  801114:	89 e9                	mov    %ebp,%ecx
  801116:	89 f0                	mov    %esi,%eax
  801118:	09 14 24             	or     %edx,(%esp)
  80111b:	d3 e0                	shl    %cl,%eax
  80111d:	89 fa                	mov    %edi,%edx
  80111f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801123:	d3 ea                	shr    %cl,%edx
  801125:	89 e9                	mov    %ebp,%ecx
  801127:	89 c6                	mov    %eax,%esi
  801129:	d3 e7                	shl    %cl,%edi
  80112b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80112f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801133:	8b 44 24 10          	mov    0x10(%esp),%eax
  801137:	d3 e8                	shr    %cl,%eax
  801139:	09 f8                	or     %edi,%eax
  80113b:	89 e9                	mov    %ebp,%ecx
  80113d:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801141:	d3 e7                	shl    %cl,%edi
  801143:	f7 34 24             	divl   (%esp)
  801146:	89 d1                	mov    %edx,%ecx
  801148:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80114c:	f7 e6                	mul    %esi
  80114e:	89 c7                	mov    %eax,%edi
  801150:	89 d6                	mov    %edx,%esi
  801152:	39 d1                	cmp    %edx,%ecx
  801154:	72 2e                	jb     801184 <__umoddi3+0x144>
  801156:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80115a:	72 24                	jb     801180 <__umoddi3+0x140>
  80115c:	89 ca                	mov    %ecx,%edx
  80115e:	89 e9                	mov    %ebp,%ecx
  801160:	8b 44 24 08          	mov    0x8(%esp),%eax
  801164:	29 f8                	sub    %edi,%eax
  801166:	19 f2                	sbb    %esi,%edx
  801168:	d3 e8                	shr    %cl,%eax
  80116a:	89 d6                	mov    %edx,%esi
  80116c:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801170:	d3 e6                	shl    %cl,%esi
  801172:	89 e9                	mov    %ebp,%ecx
  801174:	09 f0                	or     %esi,%eax
  801176:	d3 ea                	shr    %cl,%edx
  801178:	83 c4 14             	add    $0x14,%esp
  80117b:	5e                   	pop    %esi
  80117c:	5f                   	pop    %edi
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    
  80117f:	90                   	nop
  801180:	39 d1                	cmp    %edx,%ecx
  801182:	75 d8                	jne    80115c <__umoddi3+0x11c>
  801184:	89 d6                	mov    %edx,%esi
  801186:	89 c7                	mov    %eax,%edi
  801188:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  80118c:	1b 34 24             	sbb    (%esp),%esi
  80118f:	eb cb                	jmp    80115c <__umoddi3+0x11c>
  801191:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801198:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80119c:	0f 82 ff fe ff ff    	jb     8010a1 <__umoddi3+0x61>
  8011a2:	e9 0a ff ff ff       	jmp    8010b1 <__umoddi3+0x71>
