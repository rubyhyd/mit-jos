
obj/user/faultregs:     file format elf32-i386


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
  80002c:	e8 2f 05 00 00       	call   800560 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	89 c6                	mov    %eax,%esi
  80003f:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800041:	8b 45 08             	mov    0x8(%ebp),%eax
  800044:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800048:	89 54 24 08          	mov    %edx,0x8(%esp)
  80004c:	c7 44 24 04 51 16 80 	movl   $0x801651,0x4(%esp)
  800053:	00 
  800054:	c7 04 24 20 16 80 00 	movl   $0x801620,(%esp)
  80005b:	e8 82 06 00 00       	call   8006e2 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800060:	8b 03                	mov    (%ebx),%eax
  800062:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800066:	8b 06                	mov    (%esi),%eax
  800068:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006c:	c7 44 24 04 30 16 80 	movl   $0x801630,0x4(%esp)
  800073:	00 
  800074:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  80007b:	e8 62 06 00 00       	call   8006e2 <cprintf>
  800080:	8b 03                	mov    (%ebx),%eax
  800082:	39 06                	cmp    %eax,(%esi)
  800084:	75 13                	jne    800099 <check_regs+0x65>
  800086:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  80008d:	e8 50 06 00 00       	call   8006e2 <cprintf>

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  800092:	bf 00 00 00 00       	mov    $0x0,%edi
  800097:	eb 11                	jmp    8000aa <check_regs+0x76>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800099:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  8000a0:	e8 3d 06 00 00       	call   8006e2 <cprintf>
  8000a5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000aa:	8b 43 04             	mov    0x4(%ebx),%eax
  8000ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b1:	8b 46 04             	mov    0x4(%esi),%eax
  8000b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b8:	c7 44 24 04 52 16 80 	movl   $0x801652,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  8000c7:	e8 16 06 00 00       	call   8006e2 <cprintf>
  8000cc:	8b 43 04             	mov    0x4(%ebx),%eax
  8000cf:	39 46 04             	cmp    %eax,0x4(%esi)
  8000d2:	75 0e                	jne    8000e2 <check_regs+0xae>
  8000d4:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  8000db:	e8 02 06 00 00       	call   8006e2 <cprintf>
  8000e0:	eb 11                	jmp    8000f3 <check_regs+0xbf>
  8000e2:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  8000e9:	e8 f4 05 00 00       	call   8006e2 <cprintf>
  8000ee:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f3:	8b 43 08             	mov    0x8(%ebx),%eax
  8000f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fa:	8b 46 08             	mov    0x8(%esi),%eax
  8000fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800101:	c7 44 24 04 56 16 80 	movl   $0x801656,0x4(%esp)
  800108:	00 
  800109:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  800110:	e8 cd 05 00 00       	call   8006e2 <cprintf>
  800115:	8b 43 08             	mov    0x8(%ebx),%eax
  800118:	39 46 08             	cmp    %eax,0x8(%esi)
  80011b:	75 0e                	jne    80012b <check_regs+0xf7>
  80011d:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  800124:	e8 b9 05 00 00       	call   8006e2 <cprintf>
  800129:	eb 11                	jmp    80013c <check_regs+0x108>
  80012b:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  800132:	e8 ab 05 00 00       	call   8006e2 <cprintf>
  800137:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013c:	8b 43 10             	mov    0x10(%ebx),%eax
  80013f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800143:	8b 46 10             	mov    0x10(%esi),%eax
  800146:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014a:	c7 44 24 04 5a 16 80 	movl   $0x80165a,0x4(%esp)
  800151:	00 
  800152:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  800159:	e8 84 05 00 00       	call   8006e2 <cprintf>
  80015e:	8b 43 10             	mov    0x10(%ebx),%eax
  800161:	39 46 10             	cmp    %eax,0x10(%esi)
  800164:	75 0e                	jne    800174 <check_regs+0x140>
  800166:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  80016d:	e8 70 05 00 00       	call   8006e2 <cprintf>
  800172:	eb 11                	jmp    800185 <check_regs+0x151>
  800174:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  80017b:	e8 62 05 00 00       	call   8006e2 <cprintf>
  800180:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800185:	8b 43 14             	mov    0x14(%ebx),%eax
  800188:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018c:	8b 46 14             	mov    0x14(%esi),%eax
  80018f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800193:	c7 44 24 04 5e 16 80 	movl   $0x80165e,0x4(%esp)
  80019a:	00 
  80019b:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  8001a2:	e8 3b 05 00 00       	call   8006e2 <cprintf>
  8001a7:	8b 43 14             	mov    0x14(%ebx),%eax
  8001aa:	39 46 14             	cmp    %eax,0x14(%esi)
  8001ad:	75 0e                	jne    8001bd <check_regs+0x189>
  8001af:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  8001b6:	e8 27 05 00 00       	call   8006e2 <cprintf>
  8001bb:	eb 11                	jmp    8001ce <check_regs+0x19a>
  8001bd:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  8001c4:	e8 19 05 00 00       	call   8006e2 <cprintf>
  8001c9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001ce:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d5:	8b 46 18             	mov    0x18(%esi),%eax
  8001d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dc:	c7 44 24 04 62 16 80 	movl   $0x801662,0x4(%esp)
  8001e3:	00 
  8001e4:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  8001eb:	e8 f2 04 00 00       	call   8006e2 <cprintf>
  8001f0:	8b 43 18             	mov    0x18(%ebx),%eax
  8001f3:	39 46 18             	cmp    %eax,0x18(%esi)
  8001f6:	75 0e                	jne    800206 <check_regs+0x1d2>
  8001f8:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  8001ff:	e8 de 04 00 00       	call   8006e2 <cprintf>
  800204:	eb 11                	jmp    800217 <check_regs+0x1e3>
  800206:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  80020d:	e8 d0 04 00 00       	call   8006e2 <cprintf>
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800217:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80021a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021e:	8b 46 1c             	mov    0x1c(%esi),%eax
  800221:	89 44 24 08          	mov    %eax,0x8(%esp)
  800225:	c7 44 24 04 66 16 80 	movl   $0x801666,0x4(%esp)
  80022c:	00 
  80022d:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  800234:	e8 a9 04 00 00       	call   8006e2 <cprintf>
  800239:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80023c:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80023f:	75 0e                	jne    80024f <check_regs+0x21b>
  800241:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  800248:	e8 95 04 00 00       	call   8006e2 <cprintf>
  80024d:	eb 11                	jmp    800260 <check_regs+0x22c>
  80024f:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  800256:	e8 87 04 00 00       	call   8006e2 <cprintf>
  80025b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800260:	8b 43 20             	mov    0x20(%ebx),%eax
  800263:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800267:	8b 46 20             	mov    0x20(%esi),%eax
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	c7 44 24 04 6a 16 80 	movl   $0x80166a,0x4(%esp)
  800275:	00 
  800276:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  80027d:	e8 60 04 00 00       	call   8006e2 <cprintf>
  800282:	8b 43 20             	mov    0x20(%ebx),%eax
  800285:	39 46 20             	cmp    %eax,0x20(%esi)
  800288:	75 0e                	jne    800298 <check_regs+0x264>
  80028a:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  800291:	e8 4c 04 00 00       	call   8006e2 <cprintf>
  800296:	eb 11                	jmp    8002a9 <check_regs+0x275>
  800298:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  80029f:	e8 3e 04 00 00       	call   8006e2 <cprintf>
  8002a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a9:	8b 43 24             	mov    0x24(%ebx),%eax
  8002ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b0:	8b 46 24             	mov    0x24(%esi),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	c7 44 24 04 6e 16 80 	movl   $0x80166e,0x4(%esp)
  8002be:	00 
  8002bf:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  8002c6:	e8 17 04 00 00       	call   8006e2 <cprintf>
  8002cb:	8b 43 24             	mov    0x24(%ebx),%eax
  8002ce:	39 46 24             	cmp    %eax,0x24(%esi)
  8002d1:	75 0e                	jne    8002e1 <check_regs+0x2ad>
  8002d3:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  8002da:	e8 03 04 00 00       	call   8006e2 <cprintf>
  8002df:	eb 11                	jmp    8002f2 <check_regs+0x2be>
  8002e1:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  8002e8:	e8 f5 03 00 00       	call   8006e2 <cprintf>
  8002ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f2:	8b 43 28             	mov    0x28(%ebx),%eax
  8002f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f9:	8b 46 28             	mov    0x28(%esi),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	c7 44 24 04 75 16 80 	movl   $0x801675,0x4(%esp)
  800307:	00 
  800308:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  80030f:	e8 ce 03 00 00       	call   8006e2 <cprintf>
  800314:	8b 43 28             	mov    0x28(%ebx),%eax
  800317:	39 46 28             	cmp    %eax,0x28(%esi)
  80031a:	75 25                	jne    800341 <check_regs+0x30d>
  80031c:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  800323:	e8 ba 03 00 00       	call   8006e2 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	c7 04 24 79 16 80 00 	movl   $0x801679,(%esp)
  800336:	e8 a7 03 00 00       	call   8006e2 <cprintf>
	if (!mismatch)
  80033b:	85 ff                	test   %edi,%edi
  80033d:	74 23                	je     800362 <check_regs+0x32e>
  80033f:	eb 2f                	jmp    800370 <check_regs+0x33c>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800341:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  800348:	e8 95 03 00 00       	call   8006e2 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800350:	89 44 24 04          	mov    %eax,0x4(%esp)
  800354:	c7 04 24 79 16 80 00 	movl   $0x801679,(%esp)
  80035b:	e8 82 03 00 00       	call   8006e2 <cprintf>
  800360:	eb 0e                	jmp    800370 <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  800362:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  800369:	e8 74 03 00 00       	call   8006e2 <cprintf>
  80036e:	eb 0c                	jmp    80037c <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  800370:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  800377:	e8 66 03 00 00       	call   8006e2 <cprintf>
}
  80037c:	83 c4 1c             	add    $0x1c,%esp
  80037f:	5b                   	pop    %ebx
  800380:	5e                   	pop    %esi
  800381:	5f                   	pop    %edi
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	83 ec 20             	sub    $0x20,%esp
  80038c:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  80038f:	8b 10                	mov    (%eax),%edx
  800391:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  800397:	74 27                	je     8003c0 <pgfault+0x3c>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800399:	8b 40 28             	mov    0x28(%eax),%eax
  80039c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a4:	c7 44 24 08 e0 16 80 	movl   $0x8016e0,0x8(%esp)
  8003ab:	00 
  8003ac:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b3:	00 
  8003b4:	c7 04 24 87 16 80 00 	movl   $0x801687,(%esp)
  8003bb:	e8 28 02 00 00       	call   8005e8 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003c0:	bf 60 20 80 00       	mov    $0x802060,%edi
  8003c5:	8d 70 08             	lea    0x8(%eax),%esi
  8003c8:	b9 08 00 00 00       	mov    $0x8,%ecx
  8003cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	during.eip = utf->utf_eip;
  8003cf:	8b 50 28             	mov    0x28(%eax),%edx
  8003d2:	89 17                	mov    %edx,(%edi)
	during.eflags = utf->utf_eflags;
  8003d4:	8b 50 2c             	mov    0x2c(%eax),%edx
  8003d7:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  8003dd:	8b 40 30             	mov    0x30(%eax),%eax
  8003e0:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  8003e5:	c7 44 24 04 9f 16 80 	movl   $0x80169f,0x4(%esp)
  8003ec:	00 
  8003ed:	c7 04 24 ad 16 80 00 	movl   $0x8016ad,(%esp)
  8003f4:	b9 60 20 80 00       	mov    $0x802060,%ecx
  8003f9:	ba 98 16 80 00       	mov    $0x801698,%edx
  8003fe:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  800403:	e8 2c fc ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800408:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80040f:	00 
  800410:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  800417:	00 
  800418:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80041f:	e8 ad 0c 00 00       	call   8010d1 <sys_page_alloc>
  800424:	85 c0                	test   %eax,%eax
  800426:	79 20                	jns    800448 <pgfault+0xc4>
		panic("sys_page_alloc: %e", r);
  800428:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042c:	c7 44 24 08 b4 16 80 	movl   $0x8016b4,0x8(%esp)
  800433:	00 
  800434:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  80043b:	00 
  80043c:	c7 04 24 87 16 80 00 	movl   $0x801687,(%esp)
  800443:	e8 a0 01 00 00       	call   8005e8 <_panic>
}
  800448:	83 c4 20             	add    $0x20,%esp
  80044b:	5e                   	pop    %esi
  80044c:	5f                   	pop    %edi
  80044d:	5d                   	pop    %ebp
  80044e:	c3                   	ret    

0080044f <umain>:

void
umain(int argc, char **argv)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800455:	c7 04 24 84 03 80 00 	movl   $0x800384,(%esp)
  80045c:	e8 87 0e 00 00       	call   8012e8 <set_pgfault_handler>

	__asm __volatile(
  800461:	50                   	push   %eax
  800462:	9c                   	pushf  
  800463:	58                   	pop    %eax
  800464:	0d d5 08 00 00       	or     $0x8d5,%eax
  800469:	50                   	push   %eax
  80046a:	9d                   	popf   
  80046b:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  800470:	8d 05 ab 04 80 00    	lea    0x8004ab,%eax
  800476:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  80047b:	58                   	pop    %eax
  80047c:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  800482:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  800488:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  80048e:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  800494:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  80049a:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  8004a0:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  8004a5:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  8004ab:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004b2:	00 00 00 
  8004b5:	89 3d 20 20 80 00    	mov    %edi,0x802020
  8004bb:	89 35 24 20 80 00    	mov    %esi,0x802024
  8004c1:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  8004c7:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  8004cd:	89 15 34 20 80 00    	mov    %edx,0x802034
  8004d3:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  8004d9:	a3 3c 20 80 00       	mov    %eax,0x80203c
  8004de:	89 25 48 20 80 00    	mov    %esp,0x802048
  8004e4:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  8004ea:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  8004f0:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  8004f6:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  8004fc:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  800502:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  800508:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  80050d:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  800513:	50                   	push   %eax
  800514:	9c                   	pushf  
  800515:	58                   	pop    %eax
  800516:	a3 44 20 80 00       	mov    %eax,0x802044
  80051b:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80051c:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800523:	74 0c                	je     800531 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  800525:	c7 04 24 14 17 80 00 	movl   $0x801714,(%esp)
  80052c:	e8 b1 01 00 00       	call   8006e2 <cprintf>
	after.eip = before.eip;
  800531:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  800536:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  80053b:	c7 44 24 04 c7 16 80 	movl   $0x8016c7,0x4(%esp)
  800542:	00 
  800543:	c7 04 24 d8 16 80 00 	movl   $0x8016d8,(%esp)
  80054a:	b9 20 20 80 00       	mov    $0x802020,%ecx
  80054f:	ba 98 16 80 00       	mov    $0x801698,%edx
  800554:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  800559:	e8 d6 fa ff ff       	call   800034 <check_regs>
}
  80055e:	c9                   	leave  
  80055f:	c3                   	ret    

00800560 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	56                   	push   %esi
  800564:	53                   	push   %ebx
  800565:	83 ec 10             	sub    $0x10,%esp
  800568:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80056b:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  80056e:	b8 d4 20 80 00       	mov    $0x8020d4,%eax
  800573:	2d 04 20 80 00       	sub    $0x802004,%eax
  800578:	89 44 24 08          	mov    %eax,0x8(%esp)
  80057c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800583:	00 
  800584:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  80058b:	e8 7f 08 00 00       	call   800e0f <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  800590:	e8 fe 0a 00 00       	call   801093 <sys_getenvid>
  800595:	25 ff 03 00 00       	and    $0x3ff,%eax
  80059a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8005a1:	c1 e0 07             	shl    $0x7,%eax
  8005a4:	29 d0                	sub    %edx,%eax
  8005a6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005ab:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005b0:	85 db                	test   %ebx,%ebx
  8005b2:	7e 07                	jle    8005bb <libmain+0x5b>
		binaryname = argv[0];
  8005b4:	8b 06                	mov    (%esi),%eax
  8005b6:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8005bb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005bf:	89 1c 24             	mov    %ebx,(%esp)
  8005c2:	e8 88 fe ff ff       	call   80044f <umain>

	// exit gracefully
	exit();
  8005c7:	e8 08 00 00 00       	call   8005d4 <exit>
}
  8005cc:	83 c4 10             	add    $0x10,%esp
  8005cf:	5b                   	pop    %ebx
  8005d0:	5e                   	pop    %esi
  8005d1:	5d                   	pop    %ebp
  8005d2:	c3                   	ret    
  8005d3:	90                   	nop

008005d4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005d4:	55                   	push   %ebp
  8005d5:	89 e5                	mov    %esp,%ebp
  8005d7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8005da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005e1:	e8 5b 0a 00 00       	call   801041 <sys_env_destroy>
}
  8005e6:	c9                   	leave  
  8005e7:	c3                   	ret    

008005e8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005e8:	55                   	push   %ebp
  8005e9:	89 e5                	mov    %esp,%ebp
  8005eb:	56                   	push   %esi
  8005ec:	53                   	push   %ebx
  8005ed:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005f0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005f3:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8005f9:	e8 95 0a 00 00       	call   801093 <sys_getenvid>
  8005fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800601:	89 54 24 10          	mov    %edx,0x10(%esp)
  800605:	8b 55 08             	mov    0x8(%ebp),%edx
  800608:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80060c:	89 74 24 08          	mov    %esi,0x8(%esp)
  800610:	89 44 24 04          	mov    %eax,0x4(%esp)
  800614:	c7 04 24 40 17 80 00 	movl   $0x801740,(%esp)
  80061b:	e8 c2 00 00 00       	call   8006e2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800620:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800624:	8b 45 10             	mov    0x10(%ebp),%eax
  800627:	89 04 24             	mov    %eax,(%esp)
  80062a:	e8 52 00 00 00       	call   800681 <vcprintf>
	cprintf("\n");
  80062f:	c7 04 24 50 16 80 00 	movl   $0x801650,(%esp)
  800636:	e8 a7 00 00 00       	call   8006e2 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80063b:	cc                   	int3   
  80063c:	eb fd                	jmp    80063b <_panic+0x53>
  80063e:	66 90                	xchg   %ax,%ax

00800640 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800640:	55                   	push   %ebp
  800641:	89 e5                	mov    %esp,%ebp
  800643:	53                   	push   %ebx
  800644:	83 ec 14             	sub    $0x14,%esp
  800647:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80064a:	8b 13                	mov    (%ebx),%edx
  80064c:	8d 42 01             	lea    0x1(%edx),%eax
  80064f:	89 03                	mov    %eax,(%ebx)
  800651:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800654:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800658:	3d ff 00 00 00       	cmp    $0xff,%eax
  80065d:	75 19                	jne    800678 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80065f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800666:	00 
  800667:	8d 43 08             	lea    0x8(%ebx),%eax
  80066a:	89 04 24             	mov    %eax,(%esp)
  80066d:	e8 92 09 00 00       	call   801004 <sys_cputs>
		b->idx = 0;
  800672:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800678:	ff 43 04             	incl   0x4(%ebx)
}
  80067b:	83 c4 14             	add    $0x14,%esp
  80067e:	5b                   	pop    %ebx
  80067f:	5d                   	pop    %ebp
  800680:	c3                   	ret    

00800681 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800681:	55                   	push   %ebp
  800682:	89 e5                	mov    %esp,%ebp
  800684:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80068a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800691:	00 00 00 
	b.cnt = 0;
  800694:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80069b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80069e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ac:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b6:	c7 04 24 40 06 80 00 	movl   $0x800640,(%esp)
  8006bd:	e8 a9 01 00 00       	call   80086b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006c2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006d2:	89 04 24             	mov    %eax,(%esp)
  8006d5:	e8 2a 09 00 00       	call   801004 <sys_cputs>

	return b.cnt;
}
  8006da:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006e0:	c9                   	leave  
  8006e1:	c3                   	ret    

008006e2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006e8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f2:	89 04 24             	mov    %eax,(%esp)
  8006f5:	e8 87 ff ff ff       	call   800681 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006fa:	c9                   	leave  
  8006fb:	c3                   	ret    

008006fc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	57                   	push   %edi
  800700:	56                   	push   %esi
  800701:	53                   	push   %ebx
  800702:	83 ec 3c             	sub    $0x3c,%esp
  800705:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800708:	89 d7                	mov    %edx,%edi
  80070a:	8b 45 08             	mov    0x8(%ebp),%eax
  80070d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800710:	8b 45 0c             	mov    0xc(%ebp),%eax
  800713:	89 c1                	mov    %eax,%ecx
  800715:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800718:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80071b:	8b 45 10             	mov    0x10(%ebp),%eax
  80071e:	ba 00 00 00 00       	mov    $0x0,%edx
  800723:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800726:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800729:	39 ca                	cmp    %ecx,%edx
  80072b:	72 08                	jb     800735 <printnum+0x39>
  80072d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800730:	39 45 10             	cmp    %eax,0x10(%ebp)
  800733:	77 6a                	ja     80079f <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800735:	8b 45 18             	mov    0x18(%ebp),%eax
  800738:	89 44 24 10          	mov    %eax,0x10(%esp)
  80073c:	4e                   	dec    %esi
  80073d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800741:	8b 45 10             	mov    0x10(%ebp),%eax
  800744:	89 44 24 08          	mov    %eax,0x8(%esp)
  800748:	8b 44 24 08          	mov    0x8(%esp),%eax
  80074c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800750:	89 c3                	mov    %eax,%ebx
  800752:	89 d6                	mov    %edx,%esi
  800754:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800757:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80075a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80075e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800762:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800765:	89 04 24             	mov    %eax,(%esp)
  800768:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80076b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076f:	e8 0c 0c 00 00       	call   801380 <__udivdi3>
  800774:	89 d9                	mov    %ebx,%ecx
  800776:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80077a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80077e:	89 04 24             	mov    %eax,(%esp)
  800781:	89 54 24 04          	mov    %edx,0x4(%esp)
  800785:	89 fa                	mov    %edi,%edx
  800787:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80078a:	e8 6d ff ff ff       	call   8006fc <printnum>
  80078f:	eb 19                	jmp    8007aa <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800791:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800795:	8b 45 18             	mov    0x18(%ebp),%eax
  800798:	89 04 24             	mov    %eax,(%esp)
  80079b:	ff d3                	call   *%ebx
  80079d:	eb 03                	jmp    8007a2 <printnum+0xa6>
  80079f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007a2:	4e                   	dec    %esi
  8007a3:	85 f6                	test   %esi,%esi
  8007a5:	7f ea                	jg     800791 <printnum+0x95>
  8007a7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ae:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8007b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007b5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007c3:	89 04 24             	mov    %eax,(%esp)
  8007c6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cd:	e8 de 0c 00 00       	call   8014b0 <__umoddi3>
  8007d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007d6:	0f be 80 64 17 80 00 	movsbl 0x801764(%eax),%eax
  8007dd:	89 04 24             	mov    %eax,(%esp)
  8007e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007e3:	ff d0                	call   *%eax
}
  8007e5:	83 c4 3c             	add    $0x3c,%esp
  8007e8:	5b                   	pop    %ebx
  8007e9:	5e                   	pop    %esi
  8007ea:	5f                   	pop    %edi
  8007eb:	5d                   	pop    %ebp
  8007ec:	c3                   	ret    

008007ed <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007f0:	83 fa 01             	cmp    $0x1,%edx
  8007f3:	7e 0e                	jle    800803 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007f5:	8b 10                	mov    (%eax),%edx
  8007f7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007fa:	89 08                	mov    %ecx,(%eax)
  8007fc:	8b 02                	mov    (%edx),%eax
  8007fe:	8b 52 04             	mov    0x4(%edx),%edx
  800801:	eb 22                	jmp    800825 <getuint+0x38>
	else if (lflag)
  800803:	85 d2                	test   %edx,%edx
  800805:	74 10                	je     800817 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800807:	8b 10                	mov    (%eax),%edx
  800809:	8d 4a 04             	lea    0x4(%edx),%ecx
  80080c:	89 08                	mov    %ecx,(%eax)
  80080e:	8b 02                	mov    (%edx),%eax
  800810:	ba 00 00 00 00       	mov    $0x0,%edx
  800815:	eb 0e                	jmp    800825 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800817:	8b 10                	mov    (%eax),%edx
  800819:	8d 4a 04             	lea    0x4(%edx),%ecx
  80081c:	89 08                	mov    %ecx,(%eax)
  80081e:	8b 02                	mov    (%edx),%eax
  800820:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80082d:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800830:	8b 10                	mov    (%eax),%edx
  800832:	3b 50 04             	cmp    0x4(%eax),%edx
  800835:	73 0a                	jae    800841 <sprintputch+0x1a>
		*b->buf++ = ch;
  800837:	8d 4a 01             	lea    0x1(%edx),%ecx
  80083a:	89 08                	mov    %ecx,(%eax)
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	88 02                	mov    %al,(%edx)
}
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800849:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80084c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800850:	8b 45 10             	mov    0x10(%ebp),%eax
  800853:	89 44 24 08          	mov    %eax,0x8(%esp)
  800857:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	89 04 24             	mov    %eax,(%esp)
  800864:	e8 02 00 00 00       	call   80086b <vprintfmt>
	va_end(ap);
}
  800869:	c9                   	leave  
  80086a:	c3                   	ret    

0080086b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	57                   	push   %edi
  80086f:	56                   	push   %esi
  800870:	53                   	push   %ebx
  800871:	83 ec 3c             	sub    $0x3c,%esp
  800874:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800877:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80087a:	eb 14                	jmp    800890 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80087c:	85 c0                	test   %eax,%eax
  80087e:	0f 84 8a 03 00 00    	je     800c0e <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  800884:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800888:	89 04 24             	mov    %eax,(%esp)
  80088b:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80088e:	89 f3                	mov    %esi,%ebx
  800890:	8d 73 01             	lea    0x1(%ebx),%esi
  800893:	31 c0                	xor    %eax,%eax
  800895:	8a 03                	mov    (%ebx),%al
  800897:	83 f8 25             	cmp    $0x25,%eax
  80089a:	75 e0                	jne    80087c <vprintfmt+0x11>
  80089c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8008a0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008a7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008ae:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8008b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ba:	eb 1d                	jmp    8008d9 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008bc:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008be:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8008c2:	eb 15                	jmp    8008d9 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c4:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008c6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8008ca:	eb 0d                	jmp    8008d9 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8008cc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8008d2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d9:	8d 5e 01             	lea    0x1(%esi),%ebx
  8008dc:	31 c0                	xor    %eax,%eax
  8008de:	8a 06                	mov    (%esi),%al
  8008e0:	8a 0e                	mov    (%esi),%cl
  8008e2:	83 e9 23             	sub    $0x23,%ecx
  8008e5:	88 4d e0             	mov    %cl,-0x20(%ebp)
  8008e8:	80 f9 55             	cmp    $0x55,%cl
  8008eb:	0f 87 ff 02 00 00    	ja     800bf0 <vprintfmt+0x385>
  8008f1:	31 c9                	xor    %ecx,%ecx
  8008f3:	8a 4d e0             	mov    -0x20(%ebp),%cl
  8008f6:	ff 24 8d 20 18 80 00 	jmp    *0x801820(,%ecx,4)
  8008fd:	89 de                	mov    %ebx,%esi
  8008ff:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800904:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800907:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  80090b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80090e:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800911:	83 fb 09             	cmp    $0x9,%ebx
  800914:	77 2f                	ja     800945 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800916:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800917:	eb eb                	jmp    800904 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800919:	8b 45 14             	mov    0x14(%ebp),%eax
  80091c:	8d 48 04             	lea    0x4(%eax),%ecx
  80091f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800922:	8b 00                	mov    (%eax),%eax
  800924:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800927:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800929:	eb 1d                	jmp    800948 <vprintfmt+0xdd>
  80092b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80092e:	f7 d0                	not    %eax
  800930:	c1 f8 1f             	sar    $0x1f,%eax
  800933:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800936:	89 de                	mov    %ebx,%esi
  800938:	eb 9f                	jmp    8008d9 <vprintfmt+0x6e>
  80093a:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80093c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800943:	eb 94                	jmp    8008d9 <vprintfmt+0x6e>
  800945:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800948:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80094c:	79 8b                	jns    8008d9 <vprintfmt+0x6e>
  80094e:	e9 79 ff ff ff       	jmp    8008cc <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800953:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800954:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800956:	eb 81                	jmp    8008d9 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800958:	8b 45 14             	mov    0x14(%ebp),%eax
  80095b:	8d 50 04             	lea    0x4(%eax),%edx
  80095e:	89 55 14             	mov    %edx,0x14(%ebp)
  800961:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800965:	8b 00                	mov    (%eax),%eax
  800967:	89 04 24             	mov    %eax,(%esp)
  80096a:	ff 55 08             	call   *0x8(%ebp)
			break;
  80096d:	e9 1e ff ff ff       	jmp    800890 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800972:	8b 45 14             	mov    0x14(%ebp),%eax
  800975:	8d 50 04             	lea    0x4(%eax),%edx
  800978:	89 55 14             	mov    %edx,0x14(%ebp)
  80097b:	8b 00                	mov    (%eax),%eax
  80097d:	89 c2                	mov    %eax,%edx
  80097f:	c1 fa 1f             	sar    $0x1f,%edx
  800982:	31 d0                	xor    %edx,%eax
  800984:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800986:	83 f8 09             	cmp    $0x9,%eax
  800989:	7f 0b                	jg     800996 <vprintfmt+0x12b>
  80098b:	8b 14 85 80 19 80 00 	mov    0x801980(,%eax,4),%edx
  800992:	85 d2                	test   %edx,%edx
  800994:	75 20                	jne    8009b6 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  800996:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80099a:	c7 44 24 08 7c 17 80 	movl   $0x80177c,0x8(%esp)
  8009a1:	00 
  8009a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	89 04 24             	mov    %eax,(%esp)
  8009ac:	e8 92 fe ff ff       	call   800843 <printfmt>
  8009b1:	e9 da fe ff ff       	jmp    800890 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8009b6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009ba:	c7 44 24 08 85 17 80 	movl   $0x801785,0x8(%esp)
  8009c1:	00 
  8009c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	89 04 24             	mov    %eax,(%esp)
  8009cc:	e8 72 fe ff ff       	call   800843 <printfmt>
  8009d1:	e9 ba fe ff ff       	jmp    800890 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009d6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8009d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8009dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009df:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e2:	8d 50 04             	lea    0x4(%eax),%edx
  8009e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009e8:	8b 30                	mov    (%eax),%esi
  8009ea:	85 f6                	test   %esi,%esi
  8009ec:	75 05                	jne    8009f3 <vprintfmt+0x188>
				p = "(null)";
  8009ee:	be 75 17 80 00       	mov    $0x801775,%esi
			if (width > 0 && padc != '-')
  8009f3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8009f7:	0f 84 8c 00 00 00    	je     800a89 <vprintfmt+0x21e>
  8009fd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a01:	0f 8e 8a 00 00 00    	jle    800a91 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a07:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a0b:	89 34 24             	mov    %esi,(%esp)
  800a0e:	e8 9b 02 00 00       	call   800cae <strnlen>
  800a13:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a16:	29 c1                	sub    %eax,%ecx
  800a18:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800a1b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a22:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800a25:	8b 75 08             	mov    0x8(%ebp),%esi
  800a28:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a2b:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a2d:	eb 0d                	jmp    800a3c <vprintfmt+0x1d1>
					putch(padc, putdat);
  800a2f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a33:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a36:	89 04 24             	mov    %eax,(%esp)
  800a39:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a3b:	4b                   	dec    %ebx
  800a3c:	85 db                	test   %ebx,%ebx
  800a3e:	7f ef                	jg     800a2f <vprintfmt+0x1c4>
  800a40:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800a43:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800a46:	89 c8                	mov    %ecx,%eax
  800a48:	f7 d0                	not    %eax
  800a4a:	c1 f8 1f             	sar    $0x1f,%eax
  800a4d:	21 c8                	and    %ecx,%eax
  800a4f:	29 c1                	sub    %eax,%ecx
  800a51:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800a54:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a57:	eb 3e                	jmp    800a97 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a59:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a5d:	74 1b                	je     800a7a <vprintfmt+0x20f>
  800a5f:	0f be d2             	movsbl %dl,%edx
  800a62:	83 ea 20             	sub    $0x20,%edx
  800a65:	83 fa 5e             	cmp    $0x5e,%edx
  800a68:	76 10                	jbe    800a7a <vprintfmt+0x20f>
					putch('?', putdat);
  800a6a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a6e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a75:	ff 55 08             	call   *0x8(%ebp)
  800a78:	eb 0a                	jmp    800a84 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800a7a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a7e:	89 04 24             	mov    %eax,(%esp)
  800a81:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a84:	ff 4d dc             	decl   -0x24(%ebp)
  800a87:	eb 0e                	jmp    800a97 <vprintfmt+0x22c>
  800a89:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a8c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a8f:	eb 06                	jmp    800a97 <vprintfmt+0x22c>
  800a91:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a94:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a97:	46                   	inc    %esi
  800a98:	8a 56 ff             	mov    -0x1(%esi),%dl
  800a9b:	0f be c2             	movsbl %dl,%eax
  800a9e:	85 c0                	test   %eax,%eax
  800aa0:	74 1f                	je     800ac1 <vprintfmt+0x256>
  800aa2:	85 db                	test   %ebx,%ebx
  800aa4:	78 b3                	js     800a59 <vprintfmt+0x1ee>
  800aa6:	4b                   	dec    %ebx
  800aa7:	79 b0                	jns    800a59 <vprintfmt+0x1ee>
  800aa9:	8b 75 08             	mov    0x8(%ebp),%esi
  800aac:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800aaf:	eb 16                	jmp    800ac7 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800ab1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ab5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800abc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800abe:	4b                   	dec    %ebx
  800abf:	eb 06                	jmp    800ac7 <vprintfmt+0x25c>
  800ac1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800ac4:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac7:	85 db                	test   %ebx,%ebx
  800ac9:	7f e6                	jg     800ab1 <vprintfmt+0x246>
  800acb:	89 75 08             	mov    %esi,0x8(%ebp)
  800ace:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ad1:	e9 ba fd ff ff       	jmp    800890 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ad6:	83 fa 01             	cmp    $0x1,%edx
  800ad9:	7e 16                	jle    800af1 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  800adb:	8b 45 14             	mov    0x14(%ebp),%eax
  800ade:	8d 50 08             	lea    0x8(%eax),%edx
  800ae1:	89 55 14             	mov    %edx,0x14(%ebp)
  800ae4:	8b 50 04             	mov    0x4(%eax),%edx
  800ae7:	8b 00                	mov    (%eax),%eax
  800ae9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800aec:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800aef:	eb 32                	jmp    800b23 <vprintfmt+0x2b8>
	else if (lflag)
  800af1:	85 d2                	test   %edx,%edx
  800af3:	74 18                	je     800b0d <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800af5:	8b 45 14             	mov    0x14(%ebp),%eax
  800af8:	8d 50 04             	lea    0x4(%eax),%edx
  800afb:	89 55 14             	mov    %edx,0x14(%ebp)
  800afe:	8b 30                	mov    (%eax),%esi
  800b00:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800b03:	89 f0                	mov    %esi,%eax
  800b05:	c1 f8 1f             	sar    $0x1f,%eax
  800b08:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b0b:	eb 16                	jmp    800b23 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800b0d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b10:	8d 50 04             	lea    0x4(%eax),%edx
  800b13:	89 55 14             	mov    %edx,0x14(%ebp)
  800b16:	8b 30                	mov    (%eax),%esi
  800b18:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800b1b:	89 f0                	mov    %esi,%eax
  800b1d:	c1 f8 1f             	sar    $0x1f,%eax
  800b20:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b23:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b26:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b29:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b2e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b32:	0f 89 80 00 00 00    	jns    800bb8 <vprintfmt+0x34d>
				putch('-', putdat);
  800b38:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b3c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b43:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b46:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b49:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b4c:	f7 d8                	neg    %eax
  800b4e:	83 d2 00             	adc    $0x0,%edx
  800b51:	f7 da                	neg    %edx
			}
			base = 10;
  800b53:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b58:	eb 5e                	jmp    800bb8 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b5a:	8d 45 14             	lea    0x14(%ebp),%eax
  800b5d:	e8 8b fc ff ff       	call   8007ed <getuint>
			base = 10;
  800b62:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b67:	eb 4f                	jmp    800bb8 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800b69:	8d 45 14             	lea    0x14(%ebp),%eax
  800b6c:	e8 7c fc ff ff       	call   8007ed <getuint>
			base = 8;
  800b71:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800b76:	eb 40                	jmp    800bb8 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800b78:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b7c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b83:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b86:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b8a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b91:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b94:	8b 45 14             	mov    0x14(%ebp),%eax
  800b97:	8d 50 04             	lea    0x4(%eax),%edx
  800b9a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b9d:	8b 00                	mov    (%eax),%eax
  800b9f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ba4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800ba9:	eb 0d                	jmp    800bb8 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bab:	8d 45 14             	lea    0x14(%ebp),%eax
  800bae:	e8 3a fc ff ff       	call   8007ed <getuint>
			base = 16;
  800bb3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bb8:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800bbc:	89 74 24 10          	mov    %esi,0x10(%esp)
  800bc0:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800bc3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800bc7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800bcb:	89 04 24             	mov    %eax,(%esp)
  800bce:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bd2:	89 fa                	mov    %edi,%edx
  800bd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd7:	e8 20 fb ff ff       	call   8006fc <printnum>
			break;
  800bdc:	e9 af fc ff ff       	jmp    800890 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800be1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800be5:	89 04 24             	mov    %eax,(%esp)
  800be8:	ff 55 08             	call   *0x8(%ebp)
			break;
  800beb:	e9 a0 fc ff ff       	jmp    800890 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800bf0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bf4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800bfb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bfe:	89 f3                	mov    %esi,%ebx
  800c00:	eb 01                	jmp    800c03 <vprintfmt+0x398>
  800c02:	4b                   	dec    %ebx
  800c03:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800c07:	75 f9                	jne    800c02 <vprintfmt+0x397>
  800c09:	e9 82 fc ff ff       	jmp    800890 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800c0e:	83 c4 3c             	add    $0x3c,%esp
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	83 ec 28             	sub    $0x28,%esp
  800c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c22:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c25:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c29:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c2c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c33:	85 c0                	test   %eax,%eax
  800c35:	74 30                	je     800c67 <vsnprintf+0x51>
  800c37:	85 d2                	test   %edx,%edx
  800c39:	7e 2c                	jle    800c67 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c3b:	8b 45 14             	mov    0x14(%ebp),%eax
  800c3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c42:	8b 45 10             	mov    0x10(%ebp),%eax
  800c45:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c49:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c50:	c7 04 24 27 08 80 00 	movl   $0x800827,(%esp)
  800c57:	e8 0f fc ff ff       	call   80086b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c5f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c65:	eb 05                	jmp    800c6c <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c67:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c6c:	c9                   	leave  
  800c6d:	c3                   	ret    

00800c6e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c74:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c77:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c7b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c85:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c89:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8c:	89 04 24             	mov    %eax,(%esp)
  800c8f:	e8 82 ff ff ff       	call   800c16 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c94:	c9                   	leave  
  800c95:	c3                   	ret    
  800c96:	66 90                	xchg   %ax,%ax

00800c98 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca3:	eb 01                	jmp    800ca6 <strlen+0xe>
		n++;
  800ca5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ca6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800caa:	75 f9                	jne    800ca5 <strlen+0xd>
		n++;
	return n;
}
  800cac:	5d                   	pop    %ebp
  800cad:	c3                   	ret    

00800cae <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cb7:	b8 00 00 00 00       	mov    $0x0,%eax
  800cbc:	eb 01                	jmp    800cbf <strnlen+0x11>
		n++;
  800cbe:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cbf:	39 d0                	cmp    %edx,%eax
  800cc1:	74 06                	je     800cc9 <strnlen+0x1b>
  800cc3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800cc7:	75 f5                	jne    800cbe <strnlen+0x10>
		n++;
	return n;
}
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	53                   	push   %ebx
  800ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cd5:	89 c2                	mov    %eax,%edx
  800cd7:	42                   	inc    %edx
  800cd8:	41                   	inc    %ecx
  800cd9:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800cdc:	88 5a ff             	mov    %bl,-0x1(%edx)
  800cdf:	84 db                	test   %bl,%bl
  800ce1:	75 f4                	jne    800cd7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ce3:	5b                   	pop    %ebx
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	53                   	push   %ebx
  800cea:	83 ec 08             	sub    $0x8,%esp
  800ced:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cf0:	89 1c 24             	mov    %ebx,(%esp)
  800cf3:	e8 a0 ff ff ff       	call   800c98 <strlen>
	strcpy(dst + len, src);
  800cf8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cfb:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cff:	01 d8                	add    %ebx,%eax
  800d01:	89 04 24             	mov    %eax,(%esp)
  800d04:	e8 c2 ff ff ff       	call   800ccb <strcpy>
	return dst;
}
  800d09:	89 d8                	mov    %ebx,%eax
  800d0b:	83 c4 08             	add    $0x8,%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
  800d16:	8b 75 08             	mov    0x8(%ebp),%esi
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	89 f3                	mov    %esi,%ebx
  800d1e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d21:	89 f2                	mov    %esi,%edx
  800d23:	eb 0c                	jmp    800d31 <strncpy+0x20>
		*dst++ = *src;
  800d25:	42                   	inc    %edx
  800d26:	8a 01                	mov    (%ecx),%al
  800d28:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d2b:	80 39 01             	cmpb   $0x1,(%ecx)
  800d2e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d31:	39 da                	cmp    %ebx,%edx
  800d33:	75 f0                	jne    800d25 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d35:	89 f0                	mov    %esi,%eax
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
  800d40:	8b 75 08             	mov    0x8(%ebp),%esi
  800d43:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d46:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d49:	89 f0                	mov    %esi,%eax
  800d4b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d4f:	85 c9                	test   %ecx,%ecx
  800d51:	75 07                	jne    800d5a <strlcpy+0x1f>
  800d53:	eb 18                	jmp    800d6d <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d55:	40                   	inc    %eax
  800d56:	42                   	inc    %edx
  800d57:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d5a:	39 d8                	cmp    %ebx,%eax
  800d5c:	74 0a                	je     800d68 <strlcpy+0x2d>
  800d5e:	8a 0a                	mov    (%edx),%cl
  800d60:	84 c9                	test   %cl,%cl
  800d62:	75 f1                	jne    800d55 <strlcpy+0x1a>
  800d64:	89 c2                	mov    %eax,%edx
  800d66:	eb 02                	jmp    800d6a <strlcpy+0x2f>
  800d68:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800d6a:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800d6d:	29 f0                	sub    %esi,%eax
}
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d79:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d7c:	eb 02                	jmp    800d80 <strcmp+0xd>
		p++, q++;
  800d7e:	41                   	inc    %ecx
  800d7f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d80:	8a 01                	mov    (%ecx),%al
  800d82:	84 c0                	test   %al,%al
  800d84:	74 04                	je     800d8a <strcmp+0x17>
  800d86:	3a 02                	cmp    (%edx),%al
  800d88:	74 f4                	je     800d7e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d8a:	25 ff 00 00 00       	and    $0xff,%eax
  800d8f:	8a 0a                	mov    (%edx),%cl
  800d91:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  800d97:	29 c8                	sub    %ecx,%eax
}
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	53                   	push   %ebx
  800d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800da2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da5:	89 c3                	mov    %eax,%ebx
  800da7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800daa:	eb 02                	jmp    800dae <strncmp+0x13>
		n--, p++, q++;
  800dac:	40                   	inc    %eax
  800dad:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dae:	39 d8                	cmp    %ebx,%eax
  800db0:	74 20                	je     800dd2 <strncmp+0x37>
  800db2:	8a 08                	mov    (%eax),%cl
  800db4:	84 c9                	test   %cl,%cl
  800db6:	74 04                	je     800dbc <strncmp+0x21>
  800db8:	3a 0a                	cmp    (%edx),%cl
  800dba:	74 f0                	je     800dac <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dbc:	8a 18                	mov    (%eax),%bl
  800dbe:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800dc4:	89 d8                	mov    %ebx,%eax
  800dc6:	8a 1a                	mov    (%edx),%bl
  800dc8:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800dce:	29 d8                	sub    %ebx,%eax
  800dd0:	eb 05                	jmp    800dd7 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800dd2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800dd7:	5b                   	pop    %ebx
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  800de0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800de3:	eb 05                	jmp    800dea <strchr+0x10>
		if (*s == c)
  800de5:	38 ca                	cmp    %cl,%dl
  800de7:	74 0c                	je     800df5 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800de9:	40                   	inc    %eax
  800dea:	8a 10                	mov    (%eax),%dl
  800dec:	84 d2                	test   %dl,%dl
  800dee:	75 f5                	jne    800de5 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800df0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    

00800df7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfd:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800e00:	eb 05                	jmp    800e07 <strfind+0x10>
		if (*s == c)
  800e02:	38 ca                	cmp    %cl,%dl
  800e04:	74 07                	je     800e0d <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e06:	40                   	inc    %eax
  800e07:	8a 10                	mov    (%eax),%dl
  800e09:	84 d2                	test   %dl,%dl
  800e0b:	75 f5                	jne    800e02 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	57                   	push   %edi
  800e13:	56                   	push   %esi
  800e14:	53                   	push   %ebx
  800e15:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e18:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e1b:	85 c9                	test   %ecx,%ecx
  800e1d:	74 37                	je     800e56 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e25:	75 29                	jne    800e50 <memset+0x41>
  800e27:	f6 c1 03             	test   $0x3,%cl
  800e2a:	75 24                	jne    800e50 <memset+0x41>
		c &= 0xFF;
  800e2c:	31 d2                	xor    %edx,%edx
  800e2e:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e31:	89 d3                	mov    %edx,%ebx
  800e33:	c1 e3 08             	shl    $0x8,%ebx
  800e36:	89 d6                	mov    %edx,%esi
  800e38:	c1 e6 18             	shl    $0x18,%esi
  800e3b:	89 d0                	mov    %edx,%eax
  800e3d:	c1 e0 10             	shl    $0x10,%eax
  800e40:	09 f0                	or     %esi,%eax
  800e42:	09 c2                	or     %eax,%edx
  800e44:	89 d0                	mov    %edx,%eax
  800e46:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e48:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e4b:	fc                   	cld    
  800e4c:	f3 ab                	rep stos %eax,%es:(%edi)
  800e4e:	eb 06                	jmp    800e56 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e53:	fc                   	cld    
  800e54:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e56:	89 f8                	mov    %edi,%eax
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	57                   	push   %edi
  800e61:	56                   	push   %esi
  800e62:	8b 45 08             	mov    0x8(%ebp),%eax
  800e65:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e68:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e6b:	39 c6                	cmp    %eax,%esi
  800e6d:	73 33                	jae    800ea2 <memmove+0x45>
  800e6f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e72:	39 d0                	cmp    %edx,%eax
  800e74:	73 2c                	jae    800ea2 <memmove+0x45>
		s += n;
		d += n;
  800e76:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800e79:	89 d6                	mov    %edx,%esi
  800e7b:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e7d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e83:	75 13                	jne    800e98 <memmove+0x3b>
  800e85:	f6 c1 03             	test   $0x3,%cl
  800e88:	75 0e                	jne    800e98 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e8a:	83 ef 04             	sub    $0x4,%edi
  800e8d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e90:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e93:	fd                   	std    
  800e94:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e96:	eb 07                	jmp    800e9f <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e98:	4f                   	dec    %edi
  800e99:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e9c:	fd                   	std    
  800e9d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e9f:	fc                   	cld    
  800ea0:	eb 1d                	jmp    800ebf <memmove+0x62>
  800ea2:	89 f2                	mov    %esi,%edx
  800ea4:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ea6:	f6 c2 03             	test   $0x3,%dl
  800ea9:	75 0f                	jne    800eba <memmove+0x5d>
  800eab:	f6 c1 03             	test   $0x3,%cl
  800eae:	75 0a                	jne    800eba <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800eb0:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800eb3:	89 c7                	mov    %eax,%edi
  800eb5:	fc                   	cld    
  800eb6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800eb8:	eb 05                	jmp    800ebf <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800eba:	89 c7                	mov    %eax,%edi
  800ebc:	fc                   	cld    
  800ebd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ec9:	8b 45 10             	mov    0x10(%ebp),%eax
  800ecc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ed7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eda:	89 04 24             	mov    %eax,(%esp)
  800edd:	e8 7b ff ff ff       	call   800e5d <memmove>
}
  800ee2:	c9                   	leave  
  800ee3:	c3                   	ret    

00800ee4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	56                   	push   %esi
  800ee8:	53                   	push   %ebx
  800ee9:	8b 55 08             	mov    0x8(%ebp),%edx
  800eec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eef:	89 d6                	mov    %edx,%esi
  800ef1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ef4:	eb 19                	jmp    800f0f <memcmp+0x2b>
		if (*s1 != *s2)
  800ef6:	8a 02                	mov    (%edx),%al
  800ef8:	8a 19                	mov    (%ecx),%bl
  800efa:	38 d8                	cmp    %bl,%al
  800efc:	74 0f                	je     800f0d <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800efe:	25 ff 00 00 00       	and    $0xff,%eax
  800f03:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800f09:	29 d8                	sub    %ebx,%eax
  800f0b:	eb 0b                	jmp    800f18 <memcmp+0x34>
		s1++, s2++;
  800f0d:	42                   	inc    %edx
  800f0e:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f0f:	39 f2                	cmp    %esi,%edx
  800f11:	75 e3                	jne    800ef6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f18:	5b                   	pop    %ebx
  800f19:	5e                   	pop    %esi
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f25:	89 c2                	mov    %eax,%edx
  800f27:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f2a:	eb 05                	jmp    800f31 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f2c:	38 08                	cmp    %cl,(%eax)
  800f2e:	74 05                	je     800f35 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f30:	40                   	inc    %eax
  800f31:	39 d0                	cmp    %edx,%eax
  800f33:	72 f7                	jb     800f2c <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f35:	5d                   	pop    %ebp
  800f36:	c3                   	ret    

00800f37 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	57                   	push   %edi
  800f3b:	56                   	push   %esi
  800f3c:	53                   	push   %ebx
  800f3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f40:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f43:	eb 01                	jmp    800f46 <strtol+0xf>
		s++;
  800f45:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f46:	8a 02                	mov    (%edx),%al
  800f48:	3c 09                	cmp    $0x9,%al
  800f4a:	74 f9                	je     800f45 <strtol+0xe>
  800f4c:	3c 20                	cmp    $0x20,%al
  800f4e:	74 f5                	je     800f45 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f50:	3c 2b                	cmp    $0x2b,%al
  800f52:	75 08                	jne    800f5c <strtol+0x25>
		s++;
  800f54:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f55:	bf 00 00 00 00       	mov    $0x0,%edi
  800f5a:	eb 10                	jmp    800f6c <strtol+0x35>
  800f5c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f61:	3c 2d                	cmp    $0x2d,%al
  800f63:	75 07                	jne    800f6c <strtol+0x35>
		s++, neg = 1;
  800f65:	8d 52 01             	lea    0x1(%edx),%edx
  800f68:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f6c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f72:	75 15                	jne    800f89 <strtol+0x52>
  800f74:	80 3a 30             	cmpb   $0x30,(%edx)
  800f77:	75 10                	jne    800f89 <strtol+0x52>
  800f79:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f7d:	75 0a                	jne    800f89 <strtol+0x52>
		s += 2, base = 16;
  800f7f:	83 c2 02             	add    $0x2,%edx
  800f82:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f87:	eb 0e                	jmp    800f97 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800f89:	85 db                	test   %ebx,%ebx
  800f8b:	75 0a                	jne    800f97 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f8d:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f8f:	80 3a 30             	cmpb   $0x30,(%edx)
  800f92:	75 03                	jne    800f97 <strtol+0x60>
		s++, base = 8;
  800f94:	42                   	inc    %edx
  800f95:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800f97:	b8 00 00 00 00       	mov    $0x0,%eax
  800f9c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f9f:	8a 0a                	mov    (%edx),%cl
  800fa1:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800fa4:	89 f3                	mov    %esi,%ebx
  800fa6:	80 fb 09             	cmp    $0x9,%bl
  800fa9:	77 08                	ja     800fb3 <strtol+0x7c>
			dig = *s - '0';
  800fab:	0f be c9             	movsbl %cl,%ecx
  800fae:	83 e9 30             	sub    $0x30,%ecx
  800fb1:	eb 22                	jmp    800fd5 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800fb3:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800fb6:	89 f3                	mov    %esi,%ebx
  800fb8:	80 fb 19             	cmp    $0x19,%bl
  800fbb:	77 08                	ja     800fc5 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800fbd:	0f be c9             	movsbl %cl,%ecx
  800fc0:	83 e9 57             	sub    $0x57,%ecx
  800fc3:	eb 10                	jmp    800fd5 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800fc5:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800fc8:	89 f3                	mov    %esi,%ebx
  800fca:	80 fb 19             	cmp    $0x19,%bl
  800fcd:	77 14                	ja     800fe3 <strtol+0xac>
			dig = *s - 'A' + 10;
  800fcf:	0f be c9             	movsbl %cl,%ecx
  800fd2:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800fd5:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800fd8:	7d 0d                	jge    800fe7 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800fda:	42                   	inc    %edx
  800fdb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800fdf:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800fe1:	eb bc                	jmp    800f9f <strtol+0x68>
  800fe3:	89 c1                	mov    %eax,%ecx
  800fe5:	eb 02                	jmp    800fe9 <strtol+0xb2>
  800fe7:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800fe9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fed:	74 05                	je     800ff4 <strtol+0xbd>
		*endptr = (char *) s;
  800fef:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ff2:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800ff4:	85 ff                	test   %edi,%edi
  800ff6:	74 04                	je     800ffc <strtol+0xc5>
  800ff8:	89 c8                	mov    %ecx,%eax
  800ffa:	f7 d8                	neg    %eax
}
  800ffc:	5b                   	pop    %ebx
  800ffd:	5e                   	pop    %esi
  800ffe:	5f                   	pop    %edi
  800fff:	5d                   	pop    %ebp
  801000:	c3                   	ret    
  801001:	66 90                	xchg   %ax,%ax
  801003:	90                   	nop

00801004 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	57                   	push   %edi
  801008:	56                   	push   %esi
  801009:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100a:	b8 00 00 00 00       	mov    $0x0,%eax
  80100f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801012:	8b 55 08             	mov    0x8(%ebp),%edx
  801015:	89 c3                	mov    %eax,%ebx
  801017:	89 c7                	mov    %eax,%edi
  801019:	89 c6                	mov    %eax,%esi
  80101b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80101d:	5b                   	pop    %ebx
  80101e:	5e                   	pop    %esi
  80101f:	5f                   	pop    %edi
  801020:	5d                   	pop    %ebp
  801021:	c3                   	ret    

00801022 <sys_cgetc>:

int
sys_cgetc(void)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	57                   	push   %edi
  801026:	56                   	push   %esi
  801027:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801028:	ba 00 00 00 00       	mov    $0x0,%edx
  80102d:	b8 01 00 00 00       	mov    $0x1,%eax
  801032:	89 d1                	mov    %edx,%ecx
  801034:	89 d3                	mov    %edx,%ebx
  801036:	89 d7                	mov    %edx,%edi
  801038:	89 d6                	mov    %edx,%esi
  80103a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80103c:	5b                   	pop    %ebx
  80103d:	5e                   	pop    %esi
  80103e:	5f                   	pop    %edi
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    

00801041 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	57                   	push   %edi
  801045:	56                   	push   %esi
  801046:	53                   	push   %ebx
  801047:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80104a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80104f:	b8 03 00 00 00       	mov    $0x3,%eax
  801054:	8b 55 08             	mov    0x8(%ebp),%edx
  801057:	89 cb                	mov    %ecx,%ebx
  801059:	89 cf                	mov    %ecx,%edi
  80105b:	89 ce                	mov    %ecx,%esi
  80105d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80105f:	85 c0                	test   %eax,%eax
  801061:	7e 28                	jle    80108b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801063:	89 44 24 10          	mov    %eax,0x10(%esp)
  801067:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80106e:	00 
  80106f:	c7 44 24 08 a8 19 80 	movl   $0x8019a8,0x8(%esp)
  801076:	00 
  801077:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80107e:	00 
  80107f:	c7 04 24 c5 19 80 00 	movl   $0x8019c5,(%esp)
  801086:	e8 5d f5 ff ff       	call   8005e8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80108b:	83 c4 2c             	add    $0x2c,%esp
  80108e:	5b                   	pop    %ebx
  80108f:	5e                   	pop    %esi
  801090:	5f                   	pop    %edi
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    

00801093 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	57                   	push   %edi
  801097:	56                   	push   %esi
  801098:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801099:	ba 00 00 00 00       	mov    $0x0,%edx
  80109e:	b8 02 00 00 00       	mov    $0x2,%eax
  8010a3:	89 d1                	mov    %edx,%ecx
  8010a5:	89 d3                	mov    %edx,%ebx
  8010a7:	89 d7                	mov    %edx,%edi
  8010a9:	89 d6                	mov    %edx,%esi
  8010ab:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010ad:	5b                   	pop    %ebx
  8010ae:	5e                   	pop    %esi
  8010af:	5f                   	pop    %edi
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    

008010b2 <sys_yield>:

void
sys_yield(void)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	57                   	push   %edi
  8010b6:	56                   	push   %esi
  8010b7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8010bd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010c2:	89 d1                	mov    %edx,%ecx
  8010c4:	89 d3                	mov    %edx,%ebx
  8010c6:	89 d7                	mov    %edx,%edi
  8010c8:	89 d6                	mov    %edx,%esi
  8010ca:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010cc:	5b                   	pop    %ebx
  8010cd:	5e                   	pop    %esi
  8010ce:	5f                   	pop    %edi
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	57                   	push   %edi
  8010d5:	56                   	push   %esi
  8010d6:	53                   	push   %ebx
  8010d7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010da:	be 00 00 00 00       	mov    $0x0,%esi
  8010df:	b8 04 00 00 00       	mov    $0x4,%eax
  8010e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ed:	89 f7                	mov    %esi,%edi
  8010ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	7e 28                	jle    80111d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010f9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801100:	00 
  801101:	c7 44 24 08 a8 19 80 	movl   $0x8019a8,0x8(%esp)
  801108:	00 
  801109:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801110:	00 
  801111:	c7 04 24 c5 19 80 00 	movl   $0x8019c5,(%esp)
  801118:	e8 cb f4 ff ff       	call   8005e8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80111d:	83 c4 2c             	add    $0x2c,%esp
  801120:	5b                   	pop    %ebx
  801121:	5e                   	pop    %esi
  801122:	5f                   	pop    %edi
  801123:	5d                   	pop    %ebp
  801124:	c3                   	ret    

00801125 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	57                   	push   %edi
  801129:	56                   	push   %esi
  80112a:	53                   	push   %ebx
  80112b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80112e:	b8 05 00 00 00       	mov    $0x5,%eax
  801133:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801136:	8b 55 08             	mov    0x8(%ebp),%edx
  801139:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80113c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80113f:	8b 75 18             	mov    0x18(%ebp),%esi
  801142:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801144:	85 c0                	test   %eax,%eax
  801146:	7e 28                	jle    801170 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801148:	89 44 24 10          	mov    %eax,0x10(%esp)
  80114c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801153:	00 
  801154:	c7 44 24 08 a8 19 80 	movl   $0x8019a8,0x8(%esp)
  80115b:	00 
  80115c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801163:	00 
  801164:	c7 04 24 c5 19 80 00 	movl   $0x8019c5,(%esp)
  80116b:	e8 78 f4 ff ff       	call   8005e8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801170:	83 c4 2c             	add    $0x2c,%esp
  801173:	5b                   	pop    %ebx
  801174:	5e                   	pop    %esi
  801175:	5f                   	pop    %edi
  801176:	5d                   	pop    %ebp
  801177:	c3                   	ret    

00801178 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	57                   	push   %edi
  80117c:	56                   	push   %esi
  80117d:	53                   	push   %ebx
  80117e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801181:	bb 00 00 00 00       	mov    $0x0,%ebx
  801186:	b8 06 00 00 00       	mov    $0x6,%eax
  80118b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80118e:	8b 55 08             	mov    0x8(%ebp),%edx
  801191:	89 df                	mov    %ebx,%edi
  801193:	89 de                	mov    %ebx,%esi
  801195:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801197:	85 c0                	test   %eax,%eax
  801199:	7e 28                	jle    8011c3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80119b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80119f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8011a6:	00 
  8011a7:	c7 44 24 08 a8 19 80 	movl   $0x8019a8,0x8(%esp)
  8011ae:	00 
  8011af:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011b6:	00 
  8011b7:	c7 04 24 c5 19 80 00 	movl   $0x8019c5,(%esp)
  8011be:	e8 25 f4 ff ff       	call   8005e8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011c3:	83 c4 2c             	add    $0x2c,%esp
  8011c6:	5b                   	pop    %ebx
  8011c7:	5e                   	pop    %esi
  8011c8:	5f                   	pop    %edi
  8011c9:	5d                   	pop    %ebp
  8011ca:	c3                   	ret    

008011cb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	57                   	push   %edi
  8011cf:	56                   	push   %esi
  8011d0:	53                   	push   %ebx
  8011d1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d9:	b8 08 00 00 00       	mov    $0x8,%eax
  8011de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e4:	89 df                	mov    %ebx,%edi
  8011e6:	89 de                	mov    %ebx,%esi
  8011e8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	7e 28                	jle    801216 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ee:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011f2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8011f9:	00 
  8011fa:	c7 44 24 08 a8 19 80 	movl   $0x8019a8,0x8(%esp)
  801201:	00 
  801202:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801209:	00 
  80120a:	c7 04 24 c5 19 80 00 	movl   $0x8019c5,(%esp)
  801211:	e8 d2 f3 ff ff       	call   8005e8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801216:	83 c4 2c             	add    $0x2c,%esp
  801219:	5b                   	pop    %ebx
  80121a:	5e                   	pop    %esi
  80121b:	5f                   	pop    %edi
  80121c:	5d                   	pop    %ebp
  80121d:	c3                   	ret    

0080121e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	57                   	push   %edi
  801222:	56                   	push   %esi
  801223:	53                   	push   %ebx
  801224:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801227:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122c:	b8 09 00 00 00       	mov    $0x9,%eax
  801231:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801234:	8b 55 08             	mov    0x8(%ebp),%edx
  801237:	89 df                	mov    %ebx,%edi
  801239:	89 de                	mov    %ebx,%esi
  80123b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80123d:	85 c0                	test   %eax,%eax
  80123f:	7e 28                	jle    801269 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801241:	89 44 24 10          	mov    %eax,0x10(%esp)
  801245:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80124c:	00 
  80124d:	c7 44 24 08 a8 19 80 	movl   $0x8019a8,0x8(%esp)
  801254:	00 
  801255:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80125c:	00 
  80125d:	c7 04 24 c5 19 80 00 	movl   $0x8019c5,(%esp)
  801264:	e8 7f f3 ff ff       	call   8005e8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801269:	83 c4 2c             	add    $0x2c,%esp
  80126c:	5b                   	pop    %ebx
  80126d:	5e                   	pop    %esi
  80126e:	5f                   	pop    %edi
  80126f:	5d                   	pop    %ebp
  801270:	c3                   	ret    

00801271 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	57                   	push   %edi
  801275:	56                   	push   %esi
  801276:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801277:	be 00 00 00 00       	mov    $0x0,%esi
  80127c:	b8 0b 00 00 00       	mov    $0xb,%eax
  801281:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801284:	8b 55 08             	mov    0x8(%ebp),%edx
  801287:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80128a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80128d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80128f:	5b                   	pop    %ebx
  801290:	5e                   	pop    %esi
  801291:	5f                   	pop    %edi
  801292:	5d                   	pop    %ebp
  801293:	c3                   	ret    

00801294 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	57                   	push   %edi
  801298:	56                   	push   %esi
  801299:	53                   	push   %ebx
  80129a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80129d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012a2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8012aa:	89 cb                	mov    %ecx,%ebx
  8012ac:	89 cf                	mov    %ecx,%edi
  8012ae:	89 ce                	mov    %ecx,%esi
  8012b0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	7e 28                	jle    8012de <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012ba:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8012c1:	00 
  8012c2:	c7 44 24 08 a8 19 80 	movl   $0x8019a8,0x8(%esp)
  8012c9:	00 
  8012ca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012d1:	00 
  8012d2:	c7 04 24 c5 19 80 00 	movl   $0x8019c5,(%esp)
  8012d9:	e8 0a f3 ff ff       	call   8005e8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012de:	83 c4 2c             	add    $0x2c,%esp
  8012e1:	5b                   	pop    %ebx
  8012e2:	5e                   	pop    %esi
  8012e3:	5f                   	pop    %edi
  8012e4:	5d                   	pop    %ebp
  8012e5:	c3                   	ret    
  8012e6:	66 90                	xchg   %ax,%ax

008012e8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012e8:	55                   	push   %ebp
  8012e9:	89 e5                	mov    %esp,%ebp
  8012eb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012ee:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  8012f5:	75 32                	jne    801329 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
    //region_alloc(curenv, (void *)UXSTACKTOP - PGSIZE, PGSIZE);
		//panic("set_pgfault_handler not implemented");
		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  8012f7:	e8 97 fd ff ff       	call   801093 <sys_getenvid>
  8012fc:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801303:	00 
  801304:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80130b:	ee 
  80130c:	89 04 24             	mov    %eax,(%esp)
  80130f:	e8 bd fd ff ff       	call   8010d1 <sys_page_alloc>
    sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801314:	e8 7a fd ff ff       	call   801093 <sys_getenvid>
  801319:	c7 44 24 04 34 13 80 	movl   $0x801334,0x4(%esp)
  801320:	00 
  801321:	89 04 24             	mov    %eax,(%esp)
  801324:	e8 f5 fe ff ff       	call   80121e <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801329:	8b 45 08             	mov    0x8(%ebp),%eax
  80132c:	a3 d0 20 80 00       	mov    %eax,0x8020d0

}
  801331:	c9                   	leave  
  801332:	c3                   	ret    
  801333:	90                   	nop

00801334 <_pgfault_upcall>:
  801334:	54                   	push   %esp
  801335:	a1 d0 20 80 00       	mov    0x8020d0,%eax
  80133a:	ff d0                	call   *%eax
  80133c:	83 c4 04             	add    $0x4,%esp
  80133f:	8b 44 24 28          	mov    0x28(%esp),%eax
  801343:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801347:	89 43 fc             	mov    %eax,-0x4(%ebx)
  80134a:	83 eb 04             	sub    $0x4,%ebx
  80134d:	89 5c 24 30          	mov    %ebx,0x30(%esp)
  801351:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801355:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801359:	8b 6c 24 10          	mov    0x10(%esp),%ebp
  80135d:	8b 5c 24 18          	mov    0x18(%esp),%ebx
  801361:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  801365:	8b 4c 24 20          	mov    0x20(%esp),%ecx
  801369:	8b 44 24 24          	mov    0x24(%esp),%eax
  80136d:	ff 74 24 2c          	pushl  0x2c(%esp)
  801371:	9d                   	popf   
  801372:	8b 64 24 30          	mov    0x30(%esp),%esp
  801376:	c3                   	ret    
  801377:	66 90                	xchg   %ax,%ax
  801379:	66 90                	xchg   %ax,%ax
  80137b:	66 90                	xchg   %ax,%ax
  80137d:	66 90                	xchg   %ax,%ax
  80137f:	90                   	nop

00801380 <__udivdi3>:
  801380:	55                   	push   %ebp
  801381:	57                   	push   %edi
  801382:	56                   	push   %esi
  801383:	83 ec 0c             	sub    $0xc,%esp
  801386:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80138a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  80138e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801392:	8b 44 24 28          	mov    0x28(%esp),%eax
  801396:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80139a:	89 ea                	mov    %ebp,%edx
  80139c:	89 0c 24             	mov    %ecx,(%esp)
  80139f:	85 c0                	test   %eax,%eax
  8013a1:	75 2d                	jne    8013d0 <__udivdi3+0x50>
  8013a3:	39 e9                	cmp    %ebp,%ecx
  8013a5:	77 61                	ja     801408 <__udivdi3+0x88>
  8013a7:	89 ce                	mov    %ecx,%esi
  8013a9:	85 c9                	test   %ecx,%ecx
  8013ab:	75 0b                	jne    8013b8 <__udivdi3+0x38>
  8013ad:	b8 01 00 00 00       	mov    $0x1,%eax
  8013b2:	31 d2                	xor    %edx,%edx
  8013b4:	f7 f1                	div    %ecx
  8013b6:	89 c6                	mov    %eax,%esi
  8013b8:	31 d2                	xor    %edx,%edx
  8013ba:	89 e8                	mov    %ebp,%eax
  8013bc:	f7 f6                	div    %esi
  8013be:	89 c5                	mov    %eax,%ebp
  8013c0:	89 f8                	mov    %edi,%eax
  8013c2:	f7 f6                	div    %esi
  8013c4:	89 ea                	mov    %ebp,%edx
  8013c6:	83 c4 0c             	add    $0xc,%esp
  8013c9:	5e                   	pop    %esi
  8013ca:	5f                   	pop    %edi
  8013cb:	5d                   	pop    %ebp
  8013cc:	c3                   	ret    
  8013cd:	8d 76 00             	lea    0x0(%esi),%esi
  8013d0:	39 e8                	cmp    %ebp,%eax
  8013d2:	77 24                	ja     8013f8 <__udivdi3+0x78>
  8013d4:	0f bd e8             	bsr    %eax,%ebp
  8013d7:	83 f5 1f             	xor    $0x1f,%ebp
  8013da:	75 3c                	jne    801418 <__udivdi3+0x98>
  8013dc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8013e0:	39 34 24             	cmp    %esi,(%esp)
  8013e3:	0f 86 9f 00 00 00    	jbe    801488 <__udivdi3+0x108>
  8013e9:	39 d0                	cmp    %edx,%eax
  8013eb:	0f 82 97 00 00 00    	jb     801488 <__udivdi3+0x108>
  8013f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013f8:	31 d2                	xor    %edx,%edx
  8013fa:	31 c0                	xor    %eax,%eax
  8013fc:	83 c4 0c             	add    $0xc,%esp
  8013ff:	5e                   	pop    %esi
  801400:	5f                   	pop    %edi
  801401:	5d                   	pop    %ebp
  801402:	c3                   	ret    
  801403:	90                   	nop
  801404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801408:	89 f8                	mov    %edi,%eax
  80140a:	f7 f1                	div    %ecx
  80140c:	31 d2                	xor    %edx,%edx
  80140e:	83 c4 0c             	add    $0xc,%esp
  801411:	5e                   	pop    %esi
  801412:	5f                   	pop    %edi
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    
  801415:	8d 76 00             	lea    0x0(%esi),%esi
  801418:	89 e9                	mov    %ebp,%ecx
  80141a:	8b 3c 24             	mov    (%esp),%edi
  80141d:	d3 e0                	shl    %cl,%eax
  80141f:	89 c6                	mov    %eax,%esi
  801421:	b8 20 00 00 00       	mov    $0x20,%eax
  801426:	29 e8                	sub    %ebp,%eax
  801428:	88 c1                	mov    %al,%cl
  80142a:	d3 ef                	shr    %cl,%edi
  80142c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801430:	89 e9                	mov    %ebp,%ecx
  801432:	8b 3c 24             	mov    (%esp),%edi
  801435:	09 74 24 08          	or     %esi,0x8(%esp)
  801439:	d3 e7                	shl    %cl,%edi
  80143b:	89 d6                	mov    %edx,%esi
  80143d:	88 c1                	mov    %al,%cl
  80143f:	d3 ee                	shr    %cl,%esi
  801441:	89 e9                	mov    %ebp,%ecx
  801443:	89 3c 24             	mov    %edi,(%esp)
  801446:	d3 e2                	shl    %cl,%edx
  801448:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80144c:	88 c1                	mov    %al,%cl
  80144e:	d3 ef                	shr    %cl,%edi
  801450:	09 d7                	or     %edx,%edi
  801452:	89 f2                	mov    %esi,%edx
  801454:	89 f8                	mov    %edi,%eax
  801456:	f7 74 24 08          	divl   0x8(%esp)
  80145a:	89 d6                	mov    %edx,%esi
  80145c:	89 c7                	mov    %eax,%edi
  80145e:	f7 24 24             	mull   (%esp)
  801461:	89 14 24             	mov    %edx,(%esp)
  801464:	39 d6                	cmp    %edx,%esi
  801466:	72 30                	jb     801498 <__udivdi3+0x118>
  801468:	8b 54 24 04          	mov    0x4(%esp),%edx
  80146c:	89 e9                	mov    %ebp,%ecx
  80146e:	d3 e2                	shl    %cl,%edx
  801470:	39 c2                	cmp    %eax,%edx
  801472:	73 05                	jae    801479 <__udivdi3+0xf9>
  801474:	3b 34 24             	cmp    (%esp),%esi
  801477:	74 1f                	je     801498 <__udivdi3+0x118>
  801479:	89 f8                	mov    %edi,%eax
  80147b:	31 d2                	xor    %edx,%edx
  80147d:	e9 7a ff ff ff       	jmp    8013fc <__udivdi3+0x7c>
  801482:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801488:	31 d2                	xor    %edx,%edx
  80148a:	b8 01 00 00 00       	mov    $0x1,%eax
  80148f:	e9 68 ff ff ff       	jmp    8013fc <__udivdi3+0x7c>
  801494:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801498:	8d 47 ff             	lea    -0x1(%edi),%eax
  80149b:	31 d2                	xor    %edx,%edx
  80149d:	83 c4 0c             	add    $0xc,%esp
  8014a0:	5e                   	pop    %esi
  8014a1:	5f                   	pop    %edi
  8014a2:	5d                   	pop    %ebp
  8014a3:	c3                   	ret    
  8014a4:	66 90                	xchg   %ax,%ax
  8014a6:	66 90                	xchg   %ax,%ax
  8014a8:	66 90                	xchg   %ax,%ax
  8014aa:	66 90                	xchg   %ax,%ax
  8014ac:	66 90                	xchg   %ax,%ax
  8014ae:	66 90                	xchg   %ax,%ax

008014b0 <__umoddi3>:
  8014b0:	55                   	push   %ebp
  8014b1:	57                   	push   %edi
  8014b2:	56                   	push   %esi
  8014b3:	83 ec 14             	sub    $0x14,%esp
  8014b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8014ba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8014be:	89 c7                	mov    %eax,%edi
  8014c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8014c8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8014cc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8014d0:	89 34 24             	mov    %esi,(%esp)
  8014d3:	89 c2                	mov    %eax,%edx
  8014d5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014d9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014dd:	85 c0                	test   %eax,%eax
  8014df:	75 17                	jne    8014f8 <__umoddi3+0x48>
  8014e1:	39 fe                	cmp    %edi,%esi
  8014e3:	76 4b                	jbe    801530 <__umoddi3+0x80>
  8014e5:	89 c8                	mov    %ecx,%eax
  8014e7:	89 fa                	mov    %edi,%edx
  8014e9:	f7 f6                	div    %esi
  8014eb:	89 d0                	mov    %edx,%eax
  8014ed:	31 d2                	xor    %edx,%edx
  8014ef:	83 c4 14             	add    $0x14,%esp
  8014f2:	5e                   	pop    %esi
  8014f3:	5f                   	pop    %edi
  8014f4:	5d                   	pop    %ebp
  8014f5:	c3                   	ret    
  8014f6:	66 90                	xchg   %ax,%ax
  8014f8:	39 f8                	cmp    %edi,%eax
  8014fa:	77 54                	ja     801550 <__umoddi3+0xa0>
  8014fc:	0f bd e8             	bsr    %eax,%ebp
  8014ff:	83 f5 1f             	xor    $0x1f,%ebp
  801502:	75 5c                	jne    801560 <__umoddi3+0xb0>
  801504:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801508:	39 3c 24             	cmp    %edi,(%esp)
  80150b:	0f 87 f7 00 00 00    	ja     801608 <__umoddi3+0x158>
  801511:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801515:	29 f1                	sub    %esi,%ecx
  801517:	19 c7                	sbb    %eax,%edi
  801519:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80151d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801521:	8b 44 24 08          	mov    0x8(%esp),%eax
  801525:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801529:	83 c4 14             	add    $0x14,%esp
  80152c:	5e                   	pop    %esi
  80152d:	5f                   	pop    %edi
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    
  801530:	89 f5                	mov    %esi,%ebp
  801532:	85 f6                	test   %esi,%esi
  801534:	75 0b                	jne    801541 <__umoddi3+0x91>
  801536:	b8 01 00 00 00       	mov    $0x1,%eax
  80153b:	31 d2                	xor    %edx,%edx
  80153d:	f7 f6                	div    %esi
  80153f:	89 c5                	mov    %eax,%ebp
  801541:	8b 44 24 04          	mov    0x4(%esp),%eax
  801545:	31 d2                	xor    %edx,%edx
  801547:	f7 f5                	div    %ebp
  801549:	89 c8                	mov    %ecx,%eax
  80154b:	f7 f5                	div    %ebp
  80154d:	eb 9c                	jmp    8014eb <__umoddi3+0x3b>
  80154f:	90                   	nop
  801550:	89 c8                	mov    %ecx,%eax
  801552:	89 fa                	mov    %edi,%edx
  801554:	83 c4 14             	add    $0x14,%esp
  801557:	5e                   	pop    %esi
  801558:	5f                   	pop    %edi
  801559:	5d                   	pop    %ebp
  80155a:	c3                   	ret    
  80155b:	90                   	nop
  80155c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801560:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801567:	00 
  801568:	8b 34 24             	mov    (%esp),%esi
  80156b:	8b 44 24 04          	mov    0x4(%esp),%eax
  80156f:	89 e9                	mov    %ebp,%ecx
  801571:	29 e8                	sub    %ebp,%eax
  801573:	89 44 24 04          	mov    %eax,0x4(%esp)
  801577:	89 f0                	mov    %esi,%eax
  801579:	d3 e2                	shl    %cl,%edx
  80157b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  80157f:	d3 e8                	shr    %cl,%eax
  801581:	89 04 24             	mov    %eax,(%esp)
  801584:	89 e9                	mov    %ebp,%ecx
  801586:	89 f0                	mov    %esi,%eax
  801588:	09 14 24             	or     %edx,(%esp)
  80158b:	d3 e0                	shl    %cl,%eax
  80158d:	89 fa                	mov    %edi,%edx
  80158f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801593:	d3 ea                	shr    %cl,%edx
  801595:	89 e9                	mov    %ebp,%ecx
  801597:	89 c6                	mov    %eax,%esi
  801599:	d3 e7                	shl    %cl,%edi
  80159b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80159f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8015a3:	8b 44 24 10          	mov    0x10(%esp),%eax
  8015a7:	d3 e8                	shr    %cl,%eax
  8015a9:	09 f8                	or     %edi,%eax
  8015ab:	89 e9                	mov    %ebp,%ecx
  8015ad:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8015b1:	d3 e7                	shl    %cl,%edi
  8015b3:	f7 34 24             	divl   (%esp)
  8015b6:	89 d1                	mov    %edx,%ecx
  8015b8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8015bc:	f7 e6                	mul    %esi
  8015be:	89 c7                	mov    %eax,%edi
  8015c0:	89 d6                	mov    %edx,%esi
  8015c2:	39 d1                	cmp    %edx,%ecx
  8015c4:	72 2e                	jb     8015f4 <__umoddi3+0x144>
  8015c6:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8015ca:	72 24                	jb     8015f0 <__umoddi3+0x140>
  8015cc:	89 ca                	mov    %ecx,%edx
  8015ce:	89 e9                	mov    %ebp,%ecx
  8015d0:	8b 44 24 08          	mov    0x8(%esp),%eax
  8015d4:	29 f8                	sub    %edi,%eax
  8015d6:	19 f2                	sbb    %esi,%edx
  8015d8:	d3 e8                	shr    %cl,%eax
  8015da:	89 d6                	mov    %edx,%esi
  8015dc:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8015e0:	d3 e6                	shl    %cl,%esi
  8015e2:	89 e9                	mov    %ebp,%ecx
  8015e4:	09 f0                	or     %esi,%eax
  8015e6:	d3 ea                	shr    %cl,%edx
  8015e8:	83 c4 14             	add    $0x14,%esp
  8015eb:	5e                   	pop    %esi
  8015ec:	5f                   	pop    %edi
  8015ed:	5d                   	pop    %ebp
  8015ee:	c3                   	ret    
  8015ef:	90                   	nop
  8015f0:	39 d1                	cmp    %edx,%ecx
  8015f2:	75 d8                	jne    8015cc <__umoddi3+0x11c>
  8015f4:	89 d6                	mov    %edx,%esi
  8015f6:	89 c7                	mov    %eax,%edi
  8015f8:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  8015fc:	1b 34 24             	sbb    (%esp),%esi
  8015ff:	eb cb                	jmp    8015cc <__umoddi3+0x11c>
  801601:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801608:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80160c:	0f 82 ff fe ff ff    	jb     801511 <__umoddi3+0x61>
  801612:	e9 0a ff ff ff       	jmp    801521 <__umoddi3+0x71>
