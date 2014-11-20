
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
  800047:	56                   	push   %esi
  800048:	53                   	push   %ebx
  800049:	83 ec 10             	sub    $0x10,%esp
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  800052:	b8 08 20 80 00       	mov    $0x802008,%eax
  800057:	2d 04 20 80 00       	sub    $0x802004,%eax
  80005c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800060:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800067:	00 
  800068:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  80006f:	e8 cf 01 00 00       	call   800243 <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  800074:	e8 4e 04 00 00       	call   8004c7 <sys_getenvid>
  800079:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800085:	c1 e0 07             	shl    $0x7,%eax
  800088:	29 d0                	sub    %edx,%eax
  80008a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800094:	85 db                	test   %ebx,%ebx
  800096:	7e 07                	jle    80009f <libmain+0x5b>
		binaryname = argv[0];
  800098:	8b 06                	mov    (%esi),%eax
  80009a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000a3:	89 1c 24             	mov    %ebx,(%esp)
  8000a6:	e8 89 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000ab:	e8 08 00 00 00       	call   8000b8 <exit>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    
  8000b7:	90                   	nop

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c5:	e8 ab 03 00 00       	call   800475 <sys_env_destroy>
}
  8000ca:	c9                   	leave  
  8000cb:	c3                   	ret    

008000cc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8000d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d7:	eb 01                	jmp    8000da <strlen+0xe>
		n++;
  8000d9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8000da:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8000de:	75 f9                	jne    8000d9 <strlen+0xd>
		n++;
	return n;
}
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    

008000e2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8000eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f0:	eb 01                	jmp    8000f3 <strnlen+0x11>
		n++;
  8000f2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8000f3:	39 d0                	cmp    %edx,%eax
  8000f5:	74 06                	je     8000fd <strnlen+0x1b>
  8000f7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8000fb:	75 f5                	jne    8000f2 <strnlen+0x10>
		n++;
	return n;
}
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	53                   	push   %ebx
  800103:	8b 45 08             	mov    0x8(%ebp),%eax
  800106:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800109:	89 c2                	mov    %eax,%edx
  80010b:	42                   	inc    %edx
  80010c:	41                   	inc    %ecx
  80010d:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800110:	88 5a ff             	mov    %bl,-0x1(%edx)
  800113:	84 db                	test   %bl,%bl
  800115:	75 f4                	jne    80010b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800117:	5b                   	pop    %ebx
  800118:	5d                   	pop    %ebp
  800119:	c3                   	ret    

0080011a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	53                   	push   %ebx
  80011e:	83 ec 08             	sub    $0x8,%esp
  800121:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800124:	89 1c 24             	mov    %ebx,(%esp)
  800127:	e8 a0 ff ff ff       	call   8000cc <strlen>
	strcpy(dst + len, src);
  80012c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80012f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800133:	01 d8                	add    %ebx,%eax
  800135:	89 04 24             	mov    %eax,(%esp)
  800138:	e8 c2 ff ff ff       	call   8000ff <strcpy>
	return dst;
}
  80013d:	89 d8                	mov    %ebx,%eax
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	5b                   	pop    %ebx
  800143:	5d                   	pop    %ebp
  800144:	c3                   	ret    

00800145 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
  80014a:	8b 75 08             	mov    0x8(%ebp),%esi
  80014d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800150:	89 f3                	mov    %esi,%ebx
  800152:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800155:	89 f2                	mov    %esi,%edx
  800157:	eb 0c                	jmp    800165 <strncpy+0x20>
		*dst++ = *src;
  800159:	42                   	inc    %edx
  80015a:	8a 01                	mov    (%ecx),%al
  80015c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80015f:	80 39 01             	cmpb   $0x1,(%ecx)
  800162:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800165:	39 da                	cmp    %ebx,%edx
  800167:	75 f0                	jne    800159 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800169:	89 f0                	mov    %esi,%eax
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5d                   	pop    %ebp
  80016e:	c3                   	ret    

0080016f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	56                   	push   %esi
  800173:	53                   	push   %ebx
  800174:	8b 75 08             	mov    0x8(%ebp),%esi
  800177:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80017d:	89 f0                	mov    %esi,%eax
  80017f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800183:	85 c9                	test   %ecx,%ecx
  800185:	75 07                	jne    80018e <strlcpy+0x1f>
  800187:	eb 18                	jmp    8001a1 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800189:	40                   	inc    %eax
  80018a:	42                   	inc    %edx
  80018b:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80018e:	39 d8                	cmp    %ebx,%eax
  800190:	74 0a                	je     80019c <strlcpy+0x2d>
  800192:	8a 0a                	mov    (%edx),%cl
  800194:	84 c9                	test   %cl,%cl
  800196:	75 f1                	jne    800189 <strlcpy+0x1a>
  800198:	89 c2                	mov    %eax,%edx
  80019a:	eb 02                	jmp    80019e <strlcpy+0x2f>
  80019c:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80019e:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8001a1:	29 f0                	sub    %esi,%eax
}
  8001a3:	5b                   	pop    %ebx
  8001a4:	5e                   	pop    %esi
  8001a5:	5d                   	pop    %ebp
  8001a6:	c3                   	ret    

008001a7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8001b0:	eb 02                	jmp    8001b4 <strcmp+0xd>
		p++, q++;
  8001b2:	41                   	inc    %ecx
  8001b3:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8001b4:	8a 01                	mov    (%ecx),%al
  8001b6:	84 c0                	test   %al,%al
  8001b8:	74 04                	je     8001be <strcmp+0x17>
  8001ba:	3a 02                	cmp    (%edx),%al
  8001bc:	74 f4                	je     8001b2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8001be:	25 ff 00 00 00       	and    $0xff,%eax
  8001c3:	8a 0a                	mov    (%edx),%cl
  8001c5:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8001cb:	29 c8                	sub    %ecx,%eax
}
  8001cd:	5d                   	pop    %ebp
  8001ce:	c3                   	ret    

008001cf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	53                   	push   %ebx
  8001d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d9:	89 c3                	mov    %eax,%ebx
  8001db:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8001de:	eb 02                	jmp    8001e2 <strncmp+0x13>
		n--, p++, q++;
  8001e0:	40                   	inc    %eax
  8001e1:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8001e2:	39 d8                	cmp    %ebx,%eax
  8001e4:	74 20                	je     800206 <strncmp+0x37>
  8001e6:	8a 08                	mov    (%eax),%cl
  8001e8:	84 c9                	test   %cl,%cl
  8001ea:	74 04                	je     8001f0 <strncmp+0x21>
  8001ec:	3a 0a                	cmp    (%edx),%cl
  8001ee:	74 f0                	je     8001e0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8001f0:	8a 18                	mov    (%eax),%bl
  8001f2:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8001f8:	89 d8                	mov    %ebx,%eax
  8001fa:	8a 1a                	mov    (%edx),%bl
  8001fc:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800202:	29 d8                	sub    %ebx,%eax
  800204:	eb 05                	jmp    80020b <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800206:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80020b:	5b                   	pop    %ebx
  80020c:	5d                   	pop    %ebp
  80020d:	c3                   	ret    

0080020e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
  800211:	8b 45 08             	mov    0x8(%ebp),%eax
  800214:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800217:	eb 05                	jmp    80021e <strchr+0x10>
		if (*s == c)
  800219:	38 ca                	cmp    %cl,%dl
  80021b:	74 0c                	je     800229 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80021d:	40                   	inc    %eax
  80021e:	8a 10                	mov    (%eax),%dl
  800220:	84 d2                	test   %dl,%dl
  800222:	75 f5                	jne    800219 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800224:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800229:	5d                   	pop    %ebp
  80022a:	c3                   	ret    

0080022b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800234:	eb 05                	jmp    80023b <strfind+0x10>
		if (*s == c)
  800236:	38 ca                	cmp    %cl,%dl
  800238:	74 07                	je     800241 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80023a:	40                   	inc    %eax
  80023b:	8a 10                	mov    (%eax),%dl
  80023d:	84 d2                	test   %dl,%dl
  80023f:	75 f5                	jne    800236 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800241:	5d                   	pop    %ebp
  800242:	c3                   	ret    

00800243 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	57                   	push   %edi
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
  800249:	8b 7d 08             	mov    0x8(%ebp),%edi
  80024c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80024f:	85 c9                	test   %ecx,%ecx
  800251:	74 37                	je     80028a <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800253:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800259:	75 29                	jne    800284 <memset+0x41>
  80025b:	f6 c1 03             	test   $0x3,%cl
  80025e:	75 24                	jne    800284 <memset+0x41>
		c &= 0xFF;
  800260:	31 d2                	xor    %edx,%edx
  800262:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800265:	89 d3                	mov    %edx,%ebx
  800267:	c1 e3 08             	shl    $0x8,%ebx
  80026a:	89 d6                	mov    %edx,%esi
  80026c:	c1 e6 18             	shl    $0x18,%esi
  80026f:	89 d0                	mov    %edx,%eax
  800271:	c1 e0 10             	shl    $0x10,%eax
  800274:	09 f0                	or     %esi,%eax
  800276:	09 c2                	or     %eax,%edx
  800278:	89 d0                	mov    %edx,%eax
  80027a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80027c:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80027f:	fc                   	cld    
  800280:	f3 ab                	rep stos %eax,%es:(%edi)
  800282:	eb 06                	jmp    80028a <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800284:	8b 45 0c             	mov    0xc(%ebp),%eax
  800287:	fc                   	cld    
  800288:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80028a:	89 f8                	mov    %edi,%eax
  80028c:	5b                   	pop    %ebx
  80028d:	5e                   	pop    %esi
  80028e:	5f                   	pop    %edi
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	57                   	push   %edi
  800295:	56                   	push   %esi
  800296:	8b 45 08             	mov    0x8(%ebp),%eax
  800299:	8b 75 0c             	mov    0xc(%ebp),%esi
  80029c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80029f:	39 c6                	cmp    %eax,%esi
  8002a1:	73 33                	jae    8002d6 <memmove+0x45>
  8002a3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8002a6:	39 d0                	cmp    %edx,%eax
  8002a8:	73 2c                	jae    8002d6 <memmove+0x45>
		s += n;
		d += n;
  8002aa:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8002ad:	89 d6                	mov    %edx,%esi
  8002af:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8002b1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8002b7:	75 13                	jne    8002cc <memmove+0x3b>
  8002b9:	f6 c1 03             	test   $0x3,%cl
  8002bc:	75 0e                	jne    8002cc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8002be:	83 ef 04             	sub    $0x4,%edi
  8002c1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8002c4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8002c7:	fd                   	std    
  8002c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8002ca:	eb 07                	jmp    8002d3 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8002cc:	4f                   	dec    %edi
  8002cd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8002d0:	fd                   	std    
  8002d1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8002d3:	fc                   	cld    
  8002d4:	eb 1d                	jmp    8002f3 <memmove+0x62>
  8002d6:	89 f2                	mov    %esi,%edx
  8002d8:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8002da:	f6 c2 03             	test   $0x3,%dl
  8002dd:	75 0f                	jne    8002ee <memmove+0x5d>
  8002df:	f6 c1 03             	test   $0x3,%cl
  8002e2:	75 0a                	jne    8002ee <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8002e4:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8002e7:	89 c7                	mov    %eax,%edi
  8002e9:	fc                   	cld    
  8002ea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8002ec:	eb 05                	jmp    8002f3 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8002ee:	89 c7                	mov    %eax,%edi
  8002f0:	fc                   	cld    
  8002f1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8002fd:	8b 45 10             	mov    0x10(%ebp),%eax
  800300:	89 44 24 08          	mov    %eax,0x8(%esp)
  800304:	8b 45 0c             	mov    0xc(%ebp),%eax
  800307:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030b:	8b 45 08             	mov    0x8(%ebp),%eax
  80030e:	89 04 24             	mov    %eax,(%esp)
  800311:	e8 7b ff ff ff       	call   800291 <memmove>
}
  800316:	c9                   	leave  
  800317:	c3                   	ret    

00800318 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	56                   	push   %esi
  80031c:	53                   	push   %ebx
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800323:	89 d6                	mov    %edx,%esi
  800325:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800328:	eb 19                	jmp    800343 <memcmp+0x2b>
		if (*s1 != *s2)
  80032a:	8a 02                	mov    (%edx),%al
  80032c:	8a 19                	mov    (%ecx),%bl
  80032e:	38 d8                	cmp    %bl,%al
  800330:	74 0f                	je     800341 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800332:	25 ff 00 00 00       	and    $0xff,%eax
  800337:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80033d:	29 d8                	sub    %ebx,%eax
  80033f:	eb 0b                	jmp    80034c <memcmp+0x34>
		s1++, s2++;
  800341:	42                   	inc    %edx
  800342:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800343:	39 f2                	cmp    %esi,%edx
  800345:	75 e3                	jne    80032a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800347:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80034c:	5b                   	pop    %ebx
  80034d:	5e                   	pop    %esi
  80034e:	5d                   	pop    %ebp
  80034f:	c3                   	ret    

00800350 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	8b 45 08             	mov    0x8(%ebp),%eax
  800356:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800359:	89 c2                	mov    %eax,%edx
  80035b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80035e:	eb 05                	jmp    800365 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800360:	38 08                	cmp    %cl,(%eax)
  800362:	74 05                	je     800369 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800364:	40                   	inc    %eax
  800365:	39 d0                	cmp    %edx,%eax
  800367:	72 f7                	jb     800360 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	57                   	push   %edi
  80036f:	56                   	push   %esi
  800370:	53                   	push   %ebx
  800371:	8b 55 08             	mov    0x8(%ebp),%edx
  800374:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800377:	eb 01                	jmp    80037a <strtol+0xf>
		s++;
  800379:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80037a:	8a 02                	mov    (%edx),%al
  80037c:	3c 09                	cmp    $0x9,%al
  80037e:	74 f9                	je     800379 <strtol+0xe>
  800380:	3c 20                	cmp    $0x20,%al
  800382:	74 f5                	je     800379 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800384:	3c 2b                	cmp    $0x2b,%al
  800386:	75 08                	jne    800390 <strtol+0x25>
		s++;
  800388:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800389:	bf 00 00 00 00       	mov    $0x0,%edi
  80038e:	eb 10                	jmp    8003a0 <strtol+0x35>
  800390:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800395:	3c 2d                	cmp    $0x2d,%al
  800397:	75 07                	jne    8003a0 <strtol+0x35>
		s++, neg = 1;
  800399:	8d 52 01             	lea    0x1(%edx),%edx
  80039c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8003a0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8003a6:	75 15                	jne    8003bd <strtol+0x52>
  8003a8:	80 3a 30             	cmpb   $0x30,(%edx)
  8003ab:	75 10                	jne    8003bd <strtol+0x52>
  8003ad:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8003b1:	75 0a                	jne    8003bd <strtol+0x52>
		s += 2, base = 16;
  8003b3:	83 c2 02             	add    $0x2,%edx
  8003b6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8003bb:	eb 0e                	jmp    8003cb <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  8003bd:	85 db                	test   %ebx,%ebx
  8003bf:	75 0a                	jne    8003cb <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8003c1:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8003c3:	80 3a 30             	cmpb   $0x30,(%edx)
  8003c6:	75 03                	jne    8003cb <strtol+0x60>
		s++, base = 8;
  8003c8:	42                   	inc    %edx
  8003c9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  8003cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8003d3:	8a 0a                	mov    (%edx),%cl
  8003d5:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8003d8:	89 f3                	mov    %esi,%ebx
  8003da:	80 fb 09             	cmp    $0x9,%bl
  8003dd:	77 08                	ja     8003e7 <strtol+0x7c>
			dig = *s - '0';
  8003df:	0f be c9             	movsbl %cl,%ecx
  8003e2:	83 e9 30             	sub    $0x30,%ecx
  8003e5:	eb 22                	jmp    800409 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  8003e7:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8003ea:	89 f3                	mov    %esi,%ebx
  8003ec:	80 fb 19             	cmp    $0x19,%bl
  8003ef:	77 08                	ja     8003f9 <strtol+0x8e>
			dig = *s - 'a' + 10;
  8003f1:	0f be c9             	movsbl %cl,%ecx
  8003f4:	83 e9 57             	sub    $0x57,%ecx
  8003f7:	eb 10                	jmp    800409 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  8003f9:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8003fc:	89 f3                	mov    %esi,%ebx
  8003fe:	80 fb 19             	cmp    $0x19,%bl
  800401:	77 14                	ja     800417 <strtol+0xac>
			dig = *s - 'A' + 10;
  800403:	0f be c9             	movsbl %cl,%ecx
  800406:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800409:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80040c:	7d 0d                	jge    80041b <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  80040e:	42                   	inc    %edx
  80040f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800413:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800415:	eb bc                	jmp    8003d3 <strtol+0x68>
  800417:	89 c1                	mov    %eax,%ecx
  800419:	eb 02                	jmp    80041d <strtol+0xb2>
  80041b:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80041d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800421:	74 05                	je     800428 <strtol+0xbd>
		*endptr = (char *) s;
  800423:	8b 75 0c             	mov    0xc(%ebp),%esi
  800426:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800428:	85 ff                	test   %edi,%edi
  80042a:	74 04                	je     800430 <strtol+0xc5>
  80042c:	89 c8                	mov    %ecx,%eax
  80042e:	f7 d8                	neg    %eax
}
  800430:	5b                   	pop    %ebx
  800431:	5e                   	pop    %esi
  800432:	5f                   	pop    %edi
  800433:	5d                   	pop    %ebp
  800434:	c3                   	ret    
  800435:	66 90                	xchg   %ax,%ax
  800437:	90                   	nop

00800438 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	57                   	push   %edi
  80043c:	56                   	push   %esi
  80043d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80043e:	b8 00 00 00 00       	mov    $0x0,%eax
  800443:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800446:	8b 55 08             	mov    0x8(%ebp),%edx
  800449:	89 c3                	mov    %eax,%ebx
  80044b:	89 c7                	mov    %eax,%edi
  80044d:	89 c6                	mov    %eax,%esi
  80044f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800451:	5b                   	pop    %ebx
  800452:	5e                   	pop    %esi
  800453:	5f                   	pop    %edi
  800454:	5d                   	pop    %ebp
  800455:	c3                   	ret    

00800456 <sys_cgetc>:

int
sys_cgetc(void)
{
  800456:	55                   	push   %ebp
  800457:	89 e5                	mov    %esp,%ebp
  800459:	57                   	push   %edi
  80045a:	56                   	push   %esi
  80045b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80045c:	ba 00 00 00 00       	mov    $0x0,%edx
  800461:	b8 01 00 00 00       	mov    $0x1,%eax
  800466:	89 d1                	mov    %edx,%ecx
  800468:	89 d3                	mov    %edx,%ebx
  80046a:	89 d7                	mov    %edx,%edi
  80046c:	89 d6                	mov    %edx,%esi
  80046e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800470:	5b                   	pop    %ebx
  800471:	5e                   	pop    %esi
  800472:	5f                   	pop    %edi
  800473:	5d                   	pop    %ebp
  800474:	c3                   	ret    

00800475 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800475:	55                   	push   %ebp
  800476:	89 e5                	mov    %esp,%ebp
  800478:	57                   	push   %edi
  800479:	56                   	push   %esi
  80047a:	53                   	push   %ebx
  80047b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80047e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800483:	b8 03 00 00 00       	mov    $0x3,%eax
  800488:	8b 55 08             	mov    0x8(%ebp),%edx
  80048b:	89 cb                	mov    %ecx,%ebx
  80048d:	89 cf                	mov    %ecx,%edi
  80048f:	89 ce                	mov    %ecx,%esi
  800491:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800493:	85 c0                	test   %eax,%eax
  800495:	7e 28                	jle    8004bf <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800497:	89 44 24 10          	mov    %eax,0x10(%esp)
  80049b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8004a2:	00 
  8004a3:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8004aa:	00 
  8004ab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004b2:	00 
  8004b3:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8004ba:	e8 5d 02 00 00       	call   80071c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8004bf:	83 c4 2c             	add    $0x2c,%esp
  8004c2:	5b                   	pop    %ebx
  8004c3:	5e                   	pop    %esi
  8004c4:	5f                   	pop    %edi
  8004c5:	5d                   	pop    %ebp
  8004c6:	c3                   	ret    

008004c7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8004c7:	55                   	push   %ebp
  8004c8:	89 e5                	mov    %esp,%ebp
  8004ca:	57                   	push   %edi
  8004cb:	56                   	push   %esi
  8004cc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d2:	b8 02 00 00 00       	mov    $0x2,%eax
  8004d7:	89 d1                	mov    %edx,%ecx
  8004d9:	89 d3                	mov    %edx,%ebx
  8004db:	89 d7                	mov    %edx,%edi
  8004dd:	89 d6                	mov    %edx,%esi
  8004df:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8004e1:	5b                   	pop    %ebx
  8004e2:	5e                   	pop    %esi
  8004e3:	5f                   	pop    %edi
  8004e4:	5d                   	pop    %ebp
  8004e5:	c3                   	ret    

008004e6 <sys_yield>:

void
sys_yield(void)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	57                   	push   %edi
  8004ea:	56                   	push   %esi
  8004eb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004f6:	89 d1                	mov    %edx,%ecx
  8004f8:	89 d3                	mov    %edx,%ebx
  8004fa:	89 d7                	mov    %edx,%edi
  8004fc:	89 d6                	mov    %edx,%esi
  8004fe:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800500:	5b                   	pop    %ebx
  800501:	5e                   	pop    %esi
  800502:	5f                   	pop    %edi
  800503:	5d                   	pop    %ebp
  800504:	c3                   	ret    

00800505 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
  800508:	57                   	push   %edi
  800509:	56                   	push   %esi
  80050a:	53                   	push   %ebx
  80050b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80050e:	be 00 00 00 00       	mov    $0x0,%esi
  800513:	b8 04 00 00 00       	mov    $0x4,%eax
  800518:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80051b:	8b 55 08             	mov    0x8(%ebp),%edx
  80051e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800521:	89 f7                	mov    %esi,%edi
  800523:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800525:	85 c0                	test   %eax,%eax
  800527:	7e 28                	jle    800551 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800529:	89 44 24 10          	mov    %eax,0x10(%esp)
  80052d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800534:	00 
  800535:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  80053c:	00 
  80053d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800544:	00 
  800545:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  80054c:	e8 cb 01 00 00       	call   80071c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800551:	83 c4 2c             	add    $0x2c,%esp
  800554:	5b                   	pop    %ebx
  800555:	5e                   	pop    %esi
  800556:	5f                   	pop    %edi
  800557:	5d                   	pop    %ebp
  800558:	c3                   	ret    

00800559 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800559:	55                   	push   %ebp
  80055a:	89 e5                	mov    %esp,%ebp
  80055c:	57                   	push   %edi
  80055d:	56                   	push   %esi
  80055e:	53                   	push   %ebx
  80055f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800562:	b8 05 00 00 00       	mov    $0x5,%eax
  800567:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80056a:	8b 55 08             	mov    0x8(%ebp),%edx
  80056d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800570:	8b 7d 14             	mov    0x14(%ebp),%edi
  800573:	8b 75 18             	mov    0x18(%ebp),%esi
  800576:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800578:	85 c0                	test   %eax,%eax
  80057a:	7e 28                	jle    8005a4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80057c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800580:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800587:	00 
  800588:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  80058f:	00 
  800590:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800597:	00 
  800598:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  80059f:	e8 78 01 00 00       	call   80071c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8005a4:	83 c4 2c             	add    $0x2c,%esp
  8005a7:	5b                   	pop    %ebx
  8005a8:	5e                   	pop    %esi
  8005a9:	5f                   	pop    %edi
  8005aa:	5d                   	pop    %ebp
  8005ab:	c3                   	ret    

008005ac <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8005ac:	55                   	push   %ebp
  8005ad:	89 e5                	mov    %esp,%ebp
  8005af:	57                   	push   %edi
  8005b0:	56                   	push   %esi
  8005b1:	53                   	push   %ebx
  8005b2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005ba:	b8 06 00 00 00       	mov    $0x6,%eax
  8005bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8005c5:	89 df                	mov    %ebx,%edi
  8005c7:	89 de                	mov    %ebx,%esi
  8005c9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	7e 28                	jle    8005f7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005cf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005d3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8005da:	00 
  8005db:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8005e2:	00 
  8005e3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005ea:	00 
  8005eb:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8005f2:	e8 25 01 00 00       	call   80071c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8005f7:	83 c4 2c             	add    $0x2c,%esp
  8005fa:	5b                   	pop    %ebx
  8005fb:	5e                   	pop    %esi
  8005fc:	5f                   	pop    %edi
  8005fd:	5d                   	pop    %ebp
  8005fe:	c3                   	ret    

008005ff <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8005ff:	55                   	push   %ebp
  800600:	89 e5                	mov    %esp,%ebp
  800602:	57                   	push   %edi
  800603:	56                   	push   %esi
  800604:	53                   	push   %ebx
  800605:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800608:	bb 00 00 00 00       	mov    $0x0,%ebx
  80060d:	b8 08 00 00 00       	mov    $0x8,%eax
  800612:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800615:	8b 55 08             	mov    0x8(%ebp),%edx
  800618:	89 df                	mov    %ebx,%edi
  80061a:	89 de                	mov    %ebx,%esi
  80061c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80061e:	85 c0                	test   %eax,%eax
  800620:	7e 28                	jle    80064a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800622:	89 44 24 10          	mov    %eax,0x10(%esp)
  800626:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80062d:	00 
  80062e:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800635:	00 
  800636:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80063d:	00 
  80063e:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800645:	e8 d2 00 00 00       	call   80071c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80064a:	83 c4 2c             	add    $0x2c,%esp
  80064d:	5b                   	pop    %ebx
  80064e:	5e                   	pop    %esi
  80064f:	5f                   	pop    %edi
  800650:	5d                   	pop    %ebp
  800651:	c3                   	ret    

00800652 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800652:	55                   	push   %ebp
  800653:	89 e5                	mov    %esp,%ebp
  800655:	57                   	push   %edi
  800656:	56                   	push   %esi
  800657:	53                   	push   %ebx
  800658:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80065b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800660:	b8 09 00 00 00       	mov    $0x9,%eax
  800665:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800668:	8b 55 08             	mov    0x8(%ebp),%edx
  80066b:	89 df                	mov    %ebx,%edi
  80066d:	89 de                	mov    %ebx,%esi
  80066f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800671:	85 c0                	test   %eax,%eax
  800673:	7e 28                	jle    80069d <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800675:	89 44 24 10          	mov    %eax,0x10(%esp)
  800679:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800680:	00 
  800681:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800688:	00 
  800689:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800690:	00 
  800691:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800698:	e8 7f 00 00 00       	call   80071c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80069d:	83 c4 2c             	add    $0x2c,%esp
  8006a0:	5b                   	pop    %ebx
  8006a1:	5e                   	pop    %esi
  8006a2:	5f                   	pop    %edi
  8006a3:	5d                   	pop    %ebp
  8006a4:	c3                   	ret    

008006a5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8006a5:	55                   	push   %ebp
  8006a6:	89 e5                	mov    %esp,%ebp
  8006a8:	57                   	push   %edi
  8006a9:	56                   	push   %esi
  8006aa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006ab:	be 00 00 00 00       	mov    $0x0,%esi
  8006b0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8006b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8006bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006be:	8b 7d 14             	mov    0x14(%ebp),%edi
  8006c1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8006c3:	5b                   	pop    %ebx
  8006c4:	5e                   	pop    %esi
  8006c5:	5f                   	pop    %edi
  8006c6:	5d                   	pop    %ebp
  8006c7:	c3                   	ret    

008006c8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	57                   	push   %edi
  8006cc:	56                   	push   %esi
  8006cd:	53                   	push   %ebx
  8006ce:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8006db:	8b 55 08             	mov    0x8(%ebp),%edx
  8006de:	89 cb                	mov    %ecx,%ebx
  8006e0:	89 cf                	mov    %ecx,%edi
  8006e2:	89 ce                	mov    %ecx,%esi
  8006e4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006e6:	85 c0                	test   %eax,%eax
  8006e8:	7e 28                	jle    800712 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006ea:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ee:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8006f5:	00 
  8006f6:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8006fd:	00 
  8006fe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800705:	00 
  800706:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  80070d:	e8 0a 00 00 00       	call   80071c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800712:	83 c4 2c             	add    $0x2c,%esp
  800715:	5b                   	pop    %ebx
  800716:	5e                   	pop    %esi
  800717:	5f                   	pop    %edi
  800718:	5d                   	pop    %ebp
  800719:	c3                   	ret    
  80071a:	66 90                	xchg   %ax,%ax

0080071c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	56                   	push   %esi
  800720:	53                   	push   %ebx
  800721:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800724:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800727:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80072d:	e8 95 fd ff ff       	call   8004c7 <sys_getenvid>
  800732:	8b 55 0c             	mov    0xc(%ebp),%edx
  800735:	89 54 24 10          	mov    %edx,0x10(%esp)
  800739:	8b 55 08             	mov    0x8(%ebp),%edx
  80073c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800740:	89 74 24 08          	mov    %esi,0x8(%esp)
  800744:	89 44 24 04          	mov    %eax,0x4(%esp)
  800748:	c7 04 24 b8 10 80 00 	movl   $0x8010b8,(%esp)
  80074f:	e8 c2 00 00 00       	call   800816 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800754:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800758:	8b 45 10             	mov    0x10(%ebp),%eax
  80075b:	89 04 24             	mov    %eax,(%esp)
  80075e:	e8 52 00 00 00       	call   8007b5 <vcprintf>
	cprintf("\n");
  800763:	c7 04 24 dc 10 80 00 	movl   $0x8010dc,(%esp)
  80076a:	e8 a7 00 00 00       	call   800816 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80076f:	cc                   	int3   
  800770:	eb fd                	jmp    80076f <_panic+0x53>
  800772:	66 90                	xchg   %ax,%ax

00800774 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	53                   	push   %ebx
  800778:	83 ec 14             	sub    $0x14,%esp
  80077b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80077e:	8b 13                	mov    (%ebx),%edx
  800780:	8d 42 01             	lea    0x1(%edx),%eax
  800783:	89 03                	mov    %eax,(%ebx)
  800785:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800788:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80078c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800791:	75 19                	jne    8007ac <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800793:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80079a:	00 
  80079b:	8d 43 08             	lea    0x8(%ebx),%eax
  80079e:	89 04 24             	mov    %eax,(%esp)
  8007a1:	e8 92 fc ff ff       	call   800438 <sys_cputs>
		b->idx = 0;
  8007a6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8007ac:	ff 43 04             	incl   0x4(%ebx)
}
  8007af:	83 c4 14             	add    $0x14,%esp
  8007b2:	5b                   	pop    %ebx
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8007be:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8007c5:	00 00 00 
	b.cnt = 0;
  8007c8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8007cf:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8007d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8007e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ea:	c7 04 24 74 07 80 00 	movl   $0x800774,(%esp)
  8007f1:	e8 a9 01 00 00       	call   80099f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8007f6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8007fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800800:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800806:	89 04 24             	mov    %eax,(%esp)
  800809:	e8 2a fc ff ff       	call   800438 <sys_cputs>

	return b.cnt;
}
  80080e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800814:	c9                   	leave  
  800815:	c3                   	ret    

00800816 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80081c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80081f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	89 04 24             	mov    %eax,(%esp)
  800829:	e8 87 ff ff ff       	call   8007b5 <vcprintf>
	va_end(ap);

	return cnt;
}
  80082e:	c9                   	leave  
  80082f:	c3                   	ret    

00800830 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	57                   	push   %edi
  800834:	56                   	push   %esi
  800835:	53                   	push   %ebx
  800836:	83 ec 3c             	sub    $0x3c,%esp
  800839:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80083c:	89 d7                	mov    %edx,%edi
  80083e:	8b 45 08             	mov    0x8(%ebp),%eax
  800841:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800844:	8b 45 0c             	mov    0xc(%ebp),%eax
  800847:	89 c1                	mov    %eax,%ecx
  800849:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80084c:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80084f:	8b 45 10             	mov    0x10(%ebp),%eax
  800852:	ba 00 00 00 00       	mov    $0x0,%edx
  800857:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80085a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80085d:	39 ca                	cmp    %ecx,%edx
  80085f:	72 08                	jb     800869 <printnum+0x39>
  800861:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800864:	39 45 10             	cmp    %eax,0x10(%ebp)
  800867:	77 6a                	ja     8008d3 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800869:	8b 45 18             	mov    0x18(%ebp),%eax
  80086c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800870:	4e                   	dec    %esi
  800871:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800875:	8b 45 10             	mov    0x10(%ebp),%eax
  800878:	89 44 24 08          	mov    %eax,0x8(%esp)
  80087c:	8b 44 24 08          	mov    0x8(%esp),%eax
  800880:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800884:	89 c3                	mov    %eax,%ebx
  800886:	89 d6                	mov    %edx,%esi
  800888:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80088b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80088e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800892:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800896:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800899:	89 04 24             	mov    %eax,(%esp)
  80089c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80089f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a3:	e8 28 05 00 00       	call   800dd0 <__udivdi3>
  8008a8:	89 d9                	mov    %ebx,%ecx
  8008aa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008ae:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008b2:	89 04 24             	mov    %eax,(%esp)
  8008b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b9:	89 fa                	mov    %edi,%edx
  8008bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008be:	e8 6d ff ff ff       	call   800830 <printnum>
  8008c3:	eb 19                	jmp    8008de <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8008c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008c9:	8b 45 18             	mov    0x18(%ebp),%eax
  8008cc:	89 04 24             	mov    %eax,(%esp)
  8008cf:	ff d3                	call   *%ebx
  8008d1:	eb 03                	jmp    8008d6 <printnum+0xa6>
  8008d3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8008d6:	4e                   	dec    %esi
  8008d7:	85 f6                	test   %esi,%esi
  8008d9:	7f ea                	jg     8008c5 <printnum+0x95>
  8008db:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8008de:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008e2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8008e6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008e9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008f0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008f7:	89 04 24             	mov    %eax,(%esp)
  8008fa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8008fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800901:	e8 fa 05 00 00       	call   800f00 <__umoddi3>
  800906:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80090a:	0f be 80 de 10 80 00 	movsbl 0x8010de(%eax),%eax
  800911:	89 04 24             	mov    %eax,(%esp)
  800914:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800917:	ff d0                	call   *%eax
}
  800919:	83 c4 3c             	add    $0x3c,%esp
  80091c:	5b                   	pop    %ebx
  80091d:	5e                   	pop    %esi
  80091e:	5f                   	pop    %edi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800924:	83 fa 01             	cmp    $0x1,%edx
  800927:	7e 0e                	jle    800937 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800929:	8b 10                	mov    (%eax),%edx
  80092b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80092e:	89 08                	mov    %ecx,(%eax)
  800930:	8b 02                	mov    (%edx),%eax
  800932:	8b 52 04             	mov    0x4(%edx),%edx
  800935:	eb 22                	jmp    800959 <getuint+0x38>
	else if (lflag)
  800937:	85 d2                	test   %edx,%edx
  800939:	74 10                	je     80094b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80093b:	8b 10                	mov    (%eax),%edx
  80093d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800940:	89 08                	mov    %ecx,(%eax)
  800942:	8b 02                	mov    (%edx),%eax
  800944:	ba 00 00 00 00       	mov    $0x0,%edx
  800949:	eb 0e                	jmp    800959 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80094b:	8b 10                	mov    (%eax),%edx
  80094d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800950:	89 08                	mov    %ecx,(%eax)
  800952:	8b 02                	mov    (%edx),%eax
  800954:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800961:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800964:	8b 10                	mov    (%eax),%edx
  800966:	3b 50 04             	cmp    0x4(%eax),%edx
  800969:	73 0a                	jae    800975 <sprintputch+0x1a>
		*b->buf++ = ch;
  80096b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80096e:	89 08                	mov    %ecx,(%eax)
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	88 02                	mov    %al,(%edx)
}
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80097d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800980:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800984:	8b 45 10             	mov    0x10(%ebp),%eax
  800987:	89 44 24 08          	mov    %eax,0x8(%esp)
  80098b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	89 04 24             	mov    %eax,(%esp)
  800998:	e8 02 00 00 00       	call   80099f <vprintfmt>
	va_end(ap);
}
  80099d:	c9                   	leave  
  80099e:	c3                   	ret    

0080099f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	57                   	push   %edi
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	83 ec 3c             	sub    $0x3c,%esp
  8009a8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8009ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009ae:	eb 14                	jmp    8009c4 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8009b0:	85 c0                	test   %eax,%eax
  8009b2:	0f 84 8a 03 00 00    	je     800d42 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  8009b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009bc:	89 04 24             	mov    %eax,(%esp)
  8009bf:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8009c2:	89 f3                	mov    %esi,%ebx
  8009c4:	8d 73 01             	lea    0x1(%ebx),%esi
  8009c7:	31 c0                	xor    %eax,%eax
  8009c9:	8a 03                	mov    (%ebx),%al
  8009cb:	83 f8 25             	cmp    $0x25,%eax
  8009ce:	75 e0                	jne    8009b0 <vprintfmt+0x11>
  8009d0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8009d4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8009db:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8009e2:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8009e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ee:	eb 1d                	jmp    800a0d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009f0:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8009f2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8009f6:	eb 15                	jmp    800a0d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009f8:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8009fa:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8009fe:	eb 0d                	jmp    800a0d <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800a00:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a03:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a06:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a0d:	8d 5e 01             	lea    0x1(%esi),%ebx
  800a10:	31 c0                	xor    %eax,%eax
  800a12:	8a 06                	mov    (%esi),%al
  800a14:	8a 0e                	mov    (%esi),%cl
  800a16:	83 e9 23             	sub    $0x23,%ecx
  800a19:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800a1c:	80 f9 55             	cmp    $0x55,%cl
  800a1f:	0f 87 ff 02 00 00    	ja     800d24 <vprintfmt+0x385>
  800a25:	31 c9                	xor    %ecx,%ecx
  800a27:	8a 4d e0             	mov    -0x20(%ebp),%cl
  800a2a:	ff 24 8d a0 11 80 00 	jmp    *0x8011a0(,%ecx,4)
  800a31:	89 de                	mov    %ebx,%esi
  800a33:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800a38:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800a3b:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800a3f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800a42:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800a45:	83 fb 09             	cmp    $0x9,%ebx
  800a48:	77 2f                	ja     800a79 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800a4a:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800a4b:	eb eb                	jmp    800a38 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800a4d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a50:	8d 48 04             	lea    0x4(%eax),%ecx
  800a53:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a56:	8b 00                	mov    (%eax),%eax
  800a58:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a5b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800a5d:	eb 1d                	jmp    800a7c <vprintfmt+0xdd>
  800a5f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a62:	f7 d0                	not    %eax
  800a64:	c1 f8 1f             	sar    $0x1f,%eax
  800a67:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a6a:	89 de                	mov    %ebx,%esi
  800a6c:	eb 9f                	jmp    800a0d <vprintfmt+0x6e>
  800a6e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800a70:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800a77:	eb 94                	jmp    800a0d <vprintfmt+0x6e>
  800a79:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800a7c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a80:	79 8b                	jns    800a0d <vprintfmt+0x6e>
  800a82:	e9 79 ff ff ff       	jmp    800a00 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800a87:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a88:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800a8a:	eb 81                	jmp    800a0d <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800a8c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8f:	8d 50 04             	lea    0x4(%eax),%edx
  800a92:	89 55 14             	mov    %edx,0x14(%ebp)
  800a95:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a99:	8b 00                	mov    (%eax),%eax
  800a9b:	89 04 24             	mov    %eax,(%esp)
  800a9e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800aa1:	e9 1e ff ff ff       	jmp    8009c4 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800aa6:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa9:	8d 50 04             	lea    0x4(%eax),%edx
  800aac:	89 55 14             	mov    %edx,0x14(%ebp)
  800aaf:	8b 00                	mov    (%eax),%eax
  800ab1:	89 c2                	mov    %eax,%edx
  800ab3:	c1 fa 1f             	sar    $0x1f,%edx
  800ab6:	31 d0                	xor    %edx,%eax
  800ab8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800aba:	83 f8 09             	cmp    $0x9,%eax
  800abd:	7f 0b                	jg     800aca <vprintfmt+0x12b>
  800abf:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  800ac6:	85 d2                	test   %edx,%edx
  800ac8:	75 20                	jne    800aea <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  800aca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ace:	c7 44 24 08 f6 10 80 	movl   $0x8010f6,0x8(%esp)
  800ad5:	00 
  800ad6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ada:	8b 45 08             	mov    0x8(%ebp),%eax
  800add:	89 04 24             	mov    %eax,(%esp)
  800ae0:	e8 92 fe ff ff       	call   800977 <printfmt>
  800ae5:	e9 da fe ff ff       	jmp    8009c4 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800aea:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800aee:	c7 44 24 08 ff 10 80 	movl   $0x8010ff,0x8(%esp)
  800af5:	00 
  800af6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800afa:	8b 45 08             	mov    0x8(%ebp),%eax
  800afd:	89 04 24             	mov    %eax,(%esp)
  800b00:	e8 72 fe ff ff       	call   800977 <printfmt>
  800b05:	e9 ba fe ff ff       	jmp    8009c4 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b0a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800b0d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b10:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800b13:	8b 45 14             	mov    0x14(%ebp),%eax
  800b16:	8d 50 04             	lea    0x4(%eax),%edx
  800b19:	89 55 14             	mov    %edx,0x14(%ebp)
  800b1c:	8b 30                	mov    (%eax),%esi
  800b1e:	85 f6                	test   %esi,%esi
  800b20:	75 05                	jne    800b27 <vprintfmt+0x188>
				p = "(null)";
  800b22:	be ef 10 80 00       	mov    $0x8010ef,%esi
			if (width > 0 && padc != '-')
  800b27:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800b2b:	0f 84 8c 00 00 00    	je     800bbd <vprintfmt+0x21e>
  800b31:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b35:	0f 8e 8a 00 00 00    	jle    800bc5 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b3b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b3f:	89 34 24             	mov    %esi,(%esp)
  800b42:	e8 9b f5 ff ff       	call   8000e2 <strnlen>
  800b47:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800b4a:	29 c1                	sub    %eax,%ecx
  800b4c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800b4f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800b53:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b56:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800b59:	8b 75 08             	mov    0x8(%ebp),%esi
  800b5c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b5f:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b61:	eb 0d                	jmp    800b70 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800b63:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b67:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b6a:	89 04 24             	mov    %eax,(%esp)
  800b6d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b6f:	4b                   	dec    %ebx
  800b70:	85 db                	test   %ebx,%ebx
  800b72:	7f ef                	jg     800b63 <vprintfmt+0x1c4>
  800b74:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800b77:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b7a:	89 c8                	mov    %ecx,%eax
  800b7c:	f7 d0                	not    %eax
  800b7e:	c1 f8 1f             	sar    $0x1f,%eax
  800b81:	21 c8                	and    %ecx,%eax
  800b83:	29 c1                	sub    %eax,%ecx
  800b85:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b88:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800b8b:	eb 3e                	jmp    800bcb <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b8d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800b91:	74 1b                	je     800bae <vprintfmt+0x20f>
  800b93:	0f be d2             	movsbl %dl,%edx
  800b96:	83 ea 20             	sub    $0x20,%edx
  800b99:	83 fa 5e             	cmp    $0x5e,%edx
  800b9c:	76 10                	jbe    800bae <vprintfmt+0x20f>
					putch('?', putdat);
  800b9e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ba2:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800ba9:	ff 55 08             	call   *0x8(%ebp)
  800bac:	eb 0a                	jmp    800bb8 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800bae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bb2:	89 04 24             	mov    %eax,(%esp)
  800bb5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bb8:	ff 4d dc             	decl   -0x24(%ebp)
  800bbb:	eb 0e                	jmp    800bcb <vprintfmt+0x22c>
  800bbd:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bc0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800bc3:	eb 06                	jmp    800bcb <vprintfmt+0x22c>
  800bc5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bc8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800bcb:	46                   	inc    %esi
  800bcc:	8a 56 ff             	mov    -0x1(%esi),%dl
  800bcf:	0f be c2             	movsbl %dl,%eax
  800bd2:	85 c0                	test   %eax,%eax
  800bd4:	74 1f                	je     800bf5 <vprintfmt+0x256>
  800bd6:	85 db                	test   %ebx,%ebx
  800bd8:	78 b3                	js     800b8d <vprintfmt+0x1ee>
  800bda:	4b                   	dec    %ebx
  800bdb:	79 b0                	jns    800b8d <vprintfmt+0x1ee>
  800bdd:	8b 75 08             	mov    0x8(%ebp),%esi
  800be0:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800be3:	eb 16                	jmp    800bfb <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800be5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800be9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800bf0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800bf2:	4b                   	dec    %ebx
  800bf3:	eb 06                	jmp    800bfb <vprintfmt+0x25c>
  800bf5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800bf8:	8b 75 08             	mov    0x8(%ebp),%esi
  800bfb:	85 db                	test   %ebx,%ebx
  800bfd:	7f e6                	jg     800be5 <vprintfmt+0x246>
  800bff:	89 75 08             	mov    %esi,0x8(%ebp)
  800c02:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c05:	e9 ba fd ff ff       	jmp    8009c4 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c0a:	83 fa 01             	cmp    $0x1,%edx
  800c0d:	7e 16                	jle    800c25 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  800c0f:	8b 45 14             	mov    0x14(%ebp),%eax
  800c12:	8d 50 08             	lea    0x8(%eax),%edx
  800c15:	89 55 14             	mov    %edx,0x14(%ebp)
  800c18:	8b 50 04             	mov    0x4(%eax),%edx
  800c1b:	8b 00                	mov    (%eax),%eax
  800c1d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c20:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c23:	eb 32                	jmp    800c57 <vprintfmt+0x2b8>
	else if (lflag)
  800c25:	85 d2                	test   %edx,%edx
  800c27:	74 18                	je     800c41 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800c29:	8b 45 14             	mov    0x14(%ebp),%eax
  800c2c:	8d 50 04             	lea    0x4(%eax),%edx
  800c2f:	89 55 14             	mov    %edx,0x14(%ebp)
  800c32:	8b 30                	mov    (%eax),%esi
  800c34:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800c37:	89 f0                	mov    %esi,%eax
  800c39:	c1 f8 1f             	sar    $0x1f,%eax
  800c3c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c3f:	eb 16                	jmp    800c57 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800c41:	8b 45 14             	mov    0x14(%ebp),%eax
  800c44:	8d 50 04             	lea    0x4(%eax),%edx
  800c47:	89 55 14             	mov    %edx,0x14(%ebp)
  800c4a:	8b 30                	mov    (%eax),%esi
  800c4c:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800c4f:	89 f0                	mov    %esi,%eax
  800c51:	c1 f8 1f             	sar    $0x1f,%eax
  800c54:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c57:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c5a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800c5d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800c62:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c66:	0f 89 80 00 00 00    	jns    800cec <vprintfmt+0x34d>
				putch('-', putdat);
  800c6c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c70:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800c77:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800c7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c7d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c80:	f7 d8                	neg    %eax
  800c82:	83 d2 00             	adc    $0x0,%edx
  800c85:	f7 da                	neg    %edx
			}
			base = 10;
  800c87:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c8c:	eb 5e                	jmp    800cec <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800c8e:	8d 45 14             	lea    0x14(%ebp),%eax
  800c91:	e8 8b fc ff ff       	call   800921 <getuint>
			base = 10;
  800c96:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800c9b:	eb 4f                	jmp    800cec <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800c9d:	8d 45 14             	lea    0x14(%ebp),%eax
  800ca0:	e8 7c fc ff ff       	call   800921 <getuint>
			base = 8;
  800ca5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800caa:	eb 40                	jmp    800cec <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800cac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cb0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800cb7:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800cba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cbe:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800cc5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800cc8:	8b 45 14             	mov    0x14(%ebp),%eax
  800ccb:	8d 50 04             	lea    0x4(%eax),%edx
  800cce:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800cd1:	8b 00                	mov    (%eax),%eax
  800cd3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800cd8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800cdd:	eb 0d                	jmp    800cec <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800cdf:	8d 45 14             	lea    0x14(%ebp),%eax
  800ce2:	e8 3a fc ff ff       	call   800921 <getuint>
			base = 16;
  800ce7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800cec:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800cf0:	89 74 24 10          	mov    %esi,0x10(%esp)
  800cf4:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800cf7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800cfb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cff:	89 04 24             	mov    %eax,(%esp)
  800d02:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d06:	89 fa                	mov    %edi,%edx
  800d08:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0b:	e8 20 fb ff ff       	call   800830 <printnum>
			break;
  800d10:	e9 af fc ff ff       	jmp    8009c4 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d15:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d19:	89 04 24             	mov    %eax,(%esp)
  800d1c:	ff 55 08             	call   *0x8(%ebp)
			break;
  800d1f:	e9 a0 fc ff ff       	jmp    8009c4 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d24:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d28:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800d2f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d32:	89 f3                	mov    %esi,%ebx
  800d34:	eb 01                	jmp    800d37 <vprintfmt+0x398>
  800d36:	4b                   	dec    %ebx
  800d37:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800d3b:	75 f9                	jne    800d36 <vprintfmt+0x397>
  800d3d:	e9 82 fc ff ff       	jmp    8009c4 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800d42:	83 c4 3c             	add    $0x3c,%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	83 ec 28             	sub    $0x28,%esp
  800d50:	8b 45 08             	mov    0x8(%ebp),%eax
  800d53:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d56:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d59:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d5d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d60:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d67:	85 c0                	test   %eax,%eax
  800d69:	74 30                	je     800d9b <vsnprintf+0x51>
  800d6b:	85 d2                	test   %edx,%edx
  800d6d:	7e 2c                	jle    800d9b <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d6f:	8b 45 14             	mov    0x14(%ebp),%eax
  800d72:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d76:	8b 45 10             	mov    0x10(%ebp),%eax
  800d79:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d7d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d80:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d84:	c7 04 24 5b 09 80 00 	movl   $0x80095b,(%esp)
  800d8b:	e8 0f fc ff ff       	call   80099f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d90:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d93:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d99:	eb 05                	jmp    800da0 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800da0:	c9                   	leave  
  800da1:	c3                   	ret    

00800da2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800da8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800dab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800daf:	8b 45 10             	mov    0x10(%ebp),%eax
  800db2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800db6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc0:	89 04 24             	mov    %eax,(%esp)
  800dc3:	e8 82 ff ff ff       	call   800d4a <vsnprintf>
	va_end(ap);

	return rc;
}
  800dc8:	c9                   	leave  
  800dc9:	c3                   	ret    
  800dca:	66 90                	xchg   %ax,%ax
  800dcc:	66 90                	xchg   %ax,%ax
  800dce:	66 90                	xchg   %ax,%ax

00800dd0 <__udivdi3>:
  800dd0:	55                   	push   %ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	83 ec 0c             	sub    $0xc,%esp
  800dd6:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800dda:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800dde:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800de2:	8b 44 24 28          	mov    0x28(%esp),%eax
  800de6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800dea:	89 ea                	mov    %ebp,%edx
  800dec:	89 0c 24             	mov    %ecx,(%esp)
  800def:	85 c0                	test   %eax,%eax
  800df1:	75 2d                	jne    800e20 <__udivdi3+0x50>
  800df3:	39 e9                	cmp    %ebp,%ecx
  800df5:	77 61                	ja     800e58 <__udivdi3+0x88>
  800df7:	89 ce                	mov    %ecx,%esi
  800df9:	85 c9                	test   %ecx,%ecx
  800dfb:	75 0b                	jne    800e08 <__udivdi3+0x38>
  800dfd:	b8 01 00 00 00       	mov    $0x1,%eax
  800e02:	31 d2                	xor    %edx,%edx
  800e04:	f7 f1                	div    %ecx
  800e06:	89 c6                	mov    %eax,%esi
  800e08:	31 d2                	xor    %edx,%edx
  800e0a:	89 e8                	mov    %ebp,%eax
  800e0c:	f7 f6                	div    %esi
  800e0e:	89 c5                	mov    %eax,%ebp
  800e10:	89 f8                	mov    %edi,%eax
  800e12:	f7 f6                	div    %esi
  800e14:	89 ea                	mov    %ebp,%edx
  800e16:	83 c4 0c             	add    $0xc,%esp
  800e19:	5e                   	pop    %esi
  800e1a:	5f                   	pop    %edi
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    
  800e1d:	8d 76 00             	lea    0x0(%esi),%esi
  800e20:	39 e8                	cmp    %ebp,%eax
  800e22:	77 24                	ja     800e48 <__udivdi3+0x78>
  800e24:	0f bd e8             	bsr    %eax,%ebp
  800e27:	83 f5 1f             	xor    $0x1f,%ebp
  800e2a:	75 3c                	jne    800e68 <__udivdi3+0x98>
  800e2c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e30:	39 34 24             	cmp    %esi,(%esp)
  800e33:	0f 86 9f 00 00 00    	jbe    800ed8 <__udivdi3+0x108>
  800e39:	39 d0                	cmp    %edx,%eax
  800e3b:	0f 82 97 00 00 00    	jb     800ed8 <__udivdi3+0x108>
  800e41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e48:	31 d2                	xor    %edx,%edx
  800e4a:	31 c0                	xor    %eax,%eax
  800e4c:	83 c4 0c             	add    $0xc,%esp
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    
  800e53:	90                   	nop
  800e54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e58:	89 f8                	mov    %edi,%eax
  800e5a:	f7 f1                	div    %ecx
  800e5c:	31 d2                	xor    %edx,%edx
  800e5e:	83 c4 0c             	add    $0xc,%esp
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    
  800e65:	8d 76 00             	lea    0x0(%esi),%esi
  800e68:	89 e9                	mov    %ebp,%ecx
  800e6a:	8b 3c 24             	mov    (%esp),%edi
  800e6d:	d3 e0                	shl    %cl,%eax
  800e6f:	89 c6                	mov    %eax,%esi
  800e71:	b8 20 00 00 00       	mov    $0x20,%eax
  800e76:	29 e8                	sub    %ebp,%eax
  800e78:	88 c1                	mov    %al,%cl
  800e7a:	d3 ef                	shr    %cl,%edi
  800e7c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e80:	89 e9                	mov    %ebp,%ecx
  800e82:	8b 3c 24             	mov    (%esp),%edi
  800e85:	09 74 24 08          	or     %esi,0x8(%esp)
  800e89:	d3 e7                	shl    %cl,%edi
  800e8b:	89 d6                	mov    %edx,%esi
  800e8d:	88 c1                	mov    %al,%cl
  800e8f:	d3 ee                	shr    %cl,%esi
  800e91:	89 e9                	mov    %ebp,%ecx
  800e93:	89 3c 24             	mov    %edi,(%esp)
  800e96:	d3 e2                	shl    %cl,%edx
  800e98:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e9c:	88 c1                	mov    %al,%cl
  800e9e:	d3 ef                	shr    %cl,%edi
  800ea0:	09 d7                	or     %edx,%edi
  800ea2:	89 f2                	mov    %esi,%edx
  800ea4:	89 f8                	mov    %edi,%eax
  800ea6:	f7 74 24 08          	divl   0x8(%esp)
  800eaa:	89 d6                	mov    %edx,%esi
  800eac:	89 c7                	mov    %eax,%edi
  800eae:	f7 24 24             	mull   (%esp)
  800eb1:	89 14 24             	mov    %edx,(%esp)
  800eb4:	39 d6                	cmp    %edx,%esi
  800eb6:	72 30                	jb     800ee8 <__udivdi3+0x118>
  800eb8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ebc:	89 e9                	mov    %ebp,%ecx
  800ebe:	d3 e2                	shl    %cl,%edx
  800ec0:	39 c2                	cmp    %eax,%edx
  800ec2:	73 05                	jae    800ec9 <__udivdi3+0xf9>
  800ec4:	3b 34 24             	cmp    (%esp),%esi
  800ec7:	74 1f                	je     800ee8 <__udivdi3+0x118>
  800ec9:	89 f8                	mov    %edi,%eax
  800ecb:	31 d2                	xor    %edx,%edx
  800ecd:	e9 7a ff ff ff       	jmp    800e4c <__udivdi3+0x7c>
  800ed2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ed8:	31 d2                	xor    %edx,%edx
  800eda:	b8 01 00 00 00       	mov    $0x1,%eax
  800edf:	e9 68 ff ff ff       	jmp    800e4c <__udivdi3+0x7c>
  800ee4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ee8:	8d 47 ff             	lea    -0x1(%edi),%eax
  800eeb:	31 d2                	xor    %edx,%edx
  800eed:	83 c4 0c             	add    $0xc,%esp
  800ef0:	5e                   	pop    %esi
  800ef1:	5f                   	pop    %edi
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    
  800ef4:	66 90                	xchg   %ax,%ax
  800ef6:	66 90                	xchg   %ax,%ax
  800ef8:	66 90                	xchg   %ax,%ax
  800efa:	66 90                	xchg   %ax,%ax
  800efc:	66 90                	xchg   %ax,%ax
  800efe:	66 90                	xchg   %ax,%ax

00800f00 <__umoddi3>:
  800f00:	55                   	push   %ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	83 ec 14             	sub    $0x14,%esp
  800f06:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f0a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f0e:	89 c7                	mov    %eax,%edi
  800f10:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f14:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800f18:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f1c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f20:	89 34 24             	mov    %esi,(%esp)
  800f23:	89 c2                	mov    %eax,%edx
  800f25:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f29:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	75 17                	jne    800f48 <__umoddi3+0x48>
  800f31:	39 fe                	cmp    %edi,%esi
  800f33:	76 4b                	jbe    800f80 <__umoddi3+0x80>
  800f35:	89 c8                	mov    %ecx,%eax
  800f37:	89 fa                	mov    %edi,%edx
  800f39:	f7 f6                	div    %esi
  800f3b:	89 d0                	mov    %edx,%eax
  800f3d:	31 d2                	xor    %edx,%edx
  800f3f:	83 c4 14             	add    $0x14,%esp
  800f42:	5e                   	pop    %esi
  800f43:	5f                   	pop    %edi
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    
  800f46:	66 90                	xchg   %ax,%ax
  800f48:	39 f8                	cmp    %edi,%eax
  800f4a:	77 54                	ja     800fa0 <__umoddi3+0xa0>
  800f4c:	0f bd e8             	bsr    %eax,%ebp
  800f4f:	83 f5 1f             	xor    $0x1f,%ebp
  800f52:	75 5c                	jne    800fb0 <__umoddi3+0xb0>
  800f54:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f58:	39 3c 24             	cmp    %edi,(%esp)
  800f5b:	0f 87 f7 00 00 00    	ja     801058 <__umoddi3+0x158>
  800f61:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f65:	29 f1                	sub    %esi,%ecx
  800f67:	19 c7                	sbb    %eax,%edi
  800f69:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f6d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f71:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f75:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f79:	83 c4 14             	add    $0x14,%esp
  800f7c:	5e                   	pop    %esi
  800f7d:	5f                   	pop    %edi
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    
  800f80:	89 f5                	mov    %esi,%ebp
  800f82:	85 f6                	test   %esi,%esi
  800f84:	75 0b                	jne    800f91 <__umoddi3+0x91>
  800f86:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8b:	31 d2                	xor    %edx,%edx
  800f8d:	f7 f6                	div    %esi
  800f8f:	89 c5                	mov    %eax,%ebp
  800f91:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f95:	31 d2                	xor    %edx,%edx
  800f97:	f7 f5                	div    %ebp
  800f99:	89 c8                	mov    %ecx,%eax
  800f9b:	f7 f5                	div    %ebp
  800f9d:	eb 9c                	jmp    800f3b <__umoddi3+0x3b>
  800f9f:	90                   	nop
  800fa0:	89 c8                	mov    %ecx,%eax
  800fa2:	89 fa                	mov    %edi,%edx
  800fa4:	83 c4 14             	add    $0x14,%esp
  800fa7:	5e                   	pop    %esi
  800fa8:	5f                   	pop    %edi
  800fa9:	5d                   	pop    %ebp
  800faa:	c3                   	ret    
  800fab:	90                   	nop
  800fac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fb0:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800fb7:	00 
  800fb8:	8b 34 24             	mov    (%esp),%esi
  800fbb:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fbf:	89 e9                	mov    %ebp,%ecx
  800fc1:	29 e8                	sub    %ebp,%eax
  800fc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fc7:	89 f0                	mov    %esi,%eax
  800fc9:	d3 e2                	shl    %cl,%edx
  800fcb:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800fcf:	d3 e8                	shr    %cl,%eax
  800fd1:	89 04 24             	mov    %eax,(%esp)
  800fd4:	89 e9                	mov    %ebp,%ecx
  800fd6:	89 f0                	mov    %esi,%eax
  800fd8:	09 14 24             	or     %edx,(%esp)
  800fdb:	d3 e0                	shl    %cl,%eax
  800fdd:	89 fa                	mov    %edi,%edx
  800fdf:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800fe3:	d3 ea                	shr    %cl,%edx
  800fe5:	89 e9                	mov    %ebp,%ecx
  800fe7:	89 c6                	mov    %eax,%esi
  800fe9:	d3 e7                	shl    %cl,%edi
  800feb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fef:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800ff3:	8b 44 24 10          	mov    0x10(%esp),%eax
  800ff7:	d3 e8                	shr    %cl,%eax
  800ff9:	09 f8                	or     %edi,%eax
  800ffb:	89 e9                	mov    %ebp,%ecx
  800ffd:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801001:	d3 e7                	shl    %cl,%edi
  801003:	f7 34 24             	divl   (%esp)
  801006:	89 d1                	mov    %edx,%ecx
  801008:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80100c:	f7 e6                	mul    %esi
  80100e:	89 c7                	mov    %eax,%edi
  801010:	89 d6                	mov    %edx,%esi
  801012:	39 d1                	cmp    %edx,%ecx
  801014:	72 2e                	jb     801044 <__umoddi3+0x144>
  801016:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80101a:	72 24                	jb     801040 <__umoddi3+0x140>
  80101c:	89 ca                	mov    %ecx,%edx
  80101e:	89 e9                	mov    %ebp,%ecx
  801020:	8b 44 24 08          	mov    0x8(%esp),%eax
  801024:	29 f8                	sub    %edi,%eax
  801026:	19 f2                	sbb    %esi,%edx
  801028:	d3 e8                	shr    %cl,%eax
  80102a:	89 d6                	mov    %edx,%esi
  80102c:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801030:	d3 e6                	shl    %cl,%esi
  801032:	89 e9                	mov    %ebp,%ecx
  801034:	09 f0                	or     %esi,%eax
  801036:	d3 ea                	shr    %cl,%edx
  801038:	83 c4 14             	add    $0x14,%esp
  80103b:	5e                   	pop    %esi
  80103c:	5f                   	pop    %edi
  80103d:	5d                   	pop    %ebp
  80103e:	c3                   	ret    
  80103f:	90                   	nop
  801040:	39 d1                	cmp    %edx,%ecx
  801042:	75 d8                	jne    80101c <__umoddi3+0x11c>
  801044:	89 d6                	mov    %edx,%esi
  801046:	89 c7                	mov    %eax,%edi
  801048:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  80104c:	1b 34 24             	sbb    (%esp),%esi
  80104f:	eb cb                	jmp    80101c <__umoddi3+0x11c>
  801051:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801058:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80105c:	0f 82 ff fe ff ff    	jb     800f61 <__umoddi3+0x61>
  801062:	e9 0a ff ff ff       	jmp    800f71 <__umoddi3+0x71>
