
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 34 07 80 	movl   $0x800734,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 1c 06 00 00       	call   80066a <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
  80005a:	66 90                	xchg   %ax,%ax

0080005c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	56                   	push   %esi
  800060:	53                   	push   %ebx
  800061:	83 ec 10             	sub    $0x10,%esp
  800064:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800067:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  80006a:	b8 0c 20 80 00       	mov    $0x80200c,%eax
  80006f:	2d 04 20 80 00       	sub    $0x802004,%eax
  800074:	89 44 24 08          	mov    %eax,0x8(%esp)
  800078:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007f:	00 
  800080:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  800087:	e8 cf 01 00 00       	call   80025b <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  80008c:	e8 4e 04 00 00       	call   8004df <sys_getenvid>
  800091:	25 ff 03 00 00       	and    $0x3ff,%eax
  800096:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80009d:	c1 e0 07             	shl    $0x7,%eax
  8000a0:	29 d0                	sub    %edx,%eax
  8000a2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a7:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ac:	85 db                	test   %ebx,%ebx
  8000ae:	7e 07                	jle    8000b7 <libmain+0x5b>
		binaryname = argv[0];
  8000b0:	8b 06                	mov    (%esi),%eax
  8000b2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000b7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000bb:	89 1c 24             	mov    %ebx,(%esp)
  8000be:	e8 71 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000c3:	e8 08 00 00 00       	call   8000d0 <exit>
}
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	5b                   	pop    %ebx
  8000cc:	5e                   	pop    %esi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    
  8000cf:	90                   	nop

008000d0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000dd:	e8 ab 03 00 00       	call   80048d <sys_env_destroy>
}
  8000e2:	c9                   	leave  
  8000e3:	c3                   	ret    

008000e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8000ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ef:	eb 01                	jmp    8000f2 <strlen+0xe>
		n++;
  8000f1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8000f2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8000f6:	75 f9                	jne    8000f1 <strlen+0xd>
		n++;
	return n;
}
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800100:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800103:	b8 00 00 00 00       	mov    $0x0,%eax
  800108:	eb 01                	jmp    80010b <strnlen+0x11>
		n++;
  80010a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80010b:	39 d0                	cmp    %edx,%eax
  80010d:	74 06                	je     800115 <strnlen+0x1b>
  80010f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800113:	75 f5                	jne    80010a <strnlen+0x10>
		n++;
	return n;
}
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	53                   	push   %ebx
  80011b:	8b 45 08             	mov    0x8(%ebp),%eax
  80011e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800121:	89 c2                	mov    %eax,%edx
  800123:	42                   	inc    %edx
  800124:	41                   	inc    %ecx
  800125:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800128:	88 5a ff             	mov    %bl,-0x1(%edx)
  80012b:	84 db                	test   %bl,%bl
  80012d:	75 f4                	jne    800123 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80012f:	5b                   	pop    %ebx
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	53                   	push   %ebx
  800136:	83 ec 08             	sub    $0x8,%esp
  800139:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80013c:	89 1c 24             	mov    %ebx,(%esp)
  80013f:	e8 a0 ff ff ff       	call   8000e4 <strlen>
	strcpy(dst + len, src);
  800144:	8b 55 0c             	mov    0xc(%ebp),%edx
  800147:	89 54 24 04          	mov    %edx,0x4(%esp)
  80014b:	01 d8                	add    %ebx,%eax
  80014d:	89 04 24             	mov    %eax,(%esp)
  800150:	e8 c2 ff ff ff       	call   800117 <strcpy>
	return dst;
}
  800155:	89 d8                	mov    %ebx,%eax
  800157:	83 c4 08             	add    $0x8,%esp
  80015a:	5b                   	pop    %ebx
  80015b:	5d                   	pop    %ebp
  80015c:	c3                   	ret    

0080015d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	56                   	push   %esi
  800161:	53                   	push   %ebx
  800162:	8b 75 08             	mov    0x8(%ebp),%esi
  800165:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800168:	89 f3                	mov    %esi,%ebx
  80016a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80016d:	89 f2                	mov    %esi,%edx
  80016f:	eb 0c                	jmp    80017d <strncpy+0x20>
		*dst++ = *src;
  800171:	42                   	inc    %edx
  800172:	8a 01                	mov    (%ecx),%al
  800174:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800177:	80 39 01             	cmpb   $0x1,(%ecx)
  80017a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80017d:	39 da                	cmp    %ebx,%edx
  80017f:	75 f0                	jne    800171 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800181:	89 f0                	mov    %esi,%eax
  800183:	5b                   	pop    %ebx
  800184:	5e                   	pop    %esi
  800185:	5d                   	pop    %ebp
  800186:	c3                   	ret    

00800187 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	56                   	push   %esi
  80018b:	53                   	push   %ebx
  80018c:	8b 75 08             	mov    0x8(%ebp),%esi
  80018f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800192:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800195:	89 f0                	mov    %esi,%eax
  800197:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80019b:	85 c9                	test   %ecx,%ecx
  80019d:	75 07                	jne    8001a6 <strlcpy+0x1f>
  80019f:	eb 18                	jmp    8001b9 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8001a1:	40                   	inc    %eax
  8001a2:	42                   	inc    %edx
  8001a3:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8001a6:	39 d8                	cmp    %ebx,%eax
  8001a8:	74 0a                	je     8001b4 <strlcpy+0x2d>
  8001aa:	8a 0a                	mov    (%edx),%cl
  8001ac:	84 c9                	test   %cl,%cl
  8001ae:	75 f1                	jne    8001a1 <strlcpy+0x1a>
  8001b0:	89 c2                	mov    %eax,%edx
  8001b2:	eb 02                	jmp    8001b6 <strlcpy+0x2f>
  8001b4:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8001b6:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8001b9:	29 f0                	sub    %esi,%eax
}
  8001bb:	5b                   	pop    %ebx
  8001bc:	5e                   	pop    %esi
  8001bd:	5d                   	pop    %ebp
  8001be:	c3                   	ret    

008001bf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8001bf:	55                   	push   %ebp
  8001c0:	89 e5                	mov    %esp,%ebp
  8001c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8001c8:	eb 02                	jmp    8001cc <strcmp+0xd>
		p++, q++;
  8001ca:	41                   	inc    %ecx
  8001cb:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8001cc:	8a 01                	mov    (%ecx),%al
  8001ce:	84 c0                	test   %al,%al
  8001d0:	74 04                	je     8001d6 <strcmp+0x17>
  8001d2:	3a 02                	cmp    (%edx),%al
  8001d4:	74 f4                	je     8001ca <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8001d6:	25 ff 00 00 00       	and    $0xff,%eax
  8001db:	8a 0a                	mov    (%edx),%cl
  8001dd:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8001e3:	29 c8                	sub    %ecx,%eax
}
  8001e5:	5d                   	pop    %ebp
  8001e6:	c3                   	ret    

008001e7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	53                   	push   %ebx
  8001eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f1:	89 c3                	mov    %eax,%ebx
  8001f3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8001f6:	eb 02                	jmp    8001fa <strncmp+0x13>
		n--, p++, q++;
  8001f8:	40                   	inc    %eax
  8001f9:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8001fa:	39 d8                	cmp    %ebx,%eax
  8001fc:	74 20                	je     80021e <strncmp+0x37>
  8001fe:	8a 08                	mov    (%eax),%cl
  800200:	84 c9                	test   %cl,%cl
  800202:	74 04                	je     800208 <strncmp+0x21>
  800204:	3a 0a                	cmp    (%edx),%cl
  800206:	74 f0                	je     8001f8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800208:	8a 18                	mov    (%eax),%bl
  80020a:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800210:	89 d8                	mov    %ebx,%eax
  800212:	8a 1a                	mov    (%edx),%bl
  800214:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80021a:	29 d8                	sub    %ebx,%eax
  80021c:	eb 05                	jmp    800223 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80021e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800223:	5b                   	pop    %ebx
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	8b 45 08             	mov    0x8(%ebp),%eax
  80022c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80022f:	eb 05                	jmp    800236 <strchr+0x10>
		if (*s == c)
  800231:	38 ca                	cmp    %cl,%dl
  800233:	74 0c                	je     800241 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800235:	40                   	inc    %eax
  800236:	8a 10                	mov    (%eax),%dl
  800238:	84 d2                	test   %dl,%dl
  80023a:	75 f5                	jne    800231 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80023c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800241:	5d                   	pop    %ebp
  800242:	c3                   	ret    

00800243 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	8b 45 08             	mov    0x8(%ebp),%eax
  800249:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80024c:	eb 05                	jmp    800253 <strfind+0x10>
		if (*s == c)
  80024e:	38 ca                	cmp    %cl,%dl
  800250:	74 07                	je     800259 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800252:	40                   	inc    %eax
  800253:	8a 10                	mov    (%eax),%dl
  800255:	84 d2                	test   %dl,%dl
  800257:	75 f5                	jne    80024e <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    

0080025b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	57                   	push   %edi
  80025f:	56                   	push   %esi
  800260:	53                   	push   %ebx
  800261:	8b 7d 08             	mov    0x8(%ebp),%edi
  800264:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800267:	85 c9                	test   %ecx,%ecx
  800269:	74 37                	je     8002a2 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80026b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800271:	75 29                	jne    80029c <memset+0x41>
  800273:	f6 c1 03             	test   $0x3,%cl
  800276:	75 24                	jne    80029c <memset+0x41>
		c &= 0xFF;
  800278:	31 d2                	xor    %edx,%edx
  80027a:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80027d:	89 d3                	mov    %edx,%ebx
  80027f:	c1 e3 08             	shl    $0x8,%ebx
  800282:	89 d6                	mov    %edx,%esi
  800284:	c1 e6 18             	shl    $0x18,%esi
  800287:	89 d0                	mov    %edx,%eax
  800289:	c1 e0 10             	shl    $0x10,%eax
  80028c:	09 f0                	or     %esi,%eax
  80028e:	09 c2                	or     %eax,%edx
  800290:	89 d0                	mov    %edx,%eax
  800292:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800294:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800297:	fc                   	cld    
  800298:	f3 ab                	rep stos %eax,%es:(%edi)
  80029a:	eb 06                	jmp    8002a2 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80029c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029f:	fc                   	cld    
  8002a0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8002a2:	89 f8                	mov    %edi,%eax
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8002b7:	39 c6                	cmp    %eax,%esi
  8002b9:	73 33                	jae    8002ee <memmove+0x45>
  8002bb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8002be:	39 d0                	cmp    %edx,%eax
  8002c0:	73 2c                	jae    8002ee <memmove+0x45>
		s += n;
		d += n;
  8002c2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8002c5:	89 d6                	mov    %edx,%esi
  8002c7:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8002c9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8002cf:	75 13                	jne    8002e4 <memmove+0x3b>
  8002d1:	f6 c1 03             	test   $0x3,%cl
  8002d4:	75 0e                	jne    8002e4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8002d6:	83 ef 04             	sub    $0x4,%edi
  8002d9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8002dc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8002df:	fd                   	std    
  8002e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8002e2:	eb 07                	jmp    8002eb <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8002e4:	4f                   	dec    %edi
  8002e5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8002e8:	fd                   	std    
  8002e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8002eb:	fc                   	cld    
  8002ec:	eb 1d                	jmp    80030b <memmove+0x62>
  8002ee:	89 f2                	mov    %esi,%edx
  8002f0:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8002f2:	f6 c2 03             	test   $0x3,%dl
  8002f5:	75 0f                	jne    800306 <memmove+0x5d>
  8002f7:	f6 c1 03             	test   $0x3,%cl
  8002fa:	75 0a                	jne    800306 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8002fc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8002ff:	89 c7                	mov    %eax,%edi
  800301:	fc                   	cld    
  800302:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800304:	eb 05                	jmp    80030b <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800306:	89 c7                	mov    %eax,%edi
  800308:	fc                   	cld    
  800309:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80030b:	5e                   	pop    %esi
  80030c:	5f                   	pop    %edi
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800315:	8b 45 10             	mov    0x10(%ebp),%eax
  800318:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80031f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800323:	8b 45 08             	mov    0x8(%ebp),%eax
  800326:	89 04 24             	mov    %eax,(%esp)
  800329:	e8 7b ff ff ff       	call   8002a9 <memmove>
}
  80032e:	c9                   	leave  
  80032f:	c3                   	ret    

00800330 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	56                   	push   %esi
  800334:	53                   	push   %ebx
  800335:	8b 55 08             	mov    0x8(%ebp),%edx
  800338:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033b:	89 d6                	mov    %edx,%esi
  80033d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800340:	eb 19                	jmp    80035b <memcmp+0x2b>
		if (*s1 != *s2)
  800342:	8a 02                	mov    (%edx),%al
  800344:	8a 19                	mov    (%ecx),%bl
  800346:	38 d8                	cmp    %bl,%al
  800348:	74 0f                	je     800359 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  80034a:	25 ff 00 00 00       	and    $0xff,%eax
  80034f:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800355:	29 d8                	sub    %ebx,%eax
  800357:	eb 0b                	jmp    800364 <memcmp+0x34>
		s1++, s2++;
  800359:	42                   	inc    %edx
  80035a:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80035b:	39 f2                	cmp    %esi,%edx
  80035d:	75 e3                	jne    800342 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80035f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800364:	5b                   	pop    %ebx
  800365:	5e                   	pop    %esi
  800366:	5d                   	pop    %ebp
  800367:	c3                   	ret    

00800368 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	8b 45 08             	mov    0x8(%ebp),%eax
  80036e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800371:	89 c2                	mov    %eax,%edx
  800373:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800376:	eb 05                	jmp    80037d <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800378:	38 08                	cmp    %cl,(%eax)
  80037a:	74 05                	je     800381 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80037c:	40                   	inc    %eax
  80037d:	39 d0                	cmp    %edx,%eax
  80037f:	72 f7                	jb     800378 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800381:	5d                   	pop    %ebp
  800382:	c3                   	ret    

00800383 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	57                   	push   %edi
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	8b 55 08             	mov    0x8(%ebp),%edx
  80038c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80038f:	eb 01                	jmp    800392 <strtol+0xf>
		s++;
  800391:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800392:	8a 02                	mov    (%edx),%al
  800394:	3c 09                	cmp    $0x9,%al
  800396:	74 f9                	je     800391 <strtol+0xe>
  800398:	3c 20                	cmp    $0x20,%al
  80039a:	74 f5                	je     800391 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80039c:	3c 2b                	cmp    $0x2b,%al
  80039e:	75 08                	jne    8003a8 <strtol+0x25>
		s++;
  8003a0:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8003a1:	bf 00 00 00 00       	mov    $0x0,%edi
  8003a6:	eb 10                	jmp    8003b8 <strtol+0x35>
  8003a8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8003ad:	3c 2d                	cmp    $0x2d,%al
  8003af:	75 07                	jne    8003b8 <strtol+0x35>
		s++, neg = 1;
  8003b1:	8d 52 01             	lea    0x1(%edx),%edx
  8003b4:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8003b8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8003be:	75 15                	jne    8003d5 <strtol+0x52>
  8003c0:	80 3a 30             	cmpb   $0x30,(%edx)
  8003c3:	75 10                	jne    8003d5 <strtol+0x52>
  8003c5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8003c9:	75 0a                	jne    8003d5 <strtol+0x52>
		s += 2, base = 16;
  8003cb:	83 c2 02             	add    $0x2,%edx
  8003ce:	bb 10 00 00 00       	mov    $0x10,%ebx
  8003d3:	eb 0e                	jmp    8003e3 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  8003d5:	85 db                	test   %ebx,%ebx
  8003d7:	75 0a                	jne    8003e3 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8003d9:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8003db:	80 3a 30             	cmpb   $0x30,(%edx)
  8003de:	75 03                	jne    8003e3 <strtol+0x60>
		s++, base = 8;
  8003e0:	42                   	inc    %edx
  8003e1:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  8003e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8003eb:	8a 0a                	mov    (%edx),%cl
  8003ed:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8003f0:	89 f3                	mov    %esi,%ebx
  8003f2:	80 fb 09             	cmp    $0x9,%bl
  8003f5:	77 08                	ja     8003ff <strtol+0x7c>
			dig = *s - '0';
  8003f7:	0f be c9             	movsbl %cl,%ecx
  8003fa:	83 e9 30             	sub    $0x30,%ecx
  8003fd:	eb 22                	jmp    800421 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  8003ff:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800402:	89 f3                	mov    %esi,%ebx
  800404:	80 fb 19             	cmp    $0x19,%bl
  800407:	77 08                	ja     800411 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800409:	0f be c9             	movsbl %cl,%ecx
  80040c:	83 e9 57             	sub    $0x57,%ecx
  80040f:	eb 10                	jmp    800421 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800411:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800414:	89 f3                	mov    %esi,%ebx
  800416:	80 fb 19             	cmp    $0x19,%bl
  800419:	77 14                	ja     80042f <strtol+0xac>
			dig = *s - 'A' + 10;
  80041b:	0f be c9             	movsbl %cl,%ecx
  80041e:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800421:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800424:	7d 0d                	jge    800433 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800426:	42                   	inc    %edx
  800427:	0f af 45 10          	imul   0x10(%ebp),%eax
  80042b:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80042d:	eb bc                	jmp    8003eb <strtol+0x68>
  80042f:	89 c1                	mov    %eax,%ecx
  800431:	eb 02                	jmp    800435 <strtol+0xb2>
  800433:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800435:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800439:	74 05                	je     800440 <strtol+0xbd>
		*endptr = (char *) s;
  80043b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80043e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800440:	85 ff                	test   %edi,%edi
  800442:	74 04                	je     800448 <strtol+0xc5>
  800444:	89 c8                	mov    %ecx,%eax
  800446:	f7 d8                	neg    %eax
}
  800448:	5b                   	pop    %ebx
  800449:	5e                   	pop    %esi
  80044a:	5f                   	pop    %edi
  80044b:	5d                   	pop    %ebp
  80044c:	c3                   	ret    
  80044d:	66 90                	xchg   %ax,%ax
  80044f:	90                   	nop

00800450 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
  800453:	57                   	push   %edi
  800454:	56                   	push   %esi
  800455:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800456:	b8 00 00 00 00       	mov    $0x0,%eax
  80045b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80045e:	8b 55 08             	mov    0x8(%ebp),%edx
  800461:	89 c3                	mov    %eax,%ebx
  800463:	89 c7                	mov    %eax,%edi
  800465:	89 c6                	mov    %eax,%esi
  800467:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800469:	5b                   	pop    %ebx
  80046a:	5e                   	pop    %esi
  80046b:	5f                   	pop    %edi
  80046c:	5d                   	pop    %ebp
  80046d:	c3                   	ret    

0080046e <sys_cgetc>:

int
sys_cgetc(void)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	57                   	push   %edi
  800472:	56                   	push   %esi
  800473:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800474:	ba 00 00 00 00       	mov    $0x0,%edx
  800479:	b8 01 00 00 00       	mov    $0x1,%eax
  80047e:	89 d1                	mov    %edx,%ecx
  800480:	89 d3                	mov    %edx,%ebx
  800482:	89 d7                	mov    %edx,%edi
  800484:	89 d6                	mov    %edx,%esi
  800486:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800488:	5b                   	pop    %ebx
  800489:	5e                   	pop    %esi
  80048a:	5f                   	pop    %edi
  80048b:	5d                   	pop    %ebp
  80048c:	c3                   	ret    

0080048d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80048d:	55                   	push   %ebp
  80048e:	89 e5                	mov    %esp,%ebp
  800490:	57                   	push   %edi
  800491:	56                   	push   %esi
  800492:	53                   	push   %ebx
  800493:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800496:	b9 00 00 00 00       	mov    $0x0,%ecx
  80049b:	b8 03 00 00 00       	mov    $0x3,%eax
  8004a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a3:	89 cb                	mov    %ecx,%ebx
  8004a5:	89 cf                	mov    %ecx,%edi
  8004a7:	89 ce                	mov    %ecx,%esi
  8004a9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	7e 28                	jle    8004d7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004af:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004b3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8004ba:	00 
  8004bb:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  8004c2:	00 
  8004c3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004ca:	00 
  8004cb:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  8004d2:	e8 a1 02 00 00       	call   800778 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8004d7:	83 c4 2c             	add    $0x2c,%esp
  8004da:	5b                   	pop    %ebx
  8004db:	5e                   	pop    %esi
  8004dc:	5f                   	pop    %edi
  8004dd:	5d                   	pop    %ebp
  8004de:	c3                   	ret    

008004df <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8004df:	55                   	push   %ebp
  8004e0:	89 e5                	mov    %esp,%ebp
  8004e2:	57                   	push   %edi
  8004e3:	56                   	push   %esi
  8004e4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ea:	b8 02 00 00 00       	mov    $0x2,%eax
  8004ef:	89 d1                	mov    %edx,%ecx
  8004f1:	89 d3                	mov    %edx,%ebx
  8004f3:	89 d7                	mov    %edx,%edi
  8004f5:	89 d6                	mov    %edx,%esi
  8004f7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8004f9:	5b                   	pop    %ebx
  8004fa:	5e                   	pop    %esi
  8004fb:	5f                   	pop    %edi
  8004fc:	5d                   	pop    %ebp
  8004fd:	c3                   	ret    

008004fe <sys_yield>:

void
sys_yield(void)
{
  8004fe:	55                   	push   %ebp
  8004ff:	89 e5                	mov    %esp,%ebp
  800501:	57                   	push   %edi
  800502:	56                   	push   %esi
  800503:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800504:	ba 00 00 00 00       	mov    $0x0,%edx
  800509:	b8 0a 00 00 00       	mov    $0xa,%eax
  80050e:	89 d1                	mov    %edx,%ecx
  800510:	89 d3                	mov    %edx,%ebx
  800512:	89 d7                	mov    %edx,%edi
  800514:	89 d6                	mov    %edx,%esi
  800516:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800518:	5b                   	pop    %ebx
  800519:	5e                   	pop    %esi
  80051a:	5f                   	pop    %edi
  80051b:	5d                   	pop    %ebp
  80051c:	c3                   	ret    

0080051d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	57                   	push   %edi
  800521:	56                   	push   %esi
  800522:	53                   	push   %ebx
  800523:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800526:	be 00 00 00 00       	mov    $0x0,%esi
  80052b:	b8 04 00 00 00       	mov    $0x4,%eax
  800530:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800533:	8b 55 08             	mov    0x8(%ebp),%edx
  800536:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800539:	89 f7                	mov    %esi,%edi
  80053b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80053d:	85 c0                	test   %eax,%eax
  80053f:	7e 28                	jle    800569 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800541:	89 44 24 10          	mov    %eax,0x10(%esp)
  800545:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80054c:	00 
  80054d:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  800554:	00 
  800555:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80055c:	00 
  80055d:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  800564:	e8 0f 02 00 00       	call   800778 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800569:	83 c4 2c             	add    $0x2c,%esp
  80056c:	5b                   	pop    %ebx
  80056d:	5e                   	pop    %esi
  80056e:	5f                   	pop    %edi
  80056f:	5d                   	pop    %ebp
  800570:	c3                   	ret    

00800571 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800571:	55                   	push   %ebp
  800572:	89 e5                	mov    %esp,%ebp
  800574:	57                   	push   %edi
  800575:	56                   	push   %esi
  800576:	53                   	push   %ebx
  800577:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80057a:	b8 05 00 00 00       	mov    $0x5,%eax
  80057f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800582:	8b 55 08             	mov    0x8(%ebp),%edx
  800585:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800588:	8b 7d 14             	mov    0x14(%ebp),%edi
  80058b:	8b 75 18             	mov    0x18(%ebp),%esi
  80058e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800590:	85 c0                	test   %eax,%eax
  800592:	7e 28                	jle    8005bc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800594:	89 44 24 10          	mov    %eax,0x10(%esp)
  800598:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80059f:	00 
  8005a0:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  8005a7:	00 
  8005a8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005af:	00 
  8005b0:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  8005b7:	e8 bc 01 00 00       	call   800778 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8005bc:	83 c4 2c             	add    $0x2c,%esp
  8005bf:	5b                   	pop    %ebx
  8005c0:	5e                   	pop    %esi
  8005c1:	5f                   	pop    %edi
  8005c2:	5d                   	pop    %ebp
  8005c3:	c3                   	ret    

008005c4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8005c4:	55                   	push   %ebp
  8005c5:	89 e5                	mov    %esp,%ebp
  8005c7:	57                   	push   %edi
  8005c8:	56                   	push   %esi
  8005c9:	53                   	push   %ebx
  8005ca:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005d2:	b8 06 00 00 00       	mov    $0x6,%eax
  8005d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005da:	8b 55 08             	mov    0x8(%ebp),%edx
  8005dd:	89 df                	mov    %ebx,%edi
  8005df:	89 de                	mov    %ebx,%esi
  8005e1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005e3:	85 c0                	test   %eax,%eax
  8005e5:	7e 28                	jle    80060f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005eb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8005f2:	00 
  8005f3:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  8005fa:	00 
  8005fb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800602:	00 
  800603:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  80060a:	e8 69 01 00 00       	call   800778 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80060f:	83 c4 2c             	add    $0x2c,%esp
  800612:	5b                   	pop    %ebx
  800613:	5e                   	pop    %esi
  800614:	5f                   	pop    %edi
  800615:	5d                   	pop    %ebp
  800616:	c3                   	ret    

00800617 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800617:	55                   	push   %ebp
  800618:	89 e5                	mov    %esp,%ebp
  80061a:	57                   	push   %edi
  80061b:	56                   	push   %esi
  80061c:	53                   	push   %ebx
  80061d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800620:	bb 00 00 00 00       	mov    $0x0,%ebx
  800625:	b8 08 00 00 00       	mov    $0x8,%eax
  80062a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80062d:	8b 55 08             	mov    0x8(%ebp),%edx
  800630:	89 df                	mov    %ebx,%edi
  800632:	89 de                	mov    %ebx,%esi
  800634:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800636:	85 c0                	test   %eax,%eax
  800638:	7e 28                	jle    800662 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80063a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80063e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800645:	00 
  800646:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  80064d:	00 
  80064e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800655:	00 
  800656:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  80065d:	e8 16 01 00 00       	call   800778 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800662:	83 c4 2c             	add    $0x2c,%esp
  800665:	5b                   	pop    %ebx
  800666:	5e                   	pop    %esi
  800667:	5f                   	pop    %edi
  800668:	5d                   	pop    %ebp
  800669:	c3                   	ret    

0080066a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80066a:	55                   	push   %ebp
  80066b:	89 e5                	mov    %esp,%ebp
  80066d:	57                   	push   %edi
  80066e:	56                   	push   %esi
  80066f:	53                   	push   %ebx
  800670:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800673:	bb 00 00 00 00       	mov    $0x0,%ebx
  800678:	b8 09 00 00 00       	mov    $0x9,%eax
  80067d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800680:	8b 55 08             	mov    0x8(%ebp),%edx
  800683:	89 df                	mov    %ebx,%edi
  800685:	89 de                	mov    %ebx,%esi
  800687:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800689:	85 c0                	test   %eax,%eax
  80068b:	7e 28                	jle    8006b5 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80068d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800691:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800698:	00 
  800699:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  8006a0:	00 
  8006a1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8006a8:	00 
  8006a9:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  8006b0:	e8 c3 00 00 00       	call   800778 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8006b5:	83 c4 2c             	add    $0x2c,%esp
  8006b8:	5b                   	pop    %ebx
  8006b9:	5e                   	pop    %esi
  8006ba:	5f                   	pop    %edi
  8006bb:	5d                   	pop    %ebp
  8006bc:	c3                   	ret    

008006bd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	57                   	push   %edi
  8006c1:	56                   	push   %esi
  8006c2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006c3:	be 00 00 00 00       	mov    $0x0,%esi
  8006c8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8006cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006d6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8006d9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8006db:	5b                   	pop    %ebx
  8006dc:	5e                   	pop    %esi
  8006dd:	5f                   	pop    %edi
  8006de:	5d                   	pop    %ebp
  8006df:	c3                   	ret    

008006e0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	57                   	push   %edi
  8006e4:	56                   	push   %esi
  8006e5:	53                   	push   %ebx
  8006e6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  8006f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f6:	89 cb                	mov    %ecx,%ebx
  8006f8:	89 cf                	mov    %ecx,%edi
  8006fa:	89 ce                	mov    %ecx,%esi
  8006fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006fe:	85 c0                	test   %eax,%eax
  800700:	7e 28                	jle    80072a <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800702:	89 44 24 10          	mov    %eax,0x10(%esp)
  800706:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80070d:	00 
  80070e:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  800715:	00 
  800716:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80071d:	00 
  80071e:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  800725:	e8 4e 00 00 00       	call   800778 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80072a:	83 c4 2c             	add    $0x2c,%esp
  80072d:	5b                   	pop    %ebx
  80072e:	5e                   	pop    %esi
  80072f:	5f                   	pop    %edi
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    
  800732:	66 90                	xchg   %ax,%ax

00800734 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800734:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800735:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80073a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80073c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here. 
	movl 0x28(%esp), %eax
  80073f:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp), %ebx
  800743:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, -0x4(%ebx)
  800747:	89 43 fc             	mov    %eax,-0x4(%ebx)
	subl $0x4, %ebx
  80074a:	83 eb 04             	sub    $0x4,%ebx
  movl %ebx, 0x30(%esp)
  80074d:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x08(%esp), %edi
  800751:	8b 7c 24 08          	mov    0x8(%esp),%edi
	movl 0x0c(%esp), %esi
  800755:	8b 74 24 0c          	mov    0xc(%esp),%esi
	movl 0x10(%esp), %ebp
  800759:	8b 6c 24 10          	mov    0x10(%esp),%ebp
	#movl 0x14(%esp), %oesp
	movl 0x18(%esp), %ebx
  80075d:	8b 5c 24 18          	mov    0x18(%esp),%ebx
	movl 0x1c(%esp), %edx
  800761:	8b 54 24 1c          	mov    0x1c(%esp),%edx
	movl 0x20(%esp), %ecx
  800765:	8b 4c 24 20          	mov    0x20(%esp),%ecx
	movl 0x24(%esp), %eax
  800769:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	pushl 0x2c(%esp)
  80076d:	ff 74 24 2c          	pushl  0x2c(%esp)
	popfl
  800771:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl 0x30(%esp), %esp
  800772:	8b 64 24 30          	mov    0x30(%esp),%esp
  
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800776:	c3                   	ret    
  800777:	90                   	nop

00800778 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	56                   	push   %esi
  80077c:	53                   	push   %ebx
  80077d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800780:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800783:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800789:	e8 51 fd ff ff       	call   8004df <sys_getenvid>
  80078e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800791:	89 54 24 10          	mov    %edx,0x10(%esp)
  800795:	8b 55 08             	mov    0x8(%ebp),%edx
  800798:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80079c:	89 74 24 08          	mov    %esi,0x8(%esp)
  8007a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a4:	c7 04 24 58 11 80 00 	movl   $0x801158,(%esp)
  8007ab:	e8 c2 00 00 00       	call   800872 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8007b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b7:	89 04 24             	mov    %eax,(%esp)
  8007ba:	e8 52 00 00 00       	call   800811 <vcprintf>
	cprintf("\n");
  8007bf:	c7 04 24 7c 11 80 00 	movl   $0x80117c,(%esp)
  8007c6:	e8 a7 00 00 00       	call   800872 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8007cb:	cc                   	int3   
  8007cc:	eb fd                	jmp    8007cb <_panic+0x53>
  8007ce:	66 90                	xchg   %ax,%ax

008007d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	53                   	push   %ebx
  8007d4:	83 ec 14             	sub    $0x14,%esp
  8007d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8007da:	8b 13                	mov    (%ebx),%edx
  8007dc:	8d 42 01             	lea    0x1(%edx),%eax
  8007df:	89 03                	mov    %eax,(%ebx)
  8007e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8007e8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8007ed:	75 19                	jne    800808 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8007ef:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8007f6:	00 
  8007f7:	8d 43 08             	lea    0x8(%ebx),%eax
  8007fa:	89 04 24             	mov    %eax,(%esp)
  8007fd:	e8 4e fc ff ff       	call   800450 <sys_cputs>
		b->idx = 0;
  800802:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800808:	ff 43 04             	incl   0x4(%ebx)
}
  80080b:	83 c4 14             	add    $0x14,%esp
  80080e:	5b                   	pop    %ebx
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80081a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800821:	00 00 00 
	b.cnt = 0;
  800824:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80082b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80082e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800831:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800835:	8b 45 08             	mov    0x8(%ebp),%eax
  800838:	89 44 24 08          	mov    %eax,0x8(%esp)
  80083c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800842:	89 44 24 04          	mov    %eax,0x4(%esp)
  800846:	c7 04 24 d0 07 80 00 	movl   $0x8007d0,(%esp)
  80084d:	e8 a9 01 00 00       	call   8009fb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800852:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800858:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800862:	89 04 24             	mov    %eax,(%esp)
  800865:	e8 e6 fb ff ff       	call   800450 <sys_cputs>

	return b.cnt;
}
  80086a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800870:	c9                   	leave  
  800871:	c3                   	ret    

00800872 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800878:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80087b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	89 04 24             	mov    %eax,(%esp)
  800885:	e8 87 ff ff ff       	call   800811 <vcprintf>
	va_end(ap);

	return cnt;
}
  80088a:	c9                   	leave  
  80088b:	c3                   	ret    

0080088c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	57                   	push   %edi
  800890:	56                   	push   %esi
  800891:	53                   	push   %ebx
  800892:	83 ec 3c             	sub    $0x3c,%esp
  800895:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800898:	89 d7                	mov    %edx,%edi
  80089a:	8b 45 08             	mov    0x8(%ebp),%eax
  80089d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a3:	89 c1                	mov    %eax,%ecx
  8008a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8008a8:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8008ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8008b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008b9:	39 ca                	cmp    %ecx,%edx
  8008bb:	72 08                	jb     8008c5 <printnum+0x39>
  8008bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008c0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8008c3:	77 6a                	ja     80092f <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8008c5:	8b 45 18             	mov    0x18(%ebp),%eax
  8008c8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8008cc:	4e                   	dec    %esi
  8008cd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8008d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008d8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8008dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8008e0:	89 c3                	mov    %eax,%ebx
  8008e2:	89 d6                	mov    %edx,%esi
  8008e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ee:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008f5:	89 04 24             	mov    %eax,(%esp)
  8008f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8008fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ff:	e8 7c 05 00 00       	call   800e80 <__udivdi3>
  800904:	89 d9                	mov    %ebx,%ecx
  800906:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80090a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80090e:	89 04 24             	mov    %eax,(%esp)
  800911:	89 54 24 04          	mov    %edx,0x4(%esp)
  800915:	89 fa                	mov    %edi,%edx
  800917:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80091a:	e8 6d ff ff ff       	call   80088c <printnum>
  80091f:	eb 19                	jmp    80093a <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800921:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800925:	8b 45 18             	mov    0x18(%ebp),%eax
  800928:	89 04 24             	mov    %eax,(%esp)
  80092b:	ff d3                	call   *%ebx
  80092d:	eb 03                	jmp    800932 <printnum+0xa6>
  80092f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800932:	4e                   	dec    %esi
  800933:	85 f6                	test   %esi,%esi
  800935:	7f ea                	jg     800921 <printnum+0x95>
  800937:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80093a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80093e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800942:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800945:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800948:	89 44 24 08          	mov    %eax,0x8(%esp)
  80094c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800950:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800953:	89 04 24             	mov    %eax,(%esp)
  800956:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800959:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095d:	e8 4e 06 00 00       	call   800fb0 <__umoddi3>
  800962:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800966:	0f be 80 7e 11 80 00 	movsbl 0x80117e(%eax),%eax
  80096d:	89 04 24             	mov    %eax,(%esp)
  800970:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800973:	ff d0                	call   *%eax
}
  800975:	83 c4 3c             	add    $0x3c,%esp
  800978:	5b                   	pop    %ebx
  800979:	5e                   	pop    %esi
  80097a:	5f                   	pop    %edi
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    

0080097d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800980:	83 fa 01             	cmp    $0x1,%edx
  800983:	7e 0e                	jle    800993 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800985:	8b 10                	mov    (%eax),%edx
  800987:	8d 4a 08             	lea    0x8(%edx),%ecx
  80098a:	89 08                	mov    %ecx,(%eax)
  80098c:	8b 02                	mov    (%edx),%eax
  80098e:	8b 52 04             	mov    0x4(%edx),%edx
  800991:	eb 22                	jmp    8009b5 <getuint+0x38>
	else if (lflag)
  800993:	85 d2                	test   %edx,%edx
  800995:	74 10                	je     8009a7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800997:	8b 10                	mov    (%eax),%edx
  800999:	8d 4a 04             	lea    0x4(%edx),%ecx
  80099c:	89 08                	mov    %ecx,(%eax)
  80099e:	8b 02                	mov    (%edx),%eax
  8009a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a5:	eb 0e                	jmp    8009b5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8009a7:	8b 10                	mov    (%eax),%edx
  8009a9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8009ac:	89 08                	mov    %ecx,(%eax)
  8009ae:	8b 02                	mov    (%edx),%eax
  8009b0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8009bd:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8009c0:	8b 10                	mov    (%eax),%edx
  8009c2:	3b 50 04             	cmp    0x4(%eax),%edx
  8009c5:	73 0a                	jae    8009d1 <sprintputch+0x1a>
		*b->buf++ = ch;
  8009c7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009ca:	89 08                	mov    %ecx,(%eax)
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	88 02                	mov    %al,(%edx)
}
  8009d1:	5d                   	pop    %ebp
  8009d2:	c3                   	ret    

008009d3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8009d9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8009dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	89 04 24             	mov    %eax,(%esp)
  8009f4:	e8 02 00 00 00       	call   8009fb <vprintfmt>
	va_end(ap);
}
  8009f9:	c9                   	leave  
  8009fa:	c3                   	ret    

008009fb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	57                   	push   %edi
  8009ff:	56                   	push   %esi
  800a00:	53                   	push   %ebx
  800a01:	83 ec 3c             	sub    $0x3c,%esp
  800a04:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a0a:	eb 14                	jmp    800a20 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800a0c:	85 c0                	test   %eax,%eax
  800a0e:	0f 84 8a 03 00 00    	je     800d9e <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  800a14:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a18:	89 04 24             	mov    %eax,(%esp)
  800a1b:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a1e:	89 f3                	mov    %esi,%ebx
  800a20:	8d 73 01             	lea    0x1(%ebx),%esi
  800a23:	31 c0                	xor    %eax,%eax
  800a25:	8a 03                	mov    (%ebx),%al
  800a27:	83 f8 25             	cmp    $0x25,%eax
  800a2a:	75 e0                	jne    800a0c <vprintfmt+0x11>
  800a2c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800a30:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800a37:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800a3e:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800a45:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4a:	eb 1d                	jmp    800a69 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a4c:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800a4e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800a52:	eb 15                	jmp    800a69 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a54:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a56:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800a5a:	eb 0d                	jmp    800a69 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800a5c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a5f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a62:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a69:	8d 5e 01             	lea    0x1(%esi),%ebx
  800a6c:	31 c0                	xor    %eax,%eax
  800a6e:	8a 06                	mov    (%esi),%al
  800a70:	8a 0e                	mov    (%esi),%cl
  800a72:	83 e9 23             	sub    $0x23,%ecx
  800a75:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800a78:	80 f9 55             	cmp    $0x55,%cl
  800a7b:	0f 87 ff 02 00 00    	ja     800d80 <vprintfmt+0x385>
  800a81:	31 c9                	xor    %ecx,%ecx
  800a83:	8a 4d e0             	mov    -0x20(%ebp),%cl
  800a86:	ff 24 8d 40 12 80 00 	jmp    *0x801240(,%ecx,4)
  800a8d:	89 de                	mov    %ebx,%esi
  800a8f:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800a94:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800a97:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800a9b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800a9e:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800aa1:	83 fb 09             	cmp    $0x9,%ebx
  800aa4:	77 2f                	ja     800ad5 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800aa6:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800aa7:	eb eb                	jmp    800a94 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800aa9:	8b 45 14             	mov    0x14(%ebp),%eax
  800aac:	8d 48 04             	lea    0x4(%eax),%ecx
  800aaf:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800ab2:	8b 00                	mov    (%eax),%eax
  800ab4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ab7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800ab9:	eb 1d                	jmp    800ad8 <vprintfmt+0xdd>
  800abb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800abe:	f7 d0                	not    %eax
  800ac0:	c1 f8 1f             	sar    $0x1f,%eax
  800ac3:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ac6:	89 de                	mov    %ebx,%esi
  800ac8:	eb 9f                	jmp    800a69 <vprintfmt+0x6e>
  800aca:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800acc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800ad3:	eb 94                	jmp    800a69 <vprintfmt+0x6e>
  800ad5:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800ad8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800adc:	79 8b                	jns    800a69 <vprintfmt+0x6e>
  800ade:	e9 79 ff ff ff       	jmp    800a5c <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800ae3:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ae4:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800ae6:	eb 81                	jmp    800a69 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800ae8:	8b 45 14             	mov    0x14(%ebp),%eax
  800aeb:	8d 50 04             	lea    0x4(%eax),%edx
  800aee:	89 55 14             	mov    %edx,0x14(%ebp)
  800af1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800af5:	8b 00                	mov    (%eax),%eax
  800af7:	89 04 24             	mov    %eax,(%esp)
  800afa:	ff 55 08             	call   *0x8(%ebp)
			break;
  800afd:	e9 1e ff ff ff       	jmp    800a20 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800b02:	8b 45 14             	mov    0x14(%ebp),%eax
  800b05:	8d 50 04             	lea    0x4(%eax),%edx
  800b08:	89 55 14             	mov    %edx,0x14(%ebp)
  800b0b:	8b 00                	mov    (%eax),%eax
  800b0d:	89 c2                	mov    %eax,%edx
  800b0f:	c1 fa 1f             	sar    $0x1f,%edx
  800b12:	31 d0                	xor    %edx,%eax
  800b14:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800b16:	83 f8 09             	cmp    $0x9,%eax
  800b19:	7f 0b                	jg     800b26 <vprintfmt+0x12b>
  800b1b:	8b 14 85 a0 13 80 00 	mov    0x8013a0(,%eax,4),%edx
  800b22:	85 d2                	test   %edx,%edx
  800b24:	75 20                	jne    800b46 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  800b26:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b2a:	c7 44 24 08 96 11 80 	movl   $0x801196,0x8(%esp)
  800b31:	00 
  800b32:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b36:	8b 45 08             	mov    0x8(%ebp),%eax
  800b39:	89 04 24             	mov    %eax,(%esp)
  800b3c:	e8 92 fe ff ff       	call   8009d3 <printfmt>
  800b41:	e9 da fe ff ff       	jmp    800a20 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800b46:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b4a:	c7 44 24 08 9f 11 80 	movl   $0x80119f,0x8(%esp)
  800b51:	00 
  800b52:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b56:	8b 45 08             	mov    0x8(%ebp),%eax
  800b59:	89 04 24             	mov    %eax,(%esp)
  800b5c:	e8 72 fe ff ff       	call   8009d3 <printfmt>
  800b61:	e9 ba fe ff ff       	jmp    800a20 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b66:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800b69:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b6c:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800b6f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b72:	8d 50 04             	lea    0x4(%eax),%edx
  800b75:	89 55 14             	mov    %edx,0x14(%ebp)
  800b78:	8b 30                	mov    (%eax),%esi
  800b7a:	85 f6                	test   %esi,%esi
  800b7c:	75 05                	jne    800b83 <vprintfmt+0x188>
				p = "(null)";
  800b7e:	be 8f 11 80 00       	mov    $0x80118f,%esi
			if (width > 0 && padc != '-')
  800b83:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800b87:	0f 84 8c 00 00 00    	je     800c19 <vprintfmt+0x21e>
  800b8d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b91:	0f 8e 8a 00 00 00    	jle    800c21 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b97:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b9b:	89 34 24             	mov    %esi,(%esp)
  800b9e:	e8 57 f5 ff ff       	call   8000fa <strnlen>
  800ba3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800ba6:	29 c1                	sub    %eax,%ecx
  800ba8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800bab:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800baf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bb2:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800bb5:	8b 75 08             	mov    0x8(%ebp),%esi
  800bb8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bbb:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800bbd:	eb 0d                	jmp    800bcc <vprintfmt+0x1d1>
					putch(padc, putdat);
  800bbf:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800bc6:	89 04 24             	mov    %eax,(%esp)
  800bc9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800bcb:	4b                   	dec    %ebx
  800bcc:	85 db                	test   %ebx,%ebx
  800bce:	7f ef                	jg     800bbf <vprintfmt+0x1c4>
  800bd0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800bd3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800bd6:	89 c8                	mov    %ecx,%eax
  800bd8:	f7 d0                	not    %eax
  800bda:	c1 f8 1f             	sar    $0x1f,%eax
  800bdd:	21 c8                	and    %ecx,%eax
  800bdf:	29 c1                	sub    %eax,%ecx
  800be1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800be4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800be7:	eb 3e                	jmp    800c27 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800be9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800bed:	74 1b                	je     800c0a <vprintfmt+0x20f>
  800bef:	0f be d2             	movsbl %dl,%edx
  800bf2:	83 ea 20             	sub    $0x20,%edx
  800bf5:	83 fa 5e             	cmp    $0x5e,%edx
  800bf8:	76 10                	jbe    800c0a <vprintfmt+0x20f>
					putch('?', putdat);
  800bfa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bfe:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800c05:	ff 55 08             	call   *0x8(%ebp)
  800c08:	eb 0a                	jmp    800c14 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800c0a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c0e:	89 04 24             	mov    %eax,(%esp)
  800c11:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c14:	ff 4d dc             	decl   -0x24(%ebp)
  800c17:	eb 0e                	jmp    800c27 <vprintfmt+0x22c>
  800c19:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c1c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800c1f:	eb 06                	jmp    800c27 <vprintfmt+0x22c>
  800c21:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c24:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800c27:	46                   	inc    %esi
  800c28:	8a 56 ff             	mov    -0x1(%esi),%dl
  800c2b:	0f be c2             	movsbl %dl,%eax
  800c2e:	85 c0                	test   %eax,%eax
  800c30:	74 1f                	je     800c51 <vprintfmt+0x256>
  800c32:	85 db                	test   %ebx,%ebx
  800c34:	78 b3                	js     800be9 <vprintfmt+0x1ee>
  800c36:	4b                   	dec    %ebx
  800c37:	79 b0                	jns    800be9 <vprintfmt+0x1ee>
  800c39:	8b 75 08             	mov    0x8(%ebp),%esi
  800c3c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800c3f:	eb 16                	jmp    800c57 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800c41:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c45:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800c4c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800c4e:	4b                   	dec    %ebx
  800c4f:	eb 06                	jmp    800c57 <vprintfmt+0x25c>
  800c51:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800c54:	8b 75 08             	mov    0x8(%ebp),%esi
  800c57:	85 db                	test   %ebx,%ebx
  800c59:	7f e6                	jg     800c41 <vprintfmt+0x246>
  800c5b:	89 75 08             	mov    %esi,0x8(%ebp)
  800c5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c61:	e9 ba fd ff ff       	jmp    800a20 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c66:	83 fa 01             	cmp    $0x1,%edx
  800c69:	7e 16                	jle    800c81 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  800c6b:	8b 45 14             	mov    0x14(%ebp),%eax
  800c6e:	8d 50 08             	lea    0x8(%eax),%edx
  800c71:	89 55 14             	mov    %edx,0x14(%ebp)
  800c74:	8b 50 04             	mov    0x4(%eax),%edx
  800c77:	8b 00                	mov    (%eax),%eax
  800c79:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c7c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c7f:	eb 32                	jmp    800cb3 <vprintfmt+0x2b8>
	else if (lflag)
  800c81:	85 d2                	test   %edx,%edx
  800c83:	74 18                	je     800c9d <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800c85:	8b 45 14             	mov    0x14(%ebp),%eax
  800c88:	8d 50 04             	lea    0x4(%eax),%edx
  800c8b:	89 55 14             	mov    %edx,0x14(%ebp)
  800c8e:	8b 30                	mov    (%eax),%esi
  800c90:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800c93:	89 f0                	mov    %esi,%eax
  800c95:	c1 f8 1f             	sar    $0x1f,%eax
  800c98:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c9b:	eb 16                	jmp    800cb3 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800c9d:	8b 45 14             	mov    0x14(%ebp),%eax
  800ca0:	8d 50 04             	lea    0x4(%eax),%edx
  800ca3:	89 55 14             	mov    %edx,0x14(%ebp)
  800ca6:	8b 30                	mov    (%eax),%esi
  800ca8:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800cab:	89 f0                	mov    %esi,%eax
  800cad:	c1 f8 1f             	sar    $0x1f,%eax
  800cb0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800cb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800cb6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800cb9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800cbe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800cc2:	0f 89 80 00 00 00    	jns    800d48 <vprintfmt+0x34d>
				putch('-', putdat);
  800cc8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ccc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800cd3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800cd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800cd9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800cdc:	f7 d8                	neg    %eax
  800cde:	83 d2 00             	adc    $0x0,%edx
  800ce1:	f7 da                	neg    %edx
			}
			base = 10;
  800ce3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800ce8:	eb 5e                	jmp    800d48 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800cea:	8d 45 14             	lea    0x14(%ebp),%eax
  800ced:	e8 8b fc ff ff       	call   80097d <getuint>
			base = 10;
  800cf2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800cf7:	eb 4f                	jmp    800d48 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800cf9:	8d 45 14             	lea    0x14(%ebp),%eax
  800cfc:	e8 7c fc ff ff       	call   80097d <getuint>
			base = 8;
  800d01:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800d06:	eb 40                	jmp    800d48 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800d08:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d0c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800d13:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800d16:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d1a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800d21:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800d24:	8b 45 14             	mov    0x14(%ebp),%eax
  800d27:	8d 50 04             	lea    0x4(%eax),%edx
  800d2a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800d2d:	8b 00                	mov    (%eax),%eax
  800d2f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800d34:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800d39:	eb 0d                	jmp    800d48 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800d3b:	8d 45 14             	lea    0x14(%ebp),%eax
  800d3e:	e8 3a fc ff ff       	call   80097d <getuint>
			base = 16;
  800d43:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800d48:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800d4c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800d50:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800d53:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800d57:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d5b:	89 04 24             	mov    %eax,(%esp)
  800d5e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d62:	89 fa                	mov    %edi,%edx
  800d64:	8b 45 08             	mov    0x8(%ebp),%eax
  800d67:	e8 20 fb ff ff       	call   80088c <printnum>
			break;
  800d6c:	e9 af fc ff ff       	jmp    800a20 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d71:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d75:	89 04 24             	mov    %eax,(%esp)
  800d78:	ff 55 08             	call   *0x8(%ebp)
			break;
  800d7b:	e9 a0 fc ff ff       	jmp    800a20 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d80:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d84:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800d8b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d8e:	89 f3                	mov    %esi,%ebx
  800d90:	eb 01                	jmp    800d93 <vprintfmt+0x398>
  800d92:	4b                   	dec    %ebx
  800d93:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800d97:	75 f9                	jne    800d92 <vprintfmt+0x397>
  800d99:	e9 82 fc ff ff       	jmp    800a20 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800d9e:	83 c4 3c             	add    $0x3c,%esp
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	83 ec 28             	sub    $0x28,%esp
  800dac:	8b 45 08             	mov    0x8(%ebp),%eax
  800daf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800db2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800db5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800db9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800dbc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	74 30                	je     800df7 <vsnprintf+0x51>
  800dc7:	85 d2                	test   %edx,%edx
  800dc9:	7e 2c                	jle    800df7 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800dcb:	8b 45 14             	mov    0x14(%ebp),%eax
  800dce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dd2:	8b 45 10             	mov    0x10(%ebp),%eax
  800dd5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dd9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ddc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800de0:	c7 04 24 b7 09 80 00 	movl   $0x8009b7,(%esp)
  800de7:	e8 0f fc ff ff       	call   8009fb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800dec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800def:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df5:	eb 05                	jmp    800dfc <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800df7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800dfc:	c9                   	leave  
  800dfd:	c3                   	ret    

00800dfe <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800e04:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800e07:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800e0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e19:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1c:	89 04 24             	mov    %eax,(%esp)
  800e1f:	e8 82 ff ff ff       	call   800da6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800e24:	c9                   	leave  
  800e25:	c3                   	ret    
  800e26:	66 90                	xchg   %ax,%ax

00800e28 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e2e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e35:	75 32                	jne    800e69 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
    //region_alloc(curenv, (void *)UXSTACKTOP - PGSIZE, PGSIZE);
		//panic("set_pgfault_handler not implemented");
		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  800e37:	e8 a3 f6 ff ff       	call   8004df <sys_getenvid>
  800e3c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e43:	00 
  800e44:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800e4b:	ee 
  800e4c:	89 04 24             	mov    %eax,(%esp)
  800e4f:	e8 c9 f6 ff ff       	call   80051d <sys_page_alloc>
    sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800e54:	e8 86 f6 ff ff       	call   8004df <sys_getenvid>
  800e59:	c7 44 24 04 34 07 80 	movl   $0x800734,0x4(%esp)
  800e60:	00 
  800e61:	89 04 24             	mov    %eax,(%esp)
  800e64:	e8 01 f8 ff ff       	call   80066a <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e69:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6c:	a3 08 20 80 00       	mov    %eax,0x802008

}
  800e71:	c9                   	leave  
  800e72:	c3                   	ret    
  800e73:	66 90                	xchg   %ax,%ax
  800e75:	66 90                	xchg   %ax,%ax
  800e77:	66 90                	xchg   %ax,%ax
  800e79:	66 90                	xchg   %ax,%ax
  800e7b:	66 90                	xchg   %ax,%ax
  800e7d:	66 90                	xchg   %ax,%ax
  800e7f:	90                   	nop

00800e80 <__udivdi3>:
  800e80:	55                   	push   %ebp
  800e81:	57                   	push   %edi
  800e82:	56                   	push   %esi
  800e83:	83 ec 0c             	sub    $0xc,%esp
  800e86:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800e8a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800e8e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800e92:	8b 44 24 28          	mov    0x28(%esp),%eax
  800e96:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e9a:	89 ea                	mov    %ebp,%edx
  800e9c:	89 0c 24             	mov    %ecx,(%esp)
  800e9f:	85 c0                	test   %eax,%eax
  800ea1:	75 2d                	jne    800ed0 <__udivdi3+0x50>
  800ea3:	39 e9                	cmp    %ebp,%ecx
  800ea5:	77 61                	ja     800f08 <__udivdi3+0x88>
  800ea7:	89 ce                	mov    %ecx,%esi
  800ea9:	85 c9                	test   %ecx,%ecx
  800eab:	75 0b                	jne    800eb8 <__udivdi3+0x38>
  800ead:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb2:	31 d2                	xor    %edx,%edx
  800eb4:	f7 f1                	div    %ecx
  800eb6:	89 c6                	mov    %eax,%esi
  800eb8:	31 d2                	xor    %edx,%edx
  800eba:	89 e8                	mov    %ebp,%eax
  800ebc:	f7 f6                	div    %esi
  800ebe:	89 c5                	mov    %eax,%ebp
  800ec0:	89 f8                	mov    %edi,%eax
  800ec2:	f7 f6                	div    %esi
  800ec4:	89 ea                	mov    %ebp,%edx
  800ec6:	83 c4 0c             	add    $0xc,%esp
  800ec9:	5e                   	pop    %esi
  800eca:	5f                   	pop    %edi
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    
  800ecd:	8d 76 00             	lea    0x0(%esi),%esi
  800ed0:	39 e8                	cmp    %ebp,%eax
  800ed2:	77 24                	ja     800ef8 <__udivdi3+0x78>
  800ed4:	0f bd e8             	bsr    %eax,%ebp
  800ed7:	83 f5 1f             	xor    $0x1f,%ebp
  800eda:	75 3c                	jne    800f18 <__udivdi3+0x98>
  800edc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ee0:	39 34 24             	cmp    %esi,(%esp)
  800ee3:	0f 86 9f 00 00 00    	jbe    800f88 <__udivdi3+0x108>
  800ee9:	39 d0                	cmp    %edx,%eax
  800eeb:	0f 82 97 00 00 00    	jb     800f88 <__udivdi3+0x108>
  800ef1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ef8:	31 d2                	xor    %edx,%edx
  800efa:	31 c0                	xor    %eax,%eax
  800efc:	83 c4 0c             	add    $0xc,%esp
  800eff:	5e                   	pop    %esi
  800f00:	5f                   	pop    %edi
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    
  800f03:	90                   	nop
  800f04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f08:	89 f8                	mov    %edi,%eax
  800f0a:	f7 f1                	div    %ecx
  800f0c:	31 d2                	xor    %edx,%edx
  800f0e:	83 c4 0c             	add    $0xc,%esp
  800f11:	5e                   	pop    %esi
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    
  800f15:	8d 76 00             	lea    0x0(%esi),%esi
  800f18:	89 e9                	mov    %ebp,%ecx
  800f1a:	8b 3c 24             	mov    (%esp),%edi
  800f1d:	d3 e0                	shl    %cl,%eax
  800f1f:	89 c6                	mov    %eax,%esi
  800f21:	b8 20 00 00 00       	mov    $0x20,%eax
  800f26:	29 e8                	sub    %ebp,%eax
  800f28:	88 c1                	mov    %al,%cl
  800f2a:	d3 ef                	shr    %cl,%edi
  800f2c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f30:	89 e9                	mov    %ebp,%ecx
  800f32:	8b 3c 24             	mov    (%esp),%edi
  800f35:	09 74 24 08          	or     %esi,0x8(%esp)
  800f39:	d3 e7                	shl    %cl,%edi
  800f3b:	89 d6                	mov    %edx,%esi
  800f3d:	88 c1                	mov    %al,%cl
  800f3f:	d3 ee                	shr    %cl,%esi
  800f41:	89 e9                	mov    %ebp,%ecx
  800f43:	89 3c 24             	mov    %edi,(%esp)
  800f46:	d3 e2                	shl    %cl,%edx
  800f48:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f4c:	88 c1                	mov    %al,%cl
  800f4e:	d3 ef                	shr    %cl,%edi
  800f50:	09 d7                	or     %edx,%edi
  800f52:	89 f2                	mov    %esi,%edx
  800f54:	89 f8                	mov    %edi,%eax
  800f56:	f7 74 24 08          	divl   0x8(%esp)
  800f5a:	89 d6                	mov    %edx,%esi
  800f5c:	89 c7                	mov    %eax,%edi
  800f5e:	f7 24 24             	mull   (%esp)
  800f61:	89 14 24             	mov    %edx,(%esp)
  800f64:	39 d6                	cmp    %edx,%esi
  800f66:	72 30                	jb     800f98 <__udivdi3+0x118>
  800f68:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f6c:	89 e9                	mov    %ebp,%ecx
  800f6e:	d3 e2                	shl    %cl,%edx
  800f70:	39 c2                	cmp    %eax,%edx
  800f72:	73 05                	jae    800f79 <__udivdi3+0xf9>
  800f74:	3b 34 24             	cmp    (%esp),%esi
  800f77:	74 1f                	je     800f98 <__udivdi3+0x118>
  800f79:	89 f8                	mov    %edi,%eax
  800f7b:	31 d2                	xor    %edx,%edx
  800f7d:	e9 7a ff ff ff       	jmp    800efc <__udivdi3+0x7c>
  800f82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f88:	31 d2                	xor    %edx,%edx
  800f8a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8f:	e9 68 ff ff ff       	jmp    800efc <__udivdi3+0x7c>
  800f94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f98:	8d 47 ff             	lea    -0x1(%edi),%eax
  800f9b:	31 d2                	xor    %edx,%edx
  800f9d:	83 c4 0c             	add    $0xc,%esp
  800fa0:	5e                   	pop    %esi
  800fa1:	5f                   	pop    %edi
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    
  800fa4:	66 90                	xchg   %ax,%ax
  800fa6:	66 90                	xchg   %ax,%ax
  800fa8:	66 90                	xchg   %ax,%ax
  800faa:	66 90                	xchg   %ax,%ax
  800fac:	66 90                	xchg   %ax,%ax
  800fae:	66 90                	xchg   %ax,%ax

00800fb0 <__umoddi3>:
  800fb0:	55                   	push   %ebp
  800fb1:	57                   	push   %edi
  800fb2:	56                   	push   %esi
  800fb3:	83 ec 14             	sub    $0x14,%esp
  800fb6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800fba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800fbe:	89 c7                	mov    %eax,%edi
  800fc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fc4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800fc8:	8b 44 24 30          	mov    0x30(%esp),%eax
  800fcc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fd0:	89 34 24             	mov    %esi,(%esp)
  800fd3:	89 c2                	mov    %eax,%edx
  800fd5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fd9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	75 17                	jne    800ff8 <__umoddi3+0x48>
  800fe1:	39 fe                	cmp    %edi,%esi
  800fe3:	76 4b                	jbe    801030 <__umoddi3+0x80>
  800fe5:	89 c8                	mov    %ecx,%eax
  800fe7:	89 fa                	mov    %edi,%edx
  800fe9:	f7 f6                	div    %esi
  800feb:	89 d0                	mov    %edx,%eax
  800fed:	31 d2                	xor    %edx,%edx
  800fef:	83 c4 14             	add    $0x14,%esp
  800ff2:	5e                   	pop    %esi
  800ff3:	5f                   	pop    %edi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    
  800ff6:	66 90                	xchg   %ax,%ax
  800ff8:	39 f8                	cmp    %edi,%eax
  800ffa:	77 54                	ja     801050 <__umoddi3+0xa0>
  800ffc:	0f bd e8             	bsr    %eax,%ebp
  800fff:	83 f5 1f             	xor    $0x1f,%ebp
  801002:	75 5c                	jne    801060 <__umoddi3+0xb0>
  801004:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801008:	39 3c 24             	cmp    %edi,(%esp)
  80100b:	0f 87 f7 00 00 00    	ja     801108 <__umoddi3+0x158>
  801011:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801015:	29 f1                	sub    %esi,%ecx
  801017:	19 c7                	sbb    %eax,%edi
  801019:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80101d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801021:	8b 44 24 08          	mov    0x8(%esp),%eax
  801025:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801029:	83 c4 14             	add    $0x14,%esp
  80102c:	5e                   	pop    %esi
  80102d:	5f                   	pop    %edi
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    
  801030:	89 f5                	mov    %esi,%ebp
  801032:	85 f6                	test   %esi,%esi
  801034:	75 0b                	jne    801041 <__umoddi3+0x91>
  801036:	b8 01 00 00 00       	mov    $0x1,%eax
  80103b:	31 d2                	xor    %edx,%edx
  80103d:	f7 f6                	div    %esi
  80103f:	89 c5                	mov    %eax,%ebp
  801041:	8b 44 24 04          	mov    0x4(%esp),%eax
  801045:	31 d2                	xor    %edx,%edx
  801047:	f7 f5                	div    %ebp
  801049:	89 c8                	mov    %ecx,%eax
  80104b:	f7 f5                	div    %ebp
  80104d:	eb 9c                	jmp    800feb <__umoddi3+0x3b>
  80104f:	90                   	nop
  801050:	89 c8                	mov    %ecx,%eax
  801052:	89 fa                	mov    %edi,%edx
  801054:	83 c4 14             	add    $0x14,%esp
  801057:	5e                   	pop    %esi
  801058:	5f                   	pop    %edi
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    
  80105b:	90                   	nop
  80105c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801060:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801067:	00 
  801068:	8b 34 24             	mov    (%esp),%esi
  80106b:	8b 44 24 04          	mov    0x4(%esp),%eax
  80106f:	89 e9                	mov    %ebp,%ecx
  801071:	29 e8                	sub    %ebp,%eax
  801073:	89 44 24 04          	mov    %eax,0x4(%esp)
  801077:	89 f0                	mov    %esi,%eax
  801079:	d3 e2                	shl    %cl,%edx
  80107b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  80107f:	d3 e8                	shr    %cl,%eax
  801081:	89 04 24             	mov    %eax,(%esp)
  801084:	89 e9                	mov    %ebp,%ecx
  801086:	89 f0                	mov    %esi,%eax
  801088:	09 14 24             	or     %edx,(%esp)
  80108b:	d3 e0                	shl    %cl,%eax
  80108d:	89 fa                	mov    %edi,%edx
  80108f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801093:	d3 ea                	shr    %cl,%edx
  801095:	89 e9                	mov    %ebp,%ecx
  801097:	89 c6                	mov    %eax,%esi
  801099:	d3 e7                	shl    %cl,%edi
  80109b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80109f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8010a3:	8b 44 24 10          	mov    0x10(%esp),%eax
  8010a7:	d3 e8                	shr    %cl,%eax
  8010a9:	09 f8                	or     %edi,%eax
  8010ab:	89 e9                	mov    %ebp,%ecx
  8010ad:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8010b1:	d3 e7                	shl    %cl,%edi
  8010b3:	f7 34 24             	divl   (%esp)
  8010b6:	89 d1                	mov    %edx,%ecx
  8010b8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010bc:	f7 e6                	mul    %esi
  8010be:	89 c7                	mov    %eax,%edi
  8010c0:	89 d6                	mov    %edx,%esi
  8010c2:	39 d1                	cmp    %edx,%ecx
  8010c4:	72 2e                	jb     8010f4 <__umoddi3+0x144>
  8010c6:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8010ca:	72 24                	jb     8010f0 <__umoddi3+0x140>
  8010cc:	89 ca                	mov    %ecx,%edx
  8010ce:	89 e9                	mov    %ebp,%ecx
  8010d0:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010d4:	29 f8                	sub    %edi,%eax
  8010d6:	19 f2                	sbb    %esi,%edx
  8010d8:	d3 e8                	shr    %cl,%eax
  8010da:	89 d6                	mov    %edx,%esi
  8010dc:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8010e0:	d3 e6                	shl    %cl,%esi
  8010e2:	89 e9                	mov    %ebp,%ecx
  8010e4:	09 f0                	or     %esi,%eax
  8010e6:	d3 ea                	shr    %cl,%edx
  8010e8:	83 c4 14             	add    $0x14,%esp
  8010eb:	5e                   	pop    %esi
  8010ec:	5f                   	pop    %edi
  8010ed:	5d                   	pop    %ebp
  8010ee:	c3                   	ret    
  8010ef:	90                   	nop
  8010f0:	39 d1                	cmp    %edx,%ecx
  8010f2:	75 d8                	jne    8010cc <__umoddi3+0x11c>
  8010f4:	89 d6                	mov    %edx,%esi
  8010f6:	89 c7                	mov    %eax,%edi
  8010f8:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  8010fc:	1b 34 24             	sbb    (%esp),%esi
  8010ff:	eb cb                	jmp    8010cc <__umoddi3+0x11c>
  801101:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801108:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80110c:	0f 82 ff fe ff ff    	jb     801011 <__umoddi3+0x61>
  801112:	e9 0a ff ff ff       	jmp    801021 <__umoddi3+0x71>
