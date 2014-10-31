
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800041:	00 
  800042:	a1 00 20 80 00       	mov    0x802000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 51 00 00 00       	call   8000a0 <sys_cputs>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	66 90                	xchg   %ax,%ax
  800053:	90                   	nop

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	8b 45 08             	mov    0x8(%ebp),%eax
  80005d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800060:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800067:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006a:	85 c0                	test   %eax,%eax
  80006c:	7e 08                	jle    800076 <libmain+0x22>
		binaryname = argv[0];
  80006e:	8b 0a                	mov    (%edx),%ecx
  800070:	89 0d 04 20 80 00    	mov    %ecx,0x802004

	// call user main routine
	umain(argc, argv);
  800076:	89 54 24 04          	mov    %edx,0x4(%esp)
  80007a:	89 04 24             	mov    %eax,(%esp)
  80007d:	e8 b2 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800082:	e8 05 00 00 00       	call   80008c <exit>
}
  800087:	c9                   	leave  
  800088:	c3                   	ret    
  800089:	66 90                	xchg   %ax,%ax
  80008b:	90                   	nop

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800092:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800099:	e8 3f 00 00 00       	call   8000dd <sys_env_destroy>
}
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b1:	89 c3                	mov    %eax,%ebx
  8000b3:	89 c7                	mov    %eax,%edi
  8000b5:	89 c6                	mov    %eax,%esi
  8000b7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <sys_cgetc>:

int
sys_cgetc(void)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	57                   	push   %edi
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ce:	89 d1                	mov    %edx,%ecx
  8000d0:	89 d3                	mov    %edx,%ebx
  8000d2:	89 d7                	mov    %edx,%edi
  8000d4:	89 d6                	mov    %edx,%esi
  8000d6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d8:	5b                   	pop    %ebx
  8000d9:	5e                   	pop    %esi
  8000da:	5f                   	pop    %edi
  8000db:	5d                   	pop    %ebp
  8000dc:	c3                   	ret    

008000dd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dd:	55                   	push   %ebp
  8000de:	89 e5                	mov    %esp,%ebp
  8000e0:	57                   	push   %edi
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000eb:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f3:	89 cb                	mov    %ecx,%ebx
  8000f5:	89 cf                	mov    %ecx,%edi
  8000f7:	89 ce                	mov    %ecx,%esi
  8000f9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fb:	85 c0                	test   %eax,%eax
  8000fd:	7e 28                	jle    800127 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800103:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80010a:	00 
  80010b:	c7 44 24 08 38 0e 80 	movl   $0x800e38,0x8(%esp)
  800112:	00 
  800113:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80011a:	00 
  80011b:	c7 04 24 55 0e 80 00 	movl   $0x800e55,(%esp)
  800122:	e8 29 00 00 00       	call   800150 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800127:	83 c4 2c             	add    $0x2c,%esp
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	57                   	push   %edi
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800135:	ba 00 00 00 00       	mov    $0x0,%edx
  80013a:	b8 02 00 00 00       	mov    $0x2,%eax
  80013f:	89 d1                	mov    %edx,%ecx
  800141:	89 d3                	mov    %edx,%ebx
  800143:	89 d7                	mov    %edx,%edi
  800145:	89 d6                	mov    %edx,%esi
  800147:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800149:	5b                   	pop    %ebx
  80014a:	5e                   	pop    %esi
  80014b:	5f                   	pop    %edi
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    
  80014e:	66 90                	xchg   %ax,%ax

00800150 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
  800155:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800158:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015b:	8b 35 04 20 80 00    	mov    0x802004,%esi
  800161:	e8 c9 ff ff ff       	call   80012f <sys_getenvid>
  800166:	8b 55 0c             	mov    0xc(%ebp),%edx
  800169:	89 54 24 10          	mov    %edx,0x10(%esp)
  80016d:	8b 55 08             	mov    0x8(%ebp),%edx
  800170:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800174:	89 74 24 08          	mov    %esi,0x8(%esp)
  800178:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017c:	c7 04 24 64 0e 80 00 	movl   $0x800e64,(%esp)
  800183:	e8 c2 00 00 00       	call   80024a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800188:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80018c:	8b 45 10             	mov    0x10(%ebp),%eax
  80018f:	89 04 24             	mov    %eax,(%esp)
  800192:	e8 52 00 00 00       	call   8001e9 <vcprintf>
	cprintf("\n");
  800197:	c7 04 24 2c 0e 80 00 	movl   $0x800e2c,(%esp)
  80019e:	e8 a7 00 00 00       	call   80024a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a3:	cc                   	int3   
  8001a4:	eb fd                	jmp    8001a3 <_panic+0x53>
  8001a6:	66 90                	xchg   %ax,%ax

008001a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 14             	sub    $0x14,%esp
  8001af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b2:	8b 13                	mov    (%ebx),%edx
  8001b4:	8d 42 01             	lea    0x1(%edx),%eax
  8001b7:	89 03                	mov    %eax,(%ebx)
  8001b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001bc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001c0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c5:	75 19                	jne    8001e0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001c7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ce:	00 
  8001cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d2:	89 04 24             	mov    %eax,(%esp)
  8001d5:	e8 c6 fe ff ff       	call   8000a0 <sys_cputs>
		b->idx = 0;
  8001da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e0:	ff 43 04             	incl   0x4(%ebx)
}
  8001e3:	83 c4 14             	add    $0x14,%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5d                   	pop    %ebp
  8001e8:	c3                   	ret    

008001e9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f9:	00 00 00 
	b.cnt = 0;
  8001fc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800203:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800206:	8b 45 0c             	mov    0xc(%ebp),%eax
  800209:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80020d:	8b 45 08             	mov    0x8(%ebp),%eax
  800210:	89 44 24 08          	mov    %eax,0x8(%esp)
  800214:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021e:	c7 04 24 a8 01 80 00 	movl   $0x8001a8,(%esp)
  800225:	e8 a9 01 00 00       	call   8003d3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800230:	89 44 24 04          	mov    %eax,0x4(%esp)
  800234:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023a:	89 04 24             	mov    %eax,(%esp)
  80023d:	e8 5e fe ff ff       	call   8000a0 <sys_cputs>

	return b.cnt;
}
  800242:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800248:	c9                   	leave  
  800249:	c3                   	ret    

0080024a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800250:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800253:	89 44 24 04          	mov    %eax,0x4(%esp)
  800257:	8b 45 08             	mov    0x8(%ebp),%eax
  80025a:	89 04 24             	mov    %eax,(%esp)
  80025d:	e8 87 ff ff ff       	call   8001e9 <vcprintf>
	va_end(ap);

	return cnt;
}
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	57                   	push   %edi
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	83 ec 3c             	sub    $0x3c,%esp
  80026d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800270:	89 d7                	mov    %edx,%edi
  800272:	8b 45 08             	mov    0x8(%ebp),%eax
  800275:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800278:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027b:	89 c1                	mov    %eax,%ecx
  80027d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800280:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800283:	8b 45 10             	mov    0x10(%ebp),%eax
  800286:	ba 00 00 00 00       	mov    $0x0,%edx
  80028b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80028e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800291:	39 ca                	cmp    %ecx,%edx
  800293:	72 08                	jb     80029d <printnum+0x39>
  800295:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800298:	39 45 10             	cmp    %eax,0x10(%ebp)
  80029b:	77 6a                	ja     800307 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80029d:	8b 45 18             	mov    0x18(%ebp),%eax
  8002a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a4:	4e                   	dec    %esi
  8002a5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b0:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002b4:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002b8:	89 c3                	mov    %eax,%ebx
  8002ba:	89 d6                	mov    %edx,%esi
  8002bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002cd:	89 04 24             	mov    %eax,(%esp)
  8002d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d7:	e8 94 08 00 00       	call   800b70 <__udivdi3>
  8002dc:	89 d9                	mov    %ebx,%ecx
  8002de:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002e6:	89 04 24             	mov    %eax,(%esp)
  8002e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ed:	89 fa                	mov    %edi,%edx
  8002ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f2:	e8 6d ff ff ff       	call   800264 <printnum>
  8002f7:	eb 19                	jmp    800312 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002fd:	8b 45 18             	mov    0x18(%ebp),%eax
  800300:	89 04 24             	mov    %eax,(%esp)
  800303:	ff d3                	call   *%ebx
  800305:	eb 03                	jmp    80030a <printnum+0xa6>
  800307:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80030a:	4e                   	dec    %esi
  80030b:	85 f6                	test   %esi,%esi
  80030d:	7f ea                	jg     8002f9 <printnum+0x95>
  80030f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800312:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800316:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80031a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80031d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800320:	89 44 24 08          	mov    %eax,0x8(%esp)
  800324:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800328:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032b:	89 04 24             	mov    %eax,(%esp)
  80032e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800331:	89 44 24 04          	mov    %eax,0x4(%esp)
  800335:	e8 66 09 00 00       	call   800ca0 <__umoddi3>
  80033a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80033e:	0f be 80 88 0e 80 00 	movsbl 0x800e88(%eax),%eax
  800345:	89 04 24             	mov    %eax,(%esp)
  800348:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80034b:	ff d0                	call   *%eax
}
  80034d:	83 c4 3c             	add    $0x3c,%esp
  800350:	5b                   	pop    %ebx
  800351:	5e                   	pop    %esi
  800352:	5f                   	pop    %edi
  800353:	5d                   	pop    %ebp
  800354:	c3                   	ret    

00800355 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800358:	83 fa 01             	cmp    $0x1,%edx
  80035b:	7e 0e                	jle    80036b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80035d:	8b 10                	mov    (%eax),%edx
  80035f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800362:	89 08                	mov    %ecx,(%eax)
  800364:	8b 02                	mov    (%edx),%eax
  800366:	8b 52 04             	mov    0x4(%edx),%edx
  800369:	eb 22                	jmp    80038d <getuint+0x38>
	else if (lflag)
  80036b:	85 d2                	test   %edx,%edx
  80036d:	74 10                	je     80037f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80036f:	8b 10                	mov    (%eax),%edx
  800371:	8d 4a 04             	lea    0x4(%edx),%ecx
  800374:	89 08                	mov    %ecx,(%eax)
  800376:	8b 02                	mov    (%edx),%eax
  800378:	ba 00 00 00 00       	mov    $0x0,%edx
  80037d:	eb 0e                	jmp    80038d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80037f:	8b 10                	mov    (%eax),%edx
  800381:	8d 4a 04             	lea    0x4(%edx),%ecx
  800384:	89 08                	mov    %ecx,(%eax)
  800386:	8b 02                	mov    (%edx),%eax
  800388:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    

0080038f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
  800392:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800395:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800398:	8b 10                	mov    (%eax),%edx
  80039a:	3b 50 04             	cmp    0x4(%eax),%edx
  80039d:	73 0a                	jae    8003a9 <sprintputch+0x1a>
		*b->buf++ = ch;
  80039f:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003a2:	89 08                	mov    %ecx,(%eax)
  8003a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a7:	88 02                	mov    %al,(%edx)
}
  8003a9:	5d                   	pop    %ebp
  8003aa:	c3                   	ret    

008003ab <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003b1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8003bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c9:	89 04 24             	mov    %eax,(%esp)
  8003cc:	e8 02 00 00 00       	call   8003d3 <vprintfmt>
	va_end(ap);
}
  8003d1:	c9                   	leave  
  8003d2:	c3                   	ret    

008003d3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	57                   	push   %edi
  8003d7:	56                   	push   %esi
  8003d8:	53                   	push   %ebx
  8003d9:	83 ec 3c             	sub    $0x3c,%esp
  8003dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003df:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003e2:	eb 14                	jmp    8003f8 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003e4:	85 c0                	test   %eax,%eax
  8003e6:	0f 84 8a 03 00 00    	je     800776 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  8003ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f0:	89 04 24             	mov    %eax,(%esp)
  8003f3:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f6:	89 f3                	mov    %esi,%ebx
  8003f8:	8d 73 01             	lea    0x1(%ebx),%esi
  8003fb:	31 c0                	xor    %eax,%eax
  8003fd:	8a 03                	mov    (%ebx),%al
  8003ff:	83 f8 25             	cmp    $0x25,%eax
  800402:	75 e0                	jne    8003e4 <vprintfmt+0x11>
  800404:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800408:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80040f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800416:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80041d:	ba 00 00 00 00       	mov    $0x0,%edx
  800422:	eb 1d                	jmp    800441 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800424:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800426:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80042a:	eb 15                	jmp    800441 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80042e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800432:	eb 0d                	jmp    800441 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800434:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800437:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80043a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8d 5e 01             	lea    0x1(%esi),%ebx
  800444:	31 c0                	xor    %eax,%eax
  800446:	8a 06                	mov    (%esi),%al
  800448:	8a 0e                	mov    (%esi),%cl
  80044a:	83 e9 23             	sub    $0x23,%ecx
  80044d:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800450:	80 f9 55             	cmp    $0x55,%cl
  800453:	0f 87 ff 02 00 00    	ja     800758 <vprintfmt+0x385>
  800459:	31 c9                	xor    %ecx,%ecx
  80045b:	8a 4d e0             	mov    -0x20(%ebp),%cl
  80045e:	ff 24 8d 20 0f 80 00 	jmp    *0x800f20(,%ecx,4)
  800465:	89 de                	mov    %ebx,%esi
  800467:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80046c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80046f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800473:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800476:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800479:	83 fb 09             	cmp    $0x9,%ebx
  80047c:	77 2f                	ja     8004ad <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80047e:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80047f:	eb eb                	jmp    80046c <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800481:	8b 45 14             	mov    0x14(%ebp),%eax
  800484:	8d 48 04             	lea    0x4(%eax),%ecx
  800487:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80048a:	8b 00                	mov    (%eax),%eax
  80048c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800491:	eb 1d                	jmp    8004b0 <vprintfmt+0xdd>
  800493:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800496:	f7 d0                	not    %eax
  800498:	c1 f8 1f             	sar    $0x1f,%eax
  80049b:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	89 de                	mov    %ebx,%esi
  8004a0:	eb 9f                	jmp    800441 <vprintfmt+0x6e>
  8004a2:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004a4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004ab:	eb 94                	jmp    800441 <vprintfmt+0x6e>
  8004ad:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004b0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004b4:	79 8b                	jns    800441 <vprintfmt+0x6e>
  8004b6:	e9 79 ff ff ff       	jmp    800434 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004bb:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bc:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004be:	eb 81                	jmp    800441 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8d 50 04             	lea    0x4(%eax),%edx
  8004c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004cd:	8b 00                	mov    (%eax),%eax
  8004cf:	89 04 24             	mov    %eax,(%esp)
  8004d2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004d5:	e9 1e ff ff ff       	jmp    8003f8 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004da:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dd:	8d 50 04             	lea    0x4(%eax),%edx
  8004e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e3:	8b 00                	mov    (%eax),%eax
  8004e5:	89 c2                	mov    %eax,%edx
  8004e7:	c1 fa 1f             	sar    $0x1f,%edx
  8004ea:	31 d0                	xor    %edx,%eax
  8004ec:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ee:	83 f8 07             	cmp    $0x7,%eax
  8004f1:	7f 0b                	jg     8004fe <vprintfmt+0x12b>
  8004f3:	8b 14 85 80 10 80 00 	mov    0x801080(,%eax,4),%edx
  8004fa:	85 d2                	test   %edx,%edx
  8004fc:	75 20                	jne    80051e <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  8004fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800502:	c7 44 24 08 a0 0e 80 	movl   $0x800ea0,0x8(%esp)
  800509:	00 
  80050a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80050e:	8b 45 08             	mov    0x8(%ebp),%eax
  800511:	89 04 24             	mov    %eax,(%esp)
  800514:	e8 92 fe ff ff       	call   8003ab <printfmt>
  800519:	e9 da fe ff ff       	jmp    8003f8 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80051e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800522:	c7 44 24 08 a9 0e 80 	movl   $0x800ea9,0x8(%esp)
  800529:	00 
  80052a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052e:	8b 45 08             	mov    0x8(%ebp),%eax
  800531:	89 04 24             	mov    %eax,(%esp)
  800534:	e8 72 fe ff ff       	call   8003ab <printfmt>
  800539:	e9 ba fe ff ff       	jmp    8003f8 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800541:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800544:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8d 50 04             	lea    0x4(%eax),%edx
  80054d:	89 55 14             	mov    %edx,0x14(%ebp)
  800550:	8b 30                	mov    (%eax),%esi
  800552:	85 f6                	test   %esi,%esi
  800554:	75 05                	jne    80055b <vprintfmt+0x188>
				p = "(null)";
  800556:	be 99 0e 80 00       	mov    $0x800e99,%esi
			if (width > 0 && padc != '-')
  80055b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80055f:	0f 84 8c 00 00 00    	je     8005f1 <vprintfmt+0x21e>
  800565:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800569:	0f 8e 8a 00 00 00    	jle    8005f9 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  80056f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800573:	89 34 24             	mov    %esi,(%esp)
  800576:	e8 9b 02 00 00       	call   800816 <strnlen>
  80057b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80057e:	29 c1                	sub    %eax,%ecx
  800580:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800583:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800587:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80058a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  80058d:	8b 75 08             	mov    0x8(%ebp),%esi
  800590:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800593:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800595:	eb 0d                	jmp    8005a4 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800597:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80059b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80059e:	89 04 24             	mov    %eax,(%esp)
  8005a1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a3:	4b                   	dec    %ebx
  8005a4:	85 db                	test   %ebx,%ebx
  8005a6:	7f ef                	jg     800597 <vprintfmt+0x1c4>
  8005a8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ae:	89 c8                	mov    %ecx,%eax
  8005b0:	f7 d0                	not    %eax
  8005b2:	c1 f8 1f             	sar    $0x1f,%eax
  8005b5:	21 c8                	and    %ecx,%eax
  8005b7:	29 c1                	sub    %eax,%ecx
  8005b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005bc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005bf:	eb 3e                	jmp    8005ff <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005c1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c5:	74 1b                	je     8005e2 <vprintfmt+0x20f>
  8005c7:	0f be d2             	movsbl %dl,%edx
  8005ca:	83 ea 20             	sub    $0x20,%edx
  8005cd:	83 fa 5e             	cmp    $0x5e,%edx
  8005d0:	76 10                	jbe    8005e2 <vprintfmt+0x20f>
					putch('?', putdat);
  8005d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005dd:	ff 55 08             	call   *0x8(%ebp)
  8005e0:	eb 0a                	jmp    8005ec <vprintfmt+0x219>
				else
					putch(ch, putdat);
  8005e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e6:	89 04 24             	mov    %eax,(%esp)
  8005e9:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ec:	ff 4d dc             	decl   -0x24(%ebp)
  8005ef:	eb 0e                	jmp    8005ff <vprintfmt+0x22c>
  8005f1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005f4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005f7:	eb 06                	jmp    8005ff <vprintfmt+0x22c>
  8005f9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005fc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005ff:	46                   	inc    %esi
  800600:	8a 56 ff             	mov    -0x1(%esi),%dl
  800603:	0f be c2             	movsbl %dl,%eax
  800606:	85 c0                	test   %eax,%eax
  800608:	74 1f                	je     800629 <vprintfmt+0x256>
  80060a:	85 db                	test   %ebx,%ebx
  80060c:	78 b3                	js     8005c1 <vprintfmt+0x1ee>
  80060e:	4b                   	dec    %ebx
  80060f:	79 b0                	jns    8005c1 <vprintfmt+0x1ee>
  800611:	8b 75 08             	mov    0x8(%ebp),%esi
  800614:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800617:	eb 16                	jmp    80062f <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800619:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800624:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800626:	4b                   	dec    %ebx
  800627:	eb 06                	jmp    80062f <vprintfmt+0x25c>
  800629:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80062c:	8b 75 08             	mov    0x8(%ebp),%esi
  80062f:	85 db                	test   %ebx,%ebx
  800631:	7f e6                	jg     800619 <vprintfmt+0x246>
  800633:	89 75 08             	mov    %esi,0x8(%ebp)
  800636:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800639:	e9 ba fd ff ff       	jmp    8003f8 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80063e:	83 fa 01             	cmp    $0x1,%edx
  800641:	7e 16                	jle    800659 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8d 50 08             	lea    0x8(%eax),%edx
  800649:	89 55 14             	mov    %edx,0x14(%ebp)
  80064c:	8b 50 04             	mov    0x4(%eax),%edx
  80064f:	8b 00                	mov    (%eax),%eax
  800651:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800654:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800657:	eb 32                	jmp    80068b <vprintfmt+0x2b8>
	else if (lflag)
  800659:	85 d2                	test   %edx,%edx
  80065b:	74 18                	je     800675 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8d 50 04             	lea    0x4(%eax),%edx
  800663:	89 55 14             	mov    %edx,0x14(%ebp)
  800666:	8b 30                	mov    (%eax),%esi
  800668:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80066b:	89 f0                	mov    %esi,%eax
  80066d:	c1 f8 1f             	sar    $0x1f,%eax
  800670:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800673:	eb 16                	jmp    80068b <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8d 50 04             	lea    0x4(%eax),%edx
  80067b:	89 55 14             	mov    %edx,0x14(%ebp)
  80067e:	8b 30                	mov    (%eax),%esi
  800680:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800683:	89 f0                	mov    %esi,%eax
  800685:	c1 f8 1f             	sar    $0x1f,%eax
  800688:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80068b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80068e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800691:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800696:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80069a:	0f 89 80 00 00 00    	jns    800720 <vprintfmt+0x34d>
				putch('-', putdat);
  8006a0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006ab:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006b1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006b4:	f7 d8                	neg    %eax
  8006b6:	83 d2 00             	adc    $0x0,%edx
  8006b9:	f7 da                	neg    %edx
			}
			base = 10;
  8006bb:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006c0:	eb 5e                	jmp    800720 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c5:	e8 8b fc ff ff       	call   800355 <getuint>
			base = 10;
  8006ca:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006cf:	eb 4f                	jmp    800720 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  8006d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d4:	e8 7c fc ff ff       	call   800355 <getuint>
			base = 8;
  8006d9:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006de:	eb 40                	jmp    800720 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  8006e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006e4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006eb:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006f2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006f9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8d 50 04             	lea    0x4(%eax),%edx
  800702:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800705:	8b 00                	mov    (%eax),%eax
  800707:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80070c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800711:	eb 0d                	jmp    800720 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800713:	8d 45 14             	lea    0x14(%ebp),%eax
  800716:	e8 3a fc ff ff       	call   800355 <getuint>
			base = 16;
  80071b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800720:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800724:	89 74 24 10          	mov    %esi,0x10(%esp)
  800728:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80072b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80072f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800733:	89 04 24             	mov    %eax,(%esp)
  800736:	89 54 24 04          	mov    %edx,0x4(%esp)
  80073a:	89 fa                	mov    %edi,%edx
  80073c:	8b 45 08             	mov    0x8(%ebp),%eax
  80073f:	e8 20 fb ff ff       	call   800264 <printnum>
			break;
  800744:	e9 af fc ff ff       	jmp    8003f8 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800749:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80074d:	89 04 24             	mov    %eax,(%esp)
  800750:	ff 55 08             	call   *0x8(%ebp)
			break;
  800753:	e9 a0 fc ff ff       	jmp    8003f8 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800758:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80075c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800763:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800766:	89 f3                	mov    %esi,%ebx
  800768:	eb 01                	jmp    80076b <vprintfmt+0x398>
  80076a:	4b                   	dec    %ebx
  80076b:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80076f:	75 f9                	jne    80076a <vprintfmt+0x397>
  800771:	e9 82 fc ff ff       	jmp    8003f8 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800776:	83 c4 3c             	add    $0x3c,%esp
  800779:	5b                   	pop    %ebx
  80077a:	5e                   	pop    %esi
  80077b:	5f                   	pop    %edi
  80077c:	5d                   	pop    %ebp
  80077d:	c3                   	ret    

0080077e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	83 ec 28             	sub    $0x28,%esp
  800784:	8b 45 08             	mov    0x8(%ebp),%eax
  800787:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80078a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80078d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800791:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800794:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80079b:	85 c0                	test   %eax,%eax
  80079d:	74 30                	je     8007cf <vsnprintf+0x51>
  80079f:	85 d2                	test   %edx,%edx
  8007a1:	7e 2c                	jle    8007cf <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b8:	c7 04 24 8f 03 80 00 	movl   $0x80038f,(%esp)
  8007bf:	e8 0f fc ff ff       	call   8003d3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007cd:	eb 05                	jmp    8007d4 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007d4:	c9                   	leave  
  8007d5:	c3                   	ret    

008007d6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007dc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	89 04 24             	mov    %eax,(%esp)
  8007f7:	e8 82 ff ff ff       	call   80077e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    
  8007fe:	66 90                	xchg   %ax,%ax

00800800 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800806:	b8 00 00 00 00       	mov    $0x0,%eax
  80080b:	eb 01                	jmp    80080e <strlen+0xe>
		n++;
  80080d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800812:	75 f9                	jne    80080d <strlen+0xd>
		n++;
	return n;
}
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081f:	b8 00 00 00 00       	mov    $0x0,%eax
  800824:	eb 01                	jmp    800827 <strnlen+0x11>
		n++;
  800826:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800827:	39 d0                	cmp    %edx,%eax
  800829:	74 06                	je     800831 <strnlen+0x1b>
  80082b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80082f:	75 f5                	jne    800826 <strnlen+0x10>
		n++;
	return n;
}
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80083d:	89 c2                	mov    %eax,%edx
  80083f:	42                   	inc    %edx
  800840:	41                   	inc    %ecx
  800841:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800844:	88 5a ff             	mov    %bl,-0x1(%edx)
  800847:	84 db                	test   %bl,%bl
  800849:	75 f4                	jne    80083f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80084b:	5b                   	pop    %ebx
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	53                   	push   %ebx
  800852:	83 ec 08             	sub    $0x8,%esp
  800855:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800858:	89 1c 24             	mov    %ebx,(%esp)
  80085b:	e8 a0 ff ff ff       	call   800800 <strlen>
	strcpy(dst + len, src);
  800860:	8b 55 0c             	mov    0xc(%ebp),%edx
  800863:	89 54 24 04          	mov    %edx,0x4(%esp)
  800867:	01 d8                	add    %ebx,%eax
  800869:	89 04 24             	mov    %eax,(%esp)
  80086c:	e8 c2 ff ff ff       	call   800833 <strcpy>
	return dst;
}
  800871:	89 d8                	mov    %ebx,%eax
  800873:	83 c4 08             	add    $0x8,%esp
  800876:	5b                   	pop    %ebx
  800877:	5d                   	pop    %ebp
  800878:	c3                   	ret    

00800879 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	56                   	push   %esi
  80087d:	53                   	push   %ebx
  80087e:	8b 75 08             	mov    0x8(%ebp),%esi
  800881:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800884:	89 f3                	mov    %esi,%ebx
  800886:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800889:	89 f2                	mov    %esi,%edx
  80088b:	eb 0c                	jmp    800899 <strncpy+0x20>
		*dst++ = *src;
  80088d:	42                   	inc    %edx
  80088e:	8a 01                	mov    (%ecx),%al
  800890:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800893:	80 39 01             	cmpb   $0x1,(%ecx)
  800896:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800899:	39 da                	cmp    %ebx,%edx
  80089b:	75 f0                	jne    80088d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80089d:	89 f0                	mov    %esi,%eax
  80089f:	5b                   	pop    %ebx
  8008a0:	5e                   	pop    %esi
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	56                   	push   %esi
  8008a7:	53                   	push   %ebx
  8008a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008b1:	89 f0                	mov    %esi,%eax
  8008b3:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b7:	85 c9                	test   %ecx,%ecx
  8008b9:	75 07                	jne    8008c2 <strlcpy+0x1f>
  8008bb:	eb 18                	jmp    8008d5 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008bd:	40                   	inc    %eax
  8008be:	42                   	inc    %edx
  8008bf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c2:	39 d8                	cmp    %ebx,%eax
  8008c4:	74 0a                	je     8008d0 <strlcpy+0x2d>
  8008c6:	8a 0a                	mov    (%edx),%cl
  8008c8:	84 c9                	test   %cl,%cl
  8008ca:	75 f1                	jne    8008bd <strlcpy+0x1a>
  8008cc:	89 c2                	mov    %eax,%edx
  8008ce:	eb 02                	jmp    8008d2 <strlcpy+0x2f>
  8008d0:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008d2:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008d5:	29 f0                	sub    %esi,%eax
}
  8008d7:	5b                   	pop    %ebx
  8008d8:	5e                   	pop    %esi
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e4:	eb 02                	jmp    8008e8 <strcmp+0xd>
		p++, q++;
  8008e6:	41                   	inc    %ecx
  8008e7:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008e8:	8a 01                	mov    (%ecx),%al
  8008ea:	84 c0                	test   %al,%al
  8008ec:	74 04                	je     8008f2 <strcmp+0x17>
  8008ee:	3a 02                	cmp    (%edx),%al
  8008f0:	74 f4                	je     8008e6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f2:	25 ff 00 00 00       	and    $0xff,%eax
  8008f7:	8a 0a                	mov    (%edx),%cl
  8008f9:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8008ff:	29 c8                	sub    %ecx,%eax
}
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	53                   	push   %ebx
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090d:	89 c3                	mov    %eax,%ebx
  80090f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800912:	eb 02                	jmp    800916 <strncmp+0x13>
		n--, p++, q++;
  800914:	40                   	inc    %eax
  800915:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800916:	39 d8                	cmp    %ebx,%eax
  800918:	74 20                	je     80093a <strncmp+0x37>
  80091a:	8a 08                	mov    (%eax),%cl
  80091c:	84 c9                	test   %cl,%cl
  80091e:	74 04                	je     800924 <strncmp+0x21>
  800920:	3a 0a                	cmp    (%edx),%cl
  800922:	74 f0                	je     800914 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800924:	8a 18                	mov    (%eax),%bl
  800926:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80092c:	89 d8                	mov    %ebx,%eax
  80092e:	8a 1a                	mov    (%edx),%bl
  800930:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800936:	29 d8                	sub    %ebx,%eax
  800938:	eb 05                	jmp    80093f <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80093a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80093f:	5b                   	pop    %ebx
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80094b:	eb 05                	jmp    800952 <strchr+0x10>
		if (*s == c)
  80094d:	38 ca                	cmp    %cl,%dl
  80094f:	74 0c                	je     80095d <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800951:	40                   	inc    %eax
  800952:	8a 10                	mov    (%eax),%dl
  800954:	84 d2                	test   %dl,%dl
  800956:	75 f5                	jne    80094d <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800958:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800968:	eb 05                	jmp    80096f <strfind+0x10>
		if (*s == c)
  80096a:	38 ca                	cmp    %cl,%dl
  80096c:	74 07                	je     800975 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80096e:	40                   	inc    %eax
  80096f:	8a 10                	mov    (%eax),%dl
  800971:	84 d2                	test   %dl,%dl
  800973:	75 f5                	jne    80096a <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	57                   	push   %edi
  80097b:	56                   	push   %esi
  80097c:	53                   	push   %ebx
  80097d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800980:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800983:	85 c9                	test   %ecx,%ecx
  800985:	74 37                	je     8009be <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800987:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098d:	75 29                	jne    8009b8 <memset+0x41>
  80098f:	f6 c1 03             	test   $0x3,%cl
  800992:	75 24                	jne    8009b8 <memset+0x41>
		c &= 0xFF;
  800994:	31 d2                	xor    %edx,%edx
  800996:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800999:	89 d3                	mov    %edx,%ebx
  80099b:	c1 e3 08             	shl    $0x8,%ebx
  80099e:	89 d6                	mov    %edx,%esi
  8009a0:	c1 e6 18             	shl    $0x18,%esi
  8009a3:	89 d0                	mov    %edx,%eax
  8009a5:	c1 e0 10             	shl    $0x10,%eax
  8009a8:	09 f0                	or     %esi,%eax
  8009aa:	09 c2                	or     %eax,%edx
  8009ac:	89 d0                	mov    %edx,%eax
  8009ae:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009b0:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009b3:	fc                   	cld    
  8009b4:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b6:	eb 06                	jmp    8009be <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bb:	fc                   	cld    
  8009bc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009be:	89 f8                	mov    %edi,%eax
  8009c0:	5b                   	pop    %ebx
  8009c1:	5e                   	pop    %esi
  8009c2:	5f                   	pop    %edi
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	57                   	push   %edi
  8009c9:	56                   	push   %esi
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d3:	39 c6                	cmp    %eax,%esi
  8009d5:	73 33                	jae    800a0a <memmove+0x45>
  8009d7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009da:	39 d0                	cmp    %edx,%eax
  8009dc:	73 2c                	jae    800a0a <memmove+0x45>
		s += n;
		d += n;
  8009de:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009e1:	89 d6                	mov    %edx,%esi
  8009e3:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009eb:	75 13                	jne    800a00 <memmove+0x3b>
  8009ed:	f6 c1 03             	test   $0x3,%cl
  8009f0:	75 0e                	jne    800a00 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009f2:	83 ef 04             	sub    $0x4,%edi
  8009f5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009fb:	fd                   	std    
  8009fc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fe:	eb 07                	jmp    800a07 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a00:	4f                   	dec    %edi
  800a01:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a04:	fd                   	std    
  800a05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a07:	fc                   	cld    
  800a08:	eb 1d                	jmp    800a27 <memmove+0x62>
  800a0a:	89 f2                	mov    %esi,%edx
  800a0c:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0e:	f6 c2 03             	test   $0x3,%dl
  800a11:	75 0f                	jne    800a22 <memmove+0x5d>
  800a13:	f6 c1 03             	test   $0x3,%cl
  800a16:	75 0a                	jne    800a22 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a18:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a1b:	89 c7                	mov    %eax,%edi
  800a1d:	fc                   	cld    
  800a1e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a20:	eb 05                	jmp    800a27 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a22:	89 c7                	mov    %eax,%edi
  800a24:	fc                   	cld    
  800a25:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a27:	5e                   	pop    %esi
  800a28:	5f                   	pop    %edi
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a31:	8b 45 10             	mov    0x10(%ebp),%eax
  800a34:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	89 04 24             	mov    %eax,(%esp)
  800a45:	e8 7b ff ff ff       	call   8009c5 <memmove>
}
  800a4a:	c9                   	leave  
  800a4b:	c3                   	ret    

00800a4c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	56                   	push   %esi
  800a50:	53                   	push   %ebx
  800a51:	8b 55 08             	mov    0x8(%ebp),%edx
  800a54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a57:	89 d6                	mov    %edx,%esi
  800a59:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5c:	eb 19                	jmp    800a77 <memcmp+0x2b>
		if (*s1 != *s2)
  800a5e:	8a 02                	mov    (%edx),%al
  800a60:	8a 19                	mov    (%ecx),%bl
  800a62:	38 d8                	cmp    %bl,%al
  800a64:	74 0f                	je     800a75 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800a66:	25 ff 00 00 00       	and    $0xff,%eax
  800a6b:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800a71:	29 d8                	sub    %ebx,%eax
  800a73:	eb 0b                	jmp    800a80 <memcmp+0x34>
		s1++, s2++;
  800a75:	42                   	inc    %edx
  800a76:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a77:	39 f2                	cmp    %esi,%edx
  800a79:	75 e3                	jne    800a5e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a8d:	89 c2                	mov    %eax,%edx
  800a8f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a92:	eb 05                	jmp    800a99 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a94:	38 08                	cmp    %cl,(%eax)
  800a96:	74 05                	je     800a9d <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a98:	40                   	inc    %eax
  800a99:	39 d0                	cmp    %edx,%eax
  800a9b:	72 f7                	jb     800a94 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	57                   	push   %edi
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aab:	eb 01                	jmp    800aae <strtol+0xf>
		s++;
  800aad:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aae:	8a 02                	mov    (%edx),%al
  800ab0:	3c 09                	cmp    $0x9,%al
  800ab2:	74 f9                	je     800aad <strtol+0xe>
  800ab4:	3c 20                	cmp    $0x20,%al
  800ab6:	74 f5                	je     800aad <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ab8:	3c 2b                	cmp    $0x2b,%al
  800aba:	75 08                	jne    800ac4 <strtol+0x25>
		s++;
  800abc:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800abd:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac2:	eb 10                	jmp    800ad4 <strtol+0x35>
  800ac4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ac9:	3c 2d                	cmp    $0x2d,%al
  800acb:	75 07                	jne    800ad4 <strtol+0x35>
		s++, neg = 1;
  800acd:	8d 52 01             	lea    0x1(%edx),%edx
  800ad0:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ada:	75 15                	jne    800af1 <strtol+0x52>
  800adc:	80 3a 30             	cmpb   $0x30,(%edx)
  800adf:	75 10                	jne    800af1 <strtol+0x52>
  800ae1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ae5:	75 0a                	jne    800af1 <strtol+0x52>
		s += 2, base = 16;
  800ae7:	83 c2 02             	add    $0x2,%edx
  800aea:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aef:	eb 0e                	jmp    800aff <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800af1:	85 db                	test   %ebx,%ebx
  800af3:	75 0a                	jne    800aff <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800af5:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af7:	80 3a 30             	cmpb   $0x30,(%edx)
  800afa:	75 03                	jne    800aff <strtol+0x60>
		s++, base = 8;
  800afc:	42                   	inc    %edx
  800afd:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800aff:	b8 00 00 00 00       	mov    $0x0,%eax
  800b04:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b07:	8a 0a                	mov    (%edx),%cl
  800b09:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b0c:	89 f3                	mov    %esi,%ebx
  800b0e:	80 fb 09             	cmp    $0x9,%bl
  800b11:	77 08                	ja     800b1b <strtol+0x7c>
			dig = *s - '0';
  800b13:	0f be c9             	movsbl %cl,%ecx
  800b16:	83 e9 30             	sub    $0x30,%ecx
  800b19:	eb 22                	jmp    800b3d <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800b1b:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b1e:	89 f3                	mov    %esi,%ebx
  800b20:	80 fb 19             	cmp    $0x19,%bl
  800b23:	77 08                	ja     800b2d <strtol+0x8e>
			dig = *s - 'a' + 10;
  800b25:	0f be c9             	movsbl %cl,%ecx
  800b28:	83 e9 57             	sub    $0x57,%ecx
  800b2b:	eb 10                	jmp    800b3d <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800b2d:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b30:	89 f3                	mov    %esi,%ebx
  800b32:	80 fb 19             	cmp    $0x19,%bl
  800b35:	77 14                	ja     800b4b <strtol+0xac>
			dig = *s - 'A' + 10;
  800b37:	0f be c9             	movsbl %cl,%ecx
  800b3a:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b3d:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b40:	7d 0d                	jge    800b4f <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b42:	42                   	inc    %edx
  800b43:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b47:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b49:	eb bc                	jmp    800b07 <strtol+0x68>
  800b4b:	89 c1                	mov    %eax,%ecx
  800b4d:	eb 02                	jmp    800b51 <strtol+0xb2>
  800b4f:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b51:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b55:	74 05                	je     800b5c <strtol+0xbd>
		*endptr = (char *) s;
  800b57:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b5a:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b5c:	85 ff                	test   %edi,%edi
  800b5e:	74 04                	je     800b64 <strtol+0xc5>
  800b60:	89 c8                	mov    %ecx,%eax
  800b62:	f7 d8                	neg    %eax
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    
  800b69:	66 90                	xchg   %ax,%ax
  800b6b:	66 90                	xchg   %ax,%ax
  800b6d:	66 90                	xchg   %ax,%ax
  800b6f:	90                   	nop

00800b70 <__udivdi3>:
  800b70:	55                   	push   %ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	83 ec 0c             	sub    $0xc,%esp
  800b76:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800b7a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800b7e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800b82:	8b 44 24 28          	mov    0x28(%esp),%eax
  800b86:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b8a:	89 ea                	mov    %ebp,%edx
  800b8c:	89 0c 24             	mov    %ecx,(%esp)
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	75 2d                	jne    800bc0 <__udivdi3+0x50>
  800b93:	39 e9                	cmp    %ebp,%ecx
  800b95:	77 61                	ja     800bf8 <__udivdi3+0x88>
  800b97:	89 ce                	mov    %ecx,%esi
  800b99:	85 c9                	test   %ecx,%ecx
  800b9b:	75 0b                	jne    800ba8 <__udivdi3+0x38>
  800b9d:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba2:	31 d2                	xor    %edx,%edx
  800ba4:	f7 f1                	div    %ecx
  800ba6:	89 c6                	mov    %eax,%esi
  800ba8:	31 d2                	xor    %edx,%edx
  800baa:	89 e8                	mov    %ebp,%eax
  800bac:	f7 f6                	div    %esi
  800bae:	89 c5                	mov    %eax,%ebp
  800bb0:	89 f8                	mov    %edi,%eax
  800bb2:	f7 f6                	div    %esi
  800bb4:	89 ea                	mov    %ebp,%edx
  800bb6:	83 c4 0c             	add    $0xc,%esp
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    
  800bbd:	8d 76 00             	lea    0x0(%esi),%esi
  800bc0:	39 e8                	cmp    %ebp,%eax
  800bc2:	77 24                	ja     800be8 <__udivdi3+0x78>
  800bc4:	0f bd e8             	bsr    %eax,%ebp
  800bc7:	83 f5 1f             	xor    $0x1f,%ebp
  800bca:	75 3c                	jne    800c08 <__udivdi3+0x98>
  800bcc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bd0:	39 34 24             	cmp    %esi,(%esp)
  800bd3:	0f 86 9f 00 00 00    	jbe    800c78 <__udivdi3+0x108>
  800bd9:	39 d0                	cmp    %edx,%eax
  800bdb:	0f 82 97 00 00 00    	jb     800c78 <__udivdi3+0x108>
  800be1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800be8:	31 d2                	xor    %edx,%edx
  800bea:	31 c0                	xor    %eax,%eax
  800bec:	83 c4 0c             	add    $0xc,%esp
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    
  800bf3:	90                   	nop
  800bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800bf8:	89 f8                	mov    %edi,%eax
  800bfa:	f7 f1                	div    %ecx
  800bfc:	31 d2                	xor    %edx,%edx
  800bfe:	83 c4 0c             	add    $0xc,%esp
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    
  800c05:	8d 76 00             	lea    0x0(%esi),%esi
  800c08:	89 e9                	mov    %ebp,%ecx
  800c0a:	8b 3c 24             	mov    (%esp),%edi
  800c0d:	d3 e0                	shl    %cl,%eax
  800c0f:	89 c6                	mov    %eax,%esi
  800c11:	b8 20 00 00 00       	mov    $0x20,%eax
  800c16:	29 e8                	sub    %ebp,%eax
  800c18:	88 c1                	mov    %al,%cl
  800c1a:	d3 ef                	shr    %cl,%edi
  800c1c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c20:	89 e9                	mov    %ebp,%ecx
  800c22:	8b 3c 24             	mov    (%esp),%edi
  800c25:	09 74 24 08          	or     %esi,0x8(%esp)
  800c29:	d3 e7                	shl    %cl,%edi
  800c2b:	89 d6                	mov    %edx,%esi
  800c2d:	88 c1                	mov    %al,%cl
  800c2f:	d3 ee                	shr    %cl,%esi
  800c31:	89 e9                	mov    %ebp,%ecx
  800c33:	89 3c 24             	mov    %edi,(%esp)
  800c36:	d3 e2                	shl    %cl,%edx
  800c38:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c3c:	88 c1                	mov    %al,%cl
  800c3e:	d3 ef                	shr    %cl,%edi
  800c40:	09 d7                	or     %edx,%edi
  800c42:	89 f2                	mov    %esi,%edx
  800c44:	89 f8                	mov    %edi,%eax
  800c46:	f7 74 24 08          	divl   0x8(%esp)
  800c4a:	89 d6                	mov    %edx,%esi
  800c4c:	89 c7                	mov    %eax,%edi
  800c4e:	f7 24 24             	mull   (%esp)
  800c51:	89 14 24             	mov    %edx,(%esp)
  800c54:	39 d6                	cmp    %edx,%esi
  800c56:	72 30                	jb     800c88 <__udivdi3+0x118>
  800c58:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c5c:	89 e9                	mov    %ebp,%ecx
  800c5e:	d3 e2                	shl    %cl,%edx
  800c60:	39 c2                	cmp    %eax,%edx
  800c62:	73 05                	jae    800c69 <__udivdi3+0xf9>
  800c64:	3b 34 24             	cmp    (%esp),%esi
  800c67:	74 1f                	je     800c88 <__udivdi3+0x118>
  800c69:	89 f8                	mov    %edi,%eax
  800c6b:	31 d2                	xor    %edx,%edx
  800c6d:	e9 7a ff ff ff       	jmp    800bec <__udivdi3+0x7c>
  800c72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c78:	31 d2                	xor    %edx,%edx
  800c7a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c7f:	e9 68 ff ff ff       	jmp    800bec <__udivdi3+0x7c>
  800c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c88:	8d 47 ff             	lea    -0x1(%edi),%eax
  800c8b:	31 d2                	xor    %edx,%edx
  800c8d:	83 c4 0c             	add    $0xc,%esp
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    
  800c94:	66 90                	xchg   %ax,%ax
  800c96:	66 90                	xchg   %ax,%ax
  800c98:	66 90                	xchg   %ax,%ax
  800c9a:	66 90                	xchg   %ax,%ax
  800c9c:	66 90                	xchg   %ax,%ax
  800c9e:	66 90                	xchg   %ax,%ax

00800ca0 <__umoddi3>:
  800ca0:	55                   	push   %ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	83 ec 14             	sub    $0x14,%esp
  800ca6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800caa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800cae:	89 c7                	mov    %eax,%edi
  800cb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800cb8:	8b 44 24 30          	mov    0x30(%esp),%eax
  800cbc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800cc0:	89 34 24             	mov    %esi,(%esp)
  800cc3:	89 c2                	mov    %eax,%edx
  800cc5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cc9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	75 17                	jne    800ce8 <__umoddi3+0x48>
  800cd1:	39 fe                	cmp    %edi,%esi
  800cd3:	76 4b                	jbe    800d20 <__umoddi3+0x80>
  800cd5:	89 c8                	mov    %ecx,%eax
  800cd7:	89 fa                	mov    %edi,%edx
  800cd9:	f7 f6                	div    %esi
  800cdb:	89 d0                	mov    %edx,%eax
  800cdd:	31 d2                	xor    %edx,%edx
  800cdf:	83 c4 14             	add    $0x14,%esp
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    
  800ce6:	66 90                	xchg   %ax,%ax
  800ce8:	39 f8                	cmp    %edi,%eax
  800cea:	77 54                	ja     800d40 <__umoddi3+0xa0>
  800cec:	0f bd e8             	bsr    %eax,%ebp
  800cef:	83 f5 1f             	xor    $0x1f,%ebp
  800cf2:	75 5c                	jne    800d50 <__umoddi3+0xb0>
  800cf4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cf8:	39 3c 24             	cmp    %edi,(%esp)
  800cfb:	0f 87 f7 00 00 00    	ja     800df8 <__umoddi3+0x158>
  800d01:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d05:	29 f1                	sub    %esi,%ecx
  800d07:	19 c7                	sbb    %eax,%edi
  800d09:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d0d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d11:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d15:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d19:	83 c4 14             	add    $0x14,%esp
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    
  800d20:	89 f5                	mov    %esi,%ebp
  800d22:	85 f6                	test   %esi,%esi
  800d24:	75 0b                	jne    800d31 <__umoddi3+0x91>
  800d26:	b8 01 00 00 00       	mov    $0x1,%eax
  800d2b:	31 d2                	xor    %edx,%edx
  800d2d:	f7 f6                	div    %esi
  800d2f:	89 c5                	mov    %eax,%ebp
  800d31:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d35:	31 d2                	xor    %edx,%edx
  800d37:	f7 f5                	div    %ebp
  800d39:	89 c8                	mov    %ecx,%eax
  800d3b:	f7 f5                	div    %ebp
  800d3d:	eb 9c                	jmp    800cdb <__umoddi3+0x3b>
  800d3f:	90                   	nop
  800d40:	89 c8                	mov    %ecx,%eax
  800d42:	89 fa                	mov    %edi,%edx
  800d44:	83 c4 14             	add    $0x14,%esp
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    
  800d4b:	90                   	nop
  800d4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d50:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800d57:	00 
  800d58:	8b 34 24             	mov    (%esp),%esi
  800d5b:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d5f:	89 e9                	mov    %ebp,%ecx
  800d61:	29 e8                	sub    %ebp,%eax
  800d63:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d67:	89 f0                	mov    %esi,%eax
  800d69:	d3 e2                	shl    %cl,%edx
  800d6b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800d6f:	d3 e8                	shr    %cl,%eax
  800d71:	89 04 24             	mov    %eax,(%esp)
  800d74:	89 e9                	mov    %ebp,%ecx
  800d76:	89 f0                	mov    %esi,%eax
  800d78:	09 14 24             	or     %edx,(%esp)
  800d7b:	d3 e0                	shl    %cl,%eax
  800d7d:	89 fa                	mov    %edi,%edx
  800d7f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800d83:	d3 ea                	shr    %cl,%edx
  800d85:	89 e9                	mov    %ebp,%ecx
  800d87:	89 c6                	mov    %eax,%esi
  800d89:	d3 e7                	shl    %cl,%edi
  800d8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d8f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800d93:	8b 44 24 10          	mov    0x10(%esp),%eax
  800d97:	d3 e8                	shr    %cl,%eax
  800d99:	09 f8                	or     %edi,%eax
  800d9b:	89 e9                	mov    %ebp,%ecx
  800d9d:	8b 7c 24 10          	mov    0x10(%esp),%edi
  800da1:	d3 e7                	shl    %cl,%edi
  800da3:	f7 34 24             	divl   (%esp)
  800da6:	89 d1                	mov    %edx,%ecx
  800da8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dac:	f7 e6                	mul    %esi
  800dae:	89 c7                	mov    %eax,%edi
  800db0:	89 d6                	mov    %edx,%esi
  800db2:	39 d1                	cmp    %edx,%ecx
  800db4:	72 2e                	jb     800de4 <__umoddi3+0x144>
  800db6:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800dba:	72 24                	jb     800de0 <__umoddi3+0x140>
  800dbc:	89 ca                	mov    %ecx,%edx
  800dbe:	89 e9                	mov    %ebp,%ecx
  800dc0:	8b 44 24 08          	mov    0x8(%esp),%eax
  800dc4:	29 f8                	sub    %edi,%eax
  800dc6:	19 f2                	sbb    %esi,%edx
  800dc8:	d3 e8                	shr    %cl,%eax
  800dca:	89 d6                	mov    %edx,%esi
  800dcc:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800dd0:	d3 e6                	shl    %cl,%esi
  800dd2:	89 e9                	mov    %ebp,%ecx
  800dd4:	09 f0                	or     %esi,%eax
  800dd6:	d3 ea                	shr    %cl,%edx
  800dd8:	83 c4 14             	add    $0x14,%esp
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    
  800ddf:	90                   	nop
  800de0:	39 d1                	cmp    %edx,%ecx
  800de2:	75 d8                	jne    800dbc <__umoddi3+0x11c>
  800de4:	89 d6                	mov    %edx,%esi
  800de6:	89 c7                	mov    %eax,%edi
  800de8:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  800dec:	1b 34 24             	sbb    (%esp),%esi
  800def:	eb cb                	jmp    800dbc <__umoddi3+0x11c>
  800df1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800df8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  800dfc:	0f 82 ff fe ff ff    	jb     800d01 <__umoddi3+0x61>
  800e02:	e9 0a ff ff ff       	jmp    800d11 <__umoddi3+0x71>
