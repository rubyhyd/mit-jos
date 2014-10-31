
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
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
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	5d                   	pop    %ebp
  80003e:	c3                   	ret    
  80003f:	90                   	nop

00800040 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
  800046:	8b 45 08             	mov    0x8(%ebp),%eax
  800049:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004c:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800053:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800056:	85 c0                	test   %eax,%eax
  800058:	7e 08                	jle    800062 <libmain+0x22>
		binaryname = argv[0];
  80005a:	8b 0a                	mov    (%edx),%ecx
  80005c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800062:	89 54 24 04          	mov    %edx,0x4(%esp)
  800066:	89 04 24             	mov    %eax,(%esp)
  800069:	e8 c6 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80006e:	e8 05 00 00 00       	call   800078 <exit>
}
  800073:	c9                   	leave  
  800074:	c3                   	ret    
  800075:	66 90                	xchg   %ax,%ax
  800077:	90                   	nop

00800078 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80007e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800085:	e8 3f 00 00 00       	call   8000c9 <sys_env_destroy>
}
  80008a:	c9                   	leave  
  80008b:	c3                   	ret    

0080008c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	57                   	push   %edi
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800092:	b8 00 00 00 00       	mov    $0x0,%eax
  800097:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009a:	8b 55 08             	mov    0x8(%ebp),%edx
  80009d:	89 c3                	mov    %eax,%ebx
  80009f:	89 c7                	mov    %eax,%edi
  8000a1:	89 c6                	mov    %eax,%esi
  8000a3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000a5:	5b                   	pop    %ebx
  8000a6:	5e                   	pop    %esi
  8000a7:	5f                   	pop    %edi
  8000a8:	5d                   	pop    %ebp
  8000a9:	c3                   	ret    

008000aa <sys_cgetc>:

int
sys_cgetc(void)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ba:	89 d1                	mov    %edx,%ecx
  8000bc:	89 d3                	mov    %edx,%ebx
  8000be:	89 d7                	mov    %edx,%edi
  8000c0:	89 d6                	mov    %edx,%esi
  8000c2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c4:	5b                   	pop    %ebx
  8000c5:	5e                   	pop    %esi
  8000c6:	5f                   	pop    %edi
  8000c7:	5d                   	pop    %ebp
  8000c8:	c3                   	ret    

008000c9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	57                   	push   %edi
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000d7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000df:	89 cb                	mov    %ecx,%ebx
  8000e1:	89 cf                	mov    %ecx,%edi
  8000e3:	89 ce                	mov    %ecx,%esi
  8000e5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000e7:	85 c0                	test   %eax,%eax
  8000e9:	7e 28                	jle    800113 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000ef:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8000f6:	00 
  8000f7:	c7 44 24 08 0a 0e 80 	movl   $0x800e0a,0x8(%esp)
  8000fe:	00 
  8000ff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800106:	00 
  800107:	c7 04 24 27 0e 80 00 	movl   $0x800e27,(%esp)
  80010e:	e8 29 00 00 00       	call   80013c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800113:	83 c4 2c             	add    $0x2c,%esp
  800116:	5b                   	pop    %ebx
  800117:	5e                   	pop    %esi
  800118:	5f                   	pop    %edi
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    

0080011b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	57                   	push   %edi
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800121:	ba 00 00 00 00       	mov    $0x0,%edx
  800126:	b8 02 00 00 00       	mov    $0x2,%eax
  80012b:	89 d1                	mov    %edx,%ecx
  80012d:	89 d3                	mov    %edx,%ebx
  80012f:	89 d7                	mov    %edx,%edi
  800131:	89 d6                	mov    %edx,%esi
  800133:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800135:	5b                   	pop    %ebx
  800136:	5e                   	pop    %esi
  800137:	5f                   	pop    %edi
  800138:	5d                   	pop    %ebp
  800139:	c3                   	ret    
  80013a:	66 90                	xchg   %ax,%ax

0080013c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
  800141:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800144:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800147:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80014d:	e8 c9 ff ff ff       	call   80011b <sys_getenvid>
  800152:	8b 55 0c             	mov    0xc(%ebp),%edx
  800155:	89 54 24 10          	mov    %edx,0x10(%esp)
  800159:	8b 55 08             	mov    0x8(%ebp),%edx
  80015c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800160:	89 74 24 08          	mov    %esi,0x8(%esp)
  800164:	89 44 24 04          	mov    %eax,0x4(%esp)
  800168:	c7 04 24 38 0e 80 00 	movl   $0x800e38,(%esp)
  80016f:	e8 c2 00 00 00       	call   800236 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800174:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800178:	8b 45 10             	mov    0x10(%ebp),%eax
  80017b:	89 04 24             	mov    %eax,(%esp)
  80017e:	e8 52 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800183:	c7 04 24 5c 0e 80 00 	movl   $0x800e5c,(%esp)
  80018a:	e8 a7 00 00 00       	call   800236 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018f:	cc                   	int3   
  800190:	eb fd                	jmp    80018f <_panic+0x53>
  800192:	66 90                	xchg   %ax,%ax

00800194 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	53                   	push   %ebx
  800198:	83 ec 14             	sub    $0x14,%esp
  80019b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019e:	8b 13                	mov    (%ebx),%edx
  8001a0:	8d 42 01             	lea    0x1(%edx),%eax
  8001a3:	89 03                	mov    %eax,(%ebx)
  8001a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ac:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b1:	75 19                	jne    8001cc <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001b3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ba:	00 
  8001bb:	8d 43 08             	lea    0x8(%ebx),%eax
  8001be:	89 04 24             	mov    %eax,(%esp)
  8001c1:	e8 c6 fe ff ff       	call   80008c <sys_cputs>
		b->idx = 0;
  8001c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001cc:	ff 43 04             	incl   0x4(%ebx)
}
  8001cf:	83 c4 14             	add    $0x14,%esp
  8001d2:	5b                   	pop    %ebx
  8001d3:	5d                   	pop    %ebp
  8001d4:	c3                   	ret    

008001d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e5:	00 00 00 
	b.cnt = 0;
  8001e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800200:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800206:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020a:	c7 04 24 94 01 80 00 	movl   $0x800194,(%esp)
  800211:	e8 a9 01 00 00       	call   8003bf <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800216:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80021c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800220:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800226:	89 04 24             	mov    %eax,(%esp)
  800229:	e8 5e fe ff ff       	call   80008c <sys_cputs>

	return b.cnt;
}
  80022e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800243:	8b 45 08             	mov    0x8(%ebp),%eax
  800246:	89 04 24             	mov    %eax,(%esp)
  800249:	e8 87 ff ff ff       	call   8001d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	57                   	push   %edi
  800254:	56                   	push   %esi
  800255:	53                   	push   %ebx
  800256:	83 ec 3c             	sub    $0x3c,%esp
  800259:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80025c:	89 d7                	mov    %edx,%edi
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800264:	8b 45 0c             	mov    0xc(%ebp),%eax
  800267:	89 c1                	mov    %eax,%ecx
  800269:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80026c:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80026f:	8b 45 10             	mov    0x10(%ebp),%eax
  800272:	ba 00 00 00 00       	mov    $0x0,%edx
  800277:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80027a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80027d:	39 ca                	cmp    %ecx,%edx
  80027f:	72 08                	jb     800289 <printnum+0x39>
  800281:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800284:	39 45 10             	cmp    %eax,0x10(%ebp)
  800287:	77 6a                	ja     8002f3 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800289:	8b 45 18             	mov    0x18(%ebp),%eax
  80028c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800290:	4e                   	dec    %esi
  800291:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800295:	8b 45 10             	mov    0x10(%ebp),%eax
  800298:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029c:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002a0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002a4:	89 c3                	mov    %eax,%ebx
  8002a6:	89 d6                	mov    %edx,%esi
  8002a8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002ab:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b9:	89 04 24             	mov    %eax,(%esp)
  8002bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c3:	e8 98 08 00 00       	call   800b60 <__udivdi3>
  8002c8:	89 d9                	mov    %ebx,%ecx
  8002ca:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ce:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d2:	89 04 24             	mov    %eax,(%esp)
  8002d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002d9:	89 fa                	mov    %edi,%edx
  8002db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002de:	e8 6d ff ff ff       	call   800250 <printnum>
  8002e3:	eb 19                	jmp    8002fe <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e9:	8b 45 18             	mov    0x18(%ebp),%eax
  8002ec:	89 04 24             	mov    %eax,(%esp)
  8002ef:	ff d3                	call   *%ebx
  8002f1:	eb 03                	jmp    8002f6 <printnum+0xa6>
  8002f3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f6:	4e                   	dec    %esi
  8002f7:	85 f6                	test   %esi,%esi
  8002f9:	7f ea                	jg     8002e5 <printnum+0x95>
  8002fb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800302:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800306:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800309:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80030c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800310:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800314:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800317:	89 04 24             	mov    %eax,(%esp)
  80031a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80031d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800321:	e8 6a 09 00 00       	call   800c90 <__umoddi3>
  800326:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80032a:	0f be 80 5e 0e 80 00 	movsbl 0x800e5e(%eax),%eax
  800331:	89 04 24             	mov    %eax,(%esp)
  800334:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800337:	ff d0                	call   *%eax
}
  800339:	83 c4 3c             	add    $0x3c,%esp
  80033c:	5b                   	pop    %ebx
  80033d:	5e                   	pop    %esi
  80033e:	5f                   	pop    %edi
  80033f:	5d                   	pop    %ebp
  800340:	c3                   	ret    

00800341 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800341:	55                   	push   %ebp
  800342:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800344:	83 fa 01             	cmp    $0x1,%edx
  800347:	7e 0e                	jle    800357 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800349:	8b 10                	mov    (%eax),%edx
  80034b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80034e:	89 08                	mov    %ecx,(%eax)
  800350:	8b 02                	mov    (%edx),%eax
  800352:	8b 52 04             	mov    0x4(%edx),%edx
  800355:	eb 22                	jmp    800379 <getuint+0x38>
	else if (lflag)
  800357:	85 d2                	test   %edx,%edx
  800359:	74 10                	je     80036b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80035b:	8b 10                	mov    (%eax),%edx
  80035d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800360:	89 08                	mov    %ecx,(%eax)
  800362:	8b 02                	mov    (%edx),%eax
  800364:	ba 00 00 00 00       	mov    $0x0,%edx
  800369:	eb 0e                	jmp    800379 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80036b:	8b 10                	mov    (%eax),%edx
  80036d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800370:	89 08                	mov    %ecx,(%eax)
  800372:	8b 02                	mov    (%edx),%eax
  800374:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800381:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800384:	8b 10                	mov    (%eax),%edx
  800386:	3b 50 04             	cmp    0x4(%eax),%edx
  800389:	73 0a                	jae    800395 <sprintputch+0x1a>
		*b->buf++ = ch;
  80038b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80038e:	89 08                	mov    %ecx,(%eax)
  800390:	8b 45 08             	mov    0x8(%ebp),%eax
  800393:	88 02                	mov    %al,(%edx)
}
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80039d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b5:	89 04 24             	mov    %eax,(%esp)
  8003b8:	e8 02 00 00 00       	call   8003bf <vprintfmt>
	va_end(ap);
}
  8003bd:	c9                   	leave  
  8003be:	c3                   	ret    

008003bf <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	57                   	push   %edi
  8003c3:	56                   	push   %esi
  8003c4:	53                   	push   %ebx
  8003c5:	83 ec 3c             	sub    $0x3c,%esp
  8003c8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003ce:	eb 14                	jmp    8003e4 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d0:	85 c0                	test   %eax,%eax
  8003d2:	0f 84 8a 03 00 00    	je     800762 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  8003d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003dc:	89 04 24             	mov    %eax,(%esp)
  8003df:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e2:	89 f3                	mov    %esi,%ebx
  8003e4:	8d 73 01             	lea    0x1(%ebx),%esi
  8003e7:	31 c0                	xor    %eax,%eax
  8003e9:	8a 03                	mov    (%ebx),%al
  8003eb:	83 f8 25             	cmp    $0x25,%eax
  8003ee:	75 e0                	jne    8003d0 <vprintfmt+0x11>
  8003f0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003f4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003fb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800402:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800409:	ba 00 00 00 00       	mov    $0x0,%edx
  80040e:	eb 1d                	jmp    80042d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800412:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800416:	eb 15                	jmp    80042d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80041a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80041e:	eb 0d                	jmp    80042d <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800420:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800423:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800426:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8d 5e 01             	lea    0x1(%esi),%ebx
  800430:	31 c0                	xor    %eax,%eax
  800432:	8a 06                	mov    (%esi),%al
  800434:	8a 0e                	mov    (%esi),%cl
  800436:	83 e9 23             	sub    $0x23,%ecx
  800439:	88 4d e0             	mov    %cl,-0x20(%ebp)
  80043c:	80 f9 55             	cmp    $0x55,%cl
  80043f:	0f 87 ff 02 00 00    	ja     800744 <vprintfmt+0x385>
  800445:	31 c9                	xor    %ecx,%ecx
  800447:	8a 4d e0             	mov    -0x20(%ebp),%cl
  80044a:	ff 24 8d 00 0f 80 00 	jmp    *0x800f00(,%ecx,4)
  800451:	89 de                	mov    %ebx,%esi
  800453:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800458:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80045b:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  80045f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800462:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800465:	83 fb 09             	cmp    $0x9,%ebx
  800468:	77 2f                	ja     800499 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80046a:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80046b:	eb eb                	jmp    800458 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80046d:	8b 45 14             	mov    0x14(%ebp),%eax
  800470:	8d 48 04             	lea    0x4(%eax),%ecx
  800473:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800476:	8b 00                	mov    (%eax),%eax
  800478:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80047d:	eb 1d                	jmp    80049c <vprintfmt+0xdd>
  80047f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800482:	f7 d0                	not    %eax
  800484:	c1 f8 1f             	sar    $0x1f,%eax
  800487:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	89 de                	mov    %ebx,%esi
  80048c:	eb 9f                	jmp    80042d <vprintfmt+0x6e>
  80048e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800490:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800497:	eb 94                	jmp    80042d <vprintfmt+0x6e>
  800499:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80049c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004a0:	79 8b                	jns    80042d <vprintfmt+0x6e>
  8004a2:	e9 79 ff ff ff       	jmp    800420 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a7:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004aa:	eb 81                	jmp    80042d <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8d 50 04             	lea    0x4(%eax),%edx
  8004b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004b9:	8b 00                	mov    (%eax),%eax
  8004bb:	89 04 24             	mov    %eax,(%esp)
  8004be:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004c1:	e9 1e ff ff ff       	jmp    8003e4 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8d 50 04             	lea    0x4(%eax),%edx
  8004cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	89 c2                	mov    %eax,%edx
  8004d3:	c1 fa 1f             	sar    $0x1f,%edx
  8004d6:	31 d0                	xor    %edx,%eax
  8004d8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004da:	83 f8 07             	cmp    $0x7,%eax
  8004dd:	7f 0b                	jg     8004ea <vprintfmt+0x12b>
  8004df:	8b 14 85 60 10 80 00 	mov    0x801060(,%eax,4),%edx
  8004e6:	85 d2                	test   %edx,%edx
  8004e8:	75 20                	jne    80050a <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  8004ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ee:	c7 44 24 08 76 0e 80 	movl   $0x800e76,0x8(%esp)
  8004f5:	00 
  8004f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fd:	89 04 24             	mov    %eax,(%esp)
  800500:	e8 92 fe ff ff       	call   800397 <printfmt>
  800505:	e9 da fe ff ff       	jmp    8003e4 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80050a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80050e:	c7 44 24 08 7f 0e 80 	movl   $0x800e7f,0x8(%esp)
  800515:	00 
  800516:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80051a:	8b 45 08             	mov    0x8(%ebp),%eax
  80051d:	89 04 24             	mov    %eax,(%esp)
  800520:	e8 72 fe ff ff       	call   800397 <printfmt>
  800525:	e9 ba fe ff ff       	jmp    8003e4 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80052d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800530:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 50 04             	lea    0x4(%eax),%edx
  800539:	89 55 14             	mov    %edx,0x14(%ebp)
  80053c:	8b 30                	mov    (%eax),%esi
  80053e:	85 f6                	test   %esi,%esi
  800540:	75 05                	jne    800547 <vprintfmt+0x188>
				p = "(null)";
  800542:	be 6f 0e 80 00       	mov    $0x800e6f,%esi
			if (width > 0 && padc != '-')
  800547:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80054b:	0f 84 8c 00 00 00    	je     8005dd <vprintfmt+0x21e>
  800551:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800555:	0f 8e 8a 00 00 00    	jle    8005e5 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80055f:	89 34 24             	mov    %esi,(%esp)
  800562:	e8 9b 02 00 00       	call   800802 <strnlen>
  800567:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80056a:	29 c1                	sub    %eax,%ecx
  80056c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  80056f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800573:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800576:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800579:	8b 75 08             	mov    0x8(%ebp),%esi
  80057c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80057f:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800581:	eb 0d                	jmp    800590 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800583:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800587:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80058a:	89 04 24             	mov    %eax,(%esp)
  80058d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058f:	4b                   	dec    %ebx
  800590:	85 db                	test   %ebx,%ebx
  800592:	7f ef                	jg     800583 <vprintfmt+0x1c4>
  800594:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800597:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80059a:	89 c8                	mov    %ecx,%eax
  80059c:	f7 d0                	not    %eax
  80059e:	c1 f8 1f             	sar    $0x1f,%eax
  8005a1:	21 c8                	and    %ecx,%eax
  8005a3:	29 c1                	sub    %eax,%ecx
  8005a5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005ab:	eb 3e                	jmp    8005eb <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b1:	74 1b                	je     8005ce <vprintfmt+0x20f>
  8005b3:	0f be d2             	movsbl %dl,%edx
  8005b6:	83 ea 20             	sub    $0x20,%edx
  8005b9:	83 fa 5e             	cmp    $0x5e,%edx
  8005bc:	76 10                	jbe    8005ce <vprintfmt+0x20f>
					putch('?', putdat);
  8005be:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005c2:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005c9:	ff 55 08             	call   *0x8(%ebp)
  8005cc:	eb 0a                	jmp    8005d8 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  8005ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d2:	89 04 24             	mov    %eax,(%esp)
  8005d5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d8:	ff 4d dc             	decl   -0x24(%ebp)
  8005db:	eb 0e                	jmp    8005eb <vprintfmt+0x22c>
  8005dd:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005e0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005e3:	eb 06                	jmp    8005eb <vprintfmt+0x22c>
  8005e5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005e8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005eb:	46                   	inc    %esi
  8005ec:	8a 56 ff             	mov    -0x1(%esi),%dl
  8005ef:	0f be c2             	movsbl %dl,%eax
  8005f2:	85 c0                	test   %eax,%eax
  8005f4:	74 1f                	je     800615 <vprintfmt+0x256>
  8005f6:	85 db                	test   %ebx,%ebx
  8005f8:	78 b3                	js     8005ad <vprintfmt+0x1ee>
  8005fa:	4b                   	dec    %ebx
  8005fb:	79 b0                	jns    8005ad <vprintfmt+0x1ee>
  8005fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800600:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800603:	eb 16                	jmp    80061b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800605:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800609:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800610:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800612:	4b                   	dec    %ebx
  800613:	eb 06                	jmp    80061b <vprintfmt+0x25c>
  800615:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800618:	8b 75 08             	mov    0x8(%ebp),%esi
  80061b:	85 db                	test   %ebx,%ebx
  80061d:	7f e6                	jg     800605 <vprintfmt+0x246>
  80061f:	89 75 08             	mov    %esi,0x8(%ebp)
  800622:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800625:	e9 ba fd ff ff       	jmp    8003e4 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80062a:	83 fa 01             	cmp    $0x1,%edx
  80062d:	7e 16                	jle    800645 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8d 50 08             	lea    0x8(%eax),%edx
  800635:	89 55 14             	mov    %edx,0x14(%ebp)
  800638:	8b 50 04             	mov    0x4(%eax),%edx
  80063b:	8b 00                	mov    (%eax),%eax
  80063d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800640:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800643:	eb 32                	jmp    800677 <vprintfmt+0x2b8>
	else if (lflag)
  800645:	85 d2                	test   %edx,%edx
  800647:	74 18                	je     800661 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8d 50 04             	lea    0x4(%eax),%edx
  80064f:	89 55 14             	mov    %edx,0x14(%ebp)
  800652:	8b 30                	mov    (%eax),%esi
  800654:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800657:	89 f0                	mov    %esi,%eax
  800659:	c1 f8 1f             	sar    $0x1f,%eax
  80065c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80065f:	eb 16                	jmp    800677 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	8d 50 04             	lea    0x4(%eax),%edx
  800667:	89 55 14             	mov    %edx,0x14(%ebp)
  80066a:	8b 30                	mov    (%eax),%esi
  80066c:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80066f:	89 f0                	mov    %esi,%eax
  800671:	c1 f8 1f             	sar    $0x1f,%eax
  800674:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800677:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80067a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80067d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800682:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800686:	0f 89 80 00 00 00    	jns    80070c <vprintfmt+0x34d>
				putch('-', putdat);
  80068c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800690:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800697:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80069a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80069d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006a0:	f7 d8                	neg    %eax
  8006a2:	83 d2 00             	adc    $0x0,%edx
  8006a5:	f7 da                	neg    %edx
			}
			base = 10;
  8006a7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006ac:	eb 5e                	jmp    80070c <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b1:	e8 8b fc ff ff       	call   800341 <getuint>
			base = 10;
  8006b6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006bb:	eb 4f                	jmp    80070c <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  8006bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c0:	e8 7c fc ff ff       	call   800341 <getuint>
			base = 8;
  8006c5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006ca:	eb 40                	jmp    80070c <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  8006cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006d7:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006de:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006e5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8d 50 04             	lea    0x4(%eax),%edx
  8006ee:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006f1:	8b 00                	mov    (%eax),%eax
  8006f3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006f8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006fd:	eb 0d                	jmp    80070c <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800702:	e8 3a fc ff ff       	call   800341 <getuint>
			base = 16;
  800707:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80070c:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800710:	89 74 24 10          	mov    %esi,0x10(%esp)
  800714:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800717:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80071b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80071f:	89 04 24             	mov    %eax,(%esp)
  800722:	89 54 24 04          	mov    %edx,0x4(%esp)
  800726:	89 fa                	mov    %edi,%edx
  800728:	8b 45 08             	mov    0x8(%ebp),%eax
  80072b:	e8 20 fb ff ff       	call   800250 <printnum>
			break;
  800730:	e9 af fc ff ff       	jmp    8003e4 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800735:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800739:	89 04 24             	mov    %eax,(%esp)
  80073c:	ff 55 08             	call   *0x8(%ebp)
			break;
  80073f:	e9 a0 fc ff ff       	jmp    8003e4 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800744:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800748:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80074f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800752:	89 f3                	mov    %esi,%ebx
  800754:	eb 01                	jmp    800757 <vprintfmt+0x398>
  800756:	4b                   	dec    %ebx
  800757:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80075b:	75 f9                	jne    800756 <vprintfmt+0x397>
  80075d:	e9 82 fc ff ff       	jmp    8003e4 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800762:	83 c4 3c             	add    $0x3c,%esp
  800765:	5b                   	pop    %ebx
  800766:	5e                   	pop    %esi
  800767:	5f                   	pop    %edi
  800768:	5d                   	pop    %ebp
  800769:	c3                   	ret    

0080076a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	83 ec 28             	sub    $0x28,%esp
  800770:	8b 45 08             	mov    0x8(%ebp),%eax
  800773:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800776:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800779:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80077d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800780:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800787:	85 c0                	test   %eax,%eax
  800789:	74 30                	je     8007bb <vsnprintf+0x51>
  80078b:	85 d2                	test   %edx,%edx
  80078d:	7e 2c                	jle    8007bb <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800796:	8b 45 10             	mov    0x10(%ebp),%eax
  800799:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a4:	c7 04 24 7b 03 80 00 	movl   $0x80037b,(%esp)
  8007ab:	e8 0f fc ff ff       	call   8003bf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b9:	eb 05                	jmp    8007c0 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e0:	89 04 24             	mov    %eax,(%esp)
  8007e3:	e8 82 ff ff ff       	call   80076a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e8:	c9                   	leave  
  8007e9:	c3                   	ret    
  8007ea:	66 90                	xchg   %ax,%ax

008007ec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f7:	eb 01                	jmp    8007fa <strlen+0xe>
		n++;
  8007f9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007fe:	75 f9                	jne    8007f9 <strlen+0xd>
		n++;
	return n;
}
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800808:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080b:	b8 00 00 00 00       	mov    $0x0,%eax
  800810:	eb 01                	jmp    800813 <strnlen+0x11>
		n++;
  800812:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800813:	39 d0                	cmp    %edx,%eax
  800815:	74 06                	je     80081d <strnlen+0x1b>
  800817:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80081b:	75 f5                	jne    800812 <strnlen+0x10>
		n++;
	return n;
}
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	53                   	push   %ebx
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800829:	89 c2                	mov    %eax,%edx
  80082b:	42                   	inc    %edx
  80082c:	41                   	inc    %ecx
  80082d:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800830:	88 5a ff             	mov    %bl,-0x1(%edx)
  800833:	84 db                	test   %bl,%bl
  800835:	75 f4                	jne    80082b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800837:	5b                   	pop    %ebx
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	83 ec 08             	sub    $0x8,%esp
  800841:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800844:	89 1c 24             	mov    %ebx,(%esp)
  800847:	e8 a0 ff ff ff       	call   8007ec <strlen>
	strcpy(dst + len, src);
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800853:	01 d8                	add    %ebx,%eax
  800855:	89 04 24             	mov    %eax,(%esp)
  800858:	e8 c2 ff ff ff       	call   80081f <strcpy>
	return dst;
}
  80085d:	89 d8                	mov    %ebx,%eax
  80085f:	83 c4 08             	add    $0x8,%esp
  800862:	5b                   	pop    %ebx
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	56                   	push   %esi
  800869:	53                   	push   %ebx
  80086a:	8b 75 08             	mov    0x8(%ebp),%esi
  80086d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800870:	89 f3                	mov    %esi,%ebx
  800872:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800875:	89 f2                	mov    %esi,%edx
  800877:	eb 0c                	jmp    800885 <strncpy+0x20>
		*dst++ = *src;
  800879:	42                   	inc    %edx
  80087a:	8a 01                	mov    (%ecx),%al
  80087c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80087f:	80 39 01             	cmpb   $0x1,(%ecx)
  800882:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800885:	39 da                	cmp    %ebx,%edx
  800887:	75 f0                	jne    800879 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800889:	89 f0                	mov    %esi,%eax
  80088b:	5b                   	pop    %ebx
  80088c:	5e                   	pop    %esi
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    

0080088f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	56                   	push   %esi
  800893:	53                   	push   %ebx
  800894:	8b 75 08             	mov    0x8(%ebp),%esi
  800897:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80089d:	89 f0                	mov    %esi,%eax
  80089f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a3:	85 c9                	test   %ecx,%ecx
  8008a5:	75 07                	jne    8008ae <strlcpy+0x1f>
  8008a7:	eb 18                	jmp    8008c1 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a9:	40                   	inc    %eax
  8008aa:	42                   	inc    %edx
  8008ab:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ae:	39 d8                	cmp    %ebx,%eax
  8008b0:	74 0a                	je     8008bc <strlcpy+0x2d>
  8008b2:	8a 0a                	mov    (%edx),%cl
  8008b4:	84 c9                	test   %cl,%cl
  8008b6:	75 f1                	jne    8008a9 <strlcpy+0x1a>
  8008b8:	89 c2                	mov    %eax,%edx
  8008ba:	eb 02                	jmp    8008be <strlcpy+0x2f>
  8008bc:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008be:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008c1:	29 f0                	sub    %esi,%eax
}
  8008c3:	5b                   	pop    %ebx
  8008c4:	5e                   	pop    %esi
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008cd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d0:	eb 02                	jmp    8008d4 <strcmp+0xd>
		p++, q++;
  8008d2:	41                   	inc    %ecx
  8008d3:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008d4:	8a 01                	mov    (%ecx),%al
  8008d6:	84 c0                	test   %al,%al
  8008d8:	74 04                	je     8008de <strcmp+0x17>
  8008da:	3a 02                	cmp    (%edx),%al
  8008dc:	74 f4                	je     8008d2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008de:	25 ff 00 00 00       	and    $0xff,%eax
  8008e3:	8a 0a                	mov    (%edx),%cl
  8008e5:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8008eb:	29 c8                	sub    %ecx,%eax
}
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	53                   	push   %ebx
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f9:	89 c3                	mov    %eax,%ebx
  8008fb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008fe:	eb 02                	jmp    800902 <strncmp+0x13>
		n--, p++, q++;
  800900:	40                   	inc    %eax
  800901:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800902:	39 d8                	cmp    %ebx,%eax
  800904:	74 20                	je     800926 <strncmp+0x37>
  800906:	8a 08                	mov    (%eax),%cl
  800908:	84 c9                	test   %cl,%cl
  80090a:	74 04                	je     800910 <strncmp+0x21>
  80090c:	3a 0a                	cmp    (%edx),%cl
  80090e:	74 f0                	je     800900 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800910:	8a 18                	mov    (%eax),%bl
  800912:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800918:	89 d8                	mov    %ebx,%eax
  80091a:	8a 1a                	mov    (%edx),%bl
  80091c:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800922:	29 d8                	sub    %ebx,%eax
  800924:	eb 05                	jmp    80092b <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800926:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80092b:	5b                   	pop    %ebx
  80092c:	5d                   	pop    %ebp
  80092d:	c3                   	ret    

0080092e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800937:	eb 05                	jmp    80093e <strchr+0x10>
		if (*s == c)
  800939:	38 ca                	cmp    %cl,%dl
  80093b:	74 0c                	je     800949 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80093d:	40                   	inc    %eax
  80093e:	8a 10                	mov    (%eax),%dl
  800940:	84 d2                	test   %dl,%dl
  800942:	75 f5                	jne    800939 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800944:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800954:	eb 05                	jmp    80095b <strfind+0x10>
		if (*s == c)
  800956:	38 ca                	cmp    %cl,%dl
  800958:	74 07                	je     800961 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80095a:	40                   	inc    %eax
  80095b:	8a 10                	mov    (%eax),%dl
  80095d:	84 d2                	test   %dl,%dl
  80095f:	75 f5                	jne    800956 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	57                   	push   %edi
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
  800969:	8b 7d 08             	mov    0x8(%ebp),%edi
  80096c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80096f:	85 c9                	test   %ecx,%ecx
  800971:	74 37                	je     8009aa <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800973:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800979:	75 29                	jne    8009a4 <memset+0x41>
  80097b:	f6 c1 03             	test   $0x3,%cl
  80097e:	75 24                	jne    8009a4 <memset+0x41>
		c &= 0xFF;
  800980:	31 d2                	xor    %edx,%edx
  800982:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800985:	89 d3                	mov    %edx,%ebx
  800987:	c1 e3 08             	shl    $0x8,%ebx
  80098a:	89 d6                	mov    %edx,%esi
  80098c:	c1 e6 18             	shl    $0x18,%esi
  80098f:	89 d0                	mov    %edx,%eax
  800991:	c1 e0 10             	shl    $0x10,%eax
  800994:	09 f0                	or     %esi,%eax
  800996:	09 c2                	or     %eax,%edx
  800998:	89 d0                	mov    %edx,%eax
  80099a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80099c:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80099f:	fc                   	cld    
  8009a0:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a2:	eb 06                	jmp    8009aa <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a7:	fc                   	cld    
  8009a8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009aa:	89 f8                	mov    %edi,%eax
  8009ac:	5b                   	pop    %ebx
  8009ad:	5e                   	pop    %esi
  8009ae:	5f                   	pop    %edi
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    

008009b1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	57                   	push   %edi
  8009b5:	56                   	push   %esi
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009bf:	39 c6                	cmp    %eax,%esi
  8009c1:	73 33                	jae    8009f6 <memmove+0x45>
  8009c3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c6:	39 d0                	cmp    %edx,%eax
  8009c8:	73 2c                	jae    8009f6 <memmove+0x45>
		s += n;
		d += n;
  8009ca:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009cd:	89 d6                	mov    %edx,%esi
  8009cf:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d7:	75 13                	jne    8009ec <memmove+0x3b>
  8009d9:	f6 c1 03             	test   $0x3,%cl
  8009dc:	75 0e                	jne    8009ec <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009de:	83 ef 04             	sub    $0x4,%edi
  8009e1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009e7:	fd                   	std    
  8009e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ea:	eb 07                	jmp    8009f3 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ec:	4f                   	dec    %edi
  8009ed:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009f0:	fd                   	std    
  8009f1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f3:	fc                   	cld    
  8009f4:	eb 1d                	jmp    800a13 <memmove+0x62>
  8009f6:	89 f2                	mov    %esi,%edx
  8009f8:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fa:	f6 c2 03             	test   $0x3,%dl
  8009fd:	75 0f                	jne    800a0e <memmove+0x5d>
  8009ff:	f6 c1 03             	test   $0x3,%cl
  800a02:	75 0a                	jne    800a0e <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a04:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a07:	89 c7                	mov    %eax,%edi
  800a09:	fc                   	cld    
  800a0a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0c:	eb 05                	jmp    800a13 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a0e:	89 c7                	mov    %eax,%edi
  800a10:	fc                   	cld    
  800a11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a13:	5e                   	pop    %esi
  800a14:	5f                   	pop    %edi
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a1d:	8b 45 10             	mov    0x10(%ebp),%eax
  800a20:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a27:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	89 04 24             	mov    %eax,(%esp)
  800a31:	e8 7b ff ff ff       	call   8009b1 <memmove>
}
  800a36:	c9                   	leave  
  800a37:	c3                   	ret    

00800a38 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	56                   	push   %esi
  800a3c:	53                   	push   %ebx
  800a3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a43:	89 d6                	mov    %edx,%esi
  800a45:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a48:	eb 19                	jmp    800a63 <memcmp+0x2b>
		if (*s1 != *s2)
  800a4a:	8a 02                	mov    (%edx),%al
  800a4c:	8a 19                	mov    (%ecx),%bl
  800a4e:	38 d8                	cmp    %bl,%al
  800a50:	74 0f                	je     800a61 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800a52:	25 ff 00 00 00       	and    $0xff,%eax
  800a57:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800a5d:	29 d8                	sub    %ebx,%eax
  800a5f:	eb 0b                	jmp    800a6c <memcmp+0x34>
		s1++, s2++;
  800a61:	42                   	inc    %edx
  800a62:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a63:	39 f2                	cmp    %esi,%edx
  800a65:	75 e3                	jne    800a4a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6c:	5b                   	pop    %ebx
  800a6d:	5e                   	pop    %esi
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a79:	89 c2                	mov    %eax,%edx
  800a7b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a7e:	eb 05                	jmp    800a85 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a80:	38 08                	cmp    %cl,(%eax)
  800a82:	74 05                	je     800a89 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a84:	40                   	inc    %eax
  800a85:	39 d0                	cmp    %edx,%eax
  800a87:	72 f7                	jb     800a80 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
  800a91:	8b 55 08             	mov    0x8(%ebp),%edx
  800a94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a97:	eb 01                	jmp    800a9a <strtol+0xf>
		s++;
  800a99:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9a:	8a 02                	mov    (%edx),%al
  800a9c:	3c 09                	cmp    $0x9,%al
  800a9e:	74 f9                	je     800a99 <strtol+0xe>
  800aa0:	3c 20                	cmp    $0x20,%al
  800aa2:	74 f5                	je     800a99 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aa4:	3c 2b                	cmp    $0x2b,%al
  800aa6:	75 08                	jne    800ab0 <strtol+0x25>
		s++;
  800aa8:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa9:	bf 00 00 00 00       	mov    $0x0,%edi
  800aae:	eb 10                	jmp    800ac0 <strtol+0x35>
  800ab0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ab5:	3c 2d                	cmp    $0x2d,%al
  800ab7:	75 07                	jne    800ac0 <strtol+0x35>
		s++, neg = 1;
  800ab9:	8d 52 01             	lea    0x1(%edx),%edx
  800abc:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ac6:	75 15                	jne    800add <strtol+0x52>
  800ac8:	80 3a 30             	cmpb   $0x30,(%edx)
  800acb:	75 10                	jne    800add <strtol+0x52>
  800acd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ad1:	75 0a                	jne    800add <strtol+0x52>
		s += 2, base = 16;
  800ad3:	83 c2 02             	add    $0x2,%edx
  800ad6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800adb:	eb 0e                	jmp    800aeb <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800add:	85 db                	test   %ebx,%ebx
  800adf:	75 0a                	jne    800aeb <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ae1:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ae6:	75 03                	jne    800aeb <strtol+0x60>
		s++, base = 8;
  800ae8:	42                   	inc    %edx
  800ae9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800aeb:	b8 00 00 00 00       	mov    $0x0,%eax
  800af0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af3:	8a 0a                	mov    (%edx),%cl
  800af5:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800af8:	89 f3                	mov    %esi,%ebx
  800afa:	80 fb 09             	cmp    $0x9,%bl
  800afd:	77 08                	ja     800b07 <strtol+0x7c>
			dig = *s - '0';
  800aff:	0f be c9             	movsbl %cl,%ecx
  800b02:	83 e9 30             	sub    $0x30,%ecx
  800b05:	eb 22                	jmp    800b29 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800b07:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b0a:	89 f3                	mov    %esi,%ebx
  800b0c:	80 fb 19             	cmp    $0x19,%bl
  800b0f:	77 08                	ja     800b19 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800b11:	0f be c9             	movsbl %cl,%ecx
  800b14:	83 e9 57             	sub    $0x57,%ecx
  800b17:	eb 10                	jmp    800b29 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800b19:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b1c:	89 f3                	mov    %esi,%ebx
  800b1e:	80 fb 19             	cmp    $0x19,%bl
  800b21:	77 14                	ja     800b37 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b23:	0f be c9             	movsbl %cl,%ecx
  800b26:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b29:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b2c:	7d 0d                	jge    800b3b <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b2e:	42                   	inc    %edx
  800b2f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b33:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b35:	eb bc                	jmp    800af3 <strtol+0x68>
  800b37:	89 c1                	mov    %eax,%ecx
  800b39:	eb 02                	jmp    800b3d <strtol+0xb2>
  800b3b:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b3d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b41:	74 05                	je     800b48 <strtol+0xbd>
		*endptr = (char *) s;
  800b43:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b46:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b48:	85 ff                	test   %edi,%edi
  800b4a:	74 04                	je     800b50 <strtol+0xc5>
  800b4c:	89 c8                	mov    %ecx,%eax
  800b4e:	f7 d8                	neg    %eax
}
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    
  800b55:	66 90                	xchg   %ax,%ax
  800b57:	66 90                	xchg   %ax,%ax
  800b59:	66 90                	xchg   %ax,%ax
  800b5b:	66 90                	xchg   %ax,%ax
  800b5d:	66 90                	xchg   %ax,%ax
  800b5f:	90                   	nop

00800b60 <__udivdi3>:
  800b60:	55                   	push   %ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	83 ec 0c             	sub    $0xc,%esp
  800b66:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800b6a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800b6e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800b72:	8b 44 24 28          	mov    0x28(%esp),%eax
  800b76:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b7a:	89 ea                	mov    %ebp,%edx
  800b7c:	89 0c 24             	mov    %ecx,(%esp)
  800b7f:	85 c0                	test   %eax,%eax
  800b81:	75 2d                	jne    800bb0 <__udivdi3+0x50>
  800b83:	39 e9                	cmp    %ebp,%ecx
  800b85:	77 61                	ja     800be8 <__udivdi3+0x88>
  800b87:	89 ce                	mov    %ecx,%esi
  800b89:	85 c9                	test   %ecx,%ecx
  800b8b:	75 0b                	jne    800b98 <__udivdi3+0x38>
  800b8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b92:	31 d2                	xor    %edx,%edx
  800b94:	f7 f1                	div    %ecx
  800b96:	89 c6                	mov    %eax,%esi
  800b98:	31 d2                	xor    %edx,%edx
  800b9a:	89 e8                	mov    %ebp,%eax
  800b9c:	f7 f6                	div    %esi
  800b9e:	89 c5                	mov    %eax,%ebp
  800ba0:	89 f8                	mov    %edi,%eax
  800ba2:	f7 f6                	div    %esi
  800ba4:	89 ea                	mov    %ebp,%edx
  800ba6:	83 c4 0c             	add    $0xc,%esp
  800ba9:	5e                   	pop    %esi
  800baa:	5f                   	pop    %edi
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    
  800bad:	8d 76 00             	lea    0x0(%esi),%esi
  800bb0:	39 e8                	cmp    %ebp,%eax
  800bb2:	77 24                	ja     800bd8 <__udivdi3+0x78>
  800bb4:	0f bd e8             	bsr    %eax,%ebp
  800bb7:	83 f5 1f             	xor    $0x1f,%ebp
  800bba:	75 3c                	jne    800bf8 <__udivdi3+0x98>
  800bbc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bc0:	39 34 24             	cmp    %esi,(%esp)
  800bc3:	0f 86 9f 00 00 00    	jbe    800c68 <__udivdi3+0x108>
  800bc9:	39 d0                	cmp    %edx,%eax
  800bcb:	0f 82 97 00 00 00    	jb     800c68 <__udivdi3+0x108>
  800bd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800bd8:	31 d2                	xor    %edx,%edx
  800bda:	31 c0                	xor    %eax,%eax
  800bdc:	83 c4 0c             	add    $0xc,%esp
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    
  800be3:	90                   	nop
  800be4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800be8:	89 f8                	mov    %edi,%eax
  800bea:	f7 f1                	div    %ecx
  800bec:	31 d2                	xor    %edx,%edx
  800bee:	83 c4 0c             	add    $0xc,%esp
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    
  800bf5:	8d 76 00             	lea    0x0(%esi),%esi
  800bf8:	89 e9                	mov    %ebp,%ecx
  800bfa:	8b 3c 24             	mov    (%esp),%edi
  800bfd:	d3 e0                	shl    %cl,%eax
  800bff:	89 c6                	mov    %eax,%esi
  800c01:	b8 20 00 00 00       	mov    $0x20,%eax
  800c06:	29 e8                	sub    %ebp,%eax
  800c08:	88 c1                	mov    %al,%cl
  800c0a:	d3 ef                	shr    %cl,%edi
  800c0c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c10:	89 e9                	mov    %ebp,%ecx
  800c12:	8b 3c 24             	mov    (%esp),%edi
  800c15:	09 74 24 08          	or     %esi,0x8(%esp)
  800c19:	d3 e7                	shl    %cl,%edi
  800c1b:	89 d6                	mov    %edx,%esi
  800c1d:	88 c1                	mov    %al,%cl
  800c1f:	d3 ee                	shr    %cl,%esi
  800c21:	89 e9                	mov    %ebp,%ecx
  800c23:	89 3c 24             	mov    %edi,(%esp)
  800c26:	d3 e2                	shl    %cl,%edx
  800c28:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c2c:	88 c1                	mov    %al,%cl
  800c2e:	d3 ef                	shr    %cl,%edi
  800c30:	09 d7                	or     %edx,%edi
  800c32:	89 f2                	mov    %esi,%edx
  800c34:	89 f8                	mov    %edi,%eax
  800c36:	f7 74 24 08          	divl   0x8(%esp)
  800c3a:	89 d6                	mov    %edx,%esi
  800c3c:	89 c7                	mov    %eax,%edi
  800c3e:	f7 24 24             	mull   (%esp)
  800c41:	89 14 24             	mov    %edx,(%esp)
  800c44:	39 d6                	cmp    %edx,%esi
  800c46:	72 30                	jb     800c78 <__udivdi3+0x118>
  800c48:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c4c:	89 e9                	mov    %ebp,%ecx
  800c4e:	d3 e2                	shl    %cl,%edx
  800c50:	39 c2                	cmp    %eax,%edx
  800c52:	73 05                	jae    800c59 <__udivdi3+0xf9>
  800c54:	3b 34 24             	cmp    (%esp),%esi
  800c57:	74 1f                	je     800c78 <__udivdi3+0x118>
  800c59:	89 f8                	mov    %edi,%eax
  800c5b:	31 d2                	xor    %edx,%edx
  800c5d:	e9 7a ff ff ff       	jmp    800bdc <__udivdi3+0x7c>
  800c62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c68:	31 d2                	xor    %edx,%edx
  800c6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6f:	e9 68 ff ff ff       	jmp    800bdc <__udivdi3+0x7c>
  800c74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c78:	8d 47 ff             	lea    -0x1(%edi),%eax
  800c7b:	31 d2                	xor    %edx,%edx
  800c7d:	83 c4 0c             	add    $0xc,%esp
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    
  800c84:	66 90                	xchg   %ax,%ax
  800c86:	66 90                	xchg   %ax,%ax
  800c88:	66 90                	xchg   %ax,%ax
  800c8a:	66 90                	xchg   %ax,%ax
  800c8c:	66 90                	xchg   %ax,%ax
  800c8e:	66 90                	xchg   %ax,%ax

00800c90 <__umoddi3>:
  800c90:	55                   	push   %ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	83 ec 14             	sub    $0x14,%esp
  800c96:	8b 44 24 28          	mov    0x28(%esp),%eax
  800c9a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800c9e:	89 c7                	mov    %eax,%edi
  800ca0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800ca8:	8b 44 24 30          	mov    0x30(%esp),%eax
  800cac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800cb0:	89 34 24             	mov    %esi,(%esp)
  800cb3:	89 c2                	mov    %eax,%edx
  800cb5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cb9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	75 17                	jne    800cd8 <__umoddi3+0x48>
  800cc1:	39 fe                	cmp    %edi,%esi
  800cc3:	76 4b                	jbe    800d10 <__umoddi3+0x80>
  800cc5:	89 c8                	mov    %ecx,%eax
  800cc7:	89 fa                	mov    %edi,%edx
  800cc9:	f7 f6                	div    %esi
  800ccb:	89 d0                	mov    %edx,%eax
  800ccd:	31 d2                	xor    %edx,%edx
  800ccf:	83 c4 14             	add    $0x14,%esp
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    
  800cd6:	66 90                	xchg   %ax,%ax
  800cd8:	39 f8                	cmp    %edi,%eax
  800cda:	77 54                	ja     800d30 <__umoddi3+0xa0>
  800cdc:	0f bd e8             	bsr    %eax,%ebp
  800cdf:	83 f5 1f             	xor    $0x1f,%ebp
  800ce2:	75 5c                	jne    800d40 <__umoddi3+0xb0>
  800ce4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ce8:	39 3c 24             	cmp    %edi,(%esp)
  800ceb:	0f 87 f7 00 00 00    	ja     800de8 <__umoddi3+0x158>
  800cf1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cf5:	29 f1                	sub    %esi,%ecx
  800cf7:	19 c7                	sbb    %eax,%edi
  800cf9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cfd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d01:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d05:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d09:	83 c4 14             	add    $0x14,%esp
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    
  800d10:	89 f5                	mov    %esi,%ebp
  800d12:	85 f6                	test   %esi,%esi
  800d14:	75 0b                	jne    800d21 <__umoddi3+0x91>
  800d16:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1b:	31 d2                	xor    %edx,%edx
  800d1d:	f7 f6                	div    %esi
  800d1f:	89 c5                	mov    %eax,%ebp
  800d21:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d25:	31 d2                	xor    %edx,%edx
  800d27:	f7 f5                	div    %ebp
  800d29:	89 c8                	mov    %ecx,%eax
  800d2b:	f7 f5                	div    %ebp
  800d2d:	eb 9c                	jmp    800ccb <__umoddi3+0x3b>
  800d2f:	90                   	nop
  800d30:	89 c8                	mov    %ecx,%eax
  800d32:	89 fa                	mov    %edi,%edx
  800d34:	83 c4 14             	add    $0x14,%esp
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    
  800d3b:	90                   	nop
  800d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d40:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800d47:	00 
  800d48:	8b 34 24             	mov    (%esp),%esi
  800d4b:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d4f:	89 e9                	mov    %ebp,%ecx
  800d51:	29 e8                	sub    %ebp,%eax
  800d53:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d57:	89 f0                	mov    %esi,%eax
  800d59:	d3 e2                	shl    %cl,%edx
  800d5b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800d5f:	d3 e8                	shr    %cl,%eax
  800d61:	89 04 24             	mov    %eax,(%esp)
  800d64:	89 e9                	mov    %ebp,%ecx
  800d66:	89 f0                	mov    %esi,%eax
  800d68:	09 14 24             	or     %edx,(%esp)
  800d6b:	d3 e0                	shl    %cl,%eax
  800d6d:	89 fa                	mov    %edi,%edx
  800d6f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800d73:	d3 ea                	shr    %cl,%edx
  800d75:	89 e9                	mov    %ebp,%ecx
  800d77:	89 c6                	mov    %eax,%esi
  800d79:	d3 e7                	shl    %cl,%edi
  800d7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d7f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800d83:	8b 44 24 10          	mov    0x10(%esp),%eax
  800d87:	d3 e8                	shr    %cl,%eax
  800d89:	09 f8                	or     %edi,%eax
  800d8b:	89 e9                	mov    %ebp,%ecx
  800d8d:	8b 7c 24 10          	mov    0x10(%esp),%edi
  800d91:	d3 e7                	shl    %cl,%edi
  800d93:	f7 34 24             	divl   (%esp)
  800d96:	89 d1                	mov    %edx,%ecx
  800d98:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d9c:	f7 e6                	mul    %esi
  800d9e:	89 c7                	mov    %eax,%edi
  800da0:	89 d6                	mov    %edx,%esi
  800da2:	39 d1                	cmp    %edx,%ecx
  800da4:	72 2e                	jb     800dd4 <__umoddi3+0x144>
  800da6:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800daa:	72 24                	jb     800dd0 <__umoddi3+0x140>
  800dac:	89 ca                	mov    %ecx,%edx
  800dae:	89 e9                	mov    %ebp,%ecx
  800db0:	8b 44 24 08          	mov    0x8(%esp),%eax
  800db4:	29 f8                	sub    %edi,%eax
  800db6:	19 f2                	sbb    %esi,%edx
  800db8:	d3 e8                	shr    %cl,%eax
  800dba:	89 d6                	mov    %edx,%esi
  800dbc:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800dc0:	d3 e6                	shl    %cl,%esi
  800dc2:	89 e9                	mov    %ebp,%ecx
  800dc4:	09 f0                	or     %esi,%eax
  800dc6:	d3 ea                	shr    %cl,%edx
  800dc8:	83 c4 14             	add    $0x14,%esp
  800dcb:	5e                   	pop    %esi
  800dcc:	5f                   	pop    %edi
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    
  800dcf:	90                   	nop
  800dd0:	39 d1                	cmp    %edx,%ecx
  800dd2:	75 d8                	jne    800dac <__umoddi3+0x11c>
  800dd4:	89 d6                	mov    %edx,%esi
  800dd6:	89 c7                	mov    %eax,%edi
  800dd8:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  800ddc:	1b 34 24             	sbb    (%esp),%esi
  800ddf:	eb cb                	jmp    800dac <__umoddi3+0x11c>
  800de1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800de8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  800dec:	0f 82 ff fe ff ff    	jb     800cf1 <__umoddi3+0x61>
  800df2:	e9 0a ff ff ff       	jmp    800d01 <__umoddi3+0x71>
