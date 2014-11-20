
obj/user/testbss:     file format elf32-i386


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

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int i;
	
	cprintf("Making sure bss works right...\n");
  80003a:	c7 04 24 40 11 80 00 	movl   $0x801140,(%esp)
  800041:	e8 38 02 00 00       	call   80027e <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	74 20                	je     800075 <umain+0x41>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800059:	c7 44 24 08 bb 11 80 	movl   $0x8011bb,0x8(%esp)
  800060:	00 
  800061:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 d8 11 80 00 	movl   $0x8011d8,(%esp)
  800070:	e8 0f 01 00 00       	call   800184 <_panic>
umain(int argc, char **argv)
{
	int i;
	
	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800075:	40                   	inc    %eax
  800076:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80007b:	75 ce                	jne    80004b <umain+0x17>
  80007d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800082:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)
	
	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  800089:	40                   	inc    %eax
  80008a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008f:	75 f1                	jne    800082 <umain+0x4e>
  800091:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  800096:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  80009d:	74 20                	je     8000bf <umain+0x8b>
			panic("bigarray[%d] didn't hold its value!\n", i);
  80009f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a3:	c7 44 24 08 60 11 80 	movl   $0x801160,0x8(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000b2:	00 
  8000b3:	c7 04 24 d8 11 80 00 	movl   $0x8011d8,(%esp)
  8000ba:	e8 c5 00 00 00       	call   800184 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000bf:	40                   	inc    %eax
  8000c0:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000c5:	75 cf                	jne    800096 <umain+0x62>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000c7:	c7 04 24 88 11 80 00 	movl   $0x801188,(%esp)
  8000ce:	e8 ab 01 00 00       	call   80027e <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d3:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000da:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000dd:	c7 44 24 08 e7 11 80 	movl   $0x8011e7,0x8(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8000ec:	00 
  8000ed:	c7 04 24 d8 11 80 00 	movl   $0x8011d8,(%esp)
  8000f4:	e8 8b 00 00 00       	call   800184 <_panic>
  8000f9:	66 90                	xchg   %ax,%ax
  8000fb:	90                   	nop

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
  80010a:	b8 24 20 c0 00       	mov    $0xc02024,%eax
  80010f:	2d 04 20 80 00       	sub    $0x802004,%eax
  800114:	89 44 24 08          	mov    %eax,0x8(%esp)
  800118:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80011f:	00 
  800120:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  800127:	e8 7f 08 00 00       	call   8009ab <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  80012c:	e8 fe 0a 00 00       	call   800c2f <sys_getenvid>
  800131:	25 ff 03 00 00       	and    $0x3ff,%eax
  800136:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80013d:	c1 e0 07             	shl    $0x7,%eax
  800140:	29 d0                	sub    %edx,%eax
  800142:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800147:	a3 20 20 c0 00       	mov    %eax,0xc02020

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
  80017d:	e8 5b 0a 00 00       	call   800bdd <sys_env_destroy>
}
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80018c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800195:	e8 95 0a 00 00       	call   800c2f <sys_getenvid>
  80019a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019d:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001a8:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b0:	c7 04 24 08 12 80 00 	movl   $0x801208,(%esp)
  8001b7:	e8 c2 00 00 00       	call   80027e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c3:	89 04 24             	mov    %eax,(%esp)
  8001c6:	e8 52 00 00 00       	call   80021d <vcprintf>
	cprintf("\n");
  8001cb:	c7 04 24 d6 11 80 00 	movl   $0x8011d6,(%esp)
  8001d2:	e8 a7 00 00 00       	call   80027e <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d7:	cc                   	int3   
  8001d8:	eb fd                	jmp    8001d7 <_panic+0x53>
  8001da:	66 90                	xchg   %ax,%ax

008001dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 14             	sub    $0x14,%esp
  8001e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e6:	8b 13                	mov    (%ebx),%edx
  8001e8:	8d 42 01             	lea    0x1(%edx),%eax
  8001eb:	89 03                	mov    %eax,(%ebx)
  8001ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f9:	75 19                	jne    800214 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001fb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800202:	00 
  800203:	8d 43 08             	lea    0x8(%ebx),%eax
  800206:	89 04 24             	mov    %eax,(%esp)
  800209:	e8 92 09 00 00       	call   800ba0 <sys_cputs>
		b->idx = 0;
  80020e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800214:	ff 43 04             	incl   0x4(%ebx)
}
  800217:	83 c4 14             	add    $0x14,%esp
  80021a:	5b                   	pop    %ebx
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800226:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022d:	00 00 00 
	b.cnt = 0;
  800230:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800237:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80023a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800241:	8b 45 08             	mov    0x8(%ebp),%eax
  800244:	89 44 24 08          	mov    %eax,0x8(%esp)
  800248:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800252:	c7 04 24 dc 01 80 00 	movl   $0x8001dc,(%esp)
  800259:	e8 a9 01 00 00       	call   800407 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800264:	89 44 24 04          	mov    %eax,0x4(%esp)
  800268:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026e:	89 04 24             	mov    %eax,(%esp)
  800271:	e8 2a 09 00 00       	call   800ba0 <sys_cputs>

	return b.cnt;
}
  800276:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027c:	c9                   	leave  
  80027d:	c3                   	ret    

0080027e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800284:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800287:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028b:	8b 45 08             	mov    0x8(%ebp),%eax
  80028e:	89 04 24             	mov    %eax,(%esp)
  800291:	e8 87 ff ff ff       	call   80021d <vcprintf>
	va_end(ap);

	return cnt;
}
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 3c             	sub    $0x3c,%esp
  8002a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a4:	89 d7                	mov    %edx,%edi
  8002a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002af:	89 c1                	mov    %eax,%ecx
  8002b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002b4:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002c5:	39 ca                	cmp    %ecx,%edx
  8002c7:	72 08                	jb     8002d1 <printnum+0x39>
  8002c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002cc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002cf:	77 6a                	ja     80033b <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d1:	8b 45 18             	mov    0x18(%ebp),%eax
  8002d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002d8:	4e                   	dec    %esi
  8002d9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e4:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002e8:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002ec:	89 c3                	mov    %eax,%ebx
  8002ee:	89 d6                	mov    %edx,%esi
  8002f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002f3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800301:	89 04 24             	mov    %eax,(%esp)
  800304:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800307:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030b:	e8 80 0b 00 00       	call   800e90 <__udivdi3>
  800310:	89 d9                	mov    %ebx,%ecx
  800312:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800316:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80031a:	89 04 24             	mov    %eax,(%esp)
  80031d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800321:	89 fa                	mov    %edi,%edx
  800323:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800326:	e8 6d ff ff ff       	call   800298 <printnum>
  80032b:	eb 19                	jmp    800346 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800331:	8b 45 18             	mov    0x18(%ebp),%eax
  800334:	89 04 24             	mov    %eax,(%esp)
  800337:	ff d3                	call   *%ebx
  800339:	eb 03                	jmp    80033e <printnum+0xa6>
  80033b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033e:	4e                   	dec    %esi
  80033f:	85 f6                	test   %esi,%esi
  800341:	7f ea                	jg     80032d <printnum+0x95>
  800343:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800346:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80034a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80034e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800351:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800354:	89 44 24 08          	mov    %eax,0x8(%esp)
  800358:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80035c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80035f:	89 04 24             	mov    %eax,(%esp)
  800362:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800365:	89 44 24 04          	mov    %eax,0x4(%esp)
  800369:	e8 52 0c 00 00       	call   800fc0 <__umoddi3>
  80036e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800372:	0f be 80 2c 12 80 00 	movsbl 0x80122c(%eax),%eax
  800379:	89 04 24             	mov    %eax,(%esp)
  80037c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80037f:	ff d0                	call   *%eax
}
  800381:	83 c4 3c             	add    $0x3c,%esp
  800384:	5b                   	pop    %ebx
  800385:	5e                   	pop    %esi
  800386:	5f                   	pop    %edi
  800387:	5d                   	pop    %ebp
  800388:	c3                   	ret    

00800389 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80038c:	83 fa 01             	cmp    $0x1,%edx
  80038f:	7e 0e                	jle    80039f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800391:	8b 10                	mov    (%eax),%edx
  800393:	8d 4a 08             	lea    0x8(%edx),%ecx
  800396:	89 08                	mov    %ecx,(%eax)
  800398:	8b 02                	mov    (%edx),%eax
  80039a:	8b 52 04             	mov    0x4(%edx),%edx
  80039d:	eb 22                	jmp    8003c1 <getuint+0x38>
	else if (lflag)
  80039f:	85 d2                	test   %edx,%edx
  8003a1:	74 10                	je     8003b3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003a3:	8b 10                	mov    (%eax),%edx
  8003a5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a8:	89 08                	mov    %ecx,(%eax)
  8003aa:	8b 02                	mov    (%edx),%eax
  8003ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b1:	eb 0e                	jmp    8003c1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003b3:	8b 10                	mov    (%eax),%edx
  8003b5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b8:	89 08                	mov    %ecx,(%eax)
  8003ba:	8b 02                	mov    (%edx),%eax
  8003bc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c1:	5d                   	pop    %ebp
  8003c2:	c3                   	ret    

008003c3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c9:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003cc:	8b 10                	mov    (%eax),%edx
  8003ce:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d1:	73 0a                	jae    8003dd <sprintputch+0x1a>
		*b->buf++ = ch;
  8003d3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003d6:	89 08                	mov    %ecx,(%eax)
  8003d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003db:	88 02                	mov    %al,(%edx)
}
  8003dd:	5d                   	pop    %ebp
  8003de:	c3                   	ret    

008003df <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003e5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fd:	89 04 24             	mov    %eax,(%esp)
  800400:	e8 02 00 00 00       	call   800407 <vprintfmt>
	va_end(ap);
}
  800405:	c9                   	leave  
  800406:	c3                   	ret    

00800407 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
  80040a:	57                   	push   %edi
  80040b:	56                   	push   %esi
  80040c:	53                   	push   %ebx
  80040d:	83 ec 3c             	sub    $0x3c,%esp
  800410:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800413:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800416:	eb 14                	jmp    80042c <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800418:	85 c0                	test   %eax,%eax
  80041a:	0f 84 8a 03 00 00    	je     8007aa <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  800420:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800424:	89 04 24             	mov    %eax,(%esp)
  800427:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80042a:	89 f3                	mov    %esi,%ebx
  80042c:	8d 73 01             	lea    0x1(%ebx),%esi
  80042f:	31 c0                	xor    %eax,%eax
  800431:	8a 03                	mov    (%ebx),%al
  800433:	83 f8 25             	cmp    $0x25,%eax
  800436:	75 e0                	jne    800418 <vprintfmt+0x11>
  800438:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80043c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800443:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80044a:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800451:	ba 00 00 00 00       	mov    $0x0,%edx
  800456:	eb 1d                	jmp    800475 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800458:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80045a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80045e:	eb 15                	jmp    800475 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800462:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800466:	eb 0d                	jmp    800475 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800468:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80046b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80046e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8d 5e 01             	lea    0x1(%esi),%ebx
  800478:	31 c0                	xor    %eax,%eax
  80047a:	8a 06                	mov    (%esi),%al
  80047c:	8a 0e                	mov    (%esi),%cl
  80047e:	83 e9 23             	sub    $0x23,%ecx
  800481:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800484:	80 f9 55             	cmp    $0x55,%cl
  800487:	0f 87 ff 02 00 00    	ja     80078c <vprintfmt+0x385>
  80048d:	31 c9                	xor    %ecx,%ecx
  80048f:	8a 4d e0             	mov    -0x20(%ebp),%cl
  800492:	ff 24 8d 00 13 80 00 	jmp    *0x801300(,%ecx,4)
  800499:	89 de                	mov    %ebx,%esi
  80049b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a0:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004a3:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8004a7:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004aa:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004ad:	83 fb 09             	cmp    $0x9,%ebx
  8004b0:	77 2f                	ja     8004e1 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b2:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004b3:	eb eb                	jmp    8004a0 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b8:	8d 48 04             	lea    0x4(%eax),%ecx
  8004bb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004be:	8b 00                	mov    (%eax),%eax
  8004c0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004c5:	eb 1d                	jmp    8004e4 <vprintfmt+0xdd>
  8004c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ca:	f7 d0                	not    %eax
  8004cc:	c1 f8 1f             	sar    $0x1f,%eax
  8004cf:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	89 de                	mov    %ebx,%esi
  8004d4:	eb 9f                	jmp    800475 <vprintfmt+0x6e>
  8004d6:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004d8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004df:	eb 94                	jmp    800475 <vprintfmt+0x6e>
  8004e1:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004e4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004e8:	79 8b                	jns    800475 <vprintfmt+0x6e>
  8004ea:	e9 79 ff ff ff       	jmp    800468 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ef:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004f2:	eb 81                	jmp    800475 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f7:	8d 50 04             	lea    0x4(%eax),%edx
  8004fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800501:	8b 00                	mov    (%eax),%eax
  800503:	89 04 24             	mov    %eax,(%esp)
  800506:	ff 55 08             	call   *0x8(%ebp)
			break;
  800509:	e9 1e ff ff ff       	jmp    80042c <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80050e:	8b 45 14             	mov    0x14(%ebp),%eax
  800511:	8d 50 04             	lea    0x4(%eax),%edx
  800514:	89 55 14             	mov    %edx,0x14(%ebp)
  800517:	8b 00                	mov    (%eax),%eax
  800519:	89 c2                	mov    %eax,%edx
  80051b:	c1 fa 1f             	sar    $0x1f,%edx
  80051e:	31 d0                	xor    %edx,%eax
  800520:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800522:	83 f8 09             	cmp    $0x9,%eax
  800525:	7f 0b                	jg     800532 <vprintfmt+0x12b>
  800527:	8b 14 85 60 14 80 00 	mov    0x801460(,%eax,4),%edx
  80052e:	85 d2                	test   %edx,%edx
  800530:	75 20                	jne    800552 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  800532:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800536:	c7 44 24 08 44 12 80 	movl   $0x801244,0x8(%esp)
  80053d:	00 
  80053e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800542:	8b 45 08             	mov    0x8(%ebp),%eax
  800545:	89 04 24             	mov    %eax,(%esp)
  800548:	e8 92 fe ff ff       	call   8003df <printfmt>
  80054d:	e9 da fe ff ff       	jmp    80042c <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800552:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800556:	c7 44 24 08 4d 12 80 	movl   $0x80124d,0x8(%esp)
  80055d:	00 
  80055e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800562:	8b 45 08             	mov    0x8(%ebp),%eax
  800565:	89 04 24             	mov    %eax,(%esp)
  800568:	e8 72 fe ff ff       	call   8003df <printfmt>
  80056d:	e9 ba fe ff ff       	jmp    80042c <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800575:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800578:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8d 50 04             	lea    0x4(%eax),%edx
  800581:	89 55 14             	mov    %edx,0x14(%ebp)
  800584:	8b 30                	mov    (%eax),%esi
  800586:	85 f6                	test   %esi,%esi
  800588:	75 05                	jne    80058f <vprintfmt+0x188>
				p = "(null)";
  80058a:	be 3d 12 80 00       	mov    $0x80123d,%esi
			if (width > 0 && padc != '-')
  80058f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800593:	0f 84 8c 00 00 00    	je     800625 <vprintfmt+0x21e>
  800599:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80059d:	0f 8e 8a 00 00 00    	jle    80062d <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005a7:	89 34 24             	mov    %esi,(%esp)
  8005aa:	e8 9b 02 00 00       	call   80084a <strnlen>
  8005af:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005b2:	29 c1                	sub    %eax,%ecx
  8005b4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  8005b7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005be:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8005c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005c7:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c9:	eb 0d                	jmp    8005d8 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8005cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d2:	89 04 24             	mov    %eax,(%esp)
  8005d5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d7:	4b                   	dec    %ebx
  8005d8:	85 db                	test   %ebx,%ebx
  8005da:	7f ef                	jg     8005cb <vprintfmt+0x1c4>
  8005dc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005df:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005e2:	89 c8                	mov    %ecx,%eax
  8005e4:	f7 d0                	not    %eax
  8005e6:	c1 f8 1f             	sar    $0x1f,%eax
  8005e9:	21 c8                	and    %ecx,%eax
  8005eb:	29 c1                	sub    %eax,%ecx
  8005ed:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005f3:	eb 3e                	jmp    800633 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f9:	74 1b                	je     800616 <vprintfmt+0x20f>
  8005fb:	0f be d2             	movsbl %dl,%edx
  8005fe:	83 ea 20             	sub    $0x20,%edx
  800601:	83 fa 5e             	cmp    $0x5e,%edx
  800604:	76 10                	jbe    800616 <vprintfmt+0x20f>
					putch('?', putdat);
  800606:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80060a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800611:	ff 55 08             	call   *0x8(%ebp)
  800614:	eb 0a                	jmp    800620 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800616:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061a:	89 04 24             	mov    %eax,(%esp)
  80061d:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800620:	ff 4d dc             	decl   -0x24(%ebp)
  800623:	eb 0e                	jmp    800633 <vprintfmt+0x22c>
  800625:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800628:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80062b:	eb 06                	jmp    800633 <vprintfmt+0x22c>
  80062d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800630:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800633:	46                   	inc    %esi
  800634:	8a 56 ff             	mov    -0x1(%esi),%dl
  800637:	0f be c2             	movsbl %dl,%eax
  80063a:	85 c0                	test   %eax,%eax
  80063c:	74 1f                	je     80065d <vprintfmt+0x256>
  80063e:	85 db                	test   %ebx,%ebx
  800640:	78 b3                	js     8005f5 <vprintfmt+0x1ee>
  800642:	4b                   	dec    %ebx
  800643:	79 b0                	jns    8005f5 <vprintfmt+0x1ee>
  800645:	8b 75 08             	mov    0x8(%ebp),%esi
  800648:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80064b:	eb 16                	jmp    800663 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80064d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800651:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800658:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065a:	4b                   	dec    %ebx
  80065b:	eb 06                	jmp    800663 <vprintfmt+0x25c>
  80065d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800660:	8b 75 08             	mov    0x8(%ebp),%esi
  800663:	85 db                	test   %ebx,%ebx
  800665:	7f e6                	jg     80064d <vprintfmt+0x246>
  800667:	89 75 08             	mov    %esi,0x8(%ebp)
  80066a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80066d:	e9 ba fd ff ff       	jmp    80042c <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800672:	83 fa 01             	cmp    $0x1,%edx
  800675:	7e 16                	jle    80068d <vprintfmt+0x286>
		return va_arg(*ap, long long);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8d 50 08             	lea    0x8(%eax),%edx
  80067d:	89 55 14             	mov    %edx,0x14(%ebp)
  800680:	8b 50 04             	mov    0x4(%eax),%edx
  800683:	8b 00                	mov    (%eax),%eax
  800685:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800688:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80068b:	eb 32                	jmp    8006bf <vprintfmt+0x2b8>
	else if (lflag)
  80068d:	85 d2                	test   %edx,%edx
  80068f:	74 18                	je     8006a9 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8d 50 04             	lea    0x4(%eax),%edx
  800697:	89 55 14             	mov    %edx,0x14(%ebp)
  80069a:	8b 30                	mov    (%eax),%esi
  80069c:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80069f:	89 f0                	mov    %esi,%eax
  8006a1:	c1 f8 1f             	sar    $0x1f,%eax
  8006a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006a7:	eb 16                	jmp    8006bf <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  8006a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ac:	8d 50 04             	lea    0x4(%eax),%edx
  8006af:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b2:	8b 30                	mov    (%eax),%esi
  8006b4:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006b7:	89 f0                	mov    %esi,%eax
  8006b9:	c1 f8 1f             	sar    $0x1f,%eax
  8006bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006ce:	0f 89 80 00 00 00    	jns    800754 <vprintfmt+0x34d>
				putch('-', putdat);
  8006d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006df:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006e8:	f7 d8                	neg    %eax
  8006ea:	83 d2 00             	adc    $0x0,%edx
  8006ed:	f7 da                	neg    %edx
			}
			base = 10;
  8006ef:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006f4:	eb 5e                	jmp    800754 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f9:	e8 8b fc ff ff       	call   800389 <getuint>
			base = 10;
  8006fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800703:	eb 4f                	jmp    800754 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800705:	8d 45 14             	lea    0x14(%ebp),%eax
  800708:	e8 7c fc ff ff       	call   800389 <getuint>
			base = 8;
  80070d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800712:	eb 40                	jmp    800754 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800714:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800718:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80071f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800722:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800726:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80072d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800730:	8b 45 14             	mov    0x14(%ebp),%eax
  800733:	8d 50 04             	lea    0x4(%eax),%edx
  800736:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800739:	8b 00                	mov    (%eax),%eax
  80073b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800740:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800745:	eb 0d                	jmp    800754 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800747:	8d 45 14             	lea    0x14(%ebp),%eax
  80074a:	e8 3a fc ff ff       	call   800389 <getuint>
			base = 16;
  80074f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800754:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800758:	89 74 24 10          	mov    %esi,0x10(%esp)
  80075c:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80075f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800763:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800767:	89 04 24             	mov    %eax,(%esp)
  80076a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80076e:	89 fa                	mov    %edi,%edx
  800770:	8b 45 08             	mov    0x8(%ebp),%eax
  800773:	e8 20 fb ff ff       	call   800298 <printnum>
			break;
  800778:	e9 af fc ff ff       	jmp    80042c <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80077d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800781:	89 04 24             	mov    %eax,(%esp)
  800784:	ff 55 08             	call   *0x8(%ebp)
			break;
  800787:	e9 a0 fc ff ff       	jmp    80042c <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80078c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800790:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800797:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80079a:	89 f3                	mov    %esi,%ebx
  80079c:	eb 01                	jmp    80079f <vprintfmt+0x398>
  80079e:	4b                   	dec    %ebx
  80079f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007a3:	75 f9                	jne    80079e <vprintfmt+0x397>
  8007a5:	e9 82 fc ff ff       	jmp    80042c <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007aa:	83 c4 3c             	add    $0x3c,%esp
  8007ad:	5b                   	pop    %ebx
  8007ae:	5e                   	pop    %esi
  8007af:	5f                   	pop    %edi
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	83 ec 28             	sub    $0x28,%esp
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007cf:	85 c0                	test   %eax,%eax
  8007d1:	74 30                	je     800803 <vsnprintf+0x51>
  8007d3:	85 d2                	test   %edx,%edx
  8007d5:	7e 2c                	jle    800803 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007de:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ec:	c7 04 24 c3 03 80 00 	movl   $0x8003c3,(%esp)
  8007f3:	e8 0f fc ff ff       	call   800407 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007fb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800801:	eb 05                	jmp    800808 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800803:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800810:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800813:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800817:	8b 45 10             	mov    0x10(%ebp),%eax
  80081a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800821:	89 44 24 04          	mov    %eax,0x4(%esp)
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	89 04 24             	mov    %eax,(%esp)
  80082b:	e8 82 ff ff ff       	call   8007b2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800830:	c9                   	leave  
  800831:	c3                   	ret    
  800832:	66 90                	xchg   %ax,%ax

00800834 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80083a:	b8 00 00 00 00       	mov    $0x0,%eax
  80083f:	eb 01                	jmp    800842 <strlen+0xe>
		n++;
  800841:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800842:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800846:	75 f9                	jne    800841 <strlen+0xd>
		n++;
	return n;
}
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800850:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
  800858:	eb 01                	jmp    80085b <strnlen+0x11>
		n++;
  80085a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085b:	39 d0                	cmp    %edx,%eax
  80085d:	74 06                	je     800865 <strnlen+0x1b>
  80085f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800863:	75 f5                	jne    80085a <strnlen+0x10>
		n++;
	return n;
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800871:	89 c2                	mov    %eax,%edx
  800873:	42                   	inc    %edx
  800874:	41                   	inc    %ecx
  800875:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800878:	88 5a ff             	mov    %bl,-0x1(%edx)
  80087b:	84 db                	test   %bl,%bl
  80087d:	75 f4                	jne    800873 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80087f:	5b                   	pop    %ebx
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	53                   	push   %ebx
  800886:	83 ec 08             	sub    $0x8,%esp
  800889:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80088c:	89 1c 24             	mov    %ebx,(%esp)
  80088f:	e8 a0 ff ff ff       	call   800834 <strlen>
	strcpy(dst + len, src);
  800894:	8b 55 0c             	mov    0xc(%ebp),%edx
  800897:	89 54 24 04          	mov    %edx,0x4(%esp)
  80089b:	01 d8                	add    %ebx,%eax
  80089d:	89 04 24             	mov    %eax,(%esp)
  8008a0:	e8 c2 ff ff ff       	call   800867 <strcpy>
	return dst;
}
  8008a5:	89 d8                	mov    %ebx,%eax
  8008a7:	83 c4 08             	add    $0x8,%esp
  8008aa:	5b                   	pop    %ebx
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	56                   	push   %esi
  8008b1:	53                   	push   %ebx
  8008b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b8:	89 f3                	mov    %esi,%ebx
  8008ba:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008bd:	89 f2                	mov    %esi,%edx
  8008bf:	eb 0c                	jmp    8008cd <strncpy+0x20>
		*dst++ = *src;
  8008c1:	42                   	inc    %edx
  8008c2:	8a 01                	mov    (%ecx),%al
  8008c4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c7:	80 39 01             	cmpb   $0x1,(%ecx)
  8008ca:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008cd:	39 da                	cmp    %ebx,%edx
  8008cf:	75 f0                	jne    8008c1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008d1:	89 f0                	mov    %esi,%eax
  8008d3:	5b                   	pop    %ebx
  8008d4:	5e                   	pop    %esi
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	56                   	push   %esi
  8008db:	53                   	push   %ebx
  8008dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8008df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008e5:	89 f0                	mov    %esi,%eax
  8008e7:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008eb:	85 c9                	test   %ecx,%ecx
  8008ed:	75 07                	jne    8008f6 <strlcpy+0x1f>
  8008ef:	eb 18                	jmp    800909 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008f1:	40                   	inc    %eax
  8008f2:	42                   	inc    %edx
  8008f3:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008f6:	39 d8                	cmp    %ebx,%eax
  8008f8:	74 0a                	je     800904 <strlcpy+0x2d>
  8008fa:	8a 0a                	mov    (%edx),%cl
  8008fc:	84 c9                	test   %cl,%cl
  8008fe:	75 f1                	jne    8008f1 <strlcpy+0x1a>
  800900:	89 c2                	mov    %eax,%edx
  800902:	eb 02                	jmp    800906 <strlcpy+0x2f>
  800904:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800906:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800909:	29 f0                	sub    %esi,%eax
}
  80090b:	5b                   	pop    %ebx
  80090c:	5e                   	pop    %esi
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800915:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800918:	eb 02                	jmp    80091c <strcmp+0xd>
		p++, q++;
  80091a:	41                   	inc    %ecx
  80091b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80091c:	8a 01                	mov    (%ecx),%al
  80091e:	84 c0                	test   %al,%al
  800920:	74 04                	je     800926 <strcmp+0x17>
  800922:	3a 02                	cmp    (%edx),%al
  800924:	74 f4                	je     80091a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800926:	25 ff 00 00 00       	and    $0xff,%eax
  80092b:	8a 0a                	mov    (%edx),%cl
  80092d:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  800933:	29 c8                	sub    %ecx,%eax
}
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	53                   	push   %ebx
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800941:	89 c3                	mov    %eax,%ebx
  800943:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800946:	eb 02                	jmp    80094a <strncmp+0x13>
		n--, p++, q++;
  800948:	40                   	inc    %eax
  800949:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80094a:	39 d8                	cmp    %ebx,%eax
  80094c:	74 20                	je     80096e <strncmp+0x37>
  80094e:	8a 08                	mov    (%eax),%cl
  800950:	84 c9                	test   %cl,%cl
  800952:	74 04                	je     800958 <strncmp+0x21>
  800954:	3a 0a                	cmp    (%edx),%cl
  800956:	74 f0                	je     800948 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800958:	8a 18                	mov    (%eax),%bl
  80095a:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800960:	89 d8                	mov    %ebx,%eax
  800962:	8a 1a                	mov    (%edx),%bl
  800964:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80096a:	29 d8                	sub    %ebx,%eax
  80096c:	eb 05                	jmp    800973 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80096e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800973:	5b                   	pop    %ebx
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80097f:	eb 05                	jmp    800986 <strchr+0x10>
		if (*s == c)
  800981:	38 ca                	cmp    %cl,%dl
  800983:	74 0c                	je     800991 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800985:	40                   	inc    %eax
  800986:	8a 10                	mov    (%eax),%dl
  800988:	84 d2                	test   %dl,%dl
  80098a:	75 f5                	jne    800981 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80098c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80099c:	eb 05                	jmp    8009a3 <strfind+0x10>
		if (*s == c)
  80099e:	38 ca                	cmp    %cl,%dl
  8009a0:	74 07                	je     8009a9 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009a2:	40                   	inc    %eax
  8009a3:	8a 10                	mov    (%eax),%dl
  8009a5:	84 d2                	test   %dl,%dl
  8009a7:	75 f5                	jne    80099e <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	57                   	push   %edi
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b7:	85 c9                	test   %ecx,%ecx
  8009b9:	74 37                	je     8009f2 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009bb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009c1:	75 29                	jne    8009ec <memset+0x41>
  8009c3:	f6 c1 03             	test   $0x3,%cl
  8009c6:	75 24                	jne    8009ec <memset+0x41>
		c &= 0xFF;
  8009c8:	31 d2                	xor    %edx,%edx
  8009ca:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009cd:	89 d3                	mov    %edx,%ebx
  8009cf:	c1 e3 08             	shl    $0x8,%ebx
  8009d2:	89 d6                	mov    %edx,%esi
  8009d4:	c1 e6 18             	shl    $0x18,%esi
  8009d7:	89 d0                	mov    %edx,%eax
  8009d9:	c1 e0 10             	shl    $0x10,%eax
  8009dc:	09 f0                	or     %esi,%eax
  8009de:	09 c2                	or     %eax,%edx
  8009e0:	89 d0                	mov    %edx,%eax
  8009e2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009e4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009e7:	fc                   	cld    
  8009e8:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ea:	eb 06                	jmp    8009f2 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ef:	fc                   	cld    
  8009f0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f2:	89 f8                	mov    %edi,%eax
  8009f4:	5b                   	pop    %ebx
  8009f5:	5e                   	pop    %esi
  8009f6:	5f                   	pop    %edi
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	57                   	push   %edi
  8009fd:	56                   	push   %esi
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a04:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a07:	39 c6                	cmp    %eax,%esi
  800a09:	73 33                	jae    800a3e <memmove+0x45>
  800a0b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a0e:	39 d0                	cmp    %edx,%eax
  800a10:	73 2c                	jae    800a3e <memmove+0x45>
		s += n;
		d += n;
  800a12:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a15:	89 d6                	mov    %edx,%esi
  800a17:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a19:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a1f:	75 13                	jne    800a34 <memmove+0x3b>
  800a21:	f6 c1 03             	test   $0x3,%cl
  800a24:	75 0e                	jne    800a34 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a26:	83 ef 04             	sub    $0x4,%edi
  800a29:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a2c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a2f:	fd                   	std    
  800a30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a32:	eb 07                	jmp    800a3b <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a34:	4f                   	dec    %edi
  800a35:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a38:	fd                   	std    
  800a39:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a3b:	fc                   	cld    
  800a3c:	eb 1d                	jmp    800a5b <memmove+0x62>
  800a3e:	89 f2                	mov    %esi,%edx
  800a40:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a42:	f6 c2 03             	test   $0x3,%dl
  800a45:	75 0f                	jne    800a56 <memmove+0x5d>
  800a47:	f6 c1 03             	test   $0x3,%cl
  800a4a:	75 0a                	jne    800a56 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a4c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a4f:	89 c7                	mov    %eax,%edi
  800a51:	fc                   	cld    
  800a52:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a54:	eb 05                	jmp    800a5b <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a56:	89 c7                	mov    %eax,%edi
  800a58:	fc                   	cld    
  800a59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a5b:	5e                   	pop    %esi
  800a5c:	5f                   	pop    %edi
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a65:	8b 45 10             	mov    0x10(%ebp),%eax
  800a68:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	89 04 24             	mov    %eax,(%esp)
  800a79:	e8 7b ff ff ff       	call   8009f9 <memmove>
}
  800a7e:	c9                   	leave  
  800a7f:	c3                   	ret    

00800a80 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
  800a85:	8b 55 08             	mov    0x8(%ebp),%edx
  800a88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8b:	89 d6                	mov    %edx,%esi
  800a8d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a90:	eb 19                	jmp    800aab <memcmp+0x2b>
		if (*s1 != *s2)
  800a92:	8a 02                	mov    (%edx),%al
  800a94:	8a 19                	mov    (%ecx),%bl
  800a96:	38 d8                	cmp    %bl,%al
  800a98:	74 0f                	je     800aa9 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800a9a:	25 ff 00 00 00       	and    $0xff,%eax
  800a9f:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800aa5:	29 d8                	sub    %ebx,%eax
  800aa7:	eb 0b                	jmp    800ab4 <memcmp+0x34>
		s1++, s2++;
  800aa9:	42                   	inc    %edx
  800aaa:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aab:	39 f2                	cmp    %esi,%edx
  800aad:	75 e3                	jne    800a92 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aaf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	5d                   	pop    %ebp
  800ab7:	c3                   	ret    

00800ab8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	8b 45 08             	mov    0x8(%ebp),%eax
  800abe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ac1:	89 c2                	mov    %eax,%edx
  800ac3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac6:	eb 05                	jmp    800acd <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac8:	38 08                	cmp    %cl,(%eax)
  800aca:	74 05                	je     800ad1 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800acc:	40                   	inc    %eax
  800acd:	39 d0                	cmp    %edx,%eax
  800acf:	72 f7                	jb     800ac8 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	8b 55 08             	mov    0x8(%ebp),%edx
  800adc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800adf:	eb 01                	jmp    800ae2 <strtol+0xf>
		s++;
  800ae1:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae2:	8a 02                	mov    (%edx),%al
  800ae4:	3c 09                	cmp    $0x9,%al
  800ae6:	74 f9                	je     800ae1 <strtol+0xe>
  800ae8:	3c 20                	cmp    $0x20,%al
  800aea:	74 f5                	je     800ae1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aec:	3c 2b                	cmp    $0x2b,%al
  800aee:	75 08                	jne    800af8 <strtol+0x25>
		s++;
  800af0:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800af1:	bf 00 00 00 00       	mov    $0x0,%edi
  800af6:	eb 10                	jmp    800b08 <strtol+0x35>
  800af8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800afd:	3c 2d                	cmp    $0x2d,%al
  800aff:	75 07                	jne    800b08 <strtol+0x35>
		s++, neg = 1;
  800b01:	8d 52 01             	lea    0x1(%edx),%edx
  800b04:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b08:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b0e:	75 15                	jne    800b25 <strtol+0x52>
  800b10:	80 3a 30             	cmpb   $0x30,(%edx)
  800b13:	75 10                	jne    800b25 <strtol+0x52>
  800b15:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b19:	75 0a                	jne    800b25 <strtol+0x52>
		s += 2, base = 16;
  800b1b:	83 c2 02             	add    $0x2,%edx
  800b1e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b23:	eb 0e                	jmp    800b33 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800b25:	85 db                	test   %ebx,%ebx
  800b27:	75 0a                	jne    800b33 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b29:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b2b:	80 3a 30             	cmpb   $0x30,(%edx)
  800b2e:	75 03                	jne    800b33 <strtol+0x60>
		s++, base = 8;
  800b30:	42                   	inc    %edx
  800b31:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b33:	b8 00 00 00 00       	mov    $0x0,%eax
  800b38:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b3b:	8a 0a                	mov    (%edx),%cl
  800b3d:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b40:	89 f3                	mov    %esi,%ebx
  800b42:	80 fb 09             	cmp    $0x9,%bl
  800b45:	77 08                	ja     800b4f <strtol+0x7c>
			dig = *s - '0';
  800b47:	0f be c9             	movsbl %cl,%ecx
  800b4a:	83 e9 30             	sub    $0x30,%ecx
  800b4d:	eb 22                	jmp    800b71 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800b4f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b52:	89 f3                	mov    %esi,%ebx
  800b54:	80 fb 19             	cmp    $0x19,%bl
  800b57:	77 08                	ja     800b61 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800b59:	0f be c9             	movsbl %cl,%ecx
  800b5c:	83 e9 57             	sub    $0x57,%ecx
  800b5f:	eb 10                	jmp    800b71 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800b61:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b64:	89 f3                	mov    %esi,%ebx
  800b66:	80 fb 19             	cmp    $0x19,%bl
  800b69:	77 14                	ja     800b7f <strtol+0xac>
			dig = *s - 'A' + 10;
  800b6b:	0f be c9             	movsbl %cl,%ecx
  800b6e:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b71:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b74:	7d 0d                	jge    800b83 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b76:	42                   	inc    %edx
  800b77:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b7b:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b7d:	eb bc                	jmp    800b3b <strtol+0x68>
  800b7f:	89 c1                	mov    %eax,%ecx
  800b81:	eb 02                	jmp    800b85 <strtol+0xb2>
  800b83:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b85:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b89:	74 05                	je     800b90 <strtol+0xbd>
		*endptr = (char *) s;
  800b8b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b8e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b90:	85 ff                	test   %edi,%edi
  800b92:	74 04                	je     800b98 <strtol+0xc5>
  800b94:	89 c8                	mov    %ecx,%eax
  800b96:	f7 d8                	neg    %eax
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    
  800b9d:	66 90                	xchg   %ax,%ax
  800b9f:	90                   	nop

00800ba0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bae:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb1:	89 c3                	mov    %eax,%ebx
  800bb3:	89 c7                	mov    %eax,%edi
  800bb5:	89 c6                	mov    %eax,%esi
  800bb7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_cgetc>:

int
sys_cgetc(void)
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
  800bc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bce:	89 d1                	mov    %edx,%ecx
  800bd0:	89 d3                	mov    %edx,%ebx
  800bd2:	89 d7                	mov    %edx,%edi
  800bd4:	89 d6                	mov    %edx,%esi
  800bd6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800be6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800beb:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf3:	89 cb                	mov    %ecx,%ebx
  800bf5:	89 cf                	mov    %ecx,%edi
  800bf7:	89 ce                	mov    %ecx,%esi
  800bf9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 28                	jle    800c27 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c03:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c0a:	00 
  800c0b:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800c12:	00 
  800c13:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c1a:	00 
  800c1b:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800c22:	e8 5d f5 ff ff       	call   800184 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c27:	83 c4 2c             	add    $0x2c,%esp
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c35:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c3f:	89 d1                	mov    %edx,%ecx
  800c41:	89 d3                	mov    %edx,%ebx
  800c43:	89 d7                	mov    %edx,%edi
  800c45:	89 d6                	mov    %edx,%esi
  800c47:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5f                   	pop    %edi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <sys_yield>:

void
sys_yield(void)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c54:	ba 00 00 00 00       	mov    $0x0,%edx
  800c59:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c5e:	89 d1                	mov    %edx,%ecx
  800c60:	89 d3                	mov    %edx,%ebx
  800c62:	89 d7                	mov    %edx,%edi
  800c64:	89 d6                	mov    %edx,%esi
  800c66:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
  800c73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c76:	be 00 00 00 00       	mov    $0x0,%esi
  800c7b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c89:	89 f7                	mov    %esi,%edi
  800c8b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c8d:	85 c0                	test   %eax,%eax
  800c8f:	7e 28                	jle    800cb9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c91:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c95:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c9c:	00 
  800c9d:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800ca4:	00 
  800ca5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cac:	00 
  800cad:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800cb4:	e8 cb f4 ff ff       	call   800184 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb9:	83 c4 2c             	add    $0x2c,%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	b8 05 00 00 00       	mov    $0x5,%eax
  800ccf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cdb:	8b 75 18             	mov    0x18(%ebp),%esi
  800cde:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7e 28                	jle    800d0c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cef:	00 
  800cf0:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800cf7:	00 
  800cf8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cff:	00 
  800d00:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800d07:	e8 78 f4 ff ff       	call   800184 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d0c:	83 c4 2c             	add    $0x2c,%esp
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d22:	b8 06 00 00 00       	mov    $0x6,%eax
  800d27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2d:	89 df                	mov    %ebx,%edi
  800d2f:	89 de                	mov    %ebx,%esi
  800d31:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d33:	85 c0                	test   %eax,%eax
  800d35:	7e 28                	jle    800d5f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d42:	00 
  800d43:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800d4a:	00 
  800d4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d52:	00 
  800d53:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800d5a:	e8 25 f4 ff ff       	call   800184 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d5f:	83 c4 2c             	add    $0x2c,%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d75:	b8 08 00 00 00       	mov    $0x8,%eax
  800d7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d80:	89 df                	mov    %ebx,%edi
  800d82:	89 de                	mov    %ebx,%esi
  800d84:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d86:	85 c0                	test   %eax,%eax
  800d88:	7e 28                	jle    800db2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d95:	00 
  800d96:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800d9d:	00 
  800d9e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da5:	00 
  800da6:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800dad:	e8 d2 f3 ff ff       	call   800184 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800db2:	83 c4 2c             	add    $0x2c,%esp
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
  800dc0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc8:	b8 09 00 00 00       	mov    $0x9,%eax
  800dcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd3:	89 df                	mov    %ebx,%edi
  800dd5:	89 de                	mov    %ebx,%esi
  800dd7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	7e 28                	jle    800e05 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800de8:	00 
  800de9:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800df0:	00 
  800df1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df8:	00 
  800df9:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800e00:	e8 7f f3 ff ff       	call   800184 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e05:	83 c4 2c             	add    $0x2c,%esp
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	57                   	push   %edi
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e13:	be 00 00 00 00       	mov    $0x0,%esi
  800e18:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e26:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e29:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e2b:	5b                   	pop    %ebx
  800e2c:	5e                   	pop    %esi
  800e2d:	5f                   	pop    %edi
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    

00800e30 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	57                   	push   %edi
  800e34:	56                   	push   %esi
  800e35:	53                   	push   %ebx
  800e36:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e3e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e43:	8b 55 08             	mov    0x8(%ebp),%edx
  800e46:	89 cb                	mov    %ecx,%ebx
  800e48:	89 cf                	mov    %ecx,%edi
  800e4a:	89 ce                	mov    %ecx,%esi
  800e4c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e4e:	85 c0                	test   %eax,%eax
  800e50:	7e 28                	jle    800e7a <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e52:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e56:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e5d:	00 
  800e5e:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800e65:	00 
  800e66:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6d:	00 
  800e6e:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800e75:	e8 0a f3 ff ff       	call   800184 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e7a:	83 c4 2c             	add    $0x2c,%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    
  800e82:	66 90                	xchg   %ax,%ax
  800e84:	66 90                	xchg   %ax,%ax
  800e86:	66 90                	xchg   %ax,%ax
  800e88:	66 90                	xchg   %ax,%ax
  800e8a:	66 90                	xchg   %ax,%ax
  800e8c:	66 90                	xchg   %ax,%ax
  800e8e:	66 90                	xchg   %ax,%ax

00800e90 <__udivdi3>:
  800e90:	55                   	push   %ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	83 ec 0c             	sub    $0xc,%esp
  800e96:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800e9a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800e9e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800ea2:	8b 44 24 28          	mov    0x28(%esp),%eax
  800ea6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800eaa:	89 ea                	mov    %ebp,%edx
  800eac:	89 0c 24             	mov    %ecx,(%esp)
  800eaf:	85 c0                	test   %eax,%eax
  800eb1:	75 2d                	jne    800ee0 <__udivdi3+0x50>
  800eb3:	39 e9                	cmp    %ebp,%ecx
  800eb5:	77 61                	ja     800f18 <__udivdi3+0x88>
  800eb7:	89 ce                	mov    %ecx,%esi
  800eb9:	85 c9                	test   %ecx,%ecx
  800ebb:	75 0b                	jne    800ec8 <__udivdi3+0x38>
  800ebd:	b8 01 00 00 00       	mov    $0x1,%eax
  800ec2:	31 d2                	xor    %edx,%edx
  800ec4:	f7 f1                	div    %ecx
  800ec6:	89 c6                	mov    %eax,%esi
  800ec8:	31 d2                	xor    %edx,%edx
  800eca:	89 e8                	mov    %ebp,%eax
  800ecc:	f7 f6                	div    %esi
  800ece:	89 c5                	mov    %eax,%ebp
  800ed0:	89 f8                	mov    %edi,%eax
  800ed2:	f7 f6                	div    %esi
  800ed4:	89 ea                	mov    %ebp,%edx
  800ed6:	83 c4 0c             	add    $0xc,%esp
  800ed9:	5e                   	pop    %esi
  800eda:	5f                   	pop    %edi
  800edb:	5d                   	pop    %ebp
  800edc:	c3                   	ret    
  800edd:	8d 76 00             	lea    0x0(%esi),%esi
  800ee0:	39 e8                	cmp    %ebp,%eax
  800ee2:	77 24                	ja     800f08 <__udivdi3+0x78>
  800ee4:	0f bd e8             	bsr    %eax,%ebp
  800ee7:	83 f5 1f             	xor    $0x1f,%ebp
  800eea:	75 3c                	jne    800f28 <__udivdi3+0x98>
  800eec:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ef0:	39 34 24             	cmp    %esi,(%esp)
  800ef3:	0f 86 9f 00 00 00    	jbe    800f98 <__udivdi3+0x108>
  800ef9:	39 d0                	cmp    %edx,%eax
  800efb:	0f 82 97 00 00 00    	jb     800f98 <__udivdi3+0x108>
  800f01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f08:	31 d2                	xor    %edx,%edx
  800f0a:	31 c0                	xor    %eax,%eax
  800f0c:	83 c4 0c             	add    $0xc,%esp
  800f0f:	5e                   	pop    %esi
  800f10:	5f                   	pop    %edi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    
  800f13:	90                   	nop
  800f14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f18:	89 f8                	mov    %edi,%eax
  800f1a:	f7 f1                	div    %ecx
  800f1c:	31 d2                	xor    %edx,%edx
  800f1e:	83 c4 0c             	add    $0xc,%esp
  800f21:	5e                   	pop    %esi
  800f22:	5f                   	pop    %edi
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    
  800f25:	8d 76 00             	lea    0x0(%esi),%esi
  800f28:	89 e9                	mov    %ebp,%ecx
  800f2a:	8b 3c 24             	mov    (%esp),%edi
  800f2d:	d3 e0                	shl    %cl,%eax
  800f2f:	89 c6                	mov    %eax,%esi
  800f31:	b8 20 00 00 00       	mov    $0x20,%eax
  800f36:	29 e8                	sub    %ebp,%eax
  800f38:	88 c1                	mov    %al,%cl
  800f3a:	d3 ef                	shr    %cl,%edi
  800f3c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f40:	89 e9                	mov    %ebp,%ecx
  800f42:	8b 3c 24             	mov    (%esp),%edi
  800f45:	09 74 24 08          	or     %esi,0x8(%esp)
  800f49:	d3 e7                	shl    %cl,%edi
  800f4b:	89 d6                	mov    %edx,%esi
  800f4d:	88 c1                	mov    %al,%cl
  800f4f:	d3 ee                	shr    %cl,%esi
  800f51:	89 e9                	mov    %ebp,%ecx
  800f53:	89 3c 24             	mov    %edi,(%esp)
  800f56:	d3 e2                	shl    %cl,%edx
  800f58:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f5c:	88 c1                	mov    %al,%cl
  800f5e:	d3 ef                	shr    %cl,%edi
  800f60:	09 d7                	or     %edx,%edi
  800f62:	89 f2                	mov    %esi,%edx
  800f64:	89 f8                	mov    %edi,%eax
  800f66:	f7 74 24 08          	divl   0x8(%esp)
  800f6a:	89 d6                	mov    %edx,%esi
  800f6c:	89 c7                	mov    %eax,%edi
  800f6e:	f7 24 24             	mull   (%esp)
  800f71:	89 14 24             	mov    %edx,(%esp)
  800f74:	39 d6                	cmp    %edx,%esi
  800f76:	72 30                	jb     800fa8 <__udivdi3+0x118>
  800f78:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f7c:	89 e9                	mov    %ebp,%ecx
  800f7e:	d3 e2                	shl    %cl,%edx
  800f80:	39 c2                	cmp    %eax,%edx
  800f82:	73 05                	jae    800f89 <__udivdi3+0xf9>
  800f84:	3b 34 24             	cmp    (%esp),%esi
  800f87:	74 1f                	je     800fa8 <__udivdi3+0x118>
  800f89:	89 f8                	mov    %edi,%eax
  800f8b:	31 d2                	xor    %edx,%edx
  800f8d:	e9 7a ff ff ff       	jmp    800f0c <__udivdi3+0x7c>
  800f92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f98:	31 d2                	xor    %edx,%edx
  800f9a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9f:	e9 68 ff ff ff       	jmp    800f0c <__udivdi3+0x7c>
  800fa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fa8:	8d 47 ff             	lea    -0x1(%edi),%eax
  800fab:	31 d2                	xor    %edx,%edx
  800fad:	83 c4 0c             	add    $0xc,%esp
  800fb0:	5e                   	pop    %esi
  800fb1:	5f                   	pop    %edi
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    
  800fb4:	66 90                	xchg   %ax,%ax
  800fb6:	66 90                	xchg   %ax,%ax
  800fb8:	66 90                	xchg   %ax,%ax
  800fba:	66 90                	xchg   %ax,%ax
  800fbc:	66 90                	xchg   %ax,%ax
  800fbe:	66 90                	xchg   %ax,%ax

00800fc0 <__umoddi3>:
  800fc0:	55                   	push   %ebp
  800fc1:	57                   	push   %edi
  800fc2:	56                   	push   %esi
  800fc3:	83 ec 14             	sub    $0x14,%esp
  800fc6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800fca:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800fce:	89 c7                	mov    %eax,%edi
  800fd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800fd8:	8b 44 24 30          	mov    0x30(%esp),%eax
  800fdc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fe0:	89 34 24             	mov    %esi,(%esp)
  800fe3:	89 c2                	mov    %eax,%edx
  800fe5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fe9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fed:	85 c0                	test   %eax,%eax
  800fef:	75 17                	jne    801008 <__umoddi3+0x48>
  800ff1:	39 fe                	cmp    %edi,%esi
  800ff3:	76 4b                	jbe    801040 <__umoddi3+0x80>
  800ff5:	89 c8                	mov    %ecx,%eax
  800ff7:	89 fa                	mov    %edi,%edx
  800ff9:	f7 f6                	div    %esi
  800ffb:	89 d0                	mov    %edx,%eax
  800ffd:	31 d2                	xor    %edx,%edx
  800fff:	83 c4 14             	add    $0x14,%esp
  801002:	5e                   	pop    %esi
  801003:	5f                   	pop    %edi
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    
  801006:	66 90                	xchg   %ax,%ax
  801008:	39 f8                	cmp    %edi,%eax
  80100a:	77 54                	ja     801060 <__umoddi3+0xa0>
  80100c:	0f bd e8             	bsr    %eax,%ebp
  80100f:	83 f5 1f             	xor    $0x1f,%ebp
  801012:	75 5c                	jne    801070 <__umoddi3+0xb0>
  801014:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801018:	39 3c 24             	cmp    %edi,(%esp)
  80101b:	0f 87 f7 00 00 00    	ja     801118 <__umoddi3+0x158>
  801021:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801025:	29 f1                	sub    %esi,%ecx
  801027:	19 c7                	sbb    %eax,%edi
  801029:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80102d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801031:	8b 44 24 08          	mov    0x8(%esp),%eax
  801035:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801039:	83 c4 14             	add    $0x14,%esp
  80103c:	5e                   	pop    %esi
  80103d:	5f                   	pop    %edi
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    
  801040:	89 f5                	mov    %esi,%ebp
  801042:	85 f6                	test   %esi,%esi
  801044:	75 0b                	jne    801051 <__umoddi3+0x91>
  801046:	b8 01 00 00 00       	mov    $0x1,%eax
  80104b:	31 d2                	xor    %edx,%edx
  80104d:	f7 f6                	div    %esi
  80104f:	89 c5                	mov    %eax,%ebp
  801051:	8b 44 24 04          	mov    0x4(%esp),%eax
  801055:	31 d2                	xor    %edx,%edx
  801057:	f7 f5                	div    %ebp
  801059:	89 c8                	mov    %ecx,%eax
  80105b:	f7 f5                	div    %ebp
  80105d:	eb 9c                	jmp    800ffb <__umoddi3+0x3b>
  80105f:	90                   	nop
  801060:	89 c8                	mov    %ecx,%eax
  801062:	89 fa                	mov    %edi,%edx
  801064:	83 c4 14             	add    $0x14,%esp
  801067:	5e                   	pop    %esi
  801068:	5f                   	pop    %edi
  801069:	5d                   	pop    %ebp
  80106a:	c3                   	ret    
  80106b:	90                   	nop
  80106c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801070:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801077:	00 
  801078:	8b 34 24             	mov    (%esp),%esi
  80107b:	8b 44 24 04          	mov    0x4(%esp),%eax
  80107f:	89 e9                	mov    %ebp,%ecx
  801081:	29 e8                	sub    %ebp,%eax
  801083:	89 44 24 04          	mov    %eax,0x4(%esp)
  801087:	89 f0                	mov    %esi,%eax
  801089:	d3 e2                	shl    %cl,%edx
  80108b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  80108f:	d3 e8                	shr    %cl,%eax
  801091:	89 04 24             	mov    %eax,(%esp)
  801094:	89 e9                	mov    %ebp,%ecx
  801096:	89 f0                	mov    %esi,%eax
  801098:	09 14 24             	or     %edx,(%esp)
  80109b:	d3 e0                	shl    %cl,%eax
  80109d:	89 fa                	mov    %edi,%edx
  80109f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8010a3:	d3 ea                	shr    %cl,%edx
  8010a5:	89 e9                	mov    %ebp,%ecx
  8010a7:	89 c6                	mov    %eax,%esi
  8010a9:	d3 e7                	shl    %cl,%edi
  8010ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010af:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8010b3:	8b 44 24 10          	mov    0x10(%esp),%eax
  8010b7:	d3 e8                	shr    %cl,%eax
  8010b9:	09 f8                	or     %edi,%eax
  8010bb:	89 e9                	mov    %ebp,%ecx
  8010bd:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8010c1:	d3 e7                	shl    %cl,%edi
  8010c3:	f7 34 24             	divl   (%esp)
  8010c6:	89 d1                	mov    %edx,%ecx
  8010c8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010cc:	f7 e6                	mul    %esi
  8010ce:	89 c7                	mov    %eax,%edi
  8010d0:	89 d6                	mov    %edx,%esi
  8010d2:	39 d1                	cmp    %edx,%ecx
  8010d4:	72 2e                	jb     801104 <__umoddi3+0x144>
  8010d6:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8010da:	72 24                	jb     801100 <__umoddi3+0x140>
  8010dc:	89 ca                	mov    %ecx,%edx
  8010de:	89 e9                	mov    %ebp,%ecx
  8010e0:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010e4:	29 f8                	sub    %edi,%eax
  8010e6:	19 f2                	sbb    %esi,%edx
  8010e8:	d3 e8                	shr    %cl,%eax
  8010ea:	89 d6                	mov    %edx,%esi
  8010ec:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8010f0:	d3 e6                	shl    %cl,%esi
  8010f2:	89 e9                	mov    %ebp,%ecx
  8010f4:	09 f0                	or     %esi,%eax
  8010f6:	d3 ea                	shr    %cl,%edx
  8010f8:	83 c4 14             	add    $0x14,%esp
  8010fb:	5e                   	pop    %esi
  8010fc:	5f                   	pop    %edi
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    
  8010ff:	90                   	nop
  801100:	39 d1                	cmp    %edx,%ecx
  801102:	75 d8                	jne    8010dc <__umoddi3+0x11c>
  801104:	89 d6                	mov    %edx,%esi
  801106:	89 c7                	mov    %eax,%edi
  801108:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  80110c:	1b 34 24             	sbb    (%esp),%esi
  80110f:	eb cb                	jmp    8010dc <__umoddi3+0x11c>
  801111:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801118:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80111c:	0f 82 ff fe ff ff    	jb     801021 <__umoddi3+0x61>
  801122:	e9 0a ff ff ff       	jmp    801031 <__umoddi3+0x71>
