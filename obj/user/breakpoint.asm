
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $3");
  800037:	cc                   	int3   
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    
  80003a:	66 90                	xchg   %ax,%ax

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	56                   	push   %esi
  800040:	53                   	push   %ebx
  800041:	83 ec 10             	sub    $0x10,%esp
  800044:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800047:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  80004a:	b8 08 20 80 00       	mov    $0x802008,%eax
  80004f:	2d 04 20 80 00       	sub    $0x802004,%eax
  800054:	89 44 24 08          	mov    %eax,0x8(%esp)
  800058:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80005f:	00 
  800060:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  800067:	e8 bb 01 00 00       	call   800227 <memset>

	thisenv = 0;
	thisenv = &envs[0];
  80006c:	c7 05 04 20 80 00 00 	movl   $0xeec00000,0x802004
  800073:	00 c0 ee 
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x45>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800081:	89 74 24 04          	mov    %esi,0x4(%esp)
  800085:	89 1c 24             	mov    %ebx,(%esp)
  800088:	e8 a7 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008d:	e8 0a 00 00 00       	call   80009c <exit>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	5b                   	pop    %ebx
  800096:	5e                   	pop    %esi
  800097:	5d                   	pop    %ebp
  800098:	c3                   	ret    
  800099:	66 90                	xchg   %ax,%ax
  80009b:	90                   	nop

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a9:	e8 ab 03 00 00       	call   800459 <sys_env_destroy>
}
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8000b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bb:	eb 01                	jmp    8000be <strlen+0xe>
		n++;
  8000bd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8000be:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8000c2:	75 f9                	jne    8000bd <strlen+0xd>
		n++;
	return n;
}
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8000cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d4:	eb 01                	jmp    8000d7 <strnlen+0x11>
		n++;
  8000d6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8000d7:	39 d0                	cmp    %edx,%eax
  8000d9:	74 06                	je     8000e1 <strnlen+0x1b>
  8000db:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8000df:	75 f5                	jne    8000d6 <strnlen+0x10>
		n++;
	return n;
}
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	53                   	push   %ebx
  8000e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8000ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8000ed:	89 c2                	mov    %eax,%edx
  8000ef:	42                   	inc    %edx
  8000f0:	41                   	inc    %ecx
  8000f1:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8000f4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8000f7:	84 db                	test   %bl,%bl
  8000f9:	75 f4                	jne    8000ef <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8000fb:	5b                   	pop    %ebx
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <strcat>:

char *
strcat(char *dst, const char *src)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	53                   	push   %ebx
  800102:	83 ec 08             	sub    $0x8,%esp
  800105:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800108:	89 1c 24             	mov    %ebx,(%esp)
  80010b:	e8 a0 ff ff ff       	call   8000b0 <strlen>
	strcpy(dst + len, src);
  800110:	8b 55 0c             	mov    0xc(%ebp),%edx
  800113:	89 54 24 04          	mov    %edx,0x4(%esp)
  800117:	01 d8                	add    %ebx,%eax
  800119:	89 04 24             	mov    %eax,(%esp)
  80011c:	e8 c2 ff ff ff       	call   8000e3 <strcpy>
	return dst;
}
  800121:	89 d8                	mov    %ebx,%eax
  800123:	83 c4 08             	add    $0x8,%esp
  800126:	5b                   	pop    %ebx
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    

00800129 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
  80012e:	8b 75 08             	mov    0x8(%ebp),%esi
  800131:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800134:	89 f3                	mov    %esi,%ebx
  800136:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800139:	89 f2                	mov    %esi,%edx
  80013b:	eb 0c                	jmp    800149 <strncpy+0x20>
		*dst++ = *src;
  80013d:	42                   	inc    %edx
  80013e:	8a 01                	mov    (%ecx),%al
  800140:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800143:	80 39 01             	cmpb   $0x1,(%ecx)
  800146:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800149:	39 da                	cmp    %ebx,%edx
  80014b:	75 f0                	jne    80013d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80014d:	89 f0                	mov    %esi,%eax
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	56                   	push   %esi
  800157:	53                   	push   %ebx
  800158:	8b 75 08             	mov    0x8(%ebp),%esi
  80015b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80015e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800161:	89 f0                	mov    %esi,%eax
  800163:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800167:	85 c9                	test   %ecx,%ecx
  800169:	75 07                	jne    800172 <strlcpy+0x1f>
  80016b:	eb 18                	jmp    800185 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80016d:	40                   	inc    %eax
  80016e:	42                   	inc    %edx
  80016f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800172:	39 d8                	cmp    %ebx,%eax
  800174:	74 0a                	je     800180 <strlcpy+0x2d>
  800176:	8a 0a                	mov    (%edx),%cl
  800178:	84 c9                	test   %cl,%cl
  80017a:	75 f1                	jne    80016d <strlcpy+0x1a>
  80017c:	89 c2                	mov    %eax,%edx
  80017e:	eb 02                	jmp    800182 <strlcpy+0x2f>
  800180:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800182:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800185:	29 f0                	sub    %esi,%eax
}
  800187:	5b                   	pop    %ebx
  800188:	5e                   	pop    %esi
  800189:	5d                   	pop    %ebp
  80018a:	c3                   	ret    

0080018b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800191:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800194:	eb 02                	jmp    800198 <strcmp+0xd>
		p++, q++;
  800196:	41                   	inc    %ecx
  800197:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800198:	8a 01                	mov    (%ecx),%al
  80019a:	84 c0                	test   %al,%al
  80019c:	74 04                	je     8001a2 <strcmp+0x17>
  80019e:	3a 02                	cmp    (%edx),%al
  8001a0:	74 f4                	je     800196 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8001a2:	25 ff 00 00 00       	and    $0xff,%eax
  8001a7:	8a 0a                	mov    (%edx),%cl
  8001a9:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8001af:	29 c8                	sub    %ecx,%eax
}
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    

008001b3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	53                   	push   %ebx
  8001b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bd:	89 c3                	mov    %eax,%ebx
  8001bf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8001c2:	eb 02                	jmp    8001c6 <strncmp+0x13>
		n--, p++, q++;
  8001c4:	40                   	inc    %eax
  8001c5:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8001c6:	39 d8                	cmp    %ebx,%eax
  8001c8:	74 20                	je     8001ea <strncmp+0x37>
  8001ca:	8a 08                	mov    (%eax),%cl
  8001cc:	84 c9                	test   %cl,%cl
  8001ce:	74 04                	je     8001d4 <strncmp+0x21>
  8001d0:	3a 0a                	cmp    (%edx),%cl
  8001d2:	74 f0                	je     8001c4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8001d4:	8a 18                	mov    (%eax),%bl
  8001d6:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8001dc:	89 d8                	mov    %ebx,%eax
  8001de:	8a 1a                	mov    (%edx),%bl
  8001e0:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8001e6:	29 d8                	sub    %ebx,%eax
  8001e8:	eb 05                	jmp    8001ef <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8001ea:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8001ef:	5b                   	pop    %ebx
  8001f0:	5d                   	pop    %ebp
  8001f1:	c3                   	ret    

008001f2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8001fb:	eb 05                	jmp    800202 <strchr+0x10>
		if (*s == c)
  8001fd:	38 ca                	cmp    %cl,%dl
  8001ff:	74 0c                	je     80020d <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800201:	40                   	inc    %eax
  800202:	8a 10                	mov    (%eax),%dl
  800204:	84 d2                	test   %dl,%dl
  800206:	75 f5                	jne    8001fd <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800208:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    

0080020f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	8b 45 08             	mov    0x8(%ebp),%eax
  800215:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800218:	eb 05                	jmp    80021f <strfind+0x10>
		if (*s == c)
  80021a:	38 ca                	cmp    %cl,%dl
  80021c:	74 07                	je     800225 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80021e:	40                   	inc    %eax
  80021f:	8a 10                	mov    (%eax),%dl
  800221:	84 d2                	test   %dl,%dl
  800223:	75 f5                	jne    80021a <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800225:	5d                   	pop    %ebp
  800226:	c3                   	ret    

00800227 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	57                   	push   %edi
  80022b:	56                   	push   %esi
  80022c:	53                   	push   %ebx
  80022d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800230:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800233:	85 c9                	test   %ecx,%ecx
  800235:	74 37                	je     80026e <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800237:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80023d:	75 29                	jne    800268 <memset+0x41>
  80023f:	f6 c1 03             	test   $0x3,%cl
  800242:	75 24                	jne    800268 <memset+0x41>
		c &= 0xFF;
  800244:	31 d2                	xor    %edx,%edx
  800246:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800249:	89 d3                	mov    %edx,%ebx
  80024b:	c1 e3 08             	shl    $0x8,%ebx
  80024e:	89 d6                	mov    %edx,%esi
  800250:	c1 e6 18             	shl    $0x18,%esi
  800253:	89 d0                	mov    %edx,%eax
  800255:	c1 e0 10             	shl    $0x10,%eax
  800258:	09 f0                	or     %esi,%eax
  80025a:	09 c2                	or     %eax,%edx
  80025c:	89 d0                	mov    %edx,%eax
  80025e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800260:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800263:	fc                   	cld    
  800264:	f3 ab                	rep stos %eax,%es:(%edi)
  800266:	eb 06                	jmp    80026e <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800268:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026b:	fc                   	cld    
  80026c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80026e:	89 f8                	mov    %edi,%eax
  800270:	5b                   	pop    %ebx
  800271:	5e                   	pop    %esi
  800272:	5f                   	pop    %edi
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    

00800275 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	57                   	push   %edi
  800279:	56                   	push   %esi
  80027a:	8b 45 08             	mov    0x8(%ebp),%eax
  80027d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800280:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800283:	39 c6                	cmp    %eax,%esi
  800285:	73 33                	jae    8002ba <memmove+0x45>
  800287:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80028a:	39 d0                	cmp    %edx,%eax
  80028c:	73 2c                	jae    8002ba <memmove+0x45>
		s += n;
		d += n;
  80028e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800291:	89 d6                	mov    %edx,%esi
  800293:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800295:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80029b:	75 13                	jne    8002b0 <memmove+0x3b>
  80029d:	f6 c1 03             	test   $0x3,%cl
  8002a0:	75 0e                	jne    8002b0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8002a2:	83 ef 04             	sub    $0x4,%edi
  8002a5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8002a8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8002ab:	fd                   	std    
  8002ac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8002ae:	eb 07                	jmp    8002b7 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8002b0:	4f                   	dec    %edi
  8002b1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8002b4:	fd                   	std    
  8002b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8002b7:	fc                   	cld    
  8002b8:	eb 1d                	jmp    8002d7 <memmove+0x62>
  8002ba:	89 f2                	mov    %esi,%edx
  8002bc:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8002be:	f6 c2 03             	test   $0x3,%dl
  8002c1:	75 0f                	jne    8002d2 <memmove+0x5d>
  8002c3:	f6 c1 03             	test   $0x3,%cl
  8002c6:	75 0a                	jne    8002d2 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8002c8:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8002cb:	89 c7                	mov    %eax,%edi
  8002cd:	fc                   	cld    
  8002ce:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8002d0:	eb 05                	jmp    8002d7 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8002d2:	89 c7                	mov    %eax,%edi
  8002d4:	fc                   	cld    
  8002d5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8002d7:	5e                   	pop    %esi
  8002d8:	5f                   	pop    %edi
  8002d9:	5d                   	pop    %ebp
  8002da:	c3                   	ret    

008002db <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8002e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f2:	89 04 24             	mov    %eax,(%esp)
  8002f5:	e8 7b ff ff ff       	call   800275 <memmove>
}
  8002fa:	c9                   	leave  
  8002fb:	c3                   	ret    

008002fc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	56                   	push   %esi
  800300:	53                   	push   %ebx
  800301:	8b 55 08             	mov    0x8(%ebp),%edx
  800304:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800307:	89 d6                	mov    %edx,%esi
  800309:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80030c:	eb 19                	jmp    800327 <memcmp+0x2b>
		if (*s1 != *s2)
  80030e:	8a 02                	mov    (%edx),%al
  800310:	8a 19                	mov    (%ecx),%bl
  800312:	38 d8                	cmp    %bl,%al
  800314:	74 0f                	je     800325 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800316:	25 ff 00 00 00       	and    $0xff,%eax
  80031b:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800321:	29 d8                	sub    %ebx,%eax
  800323:	eb 0b                	jmp    800330 <memcmp+0x34>
		s1++, s2++;
  800325:	42                   	inc    %edx
  800326:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800327:	39 f2                	cmp    %esi,%edx
  800329:	75 e3                	jne    80030e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80032b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800330:	5b                   	pop    %ebx
  800331:	5e                   	pop    %esi
  800332:	5d                   	pop    %ebp
  800333:	c3                   	ret    

00800334 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	8b 45 08             	mov    0x8(%ebp),%eax
  80033a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80033d:	89 c2                	mov    %eax,%edx
  80033f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800342:	eb 05                	jmp    800349 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800344:	38 08                	cmp    %cl,(%eax)
  800346:	74 05                	je     80034d <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800348:	40                   	inc    %eax
  800349:	39 d0                	cmp    %edx,%eax
  80034b:	72 f7                	jb     800344 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	57                   	push   %edi
  800353:	56                   	push   %esi
  800354:	53                   	push   %ebx
  800355:	8b 55 08             	mov    0x8(%ebp),%edx
  800358:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80035b:	eb 01                	jmp    80035e <strtol+0xf>
		s++;
  80035d:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80035e:	8a 02                	mov    (%edx),%al
  800360:	3c 09                	cmp    $0x9,%al
  800362:	74 f9                	je     80035d <strtol+0xe>
  800364:	3c 20                	cmp    $0x20,%al
  800366:	74 f5                	je     80035d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800368:	3c 2b                	cmp    $0x2b,%al
  80036a:	75 08                	jne    800374 <strtol+0x25>
		s++;
  80036c:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80036d:	bf 00 00 00 00       	mov    $0x0,%edi
  800372:	eb 10                	jmp    800384 <strtol+0x35>
  800374:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800379:	3c 2d                	cmp    $0x2d,%al
  80037b:	75 07                	jne    800384 <strtol+0x35>
		s++, neg = 1;
  80037d:	8d 52 01             	lea    0x1(%edx),%edx
  800380:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800384:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80038a:	75 15                	jne    8003a1 <strtol+0x52>
  80038c:	80 3a 30             	cmpb   $0x30,(%edx)
  80038f:	75 10                	jne    8003a1 <strtol+0x52>
  800391:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800395:	75 0a                	jne    8003a1 <strtol+0x52>
		s += 2, base = 16;
  800397:	83 c2 02             	add    $0x2,%edx
  80039a:	bb 10 00 00 00       	mov    $0x10,%ebx
  80039f:	eb 0e                	jmp    8003af <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  8003a1:	85 db                	test   %ebx,%ebx
  8003a3:	75 0a                	jne    8003af <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8003a5:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8003a7:	80 3a 30             	cmpb   $0x30,(%edx)
  8003aa:	75 03                	jne    8003af <strtol+0x60>
		s++, base = 8;
  8003ac:	42                   	inc    %edx
  8003ad:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  8003af:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8003b7:	8a 0a                	mov    (%edx),%cl
  8003b9:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8003bc:	89 f3                	mov    %esi,%ebx
  8003be:	80 fb 09             	cmp    $0x9,%bl
  8003c1:	77 08                	ja     8003cb <strtol+0x7c>
			dig = *s - '0';
  8003c3:	0f be c9             	movsbl %cl,%ecx
  8003c6:	83 e9 30             	sub    $0x30,%ecx
  8003c9:	eb 22                	jmp    8003ed <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  8003cb:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8003ce:	89 f3                	mov    %esi,%ebx
  8003d0:	80 fb 19             	cmp    $0x19,%bl
  8003d3:	77 08                	ja     8003dd <strtol+0x8e>
			dig = *s - 'a' + 10;
  8003d5:	0f be c9             	movsbl %cl,%ecx
  8003d8:	83 e9 57             	sub    $0x57,%ecx
  8003db:	eb 10                	jmp    8003ed <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  8003dd:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8003e0:	89 f3                	mov    %esi,%ebx
  8003e2:	80 fb 19             	cmp    $0x19,%bl
  8003e5:	77 14                	ja     8003fb <strtol+0xac>
			dig = *s - 'A' + 10;
  8003e7:	0f be c9             	movsbl %cl,%ecx
  8003ea:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8003ed:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  8003f0:	7d 0d                	jge    8003ff <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8003f2:	42                   	inc    %edx
  8003f3:	0f af 45 10          	imul   0x10(%ebp),%eax
  8003f7:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8003f9:	eb bc                	jmp    8003b7 <strtol+0x68>
  8003fb:	89 c1                	mov    %eax,%ecx
  8003fd:	eb 02                	jmp    800401 <strtol+0xb2>
  8003ff:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800401:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800405:	74 05                	je     80040c <strtol+0xbd>
		*endptr = (char *) s;
  800407:	8b 75 0c             	mov    0xc(%ebp),%esi
  80040a:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80040c:	85 ff                	test   %edi,%edi
  80040e:	74 04                	je     800414 <strtol+0xc5>
  800410:	89 c8                	mov    %ecx,%eax
  800412:	f7 d8                	neg    %eax
}
  800414:	5b                   	pop    %ebx
  800415:	5e                   	pop    %esi
  800416:	5f                   	pop    %edi
  800417:	5d                   	pop    %ebp
  800418:	c3                   	ret    
  800419:	66 90                	xchg   %ax,%ax
  80041b:	90                   	nop

0080041c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80041c:	55                   	push   %ebp
  80041d:	89 e5                	mov    %esp,%ebp
  80041f:	57                   	push   %edi
  800420:	56                   	push   %esi
  800421:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800422:	b8 00 00 00 00       	mov    $0x0,%eax
  800427:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042a:	8b 55 08             	mov    0x8(%ebp),%edx
  80042d:	89 c3                	mov    %eax,%ebx
  80042f:	89 c7                	mov    %eax,%edi
  800431:	89 c6                	mov    %eax,%esi
  800433:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800435:	5b                   	pop    %ebx
  800436:	5e                   	pop    %esi
  800437:	5f                   	pop    %edi
  800438:	5d                   	pop    %ebp
  800439:	c3                   	ret    

0080043a <sys_cgetc>:

int
sys_cgetc(void)
{
  80043a:	55                   	push   %ebp
  80043b:	89 e5                	mov    %esp,%ebp
  80043d:	57                   	push   %edi
  80043e:	56                   	push   %esi
  80043f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800440:	ba 00 00 00 00       	mov    $0x0,%edx
  800445:	b8 01 00 00 00       	mov    $0x1,%eax
  80044a:	89 d1                	mov    %edx,%ecx
  80044c:	89 d3                	mov    %edx,%ebx
  80044e:	89 d7                	mov    %edx,%edi
  800450:	89 d6                	mov    %edx,%esi
  800452:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800454:	5b                   	pop    %ebx
  800455:	5e                   	pop    %esi
  800456:	5f                   	pop    %edi
  800457:	5d                   	pop    %ebp
  800458:	c3                   	ret    

00800459 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800459:	55                   	push   %ebp
  80045a:	89 e5                	mov    %esp,%ebp
  80045c:	57                   	push   %edi
  80045d:	56                   	push   %esi
  80045e:	53                   	push   %ebx
  80045f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800462:	b9 00 00 00 00       	mov    $0x0,%ecx
  800467:	b8 03 00 00 00       	mov    $0x3,%eax
  80046c:	8b 55 08             	mov    0x8(%ebp),%edx
  80046f:	89 cb                	mov    %ecx,%ebx
  800471:	89 cf                	mov    %ecx,%edi
  800473:	89 ce                	mov    %ecx,%esi
  800475:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800477:	85 c0                	test   %eax,%eax
  800479:	7e 28                	jle    8004a3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80047b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80047f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800486:	00 
  800487:	c7 44 24 08 2a 0e 80 	movl   $0x800e2a,0x8(%esp)
  80048e:	00 
  80048f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800496:	00 
  800497:	c7 04 24 47 0e 80 00 	movl   $0x800e47,(%esp)
  80049e:	e8 29 00 00 00       	call   8004cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8004a3:	83 c4 2c             	add    $0x2c,%esp
  8004a6:	5b                   	pop    %ebx
  8004a7:	5e                   	pop    %esi
  8004a8:	5f                   	pop    %edi
  8004a9:	5d                   	pop    %ebp
  8004aa:	c3                   	ret    

008004ab <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8004ab:	55                   	push   %ebp
  8004ac:	89 e5                	mov    %esp,%ebp
  8004ae:	57                   	push   %edi
  8004af:	56                   	push   %esi
  8004b0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b6:	b8 02 00 00 00       	mov    $0x2,%eax
  8004bb:	89 d1                	mov    %edx,%ecx
  8004bd:	89 d3                	mov    %edx,%ebx
  8004bf:	89 d7                	mov    %edx,%edi
  8004c1:	89 d6                	mov    %edx,%esi
  8004c3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8004c5:	5b                   	pop    %ebx
  8004c6:	5e                   	pop    %esi
  8004c7:	5f                   	pop    %edi
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    
  8004ca:	66 90                	xchg   %ax,%ax

008004cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004cc:	55                   	push   %ebp
  8004cd:	89 e5                	mov    %esp,%ebp
  8004cf:	56                   	push   %esi
  8004d0:	53                   	push   %ebx
  8004d1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004d7:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8004dd:	e8 c9 ff ff ff       	call   8004ab <sys_getenvid>
  8004e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004e5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f0:	89 74 24 08          	mov    %esi,0x8(%esp)
  8004f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f8:	c7 04 24 58 0e 80 00 	movl   $0x800e58,(%esp)
  8004ff:	e8 c2 00 00 00       	call   8005c6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800504:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800508:	8b 45 10             	mov    0x10(%ebp),%eax
  80050b:	89 04 24             	mov    %eax,(%esp)
  80050e:	e8 52 00 00 00       	call   800565 <vcprintf>
	cprintf("\n");
  800513:	c7 04 24 7c 0e 80 00 	movl   $0x800e7c,(%esp)
  80051a:	e8 a7 00 00 00       	call   8005c6 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80051f:	cc                   	int3   
  800520:	eb fd                	jmp    80051f <_panic+0x53>
  800522:	66 90                	xchg   %ax,%ax

00800524 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800524:	55                   	push   %ebp
  800525:	89 e5                	mov    %esp,%ebp
  800527:	53                   	push   %ebx
  800528:	83 ec 14             	sub    $0x14,%esp
  80052b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80052e:	8b 13                	mov    (%ebx),%edx
  800530:	8d 42 01             	lea    0x1(%edx),%eax
  800533:	89 03                	mov    %eax,(%ebx)
  800535:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800538:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80053c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800541:	75 19                	jne    80055c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800543:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80054a:	00 
  80054b:	8d 43 08             	lea    0x8(%ebx),%eax
  80054e:	89 04 24             	mov    %eax,(%esp)
  800551:	e8 c6 fe ff ff       	call   80041c <sys_cputs>
		b->idx = 0;
  800556:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80055c:	ff 43 04             	incl   0x4(%ebx)
}
  80055f:	83 c4 14             	add    $0x14,%esp
  800562:	5b                   	pop    %ebx
  800563:	5d                   	pop    %ebp
  800564:	c3                   	ret    

00800565 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800565:	55                   	push   %ebp
  800566:	89 e5                	mov    %esp,%ebp
  800568:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80056e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800575:	00 00 00 
	b.cnt = 0;
  800578:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80057f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800582:	8b 45 0c             	mov    0xc(%ebp),%eax
  800585:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800589:	8b 45 08             	mov    0x8(%ebp),%eax
  80058c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800590:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800596:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059a:	c7 04 24 24 05 80 00 	movl   $0x800524,(%esp)
  8005a1:	e8 a9 01 00 00       	call   80074f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8005ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005b6:	89 04 24             	mov    %eax,(%esp)
  8005b9:	e8 5e fe ff ff       	call   80041c <sys_cputs>

	return b.cnt;
}
  8005be:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005c4:	c9                   	leave  
  8005c5:	c3                   	ret    

008005c6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005c6:	55                   	push   %ebp
  8005c7:	89 e5                	mov    %esp,%ebp
  8005c9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005cc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d6:	89 04 24             	mov    %eax,(%esp)
  8005d9:	e8 87 ff ff ff       	call   800565 <vcprintf>
	va_end(ap);

	return cnt;
}
  8005de:	c9                   	leave  
  8005df:	c3                   	ret    

008005e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005e0:	55                   	push   %ebp
  8005e1:	89 e5                	mov    %esp,%ebp
  8005e3:	57                   	push   %edi
  8005e4:	56                   	push   %esi
  8005e5:	53                   	push   %ebx
  8005e6:	83 ec 3c             	sub    $0x3c,%esp
  8005e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005ec:	89 d7                	mov    %edx,%edi
  8005ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f7:	89 c1                	mov    %eax,%ecx
  8005f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8005fc:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800602:	ba 00 00 00 00       	mov    $0x0,%edx
  800607:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80060d:	39 ca                	cmp    %ecx,%edx
  80060f:	72 08                	jb     800619 <printnum+0x39>
  800611:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800614:	39 45 10             	cmp    %eax,0x10(%ebp)
  800617:	77 6a                	ja     800683 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800619:	8b 45 18             	mov    0x18(%ebp),%eax
  80061c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800620:	4e                   	dec    %esi
  800621:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800625:	8b 45 10             	mov    0x10(%ebp),%eax
  800628:	89 44 24 08          	mov    %eax,0x8(%esp)
  80062c:	8b 44 24 08          	mov    0x8(%esp),%eax
  800630:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800634:	89 c3                	mov    %eax,%ebx
  800636:	89 d6                	mov    %edx,%esi
  800638:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80063e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800642:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800646:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800649:	89 04 24             	mov    %eax,(%esp)
  80064c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80064f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800653:	e8 28 05 00 00       	call   800b80 <__udivdi3>
  800658:	89 d9                	mov    %ebx,%ecx
  80065a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80065e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800662:	89 04 24             	mov    %eax,(%esp)
  800665:	89 54 24 04          	mov    %edx,0x4(%esp)
  800669:	89 fa                	mov    %edi,%edx
  80066b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80066e:	e8 6d ff ff ff       	call   8005e0 <printnum>
  800673:	eb 19                	jmp    80068e <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800675:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800679:	8b 45 18             	mov    0x18(%ebp),%eax
  80067c:	89 04 24             	mov    %eax,(%esp)
  80067f:	ff d3                	call   *%ebx
  800681:	eb 03                	jmp    800686 <printnum+0xa6>
  800683:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800686:	4e                   	dec    %esi
  800687:	85 f6                	test   %esi,%esi
  800689:	7f ea                	jg     800675 <printnum+0x95>
  80068b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80068e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800692:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800696:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800699:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80069c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006a7:	89 04 24             	mov    %eax,(%esp)
  8006aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b1:	e8 fa 05 00 00       	call   800cb0 <__umoddi3>
  8006b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ba:	0f be 80 7e 0e 80 00 	movsbl 0x800e7e(%eax),%eax
  8006c1:	89 04 24             	mov    %eax,(%esp)
  8006c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006c7:	ff d0                	call   *%eax
}
  8006c9:	83 c4 3c             	add    $0x3c,%esp
  8006cc:	5b                   	pop    %ebx
  8006cd:	5e                   	pop    %esi
  8006ce:	5f                   	pop    %edi
  8006cf:	5d                   	pop    %ebp
  8006d0:	c3                   	ret    

008006d1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006d1:	55                   	push   %ebp
  8006d2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006d4:	83 fa 01             	cmp    $0x1,%edx
  8006d7:	7e 0e                	jle    8006e7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8006d9:	8b 10                	mov    (%eax),%edx
  8006db:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006de:	89 08                	mov    %ecx,(%eax)
  8006e0:	8b 02                	mov    (%edx),%eax
  8006e2:	8b 52 04             	mov    0x4(%edx),%edx
  8006e5:	eb 22                	jmp    800709 <getuint+0x38>
	else if (lflag)
  8006e7:	85 d2                	test   %edx,%edx
  8006e9:	74 10                	je     8006fb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006eb:	8b 10                	mov    (%eax),%edx
  8006ed:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006f0:	89 08                	mov    %ecx,(%eax)
  8006f2:	8b 02                	mov    (%edx),%eax
  8006f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f9:	eb 0e                	jmp    800709 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006fb:	8b 10                	mov    (%eax),%edx
  8006fd:	8d 4a 04             	lea    0x4(%edx),%ecx
  800700:	89 08                	mov    %ecx,(%eax)
  800702:	8b 02                	mov    (%edx),%eax
  800704:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800709:	5d                   	pop    %ebp
  80070a:	c3                   	ret    

0080070b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800711:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800714:	8b 10                	mov    (%eax),%edx
  800716:	3b 50 04             	cmp    0x4(%eax),%edx
  800719:	73 0a                	jae    800725 <sprintputch+0x1a>
		*b->buf++ = ch;
  80071b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80071e:	89 08                	mov    %ecx,(%eax)
  800720:	8b 45 08             	mov    0x8(%ebp),%eax
  800723:	88 02                	mov    %al,(%edx)
}
  800725:	5d                   	pop    %ebp
  800726:	c3                   	ret    

00800727 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80072d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800730:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800734:	8b 45 10             	mov    0x10(%ebp),%eax
  800737:	89 44 24 08          	mov    %eax,0x8(%esp)
  80073b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800742:	8b 45 08             	mov    0x8(%ebp),%eax
  800745:	89 04 24             	mov    %eax,(%esp)
  800748:	e8 02 00 00 00       	call   80074f <vprintfmt>
	va_end(ap);
}
  80074d:	c9                   	leave  
  80074e:	c3                   	ret    

0080074f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	57                   	push   %edi
  800753:	56                   	push   %esi
  800754:	53                   	push   %ebx
  800755:	83 ec 3c             	sub    $0x3c,%esp
  800758:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80075b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80075e:	eb 14                	jmp    800774 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800760:	85 c0                	test   %eax,%eax
  800762:	0f 84 8a 03 00 00    	je     800af2 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  800768:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076c:	89 04 24             	mov    %eax,(%esp)
  80076f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800772:	89 f3                	mov    %esi,%ebx
  800774:	8d 73 01             	lea    0x1(%ebx),%esi
  800777:	31 c0                	xor    %eax,%eax
  800779:	8a 03                	mov    (%ebx),%al
  80077b:	83 f8 25             	cmp    $0x25,%eax
  80077e:	75 e0                	jne    800760 <vprintfmt+0x11>
  800780:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800784:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80078b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800792:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800799:	ba 00 00 00 00       	mov    $0x0,%edx
  80079e:	eb 1d                	jmp    8007bd <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a0:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8007a2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8007a6:	eb 15                	jmp    8007bd <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a8:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007aa:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8007ae:	eb 0d                	jmp    8007bd <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8007b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8007b6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bd:	8d 5e 01             	lea    0x1(%esi),%ebx
  8007c0:	31 c0                	xor    %eax,%eax
  8007c2:	8a 06                	mov    (%esi),%al
  8007c4:	8a 0e                	mov    (%esi),%cl
  8007c6:	83 e9 23             	sub    $0x23,%ecx
  8007c9:	88 4d e0             	mov    %cl,-0x20(%ebp)
  8007cc:	80 f9 55             	cmp    $0x55,%cl
  8007cf:	0f 87 ff 02 00 00    	ja     800ad4 <vprintfmt+0x385>
  8007d5:	31 c9                	xor    %ecx,%ecx
  8007d7:	8a 4d e0             	mov    -0x20(%ebp),%cl
  8007da:	ff 24 8d 20 0f 80 00 	jmp    *0x800f20(,%ecx,4)
  8007e1:	89 de                	mov    %ebx,%esi
  8007e3:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8007e8:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8007eb:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8007ef:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8007f2:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8007f5:	83 fb 09             	cmp    $0x9,%ebx
  8007f8:	77 2f                	ja     800829 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007fa:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007fb:	eb eb                	jmp    8007e8 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800800:	8d 48 04             	lea    0x4(%eax),%ecx
  800803:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800806:	8b 00                	mov    (%eax),%eax
  800808:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80080d:	eb 1d                	jmp    80082c <vprintfmt+0xdd>
  80080f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800812:	f7 d0                	not    %eax
  800814:	c1 f8 1f             	sar    $0x1f,%eax
  800817:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081a:	89 de                	mov    %ebx,%esi
  80081c:	eb 9f                	jmp    8007bd <vprintfmt+0x6e>
  80081e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800820:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800827:	eb 94                	jmp    8007bd <vprintfmt+0x6e>
  800829:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80082c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800830:	79 8b                	jns    8007bd <vprintfmt+0x6e>
  800832:	e9 79 ff ff ff       	jmp    8007b0 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800837:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800838:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80083a:	eb 81                	jmp    8007bd <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	8d 50 04             	lea    0x4(%eax),%edx
  800842:	89 55 14             	mov    %edx,0x14(%ebp)
  800845:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800849:	8b 00                	mov    (%eax),%eax
  80084b:	89 04 24             	mov    %eax,(%esp)
  80084e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800851:	e9 1e ff ff ff       	jmp    800774 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800856:	8b 45 14             	mov    0x14(%ebp),%eax
  800859:	8d 50 04             	lea    0x4(%eax),%edx
  80085c:	89 55 14             	mov    %edx,0x14(%ebp)
  80085f:	8b 00                	mov    (%eax),%eax
  800861:	89 c2                	mov    %eax,%edx
  800863:	c1 fa 1f             	sar    $0x1f,%edx
  800866:	31 d0                	xor    %edx,%eax
  800868:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80086a:	83 f8 07             	cmp    $0x7,%eax
  80086d:	7f 0b                	jg     80087a <vprintfmt+0x12b>
  80086f:	8b 14 85 80 10 80 00 	mov    0x801080(,%eax,4),%edx
  800876:	85 d2                	test   %edx,%edx
  800878:	75 20                	jne    80089a <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  80087a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80087e:	c7 44 24 08 96 0e 80 	movl   $0x800e96,0x8(%esp)
  800885:	00 
  800886:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80088a:	8b 45 08             	mov    0x8(%ebp),%eax
  80088d:	89 04 24             	mov    %eax,(%esp)
  800890:	e8 92 fe ff ff       	call   800727 <printfmt>
  800895:	e9 da fe ff ff       	jmp    800774 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80089a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80089e:	c7 44 24 08 9f 0e 80 	movl   $0x800e9f,0x8(%esp)
  8008a5:	00 
  8008a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ad:	89 04 24             	mov    %eax,(%esp)
  8008b0:	e8 72 fe ff ff       	call   800727 <printfmt>
  8008b5:	e9 ba fe ff ff       	jmp    800774 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ba:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8008bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8008c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c6:	8d 50 04             	lea    0x4(%eax),%edx
  8008c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8008cc:	8b 30                	mov    (%eax),%esi
  8008ce:	85 f6                	test   %esi,%esi
  8008d0:	75 05                	jne    8008d7 <vprintfmt+0x188>
				p = "(null)";
  8008d2:	be 8f 0e 80 00       	mov    $0x800e8f,%esi
			if (width > 0 && padc != '-')
  8008d7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8008db:	0f 84 8c 00 00 00    	je     80096d <vprintfmt+0x21e>
  8008e1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008e5:	0f 8e 8a 00 00 00    	jle    800975 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008ef:	89 34 24             	mov    %esi,(%esp)
  8008f2:	e8 cf f7 ff ff       	call   8000c6 <strnlen>
  8008f7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008fa:	29 c1                	sub    %eax,%ecx
  8008fc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  8008ff:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800903:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800906:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800909:	8b 75 08             	mov    0x8(%ebp),%esi
  80090c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80090f:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800911:	eb 0d                	jmp    800920 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800913:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800917:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80091a:	89 04 24             	mov    %eax,(%esp)
  80091d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80091f:	4b                   	dec    %ebx
  800920:	85 db                	test   %ebx,%ebx
  800922:	7f ef                	jg     800913 <vprintfmt+0x1c4>
  800924:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800927:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80092a:	89 c8                	mov    %ecx,%eax
  80092c:	f7 d0                	not    %eax
  80092e:	c1 f8 1f             	sar    $0x1f,%eax
  800931:	21 c8                	and    %ecx,%eax
  800933:	29 c1                	sub    %eax,%ecx
  800935:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800938:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80093b:	eb 3e                	jmp    80097b <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80093d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800941:	74 1b                	je     80095e <vprintfmt+0x20f>
  800943:	0f be d2             	movsbl %dl,%edx
  800946:	83 ea 20             	sub    $0x20,%edx
  800949:	83 fa 5e             	cmp    $0x5e,%edx
  80094c:	76 10                	jbe    80095e <vprintfmt+0x20f>
					putch('?', putdat);
  80094e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800952:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800959:	ff 55 08             	call   *0x8(%ebp)
  80095c:	eb 0a                	jmp    800968 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  80095e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800962:	89 04 24             	mov    %eax,(%esp)
  800965:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800968:	ff 4d dc             	decl   -0x24(%ebp)
  80096b:	eb 0e                	jmp    80097b <vprintfmt+0x22c>
  80096d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800970:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800973:	eb 06                	jmp    80097b <vprintfmt+0x22c>
  800975:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800978:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80097b:	46                   	inc    %esi
  80097c:	8a 56 ff             	mov    -0x1(%esi),%dl
  80097f:	0f be c2             	movsbl %dl,%eax
  800982:	85 c0                	test   %eax,%eax
  800984:	74 1f                	je     8009a5 <vprintfmt+0x256>
  800986:	85 db                	test   %ebx,%ebx
  800988:	78 b3                	js     80093d <vprintfmt+0x1ee>
  80098a:	4b                   	dec    %ebx
  80098b:	79 b0                	jns    80093d <vprintfmt+0x1ee>
  80098d:	8b 75 08             	mov    0x8(%ebp),%esi
  800990:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800993:	eb 16                	jmp    8009ab <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800995:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800999:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009a0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009a2:	4b                   	dec    %ebx
  8009a3:	eb 06                	jmp    8009ab <vprintfmt+0x25c>
  8009a5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8009a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ab:	85 db                	test   %ebx,%ebx
  8009ad:	7f e6                	jg     800995 <vprintfmt+0x246>
  8009af:	89 75 08             	mov    %esi,0x8(%ebp)
  8009b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009b5:	e9 ba fd ff ff       	jmp    800774 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009ba:	83 fa 01             	cmp    $0x1,%edx
  8009bd:	7e 16                	jle    8009d5 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  8009bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c2:	8d 50 08             	lea    0x8(%eax),%edx
  8009c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009c8:	8b 50 04             	mov    0x4(%eax),%edx
  8009cb:	8b 00                	mov    (%eax),%eax
  8009cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009d0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009d3:	eb 32                	jmp    800a07 <vprintfmt+0x2b8>
	else if (lflag)
  8009d5:	85 d2                	test   %edx,%edx
  8009d7:	74 18                	je     8009f1 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  8009d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8009dc:	8d 50 04             	lea    0x4(%eax),%edx
  8009df:	89 55 14             	mov    %edx,0x14(%ebp)
  8009e2:	8b 30                	mov    (%eax),%esi
  8009e4:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8009e7:	89 f0                	mov    %esi,%eax
  8009e9:	c1 f8 1f             	sar    $0x1f,%eax
  8009ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009ef:	eb 16                	jmp    800a07 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  8009f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f4:	8d 50 04             	lea    0x4(%eax),%edx
  8009f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8009fa:	8b 30                	mov    (%eax),%esi
  8009fc:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8009ff:	89 f0                	mov    %esi,%eax
  800a01:	c1 f8 1f             	sar    $0x1f,%eax
  800a04:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a07:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a0a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a0d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a12:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a16:	0f 89 80 00 00 00    	jns    800a9c <vprintfmt+0x34d>
				putch('-', putdat);
  800a1c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a20:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a27:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a2d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a30:	f7 d8                	neg    %eax
  800a32:	83 d2 00             	adc    $0x0,%edx
  800a35:	f7 da                	neg    %edx
			}
			base = 10;
  800a37:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a3c:	eb 5e                	jmp    800a9c <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a3e:	8d 45 14             	lea    0x14(%ebp),%eax
  800a41:	e8 8b fc ff ff       	call   8006d1 <getuint>
			base = 10;
  800a46:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a4b:	eb 4f                	jmp    800a9c <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800a4d:	8d 45 14             	lea    0x14(%ebp),%eax
  800a50:	e8 7c fc ff ff       	call   8006d1 <getuint>
			base = 8;
  800a55:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800a5a:	eb 40                	jmp    800a9c <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800a5c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a60:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a67:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a6a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a6e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a75:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a78:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7b:	8d 50 04             	lea    0x4(%eax),%edx
  800a7e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a81:	8b 00                	mov    (%eax),%eax
  800a83:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a88:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a8d:	eb 0d                	jmp    800a9c <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a8f:	8d 45 14             	lea    0x14(%ebp),%eax
  800a92:	e8 3a fc ff ff       	call   8006d1 <getuint>
			base = 16;
  800a97:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a9c:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800aa0:	89 74 24 10          	mov    %esi,0x10(%esp)
  800aa4:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800aa7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800aab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800aaf:	89 04 24             	mov    %eax,(%esp)
  800ab2:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ab6:	89 fa                	mov    %edi,%edx
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	e8 20 fb ff ff       	call   8005e0 <printnum>
			break;
  800ac0:	e9 af fc ff ff       	jmp    800774 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ac5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ac9:	89 04 24             	mov    %eax,(%esp)
  800acc:	ff 55 08             	call   *0x8(%ebp)
			break;
  800acf:	e9 a0 fc ff ff       	jmp    800774 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ad4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ad8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800adf:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ae2:	89 f3                	mov    %esi,%ebx
  800ae4:	eb 01                	jmp    800ae7 <vprintfmt+0x398>
  800ae6:	4b                   	dec    %ebx
  800ae7:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800aeb:	75 f9                	jne    800ae6 <vprintfmt+0x397>
  800aed:	e9 82 fc ff ff       	jmp    800774 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800af2:	83 c4 3c             	add    $0x3c,%esp
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	83 ec 28             	sub    $0x28,%esp
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b06:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b09:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b0d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b17:	85 c0                	test   %eax,%eax
  800b19:	74 30                	je     800b4b <vsnprintf+0x51>
  800b1b:	85 d2                	test   %edx,%edx
  800b1d:	7e 2c                	jle    800b4b <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b1f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b22:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b26:	8b 45 10             	mov    0x10(%ebp),%eax
  800b29:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b2d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b30:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b34:	c7 04 24 0b 07 80 00 	movl   $0x80070b,(%esp)
  800b3b:	e8 0f fc ff ff       	call   80074f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b40:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b43:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b49:	eb 05                	jmp    800b50 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b4b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b50:	c9                   	leave  
  800b51:	c3                   	ret    

00800b52 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b58:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b5f:	8b 45 10             	mov    0x10(%ebp),%eax
  800b62:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b69:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b70:	89 04 24             	mov    %eax,(%esp)
  800b73:	e8 82 ff ff ff       	call   800afa <vsnprintf>
	va_end(ap);

	return rc;
}
  800b78:	c9                   	leave  
  800b79:	c3                   	ret    
  800b7a:	66 90                	xchg   %ax,%ax
  800b7c:	66 90                	xchg   %ax,%ax
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
