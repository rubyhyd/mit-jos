
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 37 00 00 00       	call   800068 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
  sys_cputs(hello, 5);
  80003a:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  800041:	00 
  800042:	a1 00 20 80 00       	mov    0x802000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 f9 03 00 00       	call   800448 <sys_cputs>
	sys_cputs(hello, 1024*1024);
  80004f:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800056:	00 
  800057:	a1 00 20 80 00       	mov    0x802000,%eax
  80005c:	89 04 24             	mov    %eax,(%esp)
  80005f:	e8 e4 03 00 00       	call   800448 <sys_cputs>
}
  800064:	c9                   	leave  
  800065:	c3                   	ret    
  800066:	66 90                	xchg   %ax,%ax

00800068 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	56                   	push   %esi
  80006c:	53                   	push   %ebx
  80006d:	83 ec 10             	sub    $0x10,%esp
  800070:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800073:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  800076:	b8 0c 20 80 00       	mov    $0x80200c,%eax
  80007b:	2d 08 20 80 00       	sub    $0x802008,%eax
  800080:	89 44 24 08          	mov    %eax,0x8(%esp)
  800084:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80008b:	00 
  80008c:	c7 04 24 08 20 80 00 	movl   $0x802008,(%esp)
  800093:	e8 bb 01 00 00       	call   800253 <memset>

	thisenv = 0;
	thisenv = &envs[0];
  800098:	c7 05 08 20 80 00 00 	movl   $0xeec00000,0x802008
  80009f:	00 c0 ee 
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x45>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  8000ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000b1:	89 1c 24             	mov    %ebx,(%esp)
  8000b4:	e8 7b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b9:	e8 0a 00 00 00       	call   8000c8 <exit>
}
  8000be:	83 c4 10             	add    $0x10,%esp
  8000c1:	5b                   	pop    %ebx
  8000c2:	5e                   	pop    %esi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    
  8000c5:	66 90                	xchg   %ax,%ax
  8000c7:	90                   	nop

008000c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d5:	e8 ab 03 00 00       	call   800485 <sys_env_destroy>
}
  8000da:	c9                   	leave  
  8000db:	c3                   	ret    

008000dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8000e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e7:	eb 01                	jmp    8000ea <strlen+0xe>
		n++;
  8000e9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8000ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8000ee:	75 f9                	jne    8000e9 <strlen+0xd>
		n++;
	return n;
}
  8000f0:	5d                   	pop    %ebp
  8000f1:	c3                   	ret    

008000f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8000fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800100:	eb 01                	jmp    800103 <strnlen+0x11>
		n++;
  800102:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800103:	39 d0                	cmp    %edx,%eax
  800105:	74 06                	je     80010d <strnlen+0x1b>
  800107:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80010b:	75 f5                	jne    800102 <strnlen+0x10>
		n++;
	return n;
}
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    

0080010f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	53                   	push   %ebx
  800113:	8b 45 08             	mov    0x8(%ebp),%eax
  800116:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800119:	89 c2                	mov    %eax,%edx
  80011b:	42                   	inc    %edx
  80011c:	41                   	inc    %ecx
  80011d:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800120:	88 5a ff             	mov    %bl,-0x1(%edx)
  800123:	84 db                	test   %bl,%bl
  800125:	75 f4                	jne    80011b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800127:	5b                   	pop    %ebx
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	53                   	push   %ebx
  80012e:	83 ec 08             	sub    $0x8,%esp
  800131:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800134:	89 1c 24             	mov    %ebx,(%esp)
  800137:	e8 a0 ff ff ff       	call   8000dc <strlen>
	strcpy(dst + len, src);
  80013c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80013f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800143:	01 d8                	add    %ebx,%eax
  800145:	89 04 24             	mov    %eax,(%esp)
  800148:	e8 c2 ff ff ff       	call   80010f <strcpy>
	return dst;
}
  80014d:	89 d8                	mov    %ebx,%eax
  80014f:	83 c4 08             	add    $0x8,%esp
  800152:	5b                   	pop    %ebx
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
  80015a:	8b 75 08             	mov    0x8(%ebp),%esi
  80015d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800160:	89 f3                	mov    %esi,%ebx
  800162:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800165:	89 f2                	mov    %esi,%edx
  800167:	eb 0c                	jmp    800175 <strncpy+0x20>
		*dst++ = *src;
  800169:	42                   	inc    %edx
  80016a:	8a 01                	mov    (%ecx),%al
  80016c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80016f:	80 39 01             	cmpb   $0x1,(%ecx)
  800172:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800175:	39 da                	cmp    %ebx,%edx
  800177:	75 f0                	jne    800169 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800179:	89 f0                	mov    %esi,%eax
  80017b:	5b                   	pop    %ebx
  80017c:	5e                   	pop    %esi
  80017d:	5d                   	pop    %ebp
  80017e:	c3                   	ret    

0080017f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	56                   	push   %esi
  800183:	53                   	push   %ebx
  800184:	8b 75 08             	mov    0x8(%ebp),%esi
  800187:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80018d:	89 f0                	mov    %esi,%eax
  80018f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800193:	85 c9                	test   %ecx,%ecx
  800195:	75 07                	jne    80019e <strlcpy+0x1f>
  800197:	eb 18                	jmp    8001b1 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800199:	40                   	inc    %eax
  80019a:	42                   	inc    %edx
  80019b:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80019e:	39 d8                	cmp    %ebx,%eax
  8001a0:	74 0a                	je     8001ac <strlcpy+0x2d>
  8001a2:	8a 0a                	mov    (%edx),%cl
  8001a4:	84 c9                	test   %cl,%cl
  8001a6:	75 f1                	jne    800199 <strlcpy+0x1a>
  8001a8:	89 c2                	mov    %eax,%edx
  8001aa:	eb 02                	jmp    8001ae <strlcpy+0x2f>
  8001ac:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8001ae:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8001b1:	29 f0                	sub    %esi,%eax
}
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5d                   	pop    %ebp
  8001b6:	c3                   	ret    

008001b7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001bd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8001c0:	eb 02                	jmp    8001c4 <strcmp+0xd>
		p++, q++;
  8001c2:	41                   	inc    %ecx
  8001c3:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8001c4:	8a 01                	mov    (%ecx),%al
  8001c6:	84 c0                	test   %al,%al
  8001c8:	74 04                	je     8001ce <strcmp+0x17>
  8001ca:	3a 02                	cmp    (%edx),%al
  8001cc:	74 f4                	je     8001c2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8001ce:	25 ff 00 00 00       	and    $0xff,%eax
  8001d3:	8a 0a                	mov    (%edx),%cl
  8001d5:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8001db:	29 c8                	sub    %ecx,%eax
}
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	53                   	push   %ebx
  8001e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e9:	89 c3                	mov    %eax,%ebx
  8001eb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8001ee:	eb 02                	jmp    8001f2 <strncmp+0x13>
		n--, p++, q++;
  8001f0:	40                   	inc    %eax
  8001f1:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8001f2:	39 d8                	cmp    %ebx,%eax
  8001f4:	74 20                	je     800216 <strncmp+0x37>
  8001f6:	8a 08                	mov    (%eax),%cl
  8001f8:	84 c9                	test   %cl,%cl
  8001fa:	74 04                	je     800200 <strncmp+0x21>
  8001fc:	3a 0a                	cmp    (%edx),%cl
  8001fe:	74 f0                	je     8001f0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800200:	8a 18                	mov    (%eax),%bl
  800202:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800208:	89 d8                	mov    %ebx,%eax
  80020a:	8a 1a                	mov    (%edx),%bl
  80020c:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800212:	29 d8                	sub    %ebx,%eax
  800214:	eb 05                	jmp    80021b <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800216:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80021b:	5b                   	pop    %ebx
  80021c:	5d                   	pop    %ebp
  80021d:	c3                   	ret    

0080021e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	8b 45 08             	mov    0x8(%ebp),%eax
  800224:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800227:	eb 05                	jmp    80022e <strchr+0x10>
		if (*s == c)
  800229:	38 ca                	cmp    %cl,%dl
  80022b:	74 0c                	je     800239 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80022d:	40                   	inc    %eax
  80022e:	8a 10                	mov    (%eax),%dl
  800230:	84 d2                	test   %dl,%dl
  800232:	75 f5                	jne    800229 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800234:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800239:	5d                   	pop    %ebp
  80023a:	c3                   	ret    

0080023b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	8b 45 08             	mov    0x8(%ebp),%eax
  800241:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800244:	eb 05                	jmp    80024b <strfind+0x10>
		if (*s == c)
  800246:	38 ca                	cmp    %cl,%dl
  800248:	74 07                	je     800251 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80024a:	40                   	inc    %eax
  80024b:	8a 10                	mov    (%eax),%dl
  80024d:	84 d2                	test   %dl,%dl
  80024f:	75 f5                	jne    800246 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800251:	5d                   	pop    %ebp
  800252:	c3                   	ret    

00800253 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	57                   	push   %edi
  800257:	56                   	push   %esi
  800258:	53                   	push   %ebx
  800259:	8b 7d 08             	mov    0x8(%ebp),%edi
  80025c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80025f:	85 c9                	test   %ecx,%ecx
  800261:	74 37                	je     80029a <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800263:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800269:	75 29                	jne    800294 <memset+0x41>
  80026b:	f6 c1 03             	test   $0x3,%cl
  80026e:	75 24                	jne    800294 <memset+0x41>
		c &= 0xFF;
  800270:	31 d2                	xor    %edx,%edx
  800272:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800275:	89 d3                	mov    %edx,%ebx
  800277:	c1 e3 08             	shl    $0x8,%ebx
  80027a:	89 d6                	mov    %edx,%esi
  80027c:	c1 e6 18             	shl    $0x18,%esi
  80027f:	89 d0                	mov    %edx,%eax
  800281:	c1 e0 10             	shl    $0x10,%eax
  800284:	09 f0                	or     %esi,%eax
  800286:	09 c2                	or     %eax,%edx
  800288:	89 d0                	mov    %edx,%eax
  80028a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80028c:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80028f:	fc                   	cld    
  800290:	f3 ab                	rep stos %eax,%es:(%edi)
  800292:	eb 06                	jmp    80029a <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
  800297:	fc                   	cld    
  800298:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80029a:	89 f8                	mov    %edi,%eax
  80029c:	5b                   	pop    %ebx
  80029d:	5e                   	pop    %esi
  80029e:	5f                   	pop    %edi
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8002af:	39 c6                	cmp    %eax,%esi
  8002b1:	73 33                	jae    8002e6 <memmove+0x45>
  8002b3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8002b6:	39 d0                	cmp    %edx,%eax
  8002b8:	73 2c                	jae    8002e6 <memmove+0x45>
		s += n;
		d += n;
  8002ba:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8002bd:	89 d6                	mov    %edx,%esi
  8002bf:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8002c1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8002c7:	75 13                	jne    8002dc <memmove+0x3b>
  8002c9:	f6 c1 03             	test   $0x3,%cl
  8002cc:	75 0e                	jne    8002dc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8002ce:	83 ef 04             	sub    $0x4,%edi
  8002d1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8002d4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8002d7:	fd                   	std    
  8002d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8002da:	eb 07                	jmp    8002e3 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8002dc:	4f                   	dec    %edi
  8002dd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8002e0:	fd                   	std    
  8002e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8002e3:	fc                   	cld    
  8002e4:	eb 1d                	jmp    800303 <memmove+0x62>
  8002e6:	89 f2                	mov    %esi,%edx
  8002e8:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8002ea:	f6 c2 03             	test   $0x3,%dl
  8002ed:	75 0f                	jne    8002fe <memmove+0x5d>
  8002ef:	f6 c1 03             	test   $0x3,%cl
  8002f2:	75 0a                	jne    8002fe <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8002f4:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8002f7:	89 c7                	mov    %eax,%edi
  8002f9:	fc                   	cld    
  8002fa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8002fc:	eb 05                	jmp    800303 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8002fe:	89 c7                	mov    %eax,%edi
  800300:	fc                   	cld    
  800301:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800303:	5e                   	pop    %esi
  800304:	5f                   	pop    %edi
  800305:	5d                   	pop    %ebp
  800306:	c3                   	ret    

00800307 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80030d:	8b 45 10             	mov    0x10(%ebp),%eax
  800310:	89 44 24 08          	mov    %eax,0x8(%esp)
  800314:	8b 45 0c             	mov    0xc(%ebp),%eax
  800317:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031b:	8b 45 08             	mov    0x8(%ebp),%eax
  80031e:	89 04 24             	mov    %eax,(%esp)
  800321:	e8 7b ff ff ff       	call   8002a1 <memmove>
}
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	56                   	push   %esi
  80032c:	53                   	push   %ebx
  80032d:	8b 55 08             	mov    0x8(%ebp),%edx
  800330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800333:	89 d6                	mov    %edx,%esi
  800335:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800338:	eb 19                	jmp    800353 <memcmp+0x2b>
		if (*s1 != *s2)
  80033a:	8a 02                	mov    (%edx),%al
  80033c:	8a 19                	mov    (%ecx),%bl
  80033e:	38 d8                	cmp    %bl,%al
  800340:	74 0f                	je     800351 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800342:	25 ff 00 00 00       	and    $0xff,%eax
  800347:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80034d:	29 d8                	sub    %ebx,%eax
  80034f:	eb 0b                	jmp    80035c <memcmp+0x34>
		s1++, s2++;
  800351:	42                   	inc    %edx
  800352:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800353:	39 f2                	cmp    %esi,%edx
  800355:	75 e3                	jne    80033a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800357:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80035c:	5b                   	pop    %ebx
  80035d:	5e                   	pop    %esi
  80035e:	5d                   	pop    %ebp
  80035f:	c3                   	ret    

00800360 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	8b 45 08             	mov    0x8(%ebp),%eax
  800366:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800369:	89 c2                	mov    %eax,%edx
  80036b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80036e:	eb 05                	jmp    800375 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800370:	38 08                	cmp    %cl,(%eax)
  800372:	74 05                	je     800379 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800374:	40                   	inc    %eax
  800375:	39 d0                	cmp    %edx,%eax
  800377:	72 f7                	jb     800370 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	57                   	push   %edi
  80037f:	56                   	push   %esi
  800380:	53                   	push   %ebx
  800381:	8b 55 08             	mov    0x8(%ebp),%edx
  800384:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800387:	eb 01                	jmp    80038a <strtol+0xf>
		s++;
  800389:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80038a:	8a 02                	mov    (%edx),%al
  80038c:	3c 09                	cmp    $0x9,%al
  80038e:	74 f9                	je     800389 <strtol+0xe>
  800390:	3c 20                	cmp    $0x20,%al
  800392:	74 f5                	je     800389 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800394:	3c 2b                	cmp    $0x2b,%al
  800396:	75 08                	jne    8003a0 <strtol+0x25>
		s++;
  800398:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800399:	bf 00 00 00 00       	mov    $0x0,%edi
  80039e:	eb 10                	jmp    8003b0 <strtol+0x35>
  8003a0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8003a5:	3c 2d                	cmp    $0x2d,%al
  8003a7:	75 07                	jne    8003b0 <strtol+0x35>
		s++, neg = 1;
  8003a9:	8d 52 01             	lea    0x1(%edx),%edx
  8003ac:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8003b0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8003b6:	75 15                	jne    8003cd <strtol+0x52>
  8003b8:	80 3a 30             	cmpb   $0x30,(%edx)
  8003bb:	75 10                	jne    8003cd <strtol+0x52>
  8003bd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8003c1:	75 0a                	jne    8003cd <strtol+0x52>
		s += 2, base = 16;
  8003c3:	83 c2 02             	add    $0x2,%edx
  8003c6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8003cb:	eb 0e                	jmp    8003db <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  8003cd:	85 db                	test   %ebx,%ebx
  8003cf:	75 0a                	jne    8003db <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8003d1:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8003d3:	80 3a 30             	cmpb   $0x30,(%edx)
  8003d6:	75 03                	jne    8003db <strtol+0x60>
		s++, base = 8;
  8003d8:	42                   	inc    %edx
  8003d9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  8003db:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8003e3:	8a 0a                	mov    (%edx),%cl
  8003e5:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8003e8:	89 f3                	mov    %esi,%ebx
  8003ea:	80 fb 09             	cmp    $0x9,%bl
  8003ed:	77 08                	ja     8003f7 <strtol+0x7c>
			dig = *s - '0';
  8003ef:	0f be c9             	movsbl %cl,%ecx
  8003f2:	83 e9 30             	sub    $0x30,%ecx
  8003f5:	eb 22                	jmp    800419 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  8003f7:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8003fa:	89 f3                	mov    %esi,%ebx
  8003fc:	80 fb 19             	cmp    $0x19,%bl
  8003ff:	77 08                	ja     800409 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800401:	0f be c9             	movsbl %cl,%ecx
  800404:	83 e9 57             	sub    $0x57,%ecx
  800407:	eb 10                	jmp    800419 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800409:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80040c:	89 f3                	mov    %esi,%ebx
  80040e:	80 fb 19             	cmp    $0x19,%bl
  800411:	77 14                	ja     800427 <strtol+0xac>
			dig = *s - 'A' + 10;
  800413:	0f be c9             	movsbl %cl,%ecx
  800416:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800419:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80041c:	7d 0d                	jge    80042b <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  80041e:	42                   	inc    %edx
  80041f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800423:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800425:	eb bc                	jmp    8003e3 <strtol+0x68>
  800427:	89 c1                	mov    %eax,%ecx
  800429:	eb 02                	jmp    80042d <strtol+0xb2>
  80042b:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80042d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800431:	74 05                	je     800438 <strtol+0xbd>
		*endptr = (char *) s;
  800433:	8b 75 0c             	mov    0xc(%ebp),%esi
  800436:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800438:	85 ff                	test   %edi,%edi
  80043a:	74 04                	je     800440 <strtol+0xc5>
  80043c:	89 c8                	mov    %ecx,%eax
  80043e:	f7 d8                	neg    %eax
}
  800440:	5b                   	pop    %ebx
  800441:	5e                   	pop    %esi
  800442:	5f                   	pop    %edi
  800443:	5d                   	pop    %ebp
  800444:	c3                   	ret    
  800445:	66 90                	xchg   %ax,%ax
  800447:	90                   	nop

00800448 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	57                   	push   %edi
  80044c:	56                   	push   %esi
  80044d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80044e:	b8 00 00 00 00       	mov    $0x0,%eax
  800453:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800456:	8b 55 08             	mov    0x8(%ebp),%edx
  800459:	89 c3                	mov    %eax,%ebx
  80045b:	89 c7                	mov    %eax,%edi
  80045d:	89 c6                	mov    %eax,%esi
  80045f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800461:	5b                   	pop    %ebx
  800462:	5e                   	pop    %esi
  800463:	5f                   	pop    %edi
  800464:	5d                   	pop    %ebp
  800465:	c3                   	ret    

00800466 <sys_cgetc>:

int
sys_cgetc(void)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	57                   	push   %edi
  80046a:	56                   	push   %esi
  80046b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80046c:	ba 00 00 00 00       	mov    $0x0,%edx
  800471:	b8 01 00 00 00       	mov    $0x1,%eax
  800476:	89 d1                	mov    %edx,%ecx
  800478:	89 d3                	mov    %edx,%ebx
  80047a:	89 d7                	mov    %edx,%edi
  80047c:	89 d6                	mov    %edx,%esi
  80047e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800480:	5b                   	pop    %ebx
  800481:	5e                   	pop    %esi
  800482:	5f                   	pop    %edi
  800483:	5d                   	pop    %ebp
  800484:	c3                   	ret    

00800485 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800485:	55                   	push   %ebp
  800486:	89 e5                	mov    %esp,%ebp
  800488:	57                   	push   %edi
  800489:	56                   	push   %esi
  80048a:	53                   	push   %ebx
  80048b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80048e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800493:	b8 03 00 00 00       	mov    $0x3,%eax
  800498:	8b 55 08             	mov    0x8(%ebp),%edx
  80049b:	89 cb                	mov    %ecx,%ebx
  80049d:	89 cf                	mov    %ecx,%edi
  80049f:	89 ce                	mov    %ecx,%esi
  8004a1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	7e 28                	jle    8004cf <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004ab:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8004b2:	00 
  8004b3:	c7 44 24 08 78 0e 80 	movl   $0x800e78,0x8(%esp)
  8004ba:	00 
  8004bb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004c2:	00 
  8004c3:	c7 04 24 95 0e 80 00 	movl   $0x800e95,(%esp)
  8004ca:	e8 29 00 00 00       	call   8004f8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8004cf:	83 c4 2c             	add    $0x2c,%esp
  8004d2:	5b                   	pop    %ebx
  8004d3:	5e                   	pop    %esi
  8004d4:	5f                   	pop    %edi
  8004d5:	5d                   	pop    %ebp
  8004d6:	c3                   	ret    

008004d7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8004d7:	55                   	push   %ebp
  8004d8:	89 e5                	mov    %esp,%ebp
  8004da:	57                   	push   %edi
  8004db:	56                   	push   %esi
  8004dc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e2:	b8 02 00 00 00       	mov    $0x2,%eax
  8004e7:	89 d1                	mov    %edx,%ecx
  8004e9:	89 d3                	mov    %edx,%ebx
  8004eb:	89 d7                	mov    %edx,%edi
  8004ed:	89 d6                	mov    %edx,%esi
  8004ef:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8004f1:	5b                   	pop    %ebx
  8004f2:	5e                   	pop    %esi
  8004f3:	5f                   	pop    %edi
  8004f4:	5d                   	pop    %ebp
  8004f5:	c3                   	ret    
  8004f6:	66 90                	xchg   %ax,%ax

008004f8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004f8:	55                   	push   %ebp
  8004f9:	89 e5                	mov    %esp,%ebp
  8004fb:	56                   	push   %esi
  8004fc:	53                   	push   %ebx
  8004fd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800500:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800503:	8b 35 04 20 80 00    	mov    0x802004,%esi
  800509:	e8 c9 ff ff ff       	call   8004d7 <sys_getenvid>
  80050e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800511:	89 54 24 10          	mov    %edx,0x10(%esp)
  800515:	8b 55 08             	mov    0x8(%ebp),%edx
  800518:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80051c:	89 74 24 08          	mov    %esi,0x8(%esp)
  800520:	89 44 24 04          	mov    %eax,0x4(%esp)
  800524:	c7 04 24 a4 0e 80 00 	movl   $0x800ea4,(%esp)
  80052b:	e8 c2 00 00 00       	call   8005f2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800530:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800534:	8b 45 10             	mov    0x10(%ebp),%eax
  800537:	89 04 24             	mov    %eax,(%esp)
  80053a:	e8 52 00 00 00       	call   800591 <vcprintf>
	cprintf("\n");
  80053f:	c7 04 24 6c 0e 80 00 	movl   $0x800e6c,(%esp)
  800546:	e8 a7 00 00 00       	call   8005f2 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80054b:	cc                   	int3   
  80054c:	eb fd                	jmp    80054b <_panic+0x53>
  80054e:	66 90                	xchg   %ax,%ax

00800550 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	53                   	push   %ebx
  800554:	83 ec 14             	sub    $0x14,%esp
  800557:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80055a:	8b 13                	mov    (%ebx),%edx
  80055c:	8d 42 01             	lea    0x1(%edx),%eax
  80055f:	89 03                	mov    %eax,(%ebx)
  800561:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800564:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800568:	3d ff 00 00 00       	cmp    $0xff,%eax
  80056d:	75 19                	jne    800588 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80056f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800576:	00 
  800577:	8d 43 08             	lea    0x8(%ebx),%eax
  80057a:	89 04 24             	mov    %eax,(%esp)
  80057d:	e8 c6 fe ff ff       	call   800448 <sys_cputs>
		b->idx = 0;
  800582:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800588:	ff 43 04             	incl   0x4(%ebx)
}
  80058b:	83 c4 14             	add    $0x14,%esp
  80058e:	5b                   	pop    %ebx
  80058f:	5d                   	pop    %ebp
  800590:	c3                   	ret    

00800591 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800591:	55                   	push   %ebp
  800592:	89 e5                	mov    %esp,%ebp
  800594:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80059a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005a1:	00 00 00 
	b.cnt = 0;
  8005a4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005ab:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005bc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c6:	c7 04 24 50 05 80 00 	movl   $0x800550,(%esp)
  8005cd:	e8 a9 01 00 00       	call   80077b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005d2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8005d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005dc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005e2:	89 04 24             	mov    %eax,(%esp)
  8005e5:	e8 5e fe ff ff       	call   800448 <sys_cputs>

	return b.cnt;
}
  8005ea:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005f0:	c9                   	leave  
  8005f1:	c3                   	ret    

008005f2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005f2:	55                   	push   %ebp
  8005f3:	89 e5                	mov    %esp,%ebp
  8005f5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005f8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800602:	89 04 24             	mov    %eax,(%esp)
  800605:	e8 87 ff ff ff       	call   800591 <vcprintf>
	va_end(ap);

	return cnt;
}
  80060a:	c9                   	leave  
  80060b:	c3                   	ret    

0080060c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80060c:	55                   	push   %ebp
  80060d:	89 e5                	mov    %esp,%ebp
  80060f:	57                   	push   %edi
  800610:	56                   	push   %esi
  800611:	53                   	push   %ebx
  800612:	83 ec 3c             	sub    $0x3c,%esp
  800615:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800618:	89 d7                	mov    %edx,%edi
  80061a:	8b 45 08             	mov    0x8(%ebp),%eax
  80061d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800620:	8b 45 0c             	mov    0xc(%ebp),%eax
  800623:	89 c1                	mov    %eax,%ecx
  800625:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800628:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80062b:	8b 45 10             	mov    0x10(%ebp),%eax
  80062e:	ba 00 00 00 00       	mov    $0x0,%edx
  800633:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800636:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800639:	39 ca                	cmp    %ecx,%edx
  80063b:	72 08                	jb     800645 <printnum+0x39>
  80063d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800640:	39 45 10             	cmp    %eax,0x10(%ebp)
  800643:	77 6a                	ja     8006af <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800645:	8b 45 18             	mov    0x18(%ebp),%eax
  800648:	89 44 24 10          	mov    %eax,0x10(%esp)
  80064c:	4e                   	dec    %esi
  80064d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800651:	8b 45 10             	mov    0x10(%ebp),%eax
  800654:	89 44 24 08          	mov    %eax,0x8(%esp)
  800658:	8b 44 24 08          	mov    0x8(%esp),%eax
  80065c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800660:	89 c3                	mov    %eax,%ebx
  800662:	89 d6                	mov    %edx,%esi
  800664:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800667:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80066a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80066e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800672:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800675:	89 04 24             	mov    %eax,(%esp)
  800678:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80067b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80067f:	e8 2c 05 00 00       	call   800bb0 <__udivdi3>
  800684:	89 d9                	mov    %ebx,%ecx
  800686:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80068a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80068e:	89 04 24             	mov    %eax,(%esp)
  800691:	89 54 24 04          	mov    %edx,0x4(%esp)
  800695:	89 fa                	mov    %edi,%edx
  800697:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80069a:	e8 6d ff ff ff       	call   80060c <printnum>
  80069f:	eb 19                	jmp    8006ba <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8006a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a5:	8b 45 18             	mov    0x18(%ebp),%eax
  8006a8:	89 04 24             	mov    %eax,(%esp)
  8006ab:	ff d3                	call   *%ebx
  8006ad:	eb 03                	jmp    8006b2 <printnum+0xa6>
  8006af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006b2:	4e                   	dec    %esi
  8006b3:	85 f6                	test   %esi,%esi
  8006b5:	7f ea                	jg     8006a1 <printnum+0x95>
  8006b7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006be:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8006c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006c5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006cc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006d3:	89 04 24             	mov    %eax,(%esp)
  8006d6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006dd:	e8 fe 05 00 00       	call   800ce0 <__umoddi3>
  8006e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006e6:	0f be 80 c8 0e 80 00 	movsbl 0x800ec8(%eax),%eax
  8006ed:	89 04 24             	mov    %eax,(%esp)
  8006f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006f3:	ff d0                	call   *%eax
}
  8006f5:	83 c4 3c             	add    $0x3c,%esp
  8006f8:	5b                   	pop    %ebx
  8006f9:	5e                   	pop    %esi
  8006fa:	5f                   	pop    %edi
  8006fb:	5d                   	pop    %ebp
  8006fc:	c3                   	ret    

008006fd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800700:	83 fa 01             	cmp    $0x1,%edx
  800703:	7e 0e                	jle    800713 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800705:	8b 10                	mov    (%eax),%edx
  800707:	8d 4a 08             	lea    0x8(%edx),%ecx
  80070a:	89 08                	mov    %ecx,(%eax)
  80070c:	8b 02                	mov    (%edx),%eax
  80070e:	8b 52 04             	mov    0x4(%edx),%edx
  800711:	eb 22                	jmp    800735 <getuint+0x38>
	else if (lflag)
  800713:	85 d2                	test   %edx,%edx
  800715:	74 10                	je     800727 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800717:	8b 10                	mov    (%eax),%edx
  800719:	8d 4a 04             	lea    0x4(%edx),%ecx
  80071c:	89 08                	mov    %ecx,(%eax)
  80071e:	8b 02                	mov    (%edx),%eax
  800720:	ba 00 00 00 00       	mov    $0x0,%edx
  800725:	eb 0e                	jmp    800735 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800727:	8b 10                	mov    (%eax),%edx
  800729:	8d 4a 04             	lea    0x4(%edx),%ecx
  80072c:	89 08                	mov    %ecx,(%eax)
  80072e:	8b 02                	mov    (%edx),%eax
  800730:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800735:	5d                   	pop    %ebp
  800736:	c3                   	ret    

00800737 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800737:	55                   	push   %ebp
  800738:	89 e5                	mov    %esp,%ebp
  80073a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80073d:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800740:	8b 10                	mov    (%eax),%edx
  800742:	3b 50 04             	cmp    0x4(%eax),%edx
  800745:	73 0a                	jae    800751 <sprintputch+0x1a>
		*b->buf++ = ch;
  800747:	8d 4a 01             	lea    0x1(%edx),%ecx
  80074a:	89 08                	mov    %ecx,(%eax)
  80074c:	8b 45 08             	mov    0x8(%ebp),%eax
  80074f:	88 02                	mov    %al,(%edx)
}
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800759:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80075c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800760:	8b 45 10             	mov    0x10(%ebp),%eax
  800763:	89 44 24 08          	mov    %eax,0x8(%esp)
  800767:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076e:	8b 45 08             	mov    0x8(%ebp),%eax
  800771:	89 04 24             	mov    %eax,(%esp)
  800774:	e8 02 00 00 00       	call   80077b <vprintfmt>
	va_end(ap);
}
  800779:	c9                   	leave  
  80077a:	c3                   	ret    

0080077b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	57                   	push   %edi
  80077f:	56                   	push   %esi
  800780:	53                   	push   %ebx
  800781:	83 ec 3c             	sub    $0x3c,%esp
  800784:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800787:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80078a:	eb 14                	jmp    8007a0 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80078c:	85 c0                	test   %eax,%eax
  80078e:	0f 84 8a 03 00 00    	je     800b1e <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  800794:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800798:	89 04 24             	mov    %eax,(%esp)
  80079b:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80079e:	89 f3                	mov    %esi,%ebx
  8007a0:	8d 73 01             	lea    0x1(%ebx),%esi
  8007a3:	31 c0                	xor    %eax,%eax
  8007a5:	8a 03                	mov    (%ebx),%al
  8007a7:	83 f8 25             	cmp    $0x25,%eax
  8007aa:	75 e0                	jne    80078c <vprintfmt+0x11>
  8007ac:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8007b0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8007b7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007be:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8007c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ca:	eb 1d                	jmp    8007e9 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cc:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8007ce:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8007d2:	eb 15                	jmp    8007e9 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d4:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007d6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8007da:	eb 0d                	jmp    8007e9 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8007dc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007df:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8007e2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e9:	8d 5e 01             	lea    0x1(%esi),%ebx
  8007ec:	31 c0                	xor    %eax,%eax
  8007ee:	8a 06                	mov    (%esi),%al
  8007f0:	8a 0e                	mov    (%esi),%cl
  8007f2:	83 e9 23             	sub    $0x23,%ecx
  8007f5:	88 4d e0             	mov    %cl,-0x20(%ebp)
  8007f8:	80 f9 55             	cmp    $0x55,%cl
  8007fb:	0f 87 ff 02 00 00    	ja     800b00 <vprintfmt+0x385>
  800801:	31 c9                	xor    %ecx,%ecx
  800803:	8a 4d e0             	mov    -0x20(%ebp),%cl
  800806:	ff 24 8d 60 0f 80 00 	jmp    *0x800f60(,%ecx,4)
  80080d:	89 de                	mov    %ebx,%esi
  80080f:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800814:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800817:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  80081b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80081e:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800821:	83 fb 09             	cmp    $0x9,%ebx
  800824:	77 2f                	ja     800855 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800826:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800827:	eb eb                	jmp    800814 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800829:	8b 45 14             	mov    0x14(%ebp),%eax
  80082c:	8d 48 04             	lea    0x4(%eax),%ecx
  80082f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800832:	8b 00                	mov    (%eax),%eax
  800834:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800837:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800839:	eb 1d                	jmp    800858 <vprintfmt+0xdd>
  80083b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80083e:	f7 d0                	not    %eax
  800840:	c1 f8 1f             	sar    $0x1f,%eax
  800843:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800846:	89 de                	mov    %ebx,%esi
  800848:	eb 9f                	jmp    8007e9 <vprintfmt+0x6e>
  80084a:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80084c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800853:	eb 94                	jmp    8007e9 <vprintfmt+0x6e>
  800855:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800858:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80085c:	79 8b                	jns    8007e9 <vprintfmt+0x6e>
  80085e:	e9 79 ff ff ff       	jmp    8007dc <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800863:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800864:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800866:	eb 81                	jmp    8007e9 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800868:	8b 45 14             	mov    0x14(%ebp),%eax
  80086b:	8d 50 04             	lea    0x4(%eax),%edx
  80086e:	89 55 14             	mov    %edx,0x14(%ebp)
  800871:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800875:	8b 00                	mov    (%eax),%eax
  800877:	89 04 24             	mov    %eax,(%esp)
  80087a:	ff 55 08             	call   *0x8(%ebp)
			break;
  80087d:	e9 1e ff ff ff       	jmp    8007a0 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800882:	8b 45 14             	mov    0x14(%ebp),%eax
  800885:	8d 50 04             	lea    0x4(%eax),%edx
  800888:	89 55 14             	mov    %edx,0x14(%ebp)
  80088b:	8b 00                	mov    (%eax),%eax
  80088d:	89 c2                	mov    %eax,%edx
  80088f:	c1 fa 1f             	sar    $0x1f,%edx
  800892:	31 d0                	xor    %edx,%eax
  800894:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800896:	83 f8 07             	cmp    $0x7,%eax
  800899:	7f 0b                	jg     8008a6 <vprintfmt+0x12b>
  80089b:	8b 14 85 c0 10 80 00 	mov    0x8010c0(,%eax,4),%edx
  8008a2:	85 d2                	test   %edx,%edx
  8008a4:	75 20                	jne    8008c6 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  8008a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008aa:	c7 44 24 08 e0 0e 80 	movl   $0x800ee0,0x8(%esp)
  8008b1:	00 
  8008b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b9:	89 04 24             	mov    %eax,(%esp)
  8008bc:	e8 92 fe ff ff       	call   800753 <printfmt>
  8008c1:	e9 da fe ff ff       	jmp    8007a0 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8008c6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008ca:	c7 44 24 08 e9 0e 80 	movl   $0x800ee9,0x8(%esp)
  8008d1:	00 
  8008d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	89 04 24             	mov    %eax,(%esp)
  8008dc:	e8 72 fe ff ff       	call   800753 <printfmt>
  8008e1:	e9 ba fe ff ff       	jmp    8007a0 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8008e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8008ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f2:	8d 50 04             	lea    0x4(%eax),%edx
  8008f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f8:	8b 30                	mov    (%eax),%esi
  8008fa:	85 f6                	test   %esi,%esi
  8008fc:	75 05                	jne    800903 <vprintfmt+0x188>
				p = "(null)";
  8008fe:	be d9 0e 80 00       	mov    $0x800ed9,%esi
			if (width > 0 && padc != '-')
  800903:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800907:	0f 84 8c 00 00 00    	je     800999 <vprintfmt+0x21e>
  80090d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800911:	0f 8e 8a 00 00 00    	jle    8009a1 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  800917:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80091b:	89 34 24             	mov    %esi,(%esp)
  80091e:	e8 cf f7 ff ff       	call   8000f2 <strnlen>
  800923:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800926:	29 c1                	sub    %eax,%ecx
  800928:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  80092b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80092f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800932:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800935:	8b 75 08             	mov    0x8(%ebp),%esi
  800938:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80093b:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80093d:	eb 0d                	jmp    80094c <vprintfmt+0x1d1>
					putch(padc, putdat);
  80093f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800943:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800946:	89 04 24             	mov    %eax,(%esp)
  800949:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80094b:	4b                   	dec    %ebx
  80094c:	85 db                	test   %ebx,%ebx
  80094e:	7f ef                	jg     80093f <vprintfmt+0x1c4>
  800950:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800953:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800956:	89 c8                	mov    %ecx,%eax
  800958:	f7 d0                	not    %eax
  80095a:	c1 f8 1f             	sar    $0x1f,%eax
  80095d:	21 c8                	and    %ecx,%eax
  80095f:	29 c1                	sub    %eax,%ecx
  800961:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800964:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800967:	eb 3e                	jmp    8009a7 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800969:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80096d:	74 1b                	je     80098a <vprintfmt+0x20f>
  80096f:	0f be d2             	movsbl %dl,%edx
  800972:	83 ea 20             	sub    $0x20,%edx
  800975:	83 fa 5e             	cmp    $0x5e,%edx
  800978:	76 10                	jbe    80098a <vprintfmt+0x20f>
					putch('?', putdat);
  80097a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80097e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800985:	ff 55 08             	call   *0x8(%ebp)
  800988:	eb 0a                	jmp    800994 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  80098a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80098e:	89 04 24             	mov    %eax,(%esp)
  800991:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800994:	ff 4d dc             	decl   -0x24(%ebp)
  800997:	eb 0e                	jmp    8009a7 <vprintfmt+0x22c>
  800999:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80099c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80099f:	eb 06                	jmp    8009a7 <vprintfmt+0x22c>
  8009a1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009a4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8009a7:	46                   	inc    %esi
  8009a8:	8a 56 ff             	mov    -0x1(%esi),%dl
  8009ab:	0f be c2             	movsbl %dl,%eax
  8009ae:	85 c0                	test   %eax,%eax
  8009b0:	74 1f                	je     8009d1 <vprintfmt+0x256>
  8009b2:	85 db                	test   %ebx,%ebx
  8009b4:	78 b3                	js     800969 <vprintfmt+0x1ee>
  8009b6:	4b                   	dec    %ebx
  8009b7:	79 b0                	jns    800969 <vprintfmt+0x1ee>
  8009b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009bc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8009bf:	eb 16                	jmp    8009d7 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8009c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009c5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009cc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009ce:	4b                   	dec    %ebx
  8009cf:	eb 06                	jmp    8009d7 <vprintfmt+0x25c>
  8009d1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8009d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d7:	85 db                	test   %ebx,%ebx
  8009d9:	7f e6                	jg     8009c1 <vprintfmt+0x246>
  8009db:	89 75 08             	mov    %esi,0x8(%ebp)
  8009de:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009e1:	e9 ba fd ff ff       	jmp    8007a0 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009e6:	83 fa 01             	cmp    $0x1,%edx
  8009e9:	7e 16                	jle    800a01 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  8009eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ee:	8d 50 08             	lea    0x8(%eax),%edx
  8009f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8009f4:	8b 50 04             	mov    0x4(%eax),%edx
  8009f7:	8b 00                	mov    (%eax),%eax
  8009f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009fc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009ff:	eb 32                	jmp    800a33 <vprintfmt+0x2b8>
	else if (lflag)
  800a01:	85 d2                	test   %edx,%edx
  800a03:	74 18                	je     800a1d <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800a05:	8b 45 14             	mov    0x14(%ebp),%eax
  800a08:	8d 50 04             	lea    0x4(%eax),%edx
  800a0b:	89 55 14             	mov    %edx,0x14(%ebp)
  800a0e:	8b 30                	mov    (%eax),%esi
  800a10:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800a13:	89 f0                	mov    %esi,%eax
  800a15:	c1 f8 1f             	sar    $0x1f,%eax
  800a18:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a1b:	eb 16                	jmp    800a33 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800a1d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a20:	8d 50 04             	lea    0x4(%eax),%edx
  800a23:	89 55 14             	mov    %edx,0x14(%ebp)
  800a26:	8b 30                	mov    (%eax),%esi
  800a28:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800a2b:	89 f0                	mov    %esi,%eax
  800a2d:	c1 f8 1f             	sar    $0x1f,%eax
  800a30:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a33:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a36:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a39:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a3e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a42:	0f 89 80 00 00 00    	jns    800ac8 <vprintfmt+0x34d>
				putch('-', putdat);
  800a48:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a4c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a53:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a56:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a59:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a5c:	f7 d8                	neg    %eax
  800a5e:	83 d2 00             	adc    $0x0,%edx
  800a61:	f7 da                	neg    %edx
			}
			base = 10;
  800a63:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a68:	eb 5e                	jmp    800ac8 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a6a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a6d:	e8 8b fc ff ff       	call   8006fd <getuint>
			base = 10;
  800a72:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a77:	eb 4f                	jmp    800ac8 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800a79:	8d 45 14             	lea    0x14(%ebp),%eax
  800a7c:	e8 7c fc ff ff       	call   8006fd <getuint>
			base = 8;
  800a81:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800a86:	eb 40                	jmp    800ac8 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800a88:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a8c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a93:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a96:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a9a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800aa1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800aa4:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa7:	8d 50 04             	lea    0x4(%eax),%edx
  800aaa:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800aad:	8b 00                	mov    (%eax),%eax
  800aaf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ab4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800ab9:	eb 0d                	jmp    800ac8 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800abb:	8d 45 14             	lea    0x14(%ebp),%eax
  800abe:	e8 3a fc ff ff       	call   8006fd <getuint>
			base = 16;
  800ac3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ac8:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800acc:	89 74 24 10          	mov    %esi,0x10(%esp)
  800ad0:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800ad3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ad7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800adb:	89 04 24             	mov    %eax,(%esp)
  800ade:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ae2:	89 fa                	mov    %edi,%edx
  800ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae7:	e8 20 fb ff ff       	call   80060c <printnum>
			break;
  800aec:	e9 af fc ff ff       	jmp    8007a0 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800af1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800af5:	89 04 24             	mov    %eax,(%esp)
  800af8:	ff 55 08             	call   *0x8(%ebp)
			break;
  800afb:	e9 a0 fc ff ff       	jmp    8007a0 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b00:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b04:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b0b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b0e:	89 f3                	mov    %esi,%ebx
  800b10:	eb 01                	jmp    800b13 <vprintfmt+0x398>
  800b12:	4b                   	dec    %ebx
  800b13:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800b17:	75 f9                	jne    800b12 <vprintfmt+0x397>
  800b19:	e9 82 fc ff ff       	jmp    8007a0 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800b1e:	83 c4 3c             	add    $0x3c,%esp
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	83 ec 28             	sub    $0x28,%esp
  800b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b32:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b35:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b39:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b3c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b43:	85 c0                	test   %eax,%eax
  800b45:	74 30                	je     800b77 <vsnprintf+0x51>
  800b47:	85 d2                	test   %edx,%edx
  800b49:	7e 2c                	jle    800b77 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b4b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b52:	8b 45 10             	mov    0x10(%ebp),%eax
  800b55:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b59:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b60:	c7 04 24 37 07 80 00 	movl   $0x800737,(%esp)
  800b67:	e8 0f fc ff ff       	call   80077b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b6f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b75:	eb 05                	jmp    800b7c <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b77:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b7c:	c9                   	leave  
  800b7d:	c3                   	ret    

00800b7e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b84:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b8b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b95:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b99:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9c:	89 04 24             	mov    %eax,(%esp)
  800b9f:	e8 82 ff ff ff       	call   800b26 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ba4:	c9                   	leave  
  800ba5:	c3                   	ret    
  800ba6:	66 90                	xchg   %ax,%ax
  800ba8:	66 90                	xchg   %ax,%ax
  800baa:	66 90                	xchg   %ax,%ax
  800bac:	66 90                	xchg   %ax,%ax
  800bae:	66 90                	xchg   %ax,%ax

00800bb0 <__udivdi3>:
  800bb0:	55                   	push   %ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800bba:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800bbe:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800bc2:	8b 44 24 28          	mov    0x28(%esp),%eax
  800bc6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bca:	89 ea                	mov    %ebp,%edx
  800bcc:	89 0c 24             	mov    %ecx,(%esp)
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	75 2d                	jne    800c00 <__udivdi3+0x50>
  800bd3:	39 e9                	cmp    %ebp,%ecx
  800bd5:	77 61                	ja     800c38 <__udivdi3+0x88>
  800bd7:	89 ce                	mov    %ecx,%esi
  800bd9:	85 c9                	test   %ecx,%ecx
  800bdb:	75 0b                	jne    800be8 <__udivdi3+0x38>
  800bdd:	b8 01 00 00 00       	mov    $0x1,%eax
  800be2:	31 d2                	xor    %edx,%edx
  800be4:	f7 f1                	div    %ecx
  800be6:	89 c6                	mov    %eax,%esi
  800be8:	31 d2                	xor    %edx,%edx
  800bea:	89 e8                	mov    %ebp,%eax
  800bec:	f7 f6                	div    %esi
  800bee:	89 c5                	mov    %eax,%ebp
  800bf0:	89 f8                	mov    %edi,%eax
  800bf2:	f7 f6                	div    %esi
  800bf4:	89 ea                	mov    %ebp,%edx
  800bf6:	83 c4 0c             	add    $0xc,%esp
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    
  800bfd:	8d 76 00             	lea    0x0(%esi),%esi
  800c00:	39 e8                	cmp    %ebp,%eax
  800c02:	77 24                	ja     800c28 <__udivdi3+0x78>
  800c04:	0f bd e8             	bsr    %eax,%ebp
  800c07:	83 f5 1f             	xor    $0x1f,%ebp
  800c0a:	75 3c                	jne    800c48 <__udivdi3+0x98>
  800c0c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c10:	39 34 24             	cmp    %esi,(%esp)
  800c13:	0f 86 9f 00 00 00    	jbe    800cb8 <__udivdi3+0x108>
  800c19:	39 d0                	cmp    %edx,%eax
  800c1b:	0f 82 97 00 00 00    	jb     800cb8 <__udivdi3+0x108>
  800c21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c28:	31 d2                	xor    %edx,%edx
  800c2a:	31 c0                	xor    %eax,%eax
  800c2c:	83 c4 0c             	add    $0xc,%esp
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    
  800c33:	90                   	nop
  800c34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c38:	89 f8                	mov    %edi,%eax
  800c3a:	f7 f1                	div    %ecx
  800c3c:	31 d2                	xor    %edx,%edx
  800c3e:	83 c4 0c             	add    $0xc,%esp
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    
  800c45:	8d 76 00             	lea    0x0(%esi),%esi
  800c48:	89 e9                	mov    %ebp,%ecx
  800c4a:	8b 3c 24             	mov    (%esp),%edi
  800c4d:	d3 e0                	shl    %cl,%eax
  800c4f:	89 c6                	mov    %eax,%esi
  800c51:	b8 20 00 00 00       	mov    $0x20,%eax
  800c56:	29 e8                	sub    %ebp,%eax
  800c58:	88 c1                	mov    %al,%cl
  800c5a:	d3 ef                	shr    %cl,%edi
  800c5c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c60:	89 e9                	mov    %ebp,%ecx
  800c62:	8b 3c 24             	mov    (%esp),%edi
  800c65:	09 74 24 08          	or     %esi,0x8(%esp)
  800c69:	d3 e7                	shl    %cl,%edi
  800c6b:	89 d6                	mov    %edx,%esi
  800c6d:	88 c1                	mov    %al,%cl
  800c6f:	d3 ee                	shr    %cl,%esi
  800c71:	89 e9                	mov    %ebp,%ecx
  800c73:	89 3c 24             	mov    %edi,(%esp)
  800c76:	d3 e2                	shl    %cl,%edx
  800c78:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c7c:	88 c1                	mov    %al,%cl
  800c7e:	d3 ef                	shr    %cl,%edi
  800c80:	09 d7                	or     %edx,%edi
  800c82:	89 f2                	mov    %esi,%edx
  800c84:	89 f8                	mov    %edi,%eax
  800c86:	f7 74 24 08          	divl   0x8(%esp)
  800c8a:	89 d6                	mov    %edx,%esi
  800c8c:	89 c7                	mov    %eax,%edi
  800c8e:	f7 24 24             	mull   (%esp)
  800c91:	89 14 24             	mov    %edx,(%esp)
  800c94:	39 d6                	cmp    %edx,%esi
  800c96:	72 30                	jb     800cc8 <__udivdi3+0x118>
  800c98:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c9c:	89 e9                	mov    %ebp,%ecx
  800c9e:	d3 e2                	shl    %cl,%edx
  800ca0:	39 c2                	cmp    %eax,%edx
  800ca2:	73 05                	jae    800ca9 <__udivdi3+0xf9>
  800ca4:	3b 34 24             	cmp    (%esp),%esi
  800ca7:	74 1f                	je     800cc8 <__udivdi3+0x118>
  800ca9:	89 f8                	mov    %edi,%eax
  800cab:	31 d2                	xor    %edx,%edx
  800cad:	e9 7a ff ff ff       	jmp    800c2c <__udivdi3+0x7c>
  800cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cb8:	31 d2                	xor    %edx,%edx
  800cba:	b8 01 00 00 00       	mov    $0x1,%eax
  800cbf:	e9 68 ff ff ff       	jmp    800c2c <__udivdi3+0x7c>
  800cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cc8:	8d 47 ff             	lea    -0x1(%edi),%eax
  800ccb:	31 d2                	xor    %edx,%edx
  800ccd:	83 c4 0c             	add    $0xc,%esp
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    
  800cd4:	66 90                	xchg   %ax,%ax
  800cd6:	66 90                	xchg   %ax,%ax
  800cd8:	66 90                	xchg   %ax,%ax
  800cda:	66 90                	xchg   %ax,%ax
  800cdc:	66 90                	xchg   %ax,%ax
  800cde:	66 90                	xchg   %ax,%ax

00800ce0 <__umoddi3>:
  800ce0:	55                   	push   %ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	83 ec 14             	sub    $0x14,%esp
  800ce6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800cea:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800cee:	89 c7                	mov    %eax,%edi
  800cf0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800cf8:	8b 44 24 30          	mov    0x30(%esp),%eax
  800cfc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800d00:	89 34 24             	mov    %esi,(%esp)
  800d03:	89 c2                	mov    %eax,%edx
  800d05:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d09:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	75 17                	jne    800d28 <__umoddi3+0x48>
  800d11:	39 fe                	cmp    %edi,%esi
  800d13:	76 4b                	jbe    800d60 <__umoddi3+0x80>
  800d15:	89 c8                	mov    %ecx,%eax
  800d17:	89 fa                	mov    %edi,%edx
  800d19:	f7 f6                	div    %esi
  800d1b:	89 d0                	mov    %edx,%eax
  800d1d:	31 d2                	xor    %edx,%edx
  800d1f:	83 c4 14             	add    $0x14,%esp
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    
  800d26:	66 90                	xchg   %ax,%ax
  800d28:	39 f8                	cmp    %edi,%eax
  800d2a:	77 54                	ja     800d80 <__umoddi3+0xa0>
  800d2c:	0f bd e8             	bsr    %eax,%ebp
  800d2f:	83 f5 1f             	xor    $0x1f,%ebp
  800d32:	75 5c                	jne    800d90 <__umoddi3+0xb0>
  800d34:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d38:	39 3c 24             	cmp    %edi,(%esp)
  800d3b:	0f 87 f7 00 00 00    	ja     800e38 <__umoddi3+0x158>
  800d41:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d45:	29 f1                	sub    %esi,%ecx
  800d47:	19 c7                	sbb    %eax,%edi
  800d49:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d4d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d51:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d55:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d59:	83 c4 14             	add    $0x14,%esp
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    
  800d60:	89 f5                	mov    %esi,%ebp
  800d62:	85 f6                	test   %esi,%esi
  800d64:	75 0b                	jne    800d71 <__umoddi3+0x91>
  800d66:	b8 01 00 00 00       	mov    $0x1,%eax
  800d6b:	31 d2                	xor    %edx,%edx
  800d6d:	f7 f6                	div    %esi
  800d6f:	89 c5                	mov    %eax,%ebp
  800d71:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d75:	31 d2                	xor    %edx,%edx
  800d77:	f7 f5                	div    %ebp
  800d79:	89 c8                	mov    %ecx,%eax
  800d7b:	f7 f5                	div    %ebp
  800d7d:	eb 9c                	jmp    800d1b <__umoddi3+0x3b>
  800d7f:	90                   	nop
  800d80:	89 c8                	mov    %ecx,%eax
  800d82:	89 fa                	mov    %edi,%edx
  800d84:	83 c4 14             	add    $0x14,%esp
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    
  800d8b:	90                   	nop
  800d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d90:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800d97:	00 
  800d98:	8b 34 24             	mov    (%esp),%esi
  800d9b:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d9f:	89 e9                	mov    %ebp,%ecx
  800da1:	29 e8                	sub    %ebp,%eax
  800da3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da7:	89 f0                	mov    %esi,%eax
  800da9:	d3 e2                	shl    %cl,%edx
  800dab:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800daf:	d3 e8                	shr    %cl,%eax
  800db1:	89 04 24             	mov    %eax,(%esp)
  800db4:	89 e9                	mov    %ebp,%ecx
  800db6:	89 f0                	mov    %esi,%eax
  800db8:	09 14 24             	or     %edx,(%esp)
  800dbb:	d3 e0                	shl    %cl,%eax
  800dbd:	89 fa                	mov    %edi,%edx
  800dbf:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800dc3:	d3 ea                	shr    %cl,%edx
  800dc5:	89 e9                	mov    %ebp,%ecx
  800dc7:	89 c6                	mov    %eax,%esi
  800dc9:	d3 e7                	shl    %cl,%edi
  800dcb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dcf:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800dd3:	8b 44 24 10          	mov    0x10(%esp),%eax
  800dd7:	d3 e8                	shr    %cl,%eax
  800dd9:	09 f8                	or     %edi,%eax
  800ddb:	89 e9                	mov    %ebp,%ecx
  800ddd:	8b 7c 24 10          	mov    0x10(%esp),%edi
  800de1:	d3 e7                	shl    %cl,%edi
  800de3:	f7 34 24             	divl   (%esp)
  800de6:	89 d1                	mov    %edx,%ecx
  800de8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dec:	f7 e6                	mul    %esi
  800dee:	89 c7                	mov    %eax,%edi
  800df0:	89 d6                	mov    %edx,%esi
  800df2:	39 d1                	cmp    %edx,%ecx
  800df4:	72 2e                	jb     800e24 <__umoddi3+0x144>
  800df6:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800dfa:	72 24                	jb     800e20 <__umoddi3+0x140>
  800dfc:	89 ca                	mov    %ecx,%edx
  800dfe:	89 e9                	mov    %ebp,%ecx
  800e00:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e04:	29 f8                	sub    %edi,%eax
  800e06:	19 f2                	sbb    %esi,%edx
  800e08:	d3 e8                	shr    %cl,%eax
  800e0a:	89 d6                	mov    %edx,%esi
  800e0c:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800e10:	d3 e6                	shl    %cl,%esi
  800e12:	89 e9                	mov    %ebp,%ecx
  800e14:	09 f0                	or     %esi,%eax
  800e16:	d3 ea                	shr    %cl,%edx
  800e18:	83 c4 14             	add    $0x14,%esp
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    
  800e1f:	90                   	nop
  800e20:	39 d1                	cmp    %edx,%ecx
  800e22:	75 d8                	jne    800dfc <__umoddi3+0x11c>
  800e24:	89 d6                	mov    %edx,%esi
  800e26:	89 c7                	mov    %eax,%edi
  800e28:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  800e2c:	1b 34 24             	sbb    (%esp),%esi
  800e2f:	eb cb                	jmp    800dfc <__umoddi3+0x11c>
  800e31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e38:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  800e3c:	0f 82 ff fe ff ff    	jb     800d41 <__umoddi3+0x61>
  800e42:	e9 0a ff ff ff       	jmp    800d51 <__umoddi3+0x71>
