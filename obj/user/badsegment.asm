
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
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
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	5d                   	pop    %ebp
  80003e:	c3                   	ret    
  80003f:	90                   	nop

00800040 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
  800048:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004b:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  80004e:	b8 08 20 80 00       	mov    $0x802008,%eax
  800053:	2d 04 20 80 00       	sub    $0x802004,%eax
  800058:	89 44 24 08          	mov    %eax,0x8(%esp)
  80005c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800063:	00 
  800064:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  80006b:	e8 bb 01 00 00       	call   80022b <memset>

	thisenv = 0;
	thisenv = &envs[0];
  800070:	c7 05 04 20 80 00 00 	movl   $0xeec00000,0x802004
  800077:	00 c0 ee 
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007a:	85 db                	test   %ebx,%ebx
  80007c:	7e 07                	jle    800085 <libmain+0x45>
		binaryname = argv[0];
  80007e:	8b 06                	mov    (%esi),%eax
  800080:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800085:	89 74 24 04          	mov    %esi,0x4(%esp)
  800089:	89 1c 24             	mov    %ebx,(%esp)
  80008c:	e8 a3 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800091:	e8 0a 00 00 00       	call   8000a0 <exit>
}
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	5b                   	pop    %ebx
  80009a:	5e                   	pop    %esi
  80009b:	5d                   	pop    %ebp
  80009c:	c3                   	ret    
  80009d:	66 90                	xchg   %ax,%ax
  80009f:	90                   	nop

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ad:	e8 ab 03 00 00       	call   80045d <sys_env_destroy>
}
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	eb 01                	jmp    8000c2 <strlen+0xe>
		n++;
  8000c1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8000c2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8000c6:	75 f9                	jne    8000c1 <strlen+0xd>
		n++;
	return n;
}
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8000d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d8:	eb 01                	jmp    8000db <strnlen+0x11>
		n++;
  8000da:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8000db:	39 d0                	cmp    %edx,%eax
  8000dd:	74 06                	je     8000e5 <strnlen+0x1b>
  8000df:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8000e3:	75 f5                	jne    8000da <strnlen+0x10>
		n++;
	return n;
}
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	53                   	push   %ebx
  8000eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8000ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8000f1:	89 c2                	mov    %eax,%edx
  8000f3:	42                   	inc    %edx
  8000f4:	41                   	inc    %ecx
  8000f5:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8000f8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8000fb:	84 db                	test   %bl,%bl
  8000fd:	75 f4                	jne    8000f3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8000ff:	5b                   	pop    %ebx
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	53                   	push   %ebx
  800106:	83 ec 08             	sub    $0x8,%esp
  800109:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80010c:	89 1c 24             	mov    %ebx,(%esp)
  80010f:	e8 a0 ff ff ff       	call   8000b4 <strlen>
	strcpy(dst + len, src);
  800114:	8b 55 0c             	mov    0xc(%ebp),%edx
  800117:	89 54 24 04          	mov    %edx,0x4(%esp)
  80011b:	01 d8                	add    %ebx,%eax
  80011d:	89 04 24             	mov    %eax,(%esp)
  800120:	e8 c2 ff ff ff       	call   8000e7 <strcpy>
	return dst;
}
  800125:	89 d8                	mov    %ebx,%eax
  800127:	83 c4 08             	add    $0x8,%esp
  80012a:	5b                   	pop    %ebx
  80012b:	5d                   	pop    %ebp
  80012c:	c3                   	ret    

0080012d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
  800132:	8b 75 08             	mov    0x8(%ebp),%esi
  800135:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800138:	89 f3                	mov    %esi,%ebx
  80013a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80013d:	89 f2                	mov    %esi,%edx
  80013f:	eb 0c                	jmp    80014d <strncpy+0x20>
		*dst++ = *src;
  800141:	42                   	inc    %edx
  800142:	8a 01                	mov    (%ecx),%al
  800144:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800147:	80 39 01             	cmpb   $0x1,(%ecx)
  80014a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80014d:	39 da                	cmp    %ebx,%edx
  80014f:	75 f0                	jne    800141 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800151:	89 f0                	mov    %esi,%eax
  800153:	5b                   	pop    %ebx
  800154:	5e                   	pop    %esi
  800155:	5d                   	pop    %ebp
  800156:	c3                   	ret    

00800157 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	8b 75 08             	mov    0x8(%ebp),%esi
  80015f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800162:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800165:	89 f0                	mov    %esi,%eax
  800167:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80016b:	85 c9                	test   %ecx,%ecx
  80016d:	75 07                	jne    800176 <strlcpy+0x1f>
  80016f:	eb 18                	jmp    800189 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800171:	40                   	inc    %eax
  800172:	42                   	inc    %edx
  800173:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800176:	39 d8                	cmp    %ebx,%eax
  800178:	74 0a                	je     800184 <strlcpy+0x2d>
  80017a:	8a 0a                	mov    (%edx),%cl
  80017c:	84 c9                	test   %cl,%cl
  80017e:	75 f1                	jne    800171 <strlcpy+0x1a>
  800180:	89 c2                	mov    %eax,%edx
  800182:	eb 02                	jmp    800186 <strlcpy+0x2f>
  800184:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800186:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800189:	29 f0                	sub    %esi,%eax
}
  80018b:	5b                   	pop    %ebx
  80018c:	5e                   	pop    %esi
  80018d:	5d                   	pop    %ebp
  80018e:	c3                   	ret    

0080018f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800195:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800198:	eb 02                	jmp    80019c <strcmp+0xd>
		p++, q++;
  80019a:	41                   	inc    %ecx
  80019b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80019c:	8a 01                	mov    (%ecx),%al
  80019e:	84 c0                	test   %al,%al
  8001a0:	74 04                	je     8001a6 <strcmp+0x17>
  8001a2:	3a 02                	cmp    (%edx),%al
  8001a4:	74 f4                	je     80019a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8001a6:	25 ff 00 00 00       	and    $0xff,%eax
  8001ab:	8a 0a                	mov    (%edx),%cl
  8001ad:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8001b3:	29 c8                	sub    %ecx,%eax
}
  8001b5:	5d                   	pop    %ebp
  8001b6:	c3                   	ret    

008001b7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	53                   	push   %ebx
  8001bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c1:	89 c3                	mov    %eax,%ebx
  8001c3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8001c6:	eb 02                	jmp    8001ca <strncmp+0x13>
		n--, p++, q++;
  8001c8:	40                   	inc    %eax
  8001c9:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8001ca:	39 d8                	cmp    %ebx,%eax
  8001cc:	74 20                	je     8001ee <strncmp+0x37>
  8001ce:	8a 08                	mov    (%eax),%cl
  8001d0:	84 c9                	test   %cl,%cl
  8001d2:	74 04                	je     8001d8 <strncmp+0x21>
  8001d4:	3a 0a                	cmp    (%edx),%cl
  8001d6:	74 f0                	je     8001c8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8001d8:	8a 18                	mov    (%eax),%bl
  8001da:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8001e0:	89 d8                	mov    %ebx,%eax
  8001e2:	8a 1a                	mov    (%edx),%bl
  8001e4:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8001ea:	29 d8                	sub    %ebx,%eax
  8001ec:	eb 05                	jmp    8001f3 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8001ee:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8001f3:	5b                   	pop    %ebx
  8001f4:	5d                   	pop    %ebp
  8001f5:	c3                   	ret    

008001f6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8001ff:	eb 05                	jmp    800206 <strchr+0x10>
		if (*s == c)
  800201:	38 ca                	cmp    %cl,%dl
  800203:	74 0c                	je     800211 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800205:	40                   	inc    %eax
  800206:	8a 10                	mov    (%eax),%dl
  800208:	84 d2                	test   %dl,%dl
  80020a:	75 f5                	jne    800201 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80020c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800211:	5d                   	pop    %ebp
  800212:	c3                   	ret    

00800213 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	8b 45 08             	mov    0x8(%ebp),%eax
  800219:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80021c:	eb 05                	jmp    800223 <strfind+0x10>
		if (*s == c)
  80021e:	38 ca                	cmp    %cl,%dl
  800220:	74 07                	je     800229 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800222:	40                   	inc    %eax
  800223:	8a 10                	mov    (%eax),%dl
  800225:	84 d2                	test   %dl,%dl
  800227:	75 f5                	jne    80021e <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800229:	5d                   	pop    %ebp
  80022a:	c3                   	ret    

0080022b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	57                   	push   %edi
  80022f:	56                   	push   %esi
  800230:	53                   	push   %ebx
  800231:	8b 7d 08             	mov    0x8(%ebp),%edi
  800234:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800237:	85 c9                	test   %ecx,%ecx
  800239:	74 37                	je     800272 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80023b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800241:	75 29                	jne    80026c <memset+0x41>
  800243:	f6 c1 03             	test   $0x3,%cl
  800246:	75 24                	jne    80026c <memset+0x41>
		c &= 0xFF;
  800248:	31 d2                	xor    %edx,%edx
  80024a:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80024d:	89 d3                	mov    %edx,%ebx
  80024f:	c1 e3 08             	shl    $0x8,%ebx
  800252:	89 d6                	mov    %edx,%esi
  800254:	c1 e6 18             	shl    $0x18,%esi
  800257:	89 d0                	mov    %edx,%eax
  800259:	c1 e0 10             	shl    $0x10,%eax
  80025c:	09 f0                	or     %esi,%eax
  80025e:	09 c2                	or     %eax,%edx
  800260:	89 d0                	mov    %edx,%eax
  800262:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800264:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800267:	fc                   	cld    
  800268:	f3 ab                	rep stos %eax,%es:(%edi)
  80026a:	eb 06                	jmp    800272 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80026c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026f:	fc                   	cld    
  800270:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800272:	89 f8                	mov    %edi,%eax
  800274:	5b                   	pop    %ebx
  800275:	5e                   	pop    %esi
  800276:	5f                   	pop    %edi
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	8b 75 0c             	mov    0xc(%ebp),%esi
  800284:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800287:	39 c6                	cmp    %eax,%esi
  800289:	73 33                	jae    8002be <memmove+0x45>
  80028b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80028e:	39 d0                	cmp    %edx,%eax
  800290:	73 2c                	jae    8002be <memmove+0x45>
		s += n;
		d += n;
  800292:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800295:	89 d6                	mov    %edx,%esi
  800297:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800299:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80029f:	75 13                	jne    8002b4 <memmove+0x3b>
  8002a1:	f6 c1 03             	test   $0x3,%cl
  8002a4:	75 0e                	jne    8002b4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8002a6:	83 ef 04             	sub    $0x4,%edi
  8002a9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8002ac:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8002af:	fd                   	std    
  8002b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8002b2:	eb 07                	jmp    8002bb <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8002b4:	4f                   	dec    %edi
  8002b5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8002b8:	fd                   	std    
  8002b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8002bb:	fc                   	cld    
  8002bc:	eb 1d                	jmp    8002db <memmove+0x62>
  8002be:	89 f2                	mov    %esi,%edx
  8002c0:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8002c2:	f6 c2 03             	test   $0x3,%dl
  8002c5:	75 0f                	jne    8002d6 <memmove+0x5d>
  8002c7:	f6 c1 03             	test   $0x3,%cl
  8002ca:	75 0a                	jne    8002d6 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8002cc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8002cf:	89 c7                	mov    %eax,%edi
  8002d1:	fc                   	cld    
  8002d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8002d4:	eb 05                	jmp    8002db <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8002d6:	89 c7                	mov    %eax,%edi
  8002d8:	fc                   	cld    
  8002d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8002db:	5e                   	pop    %esi
  8002dc:	5f                   	pop    %edi
  8002dd:	5d                   	pop    %ebp
  8002de:	c3                   	ret    

008002df <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8002e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f6:	89 04 24             	mov    %eax,(%esp)
  8002f9:	e8 7b ff ff ff       	call   800279 <memmove>
}
  8002fe:	c9                   	leave  
  8002ff:	c3                   	ret    

00800300 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	56                   	push   %esi
  800304:	53                   	push   %ebx
  800305:	8b 55 08             	mov    0x8(%ebp),%edx
  800308:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030b:	89 d6                	mov    %edx,%esi
  80030d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800310:	eb 19                	jmp    80032b <memcmp+0x2b>
		if (*s1 != *s2)
  800312:	8a 02                	mov    (%edx),%al
  800314:	8a 19                	mov    (%ecx),%bl
  800316:	38 d8                	cmp    %bl,%al
  800318:	74 0f                	je     800329 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  80031a:	25 ff 00 00 00       	and    $0xff,%eax
  80031f:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800325:	29 d8                	sub    %ebx,%eax
  800327:	eb 0b                	jmp    800334 <memcmp+0x34>
		s1++, s2++;
  800329:	42                   	inc    %edx
  80032a:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80032b:	39 f2                	cmp    %esi,%edx
  80032d:	75 e3                	jne    800312 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80032f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800334:	5b                   	pop    %ebx
  800335:	5e                   	pop    %esi
  800336:	5d                   	pop    %ebp
  800337:	c3                   	ret    

00800338 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	8b 45 08             	mov    0x8(%ebp),%eax
  80033e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800341:	89 c2                	mov    %eax,%edx
  800343:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800346:	eb 05                	jmp    80034d <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800348:	38 08                	cmp    %cl,(%eax)
  80034a:	74 05                	je     800351 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80034c:	40                   	inc    %eax
  80034d:	39 d0                	cmp    %edx,%eax
  80034f:	72 f7                	jb     800348 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800351:	5d                   	pop    %ebp
  800352:	c3                   	ret    

00800353 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	57                   	push   %edi
  800357:	56                   	push   %esi
  800358:	53                   	push   %ebx
  800359:	8b 55 08             	mov    0x8(%ebp),%edx
  80035c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80035f:	eb 01                	jmp    800362 <strtol+0xf>
		s++;
  800361:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800362:	8a 02                	mov    (%edx),%al
  800364:	3c 09                	cmp    $0x9,%al
  800366:	74 f9                	je     800361 <strtol+0xe>
  800368:	3c 20                	cmp    $0x20,%al
  80036a:	74 f5                	je     800361 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80036c:	3c 2b                	cmp    $0x2b,%al
  80036e:	75 08                	jne    800378 <strtol+0x25>
		s++;
  800370:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800371:	bf 00 00 00 00       	mov    $0x0,%edi
  800376:	eb 10                	jmp    800388 <strtol+0x35>
  800378:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80037d:	3c 2d                	cmp    $0x2d,%al
  80037f:	75 07                	jne    800388 <strtol+0x35>
		s++, neg = 1;
  800381:	8d 52 01             	lea    0x1(%edx),%edx
  800384:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800388:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80038e:	75 15                	jne    8003a5 <strtol+0x52>
  800390:	80 3a 30             	cmpb   $0x30,(%edx)
  800393:	75 10                	jne    8003a5 <strtol+0x52>
  800395:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800399:	75 0a                	jne    8003a5 <strtol+0x52>
		s += 2, base = 16;
  80039b:	83 c2 02             	add    $0x2,%edx
  80039e:	bb 10 00 00 00       	mov    $0x10,%ebx
  8003a3:	eb 0e                	jmp    8003b3 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  8003a5:	85 db                	test   %ebx,%ebx
  8003a7:	75 0a                	jne    8003b3 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8003a9:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8003ab:	80 3a 30             	cmpb   $0x30,(%edx)
  8003ae:	75 03                	jne    8003b3 <strtol+0x60>
		s++, base = 8;
  8003b0:	42                   	inc    %edx
  8003b1:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  8003b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8003bb:	8a 0a                	mov    (%edx),%cl
  8003bd:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8003c0:	89 f3                	mov    %esi,%ebx
  8003c2:	80 fb 09             	cmp    $0x9,%bl
  8003c5:	77 08                	ja     8003cf <strtol+0x7c>
			dig = *s - '0';
  8003c7:	0f be c9             	movsbl %cl,%ecx
  8003ca:	83 e9 30             	sub    $0x30,%ecx
  8003cd:	eb 22                	jmp    8003f1 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  8003cf:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8003d2:	89 f3                	mov    %esi,%ebx
  8003d4:	80 fb 19             	cmp    $0x19,%bl
  8003d7:	77 08                	ja     8003e1 <strtol+0x8e>
			dig = *s - 'a' + 10;
  8003d9:	0f be c9             	movsbl %cl,%ecx
  8003dc:	83 e9 57             	sub    $0x57,%ecx
  8003df:	eb 10                	jmp    8003f1 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  8003e1:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8003e4:	89 f3                	mov    %esi,%ebx
  8003e6:	80 fb 19             	cmp    $0x19,%bl
  8003e9:	77 14                	ja     8003ff <strtol+0xac>
			dig = *s - 'A' + 10;
  8003eb:	0f be c9             	movsbl %cl,%ecx
  8003ee:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8003f1:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  8003f4:	7d 0d                	jge    800403 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8003f6:	42                   	inc    %edx
  8003f7:	0f af 45 10          	imul   0x10(%ebp),%eax
  8003fb:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8003fd:	eb bc                	jmp    8003bb <strtol+0x68>
  8003ff:	89 c1                	mov    %eax,%ecx
  800401:	eb 02                	jmp    800405 <strtol+0xb2>
  800403:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800405:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800409:	74 05                	je     800410 <strtol+0xbd>
		*endptr = (char *) s;
  80040b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80040e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800410:	85 ff                	test   %edi,%edi
  800412:	74 04                	je     800418 <strtol+0xc5>
  800414:	89 c8                	mov    %ecx,%eax
  800416:	f7 d8                	neg    %eax
}
  800418:	5b                   	pop    %ebx
  800419:	5e                   	pop    %esi
  80041a:	5f                   	pop    %edi
  80041b:	5d                   	pop    %ebp
  80041c:	c3                   	ret    
  80041d:	66 90                	xchg   %ax,%ax
  80041f:	90                   	nop

00800420 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	57                   	push   %edi
  800424:	56                   	push   %esi
  800425:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800426:	b8 00 00 00 00       	mov    $0x0,%eax
  80042b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042e:	8b 55 08             	mov    0x8(%ebp),%edx
  800431:	89 c3                	mov    %eax,%ebx
  800433:	89 c7                	mov    %eax,%edi
  800435:	89 c6                	mov    %eax,%esi
  800437:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800439:	5b                   	pop    %ebx
  80043a:	5e                   	pop    %esi
  80043b:	5f                   	pop    %edi
  80043c:	5d                   	pop    %ebp
  80043d:	c3                   	ret    

0080043e <sys_cgetc>:

int
sys_cgetc(void)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	57                   	push   %edi
  800442:	56                   	push   %esi
  800443:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800444:	ba 00 00 00 00       	mov    $0x0,%edx
  800449:	b8 01 00 00 00       	mov    $0x1,%eax
  80044e:	89 d1                	mov    %edx,%ecx
  800450:	89 d3                	mov    %edx,%ebx
  800452:	89 d7                	mov    %edx,%edi
  800454:	89 d6                	mov    %edx,%esi
  800456:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800458:	5b                   	pop    %ebx
  800459:	5e                   	pop    %esi
  80045a:	5f                   	pop    %edi
  80045b:	5d                   	pop    %ebp
  80045c:	c3                   	ret    

0080045d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80045d:	55                   	push   %ebp
  80045e:	89 e5                	mov    %esp,%ebp
  800460:	57                   	push   %edi
  800461:	56                   	push   %esi
  800462:	53                   	push   %ebx
  800463:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800466:	b9 00 00 00 00       	mov    $0x0,%ecx
  80046b:	b8 03 00 00 00       	mov    $0x3,%eax
  800470:	8b 55 08             	mov    0x8(%ebp),%edx
  800473:	89 cb                	mov    %ecx,%ebx
  800475:	89 cf                	mov    %ecx,%edi
  800477:	89 ce                	mov    %ecx,%esi
  800479:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80047b:	85 c0                	test   %eax,%eax
  80047d:	7e 28                	jle    8004a7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80047f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800483:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80048a:	00 
  80048b:	c7 44 24 08 2a 0e 80 	movl   $0x800e2a,0x8(%esp)
  800492:	00 
  800493:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80049a:	00 
  80049b:	c7 04 24 47 0e 80 00 	movl   $0x800e47,(%esp)
  8004a2:	e8 29 00 00 00       	call   8004d0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8004a7:	83 c4 2c             	add    $0x2c,%esp
  8004aa:	5b                   	pop    %ebx
  8004ab:	5e                   	pop    %esi
  8004ac:	5f                   	pop    %edi
  8004ad:	5d                   	pop    %ebp
  8004ae:	c3                   	ret    

008004af <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8004af:	55                   	push   %ebp
  8004b0:	89 e5                	mov    %esp,%ebp
  8004b2:	57                   	push   %edi
  8004b3:	56                   	push   %esi
  8004b4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ba:	b8 02 00 00 00       	mov    $0x2,%eax
  8004bf:	89 d1                	mov    %edx,%ecx
  8004c1:	89 d3                	mov    %edx,%ebx
  8004c3:	89 d7                	mov    %edx,%edi
  8004c5:	89 d6                	mov    %edx,%esi
  8004c7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8004c9:	5b                   	pop    %ebx
  8004ca:	5e                   	pop    %esi
  8004cb:	5f                   	pop    %edi
  8004cc:	5d                   	pop    %ebp
  8004cd:	c3                   	ret    
  8004ce:	66 90                	xchg   %ax,%ax

008004d0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	56                   	push   %esi
  8004d4:	53                   	push   %ebx
  8004d5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004db:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8004e1:	e8 c9 ff ff ff       	call   8004af <sys_getenvid>
  8004e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004e9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8004f0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f4:	89 74 24 08          	mov    %esi,0x8(%esp)
  8004f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004fc:	c7 04 24 58 0e 80 00 	movl   $0x800e58,(%esp)
  800503:	e8 c2 00 00 00       	call   8005ca <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800508:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80050c:	8b 45 10             	mov    0x10(%ebp),%eax
  80050f:	89 04 24             	mov    %eax,(%esp)
  800512:	e8 52 00 00 00       	call   800569 <vcprintf>
	cprintf("\n");
  800517:	c7 04 24 7c 0e 80 00 	movl   $0x800e7c,(%esp)
  80051e:	e8 a7 00 00 00       	call   8005ca <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800523:	cc                   	int3   
  800524:	eb fd                	jmp    800523 <_panic+0x53>
  800526:	66 90                	xchg   %ax,%ax

00800528 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800528:	55                   	push   %ebp
  800529:	89 e5                	mov    %esp,%ebp
  80052b:	53                   	push   %ebx
  80052c:	83 ec 14             	sub    $0x14,%esp
  80052f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800532:	8b 13                	mov    (%ebx),%edx
  800534:	8d 42 01             	lea    0x1(%edx),%eax
  800537:	89 03                	mov    %eax,(%ebx)
  800539:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80053c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800540:	3d ff 00 00 00       	cmp    $0xff,%eax
  800545:	75 19                	jne    800560 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800547:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80054e:	00 
  80054f:	8d 43 08             	lea    0x8(%ebx),%eax
  800552:	89 04 24             	mov    %eax,(%esp)
  800555:	e8 c6 fe ff ff       	call   800420 <sys_cputs>
		b->idx = 0;
  80055a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800560:	ff 43 04             	incl   0x4(%ebx)
}
  800563:	83 c4 14             	add    $0x14,%esp
  800566:	5b                   	pop    %ebx
  800567:	5d                   	pop    %ebp
  800568:	c3                   	ret    

00800569 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800569:	55                   	push   %ebp
  80056a:	89 e5                	mov    %esp,%ebp
  80056c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800572:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800579:	00 00 00 
	b.cnt = 0;
  80057c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800583:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800586:	8b 45 0c             	mov    0xc(%ebp),%eax
  800589:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80058d:	8b 45 08             	mov    0x8(%ebp),%eax
  800590:	89 44 24 08          	mov    %eax,0x8(%esp)
  800594:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80059a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059e:	c7 04 24 28 05 80 00 	movl   $0x800528,(%esp)
  8005a5:	e8 a9 01 00 00       	call   800753 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005aa:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8005b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005ba:	89 04 24             	mov    %eax,(%esp)
  8005bd:	e8 5e fe ff ff       	call   800420 <sys_cputs>

	return b.cnt;
}
  8005c2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005c8:	c9                   	leave  
  8005c9:	c3                   	ret    

008005ca <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005ca:	55                   	push   %ebp
  8005cb:	89 e5                	mov    %esp,%ebp
  8005cd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005d0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005da:	89 04 24             	mov    %eax,(%esp)
  8005dd:	e8 87 ff ff ff       	call   800569 <vcprintf>
	va_end(ap);

	return cnt;
}
  8005e2:	c9                   	leave  
  8005e3:	c3                   	ret    

008005e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005e4:	55                   	push   %ebp
  8005e5:	89 e5                	mov    %esp,%ebp
  8005e7:	57                   	push   %edi
  8005e8:	56                   	push   %esi
  8005e9:	53                   	push   %ebx
  8005ea:	83 ec 3c             	sub    $0x3c,%esp
  8005ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005f0:	89 d7                	mov    %edx,%edi
  8005f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005fb:	89 c1                	mov    %eax,%ecx
  8005fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800600:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800603:	8b 45 10             	mov    0x10(%ebp),%eax
  800606:	ba 00 00 00 00       	mov    $0x0,%edx
  80060b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800611:	39 ca                	cmp    %ecx,%edx
  800613:	72 08                	jb     80061d <printnum+0x39>
  800615:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800618:	39 45 10             	cmp    %eax,0x10(%ebp)
  80061b:	77 6a                	ja     800687 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80061d:	8b 45 18             	mov    0x18(%ebp),%eax
  800620:	89 44 24 10          	mov    %eax,0x10(%esp)
  800624:	4e                   	dec    %esi
  800625:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800629:	8b 45 10             	mov    0x10(%ebp),%eax
  80062c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800630:	8b 44 24 08          	mov    0x8(%esp),%eax
  800634:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800638:	89 c3                	mov    %eax,%ebx
  80063a:	89 d6                	mov    %edx,%esi
  80063c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800642:	89 44 24 08          	mov    %eax,0x8(%esp)
  800646:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80064a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80064d:	89 04 24             	mov    %eax,(%esp)
  800650:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800653:	89 44 24 04          	mov    %eax,0x4(%esp)
  800657:	e8 24 05 00 00       	call   800b80 <__udivdi3>
  80065c:	89 d9                	mov    %ebx,%ecx
  80065e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800662:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800666:	89 04 24             	mov    %eax,(%esp)
  800669:	89 54 24 04          	mov    %edx,0x4(%esp)
  80066d:	89 fa                	mov    %edi,%edx
  80066f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800672:	e8 6d ff ff ff       	call   8005e4 <printnum>
  800677:	eb 19                	jmp    800692 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800679:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067d:	8b 45 18             	mov    0x18(%ebp),%eax
  800680:	89 04 24             	mov    %eax,(%esp)
  800683:	ff d3                	call   *%ebx
  800685:	eb 03                	jmp    80068a <printnum+0xa6>
  800687:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80068a:	4e                   	dec    %esi
  80068b:	85 f6                	test   %esi,%esi
  80068d:	7f ea                	jg     800679 <printnum+0x95>
  80068f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800692:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800696:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80069a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80069d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ab:	89 04 24             	mov    %eax,(%esp)
  8006ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b5:	e8 f6 05 00 00       	call   800cb0 <__umoddi3>
  8006ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006be:	0f be 80 7e 0e 80 00 	movsbl 0x800e7e(%eax),%eax
  8006c5:	89 04 24             	mov    %eax,(%esp)
  8006c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006cb:	ff d0                	call   *%eax
}
  8006cd:	83 c4 3c             	add    $0x3c,%esp
  8006d0:	5b                   	pop    %ebx
  8006d1:	5e                   	pop    %esi
  8006d2:	5f                   	pop    %edi
  8006d3:	5d                   	pop    %ebp
  8006d4:	c3                   	ret    

008006d5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006d8:	83 fa 01             	cmp    $0x1,%edx
  8006db:	7e 0e                	jle    8006eb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8006dd:	8b 10                	mov    (%eax),%edx
  8006df:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006e2:	89 08                	mov    %ecx,(%eax)
  8006e4:	8b 02                	mov    (%edx),%eax
  8006e6:	8b 52 04             	mov    0x4(%edx),%edx
  8006e9:	eb 22                	jmp    80070d <getuint+0x38>
	else if (lflag)
  8006eb:	85 d2                	test   %edx,%edx
  8006ed:	74 10                	je     8006ff <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006ef:	8b 10                	mov    (%eax),%edx
  8006f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006f4:	89 08                	mov    %ecx,(%eax)
  8006f6:	8b 02                	mov    (%edx),%eax
  8006f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8006fd:	eb 0e                	jmp    80070d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006ff:	8b 10                	mov    (%eax),%edx
  800701:	8d 4a 04             	lea    0x4(%edx),%ecx
  800704:	89 08                	mov    %ecx,(%eax)
  800706:	8b 02                	mov    (%edx),%eax
  800708:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80070d:	5d                   	pop    %ebp
  80070e:	c3                   	ret    

0080070f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800715:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800718:	8b 10                	mov    (%eax),%edx
  80071a:	3b 50 04             	cmp    0x4(%eax),%edx
  80071d:	73 0a                	jae    800729 <sprintputch+0x1a>
		*b->buf++ = ch;
  80071f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800722:	89 08                	mov    %ecx,(%eax)
  800724:	8b 45 08             	mov    0x8(%ebp),%eax
  800727:	88 02                	mov    %al,(%edx)
}
  800729:	5d                   	pop    %ebp
  80072a:	c3                   	ret    

0080072b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800731:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800734:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800738:	8b 45 10             	mov    0x10(%ebp),%eax
  80073b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80073f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800742:	89 44 24 04          	mov    %eax,0x4(%esp)
  800746:	8b 45 08             	mov    0x8(%ebp),%eax
  800749:	89 04 24             	mov    %eax,(%esp)
  80074c:	e8 02 00 00 00       	call   800753 <vprintfmt>
	va_end(ap);
}
  800751:	c9                   	leave  
  800752:	c3                   	ret    

00800753 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	57                   	push   %edi
  800757:	56                   	push   %esi
  800758:	53                   	push   %ebx
  800759:	83 ec 3c             	sub    $0x3c,%esp
  80075c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80075f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800762:	eb 14                	jmp    800778 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800764:	85 c0                	test   %eax,%eax
  800766:	0f 84 8a 03 00 00    	je     800af6 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  80076c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800770:	89 04 24             	mov    %eax,(%esp)
  800773:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800776:	89 f3                	mov    %esi,%ebx
  800778:	8d 73 01             	lea    0x1(%ebx),%esi
  80077b:	31 c0                	xor    %eax,%eax
  80077d:	8a 03                	mov    (%ebx),%al
  80077f:	83 f8 25             	cmp    $0x25,%eax
  800782:	75 e0                	jne    800764 <vprintfmt+0x11>
  800784:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800788:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80078f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800796:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80079d:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a2:	eb 1d                	jmp    8007c1 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a4:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8007a6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8007aa:	eb 15                	jmp    8007c1 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ac:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007ae:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8007b2:	eb 0d                	jmp    8007c1 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8007b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007b7:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8007ba:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c1:	8d 5e 01             	lea    0x1(%esi),%ebx
  8007c4:	31 c0                	xor    %eax,%eax
  8007c6:	8a 06                	mov    (%esi),%al
  8007c8:	8a 0e                	mov    (%esi),%cl
  8007ca:	83 e9 23             	sub    $0x23,%ecx
  8007cd:	88 4d e0             	mov    %cl,-0x20(%ebp)
  8007d0:	80 f9 55             	cmp    $0x55,%cl
  8007d3:	0f 87 ff 02 00 00    	ja     800ad8 <vprintfmt+0x385>
  8007d9:	31 c9                	xor    %ecx,%ecx
  8007db:	8a 4d e0             	mov    -0x20(%ebp),%cl
  8007de:	ff 24 8d 20 0f 80 00 	jmp    *0x800f20(,%ecx,4)
  8007e5:	89 de                	mov    %ebx,%esi
  8007e7:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8007ec:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8007ef:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8007f3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8007f6:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8007f9:	83 fb 09             	cmp    $0x9,%ebx
  8007fc:	77 2f                	ja     80082d <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007fe:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007ff:	eb eb                	jmp    8007ec <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800801:	8b 45 14             	mov    0x14(%ebp),%eax
  800804:	8d 48 04             	lea    0x4(%eax),%ecx
  800807:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80080a:	8b 00                	mov    (%eax),%eax
  80080c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800811:	eb 1d                	jmp    800830 <vprintfmt+0xdd>
  800813:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800816:	f7 d0                	not    %eax
  800818:	c1 f8 1f             	sar    $0x1f,%eax
  80081b:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081e:	89 de                	mov    %ebx,%esi
  800820:	eb 9f                	jmp    8007c1 <vprintfmt+0x6e>
  800822:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800824:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80082b:	eb 94                	jmp    8007c1 <vprintfmt+0x6e>
  80082d:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800830:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800834:	79 8b                	jns    8007c1 <vprintfmt+0x6e>
  800836:	e9 79 ff ff ff       	jmp    8007b4 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80083b:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083c:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80083e:	eb 81                	jmp    8007c1 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800840:	8b 45 14             	mov    0x14(%ebp),%eax
  800843:	8d 50 04             	lea    0x4(%eax),%edx
  800846:	89 55 14             	mov    %edx,0x14(%ebp)
  800849:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80084d:	8b 00                	mov    (%eax),%eax
  80084f:	89 04 24             	mov    %eax,(%esp)
  800852:	ff 55 08             	call   *0x8(%ebp)
			break;
  800855:	e9 1e ff ff ff       	jmp    800778 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80085a:	8b 45 14             	mov    0x14(%ebp),%eax
  80085d:	8d 50 04             	lea    0x4(%eax),%edx
  800860:	89 55 14             	mov    %edx,0x14(%ebp)
  800863:	8b 00                	mov    (%eax),%eax
  800865:	89 c2                	mov    %eax,%edx
  800867:	c1 fa 1f             	sar    $0x1f,%edx
  80086a:	31 d0                	xor    %edx,%eax
  80086c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80086e:	83 f8 07             	cmp    $0x7,%eax
  800871:	7f 0b                	jg     80087e <vprintfmt+0x12b>
  800873:	8b 14 85 80 10 80 00 	mov    0x801080(,%eax,4),%edx
  80087a:	85 d2                	test   %edx,%edx
  80087c:	75 20                	jne    80089e <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  80087e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800882:	c7 44 24 08 96 0e 80 	movl   $0x800e96,0x8(%esp)
  800889:	00 
  80088a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	89 04 24             	mov    %eax,(%esp)
  800894:	e8 92 fe ff ff       	call   80072b <printfmt>
  800899:	e9 da fe ff ff       	jmp    800778 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80089e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008a2:	c7 44 24 08 9f 0e 80 	movl   $0x800e9f,0x8(%esp)
  8008a9:	00 
  8008aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b1:	89 04 24             	mov    %eax,(%esp)
  8008b4:	e8 72 fe ff ff       	call   80072b <printfmt>
  8008b9:	e9 ba fe ff ff       	jmp    800778 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008be:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8008c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8008c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ca:	8d 50 04             	lea    0x4(%eax),%edx
  8008cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d0:	8b 30                	mov    (%eax),%esi
  8008d2:	85 f6                	test   %esi,%esi
  8008d4:	75 05                	jne    8008db <vprintfmt+0x188>
				p = "(null)";
  8008d6:	be 8f 0e 80 00       	mov    $0x800e8f,%esi
			if (width > 0 && padc != '-')
  8008db:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8008df:	0f 84 8c 00 00 00    	je     800971 <vprintfmt+0x21e>
  8008e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008e9:	0f 8e 8a 00 00 00    	jle    800979 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008ef:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008f3:	89 34 24             	mov    %esi,(%esp)
  8008f6:	e8 cf f7 ff ff       	call   8000ca <strnlen>
  8008fb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008fe:	29 c1                	sub    %eax,%ecx
  800900:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800903:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800907:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80090a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  80090d:	8b 75 08             	mov    0x8(%ebp),%esi
  800910:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800913:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800915:	eb 0d                	jmp    800924 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800917:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80091b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80091e:	89 04 24             	mov    %eax,(%esp)
  800921:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800923:	4b                   	dec    %ebx
  800924:	85 db                	test   %ebx,%ebx
  800926:	7f ef                	jg     800917 <vprintfmt+0x1c4>
  800928:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80092b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80092e:	89 c8                	mov    %ecx,%eax
  800930:	f7 d0                	not    %eax
  800932:	c1 f8 1f             	sar    $0x1f,%eax
  800935:	21 c8                	and    %ecx,%eax
  800937:	29 c1                	sub    %eax,%ecx
  800939:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80093c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80093f:	eb 3e                	jmp    80097f <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800941:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800945:	74 1b                	je     800962 <vprintfmt+0x20f>
  800947:	0f be d2             	movsbl %dl,%edx
  80094a:	83 ea 20             	sub    $0x20,%edx
  80094d:	83 fa 5e             	cmp    $0x5e,%edx
  800950:	76 10                	jbe    800962 <vprintfmt+0x20f>
					putch('?', putdat);
  800952:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800956:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80095d:	ff 55 08             	call   *0x8(%ebp)
  800960:	eb 0a                	jmp    80096c <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800962:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800966:	89 04 24             	mov    %eax,(%esp)
  800969:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80096c:	ff 4d dc             	decl   -0x24(%ebp)
  80096f:	eb 0e                	jmp    80097f <vprintfmt+0x22c>
  800971:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800974:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800977:	eb 06                	jmp    80097f <vprintfmt+0x22c>
  800979:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80097c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80097f:	46                   	inc    %esi
  800980:	8a 56 ff             	mov    -0x1(%esi),%dl
  800983:	0f be c2             	movsbl %dl,%eax
  800986:	85 c0                	test   %eax,%eax
  800988:	74 1f                	je     8009a9 <vprintfmt+0x256>
  80098a:	85 db                	test   %ebx,%ebx
  80098c:	78 b3                	js     800941 <vprintfmt+0x1ee>
  80098e:	4b                   	dec    %ebx
  80098f:	79 b0                	jns    800941 <vprintfmt+0x1ee>
  800991:	8b 75 08             	mov    0x8(%ebp),%esi
  800994:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800997:	eb 16                	jmp    8009af <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800999:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80099d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009a4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009a6:	4b                   	dec    %ebx
  8009a7:	eb 06                	jmp    8009af <vprintfmt+0x25c>
  8009a9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8009ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8009af:	85 db                	test   %ebx,%ebx
  8009b1:	7f e6                	jg     800999 <vprintfmt+0x246>
  8009b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8009b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009b9:	e9 ba fd ff ff       	jmp    800778 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009be:	83 fa 01             	cmp    $0x1,%edx
  8009c1:	7e 16                	jle    8009d9 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  8009c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c6:	8d 50 08             	lea    0x8(%eax),%edx
  8009c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8009cc:	8b 50 04             	mov    0x4(%eax),%edx
  8009cf:	8b 00                	mov    (%eax),%eax
  8009d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009d4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009d7:	eb 32                	jmp    800a0b <vprintfmt+0x2b8>
	else if (lflag)
  8009d9:	85 d2                	test   %edx,%edx
  8009db:	74 18                	je     8009f5 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  8009dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e0:	8d 50 04             	lea    0x4(%eax),%edx
  8009e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8009e6:	8b 30                	mov    (%eax),%esi
  8009e8:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8009eb:	89 f0                	mov    %esi,%eax
  8009ed:	c1 f8 1f             	sar    $0x1f,%eax
  8009f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009f3:	eb 16                	jmp    800a0b <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  8009f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f8:	8d 50 04             	lea    0x4(%eax),%edx
  8009fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8009fe:	8b 30                	mov    (%eax),%esi
  800a00:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800a03:	89 f0                	mov    %esi,%eax
  800a05:	c1 f8 1f             	sar    $0x1f,%eax
  800a08:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a0e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a11:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a16:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a1a:	0f 89 80 00 00 00    	jns    800aa0 <vprintfmt+0x34d>
				putch('-', putdat);
  800a20:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a24:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a2b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a31:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a34:	f7 d8                	neg    %eax
  800a36:	83 d2 00             	adc    $0x0,%edx
  800a39:	f7 da                	neg    %edx
			}
			base = 10;
  800a3b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a40:	eb 5e                	jmp    800aa0 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a42:	8d 45 14             	lea    0x14(%ebp),%eax
  800a45:	e8 8b fc ff ff       	call   8006d5 <getuint>
			base = 10;
  800a4a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a4f:	eb 4f                	jmp    800aa0 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800a51:	8d 45 14             	lea    0x14(%ebp),%eax
  800a54:	e8 7c fc ff ff       	call   8006d5 <getuint>
			base = 8;
  800a59:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800a5e:	eb 40                	jmp    800aa0 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800a60:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a64:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a6b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a6e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a72:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a79:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a7c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7f:	8d 50 04             	lea    0x4(%eax),%edx
  800a82:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a85:	8b 00                	mov    (%eax),%eax
  800a87:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a8c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a91:	eb 0d                	jmp    800aa0 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a93:	8d 45 14             	lea    0x14(%ebp),%eax
  800a96:	e8 3a fc ff ff       	call   8006d5 <getuint>
			base = 16;
  800a9b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800aa0:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800aa4:	89 74 24 10          	mov    %esi,0x10(%esp)
  800aa8:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800aab:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800aaf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ab3:	89 04 24             	mov    %eax,(%esp)
  800ab6:	89 54 24 04          	mov    %edx,0x4(%esp)
  800aba:	89 fa                	mov    %edi,%edx
  800abc:	8b 45 08             	mov    0x8(%ebp),%eax
  800abf:	e8 20 fb ff ff       	call   8005e4 <printnum>
			break;
  800ac4:	e9 af fc ff ff       	jmp    800778 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ac9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800acd:	89 04 24             	mov    %eax,(%esp)
  800ad0:	ff 55 08             	call   *0x8(%ebp)
			break;
  800ad3:	e9 a0 fc ff ff       	jmp    800778 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ad8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800adc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ae3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ae6:	89 f3                	mov    %esi,%ebx
  800ae8:	eb 01                	jmp    800aeb <vprintfmt+0x398>
  800aea:	4b                   	dec    %ebx
  800aeb:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800aef:	75 f9                	jne    800aea <vprintfmt+0x397>
  800af1:	e9 82 fc ff ff       	jmp    800778 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800af6:	83 c4 3c             	add    $0x3c,%esp
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	83 ec 28             	sub    $0x28,%esp
  800b04:	8b 45 08             	mov    0x8(%ebp),%eax
  800b07:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b0a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b0d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b11:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b14:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	74 30                	je     800b4f <vsnprintf+0x51>
  800b1f:	85 d2                	test   %edx,%edx
  800b21:	7e 2c                	jle    800b4f <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b23:	8b 45 14             	mov    0x14(%ebp),%eax
  800b26:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b2a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b31:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b34:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b38:	c7 04 24 0f 07 80 00 	movl   $0x80070f,(%esp)
  800b3f:	e8 0f fc ff ff       	call   800753 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b44:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b47:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b4d:	eb 05                	jmp    800b54 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b4f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b54:	c9                   	leave  
  800b55:	c3                   	ret    

00800b56 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b5c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b63:	8b 45 10             	mov    0x10(%ebp),%eax
  800b66:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b71:	8b 45 08             	mov    0x8(%ebp),%eax
  800b74:	89 04 24             	mov    %eax,(%esp)
  800b77:	e8 82 ff ff ff       	call   800afe <vsnprintf>
	va_end(ap);

	return rc;
}
  800b7c:	c9                   	leave  
  800b7d:	c3                   	ret    
  800b7e:	66 90                	xchg   %ax,%ax

00800b80 <__udivdi3>:
  800b80:	55                   	push   %ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	83 ec 0c             	sub    $0xc,%esp
  800b86:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800b8a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800b8e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800b92:	8b 44 24 28          	mov    0x28(%esp),%eax
  800b96:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b9a:	89 ea                	mov    %ebp,%edx
  800b9c:	89 0c 24             	mov    %ecx,(%esp)
  800b9f:	85 c0                	test   %eax,%eax
  800ba1:	75 2d                	jne    800bd0 <__udivdi3+0x50>
  800ba3:	39 e9                	cmp    %ebp,%ecx
  800ba5:	77 61                	ja     800c08 <__udivdi3+0x88>
  800ba7:	89 ce                	mov    %ecx,%esi
  800ba9:	85 c9                	test   %ecx,%ecx
  800bab:	75 0b                	jne    800bb8 <__udivdi3+0x38>
  800bad:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb2:	31 d2                	xor    %edx,%edx
  800bb4:	f7 f1                	div    %ecx
  800bb6:	89 c6                	mov    %eax,%esi
  800bb8:	31 d2                	xor    %edx,%edx
  800bba:	89 e8                	mov    %ebp,%eax
  800bbc:	f7 f6                	div    %esi
  800bbe:	89 c5                	mov    %eax,%ebp
  800bc0:	89 f8                	mov    %edi,%eax
  800bc2:	f7 f6                	div    %esi
  800bc4:	89 ea                	mov    %ebp,%edx
  800bc6:	83 c4 0c             	add    $0xc,%esp
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    
  800bcd:	8d 76 00             	lea    0x0(%esi),%esi
  800bd0:	39 e8                	cmp    %ebp,%eax
  800bd2:	77 24                	ja     800bf8 <__udivdi3+0x78>
  800bd4:	0f bd e8             	bsr    %eax,%ebp
  800bd7:	83 f5 1f             	xor    $0x1f,%ebp
  800bda:	75 3c                	jne    800c18 <__udivdi3+0x98>
  800bdc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800be0:	39 34 24             	cmp    %esi,(%esp)
  800be3:	0f 86 9f 00 00 00    	jbe    800c88 <__udivdi3+0x108>
  800be9:	39 d0                	cmp    %edx,%eax
  800beb:	0f 82 97 00 00 00    	jb     800c88 <__udivdi3+0x108>
  800bf1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800bf8:	31 d2                	xor    %edx,%edx
  800bfa:	31 c0                	xor    %eax,%eax
  800bfc:	83 c4 0c             	add    $0xc,%esp
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    
  800c03:	90                   	nop
  800c04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c08:	89 f8                	mov    %edi,%eax
  800c0a:	f7 f1                	div    %ecx
  800c0c:	31 d2                	xor    %edx,%edx
  800c0e:	83 c4 0c             	add    $0xc,%esp
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    
  800c15:	8d 76 00             	lea    0x0(%esi),%esi
  800c18:	89 e9                	mov    %ebp,%ecx
  800c1a:	8b 3c 24             	mov    (%esp),%edi
  800c1d:	d3 e0                	shl    %cl,%eax
  800c1f:	89 c6                	mov    %eax,%esi
  800c21:	b8 20 00 00 00       	mov    $0x20,%eax
  800c26:	29 e8                	sub    %ebp,%eax
  800c28:	88 c1                	mov    %al,%cl
  800c2a:	d3 ef                	shr    %cl,%edi
  800c2c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c30:	89 e9                	mov    %ebp,%ecx
  800c32:	8b 3c 24             	mov    (%esp),%edi
  800c35:	09 74 24 08          	or     %esi,0x8(%esp)
  800c39:	d3 e7                	shl    %cl,%edi
  800c3b:	89 d6                	mov    %edx,%esi
  800c3d:	88 c1                	mov    %al,%cl
  800c3f:	d3 ee                	shr    %cl,%esi
  800c41:	89 e9                	mov    %ebp,%ecx
  800c43:	89 3c 24             	mov    %edi,(%esp)
  800c46:	d3 e2                	shl    %cl,%edx
  800c48:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c4c:	88 c1                	mov    %al,%cl
  800c4e:	d3 ef                	shr    %cl,%edi
  800c50:	09 d7                	or     %edx,%edi
  800c52:	89 f2                	mov    %esi,%edx
  800c54:	89 f8                	mov    %edi,%eax
  800c56:	f7 74 24 08          	divl   0x8(%esp)
  800c5a:	89 d6                	mov    %edx,%esi
  800c5c:	89 c7                	mov    %eax,%edi
  800c5e:	f7 24 24             	mull   (%esp)
  800c61:	89 14 24             	mov    %edx,(%esp)
  800c64:	39 d6                	cmp    %edx,%esi
  800c66:	72 30                	jb     800c98 <__udivdi3+0x118>
  800c68:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c6c:	89 e9                	mov    %ebp,%ecx
  800c6e:	d3 e2                	shl    %cl,%edx
  800c70:	39 c2                	cmp    %eax,%edx
  800c72:	73 05                	jae    800c79 <__udivdi3+0xf9>
  800c74:	3b 34 24             	cmp    (%esp),%esi
  800c77:	74 1f                	je     800c98 <__udivdi3+0x118>
  800c79:	89 f8                	mov    %edi,%eax
  800c7b:	31 d2                	xor    %edx,%edx
  800c7d:	e9 7a ff ff ff       	jmp    800bfc <__udivdi3+0x7c>
  800c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c88:	31 d2                	xor    %edx,%edx
  800c8a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8f:	e9 68 ff ff ff       	jmp    800bfc <__udivdi3+0x7c>
  800c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c98:	8d 47 ff             	lea    -0x1(%edi),%eax
  800c9b:	31 d2                	xor    %edx,%edx
  800c9d:	83 c4 0c             	add    $0xc,%esp
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    
  800ca4:	66 90                	xchg   %ax,%ax
  800ca6:	66 90                	xchg   %ax,%ax
  800ca8:	66 90                	xchg   %ax,%ax
  800caa:	66 90                	xchg   %ax,%ax
  800cac:	66 90                	xchg   %ax,%ax
  800cae:	66 90                	xchg   %ax,%ax

00800cb0 <__umoddi3>:
  800cb0:	55                   	push   %ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	83 ec 14             	sub    $0x14,%esp
  800cb6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800cba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800cbe:	89 c7                	mov    %eax,%edi
  800cc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800cc8:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ccc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800cd0:	89 34 24             	mov    %esi,(%esp)
  800cd3:	89 c2                	mov    %eax,%edx
  800cd5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cd9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	75 17                	jne    800cf8 <__umoddi3+0x48>
  800ce1:	39 fe                	cmp    %edi,%esi
  800ce3:	76 4b                	jbe    800d30 <__umoddi3+0x80>
  800ce5:	89 c8                	mov    %ecx,%eax
  800ce7:	89 fa                	mov    %edi,%edx
  800ce9:	f7 f6                	div    %esi
  800ceb:	89 d0                	mov    %edx,%eax
  800ced:	31 d2                	xor    %edx,%edx
  800cef:	83 c4 14             	add    $0x14,%esp
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    
  800cf6:	66 90                	xchg   %ax,%ax
  800cf8:	39 f8                	cmp    %edi,%eax
  800cfa:	77 54                	ja     800d50 <__umoddi3+0xa0>
  800cfc:	0f bd e8             	bsr    %eax,%ebp
  800cff:	83 f5 1f             	xor    $0x1f,%ebp
  800d02:	75 5c                	jne    800d60 <__umoddi3+0xb0>
  800d04:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d08:	39 3c 24             	cmp    %edi,(%esp)
  800d0b:	0f 87 f7 00 00 00    	ja     800e08 <__umoddi3+0x158>
  800d11:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d15:	29 f1                	sub    %esi,%ecx
  800d17:	19 c7                	sbb    %eax,%edi
  800d19:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d1d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d21:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d25:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d29:	83 c4 14             	add    $0x14,%esp
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    
  800d30:	89 f5                	mov    %esi,%ebp
  800d32:	85 f6                	test   %esi,%esi
  800d34:	75 0b                	jne    800d41 <__umoddi3+0x91>
  800d36:	b8 01 00 00 00       	mov    $0x1,%eax
  800d3b:	31 d2                	xor    %edx,%edx
  800d3d:	f7 f6                	div    %esi
  800d3f:	89 c5                	mov    %eax,%ebp
  800d41:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d45:	31 d2                	xor    %edx,%edx
  800d47:	f7 f5                	div    %ebp
  800d49:	89 c8                	mov    %ecx,%eax
  800d4b:	f7 f5                	div    %ebp
  800d4d:	eb 9c                	jmp    800ceb <__umoddi3+0x3b>
  800d4f:	90                   	nop
  800d50:	89 c8                	mov    %ecx,%eax
  800d52:	89 fa                	mov    %edi,%edx
  800d54:	83 c4 14             	add    $0x14,%esp
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    
  800d5b:	90                   	nop
  800d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d60:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800d67:	00 
  800d68:	8b 34 24             	mov    (%esp),%esi
  800d6b:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d6f:	89 e9                	mov    %ebp,%ecx
  800d71:	29 e8                	sub    %ebp,%eax
  800d73:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d77:	89 f0                	mov    %esi,%eax
  800d79:	d3 e2                	shl    %cl,%edx
  800d7b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800d7f:	d3 e8                	shr    %cl,%eax
  800d81:	89 04 24             	mov    %eax,(%esp)
  800d84:	89 e9                	mov    %ebp,%ecx
  800d86:	89 f0                	mov    %esi,%eax
  800d88:	09 14 24             	or     %edx,(%esp)
  800d8b:	d3 e0                	shl    %cl,%eax
  800d8d:	89 fa                	mov    %edi,%edx
  800d8f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800d93:	d3 ea                	shr    %cl,%edx
  800d95:	89 e9                	mov    %ebp,%ecx
  800d97:	89 c6                	mov    %eax,%esi
  800d99:	d3 e7                	shl    %cl,%edi
  800d9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d9f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800da3:	8b 44 24 10          	mov    0x10(%esp),%eax
  800da7:	d3 e8                	shr    %cl,%eax
  800da9:	09 f8                	or     %edi,%eax
  800dab:	89 e9                	mov    %ebp,%ecx
  800dad:	8b 7c 24 10          	mov    0x10(%esp),%edi
  800db1:	d3 e7                	shl    %cl,%edi
  800db3:	f7 34 24             	divl   (%esp)
  800db6:	89 d1                	mov    %edx,%ecx
  800db8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dbc:	f7 e6                	mul    %esi
  800dbe:	89 c7                	mov    %eax,%edi
  800dc0:	89 d6                	mov    %edx,%esi
  800dc2:	39 d1                	cmp    %edx,%ecx
  800dc4:	72 2e                	jb     800df4 <__umoddi3+0x144>
  800dc6:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800dca:	72 24                	jb     800df0 <__umoddi3+0x140>
  800dcc:	89 ca                	mov    %ecx,%edx
  800dce:	89 e9                	mov    %ebp,%ecx
  800dd0:	8b 44 24 08          	mov    0x8(%esp),%eax
  800dd4:	29 f8                	sub    %edi,%eax
  800dd6:	19 f2                	sbb    %esi,%edx
  800dd8:	d3 e8                	shr    %cl,%eax
  800dda:	89 d6                	mov    %edx,%esi
  800ddc:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800de0:	d3 e6                	shl    %cl,%esi
  800de2:	89 e9                	mov    %ebp,%ecx
  800de4:	09 f0                	or     %esi,%eax
  800de6:	d3 ea                	shr    %cl,%edx
  800de8:	83 c4 14             	add    $0x14,%esp
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    
  800def:	90                   	nop
  800df0:	39 d1                	cmp    %edx,%ecx
  800df2:	75 d8                	jne    800dcc <__umoddi3+0x11c>
  800df4:	89 d6                	mov    %edx,%esi
  800df6:	89 c7                	mov    %eax,%edi
  800df8:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  800dfc:	1b 34 24             	sbb    (%esp),%esi
  800dff:	eb cb                	jmp    800dcc <__umoddi3+0x11c>
  800e01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e08:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  800e0c:	0f 82 ff fe ff ff    	jb     800d11 <__umoddi3+0x61>
  800e12:	e9 0a ff ff ff       	jmp    800d21 <__umoddi3+0x71>
