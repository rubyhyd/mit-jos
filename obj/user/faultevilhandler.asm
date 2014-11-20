
obj/user/faultevilhandler:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
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
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800041:	00 
  800042:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800049:	ee 
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 e3 04 00 00       	call   800539 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800056:	c7 44 24 04 20 00 10 	movl   $0xf0100020,0x4(%esp)
  80005d:	f0 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 1c 06 00 00       	call   800686 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80006a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800071:	00 00 00 
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
  800076:	66 90                	xchg   %ax,%ax

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	56                   	push   %esi
  80007c:	53                   	push   %ebx
  80007d:	83 ec 10             	sub    $0x10,%esp
  800080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800083:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  800086:	b8 08 20 80 00       	mov    $0x802008,%eax
  80008b:	2d 04 20 80 00       	sub    $0x802004,%eax
  800090:	89 44 24 08          	mov    %eax,0x8(%esp)
  800094:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009b:	00 
  80009c:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  8000a3:	e8 cf 01 00 00       	call   800277 <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  8000a8:	e8 4e 04 00 00       	call   8004fb <sys_getenvid>
  8000ad:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000b9:	c1 e0 07             	shl    $0x7,%eax
  8000bc:	29 d0                	sub    %edx,%eax
  8000be:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c3:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c8:	85 db                	test   %ebx,%ebx
  8000ca:	7e 07                	jle    8000d3 <libmain+0x5b>
		binaryname = argv[0];
  8000cc:	8b 06                	mov    (%esi),%eax
  8000ce:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000d7:	89 1c 24             	mov    %ebx,(%esp)
  8000da:	e8 55 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000df:	e8 08 00 00 00       	call   8000ec <exit>
}
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    
  8000eb:	90                   	nop

008000ec <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f9:	e8 ab 03 00 00       	call   8004a9 <sys_env_destroy>
}
  8000fe:	c9                   	leave  
  8000ff:	c3                   	ret    

00800100 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800106:	b8 00 00 00 00       	mov    $0x0,%eax
  80010b:	eb 01                	jmp    80010e <strlen+0xe>
		n++;
  80010d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80010e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800112:	75 f9                	jne    80010d <strlen+0xd>
		n++;
	return n;
}
  800114:	5d                   	pop    %ebp
  800115:	c3                   	ret    

00800116 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80011c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80011f:	b8 00 00 00 00       	mov    $0x0,%eax
  800124:	eb 01                	jmp    800127 <strnlen+0x11>
		n++;
  800126:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800127:	39 d0                	cmp    %edx,%eax
  800129:	74 06                	je     800131 <strnlen+0x1b>
  80012b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80012f:	75 f5                	jne    800126 <strnlen+0x10>
		n++;
	return n;
}
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	53                   	push   %ebx
  800137:	8b 45 08             	mov    0x8(%ebp),%eax
  80013a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80013d:	89 c2                	mov    %eax,%edx
  80013f:	42                   	inc    %edx
  800140:	41                   	inc    %ecx
  800141:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800144:	88 5a ff             	mov    %bl,-0x1(%edx)
  800147:	84 db                	test   %bl,%bl
  800149:	75 f4                	jne    80013f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80014b:	5b                   	pop    %ebx
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    

0080014e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	53                   	push   %ebx
  800152:	83 ec 08             	sub    $0x8,%esp
  800155:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800158:	89 1c 24             	mov    %ebx,(%esp)
  80015b:	e8 a0 ff ff ff       	call   800100 <strlen>
	strcpy(dst + len, src);
  800160:	8b 55 0c             	mov    0xc(%ebp),%edx
  800163:	89 54 24 04          	mov    %edx,0x4(%esp)
  800167:	01 d8                	add    %ebx,%eax
  800169:	89 04 24             	mov    %eax,(%esp)
  80016c:	e8 c2 ff ff ff       	call   800133 <strcpy>
	return dst;
}
  800171:	89 d8                	mov    %ebx,%eax
  800173:	83 c4 08             	add    $0x8,%esp
  800176:	5b                   	pop    %ebx
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	56                   	push   %esi
  80017d:	53                   	push   %ebx
  80017e:	8b 75 08             	mov    0x8(%ebp),%esi
  800181:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800184:	89 f3                	mov    %esi,%ebx
  800186:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800189:	89 f2                	mov    %esi,%edx
  80018b:	eb 0c                	jmp    800199 <strncpy+0x20>
		*dst++ = *src;
  80018d:	42                   	inc    %edx
  80018e:	8a 01                	mov    (%ecx),%al
  800190:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800193:	80 39 01             	cmpb   $0x1,(%ecx)
  800196:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800199:	39 da                	cmp    %ebx,%edx
  80019b:	75 f0                	jne    80018d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80019d:	89 f0                	mov    %esi,%eax
  80019f:	5b                   	pop    %ebx
  8001a0:	5e                   	pop    %esi
  8001a1:	5d                   	pop    %ebp
  8001a2:	c3                   	ret    

008001a3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	56                   	push   %esi
  8001a7:	53                   	push   %ebx
  8001a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8001ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001b1:	89 f0                	mov    %esi,%eax
  8001b3:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8001b7:	85 c9                	test   %ecx,%ecx
  8001b9:	75 07                	jne    8001c2 <strlcpy+0x1f>
  8001bb:	eb 18                	jmp    8001d5 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8001bd:	40                   	inc    %eax
  8001be:	42                   	inc    %edx
  8001bf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8001c2:	39 d8                	cmp    %ebx,%eax
  8001c4:	74 0a                	je     8001d0 <strlcpy+0x2d>
  8001c6:	8a 0a                	mov    (%edx),%cl
  8001c8:	84 c9                	test   %cl,%cl
  8001ca:	75 f1                	jne    8001bd <strlcpy+0x1a>
  8001cc:	89 c2                	mov    %eax,%edx
  8001ce:	eb 02                	jmp    8001d2 <strlcpy+0x2f>
  8001d0:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8001d2:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8001d5:	29 f0                	sub    %esi,%eax
}
  8001d7:	5b                   	pop    %ebx
  8001d8:	5e                   	pop    %esi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8001e4:	eb 02                	jmp    8001e8 <strcmp+0xd>
		p++, q++;
  8001e6:	41                   	inc    %ecx
  8001e7:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8001e8:	8a 01                	mov    (%ecx),%al
  8001ea:	84 c0                	test   %al,%al
  8001ec:	74 04                	je     8001f2 <strcmp+0x17>
  8001ee:	3a 02                	cmp    (%edx),%al
  8001f0:	74 f4                	je     8001e6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8001f2:	25 ff 00 00 00       	and    $0xff,%eax
  8001f7:	8a 0a                	mov    (%edx),%cl
  8001f9:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8001ff:	29 c8                	sub    %ecx,%eax
}
  800201:	5d                   	pop    %ebp
  800202:	c3                   	ret    

00800203 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	53                   	push   %ebx
  800207:	8b 45 08             	mov    0x8(%ebp),%eax
  80020a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80020d:	89 c3                	mov    %eax,%ebx
  80020f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800212:	eb 02                	jmp    800216 <strncmp+0x13>
		n--, p++, q++;
  800214:	40                   	inc    %eax
  800215:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800216:	39 d8                	cmp    %ebx,%eax
  800218:	74 20                	je     80023a <strncmp+0x37>
  80021a:	8a 08                	mov    (%eax),%cl
  80021c:	84 c9                	test   %cl,%cl
  80021e:	74 04                	je     800224 <strncmp+0x21>
  800220:	3a 0a                	cmp    (%edx),%cl
  800222:	74 f0                	je     800214 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800224:	8a 18                	mov    (%eax),%bl
  800226:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80022c:	89 d8                	mov    %ebx,%eax
  80022e:	8a 1a                	mov    (%edx),%bl
  800230:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800236:	29 d8                	sub    %ebx,%eax
  800238:	eb 05                	jmp    80023f <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80023a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80023f:	5b                   	pop    %ebx
  800240:	5d                   	pop    %ebp
  800241:	c3                   	ret    

00800242 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800242:	55                   	push   %ebp
  800243:	89 e5                	mov    %esp,%ebp
  800245:	8b 45 08             	mov    0x8(%ebp),%eax
  800248:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80024b:	eb 05                	jmp    800252 <strchr+0x10>
		if (*s == c)
  80024d:	38 ca                	cmp    %cl,%dl
  80024f:	74 0c                	je     80025d <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800251:	40                   	inc    %eax
  800252:	8a 10                	mov    (%eax),%dl
  800254:	84 d2                	test   %dl,%dl
  800256:	75 f5                	jne    80024d <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800258:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	8b 45 08             	mov    0x8(%ebp),%eax
  800265:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800268:	eb 05                	jmp    80026f <strfind+0x10>
		if (*s == c)
  80026a:	38 ca                	cmp    %cl,%dl
  80026c:	74 07                	je     800275 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80026e:	40                   	inc    %eax
  80026f:	8a 10                	mov    (%eax),%dl
  800271:	84 d2                	test   %dl,%dl
  800273:	75 f5                	jne    80026a <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	57                   	push   %edi
  80027b:	56                   	push   %esi
  80027c:	53                   	push   %ebx
  80027d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800280:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800283:	85 c9                	test   %ecx,%ecx
  800285:	74 37                	je     8002be <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800287:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80028d:	75 29                	jne    8002b8 <memset+0x41>
  80028f:	f6 c1 03             	test   $0x3,%cl
  800292:	75 24                	jne    8002b8 <memset+0x41>
		c &= 0xFF;
  800294:	31 d2                	xor    %edx,%edx
  800296:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800299:	89 d3                	mov    %edx,%ebx
  80029b:	c1 e3 08             	shl    $0x8,%ebx
  80029e:	89 d6                	mov    %edx,%esi
  8002a0:	c1 e6 18             	shl    $0x18,%esi
  8002a3:	89 d0                	mov    %edx,%eax
  8002a5:	c1 e0 10             	shl    $0x10,%eax
  8002a8:	09 f0                	or     %esi,%eax
  8002aa:	09 c2                	or     %eax,%edx
  8002ac:	89 d0                	mov    %edx,%eax
  8002ae:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8002b0:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8002b3:	fc                   	cld    
  8002b4:	f3 ab                	rep stos %eax,%es:(%edi)
  8002b6:	eb 06                	jmp    8002be <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8002b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002bb:	fc                   	cld    
  8002bc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8002be:	89 f8                	mov    %edi,%eax
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5f                   	pop    %edi
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    

008002c5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8002d3:	39 c6                	cmp    %eax,%esi
  8002d5:	73 33                	jae    80030a <memmove+0x45>
  8002d7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8002da:	39 d0                	cmp    %edx,%eax
  8002dc:	73 2c                	jae    80030a <memmove+0x45>
		s += n;
		d += n;
  8002de:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8002e1:	89 d6                	mov    %edx,%esi
  8002e3:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8002e5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8002eb:	75 13                	jne    800300 <memmove+0x3b>
  8002ed:	f6 c1 03             	test   $0x3,%cl
  8002f0:	75 0e                	jne    800300 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8002f2:	83 ef 04             	sub    $0x4,%edi
  8002f5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8002f8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8002fb:	fd                   	std    
  8002fc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8002fe:	eb 07                	jmp    800307 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800300:	4f                   	dec    %edi
  800301:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800304:	fd                   	std    
  800305:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800307:	fc                   	cld    
  800308:	eb 1d                	jmp    800327 <memmove+0x62>
  80030a:	89 f2                	mov    %esi,%edx
  80030c:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80030e:	f6 c2 03             	test   $0x3,%dl
  800311:	75 0f                	jne    800322 <memmove+0x5d>
  800313:	f6 c1 03             	test   $0x3,%cl
  800316:	75 0a                	jne    800322 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800318:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80031b:	89 c7                	mov    %eax,%edi
  80031d:	fc                   	cld    
  80031e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800320:	eb 05                	jmp    800327 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800322:	89 c7                	mov    %eax,%edi
  800324:	fc                   	cld    
  800325:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800327:	5e                   	pop    %esi
  800328:	5f                   	pop    %edi
  800329:	5d                   	pop    %ebp
  80032a:	c3                   	ret    

0080032b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800331:	8b 45 10             	mov    0x10(%ebp),%eax
  800334:	89 44 24 08          	mov    %eax,0x8(%esp)
  800338:	8b 45 0c             	mov    0xc(%ebp),%eax
  80033b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033f:	8b 45 08             	mov    0x8(%ebp),%eax
  800342:	89 04 24             	mov    %eax,(%esp)
  800345:	e8 7b ff ff ff       	call   8002c5 <memmove>
}
  80034a:	c9                   	leave  
  80034b:	c3                   	ret    

0080034c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	56                   	push   %esi
  800350:	53                   	push   %ebx
  800351:	8b 55 08             	mov    0x8(%ebp),%edx
  800354:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800357:	89 d6                	mov    %edx,%esi
  800359:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80035c:	eb 19                	jmp    800377 <memcmp+0x2b>
		if (*s1 != *s2)
  80035e:	8a 02                	mov    (%edx),%al
  800360:	8a 19                	mov    (%ecx),%bl
  800362:	38 d8                	cmp    %bl,%al
  800364:	74 0f                	je     800375 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800366:	25 ff 00 00 00       	and    $0xff,%eax
  80036b:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800371:	29 d8                	sub    %ebx,%eax
  800373:	eb 0b                	jmp    800380 <memcmp+0x34>
		s1++, s2++;
  800375:	42                   	inc    %edx
  800376:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800377:	39 f2                	cmp    %esi,%edx
  800379:	75 e3                	jne    80035e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80037b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800380:	5b                   	pop    %ebx
  800381:	5e                   	pop    %esi
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	8b 45 08             	mov    0x8(%ebp),%eax
  80038a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80038d:	89 c2                	mov    %eax,%edx
  80038f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800392:	eb 05                	jmp    800399 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800394:	38 08                	cmp    %cl,(%eax)
  800396:	74 05                	je     80039d <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800398:	40                   	inc    %eax
  800399:	39 d0                	cmp    %edx,%eax
  80039b:	72 f7                	jb     800394 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    

0080039f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	57                   	push   %edi
  8003a3:	56                   	push   %esi
  8003a4:	53                   	push   %ebx
  8003a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003ab:	eb 01                	jmp    8003ae <strtol+0xf>
		s++;
  8003ad:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003ae:	8a 02                	mov    (%edx),%al
  8003b0:	3c 09                	cmp    $0x9,%al
  8003b2:	74 f9                	je     8003ad <strtol+0xe>
  8003b4:	3c 20                	cmp    $0x20,%al
  8003b6:	74 f5                	je     8003ad <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8003b8:	3c 2b                	cmp    $0x2b,%al
  8003ba:	75 08                	jne    8003c4 <strtol+0x25>
		s++;
  8003bc:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8003bd:	bf 00 00 00 00       	mov    $0x0,%edi
  8003c2:	eb 10                	jmp    8003d4 <strtol+0x35>
  8003c4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8003c9:	3c 2d                	cmp    $0x2d,%al
  8003cb:	75 07                	jne    8003d4 <strtol+0x35>
		s++, neg = 1;
  8003cd:	8d 52 01             	lea    0x1(%edx),%edx
  8003d0:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8003d4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8003da:	75 15                	jne    8003f1 <strtol+0x52>
  8003dc:	80 3a 30             	cmpb   $0x30,(%edx)
  8003df:	75 10                	jne    8003f1 <strtol+0x52>
  8003e1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8003e5:	75 0a                	jne    8003f1 <strtol+0x52>
		s += 2, base = 16;
  8003e7:	83 c2 02             	add    $0x2,%edx
  8003ea:	bb 10 00 00 00       	mov    $0x10,%ebx
  8003ef:	eb 0e                	jmp    8003ff <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  8003f1:	85 db                	test   %ebx,%ebx
  8003f3:	75 0a                	jne    8003ff <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8003f5:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8003f7:	80 3a 30             	cmpb   $0x30,(%edx)
  8003fa:	75 03                	jne    8003ff <strtol+0x60>
		s++, base = 8;
  8003fc:	42                   	inc    %edx
  8003fd:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  8003ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800404:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800407:	8a 0a                	mov    (%edx),%cl
  800409:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80040c:	89 f3                	mov    %esi,%ebx
  80040e:	80 fb 09             	cmp    $0x9,%bl
  800411:	77 08                	ja     80041b <strtol+0x7c>
			dig = *s - '0';
  800413:	0f be c9             	movsbl %cl,%ecx
  800416:	83 e9 30             	sub    $0x30,%ecx
  800419:	eb 22                	jmp    80043d <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  80041b:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80041e:	89 f3                	mov    %esi,%ebx
  800420:	80 fb 19             	cmp    $0x19,%bl
  800423:	77 08                	ja     80042d <strtol+0x8e>
			dig = *s - 'a' + 10;
  800425:	0f be c9             	movsbl %cl,%ecx
  800428:	83 e9 57             	sub    $0x57,%ecx
  80042b:	eb 10                	jmp    80043d <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  80042d:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800430:	89 f3                	mov    %esi,%ebx
  800432:	80 fb 19             	cmp    $0x19,%bl
  800435:	77 14                	ja     80044b <strtol+0xac>
			dig = *s - 'A' + 10;
  800437:	0f be c9             	movsbl %cl,%ecx
  80043a:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80043d:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800440:	7d 0d                	jge    80044f <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800442:	42                   	inc    %edx
  800443:	0f af 45 10          	imul   0x10(%ebp),%eax
  800447:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800449:	eb bc                	jmp    800407 <strtol+0x68>
  80044b:	89 c1                	mov    %eax,%ecx
  80044d:	eb 02                	jmp    800451 <strtol+0xb2>
  80044f:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800451:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800455:	74 05                	je     80045c <strtol+0xbd>
		*endptr = (char *) s;
  800457:	8b 75 0c             	mov    0xc(%ebp),%esi
  80045a:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80045c:	85 ff                	test   %edi,%edi
  80045e:	74 04                	je     800464 <strtol+0xc5>
  800460:	89 c8                	mov    %ecx,%eax
  800462:	f7 d8                	neg    %eax
}
  800464:	5b                   	pop    %ebx
  800465:	5e                   	pop    %esi
  800466:	5f                   	pop    %edi
  800467:	5d                   	pop    %ebp
  800468:	c3                   	ret    
  800469:	66 90                	xchg   %ax,%ax
  80046b:	90                   	nop

0080046c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80046c:	55                   	push   %ebp
  80046d:	89 e5                	mov    %esp,%ebp
  80046f:	57                   	push   %edi
  800470:	56                   	push   %esi
  800471:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800472:	b8 00 00 00 00       	mov    $0x0,%eax
  800477:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80047a:	8b 55 08             	mov    0x8(%ebp),%edx
  80047d:	89 c3                	mov    %eax,%ebx
  80047f:	89 c7                	mov    %eax,%edi
  800481:	89 c6                	mov    %eax,%esi
  800483:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800485:	5b                   	pop    %ebx
  800486:	5e                   	pop    %esi
  800487:	5f                   	pop    %edi
  800488:	5d                   	pop    %ebp
  800489:	c3                   	ret    

0080048a <sys_cgetc>:

int
sys_cgetc(void)
{
  80048a:	55                   	push   %ebp
  80048b:	89 e5                	mov    %esp,%ebp
  80048d:	57                   	push   %edi
  80048e:	56                   	push   %esi
  80048f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800490:	ba 00 00 00 00       	mov    $0x0,%edx
  800495:	b8 01 00 00 00       	mov    $0x1,%eax
  80049a:	89 d1                	mov    %edx,%ecx
  80049c:	89 d3                	mov    %edx,%ebx
  80049e:	89 d7                	mov    %edx,%edi
  8004a0:	89 d6                	mov    %edx,%esi
  8004a2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8004a4:	5b                   	pop    %ebx
  8004a5:	5e                   	pop    %esi
  8004a6:	5f                   	pop    %edi
  8004a7:	5d                   	pop    %ebp
  8004a8:	c3                   	ret    

008004a9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8004a9:	55                   	push   %ebp
  8004aa:	89 e5                	mov    %esp,%ebp
  8004ac:	57                   	push   %edi
  8004ad:	56                   	push   %esi
  8004ae:	53                   	push   %ebx
  8004af:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004b7:	b8 03 00 00 00       	mov    $0x3,%eax
  8004bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004bf:	89 cb                	mov    %ecx,%ebx
  8004c1:	89 cf                	mov    %ecx,%edi
  8004c3:	89 ce                	mov    %ecx,%esi
  8004c5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8004c7:	85 c0                	test   %eax,%eax
  8004c9:	7e 28                	jle    8004f3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004cb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004cf:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8004d6:	00 
  8004d7:	c7 44 24 08 aa 10 80 	movl   $0x8010aa,0x8(%esp)
  8004de:	00 
  8004df:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004e6:	00 
  8004e7:	c7 04 24 c7 10 80 00 	movl   $0x8010c7,(%esp)
  8004ee:	e8 5d 02 00 00       	call   800750 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8004f3:	83 c4 2c             	add    $0x2c,%esp
  8004f6:	5b                   	pop    %ebx
  8004f7:	5e                   	pop    %esi
  8004f8:	5f                   	pop    %edi
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	57                   	push   %edi
  8004ff:	56                   	push   %esi
  800500:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800501:	ba 00 00 00 00       	mov    $0x0,%edx
  800506:	b8 02 00 00 00       	mov    $0x2,%eax
  80050b:	89 d1                	mov    %edx,%ecx
  80050d:	89 d3                	mov    %edx,%ebx
  80050f:	89 d7                	mov    %edx,%edi
  800511:	89 d6                	mov    %edx,%esi
  800513:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800515:	5b                   	pop    %ebx
  800516:	5e                   	pop    %esi
  800517:	5f                   	pop    %edi
  800518:	5d                   	pop    %ebp
  800519:	c3                   	ret    

0080051a <sys_yield>:

void
sys_yield(void)
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	57                   	push   %edi
  80051e:	56                   	push   %esi
  80051f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800520:	ba 00 00 00 00       	mov    $0x0,%edx
  800525:	b8 0a 00 00 00       	mov    $0xa,%eax
  80052a:	89 d1                	mov    %edx,%ecx
  80052c:	89 d3                	mov    %edx,%ebx
  80052e:	89 d7                	mov    %edx,%edi
  800530:	89 d6                	mov    %edx,%esi
  800532:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800534:	5b                   	pop    %ebx
  800535:	5e                   	pop    %esi
  800536:	5f                   	pop    %edi
  800537:	5d                   	pop    %ebp
  800538:	c3                   	ret    

00800539 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800539:	55                   	push   %ebp
  80053a:	89 e5                	mov    %esp,%ebp
  80053c:	57                   	push   %edi
  80053d:	56                   	push   %esi
  80053e:	53                   	push   %ebx
  80053f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800542:	be 00 00 00 00       	mov    $0x0,%esi
  800547:	b8 04 00 00 00       	mov    $0x4,%eax
  80054c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80054f:	8b 55 08             	mov    0x8(%ebp),%edx
  800552:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800555:	89 f7                	mov    %esi,%edi
  800557:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800559:	85 c0                	test   %eax,%eax
  80055b:	7e 28                	jle    800585 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80055d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800561:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800568:	00 
  800569:	c7 44 24 08 aa 10 80 	movl   $0x8010aa,0x8(%esp)
  800570:	00 
  800571:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800578:	00 
  800579:	c7 04 24 c7 10 80 00 	movl   $0x8010c7,(%esp)
  800580:	e8 cb 01 00 00       	call   800750 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800585:	83 c4 2c             	add    $0x2c,%esp
  800588:	5b                   	pop    %ebx
  800589:	5e                   	pop    %esi
  80058a:	5f                   	pop    %edi
  80058b:	5d                   	pop    %ebp
  80058c:	c3                   	ret    

0080058d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80058d:	55                   	push   %ebp
  80058e:	89 e5                	mov    %esp,%ebp
  800590:	57                   	push   %edi
  800591:	56                   	push   %esi
  800592:	53                   	push   %ebx
  800593:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800596:	b8 05 00 00 00       	mov    $0x5,%eax
  80059b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80059e:	8b 55 08             	mov    0x8(%ebp),%edx
  8005a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005a4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005a7:	8b 75 18             	mov    0x18(%ebp),%esi
  8005aa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005ac:	85 c0                	test   %eax,%eax
  8005ae:	7e 28                	jle    8005d8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005b4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8005bb:	00 
  8005bc:	c7 44 24 08 aa 10 80 	movl   $0x8010aa,0x8(%esp)
  8005c3:	00 
  8005c4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005cb:	00 
  8005cc:	c7 04 24 c7 10 80 00 	movl   $0x8010c7,(%esp)
  8005d3:	e8 78 01 00 00       	call   800750 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8005d8:	83 c4 2c             	add    $0x2c,%esp
  8005db:	5b                   	pop    %ebx
  8005dc:	5e                   	pop    %esi
  8005dd:	5f                   	pop    %edi
  8005de:	5d                   	pop    %ebp
  8005df:	c3                   	ret    

008005e0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8005e0:	55                   	push   %ebp
  8005e1:	89 e5                	mov    %esp,%ebp
  8005e3:	57                   	push   %edi
  8005e4:	56                   	push   %esi
  8005e5:	53                   	push   %ebx
  8005e6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8005f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8005f9:	89 df                	mov    %ebx,%edi
  8005fb:	89 de                	mov    %ebx,%esi
  8005fd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005ff:	85 c0                	test   %eax,%eax
  800601:	7e 28                	jle    80062b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800603:	89 44 24 10          	mov    %eax,0x10(%esp)
  800607:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80060e:	00 
  80060f:	c7 44 24 08 aa 10 80 	movl   $0x8010aa,0x8(%esp)
  800616:	00 
  800617:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80061e:	00 
  80061f:	c7 04 24 c7 10 80 00 	movl   $0x8010c7,(%esp)
  800626:	e8 25 01 00 00       	call   800750 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80062b:	83 c4 2c             	add    $0x2c,%esp
  80062e:	5b                   	pop    %ebx
  80062f:	5e                   	pop    %esi
  800630:	5f                   	pop    %edi
  800631:	5d                   	pop    %ebp
  800632:	c3                   	ret    

00800633 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800633:	55                   	push   %ebp
  800634:	89 e5                	mov    %esp,%ebp
  800636:	57                   	push   %edi
  800637:	56                   	push   %esi
  800638:	53                   	push   %ebx
  800639:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80063c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800641:	b8 08 00 00 00       	mov    $0x8,%eax
  800646:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800649:	8b 55 08             	mov    0x8(%ebp),%edx
  80064c:	89 df                	mov    %ebx,%edi
  80064e:	89 de                	mov    %ebx,%esi
  800650:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800652:	85 c0                	test   %eax,%eax
  800654:	7e 28                	jle    80067e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800656:	89 44 24 10          	mov    %eax,0x10(%esp)
  80065a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800661:	00 
  800662:	c7 44 24 08 aa 10 80 	movl   $0x8010aa,0x8(%esp)
  800669:	00 
  80066a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800671:	00 
  800672:	c7 04 24 c7 10 80 00 	movl   $0x8010c7,(%esp)
  800679:	e8 d2 00 00 00       	call   800750 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80067e:	83 c4 2c             	add    $0x2c,%esp
  800681:	5b                   	pop    %ebx
  800682:	5e                   	pop    %esi
  800683:	5f                   	pop    %edi
  800684:	5d                   	pop    %ebp
  800685:	c3                   	ret    

00800686 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800686:	55                   	push   %ebp
  800687:	89 e5                	mov    %esp,%ebp
  800689:	57                   	push   %edi
  80068a:	56                   	push   %esi
  80068b:	53                   	push   %ebx
  80068c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80068f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800694:	b8 09 00 00 00       	mov    $0x9,%eax
  800699:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80069c:	8b 55 08             	mov    0x8(%ebp),%edx
  80069f:	89 df                	mov    %ebx,%edi
  8006a1:	89 de                	mov    %ebx,%esi
  8006a3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006a5:	85 c0                	test   %eax,%eax
  8006a7:	7e 28                	jle    8006d1 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006a9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ad:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8006b4:	00 
  8006b5:	c7 44 24 08 aa 10 80 	movl   $0x8010aa,0x8(%esp)
  8006bc:	00 
  8006bd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8006c4:	00 
  8006c5:	c7 04 24 c7 10 80 00 	movl   $0x8010c7,(%esp)
  8006cc:	e8 7f 00 00 00       	call   800750 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8006d1:	83 c4 2c             	add    $0x2c,%esp
  8006d4:	5b                   	pop    %ebx
  8006d5:	5e                   	pop    %esi
  8006d6:	5f                   	pop    %edi
  8006d7:	5d                   	pop    %ebp
  8006d8:	c3                   	ret    

008006d9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	57                   	push   %edi
  8006dd:	56                   	push   %esi
  8006de:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006df:	be 00 00 00 00       	mov    $0x0,%esi
  8006e4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8006e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006f2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8006f5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8006f7:	5b                   	pop    %ebx
  8006f8:	5e                   	pop    %esi
  8006f9:	5f                   	pop    %edi
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	57                   	push   %edi
  800700:	56                   	push   %esi
  800701:	53                   	push   %ebx
  800702:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800705:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80070f:	8b 55 08             	mov    0x8(%ebp),%edx
  800712:	89 cb                	mov    %ecx,%ebx
  800714:	89 cf                	mov    %ecx,%edi
  800716:	89 ce                	mov    %ecx,%esi
  800718:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80071a:	85 c0                	test   %eax,%eax
  80071c:	7e 28                	jle    800746 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80071e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800722:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800729:	00 
  80072a:	c7 44 24 08 aa 10 80 	movl   $0x8010aa,0x8(%esp)
  800731:	00 
  800732:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800739:	00 
  80073a:	c7 04 24 c7 10 80 00 	movl   $0x8010c7,(%esp)
  800741:	e8 0a 00 00 00       	call   800750 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800746:	83 c4 2c             	add    $0x2c,%esp
  800749:	5b                   	pop    %ebx
  80074a:	5e                   	pop    %esi
  80074b:	5f                   	pop    %edi
  80074c:	5d                   	pop    %ebp
  80074d:	c3                   	ret    
  80074e:	66 90                	xchg   %ax,%ax

00800750 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	56                   	push   %esi
  800754:	53                   	push   %ebx
  800755:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800758:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80075b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800761:	e8 95 fd ff ff       	call   8004fb <sys_getenvid>
  800766:	8b 55 0c             	mov    0xc(%ebp),%edx
  800769:	89 54 24 10          	mov    %edx,0x10(%esp)
  80076d:	8b 55 08             	mov    0x8(%ebp),%edx
  800770:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800774:	89 74 24 08          	mov    %esi,0x8(%esp)
  800778:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077c:	c7 04 24 d8 10 80 00 	movl   $0x8010d8,(%esp)
  800783:	e8 c2 00 00 00       	call   80084a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800788:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078c:	8b 45 10             	mov    0x10(%ebp),%eax
  80078f:	89 04 24             	mov    %eax,(%esp)
  800792:	e8 52 00 00 00       	call   8007e9 <vcprintf>
	cprintf("\n");
  800797:	c7 04 24 fc 10 80 00 	movl   $0x8010fc,(%esp)
  80079e:	e8 a7 00 00 00       	call   80084a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8007a3:	cc                   	int3   
  8007a4:	eb fd                	jmp    8007a3 <_panic+0x53>
  8007a6:	66 90                	xchg   %ax,%ax

008007a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	53                   	push   %ebx
  8007ac:	83 ec 14             	sub    $0x14,%esp
  8007af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8007b2:	8b 13                	mov    (%ebx),%edx
  8007b4:	8d 42 01             	lea    0x1(%edx),%eax
  8007b7:	89 03                	mov    %eax,(%ebx)
  8007b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8007c0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8007c5:	75 19                	jne    8007e0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8007c7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8007ce:	00 
  8007cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8007d2:	89 04 24             	mov    %eax,(%esp)
  8007d5:	e8 92 fc ff ff       	call   80046c <sys_cputs>
		b->idx = 0;
  8007da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8007e0:	ff 43 04             	incl   0x4(%ebx)
}
  8007e3:	83 c4 14             	add    $0x14,%esp
  8007e6:	5b                   	pop    %ebx
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8007f2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8007f9:	00 00 00 
	b.cnt = 0;
  8007fc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800803:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800806:	8b 45 0c             	mov    0xc(%ebp),%eax
  800809:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080d:	8b 45 08             	mov    0x8(%ebp),%eax
  800810:	89 44 24 08          	mov    %eax,0x8(%esp)
  800814:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80081a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081e:	c7 04 24 a8 07 80 00 	movl   $0x8007a8,(%esp)
  800825:	e8 a9 01 00 00       	call   8009d3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80082a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800830:	89 44 24 04          	mov    %eax,0x4(%esp)
  800834:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80083a:	89 04 24             	mov    %eax,(%esp)
  80083d:	e8 2a fc ff ff       	call   80046c <sys_cputs>

	return b.cnt;
}
  800842:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800848:	c9                   	leave  
  800849:	c3                   	ret    

0080084a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800850:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800853:	89 44 24 04          	mov    %eax,0x4(%esp)
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	89 04 24             	mov    %eax,(%esp)
  80085d:	e8 87 ff ff ff       	call   8007e9 <vcprintf>
	va_end(ap);

	return cnt;
}
  800862:	c9                   	leave  
  800863:	c3                   	ret    

00800864 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	57                   	push   %edi
  800868:	56                   	push   %esi
  800869:	53                   	push   %ebx
  80086a:	83 ec 3c             	sub    $0x3c,%esp
  80086d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800870:	89 d7                	mov    %edx,%edi
  800872:	8b 45 08             	mov    0x8(%ebp),%eax
  800875:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800878:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087b:	89 c1                	mov    %eax,%ecx
  80087d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800880:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800883:	8b 45 10             	mov    0x10(%ebp),%eax
  800886:	ba 00 00 00 00       	mov    $0x0,%edx
  80088b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80088e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800891:	39 ca                	cmp    %ecx,%edx
  800893:	72 08                	jb     80089d <printnum+0x39>
  800895:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800898:	39 45 10             	cmp    %eax,0x10(%ebp)
  80089b:	77 6a                	ja     800907 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80089d:	8b 45 18             	mov    0x18(%ebp),%eax
  8008a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8008a4:	4e                   	dec    %esi
  8008a5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b0:	8b 44 24 08          	mov    0x8(%esp),%eax
  8008b4:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8008b8:	89 c3                	mov    %eax,%ebx
  8008ba:	89 d6                	mov    %edx,%esi
  8008bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008c6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008cd:	89 04 24             	mov    %eax,(%esp)
  8008d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8008d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d7:	e8 24 05 00 00       	call   800e00 <__udivdi3>
  8008dc:	89 d9                	mov    %ebx,%ecx
  8008de:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008e6:	89 04 24             	mov    %eax,(%esp)
  8008e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ed:	89 fa                	mov    %edi,%edx
  8008ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008f2:	e8 6d ff ff ff       	call   800864 <printnum>
  8008f7:	eb 19                	jmp    800912 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8008f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008fd:	8b 45 18             	mov    0x18(%ebp),%eax
  800900:	89 04 24             	mov    %eax,(%esp)
  800903:	ff d3                	call   *%ebx
  800905:	eb 03                	jmp    80090a <printnum+0xa6>
  800907:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80090a:	4e                   	dec    %esi
  80090b:	85 f6                	test   %esi,%esi
  80090d:	7f ea                	jg     8008f9 <printnum+0x95>
  80090f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800912:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800916:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80091a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80091d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800920:	89 44 24 08          	mov    %eax,0x8(%esp)
  800924:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800928:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80092b:	89 04 24             	mov    %eax,(%esp)
  80092e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800931:	89 44 24 04          	mov    %eax,0x4(%esp)
  800935:	e8 f6 05 00 00       	call   800f30 <__umoddi3>
  80093a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80093e:	0f be 80 fe 10 80 00 	movsbl 0x8010fe(%eax),%eax
  800945:	89 04 24             	mov    %eax,(%esp)
  800948:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80094b:	ff d0                	call   *%eax
}
  80094d:	83 c4 3c             	add    $0x3c,%esp
  800950:	5b                   	pop    %ebx
  800951:	5e                   	pop    %esi
  800952:	5f                   	pop    %edi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800958:	83 fa 01             	cmp    $0x1,%edx
  80095b:	7e 0e                	jle    80096b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80095d:	8b 10                	mov    (%eax),%edx
  80095f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800962:	89 08                	mov    %ecx,(%eax)
  800964:	8b 02                	mov    (%edx),%eax
  800966:	8b 52 04             	mov    0x4(%edx),%edx
  800969:	eb 22                	jmp    80098d <getuint+0x38>
	else if (lflag)
  80096b:	85 d2                	test   %edx,%edx
  80096d:	74 10                	je     80097f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80096f:	8b 10                	mov    (%eax),%edx
  800971:	8d 4a 04             	lea    0x4(%edx),%ecx
  800974:	89 08                	mov    %ecx,(%eax)
  800976:	8b 02                	mov    (%edx),%eax
  800978:	ba 00 00 00 00       	mov    $0x0,%edx
  80097d:	eb 0e                	jmp    80098d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80097f:	8b 10                	mov    (%eax),%edx
  800981:	8d 4a 04             	lea    0x4(%edx),%ecx
  800984:	89 08                	mov    %ecx,(%eax)
  800986:	8b 02                	mov    (%edx),%eax
  800988:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800995:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800998:	8b 10                	mov    (%eax),%edx
  80099a:	3b 50 04             	cmp    0x4(%eax),%edx
  80099d:	73 0a                	jae    8009a9 <sprintputch+0x1a>
		*b->buf++ = ch;
  80099f:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009a2:	89 08                	mov    %ecx,(%eax)
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	88 02                	mov    %al,(%edx)
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8009b1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8009b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	89 04 24             	mov    %eax,(%esp)
  8009cc:	e8 02 00 00 00       	call   8009d3 <vprintfmt>
	va_end(ap);
}
  8009d1:	c9                   	leave  
  8009d2:	c3                   	ret    

008009d3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	57                   	push   %edi
  8009d7:	56                   	push   %esi
  8009d8:	53                   	push   %ebx
  8009d9:	83 ec 3c             	sub    $0x3c,%esp
  8009dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8009df:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009e2:	eb 14                	jmp    8009f8 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8009e4:	85 c0                	test   %eax,%eax
  8009e6:	0f 84 8a 03 00 00    	je     800d76 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  8009ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009f0:	89 04 24             	mov    %eax,(%esp)
  8009f3:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8009f6:	89 f3                	mov    %esi,%ebx
  8009f8:	8d 73 01             	lea    0x1(%ebx),%esi
  8009fb:	31 c0                	xor    %eax,%eax
  8009fd:	8a 03                	mov    (%ebx),%al
  8009ff:	83 f8 25             	cmp    $0x25,%eax
  800a02:	75 e0                	jne    8009e4 <vprintfmt+0x11>
  800a04:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800a08:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800a0f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800a16:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800a1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a22:	eb 1d                	jmp    800a41 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a24:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800a26:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800a2a:	eb 15                	jmp    800a41 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a2c:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a2e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800a32:	eb 0d                	jmp    800a41 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800a34:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a37:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a3a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a41:	8d 5e 01             	lea    0x1(%esi),%ebx
  800a44:	31 c0                	xor    %eax,%eax
  800a46:	8a 06                	mov    (%esi),%al
  800a48:	8a 0e                	mov    (%esi),%cl
  800a4a:	83 e9 23             	sub    $0x23,%ecx
  800a4d:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800a50:	80 f9 55             	cmp    $0x55,%cl
  800a53:	0f 87 ff 02 00 00    	ja     800d58 <vprintfmt+0x385>
  800a59:	31 c9                	xor    %ecx,%ecx
  800a5b:	8a 4d e0             	mov    -0x20(%ebp),%cl
  800a5e:	ff 24 8d c0 11 80 00 	jmp    *0x8011c0(,%ecx,4)
  800a65:	89 de                	mov    %ebx,%esi
  800a67:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800a6c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800a6f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800a73:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800a76:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800a79:	83 fb 09             	cmp    $0x9,%ebx
  800a7c:	77 2f                	ja     800aad <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800a7e:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800a7f:	eb eb                	jmp    800a6c <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800a81:	8b 45 14             	mov    0x14(%ebp),%eax
  800a84:	8d 48 04             	lea    0x4(%eax),%ecx
  800a87:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a8a:	8b 00                	mov    (%eax),%eax
  800a8c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a8f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800a91:	eb 1d                	jmp    800ab0 <vprintfmt+0xdd>
  800a93:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a96:	f7 d0                	not    %eax
  800a98:	c1 f8 1f             	sar    $0x1f,%eax
  800a9b:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a9e:	89 de                	mov    %ebx,%esi
  800aa0:	eb 9f                	jmp    800a41 <vprintfmt+0x6e>
  800aa2:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800aa4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800aab:	eb 94                	jmp    800a41 <vprintfmt+0x6e>
  800aad:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800ab0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ab4:	79 8b                	jns    800a41 <vprintfmt+0x6e>
  800ab6:	e9 79 ff ff ff       	jmp    800a34 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800abb:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800abc:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800abe:	eb 81                	jmp    800a41 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800ac0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac3:	8d 50 04             	lea    0x4(%eax),%edx
  800ac6:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800acd:	8b 00                	mov    (%eax),%eax
  800acf:	89 04 24             	mov    %eax,(%esp)
  800ad2:	ff 55 08             	call   *0x8(%ebp)
			break;
  800ad5:	e9 1e ff ff ff       	jmp    8009f8 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800ada:	8b 45 14             	mov    0x14(%ebp),%eax
  800add:	8d 50 04             	lea    0x4(%eax),%edx
  800ae0:	89 55 14             	mov    %edx,0x14(%ebp)
  800ae3:	8b 00                	mov    (%eax),%eax
  800ae5:	89 c2                	mov    %eax,%edx
  800ae7:	c1 fa 1f             	sar    $0x1f,%edx
  800aea:	31 d0                	xor    %edx,%eax
  800aec:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800aee:	83 f8 09             	cmp    $0x9,%eax
  800af1:	7f 0b                	jg     800afe <vprintfmt+0x12b>
  800af3:	8b 14 85 20 13 80 00 	mov    0x801320(,%eax,4),%edx
  800afa:	85 d2                	test   %edx,%edx
  800afc:	75 20                	jne    800b1e <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  800afe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b02:	c7 44 24 08 16 11 80 	movl   $0x801116,0x8(%esp)
  800b09:	00 
  800b0a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b11:	89 04 24             	mov    %eax,(%esp)
  800b14:	e8 92 fe ff ff       	call   8009ab <printfmt>
  800b19:	e9 da fe ff ff       	jmp    8009f8 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800b1e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b22:	c7 44 24 08 1f 11 80 	movl   $0x80111f,0x8(%esp)
  800b29:	00 
  800b2a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b31:	89 04 24             	mov    %eax,(%esp)
  800b34:	e8 72 fe ff ff       	call   8009ab <printfmt>
  800b39:	e9 ba fe ff ff       	jmp    8009f8 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b3e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800b41:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b44:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800b47:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4a:	8d 50 04             	lea    0x4(%eax),%edx
  800b4d:	89 55 14             	mov    %edx,0x14(%ebp)
  800b50:	8b 30                	mov    (%eax),%esi
  800b52:	85 f6                	test   %esi,%esi
  800b54:	75 05                	jne    800b5b <vprintfmt+0x188>
				p = "(null)";
  800b56:	be 0f 11 80 00       	mov    $0x80110f,%esi
			if (width > 0 && padc != '-')
  800b5b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800b5f:	0f 84 8c 00 00 00    	je     800bf1 <vprintfmt+0x21e>
  800b65:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b69:	0f 8e 8a 00 00 00    	jle    800bf9 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b6f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b73:	89 34 24             	mov    %esi,(%esp)
  800b76:	e8 9b f5 ff ff       	call   800116 <strnlen>
  800b7b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800b7e:	29 c1                	sub    %eax,%ecx
  800b80:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800b83:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800b87:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b8a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800b8d:	8b 75 08             	mov    0x8(%ebp),%esi
  800b90:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b93:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b95:	eb 0d                	jmp    800ba4 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800b97:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b9e:	89 04 24             	mov    %eax,(%esp)
  800ba1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800ba3:	4b                   	dec    %ebx
  800ba4:	85 db                	test   %ebx,%ebx
  800ba6:	7f ef                	jg     800b97 <vprintfmt+0x1c4>
  800ba8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800bab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800bae:	89 c8                	mov    %ecx,%eax
  800bb0:	f7 d0                	not    %eax
  800bb2:	c1 f8 1f             	sar    $0x1f,%eax
  800bb5:	21 c8                	and    %ecx,%eax
  800bb7:	29 c1                	sub    %eax,%ecx
  800bb9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800bbc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800bbf:	eb 3e                	jmp    800bff <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800bc1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800bc5:	74 1b                	je     800be2 <vprintfmt+0x20f>
  800bc7:	0f be d2             	movsbl %dl,%edx
  800bca:	83 ea 20             	sub    $0x20,%edx
  800bcd:	83 fa 5e             	cmp    $0x5e,%edx
  800bd0:	76 10                	jbe    800be2 <vprintfmt+0x20f>
					putch('?', putdat);
  800bd2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bd6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800bdd:	ff 55 08             	call   *0x8(%ebp)
  800be0:	eb 0a                	jmp    800bec <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800be2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800be6:	89 04 24             	mov    %eax,(%esp)
  800be9:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bec:	ff 4d dc             	decl   -0x24(%ebp)
  800bef:	eb 0e                	jmp    800bff <vprintfmt+0x22c>
  800bf1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bf4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800bf7:	eb 06                	jmp    800bff <vprintfmt+0x22c>
  800bf9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bfc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800bff:	46                   	inc    %esi
  800c00:	8a 56 ff             	mov    -0x1(%esi),%dl
  800c03:	0f be c2             	movsbl %dl,%eax
  800c06:	85 c0                	test   %eax,%eax
  800c08:	74 1f                	je     800c29 <vprintfmt+0x256>
  800c0a:	85 db                	test   %ebx,%ebx
  800c0c:	78 b3                	js     800bc1 <vprintfmt+0x1ee>
  800c0e:	4b                   	dec    %ebx
  800c0f:	79 b0                	jns    800bc1 <vprintfmt+0x1ee>
  800c11:	8b 75 08             	mov    0x8(%ebp),%esi
  800c14:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800c17:	eb 16                	jmp    800c2f <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800c19:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c1d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800c24:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800c26:	4b                   	dec    %ebx
  800c27:	eb 06                	jmp    800c2f <vprintfmt+0x25c>
  800c29:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800c2c:	8b 75 08             	mov    0x8(%ebp),%esi
  800c2f:	85 db                	test   %ebx,%ebx
  800c31:	7f e6                	jg     800c19 <vprintfmt+0x246>
  800c33:	89 75 08             	mov    %esi,0x8(%ebp)
  800c36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c39:	e9 ba fd ff ff       	jmp    8009f8 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c3e:	83 fa 01             	cmp    $0x1,%edx
  800c41:	7e 16                	jle    800c59 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  800c43:	8b 45 14             	mov    0x14(%ebp),%eax
  800c46:	8d 50 08             	lea    0x8(%eax),%edx
  800c49:	89 55 14             	mov    %edx,0x14(%ebp)
  800c4c:	8b 50 04             	mov    0x4(%eax),%edx
  800c4f:	8b 00                	mov    (%eax),%eax
  800c51:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c54:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c57:	eb 32                	jmp    800c8b <vprintfmt+0x2b8>
	else if (lflag)
  800c59:	85 d2                	test   %edx,%edx
  800c5b:	74 18                	je     800c75 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800c5d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c60:	8d 50 04             	lea    0x4(%eax),%edx
  800c63:	89 55 14             	mov    %edx,0x14(%ebp)
  800c66:	8b 30                	mov    (%eax),%esi
  800c68:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800c6b:	89 f0                	mov    %esi,%eax
  800c6d:	c1 f8 1f             	sar    $0x1f,%eax
  800c70:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c73:	eb 16                	jmp    800c8b <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800c75:	8b 45 14             	mov    0x14(%ebp),%eax
  800c78:	8d 50 04             	lea    0x4(%eax),%edx
  800c7b:	89 55 14             	mov    %edx,0x14(%ebp)
  800c7e:	8b 30                	mov    (%eax),%esi
  800c80:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800c83:	89 f0                	mov    %esi,%eax
  800c85:	c1 f8 1f             	sar    $0x1f,%eax
  800c88:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c8e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800c91:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800c96:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c9a:	0f 89 80 00 00 00    	jns    800d20 <vprintfmt+0x34d>
				putch('-', putdat);
  800ca0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ca4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800cab:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800cae:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800cb1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800cb4:	f7 d8                	neg    %eax
  800cb6:	83 d2 00             	adc    $0x0,%edx
  800cb9:	f7 da                	neg    %edx
			}
			base = 10;
  800cbb:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800cc0:	eb 5e                	jmp    800d20 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800cc2:	8d 45 14             	lea    0x14(%ebp),%eax
  800cc5:	e8 8b fc ff ff       	call   800955 <getuint>
			base = 10;
  800cca:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800ccf:	eb 4f                	jmp    800d20 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800cd1:	8d 45 14             	lea    0x14(%ebp),%eax
  800cd4:	e8 7c fc ff ff       	call   800955 <getuint>
			base = 8;
  800cd9:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800cde:	eb 40                	jmp    800d20 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800ce0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ce4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800ceb:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800cee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cf2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800cf9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800cfc:	8b 45 14             	mov    0x14(%ebp),%eax
  800cff:	8d 50 04             	lea    0x4(%eax),%edx
  800d02:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800d05:	8b 00                	mov    (%eax),%eax
  800d07:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800d0c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800d11:	eb 0d                	jmp    800d20 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800d13:	8d 45 14             	lea    0x14(%ebp),%eax
  800d16:	e8 3a fc ff ff       	call   800955 <getuint>
			base = 16;
  800d1b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800d20:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800d24:	89 74 24 10          	mov    %esi,0x10(%esp)
  800d28:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800d2b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800d2f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d33:	89 04 24             	mov    %eax,(%esp)
  800d36:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d3a:	89 fa                	mov    %edi,%edx
  800d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3f:	e8 20 fb ff ff       	call   800864 <printnum>
			break;
  800d44:	e9 af fc ff ff       	jmp    8009f8 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d49:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d4d:	89 04 24             	mov    %eax,(%esp)
  800d50:	ff 55 08             	call   *0x8(%ebp)
			break;
  800d53:	e9 a0 fc ff ff       	jmp    8009f8 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d58:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d5c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800d63:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d66:	89 f3                	mov    %esi,%ebx
  800d68:	eb 01                	jmp    800d6b <vprintfmt+0x398>
  800d6a:	4b                   	dec    %ebx
  800d6b:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800d6f:	75 f9                	jne    800d6a <vprintfmt+0x397>
  800d71:	e9 82 fc ff ff       	jmp    8009f8 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800d76:	83 c4 3c             	add    $0x3c,%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	83 ec 28             	sub    $0x28,%esp
  800d84:	8b 45 08             	mov    0x8(%ebp),%eax
  800d87:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d8a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d8d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d91:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	74 30                	je     800dcf <vsnprintf+0x51>
  800d9f:	85 d2                	test   %edx,%edx
  800da1:	7e 2c                	jle    800dcf <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800da3:	8b 45 14             	mov    0x14(%ebp),%eax
  800da6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800daa:	8b 45 10             	mov    0x10(%ebp),%eax
  800dad:	89 44 24 08          	mov    %eax,0x8(%esp)
  800db1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800db4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800db8:	c7 04 24 8f 09 80 00 	movl   $0x80098f,(%esp)
  800dbf:	e8 0f fc ff ff       	call   8009d3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800dc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dc7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dcd:	eb 05                	jmp    800dd4 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800dcf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800dd4:	c9                   	leave  
  800dd5:	c3                   	ret    

00800dd6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ddc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ddf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800de3:	8b 45 10             	mov    0x10(%ebp),%eax
  800de6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ded:	89 44 24 04          	mov    %eax,0x4(%esp)
  800df1:	8b 45 08             	mov    0x8(%ebp),%eax
  800df4:	89 04 24             	mov    %eax,(%esp)
  800df7:	e8 82 ff ff ff       	call   800d7e <vsnprintf>
	va_end(ap);

	return rc;
}
  800dfc:	c9                   	leave  
  800dfd:	c3                   	ret    
  800dfe:	66 90                	xchg   %ax,%ax

00800e00 <__udivdi3>:
  800e00:	55                   	push   %ebp
  800e01:	57                   	push   %edi
  800e02:	56                   	push   %esi
  800e03:	83 ec 0c             	sub    $0xc,%esp
  800e06:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800e0a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800e0e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800e12:	8b 44 24 28          	mov    0x28(%esp),%eax
  800e16:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e1a:	89 ea                	mov    %ebp,%edx
  800e1c:	89 0c 24             	mov    %ecx,(%esp)
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	75 2d                	jne    800e50 <__udivdi3+0x50>
  800e23:	39 e9                	cmp    %ebp,%ecx
  800e25:	77 61                	ja     800e88 <__udivdi3+0x88>
  800e27:	89 ce                	mov    %ecx,%esi
  800e29:	85 c9                	test   %ecx,%ecx
  800e2b:	75 0b                	jne    800e38 <__udivdi3+0x38>
  800e2d:	b8 01 00 00 00       	mov    $0x1,%eax
  800e32:	31 d2                	xor    %edx,%edx
  800e34:	f7 f1                	div    %ecx
  800e36:	89 c6                	mov    %eax,%esi
  800e38:	31 d2                	xor    %edx,%edx
  800e3a:	89 e8                	mov    %ebp,%eax
  800e3c:	f7 f6                	div    %esi
  800e3e:	89 c5                	mov    %eax,%ebp
  800e40:	89 f8                	mov    %edi,%eax
  800e42:	f7 f6                	div    %esi
  800e44:	89 ea                	mov    %ebp,%edx
  800e46:	83 c4 0c             	add    $0xc,%esp
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    
  800e4d:	8d 76 00             	lea    0x0(%esi),%esi
  800e50:	39 e8                	cmp    %ebp,%eax
  800e52:	77 24                	ja     800e78 <__udivdi3+0x78>
  800e54:	0f bd e8             	bsr    %eax,%ebp
  800e57:	83 f5 1f             	xor    $0x1f,%ebp
  800e5a:	75 3c                	jne    800e98 <__udivdi3+0x98>
  800e5c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e60:	39 34 24             	cmp    %esi,(%esp)
  800e63:	0f 86 9f 00 00 00    	jbe    800f08 <__udivdi3+0x108>
  800e69:	39 d0                	cmp    %edx,%eax
  800e6b:	0f 82 97 00 00 00    	jb     800f08 <__udivdi3+0x108>
  800e71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e78:	31 d2                	xor    %edx,%edx
  800e7a:	31 c0                	xor    %eax,%eax
  800e7c:	83 c4 0c             	add    $0xc,%esp
  800e7f:	5e                   	pop    %esi
  800e80:	5f                   	pop    %edi
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    
  800e83:	90                   	nop
  800e84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e88:	89 f8                	mov    %edi,%eax
  800e8a:	f7 f1                	div    %ecx
  800e8c:	31 d2                	xor    %edx,%edx
  800e8e:	83 c4 0c             	add    $0xc,%esp
  800e91:	5e                   	pop    %esi
  800e92:	5f                   	pop    %edi
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    
  800e95:	8d 76 00             	lea    0x0(%esi),%esi
  800e98:	89 e9                	mov    %ebp,%ecx
  800e9a:	8b 3c 24             	mov    (%esp),%edi
  800e9d:	d3 e0                	shl    %cl,%eax
  800e9f:	89 c6                	mov    %eax,%esi
  800ea1:	b8 20 00 00 00       	mov    $0x20,%eax
  800ea6:	29 e8                	sub    %ebp,%eax
  800ea8:	88 c1                	mov    %al,%cl
  800eaa:	d3 ef                	shr    %cl,%edi
  800eac:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800eb0:	89 e9                	mov    %ebp,%ecx
  800eb2:	8b 3c 24             	mov    (%esp),%edi
  800eb5:	09 74 24 08          	or     %esi,0x8(%esp)
  800eb9:	d3 e7                	shl    %cl,%edi
  800ebb:	89 d6                	mov    %edx,%esi
  800ebd:	88 c1                	mov    %al,%cl
  800ebf:	d3 ee                	shr    %cl,%esi
  800ec1:	89 e9                	mov    %ebp,%ecx
  800ec3:	89 3c 24             	mov    %edi,(%esp)
  800ec6:	d3 e2                	shl    %cl,%edx
  800ec8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ecc:	88 c1                	mov    %al,%cl
  800ece:	d3 ef                	shr    %cl,%edi
  800ed0:	09 d7                	or     %edx,%edi
  800ed2:	89 f2                	mov    %esi,%edx
  800ed4:	89 f8                	mov    %edi,%eax
  800ed6:	f7 74 24 08          	divl   0x8(%esp)
  800eda:	89 d6                	mov    %edx,%esi
  800edc:	89 c7                	mov    %eax,%edi
  800ede:	f7 24 24             	mull   (%esp)
  800ee1:	89 14 24             	mov    %edx,(%esp)
  800ee4:	39 d6                	cmp    %edx,%esi
  800ee6:	72 30                	jb     800f18 <__udivdi3+0x118>
  800ee8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800eec:	89 e9                	mov    %ebp,%ecx
  800eee:	d3 e2                	shl    %cl,%edx
  800ef0:	39 c2                	cmp    %eax,%edx
  800ef2:	73 05                	jae    800ef9 <__udivdi3+0xf9>
  800ef4:	3b 34 24             	cmp    (%esp),%esi
  800ef7:	74 1f                	je     800f18 <__udivdi3+0x118>
  800ef9:	89 f8                	mov    %edi,%eax
  800efb:	31 d2                	xor    %edx,%edx
  800efd:	e9 7a ff ff ff       	jmp    800e7c <__udivdi3+0x7c>
  800f02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f08:	31 d2                	xor    %edx,%edx
  800f0a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f0f:	e9 68 ff ff ff       	jmp    800e7c <__udivdi3+0x7c>
  800f14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f18:	8d 47 ff             	lea    -0x1(%edi),%eax
  800f1b:	31 d2                	xor    %edx,%edx
  800f1d:	83 c4 0c             	add    $0xc,%esp
  800f20:	5e                   	pop    %esi
  800f21:	5f                   	pop    %edi
  800f22:	5d                   	pop    %ebp
  800f23:	c3                   	ret    
  800f24:	66 90                	xchg   %ax,%ax
  800f26:	66 90                	xchg   %ax,%ax
  800f28:	66 90                	xchg   %ax,%ax
  800f2a:	66 90                	xchg   %ax,%ax
  800f2c:	66 90                	xchg   %ax,%ax
  800f2e:	66 90                	xchg   %ax,%ax

00800f30 <__umoddi3>:
  800f30:	55                   	push   %ebp
  800f31:	57                   	push   %edi
  800f32:	56                   	push   %esi
  800f33:	83 ec 14             	sub    $0x14,%esp
  800f36:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f3a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f3e:	89 c7                	mov    %eax,%edi
  800f40:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f44:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800f48:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f4c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f50:	89 34 24             	mov    %esi,(%esp)
  800f53:	89 c2                	mov    %eax,%edx
  800f55:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f59:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	75 17                	jne    800f78 <__umoddi3+0x48>
  800f61:	39 fe                	cmp    %edi,%esi
  800f63:	76 4b                	jbe    800fb0 <__umoddi3+0x80>
  800f65:	89 c8                	mov    %ecx,%eax
  800f67:	89 fa                	mov    %edi,%edx
  800f69:	f7 f6                	div    %esi
  800f6b:	89 d0                	mov    %edx,%eax
  800f6d:	31 d2                	xor    %edx,%edx
  800f6f:	83 c4 14             	add    $0x14,%esp
  800f72:	5e                   	pop    %esi
  800f73:	5f                   	pop    %edi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    
  800f76:	66 90                	xchg   %ax,%ax
  800f78:	39 f8                	cmp    %edi,%eax
  800f7a:	77 54                	ja     800fd0 <__umoddi3+0xa0>
  800f7c:	0f bd e8             	bsr    %eax,%ebp
  800f7f:	83 f5 1f             	xor    $0x1f,%ebp
  800f82:	75 5c                	jne    800fe0 <__umoddi3+0xb0>
  800f84:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f88:	39 3c 24             	cmp    %edi,(%esp)
  800f8b:	0f 87 f7 00 00 00    	ja     801088 <__umoddi3+0x158>
  800f91:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f95:	29 f1                	sub    %esi,%ecx
  800f97:	19 c7                	sbb    %eax,%edi
  800f99:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f9d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fa1:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fa5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fa9:	83 c4 14             	add    $0x14,%esp
  800fac:	5e                   	pop    %esi
  800fad:	5f                   	pop    %edi
  800fae:	5d                   	pop    %ebp
  800faf:	c3                   	ret    
  800fb0:	89 f5                	mov    %esi,%ebp
  800fb2:	85 f6                	test   %esi,%esi
  800fb4:	75 0b                	jne    800fc1 <__umoddi3+0x91>
  800fb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fbb:	31 d2                	xor    %edx,%edx
  800fbd:	f7 f6                	div    %esi
  800fbf:	89 c5                	mov    %eax,%ebp
  800fc1:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fc5:	31 d2                	xor    %edx,%edx
  800fc7:	f7 f5                	div    %ebp
  800fc9:	89 c8                	mov    %ecx,%eax
  800fcb:	f7 f5                	div    %ebp
  800fcd:	eb 9c                	jmp    800f6b <__umoddi3+0x3b>
  800fcf:	90                   	nop
  800fd0:	89 c8                	mov    %ecx,%eax
  800fd2:	89 fa                	mov    %edi,%edx
  800fd4:	83 c4 14             	add    $0x14,%esp
  800fd7:	5e                   	pop    %esi
  800fd8:	5f                   	pop    %edi
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    
  800fdb:	90                   	nop
  800fdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fe0:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800fe7:	00 
  800fe8:	8b 34 24             	mov    (%esp),%esi
  800feb:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fef:	89 e9                	mov    %ebp,%ecx
  800ff1:	29 e8                	sub    %ebp,%eax
  800ff3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ff7:	89 f0                	mov    %esi,%eax
  800ff9:	d3 e2                	shl    %cl,%edx
  800ffb:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800fff:	d3 e8                	shr    %cl,%eax
  801001:	89 04 24             	mov    %eax,(%esp)
  801004:	89 e9                	mov    %ebp,%ecx
  801006:	89 f0                	mov    %esi,%eax
  801008:	09 14 24             	or     %edx,(%esp)
  80100b:	d3 e0                	shl    %cl,%eax
  80100d:	89 fa                	mov    %edi,%edx
  80100f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801013:	d3 ea                	shr    %cl,%edx
  801015:	89 e9                	mov    %ebp,%ecx
  801017:	89 c6                	mov    %eax,%esi
  801019:	d3 e7                	shl    %cl,%edi
  80101b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80101f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801023:	8b 44 24 10          	mov    0x10(%esp),%eax
  801027:	d3 e8                	shr    %cl,%eax
  801029:	09 f8                	or     %edi,%eax
  80102b:	89 e9                	mov    %ebp,%ecx
  80102d:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801031:	d3 e7                	shl    %cl,%edi
  801033:	f7 34 24             	divl   (%esp)
  801036:	89 d1                	mov    %edx,%ecx
  801038:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80103c:	f7 e6                	mul    %esi
  80103e:	89 c7                	mov    %eax,%edi
  801040:	89 d6                	mov    %edx,%esi
  801042:	39 d1                	cmp    %edx,%ecx
  801044:	72 2e                	jb     801074 <__umoddi3+0x144>
  801046:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80104a:	72 24                	jb     801070 <__umoddi3+0x140>
  80104c:	89 ca                	mov    %ecx,%edx
  80104e:	89 e9                	mov    %ebp,%ecx
  801050:	8b 44 24 08          	mov    0x8(%esp),%eax
  801054:	29 f8                	sub    %edi,%eax
  801056:	19 f2                	sbb    %esi,%edx
  801058:	d3 e8                	shr    %cl,%eax
  80105a:	89 d6                	mov    %edx,%esi
  80105c:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801060:	d3 e6                	shl    %cl,%esi
  801062:	89 e9                	mov    %ebp,%ecx
  801064:	09 f0                	or     %esi,%eax
  801066:	d3 ea                	shr    %cl,%edx
  801068:	83 c4 14             	add    $0x14,%esp
  80106b:	5e                   	pop    %esi
  80106c:	5f                   	pop    %edi
  80106d:	5d                   	pop    %ebp
  80106e:	c3                   	ret    
  80106f:	90                   	nop
  801070:	39 d1                	cmp    %edx,%ecx
  801072:	75 d8                	jne    80104c <__umoddi3+0x11c>
  801074:	89 d6                	mov    %edx,%esi
  801076:	89 c7                	mov    %eax,%edi
  801078:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  80107c:	1b 34 24             	sbb    (%esp),%esi
  80107f:	eb cb                	jmp    80104c <__umoddi3+0x11c>
  801081:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801088:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80108c:	0f 82 ff fe ff ff    	jb     800f91 <__umoddi3+0x61>
  801092:	e9 0a ff ff ff       	jmp    800fa1 <__umoddi3+0x71>
