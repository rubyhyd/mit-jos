
obj/user/idle:     file format elf32-i386


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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003a:	c7 05 00 20 80 00 80 	movl   $0x801080,0x802000
  800041:	10 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 a5 04 00 00       	call   8004ee <sys_yield>
  800049:	eb f9                	jmp    800044 <umain+0x10>
  80004b:	90                   	nop

0080004c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	56                   	push   %esi
  800050:	53                   	push   %ebx
  800051:	83 ec 10             	sub    $0x10,%esp
  800054:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800057:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  80005a:	b8 08 20 80 00       	mov    $0x802008,%eax
  80005f:	2d 04 20 80 00       	sub    $0x802004,%eax
  800064:	89 44 24 08          	mov    %eax,0x8(%esp)
  800068:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80006f:	00 
  800070:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  800077:	e8 cf 01 00 00       	call   80024b <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  80007c:	e8 4e 04 00 00       	call   8004cf <sys_getenvid>
  800081:	25 ff 03 00 00       	and    $0x3ff,%eax
  800086:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80008d:	c1 e0 07             	shl    $0x7,%eax
  800090:	29 d0                	sub    %edx,%eax
  800092:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800097:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009c:	85 db                	test   %ebx,%ebx
  80009e:	7e 07                	jle    8000a7 <libmain+0x5b>
		binaryname = argv[0];
  8000a0:	8b 06                	mov    (%esi),%eax
  8000a2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 81 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b3:	e8 08 00 00 00       	call   8000c0 <exit>
}
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    
  8000bf:	90                   	nop

008000c0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000cd:	e8 ab 03 00 00       	call   80047d <sys_env_destroy>
}
  8000d2:	c9                   	leave  
  8000d3:	c3                   	ret    

008000d4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8000da:	b8 00 00 00 00       	mov    $0x0,%eax
  8000df:	eb 01                	jmp    8000e2 <strlen+0xe>
		n++;
  8000e1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8000e2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8000e6:	75 f9                	jne    8000e1 <strlen+0xd>
		n++;
	return n;
}
  8000e8:	5d                   	pop    %ebp
  8000e9:	c3                   	ret    

008000ea <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8000f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f8:	eb 01                	jmp    8000fb <strnlen+0x11>
		n++;
  8000fa:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8000fb:	39 d0                	cmp    %edx,%eax
  8000fd:	74 06                	je     800105 <strnlen+0x1b>
  8000ff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800103:	75 f5                	jne    8000fa <strnlen+0x10>
		n++;
	return n;
}
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	53                   	push   %ebx
  80010b:	8b 45 08             	mov    0x8(%ebp),%eax
  80010e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800111:	89 c2                	mov    %eax,%edx
  800113:	42                   	inc    %edx
  800114:	41                   	inc    %ecx
  800115:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800118:	88 5a ff             	mov    %bl,-0x1(%edx)
  80011b:	84 db                	test   %bl,%bl
  80011d:	75 f4                	jne    800113 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80011f:	5b                   	pop    %ebx
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	53                   	push   %ebx
  800126:	83 ec 08             	sub    $0x8,%esp
  800129:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80012c:	89 1c 24             	mov    %ebx,(%esp)
  80012f:	e8 a0 ff ff ff       	call   8000d4 <strlen>
	strcpy(dst + len, src);
  800134:	8b 55 0c             	mov    0xc(%ebp),%edx
  800137:	89 54 24 04          	mov    %edx,0x4(%esp)
  80013b:	01 d8                	add    %ebx,%eax
  80013d:	89 04 24             	mov    %eax,(%esp)
  800140:	e8 c2 ff ff ff       	call   800107 <strcpy>
	return dst;
}
  800145:	89 d8                	mov    %ebx,%eax
  800147:	83 c4 08             	add    $0x8,%esp
  80014a:	5b                   	pop    %ebx
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    

0080014d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
  800152:	8b 75 08             	mov    0x8(%ebp),%esi
  800155:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800158:	89 f3                	mov    %esi,%ebx
  80015a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80015d:	89 f2                	mov    %esi,%edx
  80015f:	eb 0c                	jmp    80016d <strncpy+0x20>
		*dst++ = *src;
  800161:	42                   	inc    %edx
  800162:	8a 01                	mov    (%ecx),%al
  800164:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800167:	80 39 01             	cmpb   $0x1,(%ecx)
  80016a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80016d:	39 da                	cmp    %ebx,%edx
  80016f:	75 f0                	jne    800161 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800171:	89 f0                	mov    %esi,%eax
  800173:	5b                   	pop    %ebx
  800174:	5e                   	pop    %esi
  800175:	5d                   	pop    %ebp
  800176:	c3                   	ret    

00800177 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	56                   	push   %esi
  80017b:	53                   	push   %ebx
  80017c:	8b 75 08             	mov    0x8(%ebp),%esi
  80017f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800182:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800185:	89 f0                	mov    %esi,%eax
  800187:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80018b:	85 c9                	test   %ecx,%ecx
  80018d:	75 07                	jne    800196 <strlcpy+0x1f>
  80018f:	eb 18                	jmp    8001a9 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800191:	40                   	inc    %eax
  800192:	42                   	inc    %edx
  800193:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800196:	39 d8                	cmp    %ebx,%eax
  800198:	74 0a                	je     8001a4 <strlcpy+0x2d>
  80019a:	8a 0a                	mov    (%edx),%cl
  80019c:	84 c9                	test   %cl,%cl
  80019e:	75 f1                	jne    800191 <strlcpy+0x1a>
  8001a0:	89 c2                	mov    %eax,%edx
  8001a2:	eb 02                	jmp    8001a6 <strlcpy+0x2f>
  8001a4:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8001a6:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8001a9:	29 f0                	sub    %esi,%eax
}
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5d                   	pop    %ebp
  8001ae:	c3                   	ret    

008001af <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8001b8:	eb 02                	jmp    8001bc <strcmp+0xd>
		p++, q++;
  8001ba:	41                   	inc    %ecx
  8001bb:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8001bc:	8a 01                	mov    (%ecx),%al
  8001be:	84 c0                	test   %al,%al
  8001c0:	74 04                	je     8001c6 <strcmp+0x17>
  8001c2:	3a 02                	cmp    (%edx),%al
  8001c4:	74 f4                	je     8001ba <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8001c6:	25 ff 00 00 00       	and    $0xff,%eax
  8001cb:	8a 0a                	mov    (%edx),%cl
  8001cd:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8001d3:	29 c8                	sub    %ecx,%eax
}
  8001d5:	5d                   	pop    %ebp
  8001d6:	c3                   	ret    

008001d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	53                   	push   %ebx
  8001db:	8b 45 08             	mov    0x8(%ebp),%eax
  8001de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e1:	89 c3                	mov    %eax,%ebx
  8001e3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8001e6:	eb 02                	jmp    8001ea <strncmp+0x13>
		n--, p++, q++;
  8001e8:	40                   	inc    %eax
  8001e9:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8001ea:	39 d8                	cmp    %ebx,%eax
  8001ec:	74 20                	je     80020e <strncmp+0x37>
  8001ee:	8a 08                	mov    (%eax),%cl
  8001f0:	84 c9                	test   %cl,%cl
  8001f2:	74 04                	je     8001f8 <strncmp+0x21>
  8001f4:	3a 0a                	cmp    (%edx),%cl
  8001f6:	74 f0                	je     8001e8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8001f8:	8a 18                	mov    (%eax),%bl
  8001fa:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800200:	89 d8                	mov    %ebx,%eax
  800202:	8a 1a                	mov    (%edx),%bl
  800204:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80020a:	29 d8                	sub    %ebx,%eax
  80020c:	eb 05                	jmp    800213 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80020e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800213:	5b                   	pop    %ebx
  800214:	5d                   	pop    %ebp
  800215:	c3                   	ret    

00800216 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800216:	55                   	push   %ebp
  800217:	89 e5                	mov    %esp,%ebp
  800219:	8b 45 08             	mov    0x8(%ebp),%eax
  80021c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80021f:	eb 05                	jmp    800226 <strchr+0x10>
		if (*s == c)
  800221:	38 ca                	cmp    %cl,%dl
  800223:	74 0c                	je     800231 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800225:	40                   	inc    %eax
  800226:	8a 10                	mov    (%eax),%dl
  800228:	84 d2                	test   %dl,%dl
  80022a:	75 f5                	jne    800221 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80022c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800231:	5d                   	pop    %ebp
  800232:	c3                   	ret    

00800233 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80023c:	eb 05                	jmp    800243 <strfind+0x10>
		if (*s == c)
  80023e:	38 ca                	cmp    %cl,%dl
  800240:	74 07                	je     800249 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800242:	40                   	inc    %eax
  800243:	8a 10                	mov    (%eax),%dl
  800245:	84 d2                	test   %dl,%dl
  800247:	75 f5                	jne    80023e <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800249:	5d                   	pop    %ebp
  80024a:	c3                   	ret    

0080024b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	57                   	push   %edi
  80024f:	56                   	push   %esi
  800250:	53                   	push   %ebx
  800251:	8b 7d 08             	mov    0x8(%ebp),%edi
  800254:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800257:	85 c9                	test   %ecx,%ecx
  800259:	74 37                	je     800292 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80025b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800261:	75 29                	jne    80028c <memset+0x41>
  800263:	f6 c1 03             	test   $0x3,%cl
  800266:	75 24                	jne    80028c <memset+0x41>
		c &= 0xFF;
  800268:	31 d2                	xor    %edx,%edx
  80026a:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80026d:	89 d3                	mov    %edx,%ebx
  80026f:	c1 e3 08             	shl    $0x8,%ebx
  800272:	89 d6                	mov    %edx,%esi
  800274:	c1 e6 18             	shl    $0x18,%esi
  800277:	89 d0                	mov    %edx,%eax
  800279:	c1 e0 10             	shl    $0x10,%eax
  80027c:	09 f0                	or     %esi,%eax
  80027e:	09 c2                	or     %eax,%edx
  800280:	89 d0                	mov    %edx,%eax
  800282:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800284:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800287:	fc                   	cld    
  800288:	f3 ab                	rep stos %eax,%es:(%edi)
  80028a:	eb 06                	jmp    800292 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80028c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80028f:	fc                   	cld    
  800290:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800292:	89 f8                	mov    %edi,%eax
  800294:	5b                   	pop    %ebx
  800295:	5e                   	pop    %esi
  800296:	5f                   	pop    %edi
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    

00800299 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	57                   	push   %edi
  80029d:	56                   	push   %esi
  80029e:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8002a7:	39 c6                	cmp    %eax,%esi
  8002a9:	73 33                	jae    8002de <memmove+0x45>
  8002ab:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8002ae:	39 d0                	cmp    %edx,%eax
  8002b0:	73 2c                	jae    8002de <memmove+0x45>
		s += n;
		d += n;
  8002b2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8002b5:	89 d6                	mov    %edx,%esi
  8002b7:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8002b9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8002bf:	75 13                	jne    8002d4 <memmove+0x3b>
  8002c1:	f6 c1 03             	test   $0x3,%cl
  8002c4:	75 0e                	jne    8002d4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8002c6:	83 ef 04             	sub    $0x4,%edi
  8002c9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8002cc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8002cf:	fd                   	std    
  8002d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8002d2:	eb 07                	jmp    8002db <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8002d4:	4f                   	dec    %edi
  8002d5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8002d8:	fd                   	std    
  8002d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8002db:	fc                   	cld    
  8002dc:	eb 1d                	jmp    8002fb <memmove+0x62>
  8002de:	89 f2                	mov    %esi,%edx
  8002e0:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8002e2:	f6 c2 03             	test   $0x3,%dl
  8002e5:	75 0f                	jne    8002f6 <memmove+0x5d>
  8002e7:	f6 c1 03             	test   $0x3,%cl
  8002ea:	75 0a                	jne    8002f6 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8002ec:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8002ef:	89 c7                	mov    %eax,%edi
  8002f1:	fc                   	cld    
  8002f2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8002f4:	eb 05                	jmp    8002fb <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8002f6:	89 c7                	mov    %eax,%edi
  8002f8:	fc                   	cld    
  8002f9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8002fb:	5e                   	pop    %esi
  8002fc:	5f                   	pop    %edi
  8002fd:	5d                   	pop    %ebp
  8002fe:	c3                   	ret    

008002ff <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800305:	8b 45 10             	mov    0x10(%ebp),%eax
  800308:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80030f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800313:	8b 45 08             	mov    0x8(%ebp),%eax
  800316:	89 04 24             	mov    %eax,(%esp)
  800319:	e8 7b ff ff ff       	call   800299 <memmove>
}
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	56                   	push   %esi
  800324:	53                   	push   %ebx
  800325:	8b 55 08             	mov    0x8(%ebp),%edx
  800328:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032b:	89 d6                	mov    %edx,%esi
  80032d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800330:	eb 19                	jmp    80034b <memcmp+0x2b>
		if (*s1 != *s2)
  800332:	8a 02                	mov    (%edx),%al
  800334:	8a 19                	mov    (%ecx),%bl
  800336:	38 d8                	cmp    %bl,%al
  800338:	74 0f                	je     800349 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  80033a:	25 ff 00 00 00       	and    $0xff,%eax
  80033f:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800345:	29 d8                	sub    %ebx,%eax
  800347:	eb 0b                	jmp    800354 <memcmp+0x34>
		s1++, s2++;
  800349:	42                   	inc    %edx
  80034a:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80034b:	39 f2                	cmp    %esi,%edx
  80034d:	75 e3                	jne    800332 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80034f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800354:	5b                   	pop    %ebx
  800355:	5e                   	pop    %esi
  800356:	5d                   	pop    %ebp
  800357:	c3                   	ret    

00800358 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	8b 45 08             	mov    0x8(%ebp),%eax
  80035e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800361:	89 c2                	mov    %eax,%edx
  800363:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800366:	eb 05                	jmp    80036d <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800368:	38 08                	cmp    %cl,(%eax)
  80036a:	74 05                	je     800371 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80036c:	40                   	inc    %eax
  80036d:	39 d0                	cmp    %edx,%eax
  80036f:	72 f7                	jb     800368 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	57                   	push   %edi
  800377:	56                   	push   %esi
  800378:	53                   	push   %ebx
  800379:	8b 55 08             	mov    0x8(%ebp),%edx
  80037c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80037f:	eb 01                	jmp    800382 <strtol+0xf>
		s++;
  800381:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800382:	8a 02                	mov    (%edx),%al
  800384:	3c 09                	cmp    $0x9,%al
  800386:	74 f9                	je     800381 <strtol+0xe>
  800388:	3c 20                	cmp    $0x20,%al
  80038a:	74 f5                	je     800381 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80038c:	3c 2b                	cmp    $0x2b,%al
  80038e:	75 08                	jne    800398 <strtol+0x25>
		s++;
  800390:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800391:	bf 00 00 00 00       	mov    $0x0,%edi
  800396:	eb 10                	jmp    8003a8 <strtol+0x35>
  800398:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80039d:	3c 2d                	cmp    $0x2d,%al
  80039f:	75 07                	jne    8003a8 <strtol+0x35>
		s++, neg = 1;
  8003a1:	8d 52 01             	lea    0x1(%edx),%edx
  8003a4:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8003a8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8003ae:	75 15                	jne    8003c5 <strtol+0x52>
  8003b0:	80 3a 30             	cmpb   $0x30,(%edx)
  8003b3:	75 10                	jne    8003c5 <strtol+0x52>
  8003b5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8003b9:	75 0a                	jne    8003c5 <strtol+0x52>
		s += 2, base = 16;
  8003bb:	83 c2 02             	add    $0x2,%edx
  8003be:	bb 10 00 00 00       	mov    $0x10,%ebx
  8003c3:	eb 0e                	jmp    8003d3 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  8003c5:	85 db                	test   %ebx,%ebx
  8003c7:	75 0a                	jne    8003d3 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8003c9:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8003cb:	80 3a 30             	cmpb   $0x30,(%edx)
  8003ce:	75 03                	jne    8003d3 <strtol+0x60>
		s++, base = 8;
  8003d0:	42                   	inc    %edx
  8003d1:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  8003d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8003db:	8a 0a                	mov    (%edx),%cl
  8003dd:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8003e0:	89 f3                	mov    %esi,%ebx
  8003e2:	80 fb 09             	cmp    $0x9,%bl
  8003e5:	77 08                	ja     8003ef <strtol+0x7c>
			dig = *s - '0';
  8003e7:	0f be c9             	movsbl %cl,%ecx
  8003ea:	83 e9 30             	sub    $0x30,%ecx
  8003ed:	eb 22                	jmp    800411 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  8003ef:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8003f2:	89 f3                	mov    %esi,%ebx
  8003f4:	80 fb 19             	cmp    $0x19,%bl
  8003f7:	77 08                	ja     800401 <strtol+0x8e>
			dig = *s - 'a' + 10;
  8003f9:	0f be c9             	movsbl %cl,%ecx
  8003fc:	83 e9 57             	sub    $0x57,%ecx
  8003ff:	eb 10                	jmp    800411 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800401:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800404:	89 f3                	mov    %esi,%ebx
  800406:	80 fb 19             	cmp    $0x19,%bl
  800409:	77 14                	ja     80041f <strtol+0xac>
			dig = *s - 'A' + 10;
  80040b:	0f be c9             	movsbl %cl,%ecx
  80040e:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800411:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800414:	7d 0d                	jge    800423 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800416:	42                   	inc    %edx
  800417:	0f af 45 10          	imul   0x10(%ebp),%eax
  80041b:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80041d:	eb bc                	jmp    8003db <strtol+0x68>
  80041f:	89 c1                	mov    %eax,%ecx
  800421:	eb 02                	jmp    800425 <strtol+0xb2>
  800423:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800425:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800429:	74 05                	je     800430 <strtol+0xbd>
		*endptr = (char *) s;
  80042b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80042e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800430:	85 ff                	test   %edi,%edi
  800432:	74 04                	je     800438 <strtol+0xc5>
  800434:	89 c8                	mov    %ecx,%eax
  800436:	f7 d8                	neg    %eax
}
  800438:	5b                   	pop    %ebx
  800439:	5e                   	pop    %esi
  80043a:	5f                   	pop    %edi
  80043b:	5d                   	pop    %ebp
  80043c:	c3                   	ret    
  80043d:	66 90                	xchg   %ax,%ax
  80043f:	90                   	nop

00800440 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800440:	55                   	push   %ebp
  800441:	89 e5                	mov    %esp,%ebp
  800443:	57                   	push   %edi
  800444:	56                   	push   %esi
  800445:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800446:	b8 00 00 00 00       	mov    $0x0,%eax
  80044b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80044e:	8b 55 08             	mov    0x8(%ebp),%edx
  800451:	89 c3                	mov    %eax,%ebx
  800453:	89 c7                	mov    %eax,%edi
  800455:	89 c6                	mov    %eax,%esi
  800457:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800459:	5b                   	pop    %ebx
  80045a:	5e                   	pop    %esi
  80045b:	5f                   	pop    %edi
  80045c:	5d                   	pop    %ebp
  80045d:	c3                   	ret    

0080045e <sys_cgetc>:

int
sys_cgetc(void)
{
  80045e:	55                   	push   %ebp
  80045f:	89 e5                	mov    %esp,%ebp
  800461:	57                   	push   %edi
  800462:	56                   	push   %esi
  800463:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800464:	ba 00 00 00 00       	mov    $0x0,%edx
  800469:	b8 01 00 00 00       	mov    $0x1,%eax
  80046e:	89 d1                	mov    %edx,%ecx
  800470:	89 d3                	mov    %edx,%ebx
  800472:	89 d7                	mov    %edx,%edi
  800474:	89 d6                	mov    %edx,%esi
  800476:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800478:	5b                   	pop    %ebx
  800479:	5e                   	pop    %esi
  80047a:	5f                   	pop    %edi
  80047b:	5d                   	pop    %ebp
  80047c:	c3                   	ret    

0080047d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80047d:	55                   	push   %ebp
  80047e:	89 e5                	mov    %esp,%ebp
  800480:	57                   	push   %edi
  800481:	56                   	push   %esi
  800482:	53                   	push   %ebx
  800483:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800486:	b9 00 00 00 00       	mov    $0x0,%ecx
  80048b:	b8 03 00 00 00       	mov    $0x3,%eax
  800490:	8b 55 08             	mov    0x8(%ebp),%edx
  800493:	89 cb                	mov    %ecx,%ebx
  800495:	89 cf                	mov    %ecx,%edi
  800497:	89 ce                	mov    %ecx,%esi
  800499:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80049b:	85 c0                	test   %eax,%eax
  80049d:	7e 28                	jle    8004c7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80049f:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004a3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8004aa:	00 
  8004ab:	c7 44 24 08 8f 10 80 	movl   $0x80108f,0x8(%esp)
  8004b2:	00 
  8004b3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004ba:	00 
  8004bb:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  8004c2:	e8 5d 02 00 00       	call   800724 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8004c7:	83 c4 2c             	add    $0x2c,%esp
  8004ca:	5b                   	pop    %ebx
  8004cb:	5e                   	pop    %esi
  8004cc:	5f                   	pop    %edi
  8004cd:	5d                   	pop    %ebp
  8004ce:	c3                   	ret    

008004cf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8004cf:	55                   	push   %ebp
  8004d0:	89 e5                	mov    %esp,%ebp
  8004d2:	57                   	push   %edi
  8004d3:	56                   	push   %esi
  8004d4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004da:	b8 02 00 00 00       	mov    $0x2,%eax
  8004df:	89 d1                	mov    %edx,%ecx
  8004e1:	89 d3                	mov    %edx,%ebx
  8004e3:	89 d7                	mov    %edx,%edi
  8004e5:	89 d6                	mov    %edx,%esi
  8004e7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8004e9:	5b                   	pop    %ebx
  8004ea:	5e                   	pop    %esi
  8004eb:	5f                   	pop    %edi
  8004ec:	5d                   	pop    %ebp
  8004ed:	c3                   	ret    

008004ee <sys_yield>:

void
sys_yield(void)
{
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  8004f1:	57                   	push   %edi
  8004f2:	56                   	push   %esi
  8004f3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004fe:	89 d1                	mov    %edx,%ecx
  800500:	89 d3                	mov    %edx,%ebx
  800502:	89 d7                	mov    %edx,%edi
  800504:	89 d6                	mov    %edx,%esi
  800506:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800508:	5b                   	pop    %ebx
  800509:	5e                   	pop    %esi
  80050a:	5f                   	pop    %edi
  80050b:	5d                   	pop    %ebp
  80050c:	c3                   	ret    

0080050d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80050d:	55                   	push   %ebp
  80050e:	89 e5                	mov    %esp,%ebp
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	53                   	push   %ebx
  800513:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800516:	be 00 00 00 00       	mov    $0x0,%esi
  80051b:	b8 04 00 00 00       	mov    $0x4,%eax
  800520:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800523:	8b 55 08             	mov    0x8(%ebp),%edx
  800526:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800529:	89 f7                	mov    %esi,%edi
  80052b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80052d:	85 c0                	test   %eax,%eax
  80052f:	7e 28                	jle    800559 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800531:	89 44 24 10          	mov    %eax,0x10(%esp)
  800535:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80053c:	00 
  80053d:	c7 44 24 08 8f 10 80 	movl   $0x80108f,0x8(%esp)
  800544:	00 
  800545:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80054c:	00 
  80054d:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  800554:	e8 cb 01 00 00       	call   800724 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800559:	83 c4 2c             	add    $0x2c,%esp
  80055c:	5b                   	pop    %ebx
  80055d:	5e                   	pop    %esi
  80055e:	5f                   	pop    %edi
  80055f:	5d                   	pop    %ebp
  800560:	c3                   	ret    

00800561 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800561:	55                   	push   %ebp
  800562:	89 e5                	mov    %esp,%ebp
  800564:	57                   	push   %edi
  800565:	56                   	push   %esi
  800566:	53                   	push   %ebx
  800567:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80056a:	b8 05 00 00 00       	mov    $0x5,%eax
  80056f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800572:	8b 55 08             	mov    0x8(%ebp),%edx
  800575:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800578:	8b 7d 14             	mov    0x14(%ebp),%edi
  80057b:	8b 75 18             	mov    0x18(%ebp),%esi
  80057e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800580:	85 c0                	test   %eax,%eax
  800582:	7e 28                	jle    8005ac <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800584:	89 44 24 10          	mov    %eax,0x10(%esp)
  800588:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80058f:	00 
  800590:	c7 44 24 08 8f 10 80 	movl   $0x80108f,0x8(%esp)
  800597:	00 
  800598:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80059f:	00 
  8005a0:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  8005a7:	e8 78 01 00 00       	call   800724 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8005ac:	83 c4 2c             	add    $0x2c,%esp
  8005af:	5b                   	pop    %ebx
  8005b0:	5e                   	pop    %esi
  8005b1:	5f                   	pop    %edi
  8005b2:	5d                   	pop    %ebp
  8005b3:	c3                   	ret    

008005b4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8005b4:	55                   	push   %ebp
  8005b5:	89 e5                	mov    %esp,%ebp
  8005b7:	57                   	push   %edi
  8005b8:	56                   	push   %esi
  8005b9:	53                   	push   %ebx
  8005ba:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005c2:	b8 06 00 00 00       	mov    $0x6,%eax
  8005c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8005cd:	89 df                	mov    %ebx,%edi
  8005cf:	89 de                	mov    %ebx,%esi
  8005d1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005d3:	85 c0                	test   %eax,%eax
  8005d5:	7e 28                	jle    8005ff <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005d7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005db:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8005e2:	00 
  8005e3:	c7 44 24 08 8f 10 80 	movl   $0x80108f,0x8(%esp)
  8005ea:	00 
  8005eb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005f2:	00 
  8005f3:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  8005fa:	e8 25 01 00 00       	call   800724 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8005ff:	83 c4 2c             	add    $0x2c,%esp
  800602:	5b                   	pop    %ebx
  800603:	5e                   	pop    %esi
  800604:	5f                   	pop    %edi
  800605:	5d                   	pop    %ebp
  800606:	c3                   	ret    

00800607 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800607:	55                   	push   %ebp
  800608:	89 e5                	mov    %esp,%ebp
  80060a:	57                   	push   %edi
  80060b:	56                   	push   %esi
  80060c:	53                   	push   %ebx
  80060d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800610:	bb 00 00 00 00       	mov    $0x0,%ebx
  800615:	b8 08 00 00 00       	mov    $0x8,%eax
  80061a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80061d:	8b 55 08             	mov    0x8(%ebp),%edx
  800620:	89 df                	mov    %ebx,%edi
  800622:	89 de                	mov    %ebx,%esi
  800624:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800626:	85 c0                	test   %eax,%eax
  800628:	7e 28                	jle    800652 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80062a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80062e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800635:	00 
  800636:	c7 44 24 08 8f 10 80 	movl   $0x80108f,0x8(%esp)
  80063d:	00 
  80063e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800645:	00 
  800646:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  80064d:	e8 d2 00 00 00       	call   800724 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800652:	83 c4 2c             	add    $0x2c,%esp
  800655:	5b                   	pop    %ebx
  800656:	5e                   	pop    %esi
  800657:	5f                   	pop    %edi
  800658:	5d                   	pop    %ebp
  800659:	c3                   	ret    

0080065a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80065a:	55                   	push   %ebp
  80065b:	89 e5                	mov    %esp,%ebp
  80065d:	57                   	push   %edi
  80065e:	56                   	push   %esi
  80065f:	53                   	push   %ebx
  800660:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800663:	bb 00 00 00 00       	mov    $0x0,%ebx
  800668:	b8 09 00 00 00       	mov    $0x9,%eax
  80066d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800670:	8b 55 08             	mov    0x8(%ebp),%edx
  800673:	89 df                	mov    %ebx,%edi
  800675:	89 de                	mov    %ebx,%esi
  800677:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800679:	85 c0                	test   %eax,%eax
  80067b:	7e 28                	jle    8006a5 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80067d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800681:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800688:	00 
  800689:	c7 44 24 08 8f 10 80 	movl   $0x80108f,0x8(%esp)
  800690:	00 
  800691:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800698:	00 
  800699:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  8006a0:	e8 7f 00 00 00       	call   800724 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8006a5:	83 c4 2c             	add    $0x2c,%esp
  8006a8:	5b                   	pop    %ebx
  8006a9:	5e                   	pop    %esi
  8006aa:	5f                   	pop    %edi
  8006ab:	5d                   	pop    %ebp
  8006ac:	c3                   	ret    

008006ad <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	57                   	push   %edi
  8006b1:	56                   	push   %esi
  8006b2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006b3:	be 00 00 00 00       	mov    $0x0,%esi
  8006b8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8006bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006c6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8006c9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8006cb:	5b                   	pop    %ebx
  8006cc:	5e                   	pop    %esi
  8006cd:	5f                   	pop    %edi
  8006ce:	5d                   	pop    %ebp
  8006cf:	c3                   	ret    

008006d0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	57                   	push   %edi
  8006d4:	56                   	push   %esi
  8006d5:	53                   	push   %ebx
  8006d6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006de:	b8 0c 00 00 00       	mov    $0xc,%eax
  8006e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e6:	89 cb                	mov    %ecx,%ebx
  8006e8:	89 cf                	mov    %ecx,%edi
  8006ea:	89 ce                	mov    %ecx,%esi
  8006ec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	7e 28                	jle    80071a <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006f2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006f6:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8006fd:	00 
  8006fe:	c7 44 24 08 8f 10 80 	movl   $0x80108f,0x8(%esp)
  800705:	00 
  800706:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80070d:	00 
  80070e:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  800715:	e8 0a 00 00 00       	call   800724 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80071a:	83 c4 2c             	add    $0x2c,%esp
  80071d:	5b                   	pop    %ebx
  80071e:	5e                   	pop    %esi
  80071f:	5f                   	pop    %edi
  800720:	5d                   	pop    %ebp
  800721:	c3                   	ret    
  800722:	66 90                	xchg   %ax,%ax

00800724 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	56                   	push   %esi
  800728:	53                   	push   %ebx
  800729:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80072c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80072f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800735:	e8 95 fd ff ff       	call   8004cf <sys_getenvid>
  80073a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80073d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800741:	8b 55 08             	mov    0x8(%ebp),%edx
  800744:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800748:	89 74 24 08          	mov    %esi,0x8(%esp)
  80074c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800750:	c7 04 24 bc 10 80 00 	movl   $0x8010bc,(%esp)
  800757:	e8 c2 00 00 00       	call   80081e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80075c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800760:	8b 45 10             	mov    0x10(%ebp),%eax
  800763:	89 04 24             	mov    %eax,(%esp)
  800766:	e8 52 00 00 00       	call   8007bd <vcprintf>
	cprintf("\n");
  80076b:	c7 04 24 e0 10 80 00 	movl   $0x8010e0,(%esp)
  800772:	e8 a7 00 00 00       	call   80081e <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800777:	cc                   	int3   
  800778:	eb fd                	jmp    800777 <_panic+0x53>
  80077a:	66 90                	xchg   %ax,%ax

0080077c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	53                   	push   %ebx
  800780:	83 ec 14             	sub    $0x14,%esp
  800783:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800786:	8b 13                	mov    (%ebx),%edx
  800788:	8d 42 01             	lea    0x1(%edx),%eax
  80078b:	89 03                	mov    %eax,(%ebx)
  80078d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800790:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800794:	3d ff 00 00 00       	cmp    $0xff,%eax
  800799:	75 19                	jne    8007b4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80079b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8007a2:	00 
  8007a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8007a6:	89 04 24             	mov    %eax,(%esp)
  8007a9:	e8 92 fc ff ff       	call   800440 <sys_cputs>
		b->idx = 0;
  8007ae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8007b4:	ff 43 04             	incl   0x4(%ebx)
}
  8007b7:	83 c4 14             	add    $0x14,%esp
  8007ba:	5b                   	pop    %ebx
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8007c6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8007cd:	00 00 00 
	b.cnt = 0;
  8007d0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8007d7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8007da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8007ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f2:	c7 04 24 7c 07 80 00 	movl   $0x80077c,(%esp)
  8007f9:	e8 a9 01 00 00       	call   8009a7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8007fe:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800804:	89 44 24 04          	mov    %eax,0x4(%esp)
  800808:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80080e:	89 04 24             	mov    %eax,(%esp)
  800811:	e8 2a fc ff ff       	call   800440 <sys_cputs>

	return b.cnt;
}
  800816:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80081c:	c9                   	leave  
  80081d:	c3                   	ret    

0080081e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800824:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800827:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082b:	8b 45 08             	mov    0x8(%ebp),%eax
  80082e:	89 04 24             	mov    %eax,(%esp)
  800831:	e8 87 ff ff ff       	call   8007bd <vcprintf>
	va_end(ap);

	return cnt;
}
  800836:	c9                   	leave  
  800837:	c3                   	ret    

00800838 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	57                   	push   %edi
  80083c:	56                   	push   %esi
  80083d:	53                   	push   %ebx
  80083e:	83 ec 3c             	sub    $0x3c,%esp
  800841:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800844:	89 d7                	mov    %edx,%edi
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80084c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084f:	89 c1                	mov    %eax,%ecx
  800851:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800854:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800857:	8b 45 10             	mov    0x10(%ebp),%eax
  80085a:	ba 00 00 00 00       	mov    $0x0,%edx
  80085f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800862:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800865:	39 ca                	cmp    %ecx,%edx
  800867:	72 08                	jb     800871 <printnum+0x39>
  800869:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80086c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80086f:	77 6a                	ja     8008db <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800871:	8b 45 18             	mov    0x18(%ebp),%eax
  800874:	89 44 24 10          	mov    %eax,0x10(%esp)
  800878:	4e                   	dec    %esi
  800879:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80087d:	8b 45 10             	mov    0x10(%ebp),%eax
  800880:	89 44 24 08          	mov    %eax,0x8(%esp)
  800884:	8b 44 24 08          	mov    0x8(%esp),%eax
  800888:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80088c:	89 c3                	mov    %eax,%ebx
  80088e:	89 d6                	mov    %edx,%esi
  800890:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800893:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800896:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80089e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008a1:	89 04 24             	mov    %eax,(%esp)
  8008a4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8008a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ab:	e8 30 05 00 00       	call   800de0 <__udivdi3>
  8008b0:	89 d9                	mov    %ebx,%ecx
  8008b2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008b6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008ba:	89 04 24             	mov    %eax,(%esp)
  8008bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c1:	89 fa                	mov    %edi,%edx
  8008c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008c6:	e8 6d ff ff ff       	call   800838 <printnum>
  8008cb:	eb 19                	jmp    8008e6 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8008cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008d1:	8b 45 18             	mov    0x18(%ebp),%eax
  8008d4:	89 04 24             	mov    %eax,(%esp)
  8008d7:	ff d3                	call   *%ebx
  8008d9:	eb 03                	jmp    8008de <printnum+0xa6>
  8008db:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8008de:	4e                   	dec    %esi
  8008df:	85 f6                	test   %esi,%esi
  8008e1:	7f ea                	jg     8008cd <printnum+0x95>
  8008e3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8008e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ea:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8008ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008ff:	89 04 24             	mov    %eax,(%esp)
  800902:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800905:	89 44 24 04          	mov    %eax,0x4(%esp)
  800909:	e8 02 06 00 00       	call   800f10 <__umoddi3>
  80090e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800912:	0f be 80 e2 10 80 00 	movsbl 0x8010e2(%eax),%eax
  800919:	89 04 24             	mov    %eax,(%esp)
  80091c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80091f:	ff d0                	call   *%eax
}
  800921:	83 c4 3c             	add    $0x3c,%esp
  800924:	5b                   	pop    %ebx
  800925:	5e                   	pop    %esi
  800926:	5f                   	pop    %edi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80092c:	83 fa 01             	cmp    $0x1,%edx
  80092f:	7e 0e                	jle    80093f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800931:	8b 10                	mov    (%eax),%edx
  800933:	8d 4a 08             	lea    0x8(%edx),%ecx
  800936:	89 08                	mov    %ecx,(%eax)
  800938:	8b 02                	mov    (%edx),%eax
  80093a:	8b 52 04             	mov    0x4(%edx),%edx
  80093d:	eb 22                	jmp    800961 <getuint+0x38>
	else if (lflag)
  80093f:	85 d2                	test   %edx,%edx
  800941:	74 10                	je     800953 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800943:	8b 10                	mov    (%eax),%edx
  800945:	8d 4a 04             	lea    0x4(%edx),%ecx
  800948:	89 08                	mov    %ecx,(%eax)
  80094a:	8b 02                	mov    (%edx),%eax
  80094c:	ba 00 00 00 00       	mov    $0x0,%edx
  800951:	eb 0e                	jmp    800961 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800953:	8b 10                	mov    (%eax),%edx
  800955:	8d 4a 04             	lea    0x4(%edx),%ecx
  800958:	89 08                	mov    %ecx,(%eax)
  80095a:	8b 02                	mov    (%edx),%eax
  80095c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800969:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80096c:	8b 10                	mov    (%eax),%edx
  80096e:	3b 50 04             	cmp    0x4(%eax),%edx
  800971:	73 0a                	jae    80097d <sprintputch+0x1a>
		*b->buf++ = ch;
  800973:	8d 4a 01             	lea    0x1(%edx),%ecx
  800976:	89 08                	mov    %ecx,(%eax)
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	88 02                	mov    %al,(%edx)
}
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800985:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800988:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80098c:	8b 45 10             	mov    0x10(%ebp),%eax
  80098f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800993:	8b 45 0c             	mov    0xc(%ebp),%eax
  800996:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	89 04 24             	mov    %eax,(%esp)
  8009a0:	e8 02 00 00 00       	call   8009a7 <vprintfmt>
	va_end(ap);
}
  8009a5:	c9                   	leave  
  8009a6:	c3                   	ret    

008009a7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	57                   	push   %edi
  8009ab:	56                   	push   %esi
  8009ac:	53                   	push   %ebx
  8009ad:	83 ec 3c             	sub    $0x3c,%esp
  8009b0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8009b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009b6:	eb 14                	jmp    8009cc <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8009b8:	85 c0                	test   %eax,%eax
  8009ba:	0f 84 8a 03 00 00    	je     800d4a <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  8009c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009c4:	89 04 24             	mov    %eax,(%esp)
  8009c7:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8009ca:	89 f3                	mov    %esi,%ebx
  8009cc:	8d 73 01             	lea    0x1(%ebx),%esi
  8009cf:	31 c0                	xor    %eax,%eax
  8009d1:	8a 03                	mov    (%ebx),%al
  8009d3:	83 f8 25             	cmp    $0x25,%eax
  8009d6:	75 e0                	jne    8009b8 <vprintfmt+0x11>
  8009d8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8009dc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8009e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8009ea:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8009f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f6:	eb 1d                	jmp    800a15 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009f8:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8009fa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8009fe:	eb 15                	jmp    800a15 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a00:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a02:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800a06:	eb 0d                	jmp    800a15 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800a08:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a0b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a0e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a15:	8d 5e 01             	lea    0x1(%esi),%ebx
  800a18:	31 c0                	xor    %eax,%eax
  800a1a:	8a 06                	mov    (%esi),%al
  800a1c:	8a 0e                	mov    (%esi),%cl
  800a1e:	83 e9 23             	sub    $0x23,%ecx
  800a21:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800a24:	80 f9 55             	cmp    $0x55,%cl
  800a27:	0f 87 ff 02 00 00    	ja     800d2c <vprintfmt+0x385>
  800a2d:	31 c9                	xor    %ecx,%ecx
  800a2f:	8a 4d e0             	mov    -0x20(%ebp),%cl
  800a32:	ff 24 8d a0 11 80 00 	jmp    *0x8011a0(,%ecx,4)
  800a39:	89 de                	mov    %ebx,%esi
  800a3b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800a40:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800a43:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800a47:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800a4a:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800a4d:	83 fb 09             	cmp    $0x9,%ebx
  800a50:	77 2f                	ja     800a81 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800a52:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800a53:	eb eb                	jmp    800a40 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800a55:	8b 45 14             	mov    0x14(%ebp),%eax
  800a58:	8d 48 04             	lea    0x4(%eax),%ecx
  800a5b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a5e:	8b 00                	mov    (%eax),%eax
  800a60:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a63:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800a65:	eb 1d                	jmp    800a84 <vprintfmt+0xdd>
  800a67:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a6a:	f7 d0                	not    %eax
  800a6c:	c1 f8 1f             	sar    $0x1f,%eax
  800a6f:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a72:	89 de                	mov    %ebx,%esi
  800a74:	eb 9f                	jmp    800a15 <vprintfmt+0x6e>
  800a76:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800a78:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800a7f:	eb 94                	jmp    800a15 <vprintfmt+0x6e>
  800a81:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800a84:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a88:	79 8b                	jns    800a15 <vprintfmt+0x6e>
  800a8a:	e9 79 ff ff ff       	jmp    800a08 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800a8f:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a90:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800a92:	eb 81                	jmp    800a15 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800a94:	8b 45 14             	mov    0x14(%ebp),%eax
  800a97:	8d 50 04             	lea    0x4(%eax),%edx
  800a9a:	89 55 14             	mov    %edx,0x14(%ebp)
  800a9d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aa1:	8b 00                	mov    (%eax),%eax
  800aa3:	89 04 24             	mov    %eax,(%esp)
  800aa6:	ff 55 08             	call   *0x8(%ebp)
			break;
  800aa9:	e9 1e ff ff ff       	jmp    8009cc <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800aae:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab1:	8d 50 04             	lea    0x4(%eax),%edx
  800ab4:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab7:	8b 00                	mov    (%eax),%eax
  800ab9:	89 c2                	mov    %eax,%edx
  800abb:	c1 fa 1f             	sar    $0x1f,%edx
  800abe:	31 d0                	xor    %edx,%eax
  800ac0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800ac2:	83 f8 09             	cmp    $0x9,%eax
  800ac5:	7f 0b                	jg     800ad2 <vprintfmt+0x12b>
  800ac7:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  800ace:	85 d2                	test   %edx,%edx
  800ad0:	75 20                	jne    800af2 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  800ad2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ad6:	c7 44 24 08 fa 10 80 	movl   $0x8010fa,0x8(%esp)
  800add:	00 
  800ade:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae5:	89 04 24             	mov    %eax,(%esp)
  800ae8:	e8 92 fe ff ff       	call   80097f <printfmt>
  800aed:	e9 da fe ff ff       	jmp    8009cc <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800af2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800af6:	c7 44 24 08 03 11 80 	movl   $0x801103,0x8(%esp)
  800afd:	00 
  800afe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b02:	8b 45 08             	mov    0x8(%ebp),%eax
  800b05:	89 04 24             	mov    %eax,(%esp)
  800b08:	e8 72 fe ff ff       	call   80097f <printfmt>
  800b0d:	e9 ba fe ff ff       	jmp    8009cc <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b12:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800b15:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b18:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800b1b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b1e:	8d 50 04             	lea    0x4(%eax),%edx
  800b21:	89 55 14             	mov    %edx,0x14(%ebp)
  800b24:	8b 30                	mov    (%eax),%esi
  800b26:	85 f6                	test   %esi,%esi
  800b28:	75 05                	jne    800b2f <vprintfmt+0x188>
				p = "(null)";
  800b2a:	be f3 10 80 00       	mov    $0x8010f3,%esi
			if (width > 0 && padc != '-')
  800b2f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800b33:	0f 84 8c 00 00 00    	je     800bc5 <vprintfmt+0x21e>
  800b39:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b3d:	0f 8e 8a 00 00 00    	jle    800bcd <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b43:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b47:	89 34 24             	mov    %esi,(%esp)
  800b4a:	e8 9b f5 ff ff       	call   8000ea <strnlen>
  800b4f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800b52:	29 c1                	sub    %eax,%ecx
  800b54:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800b57:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800b5b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b5e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800b61:	8b 75 08             	mov    0x8(%ebp),%esi
  800b64:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b67:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b69:	eb 0d                	jmp    800b78 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800b6b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b72:	89 04 24             	mov    %eax,(%esp)
  800b75:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b77:	4b                   	dec    %ebx
  800b78:	85 db                	test   %ebx,%ebx
  800b7a:	7f ef                	jg     800b6b <vprintfmt+0x1c4>
  800b7c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800b7f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b82:	89 c8                	mov    %ecx,%eax
  800b84:	f7 d0                	not    %eax
  800b86:	c1 f8 1f             	sar    $0x1f,%eax
  800b89:	21 c8                	and    %ecx,%eax
  800b8b:	29 c1                	sub    %eax,%ecx
  800b8d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b90:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800b93:	eb 3e                	jmp    800bd3 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b95:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800b99:	74 1b                	je     800bb6 <vprintfmt+0x20f>
  800b9b:	0f be d2             	movsbl %dl,%edx
  800b9e:	83 ea 20             	sub    $0x20,%edx
  800ba1:	83 fa 5e             	cmp    $0x5e,%edx
  800ba4:	76 10                	jbe    800bb6 <vprintfmt+0x20f>
					putch('?', putdat);
  800ba6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800baa:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800bb1:	ff 55 08             	call   *0x8(%ebp)
  800bb4:	eb 0a                	jmp    800bc0 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800bb6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bba:	89 04 24             	mov    %eax,(%esp)
  800bbd:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bc0:	ff 4d dc             	decl   -0x24(%ebp)
  800bc3:	eb 0e                	jmp    800bd3 <vprintfmt+0x22c>
  800bc5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bc8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800bcb:	eb 06                	jmp    800bd3 <vprintfmt+0x22c>
  800bcd:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bd0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800bd3:	46                   	inc    %esi
  800bd4:	8a 56 ff             	mov    -0x1(%esi),%dl
  800bd7:	0f be c2             	movsbl %dl,%eax
  800bda:	85 c0                	test   %eax,%eax
  800bdc:	74 1f                	je     800bfd <vprintfmt+0x256>
  800bde:	85 db                	test   %ebx,%ebx
  800be0:	78 b3                	js     800b95 <vprintfmt+0x1ee>
  800be2:	4b                   	dec    %ebx
  800be3:	79 b0                	jns    800b95 <vprintfmt+0x1ee>
  800be5:	8b 75 08             	mov    0x8(%ebp),%esi
  800be8:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800beb:	eb 16                	jmp    800c03 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800bed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bf1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800bf8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800bfa:	4b                   	dec    %ebx
  800bfb:	eb 06                	jmp    800c03 <vprintfmt+0x25c>
  800bfd:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800c00:	8b 75 08             	mov    0x8(%ebp),%esi
  800c03:	85 db                	test   %ebx,%ebx
  800c05:	7f e6                	jg     800bed <vprintfmt+0x246>
  800c07:	89 75 08             	mov    %esi,0x8(%ebp)
  800c0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0d:	e9 ba fd ff ff       	jmp    8009cc <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c12:	83 fa 01             	cmp    $0x1,%edx
  800c15:	7e 16                	jle    800c2d <vprintfmt+0x286>
		return va_arg(*ap, long long);
  800c17:	8b 45 14             	mov    0x14(%ebp),%eax
  800c1a:	8d 50 08             	lea    0x8(%eax),%edx
  800c1d:	89 55 14             	mov    %edx,0x14(%ebp)
  800c20:	8b 50 04             	mov    0x4(%eax),%edx
  800c23:	8b 00                	mov    (%eax),%eax
  800c25:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c28:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c2b:	eb 32                	jmp    800c5f <vprintfmt+0x2b8>
	else if (lflag)
  800c2d:	85 d2                	test   %edx,%edx
  800c2f:	74 18                	je     800c49 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800c31:	8b 45 14             	mov    0x14(%ebp),%eax
  800c34:	8d 50 04             	lea    0x4(%eax),%edx
  800c37:	89 55 14             	mov    %edx,0x14(%ebp)
  800c3a:	8b 30                	mov    (%eax),%esi
  800c3c:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800c3f:	89 f0                	mov    %esi,%eax
  800c41:	c1 f8 1f             	sar    $0x1f,%eax
  800c44:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c47:	eb 16                	jmp    800c5f <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800c49:	8b 45 14             	mov    0x14(%ebp),%eax
  800c4c:	8d 50 04             	lea    0x4(%eax),%edx
  800c4f:	89 55 14             	mov    %edx,0x14(%ebp)
  800c52:	8b 30                	mov    (%eax),%esi
  800c54:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800c57:	89 f0                	mov    %esi,%eax
  800c59:	c1 f8 1f             	sar    $0x1f,%eax
  800c5c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c62:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800c65:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800c6a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c6e:	0f 89 80 00 00 00    	jns    800cf4 <vprintfmt+0x34d>
				putch('-', putdat);
  800c74:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c78:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800c7f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800c82:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c85:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c88:	f7 d8                	neg    %eax
  800c8a:	83 d2 00             	adc    $0x0,%edx
  800c8d:	f7 da                	neg    %edx
			}
			base = 10;
  800c8f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c94:	eb 5e                	jmp    800cf4 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800c96:	8d 45 14             	lea    0x14(%ebp),%eax
  800c99:	e8 8b fc ff ff       	call   800929 <getuint>
			base = 10;
  800c9e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800ca3:	eb 4f                	jmp    800cf4 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800ca5:	8d 45 14             	lea    0x14(%ebp),%eax
  800ca8:	e8 7c fc ff ff       	call   800929 <getuint>
			base = 8;
  800cad:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800cb2:	eb 40                	jmp    800cf4 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800cb4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cb8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800cbf:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800cc2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cc6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800ccd:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800cd0:	8b 45 14             	mov    0x14(%ebp),%eax
  800cd3:	8d 50 04             	lea    0x4(%eax),%edx
  800cd6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800cd9:	8b 00                	mov    (%eax),%eax
  800cdb:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ce0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800ce5:	eb 0d                	jmp    800cf4 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ce7:	8d 45 14             	lea    0x14(%ebp),%eax
  800cea:	e8 3a fc ff ff       	call   800929 <getuint>
			base = 16;
  800cef:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800cf4:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800cf8:	89 74 24 10          	mov    %esi,0x10(%esp)
  800cfc:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800cff:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800d03:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d07:	89 04 24             	mov    %eax,(%esp)
  800d0a:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d0e:	89 fa                	mov    %edi,%edx
  800d10:	8b 45 08             	mov    0x8(%ebp),%eax
  800d13:	e8 20 fb ff ff       	call   800838 <printnum>
			break;
  800d18:	e9 af fc ff ff       	jmp    8009cc <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d1d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d21:	89 04 24             	mov    %eax,(%esp)
  800d24:	ff 55 08             	call   *0x8(%ebp)
			break;
  800d27:	e9 a0 fc ff ff       	jmp    8009cc <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d2c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d30:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800d37:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d3a:	89 f3                	mov    %esi,%ebx
  800d3c:	eb 01                	jmp    800d3f <vprintfmt+0x398>
  800d3e:	4b                   	dec    %ebx
  800d3f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800d43:	75 f9                	jne    800d3e <vprintfmt+0x397>
  800d45:	e9 82 fc ff ff       	jmp    8009cc <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800d4a:	83 c4 3c             	add    $0x3c,%esp
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    

00800d52 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	83 ec 28             	sub    $0x28,%esp
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d61:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d65:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	74 30                	je     800da3 <vsnprintf+0x51>
  800d73:	85 d2                	test   %edx,%edx
  800d75:	7e 2c                	jle    800da3 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d77:	8b 45 14             	mov    0x14(%ebp),%eax
  800d7a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d7e:	8b 45 10             	mov    0x10(%ebp),%eax
  800d81:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d85:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d88:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d8c:	c7 04 24 63 09 80 00 	movl   $0x800963,(%esp)
  800d93:	e8 0f fc ff ff       	call   8009a7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d98:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d9b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800da1:	eb 05                	jmp    800da8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800da3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800da8:	c9                   	leave  
  800da9:	c3                   	ret    

00800daa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800db0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800db3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800db7:	8b 45 10             	mov    0x10(%ebp),%eax
  800dba:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc8:	89 04 24             	mov    %eax,(%esp)
  800dcb:	e8 82 ff ff ff       	call   800d52 <vsnprintf>
	va_end(ap);

	return rc;
}
  800dd0:	c9                   	leave  
  800dd1:	c3                   	ret    
  800dd2:	66 90                	xchg   %ax,%ax
  800dd4:	66 90                	xchg   %ax,%ax
  800dd6:	66 90                	xchg   %ax,%ax
  800dd8:	66 90                	xchg   %ax,%ax
  800dda:	66 90                	xchg   %ax,%ax
  800ddc:	66 90                	xchg   %ax,%ax
  800dde:	66 90                	xchg   %ax,%ax

00800de0 <__udivdi3>:
  800de0:	55                   	push   %ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800dea:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800dee:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800df2:	8b 44 24 28          	mov    0x28(%esp),%eax
  800df6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800dfa:	89 ea                	mov    %ebp,%edx
  800dfc:	89 0c 24             	mov    %ecx,(%esp)
  800dff:	85 c0                	test   %eax,%eax
  800e01:	75 2d                	jne    800e30 <__udivdi3+0x50>
  800e03:	39 e9                	cmp    %ebp,%ecx
  800e05:	77 61                	ja     800e68 <__udivdi3+0x88>
  800e07:	89 ce                	mov    %ecx,%esi
  800e09:	85 c9                	test   %ecx,%ecx
  800e0b:	75 0b                	jne    800e18 <__udivdi3+0x38>
  800e0d:	b8 01 00 00 00       	mov    $0x1,%eax
  800e12:	31 d2                	xor    %edx,%edx
  800e14:	f7 f1                	div    %ecx
  800e16:	89 c6                	mov    %eax,%esi
  800e18:	31 d2                	xor    %edx,%edx
  800e1a:	89 e8                	mov    %ebp,%eax
  800e1c:	f7 f6                	div    %esi
  800e1e:	89 c5                	mov    %eax,%ebp
  800e20:	89 f8                	mov    %edi,%eax
  800e22:	f7 f6                	div    %esi
  800e24:	89 ea                	mov    %ebp,%edx
  800e26:	83 c4 0c             	add    $0xc,%esp
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    
  800e2d:	8d 76 00             	lea    0x0(%esi),%esi
  800e30:	39 e8                	cmp    %ebp,%eax
  800e32:	77 24                	ja     800e58 <__udivdi3+0x78>
  800e34:	0f bd e8             	bsr    %eax,%ebp
  800e37:	83 f5 1f             	xor    $0x1f,%ebp
  800e3a:	75 3c                	jne    800e78 <__udivdi3+0x98>
  800e3c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e40:	39 34 24             	cmp    %esi,(%esp)
  800e43:	0f 86 9f 00 00 00    	jbe    800ee8 <__udivdi3+0x108>
  800e49:	39 d0                	cmp    %edx,%eax
  800e4b:	0f 82 97 00 00 00    	jb     800ee8 <__udivdi3+0x108>
  800e51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e58:	31 d2                	xor    %edx,%edx
  800e5a:	31 c0                	xor    %eax,%eax
  800e5c:	83 c4 0c             	add    $0xc,%esp
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    
  800e63:	90                   	nop
  800e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e68:	89 f8                	mov    %edi,%eax
  800e6a:	f7 f1                	div    %ecx
  800e6c:	31 d2                	xor    %edx,%edx
  800e6e:	83 c4 0c             	add    $0xc,%esp
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    
  800e75:	8d 76 00             	lea    0x0(%esi),%esi
  800e78:	89 e9                	mov    %ebp,%ecx
  800e7a:	8b 3c 24             	mov    (%esp),%edi
  800e7d:	d3 e0                	shl    %cl,%eax
  800e7f:	89 c6                	mov    %eax,%esi
  800e81:	b8 20 00 00 00       	mov    $0x20,%eax
  800e86:	29 e8                	sub    %ebp,%eax
  800e88:	88 c1                	mov    %al,%cl
  800e8a:	d3 ef                	shr    %cl,%edi
  800e8c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e90:	89 e9                	mov    %ebp,%ecx
  800e92:	8b 3c 24             	mov    (%esp),%edi
  800e95:	09 74 24 08          	or     %esi,0x8(%esp)
  800e99:	d3 e7                	shl    %cl,%edi
  800e9b:	89 d6                	mov    %edx,%esi
  800e9d:	88 c1                	mov    %al,%cl
  800e9f:	d3 ee                	shr    %cl,%esi
  800ea1:	89 e9                	mov    %ebp,%ecx
  800ea3:	89 3c 24             	mov    %edi,(%esp)
  800ea6:	d3 e2                	shl    %cl,%edx
  800ea8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800eac:	88 c1                	mov    %al,%cl
  800eae:	d3 ef                	shr    %cl,%edi
  800eb0:	09 d7                	or     %edx,%edi
  800eb2:	89 f2                	mov    %esi,%edx
  800eb4:	89 f8                	mov    %edi,%eax
  800eb6:	f7 74 24 08          	divl   0x8(%esp)
  800eba:	89 d6                	mov    %edx,%esi
  800ebc:	89 c7                	mov    %eax,%edi
  800ebe:	f7 24 24             	mull   (%esp)
  800ec1:	89 14 24             	mov    %edx,(%esp)
  800ec4:	39 d6                	cmp    %edx,%esi
  800ec6:	72 30                	jb     800ef8 <__udivdi3+0x118>
  800ec8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ecc:	89 e9                	mov    %ebp,%ecx
  800ece:	d3 e2                	shl    %cl,%edx
  800ed0:	39 c2                	cmp    %eax,%edx
  800ed2:	73 05                	jae    800ed9 <__udivdi3+0xf9>
  800ed4:	3b 34 24             	cmp    (%esp),%esi
  800ed7:	74 1f                	je     800ef8 <__udivdi3+0x118>
  800ed9:	89 f8                	mov    %edi,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	e9 7a ff ff ff       	jmp    800e5c <__udivdi3+0x7c>
  800ee2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ee8:	31 d2                	xor    %edx,%edx
  800eea:	b8 01 00 00 00       	mov    $0x1,%eax
  800eef:	e9 68 ff ff ff       	jmp    800e5c <__udivdi3+0x7c>
  800ef4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ef8:	8d 47 ff             	lea    -0x1(%edi),%eax
  800efb:	31 d2                	xor    %edx,%edx
  800efd:	83 c4 0c             	add    $0xc,%esp
  800f00:	5e                   	pop    %esi
  800f01:	5f                   	pop    %edi
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    
  800f04:	66 90                	xchg   %ax,%ax
  800f06:	66 90                	xchg   %ax,%ax
  800f08:	66 90                	xchg   %ax,%ax
  800f0a:	66 90                	xchg   %ax,%ax
  800f0c:	66 90                	xchg   %ax,%ax
  800f0e:	66 90                	xchg   %ax,%ax

00800f10 <__umoddi3>:
  800f10:	55                   	push   %ebp
  800f11:	57                   	push   %edi
  800f12:	56                   	push   %esi
  800f13:	83 ec 14             	sub    $0x14,%esp
  800f16:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f1a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f1e:	89 c7                	mov    %eax,%edi
  800f20:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f24:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800f28:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f2c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f30:	89 34 24             	mov    %esi,(%esp)
  800f33:	89 c2                	mov    %eax,%edx
  800f35:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f39:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	75 17                	jne    800f58 <__umoddi3+0x48>
  800f41:	39 fe                	cmp    %edi,%esi
  800f43:	76 4b                	jbe    800f90 <__umoddi3+0x80>
  800f45:	89 c8                	mov    %ecx,%eax
  800f47:	89 fa                	mov    %edi,%edx
  800f49:	f7 f6                	div    %esi
  800f4b:	89 d0                	mov    %edx,%eax
  800f4d:	31 d2                	xor    %edx,%edx
  800f4f:	83 c4 14             	add    $0x14,%esp
  800f52:	5e                   	pop    %esi
  800f53:	5f                   	pop    %edi
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    
  800f56:	66 90                	xchg   %ax,%ax
  800f58:	39 f8                	cmp    %edi,%eax
  800f5a:	77 54                	ja     800fb0 <__umoddi3+0xa0>
  800f5c:	0f bd e8             	bsr    %eax,%ebp
  800f5f:	83 f5 1f             	xor    $0x1f,%ebp
  800f62:	75 5c                	jne    800fc0 <__umoddi3+0xb0>
  800f64:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f68:	39 3c 24             	cmp    %edi,(%esp)
  800f6b:	0f 87 f7 00 00 00    	ja     801068 <__umoddi3+0x158>
  800f71:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f75:	29 f1                	sub    %esi,%ecx
  800f77:	19 c7                	sbb    %eax,%edi
  800f79:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f7d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f81:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f85:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f89:	83 c4 14             	add    $0x14,%esp
  800f8c:	5e                   	pop    %esi
  800f8d:	5f                   	pop    %edi
  800f8e:	5d                   	pop    %ebp
  800f8f:	c3                   	ret    
  800f90:	89 f5                	mov    %esi,%ebp
  800f92:	85 f6                	test   %esi,%esi
  800f94:	75 0b                	jne    800fa1 <__umoddi3+0x91>
  800f96:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9b:	31 d2                	xor    %edx,%edx
  800f9d:	f7 f6                	div    %esi
  800f9f:	89 c5                	mov    %eax,%ebp
  800fa1:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fa5:	31 d2                	xor    %edx,%edx
  800fa7:	f7 f5                	div    %ebp
  800fa9:	89 c8                	mov    %ecx,%eax
  800fab:	f7 f5                	div    %ebp
  800fad:	eb 9c                	jmp    800f4b <__umoddi3+0x3b>
  800faf:	90                   	nop
  800fb0:	89 c8                	mov    %ecx,%eax
  800fb2:	89 fa                	mov    %edi,%edx
  800fb4:	83 c4 14             	add    $0x14,%esp
  800fb7:	5e                   	pop    %esi
  800fb8:	5f                   	pop    %edi
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    
  800fbb:	90                   	nop
  800fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fc0:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800fc7:	00 
  800fc8:	8b 34 24             	mov    (%esp),%esi
  800fcb:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fcf:	89 e9                	mov    %ebp,%ecx
  800fd1:	29 e8                	sub    %ebp,%eax
  800fd3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd7:	89 f0                	mov    %esi,%eax
  800fd9:	d3 e2                	shl    %cl,%edx
  800fdb:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800fdf:	d3 e8                	shr    %cl,%eax
  800fe1:	89 04 24             	mov    %eax,(%esp)
  800fe4:	89 e9                	mov    %ebp,%ecx
  800fe6:	89 f0                	mov    %esi,%eax
  800fe8:	09 14 24             	or     %edx,(%esp)
  800feb:	d3 e0                	shl    %cl,%eax
  800fed:	89 fa                	mov    %edi,%edx
  800fef:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800ff3:	d3 ea                	shr    %cl,%edx
  800ff5:	89 e9                	mov    %ebp,%ecx
  800ff7:	89 c6                	mov    %eax,%esi
  800ff9:	d3 e7                	shl    %cl,%edi
  800ffb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fff:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801003:	8b 44 24 10          	mov    0x10(%esp),%eax
  801007:	d3 e8                	shr    %cl,%eax
  801009:	09 f8                	or     %edi,%eax
  80100b:	89 e9                	mov    %ebp,%ecx
  80100d:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801011:	d3 e7                	shl    %cl,%edi
  801013:	f7 34 24             	divl   (%esp)
  801016:	89 d1                	mov    %edx,%ecx
  801018:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80101c:	f7 e6                	mul    %esi
  80101e:	89 c7                	mov    %eax,%edi
  801020:	89 d6                	mov    %edx,%esi
  801022:	39 d1                	cmp    %edx,%ecx
  801024:	72 2e                	jb     801054 <__umoddi3+0x144>
  801026:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80102a:	72 24                	jb     801050 <__umoddi3+0x140>
  80102c:	89 ca                	mov    %ecx,%edx
  80102e:	89 e9                	mov    %ebp,%ecx
  801030:	8b 44 24 08          	mov    0x8(%esp),%eax
  801034:	29 f8                	sub    %edi,%eax
  801036:	19 f2                	sbb    %esi,%edx
  801038:	d3 e8                	shr    %cl,%eax
  80103a:	89 d6                	mov    %edx,%esi
  80103c:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801040:	d3 e6                	shl    %cl,%esi
  801042:	89 e9                	mov    %ebp,%ecx
  801044:	09 f0                	or     %esi,%eax
  801046:	d3 ea                	shr    %cl,%edx
  801048:	83 c4 14             	add    $0x14,%esp
  80104b:	5e                   	pop    %esi
  80104c:	5f                   	pop    %edi
  80104d:	5d                   	pop    %ebp
  80104e:	c3                   	ret    
  80104f:	90                   	nop
  801050:	39 d1                	cmp    %edx,%ecx
  801052:	75 d8                	jne    80102c <__umoddi3+0x11c>
  801054:	89 d6                	mov    %edx,%esi
  801056:	89 c7                	mov    %eax,%edi
  801058:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  80105c:	1b 34 24             	sbb    (%esp),%esi
  80105f:	eb cb                	jmp    80102c <__umoddi3+0x11c>
  801061:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801068:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80106c:	0f 82 ff fe ff ff    	jb     800f71 <__umoddi3+0x61>
  801072:	e9 0a ff ff ff       	jmp    800f81 <__umoddi3+0x71>
