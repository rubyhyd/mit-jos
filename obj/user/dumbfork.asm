
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 17 02 00 00       	call   800248 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800049:	00 
  80004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004e:	89 34 24             	mov    %esi,(%esp)
  800051:	e8 63 0d 00 00       	call   800db9 <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 80 12 80 	movl   $0x801280,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 93 12 80 00 	movl   $0x801293,(%esp)
  800075:	e8 56 02 00 00       	call   8002d0 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 6f 0d 00 00       	call   800e0d <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 a3 12 80 	movl   $0x8012a3,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 93 12 80 00 	movl   $0x801293,(%esp)
  8000bd:	e8 0e 02 00 00       	call   8002d0 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 6b 0a 00 00       	call   800b45 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 72 0d 00 00       	call   800e60 <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 b4 12 80 	movl   $0x8012b4,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 93 12 80 00 	movl   $0x801293,(%esp)
  80010d:	e8 be 01 00 00       	call   8002d0 <_panic>
}
  800112:	83 c4 20             	add    $0x20,%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <dumbfork>:

envid_t
dumbfork(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
  80011e:	83 ec 20             	sub    $0x20,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800121:	b8 07 00 00 00       	mov    $0x7,%eax
  800126:	cd 30                	int    $0x30
  800128:	89 c6                	mov    %eax,%esi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  80012a:	85 c0                	test   %eax,%eax
  80012c:	79 20                	jns    80014e <dumbfork+0x35>
		panic("sys_exofork: %e", envid);
  80012e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800132:	c7 44 24 08 c7 12 80 	movl   $0x8012c7,0x8(%esp)
  800139:	00 
  80013a:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800141:	00 
  800142:	c7 04 24 93 12 80 00 	movl   $0x801293,(%esp)
  800149:	e8 82 01 00 00       	call   8002d0 <_panic>
	if (envid == 0) {
  80014e:	85 c0                	test   %eax,%eax
  800150:	75 27                	jne    800179 <dumbfork+0x60>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800152:	e8 24 0c 00 00       	call   800d7b <sys_getenvid>
  800157:	25 ff 03 00 00       	and    $0x3ff,%eax
  80015c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800163:	c1 e0 07             	shl    $0x7,%eax
  800166:	29 d0                	sub    %edx,%eax
  800168:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80016d:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800172:	b8 00 00 00 00       	mov    $0x0,%eax
  800177:	eb 73                	jmp    8001ec <dumbfork+0xd3>
  800179:	89 c3                	mov    %eax,%ebx
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80017b:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800182:	eb 13                	jmp    800197 <dumbfork+0x7e>
		duppage(envid, addr);
  800184:	89 54 24 04          	mov    %edx,0x4(%esp)
  800188:	89 1c 24             	mov    %ebx,(%esp)
  80018b:	e8 a4 fe ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800190:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800197:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80019a:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
  8001a0:	72 e2                	jb     800184 <dumbfork+0x6b>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001a5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ae:	89 34 24             	mov    %esi,(%esp)
  8001b1:	e8 7e fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001b6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001bd:	00 
  8001be:	89 34 24             	mov    %esi,(%esp)
  8001c1:	e8 ed 0c 00 00       	call   800eb3 <sys_env_set_status>
  8001c6:	85 c0                	test   %eax,%eax
  8001c8:	79 20                	jns    8001ea <dumbfork+0xd1>
		panic("sys_env_set_status: %e", r);
  8001ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ce:	c7 44 24 08 d7 12 80 	movl   $0x8012d7,0x8(%esp)
  8001d5:	00 
  8001d6:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001dd:	00 
  8001de:	c7 04 24 93 12 80 00 	movl   $0x801293,(%esp)
  8001e5:	e8 e6 00 00 00       	call   8002d0 <_panic>

	return envid;
  8001ea:	89 f0                	mov    %esi,%eax
}
  8001ec:	83 c4 20             	add    $0x20,%esp
  8001ef:	5b                   	pop    %ebx
  8001f0:	5e                   	pop    %esi
  8001f1:	5d                   	pop    %ebp
  8001f2:	c3                   	ret    

008001f3 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001f3:	55                   	push   %ebp
  8001f4:	89 e5                	mov    %esp,%ebp
  8001f6:	56                   	push   %esi
  8001f7:	53                   	push   %ebx
  8001f8:	83 ec 10             	sub    $0x10,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001fb:	e8 19 ff ff ff       	call   800119 <dumbfork>
  800200:	89 c6                	mov    %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800202:	bb 00 00 00 00       	mov    $0x0,%ebx
  800207:	eb 26                	jmp    80022f <umain+0x3c>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800209:	b8 f5 12 80 00       	mov    $0x8012f5,%eax
  80020e:	eb 05                	jmp    800215 <umain+0x22>
  800210:	b8 ee 12 80 00       	mov    $0x8012ee,%eax
  800215:	89 44 24 08          	mov    %eax,0x8(%esp)
  800219:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80021d:	c7 04 24 fb 12 80 00 	movl   $0x8012fb,(%esp)
  800224:	e8 a1 01 00 00       	call   8003ca <cprintf>
		sys_yield();
  800229:	e8 6c 0b 00 00       	call   800d9a <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  80022e:	43                   	inc    %ebx
  80022f:	85 f6                	test   %esi,%esi
  800231:	75 07                	jne    80023a <umain+0x47>
  800233:	83 fb 13             	cmp    $0x13,%ebx
  800236:	7e d1                	jle    800209 <umain+0x16>
  800238:	eb 05                	jmp    80023f <umain+0x4c>
  80023a:	83 fb 09             	cmp    $0x9,%ebx
  80023d:	7e d1                	jle    800210 <umain+0x1d>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	5b                   	pop    %ebx
  800243:	5e                   	pop    %esi
  800244:	5d                   	pop    %ebp
  800245:	c3                   	ret    
  800246:	66 90                	xchg   %ax,%ax

00800248 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	56                   	push   %esi
  80024c:	53                   	push   %ebx
  80024d:	83 ec 10             	sub    $0x10,%esp
  800250:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800253:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  800256:	b8 08 20 80 00       	mov    $0x802008,%eax
  80025b:	2d 04 20 80 00       	sub    $0x802004,%eax
  800260:	89 44 24 08          	mov    %eax,0x8(%esp)
  800264:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80026b:	00 
  80026c:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  800273:	e8 7f 08 00 00       	call   800af7 <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  800278:	e8 fe 0a 00 00       	call   800d7b <sys_getenvid>
  80027d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800282:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800289:	c1 e0 07             	shl    $0x7,%eax
  80028c:	29 d0                	sub    %edx,%eax
  80028e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800293:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800298:	85 db                	test   %ebx,%ebx
  80029a:	7e 07                	jle    8002a3 <libmain+0x5b>
		binaryname = argv[0];
  80029c:	8b 06                	mov    (%esi),%eax
  80029e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8002a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a7:	89 1c 24             	mov    %ebx,(%esp)
  8002aa:	e8 44 ff ff ff       	call   8001f3 <umain>

	// exit gracefully
	exit();
  8002af:	e8 08 00 00 00       	call   8002bc <exit>
}
  8002b4:	83 c4 10             	add    $0x10,%esp
  8002b7:	5b                   	pop    %ebx
  8002b8:	5e                   	pop    %esi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    
  8002bb:	90                   	nop

008002bc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8002c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002c9:	e8 5b 0a 00 00       	call   800d29 <sys_env_destroy>
}
  8002ce:	c9                   	leave  
  8002cf:	c3                   	ret    

008002d0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	56                   	push   %esi
  8002d4:	53                   	push   %ebx
  8002d5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002db:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002e1:	e8 95 0a 00 00       	call   800d7b <sys_getenvid>
  8002e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002f4:	89 74 24 08          	mov    %esi,0x8(%esp)
  8002f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fc:	c7 04 24 18 13 80 00 	movl   $0x801318,(%esp)
  800303:	e8 c2 00 00 00       	call   8003ca <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800308:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80030c:	8b 45 10             	mov    0x10(%ebp),%eax
  80030f:	89 04 24             	mov    %eax,(%esp)
  800312:	e8 52 00 00 00       	call   800369 <vcprintf>
	cprintf("\n");
  800317:	c7 04 24 0b 13 80 00 	movl   $0x80130b,(%esp)
  80031e:	e8 a7 00 00 00       	call   8003ca <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800323:	cc                   	int3   
  800324:	eb fd                	jmp    800323 <_panic+0x53>
  800326:	66 90                	xchg   %ax,%ax

00800328 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	53                   	push   %ebx
  80032c:	83 ec 14             	sub    $0x14,%esp
  80032f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800332:	8b 13                	mov    (%ebx),%edx
  800334:	8d 42 01             	lea    0x1(%edx),%eax
  800337:	89 03                	mov    %eax,(%ebx)
  800339:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80033c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800340:	3d ff 00 00 00       	cmp    $0xff,%eax
  800345:	75 19                	jne    800360 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800347:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80034e:	00 
  80034f:	8d 43 08             	lea    0x8(%ebx),%eax
  800352:	89 04 24             	mov    %eax,(%esp)
  800355:	e8 92 09 00 00       	call   800cec <sys_cputs>
		b->idx = 0;
  80035a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800360:	ff 43 04             	incl   0x4(%ebx)
}
  800363:	83 c4 14             	add    $0x14,%esp
  800366:	5b                   	pop    %ebx
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    

00800369 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800372:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800379:	00 00 00 
	b.cnt = 0;
  80037c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800383:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800386:	8b 45 0c             	mov    0xc(%ebp),%eax
  800389:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80038d:	8b 45 08             	mov    0x8(%ebp),%eax
  800390:	89 44 24 08          	mov    %eax,0x8(%esp)
  800394:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80039a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039e:	c7 04 24 28 03 80 00 	movl   $0x800328,(%esp)
  8003a5:	e8 a9 01 00 00       	call   800553 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003aa:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8003b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ba:	89 04 24             	mov    %eax,(%esp)
  8003bd:	e8 2a 09 00 00       	call   800cec <sys_cputs>

	return b.cnt;
}
  8003c2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003c8:	c9                   	leave  
  8003c9:	c3                   	ret    

008003ca <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003d0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003da:	89 04 24             	mov    %eax,(%esp)
  8003dd:	e8 87 ff ff ff       	call   800369 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003e2:	c9                   	leave  
  8003e3:	c3                   	ret    

008003e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	57                   	push   %edi
  8003e8:	56                   	push   %esi
  8003e9:	53                   	push   %ebx
  8003ea:	83 ec 3c             	sub    $0x3c,%esp
  8003ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f0:	89 d7                	mov    %edx,%edi
  8003f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003fb:	89 c1                	mov    %eax,%ecx
  8003fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800400:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800403:	8b 45 10             	mov    0x10(%ebp),%eax
  800406:	ba 00 00 00 00       	mov    $0x0,%edx
  80040b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800411:	39 ca                	cmp    %ecx,%edx
  800413:	72 08                	jb     80041d <printnum+0x39>
  800415:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800418:	39 45 10             	cmp    %eax,0x10(%ebp)
  80041b:	77 6a                	ja     800487 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80041d:	8b 45 18             	mov    0x18(%ebp),%eax
  800420:	89 44 24 10          	mov    %eax,0x10(%esp)
  800424:	4e                   	dec    %esi
  800425:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800429:	8b 45 10             	mov    0x10(%ebp),%eax
  80042c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800430:	8b 44 24 08          	mov    0x8(%esp),%eax
  800434:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800438:	89 c3                	mov    %eax,%ebx
  80043a:	89 d6                	mov    %edx,%esi
  80043c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80043f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800442:	89 44 24 08          	mov    %eax,0x8(%esp)
  800446:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80044a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80044d:	89 04 24             	mov    %eax,(%esp)
  800450:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800453:	89 44 24 04          	mov    %eax,0x4(%esp)
  800457:	e8 74 0b 00 00       	call   800fd0 <__udivdi3>
  80045c:	89 d9                	mov    %ebx,%ecx
  80045e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800462:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800466:	89 04 24             	mov    %eax,(%esp)
  800469:	89 54 24 04          	mov    %edx,0x4(%esp)
  80046d:	89 fa                	mov    %edi,%edx
  80046f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800472:	e8 6d ff ff ff       	call   8003e4 <printnum>
  800477:	eb 19                	jmp    800492 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800479:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80047d:	8b 45 18             	mov    0x18(%ebp),%eax
  800480:	89 04 24             	mov    %eax,(%esp)
  800483:	ff d3                	call   *%ebx
  800485:	eb 03                	jmp    80048a <printnum+0xa6>
  800487:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80048a:	4e                   	dec    %esi
  80048b:	85 f6                	test   %esi,%esi
  80048d:	7f ea                	jg     800479 <printnum+0x95>
  80048f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800492:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800496:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80049a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80049d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8004a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ab:	89 04 24             	mov    %eax,(%esp)
  8004ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b5:	e8 46 0c 00 00       	call   801100 <__umoddi3>
  8004ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004be:	0f be 80 3c 13 80 00 	movsbl 0x80133c(%eax),%eax
  8004c5:	89 04 24             	mov    %eax,(%esp)
  8004c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004cb:	ff d0                	call   *%eax
}
  8004cd:	83 c4 3c             	add    $0x3c,%esp
  8004d0:	5b                   	pop    %ebx
  8004d1:	5e                   	pop    %esi
  8004d2:	5f                   	pop    %edi
  8004d3:	5d                   	pop    %ebp
  8004d4:	c3                   	ret    

008004d5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004d8:	83 fa 01             	cmp    $0x1,%edx
  8004db:	7e 0e                	jle    8004eb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004dd:	8b 10                	mov    (%eax),%edx
  8004df:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004e2:	89 08                	mov    %ecx,(%eax)
  8004e4:	8b 02                	mov    (%edx),%eax
  8004e6:	8b 52 04             	mov    0x4(%edx),%edx
  8004e9:	eb 22                	jmp    80050d <getuint+0x38>
	else if (lflag)
  8004eb:	85 d2                	test   %edx,%edx
  8004ed:	74 10                	je     8004ff <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004ef:	8b 10                	mov    (%eax),%edx
  8004f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f4:	89 08                	mov    %ecx,(%eax)
  8004f6:	8b 02                	mov    (%edx),%eax
  8004f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004fd:	eb 0e                	jmp    80050d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004ff:	8b 10                	mov    (%eax),%edx
  800501:	8d 4a 04             	lea    0x4(%edx),%ecx
  800504:	89 08                	mov    %ecx,(%eax)
  800506:	8b 02                	mov    (%edx),%eax
  800508:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80050d:	5d                   	pop    %ebp
  80050e:	c3                   	ret    

0080050f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80050f:	55                   	push   %ebp
  800510:	89 e5                	mov    %esp,%ebp
  800512:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800515:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800518:	8b 10                	mov    (%eax),%edx
  80051a:	3b 50 04             	cmp    0x4(%eax),%edx
  80051d:	73 0a                	jae    800529 <sprintputch+0x1a>
		*b->buf++ = ch;
  80051f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800522:	89 08                	mov    %ecx,(%eax)
  800524:	8b 45 08             	mov    0x8(%ebp),%eax
  800527:	88 02                	mov    %al,(%edx)
}
  800529:	5d                   	pop    %ebp
  80052a:	c3                   	ret    

0080052b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80052b:	55                   	push   %ebp
  80052c:	89 e5                	mov    %esp,%ebp
  80052e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800531:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800534:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800538:	8b 45 10             	mov    0x10(%ebp),%eax
  80053b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80053f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800542:	89 44 24 04          	mov    %eax,0x4(%esp)
  800546:	8b 45 08             	mov    0x8(%ebp),%eax
  800549:	89 04 24             	mov    %eax,(%esp)
  80054c:	e8 02 00 00 00       	call   800553 <vprintfmt>
	va_end(ap);
}
  800551:	c9                   	leave  
  800552:	c3                   	ret    

00800553 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800553:	55                   	push   %ebp
  800554:	89 e5                	mov    %esp,%ebp
  800556:	57                   	push   %edi
  800557:	56                   	push   %esi
  800558:	53                   	push   %ebx
  800559:	83 ec 3c             	sub    $0x3c,%esp
  80055c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80055f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800562:	eb 14                	jmp    800578 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800564:	85 c0                	test   %eax,%eax
  800566:	0f 84 8a 03 00 00    	je     8008f6 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  80056c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800570:	89 04 24             	mov    %eax,(%esp)
  800573:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800576:	89 f3                	mov    %esi,%ebx
  800578:	8d 73 01             	lea    0x1(%ebx),%esi
  80057b:	31 c0                	xor    %eax,%eax
  80057d:	8a 03                	mov    (%ebx),%al
  80057f:	83 f8 25             	cmp    $0x25,%eax
  800582:	75 e0                	jne    800564 <vprintfmt+0x11>
  800584:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800588:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80058f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800596:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80059d:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a2:	eb 1d                	jmp    8005c1 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005a6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8005aa:	eb 15                	jmp    8005c1 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ac:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005ae:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005b2:	eb 0d                	jmp    8005c1 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005b7:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005ba:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c1:	8d 5e 01             	lea    0x1(%esi),%ebx
  8005c4:	31 c0                	xor    %eax,%eax
  8005c6:	8a 06                	mov    (%esi),%al
  8005c8:	8a 0e                	mov    (%esi),%cl
  8005ca:	83 e9 23             	sub    $0x23,%ecx
  8005cd:	88 4d e0             	mov    %cl,-0x20(%ebp)
  8005d0:	80 f9 55             	cmp    $0x55,%cl
  8005d3:	0f 87 ff 02 00 00    	ja     8008d8 <vprintfmt+0x385>
  8005d9:	31 c9                	xor    %ecx,%ecx
  8005db:	8a 4d e0             	mov    -0x20(%ebp),%cl
  8005de:	ff 24 8d 00 14 80 00 	jmp    *0x801400(,%ecx,4)
  8005e5:	89 de                	mov    %ebx,%esi
  8005e7:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005ec:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8005ef:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8005f3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005f6:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005f9:	83 fb 09             	cmp    $0x9,%ebx
  8005fc:	77 2f                	ja     80062d <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005fe:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005ff:	eb eb                	jmp    8005ec <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8d 48 04             	lea    0x4(%eax),%ecx
  800607:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80060a:	8b 00                	mov    (%eax),%eax
  80060c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800611:	eb 1d                	jmp    800630 <vprintfmt+0xdd>
  800613:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800616:	f7 d0                	not    %eax
  800618:	c1 f8 1f             	sar    $0x1f,%eax
  80061b:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061e:	89 de                	mov    %ebx,%esi
  800620:	eb 9f                	jmp    8005c1 <vprintfmt+0x6e>
  800622:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800624:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80062b:	eb 94                	jmp    8005c1 <vprintfmt+0x6e>
  80062d:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800630:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800634:	79 8b                	jns    8005c1 <vprintfmt+0x6e>
  800636:	e9 79 ff ff ff       	jmp    8005b4 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80063b:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063c:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80063e:	eb 81                	jmp    8005c1 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 50 04             	lea    0x4(%eax),%edx
  800646:	89 55 14             	mov    %edx,0x14(%ebp)
  800649:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80064d:	8b 00                	mov    (%eax),%eax
  80064f:	89 04 24             	mov    %eax,(%esp)
  800652:	ff 55 08             	call   *0x8(%ebp)
			break;
  800655:	e9 1e ff ff ff       	jmp    800578 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8d 50 04             	lea    0x4(%eax),%edx
  800660:	89 55 14             	mov    %edx,0x14(%ebp)
  800663:	8b 00                	mov    (%eax),%eax
  800665:	89 c2                	mov    %eax,%edx
  800667:	c1 fa 1f             	sar    $0x1f,%edx
  80066a:	31 d0                	xor    %edx,%eax
  80066c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80066e:	83 f8 09             	cmp    $0x9,%eax
  800671:	7f 0b                	jg     80067e <vprintfmt+0x12b>
  800673:	8b 14 85 60 15 80 00 	mov    0x801560(,%eax,4),%edx
  80067a:	85 d2                	test   %edx,%edx
  80067c:	75 20                	jne    80069e <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  80067e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800682:	c7 44 24 08 54 13 80 	movl   $0x801354,0x8(%esp)
  800689:	00 
  80068a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80068e:	8b 45 08             	mov    0x8(%ebp),%eax
  800691:	89 04 24             	mov    %eax,(%esp)
  800694:	e8 92 fe ff ff       	call   80052b <printfmt>
  800699:	e9 da fe ff ff       	jmp    800578 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80069e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006a2:	c7 44 24 08 5d 13 80 	movl   $0x80135d,0x8(%esp)
  8006a9:	00 
  8006aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b1:	89 04 24             	mov    %eax,(%esp)
  8006b4:	e8 72 fe ff ff       	call   80052b <printfmt>
  8006b9:	e9 ba fe ff ff       	jmp    800578 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006be:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8d 50 04             	lea    0x4(%eax),%edx
  8006cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d0:	8b 30                	mov    (%eax),%esi
  8006d2:	85 f6                	test   %esi,%esi
  8006d4:	75 05                	jne    8006db <vprintfmt+0x188>
				p = "(null)";
  8006d6:	be 4d 13 80 00       	mov    $0x80134d,%esi
			if (width > 0 && padc != '-')
  8006db:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006df:	0f 84 8c 00 00 00    	je     800771 <vprintfmt+0x21e>
  8006e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006e9:	0f 8e 8a 00 00 00    	jle    800779 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ef:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006f3:	89 34 24             	mov    %esi,(%esp)
  8006f6:	e8 9b 02 00 00       	call   800996 <strnlen>
  8006fb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006fe:	29 c1                	sub    %eax,%ecx
  800700:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800703:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800707:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80070a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  80070d:	8b 75 08             	mov    0x8(%ebp),%esi
  800710:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800713:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800715:	eb 0d                	jmp    800724 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800717:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80071b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80071e:	89 04 24             	mov    %eax,(%esp)
  800721:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800723:	4b                   	dec    %ebx
  800724:	85 db                	test   %ebx,%ebx
  800726:	7f ef                	jg     800717 <vprintfmt+0x1c4>
  800728:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80072b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80072e:	89 c8                	mov    %ecx,%eax
  800730:	f7 d0                	not    %eax
  800732:	c1 f8 1f             	sar    $0x1f,%eax
  800735:	21 c8                	and    %ecx,%eax
  800737:	29 c1                	sub    %eax,%ecx
  800739:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80073c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80073f:	eb 3e                	jmp    80077f <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800741:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800745:	74 1b                	je     800762 <vprintfmt+0x20f>
  800747:	0f be d2             	movsbl %dl,%edx
  80074a:	83 ea 20             	sub    $0x20,%edx
  80074d:	83 fa 5e             	cmp    $0x5e,%edx
  800750:	76 10                	jbe    800762 <vprintfmt+0x20f>
					putch('?', putdat);
  800752:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800756:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80075d:	ff 55 08             	call   *0x8(%ebp)
  800760:	eb 0a                	jmp    80076c <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800762:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800766:	89 04 24             	mov    %eax,(%esp)
  800769:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80076c:	ff 4d dc             	decl   -0x24(%ebp)
  80076f:	eb 0e                	jmp    80077f <vprintfmt+0x22c>
  800771:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800774:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800777:	eb 06                	jmp    80077f <vprintfmt+0x22c>
  800779:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80077c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80077f:	46                   	inc    %esi
  800780:	8a 56 ff             	mov    -0x1(%esi),%dl
  800783:	0f be c2             	movsbl %dl,%eax
  800786:	85 c0                	test   %eax,%eax
  800788:	74 1f                	je     8007a9 <vprintfmt+0x256>
  80078a:	85 db                	test   %ebx,%ebx
  80078c:	78 b3                	js     800741 <vprintfmt+0x1ee>
  80078e:	4b                   	dec    %ebx
  80078f:	79 b0                	jns    800741 <vprintfmt+0x1ee>
  800791:	8b 75 08             	mov    0x8(%ebp),%esi
  800794:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800797:	eb 16                	jmp    8007af <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800799:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80079d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007a4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a6:	4b                   	dec    %ebx
  8007a7:	eb 06                	jmp    8007af <vprintfmt+0x25c>
  8007a9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8007ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8007af:	85 db                	test   %ebx,%ebx
  8007b1:	7f e6                	jg     800799 <vprintfmt+0x246>
  8007b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8007b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007b9:	e9 ba fd ff ff       	jmp    800578 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007be:	83 fa 01             	cmp    $0x1,%edx
  8007c1:	7e 16                	jle    8007d9 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8d 50 08             	lea    0x8(%eax),%edx
  8007c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cc:	8b 50 04             	mov    0x4(%eax),%edx
  8007cf:	8b 00                	mov    (%eax),%eax
  8007d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007d4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007d7:	eb 32                	jmp    80080b <vprintfmt+0x2b8>
	else if (lflag)
  8007d9:	85 d2                	test   %edx,%edx
  8007db:	74 18                	je     8007f5 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 50 04             	lea    0x4(%eax),%edx
  8007e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e6:	8b 30                	mov    (%eax),%esi
  8007e8:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007eb:	89 f0                	mov    %esi,%eax
  8007ed:	c1 f8 1f             	sar    $0x1f,%eax
  8007f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007f3:	eb 16                	jmp    80080b <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  8007f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f8:	8d 50 04             	lea    0x4(%eax),%edx
  8007fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fe:	8b 30                	mov    (%eax),%esi
  800800:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800803:	89 f0                	mov    %esi,%eax
  800805:	c1 f8 1f             	sar    $0x1f,%eax
  800808:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80080b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80080e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800811:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800816:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80081a:	0f 89 80 00 00 00    	jns    8008a0 <vprintfmt+0x34d>
				putch('-', putdat);
  800820:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800824:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80082b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80082e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800831:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800834:	f7 d8                	neg    %eax
  800836:	83 d2 00             	adc    $0x0,%edx
  800839:	f7 da                	neg    %edx
			}
			base = 10;
  80083b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800840:	eb 5e                	jmp    8008a0 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800842:	8d 45 14             	lea    0x14(%ebp),%eax
  800845:	e8 8b fc ff ff       	call   8004d5 <getuint>
			base = 10;
  80084a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80084f:	eb 4f                	jmp    8008a0 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800851:	8d 45 14             	lea    0x14(%ebp),%eax
  800854:	e8 7c fc ff ff       	call   8004d5 <getuint>
			base = 8;
  800859:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80085e:	eb 40                	jmp    8008a0 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800860:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800864:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80086b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80086e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800872:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800879:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80087c:	8b 45 14             	mov    0x14(%ebp),%eax
  80087f:	8d 50 04             	lea    0x4(%eax),%edx
  800882:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800885:	8b 00                	mov    (%eax),%eax
  800887:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80088c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800891:	eb 0d                	jmp    8008a0 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800893:	8d 45 14             	lea    0x14(%ebp),%eax
  800896:	e8 3a fc ff ff       	call   8004d5 <getuint>
			base = 16;
  80089b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008a0:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  8008a4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8008a8:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8008ab:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008af:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008b3:	89 04 24             	mov    %eax,(%esp)
  8008b6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ba:	89 fa                	mov    %edi,%edx
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	e8 20 fb ff ff       	call   8003e4 <printnum>
			break;
  8008c4:	e9 af fc ff ff       	jmp    800578 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008cd:	89 04 24             	mov    %eax,(%esp)
  8008d0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008d3:	e9 a0 fc ff ff       	jmp    800578 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008e3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008e6:	89 f3                	mov    %esi,%ebx
  8008e8:	eb 01                	jmp    8008eb <vprintfmt+0x398>
  8008ea:	4b                   	dec    %ebx
  8008eb:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8008ef:	75 f9                	jne    8008ea <vprintfmt+0x397>
  8008f1:	e9 82 fc ff ff       	jmp    800578 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8008f6:	83 c4 3c             	add    $0x3c,%esp
  8008f9:	5b                   	pop    %ebx
  8008fa:	5e                   	pop    %esi
  8008fb:	5f                   	pop    %edi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	83 ec 28             	sub    $0x28,%esp
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80090a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80090d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800911:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800914:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80091b:	85 c0                	test   %eax,%eax
  80091d:	74 30                	je     80094f <vsnprintf+0x51>
  80091f:	85 d2                	test   %edx,%edx
  800921:	7e 2c                	jle    80094f <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800923:	8b 45 14             	mov    0x14(%ebp),%eax
  800926:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80092a:	8b 45 10             	mov    0x10(%ebp),%eax
  80092d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800931:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800934:	89 44 24 04          	mov    %eax,0x4(%esp)
  800938:	c7 04 24 0f 05 80 00 	movl   $0x80050f,(%esp)
  80093f:	e8 0f fc ff ff       	call   800553 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800944:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800947:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80094a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094d:	eb 05                	jmp    800954 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80094f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800954:	c9                   	leave  
  800955:	c3                   	ret    

00800956 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80095c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80095f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800963:	8b 45 10             	mov    0x10(%ebp),%eax
  800966:	89 44 24 08          	mov    %eax,0x8(%esp)
  80096a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	89 04 24             	mov    %eax,(%esp)
  800977:	e8 82 ff ff ff       	call   8008fe <vsnprintf>
	va_end(ap);

	return rc;
}
  80097c:	c9                   	leave  
  80097d:	c3                   	ret    
  80097e:	66 90                	xchg   %ax,%ax

00800980 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800986:	b8 00 00 00 00       	mov    $0x0,%eax
  80098b:	eb 01                	jmp    80098e <strlen+0xe>
		n++;
  80098d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80098e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800992:	75 f9                	jne    80098d <strlen+0xd>
		n++;
	return n;
}
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80099f:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a4:	eb 01                	jmp    8009a7 <strnlen+0x11>
		n++;
  8009a6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a7:	39 d0                	cmp    %edx,%eax
  8009a9:	74 06                	je     8009b1 <strnlen+0x1b>
  8009ab:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009af:	75 f5                	jne    8009a6 <strnlen+0x10>
		n++;
	return n;
}
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	53                   	push   %ebx
  8009b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009bd:	89 c2                	mov    %eax,%edx
  8009bf:	42                   	inc    %edx
  8009c0:	41                   	inc    %ecx
  8009c1:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8009c4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009c7:	84 db                	test   %bl,%bl
  8009c9:	75 f4                	jne    8009bf <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009cb:	5b                   	pop    %ebx
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	53                   	push   %ebx
  8009d2:	83 ec 08             	sub    $0x8,%esp
  8009d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009d8:	89 1c 24             	mov    %ebx,(%esp)
  8009db:	e8 a0 ff ff ff       	call   800980 <strlen>
	strcpy(dst + len, src);
  8009e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009e7:	01 d8                	add    %ebx,%eax
  8009e9:	89 04 24             	mov    %eax,(%esp)
  8009ec:	e8 c2 ff ff ff       	call   8009b3 <strcpy>
	return dst;
}
  8009f1:	89 d8                	mov    %ebx,%eax
  8009f3:	83 c4 08             	add    $0x8,%esp
  8009f6:	5b                   	pop    %ebx
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	56                   	push   %esi
  8009fd:	53                   	push   %ebx
  8009fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800a01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a04:	89 f3                	mov    %esi,%ebx
  800a06:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a09:	89 f2                	mov    %esi,%edx
  800a0b:	eb 0c                	jmp    800a19 <strncpy+0x20>
		*dst++ = *src;
  800a0d:	42                   	inc    %edx
  800a0e:	8a 01                	mov    (%ecx),%al
  800a10:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a13:	80 39 01             	cmpb   $0x1,(%ecx)
  800a16:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a19:	39 da                	cmp    %ebx,%edx
  800a1b:	75 f0                	jne    800a0d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a1d:	89 f0                	mov    %esi,%eax
  800a1f:	5b                   	pop    %ebx
  800a20:	5e                   	pop    %esi
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a31:	89 f0                	mov    %esi,%eax
  800a33:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a37:	85 c9                	test   %ecx,%ecx
  800a39:	75 07                	jne    800a42 <strlcpy+0x1f>
  800a3b:	eb 18                	jmp    800a55 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a3d:	40                   	inc    %eax
  800a3e:	42                   	inc    %edx
  800a3f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a42:	39 d8                	cmp    %ebx,%eax
  800a44:	74 0a                	je     800a50 <strlcpy+0x2d>
  800a46:	8a 0a                	mov    (%edx),%cl
  800a48:	84 c9                	test   %cl,%cl
  800a4a:	75 f1                	jne    800a3d <strlcpy+0x1a>
  800a4c:	89 c2                	mov    %eax,%edx
  800a4e:	eb 02                	jmp    800a52 <strlcpy+0x2f>
  800a50:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a52:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a55:	29 f0                	sub    %esi,%eax
}
  800a57:	5b                   	pop    %ebx
  800a58:	5e                   	pop    %esi
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a61:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a64:	eb 02                	jmp    800a68 <strcmp+0xd>
		p++, q++;
  800a66:	41                   	inc    %ecx
  800a67:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a68:	8a 01                	mov    (%ecx),%al
  800a6a:	84 c0                	test   %al,%al
  800a6c:	74 04                	je     800a72 <strcmp+0x17>
  800a6e:	3a 02                	cmp    (%edx),%al
  800a70:	74 f4                	je     800a66 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a72:	25 ff 00 00 00       	and    $0xff,%eax
  800a77:	8a 0a                	mov    (%edx),%cl
  800a79:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  800a7f:	29 c8                	sub    %ecx,%eax
}
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	53                   	push   %ebx
  800a87:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8d:	89 c3                	mov    %eax,%ebx
  800a8f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a92:	eb 02                	jmp    800a96 <strncmp+0x13>
		n--, p++, q++;
  800a94:	40                   	inc    %eax
  800a95:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a96:	39 d8                	cmp    %ebx,%eax
  800a98:	74 20                	je     800aba <strncmp+0x37>
  800a9a:	8a 08                	mov    (%eax),%cl
  800a9c:	84 c9                	test   %cl,%cl
  800a9e:	74 04                	je     800aa4 <strncmp+0x21>
  800aa0:	3a 0a                	cmp    (%edx),%cl
  800aa2:	74 f0                	je     800a94 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa4:	8a 18                	mov    (%eax),%bl
  800aa6:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800aac:	89 d8                	mov    %ebx,%eax
  800aae:	8a 1a                	mov    (%edx),%bl
  800ab0:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800ab6:	29 d8                	sub    %ebx,%eax
  800ab8:	eb 05                	jmp    800abf <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aba:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800abf:	5b                   	pop    %ebx
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800acb:	eb 05                	jmp    800ad2 <strchr+0x10>
		if (*s == c)
  800acd:	38 ca                	cmp    %cl,%dl
  800acf:	74 0c                	je     800add <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ad1:	40                   	inc    %eax
  800ad2:	8a 10                	mov    (%eax),%dl
  800ad4:	84 d2                	test   %dl,%dl
  800ad6:	75 f5                	jne    800acd <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800ad8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae5:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800ae8:	eb 05                	jmp    800aef <strfind+0x10>
		if (*s == c)
  800aea:	38 ca                	cmp    %cl,%dl
  800aec:	74 07                	je     800af5 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aee:	40                   	inc    %eax
  800aef:	8a 10                	mov    (%eax),%dl
  800af1:	84 d2                	test   %dl,%dl
  800af3:	75 f5                	jne    800aea <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b03:	85 c9                	test   %ecx,%ecx
  800b05:	74 37                	je     800b3e <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b07:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b0d:	75 29                	jne    800b38 <memset+0x41>
  800b0f:	f6 c1 03             	test   $0x3,%cl
  800b12:	75 24                	jne    800b38 <memset+0x41>
		c &= 0xFF;
  800b14:	31 d2                	xor    %edx,%edx
  800b16:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b19:	89 d3                	mov    %edx,%ebx
  800b1b:	c1 e3 08             	shl    $0x8,%ebx
  800b1e:	89 d6                	mov    %edx,%esi
  800b20:	c1 e6 18             	shl    $0x18,%esi
  800b23:	89 d0                	mov    %edx,%eax
  800b25:	c1 e0 10             	shl    $0x10,%eax
  800b28:	09 f0                	or     %esi,%eax
  800b2a:	09 c2                	or     %eax,%edx
  800b2c:	89 d0                	mov    %edx,%eax
  800b2e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b30:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b33:	fc                   	cld    
  800b34:	f3 ab                	rep stos %eax,%es:(%edi)
  800b36:	eb 06                	jmp    800b3e <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3b:	fc                   	cld    
  800b3c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b3e:	89 f8                	mov    %edi,%eax
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b50:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b53:	39 c6                	cmp    %eax,%esi
  800b55:	73 33                	jae    800b8a <memmove+0x45>
  800b57:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b5a:	39 d0                	cmp    %edx,%eax
  800b5c:	73 2c                	jae    800b8a <memmove+0x45>
		s += n;
		d += n;
  800b5e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b61:	89 d6                	mov    %edx,%esi
  800b63:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b65:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b6b:	75 13                	jne    800b80 <memmove+0x3b>
  800b6d:	f6 c1 03             	test   $0x3,%cl
  800b70:	75 0e                	jne    800b80 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b72:	83 ef 04             	sub    $0x4,%edi
  800b75:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b78:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b7b:	fd                   	std    
  800b7c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7e:	eb 07                	jmp    800b87 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b80:	4f                   	dec    %edi
  800b81:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b84:	fd                   	std    
  800b85:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b87:	fc                   	cld    
  800b88:	eb 1d                	jmp    800ba7 <memmove+0x62>
  800b8a:	89 f2                	mov    %esi,%edx
  800b8c:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8e:	f6 c2 03             	test   $0x3,%dl
  800b91:	75 0f                	jne    800ba2 <memmove+0x5d>
  800b93:	f6 c1 03             	test   $0x3,%cl
  800b96:	75 0a                	jne    800ba2 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b98:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b9b:	89 c7                	mov    %eax,%edi
  800b9d:	fc                   	cld    
  800b9e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba0:	eb 05                	jmp    800ba7 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ba2:	89 c7                	mov    %eax,%edi
  800ba4:	fc                   	cld    
  800ba5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ba7:	5e                   	pop    %esi
  800ba8:	5f                   	pop    %edi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bb1:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc2:	89 04 24             	mov    %eax,(%esp)
  800bc5:	e8 7b ff ff ff       	call   800b45 <memmove>
}
  800bca:	c9                   	leave  
  800bcb:	c3                   	ret    

00800bcc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
  800bd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	89 d6                	mov    %edx,%esi
  800bd9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bdc:	eb 19                	jmp    800bf7 <memcmp+0x2b>
		if (*s1 != *s2)
  800bde:	8a 02                	mov    (%edx),%al
  800be0:	8a 19                	mov    (%ecx),%bl
  800be2:	38 d8                	cmp    %bl,%al
  800be4:	74 0f                	je     800bf5 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800be6:	25 ff 00 00 00       	and    $0xff,%eax
  800beb:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800bf1:	29 d8                	sub    %ebx,%eax
  800bf3:	eb 0b                	jmp    800c00 <memcmp+0x34>
		s1++, s2++;
  800bf5:	42                   	inc    %edx
  800bf6:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf7:	39 f2                	cmp    %esi,%edx
  800bf9:	75 e3                	jne    800bde <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bfb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c0d:	89 c2                	mov    %eax,%edx
  800c0f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c12:	eb 05                	jmp    800c19 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c14:	38 08                	cmp    %cl,(%eax)
  800c16:	74 05                	je     800c1d <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c18:	40                   	inc    %eax
  800c19:	39 d0                	cmp    %edx,%eax
  800c1b:	72 f7                	jb     800c14 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    

00800c1f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
  800c25:	8b 55 08             	mov    0x8(%ebp),%edx
  800c28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c2b:	eb 01                	jmp    800c2e <strtol+0xf>
		s++;
  800c2d:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c2e:	8a 02                	mov    (%edx),%al
  800c30:	3c 09                	cmp    $0x9,%al
  800c32:	74 f9                	je     800c2d <strtol+0xe>
  800c34:	3c 20                	cmp    $0x20,%al
  800c36:	74 f5                	je     800c2d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c38:	3c 2b                	cmp    $0x2b,%al
  800c3a:	75 08                	jne    800c44 <strtol+0x25>
		s++;
  800c3c:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c3d:	bf 00 00 00 00       	mov    $0x0,%edi
  800c42:	eb 10                	jmp    800c54 <strtol+0x35>
  800c44:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c49:	3c 2d                	cmp    $0x2d,%al
  800c4b:	75 07                	jne    800c54 <strtol+0x35>
		s++, neg = 1;
  800c4d:	8d 52 01             	lea    0x1(%edx),%edx
  800c50:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c54:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c5a:	75 15                	jne    800c71 <strtol+0x52>
  800c5c:	80 3a 30             	cmpb   $0x30,(%edx)
  800c5f:	75 10                	jne    800c71 <strtol+0x52>
  800c61:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c65:	75 0a                	jne    800c71 <strtol+0x52>
		s += 2, base = 16;
  800c67:	83 c2 02             	add    $0x2,%edx
  800c6a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c6f:	eb 0e                	jmp    800c7f <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800c71:	85 db                	test   %ebx,%ebx
  800c73:	75 0a                	jne    800c7f <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c75:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c77:	80 3a 30             	cmpb   $0x30,(%edx)
  800c7a:	75 03                	jne    800c7f <strtol+0x60>
		s++, base = 8;
  800c7c:	42                   	inc    %edx
  800c7d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c84:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c87:	8a 0a                	mov    (%edx),%cl
  800c89:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c8c:	89 f3                	mov    %esi,%ebx
  800c8e:	80 fb 09             	cmp    $0x9,%bl
  800c91:	77 08                	ja     800c9b <strtol+0x7c>
			dig = *s - '0';
  800c93:	0f be c9             	movsbl %cl,%ecx
  800c96:	83 e9 30             	sub    $0x30,%ecx
  800c99:	eb 22                	jmp    800cbd <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800c9b:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c9e:	89 f3                	mov    %esi,%ebx
  800ca0:	80 fb 19             	cmp    $0x19,%bl
  800ca3:	77 08                	ja     800cad <strtol+0x8e>
			dig = *s - 'a' + 10;
  800ca5:	0f be c9             	movsbl %cl,%ecx
  800ca8:	83 e9 57             	sub    $0x57,%ecx
  800cab:	eb 10                	jmp    800cbd <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800cad:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800cb0:	89 f3                	mov    %esi,%ebx
  800cb2:	80 fb 19             	cmp    $0x19,%bl
  800cb5:	77 14                	ja     800ccb <strtol+0xac>
			dig = *s - 'A' + 10;
  800cb7:	0f be c9             	movsbl %cl,%ecx
  800cba:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cbd:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800cc0:	7d 0d                	jge    800ccf <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800cc2:	42                   	inc    %edx
  800cc3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cc7:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800cc9:	eb bc                	jmp    800c87 <strtol+0x68>
  800ccb:	89 c1                	mov    %eax,%ecx
  800ccd:	eb 02                	jmp    800cd1 <strtol+0xb2>
  800ccf:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800cd1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cd5:	74 05                	je     800cdc <strtol+0xbd>
		*endptr = (char *) s;
  800cd7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cda:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800cdc:	85 ff                	test   %edi,%edi
  800cde:	74 04                	je     800ce4 <strtol+0xc5>
  800ce0:	89 c8                	mov    %ecx,%eax
  800ce2:	f7 d8                	neg    %eax
}
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    
  800ce9:	66 90                	xchg   %ax,%ax
  800ceb:	90                   	nop

00800cec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	89 c3                	mov    %eax,%ebx
  800cff:	89 c7                	mov    %eax,%edi
  800d01:	89 c6                	mov    %eax,%esi
  800d03:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <sys_cgetc>:

int
sys_cgetc(void)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d10:	ba 00 00 00 00       	mov    $0x0,%edx
  800d15:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1a:	89 d1                	mov    %edx,%ecx
  800d1c:	89 d3                	mov    %edx,%ebx
  800d1e:	89 d7                	mov    %edx,%edi
  800d20:	89 d6                	mov    %edx,%esi
  800d22:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d37:	b8 03 00 00 00       	mov    $0x3,%eax
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	89 cb                	mov    %ecx,%ebx
  800d41:	89 cf                	mov    %ecx,%edi
  800d43:	89 ce                	mov    %ecx,%esi
  800d45:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d47:	85 c0                	test   %eax,%eax
  800d49:	7e 28                	jle    800d73 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d4f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d56:	00 
  800d57:	c7 44 24 08 88 15 80 	movl   $0x801588,0x8(%esp)
  800d5e:	00 
  800d5f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d66:	00 
  800d67:	c7 04 24 a5 15 80 00 	movl   $0x8015a5,(%esp)
  800d6e:	e8 5d f5 ff ff       	call   8002d0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d73:	83 c4 2c             	add    $0x2c,%esp
  800d76:	5b                   	pop    %ebx
  800d77:	5e                   	pop    %esi
  800d78:	5f                   	pop    %edi
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	57                   	push   %edi
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d81:	ba 00 00 00 00       	mov    $0x0,%edx
  800d86:	b8 02 00 00 00       	mov    $0x2,%eax
  800d8b:	89 d1                	mov    %edx,%ecx
  800d8d:	89 d3                	mov    %edx,%ebx
  800d8f:	89 d7                	mov    %edx,%edi
  800d91:	89 d6                	mov    %edx,%esi
  800d93:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d95:	5b                   	pop    %ebx
  800d96:	5e                   	pop    %esi
  800d97:	5f                   	pop    %edi
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <sys_yield>:

void
sys_yield(void)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	57                   	push   %edi
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da0:	ba 00 00 00 00       	mov    $0x0,%edx
  800da5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800daa:	89 d1                	mov    %edx,%ecx
  800dac:	89 d3                	mov    %edx,%ebx
  800dae:	89 d7                	mov    %edx,%edi
  800db0:	89 d6                	mov    %edx,%esi
  800db2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800db4:	5b                   	pop    %ebx
  800db5:	5e                   	pop    %esi
  800db6:	5f                   	pop    %edi
  800db7:	5d                   	pop    %ebp
  800db8:	c3                   	ret    

00800db9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
  800dbc:	57                   	push   %edi
  800dbd:	56                   	push   %esi
  800dbe:	53                   	push   %ebx
  800dbf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc2:	be 00 00 00 00       	mov    $0x0,%esi
  800dc7:	b8 04 00 00 00       	mov    $0x4,%eax
  800dcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd5:	89 f7                	mov    %esi,%edi
  800dd7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	7e 28                	jle    800e05 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800de8:	00 
  800de9:	c7 44 24 08 88 15 80 	movl   $0x801588,0x8(%esp)
  800df0:	00 
  800df1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df8:	00 
  800df9:	c7 04 24 a5 15 80 00 	movl   $0x8015a5,(%esp)
  800e00:	e8 cb f4 ff ff       	call   8002d0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e05:	83 c4 2c             	add    $0x2c,%esp
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	57                   	push   %edi
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
  800e13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e16:	b8 05 00 00 00       	mov    $0x5,%eax
  800e1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e24:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e27:	8b 75 18             	mov    0x18(%ebp),%esi
  800e2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	7e 28                	jle    800e58 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e30:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e34:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e3b:	00 
  800e3c:	c7 44 24 08 88 15 80 	movl   $0x801588,0x8(%esp)
  800e43:	00 
  800e44:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4b:	00 
  800e4c:	c7 04 24 a5 15 80 00 	movl   $0x8015a5,(%esp)
  800e53:	e8 78 f4 ff ff       	call   8002d0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e58:	83 c4 2c             	add    $0x2c,%esp
  800e5b:	5b                   	pop    %ebx
  800e5c:	5e                   	pop    %esi
  800e5d:	5f                   	pop    %edi
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	57                   	push   %edi
  800e64:	56                   	push   %esi
  800e65:	53                   	push   %ebx
  800e66:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6e:	b8 06 00 00 00       	mov    $0x6,%eax
  800e73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e76:	8b 55 08             	mov    0x8(%ebp),%edx
  800e79:	89 df                	mov    %ebx,%edi
  800e7b:	89 de                	mov    %ebx,%esi
  800e7d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	7e 28                	jle    800eab <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e83:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e87:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e8e:	00 
  800e8f:	c7 44 24 08 88 15 80 	movl   $0x801588,0x8(%esp)
  800e96:	00 
  800e97:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9e:	00 
  800e9f:	c7 04 24 a5 15 80 00 	movl   $0x8015a5,(%esp)
  800ea6:	e8 25 f4 ff ff       	call   8002d0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eab:	83 c4 2c             	add    $0x2c,%esp
  800eae:	5b                   	pop    %ebx
  800eaf:	5e                   	pop    %esi
  800eb0:	5f                   	pop    %edi
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	57                   	push   %edi
  800eb7:	56                   	push   %esi
  800eb8:	53                   	push   %ebx
  800eb9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ec6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecc:	89 df                	mov    %ebx,%edi
  800ece:	89 de                	mov    %ebx,%esi
  800ed0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed2:	85 c0                	test   %eax,%eax
  800ed4:	7e 28                	jle    800efe <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eda:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ee1:	00 
  800ee2:	c7 44 24 08 88 15 80 	movl   $0x801588,0x8(%esp)
  800ee9:	00 
  800eea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef1:	00 
  800ef2:	c7 04 24 a5 15 80 00 	movl   $0x8015a5,(%esp)
  800ef9:	e8 d2 f3 ff ff       	call   8002d0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800efe:	83 c4 2c             	add    $0x2c,%esp
  800f01:	5b                   	pop    %ebx
  800f02:	5e                   	pop    %esi
  800f03:	5f                   	pop    %edi
  800f04:	5d                   	pop    %ebp
  800f05:	c3                   	ret    

00800f06 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	57                   	push   %edi
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
  800f0c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f14:	b8 09 00 00 00       	mov    $0x9,%eax
  800f19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1f:	89 df                	mov    %ebx,%edi
  800f21:	89 de                	mov    %ebx,%esi
  800f23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f25:	85 c0                	test   %eax,%eax
  800f27:	7e 28                	jle    800f51 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f29:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f34:	00 
  800f35:	c7 44 24 08 88 15 80 	movl   $0x801588,0x8(%esp)
  800f3c:	00 
  800f3d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f44:	00 
  800f45:	c7 04 24 a5 15 80 00 	movl   $0x8015a5,(%esp)
  800f4c:	e8 7f f3 ff ff       	call   8002d0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f51:	83 c4 2c             	add    $0x2c,%esp
  800f54:	5b                   	pop    %ebx
  800f55:	5e                   	pop    %esi
  800f56:	5f                   	pop    %edi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    

00800f59 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	57                   	push   %edi
  800f5d:	56                   	push   %esi
  800f5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5f:	be 00 00 00 00       	mov    $0x0,%esi
  800f64:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f72:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f75:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f77:	5b                   	pop    %ebx
  800f78:	5e                   	pop    %esi
  800f79:	5f                   	pop    %edi
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    

00800f7c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	57                   	push   %edi
  800f80:	56                   	push   %esi
  800f81:	53                   	push   %ebx
  800f82:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f8a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f92:	89 cb                	mov    %ecx,%ebx
  800f94:	89 cf                	mov    %ecx,%edi
  800f96:	89 ce                	mov    %ecx,%esi
  800f98:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	7e 28                	jle    800fc6 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f9e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa2:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800fa9:	00 
  800faa:	c7 44 24 08 88 15 80 	movl   $0x801588,0x8(%esp)
  800fb1:	00 
  800fb2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fb9:	00 
  800fba:	c7 04 24 a5 15 80 00 	movl   $0x8015a5,(%esp)
  800fc1:	e8 0a f3 ff ff       	call   8002d0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fc6:	83 c4 2c             	add    $0x2c,%esp
  800fc9:	5b                   	pop    %ebx
  800fca:	5e                   	pop    %esi
  800fcb:	5f                   	pop    %edi
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    
  800fce:	66 90                	xchg   %ax,%ax

00800fd0 <__udivdi3>:
  800fd0:	55                   	push   %ebp
  800fd1:	57                   	push   %edi
  800fd2:	56                   	push   %esi
  800fd3:	83 ec 0c             	sub    $0xc,%esp
  800fd6:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800fda:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800fde:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800fe2:	8b 44 24 28          	mov    0x28(%esp),%eax
  800fe6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fea:	89 ea                	mov    %ebp,%edx
  800fec:	89 0c 24             	mov    %ecx,(%esp)
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	75 2d                	jne    801020 <__udivdi3+0x50>
  800ff3:	39 e9                	cmp    %ebp,%ecx
  800ff5:	77 61                	ja     801058 <__udivdi3+0x88>
  800ff7:	89 ce                	mov    %ecx,%esi
  800ff9:	85 c9                	test   %ecx,%ecx
  800ffb:	75 0b                	jne    801008 <__udivdi3+0x38>
  800ffd:	b8 01 00 00 00       	mov    $0x1,%eax
  801002:	31 d2                	xor    %edx,%edx
  801004:	f7 f1                	div    %ecx
  801006:	89 c6                	mov    %eax,%esi
  801008:	31 d2                	xor    %edx,%edx
  80100a:	89 e8                	mov    %ebp,%eax
  80100c:	f7 f6                	div    %esi
  80100e:	89 c5                	mov    %eax,%ebp
  801010:	89 f8                	mov    %edi,%eax
  801012:	f7 f6                	div    %esi
  801014:	89 ea                	mov    %ebp,%edx
  801016:	83 c4 0c             	add    $0xc,%esp
  801019:	5e                   	pop    %esi
  80101a:	5f                   	pop    %edi
  80101b:	5d                   	pop    %ebp
  80101c:	c3                   	ret    
  80101d:	8d 76 00             	lea    0x0(%esi),%esi
  801020:	39 e8                	cmp    %ebp,%eax
  801022:	77 24                	ja     801048 <__udivdi3+0x78>
  801024:	0f bd e8             	bsr    %eax,%ebp
  801027:	83 f5 1f             	xor    $0x1f,%ebp
  80102a:	75 3c                	jne    801068 <__udivdi3+0x98>
  80102c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801030:	39 34 24             	cmp    %esi,(%esp)
  801033:	0f 86 9f 00 00 00    	jbe    8010d8 <__udivdi3+0x108>
  801039:	39 d0                	cmp    %edx,%eax
  80103b:	0f 82 97 00 00 00    	jb     8010d8 <__udivdi3+0x108>
  801041:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801048:	31 d2                	xor    %edx,%edx
  80104a:	31 c0                	xor    %eax,%eax
  80104c:	83 c4 0c             	add    $0xc,%esp
  80104f:	5e                   	pop    %esi
  801050:	5f                   	pop    %edi
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    
  801053:	90                   	nop
  801054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801058:	89 f8                	mov    %edi,%eax
  80105a:	f7 f1                	div    %ecx
  80105c:	31 d2                	xor    %edx,%edx
  80105e:	83 c4 0c             	add    $0xc,%esp
  801061:	5e                   	pop    %esi
  801062:	5f                   	pop    %edi
  801063:	5d                   	pop    %ebp
  801064:	c3                   	ret    
  801065:	8d 76 00             	lea    0x0(%esi),%esi
  801068:	89 e9                	mov    %ebp,%ecx
  80106a:	8b 3c 24             	mov    (%esp),%edi
  80106d:	d3 e0                	shl    %cl,%eax
  80106f:	89 c6                	mov    %eax,%esi
  801071:	b8 20 00 00 00       	mov    $0x20,%eax
  801076:	29 e8                	sub    %ebp,%eax
  801078:	88 c1                	mov    %al,%cl
  80107a:	d3 ef                	shr    %cl,%edi
  80107c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801080:	89 e9                	mov    %ebp,%ecx
  801082:	8b 3c 24             	mov    (%esp),%edi
  801085:	09 74 24 08          	or     %esi,0x8(%esp)
  801089:	d3 e7                	shl    %cl,%edi
  80108b:	89 d6                	mov    %edx,%esi
  80108d:	88 c1                	mov    %al,%cl
  80108f:	d3 ee                	shr    %cl,%esi
  801091:	89 e9                	mov    %ebp,%ecx
  801093:	89 3c 24             	mov    %edi,(%esp)
  801096:	d3 e2                	shl    %cl,%edx
  801098:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80109c:	88 c1                	mov    %al,%cl
  80109e:	d3 ef                	shr    %cl,%edi
  8010a0:	09 d7                	or     %edx,%edi
  8010a2:	89 f2                	mov    %esi,%edx
  8010a4:	89 f8                	mov    %edi,%eax
  8010a6:	f7 74 24 08          	divl   0x8(%esp)
  8010aa:	89 d6                	mov    %edx,%esi
  8010ac:	89 c7                	mov    %eax,%edi
  8010ae:	f7 24 24             	mull   (%esp)
  8010b1:	89 14 24             	mov    %edx,(%esp)
  8010b4:	39 d6                	cmp    %edx,%esi
  8010b6:	72 30                	jb     8010e8 <__udivdi3+0x118>
  8010b8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010bc:	89 e9                	mov    %ebp,%ecx
  8010be:	d3 e2                	shl    %cl,%edx
  8010c0:	39 c2                	cmp    %eax,%edx
  8010c2:	73 05                	jae    8010c9 <__udivdi3+0xf9>
  8010c4:	3b 34 24             	cmp    (%esp),%esi
  8010c7:	74 1f                	je     8010e8 <__udivdi3+0x118>
  8010c9:	89 f8                	mov    %edi,%eax
  8010cb:	31 d2                	xor    %edx,%edx
  8010cd:	e9 7a ff ff ff       	jmp    80104c <__udivdi3+0x7c>
  8010d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010d8:	31 d2                	xor    %edx,%edx
  8010da:	b8 01 00 00 00       	mov    $0x1,%eax
  8010df:	e9 68 ff ff ff       	jmp    80104c <__udivdi3+0x7c>
  8010e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010e8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8010eb:	31 d2                	xor    %edx,%edx
  8010ed:	83 c4 0c             	add    $0xc,%esp
  8010f0:	5e                   	pop    %esi
  8010f1:	5f                   	pop    %edi
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    
  8010f4:	66 90                	xchg   %ax,%ax
  8010f6:	66 90                	xchg   %ax,%ax
  8010f8:	66 90                	xchg   %ax,%ax
  8010fa:	66 90                	xchg   %ax,%ax
  8010fc:	66 90                	xchg   %ax,%ax
  8010fe:	66 90                	xchg   %ax,%ax

00801100 <__umoddi3>:
  801100:	55                   	push   %ebp
  801101:	57                   	push   %edi
  801102:	56                   	push   %esi
  801103:	83 ec 14             	sub    $0x14,%esp
  801106:	8b 44 24 28          	mov    0x28(%esp),%eax
  80110a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80110e:	89 c7                	mov    %eax,%edi
  801110:	89 44 24 04          	mov    %eax,0x4(%esp)
  801114:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801118:	8b 44 24 30          	mov    0x30(%esp),%eax
  80111c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801120:	89 34 24             	mov    %esi,(%esp)
  801123:	89 c2                	mov    %eax,%edx
  801125:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801129:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80112d:	85 c0                	test   %eax,%eax
  80112f:	75 17                	jne    801148 <__umoddi3+0x48>
  801131:	39 fe                	cmp    %edi,%esi
  801133:	76 4b                	jbe    801180 <__umoddi3+0x80>
  801135:	89 c8                	mov    %ecx,%eax
  801137:	89 fa                	mov    %edi,%edx
  801139:	f7 f6                	div    %esi
  80113b:	89 d0                	mov    %edx,%eax
  80113d:	31 d2                	xor    %edx,%edx
  80113f:	83 c4 14             	add    $0x14,%esp
  801142:	5e                   	pop    %esi
  801143:	5f                   	pop    %edi
  801144:	5d                   	pop    %ebp
  801145:	c3                   	ret    
  801146:	66 90                	xchg   %ax,%ax
  801148:	39 f8                	cmp    %edi,%eax
  80114a:	77 54                	ja     8011a0 <__umoddi3+0xa0>
  80114c:	0f bd e8             	bsr    %eax,%ebp
  80114f:	83 f5 1f             	xor    $0x1f,%ebp
  801152:	75 5c                	jne    8011b0 <__umoddi3+0xb0>
  801154:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801158:	39 3c 24             	cmp    %edi,(%esp)
  80115b:	0f 87 f7 00 00 00    	ja     801258 <__umoddi3+0x158>
  801161:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801165:	29 f1                	sub    %esi,%ecx
  801167:	19 c7                	sbb    %eax,%edi
  801169:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80116d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801171:	8b 44 24 08          	mov    0x8(%esp),%eax
  801175:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801179:	83 c4 14             	add    $0x14,%esp
  80117c:	5e                   	pop    %esi
  80117d:	5f                   	pop    %edi
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    
  801180:	89 f5                	mov    %esi,%ebp
  801182:	85 f6                	test   %esi,%esi
  801184:	75 0b                	jne    801191 <__umoddi3+0x91>
  801186:	b8 01 00 00 00       	mov    $0x1,%eax
  80118b:	31 d2                	xor    %edx,%edx
  80118d:	f7 f6                	div    %esi
  80118f:	89 c5                	mov    %eax,%ebp
  801191:	8b 44 24 04          	mov    0x4(%esp),%eax
  801195:	31 d2                	xor    %edx,%edx
  801197:	f7 f5                	div    %ebp
  801199:	89 c8                	mov    %ecx,%eax
  80119b:	f7 f5                	div    %ebp
  80119d:	eb 9c                	jmp    80113b <__umoddi3+0x3b>
  80119f:	90                   	nop
  8011a0:	89 c8                	mov    %ecx,%eax
  8011a2:	89 fa                	mov    %edi,%edx
  8011a4:	83 c4 14             	add    $0x14,%esp
  8011a7:	5e                   	pop    %esi
  8011a8:	5f                   	pop    %edi
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    
  8011ab:	90                   	nop
  8011ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011b0:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8011b7:	00 
  8011b8:	8b 34 24             	mov    (%esp),%esi
  8011bb:	8b 44 24 04          	mov    0x4(%esp),%eax
  8011bf:	89 e9                	mov    %ebp,%ecx
  8011c1:	29 e8                	sub    %ebp,%eax
  8011c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c7:	89 f0                	mov    %esi,%eax
  8011c9:	d3 e2                	shl    %cl,%edx
  8011cb:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8011cf:	d3 e8                	shr    %cl,%eax
  8011d1:	89 04 24             	mov    %eax,(%esp)
  8011d4:	89 e9                	mov    %ebp,%ecx
  8011d6:	89 f0                	mov    %esi,%eax
  8011d8:	09 14 24             	or     %edx,(%esp)
  8011db:	d3 e0                	shl    %cl,%eax
  8011dd:	89 fa                	mov    %edi,%edx
  8011df:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8011e3:	d3 ea                	shr    %cl,%edx
  8011e5:	89 e9                	mov    %ebp,%ecx
  8011e7:	89 c6                	mov    %eax,%esi
  8011e9:	d3 e7                	shl    %cl,%edi
  8011eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ef:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8011f3:	8b 44 24 10          	mov    0x10(%esp),%eax
  8011f7:	d3 e8                	shr    %cl,%eax
  8011f9:	09 f8                	or     %edi,%eax
  8011fb:	89 e9                	mov    %ebp,%ecx
  8011fd:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801201:	d3 e7                	shl    %cl,%edi
  801203:	f7 34 24             	divl   (%esp)
  801206:	89 d1                	mov    %edx,%ecx
  801208:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80120c:	f7 e6                	mul    %esi
  80120e:	89 c7                	mov    %eax,%edi
  801210:	89 d6                	mov    %edx,%esi
  801212:	39 d1                	cmp    %edx,%ecx
  801214:	72 2e                	jb     801244 <__umoddi3+0x144>
  801216:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80121a:	72 24                	jb     801240 <__umoddi3+0x140>
  80121c:	89 ca                	mov    %ecx,%edx
  80121e:	89 e9                	mov    %ebp,%ecx
  801220:	8b 44 24 08          	mov    0x8(%esp),%eax
  801224:	29 f8                	sub    %edi,%eax
  801226:	19 f2                	sbb    %esi,%edx
  801228:	d3 e8                	shr    %cl,%eax
  80122a:	89 d6                	mov    %edx,%esi
  80122c:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801230:	d3 e6                	shl    %cl,%esi
  801232:	89 e9                	mov    %ebp,%ecx
  801234:	09 f0                	or     %esi,%eax
  801236:	d3 ea                	shr    %cl,%edx
  801238:	83 c4 14             	add    $0x14,%esp
  80123b:	5e                   	pop    %esi
  80123c:	5f                   	pop    %edi
  80123d:	5d                   	pop    %ebp
  80123e:	c3                   	ret    
  80123f:	90                   	nop
  801240:	39 d1                	cmp    %edx,%ecx
  801242:	75 d8                	jne    80121c <__umoddi3+0x11c>
  801244:	89 d6                	mov    %edx,%esi
  801246:	89 c7                	mov    %eax,%edi
  801248:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  80124c:	1b 34 24             	sbb    (%esp),%esi
  80124f:	eb cb                	jmp    80121c <__umoddi3+0x11c>
  801251:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801258:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80125c:	0f 82 ff fe ff ff    	jb     801161 <__umoddi3+0x61>
  801262:	e9 0a ff ff ff       	jmp    801171 <__umoddi3+0x71>
