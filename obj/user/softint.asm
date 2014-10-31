
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	5d                   	pop    %ebp
  80003a:	c3                   	ret    
  80003b:	90                   	nop

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	83 ec 18             	sub    $0x18,%esp
  800042:	8b 45 08             	mov    0x8(%ebp),%eax
  800045:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800048:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80004f:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800052:	85 c0                	test   %eax,%eax
  800054:	7e 08                	jle    80005e <libmain+0x22>
		binaryname = argv[0];
  800056:	8b 0a                	mov    (%edx),%ecx
  800058:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80005e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800062:	89 04 24             	mov    %eax,(%esp)
  800065:	e8 ca ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80006a:	e8 05 00 00 00       	call   800074 <exit>
}
  80006f:	c9                   	leave  
  800070:	c3                   	ret    
  800071:	66 90                	xchg   %ax,%ax
  800073:	90                   	nop

00800074 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800074:	55                   	push   %ebp
  800075:	89 e5                	mov    %esp,%ebp
  800077:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80007a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800081:	e8 3f 00 00 00       	call   8000c5 <sys_env_destroy>
}
  800086:	c9                   	leave  
  800087:	c3                   	ret    

00800088 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	57                   	push   %edi
  80008c:	56                   	push   %esi
  80008d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80008e:	b8 00 00 00 00       	mov    $0x0,%eax
  800093:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800096:	8b 55 08             	mov    0x8(%ebp),%edx
  800099:	89 c3                	mov    %eax,%ebx
  80009b:	89 c7                	mov    %eax,%edi
  80009d:	89 c6                	mov    %eax,%esi
  80009f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000a1:	5b                   	pop    %ebx
  8000a2:	5e                   	pop    %esi
  8000a3:	5f                   	pop    %edi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000b6:	89 d1                	mov    %edx,%ecx
  8000b8:	89 d3                	mov    %edx,%ebx
  8000ba:	89 d7                	mov    %edx,%edi
  8000bc:	89 d6                	mov    %edx,%esi
  8000be:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
  8000cb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000d3:	b8 03 00 00 00       	mov    $0x3,%eax
  8000d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000db:	89 cb                	mov    %ecx,%ebx
  8000dd:	89 cf                	mov    %ecx,%edi
  8000df:	89 ce                	mov    %ecx,%esi
  8000e1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000e3:	85 c0                	test   %eax,%eax
  8000e5:	7e 28                	jle    80010f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000eb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8000f2:	00 
  8000f3:	c7 44 24 08 0a 0e 80 	movl   $0x800e0a,0x8(%esp)
  8000fa:	00 
  8000fb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800102:	00 
  800103:	c7 04 24 27 0e 80 00 	movl   $0x800e27,(%esp)
  80010a:	e8 29 00 00 00       	call   800138 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	83 c4 2c             	add    $0x2c,%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    
  800136:	66 90                	xchg   %ax,%ax

00800138 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
  80013d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800140:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800143:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800149:	e8 c9 ff ff ff       	call   800117 <sys_getenvid>
  80014e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800151:	89 54 24 10          	mov    %edx,0x10(%esp)
  800155:	8b 55 08             	mov    0x8(%ebp),%edx
  800158:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80015c:	89 74 24 08          	mov    %esi,0x8(%esp)
  800160:	89 44 24 04          	mov    %eax,0x4(%esp)
  800164:	c7 04 24 38 0e 80 00 	movl   $0x800e38,(%esp)
  80016b:	e8 c2 00 00 00       	call   800232 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800170:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800174:	8b 45 10             	mov    0x10(%ebp),%eax
  800177:	89 04 24             	mov    %eax,(%esp)
  80017a:	e8 52 00 00 00       	call   8001d1 <vcprintf>
	cprintf("\n");
  80017f:	c7 04 24 5c 0e 80 00 	movl   $0x800e5c,(%esp)
  800186:	e8 a7 00 00 00       	call   800232 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018b:	cc                   	int3   
  80018c:	eb fd                	jmp    80018b <_panic+0x53>
  80018e:	66 90                	xchg   %ax,%ax

00800190 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	53                   	push   %ebx
  800194:	83 ec 14             	sub    $0x14,%esp
  800197:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019a:	8b 13                	mov    (%ebx),%edx
  80019c:	8d 42 01             	lea    0x1(%edx),%eax
  80019f:	89 03                	mov    %eax,(%ebx)
  8001a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ad:	75 19                	jne    8001c8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001af:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001b6:	00 
  8001b7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ba:	89 04 24             	mov    %eax,(%esp)
  8001bd:	e8 c6 fe ff ff       	call   800088 <sys_cputs>
		b->idx = 0;
  8001c2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001c8:	ff 43 04             	incl   0x4(%ebx)
}
  8001cb:	83 c4 14             	add    $0x14,%esp
  8001ce:	5b                   	pop    %ebx
  8001cf:	5d                   	pop    %ebp
  8001d0:	c3                   	ret    

008001d1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001da:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e1:	00 00 00 
	b.cnt = 0;
  8001e4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001eb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001fc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800202:	89 44 24 04          	mov    %eax,0x4(%esp)
  800206:	c7 04 24 90 01 80 00 	movl   $0x800190,(%esp)
  80020d:	e8 a9 01 00 00       	call   8003bb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800212:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800218:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800222:	89 04 24             	mov    %eax,(%esp)
  800225:	e8 5e fe ff ff       	call   800088 <sys_cputs>

	return b.cnt;
}
  80022a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800238:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023f:	8b 45 08             	mov    0x8(%ebp),%eax
  800242:	89 04 24             	mov    %eax,(%esp)
  800245:	e8 87 ff ff ff       	call   8001d1 <vcprintf>
	va_end(ap);

	return cnt;
}
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	57                   	push   %edi
  800250:	56                   	push   %esi
  800251:	53                   	push   %ebx
  800252:	83 ec 3c             	sub    $0x3c,%esp
  800255:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800258:	89 d7                	mov    %edx,%edi
  80025a:	8b 45 08             	mov    0x8(%ebp),%eax
  80025d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800260:	8b 45 0c             	mov    0xc(%ebp),%eax
  800263:	89 c1                	mov    %eax,%ecx
  800265:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800268:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80026b:	8b 45 10             	mov    0x10(%ebp),%eax
  80026e:	ba 00 00 00 00       	mov    $0x0,%edx
  800273:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800276:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800279:	39 ca                	cmp    %ecx,%edx
  80027b:	72 08                	jb     800285 <printnum+0x39>
  80027d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800280:	39 45 10             	cmp    %eax,0x10(%ebp)
  800283:	77 6a                	ja     8002ef <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800285:	8b 45 18             	mov    0x18(%ebp),%eax
  800288:	89 44 24 10          	mov    %eax,0x10(%esp)
  80028c:	4e                   	dec    %esi
  80028d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800291:	8b 45 10             	mov    0x10(%ebp),%eax
  800294:	89 44 24 08          	mov    %eax,0x8(%esp)
  800298:	8b 44 24 08          	mov    0x8(%esp),%eax
  80029c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002a0:	89 c3                	mov    %eax,%ebx
  8002a2:	89 d6                	mov    %edx,%esi
  8002a4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002a7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ae:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b5:	89 04 24             	mov    %eax,(%esp)
  8002b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bf:	e8 9c 08 00 00       	call   800b60 <__udivdi3>
  8002c4:	89 d9                	mov    %ebx,%ecx
  8002c6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ca:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ce:	89 04 24             	mov    %eax,(%esp)
  8002d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002d5:	89 fa                	mov    %edi,%edx
  8002d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002da:	e8 6d ff ff ff       	call   80024c <printnum>
  8002df:	eb 19                	jmp    8002fa <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	ff d3                	call   *%ebx
  8002ed:	eb 03                	jmp    8002f2 <printnum+0xa6>
  8002ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f2:	4e                   	dec    %esi
  8002f3:	85 f6                	test   %esi,%esi
  8002f5:	7f ea                	jg     8002e1 <printnum+0x95>
  8002f7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002fe:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800302:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800305:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800308:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800310:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800313:	89 04 24             	mov    %eax,(%esp)
  800316:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800319:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031d:	e8 6e 09 00 00       	call   800c90 <__umoddi3>
  800322:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800326:	0f be 80 5e 0e 80 00 	movsbl 0x800e5e(%eax),%eax
  80032d:	89 04 24             	mov    %eax,(%esp)
  800330:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800333:	ff d0                	call   *%eax
}
  800335:	83 c4 3c             	add    $0x3c,%esp
  800338:	5b                   	pop    %ebx
  800339:	5e                   	pop    %esi
  80033a:	5f                   	pop    %edi
  80033b:	5d                   	pop    %ebp
  80033c:	c3                   	ret    

0080033d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800340:	83 fa 01             	cmp    $0x1,%edx
  800343:	7e 0e                	jle    800353 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800345:	8b 10                	mov    (%eax),%edx
  800347:	8d 4a 08             	lea    0x8(%edx),%ecx
  80034a:	89 08                	mov    %ecx,(%eax)
  80034c:	8b 02                	mov    (%edx),%eax
  80034e:	8b 52 04             	mov    0x4(%edx),%edx
  800351:	eb 22                	jmp    800375 <getuint+0x38>
	else if (lflag)
  800353:	85 d2                	test   %edx,%edx
  800355:	74 10                	je     800367 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800357:	8b 10                	mov    (%eax),%edx
  800359:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035c:	89 08                	mov    %ecx,(%eax)
  80035e:	8b 02                	mov    (%edx),%eax
  800360:	ba 00 00 00 00       	mov    $0x0,%edx
  800365:	eb 0e                	jmp    800375 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800367:	8b 10                	mov    (%eax),%edx
  800369:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036c:	89 08                	mov    %ecx,(%eax)
  80036e:	8b 02                	mov    (%edx),%eax
  800370:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800375:	5d                   	pop    %ebp
  800376:	c3                   	ret    

00800377 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
  80037a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037d:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800380:	8b 10                	mov    (%eax),%edx
  800382:	3b 50 04             	cmp    0x4(%eax),%edx
  800385:	73 0a                	jae    800391 <sprintputch+0x1a>
		*b->buf++ = ch;
  800387:	8d 4a 01             	lea    0x1(%edx),%ecx
  80038a:	89 08                	mov    %ecx,(%eax)
  80038c:	8b 45 08             	mov    0x8(%ebp),%eax
  80038f:	88 02                	mov    %al,(%edx)
}
  800391:	5d                   	pop    %ebp
  800392:	c3                   	ret    

00800393 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
  800396:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800399:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b1:	89 04 24             	mov    %eax,(%esp)
  8003b4:	e8 02 00 00 00       	call   8003bb <vprintfmt>
	va_end(ap);
}
  8003b9:	c9                   	leave  
  8003ba:	c3                   	ret    

008003bb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	57                   	push   %edi
  8003bf:	56                   	push   %esi
  8003c0:	53                   	push   %ebx
  8003c1:	83 ec 3c             	sub    $0x3c,%esp
  8003c4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003ca:	eb 14                	jmp    8003e0 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003cc:	85 c0                	test   %eax,%eax
  8003ce:	0f 84 8a 03 00 00    	je     80075e <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  8003d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003d8:	89 04 24             	mov    %eax,(%esp)
  8003db:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003de:	89 f3                	mov    %esi,%ebx
  8003e0:	8d 73 01             	lea    0x1(%ebx),%esi
  8003e3:	31 c0                	xor    %eax,%eax
  8003e5:	8a 03                	mov    (%ebx),%al
  8003e7:	83 f8 25             	cmp    $0x25,%eax
  8003ea:	75 e0                	jne    8003cc <vprintfmt+0x11>
  8003ec:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003f0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003f7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003fe:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800405:	ba 00 00 00 00       	mov    $0x0,%edx
  80040a:	eb 1d                	jmp    800429 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80040e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800412:	eb 15                	jmp    800429 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800416:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80041a:	eb 0d                	jmp    800429 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80041c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80041f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800422:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	8d 5e 01             	lea    0x1(%esi),%ebx
  80042c:	31 c0                	xor    %eax,%eax
  80042e:	8a 06                	mov    (%esi),%al
  800430:	8a 0e                	mov    (%esi),%cl
  800432:	83 e9 23             	sub    $0x23,%ecx
  800435:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800438:	80 f9 55             	cmp    $0x55,%cl
  80043b:	0f 87 ff 02 00 00    	ja     800740 <vprintfmt+0x385>
  800441:	31 c9                	xor    %ecx,%ecx
  800443:	8a 4d e0             	mov    -0x20(%ebp),%cl
  800446:	ff 24 8d 00 0f 80 00 	jmp    *0x800f00(,%ecx,4)
  80044d:	89 de                	mov    %ebx,%esi
  80044f:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800454:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800457:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  80045b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80045e:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800461:	83 fb 09             	cmp    $0x9,%ebx
  800464:	77 2f                	ja     800495 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800466:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800467:	eb eb                	jmp    800454 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800469:	8b 45 14             	mov    0x14(%ebp),%eax
  80046c:	8d 48 04             	lea    0x4(%eax),%ecx
  80046f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800472:	8b 00                	mov    (%eax),%eax
  800474:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800479:	eb 1d                	jmp    800498 <vprintfmt+0xdd>
  80047b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80047e:	f7 d0                	not    %eax
  800480:	c1 f8 1f             	sar    $0x1f,%eax
  800483:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	89 de                	mov    %ebx,%esi
  800488:	eb 9f                	jmp    800429 <vprintfmt+0x6e>
  80048a:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80048c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800493:	eb 94                	jmp    800429 <vprintfmt+0x6e>
  800495:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800498:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80049c:	79 8b                	jns    800429 <vprintfmt+0x6e>
  80049e:	e9 79 ff ff ff       	jmp    80041c <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a3:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a6:	eb 81                	jmp    800429 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ab:	8d 50 04             	lea    0x4(%eax),%edx
  8004ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004b5:	8b 00                	mov    (%eax),%eax
  8004b7:	89 04 24             	mov    %eax,(%esp)
  8004ba:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004bd:	e9 1e ff ff ff       	jmp    8003e0 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c5:	8d 50 04             	lea    0x4(%eax),%edx
  8004c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cb:	8b 00                	mov    (%eax),%eax
  8004cd:	89 c2                	mov    %eax,%edx
  8004cf:	c1 fa 1f             	sar    $0x1f,%edx
  8004d2:	31 d0                	xor    %edx,%eax
  8004d4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d6:	83 f8 07             	cmp    $0x7,%eax
  8004d9:	7f 0b                	jg     8004e6 <vprintfmt+0x12b>
  8004db:	8b 14 85 60 10 80 00 	mov    0x801060(,%eax,4),%edx
  8004e2:	85 d2                	test   %edx,%edx
  8004e4:	75 20                	jne    800506 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  8004e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ea:	c7 44 24 08 76 0e 80 	movl   $0x800e76,0x8(%esp)
  8004f1:	00 
  8004f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f9:	89 04 24             	mov    %eax,(%esp)
  8004fc:	e8 92 fe ff ff       	call   800393 <printfmt>
  800501:	e9 da fe ff ff       	jmp    8003e0 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800506:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80050a:	c7 44 24 08 7f 0e 80 	movl   $0x800e7f,0x8(%esp)
  800511:	00 
  800512:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800516:	8b 45 08             	mov    0x8(%ebp),%eax
  800519:	89 04 24             	mov    %eax,(%esp)
  80051c:	e8 72 fe ff ff       	call   800393 <printfmt>
  800521:	e9 ba fe ff ff       	jmp    8003e0 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800529:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80052c:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80052f:	8b 45 14             	mov    0x14(%ebp),%eax
  800532:	8d 50 04             	lea    0x4(%eax),%edx
  800535:	89 55 14             	mov    %edx,0x14(%ebp)
  800538:	8b 30                	mov    (%eax),%esi
  80053a:	85 f6                	test   %esi,%esi
  80053c:	75 05                	jne    800543 <vprintfmt+0x188>
				p = "(null)";
  80053e:	be 6f 0e 80 00       	mov    $0x800e6f,%esi
			if (width > 0 && padc != '-')
  800543:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800547:	0f 84 8c 00 00 00    	je     8005d9 <vprintfmt+0x21e>
  80054d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800551:	0f 8e 8a 00 00 00    	jle    8005e1 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  800557:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80055b:	89 34 24             	mov    %esi,(%esp)
  80055e:	e8 9b 02 00 00       	call   8007fe <strnlen>
  800563:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800566:	29 c1                	sub    %eax,%ecx
  800568:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  80056b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80056f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800572:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800575:	8b 75 08             	mov    0x8(%ebp),%esi
  800578:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80057b:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057d:	eb 0d                	jmp    80058c <vprintfmt+0x1d1>
					putch(padc, putdat);
  80057f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800583:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800586:	89 04 24             	mov    %eax,(%esp)
  800589:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058b:	4b                   	dec    %ebx
  80058c:	85 db                	test   %ebx,%ebx
  80058e:	7f ef                	jg     80057f <vprintfmt+0x1c4>
  800590:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800593:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800596:	89 c8                	mov    %ecx,%eax
  800598:	f7 d0                	not    %eax
  80059a:	c1 f8 1f             	sar    $0x1f,%eax
  80059d:	21 c8                	and    %ecx,%eax
  80059f:	29 c1                	sub    %eax,%ecx
  8005a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005a7:	eb 3e                	jmp    8005e7 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005a9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005ad:	74 1b                	je     8005ca <vprintfmt+0x20f>
  8005af:	0f be d2             	movsbl %dl,%edx
  8005b2:	83 ea 20             	sub    $0x20,%edx
  8005b5:	83 fa 5e             	cmp    $0x5e,%edx
  8005b8:	76 10                	jbe    8005ca <vprintfmt+0x20f>
					putch('?', putdat);
  8005ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005be:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005c5:	ff 55 08             	call   *0x8(%ebp)
  8005c8:	eb 0a                	jmp    8005d4 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  8005ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ce:	89 04 24             	mov    %eax,(%esp)
  8005d1:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d4:	ff 4d dc             	decl   -0x24(%ebp)
  8005d7:	eb 0e                	jmp    8005e7 <vprintfmt+0x22c>
  8005d9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005dc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005df:	eb 06                	jmp    8005e7 <vprintfmt+0x22c>
  8005e1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005e4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005e7:	46                   	inc    %esi
  8005e8:	8a 56 ff             	mov    -0x1(%esi),%dl
  8005eb:	0f be c2             	movsbl %dl,%eax
  8005ee:	85 c0                	test   %eax,%eax
  8005f0:	74 1f                	je     800611 <vprintfmt+0x256>
  8005f2:	85 db                	test   %ebx,%ebx
  8005f4:	78 b3                	js     8005a9 <vprintfmt+0x1ee>
  8005f6:	4b                   	dec    %ebx
  8005f7:	79 b0                	jns    8005a9 <vprintfmt+0x1ee>
  8005f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8005fc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005ff:	eb 16                	jmp    800617 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800601:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800605:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80060c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060e:	4b                   	dec    %ebx
  80060f:	eb 06                	jmp    800617 <vprintfmt+0x25c>
  800611:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800614:	8b 75 08             	mov    0x8(%ebp),%esi
  800617:	85 db                	test   %ebx,%ebx
  800619:	7f e6                	jg     800601 <vprintfmt+0x246>
  80061b:	89 75 08             	mov    %esi,0x8(%ebp)
  80061e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800621:	e9 ba fd ff ff       	jmp    8003e0 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800626:	83 fa 01             	cmp    $0x1,%edx
  800629:	7e 16                	jle    800641 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8d 50 08             	lea    0x8(%eax),%edx
  800631:	89 55 14             	mov    %edx,0x14(%ebp)
  800634:	8b 50 04             	mov    0x4(%eax),%edx
  800637:	8b 00                	mov    (%eax),%eax
  800639:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80063c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80063f:	eb 32                	jmp    800673 <vprintfmt+0x2b8>
	else if (lflag)
  800641:	85 d2                	test   %edx,%edx
  800643:	74 18                	je     80065d <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800645:	8b 45 14             	mov    0x14(%ebp),%eax
  800648:	8d 50 04             	lea    0x4(%eax),%edx
  80064b:	89 55 14             	mov    %edx,0x14(%ebp)
  80064e:	8b 30                	mov    (%eax),%esi
  800650:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800653:	89 f0                	mov    %esi,%eax
  800655:	c1 f8 1f             	sar    $0x1f,%eax
  800658:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80065b:	eb 16                	jmp    800673 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8d 50 04             	lea    0x4(%eax),%edx
  800663:	89 55 14             	mov    %edx,0x14(%ebp)
  800666:	8b 30                	mov    (%eax),%esi
  800668:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80066b:	89 f0                	mov    %esi,%eax
  80066d:	c1 f8 1f             	sar    $0x1f,%eax
  800670:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800673:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800676:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800679:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80067e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800682:	0f 89 80 00 00 00    	jns    800708 <vprintfmt+0x34d>
				putch('-', putdat);
  800688:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80068c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800693:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800696:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800699:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80069c:	f7 d8                	neg    %eax
  80069e:	83 d2 00             	adc    $0x0,%edx
  8006a1:	f7 da                	neg    %edx
			}
			base = 10;
  8006a3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006a8:	eb 5e                	jmp    800708 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ad:	e8 8b fc ff ff       	call   80033d <getuint>
			base = 10;
  8006b2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006b7:	eb 4f                	jmp    800708 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  8006b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006bc:	e8 7c fc ff ff       	call   80033d <getuint>
			base = 8;
  8006c1:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006c6:	eb 40                	jmp    800708 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  8006c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006cc:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006d3:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006da:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006e1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ea:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006ed:	8b 00                	mov    (%eax),%eax
  8006ef:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006f4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006f9:	eb 0d                	jmp    800708 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fe:	e8 3a fc ff ff       	call   80033d <getuint>
			base = 16;
  800703:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800708:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  80070c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800710:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800713:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800717:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80071b:	89 04 24             	mov    %eax,(%esp)
  80071e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800722:	89 fa                	mov    %edi,%edx
  800724:	8b 45 08             	mov    0x8(%ebp),%eax
  800727:	e8 20 fb ff ff       	call   80024c <printnum>
			break;
  80072c:	e9 af fc ff ff       	jmp    8003e0 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800731:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800735:	89 04 24             	mov    %eax,(%esp)
  800738:	ff 55 08             	call   *0x8(%ebp)
			break;
  80073b:	e9 a0 fc ff ff       	jmp    8003e0 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800740:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800744:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80074b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80074e:	89 f3                	mov    %esi,%ebx
  800750:	eb 01                	jmp    800753 <vprintfmt+0x398>
  800752:	4b                   	dec    %ebx
  800753:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800757:	75 f9                	jne    800752 <vprintfmt+0x397>
  800759:	e9 82 fc ff ff       	jmp    8003e0 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80075e:	83 c4 3c             	add    $0x3c,%esp
  800761:	5b                   	pop    %ebx
  800762:	5e                   	pop    %esi
  800763:	5f                   	pop    %edi
  800764:	5d                   	pop    %ebp
  800765:	c3                   	ret    

00800766 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	83 ec 28             	sub    $0x28,%esp
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800772:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800775:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800779:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80077c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800783:	85 c0                	test   %eax,%eax
  800785:	74 30                	je     8007b7 <vsnprintf+0x51>
  800787:	85 d2                	test   %edx,%edx
  800789:	7e 2c                	jle    8007b7 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078b:	8b 45 14             	mov    0x14(%ebp),%eax
  80078e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800792:	8b 45 10             	mov    0x10(%ebp),%eax
  800795:	89 44 24 08          	mov    %eax,0x8(%esp)
  800799:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a0:	c7 04 24 77 03 80 00 	movl   $0x800377,(%esp)
  8007a7:	e8 0f fc ff ff       	call   8003bb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007af:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b5:	eb 05                	jmp    8007bc <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007bc:	c9                   	leave  
  8007bd:	c3                   	ret    

008007be <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dc:	89 04 24             	mov    %eax,(%esp)
  8007df:	e8 82 ff ff ff       	call   800766 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e4:	c9                   	leave  
  8007e5:	c3                   	ret    
  8007e6:	66 90                	xchg   %ax,%ax

008007e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f3:	eb 01                	jmp    8007f6 <strlen+0xe>
		n++;
  8007f5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007fa:	75 f9                	jne    8007f5 <strlen+0xd>
		n++;
	return n;
}
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800807:	b8 00 00 00 00       	mov    $0x0,%eax
  80080c:	eb 01                	jmp    80080f <strnlen+0x11>
		n++;
  80080e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080f:	39 d0                	cmp    %edx,%eax
  800811:	74 06                	je     800819 <strnlen+0x1b>
  800813:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800817:	75 f5                	jne    80080e <strnlen+0x10>
		n++;
	return n;
}
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800825:	89 c2                	mov    %eax,%edx
  800827:	42                   	inc    %edx
  800828:	41                   	inc    %ecx
  800829:	8a 59 ff             	mov    -0x1(%ecx),%bl
  80082c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80082f:	84 db                	test   %bl,%bl
  800831:	75 f4                	jne    800827 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800833:	5b                   	pop    %ebx
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	53                   	push   %ebx
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800840:	89 1c 24             	mov    %ebx,(%esp)
  800843:	e8 a0 ff ff ff       	call   8007e8 <strlen>
	strcpy(dst + len, src);
  800848:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80084f:	01 d8                	add    %ebx,%eax
  800851:	89 04 24             	mov    %eax,(%esp)
  800854:	e8 c2 ff ff ff       	call   80081b <strcpy>
	return dst;
}
  800859:	89 d8                	mov    %ebx,%eax
  80085b:	83 c4 08             	add    $0x8,%esp
  80085e:	5b                   	pop    %ebx
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	56                   	push   %esi
  800865:	53                   	push   %ebx
  800866:	8b 75 08             	mov    0x8(%ebp),%esi
  800869:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086c:	89 f3                	mov    %esi,%ebx
  80086e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800871:	89 f2                	mov    %esi,%edx
  800873:	eb 0c                	jmp    800881 <strncpy+0x20>
		*dst++ = *src;
  800875:	42                   	inc    %edx
  800876:	8a 01                	mov    (%ecx),%al
  800878:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80087b:	80 39 01             	cmpb   $0x1,(%ecx)
  80087e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800881:	39 da                	cmp    %ebx,%edx
  800883:	75 f0                	jne    800875 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800885:	89 f0                	mov    %esi,%eax
  800887:	5b                   	pop    %ebx
  800888:	5e                   	pop    %esi
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	56                   	push   %esi
  80088f:	53                   	push   %ebx
  800890:	8b 75 08             	mov    0x8(%ebp),%esi
  800893:	8b 55 0c             	mov    0xc(%ebp),%edx
  800896:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800899:	89 f0                	mov    %esi,%eax
  80089b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089f:	85 c9                	test   %ecx,%ecx
  8008a1:	75 07                	jne    8008aa <strlcpy+0x1f>
  8008a3:	eb 18                	jmp    8008bd <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a5:	40                   	inc    %eax
  8008a6:	42                   	inc    %edx
  8008a7:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008aa:	39 d8                	cmp    %ebx,%eax
  8008ac:	74 0a                	je     8008b8 <strlcpy+0x2d>
  8008ae:	8a 0a                	mov    (%edx),%cl
  8008b0:	84 c9                	test   %cl,%cl
  8008b2:	75 f1                	jne    8008a5 <strlcpy+0x1a>
  8008b4:	89 c2                	mov    %eax,%edx
  8008b6:	eb 02                	jmp    8008ba <strlcpy+0x2f>
  8008b8:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008ba:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008bd:	29 f0                	sub    %esi,%eax
}
  8008bf:	5b                   	pop    %ebx
  8008c0:	5e                   	pop    %esi
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008cc:	eb 02                	jmp    8008d0 <strcmp+0xd>
		p++, q++;
  8008ce:	41                   	inc    %ecx
  8008cf:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008d0:	8a 01                	mov    (%ecx),%al
  8008d2:	84 c0                	test   %al,%al
  8008d4:	74 04                	je     8008da <strcmp+0x17>
  8008d6:	3a 02                	cmp    (%edx),%al
  8008d8:	74 f4                	je     8008ce <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008da:	25 ff 00 00 00       	and    $0xff,%eax
  8008df:	8a 0a                	mov    (%edx),%cl
  8008e1:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8008e7:	29 c8                	sub    %ecx,%eax
}
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	53                   	push   %ebx
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f5:	89 c3                	mov    %eax,%ebx
  8008f7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008fa:	eb 02                	jmp    8008fe <strncmp+0x13>
		n--, p++, q++;
  8008fc:	40                   	inc    %eax
  8008fd:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008fe:	39 d8                	cmp    %ebx,%eax
  800900:	74 20                	je     800922 <strncmp+0x37>
  800902:	8a 08                	mov    (%eax),%cl
  800904:	84 c9                	test   %cl,%cl
  800906:	74 04                	je     80090c <strncmp+0x21>
  800908:	3a 0a                	cmp    (%edx),%cl
  80090a:	74 f0                	je     8008fc <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80090c:	8a 18                	mov    (%eax),%bl
  80090e:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800914:	89 d8                	mov    %ebx,%eax
  800916:	8a 1a                	mov    (%edx),%bl
  800918:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80091e:	29 d8                	sub    %ebx,%eax
  800920:	eb 05                	jmp    800927 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800927:	5b                   	pop    %ebx
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800933:	eb 05                	jmp    80093a <strchr+0x10>
		if (*s == c)
  800935:	38 ca                	cmp    %cl,%dl
  800937:	74 0c                	je     800945 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800939:	40                   	inc    %eax
  80093a:	8a 10                	mov    (%eax),%dl
  80093c:	84 d2                	test   %dl,%dl
  80093e:	75 f5                	jne    800935 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800940:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800950:	eb 05                	jmp    800957 <strfind+0x10>
		if (*s == c)
  800952:	38 ca                	cmp    %cl,%dl
  800954:	74 07                	je     80095d <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800956:	40                   	inc    %eax
  800957:	8a 10                	mov    (%eax),%dl
  800959:	84 d2                	test   %dl,%dl
  80095b:	75 f5                	jne    800952 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	57                   	push   %edi
  800963:	56                   	push   %esi
  800964:	53                   	push   %ebx
  800965:	8b 7d 08             	mov    0x8(%ebp),%edi
  800968:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80096b:	85 c9                	test   %ecx,%ecx
  80096d:	74 37                	je     8009a6 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80096f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800975:	75 29                	jne    8009a0 <memset+0x41>
  800977:	f6 c1 03             	test   $0x3,%cl
  80097a:	75 24                	jne    8009a0 <memset+0x41>
		c &= 0xFF;
  80097c:	31 d2                	xor    %edx,%edx
  80097e:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800981:	89 d3                	mov    %edx,%ebx
  800983:	c1 e3 08             	shl    $0x8,%ebx
  800986:	89 d6                	mov    %edx,%esi
  800988:	c1 e6 18             	shl    $0x18,%esi
  80098b:	89 d0                	mov    %edx,%eax
  80098d:	c1 e0 10             	shl    $0x10,%eax
  800990:	09 f0                	or     %esi,%eax
  800992:	09 c2                	or     %eax,%edx
  800994:	89 d0                	mov    %edx,%eax
  800996:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800998:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80099b:	fc                   	cld    
  80099c:	f3 ab                	rep stos %eax,%es:(%edi)
  80099e:	eb 06                	jmp    8009a6 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a3:	fc                   	cld    
  8009a4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a6:	89 f8                	mov    %edi,%eax
  8009a8:	5b                   	pop    %ebx
  8009a9:	5e                   	pop    %esi
  8009aa:	5f                   	pop    %edi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	57                   	push   %edi
  8009b1:	56                   	push   %esi
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009bb:	39 c6                	cmp    %eax,%esi
  8009bd:	73 33                	jae    8009f2 <memmove+0x45>
  8009bf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c2:	39 d0                	cmp    %edx,%eax
  8009c4:	73 2c                	jae    8009f2 <memmove+0x45>
		s += n;
		d += n;
  8009c6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009c9:	89 d6                	mov    %edx,%esi
  8009cb:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d3:	75 13                	jne    8009e8 <memmove+0x3b>
  8009d5:	f6 c1 03             	test   $0x3,%cl
  8009d8:	75 0e                	jne    8009e8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009da:	83 ef 04             	sub    $0x4,%edi
  8009dd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009e3:	fd                   	std    
  8009e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e6:	eb 07                	jmp    8009ef <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009e8:	4f                   	dec    %edi
  8009e9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ec:	fd                   	std    
  8009ed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ef:	fc                   	cld    
  8009f0:	eb 1d                	jmp    800a0f <memmove+0x62>
  8009f2:	89 f2                	mov    %esi,%edx
  8009f4:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f6:	f6 c2 03             	test   $0x3,%dl
  8009f9:	75 0f                	jne    800a0a <memmove+0x5d>
  8009fb:	f6 c1 03             	test   $0x3,%cl
  8009fe:	75 0a                	jne    800a0a <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a00:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a03:	89 c7                	mov    %eax,%edi
  800a05:	fc                   	cld    
  800a06:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a08:	eb 05                	jmp    800a0f <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a0a:	89 c7                	mov    %eax,%edi
  800a0c:	fc                   	cld    
  800a0d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a0f:	5e                   	pop    %esi
  800a10:	5f                   	pop    %edi
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a19:	8b 45 10             	mov    0x10(%ebp),%eax
  800a1c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a23:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	89 04 24             	mov    %eax,(%esp)
  800a2d:	e8 7b ff ff ff       	call   8009ad <memmove>
}
  800a32:	c9                   	leave  
  800a33:	c3                   	ret    

00800a34 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
  800a39:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3f:	89 d6                	mov    %edx,%esi
  800a41:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a44:	eb 19                	jmp    800a5f <memcmp+0x2b>
		if (*s1 != *s2)
  800a46:	8a 02                	mov    (%edx),%al
  800a48:	8a 19                	mov    (%ecx),%bl
  800a4a:	38 d8                	cmp    %bl,%al
  800a4c:	74 0f                	je     800a5d <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800a4e:	25 ff 00 00 00       	and    $0xff,%eax
  800a53:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800a59:	29 d8                	sub    %ebx,%eax
  800a5b:	eb 0b                	jmp    800a68 <memcmp+0x34>
		s1++, s2++;
  800a5d:	42                   	inc    %edx
  800a5e:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5f:	39 f2                	cmp    %esi,%edx
  800a61:	75 e3                	jne    800a46 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a68:	5b                   	pop    %ebx
  800a69:	5e                   	pop    %esi
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a75:	89 c2                	mov    %eax,%edx
  800a77:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a7a:	eb 05                	jmp    800a81 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a7c:	38 08                	cmp    %cl,(%eax)
  800a7e:	74 05                	je     800a85 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a80:	40                   	inc    %eax
  800a81:	39 d0                	cmp    %edx,%eax
  800a83:	72 f7                	jb     800a7c <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	57                   	push   %edi
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
  800a8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a90:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a93:	eb 01                	jmp    800a96 <strtol+0xf>
		s++;
  800a95:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a96:	8a 02                	mov    (%edx),%al
  800a98:	3c 09                	cmp    $0x9,%al
  800a9a:	74 f9                	je     800a95 <strtol+0xe>
  800a9c:	3c 20                	cmp    $0x20,%al
  800a9e:	74 f5                	je     800a95 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aa0:	3c 2b                	cmp    $0x2b,%al
  800aa2:	75 08                	jne    800aac <strtol+0x25>
		s++;
  800aa4:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa5:	bf 00 00 00 00       	mov    $0x0,%edi
  800aaa:	eb 10                	jmp    800abc <strtol+0x35>
  800aac:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ab1:	3c 2d                	cmp    $0x2d,%al
  800ab3:	75 07                	jne    800abc <strtol+0x35>
		s++, neg = 1;
  800ab5:	8d 52 01             	lea    0x1(%edx),%edx
  800ab8:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800abc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ac2:	75 15                	jne    800ad9 <strtol+0x52>
  800ac4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ac7:	75 10                	jne    800ad9 <strtol+0x52>
  800ac9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800acd:	75 0a                	jne    800ad9 <strtol+0x52>
		s += 2, base = 16;
  800acf:	83 c2 02             	add    $0x2,%edx
  800ad2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad7:	eb 0e                	jmp    800ae7 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800ad9:	85 db                	test   %ebx,%ebx
  800adb:	75 0a                	jne    800ae7 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800add:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800adf:	80 3a 30             	cmpb   $0x30,(%edx)
  800ae2:	75 03                	jne    800ae7 <strtol+0x60>
		s++, base = 8;
  800ae4:	42                   	inc    %edx
  800ae5:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ae7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aec:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aef:	8a 0a                	mov    (%edx),%cl
  800af1:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800af4:	89 f3                	mov    %esi,%ebx
  800af6:	80 fb 09             	cmp    $0x9,%bl
  800af9:	77 08                	ja     800b03 <strtol+0x7c>
			dig = *s - '0';
  800afb:	0f be c9             	movsbl %cl,%ecx
  800afe:	83 e9 30             	sub    $0x30,%ecx
  800b01:	eb 22                	jmp    800b25 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800b03:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b06:	89 f3                	mov    %esi,%ebx
  800b08:	80 fb 19             	cmp    $0x19,%bl
  800b0b:	77 08                	ja     800b15 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800b0d:	0f be c9             	movsbl %cl,%ecx
  800b10:	83 e9 57             	sub    $0x57,%ecx
  800b13:	eb 10                	jmp    800b25 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800b15:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b18:	89 f3                	mov    %esi,%ebx
  800b1a:	80 fb 19             	cmp    $0x19,%bl
  800b1d:	77 14                	ja     800b33 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b1f:	0f be c9             	movsbl %cl,%ecx
  800b22:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b25:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b28:	7d 0d                	jge    800b37 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b2a:	42                   	inc    %edx
  800b2b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b2f:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b31:	eb bc                	jmp    800aef <strtol+0x68>
  800b33:	89 c1                	mov    %eax,%ecx
  800b35:	eb 02                	jmp    800b39 <strtol+0xb2>
  800b37:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b39:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b3d:	74 05                	je     800b44 <strtol+0xbd>
		*endptr = (char *) s;
  800b3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b42:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b44:	85 ff                	test   %edi,%edi
  800b46:	74 04                	je     800b4c <strtol+0xc5>
  800b48:	89 c8                	mov    %ecx,%eax
  800b4a:	f7 d8                	neg    %eax
}
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    
  800b51:	66 90                	xchg   %ax,%ax
  800b53:	66 90                	xchg   %ax,%ax
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
