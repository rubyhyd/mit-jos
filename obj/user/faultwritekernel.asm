
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0xf0100000 = 0;
  800037:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003e:	00 00 00 
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    
  800043:	90                   	nop

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	83 ec 18             	sub    $0x18,%esp
  80004a:	8b 45 08             	mov    0x8(%ebp),%eax
  80004d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800050:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800057:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005a:	85 c0                	test   %eax,%eax
  80005c:	7e 08                	jle    800066 <libmain+0x22>
		binaryname = argv[0];
  80005e:	8b 0a                	mov    (%edx),%ecx
  800060:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800066:	89 54 24 04          	mov    %edx,0x4(%esp)
  80006a:	89 04 24             	mov    %eax,(%esp)
  80006d:	e8 c2 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800072:	e8 05 00 00 00       	call   80007c <exit>
}
  800077:	c9                   	leave  
  800078:	c3                   	ret    
  800079:	66 90                	xchg   %ax,%ax
  80007b:	90                   	nop

0080007c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007c:	55                   	push   %ebp
  80007d:	89 e5                	mov    %esp,%ebp
  80007f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800082:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800089:	e8 3f 00 00 00       	call   8000cd <sys_env_destroy>
}
  80008e:	c9                   	leave  
  80008f:	c3                   	ret    

00800090 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	57                   	push   %edi
  800094:	56                   	push   %esi
  800095:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800096:	b8 00 00 00 00       	mov    $0x0,%eax
  80009b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009e:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a1:	89 c3                	mov    %eax,%ebx
  8000a3:	89 c7                	mov    %eax,%edi
  8000a5:	89 c6                	mov    %eax,%esi
  8000a7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000a9:	5b                   	pop    %ebx
  8000aa:	5e                   	pop    %esi
  8000ab:	5f                   	pop    %edi
  8000ac:	5d                   	pop    %ebp
  8000ad:	c3                   	ret    

008000ae <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000be:	89 d1                	mov    %edx,%ecx
  8000c0:	89 d3                	mov    %edx,%ebx
  8000c2:	89 d7                	mov    %edx,%edi
  8000c4:	89 d6                	mov    %edx,%esi
  8000c6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5f                   	pop    %edi
  8000cb:	5d                   	pop    %ebp
  8000cc:	c3                   	ret    

008000cd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000cd:	55                   	push   %ebp
  8000ce:	89 e5                	mov    %esp,%ebp
  8000d0:	57                   	push   %edi
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000db:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e3:	89 cb                	mov    %ecx,%ebx
  8000e5:	89 cf                	mov    %ecx,%edi
  8000e7:	89 ce                	mov    %ecx,%esi
  8000e9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000eb:	85 c0                	test   %eax,%eax
  8000ed:	7e 28                	jle    800117 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ef:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000f3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8000fa:	00 
  8000fb:	c7 44 24 08 0a 0e 80 	movl   $0x800e0a,0x8(%esp)
  800102:	00 
  800103:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80010a:	00 
  80010b:	c7 04 24 27 0e 80 00 	movl   $0x800e27,(%esp)
  800112:	e8 29 00 00 00       	call   800140 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800117:	83 c4 2c             	add    $0x2c,%esp
  80011a:	5b                   	pop    %ebx
  80011b:	5e                   	pop    %esi
  80011c:	5f                   	pop    %edi
  80011d:	5d                   	pop    %ebp
  80011e:	c3                   	ret    

0080011f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	57                   	push   %edi
  800123:	56                   	push   %esi
  800124:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800125:	ba 00 00 00 00       	mov    $0x0,%edx
  80012a:	b8 02 00 00 00       	mov    $0x2,%eax
  80012f:	89 d1                	mov    %edx,%ecx
  800131:	89 d3                	mov    %edx,%ebx
  800133:	89 d7                	mov    %edx,%edi
  800135:	89 d6                	mov    %edx,%esi
  800137:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800139:	5b                   	pop    %ebx
  80013a:	5e                   	pop    %esi
  80013b:	5f                   	pop    %edi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    
  80013e:	66 90                	xchg   %ax,%ax

00800140 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
  800145:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800148:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800151:	e8 c9 ff ff ff       	call   80011f <sys_getenvid>
  800156:	8b 55 0c             	mov    0xc(%ebp),%edx
  800159:	89 54 24 10          	mov    %edx,0x10(%esp)
  80015d:	8b 55 08             	mov    0x8(%ebp),%edx
  800160:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800164:	89 74 24 08          	mov    %esi,0x8(%esp)
  800168:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016c:	c7 04 24 38 0e 80 00 	movl   $0x800e38,(%esp)
  800173:	e8 c2 00 00 00       	call   80023a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800178:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80017c:	8b 45 10             	mov    0x10(%ebp),%eax
  80017f:	89 04 24             	mov    %eax,(%esp)
  800182:	e8 52 00 00 00       	call   8001d9 <vcprintf>
	cprintf("\n");
  800187:	c7 04 24 5c 0e 80 00 	movl   $0x800e5c,(%esp)
  80018e:	e8 a7 00 00 00       	call   80023a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800193:	cc                   	int3   
  800194:	eb fd                	jmp    800193 <_panic+0x53>
  800196:	66 90                	xchg   %ax,%ax

00800198 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	53                   	push   %ebx
  80019c:	83 ec 14             	sub    $0x14,%esp
  80019f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a2:	8b 13                	mov    (%ebx),%edx
  8001a4:	8d 42 01             	lea    0x1(%edx),%eax
  8001a7:	89 03                	mov    %eax,(%ebx)
  8001a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b5:	75 19                	jne    8001d0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001b7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001be:	00 
  8001bf:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c2:	89 04 24             	mov    %eax,(%esp)
  8001c5:	e8 c6 fe ff ff       	call   800090 <sys_cputs>
		b->idx = 0;
  8001ca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001d0:	ff 43 04             	incl   0x4(%ebx)
}
  8001d3:	83 c4 14             	add    $0x14,%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5d                   	pop    %ebp
  8001d8:	c3                   	ret    

008001d9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001e2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e9:	00 00 00 
	b.cnt = 0;
  8001ec:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800200:	89 44 24 08          	mov    %eax,0x8(%esp)
  800204:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020e:	c7 04 24 98 01 80 00 	movl   $0x800198,(%esp)
  800215:	e8 a9 01 00 00       	call   8003c3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800220:	89 44 24 04          	mov    %eax,0x4(%esp)
  800224:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022a:	89 04 24             	mov    %eax,(%esp)
  80022d:	e8 5e fe ff ff       	call   800090 <sys_cputs>

	return b.cnt;
}
  800232:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800240:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800243:	89 44 24 04          	mov    %eax,0x4(%esp)
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	89 04 24             	mov    %eax,(%esp)
  80024d:	e8 87 ff ff ff       	call   8001d9 <vcprintf>
	va_end(ap);

	return cnt;
}
  800252:	c9                   	leave  
  800253:	c3                   	ret    

00800254 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	57                   	push   %edi
  800258:	56                   	push   %esi
  800259:	53                   	push   %ebx
  80025a:	83 ec 3c             	sub    $0x3c,%esp
  80025d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800260:	89 d7                	mov    %edx,%edi
  800262:	8b 45 08             	mov    0x8(%ebp),%eax
  800265:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800268:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026b:	89 c1                	mov    %eax,%ecx
  80026d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800270:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800273:	8b 45 10             	mov    0x10(%ebp),%eax
  800276:	ba 00 00 00 00       	mov    $0x0,%edx
  80027b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80027e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800281:	39 ca                	cmp    %ecx,%edx
  800283:	72 08                	jb     80028d <printnum+0x39>
  800285:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800288:	39 45 10             	cmp    %eax,0x10(%ebp)
  80028b:	77 6a                	ja     8002f7 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80028d:	8b 45 18             	mov    0x18(%ebp),%eax
  800290:	89 44 24 10          	mov    %eax,0x10(%esp)
  800294:	4e                   	dec    %esi
  800295:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800299:	8b 45 10             	mov    0x10(%ebp),%eax
  80029c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a0:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002a4:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002a8:	89 c3                	mov    %eax,%ebx
  8002aa:	89 d6                	mov    %edx,%esi
  8002ac:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002af:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002bd:	89 04 24             	mov    %eax,(%esp)
  8002c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c7:	e8 94 08 00 00       	call   800b60 <__udivdi3>
  8002cc:	89 d9                	mov    %ebx,%ecx
  8002ce:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002d2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d6:	89 04 24             	mov    %eax,(%esp)
  8002d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002dd:	89 fa                	mov    %edi,%edx
  8002df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002e2:	e8 6d ff ff ff       	call   800254 <printnum>
  8002e7:	eb 19                	jmp    800302 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ed:	8b 45 18             	mov    0x18(%ebp),%eax
  8002f0:	89 04 24             	mov    %eax,(%esp)
  8002f3:	ff d3                	call   *%ebx
  8002f5:	eb 03                	jmp    8002fa <printnum+0xa6>
  8002f7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002fa:	4e                   	dec    %esi
  8002fb:	85 f6                	test   %esi,%esi
  8002fd:	7f ea                	jg     8002e9 <printnum+0x95>
  8002ff:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800302:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800306:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80030a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80030d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800310:	89 44 24 08          	mov    %eax,0x8(%esp)
  800314:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800318:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80031b:	89 04 24             	mov    %eax,(%esp)
  80031e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800321:	89 44 24 04          	mov    %eax,0x4(%esp)
  800325:	e8 66 09 00 00       	call   800c90 <__umoddi3>
  80032a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80032e:	0f be 80 5e 0e 80 00 	movsbl 0x800e5e(%eax),%eax
  800335:	89 04 24             	mov    %eax,(%esp)
  800338:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80033b:	ff d0                	call   *%eax
}
  80033d:	83 c4 3c             	add    $0x3c,%esp
  800340:	5b                   	pop    %ebx
  800341:	5e                   	pop    %esi
  800342:	5f                   	pop    %edi
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    

00800345 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800348:	83 fa 01             	cmp    $0x1,%edx
  80034b:	7e 0e                	jle    80035b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80034d:	8b 10                	mov    (%eax),%edx
  80034f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800352:	89 08                	mov    %ecx,(%eax)
  800354:	8b 02                	mov    (%edx),%eax
  800356:	8b 52 04             	mov    0x4(%edx),%edx
  800359:	eb 22                	jmp    80037d <getuint+0x38>
	else if (lflag)
  80035b:	85 d2                	test   %edx,%edx
  80035d:	74 10                	je     80036f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80035f:	8b 10                	mov    (%eax),%edx
  800361:	8d 4a 04             	lea    0x4(%edx),%ecx
  800364:	89 08                	mov    %ecx,(%eax)
  800366:	8b 02                	mov    (%edx),%eax
  800368:	ba 00 00 00 00       	mov    $0x0,%edx
  80036d:	eb 0e                	jmp    80037d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80036f:	8b 10                	mov    (%eax),%edx
  800371:	8d 4a 04             	lea    0x4(%edx),%ecx
  800374:	89 08                	mov    %ecx,(%eax)
  800376:	8b 02                	mov    (%edx),%eax
  800378:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037d:	5d                   	pop    %ebp
  80037e:	c3                   	ret    

0080037f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
  800382:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800385:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800388:	8b 10                	mov    (%eax),%edx
  80038a:	3b 50 04             	cmp    0x4(%eax),%edx
  80038d:	73 0a                	jae    800399 <sprintputch+0x1a>
		*b->buf++ = ch;
  80038f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800392:	89 08                	mov    %ecx,(%eax)
  800394:	8b 45 08             	mov    0x8(%ebp),%eax
  800397:	88 02                	mov    %al,(%edx)
}
  800399:	5d                   	pop    %ebp
  80039a:	c3                   	ret    

0080039b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b9:	89 04 24             	mov    %eax,(%esp)
  8003bc:	e8 02 00 00 00       	call   8003c3 <vprintfmt>
	va_end(ap);
}
  8003c1:	c9                   	leave  
  8003c2:	c3                   	ret    

008003c3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	57                   	push   %edi
  8003c7:	56                   	push   %esi
  8003c8:	53                   	push   %ebx
  8003c9:	83 ec 3c             	sub    $0x3c,%esp
  8003cc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003d2:	eb 14                	jmp    8003e8 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d4:	85 c0                	test   %eax,%eax
  8003d6:	0f 84 8a 03 00 00    	je     800766 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  8003dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003e0:	89 04 24             	mov    %eax,(%esp)
  8003e3:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e6:	89 f3                	mov    %esi,%ebx
  8003e8:	8d 73 01             	lea    0x1(%ebx),%esi
  8003eb:	31 c0                	xor    %eax,%eax
  8003ed:	8a 03                	mov    (%ebx),%al
  8003ef:	83 f8 25             	cmp    $0x25,%eax
  8003f2:	75 e0                	jne    8003d4 <vprintfmt+0x11>
  8003f4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003f8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003ff:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800406:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80040d:	ba 00 00 00 00       	mov    $0x0,%edx
  800412:	eb 1d                	jmp    800431 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800416:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80041a:	eb 15                	jmp    800431 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80041e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800422:	eb 0d                	jmp    800431 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800424:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800427:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80042a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8d 5e 01             	lea    0x1(%esi),%ebx
  800434:	31 c0                	xor    %eax,%eax
  800436:	8a 06                	mov    (%esi),%al
  800438:	8a 0e                	mov    (%esi),%cl
  80043a:	83 e9 23             	sub    $0x23,%ecx
  80043d:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800440:	80 f9 55             	cmp    $0x55,%cl
  800443:	0f 87 ff 02 00 00    	ja     800748 <vprintfmt+0x385>
  800449:	31 c9                	xor    %ecx,%ecx
  80044b:	8a 4d e0             	mov    -0x20(%ebp),%cl
  80044e:	ff 24 8d 00 0f 80 00 	jmp    *0x800f00(,%ecx,4)
  800455:	89 de                	mov    %ebx,%esi
  800457:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80045c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80045f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800463:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800466:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800469:	83 fb 09             	cmp    $0x9,%ebx
  80046c:	77 2f                	ja     80049d <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80046e:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80046f:	eb eb                	jmp    80045c <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800471:	8b 45 14             	mov    0x14(%ebp),%eax
  800474:	8d 48 04             	lea    0x4(%eax),%ecx
  800477:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80047a:	8b 00                	mov    (%eax),%eax
  80047c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800481:	eb 1d                	jmp    8004a0 <vprintfmt+0xdd>
  800483:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800486:	f7 d0                	not    %eax
  800488:	c1 f8 1f             	sar    $0x1f,%eax
  80048b:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	89 de                	mov    %ebx,%esi
  800490:	eb 9f                	jmp    800431 <vprintfmt+0x6e>
  800492:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800494:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80049b:	eb 94                	jmp    800431 <vprintfmt+0x6e>
  80049d:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004a0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004a4:	79 8b                	jns    800431 <vprintfmt+0x6e>
  8004a6:	e9 79 ff ff ff       	jmp    800424 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ab:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ae:	eb 81                	jmp    800431 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b3:	8d 50 04             	lea    0x4(%eax),%edx
  8004b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004bd:	8b 00                	mov    (%eax),%eax
  8004bf:	89 04 24             	mov    %eax,(%esp)
  8004c2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004c5:	e9 1e ff ff ff       	jmp    8003e8 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cd:	8d 50 04             	lea    0x4(%eax),%edx
  8004d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d3:	8b 00                	mov    (%eax),%eax
  8004d5:	89 c2                	mov    %eax,%edx
  8004d7:	c1 fa 1f             	sar    $0x1f,%edx
  8004da:	31 d0                	xor    %edx,%eax
  8004dc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004de:	83 f8 07             	cmp    $0x7,%eax
  8004e1:	7f 0b                	jg     8004ee <vprintfmt+0x12b>
  8004e3:	8b 14 85 60 10 80 00 	mov    0x801060(,%eax,4),%edx
  8004ea:	85 d2                	test   %edx,%edx
  8004ec:	75 20                	jne    80050e <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  8004ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f2:	c7 44 24 08 76 0e 80 	movl   $0x800e76,0x8(%esp)
  8004f9:	00 
  8004fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800501:	89 04 24             	mov    %eax,(%esp)
  800504:	e8 92 fe ff ff       	call   80039b <printfmt>
  800509:	e9 da fe ff ff       	jmp    8003e8 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80050e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800512:	c7 44 24 08 7f 0e 80 	movl   $0x800e7f,0x8(%esp)
  800519:	00 
  80051a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80051e:	8b 45 08             	mov    0x8(%ebp),%eax
  800521:	89 04 24             	mov    %eax,(%esp)
  800524:	e8 72 fe ff ff       	call   80039b <printfmt>
  800529:	e9 ba fe ff ff       	jmp    8003e8 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800531:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800534:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8d 50 04             	lea    0x4(%eax),%edx
  80053d:	89 55 14             	mov    %edx,0x14(%ebp)
  800540:	8b 30                	mov    (%eax),%esi
  800542:	85 f6                	test   %esi,%esi
  800544:	75 05                	jne    80054b <vprintfmt+0x188>
				p = "(null)";
  800546:	be 6f 0e 80 00       	mov    $0x800e6f,%esi
			if (width > 0 && padc != '-')
  80054b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80054f:	0f 84 8c 00 00 00    	je     8005e1 <vprintfmt+0x21e>
  800555:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800559:	0f 8e 8a 00 00 00    	jle    8005e9 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800563:	89 34 24             	mov    %esi,(%esp)
  800566:	e8 9b 02 00 00       	call   800806 <strnlen>
  80056b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80056e:	29 c1                	sub    %eax,%ecx
  800570:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800573:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800577:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  80057d:	8b 75 08             	mov    0x8(%ebp),%esi
  800580:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800583:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800585:	eb 0d                	jmp    800594 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800587:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80058e:	89 04 24             	mov    %eax,(%esp)
  800591:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800593:	4b                   	dec    %ebx
  800594:	85 db                	test   %ebx,%ebx
  800596:	7f ef                	jg     800587 <vprintfmt+0x1c4>
  800598:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80059b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80059e:	89 c8                	mov    %ecx,%eax
  8005a0:	f7 d0                	not    %eax
  8005a2:	c1 f8 1f             	sar    $0x1f,%eax
  8005a5:	21 c8                	and    %ecx,%eax
  8005a7:	29 c1                	sub    %eax,%ecx
  8005a9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ac:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005af:	eb 3e                	jmp    8005ef <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b5:	74 1b                	je     8005d2 <vprintfmt+0x20f>
  8005b7:	0f be d2             	movsbl %dl,%edx
  8005ba:	83 ea 20             	sub    $0x20,%edx
  8005bd:	83 fa 5e             	cmp    $0x5e,%edx
  8005c0:	76 10                	jbe    8005d2 <vprintfmt+0x20f>
					putch('?', putdat);
  8005c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005c6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005cd:	ff 55 08             	call   *0x8(%ebp)
  8005d0:	eb 0a                	jmp    8005dc <vprintfmt+0x219>
				else
					putch(ch, putdat);
  8005d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d6:	89 04 24             	mov    %eax,(%esp)
  8005d9:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005dc:	ff 4d dc             	decl   -0x24(%ebp)
  8005df:	eb 0e                	jmp    8005ef <vprintfmt+0x22c>
  8005e1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005e4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005e7:	eb 06                	jmp    8005ef <vprintfmt+0x22c>
  8005e9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005ec:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005ef:	46                   	inc    %esi
  8005f0:	8a 56 ff             	mov    -0x1(%esi),%dl
  8005f3:	0f be c2             	movsbl %dl,%eax
  8005f6:	85 c0                	test   %eax,%eax
  8005f8:	74 1f                	je     800619 <vprintfmt+0x256>
  8005fa:	85 db                	test   %ebx,%ebx
  8005fc:	78 b3                	js     8005b1 <vprintfmt+0x1ee>
  8005fe:	4b                   	dec    %ebx
  8005ff:	79 b0                	jns    8005b1 <vprintfmt+0x1ee>
  800601:	8b 75 08             	mov    0x8(%ebp),%esi
  800604:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800607:	eb 16                	jmp    80061f <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800609:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80060d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800614:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800616:	4b                   	dec    %ebx
  800617:	eb 06                	jmp    80061f <vprintfmt+0x25c>
  800619:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80061c:	8b 75 08             	mov    0x8(%ebp),%esi
  80061f:	85 db                	test   %ebx,%ebx
  800621:	7f e6                	jg     800609 <vprintfmt+0x246>
  800623:	89 75 08             	mov    %esi,0x8(%ebp)
  800626:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800629:	e9 ba fd ff ff       	jmp    8003e8 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80062e:	83 fa 01             	cmp    $0x1,%edx
  800631:	7e 16                	jle    800649 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8d 50 08             	lea    0x8(%eax),%edx
  800639:	89 55 14             	mov    %edx,0x14(%ebp)
  80063c:	8b 50 04             	mov    0x4(%eax),%edx
  80063f:	8b 00                	mov    (%eax),%eax
  800641:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800644:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800647:	eb 32                	jmp    80067b <vprintfmt+0x2b8>
	else if (lflag)
  800649:	85 d2                	test   %edx,%edx
  80064b:	74 18                	je     800665 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8d 50 04             	lea    0x4(%eax),%edx
  800653:	89 55 14             	mov    %edx,0x14(%ebp)
  800656:	8b 30                	mov    (%eax),%esi
  800658:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80065b:	89 f0                	mov    %esi,%eax
  80065d:	c1 f8 1f             	sar    $0x1f,%eax
  800660:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800663:	eb 16                	jmp    80067b <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8d 50 04             	lea    0x4(%eax),%edx
  80066b:	89 55 14             	mov    %edx,0x14(%ebp)
  80066e:	8b 30                	mov    (%eax),%esi
  800670:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800673:	89 f0                	mov    %esi,%eax
  800675:	c1 f8 1f             	sar    $0x1f,%eax
  800678:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80067b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80067e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800681:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800686:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80068a:	0f 89 80 00 00 00    	jns    800710 <vprintfmt+0x34d>
				putch('-', putdat);
  800690:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800694:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80069b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80069e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006a1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006a4:	f7 d8                	neg    %eax
  8006a6:	83 d2 00             	adc    $0x0,%edx
  8006a9:	f7 da                	neg    %edx
			}
			base = 10;
  8006ab:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006b0:	eb 5e                	jmp    800710 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b5:	e8 8b fc ff ff       	call   800345 <getuint>
			base = 10;
  8006ba:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006bf:	eb 4f                	jmp    800710 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  8006c1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c4:	e8 7c fc ff ff       	call   800345 <getuint>
			base = 8;
  8006c9:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006ce:	eb 40                	jmp    800710 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  8006d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006db:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006de:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006e2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006e9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ef:	8d 50 04             	lea    0x4(%eax),%edx
  8006f2:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006f5:	8b 00                	mov    (%eax),%eax
  8006f7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006fc:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800701:	eb 0d                	jmp    800710 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800703:	8d 45 14             	lea    0x14(%ebp),%eax
  800706:	e8 3a fc ff ff       	call   800345 <getuint>
			base = 16;
  80070b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800710:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800714:	89 74 24 10          	mov    %esi,0x10(%esp)
  800718:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80071b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80071f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800723:	89 04 24             	mov    %eax,(%esp)
  800726:	89 54 24 04          	mov    %edx,0x4(%esp)
  80072a:	89 fa                	mov    %edi,%edx
  80072c:	8b 45 08             	mov    0x8(%ebp),%eax
  80072f:	e8 20 fb ff ff       	call   800254 <printnum>
			break;
  800734:	e9 af fc ff ff       	jmp    8003e8 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800739:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80073d:	89 04 24             	mov    %eax,(%esp)
  800740:	ff 55 08             	call   *0x8(%ebp)
			break;
  800743:	e9 a0 fc ff ff       	jmp    8003e8 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800748:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80074c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800753:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800756:	89 f3                	mov    %esi,%ebx
  800758:	eb 01                	jmp    80075b <vprintfmt+0x398>
  80075a:	4b                   	dec    %ebx
  80075b:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80075f:	75 f9                	jne    80075a <vprintfmt+0x397>
  800761:	e9 82 fc ff ff       	jmp    8003e8 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800766:	83 c4 3c             	add    $0x3c,%esp
  800769:	5b                   	pop    %ebx
  80076a:	5e                   	pop    %esi
  80076b:	5f                   	pop    %edi
  80076c:	5d                   	pop    %ebp
  80076d:	c3                   	ret    

0080076e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	83 ec 28             	sub    $0x28,%esp
  800774:	8b 45 08             	mov    0x8(%ebp),%eax
  800777:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800781:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800784:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078b:	85 c0                	test   %eax,%eax
  80078d:	74 30                	je     8007bf <vsnprintf+0x51>
  80078f:	85 d2                	test   %edx,%edx
  800791:	7e 2c                	jle    8007bf <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079a:	8b 45 10             	mov    0x10(%ebp),%eax
  80079d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a8:	c7 04 24 7f 03 80 00 	movl   $0x80037f,(%esp)
  8007af:	e8 0f fc ff ff       	call   8003c3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007bd:	eb 05                	jmp    8007c4 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007cc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e4:	89 04 24             	mov    %eax,(%esp)
  8007e7:	e8 82 ff ff ff       	call   80076e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    
  8007ee:	66 90                	xchg   %ax,%ax

008007f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fb:	eb 01                	jmp    8007fe <strlen+0xe>
		n++;
  8007fd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fe:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800802:	75 f9                	jne    8007fd <strlen+0xd>
		n++;
	return n;
}
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080f:	b8 00 00 00 00       	mov    $0x0,%eax
  800814:	eb 01                	jmp    800817 <strnlen+0x11>
		n++;
  800816:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800817:	39 d0                	cmp    %edx,%eax
  800819:	74 06                	je     800821 <strnlen+0x1b>
  80081b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80081f:	75 f5                	jne    800816 <strnlen+0x10>
		n++;
	return n;
}
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	53                   	push   %ebx
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80082d:	89 c2                	mov    %eax,%edx
  80082f:	42                   	inc    %edx
  800830:	41                   	inc    %ecx
  800831:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800834:	88 5a ff             	mov    %bl,-0x1(%edx)
  800837:	84 db                	test   %bl,%bl
  800839:	75 f4                	jne    80082f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80083b:	5b                   	pop    %ebx
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	53                   	push   %ebx
  800842:	83 ec 08             	sub    $0x8,%esp
  800845:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800848:	89 1c 24             	mov    %ebx,(%esp)
  80084b:	e8 a0 ff ff ff       	call   8007f0 <strlen>
	strcpy(dst + len, src);
  800850:	8b 55 0c             	mov    0xc(%ebp),%edx
  800853:	89 54 24 04          	mov    %edx,0x4(%esp)
  800857:	01 d8                	add    %ebx,%eax
  800859:	89 04 24             	mov    %eax,(%esp)
  80085c:	e8 c2 ff ff ff       	call   800823 <strcpy>
	return dst;
}
  800861:	89 d8                	mov    %ebx,%eax
  800863:	83 c4 08             	add    $0x8,%esp
  800866:	5b                   	pop    %ebx
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	56                   	push   %esi
  80086d:	53                   	push   %ebx
  80086e:	8b 75 08             	mov    0x8(%ebp),%esi
  800871:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800874:	89 f3                	mov    %esi,%ebx
  800876:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800879:	89 f2                	mov    %esi,%edx
  80087b:	eb 0c                	jmp    800889 <strncpy+0x20>
		*dst++ = *src;
  80087d:	42                   	inc    %edx
  80087e:	8a 01                	mov    (%ecx),%al
  800880:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800883:	80 39 01             	cmpb   $0x1,(%ecx)
  800886:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800889:	39 da                	cmp    %ebx,%edx
  80088b:	75 f0                	jne    80087d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80088d:	89 f0                	mov    %esi,%eax
  80088f:	5b                   	pop    %ebx
  800890:	5e                   	pop    %esi
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
  800898:	8b 75 08             	mov    0x8(%ebp),%esi
  80089b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008a1:	89 f0                	mov    %esi,%eax
  8008a3:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a7:	85 c9                	test   %ecx,%ecx
  8008a9:	75 07                	jne    8008b2 <strlcpy+0x1f>
  8008ab:	eb 18                	jmp    8008c5 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ad:	40                   	inc    %eax
  8008ae:	42                   	inc    %edx
  8008af:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008b2:	39 d8                	cmp    %ebx,%eax
  8008b4:	74 0a                	je     8008c0 <strlcpy+0x2d>
  8008b6:	8a 0a                	mov    (%edx),%cl
  8008b8:	84 c9                	test   %cl,%cl
  8008ba:	75 f1                	jne    8008ad <strlcpy+0x1a>
  8008bc:	89 c2                	mov    %eax,%edx
  8008be:	eb 02                	jmp    8008c2 <strlcpy+0x2f>
  8008c0:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008c2:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008c5:	29 f0                	sub    %esi,%eax
}
  8008c7:	5b                   	pop    %ebx
  8008c8:	5e                   	pop    %esi
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d4:	eb 02                	jmp    8008d8 <strcmp+0xd>
		p++, q++;
  8008d6:	41                   	inc    %ecx
  8008d7:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008d8:	8a 01                	mov    (%ecx),%al
  8008da:	84 c0                	test   %al,%al
  8008dc:	74 04                	je     8008e2 <strcmp+0x17>
  8008de:	3a 02                	cmp    (%edx),%al
  8008e0:	74 f4                	je     8008d6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e2:	25 ff 00 00 00       	and    $0xff,%eax
  8008e7:	8a 0a                	mov    (%edx),%cl
  8008e9:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8008ef:	29 c8                	sub    %ecx,%eax
}
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	53                   	push   %ebx
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fd:	89 c3                	mov    %eax,%ebx
  8008ff:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800902:	eb 02                	jmp    800906 <strncmp+0x13>
		n--, p++, q++;
  800904:	40                   	inc    %eax
  800905:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800906:	39 d8                	cmp    %ebx,%eax
  800908:	74 20                	je     80092a <strncmp+0x37>
  80090a:	8a 08                	mov    (%eax),%cl
  80090c:	84 c9                	test   %cl,%cl
  80090e:	74 04                	je     800914 <strncmp+0x21>
  800910:	3a 0a                	cmp    (%edx),%cl
  800912:	74 f0                	je     800904 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800914:	8a 18                	mov    (%eax),%bl
  800916:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80091c:	89 d8                	mov    %ebx,%eax
  80091e:	8a 1a                	mov    (%edx),%bl
  800920:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800926:	29 d8                	sub    %ebx,%eax
  800928:	eb 05                	jmp    80092f <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80092a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80092f:	5b                   	pop    %ebx
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80093b:	eb 05                	jmp    800942 <strchr+0x10>
		if (*s == c)
  80093d:	38 ca                	cmp    %cl,%dl
  80093f:	74 0c                	je     80094d <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800941:	40                   	inc    %eax
  800942:	8a 10                	mov    (%eax),%dl
  800944:	84 d2                	test   %dl,%dl
  800946:	75 f5                	jne    80093d <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800948:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800958:	eb 05                	jmp    80095f <strfind+0x10>
		if (*s == c)
  80095a:	38 ca                	cmp    %cl,%dl
  80095c:	74 07                	je     800965 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80095e:	40                   	inc    %eax
  80095f:	8a 10                	mov    (%eax),%dl
  800961:	84 d2                	test   %dl,%dl
  800963:	75 f5                	jne    80095a <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	57                   	push   %edi
  80096b:	56                   	push   %esi
  80096c:	53                   	push   %ebx
  80096d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800970:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800973:	85 c9                	test   %ecx,%ecx
  800975:	74 37                	je     8009ae <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800977:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097d:	75 29                	jne    8009a8 <memset+0x41>
  80097f:	f6 c1 03             	test   $0x3,%cl
  800982:	75 24                	jne    8009a8 <memset+0x41>
		c &= 0xFF;
  800984:	31 d2                	xor    %edx,%edx
  800986:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800989:	89 d3                	mov    %edx,%ebx
  80098b:	c1 e3 08             	shl    $0x8,%ebx
  80098e:	89 d6                	mov    %edx,%esi
  800990:	c1 e6 18             	shl    $0x18,%esi
  800993:	89 d0                	mov    %edx,%eax
  800995:	c1 e0 10             	shl    $0x10,%eax
  800998:	09 f0                	or     %esi,%eax
  80099a:	09 c2                	or     %eax,%edx
  80099c:	89 d0                	mov    %edx,%eax
  80099e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009a0:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009a3:	fc                   	cld    
  8009a4:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a6:	eb 06                	jmp    8009ae <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ab:	fc                   	cld    
  8009ac:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ae:	89 f8                	mov    %edi,%eax
  8009b0:	5b                   	pop    %ebx
  8009b1:	5e                   	pop    %esi
  8009b2:	5f                   	pop    %edi
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	57                   	push   %edi
  8009b9:	56                   	push   %esi
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c3:	39 c6                	cmp    %eax,%esi
  8009c5:	73 33                	jae    8009fa <memmove+0x45>
  8009c7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ca:	39 d0                	cmp    %edx,%eax
  8009cc:	73 2c                	jae    8009fa <memmove+0x45>
		s += n;
		d += n;
  8009ce:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009d1:	89 d6                	mov    %edx,%esi
  8009d3:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009db:	75 13                	jne    8009f0 <memmove+0x3b>
  8009dd:	f6 c1 03             	test   $0x3,%cl
  8009e0:	75 0e                	jne    8009f0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009e2:	83 ef 04             	sub    $0x4,%edi
  8009e5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009eb:	fd                   	std    
  8009ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ee:	eb 07                	jmp    8009f7 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009f0:	4f                   	dec    %edi
  8009f1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009f4:	fd                   	std    
  8009f5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f7:	fc                   	cld    
  8009f8:	eb 1d                	jmp    800a17 <memmove+0x62>
  8009fa:	89 f2                	mov    %esi,%edx
  8009fc:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fe:	f6 c2 03             	test   $0x3,%dl
  800a01:	75 0f                	jne    800a12 <memmove+0x5d>
  800a03:	f6 c1 03             	test   $0x3,%cl
  800a06:	75 0a                	jne    800a12 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a08:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a0b:	89 c7                	mov    %eax,%edi
  800a0d:	fc                   	cld    
  800a0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a10:	eb 05                	jmp    800a17 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a12:	89 c7                	mov    %eax,%edi
  800a14:	fc                   	cld    
  800a15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a17:	5e                   	pop    %esi
  800a18:	5f                   	pop    %edi
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a21:	8b 45 10             	mov    0x10(%ebp),%eax
  800a24:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	89 04 24             	mov    %eax,(%esp)
  800a35:	e8 7b ff ff ff       	call   8009b5 <memmove>
}
  800a3a:	c9                   	leave  
  800a3b:	c3                   	ret    

00800a3c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	8b 55 08             	mov    0x8(%ebp),%edx
  800a44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a47:	89 d6                	mov    %edx,%esi
  800a49:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4c:	eb 19                	jmp    800a67 <memcmp+0x2b>
		if (*s1 != *s2)
  800a4e:	8a 02                	mov    (%edx),%al
  800a50:	8a 19                	mov    (%ecx),%bl
  800a52:	38 d8                	cmp    %bl,%al
  800a54:	74 0f                	je     800a65 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800a56:	25 ff 00 00 00       	and    $0xff,%eax
  800a5b:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800a61:	29 d8                	sub    %ebx,%eax
  800a63:	eb 0b                	jmp    800a70 <memcmp+0x34>
		s1++, s2++;
  800a65:	42                   	inc    %edx
  800a66:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a67:	39 f2                	cmp    %esi,%edx
  800a69:	75 e3                	jne    800a4e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a7d:	89 c2                	mov    %eax,%edx
  800a7f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a82:	eb 05                	jmp    800a89 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a84:	38 08                	cmp    %cl,(%eax)
  800a86:	74 05                	je     800a8d <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a88:	40                   	inc    %eax
  800a89:	39 d0                	cmp    %edx,%eax
  800a8b:	72 f7                	jb     800a84 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	57                   	push   %edi
  800a93:	56                   	push   %esi
  800a94:	53                   	push   %ebx
  800a95:	8b 55 08             	mov    0x8(%ebp),%edx
  800a98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9b:	eb 01                	jmp    800a9e <strtol+0xf>
		s++;
  800a9d:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9e:	8a 02                	mov    (%edx),%al
  800aa0:	3c 09                	cmp    $0x9,%al
  800aa2:	74 f9                	je     800a9d <strtol+0xe>
  800aa4:	3c 20                	cmp    $0x20,%al
  800aa6:	74 f5                	je     800a9d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aa8:	3c 2b                	cmp    $0x2b,%al
  800aaa:	75 08                	jne    800ab4 <strtol+0x25>
		s++;
  800aac:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aad:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab2:	eb 10                	jmp    800ac4 <strtol+0x35>
  800ab4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ab9:	3c 2d                	cmp    $0x2d,%al
  800abb:	75 07                	jne    800ac4 <strtol+0x35>
		s++, neg = 1;
  800abd:	8d 52 01             	lea    0x1(%edx),%edx
  800ac0:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aca:	75 15                	jne    800ae1 <strtol+0x52>
  800acc:	80 3a 30             	cmpb   $0x30,(%edx)
  800acf:	75 10                	jne    800ae1 <strtol+0x52>
  800ad1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ad5:	75 0a                	jne    800ae1 <strtol+0x52>
		s += 2, base = 16;
  800ad7:	83 c2 02             	add    $0x2,%edx
  800ada:	bb 10 00 00 00       	mov    $0x10,%ebx
  800adf:	eb 0e                	jmp    800aef <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800ae1:	85 db                	test   %ebx,%ebx
  800ae3:	75 0a                	jne    800aef <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ae5:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae7:	80 3a 30             	cmpb   $0x30,(%edx)
  800aea:	75 03                	jne    800aef <strtol+0x60>
		s++, base = 8;
  800aec:	42                   	inc    %edx
  800aed:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800aef:	b8 00 00 00 00       	mov    $0x0,%eax
  800af4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af7:	8a 0a                	mov    (%edx),%cl
  800af9:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800afc:	89 f3                	mov    %esi,%ebx
  800afe:	80 fb 09             	cmp    $0x9,%bl
  800b01:	77 08                	ja     800b0b <strtol+0x7c>
			dig = *s - '0';
  800b03:	0f be c9             	movsbl %cl,%ecx
  800b06:	83 e9 30             	sub    $0x30,%ecx
  800b09:	eb 22                	jmp    800b2d <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800b0b:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b0e:	89 f3                	mov    %esi,%ebx
  800b10:	80 fb 19             	cmp    $0x19,%bl
  800b13:	77 08                	ja     800b1d <strtol+0x8e>
			dig = *s - 'a' + 10;
  800b15:	0f be c9             	movsbl %cl,%ecx
  800b18:	83 e9 57             	sub    $0x57,%ecx
  800b1b:	eb 10                	jmp    800b2d <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800b1d:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b20:	89 f3                	mov    %esi,%ebx
  800b22:	80 fb 19             	cmp    $0x19,%bl
  800b25:	77 14                	ja     800b3b <strtol+0xac>
			dig = *s - 'A' + 10;
  800b27:	0f be c9             	movsbl %cl,%ecx
  800b2a:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b2d:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b30:	7d 0d                	jge    800b3f <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b32:	42                   	inc    %edx
  800b33:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b37:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b39:	eb bc                	jmp    800af7 <strtol+0x68>
  800b3b:	89 c1                	mov    %eax,%ecx
  800b3d:	eb 02                	jmp    800b41 <strtol+0xb2>
  800b3f:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b41:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b45:	74 05                	je     800b4c <strtol+0xbd>
		*endptr = (char *) s;
  800b47:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4a:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b4c:	85 ff                	test   %edi,%edi
  800b4e:	74 04                	je     800b54 <strtol+0xc5>
  800b50:	89 c8                	mov    %ecx,%eax
  800b52:	f7 d8                	neg    %eax
}
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    
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
