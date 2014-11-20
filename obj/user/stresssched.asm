
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 d3 00 00 00       	call   800104 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  80003c:	e8 f6 0b 00 00       	call   800c37 <sys_getenvid>
  800041:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800043:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800048:	e8 14 0f 00 00       	call   800f61 <fork>
  80004d:	85 c0                	test   %eax,%eax
  80004f:	74 08                	je     800059 <umain+0x25>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  800051:	43                   	inc    %ebx
  800052:	83 fb 14             	cmp    $0x14,%ebx
  800055:	75 f1                	jne    800048 <umain+0x14>
  800057:	eb 22                	jmp    80007b <umain+0x47>
		if (fork() == 0)
			break;
	if (i == 20) {
  800059:	83 fb 14             	cmp    $0x14,%ebx
  80005c:	74 1d                	je     80007b <umain+0x47>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80005e:	89 f0                	mov    %esi,%eax
  800060:	25 ff 03 00 00       	and    $0x3ff,%eax
  800065:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80006c:	c1 e0 07             	shl    $0x7,%eax
  80006f:	29 c8                	sub    %ecx,%eax
  800071:	89 c2                	mov    %eax,%edx
  800073:	81 c2 04 00 c0 ee    	add    $0xeec00004,%edx
  800079:	eb 09                	jmp    800084 <umain+0x50>
	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
			break;
	if (i == 20) {
		sys_yield();
  80007b:	e8 d6 0b 00 00       	call   800c56 <sys_yield>
		return;
  800080:	eb 7b                	jmp    8000fd <umain+0xc9>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800082:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800084:	8b 42 50             	mov    0x50(%edx),%eax
  800087:	85 c0                	test   %eax,%eax
  800089:	75 f7                	jne    800082 <umain+0x4e>
  80008b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800090:	e8 c1 0b 00 00       	call   800c56 <sys_yield>
  800095:	b8 10 27 00 00       	mov    $0x2710,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  80009a:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000a0:	42                   	inc    %edx
  8000a1:	89 15 04 20 80 00    	mov    %edx,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000a7:	48                   	dec    %eax
  8000a8:	75 f0                	jne    80009a <umain+0x66>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000aa:	4b                   	dec    %ebx
  8000ab:	75 e3                	jne    800090 <umain+0x5c>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000ad:	a1 04 20 80 00       	mov    0x802004,%eax
  8000b2:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b7:	74 25                	je     8000de <umain+0xaa>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b9:	a1 04 20 80 00       	mov    0x802004,%eax
  8000be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c2:	c7 44 24 08 00 15 80 	movl   $0x801500,0x8(%esp)
  8000c9:	00 
  8000ca:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000d1:	00 
  8000d2:	c7 04 24 28 15 80 00 	movl   $0x801528,(%esp)
  8000d9:	e8 ae 00 00 00       	call   80018c <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000de:	a1 08 20 80 00       	mov    0x802008,%eax
  8000e3:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000e6:	8b 40 48             	mov    0x48(%eax),%eax
  8000e9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f1:	c7 04 24 3b 15 80 00 	movl   $0x80153b,(%esp)
  8000f8:	e8 89 01 00 00       	call   800286 <cprintf>

}
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	56                   	push   %esi
  800108:	53                   	push   %ebx
  800109:	83 ec 10             	sub    $0x10,%esp
  80010c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80010f:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  800112:	b8 10 20 80 00       	mov    $0x802010,%eax
  800117:	2d 04 20 80 00       	sub    $0x802004,%eax
  80011c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800120:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800127:	00 
  800128:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  80012f:	e8 7f 08 00 00       	call   8009b3 <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  800134:	e8 fe 0a 00 00       	call   800c37 <sys_getenvid>
  800139:	25 ff 03 00 00       	and    $0x3ff,%eax
  80013e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800145:	c1 e0 07             	shl    $0x7,%eax
  800148:	29 d0                	sub    %edx,%eax
  80014a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80014f:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800154:	85 db                	test   %ebx,%ebx
  800156:	7e 07                	jle    80015f <libmain+0x5b>
		binaryname = argv[0];
  800158:	8b 06                	mov    (%esi),%eax
  80015a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80015f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800163:	89 1c 24             	mov    %ebx,(%esp)
  800166:	e8 c9 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80016b:	e8 08 00 00 00       	call   800178 <exit>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	5b                   	pop    %ebx
  800174:	5e                   	pop    %esi
  800175:	5d                   	pop    %ebp
  800176:	c3                   	ret    
  800177:	90                   	nop

00800178 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80017e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800185:	e8 5b 0a 00 00       	call   800be5 <sys_env_destroy>
}
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	56                   	push   %esi
  800190:	53                   	push   %ebx
  800191:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800194:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800197:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80019d:	e8 95 0a 00 00       	call   800c37 <sys_getenvid>
  8001a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001b0:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b8:	c7 04 24 64 15 80 00 	movl   $0x801564,(%esp)
  8001bf:	e8 c2 00 00 00       	call   800286 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cb:	89 04 24             	mov    %eax,(%esp)
  8001ce:	e8 52 00 00 00       	call   800225 <vcprintf>
	cprintf("\n");
  8001d3:	c7 04 24 41 18 80 00 	movl   $0x801841,(%esp)
  8001da:	e8 a7 00 00 00       	call   800286 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001df:	cc                   	int3   
  8001e0:	eb fd                	jmp    8001df <_panic+0x53>
  8001e2:	66 90                	xchg   %ax,%ax

008001e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	53                   	push   %ebx
  8001e8:	83 ec 14             	sub    $0x14,%esp
  8001eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ee:	8b 13                	mov    (%ebx),%edx
  8001f0:	8d 42 01             	lea    0x1(%edx),%eax
  8001f3:	89 03                	mov    %eax,(%ebx)
  8001f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001fc:	3d ff 00 00 00       	cmp    $0xff,%eax
  800201:	75 19                	jne    80021c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800203:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80020a:	00 
  80020b:	8d 43 08             	lea    0x8(%ebx),%eax
  80020e:	89 04 24             	mov    %eax,(%esp)
  800211:	e8 92 09 00 00       	call   800ba8 <sys_cputs>
		b->idx = 0;
  800216:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80021c:	ff 43 04             	incl   0x4(%ebx)
}
  80021f:	83 c4 14             	add    $0x14,%esp
  800222:	5b                   	pop    %ebx
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80022e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800235:	00 00 00 
	b.cnt = 0;
  800238:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80023f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800242:	8b 45 0c             	mov    0xc(%ebp),%eax
  800245:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800249:	8b 45 08             	mov    0x8(%ebp),%eax
  80024c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800250:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800256:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025a:	c7 04 24 e4 01 80 00 	movl   $0x8001e4,(%esp)
  800261:	e8 a9 01 00 00       	call   80040f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800266:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80026c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800270:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800276:	89 04 24             	mov    %eax,(%esp)
  800279:	e8 2a 09 00 00       	call   800ba8 <sys_cputs>

	return b.cnt;
}
  80027e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800284:	c9                   	leave  
  800285:	c3                   	ret    

00800286 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800293:	8b 45 08             	mov    0x8(%ebp),%eax
  800296:	89 04 24             	mov    %eax,(%esp)
  800299:	e8 87 ff ff ff       	call   800225 <vcprintf>
	va_end(ap);

	return cnt;
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 3c             	sub    $0x3c,%esp
  8002a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ac:	89 d7                	mov    %edx,%edi
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b7:	89 c1                	mov    %eax,%ecx
  8002b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002bc:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002cd:	39 ca                	cmp    %ecx,%edx
  8002cf:	72 08                	jb     8002d9 <printnum+0x39>
  8002d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d7:	77 6a                	ja     800343 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d9:	8b 45 18             	mov    0x18(%ebp),%eax
  8002dc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002e0:	4e                   	dec    %esi
  8002e1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ec:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002f0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002f4:	89 c3                	mov    %eax,%ebx
  8002f6:	89 d6                	mov    %edx,%esi
  8002f8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002fb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800302:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800306:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800309:	89 04 24             	mov    %eax,(%esp)
  80030c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80030f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800313:	e8 38 0f 00 00       	call   801250 <__udivdi3>
  800318:	89 d9                	mov    %ebx,%ecx
  80031a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80031e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800322:	89 04 24             	mov    %eax,(%esp)
  800325:	89 54 24 04          	mov    %edx,0x4(%esp)
  800329:	89 fa                	mov    %edi,%edx
  80032b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80032e:	e8 6d ff ff ff       	call   8002a0 <printnum>
  800333:	eb 19                	jmp    80034e <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800335:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800339:	8b 45 18             	mov    0x18(%ebp),%eax
  80033c:	89 04 24             	mov    %eax,(%esp)
  80033f:	ff d3                	call   *%ebx
  800341:	eb 03                	jmp    800346 <printnum+0xa6>
  800343:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800346:	4e                   	dec    %esi
  800347:	85 f6                	test   %esi,%esi
  800349:	7f ea                	jg     800335 <printnum+0x95>
  80034b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80034e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800352:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800356:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800359:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80035c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800360:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800364:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800367:	89 04 24             	mov    %eax,(%esp)
  80036a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80036d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800371:	e8 0a 10 00 00       	call   801380 <__umoddi3>
  800376:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80037a:	0f be 80 87 15 80 00 	movsbl 0x801587(%eax),%eax
  800381:	89 04 24             	mov    %eax,(%esp)
  800384:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800387:	ff d0                	call   *%eax
}
  800389:	83 c4 3c             	add    $0x3c,%esp
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800394:	83 fa 01             	cmp    $0x1,%edx
  800397:	7e 0e                	jle    8003a7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800399:	8b 10                	mov    (%eax),%edx
  80039b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80039e:	89 08                	mov    %ecx,(%eax)
  8003a0:	8b 02                	mov    (%edx),%eax
  8003a2:	8b 52 04             	mov    0x4(%edx),%edx
  8003a5:	eb 22                	jmp    8003c9 <getuint+0x38>
	else if (lflag)
  8003a7:	85 d2                	test   %edx,%edx
  8003a9:	74 10                	je     8003bb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ab:	8b 10                	mov    (%eax),%edx
  8003ad:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b0:	89 08                	mov    %ecx,(%eax)
  8003b2:	8b 02                	mov    (%edx),%eax
  8003b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b9:	eb 0e                	jmp    8003c9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003bb:	8b 10                	mov    (%eax),%edx
  8003bd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c0:	89 08                	mov    %ecx,(%eax)
  8003c2:	8b 02                	mov    (%edx),%eax
  8003c4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c9:	5d                   	pop    %ebp
  8003ca:	c3                   	ret    

008003cb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d1:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003d4:	8b 10                	mov    (%eax),%edx
  8003d6:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d9:	73 0a                	jae    8003e5 <sprintputch+0x1a>
		*b->buf++ = ch;
  8003db:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003de:	89 08                	mov    %ecx,(%eax)
  8003e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e3:	88 02                	mov    %al,(%edx)
}
  8003e5:	5d                   	pop    %ebp
  8003e6:	c3                   	ret    

008003e7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003e7:	55                   	push   %ebp
  8003e8:	89 e5                	mov    %esp,%ebp
  8003ea:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ed:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800402:	8b 45 08             	mov    0x8(%ebp),%eax
  800405:	89 04 24             	mov    %eax,(%esp)
  800408:	e8 02 00 00 00       	call   80040f <vprintfmt>
	va_end(ap);
}
  80040d:	c9                   	leave  
  80040e:	c3                   	ret    

0080040f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80040f:	55                   	push   %ebp
  800410:	89 e5                	mov    %esp,%ebp
  800412:	57                   	push   %edi
  800413:	56                   	push   %esi
  800414:	53                   	push   %ebx
  800415:	83 ec 3c             	sub    $0x3c,%esp
  800418:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80041b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80041e:	eb 14                	jmp    800434 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800420:	85 c0                	test   %eax,%eax
  800422:	0f 84 8a 03 00 00    	je     8007b2 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  800428:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80042c:	89 04 24             	mov    %eax,(%esp)
  80042f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800432:	89 f3                	mov    %esi,%ebx
  800434:	8d 73 01             	lea    0x1(%ebx),%esi
  800437:	31 c0                	xor    %eax,%eax
  800439:	8a 03                	mov    (%ebx),%al
  80043b:	83 f8 25             	cmp    $0x25,%eax
  80043e:	75 e0                	jne    800420 <vprintfmt+0x11>
  800440:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800444:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80044b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800452:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800459:	ba 00 00 00 00       	mov    $0x0,%edx
  80045e:	eb 1d                	jmp    80047d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800462:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800466:	eb 15                	jmp    80047d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800468:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80046a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80046e:	eb 0d                	jmp    80047d <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800470:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800473:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800476:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8d 5e 01             	lea    0x1(%esi),%ebx
  800480:	31 c0                	xor    %eax,%eax
  800482:	8a 06                	mov    (%esi),%al
  800484:	8a 0e                	mov    (%esi),%cl
  800486:	83 e9 23             	sub    $0x23,%ecx
  800489:	88 4d e0             	mov    %cl,-0x20(%ebp)
  80048c:	80 f9 55             	cmp    $0x55,%cl
  80048f:	0f 87 ff 02 00 00    	ja     800794 <vprintfmt+0x385>
  800495:	31 c9                	xor    %ecx,%ecx
  800497:	8a 4d e0             	mov    -0x20(%ebp),%cl
  80049a:	ff 24 8d 40 16 80 00 	jmp    *0x801640(,%ecx,4)
  8004a1:	89 de                	mov    %ebx,%esi
  8004a3:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a8:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004ab:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8004af:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004b2:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004b5:	83 fb 09             	cmp    $0x9,%ebx
  8004b8:	77 2f                	ja     8004e9 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ba:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004bb:	eb eb                	jmp    8004a8 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c0:	8d 48 04             	lea    0x4(%eax),%ecx
  8004c3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004c6:	8b 00                	mov    (%eax),%eax
  8004c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cb:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004cd:	eb 1d                	jmp    8004ec <vprintfmt+0xdd>
  8004cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004d2:	f7 d0                	not    %eax
  8004d4:	c1 f8 1f             	sar    $0x1f,%eax
  8004d7:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	89 de                	mov    %ebx,%esi
  8004dc:	eb 9f                	jmp    80047d <vprintfmt+0x6e>
  8004de:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004e0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004e7:	eb 94                	jmp    80047d <vprintfmt+0x6e>
  8004e9:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004ec:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004f0:	79 8b                	jns    80047d <vprintfmt+0x6e>
  8004f2:	e9 79 ff ff ff       	jmp    800470 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004f7:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f8:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004fa:	eb 81                	jmp    80047d <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ff:	8d 50 04             	lea    0x4(%eax),%edx
  800502:	89 55 14             	mov    %edx,0x14(%ebp)
  800505:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800509:	8b 00                	mov    (%eax),%eax
  80050b:	89 04 24             	mov    %eax,(%esp)
  80050e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800511:	e9 1e ff ff ff       	jmp    800434 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 50 04             	lea    0x4(%eax),%edx
  80051c:	89 55 14             	mov    %edx,0x14(%ebp)
  80051f:	8b 00                	mov    (%eax),%eax
  800521:	89 c2                	mov    %eax,%edx
  800523:	c1 fa 1f             	sar    $0x1f,%edx
  800526:	31 d0                	xor    %edx,%eax
  800528:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80052a:	83 f8 09             	cmp    $0x9,%eax
  80052d:	7f 0b                	jg     80053a <vprintfmt+0x12b>
  80052f:	8b 14 85 a0 17 80 00 	mov    0x8017a0(,%eax,4),%edx
  800536:	85 d2                	test   %edx,%edx
  800538:	75 20                	jne    80055a <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  80053a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80053e:	c7 44 24 08 9f 15 80 	movl   $0x80159f,0x8(%esp)
  800545:	00 
  800546:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80054a:	8b 45 08             	mov    0x8(%ebp),%eax
  80054d:	89 04 24             	mov    %eax,(%esp)
  800550:	e8 92 fe ff ff       	call   8003e7 <printfmt>
  800555:	e9 da fe ff ff       	jmp    800434 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80055a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80055e:	c7 44 24 08 a8 15 80 	movl   $0x8015a8,0x8(%esp)
  800565:	00 
  800566:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80056a:	8b 45 08             	mov    0x8(%ebp),%eax
  80056d:	89 04 24             	mov    %eax,(%esp)
  800570:	e8 72 fe ff ff       	call   8003e7 <printfmt>
  800575:	e9 ba fe ff ff       	jmp    800434 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80057d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800580:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 50 04             	lea    0x4(%eax),%edx
  800589:	89 55 14             	mov    %edx,0x14(%ebp)
  80058c:	8b 30                	mov    (%eax),%esi
  80058e:	85 f6                	test   %esi,%esi
  800590:	75 05                	jne    800597 <vprintfmt+0x188>
				p = "(null)";
  800592:	be 98 15 80 00       	mov    $0x801598,%esi
			if (width > 0 && padc != '-')
  800597:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80059b:	0f 84 8c 00 00 00    	je     80062d <vprintfmt+0x21e>
  8005a1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a5:	0f 8e 8a 00 00 00    	jle    800635 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005af:	89 34 24             	mov    %esi,(%esp)
  8005b2:	e8 9b 02 00 00       	call   800852 <strnlen>
  8005b7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005ba:	29 c1                	sub    %eax,%ecx
  8005bc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  8005bf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005c6:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8005c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8005cc:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005cf:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d1:	eb 0d                	jmp    8005e0 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8005d3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005da:	89 04 24             	mov    %eax,(%esp)
  8005dd:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005df:	4b                   	dec    %ebx
  8005e0:	85 db                	test   %ebx,%ebx
  8005e2:	7f ef                	jg     8005d3 <vprintfmt+0x1c4>
  8005e4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ea:	89 c8                	mov    %ecx,%eax
  8005ec:	f7 d0                	not    %eax
  8005ee:	c1 f8 1f             	sar    $0x1f,%eax
  8005f1:	21 c8                	and    %ecx,%eax
  8005f3:	29 c1                	sub    %eax,%ecx
  8005f5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005fb:	eb 3e                	jmp    80063b <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005fd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800601:	74 1b                	je     80061e <vprintfmt+0x20f>
  800603:	0f be d2             	movsbl %dl,%edx
  800606:	83 ea 20             	sub    $0x20,%edx
  800609:	83 fa 5e             	cmp    $0x5e,%edx
  80060c:	76 10                	jbe    80061e <vprintfmt+0x20f>
					putch('?', putdat);
  80060e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800612:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800619:	ff 55 08             	call   *0x8(%ebp)
  80061c:	eb 0a                	jmp    800628 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  80061e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800622:	89 04 24             	mov    %eax,(%esp)
  800625:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800628:	ff 4d dc             	decl   -0x24(%ebp)
  80062b:	eb 0e                	jmp    80063b <vprintfmt+0x22c>
  80062d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800630:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800633:	eb 06                	jmp    80063b <vprintfmt+0x22c>
  800635:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800638:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80063b:	46                   	inc    %esi
  80063c:	8a 56 ff             	mov    -0x1(%esi),%dl
  80063f:	0f be c2             	movsbl %dl,%eax
  800642:	85 c0                	test   %eax,%eax
  800644:	74 1f                	je     800665 <vprintfmt+0x256>
  800646:	85 db                	test   %ebx,%ebx
  800648:	78 b3                	js     8005fd <vprintfmt+0x1ee>
  80064a:	4b                   	dec    %ebx
  80064b:	79 b0                	jns    8005fd <vprintfmt+0x1ee>
  80064d:	8b 75 08             	mov    0x8(%ebp),%esi
  800650:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800653:	eb 16                	jmp    80066b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800655:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800659:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800660:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800662:	4b                   	dec    %ebx
  800663:	eb 06                	jmp    80066b <vprintfmt+0x25c>
  800665:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800668:	8b 75 08             	mov    0x8(%ebp),%esi
  80066b:	85 db                	test   %ebx,%ebx
  80066d:	7f e6                	jg     800655 <vprintfmt+0x246>
  80066f:	89 75 08             	mov    %esi,0x8(%ebp)
  800672:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800675:	e9 ba fd ff ff       	jmp    800434 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80067a:	83 fa 01             	cmp    $0x1,%edx
  80067d:	7e 16                	jle    800695 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8d 50 08             	lea    0x8(%eax),%edx
  800685:	89 55 14             	mov    %edx,0x14(%ebp)
  800688:	8b 50 04             	mov    0x4(%eax),%edx
  80068b:	8b 00                	mov    (%eax),%eax
  80068d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800690:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800693:	eb 32                	jmp    8006c7 <vprintfmt+0x2b8>
	else if (lflag)
  800695:	85 d2                	test   %edx,%edx
  800697:	74 18                	je     8006b1 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8d 50 04             	lea    0x4(%eax),%edx
  80069f:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a2:	8b 30                	mov    (%eax),%esi
  8006a4:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006a7:	89 f0                	mov    %esi,%eax
  8006a9:	c1 f8 1f             	sar    $0x1f,%eax
  8006ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006af:	eb 16                	jmp    8006c7 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8d 50 04             	lea    0x4(%eax),%edx
  8006b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ba:	8b 30                	mov    (%eax),%esi
  8006bc:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006bf:	89 f0                	mov    %esi,%eax
  8006c1:	c1 f8 1f             	sar    $0x1f,%eax
  8006c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006cd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006d6:	0f 89 80 00 00 00    	jns    80075c <vprintfmt+0x34d>
				putch('-', putdat);
  8006dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006e0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006e7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006f0:	f7 d8                	neg    %eax
  8006f2:	83 d2 00             	adc    $0x0,%edx
  8006f5:	f7 da                	neg    %edx
			}
			base = 10;
  8006f7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006fc:	eb 5e                	jmp    80075c <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800701:	e8 8b fc ff ff       	call   800391 <getuint>
			base = 10;
  800706:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80070b:	eb 4f                	jmp    80075c <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  80070d:	8d 45 14             	lea    0x14(%ebp),%eax
  800710:	e8 7c fc ff ff       	call   800391 <getuint>
			base = 8;
  800715:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80071a:	eb 40                	jmp    80075c <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  80071c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800720:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800727:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80072a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80072e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800735:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800738:	8b 45 14             	mov    0x14(%ebp),%eax
  80073b:	8d 50 04             	lea    0x4(%eax),%edx
  80073e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800741:	8b 00                	mov    (%eax),%eax
  800743:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800748:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80074d:	eb 0d                	jmp    80075c <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80074f:	8d 45 14             	lea    0x14(%ebp),%eax
  800752:	e8 3a fc ff ff       	call   800391 <getuint>
			base = 16;
  800757:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80075c:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800760:	89 74 24 10          	mov    %esi,0x10(%esp)
  800764:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800767:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80076b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80076f:	89 04 24             	mov    %eax,(%esp)
  800772:	89 54 24 04          	mov    %edx,0x4(%esp)
  800776:	89 fa                	mov    %edi,%edx
  800778:	8b 45 08             	mov    0x8(%ebp),%eax
  80077b:	e8 20 fb ff ff       	call   8002a0 <printnum>
			break;
  800780:	e9 af fc ff ff       	jmp    800434 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800785:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800789:	89 04 24             	mov    %eax,(%esp)
  80078c:	ff 55 08             	call   *0x8(%ebp)
			break;
  80078f:	e9 a0 fc ff ff       	jmp    800434 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800794:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800798:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80079f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a2:	89 f3                	mov    %esi,%ebx
  8007a4:	eb 01                	jmp    8007a7 <vprintfmt+0x398>
  8007a6:	4b                   	dec    %ebx
  8007a7:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007ab:	75 f9                	jne    8007a6 <vprintfmt+0x397>
  8007ad:	e9 82 fc ff ff       	jmp    800434 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007b2:	83 c4 3c             	add    $0x3c,%esp
  8007b5:	5b                   	pop    %ebx
  8007b6:	5e                   	pop    %esi
  8007b7:	5f                   	pop    %edi
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	83 ec 28             	sub    $0x28,%esp
  8007c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007cd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d7:	85 c0                	test   %eax,%eax
  8007d9:	74 30                	je     80080b <vsnprintf+0x51>
  8007db:	85 d2                	test   %edx,%edx
  8007dd:	7e 2c                	jle    80080b <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ed:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f4:	c7 04 24 cb 03 80 00 	movl   $0x8003cb,(%esp)
  8007fb:	e8 0f fc ff ff       	call   80040f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800800:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800803:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800806:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800809:	eb 05                	jmp    800810 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80080b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800818:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80081b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081f:	8b 45 10             	mov    0x10(%ebp),%eax
  800822:	89 44 24 08          	mov    %eax,0x8(%esp)
  800826:	8b 45 0c             	mov    0xc(%ebp),%eax
  800829:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082d:	8b 45 08             	mov    0x8(%ebp),%eax
  800830:	89 04 24             	mov    %eax,(%esp)
  800833:	e8 82 ff ff ff       	call   8007ba <vsnprintf>
	va_end(ap);

	return rc;
}
  800838:	c9                   	leave  
  800839:	c3                   	ret    
  80083a:	66 90                	xchg   %ax,%ax

0080083c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800842:	b8 00 00 00 00       	mov    $0x0,%eax
  800847:	eb 01                	jmp    80084a <strlen+0xe>
		n++;
  800849:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80084a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80084e:	75 f9                	jne    800849 <strlen+0xd>
		n++;
	return n;
}
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800858:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085b:	b8 00 00 00 00       	mov    $0x0,%eax
  800860:	eb 01                	jmp    800863 <strnlen+0x11>
		n++;
  800862:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800863:	39 d0                	cmp    %edx,%eax
  800865:	74 06                	je     80086d <strnlen+0x1b>
  800867:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80086b:	75 f5                	jne    800862 <strnlen+0x10>
		n++;
	return n;
}
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	53                   	push   %ebx
  800873:	8b 45 08             	mov    0x8(%ebp),%eax
  800876:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800879:	89 c2                	mov    %eax,%edx
  80087b:	42                   	inc    %edx
  80087c:	41                   	inc    %ecx
  80087d:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800880:	88 5a ff             	mov    %bl,-0x1(%edx)
  800883:	84 db                	test   %bl,%bl
  800885:	75 f4                	jne    80087b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800887:	5b                   	pop    %ebx
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	53                   	push   %ebx
  80088e:	83 ec 08             	sub    $0x8,%esp
  800891:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800894:	89 1c 24             	mov    %ebx,(%esp)
  800897:	e8 a0 ff ff ff       	call   80083c <strlen>
	strcpy(dst + len, src);
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089f:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a3:	01 d8                	add    %ebx,%eax
  8008a5:	89 04 24             	mov    %eax,(%esp)
  8008a8:	e8 c2 ff ff ff       	call   80086f <strcpy>
	return dst;
}
  8008ad:	89 d8                	mov    %ebx,%eax
  8008af:	83 c4 08             	add    $0x8,%esp
  8008b2:	5b                   	pop    %ebx
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	56                   	push   %esi
  8008b9:	53                   	push   %ebx
  8008ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8008bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c0:	89 f3                	mov    %esi,%ebx
  8008c2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c5:	89 f2                	mov    %esi,%edx
  8008c7:	eb 0c                	jmp    8008d5 <strncpy+0x20>
		*dst++ = *src;
  8008c9:	42                   	inc    %edx
  8008ca:	8a 01                	mov    (%ecx),%al
  8008cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8008d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d5:	39 da                	cmp    %ebx,%edx
  8008d7:	75 f0                	jne    8008c9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008d9:	89 f0                	mov    %esi,%eax
  8008db:	5b                   	pop    %ebx
  8008dc:	5e                   	pop    %esi
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	56                   	push   %esi
  8008e3:	53                   	push   %ebx
  8008e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008ed:	89 f0                	mov    %esi,%eax
  8008ef:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f3:	85 c9                	test   %ecx,%ecx
  8008f5:	75 07                	jne    8008fe <strlcpy+0x1f>
  8008f7:	eb 18                	jmp    800911 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008f9:	40                   	inc    %eax
  8008fa:	42                   	inc    %edx
  8008fb:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008fe:	39 d8                	cmp    %ebx,%eax
  800900:	74 0a                	je     80090c <strlcpy+0x2d>
  800902:	8a 0a                	mov    (%edx),%cl
  800904:	84 c9                	test   %cl,%cl
  800906:	75 f1                	jne    8008f9 <strlcpy+0x1a>
  800908:	89 c2                	mov    %eax,%edx
  80090a:	eb 02                	jmp    80090e <strlcpy+0x2f>
  80090c:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80090e:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800911:	29 f0                	sub    %esi,%eax
}
  800913:	5b                   	pop    %ebx
  800914:	5e                   	pop    %esi
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800920:	eb 02                	jmp    800924 <strcmp+0xd>
		p++, q++;
  800922:	41                   	inc    %ecx
  800923:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800924:	8a 01                	mov    (%ecx),%al
  800926:	84 c0                	test   %al,%al
  800928:	74 04                	je     80092e <strcmp+0x17>
  80092a:	3a 02                	cmp    (%edx),%al
  80092c:	74 f4                	je     800922 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80092e:	25 ff 00 00 00       	and    $0xff,%eax
  800933:	8a 0a                	mov    (%edx),%cl
  800935:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  80093b:	29 c8                	sub    %ecx,%eax
}
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	53                   	push   %ebx
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	8b 55 0c             	mov    0xc(%ebp),%edx
  800949:	89 c3                	mov    %eax,%ebx
  80094b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80094e:	eb 02                	jmp    800952 <strncmp+0x13>
		n--, p++, q++;
  800950:	40                   	inc    %eax
  800951:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800952:	39 d8                	cmp    %ebx,%eax
  800954:	74 20                	je     800976 <strncmp+0x37>
  800956:	8a 08                	mov    (%eax),%cl
  800958:	84 c9                	test   %cl,%cl
  80095a:	74 04                	je     800960 <strncmp+0x21>
  80095c:	3a 0a                	cmp    (%edx),%cl
  80095e:	74 f0                	je     800950 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800960:	8a 18                	mov    (%eax),%bl
  800962:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800968:	89 d8                	mov    %ebx,%eax
  80096a:	8a 1a                	mov    (%edx),%bl
  80096c:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800972:	29 d8                	sub    %ebx,%eax
  800974:	eb 05                	jmp    80097b <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80097b:	5b                   	pop    %ebx
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800987:	eb 05                	jmp    80098e <strchr+0x10>
		if (*s == c)
  800989:	38 ca                	cmp    %cl,%dl
  80098b:	74 0c                	je     800999 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80098d:	40                   	inc    %eax
  80098e:	8a 10                	mov    (%eax),%dl
  800990:	84 d2                	test   %dl,%dl
  800992:	75 f5                	jne    800989 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009a4:	eb 05                	jmp    8009ab <strfind+0x10>
		if (*s == c)
  8009a6:	38 ca                	cmp    %cl,%dl
  8009a8:	74 07                	je     8009b1 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009aa:	40                   	inc    %eax
  8009ab:	8a 10                	mov    (%eax),%dl
  8009ad:	84 d2                	test   %dl,%dl
  8009af:	75 f5                	jne    8009a6 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	57                   	push   %edi
  8009b7:	56                   	push   %esi
  8009b8:	53                   	push   %ebx
  8009b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009bf:	85 c9                	test   %ecx,%ecx
  8009c1:	74 37                	je     8009fa <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009c9:	75 29                	jne    8009f4 <memset+0x41>
  8009cb:	f6 c1 03             	test   $0x3,%cl
  8009ce:	75 24                	jne    8009f4 <memset+0x41>
		c &= 0xFF;
  8009d0:	31 d2                	xor    %edx,%edx
  8009d2:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d5:	89 d3                	mov    %edx,%ebx
  8009d7:	c1 e3 08             	shl    $0x8,%ebx
  8009da:	89 d6                	mov    %edx,%esi
  8009dc:	c1 e6 18             	shl    $0x18,%esi
  8009df:	89 d0                	mov    %edx,%eax
  8009e1:	c1 e0 10             	shl    $0x10,%eax
  8009e4:	09 f0                	or     %esi,%eax
  8009e6:	09 c2                	or     %eax,%edx
  8009e8:	89 d0                	mov    %edx,%eax
  8009ea:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ec:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009ef:	fc                   	cld    
  8009f0:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f2:	eb 06                	jmp    8009fa <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f7:	fc                   	cld    
  8009f8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009fa:	89 f8                	mov    %edi,%eax
  8009fc:	5b                   	pop    %ebx
  8009fd:	5e                   	pop    %esi
  8009fe:	5f                   	pop    %edi
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	57                   	push   %edi
  800a05:	56                   	push   %esi
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a0f:	39 c6                	cmp    %eax,%esi
  800a11:	73 33                	jae    800a46 <memmove+0x45>
  800a13:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a16:	39 d0                	cmp    %edx,%eax
  800a18:	73 2c                	jae    800a46 <memmove+0x45>
		s += n;
		d += n;
  800a1a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a1d:	89 d6                	mov    %edx,%esi
  800a1f:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a21:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a27:	75 13                	jne    800a3c <memmove+0x3b>
  800a29:	f6 c1 03             	test   $0x3,%cl
  800a2c:	75 0e                	jne    800a3c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a2e:	83 ef 04             	sub    $0x4,%edi
  800a31:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a34:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a37:	fd                   	std    
  800a38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3a:	eb 07                	jmp    800a43 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a3c:	4f                   	dec    %edi
  800a3d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a40:	fd                   	std    
  800a41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a43:	fc                   	cld    
  800a44:	eb 1d                	jmp    800a63 <memmove+0x62>
  800a46:	89 f2                	mov    %esi,%edx
  800a48:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4a:	f6 c2 03             	test   $0x3,%dl
  800a4d:	75 0f                	jne    800a5e <memmove+0x5d>
  800a4f:	f6 c1 03             	test   $0x3,%cl
  800a52:	75 0a                	jne    800a5e <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a54:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a57:	89 c7                	mov    %eax,%edi
  800a59:	fc                   	cld    
  800a5a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5c:	eb 05                	jmp    800a63 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a5e:	89 c7                	mov    %eax,%edi
  800a60:	fc                   	cld    
  800a61:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a63:	5e                   	pop    %esi
  800a64:	5f                   	pop    %edi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a6d:	8b 45 10             	mov    0x10(%ebp),%eax
  800a70:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a77:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	89 04 24             	mov    %eax,(%esp)
  800a81:	e8 7b ff ff ff       	call   800a01 <memmove>
}
  800a86:	c9                   	leave  
  800a87:	c3                   	ret    

00800a88 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
  800a8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a93:	89 d6                	mov    %edx,%esi
  800a95:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a98:	eb 19                	jmp    800ab3 <memcmp+0x2b>
		if (*s1 != *s2)
  800a9a:	8a 02                	mov    (%edx),%al
  800a9c:	8a 19                	mov    (%ecx),%bl
  800a9e:	38 d8                	cmp    %bl,%al
  800aa0:	74 0f                	je     800ab1 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800aa2:	25 ff 00 00 00       	and    $0xff,%eax
  800aa7:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800aad:	29 d8                	sub    %ebx,%eax
  800aaf:	eb 0b                	jmp    800abc <memcmp+0x34>
		s1++, s2++;
  800ab1:	42                   	inc    %edx
  800ab2:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab3:	39 f2                	cmp    %esi,%edx
  800ab5:	75 e3                	jne    800a9a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ab7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800abc:	5b                   	pop    %ebx
  800abd:	5e                   	pop    %esi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ac9:	89 c2                	mov    %eax,%edx
  800acb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ace:	eb 05                	jmp    800ad5 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad0:	38 08                	cmp    %cl,(%eax)
  800ad2:	74 05                	je     800ad9 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad4:	40                   	inc    %eax
  800ad5:	39 d0                	cmp    %edx,%eax
  800ad7:	72 f7                	jb     800ad0 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
  800ae1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae7:	eb 01                	jmp    800aea <strtol+0xf>
		s++;
  800ae9:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aea:	8a 02                	mov    (%edx),%al
  800aec:	3c 09                	cmp    $0x9,%al
  800aee:	74 f9                	je     800ae9 <strtol+0xe>
  800af0:	3c 20                	cmp    $0x20,%al
  800af2:	74 f5                	je     800ae9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800af4:	3c 2b                	cmp    $0x2b,%al
  800af6:	75 08                	jne    800b00 <strtol+0x25>
		s++;
  800af8:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800af9:	bf 00 00 00 00       	mov    $0x0,%edi
  800afe:	eb 10                	jmp    800b10 <strtol+0x35>
  800b00:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b05:	3c 2d                	cmp    $0x2d,%al
  800b07:	75 07                	jne    800b10 <strtol+0x35>
		s++, neg = 1;
  800b09:	8d 52 01             	lea    0x1(%edx),%edx
  800b0c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b10:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b16:	75 15                	jne    800b2d <strtol+0x52>
  800b18:	80 3a 30             	cmpb   $0x30,(%edx)
  800b1b:	75 10                	jne    800b2d <strtol+0x52>
  800b1d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b21:	75 0a                	jne    800b2d <strtol+0x52>
		s += 2, base = 16;
  800b23:	83 c2 02             	add    $0x2,%edx
  800b26:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b2b:	eb 0e                	jmp    800b3b <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800b2d:	85 db                	test   %ebx,%ebx
  800b2f:	75 0a                	jne    800b3b <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b31:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b33:	80 3a 30             	cmpb   $0x30,(%edx)
  800b36:	75 03                	jne    800b3b <strtol+0x60>
		s++, base = 8;
  800b38:	42                   	inc    %edx
  800b39:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b40:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b43:	8a 0a                	mov    (%edx),%cl
  800b45:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b48:	89 f3                	mov    %esi,%ebx
  800b4a:	80 fb 09             	cmp    $0x9,%bl
  800b4d:	77 08                	ja     800b57 <strtol+0x7c>
			dig = *s - '0';
  800b4f:	0f be c9             	movsbl %cl,%ecx
  800b52:	83 e9 30             	sub    $0x30,%ecx
  800b55:	eb 22                	jmp    800b79 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800b57:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b5a:	89 f3                	mov    %esi,%ebx
  800b5c:	80 fb 19             	cmp    $0x19,%bl
  800b5f:	77 08                	ja     800b69 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800b61:	0f be c9             	movsbl %cl,%ecx
  800b64:	83 e9 57             	sub    $0x57,%ecx
  800b67:	eb 10                	jmp    800b79 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800b69:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b6c:	89 f3                	mov    %esi,%ebx
  800b6e:	80 fb 19             	cmp    $0x19,%bl
  800b71:	77 14                	ja     800b87 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b73:	0f be c9             	movsbl %cl,%ecx
  800b76:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b79:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b7c:	7d 0d                	jge    800b8b <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b7e:	42                   	inc    %edx
  800b7f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b83:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b85:	eb bc                	jmp    800b43 <strtol+0x68>
  800b87:	89 c1                	mov    %eax,%ecx
  800b89:	eb 02                	jmp    800b8d <strtol+0xb2>
  800b8b:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b8d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b91:	74 05                	je     800b98 <strtol+0xbd>
		*endptr = (char *) s;
  800b93:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b96:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b98:	85 ff                	test   %edi,%edi
  800b9a:	74 04                	je     800ba0 <strtol+0xc5>
  800b9c:	89 c8                	mov    %ecx,%eax
  800b9e:	f7 d8                	neg    %eax
}
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    
  800ba5:	66 90                	xchg   %ax,%ax
  800ba7:	90                   	nop

00800ba8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bae:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	89 c3                	mov    %eax,%ebx
  800bbb:	89 c7                	mov    %eax,%edi
  800bbd:	89 c6                	mov    %eax,%esi
  800bbf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcc:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd1:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd6:	89 d1                	mov    %edx,%ecx
  800bd8:	89 d3                	mov    %edx,%ebx
  800bda:	89 d7                	mov    %edx,%edi
  800bdc:	89 d6                	mov    %edx,%esi
  800bde:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	57                   	push   %edi
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
  800beb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf3:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	89 cb                	mov    %ecx,%ebx
  800bfd:	89 cf                	mov    %ecx,%edi
  800bff:	89 ce                	mov    %ecx,%esi
  800c01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c03:	85 c0                	test   %eax,%eax
  800c05:	7e 28                	jle    800c2f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c0b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c12:	00 
  800c13:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800c1a:	00 
  800c1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c22:	00 
  800c23:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800c2a:	e8 5d f5 ff ff       	call   80018c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c2f:	83 c4 2c             	add    $0x2c,%esp
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c42:	b8 02 00 00 00       	mov    $0x2,%eax
  800c47:	89 d1                	mov    %edx,%ecx
  800c49:	89 d3                	mov    %edx,%ebx
  800c4b:	89 d7                	mov    %edx,%edi
  800c4d:	89 d6                	mov    %edx,%esi
  800c4f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <sys_yield>:

void
sys_yield(void)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c61:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c66:	89 d1                	mov    %edx,%ecx
  800c68:	89 d3                	mov    %edx,%ebx
  800c6a:	89 d7                	mov    %edx,%edi
  800c6c:	89 d6                	mov    %edx,%esi
  800c6e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	be 00 00 00 00       	mov    $0x0,%esi
  800c83:	b8 04 00 00 00       	mov    $0x4,%eax
  800c88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c91:	89 f7                	mov    %esi,%edi
  800c93:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c95:	85 c0                	test   %eax,%eax
  800c97:	7e 28                	jle    800cc1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c99:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c9d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ca4:	00 
  800ca5:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800cac:	00 
  800cad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb4:	00 
  800cb5:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800cbc:	e8 cb f4 ff ff       	call   80018c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cc1:	83 c4 2c             	add    $0x2c,%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd2:	b8 05 00 00 00       	mov    $0x5,%eax
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce3:	8b 75 18             	mov    0x18(%ebp),%esi
  800ce6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce8:	85 c0                	test   %eax,%eax
  800cea:	7e 28                	jle    800d14 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cec:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cf7:	00 
  800cf8:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800cff:	00 
  800d00:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d07:	00 
  800d08:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800d0f:	e8 78 f4 ff ff       	call   80018c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d14:	83 c4 2c             	add    $0x2c,%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	89 df                	mov    %ebx,%edi
  800d37:	89 de                	mov    %ebx,%esi
  800d39:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	7e 28                	jle    800d67 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d43:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d4a:	00 
  800d4b:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800d52:	00 
  800d53:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d5a:	00 
  800d5b:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800d62:	e8 25 f4 ff ff       	call   80018c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d67:	83 c4 2c             	add    $0x2c,%esp
  800d6a:	5b                   	pop    %ebx
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	57                   	push   %edi
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
  800d75:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d85:	8b 55 08             	mov    0x8(%ebp),%edx
  800d88:	89 df                	mov    %ebx,%edi
  800d8a:	89 de                	mov    %ebx,%esi
  800d8c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	7e 28                	jle    800dba <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d92:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d96:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d9d:	00 
  800d9e:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800da5:	00 
  800da6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dad:	00 
  800dae:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800db5:	e8 d2 f3 ff ff       	call   80018c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dba:	83 c4 2c             	add    $0x2c,%esp
  800dbd:	5b                   	pop    %ebx
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	57                   	push   %edi
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
  800dc8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd0:	b8 09 00 00 00       	mov    $0x9,%eax
  800dd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddb:	89 df                	mov    %ebx,%edi
  800ddd:	89 de                	mov    %ebx,%esi
  800ddf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de1:	85 c0                	test   %eax,%eax
  800de3:	7e 28                	jle    800e0d <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800df0:	00 
  800df1:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800df8:	00 
  800df9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e00:	00 
  800e01:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800e08:	e8 7f f3 ff ff       	call   80018c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e0d:	83 c4 2c             	add    $0x2c,%esp
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    

00800e15 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	57                   	push   %edi
  800e19:	56                   	push   %esi
  800e1a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1b:	be 00 00 00 00       	mov    $0x0,%esi
  800e20:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e28:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e2e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e31:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e33:	5b                   	pop    %ebx
  800e34:	5e                   	pop    %esi
  800e35:	5f                   	pop    %edi
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    

00800e38 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	57                   	push   %edi
  800e3c:	56                   	push   %esi
  800e3d:	53                   	push   %ebx
  800e3e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e41:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e46:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4e:	89 cb                	mov    %ecx,%ebx
  800e50:	89 cf                	mov    %ecx,%edi
  800e52:	89 ce                	mov    %ecx,%esi
  800e54:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e56:	85 c0                	test   %eax,%eax
  800e58:	7e 28                	jle    800e82 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e5e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e65:	00 
  800e66:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800e6d:	00 
  800e6e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e75:	00 
  800e76:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800e7d:	e8 0a f3 ff ff       	call   80018c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e82:	83 c4 2c             	add    $0x2c,%esp
  800e85:	5b                   	pop    %ebx
  800e86:	5e                   	pop    %esi
  800e87:	5f                   	pop    %edi
  800e88:	5d                   	pop    %ebp
  800e89:	c3                   	ret    
  800e8a:	66 90                	xchg   %ax,%ax

00800e8c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	56                   	push   %esi
  800e90:	53                   	push   %ebx
  800e91:	83 ec 20             	sub    $0x20,%esp
  800e94:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e97:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	pte_t * vpte = 
		(pte_t *)(PDX(UVPT) << 22 | PDX(addr) << 12 | PTX(addr) << 2);
  800e99:	89 d9                	mov    %ebx,%ecx
  800e9b:	c1 e9 16             	shr    $0x16,%ecx
  800e9e:	c1 e1 0c             	shl    $0xc,%ecx
  800ea1:	81 c9 00 00 40 ef    	or     $0xef400000,%ecx
  800ea7:	89 da                	mov    %ebx,%edx
  800ea9:	c1 ea 0a             	shr    $0xa,%edx
  800eac:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  800eb2:	09 ca                	or     %ecx,%edx
	if ((err & FEC_WR) == 0 || (*vpte & PTE_COW) == 0)
  800eb4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eb8:	74 07                	je     800ec1 <pgfault+0x35>
  800eba:	8b 02                	mov    (%edx),%eax
  800ebc:	f6 c4 08             	test   $0x8,%ah
  800ebf:	75 1c                	jne    800edd <pgfault+0x51>
		panic("pgfault: not cow!\n");
  800ec1:	c7 44 24 08 f3 17 80 	movl   $0x8017f3,0x8(%esp)
  800ec8:	00 
  800ec9:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800ed0:	00 
  800ed1:	c7 04 24 06 18 80 00 	movl   $0x801806,(%esp)
  800ed8:	e8 af f2 ff ff       	call   80018c <_panic>
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  800edd:	e8 55 fd ff ff       	call   800c37 <sys_getenvid>
  800ee2:	89 c6                	mov    %eax,%esi
	if (sys_page_alloc(envid, (void *) PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  800ee4:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800eeb:	00 
  800eec:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ef3:	00 
  800ef4:	89 04 24             	mov    %eax,(%esp)
  800ef7:	e8 79 fd ff ff       	call   800c75 <sys_page_alloc>
  800efc:	85 c0                	test   %eax,%eax
  800efe:	79 1c                	jns    800f1c <pgfault+0x90>
		panic("pgfault: page allocate error!\n");
  800f00:	c7 44 24 08 70 18 80 	movl   $0x801870,0x8(%esp)
  800f07:	00 
  800f08:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800f0f:	00 
  800f10:	c7 04 24 06 18 80 00 	movl   $0x801806,(%esp)
  800f17:	e8 70 f2 ff ff       	call   80018c <_panic>

	memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800f1c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800f22:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f29:	00 
  800f2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f2e:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f35:	e8 2d fb ff ff       	call   800a67 <memcpy>
	sys_page_map(envid, (void *)PFTEMP, envid, ROUNDDOWN(addr, PGSIZE), PTE_U | PTE_P | PTE_W);
  800f3a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f41:	00 
  800f42:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f46:	89 74 24 08          	mov    %esi,0x8(%esp)
  800f4a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f51:	00 
  800f52:	89 34 24             	mov    %esi,(%esp)
  800f55:	e8 6f fd ff ff       	call   800cc9 <sys_page_map>
	// panic("pgfault not implemented");
}
  800f5a:	83 c4 20             	add    $0x20,%esp
  800f5d:	5b                   	pop    %ebx
  800f5e:	5e                   	pop    %esi
  800f5f:	5d                   	pop    %ebp
  800f60:	c3                   	ret    

00800f61 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
  800f64:	57                   	push   %edi
  800f65:	56                   	push   %esi
  800f66:	53                   	push   %ebx
  800f67:	83 ec 2c             	sub    $0x2c,%esp
	set_pgfault_handler(pgfault);
  800f6a:	c7 04 24 8c 0e 80 00 	movl   $0x800e8c,(%esp)
  800f71:	e8 3e 02 00 00       	call   8011b4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f76:	b8 07 00 00 00       	mov    $0x7,%eax
  800f7b:	cd 30                	int    $0x30
  800f7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0)
  800f80:	85 c0                	test   %eax,%eax
  800f82:	79 1c                	jns    800fa0 <fork+0x3f>
		panic("something wrong when fork()\n");
  800f84:	c7 44 24 08 11 18 80 	movl   $0x801811,0x8(%esp)
  800f8b:	00 
  800f8c:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  800f93:	00 
  800f94:	c7 04 24 06 18 80 00 	movl   $0x801806,(%esp)
  800f9b:	e8 ec f1 ff ff       	call   80018c <_panic>

	if (envid == 0) {
  800fa0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fa4:	75 2a                	jne    800fd0 <fork+0x6f>
		//child
		thisenv = &envs[ENVX(sys_getenvid())];
  800fa6:	e8 8c fc ff ff       	call   800c37 <sys_getenvid>
  800fab:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fb0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fb7:	c1 e0 07             	shl    $0x7,%eax
  800fba:	29 d0                	sub    %edx,%eax
  800fbc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fc1:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0; 
  800fc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcb:	e9 b9 01 00 00       	jmp    801189 <fork+0x228>
  800fd0:	89 c6                	mov    %eax,%esi
	}

	sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_U | PTE_P | PTE_W);
  800fd2:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fd9:	00 
  800fda:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800fe1:	ee 
  800fe2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fe5:	89 04 24             	mov    %eax,(%esp)
  800fe8:	e8 88 fc ff ff       	call   800c75 <sys_page_alloc>

	int pn = 0;
	for (; pn < UTOP / PGSIZE - 1; pn++) {
  800fed:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0; 
	}

	sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_U | PTE_P | PTE_W);

	int pn = 0;
  800ff2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff7:	89 d8                	mov    %ebx,%eax
  800ff9:	c1 e0 0c             	shl    $0xc,%eax
	for (; pn < UTOP / PGSIZE - 1; pn++) {

		pde_t * vpde = 
			(pde_t *)(PDX(UVPT) << 22 | PDX(UVPT) << 12 | PDX(pn * PGSIZE) << 2);
  800ffc:	89 c2                	mov    %eax,%edx
  800ffe:	c1 ea 16             	shr    $0x16,%edx
  801001:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
  801008:	81 c9 00 d0 7b ef    	or     $0xef7bd000,%ecx
		pte_t * vpte = 
			(pte_t *)(PDX(UVPT) << 22 | PDX(pn * PGSIZE) << 12 | PTX(pn * PGSIZE) << 2);
		if ((*vpde & PTE_P) && (*vpte & PTE_P) && (*vpte & PTE_U)) 
  80100e:	f6 01 01             	testb  $0x1,(%ecx)
  801011:	0f 84 19 01 00 00    	je     801130 <fork+0x1cf>
	for (; pn < UTOP / PGSIZE - 1; pn++) {

		pde_t * vpde = 
			(pde_t *)(PDX(UVPT) << 22 | PDX(UVPT) << 12 | PDX(pn * PGSIZE) << 2);
		pte_t * vpte = 
			(pte_t *)(PDX(UVPT) << 22 | PDX(pn * PGSIZE) << 12 | PTX(pn * PGSIZE) << 2);
  801017:	c1 e2 0c             	shl    $0xc,%edx
  80101a:	81 ca 00 00 40 ef    	or     $0xef400000,%edx
  801020:	c1 e8 0a             	shr    $0xa,%eax
  801023:	25 fc 0f 00 00       	and    $0xffc,%eax
  801028:	09 c2                	or     %eax,%edx
		if ((*vpde & PTE_P) && (*vpte & PTE_P) && (*vpte & PTE_U)) 
  80102a:	8b 02                	mov    (%edx),%eax
  80102c:	83 e0 05             	and    $0x5,%eax
  80102f:	83 f8 05             	cmp    $0x5,%eax
  801032:	0f 85 f8 00 00 00    	jne    801130 <fork+0x1cf>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	if (pn * PGSIZE == UXSTACKTOP - PGSIZE)
  801038:	c1 e7 0c             	shl    $0xc,%edi
  80103b:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  801041:	0f 84 e9 00 00 00    	je     801130 <fork+0x1cf>
	int perm_w = PTE_P | PTE_U | PTE_COW;
	int perm_r = PTE_P | PTE_U;

	void * addr = (void *) (pn * PGSIZE);
	pte_t * vpte = 
		(pte_t *)(PDX(UVPT) << 22 | PDX(addr) << 12 | PTX(addr) << 2);
  801047:	89 f8                	mov    %edi,%eax
  801049:	c1 e8 16             	shr    $0x16,%eax
  80104c:	c1 e0 0c             	shl    $0xc,%eax
  80104f:	0d 00 00 40 ef       	or     $0xef400000,%eax
  801054:	89 fa                	mov    %edi,%edx
  801056:	c1 ea 0a             	shr    $0xa,%edx
  801059:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  80105f:	09 d0                	or     %edx,%eax

	if ((*vpte & PTE_W) || (*vpte & PTE_COW)){
  801061:	f7 00 02 08 00 00    	testl  $0x802,(%eax)
  801067:	0f 84 82 00 00 00    	je     8010ef <fork+0x18e>
		if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm_w)) < 0)
  80106d:	e8 c5 fb ff ff       	call   800c37 <sys_getenvid>
  801072:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801079:	00 
  80107a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80107e:	89 74 24 08          	mov    %esi,0x8(%esp)
  801082:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801086:	89 04 24             	mov    %eax,(%esp)
  801089:	e8 3b fc ff ff       	call   800cc9 <sys_page_map>
  80108e:	85 c0                	test   %eax,%eax
  801090:	79 1c                	jns    8010ae <fork+0x14d>
			panic("duppage: map error!\n");
  801092:	c7 44 24 08 2e 18 80 	movl   $0x80182e,0x8(%esp)
  801099:	00 
  80109a:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8010a1:	00 
  8010a2:	c7 04 24 06 18 80 00 	movl   $0x801806,(%esp)
  8010a9:	e8 de f0 ff ff       	call   80018c <_panic>
		if ((r = sys_page_map(envid, addr, sys_getenvid(), addr, perm_w)) < 0)
  8010ae:	e8 84 fb ff ff       	call   800c37 <sys_getenvid>
  8010b3:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8010ba:	00 
  8010bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010c7:	89 34 24             	mov    %esi,(%esp)
  8010ca:	e8 fa fb ff ff       	call   800cc9 <sys_page_map>
  8010cf:	85 c0                	test   %eax,%eax
  8010d1:	79 5d                	jns    801130 <fork+0x1cf>
			panic("duppage: map error!\n");
  8010d3:	c7 44 24 08 2e 18 80 	movl   $0x80182e,0x8(%esp)
  8010da:	00 
  8010db:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8010e2:	00 
  8010e3:	c7 04 24 06 18 80 00 	movl   $0x801806,(%esp)
  8010ea:	e8 9d f0 ff ff       	call   80018c <_panic>
	} else {
		if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm_r)) < 0)
  8010ef:	e8 43 fb ff ff       	call   800c37 <sys_getenvid>
  8010f4:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8010fb:	00 
  8010fc:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801100:	89 74 24 08          	mov    %esi,0x8(%esp)
  801104:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801108:	89 04 24             	mov    %eax,(%esp)
  80110b:	e8 b9 fb ff ff       	call   800cc9 <sys_page_map>
  801110:	85 c0                	test   %eax,%eax
  801112:	79 1c                	jns    801130 <fork+0x1cf>
			panic("duppage: map error!\n");
  801114:	c7 44 24 08 2e 18 80 	movl   $0x80182e,0x8(%esp)
  80111b:	00 
  80111c:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  801123:	00 
  801124:	c7 04 24 06 18 80 00 	movl   $0x801806,(%esp)
  80112b:	e8 5c f0 ff ff       	call   80018c <_panic>
	}

	sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_U | PTE_P | PTE_W);

	int pn = 0;
	for (; pn < UTOP / PGSIZE - 1; pn++) {
  801130:	43                   	inc    %ebx
  801131:	89 df                	mov    %ebx,%edi
  801133:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  801139:	0f 85 b8 fe ff ff    	jne    800ff7 <fork+0x96>
		if ((*vpde & PTE_P) && (*vpte & PTE_P) && (*vpte & PTE_U)) 
			duppage(envid, pn);
	}

	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80113f:	c7 44 24 04 00 12 80 	movl   $0x801200,0x4(%esp)
  801146:	00 
  801147:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80114a:	89 34 24             	mov    %esi,(%esp)
  80114d:	e8 70 fc ff ff       	call   800dc2 <sys_env_set_pgfault_upcall>

	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801152:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801159:	00 
  80115a:	89 34 24             	mov    %esi,(%esp)
  80115d:	e8 0d fc ff ff       	call   800d6f <sys_env_set_status>
  801162:	85 c0                	test   %eax,%eax
  801164:	79 20                	jns    801186 <fork+0x225>
		panic("sys_env_set_status: %e", r);
  801166:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80116a:	c7 44 24 08 43 18 80 	movl   $0x801843,0x8(%esp)
  801171:	00 
  801172:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801179:	00 
  80117a:	c7 04 24 06 18 80 00 	movl   $0x801806,(%esp)
  801181:	e8 06 f0 ff ff       	call   80018c <_panic>

	return envid;
  801186:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801189:	83 c4 2c             	add    $0x2c,%esp
  80118c:	5b                   	pop    %ebx
  80118d:	5e                   	pop    %esi
  80118e:	5f                   	pop    %edi
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    

00801191 <sfork>:

// Challenge!
int
sfork(void)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801197:	c7 44 24 08 5a 18 80 	movl   $0x80185a,0x8(%esp)
  80119e:	00 
  80119f:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  8011a6:	00 
  8011a7:	c7 04 24 06 18 80 00 	movl   $0x801806,(%esp)
  8011ae:	e8 d9 ef ff ff       	call   80018c <_panic>
  8011b3:	90                   	nop

008011b4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011ba:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8011c1:	75 32                	jne    8011f5 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
    //region_alloc(curenv, (void *)UXSTACKTOP - PGSIZE, PGSIZE);
		//panic("set_pgfault_handler not implemented");
		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  8011c3:	e8 6f fa ff ff       	call   800c37 <sys_getenvid>
  8011c8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011cf:	00 
  8011d0:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011d7:	ee 
  8011d8:	89 04 24             	mov    %eax,(%esp)
  8011db:	e8 95 fa ff ff       	call   800c75 <sys_page_alloc>
    sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8011e0:	e8 52 fa ff ff       	call   800c37 <sys_getenvid>
  8011e5:	c7 44 24 04 00 12 80 	movl   $0x801200,0x4(%esp)
  8011ec:	00 
  8011ed:	89 04 24             	mov    %eax,(%esp)
  8011f0:	e8 cd fb ff ff       	call   800dc2 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f8:	a3 0c 20 80 00       	mov    %eax,0x80200c

}
  8011fd:	c9                   	leave  
  8011fe:	c3                   	ret    
  8011ff:	90                   	nop

00801200 <_pgfault_upcall>:
  801200:	54                   	push   %esp
  801201:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801206:	ff d0                	call   *%eax
  801208:	83 c4 04             	add    $0x4,%esp
  80120b:	8b 44 24 28          	mov    0x28(%esp),%eax
  80120f:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801213:	89 43 fc             	mov    %eax,-0x4(%ebx)
  801216:	83 eb 04             	sub    $0x4,%ebx
  801219:	89 5c 24 30          	mov    %ebx,0x30(%esp)
  80121d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801221:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801225:	8b 6c 24 10          	mov    0x10(%esp),%ebp
  801229:	8b 5c 24 18          	mov    0x18(%esp),%ebx
  80122d:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  801231:	8b 4c 24 20          	mov    0x20(%esp),%ecx
  801235:	8b 44 24 24          	mov    0x24(%esp),%eax
  801239:	ff 74 24 2c          	pushl  0x2c(%esp)
  80123d:	9d                   	popf   
  80123e:	8b 64 24 30          	mov    0x30(%esp),%esp
  801242:	c3                   	ret    
  801243:	66 90                	xchg   %ax,%ax
  801245:	66 90                	xchg   %ax,%ax
  801247:	66 90                	xchg   %ax,%ax
  801249:	66 90                	xchg   %ax,%ax
  80124b:	66 90                	xchg   %ax,%ax
  80124d:	66 90                	xchg   %ax,%ax
  80124f:	90                   	nop

00801250 <__udivdi3>:
  801250:	55                   	push   %ebp
  801251:	57                   	push   %edi
  801252:	56                   	push   %esi
  801253:	83 ec 0c             	sub    $0xc,%esp
  801256:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80125a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  80125e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801262:	8b 44 24 28          	mov    0x28(%esp),%eax
  801266:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80126a:	89 ea                	mov    %ebp,%edx
  80126c:	89 0c 24             	mov    %ecx,(%esp)
  80126f:	85 c0                	test   %eax,%eax
  801271:	75 2d                	jne    8012a0 <__udivdi3+0x50>
  801273:	39 e9                	cmp    %ebp,%ecx
  801275:	77 61                	ja     8012d8 <__udivdi3+0x88>
  801277:	89 ce                	mov    %ecx,%esi
  801279:	85 c9                	test   %ecx,%ecx
  80127b:	75 0b                	jne    801288 <__udivdi3+0x38>
  80127d:	b8 01 00 00 00       	mov    $0x1,%eax
  801282:	31 d2                	xor    %edx,%edx
  801284:	f7 f1                	div    %ecx
  801286:	89 c6                	mov    %eax,%esi
  801288:	31 d2                	xor    %edx,%edx
  80128a:	89 e8                	mov    %ebp,%eax
  80128c:	f7 f6                	div    %esi
  80128e:	89 c5                	mov    %eax,%ebp
  801290:	89 f8                	mov    %edi,%eax
  801292:	f7 f6                	div    %esi
  801294:	89 ea                	mov    %ebp,%edx
  801296:	83 c4 0c             	add    $0xc,%esp
  801299:	5e                   	pop    %esi
  80129a:	5f                   	pop    %edi
  80129b:	5d                   	pop    %ebp
  80129c:	c3                   	ret    
  80129d:	8d 76 00             	lea    0x0(%esi),%esi
  8012a0:	39 e8                	cmp    %ebp,%eax
  8012a2:	77 24                	ja     8012c8 <__udivdi3+0x78>
  8012a4:	0f bd e8             	bsr    %eax,%ebp
  8012a7:	83 f5 1f             	xor    $0x1f,%ebp
  8012aa:	75 3c                	jne    8012e8 <__udivdi3+0x98>
  8012ac:	8b 74 24 04          	mov    0x4(%esp),%esi
  8012b0:	39 34 24             	cmp    %esi,(%esp)
  8012b3:	0f 86 9f 00 00 00    	jbe    801358 <__udivdi3+0x108>
  8012b9:	39 d0                	cmp    %edx,%eax
  8012bb:	0f 82 97 00 00 00    	jb     801358 <__udivdi3+0x108>
  8012c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012c8:	31 d2                	xor    %edx,%edx
  8012ca:	31 c0                	xor    %eax,%eax
  8012cc:	83 c4 0c             	add    $0xc,%esp
  8012cf:	5e                   	pop    %esi
  8012d0:	5f                   	pop    %edi
  8012d1:	5d                   	pop    %ebp
  8012d2:	c3                   	ret    
  8012d3:	90                   	nop
  8012d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012d8:	89 f8                	mov    %edi,%eax
  8012da:	f7 f1                	div    %ecx
  8012dc:	31 d2                	xor    %edx,%edx
  8012de:	83 c4 0c             	add    $0xc,%esp
  8012e1:	5e                   	pop    %esi
  8012e2:	5f                   	pop    %edi
  8012e3:	5d                   	pop    %ebp
  8012e4:	c3                   	ret    
  8012e5:	8d 76 00             	lea    0x0(%esi),%esi
  8012e8:	89 e9                	mov    %ebp,%ecx
  8012ea:	8b 3c 24             	mov    (%esp),%edi
  8012ed:	d3 e0                	shl    %cl,%eax
  8012ef:	89 c6                	mov    %eax,%esi
  8012f1:	b8 20 00 00 00       	mov    $0x20,%eax
  8012f6:	29 e8                	sub    %ebp,%eax
  8012f8:	88 c1                	mov    %al,%cl
  8012fa:	d3 ef                	shr    %cl,%edi
  8012fc:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801300:	89 e9                	mov    %ebp,%ecx
  801302:	8b 3c 24             	mov    (%esp),%edi
  801305:	09 74 24 08          	or     %esi,0x8(%esp)
  801309:	d3 e7                	shl    %cl,%edi
  80130b:	89 d6                	mov    %edx,%esi
  80130d:	88 c1                	mov    %al,%cl
  80130f:	d3 ee                	shr    %cl,%esi
  801311:	89 e9                	mov    %ebp,%ecx
  801313:	89 3c 24             	mov    %edi,(%esp)
  801316:	d3 e2                	shl    %cl,%edx
  801318:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80131c:	88 c1                	mov    %al,%cl
  80131e:	d3 ef                	shr    %cl,%edi
  801320:	09 d7                	or     %edx,%edi
  801322:	89 f2                	mov    %esi,%edx
  801324:	89 f8                	mov    %edi,%eax
  801326:	f7 74 24 08          	divl   0x8(%esp)
  80132a:	89 d6                	mov    %edx,%esi
  80132c:	89 c7                	mov    %eax,%edi
  80132e:	f7 24 24             	mull   (%esp)
  801331:	89 14 24             	mov    %edx,(%esp)
  801334:	39 d6                	cmp    %edx,%esi
  801336:	72 30                	jb     801368 <__udivdi3+0x118>
  801338:	8b 54 24 04          	mov    0x4(%esp),%edx
  80133c:	89 e9                	mov    %ebp,%ecx
  80133e:	d3 e2                	shl    %cl,%edx
  801340:	39 c2                	cmp    %eax,%edx
  801342:	73 05                	jae    801349 <__udivdi3+0xf9>
  801344:	3b 34 24             	cmp    (%esp),%esi
  801347:	74 1f                	je     801368 <__udivdi3+0x118>
  801349:	89 f8                	mov    %edi,%eax
  80134b:	31 d2                	xor    %edx,%edx
  80134d:	e9 7a ff ff ff       	jmp    8012cc <__udivdi3+0x7c>
  801352:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801358:	31 d2                	xor    %edx,%edx
  80135a:	b8 01 00 00 00       	mov    $0x1,%eax
  80135f:	e9 68 ff ff ff       	jmp    8012cc <__udivdi3+0x7c>
  801364:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801368:	8d 47 ff             	lea    -0x1(%edi),%eax
  80136b:	31 d2                	xor    %edx,%edx
  80136d:	83 c4 0c             	add    $0xc,%esp
  801370:	5e                   	pop    %esi
  801371:	5f                   	pop    %edi
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    
  801374:	66 90                	xchg   %ax,%ax
  801376:	66 90                	xchg   %ax,%ax
  801378:	66 90                	xchg   %ax,%ax
  80137a:	66 90                	xchg   %ax,%ax
  80137c:	66 90                	xchg   %ax,%ax
  80137e:	66 90                	xchg   %ax,%ax

00801380 <__umoddi3>:
  801380:	55                   	push   %ebp
  801381:	57                   	push   %edi
  801382:	56                   	push   %esi
  801383:	83 ec 14             	sub    $0x14,%esp
  801386:	8b 44 24 28          	mov    0x28(%esp),%eax
  80138a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80138e:	89 c7                	mov    %eax,%edi
  801390:	89 44 24 04          	mov    %eax,0x4(%esp)
  801394:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801398:	8b 44 24 30          	mov    0x30(%esp),%eax
  80139c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8013a0:	89 34 24             	mov    %esi,(%esp)
  8013a3:	89 c2                	mov    %eax,%edx
  8013a5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013a9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013ad:	85 c0                	test   %eax,%eax
  8013af:	75 17                	jne    8013c8 <__umoddi3+0x48>
  8013b1:	39 fe                	cmp    %edi,%esi
  8013b3:	76 4b                	jbe    801400 <__umoddi3+0x80>
  8013b5:	89 c8                	mov    %ecx,%eax
  8013b7:	89 fa                	mov    %edi,%edx
  8013b9:	f7 f6                	div    %esi
  8013bb:	89 d0                	mov    %edx,%eax
  8013bd:	31 d2                	xor    %edx,%edx
  8013bf:	83 c4 14             	add    $0x14,%esp
  8013c2:	5e                   	pop    %esi
  8013c3:	5f                   	pop    %edi
  8013c4:	5d                   	pop    %ebp
  8013c5:	c3                   	ret    
  8013c6:	66 90                	xchg   %ax,%ax
  8013c8:	39 f8                	cmp    %edi,%eax
  8013ca:	77 54                	ja     801420 <__umoddi3+0xa0>
  8013cc:	0f bd e8             	bsr    %eax,%ebp
  8013cf:	83 f5 1f             	xor    $0x1f,%ebp
  8013d2:	75 5c                	jne    801430 <__umoddi3+0xb0>
  8013d4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8013d8:	39 3c 24             	cmp    %edi,(%esp)
  8013db:	0f 87 f7 00 00 00    	ja     8014d8 <__umoddi3+0x158>
  8013e1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013e5:	29 f1                	sub    %esi,%ecx
  8013e7:	19 c7                	sbb    %eax,%edi
  8013e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013ed:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013f1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013f5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8013f9:	83 c4 14             	add    $0x14,%esp
  8013fc:	5e                   	pop    %esi
  8013fd:	5f                   	pop    %edi
  8013fe:	5d                   	pop    %ebp
  8013ff:	c3                   	ret    
  801400:	89 f5                	mov    %esi,%ebp
  801402:	85 f6                	test   %esi,%esi
  801404:	75 0b                	jne    801411 <__umoddi3+0x91>
  801406:	b8 01 00 00 00       	mov    $0x1,%eax
  80140b:	31 d2                	xor    %edx,%edx
  80140d:	f7 f6                	div    %esi
  80140f:	89 c5                	mov    %eax,%ebp
  801411:	8b 44 24 04          	mov    0x4(%esp),%eax
  801415:	31 d2                	xor    %edx,%edx
  801417:	f7 f5                	div    %ebp
  801419:	89 c8                	mov    %ecx,%eax
  80141b:	f7 f5                	div    %ebp
  80141d:	eb 9c                	jmp    8013bb <__umoddi3+0x3b>
  80141f:	90                   	nop
  801420:	89 c8                	mov    %ecx,%eax
  801422:	89 fa                	mov    %edi,%edx
  801424:	83 c4 14             	add    $0x14,%esp
  801427:	5e                   	pop    %esi
  801428:	5f                   	pop    %edi
  801429:	5d                   	pop    %ebp
  80142a:	c3                   	ret    
  80142b:	90                   	nop
  80142c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801430:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801437:	00 
  801438:	8b 34 24             	mov    (%esp),%esi
  80143b:	8b 44 24 04          	mov    0x4(%esp),%eax
  80143f:	89 e9                	mov    %ebp,%ecx
  801441:	29 e8                	sub    %ebp,%eax
  801443:	89 44 24 04          	mov    %eax,0x4(%esp)
  801447:	89 f0                	mov    %esi,%eax
  801449:	d3 e2                	shl    %cl,%edx
  80144b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  80144f:	d3 e8                	shr    %cl,%eax
  801451:	89 04 24             	mov    %eax,(%esp)
  801454:	89 e9                	mov    %ebp,%ecx
  801456:	89 f0                	mov    %esi,%eax
  801458:	09 14 24             	or     %edx,(%esp)
  80145b:	d3 e0                	shl    %cl,%eax
  80145d:	89 fa                	mov    %edi,%edx
  80145f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801463:	d3 ea                	shr    %cl,%edx
  801465:	89 e9                	mov    %ebp,%ecx
  801467:	89 c6                	mov    %eax,%esi
  801469:	d3 e7                	shl    %cl,%edi
  80146b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80146f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801473:	8b 44 24 10          	mov    0x10(%esp),%eax
  801477:	d3 e8                	shr    %cl,%eax
  801479:	09 f8                	or     %edi,%eax
  80147b:	89 e9                	mov    %ebp,%ecx
  80147d:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801481:	d3 e7                	shl    %cl,%edi
  801483:	f7 34 24             	divl   (%esp)
  801486:	89 d1                	mov    %edx,%ecx
  801488:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80148c:	f7 e6                	mul    %esi
  80148e:	89 c7                	mov    %eax,%edi
  801490:	89 d6                	mov    %edx,%esi
  801492:	39 d1                	cmp    %edx,%ecx
  801494:	72 2e                	jb     8014c4 <__umoddi3+0x144>
  801496:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80149a:	72 24                	jb     8014c0 <__umoddi3+0x140>
  80149c:	89 ca                	mov    %ecx,%edx
  80149e:	89 e9                	mov    %ebp,%ecx
  8014a0:	8b 44 24 08          	mov    0x8(%esp),%eax
  8014a4:	29 f8                	sub    %edi,%eax
  8014a6:	19 f2                	sbb    %esi,%edx
  8014a8:	d3 e8                	shr    %cl,%eax
  8014aa:	89 d6                	mov    %edx,%esi
  8014ac:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8014b0:	d3 e6                	shl    %cl,%esi
  8014b2:	89 e9                	mov    %ebp,%ecx
  8014b4:	09 f0                	or     %esi,%eax
  8014b6:	d3 ea                	shr    %cl,%edx
  8014b8:	83 c4 14             	add    $0x14,%esp
  8014bb:	5e                   	pop    %esi
  8014bc:	5f                   	pop    %edi
  8014bd:	5d                   	pop    %ebp
  8014be:	c3                   	ret    
  8014bf:	90                   	nop
  8014c0:	39 d1                	cmp    %edx,%ecx
  8014c2:	75 d8                	jne    80149c <__umoddi3+0x11c>
  8014c4:	89 d6                	mov    %edx,%esi
  8014c6:	89 c7                	mov    %eax,%edi
  8014c8:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  8014cc:	1b 34 24             	sbb    (%esp),%esi
  8014cf:	eb cb                	jmp    80149c <__umoddi3+0x11c>
  8014d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8014dc:	0f 82 ff fe ff ff    	jb     8013e1 <__umoddi3+0x61>
  8014e2:	e9 0a ff ff ff       	jmp    8013f1 <__umoddi3+0x71>
