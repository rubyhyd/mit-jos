
obj/user/sendpage:     file format elf32-i386


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
  80002c:	e8 af 01 00 00       	call   8001e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 28             	sub    $0x28,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  80003a:	e8 a6 0f 00 00       	call   800fe5 <fork>
  80003f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800042:	85 c0                	test   %eax,%eax
  800044:	0f 85 bb 00 00 00    	jne    800105 <umain+0xd1>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  80004a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800051:	00 
  800052:	c7 44 24 04 00 00 b0 	movl   $0xb00000,0x4(%esp)
  800059:	00 
  80005a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80005d:	89 04 24             	mov    %eax,(%esp)
  800060:	e8 d3 11 00 00       	call   801238 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800065:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  80006c:	00 
  80006d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800070:	89 44 24 04          	mov    %eax,0x4(%esp)
  800074:	c7 04 24 60 16 80 00 	movl   $0x801660,(%esp)
  80007b:	e8 8a 02 00 00       	call   80030a <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800080:	a1 04 20 80 00       	mov    0x802004,%eax
  800085:	89 04 24             	mov    %eax,(%esp)
  800088:	e8 33 08 00 00       	call   8008c0 <strlen>
  80008d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800091:	a1 04 20 80 00       	mov    0x802004,%eax
  800096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009a:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a1:	e8 1d 09 00 00       	call   8009c3 <strncmp>
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 0c                	jne    8000b6 <umain+0x82>
			cprintf("child received correct message\n");
  8000aa:	c7 04 24 74 16 80 00 	movl   $0x801674,(%esp)
  8000b1:	e8 54 02 00 00       	call   80030a <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000b6:	a1 00 20 80 00       	mov    0x802000,%eax
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 fd 07 00 00       	call   8008c0 <strlen>
  8000c3:	40                   	inc    %eax
  8000c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c8:	a1 00 20 80 00       	mov    0x802000,%eax
  8000cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d1:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000d8:	e8 0e 0a 00 00       	call   800aeb <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000dd:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000f4:	00 
  8000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000f8:	89 04 24             	mov    %eax,(%esp)
  8000fb:	e8 5a 11 00 00       	call   80125a <ipc_send>
		return;
  800100:	e9 d6 00 00 00       	jmp    8001db <umain+0x1a7>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800105:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80010a:	8b 40 48             	mov    0x48(%eax),%eax
  80010d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800114:	00 
  800115:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80011c:	00 
  80011d:	89 04 24             	mov    %eax,(%esp)
  800120:	e8 d4 0b 00 00       	call   800cf9 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800125:	a1 04 20 80 00       	mov    0x802004,%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 8e 07 00 00       	call   8008c0 <strlen>
  800132:	40                   	inc    %eax
  800133:	89 44 24 08          	mov    %eax,0x8(%esp)
  800137:	a1 04 20 80 00       	mov    0x802004,%eax
  80013c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800140:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  800147:	e8 9f 09 00 00       	call   800aeb <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80014c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800153:	00 
  800154:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80015b:	00 
  80015c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800163:	00 
  800164:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800167:	89 04 24             	mov    %eax,(%esp)
  80016a:	e8 eb 10 00 00       	call   80125a <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  80016f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800176:	00 
  800177:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80017e:	00 
  80017f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800182:	89 04 24             	mov    %eax,(%esp)
  800185:	e8 ae 10 00 00       	call   801238 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80018a:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  800191:	00 
  800192:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	c7 04 24 60 16 80 00 	movl   $0x801660,(%esp)
  8001a0:	e8 65 01 00 00       	call   80030a <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001a5:	a1 00 20 80 00       	mov    0x802000,%eax
  8001aa:	89 04 24             	mov    %eax,(%esp)
  8001ad:	e8 0e 07 00 00       	call   8008c0 <strlen>
  8001b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b6:	a1 00 20 80 00       	mov    0x802000,%eax
  8001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bf:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001c6:	e8 f8 07 00 00       	call   8009c3 <strncmp>
  8001cb:	85 c0                	test   %eax,%eax
  8001cd:	75 0c                	jne    8001db <umain+0x1a7>
		cprintf("parent received correct message\n");
  8001cf:	c7 04 24 94 16 80 00 	movl   $0x801694,(%esp)
  8001d6:	e8 2f 01 00 00       	call   80030a <cprintf>
	return;
}
  8001db:	c9                   	leave  
  8001dc:	c3                   	ret    
  8001dd:	66 90                	xchg   %ax,%ax
  8001df:	90                   	nop

008001e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 10             	sub    $0x10,%esp
  8001e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  8001ee:	b8 14 20 80 00       	mov    $0x802014,%eax
  8001f3:	2d 0c 20 80 00       	sub    $0x80200c,%eax
  8001f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800203:	00 
  800204:	c7 04 24 0c 20 80 00 	movl   $0x80200c,(%esp)
  80020b:	e8 27 08 00 00       	call   800a37 <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  800210:	e8 a6 0a 00 00       	call   800cbb <sys_getenvid>
  800215:	25 ff 03 00 00       	and    $0x3ff,%eax
  80021a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800221:	c1 e0 07             	shl    $0x7,%eax
  800224:	29 d0                	sub    %edx,%eax
  800226:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80022b:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800230:	85 db                	test   %ebx,%ebx
  800232:	7e 07                	jle    80023b <libmain+0x5b>
		binaryname = argv[0];
  800234:	8b 06                	mov    (%esi),%eax
  800236:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  80023b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80023f:	89 1c 24             	mov    %ebx,(%esp)
  800242:	e8 ed fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800247:	e8 08 00 00 00       	call   800254 <exit>
}
  80024c:	83 c4 10             	add    $0x10,%esp
  80024f:	5b                   	pop    %ebx
  800250:	5e                   	pop    %esi
  800251:	5d                   	pop    %ebp
  800252:	c3                   	ret    
  800253:	90                   	nop

00800254 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80025a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800261:	e8 03 0a 00 00       	call   800c69 <sys_env_destroy>
}
  800266:	c9                   	leave  
  800267:	c3                   	ret    

00800268 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	53                   	push   %ebx
  80026c:	83 ec 14             	sub    $0x14,%esp
  80026f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800272:	8b 13                	mov    (%ebx),%edx
  800274:	8d 42 01             	lea    0x1(%edx),%eax
  800277:	89 03                	mov    %eax,(%ebx)
  800279:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800280:	3d ff 00 00 00       	cmp    $0xff,%eax
  800285:	75 19                	jne    8002a0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800287:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80028e:	00 
  80028f:	8d 43 08             	lea    0x8(%ebx),%eax
  800292:	89 04 24             	mov    %eax,(%esp)
  800295:	e8 92 09 00 00       	call   800c2c <sys_cputs>
		b->idx = 0;
  80029a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002a0:	ff 43 04             	incl   0x4(%ebx)
}
  8002a3:	83 c4 14             	add    $0x14,%esp
  8002a6:	5b                   	pop    %ebx
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002b2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002b9:	00 00 00 
	b.cnt = 0;
  8002bc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002c3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002de:	c7 04 24 68 02 80 00 	movl   $0x800268,(%esp)
  8002e5:	e8 a9 01 00 00       	call   800493 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ea:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002fa:	89 04 24             	mov    %eax,(%esp)
  8002fd:	e8 2a 09 00 00       	call   800c2c <sys_cputs>

	return b.cnt;
}
  800302:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800308:	c9                   	leave  
  800309:	c3                   	ret    

0080030a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800310:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800313:	89 44 24 04          	mov    %eax,0x4(%esp)
  800317:	8b 45 08             	mov    0x8(%ebp),%eax
  80031a:	89 04 24             	mov    %eax,(%esp)
  80031d:	e8 87 ff ff ff       	call   8002a9 <vcprintf>
	va_end(ap);

	return cnt;
}
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	57                   	push   %edi
  800328:	56                   	push   %esi
  800329:	53                   	push   %ebx
  80032a:	83 ec 3c             	sub    $0x3c,%esp
  80032d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800330:	89 d7                	mov    %edx,%edi
  800332:	8b 45 08             	mov    0x8(%ebp),%eax
  800335:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800338:	8b 45 0c             	mov    0xc(%ebp),%eax
  80033b:	89 c1                	mov    %eax,%ecx
  80033d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800340:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800343:	8b 45 10             	mov    0x10(%ebp),%eax
  800346:	ba 00 00 00 00       	mov    $0x0,%edx
  80034b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80034e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800351:	39 ca                	cmp    %ecx,%edx
  800353:	72 08                	jb     80035d <printnum+0x39>
  800355:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800358:	39 45 10             	cmp    %eax,0x10(%ebp)
  80035b:	77 6a                	ja     8003c7 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80035d:	8b 45 18             	mov    0x18(%ebp),%eax
  800360:	89 44 24 10          	mov    %eax,0x10(%esp)
  800364:	4e                   	dec    %esi
  800365:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800369:	8b 45 10             	mov    0x10(%ebp),%eax
  80036c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800370:	8b 44 24 08          	mov    0x8(%esp),%eax
  800374:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800378:	89 c3                	mov    %eax,%ebx
  80037a:	89 d6                	mov    %edx,%esi
  80037c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80037f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800382:	89 44 24 08          	mov    %eax,0x8(%esp)
  800386:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80038a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80038d:	89 04 24             	mov    %eax,(%esp)
  800390:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800393:	89 44 24 04          	mov    %eax,0x4(%esp)
  800397:	e8 14 10 00 00       	call   8013b0 <__udivdi3>
  80039c:	89 d9                	mov    %ebx,%ecx
  80039e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003a2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003a6:	89 04 24             	mov    %eax,(%esp)
  8003a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003ad:	89 fa                	mov    %edi,%edx
  8003af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003b2:	e8 6d ff ff ff       	call   800324 <printnum>
  8003b7:	eb 19                	jmp    8003d2 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003bd:	8b 45 18             	mov    0x18(%ebp),%eax
  8003c0:	89 04 24             	mov    %eax,(%esp)
  8003c3:	ff d3                	call   *%ebx
  8003c5:	eb 03                	jmp    8003ca <printnum+0xa6>
  8003c7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003ca:	4e                   	dec    %esi
  8003cb:	85 f6                	test   %esi,%esi
  8003cd:	7f ea                	jg     8003b9 <printnum+0x95>
  8003cf:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003d6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003da:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003dd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003eb:	89 04 24             	mov    %eax,(%esp)
  8003ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f5:	e8 e6 10 00 00       	call   8014e0 <__umoddi3>
  8003fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003fe:	0f be 80 0c 17 80 00 	movsbl 0x80170c(%eax),%eax
  800405:	89 04 24             	mov    %eax,(%esp)
  800408:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80040b:	ff d0                	call   *%eax
}
  80040d:	83 c4 3c             	add    $0x3c,%esp
  800410:	5b                   	pop    %ebx
  800411:	5e                   	pop    %esi
  800412:	5f                   	pop    %edi
  800413:	5d                   	pop    %ebp
  800414:	c3                   	ret    

00800415 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800415:	55                   	push   %ebp
  800416:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800418:	83 fa 01             	cmp    $0x1,%edx
  80041b:	7e 0e                	jle    80042b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80041d:	8b 10                	mov    (%eax),%edx
  80041f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800422:	89 08                	mov    %ecx,(%eax)
  800424:	8b 02                	mov    (%edx),%eax
  800426:	8b 52 04             	mov    0x4(%edx),%edx
  800429:	eb 22                	jmp    80044d <getuint+0x38>
	else if (lflag)
  80042b:	85 d2                	test   %edx,%edx
  80042d:	74 10                	je     80043f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80042f:	8b 10                	mov    (%eax),%edx
  800431:	8d 4a 04             	lea    0x4(%edx),%ecx
  800434:	89 08                	mov    %ecx,(%eax)
  800436:	8b 02                	mov    (%edx),%eax
  800438:	ba 00 00 00 00       	mov    $0x0,%edx
  80043d:	eb 0e                	jmp    80044d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80043f:	8b 10                	mov    (%eax),%edx
  800441:	8d 4a 04             	lea    0x4(%edx),%ecx
  800444:	89 08                	mov    %ecx,(%eax)
  800446:	8b 02                	mov    (%edx),%eax
  800448:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80044d:	5d                   	pop    %ebp
  80044e:	c3                   	ret    

0080044f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800455:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800458:	8b 10                	mov    (%eax),%edx
  80045a:	3b 50 04             	cmp    0x4(%eax),%edx
  80045d:	73 0a                	jae    800469 <sprintputch+0x1a>
		*b->buf++ = ch;
  80045f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800462:	89 08                	mov    %ecx,(%eax)
  800464:	8b 45 08             	mov    0x8(%ebp),%eax
  800467:	88 02                	mov    %al,(%edx)
}
  800469:	5d                   	pop    %ebp
  80046a:	c3                   	ret    

0080046b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80046b:	55                   	push   %ebp
  80046c:	89 e5                	mov    %esp,%ebp
  80046e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800471:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800474:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800478:	8b 45 10             	mov    0x10(%ebp),%eax
  80047b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80047f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800482:	89 44 24 04          	mov    %eax,0x4(%esp)
  800486:	8b 45 08             	mov    0x8(%ebp),%eax
  800489:	89 04 24             	mov    %eax,(%esp)
  80048c:	e8 02 00 00 00       	call   800493 <vprintfmt>
	va_end(ap);
}
  800491:	c9                   	leave  
  800492:	c3                   	ret    

00800493 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800493:	55                   	push   %ebp
  800494:	89 e5                	mov    %esp,%ebp
  800496:	57                   	push   %edi
  800497:	56                   	push   %esi
  800498:	53                   	push   %ebx
  800499:	83 ec 3c             	sub    $0x3c,%esp
  80049c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80049f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004a2:	eb 14                	jmp    8004b8 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004a4:	85 c0                	test   %eax,%eax
  8004a6:	0f 84 8a 03 00 00    	je     800836 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  8004ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004b0:	89 04 24             	mov    %eax,(%esp)
  8004b3:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004b6:	89 f3                	mov    %esi,%ebx
  8004b8:	8d 73 01             	lea    0x1(%ebx),%esi
  8004bb:	31 c0                	xor    %eax,%eax
  8004bd:	8a 03                	mov    (%ebx),%al
  8004bf:	83 f8 25             	cmp    $0x25,%eax
  8004c2:	75 e0                	jne    8004a4 <vprintfmt+0x11>
  8004c4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004c8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004cf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004d6:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8004dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e2:	eb 1d                	jmp    800501 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004e6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8004ea:	eb 15                	jmp    800501 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004ee:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004f2:	eb 0d                	jmp    800501 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004f7:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004fa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8d 5e 01             	lea    0x1(%esi),%ebx
  800504:	31 c0                	xor    %eax,%eax
  800506:	8a 06                	mov    (%esi),%al
  800508:	8a 0e                	mov    (%esi),%cl
  80050a:	83 e9 23             	sub    $0x23,%ecx
  80050d:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800510:	80 f9 55             	cmp    $0x55,%cl
  800513:	0f 87 ff 02 00 00    	ja     800818 <vprintfmt+0x385>
  800519:	31 c9                	xor    %ecx,%ecx
  80051b:	8a 4d e0             	mov    -0x20(%ebp),%cl
  80051e:	ff 24 8d e0 17 80 00 	jmp    *0x8017e0(,%ecx,4)
  800525:	89 de                	mov    %ebx,%esi
  800527:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80052c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80052f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800533:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800536:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800539:	83 fb 09             	cmp    $0x9,%ebx
  80053c:	77 2f                	ja     80056d <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80053e:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80053f:	eb eb                	jmp    80052c <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800541:	8b 45 14             	mov    0x14(%ebp),%eax
  800544:	8d 48 04             	lea    0x4(%eax),%ecx
  800547:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80054a:	8b 00                	mov    (%eax),%eax
  80054c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800551:	eb 1d                	jmp    800570 <vprintfmt+0xdd>
  800553:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800556:	f7 d0                	not    %eax
  800558:	c1 f8 1f             	sar    $0x1f,%eax
  80055b:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055e:	89 de                	mov    %ebx,%esi
  800560:	eb 9f                	jmp    800501 <vprintfmt+0x6e>
  800562:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800564:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80056b:	eb 94                	jmp    800501 <vprintfmt+0x6e>
  80056d:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800570:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800574:	79 8b                	jns    800501 <vprintfmt+0x6e>
  800576:	e9 79 ff ff ff       	jmp    8004f4 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80057b:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057c:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80057e:	eb 81                	jmp    800501 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8d 50 04             	lea    0x4(%eax),%edx
  800586:	89 55 14             	mov    %edx,0x14(%ebp)
  800589:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058d:	8b 00                	mov    (%eax),%eax
  80058f:	89 04 24             	mov    %eax,(%esp)
  800592:	ff 55 08             	call   *0x8(%ebp)
			break;
  800595:	e9 1e ff ff ff       	jmp    8004b8 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 50 04             	lea    0x4(%eax),%edx
  8005a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a3:	8b 00                	mov    (%eax),%eax
  8005a5:	89 c2                	mov    %eax,%edx
  8005a7:	c1 fa 1f             	sar    $0x1f,%edx
  8005aa:	31 d0                	xor    %edx,%eax
  8005ac:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005ae:	83 f8 09             	cmp    $0x9,%eax
  8005b1:	7f 0b                	jg     8005be <vprintfmt+0x12b>
  8005b3:	8b 14 85 40 19 80 00 	mov    0x801940(,%eax,4),%edx
  8005ba:	85 d2                	test   %edx,%edx
  8005bc:	75 20                	jne    8005de <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  8005be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005c2:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  8005c9:	00 
  8005ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d1:	89 04 24             	mov    %eax,(%esp)
  8005d4:	e8 92 fe ff ff       	call   80046b <printfmt>
  8005d9:	e9 da fe ff ff       	jmp    8004b8 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8005de:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005e2:	c7 44 24 08 2d 17 80 	movl   $0x80172d,0x8(%esp)
  8005e9:	00 
  8005ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f1:	89 04 24             	mov    %eax,(%esp)
  8005f4:	e8 72 fe ff ff       	call   80046b <printfmt>
  8005f9:	e9 ba fe ff ff       	jmp    8004b8 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fe:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800601:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800604:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 50 04             	lea    0x4(%eax),%edx
  80060d:	89 55 14             	mov    %edx,0x14(%ebp)
  800610:	8b 30                	mov    (%eax),%esi
  800612:	85 f6                	test   %esi,%esi
  800614:	75 05                	jne    80061b <vprintfmt+0x188>
				p = "(null)";
  800616:	be 1d 17 80 00       	mov    $0x80171d,%esi
			if (width > 0 && padc != '-')
  80061b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80061f:	0f 84 8c 00 00 00    	je     8006b1 <vprintfmt+0x21e>
  800625:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800629:	0f 8e 8a 00 00 00    	jle    8006b9 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  80062f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800633:	89 34 24             	mov    %esi,(%esp)
  800636:	e8 9b 02 00 00       	call   8008d6 <strnlen>
  80063b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80063e:	29 c1                	sub    %eax,%ecx
  800640:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800643:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800647:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80064a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  80064d:	8b 75 08             	mov    0x8(%ebp),%esi
  800650:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800653:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800655:	eb 0d                	jmp    800664 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800657:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80065b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80065e:	89 04 24             	mov    %eax,(%esp)
  800661:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800663:	4b                   	dec    %ebx
  800664:	85 db                	test   %ebx,%ebx
  800666:	7f ef                	jg     800657 <vprintfmt+0x1c4>
  800668:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80066b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80066e:	89 c8                	mov    %ecx,%eax
  800670:	f7 d0                	not    %eax
  800672:	c1 f8 1f             	sar    $0x1f,%eax
  800675:	21 c8                	and    %ecx,%eax
  800677:	29 c1                	sub    %eax,%ecx
  800679:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80067c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80067f:	eb 3e                	jmp    8006bf <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800681:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800685:	74 1b                	je     8006a2 <vprintfmt+0x20f>
  800687:	0f be d2             	movsbl %dl,%edx
  80068a:	83 ea 20             	sub    $0x20,%edx
  80068d:	83 fa 5e             	cmp    $0x5e,%edx
  800690:	76 10                	jbe    8006a2 <vprintfmt+0x20f>
					putch('?', putdat);
  800692:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800696:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80069d:	ff 55 08             	call   *0x8(%ebp)
  8006a0:	eb 0a                	jmp    8006ac <vprintfmt+0x219>
				else
					putch(ch, putdat);
  8006a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a6:	89 04 24             	mov    %eax,(%esp)
  8006a9:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ac:	ff 4d dc             	decl   -0x24(%ebp)
  8006af:	eb 0e                	jmp    8006bf <vprintfmt+0x22c>
  8006b1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006b4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006b7:	eb 06                	jmp    8006bf <vprintfmt+0x22c>
  8006b9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006bc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006bf:	46                   	inc    %esi
  8006c0:	8a 56 ff             	mov    -0x1(%esi),%dl
  8006c3:	0f be c2             	movsbl %dl,%eax
  8006c6:	85 c0                	test   %eax,%eax
  8006c8:	74 1f                	je     8006e9 <vprintfmt+0x256>
  8006ca:	85 db                	test   %ebx,%ebx
  8006cc:	78 b3                	js     800681 <vprintfmt+0x1ee>
  8006ce:	4b                   	dec    %ebx
  8006cf:	79 b0                	jns    800681 <vprintfmt+0x1ee>
  8006d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d4:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006d7:	eb 16                	jmp    8006ef <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006dd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006e4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e6:	4b                   	dec    %ebx
  8006e7:	eb 06                	jmp    8006ef <vprintfmt+0x25c>
  8006e9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ef:	85 db                	test   %ebx,%ebx
  8006f1:	7f e6                	jg     8006d9 <vprintfmt+0x246>
  8006f3:	89 75 08             	mov    %esi,0x8(%ebp)
  8006f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006f9:	e9 ba fd ff ff       	jmp    8004b8 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006fe:	83 fa 01             	cmp    $0x1,%edx
  800701:	7e 16                	jle    800719 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  800703:	8b 45 14             	mov    0x14(%ebp),%eax
  800706:	8d 50 08             	lea    0x8(%eax),%edx
  800709:	89 55 14             	mov    %edx,0x14(%ebp)
  80070c:	8b 50 04             	mov    0x4(%eax),%edx
  80070f:	8b 00                	mov    (%eax),%eax
  800711:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800714:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800717:	eb 32                	jmp    80074b <vprintfmt+0x2b8>
	else if (lflag)
  800719:	85 d2                	test   %edx,%edx
  80071b:	74 18                	je     800735 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  80071d:	8b 45 14             	mov    0x14(%ebp),%eax
  800720:	8d 50 04             	lea    0x4(%eax),%edx
  800723:	89 55 14             	mov    %edx,0x14(%ebp)
  800726:	8b 30                	mov    (%eax),%esi
  800728:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80072b:	89 f0                	mov    %esi,%eax
  80072d:	c1 f8 1f             	sar    $0x1f,%eax
  800730:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800733:	eb 16                	jmp    80074b <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800735:	8b 45 14             	mov    0x14(%ebp),%eax
  800738:	8d 50 04             	lea    0x4(%eax),%edx
  80073b:	89 55 14             	mov    %edx,0x14(%ebp)
  80073e:	8b 30                	mov    (%eax),%esi
  800740:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800743:	89 f0                	mov    %esi,%eax
  800745:	c1 f8 1f             	sar    $0x1f,%eax
  800748:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80074b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80074e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800751:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800756:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80075a:	0f 89 80 00 00 00    	jns    8007e0 <vprintfmt+0x34d>
				putch('-', putdat);
  800760:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800764:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80076b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80076e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800771:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800774:	f7 d8                	neg    %eax
  800776:	83 d2 00             	adc    $0x0,%edx
  800779:	f7 da                	neg    %edx
			}
			base = 10;
  80077b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800780:	eb 5e                	jmp    8007e0 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800782:	8d 45 14             	lea    0x14(%ebp),%eax
  800785:	e8 8b fc ff ff       	call   800415 <getuint>
			base = 10;
  80078a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80078f:	eb 4f                	jmp    8007e0 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800791:	8d 45 14             	lea    0x14(%ebp),%eax
  800794:	e8 7c fc ff ff       	call   800415 <getuint>
			base = 8;
  800799:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80079e:	eb 40                	jmp    8007e0 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  8007a0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007a4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007ab:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007ae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007b2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007b9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bf:	8d 50 04             	lea    0x4(%eax),%edx
  8007c2:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007c5:	8b 00                	mov    (%eax),%eax
  8007c7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007cc:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007d1:	eb 0d                	jmp    8007e0 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d6:	e8 3a fc ff ff       	call   800415 <getuint>
			base = 16;
  8007db:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007e0:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  8007e4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8007e8:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007eb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007ef:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007f3:	89 04 24             	mov    %eax,(%esp)
  8007f6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007fa:	89 fa                	mov    %edi,%edx
  8007fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ff:	e8 20 fb ff ff       	call   800324 <printnum>
			break;
  800804:	e9 af fc ff ff       	jmp    8004b8 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800809:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80080d:	89 04 24             	mov    %eax,(%esp)
  800810:	ff 55 08             	call   *0x8(%ebp)
			break;
  800813:	e9 a0 fc ff ff       	jmp    8004b8 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800818:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80081c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800823:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800826:	89 f3                	mov    %esi,%ebx
  800828:	eb 01                	jmp    80082b <vprintfmt+0x398>
  80082a:	4b                   	dec    %ebx
  80082b:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80082f:	75 f9                	jne    80082a <vprintfmt+0x397>
  800831:	e9 82 fc ff ff       	jmp    8004b8 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800836:	83 c4 3c             	add    $0x3c,%esp
  800839:	5b                   	pop    %ebx
  80083a:	5e                   	pop    %esi
  80083b:	5f                   	pop    %edi
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	83 ec 28             	sub    $0x28,%esp
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80084a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800851:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800854:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80085b:	85 c0                	test   %eax,%eax
  80085d:	74 30                	je     80088f <vsnprintf+0x51>
  80085f:	85 d2                	test   %edx,%edx
  800861:	7e 2c                	jle    80088f <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800863:	8b 45 14             	mov    0x14(%ebp),%eax
  800866:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80086a:	8b 45 10             	mov    0x10(%ebp),%eax
  80086d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800871:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800874:	89 44 24 04          	mov    %eax,0x4(%esp)
  800878:	c7 04 24 4f 04 80 00 	movl   $0x80044f,(%esp)
  80087f:	e8 0f fc ff ff       	call   800493 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800884:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800887:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80088a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80088d:	eb 05                	jmp    800894 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80088f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800894:	c9                   	leave  
  800895:	c3                   	ret    

00800896 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80089c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80089f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	89 04 24             	mov    %eax,(%esp)
  8008b7:	e8 82 ff ff ff       	call   80083e <vsnprintf>
	va_end(ap);

	return rc;
}
  8008bc:	c9                   	leave  
  8008bd:	c3                   	ret    
  8008be:	66 90                	xchg   %ax,%ax

008008c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cb:	eb 01                	jmp    8008ce <strlen+0xe>
		n++;
  8008cd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ce:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d2:	75 f9                	jne    8008cd <strlen+0xd>
		n++;
	return n;
}
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008df:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e4:	eb 01                	jmp    8008e7 <strnlen+0x11>
		n++;
  8008e6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e7:	39 d0                	cmp    %edx,%eax
  8008e9:	74 06                	je     8008f1 <strnlen+0x1b>
  8008eb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008ef:	75 f5                	jne    8008e6 <strnlen+0x10>
		n++;
	return n;
}
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	53                   	push   %ebx
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008fd:	89 c2                	mov    %eax,%edx
  8008ff:	42                   	inc    %edx
  800900:	41                   	inc    %ecx
  800901:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800904:	88 5a ff             	mov    %bl,-0x1(%edx)
  800907:	84 db                	test   %bl,%bl
  800909:	75 f4                	jne    8008ff <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80090b:	5b                   	pop    %ebx
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	53                   	push   %ebx
  800912:	83 ec 08             	sub    $0x8,%esp
  800915:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800918:	89 1c 24             	mov    %ebx,(%esp)
  80091b:	e8 a0 ff ff ff       	call   8008c0 <strlen>
	strcpy(dst + len, src);
  800920:	8b 55 0c             	mov    0xc(%ebp),%edx
  800923:	89 54 24 04          	mov    %edx,0x4(%esp)
  800927:	01 d8                	add    %ebx,%eax
  800929:	89 04 24             	mov    %eax,(%esp)
  80092c:	e8 c2 ff ff ff       	call   8008f3 <strcpy>
	return dst;
}
  800931:	89 d8                	mov    %ebx,%eax
  800933:	83 c4 08             	add    $0x8,%esp
  800936:	5b                   	pop    %ebx
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	56                   	push   %esi
  80093d:	53                   	push   %ebx
  80093e:	8b 75 08             	mov    0x8(%ebp),%esi
  800941:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800944:	89 f3                	mov    %esi,%ebx
  800946:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800949:	89 f2                	mov    %esi,%edx
  80094b:	eb 0c                	jmp    800959 <strncpy+0x20>
		*dst++ = *src;
  80094d:	42                   	inc    %edx
  80094e:	8a 01                	mov    (%ecx),%al
  800950:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800953:	80 39 01             	cmpb   $0x1,(%ecx)
  800956:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800959:	39 da                	cmp    %ebx,%edx
  80095b:	75 f0                	jne    80094d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80095d:	89 f0                	mov    %esi,%eax
  80095f:	5b                   	pop    %ebx
  800960:	5e                   	pop    %esi
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	56                   	push   %esi
  800967:	53                   	push   %ebx
  800968:	8b 75 08             	mov    0x8(%ebp),%esi
  80096b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800971:	89 f0                	mov    %esi,%eax
  800973:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800977:	85 c9                	test   %ecx,%ecx
  800979:	75 07                	jne    800982 <strlcpy+0x1f>
  80097b:	eb 18                	jmp    800995 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80097d:	40                   	inc    %eax
  80097e:	42                   	inc    %edx
  80097f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800982:	39 d8                	cmp    %ebx,%eax
  800984:	74 0a                	je     800990 <strlcpy+0x2d>
  800986:	8a 0a                	mov    (%edx),%cl
  800988:	84 c9                	test   %cl,%cl
  80098a:	75 f1                	jne    80097d <strlcpy+0x1a>
  80098c:	89 c2                	mov    %eax,%edx
  80098e:	eb 02                	jmp    800992 <strlcpy+0x2f>
  800990:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800992:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800995:	29 f0                	sub    %esi,%eax
}
  800997:	5b                   	pop    %ebx
  800998:	5e                   	pop    %esi
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a4:	eb 02                	jmp    8009a8 <strcmp+0xd>
		p++, q++;
  8009a6:	41                   	inc    %ecx
  8009a7:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009a8:	8a 01                	mov    (%ecx),%al
  8009aa:	84 c0                	test   %al,%al
  8009ac:	74 04                	je     8009b2 <strcmp+0x17>
  8009ae:	3a 02                	cmp    (%edx),%al
  8009b0:	74 f4                	je     8009a6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b2:	25 ff 00 00 00       	and    $0xff,%eax
  8009b7:	8a 0a                	mov    (%edx),%cl
  8009b9:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8009bf:	29 c8                	sub    %ecx,%eax
}
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	53                   	push   %ebx
  8009c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cd:	89 c3                	mov    %eax,%ebx
  8009cf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d2:	eb 02                	jmp    8009d6 <strncmp+0x13>
		n--, p++, q++;
  8009d4:	40                   	inc    %eax
  8009d5:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009d6:	39 d8                	cmp    %ebx,%eax
  8009d8:	74 20                	je     8009fa <strncmp+0x37>
  8009da:	8a 08                	mov    (%eax),%cl
  8009dc:	84 c9                	test   %cl,%cl
  8009de:	74 04                	je     8009e4 <strncmp+0x21>
  8009e0:	3a 0a                	cmp    (%edx),%cl
  8009e2:	74 f0                	je     8009d4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e4:	8a 18                	mov    (%eax),%bl
  8009e6:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8009ec:	89 d8                	mov    %ebx,%eax
  8009ee:	8a 1a                	mov    (%edx),%bl
  8009f0:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8009f6:	29 d8                	sub    %ebx,%eax
  8009f8:	eb 05                	jmp    8009ff <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009ff:	5b                   	pop    %ebx
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a0b:	eb 05                	jmp    800a12 <strchr+0x10>
		if (*s == c)
  800a0d:	38 ca                	cmp    %cl,%dl
  800a0f:	74 0c                	je     800a1d <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a11:	40                   	inc    %eax
  800a12:	8a 10                	mov    (%eax),%dl
  800a14:	84 d2                	test   %dl,%dl
  800a16:	75 f5                	jne    800a0d <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a28:	eb 05                	jmp    800a2f <strfind+0x10>
		if (*s == c)
  800a2a:	38 ca                	cmp    %cl,%dl
  800a2c:	74 07                	je     800a35 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a2e:	40                   	inc    %eax
  800a2f:	8a 10                	mov    (%eax),%dl
  800a31:	84 d2                	test   %dl,%dl
  800a33:	75 f5                	jne    800a2a <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	57                   	push   %edi
  800a3b:	56                   	push   %esi
  800a3c:	53                   	push   %ebx
  800a3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a43:	85 c9                	test   %ecx,%ecx
  800a45:	74 37                	je     800a7e <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a47:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a4d:	75 29                	jne    800a78 <memset+0x41>
  800a4f:	f6 c1 03             	test   $0x3,%cl
  800a52:	75 24                	jne    800a78 <memset+0x41>
		c &= 0xFF;
  800a54:	31 d2                	xor    %edx,%edx
  800a56:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a59:	89 d3                	mov    %edx,%ebx
  800a5b:	c1 e3 08             	shl    $0x8,%ebx
  800a5e:	89 d6                	mov    %edx,%esi
  800a60:	c1 e6 18             	shl    $0x18,%esi
  800a63:	89 d0                	mov    %edx,%eax
  800a65:	c1 e0 10             	shl    $0x10,%eax
  800a68:	09 f0                	or     %esi,%eax
  800a6a:	09 c2                	or     %eax,%edx
  800a6c:	89 d0                	mov    %edx,%eax
  800a6e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a70:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a73:	fc                   	cld    
  800a74:	f3 ab                	rep stos %eax,%es:(%edi)
  800a76:	eb 06                	jmp    800a7e <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7b:	fc                   	cld    
  800a7c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a7e:	89 f8                	mov    %edi,%eax
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5f                   	pop    %edi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	57                   	push   %edi
  800a89:	56                   	push   %esi
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a93:	39 c6                	cmp    %eax,%esi
  800a95:	73 33                	jae    800aca <memmove+0x45>
  800a97:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a9a:	39 d0                	cmp    %edx,%eax
  800a9c:	73 2c                	jae    800aca <memmove+0x45>
		s += n;
		d += n;
  800a9e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800aa1:	89 d6                	mov    %edx,%esi
  800aa3:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aab:	75 13                	jne    800ac0 <memmove+0x3b>
  800aad:	f6 c1 03             	test   $0x3,%cl
  800ab0:	75 0e                	jne    800ac0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ab2:	83 ef 04             	sub    $0x4,%edi
  800ab5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800abb:	fd                   	std    
  800abc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abe:	eb 07                	jmp    800ac7 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ac0:	4f                   	dec    %edi
  800ac1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ac4:	fd                   	std    
  800ac5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac7:	fc                   	cld    
  800ac8:	eb 1d                	jmp    800ae7 <memmove+0x62>
  800aca:	89 f2                	mov    %esi,%edx
  800acc:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ace:	f6 c2 03             	test   $0x3,%dl
  800ad1:	75 0f                	jne    800ae2 <memmove+0x5d>
  800ad3:	f6 c1 03             	test   $0x3,%cl
  800ad6:	75 0a                	jne    800ae2 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ad8:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800adb:	89 c7                	mov    %eax,%edi
  800add:	fc                   	cld    
  800ade:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae0:	eb 05                	jmp    800ae7 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ae2:	89 c7                	mov    %eax,%edi
  800ae4:	fc                   	cld    
  800ae5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ae7:	5e                   	pop    %esi
  800ae8:	5f                   	pop    %edi
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800af1:	8b 45 10             	mov    0x10(%ebp),%eax
  800af4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
  800b02:	89 04 24             	mov    %eax,(%esp)
  800b05:	e8 7b ff ff ff       	call   800a85 <memmove>
}
  800b0a:	c9                   	leave  
  800b0b:	c3                   	ret    

00800b0c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	8b 55 08             	mov    0x8(%ebp),%edx
  800b14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b17:	89 d6                	mov    %edx,%esi
  800b19:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1c:	eb 19                	jmp    800b37 <memcmp+0x2b>
		if (*s1 != *s2)
  800b1e:	8a 02                	mov    (%edx),%al
  800b20:	8a 19                	mov    (%ecx),%bl
  800b22:	38 d8                	cmp    %bl,%al
  800b24:	74 0f                	je     800b35 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800b26:	25 ff 00 00 00       	and    $0xff,%eax
  800b2b:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800b31:	29 d8                	sub    %ebx,%eax
  800b33:	eb 0b                	jmp    800b40 <memcmp+0x34>
		s1++, s2++;
  800b35:	42                   	inc    %edx
  800b36:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b37:	39 f2                	cmp    %esi,%edx
  800b39:	75 e3                	jne    800b1e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b4d:	89 c2                	mov    %eax,%edx
  800b4f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b52:	eb 05                	jmp    800b59 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b54:	38 08                	cmp    %cl,(%eax)
  800b56:	74 05                	je     800b5d <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b58:	40                   	inc    %eax
  800b59:	39 d0                	cmp    %edx,%eax
  800b5b:	72 f7                	jb     800b54 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	8b 55 08             	mov    0x8(%ebp),%edx
  800b68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6b:	eb 01                	jmp    800b6e <strtol+0xf>
		s++;
  800b6d:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6e:	8a 02                	mov    (%edx),%al
  800b70:	3c 09                	cmp    $0x9,%al
  800b72:	74 f9                	je     800b6d <strtol+0xe>
  800b74:	3c 20                	cmp    $0x20,%al
  800b76:	74 f5                	je     800b6d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b78:	3c 2b                	cmp    $0x2b,%al
  800b7a:	75 08                	jne    800b84 <strtol+0x25>
		s++;
  800b7c:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b7d:	bf 00 00 00 00       	mov    $0x0,%edi
  800b82:	eb 10                	jmp    800b94 <strtol+0x35>
  800b84:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b89:	3c 2d                	cmp    $0x2d,%al
  800b8b:	75 07                	jne    800b94 <strtol+0x35>
		s++, neg = 1;
  800b8d:	8d 52 01             	lea    0x1(%edx),%edx
  800b90:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b94:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b9a:	75 15                	jne    800bb1 <strtol+0x52>
  800b9c:	80 3a 30             	cmpb   $0x30,(%edx)
  800b9f:	75 10                	jne    800bb1 <strtol+0x52>
  800ba1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ba5:	75 0a                	jne    800bb1 <strtol+0x52>
		s += 2, base = 16;
  800ba7:	83 c2 02             	add    $0x2,%edx
  800baa:	bb 10 00 00 00       	mov    $0x10,%ebx
  800baf:	eb 0e                	jmp    800bbf <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800bb1:	85 db                	test   %ebx,%ebx
  800bb3:	75 0a                	jne    800bbf <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bb5:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bb7:	80 3a 30             	cmpb   $0x30,(%edx)
  800bba:	75 03                	jne    800bbf <strtol+0x60>
		s++, base = 8;
  800bbc:	42                   	inc    %edx
  800bbd:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800bbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bc7:	8a 0a                	mov    (%edx),%cl
  800bc9:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800bcc:	89 f3                	mov    %esi,%ebx
  800bce:	80 fb 09             	cmp    $0x9,%bl
  800bd1:	77 08                	ja     800bdb <strtol+0x7c>
			dig = *s - '0';
  800bd3:	0f be c9             	movsbl %cl,%ecx
  800bd6:	83 e9 30             	sub    $0x30,%ecx
  800bd9:	eb 22                	jmp    800bfd <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800bdb:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bde:	89 f3                	mov    %esi,%ebx
  800be0:	80 fb 19             	cmp    $0x19,%bl
  800be3:	77 08                	ja     800bed <strtol+0x8e>
			dig = *s - 'a' + 10;
  800be5:	0f be c9             	movsbl %cl,%ecx
  800be8:	83 e9 57             	sub    $0x57,%ecx
  800beb:	eb 10                	jmp    800bfd <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800bed:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bf0:	89 f3                	mov    %esi,%ebx
  800bf2:	80 fb 19             	cmp    $0x19,%bl
  800bf5:	77 14                	ja     800c0b <strtol+0xac>
			dig = *s - 'A' + 10;
  800bf7:	0f be c9             	movsbl %cl,%ecx
  800bfa:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bfd:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c00:	7d 0d                	jge    800c0f <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c02:	42                   	inc    %edx
  800c03:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c07:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c09:	eb bc                	jmp    800bc7 <strtol+0x68>
  800c0b:	89 c1                	mov    %eax,%ecx
  800c0d:	eb 02                	jmp    800c11 <strtol+0xb2>
  800c0f:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c11:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c15:	74 05                	je     800c1c <strtol+0xbd>
		*endptr = (char *) s;
  800c17:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c1a:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c1c:	85 ff                	test   %edi,%edi
  800c1e:	74 04                	je     800c24 <strtol+0xc5>
  800c20:	89 c8                	mov    %ecx,%eax
  800c22:	f7 d8                	neg    %eax
}
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    
  800c29:	66 90                	xchg   %ax,%ax
  800c2b:	90                   	nop

00800c2c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c32:	b8 00 00 00 00       	mov    $0x0,%eax
  800c37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	89 c3                	mov    %eax,%ebx
  800c3f:	89 c7                	mov    %eax,%edi
  800c41:	89 c6                	mov    %eax,%esi
  800c43:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <sys_cgetc>:

int
sys_cgetc(void)
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
  800c55:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5a:	89 d1                	mov    %edx,%ecx
  800c5c:	89 d3                	mov    %edx,%ebx
  800c5e:	89 d7                	mov    %edx,%edi
  800c60:	89 d6                	mov    %edx,%esi
  800c62:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800c72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c77:	b8 03 00 00 00       	mov    $0x3,%eax
  800c7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7f:	89 cb                	mov    %ecx,%ebx
  800c81:	89 cf                	mov    %ecx,%edi
  800c83:	89 ce                	mov    %ecx,%esi
  800c85:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c87:	85 c0                	test   %eax,%eax
  800c89:	7e 28                	jle    800cb3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c8f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c96:	00 
  800c97:	c7 44 24 08 68 19 80 	movl   $0x801968,0x8(%esp)
  800c9e:	00 
  800c9f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca6:	00 
  800ca7:	c7 04 24 85 19 80 00 	movl   $0x801985,(%esp)
  800cae:	e8 11 06 00 00       	call   8012c4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cb3:	83 c4 2c             	add    $0x2c,%esp
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc6:	b8 02 00 00 00       	mov    $0x2,%eax
  800ccb:	89 d1                	mov    %edx,%ecx
  800ccd:	89 d3                	mov    %edx,%ebx
  800ccf:	89 d7                	mov    %edx,%edi
  800cd1:	89 d6                	mov    %edx,%esi
  800cd3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_yield>:

void
sys_yield(void)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cea:	89 d1                	mov    %edx,%ecx
  800cec:	89 d3                	mov    %edx,%ebx
  800cee:	89 d7                	mov    %edx,%edi
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	be 00 00 00 00       	mov    $0x0,%esi
  800d07:	b8 04 00 00 00       	mov    $0x4,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d15:	89 f7                	mov    %esi,%edi
  800d17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	7e 28                	jle    800d45 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d21:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d28:	00 
  800d29:	c7 44 24 08 68 19 80 	movl   $0x801968,0x8(%esp)
  800d30:	00 
  800d31:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d38:	00 
  800d39:	c7 04 24 85 19 80 00 	movl   $0x801985,(%esp)
  800d40:	e8 7f 05 00 00       	call   8012c4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d45:	83 c4 2c             	add    $0x2c,%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
  800d53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d56:	b8 05 00 00 00       	mov    $0x5,%eax
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d64:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d67:	8b 75 18             	mov    0x18(%ebp),%esi
  800d6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	7e 28                	jle    800d98 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d70:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d74:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d7b:	00 
  800d7c:	c7 44 24 08 68 19 80 	movl   $0x801968,0x8(%esp)
  800d83:	00 
  800d84:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8b:	00 
  800d8c:	c7 04 24 85 19 80 00 	movl   $0x801985,(%esp)
  800d93:	e8 2c 05 00 00       	call   8012c4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d98:	83 c4 2c             	add    $0x2c,%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dae:	b8 06 00 00 00       	mov    $0x6,%eax
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	89 df                	mov    %ebx,%edi
  800dbb:	89 de                	mov    %ebx,%esi
  800dbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 28                	jle    800deb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dce:	00 
  800dcf:	c7 44 24 08 68 19 80 	movl   $0x801968,0x8(%esp)
  800dd6:	00 
  800dd7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dde:	00 
  800ddf:	c7 04 24 85 19 80 00 	movl   $0x801985,(%esp)
  800de6:	e8 d9 04 00 00       	call   8012c4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800deb:	83 c4 2c             	add    $0x2c,%esp
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    

00800df3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
  800df9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e01:	b8 08 00 00 00       	mov    $0x8,%eax
  800e06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	89 df                	mov    %ebx,%edi
  800e0e:	89 de                	mov    %ebx,%esi
  800e10:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e12:	85 c0                	test   %eax,%eax
  800e14:	7e 28                	jle    800e3e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e16:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e21:	00 
  800e22:	c7 44 24 08 68 19 80 	movl   $0x801968,0x8(%esp)
  800e29:	00 
  800e2a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e31:	00 
  800e32:	c7 04 24 85 19 80 00 	movl   $0x801985,(%esp)
  800e39:	e8 86 04 00 00       	call   8012c4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e3e:	83 c4 2c             	add    $0x2c,%esp
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5f                   	pop    %edi
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	57                   	push   %edi
  800e4a:	56                   	push   %esi
  800e4b:	53                   	push   %ebx
  800e4c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e54:	b8 09 00 00 00       	mov    $0x9,%eax
  800e59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5f:	89 df                	mov    %ebx,%edi
  800e61:	89 de                	mov    %ebx,%esi
  800e63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e65:	85 c0                	test   %eax,%eax
  800e67:	7e 28                	jle    800e91 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e69:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e74:	00 
  800e75:	c7 44 24 08 68 19 80 	movl   $0x801968,0x8(%esp)
  800e7c:	00 
  800e7d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e84:	00 
  800e85:	c7 04 24 85 19 80 00 	movl   $0x801985,(%esp)
  800e8c:	e8 33 04 00 00       	call   8012c4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e91:	83 c4 2c             	add    $0x2c,%esp
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	57                   	push   %edi
  800e9d:	56                   	push   %esi
  800e9e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9f:	be 00 00 00 00       	mov    $0x0,%esi
  800ea4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ea9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eac:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eb5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eb7:	5b                   	pop    %ebx
  800eb8:	5e                   	pop    %esi
  800eb9:	5f                   	pop    %edi
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	57                   	push   %edi
  800ec0:	56                   	push   %esi
  800ec1:	53                   	push   %ebx
  800ec2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eca:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ecf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed2:	89 cb                	mov    %ecx,%ebx
  800ed4:	89 cf                	mov    %ecx,%edi
  800ed6:	89 ce                	mov    %ecx,%esi
  800ed8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eda:	85 c0                	test   %eax,%eax
  800edc:	7e 28                	jle    800f06 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ede:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee2:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ee9:	00 
  800eea:	c7 44 24 08 68 19 80 	movl   $0x801968,0x8(%esp)
  800ef1:	00 
  800ef2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef9:	00 
  800efa:	c7 04 24 85 19 80 00 	movl   $0x801985,(%esp)
  800f01:	e8 be 03 00 00       	call   8012c4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f06:	83 c4 2c             	add    $0x2c,%esp
  800f09:	5b                   	pop    %ebx
  800f0a:	5e                   	pop    %esi
  800f0b:	5f                   	pop    %edi
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    
  800f0e:	66 90                	xchg   %ax,%ax

00800f10 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	56                   	push   %esi
  800f14:	53                   	push   %ebx
  800f15:	83 ec 20             	sub    $0x20,%esp
  800f18:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f1b:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	pte_t * vpte = 
		(pte_t *)(PDX(UVPT) << 22 | PDX(addr) << 12 | PTX(addr) << 2);
  800f1d:	89 d9                	mov    %ebx,%ecx
  800f1f:	c1 e9 16             	shr    $0x16,%ecx
  800f22:	c1 e1 0c             	shl    $0xc,%ecx
  800f25:	81 c9 00 00 40 ef    	or     $0xef400000,%ecx
  800f2b:	89 da                	mov    %ebx,%edx
  800f2d:	c1 ea 0a             	shr    $0xa,%edx
  800f30:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  800f36:	09 ca                	or     %ecx,%edx
	if ((err & FEC_WR) == 0 || (*vpte & PTE_COW) == 0)
  800f38:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f3c:	74 07                	je     800f45 <pgfault+0x35>
  800f3e:	8b 02                	mov    (%edx),%eax
  800f40:	f6 c4 08             	test   $0x8,%ah
  800f43:	75 1c                	jne    800f61 <pgfault+0x51>
		panic("pgfault: not cow!\n");
  800f45:	c7 44 24 08 93 19 80 	movl   $0x801993,0x8(%esp)
  800f4c:	00 
  800f4d:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800f54:	00 
  800f55:	c7 04 24 a6 19 80 00 	movl   $0x8019a6,(%esp)
  800f5c:	e8 63 03 00 00       	call   8012c4 <_panic>
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  800f61:	e8 55 fd ff ff       	call   800cbb <sys_getenvid>
  800f66:	89 c6                	mov    %eax,%esi
	if (sys_page_alloc(envid, (void *) PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  800f68:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f6f:	00 
  800f70:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f77:	00 
  800f78:	89 04 24             	mov    %eax,(%esp)
  800f7b:	e8 79 fd ff ff       	call   800cf9 <sys_page_alloc>
  800f80:	85 c0                	test   %eax,%eax
  800f82:	79 1c                	jns    800fa0 <pgfault+0x90>
		panic("pgfault: page allocate error!\n");
  800f84:	c7 44 24 08 10 1a 80 	movl   $0x801a10,0x8(%esp)
  800f8b:	00 
  800f8c:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800f93:	00 
  800f94:	c7 04 24 a6 19 80 00 	movl   $0x8019a6,(%esp)
  800f9b:	e8 24 03 00 00       	call   8012c4 <_panic>

	memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800fa0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800fa6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800fad:	00 
  800fae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fb2:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800fb9:	e8 2d fb ff ff       	call   800aeb <memcpy>
	sys_page_map(envid, (void *)PFTEMP, envid, ROUNDDOWN(addr, PGSIZE), PTE_U | PTE_P | PTE_W);
  800fbe:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800fc5:	00 
  800fc6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fca:	89 74 24 08          	mov    %esi,0x8(%esp)
  800fce:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fd5:	00 
  800fd6:	89 34 24             	mov    %esi,(%esp)
  800fd9:	e8 6f fd ff ff       	call   800d4d <sys_page_map>
	// panic("pgfault not implemented");
}
  800fde:	83 c4 20             	add    $0x20,%esp
  800fe1:	5b                   	pop    %ebx
  800fe2:	5e                   	pop    %esi
  800fe3:	5d                   	pop    %ebp
  800fe4:	c3                   	ret    

00800fe5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	57                   	push   %edi
  800fe9:	56                   	push   %esi
  800fea:	53                   	push   %ebx
  800feb:	83 ec 2c             	sub    $0x2c,%esp
	set_pgfault_handler(pgfault);
  800fee:	c7 04 24 10 0f 80 00 	movl   $0x800f10,(%esp)
  800ff5:	e8 22 03 00 00       	call   80131c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ffa:	b8 07 00 00 00       	mov    $0x7,%eax
  800fff:	cd 30                	int    $0x30
  801001:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0)
  801004:	85 c0                	test   %eax,%eax
  801006:	79 1c                	jns    801024 <fork+0x3f>
		panic("something wrong when fork()\n");
  801008:	c7 44 24 08 b1 19 80 	movl   $0x8019b1,0x8(%esp)
  80100f:	00 
  801010:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  801017:	00 
  801018:	c7 04 24 a6 19 80 00 	movl   $0x8019a6,(%esp)
  80101f:	e8 a0 02 00 00       	call   8012c4 <_panic>

	if (envid == 0) {
  801024:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801028:	75 2a                	jne    801054 <fork+0x6f>
		//child
		thisenv = &envs[ENVX(sys_getenvid())];
  80102a:	e8 8c fc ff ff       	call   800cbb <sys_getenvid>
  80102f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801034:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80103b:	c1 e0 07             	shl    $0x7,%eax
  80103e:	29 d0                	sub    %edx,%eax
  801040:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801045:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return 0; 
  80104a:	b8 00 00 00 00       	mov    $0x0,%eax
  80104f:	e9 b9 01 00 00       	jmp    80120d <fork+0x228>
  801054:	89 c6                	mov    %eax,%esi
	}

	sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_U | PTE_P | PTE_W);
  801056:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80105d:	00 
  80105e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801065:	ee 
  801066:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801069:	89 04 24             	mov    %eax,(%esp)
  80106c:	e8 88 fc ff ff       	call   800cf9 <sys_page_alloc>

	int pn = 0;
	for (; pn < UTOP / PGSIZE - 1; pn++) {
  801071:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0; 
	}

	sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_U | PTE_P | PTE_W);

	int pn = 0;
  801076:	bb 00 00 00 00       	mov    $0x0,%ebx
  80107b:	89 d8                	mov    %ebx,%eax
  80107d:	c1 e0 0c             	shl    $0xc,%eax
	for (; pn < UTOP / PGSIZE - 1; pn++) {

		pde_t * vpde = 
			(pde_t *)(PDX(UVPT) << 22 | PDX(UVPT) << 12 | PDX(pn * PGSIZE) << 2);
  801080:	89 c2                	mov    %eax,%edx
  801082:	c1 ea 16             	shr    $0x16,%edx
  801085:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
  80108c:	81 c9 00 d0 7b ef    	or     $0xef7bd000,%ecx
		pte_t * vpte = 
			(pte_t *)(PDX(UVPT) << 22 | PDX(pn * PGSIZE) << 12 | PTX(pn * PGSIZE) << 2);
		if ((*vpde & PTE_P) && (*vpte & PTE_P) && (*vpte & PTE_U)) 
  801092:	f6 01 01             	testb  $0x1,(%ecx)
  801095:	0f 84 19 01 00 00    	je     8011b4 <fork+0x1cf>
	for (; pn < UTOP / PGSIZE - 1; pn++) {

		pde_t * vpde = 
			(pde_t *)(PDX(UVPT) << 22 | PDX(UVPT) << 12 | PDX(pn * PGSIZE) << 2);
		pte_t * vpte = 
			(pte_t *)(PDX(UVPT) << 22 | PDX(pn * PGSIZE) << 12 | PTX(pn * PGSIZE) << 2);
  80109b:	c1 e2 0c             	shl    $0xc,%edx
  80109e:	81 ca 00 00 40 ef    	or     $0xef400000,%edx
  8010a4:	c1 e8 0a             	shr    $0xa,%eax
  8010a7:	25 fc 0f 00 00       	and    $0xffc,%eax
  8010ac:	09 c2                	or     %eax,%edx
		if ((*vpde & PTE_P) && (*vpte & PTE_P) && (*vpte & PTE_U)) 
  8010ae:	8b 02                	mov    (%edx),%eax
  8010b0:	83 e0 05             	and    $0x5,%eax
  8010b3:	83 f8 05             	cmp    $0x5,%eax
  8010b6:	0f 85 f8 00 00 00    	jne    8011b4 <fork+0x1cf>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	if (pn * PGSIZE == UXSTACKTOP - PGSIZE)
  8010bc:	c1 e7 0c             	shl    $0xc,%edi
  8010bf:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  8010c5:	0f 84 e9 00 00 00    	je     8011b4 <fork+0x1cf>
	int perm_w = PTE_P | PTE_U | PTE_COW;
	int perm_r = PTE_P | PTE_U;

	void * addr = (void *) (pn * PGSIZE);
	pte_t * vpte = 
		(pte_t *)(PDX(UVPT) << 22 | PDX(addr) << 12 | PTX(addr) << 2);
  8010cb:	89 f8                	mov    %edi,%eax
  8010cd:	c1 e8 16             	shr    $0x16,%eax
  8010d0:	c1 e0 0c             	shl    $0xc,%eax
  8010d3:	0d 00 00 40 ef       	or     $0xef400000,%eax
  8010d8:	89 fa                	mov    %edi,%edx
  8010da:	c1 ea 0a             	shr    $0xa,%edx
  8010dd:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  8010e3:	09 d0                	or     %edx,%eax

	if ((*vpte & PTE_W) || (*vpte & PTE_COW)){
  8010e5:	f7 00 02 08 00 00    	testl  $0x802,(%eax)
  8010eb:	0f 84 82 00 00 00    	je     801173 <fork+0x18e>
		if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm_w)) < 0)
  8010f1:	e8 c5 fb ff ff       	call   800cbb <sys_getenvid>
  8010f6:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8010fd:	00 
  8010fe:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801102:	89 74 24 08          	mov    %esi,0x8(%esp)
  801106:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80110a:	89 04 24             	mov    %eax,(%esp)
  80110d:	e8 3b fc ff ff       	call   800d4d <sys_page_map>
  801112:	85 c0                	test   %eax,%eax
  801114:	79 1c                	jns    801132 <fork+0x14d>
			panic("duppage: map error!\n");
  801116:	c7 44 24 08 ce 19 80 	movl   $0x8019ce,0x8(%esp)
  80111d:	00 
  80111e:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  801125:	00 
  801126:	c7 04 24 a6 19 80 00 	movl   $0x8019a6,(%esp)
  80112d:	e8 92 01 00 00       	call   8012c4 <_panic>
		if ((r = sys_page_map(envid, addr, sys_getenvid(), addr, perm_w)) < 0)
  801132:	e8 84 fb ff ff       	call   800cbb <sys_getenvid>
  801137:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80113e:	00 
  80113f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801143:	89 44 24 08          	mov    %eax,0x8(%esp)
  801147:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80114b:	89 34 24             	mov    %esi,(%esp)
  80114e:	e8 fa fb ff ff       	call   800d4d <sys_page_map>
  801153:	85 c0                	test   %eax,%eax
  801155:	79 5d                	jns    8011b4 <fork+0x1cf>
			panic("duppage: map error!\n");
  801157:	c7 44 24 08 ce 19 80 	movl   $0x8019ce,0x8(%esp)
  80115e:	00 
  80115f:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801166:	00 
  801167:	c7 04 24 a6 19 80 00 	movl   $0x8019a6,(%esp)
  80116e:	e8 51 01 00 00       	call   8012c4 <_panic>
	} else {
		if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm_r)) < 0)
  801173:	e8 43 fb ff ff       	call   800cbb <sys_getenvid>
  801178:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80117f:	00 
  801180:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801184:	89 74 24 08          	mov    %esi,0x8(%esp)
  801188:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80118c:	89 04 24             	mov    %eax,(%esp)
  80118f:	e8 b9 fb ff ff       	call   800d4d <sys_page_map>
  801194:	85 c0                	test   %eax,%eax
  801196:	79 1c                	jns    8011b4 <fork+0x1cf>
			panic("duppage: map error!\n");
  801198:	c7 44 24 08 ce 19 80 	movl   $0x8019ce,0x8(%esp)
  80119f:	00 
  8011a0:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  8011a7:	00 
  8011a8:	c7 04 24 a6 19 80 00 	movl   $0x8019a6,(%esp)
  8011af:	e8 10 01 00 00       	call   8012c4 <_panic>
	}

	sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_U | PTE_P | PTE_W);

	int pn = 0;
	for (; pn < UTOP / PGSIZE - 1; pn++) {
  8011b4:	43                   	inc    %ebx
  8011b5:	89 df                	mov    %ebx,%edi
  8011b7:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  8011bd:	0f 85 b8 fe ff ff    	jne    80107b <fork+0x96>
		if ((*vpde & PTE_P) && (*vpte & PTE_P) && (*vpte & PTE_U)) 
			duppage(envid, pn);
	}

	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8011c3:	c7 44 24 04 68 13 80 	movl   $0x801368,0x4(%esp)
  8011ca:	00 
  8011cb:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8011ce:	89 34 24             	mov    %esi,(%esp)
  8011d1:	e8 70 fc ff ff       	call   800e46 <sys_env_set_pgfault_upcall>

	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8011d6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011dd:	00 
  8011de:	89 34 24             	mov    %esi,(%esp)
  8011e1:	e8 0d fc ff ff       	call   800df3 <sys_env_set_status>
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	79 20                	jns    80120a <fork+0x225>
		panic("sys_env_set_status: %e", r);
  8011ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ee:	c7 44 24 08 e3 19 80 	movl   $0x8019e3,0x8(%esp)
  8011f5:	00 
  8011f6:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  8011fd:	00 
  8011fe:	c7 04 24 a6 19 80 00 	movl   $0x8019a6,(%esp)
  801205:	e8 ba 00 00 00       	call   8012c4 <_panic>

	return envid;
  80120a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  80120d:	83 c4 2c             	add    $0x2c,%esp
  801210:	5b                   	pop    %ebx
  801211:	5e                   	pop    %esi
  801212:	5f                   	pop    %edi
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    

00801215 <sfork>:

// Challenge!
int
sfork(void)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80121b:	c7 44 24 08 fa 19 80 	movl   $0x8019fa,0x8(%esp)
  801222:	00 
  801223:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  80122a:	00 
  80122b:	c7 04 24 a6 19 80 00 	movl   $0x8019a6,(%esp)
  801232:	e8 8d 00 00 00       	call   8012c4 <_panic>
  801237:	90                   	nop

00801238 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  80123e:	c7 44 24 08 2f 1a 80 	movl   $0x801a2f,0x8(%esp)
  801245:	00 
  801246:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80124d:	00 
  80124e:	c7 04 24 48 1a 80 00 	movl   $0x801a48,(%esp)
  801255:	e8 6a 00 00 00       	call   8012c4 <_panic>

0080125a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  801260:	c7 44 24 08 52 1a 80 	movl   $0x801a52,0x8(%esp)
  801267:	00 
  801268:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  80126f:	00 
  801270:	c7 04 24 48 1a 80 00 	movl   $0x801a48,(%esp)
  801277:	e8 48 00 00 00       	call   8012c4 <_panic>

0080127c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	53                   	push   %ebx
  801280:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801283:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801288:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80128f:	89 c2                	mov    %eax,%edx
  801291:	c1 e2 07             	shl    $0x7,%edx
  801294:	29 ca                	sub    %ecx,%edx
  801296:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80129c:	8b 52 50             	mov    0x50(%edx),%edx
  80129f:	39 da                	cmp    %ebx,%edx
  8012a1:	75 0f                	jne    8012b2 <ipc_find_env+0x36>
			return envs[i].env_id;
  8012a3:	c1 e0 07             	shl    $0x7,%eax
  8012a6:	29 c8                	sub    %ecx,%eax
  8012a8:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8012ad:	8b 40 40             	mov    0x40(%eax),%eax
  8012b0:	eb 0c                	jmp    8012be <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012b2:	40                   	inc    %eax
  8012b3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012b8:	75 ce                	jne    801288 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8012ba:	66 b8 00 00          	mov    $0x0,%ax
}
  8012be:	5b                   	pop    %ebx
  8012bf:	5d                   	pop    %ebp
  8012c0:	c3                   	ret    
  8012c1:	66 90                	xchg   %ax,%ax
  8012c3:	90                   	nop

008012c4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	56                   	push   %esi
  8012c8:	53                   	push   %ebx
  8012c9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8012cc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8012cf:	8b 35 08 20 80 00    	mov    0x802008,%esi
  8012d5:	e8 e1 f9 ff ff       	call   800cbb <sys_getenvid>
  8012da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012dd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012e8:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f0:	c7 04 24 6c 1a 80 00 	movl   $0x801a6c,(%esp)
  8012f7:	e8 0e f0 ff ff       	call   80030a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8012fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801300:	8b 45 10             	mov    0x10(%ebp),%eax
  801303:	89 04 24             	mov    %eax,(%esp)
  801306:	e8 9e ef ff ff       	call   8002a9 <vcprintf>
	cprintf("\n");
  80130b:	c7 04 24 e1 19 80 00 	movl   $0x8019e1,(%esp)
  801312:	e8 f3 ef ff ff       	call   80030a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801317:	cc                   	int3   
  801318:	eb fd                	jmp    801317 <_panic+0x53>
  80131a:	66 90                	xchg   %ax,%ax

0080131c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801322:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  801329:	75 32                	jne    80135d <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
    //region_alloc(curenv, (void *)UXSTACKTOP - PGSIZE, PGSIZE);
		//panic("set_pgfault_handler not implemented");
		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  80132b:	e8 8b f9 ff ff       	call   800cbb <sys_getenvid>
  801330:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801337:	00 
  801338:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80133f:	ee 
  801340:	89 04 24             	mov    %eax,(%esp)
  801343:	e8 b1 f9 ff ff       	call   800cf9 <sys_page_alloc>
    sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801348:	e8 6e f9 ff ff       	call   800cbb <sys_getenvid>
  80134d:	c7 44 24 04 68 13 80 	movl   $0x801368,0x4(%esp)
  801354:	00 
  801355:	89 04 24             	mov    %eax,(%esp)
  801358:	e8 e9 fa ff ff       	call   800e46 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80135d:	8b 45 08             	mov    0x8(%ebp),%eax
  801360:	a3 10 20 80 00       	mov    %eax,0x802010

}
  801365:	c9                   	leave  
  801366:	c3                   	ret    
  801367:	90                   	nop

00801368 <_pgfault_upcall>:
  801368:	54                   	push   %esp
  801369:	a1 10 20 80 00       	mov    0x802010,%eax
  80136e:	ff d0                	call   *%eax
  801370:	83 c4 04             	add    $0x4,%esp
  801373:	8b 44 24 28          	mov    0x28(%esp),%eax
  801377:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80137b:	89 43 fc             	mov    %eax,-0x4(%ebx)
  80137e:	83 eb 04             	sub    $0x4,%ebx
  801381:	89 5c 24 30          	mov    %ebx,0x30(%esp)
  801385:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801389:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80138d:	8b 6c 24 10          	mov    0x10(%esp),%ebp
  801391:	8b 5c 24 18          	mov    0x18(%esp),%ebx
  801395:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  801399:	8b 4c 24 20          	mov    0x20(%esp),%ecx
  80139d:	8b 44 24 24          	mov    0x24(%esp),%eax
  8013a1:	ff 74 24 2c          	pushl  0x2c(%esp)
  8013a5:	9d                   	popf   
  8013a6:	8b 64 24 30          	mov    0x30(%esp),%esp
  8013aa:	c3                   	ret    
  8013ab:	66 90                	xchg   %ax,%ax
  8013ad:	66 90                	xchg   %ax,%ax
  8013af:	90                   	nop

008013b0 <__udivdi3>:
  8013b0:	55                   	push   %ebp
  8013b1:	57                   	push   %edi
  8013b2:	56                   	push   %esi
  8013b3:	83 ec 0c             	sub    $0xc,%esp
  8013b6:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8013ba:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8013be:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8013c2:	8b 44 24 28          	mov    0x28(%esp),%eax
  8013c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013ca:	89 ea                	mov    %ebp,%edx
  8013cc:	89 0c 24             	mov    %ecx,(%esp)
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	75 2d                	jne    801400 <__udivdi3+0x50>
  8013d3:	39 e9                	cmp    %ebp,%ecx
  8013d5:	77 61                	ja     801438 <__udivdi3+0x88>
  8013d7:	89 ce                	mov    %ecx,%esi
  8013d9:	85 c9                	test   %ecx,%ecx
  8013db:	75 0b                	jne    8013e8 <__udivdi3+0x38>
  8013dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8013e2:	31 d2                	xor    %edx,%edx
  8013e4:	f7 f1                	div    %ecx
  8013e6:	89 c6                	mov    %eax,%esi
  8013e8:	31 d2                	xor    %edx,%edx
  8013ea:	89 e8                	mov    %ebp,%eax
  8013ec:	f7 f6                	div    %esi
  8013ee:	89 c5                	mov    %eax,%ebp
  8013f0:	89 f8                	mov    %edi,%eax
  8013f2:	f7 f6                	div    %esi
  8013f4:	89 ea                	mov    %ebp,%edx
  8013f6:	83 c4 0c             	add    $0xc,%esp
  8013f9:	5e                   	pop    %esi
  8013fa:	5f                   	pop    %edi
  8013fb:	5d                   	pop    %ebp
  8013fc:	c3                   	ret    
  8013fd:	8d 76 00             	lea    0x0(%esi),%esi
  801400:	39 e8                	cmp    %ebp,%eax
  801402:	77 24                	ja     801428 <__udivdi3+0x78>
  801404:	0f bd e8             	bsr    %eax,%ebp
  801407:	83 f5 1f             	xor    $0x1f,%ebp
  80140a:	75 3c                	jne    801448 <__udivdi3+0x98>
  80140c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801410:	39 34 24             	cmp    %esi,(%esp)
  801413:	0f 86 9f 00 00 00    	jbe    8014b8 <__udivdi3+0x108>
  801419:	39 d0                	cmp    %edx,%eax
  80141b:	0f 82 97 00 00 00    	jb     8014b8 <__udivdi3+0x108>
  801421:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801428:	31 d2                	xor    %edx,%edx
  80142a:	31 c0                	xor    %eax,%eax
  80142c:	83 c4 0c             	add    $0xc,%esp
  80142f:	5e                   	pop    %esi
  801430:	5f                   	pop    %edi
  801431:	5d                   	pop    %ebp
  801432:	c3                   	ret    
  801433:	90                   	nop
  801434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801438:	89 f8                	mov    %edi,%eax
  80143a:	f7 f1                	div    %ecx
  80143c:	31 d2                	xor    %edx,%edx
  80143e:	83 c4 0c             	add    $0xc,%esp
  801441:	5e                   	pop    %esi
  801442:	5f                   	pop    %edi
  801443:	5d                   	pop    %ebp
  801444:	c3                   	ret    
  801445:	8d 76 00             	lea    0x0(%esi),%esi
  801448:	89 e9                	mov    %ebp,%ecx
  80144a:	8b 3c 24             	mov    (%esp),%edi
  80144d:	d3 e0                	shl    %cl,%eax
  80144f:	89 c6                	mov    %eax,%esi
  801451:	b8 20 00 00 00       	mov    $0x20,%eax
  801456:	29 e8                	sub    %ebp,%eax
  801458:	88 c1                	mov    %al,%cl
  80145a:	d3 ef                	shr    %cl,%edi
  80145c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801460:	89 e9                	mov    %ebp,%ecx
  801462:	8b 3c 24             	mov    (%esp),%edi
  801465:	09 74 24 08          	or     %esi,0x8(%esp)
  801469:	d3 e7                	shl    %cl,%edi
  80146b:	89 d6                	mov    %edx,%esi
  80146d:	88 c1                	mov    %al,%cl
  80146f:	d3 ee                	shr    %cl,%esi
  801471:	89 e9                	mov    %ebp,%ecx
  801473:	89 3c 24             	mov    %edi,(%esp)
  801476:	d3 e2                	shl    %cl,%edx
  801478:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80147c:	88 c1                	mov    %al,%cl
  80147e:	d3 ef                	shr    %cl,%edi
  801480:	09 d7                	or     %edx,%edi
  801482:	89 f2                	mov    %esi,%edx
  801484:	89 f8                	mov    %edi,%eax
  801486:	f7 74 24 08          	divl   0x8(%esp)
  80148a:	89 d6                	mov    %edx,%esi
  80148c:	89 c7                	mov    %eax,%edi
  80148e:	f7 24 24             	mull   (%esp)
  801491:	89 14 24             	mov    %edx,(%esp)
  801494:	39 d6                	cmp    %edx,%esi
  801496:	72 30                	jb     8014c8 <__udivdi3+0x118>
  801498:	8b 54 24 04          	mov    0x4(%esp),%edx
  80149c:	89 e9                	mov    %ebp,%ecx
  80149e:	d3 e2                	shl    %cl,%edx
  8014a0:	39 c2                	cmp    %eax,%edx
  8014a2:	73 05                	jae    8014a9 <__udivdi3+0xf9>
  8014a4:	3b 34 24             	cmp    (%esp),%esi
  8014a7:	74 1f                	je     8014c8 <__udivdi3+0x118>
  8014a9:	89 f8                	mov    %edi,%eax
  8014ab:	31 d2                	xor    %edx,%edx
  8014ad:	e9 7a ff ff ff       	jmp    80142c <__udivdi3+0x7c>
  8014b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014b8:	31 d2                	xor    %edx,%edx
  8014ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8014bf:	e9 68 ff ff ff       	jmp    80142c <__udivdi3+0x7c>
  8014c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014c8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8014cb:	31 d2                	xor    %edx,%edx
  8014cd:	83 c4 0c             	add    $0xc,%esp
  8014d0:	5e                   	pop    %esi
  8014d1:	5f                   	pop    %edi
  8014d2:	5d                   	pop    %ebp
  8014d3:	c3                   	ret    
  8014d4:	66 90                	xchg   %ax,%ax
  8014d6:	66 90                	xchg   %ax,%ax
  8014d8:	66 90                	xchg   %ax,%ax
  8014da:	66 90                	xchg   %ax,%ax
  8014dc:	66 90                	xchg   %ax,%ax
  8014de:	66 90                	xchg   %ax,%ax

008014e0 <__umoddi3>:
  8014e0:	55                   	push   %ebp
  8014e1:	57                   	push   %edi
  8014e2:	56                   	push   %esi
  8014e3:	83 ec 14             	sub    $0x14,%esp
  8014e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8014ea:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8014ee:	89 c7                	mov    %eax,%edi
  8014f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8014f8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8014fc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801500:	89 34 24             	mov    %esi,(%esp)
  801503:	89 c2                	mov    %eax,%edx
  801505:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801509:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80150d:	85 c0                	test   %eax,%eax
  80150f:	75 17                	jne    801528 <__umoddi3+0x48>
  801511:	39 fe                	cmp    %edi,%esi
  801513:	76 4b                	jbe    801560 <__umoddi3+0x80>
  801515:	89 c8                	mov    %ecx,%eax
  801517:	89 fa                	mov    %edi,%edx
  801519:	f7 f6                	div    %esi
  80151b:	89 d0                	mov    %edx,%eax
  80151d:	31 d2                	xor    %edx,%edx
  80151f:	83 c4 14             	add    $0x14,%esp
  801522:	5e                   	pop    %esi
  801523:	5f                   	pop    %edi
  801524:	5d                   	pop    %ebp
  801525:	c3                   	ret    
  801526:	66 90                	xchg   %ax,%ax
  801528:	39 f8                	cmp    %edi,%eax
  80152a:	77 54                	ja     801580 <__umoddi3+0xa0>
  80152c:	0f bd e8             	bsr    %eax,%ebp
  80152f:	83 f5 1f             	xor    $0x1f,%ebp
  801532:	75 5c                	jne    801590 <__umoddi3+0xb0>
  801534:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801538:	39 3c 24             	cmp    %edi,(%esp)
  80153b:	0f 87 f7 00 00 00    	ja     801638 <__umoddi3+0x158>
  801541:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801545:	29 f1                	sub    %esi,%ecx
  801547:	19 c7                	sbb    %eax,%edi
  801549:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80154d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801551:	8b 44 24 08          	mov    0x8(%esp),%eax
  801555:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801559:	83 c4 14             	add    $0x14,%esp
  80155c:	5e                   	pop    %esi
  80155d:	5f                   	pop    %edi
  80155e:	5d                   	pop    %ebp
  80155f:	c3                   	ret    
  801560:	89 f5                	mov    %esi,%ebp
  801562:	85 f6                	test   %esi,%esi
  801564:	75 0b                	jne    801571 <__umoddi3+0x91>
  801566:	b8 01 00 00 00       	mov    $0x1,%eax
  80156b:	31 d2                	xor    %edx,%edx
  80156d:	f7 f6                	div    %esi
  80156f:	89 c5                	mov    %eax,%ebp
  801571:	8b 44 24 04          	mov    0x4(%esp),%eax
  801575:	31 d2                	xor    %edx,%edx
  801577:	f7 f5                	div    %ebp
  801579:	89 c8                	mov    %ecx,%eax
  80157b:	f7 f5                	div    %ebp
  80157d:	eb 9c                	jmp    80151b <__umoddi3+0x3b>
  80157f:	90                   	nop
  801580:	89 c8                	mov    %ecx,%eax
  801582:	89 fa                	mov    %edi,%edx
  801584:	83 c4 14             	add    $0x14,%esp
  801587:	5e                   	pop    %esi
  801588:	5f                   	pop    %edi
  801589:	5d                   	pop    %ebp
  80158a:	c3                   	ret    
  80158b:	90                   	nop
  80158c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801590:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801597:	00 
  801598:	8b 34 24             	mov    (%esp),%esi
  80159b:	8b 44 24 04          	mov    0x4(%esp),%eax
  80159f:	89 e9                	mov    %ebp,%ecx
  8015a1:	29 e8                	sub    %ebp,%eax
  8015a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a7:	89 f0                	mov    %esi,%eax
  8015a9:	d3 e2                	shl    %cl,%edx
  8015ab:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8015af:	d3 e8                	shr    %cl,%eax
  8015b1:	89 04 24             	mov    %eax,(%esp)
  8015b4:	89 e9                	mov    %ebp,%ecx
  8015b6:	89 f0                	mov    %esi,%eax
  8015b8:	09 14 24             	or     %edx,(%esp)
  8015bb:	d3 e0                	shl    %cl,%eax
  8015bd:	89 fa                	mov    %edi,%edx
  8015bf:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8015c3:	d3 ea                	shr    %cl,%edx
  8015c5:	89 e9                	mov    %ebp,%ecx
  8015c7:	89 c6                	mov    %eax,%esi
  8015c9:	d3 e7                	shl    %cl,%edi
  8015cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015cf:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8015d3:	8b 44 24 10          	mov    0x10(%esp),%eax
  8015d7:	d3 e8                	shr    %cl,%eax
  8015d9:	09 f8                	or     %edi,%eax
  8015db:	89 e9                	mov    %ebp,%ecx
  8015dd:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8015e1:	d3 e7                	shl    %cl,%edi
  8015e3:	f7 34 24             	divl   (%esp)
  8015e6:	89 d1                	mov    %edx,%ecx
  8015e8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8015ec:	f7 e6                	mul    %esi
  8015ee:	89 c7                	mov    %eax,%edi
  8015f0:	89 d6                	mov    %edx,%esi
  8015f2:	39 d1                	cmp    %edx,%ecx
  8015f4:	72 2e                	jb     801624 <__umoddi3+0x144>
  8015f6:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8015fa:	72 24                	jb     801620 <__umoddi3+0x140>
  8015fc:	89 ca                	mov    %ecx,%edx
  8015fe:	89 e9                	mov    %ebp,%ecx
  801600:	8b 44 24 08          	mov    0x8(%esp),%eax
  801604:	29 f8                	sub    %edi,%eax
  801606:	19 f2                	sbb    %esi,%edx
  801608:	d3 e8                	shr    %cl,%eax
  80160a:	89 d6                	mov    %edx,%esi
  80160c:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801610:	d3 e6                	shl    %cl,%esi
  801612:	89 e9                	mov    %ebp,%ecx
  801614:	09 f0                	or     %esi,%eax
  801616:	d3 ea                	shr    %cl,%edx
  801618:	83 c4 14             	add    $0x14,%esp
  80161b:	5e                   	pop    %esi
  80161c:	5f                   	pop    %edi
  80161d:	5d                   	pop    %ebp
  80161e:	c3                   	ret    
  80161f:	90                   	nop
  801620:	39 d1                	cmp    %edx,%ecx
  801622:	75 d8                	jne    8015fc <__umoddi3+0x11c>
  801624:	89 d6                	mov    %edx,%esi
  801626:	89 c7                	mov    %eax,%edi
  801628:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  80162c:	1b 34 24             	sbb    (%esp),%esi
  80162f:	eb cb                	jmp    8015fc <__umoddi3+0x11c>
  801631:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801638:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80163c:	0f 82 ff fe ff ff    	jb     801541 <__umoddi3+0x61>
  801642:	e9 0a ff ff ff       	jmp    801551 <__umoddi3+0x71>
