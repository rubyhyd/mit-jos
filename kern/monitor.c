// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/pmap.h>


#define CMDBUF_SIZE	80	// enough for one VGA text line
#define ONEorZERO(a) ((a) == 0? 0 : 1)

struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "Display stack backtrace information", mon_backtrace },
	{ "sm", "show mapping virtual address to physical address", mon_sm },
	{	"q", "quit", mon_quit }, 
	{ "setpg", "set page mark bits", mon_setpg},
	{ "dump", "dump the comtent of memory given va or pa", mon_dump},
};
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	cprintf("Stack backtrace:\n");
	uint32_t* ebp = (uint32_t*)read_ebp();
	uint32_t args[6];
	while (1) {
    //print ebp eip args
    int i = 0;	
    for (; i < 6; i++)
    	args[i] = *(ebp + 1 + i); //eip is args[0]
		cprintf(" ebp %x eip %x args %08x %08x %08x %08x %08x\n", 
			ebp, args[0], args[1], args[2], args[3], args[4], args[5]);
		//print file line function
		struct Eipdebuginfo info;
		if (debuginfo_eip(args[0], &info) == 0) {
			cprintf("\t%s:%d: %.*s+%d\n", 
			info.eip_file, info.eip_line, info.eip_fn_namelen, 
			info.eip_fn_name, args[0] - info.eip_fn_addr);
		} else {
			cprintf("Informtion is not complete.");
		}

		if (*ebp == 0x0)
			break;

		ebp = (uint32_t*)(*ebp);	
	}
	return 0;
}

int 
mon_sm(int argc, char **argv, struct Trapframe *tf) {
	extern pde_t* kern_pgdir;
	physaddr_t pa;
	pte_t *pte;

	if (argc != 3) {
		cprintf("The number of arguments is %d, must be 2\n", argc - 1);
		return 0;
	}

	uint32_t va1, va2, npg;
	va1 = strtol(argv[1], 0, 16);
	va2 = strtol(argv[2], 0, 16);

	if (va2 < va1) {
		cprintf("va2 cannot be less than va1\n");
		return 0;
	}

	for(; va1 <= va2; va1 += 0x1000) {
		pte = pgdir_walk(kern_pgdir, (const void *)va1, 0);

		if (!pte) {
			cprintf("va is 0x%x, pa is NOT found\n", va1);
			continue;
		}

		if (*pte & PTE_PS)
			pa = PTE4M(*pte) + (va1 & 0x3fffff);
		else
			pa = PTE_ADDR(*pte) + PGOFF(va1);	

		cprintf("va is 0x%08x, pa is 0x%08x.\n  PS %d U/S %d R/W %d P %d\n"
			,va1, pa, ONEorZERO(*pte & PTE_PS), ONEorZERO(*pte & PTE_U)
			, ONEorZERO(*pte & PTE_W), ONEorZERO(*pte & PTE_P));
	}
	return 0;
}

int mon_setpg(int argc, char** argv, struct Trapframe* tf) {
	if (argc % 2 != 0) {
		cprintf("The number of arguments is wrong.\n\
The format is like followings:\n\
  setpg va bit1 value1 bit2 value2 ...\n\
  bit is in {\"P\", \"U\", \"W\"}, value is 0 or 1\n", argc);
		return 0;
	}

	uint32_t va = strtol(argv[1], 0, 16);
	pte_t *pte = pgdir_walk(kern_pgdir, (const void *)va, 0);

	if (!pte) {
			cprintf("va is 0x%x, pa is NOT found\n", va);
			return 0;
		}

	int i = 2;
	for(;i + 1 < argc; i += 2) {

		switch((uint8_t)argv[i][0]) {
			case 'p':
			case 'P': {
				cprintf("P was %d, ", ONEorZERO(*pte & PTE_P));
				*pte &= ~PTE_P;
				if (strtol(argv[i + 1], 0, 10))
					*pte |= PTE_P;
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_P));
				break;
			};
			case 'u':
			case 'U': {
				cprintf("U was %d, ", ONEorZERO(*pte & PTE_U));
				*pte &= ~PTE_U;
				if (strtol(argv[i + 1], 0, 10))
					*pte |= PTE_U ;
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_U));
				break;
			};
			case 'w':
			case 'W': {
				cprintf("W was %d, ", ONEorZERO(*pte & PTE_W));
				*pte &= ~PTE_W;
				if (strtol(argv[i + 1], 0, 10))
					*pte |= PTE_W;
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_W));
				break;
			};
			default: break;
		}
	}
	return 0;
}

int
mon_dump(int argc, char** argv, struct Trapframe* tf){
	return 0;
}

int 
mon_quit(int argc, char** argv, struct Trapframe* tf) {
	return -1;
}

/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
