
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
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
  800044:	c7 04 24 a0 11 80 00 	movl   $0x8011a0,(%esp)
  80004b:	e8 16 02 00 00       	call   800266 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 e6 0b 00 00       	call   800c55 <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 c0 11 80 	movl   $0x8011c0,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 aa 11 80 00 	movl   $0x8011aa,(%esp)
  800092:	e8 d5 00 00 00       	call   80016c <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 ec 11 80 	movl   $0x8011ec,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 3f 07 00 00       	call   8007f2 <snprintf>
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
  8000c6:	e8 a1 0d 00 00       	call   800e6c <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000cb:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000da:	e8 a9 0a 00 00       	call   800b88 <sys_cputs>
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	66 90                	xchg   %ax,%ax
  8000e3:	90                   	nop

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 10             	sub    $0x10,%esp
  8000ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ef:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  8000f2:	b8 0c 20 80 00       	mov    $0x80200c,%eax
  8000f7:	2d 04 20 80 00       	sub    $0x802004,%eax
  8000fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800100:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800107:	00 
  800108:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  80010f:	e8 7f 08 00 00       	call   800993 <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  800114:	e8 fe 0a 00 00       	call   800c17 <sys_getenvid>
  800119:	25 ff 03 00 00       	and    $0x3ff,%eax
  80011e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800125:	c1 e0 07             	shl    $0x7,%eax
  800128:	29 d0                	sub    %edx,%eax
  80012a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800134:	85 db                	test   %ebx,%ebx
  800136:	7e 07                	jle    80013f <libmain+0x5b>
		binaryname = argv[0];
  800138:	8b 06                	mov    (%esi),%eax
  80013a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80013f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800143:	89 1c 24             	mov    %ebx,(%esp)
  800146:	e8 6e ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  80014b:	e8 08 00 00 00       	call   800158 <exit>
}
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	5b                   	pop    %ebx
  800154:	5e                   	pop    %esi
  800155:	5d                   	pop    %ebp
  800156:	c3                   	ret    
  800157:	90                   	nop

00800158 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80015e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800165:	e8 5b 0a 00 00       	call   800bc5 <sys_env_destroy>
}
  80016a:	c9                   	leave  
  80016b:	c3                   	ret    

0080016c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
  800171:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800174:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800177:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80017d:	e8 95 0a 00 00       	call   800c17 <sys_getenvid>
  800182:	8b 55 0c             	mov    0xc(%ebp),%edx
  800185:	89 54 24 10          	mov    %edx,0x10(%esp)
  800189:	8b 55 08             	mov    0x8(%ebp),%edx
  80018c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800190:	89 74 24 08          	mov    %esi,0x8(%esp)
  800194:	89 44 24 04          	mov    %eax,0x4(%esp)
  800198:	c7 04 24 18 12 80 00 	movl   $0x801218,(%esp)
  80019f:	e8 c2 00 00 00       	call   800266 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ab:	89 04 24             	mov    %eax,(%esp)
  8001ae:	e8 52 00 00 00       	call   800205 <vcprintf>
	cprintf("\n");
  8001b3:	c7 04 24 a8 11 80 00 	movl   $0x8011a8,(%esp)
  8001ba:	e8 a7 00 00 00       	call   800266 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001bf:	cc                   	int3   
  8001c0:	eb fd                	jmp    8001bf <_panic+0x53>
  8001c2:	66 90                	xchg   %ax,%ax

008001c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	53                   	push   %ebx
  8001c8:	83 ec 14             	sub    $0x14,%esp
  8001cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ce:	8b 13                	mov    (%ebx),%edx
  8001d0:	8d 42 01             	lea    0x1(%edx),%eax
  8001d3:	89 03                	mov    %eax,(%ebx)
  8001d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001dc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e1:	75 19                	jne    8001fc <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001e3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ea:	00 
  8001eb:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ee:	89 04 24             	mov    %eax,(%esp)
  8001f1:	e8 92 09 00 00       	call   800b88 <sys_cputs>
		b->idx = 0;
  8001f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001fc:	ff 43 04             	incl   0x4(%ebx)
}
  8001ff:	83 c4 14             	add    $0x14,%esp
  800202:	5b                   	pop    %ebx
  800203:	5d                   	pop    %ebp
  800204:	c3                   	ret    

00800205 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80020e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800215:	00 00 00 
	b.cnt = 0;
  800218:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80021f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800222:	8b 45 0c             	mov    0xc(%ebp),%eax
  800225:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800229:	8b 45 08             	mov    0x8(%ebp),%eax
  80022c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800230:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800236:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023a:	c7 04 24 c4 01 80 00 	movl   $0x8001c4,(%esp)
  800241:	e8 a9 01 00 00       	call   8003ef <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800246:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80024c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800250:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800256:	89 04 24             	mov    %eax,(%esp)
  800259:	e8 2a 09 00 00       	call   800b88 <sys_cputs>

	return b.cnt;
}
  80025e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800264:	c9                   	leave  
  800265:	c3                   	ret    

00800266 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
  800269:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80026f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800273:	8b 45 08             	mov    0x8(%ebp),%eax
  800276:	89 04 24             	mov    %eax,(%esp)
  800279:	e8 87 ff ff ff       	call   800205 <vcprintf>
	va_end(ap);

	return cnt;
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 3c             	sub    $0x3c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d7                	mov    %edx,%edi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
  800297:	89 c1                	mov    %eax,%ecx
  800299:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80029c:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029f:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002aa:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002ad:	39 ca                	cmp    %ecx,%edx
  8002af:	72 08                	jb     8002b9 <printnum+0x39>
  8002b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002b7:	77 6a                	ja     800323 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b9:	8b 45 18             	mov    0x18(%ebp),%eax
  8002bc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002c0:	4e                   	dec    %esi
  8002c1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002cc:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002d0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002d4:	89 c3                	mov    %eax,%ebx
  8002d6:	89 d6                	mov    %edx,%esi
  8002d8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002db:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002e9:	89 04 24             	mov    %eax,(%esp)
  8002ec:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f3:	e8 08 0c 00 00       	call   800f00 <__udivdi3>
  8002f8:	89 d9                	mov    %ebx,%ecx
  8002fa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002fe:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800302:	89 04 24             	mov    %eax,(%esp)
  800305:	89 54 24 04          	mov    %edx,0x4(%esp)
  800309:	89 fa                	mov    %edi,%edx
  80030b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80030e:	e8 6d ff ff ff       	call   800280 <printnum>
  800313:	eb 19                	jmp    80032e <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800315:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800319:	8b 45 18             	mov    0x18(%ebp),%eax
  80031c:	89 04 24             	mov    %eax,(%esp)
  80031f:	ff d3                	call   *%ebx
  800321:	eb 03                	jmp    800326 <printnum+0xa6>
  800323:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800326:	4e                   	dec    %esi
  800327:	85 f6                	test   %esi,%esi
  800329:	7f ea                	jg     800315 <printnum+0x95>
  80032b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80032e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800332:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800336:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800339:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80033c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800340:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800344:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800347:	89 04 24             	mov    %eax,(%esp)
  80034a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80034d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800351:	e8 da 0c 00 00       	call   801030 <__umoddi3>
  800356:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80035a:	0f be 80 3c 12 80 00 	movsbl 0x80123c(%eax),%eax
  800361:	89 04 24             	mov    %eax,(%esp)
  800364:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800367:	ff d0                	call   *%eax
}
  800369:	83 c4 3c             	add    $0x3c,%esp
  80036c:	5b                   	pop    %ebx
  80036d:	5e                   	pop    %esi
  80036e:	5f                   	pop    %edi
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800374:	83 fa 01             	cmp    $0x1,%edx
  800377:	7e 0e                	jle    800387 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 02                	mov    (%edx),%eax
  800382:	8b 52 04             	mov    0x4(%edx),%edx
  800385:	eb 22                	jmp    8003a9 <getuint+0x38>
	else if (lflag)
  800387:	85 d2                	test   %edx,%edx
  800389:	74 10                	je     80039b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80038b:	8b 10                	mov    (%eax),%edx
  80038d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800390:	89 08                	mov    %ecx,(%eax)
  800392:	8b 02                	mov    (%edx),%eax
  800394:	ba 00 00 00 00       	mov    $0x0,%edx
  800399:	eb 0e                	jmp    8003a9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80039b:	8b 10                	mov    (%eax),%edx
  80039d:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a0:	89 08                	mov    %ecx,(%eax)
  8003a2:	8b 02                	mov    (%edx),%eax
  8003a4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003a9:	5d                   	pop    %ebp
  8003aa:	c3                   	ret    

008003ab <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b1:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003b4:	8b 10                	mov    (%eax),%edx
  8003b6:	3b 50 04             	cmp    0x4(%eax),%edx
  8003b9:	73 0a                	jae    8003c5 <sprintputch+0x1a>
		*b->buf++ = ch;
  8003bb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003be:	89 08                	mov    %ecx,(%eax)
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c3:	88 02                	mov    %al,(%edx)
}
  8003c5:	5d                   	pop    %ebp
  8003c6:	c3                   	ret    

008003c7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003cd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e5:	89 04 24             	mov    %eax,(%esp)
  8003e8:	e8 02 00 00 00       	call   8003ef <vprintfmt>
	va_end(ap);
}
  8003ed:	c9                   	leave  
  8003ee:	c3                   	ret    

008003ef <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	57                   	push   %edi
  8003f3:	56                   	push   %esi
  8003f4:	53                   	push   %ebx
  8003f5:	83 ec 3c             	sub    $0x3c,%esp
  8003f8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003fe:	eb 14                	jmp    800414 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800400:	85 c0                	test   %eax,%eax
  800402:	0f 84 8a 03 00 00    	je     800792 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  800408:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80040c:	89 04 24             	mov    %eax,(%esp)
  80040f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800412:	89 f3                	mov    %esi,%ebx
  800414:	8d 73 01             	lea    0x1(%ebx),%esi
  800417:	31 c0                	xor    %eax,%eax
  800419:	8a 03                	mov    (%ebx),%al
  80041b:	83 f8 25             	cmp    $0x25,%eax
  80041e:	75 e0                	jne    800400 <vprintfmt+0x11>
  800420:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800424:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80042b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800432:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800439:	ba 00 00 00 00       	mov    $0x0,%edx
  80043e:	eb 1d                	jmp    80045d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800440:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800442:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800446:	eb 15                	jmp    80045d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800448:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80044a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80044e:	eb 0d                	jmp    80045d <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800450:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800453:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800456:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	8d 5e 01             	lea    0x1(%esi),%ebx
  800460:	31 c0                	xor    %eax,%eax
  800462:	8a 06                	mov    (%esi),%al
  800464:	8a 0e                	mov    (%esi),%cl
  800466:	83 e9 23             	sub    $0x23,%ecx
  800469:	88 4d e0             	mov    %cl,-0x20(%ebp)
  80046c:	80 f9 55             	cmp    $0x55,%cl
  80046f:	0f 87 ff 02 00 00    	ja     800774 <vprintfmt+0x385>
  800475:	31 c9                	xor    %ecx,%ecx
  800477:	8a 4d e0             	mov    -0x20(%ebp),%cl
  80047a:	ff 24 8d 00 13 80 00 	jmp    *0x801300(,%ecx,4)
  800481:	89 de                	mov    %ebx,%esi
  800483:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800488:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80048b:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  80048f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800492:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800495:	83 fb 09             	cmp    $0x9,%ebx
  800498:	77 2f                	ja     8004c9 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80049a:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80049b:	eb eb                	jmp    800488 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80049d:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a0:	8d 48 04             	lea    0x4(%eax),%ecx
  8004a3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004a6:	8b 00                	mov    (%eax),%eax
  8004a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ad:	eb 1d                	jmp    8004cc <vprintfmt+0xdd>
  8004af:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004b2:	f7 d0                	not    %eax
  8004b4:	c1 f8 1f             	sar    $0x1f,%eax
  8004b7:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	89 de                	mov    %ebx,%esi
  8004bc:	eb 9f                	jmp    80045d <vprintfmt+0x6e>
  8004be:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004c7:	eb 94                	jmp    80045d <vprintfmt+0x6e>
  8004c9:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004cc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004d0:	79 8b                	jns    80045d <vprintfmt+0x6e>
  8004d2:	e9 79 ff ff ff       	jmp    800450 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004d7:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d8:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004da:	eb 81                	jmp    80045d <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004df:	8d 50 04             	lea    0x4(%eax),%edx
  8004e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004e9:	8b 00                	mov    (%eax),%eax
  8004eb:	89 04 24             	mov    %eax,(%esp)
  8004ee:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004f1:	e9 1e ff ff ff       	jmp    800414 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f9:	8d 50 04             	lea    0x4(%eax),%edx
  8004fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ff:	8b 00                	mov    (%eax),%eax
  800501:	89 c2                	mov    %eax,%edx
  800503:	c1 fa 1f             	sar    $0x1f,%edx
  800506:	31 d0                	xor    %edx,%eax
  800508:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80050a:	83 f8 09             	cmp    $0x9,%eax
  80050d:	7f 0b                	jg     80051a <vprintfmt+0x12b>
  80050f:	8b 14 85 60 14 80 00 	mov    0x801460(,%eax,4),%edx
  800516:	85 d2                	test   %edx,%edx
  800518:	75 20                	jne    80053a <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  80051a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051e:	c7 44 24 08 54 12 80 	movl   $0x801254,0x8(%esp)
  800525:	00 
  800526:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052a:	8b 45 08             	mov    0x8(%ebp),%eax
  80052d:	89 04 24             	mov    %eax,(%esp)
  800530:	e8 92 fe ff ff       	call   8003c7 <printfmt>
  800535:	e9 da fe ff ff       	jmp    800414 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80053a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80053e:	c7 44 24 08 5d 12 80 	movl   $0x80125d,0x8(%esp)
  800545:	00 
  800546:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80054a:	8b 45 08             	mov    0x8(%ebp),%eax
  80054d:	89 04 24             	mov    %eax,(%esp)
  800550:	e8 72 fe ff ff       	call   8003c7 <printfmt>
  800555:	e9 ba fe ff ff       	jmp    800414 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80055d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800560:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8d 50 04             	lea    0x4(%eax),%edx
  800569:	89 55 14             	mov    %edx,0x14(%ebp)
  80056c:	8b 30                	mov    (%eax),%esi
  80056e:	85 f6                	test   %esi,%esi
  800570:	75 05                	jne    800577 <vprintfmt+0x188>
				p = "(null)";
  800572:	be 4d 12 80 00       	mov    $0x80124d,%esi
			if (width > 0 && padc != '-')
  800577:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80057b:	0f 84 8c 00 00 00    	je     80060d <vprintfmt+0x21e>
  800581:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800585:	0f 8e 8a 00 00 00    	jle    800615 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  80058b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80058f:	89 34 24             	mov    %esi,(%esp)
  800592:	e8 9b 02 00 00       	call   800832 <strnlen>
  800597:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80059a:	29 c1                	sub    %eax,%ecx
  80059c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  80059f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a6:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8005a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ac:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005af:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b1:	eb 0d                	jmp    8005c0 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8005b3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ba:	89 04 24             	mov    %eax,(%esp)
  8005bd:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bf:	4b                   	dec    %ebx
  8005c0:	85 db                	test   %ebx,%ebx
  8005c2:	7f ef                	jg     8005b3 <vprintfmt+0x1c4>
  8005c4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ca:	89 c8                	mov    %ecx,%eax
  8005cc:	f7 d0                	not    %eax
  8005ce:	c1 f8 1f             	sar    $0x1f,%eax
  8005d1:	21 c8                	and    %ecx,%eax
  8005d3:	29 c1                	sub    %eax,%ecx
  8005d5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005db:	eb 3e                	jmp    80061b <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e1:	74 1b                	je     8005fe <vprintfmt+0x20f>
  8005e3:	0f be d2             	movsbl %dl,%edx
  8005e6:	83 ea 20             	sub    $0x20,%edx
  8005e9:	83 fa 5e             	cmp    $0x5e,%edx
  8005ec:	76 10                	jbe    8005fe <vprintfmt+0x20f>
					putch('?', putdat);
  8005ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f2:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005f9:	ff 55 08             	call   *0x8(%ebp)
  8005fc:	eb 0a                	jmp    800608 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  8005fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800602:	89 04 24             	mov    %eax,(%esp)
  800605:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800608:	ff 4d dc             	decl   -0x24(%ebp)
  80060b:	eb 0e                	jmp    80061b <vprintfmt+0x22c>
  80060d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800610:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800613:	eb 06                	jmp    80061b <vprintfmt+0x22c>
  800615:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800618:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80061b:	46                   	inc    %esi
  80061c:	8a 56 ff             	mov    -0x1(%esi),%dl
  80061f:	0f be c2             	movsbl %dl,%eax
  800622:	85 c0                	test   %eax,%eax
  800624:	74 1f                	je     800645 <vprintfmt+0x256>
  800626:	85 db                	test   %ebx,%ebx
  800628:	78 b3                	js     8005dd <vprintfmt+0x1ee>
  80062a:	4b                   	dec    %ebx
  80062b:	79 b0                	jns    8005dd <vprintfmt+0x1ee>
  80062d:	8b 75 08             	mov    0x8(%ebp),%esi
  800630:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800633:	eb 16                	jmp    80064b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800635:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800639:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800640:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800642:	4b                   	dec    %ebx
  800643:	eb 06                	jmp    80064b <vprintfmt+0x25c>
  800645:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800648:	8b 75 08             	mov    0x8(%ebp),%esi
  80064b:	85 db                	test   %ebx,%ebx
  80064d:	7f e6                	jg     800635 <vprintfmt+0x246>
  80064f:	89 75 08             	mov    %esi,0x8(%ebp)
  800652:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800655:	e9 ba fd ff ff       	jmp    800414 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80065a:	83 fa 01             	cmp    $0x1,%edx
  80065d:	7e 16                	jle    800675 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8d 50 08             	lea    0x8(%eax),%edx
  800665:	89 55 14             	mov    %edx,0x14(%ebp)
  800668:	8b 50 04             	mov    0x4(%eax),%edx
  80066b:	8b 00                	mov    (%eax),%eax
  80066d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800670:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800673:	eb 32                	jmp    8006a7 <vprintfmt+0x2b8>
	else if (lflag)
  800675:	85 d2                	test   %edx,%edx
  800677:	74 18                	je     800691 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	8d 50 04             	lea    0x4(%eax),%edx
  80067f:	89 55 14             	mov    %edx,0x14(%ebp)
  800682:	8b 30                	mov    (%eax),%esi
  800684:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800687:	89 f0                	mov    %esi,%eax
  800689:	c1 f8 1f             	sar    $0x1f,%eax
  80068c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80068f:	eb 16                	jmp    8006a7 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8d 50 04             	lea    0x4(%eax),%edx
  800697:	89 55 14             	mov    %edx,0x14(%ebp)
  80069a:	8b 30                	mov    (%eax),%esi
  80069c:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80069f:	89 f0                	mov    %esi,%eax
  8006a1:	c1 f8 1f             	sar    $0x1f,%eax
  8006a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006ad:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006b6:	0f 89 80 00 00 00    	jns    80073c <vprintfmt+0x34d>
				putch('-', putdat);
  8006bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006c7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006d0:	f7 d8                	neg    %eax
  8006d2:	83 d2 00             	adc    $0x0,%edx
  8006d5:	f7 da                	neg    %edx
			}
			base = 10;
  8006d7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006dc:	eb 5e                	jmp    80073c <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006de:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e1:	e8 8b fc ff ff       	call   800371 <getuint>
			base = 10;
  8006e6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006eb:	eb 4f                	jmp    80073c <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  8006ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f0:	e8 7c fc ff ff       	call   800371 <getuint>
			base = 8;
  8006f5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006fa:	eb 40                	jmp    80073c <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  8006fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800700:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800707:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80070a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800715:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8d 50 04             	lea    0x4(%eax),%edx
  80071e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800721:	8b 00                	mov    (%eax),%eax
  800723:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800728:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80072d:	eb 0d                	jmp    80073c <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80072f:	8d 45 14             	lea    0x14(%ebp),%eax
  800732:	e8 3a fc ff ff       	call   800371 <getuint>
			base = 16;
  800737:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073c:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800740:	89 74 24 10          	mov    %esi,0x10(%esp)
  800744:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800747:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80074b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80074f:	89 04 24             	mov    %eax,(%esp)
  800752:	89 54 24 04          	mov    %edx,0x4(%esp)
  800756:	89 fa                	mov    %edi,%edx
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	e8 20 fb ff ff       	call   800280 <printnum>
			break;
  800760:	e9 af fc ff ff       	jmp    800414 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800765:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800769:	89 04 24             	mov    %eax,(%esp)
  80076c:	ff 55 08             	call   *0x8(%ebp)
			break;
  80076f:	e9 a0 fc ff ff       	jmp    800414 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800774:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800778:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80077f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800782:	89 f3                	mov    %esi,%ebx
  800784:	eb 01                	jmp    800787 <vprintfmt+0x398>
  800786:	4b                   	dec    %ebx
  800787:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80078b:	75 f9                	jne    800786 <vprintfmt+0x397>
  80078d:	e9 82 fc ff ff       	jmp    800414 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800792:	83 c4 3c             	add    $0x3c,%esp
  800795:	5b                   	pop    %ebx
  800796:	5e                   	pop    %esi
  800797:	5f                   	pop    %edi
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	83 ec 28             	sub    $0x28,%esp
  8007a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ad:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b7:	85 c0                	test   %eax,%eax
  8007b9:	74 30                	je     8007eb <vsnprintf+0x51>
  8007bb:	85 d2                	test   %edx,%edx
  8007bd:	7e 2c                	jle    8007eb <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007cd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d4:	c7 04 24 ab 03 80 00 	movl   $0x8003ab,(%esp)
  8007db:	e8 0f fc ff ff       	call   8003ef <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e9:	eb 05                	jmp    8007f0 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007f0:	c9                   	leave  
  8007f1:	c3                   	ret    

008007f2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800802:	89 44 24 08          	mov    %eax,0x8(%esp)
  800806:	8b 45 0c             	mov    0xc(%ebp),%eax
  800809:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080d:	8b 45 08             	mov    0x8(%ebp),%eax
  800810:	89 04 24             	mov    %eax,(%esp)
  800813:	e8 82 ff ff ff       	call   80079a <vsnprintf>
	va_end(ap);

	return rc;
}
  800818:	c9                   	leave  
  800819:	c3                   	ret    
  80081a:	66 90                	xchg   %ax,%ax

0080081c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800822:	b8 00 00 00 00       	mov    $0x0,%eax
  800827:	eb 01                	jmp    80082a <strlen+0xe>
		n++;
  800829:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80082a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80082e:	75 f9                	jne    800829 <strlen+0xd>
		n++;
	return n;
}
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800838:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083b:	b8 00 00 00 00       	mov    $0x0,%eax
  800840:	eb 01                	jmp    800843 <strnlen+0x11>
		n++;
  800842:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800843:	39 d0                	cmp    %edx,%eax
  800845:	74 06                	je     80084d <strnlen+0x1b>
  800847:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80084b:	75 f5                	jne    800842 <strnlen+0x10>
		n++;
	return n;
}
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	8b 45 08             	mov    0x8(%ebp),%eax
  800856:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800859:	89 c2                	mov    %eax,%edx
  80085b:	42                   	inc    %edx
  80085c:	41                   	inc    %ecx
  80085d:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800860:	88 5a ff             	mov    %bl,-0x1(%edx)
  800863:	84 db                	test   %bl,%bl
  800865:	75 f4                	jne    80085b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800867:	5b                   	pop    %ebx
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	53                   	push   %ebx
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800874:	89 1c 24             	mov    %ebx,(%esp)
  800877:	e8 a0 ff ff ff       	call   80081c <strlen>
	strcpy(dst + len, src);
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800883:	01 d8                	add    %ebx,%eax
  800885:	89 04 24             	mov    %eax,(%esp)
  800888:	e8 c2 ff ff ff       	call   80084f <strcpy>
	return dst;
}
  80088d:	89 d8                	mov    %ebx,%eax
  80088f:	83 c4 08             	add    $0x8,%esp
  800892:	5b                   	pop    %ebx
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	56                   	push   %esi
  800899:	53                   	push   %ebx
  80089a:	8b 75 08             	mov    0x8(%ebp),%esi
  80089d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a0:	89 f3                	mov    %esi,%ebx
  8008a2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a5:	89 f2                	mov    %esi,%edx
  8008a7:	eb 0c                	jmp    8008b5 <strncpy+0x20>
		*dst++ = *src;
  8008a9:	42                   	inc    %edx
  8008aa:	8a 01                	mov    (%ecx),%al
  8008ac:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008af:	80 39 01             	cmpb   $0x1,(%ecx)
  8008b2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b5:	39 da                	cmp    %ebx,%edx
  8008b7:	75 f0                	jne    8008a9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008b9:	89 f0                	mov    %esi,%eax
  8008bb:	5b                   	pop    %ebx
  8008bc:	5e                   	pop    %esi
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	56                   	push   %esi
  8008c3:	53                   	push   %ebx
  8008c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008cd:	89 f0                	mov    %esi,%eax
  8008cf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d3:	85 c9                	test   %ecx,%ecx
  8008d5:	75 07                	jne    8008de <strlcpy+0x1f>
  8008d7:	eb 18                	jmp    8008f1 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008d9:	40                   	inc    %eax
  8008da:	42                   	inc    %edx
  8008db:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008de:	39 d8                	cmp    %ebx,%eax
  8008e0:	74 0a                	je     8008ec <strlcpy+0x2d>
  8008e2:	8a 0a                	mov    (%edx),%cl
  8008e4:	84 c9                	test   %cl,%cl
  8008e6:	75 f1                	jne    8008d9 <strlcpy+0x1a>
  8008e8:	89 c2                	mov    %eax,%edx
  8008ea:	eb 02                	jmp    8008ee <strlcpy+0x2f>
  8008ec:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008ee:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008f1:	29 f0                	sub    %esi,%eax
}
  8008f3:	5b                   	pop    %ebx
  8008f4:	5e                   	pop    %esi
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800900:	eb 02                	jmp    800904 <strcmp+0xd>
		p++, q++;
  800902:	41                   	inc    %ecx
  800903:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800904:	8a 01                	mov    (%ecx),%al
  800906:	84 c0                	test   %al,%al
  800908:	74 04                	je     80090e <strcmp+0x17>
  80090a:	3a 02                	cmp    (%edx),%al
  80090c:	74 f4                	je     800902 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80090e:	25 ff 00 00 00       	and    $0xff,%eax
  800913:	8a 0a                	mov    (%edx),%cl
  800915:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  80091b:	29 c8                	sub    %ecx,%eax
}
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	53                   	push   %ebx
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
  800929:	89 c3                	mov    %eax,%ebx
  80092b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80092e:	eb 02                	jmp    800932 <strncmp+0x13>
		n--, p++, q++;
  800930:	40                   	inc    %eax
  800931:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800932:	39 d8                	cmp    %ebx,%eax
  800934:	74 20                	je     800956 <strncmp+0x37>
  800936:	8a 08                	mov    (%eax),%cl
  800938:	84 c9                	test   %cl,%cl
  80093a:	74 04                	je     800940 <strncmp+0x21>
  80093c:	3a 0a                	cmp    (%edx),%cl
  80093e:	74 f0                	je     800930 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800940:	8a 18                	mov    (%eax),%bl
  800942:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800948:	89 d8                	mov    %ebx,%eax
  80094a:	8a 1a                	mov    (%edx),%bl
  80094c:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800952:	29 d8                	sub    %ebx,%eax
  800954:	eb 05                	jmp    80095b <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80095b:	5b                   	pop    %ebx
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800967:	eb 05                	jmp    80096e <strchr+0x10>
		if (*s == c)
  800969:	38 ca                	cmp    %cl,%dl
  80096b:	74 0c                	je     800979 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80096d:	40                   	inc    %eax
  80096e:	8a 10                	mov    (%eax),%dl
  800970:	84 d2                	test   %dl,%dl
  800972:	75 f5                	jne    800969 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800974:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800984:	eb 05                	jmp    80098b <strfind+0x10>
		if (*s == c)
  800986:	38 ca                	cmp    %cl,%dl
  800988:	74 07                	je     800991 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80098a:	40                   	inc    %eax
  80098b:	8a 10                	mov    (%eax),%dl
  80098d:	84 d2                	test   %dl,%dl
  80098f:	75 f5                	jne    800986 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	57                   	push   %edi
  800997:	56                   	push   %esi
  800998:	53                   	push   %ebx
  800999:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80099f:	85 c9                	test   %ecx,%ecx
  8009a1:	74 37                	je     8009da <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a9:	75 29                	jne    8009d4 <memset+0x41>
  8009ab:	f6 c1 03             	test   $0x3,%cl
  8009ae:	75 24                	jne    8009d4 <memset+0x41>
		c &= 0xFF;
  8009b0:	31 d2                	xor    %edx,%edx
  8009b2:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b5:	89 d3                	mov    %edx,%ebx
  8009b7:	c1 e3 08             	shl    $0x8,%ebx
  8009ba:	89 d6                	mov    %edx,%esi
  8009bc:	c1 e6 18             	shl    $0x18,%esi
  8009bf:	89 d0                	mov    %edx,%eax
  8009c1:	c1 e0 10             	shl    $0x10,%eax
  8009c4:	09 f0                	or     %esi,%eax
  8009c6:	09 c2                	or     %eax,%edx
  8009c8:	89 d0                	mov    %edx,%eax
  8009ca:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009cc:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009cf:	fc                   	cld    
  8009d0:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d2:	eb 06                	jmp    8009da <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d7:	fc                   	cld    
  8009d8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009da:	89 f8                	mov    %edi,%eax
  8009dc:	5b                   	pop    %ebx
  8009dd:	5e                   	pop    %esi
  8009de:	5f                   	pop    %edi
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    

008009e1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	57                   	push   %edi
  8009e5:	56                   	push   %esi
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ef:	39 c6                	cmp    %eax,%esi
  8009f1:	73 33                	jae    800a26 <memmove+0x45>
  8009f3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f6:	39 d0                	cmp    %edx,%eax
  8009f8:	73 2c                	jae    800a26 <memmove+0x45>
		s += n;
		d += n;
  8009fa:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009fd:	89 d6                	mov    %edx,%esi
  8009ff:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a01:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a07:	75 13                	jne    800a1c <memmove+0x3b>
  800a09:	f6 c1 03             	test   $0x3,%cl
  800a0c:	75 0e                	jne    800a1c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a0e:	83 ef 04             	sub    $0x4,%edi
  800a11:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a14:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a17:	fd                   	std    
  800a18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1a:	eb 07                	jmp    800a23 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a1c:	4f                   	dec    %edi
  800a1d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a20:	fd                   	std    
  800a21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a23:	fc                   	cld    
  800a24:	eb 1d                	jmp    800a43 <memmove+0x62>
  800a26:	89 f2                	mov    %esi,%edx
  800a28:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2a:	f6 c2 03             	test   $0x3,%dl
  800a2d:	75 0f                	jne    800a3e <memmove+0x5d>
  800a2f:	f6 c1 03             	test   $0x3,%cl
  800a32:	75 0a                	jne    800a3e <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a34:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a37:	89 c7                	mov    %eax,%edi
  800a39:	fc                   	cld    
  800a3a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3c:	eb 05                	jmp    800a43 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a3e:	89 c7                	mov    %eax,%edi
  800a40:	fc                   	cld    
  800a41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a4d:	8b 45 10             	mov    0x10(%ebp),%eax
  800a50:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a57:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5e:	89 04 24             	mov    %eax,(%esp)
  800a61:	e8 7b ff ff ff       	call   8009e1 <memmove>
}
  800a66:	c9                   	leave  
  800a67:	c3                   	ret    

00800a68 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
  800a6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a73:	89 d6                	mov    %edx,%esi
  800a75:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a78:	eb 19                	jmp    800a93 <memcmp+0x2b>
		if (*s1 != *s2)
  800a7a:	8a 02                	mov    (%edx),%al
  800a7c:	8a 19                	mov    (%ecx),%bl
  800a7e:	38 d8                	cmp    %bl,%al
  800a80:	74 0f                	je     800a91 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800a82:	25 ff 00 00 00       	and    $0xff,%eax
  800a87:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800a8d:	29 d8                	sub    %ebx,%eax
  800a8f:	eb 0b                	jmp    800a9c <memcmp+0x34>
		s1++, s2++;
  800a91:	42                   	inc    %edx
  800a92:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a93:	39 f2                	cmp    %esi,%edx
  800a95:	75 e3                	jne    800a7a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aa9:	89 c2                	mov    %eax,%edx
  800aab:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aae:	eb 05                	jmp    800ab5 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab0:	38 08                	cmp    %cl,(%eax)
  800ab2:	74 05                	je     800ab9 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab4:	40                   	inc    %eax
  800ab5:	39 d0                	cmp    %edx,%eax
  800ab7:	72 f7                	jb     800ab0 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	57                   	push   %edi
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac7:	eb 01                	jmp    800aca <strtol+0xf>
		s++;
  800ac9:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aca:	8a 02                	mov    (%edx),%al
  800acc:	3c 09                	cmp    $0x9,%al
  800ace:	74 f9                	je     800ac9 <strtol+0xe>
  800ad0:	3c 20                	cmp    $0x20,%al
  800ad2:	74 f5                	je     800ac9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ad4:	3c 2b                	cmp    $0x2b,%al
  800ad6:	75 08                	jne    800ae0 <strtol+0x25>
		s++;
  800ad8:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ad9:	bf 00 00 00 00       	mov    $0x0,%edi
  800ade:	eb 10                	jmp    800af0 <strtol+0x35>
  800ae0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ae5:	3c 2d                	cmp    $0x2d,%al
  800ae7:	75 07                	jne    800af0 <strtol+0x35>
		s++, neg = 1;
  800ae9:	8d 52 01             	lea    0x1(%edx),%edx
  800aec:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800af6:	75 15                	jne    800b0d <strtol+0x52>
  800af8:	80 3a 30             	cmpb   $0x30,(%edx)
  800afb:	75 10                	jne    800b0d <strtol+0x52>
  800afd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b01:	75 0a                	jne    800b0d <strtol+0x52>
		s += 2, base = 16;
  800b03:	83 c2 02             	add    $0x2,%edx
  800b06:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b0b:	eb 0e                	jmp    800b1b <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800b0d:	85 db                	test   %ebx,%ebx
  800b0f:	75 0a                	jne    800b1b <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b11:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b13:	80 3a 30             	cmpb   $0x30,(%edx)
  800b16:	75 03                	jne    800b1b <strtol+0x60>
		s++, base = 8;
  800b18:	42                   	inc    %edx
  800b19:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b20:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b23:	8a 0a                	mov    (%edx),%cl
  800b25:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b28:	89 f3                	mov    %esi,%ebx
  800b2a:	80 fb 09             	cmp    $0x9,%bl
  800b2d:	77 08                	ja     800b37 <strtol+0x7c>
			dig = *s - '0';
  800b2f:	0f be c9             	movsbl %cl,%ecx
  800b32:	83 e9 30             	sub    $0x30,%ecx
  800b35:	eb 22                	jmp    800b59 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800b37:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b3a:	89 f3                	mov    %esi,%ebx
  800b3c:	80 fb 19             	cmp    $0x19,%bl
  800b3f:	77 08                	ja     800b49 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800b41:	0f be c9             	movsbl %cl,%ecx
  800b44:	83 e9 57             	sub    $0x57,%ecx
  800b47:	eb 10                	jmp    800b59 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800b49:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b4c:	89 f3                	mov    %esi,%ebx
  800b4e:	80 fb 19             	cmp    $0x19,%bl
  800b51:	77 14                	ja     800b67 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b53:	0f be c9             	movsbl %cl,%ecx
  800b56:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b59:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b5c:	7d 0d                	jge    800b6b <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b5e:	42                   	inc    %edx
  800b5f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b63:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b65:	eb bc                	jmp    800b23 <strtol+0x68>
  800b67:	89 c1                	mov    %eax,%ecx
  800b69:	eb 02                	jmp    800b6d <strtol+0xb2>
  800b6b:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b6d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b71:	74 05                	je     800b78 <strtol+0xbd>
		*endptr = (char *) s;
  800b73:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b76:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b78:	85 ff                	test   %edi,%edi
  800b7a:	74 04                	je     800b80 <strtol+0xc5>
  800b7c:	89 c8                	mov    %ecx,%eax
  800b7e:	f7 d8                	neg    %eax
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    
  800b85:	66 90                	xchg   %ax,%ax
  800b87:	90                   	nop

00800b88 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	89 c3                	mov    %eax,%ebx
  800b9b:	89 c7                	mov    %eax,%edi
  800b9d:	89 c6                	mov    %eax,%esi
  800b9f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bac:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb1:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb6:	89 d1                	mov    %edx,%ecx
  800bb8:	89 d3                	mov    %edx,%ebx
  800bba:	89 d7                	mov    %edx,%edi
  800bbc:	89 d6                	mov    %edx,%esi
  800bbe:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd3:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdb:	89 cb                	mov    %ecx,%ebx
  800bdd:	89 cf                	mov    %ecx,%edi
  800bdf:	89 ce                	mov    %ecx,%esi
  800be1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be3:	85 c0                	test   %eax,%eax
  800be5:	7e 28                	jle    800c0f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800beb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bf2:	00 
  800bf3:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800bfa:	00 
  800bfb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c02:	00 
  800c03:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800c0a:	e8 5d f5 ff ff       	call   80016c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c0f:	83 c4 2c             	add    $0x2c,%esp
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c22:	b8 02 00 00 00       	mov    $0x2,%eax
  800c27:	89 d1                	mov    %edx,%ecx
  800c29:	89 d3                	mov    %edx,%ebx
  800c2b:	89 d7                	mov    %edx,%edi
  800c2d:	89 d6                	mov    %edx,%esi
  800c2f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <sys_yield>:

void
sys_yield(void)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c41:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c46:	89 d1                	mov    %edx,%ecx
  800c48:	89 d3                	mov    %edx,%ebx
  800c4a:	89 d7                	mov    %edx,%edi
  800c4c:	89 d6                	mov    %edx,%esi
  800c4e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	be 00 00 00 00       	mov    $0x0,%esi
  800c63:	b8 04 00 00 00       	mov    $0x4,%eax
  800c68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c71:	89 f7                	mov    %esi,%edi
  800c73:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c75:	85 c0                	test   %eax,%eax
  800c77:	7e 28                	jle    800ca1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c84:	00 
  800c85:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800c8c:	00 
  800c8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c94:	00 
  800c95:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800c9c:	e8 cb f4 ff ff       	call   80016c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ca1:	83 c4 2c             	add    $0x2c,%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
  800caf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb2:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc3:	8b 75 18             	mov    0x18(%ebp),%esi
  800cc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc8:	85 c0                	test   %eax,%eax
  800cca:	7e 28                	jle    800cf4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cd7:	00 
  800cd8:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800cdf:	00 
  800ce0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce7:	00 
  800ce8:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800cef:	e8 78 f4 ff ff       	call   80016c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf4:	83 c4 2c             	add    $0x2c,%esp
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	57                   	push   %edi
  800d00:	56                   	push   %esi
  800d01:	53                   	push   %ebx
  800d02:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d12:	8b 55 08             	mov    0x8(%ebp),%edx
  800d15:	89 df                	mov    %ebx,%edi
  800d17:	89 de                	mov    %ebx,%esi
  800d19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1b:	85 c0                	test   %eax,%eax
  800d1d:	7e 28                	jle    800d47 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d23:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d2a:	00 
  800d2b:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800d32:	00 
  800d33:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3a:	00 
  800d3b:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800d42:	e8 25 f4 ff ff       	call   80016c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d47:	83 c4 2c             	add    $0x2c,%esp
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
  800d55:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d65:	8b 55 08             	mov    0x8(%ebp),%edx
  800d68:	89 df                	mov    %ebx,%edi
  800d6a:	89 de                	mov    %ebx,%esi
  800d6c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6e:	85 c0                	test   %eax,%eax
  800d70:	7e 28                	jle    800d9a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d72:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d76:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d7d:	00 
  800d7e:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800d85:	00 
  800d86:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8d:	00 
  800d8e:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800d95:	e8 d2 f3 ff ff       	call   80016c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d9a:	83 c4 2c             	add    $0x2c,%esp
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	57                   	push   %edi
  800da6:	56                   	push   %esi
  800da7:	53                   	push   %ebx
  800da8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db0:	b8 09 00 00 00       	mov    $0x9,%eax
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	89 df                	mov    %ebx,%edi
  800dbd:	89 de                	mov    %ebx,%esi
  800dbf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc1:	85 c0                	test   %eax,%eax
  800dc3:	7e 28                	jle    800ded <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dd0:	00 
  800dd1:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800dd8:	00 
  800dd9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de0:	00 
  800de1:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800de8:	e8 7f f3 ff ff       	call   80016c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ded:	83 c4 2c             	add    $0x2c,%esp
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    

00800df5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	57                   	push   %edi
  800df9:	56                   	push   %esi
  800dfa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfb:	be 00 00 00 00       	mov    $0x0,%esi
  800e00:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e08:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e11:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    

00800e18 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	57                   	push   %edi
  800e1c:	56                   	push   %esi
  800e1d:	53                   	push   %ebx
  800e1e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e21:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e26:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2e:	89 cb                	mov    %ecx,%ebx
  800e30:	89 cf                	mov    %ecx,%edi
  800e32:	89 ce                	mov    %ecx,%esi
  800e34:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e36:	85 c0                	test   %eax,%eax
  800e38:	7e 28                	jle    800e62 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e45:	00 
  800e46:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800e4d:	00 
  800e4e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e55:	00 
  800e56:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800e5d:	e8 0a f3 ff ff       	call   80016c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e62:	83 c4 2c             	add    $0x2c,%esp
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    
  800e6a:	66 90                	xchg   %ax,%ax

00800e6c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e72:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e79:	75 32                	jne    800ead <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
    //region_alloc(curenv, (void *)UXSTACKTOP - PGSIZE, PGSIZE);
		//panic("set_pgfault_handler not implemented");
		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  800e7b:	e8 97 fd ff ff       	call   800c17 <sys_getenvid>
  800e80:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e87:	00 
  800e88:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800e8f:	ee 
  800e90:	89 04 24             	mov    %eax,(%esp)
  800e93:	e8 bd fd ff ff       	call   800c55 <sys_page_alloc>
    sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800e98:	e8 7a fd ff ff       	call   800c17 <sys_getenvid>
  800e9d:	c7 44 24 04 b8 0e 80 	movl   $0x800eb8,0x4(%esp)
  800ea4:	00 
  800ea5:	89 04 24             	mov    %eax,(%esp)
  800ea8:	e8 f5 fe ff ff       	call   800da2 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ead:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb0:	a3 08 20 80 00       	mov    %eax,0x802008

}
  800eb5:	c9                   	leave  
  800eb6:	c3                   	ret    
  800eb7:	90                   	nop

00800eb8 <_pgfault_upcall>:
  800eb8:	54                   	push   %esp
  800eb9:	a1 08 20 80 00       	mov    0x802008,%eax
  800ebe:	ff d0                	call   *%eax
  800ec0:	83 c4 04             	add    $0x4,%esp
  800ec3:	8b 44 24 28          	mov    0x28(%esp),%eax
  800ec7:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800ecb:	89 43 fc             	mov    %eax,-0x4(%ebx)
  800ece:	83 eb 04             	sub    $0x4,%ebx
  800ed1:	89 5c 24 30          	mov    %ebx,0x30(%esp)
  800ed5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ed9:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800edd:	8b 6c 24 10          	mov    0x10(%esp),%ebp
  800ee1:	8b 5c 24 18          	mov    0x18(%esp),%ebx
  800ee5:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  800ee9:	8b 4c 24 20          	mov    0x20(%esp),%ecx
  800eed:	8b 44 24 24          	mov    0x24(%esp),%eax
  800ef1:	ff 74 24 2c          	pushl  0x2c(%esp)
  800ef5:	9d                   	popf   
  800ef6:	8b 64 24 30          	mov    0x30(%esp),%esp
  800efa:	c3                   	ret    
  800efb:	66 90                	xchg   %ax,%ax
  800efd:	66 90                	xchg   %ax,%ax
  800eff:	90                   	nop

00800f00 <__udivdi3>:
  800f00:	55                   	push   %ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	83 ec 0c             	sub    $0xc,%esp
  800f06:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800f0a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800f0e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f12:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f16:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f1a:	89 ea                	mov    %ebp,%edx
  800f1c:	89 0c 24             	mov    %ecx,(%esp)
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	75 2d                	jne    800f50 <__udivdi3+0x50>
  800f23:	39 e9                	cmp    %ebp,%ecx
  800f25:	77 61                	ja     800f88 <__udivdi3+0x88>
  800f27:	89 ce                	mov    %ecx,%esi
  800f29:	85 c9                	test   %ecx,%ecx
  800f2b:	75 0b                	jne    800f38 <__udivdi3+0x38>
  800f2d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f32:	31 d2                	xor    %edx,%edx
  800f34:	f7 f1                	div    %ecx
  800f36:	89 c6                	mov    %eax,%esi
  800f38:	31 d2                	xor    %edx,%edx
  800f3a:	89 e8                	mov    %ebp,%eax
  800f3c:	f7 f6                	div    %esi
  800f3e:	89 c5                	mov    %eax,%ebp
  800f40:	89 f8                	mov    %edi,%eax
  800f42:	f7 f6                	div    %esi
  800f44:	89 ea                	mov    %ebp,%edx
  800f46:	83 c4 0c             	add    $0xc,%esp
  800f49:	5e                   	pop    %esi
  800f4a:	5f                   	pop    %edi
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    
  800f4d:	8d 76 00             	lea    0x0(%esi),%esi
  800f50:	39 e8                	cmp    %ebp,%eax
  800f52:	77 24                	ja     800f78 <__udivdi3+0x78>
  800f54:	0f bd e8             	bsr    %eax,%ebp
  800f57:	83 f5 1f             	xor    $0x1f,%ebp
  800f5a:	75 3c                	jne    800f98 <__udivdi3+0x98>
  800f5c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f60:	39 34 24             	cmp    %esi,(%esp)
  800f63:	0f 86 9f 00 00 00    	jbe    801008 <__udivdi3+0x108>
  800f69:	39 d0                	cmp    %edx,%eax
  800f6b:	0f 82 97 00 00 00    	jb     801008 <__udivdi3+0x108>
  800f71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f78:	31 d2                	xor    %edx,%edx
  800f7a:	31 c0                	xor    %eax,%eax
  800f7c:	83 c4 0c             	add    $0xc,%esp
  800f7f:	5e                   	pop    %esi
  800f80:	5f                   	pop    %edi
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    
  800f83:	90                   	nop
  800f84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f88:	89 f8                	mov    %edi,%eax
  800f8a:	f7 f1                	div    %ecx
  800f8c:	31 d2                	xor    %edx,%edx
  800f8e:	83 c4 0c             	add    $0xc,%esp
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    
  800f95:	8d 76 00             	lea    0x0(%esi),%esi
  800f98:	89 e9                	mov    %ebp,%ecx
  800f9a:	8b 3c 24             	mov    (%esp),%edi
  800f9d:	d3 e0                	shl    %cl,%eax
  800f9f:	89 c6                	mov    %eax,%esi
  800fa1:	b8 20 00 00 00       	mov    $0x20,%eax
  800fa6:	29 e8                	sub    %ebp,%eax
  800fa8:	88 c1                	mov    %al,%cl
  800faa:	d3 ef                	shr    %cl,%edi
  800fac:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fb0:	89 e9                	mov    %ebp,%ecx
  800fb2:	8b 3c 24             	mov    (%esp),%edi
  800fb5:	09 74 24 08          	or     %esi,0x8(%esp)
  800fb9:	d3 e7                	shl    %cl,%edi
  800fbb:	89 d6                	mov    %edx,%esi
  800fbd:	88 c1                	mov    %al,%cl
  800fbf:	d3 ee                	shr    %cl,%esi
  800fc1:	89 e9                	mov    %ebp,%ecx
  800fc3:	89 3c 24             	mov    %edi,(%esp)
  800fc6:	d3 e2                	shl    %cl,%edx
  800fc8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fcc:	88 c1                	mov    %al,%cl
  800fce:	d3 ef                	shr    %cl,%edi
  800fd0:	09 d7                	or     %edx,%edi
  800fd2:	89 f2                	mov    %esi,%edx
  800fd4:	89 f8                	mov    %edi,%eax
  800fd6:	f7 74 24 08          	divl   0x8(%esp)
  800fda:	89 d6                	mov    %edx,%esi
  800fdc:	89 c7                	mov    %eax,%edi
  800fde:	f7 24 24             	mull   (%esp)
  800fe1:	89 14 24             	mov    %edx,(%esp)
  800fe4:	39 d6                	cmp    %edx,%esi
  800fe6:	72 30                	jb     801018 <__udivdi3+0x118>
  800fe8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fec:	89 e9                	mov    %ebp,%ecx
  800fee:	d3 e2                	shl    %cl,%edx
  800ff0:	39 c2                	cmp    %eax,%edx
  800ff2:	73 05                	jae    800ff9 <__udivdi3+0xf9>
  800ff4:	3b 34 24             	cmp    (%esp),%esi
  800ff7:	74 1f                	je     801018 <__udivdi3+0x118>
  800ff9:	89 f8                	mov    %edi,%eax
  800ffb:	31 d2                	xor    %edx,%edx
  800ffd:	e9 7a ff ff ff       	jmp    800f7c <__udivdi3+0x7c>
  801002:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801008:	31 d2                	xor    %edx,%edx
  80100a:	b8 01 00 00 00       	mov    $0x1,%eax
  80100f:	e9 68 ff ff ff       	jmp    800f7c <__udivdi3+0x7c>
  801014:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801018:	8d 47 ff             	lea    -0x1(%edi),%eax
  80101b:	31 d2                	xor    %edx,%edx
  80101d:	83 c4 0c             	add    $0xc,%esp
  801020:	5e                   	pop    %esi
  801021:	5f                   	pop    %edi
  801022:	5d                   	pop    %ebp
  801023:	c3                   	ret    
  801024:	66 90                	xchg   %ax,%ax
  801026:	66 90                	xchg   %ax,%ax
  801028:	66 90                	xchg   %ax,%ax
  80102a:	66 90                	xchg   %ax,%ax
  80102c:	66 90                	xchg   %ax,%ax
  80102e:	66 90                	xchg   %ax,%ax

00801030 <__umoddi3>:
  801030:	55                   	push   %ebp
  801031:	57                   	push   %edi
  801032:	56                   	push   %esi
  801033:	83 ec 14             	sub    $0x14,%esp
  801036:	8b 44 24 28          	mov    0x28(%esp),%eax
  80103a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80103e:	89 c7                	mov    %eax,%edi
  801040:	89 44 24 04          	mov    %eax,0x4(%esp)
  801044:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801048:	8b 44 24 30          	mov    0x30(%esp),%eax
  80104c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801050:	89 34 24             	mov    %esi,(%esp)
  801053:	89 c2                	mov    %eax,%edx
  801055:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801059:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80105d:	85 c0                	test   %eax,%eax
  80105f:	75 17                	jne    801078 <__umoddi3+0x48>
  801061:	39 fe                	cmp    %edi,%esi
  801063:	76 4b                	jbe    8010b0 <__umoddi3+0x80>
  801065:	89 c8                	mov    %ecx,%eax
  801067:	89 fa                	mov    %edi,%edx
  801069:	f7 f6                	div    %esi
  80106b:	89 d0                	mov    %edx,%eax
  80106d:	31 d2                	xor    %edx,%edx
  80106f:	83 c4 14             	add    $0x14,%esp
  801072:	5e                   	pop    %esi
  801073:	5f                   	pop    %edi
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    
  801076:	66 90                	xchg   %ax,%ax
  801078:	39 f8                	cmp    %edi,%eax
  80107a:	77 54                	ja     8010d0 <__umoddi3+0xa0>
  80107c:	0f bd e8             	bsr    %eax,%ebp
  80107f:	83 f5 1f             	xor    $0x1f,%ebp
  801082:	75 5c                	jne    8010e0 <__umoddi3+0xb0>
  801084:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801088:	39 3c 24             	cmp    %edi,(%esp)
  80108b:	0f 87 f7 00 00 00    	ja     801188 <__umoddi3+0x158>
  801091:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801095:	29 f1                	sub    %esi,%ecx
  801097:	19 c7                	sbb    %eax,%edi
  801099:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80109d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010a1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8010a9:	83 c4 14             	add    $0x14,%esp
  8010ac:	5e                   	pop    %esi
  8010ad:	5f                   	pop    %edi
  8010ae:	5d                   	pop    %ebp
  8010af:	c3                   	ret    
  8010b0:	89 f5                	mov    %esi,%ebp
  8010b2:	85 f6                	test   %esi,%esi
  8010b4:	75 0b                	jne    8010c1 <__umoddi3+0x91>
  8010b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010bb:	31 d2                	xor    %edx,%edx
  8010bd:	f7 f6                	div    %esi
  8010bf:	89 c5                	mov    %eax,%ebp
  8010c1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010c5:	31 d2                	xor    %edx,%edx
  8010c7:	f7 f5                	div    %ebp
  8010c9:	89 c8                	mov    %ecx,%eax
  8010cb:	f7 f5                	div    %ebp
  8010cd:	eb 9c                	jmp    80106b <__umoddi3+0x3b>
  8010cf:	90                   	nop
  8010d0:	89 c8                	mov    %ecx,%eax
  8010d2:	89 fa                	mov    %edi,%edx
  8010d4:	83 c4 14             	add    $0x14,%esp
  8010d7:	5e                   	pop    %esi
  8010d8:	5f                   	pop    %edi
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    
  8010db:	90                   	nop
  8010dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010e0:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8010e7:	00 
  8010e8:	8b 34 24             	mov    (%esp),%esi
  8010eb:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010ef:	89 e9                	mov    %ebp,%ecx
  8010f1:	29 e8                	sub    %ebp,%eax
  8010f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f7:	89 f0                	mov    %esi,%eax
  8010f9:	d3 e2                	shl    %cl,%edx
  8010fb:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8010ff:	d3 e8                	shr    %cl,%eax
  801101:	89 04 24             	mov    %eax,(%esp)
  801104:	89 e9                	mov    %ebp,%ecx
  801106:	89 f0                	mov    %esi,%eax
  801108:	09 14 24             	or     %edx,(%esp)
  80110b:	d3 e0                	shl    %cl,%eax
  80110d:	89 fa                	mov    %edi,%edx
  80110f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801113:	d3 ea                	shr    %cl,%edx
  801115:	89 e9                	mov    %ebp,%ecx
  801117:	89 c6                	mov    %eax,%esi
  801119:	d3 e7                	shl    %cl,%edi
  80111b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80111f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801123:	8b 44 24 10          	mov    0x10(%esp),%eax
  801127:	d3 e8                	shr    %cl,%eax
  801129:	09 f8                	or     %edi,%eax
  80112b:	89 e9                	mov    %ebp,%ecx
  80112d:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801131:	d3 e7                	shl    %cl,%edi
  801133:	f7 34 24             	divl   (%esp)
  801136:	89 d1                	mov    %edx,%ecx
  801138:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80113c:	f7 e6                	mul    %esi
  80113e:	89 c7                	mov    %eax,%edi
  801140:	89 d6                	mov    %edx,%esi
  801142:	39 d1                	cmp    %edx,%ecx
  801144:	72 2e                	jb     801174 <__umoddi3+0x144>
  801146:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80114a:	72 24                	jb     801170 <__umoddi3+0x140>
  80114c:	89 ca                	mov    %ecx,%edx
  80114e:	89 e9                	mov    %ebp,%ecx
  801150:	8b 44 24 08          	mov    0x8(%esp),%eax
  801154:	29 f8                	sub    %edi,%eax
  801156:	19 f2                	sbb    %esi,%edx
  801158:	d3 e8                	shr    %cl,%eax
  80115a:	89 d6                	mov    %edx,%esi
  80115c:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801160:	d3 e6                	shl    %cl,%esi
  801162:	89 e9                	mov    %ebp,%ecx
  801164:	09 f0                	or     %esi,%eax
  801166:	d3 ea                	shr    %cl,%edx
  801168:	83 c4 14             	add    $0x14,%esp
  80116b:	5e                   	pop    %esi
  80116c:	5f                   	pop    %edi
  80116d:	5d                   	pop    %ebp
  80116e:	c3                   	ret    
  80116f:	90                   	nop
  801170:	39 d1                	cmp    %edx,%ecx
  801172:	75 d8                	jne    80114c <__umoddi3+0x11c>
  801174:	89 d6                	mov    %edx,%esi
  801176:	89 c7                	mov    %eax,%edi
  801178:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  80117c:	1b 34 24             	sbb    (%esp),%esi
  80117f:	eb cb                	jmp    80114c <__umoddi3+0x11c>
  801181:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801188:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80118c:	0f 82 ff fe ff ff    	jb     801091 <__umoddi3+0x61>
  801192:	e9 0a ff ff ff       	jmp    8010a1 <__umoddi3+0x71>
