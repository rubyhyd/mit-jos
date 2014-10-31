
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 0c 00 10 f0 	movl   $0xf010000c,(%esp)
  800049:	e8 4e 00 00 00       	call   80009c <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 18             	sub    $0x18,%esp
  800056:	8b 45 08             	mov    0x8(%ebp),%eax
  800059:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005c:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800063:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800066:	85 c0                	test   %eax,%eax
  800068:	7e 08                	jle    800072 <libmain+0x22>
		binaryname = argv[0];
  80006a:	8b 0a                	mov    (%edx),%ecx
  80006c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800072:	89 54 24 04          	mov    %edx,0x4(%esp)
  800076:	89 04 24             	mov    %eax,(%esp)
  800079:	e8 b6 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007e:	e8 05 00 00 00       	call   800088 <exit>
}
  800083:	c9                   	leave  
  800084:	c3                   	ret    
  800085:	66 90                	xchg   %ax,%ax
  800087:	90                   	nop

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80008e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800095:	e8 3f 00 00 00       	call   8000d9 <sys_env_destroy>
}
  80009a:	c9                   	leave  
  80009b:	c3                   	ret    

0080009c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	57                   	push   %edi
  8000a0:	56                   	push   %esi
  8000a1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ad:	89 c3                	mov    %eax,%ebx
  8000af:	89 c7                	mov    %eax,%edi
  8000b1:	89 c6                	mov    %eax,%esi
  8000b3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b5:	5b                   	pop    %ebx
  8000b6:	5e                   	pop    %esi
  8000b7:	5f                   	pop    %edi
  8000b8:	5d                   	pop    %ebp
  8000b9:	c3                   	ret    

008000ba <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ba:	55                   	push   %ebp
  8000bb:	89 e5                	mov    %esp,%ebp
  8000bd:	57                   	push   %edi
  8000be:	56                   	push   %esi
  8000bf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ca:	89 d1                	mov    %edx,%ecx
  8000cc:	89 d3                	mov    %edx,%ebx
  8000ce:	89 d7                	mov    %edx,%edi
  8000d0:	89 d6                	mov    %edx,%esi
  8000d2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d4:	5b                   	pop    %ebx
  8000d5:	5e                   	pop    %esi
  8000d6:	5f                   	pop    %edi
  8000d7:	5d                   	pop    %ebp
  8000d8:	c3                   	ret    

008000d9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	57                   	push   %edi
  8000dd:	56                   	push   %esi
  8000de:	53                   	push   %ebx
  8000df:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ef:	89 cb                	mov    %ecx,%ebx
  8000f1:	89 cf                	mov    %ecx,%edi
  8000f3:	89 ce                	mov    %ecx,%esi
  8000f5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f7:	85 c0                	test   %eax,%eax
  8000f9:	7e 28                	jle    800123 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000ff:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800106:	00 
  800107:	c7 44 24 08 2a 0e 80 	movl   $0x800e2a,0x8(%esp)
  80010e:	00 
  80010f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800116:	00 
  800117:	c7 04 24 47 0e 80 00 	movl   $0x800e47,(%esp)
  80011e:	e8 29 00 00 00       	call   80014c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800123:	83 c4 2c             	add    $0x2c,%esp
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	5f                   	pop    %edi
  800129:	5d                   	pop    %ebp
  80012a:	c3                   	ret    

0080012b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	57                   	push   %edi
  80012f:	56                   	push   %esi
  800130:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800131:	ba 00 00 00 00       	mov    $0x0,%edx
  800136:	b8 02 00 00 00       	mov    $0x2,%eax
  80013b:	89 d1                	mov    %edx,%ecx
  80013d:	89 d3                	mov    %edx,%ebx
  80013f:	89 d7                	mov    %edx,%edi
  800141:	89 d6                	mov    %edx,%esi
  800143:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5f                   	pop    %edi
  800148:	5d                   	pop    %ebp
  800149:	c3                   	ret    
  80014a:	66 90                	xchg   %ax,%ax

0080014c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
  800151:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800154:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800157:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80015d:	e8 c9 ff ff ff       	call   80012b <sys_getenvid>
  800162:	8b 55 0c             	mov    0xc(%ebp),%edx
  800165:	89 54 24 10          	mov    %edx,0x10(%esp)
  800169:	8b 55 08             	mov    0x8(%ebp),%edx
  80016c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800170:	89 74 24 08          	mov    %esi,0x8(%esp)
  800174:	89 44 24 04          	mov    %eax,0x4(%esp)
  800178:	c7 04 24 58 0e 80 00 	movl   $0x800e58,(%esp)
  80017f:	e8 c2 00 00 00       	call   800246 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800184:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800188:	8b 45 10             	mov    0x10(%ebp),%eax
  80018b:	89 04 24             	mov    %eax,(%esp)
  80018e:	e8 52 00 00 00       	call   8001e5 <vcprintf>
	cprintf("\n");
  800193:	c7 04 24 7c 0e 80 00 	movl   $0x800e7c,(%esp)
  80019a:	e8 a7 00 00 00       	call   800246 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019f:	cc                   	int3   
  8001a0:	eb fd                	jmp    80019f <_panic+0x53>
  8001a2:	66 90                	xchg   %ax,%ax

008001a4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	53                   	push   %ebx
  8001a8:	83 ec 14             	sub    $0x14,%esp
  8001ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ae:	8b 13                	mov    (%ebx),%edx
  8001b0:	8d 42 01             	lea    0x1(%edx),%eax
  8001b3:	89 03                	mov    %eax,(%ebx)
  8001b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001bc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c1:	75 19                	jne    8001dc <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001c3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ca:	00 
  8001cb:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ce:	89 04 24             	mov    %eax,(%esp)
  8001d1:	e8 c6 fe ff ff       	call   80009c <sys_cputs>
		b->idx = 0;
  8001d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001dc:	ff 43 04             	incl   0x4(%ebx)
}
  8001df:	83 c4 14             	add    $0x14,%esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    

008001e5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ee:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f5:	00 00 00 
	b.cnt = 0;
  8001f8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ff:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800202:	8b 45 0c             	mov    0xc(%ebp),%eax
  800205:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800209:	8b 45 08             	mov    0x8(%ebp),%eax
  80020c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800210:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800216:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021a:	c7 04 24 a4 01 80 00 	movl   $0x8001a4,(%esp)
  800221:	e8 a9 01 00 00       	call   8003cf <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800226:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80022c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800230:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800236:	89 04 24             	mov    %eax,(%esp)
  800239:	e8 5e fe ff ff       	call   80009c <sys_cputs>

	return b.cnt;
}
  80023e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800244:	c9                   	leave  
  800245:	c3                   	ret    

00800246 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80024f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800253:	8b 45 08             	mov    0x8(%ebp),%eax
  800256:	89 04 24             	mov    %eax,(%esp)
  800259:	e8 87 ff ff ff       	call   8001e5 <vcprintf>
	va_end(ap);

	return cnt;
}
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 3c             	sub    $0x3c,%esp
  800269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80026c:	89 d7                	mov    %edx,%edi
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
  800277:	89 c1                	mov    %eax,%ecx
  800279:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80027c:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80027f:	8b 45 10             	mov    0x10(%ebp),%eax
  800282:	ba 00 00 00 00       	mov    $0x0,%edx
  800287:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80028a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80028d:	39 ca                	cmp    %ecx,%edx
  80028f:	72 08                	jb     800299 <printnum+0x39>
  800291:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800294:	39 45 10             	cmp    %eax,0x10(%ebp)
  800297:	77 6a                	ja     800303 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800299:	8b 45 18             	mov    0x18(%ebp),%eax
  80029c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a0:	4e                   	dec    %esi
  8002a1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ac:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002b0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002b4:	89 c3                	mov    %eax,%ebx
  8002b6:	89 d6                	mov    %edx,%esi
  8002b8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002bb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c9:	89 04 24             	mov    %eax,(%esp)
  8002cc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d3:	e8 98 08 00 00       	call   800b70 <__udivdi3>
  8002d8:	89 d9                	mov    %ebx,%ecx
  8002da:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002de:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002e2:	89 04 24             	mov    %eax,(%esp)
  8002e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e9:	89 fa                	mov    %edi,%edx
  8002eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ee:	e8 6d ff ff ff       	call   800260 <printnum>
  8002f3:	eb 19                	jmp    80030e <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f9:	8b 45 18             	mov    0x18(%ebp),%eax
  8002fc:	89 04 24             	mov    %eax,(%esp)
  8002ff:	ff d3                	call   *%ebx
  800301:	eb 03                	jmp    800306 <printnum+0xa6>
  800303:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800306:	4e                   	dec    %esi
  800307:	85 f6                	test   %esi,%esi
  800309:	7f ea                	jg     8002f5 <printnum+0x95>
  80030b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800312:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800316:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800319:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80031c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800320:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800324:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800327:	89 04 24             	mov    %eax,(%esp)
  80032a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80032d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800331:	e8 6a 09 00 00       	call   800ca0 <__umoddi3>
  800336:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80033a:	0f be 80 7e 0e 80 00 	movsbl 0x800e7e(%eax),%eax
  800341:	89 04 24             	mov    %eax,(%esp)
  800344:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800347:	ff d0                	call   *%eax
}
  800349:	83 c4 3c             	add    $0x3c,%esp
  80034c:	5b                   	pop    %ebx
  80034d:	5e                   	pop    %esi
  80034e:	5f                   	pop    %edi
  80034f:	5d                   	pop    %ebp
  800350:	c3                   	ret    

00800351 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800354:	83 fa 01             	cmp    $0x1,%edx
  800357:	7e 0e                	jle    800367 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035e:	89 08                	mov    %ecx,(%eax)
  800360:	8b 02                	mov    (%edx),%eax
  800362:	8b 52 04             	mov    0x4(%edx),%edx
  800365:	eb 22                	jmp    800389 <getuint+0x38>
	else if (lflag)
  800367:	85 d2                	test   %edx,%edx
  800369:	74 10                	je     80037b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80036b:	8b 10                	mov    (%eax),%edx
  80036d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800370:	89 08                	mov    %ecx,(%eax)
  800372:	8b 02                	mov    (%edx),%eax
  800374:	ba 00 00 00 00       	mov    $0x0,%edx
  800379:	eb 0e                	jmp    800389 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80037b:	8b 10                	mov    (%eax),%edx
  80037d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800380:	89 08                	mov    %ecx,(%eax)
  800382:	8b 02                	mov    (%edx),%eax
  800384:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800389:	5d                   	pop    %ebp
  80038a:	c3                   	ret    

0080038b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
  80038e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800391:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800394:	8b 10                	mov    (%eax),%edx
  800396:	3b 50 04             	cmp    0x4(%eax),%edx
  800399:	73 0a                	jae    8003a5 <sprintputch+0x1a>
		*b->buf++ = ch;
  80039b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80039e:	89 08                	mov    %ecx,(%eax)
  8003a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a3:	88 02                	mov    %al,(%edx)
}
  8003a5:	5d                   	pop    %ebp
  8003a6:	c3                   	ret    

008003a7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
  8003aa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ad:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c5:	89 04 24             	mov    %eax,(%esp)
  8003c8:	e8 02 00 00 00       	call   8003cf <vprintfmt>
	va_end(ap);
}
  8003cd:	c9                   	leave  
  8003ce:	c3                   	ret    

008003cf <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	57                   	push   %edi
  8003d3:	56                   	push   %esi
  8003d4:	53                   	push   %ebx
  8003d5:	83 ec 3c             	sub    $0x3c,%esp
  8003d8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003de:	eb 14                	jmp    8003f4 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003e0:	85 c0                	test   %eax,%eax
  8003e2:	0f 84 8a 03 00 00    	je     800772 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  8003e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003ec:	89 04 24             	mov    %eax,(%esp)
  8003ef:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f2:	89 f3                	mov    %esi,%ebx
  8003f4:	8d 73 01             	lea    0x1(%ebx),%esi
  8003f7:	31 c0                	xor    %eax,%eax
  8003f9:	8a 03                	mov    (%ebx),%al
  8003fb:	83 f8 25             	cmp    $0x25,%eax
  8003fe:	75 e0                	jne    8003e0 <vprintfmt+0x11>
  800400:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800404:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80040b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800412:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800419:	ba 00 00 00 00       	mov    $0x0,%edx
  80041e:	eb 1d                	jmp    80043d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800422:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800426:	eb 15                	jmp    80043d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800428:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80042a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80042e:	eb 0d                	jmp    80043d <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800430:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800433:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800436:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	8d 5e 01             	lea    0x1(%esi),%ebx
  800440:	31 c0                	xor    %eax,%eax
  800442:	8a 06                	mov    (%esi),%al
  800444:	8a 0e                	mov    (%esi),%cl
  800446:	83 e9 23             	sub    $0x23,%ecx
  800449:	88 4d e0             	mov    %cl,-0x20(%ebp)
  80044c:	80 f9 55             	cmp    $0x55,%cl
  80044f:	0f 87 ff 02 00 00    	ja     800754 <vprintfmt+0x385>
  800455:	31 c9                	xor    %ecx,%ecx
  800457:	8a 4d e0             	mov    -0x20(%ebp),%cl
  80045a:	ff 24 8d 20 0f 80 00 	jmp    *0x800f20(,%ecx,4)
  800461:	89 de                	mov    %ebx,%esi
  800463:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800468:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80046b:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  80046f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800472:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800475:	83 fb 09             	cmp    $0x9,%ebx
  800478:	77 2f                	ja     8004a9 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80047a:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80047b:	eb eb                	jmp    800468 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80047d:	8b 45 14             	mov    0x14(%ebp),%eax
  800480:	8d 48 04             	lea    0x4(%eax),%ecx
  800483:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800486:	8b 00                	mov    (%eax),%eax
  800488:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80048d:	eb 1d                	jmp    8004ac <vprintfmt+0xdd>
  80048f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800492:	f7 d0                	not    %eax
  800494:	c1 f8 1f             	sar    $0x1f,%eax
  800497:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	89 de                	mov    %ebx,%esi
  80049c:	eb 9f                	jmp    80043d <vprintfmt+0x6e>
  80049e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004a0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004a7:	eb 94                	jmp    80043d <vprintfmt+0x6e>
  8004a9:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004ac:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004b0:	79 8b                	jns    80043d <vprintfmt+0x6e>
  8004b2:	e9 79 ff ff ff       	jmp    800430 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004b7:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b8:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ba:	eb 81                	jmp    80043d <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bf:	8d 50 04             	lea    0x4(%eax),%edx
  8004c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004c9:	8b 00                	mov    (%eax),%eax
  8004cb:	89 04 24             	mov    %eax,(%esp)
  8004ce:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004d1:	e9 1e ff ff ff       	jmp    8003f4 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d9:	8d 50 04             	lea    0x4(%eax),%edx
  8004dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004df:	8b 00                	mov    (%eax),%eax
  8004e1:	89 c2                	mov    %eax,%edx
  8004e3:	c1 fa 1f             	sar    $0x1f,%edx
  8004e6:	31 d0                	xor    %edx,%eax
  8004e8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ea:	83 f8 07             	cmp    $0x7,%eax
  8004ed:	7f 0b                	jg     8004fa <vprintfmt+0x12b>
  8004ef:	8b 14 85 80 10 80 00 	mov    0x801080(,%eax,4),%edx
  8004f6:	85 d2                	test   %edx,%edx
  8004f8:	75 20                	jne    80051a <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  8004fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fe:	c7 44 24 08 96 0e 80 	movl   $0x800e96,0x8(%esp)
  800505:	00 
  800506:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80050a:	8b 45 08             	mov    0x8(%ebp),%eax
  80050d:	89 04 24             	mov    %eax,(%esp)
  800510:	e8 92 fe ff ff       	call   8003a7 <printfmt>
  800515:	e9 da fe ff ff       	jmp    8003f4 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80051a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80051e:	c7 44 24 08 9f 0e 80 	movl   $0x800e9f,0x8(%esp)
  800525:	00 
  800526:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052a:	8b 45 08             	mov    0x8(%ebp),%eax
  80052d:	89 04 24             	mov    %eax,(%esp)
  800530:	e8 72 fe ff ff       	call   8003a7 <printfmt>
  800535:	e9 ba fe ff ff       	jmp    8003f4 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80053d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800540:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8d 50 04             	lea    0x4(%eax),%edx
  800549:	89 55 14             	mov    %edx,0x14(%ebp)
  80054c:	8b 30                	mov    (%eax),%esi
  80054e:	85 f6                	test   %esi,%esi
  800550:	75 05                	jne    800557 <vprintfmt+0x188>
				p = "(null)";
  800552:	be 8f 0e 80 00       	mov    $0x800e8f,%esi
			if (width > 0 && padc != '-')
  800557:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80055b:	0f 84 8c 00 00 00    	je     8005ed <vprintfmt+0x21e>
  800561:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800565:	0f 8e 8a 00 00 00    	jle    8005f5 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  80056b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80056f:	89 34 24             	mov    %esi,(%esp)
  800572:	e8 9b 02 00 00       	call   800812 <strnlen>
  800577:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80057a:	29 c1                	sub    %eax,%ecx
  80057c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  80057f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800583:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800586:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800589:	8b 75 08             	mov    0x8(%ebp),%esi
  80058c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80058f:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800591:	eb 0d                	jmp    8005a0 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800593:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800597:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80059a:	89 04 24             	mov    %eax,(%esp)
  80059d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80059f:	4b                   	dec    %ebx
  8005a0:	85 db                	test   %ebx,%ebx
  8005a2:	7f ef                	jg     800593 <vprintfmt+0x1c4>
  8005a4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005a7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005aa:	89 c8                	mov    %ecx,%eax
  8005ac:	f7 d0                	not    %eax
  8005ae:	c1 f8 1f             	sar    $0x1f,%eax
  8005b1:	21 c8                	and    %ecx,%eax
  8005b3:	29 c1                	sub    %eax,%ecx
  8005b5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005bb:	eb 3e                	jmp    8005fb <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005bd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c1:	74 1b                	je     8005de <vprintfmt+0x20f>
  8005c3:	0f be d2             	movsbl %dl,%edx
  8005c6:	83 ea 20             	sub    $0x20,%edx
  8005c9:	83 fa 5e             	cmp    $0x5e,%edx
  8005cc:	76 10                	jbe    8005de <vprintfmt+0x20f>
					putch('?', putdat);
  8005ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d2:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005d9:	ff 55 08             	call   *0x8(%ebp)
  8005dc:	eb 0a                	jmp    8005e8 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  8005de:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e2:	89 04 24             	mov    %eax,(%esp)
  8005e5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e8:	ff 4d dc             	decl   -0x24(%ebp)
  8005eb:	eb 0e                	jmp    8005fb <vprintfmt+0x22c>
  8005ed:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005f0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005f3:	eb 06                	jmp    8005fb <vprintfmt+0x22c>
  8005f5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005f8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005fb:	46                   	inc    %esi
  8005fc:	8a 56 ff             	mov    -0x1(%esi),%dl
  8005ff:	0f be c2             	movsbl %dl,%eax
  800602:	85 c0                	test   %eax,%eax
  800604:	74 1f                	je     800625 <vprintfmt+0x256>
  800606:	85 db                	test   %ebx,%ebx
  800608:	78 b3                	js     8005bd <vprintfmt+0x1ee>
  80060a:	4b                   	dec    %ebx
  80060b:	79 b0                	jns    8005bd <vprintfmt+0x1ee>
  80060d:	8b 75 08             	mov    0x8(%ebp),%esi
  800610:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800613:	eb 16                	jmp    80062b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800615:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800619:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800620:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800622:	4b                   	dec    %ebx
  800623:	eb 06                	jmp    80062b <vprintfmt+0x25c>
  800625:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800628:	8b 75 08             	mov    0x8(%ebp),%esi
  80062b:	85 db                	test   %ebx,%ebx
  80062d:	7f e6                	jg     800615 <vprintfmt+0x246>
  80062f:	89 75 08             	mov    %esi,0x8(%ebp)
  800632:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800635:	e9 ba fd ff ff       	jmp    8003f4 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80063a:	83 fa 01             	cmp    $0x1,%edx
  80063d:	7e 16                	jle    800655 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8d 50 08             	lea    0x8(%eax),%edx
  800645:	89 55 14             	mov    %edx,0x14(%ebp)
  800648:	8b 50 04             	mov    0x4(%eax),%edx
  80064b:	8b 00                	mov    (%eax),%eax
  80064d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800650:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800653:	eb 32                	jmp    800687 <vprintfmt+0x2b8>
	else if (lflag)
  800655:	85 d2                	test   %edx,%edx
  800657:	74 18                	je     800671 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8d 50 04             	lea    0x4(%eax),%edx
  80065f:	89 55 14             	mov    %edx,0x14(%ebp)
  800662:	8b 30                	mov    (%eax),%esi
  800664:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800667:	89 f0                	mov    %esi,%eax
  800669:	c1 f8 1f             	sar    $0x1f,%eax
  80066c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80066f:	eb 16                	jmp    800687 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8d 50 04             	lea    0x4(%eax),%edx
  800677:	89 55 14             	mov    %edx,0x14(%ebp)
  80067a:	8b 30                	mov    (%eax),%esi
  80067c:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80067f:	89 f0                	mov    %esi,%eax
  800681:	c1 f8 1f             	sar    $0x1f,%eax
  800684:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800687:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80068a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80068d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800692:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800696:	0f 89 80 00 00 00    	jns    80071c <vprintfmt+0x34d>
				putch('-', putdat);
  80069c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006a7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006b0:	f7 d8                	neg    %eax
  8006b2:	83 d2 00             	adc    $0x0,%edx
  8006b5:	f7 da                	neg    %edx
			}
			base = 10;
  8006b7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006bc:	eb 5e                	jmp    80071c <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006be:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c1:	e8 8b fc ff ff       	call   800351 <getuint>
			base = 10;
  8006c6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006cb:	eb 4f                	jmp    80071c <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  8006cd:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d0:	e8 7c fc ff ff       	call   800351 <getuint>
			base = 8;
  8006d5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006da:	eb 40                	jmp    80071c <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  8006dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006e0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006e7:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ee:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006f5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8d 50 04             	lea    0x4(%eax),%edx
  8006fe:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800701:	8b 00                	mov    (%eax),%eax
  800703:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800708:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80070d:	eb 0d                	jmp    80071c <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80070f:	8d 45 14             	lea    0x14(%ebp),%eax
  800712:	e8 3a fc ff ff       	call   800351 <getuint>
			base = 16;
  800717:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80071c:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800720:	89 74 24 10          	mov    %esi,0x10(%esp)
  800724:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800727:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80072b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80072f:	89 04 24             	mov    %eax,(%esp)
  800732:	89 54 24 04          	mov    %edx,0x4(%esp)
  800736:	89 fa                	mov    %edi,%edx
  800738:	8b 45 08             	mov    0x8(%ebp),%eax
  80073b:	e8 20 fb ff ff       	call   800260 <printnum>
			break;
  800740:	e9 af fc ff ff       	jmp    8003f4 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800745:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800749:	89 04 24             	mov    %eax,(%esp)
  80074c:	ff 55 08             	call   *0x8(%ebp)
			break;
  80074f:	e9 a0 fc ff ff       	jmp    8003f4 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800754:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800758:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80075f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800762:	89 f3                	mov    %esi,%ebx
  800764:	eb 01                	jmp    800767 <vprintfmt+0x398>
  800766:	4b                   	dec    %ebx
  800767:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80076b:	75 f9                	jne    800766 <vprintfmt+0x397>
  80076d:	e9 82 fc ff ff       	jmp    8003f4 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800772:	83 c4 3c             	add    $0x3c,%esp
  800775:	5b                   	pop    %ebx
  800776:	5e                   	pop    %esi
  800777:	5f                   	pop    %edi
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	83 ec 28             	sub    $0x28,%esp
  800780:	8b 45 08             	mov    0x8(%ebp),%eax
  800783:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800786:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800789:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80078d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800790:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800797:	85 c0                	test   %eax,%eax
  800799:	74 30                	je     8007cb <vsnprintf+0x51>
  80079b:	85 d2                	test   %edx,%edx
  80079d:	7e 2c                	jle    8007cb <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079f:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ad:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b4:	c7 04 24 8b 03 80 00 	movl   $0x80038b,(%esp)
  8007bb:	e8 0f fc ff ff       	call   8003cf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c9:	eb 05                	jmp    8007d0 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    

008007d2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007df:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f0:	89 04 24             	mov    %eax,(%esp)
  8007f3:	e8 82 ff ff ff       	call   80077a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    
  8007fa:	66 90                	xchg   %ax,%ax

008007fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800802:	b8 00 00 00 00       	mov    $0x0,%eax
  800807:	eb 01                	jmp    80080a <strlen+0xe>
		n++;
  800809:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80080e:	75 f9                	jne    800809 <strlen+0xd>
		n++;
	return n;
}
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800818:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081b:	b8 00 00 00 00       	mov    $0x0,%eax
  800820:	eb 01                	jmp    800823 <strnlen+0x11>
		n++;
  800822:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800823:	39 d0                	cmp    %edx,%eax
  800825:	74 06                	je     80082d <strnlen+0x1b>
  800827:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80082b:	75 f5                	jne    800822 <strnlen+0x10>
		n++;
	return n;
}
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	53                   	push   %ebx
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800839:	89 c2                	mov    %eax,%edx
  80083b:	42                   	inc    %edx
  80083c:	41                   	inc    %ecx
  80083d:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800840:	88 5a ff             	mov    %bl,-0x1(%edx)
  800843:	84 db                	test   %bl,%bl
  800845:	75 f4                	jne    80083b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800847:	5b                   	pop    %ebx
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	53                   	push   %ebx
  80084e:	83 ec 08             	sub    $0x8,%esp
  800851:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800854:	89 1c 24             	mov    %ebx,(%esp)
  800857:	e8 a0 ff ff ff       	call   8007fc <strlen>
	strcpy(dst + len, src);
  80085c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800863:	01 d8                	add    %ebx,%eax
  800865:	89 04 24             	mov    %eax,(%esp)
  800868:	e8 c2 ff ff ff       	call   80082f <strcpy>
	return dst;
}
  80086d:	89 d8                	mov    %ebx,%eax
  80086f:	83 c4 08             	add    $0x8,%esp
  800872:	5b                   	pop    %ebx
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	56                   	push   %esi
  800879:	53                   	push   %ebx
  80087a:	8b 75 08             	mov    0x8(%ebp),%esi
  80087d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800880:	89 f3                	mov    %esi,%ebx
  800882:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800885:	89 f2                	mov    %esi,%edx
  800887:	eb 0c                	jmp    800895 <strncpy+0x20>
		*dst++ = *src;
  800889:	42                   	inc    %edx
  80088a:	8a 01                	mov    (%ecx),%al
  80088c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80088f:	80 39 01             	cmpb   $0x1,(%ecx)
  800892:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800895:	39 da                	cmp    %ebx,%edx
  800897:	75 f0                	jne    800889 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800899:	89 f0                	mov    %esi,%eax
  80089b:	5b                   	pop    %ebx
  80089c:	5e                   	pop    %esi
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	56                   	push   %esi
  8008a3:	53                   	push   %ebx
  8008a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008ad:	89 f0                	mov    %esi,%eax
  8008af:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b3:	85 c9                	test   %ecx,%ecx
  8008b5:	75 07                	jne    8008be <strlcpy+0x1f>
  8008b7:	eb 18                	jmp    8008d1 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008b9:	40                   	inc    %eax
  8008ba:	42                   	inc    %edx
  8008bb:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008be:	39 d8                	cmp    %ebx,%eax
  8008c0:	74 0a                	je     8008cc <strlcpy+0x2d>
  8008c2:	8a 0a                	mov    (%edx),%cl
  8008c4:	84 c9                	test   %cl,%cl
  8008c6:	75 f1                	jne    8008b9 <strlcpy+0x1a>
  8008c8:	89 c2                	mov    %eax,%edx
  8008ca:	eb 02                	jmp    8008ce <strlcpy+0x2f>
  8008cc:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008ce:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008d1:	29 f0                	sub    %esi,%eax
}
  8008d3:	5b                   	pop    %ebx
  8008d4:	5e                   	pop    %esi
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e0:	eb 02                	jmp    8008e4 <strcmp+0xd>
		p++, q++;
  8008e2:	41                   	inc    %ecx
  8008e3:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008e4:	8a 01                	mov    (%ecx),%al
  8008e6:	84 c0                	test   %al,%al
  8008e8:	74 04                	je     8008ee <strcmp+0x17>
  8008ea:	3a 02                	cmp    (%edx),%al
  8008ec:	74 f4                	je     8008e2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ee:	25 ff 00 00 00       	and    $0xff,%eax
  8008f3:	8a 0a                	mov    (%edx),%cl
  8008f5:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8008fb:	29 c8                	sub    %ecx,%eax
}
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	53                   	push   %ebx
  800903:	8b 45 08             	mov    0x8(%ebp),%eax
  800906:	8b 55 0c             	mov    0xc(%ebp),%edx
  800909:	89 c3                	mov    %eax,%ebx
  80090b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80090e:	eb 02                	jmp    800912 <strncmp+0x13>
		n--, p++, q++;
  800910:	40                   	inc    %eax
  800911:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800912:	39 d8                	cmp    %ebx,%eax
  800914:	74 20                	je     800936 <strncmp+0x37>
  800916:	8a 08                	mov    (%eax),%cl
  800918:	84 c9                	test   %cl,%cl
  80091a:	74 04                	je     800920 <strncmp+0x21>
  80091c:	3a 0a                	cmp    (%edx),%cl
  80091e:	74 f0                	je     800910 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800920:	8a 18                	mov    (%eax),%bl
  800922:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800928:	89 d8                	mov    %ebx,%eax
  80092a:	8a 1a                	mov    (%edx),%bl
  80092c:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800932:	29 d8                	sub    %ebx,%eax
  800934:	eb 05                	jmp    80093b <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80093b:	5b                   	pop    %ebx
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800947:	eb 05                	jmp    80094e <strchr+0x10>
		if (*s == c)
  800949:	38 ca                	cmp    %cl,%dl
  80094b:	74 0c                	je     800959 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094d:	40                   	inc    %eax
  80094e:	8a 10                	mov    (%eax),%dl
  800950:	84 d2                	test   %dl,%dl
  800952:	75 f5                	jne    800949 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800954:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800964:	eb 05                	jmp    80096b <strfind+0x10>
		if (*s == c)
  800966:	38 ca                	cmp    %cl,%dl
  800968:	74 07                	je     800971 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80096a:	40                   	inc    %eax
  80096b:	8a 10                	mov    (%eax),%dl
  80096d:	84 d2                	test   %dl,%dl
  80096f:	75 f5                	jne    800966 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	57                   	push   %edi
  800977:	56                   	push   %esi
  800978:	53                   	push   %ebx
  800979:	8b 7d 08             	mov    0x8(%ebp),%edi
  80097c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80097f:	85 c9                	test   %ecx,%ecx
  800981:	74 37                	je     8009ba <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800983:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800989:	75 29                	jne    8009b4 <memset+0x41>
  80098b:	f6 c1 03             	test   $0x3,%cl
  80098e:	75 24                	jne    8009b4 <memset+0x41>
		c &= 0xFF;
  800990:	31 d2                	xor    %edx,%edx
  800992:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800995:	89 d3                	mov    %edx,%ebx
  800997:	c1 e3 08             	shl    $0x8,%ebx
  80099a:	89 d6                	mov    %edx,%esi
  80099c:	c1 e6 18             	shl    $0x18,%esi
  80099f:	89 d0                	mov    %edx,%eax
  8009a1:	c1 e0 10             	shl    $0x10,%eax
  8009a4:	09 f0                	or     %esi,%eax
  8009a6:	09 c2                	or     %eax,%edx
  8009a8:	89 d0                	mov    %edx,%eax
  8009aa:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ac:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009af:	fc                   	cld    
  8009b0:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b2:	eb 06                	jmp    8009ba <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b7:	fc                   	cld    
  8009b8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ba:	89 f8                	mov    %edi,%eax
  8009bc:	5b                   	pop    %ebx
  8009bd:	5e                   	pop    %esi
  8009be:	5f                   	pop    %edi
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	57                   	push   %edi
  8009c5:	56                   	push   %esi
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009cf:	39 c6                	cmp    %eax,%esi
  8009d1:	73 33                	jae    800a06 <memmove+0x45>
  8009d3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009d6:	39 d0                	cmp    %edx,%eax
  8009d8:	73 2c                	jae    800a06 <memmove+0x45>
		s += n;
		d += n;
  8009da:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009dd:	89 d6                	mov    %edx,%esi
  8009df:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e7:	75 13                	jne    8009fc <memmove+0x3b>
  8009e9:	f6 c1 03             	test   $0x3,%cl
  8009ec:	75 0e                	jne    8009fc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ee:	83 ef 04             	sub    $0x4,%edi
  8009f1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009f7:	fd                   	std    
  8009f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fa:	eb 07                	jmp    800a03 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009fc:	4f                   	dec    %edi
  8009fd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a00:	fd                   	std    
  800a01:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a03:	fc                   	cld    
  800a04:	eb 1d                	jmp    800a23 <memmove+0x62>
  800a06:	89 f2                	mov    %esi,%edx
  800a08:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0a:	f6 c2 03             	test   $0x3,%dl
  800a0d:	75 0f                	jne    800a1e <memmove+0x5d>
  800a0f:	f6 c1 03             	test   $0x3,%cl
  800a12:	75 0a                	jne    800a1e <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a14:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a17:	89 c7                	mov    %eax,%edi
  800a19:	fc                   	cld    
  800a1a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1c:	eb 05                	jmp    800a23 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a1e:	89 c7                	mov    %eax,%edi
  800a20:	fc                   	cld    
  800a21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a23:	5e                   	pop    %esi
  800a24:	5f                   	pop    %edi
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a2d:	8b 45 10             	mov    0x10(%ebp),%eax
  800a30:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a37:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3e:	89 04 24             	mov    %eax,(%esp)
  800a41:	e8 7b ff ff ff       	call   8009c1 <memmove>
}
  800a46:	c9                   	leave  
  800a47:	c3                   	ret    

00800a48 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	56                   	push   %esi
  800a4c:	53                   	push   %ebx
  800a4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a53:	89 d6                	mov    %edx,%esi
  800a55:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a58:	eb 19                	jmp    800a73 <memcmp+0x2b>
		if (*s1 != *s2)
  800a5a:	8a 02                	mov    (%edx),%al
  800a5c:	8a 19                	mov    (%ecx),%bl
  800a5e:	38 d8                	cmp    %bl,%al
  800a60:	74 0f                	je     800a71 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800a62:	25 ff 00 00 00       	and    $0xff,%eax
  800a67:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800a6d:	29 d8                	sub    %ebx,%eax
  800a6f:	eb 0b                	jmp    800a7c <memcmp+0x34>
		s1++, s2++;
  800a71:	42                   	inc    %edx
  800a72:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a73:	39 f2                	cmp    %esi,%edx
  800a75:	75 e3                	jne    800a5a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a89:	89 c2                	mov    %eax,%edx
  800a8b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a8e:	eb 05                	jmp    800a95 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a90:	38 08                	cmp    %cl,(%eax)
  800a92:	74 05                	je     800a99 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a94:	40                   	inc    %eax
  800a95:	39 d0                	cmp    %edx,%eax
  800a97:	72 f7                	jb     800a90 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	57                   	push   %edi
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
  800aa1:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa7:	eb 01                	jmp    800aaa <strtol+0xf>
		s++;
  800aa9:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aaa:	8a 02                	mov    (%edx),%al
  800aac:	3c 09                	cmp    $0x9,%al
  800aae:	74 f9                	je     800aa9 <strtol+0xe>
  800ab0:	3c 20                	cmp    $0x20,%al
  800ab2:	74 f5                	je     800aa9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ab4:	3c 2b                	cmp    $0x2b,%al
  800ab6:	75 08                	jne    800ac0 <strtol+0x25>
		s++;
  800ab8:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ab9:	bf 00 00 00 00       	mov    $0x0,%edi
  800abe:	eb 10                	jmp    800ad0 <strtol+0x35>
  800ac0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ac5:	3c 2d                	cmp    $0x2d,%al
  800ac7:	75 07                	jne    800ad0 <strtol+0x35>
		s++, neg = 1;
  800ac9:	8d 52 01             	lea    0x1(%edx),%edx
  800acc:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ad6:	75 15                	jne    800aed <strtol+0x52>
  800ad8:	80 3a 30             	cmpb   $0x30,(%edx)
  800adb:	75 10                	jne    800aed <strtol+0x52>
  800add:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ae1:	75 0a                	jne    800aed <strtol+0x52>
		s += 2, base = 16;
  800ae3:	83 c2 02             	add    $0x2,%edx
  800ae6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aeb:	eb 0e                	jmp    800afb <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800aed:	85 db                	test   %ebx,%ebx
  800aef:	75 0a                	jne    800afb <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800af1:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af3:	80 3a 30             	cmpb   $0x30,(%edx)
  800af6:	75 03                	jne    800afb <strtol+0x60>
		s++, base = 8;
  800af8:	42                   	inc    %edx
  800af9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800afb:	b8 00 00 00 00       	mov    $0x0,%eax
  800b00:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b03:	8a 0a                	mov    (%edx),%cl
  800b05:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b08:	89 f3                	mov    %esi,%ebx
  800b0a:	80 fb 09             	cmp    $0x9,%bl
  800b0d:	77 08                	ja     800b17 <strtol+0x7c>
			dig = *s - '0';
  800b0f:	0f be c9             	movsbl %cl,%ecx
  800b12:	83 e9 30             	sub    $0x30,%ecx
  800b15:	eb 22                	jmp    800b39 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800b17:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b1a:	89 f3                	mov    %esi,%ebx
  800b1c:	80 fb 19             	cmp    $0x19,%bl
  800b1f:	77 08                	ja     800b29 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800b21:	0f be c9             	movsbl %cl,%ecx
  800b24:	83 e9 57             	sub    $0x57,%ecx
  800b27:	eb 10                	jmp    800b39 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800b29:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b2c:	89 f3                	mov    %esi,%ebx
  800b2e:	80 fb 19             	cmp    $0x19,%bl
  800b31:	77 14                	ja     800b47 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b33:	0f be c9             	movsbl %cl,%ecx
  800b36:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b39:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b3c:	7d 0d                	jge    800b4b <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b3e:	42                   	inc    %edx
  800b3f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b43:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b45:	eb bc                	jmp    800b03 <strtol+0x68>
  800b47:	89 c1                	mov    %eax,%ecx
  800b49:	eb 02                	jmp    800b4d <strtol+0xb2>
  800b4b:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b4d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b51:	74 05                	je     800b58 <strtol+0xbd>
		*endptr = (char *) s;
  800b53:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b56:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b58:	85 ff                	test   %edi,%edi
  800b5a:	74 04                	je     800b60 <strtol+0xc5>
  800b5c:	89 c8                	mov    %ecx,%eax
  800b5e:	f7 d8                	neg    %eax
}
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    
  800b65:	66 90                	xchg   %ax,%ax
  800b67:	66 90                	xchg   %ax,%ax
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
