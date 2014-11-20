
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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
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
	sys_cputs(hello, 1024*1024);
  80003a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800041:	00 
  800042:	a1 00 20 80 00       	mov    0x802000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 f9 03 00 00       	call   800448 <sys_cputs>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	66 90                	xchg   %ax,%ax
  800053:	90                   	nop

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	83 ec 10             	sub    $0x10,%esp
  80005c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005f:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  800062:	b8 0c 20 80 00       	mov    $0x80200c,%eax
  800067:	2d 08 20 80 00       	sub    $0x802008,%eax
  80006c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800070:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800077:	00 
  800078:	c7 04 24 08 20 80 00 	movl   $0x802008,(%esp)
  80007f:	e8 cf 01 00 00       	call   800253 <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  800084:	e8 4e 04 00 00       	call   8004d7 <sys_getenvid>
  800089:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800095:	c1 e0 07             	shl    $0x7,%eax
  800098:	29 d0                	sub    %edx,%eax
  80009a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009f:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a4:	85 db                	test   %ebx,%ebx
  8000a6:	7e 07                	jle    8000af <libmain+0x5b>
		binaryname = argv[0];
  8000a8:	8b 06                	mov    (%esi),%eax
  8000aa:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  8000af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000b3:	89 1c 24             	mov    %ebx,(%esp)
  8000b6:	e8 79 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000bb:	e8 08 00 00 00       	call   8000c8 <exit>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    
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
  8004b3:	c7 44 24 08 98 10 80 	movl   $0x801098,0x8(%esp)
  8004ba:	00 
  8004bb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004c2:	00 
  8004c3:	c7 04 24 b5 10 80 00 	movl   $0x8010b5,(%esp)
  8004ca:	e8 5d 02 00 00       	call   80072c <_panic>

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

008004f6 <sys_yield>:

void
sys_yield(void)
{
  8004f6:	55                   	push   %ebp
  8004f7:	89 e5                	mov    %esp,%ebp
  8004f9:	57                   	push   %edi
  8004fa:	56                   	push   %esi
  8004fb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800501:	b8 0a 00 00 00       	mov    $0xa,%eax
  800506:	89 d1                	mov    %edx,%ecx
  800508:	89 d3                	mov    %edx,%ebx
  80050a:	89 d7                	mov    %edx,%edi
  80050c:	89 d6                	mov    %edx,%esi
  80050e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800510:	5b                   	pop    %ebx
  800511:	5e                   	pop    %esi
  800512:	5f                   	pop    %edi
  800513:	5d                   	pop    %ebp
  800514:	c3                   	ret    

00800515 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800515:	55                   	push   %ebp
  800516:	89 e5                	mov    %esp,%ebp
  800518:	57                   	push   %edi
  800519:	56                   	push   %esi
  80051a:	53                   	push   %ebx
  80051b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80051e:	be 00 00 00 00       	mov    $0x0,%esi
  800523:	b8 04 00 00 00       	mov    $0x4,%eax
  800528:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80052b:	8b 55 08             	mov    0x8(%ebp),%edx
  80052e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800531:	89 f7                	mov    %esi,%edi
  800533:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800535:	85 c0                	test   %eax,%eax
  800537:	7e 28                	jle    800561 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800539:	89 44 24 10          	mov    %eax,0x10(%esp)
  80053d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800544:	00 
  800545:	c7 44 24 08 98 10 80 	movl   $0x801098,0x8(%esp)
  80054c:	00 
  80054d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800554:	00 
  800555:	c7 04 24 b5 10 80 00 	movl   $0x8010b5,(%esp)
  80055c:	e8 cb 01 00 00       	call   80072c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800561:	83 c4 2c             	add    $0x2c,%esp
  800564:	5b                   	pop    %ebx
  800565:	5e                   	pop    %esi
  800566:	5f                   	pop    %edi
  800567:	5d                   	pop    %ebp
  800568:	c3                   	ret    

00800569 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800569:	55                   	push   %ebp
  80056a:	89 e5                	mov    %esp,%ebp
  80056c:	57                   	push   %edi
  80056d:	56                   	push   %esi
  80056e:	53                   	push   %ebx
  80056f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800572:	b8 05 00 00 00       	mov    $0x5,%eax
  800577:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80057a:	8b 55 08             	mov    0x8(%ebp),%edx
  80057d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800580:	8b 7d 14             	mov    0x14(%ebp),%edi
  800583:	8b 75 18             	mov    0x18(%ebp),%esi
  800586:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800588:	85 c0                	test   %eax,%eax
  80058a:	7e 28                	jle    8005b4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80058c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800590:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800597:	00 
  800598:	c7 44 24 08 98 10 80 	movl   $0x801098,0x8(%esp)
  80059f:	00 
  8005a0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005a7:	00 
  8005a8:	c7 04 24 b5 10 80 00 	movl   $0x8010b5,(%esp)
  8005af:	e8 78 01 00 00       	call   80072c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8005b4:	83 c4 2c             	add    $0x2c,%esp
  8005b7:	5b                   	pop    %ebx
  8005b8:	5e                   	pop    %esi
  8005b9:	5f                   	pop    %edi
  8005ba:	5d                   	pop    %ebp
  8005bb:	c3                   	ret    

008005bc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8005bc:	55                   	push   %ebp
  8005bd:	89 e5                	mov    %esp,%ebp
  8005bf:	57                   	push   %edi
  8005c0:	56                   	push   %esi
  8005c1:	53                   	push   %ebx
  8005c2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005ca:	b8 06 00 00 00       	mov    $0x6,%eax
  8005cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8005d5:	89 df                	mov    %ebx,%edi
  8005d7:	89 de                	mov    %ebx,%esi
  8005d9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005db:	85 c0                	test   %eax,%eax
  8005dd:	7e 28                	jle    800607 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005df:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005e3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8005ea:	00 
  8005eb:	c7 44 24 08 98 10 80 	movl   $0x801098,0x8(%esp)
  8005f2:	00 
  8005f3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005fa:	00 
  8005fb:	c7 04 24 b5 10 80 00 	movl   $0x8010b5,(%esp)
  800602:	e8 25 01 00 00       	call   80072c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800607:	83 c4 2c             	add    $0x2c,%esp
  80060a:	5b                   	pop    %ebx
  80060b:	5e                   	pop    %esi
  80060c:	5f                   	pop    %edi
  80060d:	5d                   	pop    %ebp
  80060e:	c3                   	ret    

0080060f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80060f:	55                   	push   %ebp
  800610:	89 e5                	mov    %esp,%ebp
  800612:	57                   	push   %edi
  800613:	56                   	push   %esi
  800614:	53                   	push   %ebx
  800615:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800618:	bb 00 00 00 00       	mov    $0x0,%ebx
  80061d:	b8 08 00 00 00       	mov    $0x8,%eax
  800622:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800625:	8b 55 08             	mov    0x8(%ebp),%edx
  800628:	89 df                	mov    %ebx,%edi
  80062a:	89 de                	mov    %ebx,%esi
  80062c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80062e:	85 c0                	test   %eax,%eax
  800630:	7e 28                	jle    80065a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800632:	89 44 24 10          	mov    %eax,0x10(%esp)
  800636:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80063d:	00 
  80063e:	c7 44 24 08 98 10 80 	movl   $0x801098,0x8(%esp)
  800645:	00 
  800646:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80064d:	00 
  80064e:	c7 04 24 b5 10 80 00 	movl   $0x8010b5,(%esp)
  800655:	e8 d2 00 00 00       	call   80072c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80065a:	83 c4 2c             	add    $0x2c,%esp
  80065d:	5b                   	pop    %ebx
  80065e:	5e                   	pop    %esi
  80065f:	5f                   	pop    %edi
  800660:	5d                   	pop    %ebp
  800661:	c3                   	ret    

00800662 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800662:	55                   	push   %ebp
  800663:	89 e5                	mov    %esp,%ebp
  800665:	57                   	push   %edi
  800666:	56                   	push   %esi
  800667:	53                   	push   %ebx
  800668:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80066b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800670:	b8 09 00 00 00       	mov    $0x9,%eax
  800675:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800678:	8b 55 08             	mov    0x8(%ebp),%edx
  80067b:	89 df                	mov    %ebx,%edi
  80067d:	89 de                	mov    %ebx,%esi
  80067f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800681:	85 c0                	test   %eax,%eax
  800683:	7e 28                	jle    8006ad <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800685:	89 44 24 10          	mov    %eax,0x10(%esp)
  800689:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800690:	00 
  800691:	c7 44 24 08 98 10 80 	movl   $0x801098,0x8(%esp)
  800698:	00 
  800699:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8006a0:	00 
  8006a1:	c7 04 24 b5 10 80 00 	movl   $0x8010b5,(%esp)
  8006a8:	e8 7f 00 00 00       	call   80072c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8006ad:	83 c4 2c             	add    $0x2c,%esp
  8006b0:	5b                   	pop    %ebx
  8006b1:	5e                   	pop    %esi
  8006b2:	5f                   	pop    %edi
  8006b3:	5d                   	pop    %ebp
  8006b4:	c3                   	ret    

008006b5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8006b5:	55                   	push   %ebp
  8006b6:	89 e5                	mov    %esp,%ebp
  8006b8:	57                   	push   %edi
  8006b9:	56                   	push   %esi
  8006ba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006bb:	be 00 00 00 00       	mov    $0x0,%esi
  8006c0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8006c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8006cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006ce:	8b 7d 14             	mov    0x14(%ebp),%edi
  8006d1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8006d3:	5b                   	pop    %ebx
  8006d4:	5e                   	pop    %esi
  8006d5:	5f                   	pop    %edi
  8006d6:	5d                   	pop    %ebp
  8006d7:	c3                   	ret    

008006d8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	57                   	push   %edi
  8006dc:	56                   	push   %esi
  8006dd:	53                   	push   %ebx
  8006de:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8006eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ee:	89 cb                	mov    %ecx,%ebx
  8006f0:	89 cf                	mov    %ecx,%edi
  8006f2:	89 ce                	mov    %ecx,%esi
  8006f4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006f6:	85 c0                	test   %eax,%eax
  8006f8:	7e 28                	jle    800722 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006fa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006fe:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800705:	00 
  800706:	c7 44 24 08 98 10 80 	movl   $0x801098,0x8(%esp)
  80070d:	00 
  80070e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800715:	00 
  800716:	c7 04 24 b5 10 80 00 	movl   $0x8010b5,(%esp)
  80071d:	e8 0a 00 00 00       	call   80072c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800722:	83 c4 2c             	add    $0x2c,%esp
  800725:	5b                   	pop    %ebx
  800726:	5e                   	pop    %esi
  800727:	5f                   	pop    %edi
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    
  80072a:	66 90                	xchg   %ax,%ax

0080072c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	56                   	push   %esi
  800730:	53                   	push   %ebx
  800731:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800734:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800737:	8b 35 04 20 80 00    	mov    0x802004,%esi
  80073d:	e8 95 fd ff ff       	call   8004d7 <sys_getenvid>
  800742:	8b 55 0c             	mov    0xc(%ebp),%edx
  800745:	89 54 24 10          	mov    %edx,0x10(%esp)
  800749:	8b 55 08             	mov    0x8(%ebp),%edx
  80074c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800750:	89 74 24 08          	mov    %esi,0x8(%esp)
  800754:	89 44 24 04          	mov    %eax,0x4(%esp)
  800758:	c7 04 24 c4 10 80 00 	movl   $0x8010c4,(%esp)
  80075f:	e8 c2 00 00 00       	call   800826 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800764:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800768:	8b 45 10             	mov    0x10(%ebp),%eax
  80076b:	89 04 24             	mov    %eax,(%esp)
  80076e:	e8 52 00 00 00       	call   8007c5 <vcprintf>
	cprintf("\n");
  800773:	c7 04 24 8c 10 80 00 	movl   $0x80108c,(%esp)
  80077a:	e8 a7 00 00 00       	call   800826 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80077f:	cc                   	int3   
  800780:	eb fd                	jmp    80077f <_panic+0x53>
  800782:	66 90                	xchg   %ax,%ax

00800784 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	53                   	push   %ebx
  800788:	83 ec 14             	sub    $0x14,%esp
  80078b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80078e:	8b 13                	mov    (%ebx),%edx
  800790:	8d 42 01             	lea    0x1(%edx),%eax
  800793:	89 03                	mov    %eax,(%ebx)
  800795:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800798:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80079c:	3d ff 00 00 00       	cmp    $0xff,%eax
  8007a1:	75 19                	jne    8007bc <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8007a3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8007aa:	00 
  8007ab:	8d 43 08             	lea    0x8(%ebx),%eax
  8007ae:	89 04 24             	mov    %eax,(%esp)
  8007b1:	e8 92 fc ff ff       	call   800448 <sys_cputs>
		b->idx = 0;
  8007b6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8007bc:	ff 43 04             	incl   0x4(%ebx)
}
  8007bf:	83 c4 14             	add    $0x14,%esp
  8007c2:	5b                   	pop    %ebx
  8007c3:	5d                   	pop    %ebp
  8007c4:	c3                   	ret    

008007c5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8007ce:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8007d5:	00 00 00 
	b.cnt = 0;
  8007d8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8007df:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8007e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8007f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fa:	c7 04 24 84 07 80 00 	movl   $0x800784,(%esp)
  800801:	e8 a9 01 00 00       	call   8009af <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800806:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80080c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800810:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800816:	89 04 24             	mov    %eax,(%esp)
  800819:	e8 2a fc ff ff       	call   800448 <sys_cputs>

	return b.cnt;
}
  80081e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800824:	c9                   	leave  
  800825:	c3                   	ret    

00800826 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80082c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80082f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	89 04 24             	mov    %eax,(%esp)
  800839:	e8 87 ff ff ff       	call   8007c5 <vcprintf>
	va_end(ap);

	return cnt;
}
  80083e:	c9                   	leave  
  80083f:	c3                   	ret    

00800840 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	57                   	push   %edi
  800844:	56                   	push   %esi
  800845:	53                   	push   %ebx
  800846:	83 ec 3c             	sub    $0x3c,%esp
  800849:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80084c:	89 d7                	mov    %edx,%edi
  80084e:	8b 45 08             	mov    0x8(%ebp),%eax
  800851:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800854:	8b 45 0c             	mov    0xc(%ebp),%eax
  800857:	89 c1                	mov    %eax,%ecx
  800859:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80085c:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80085f:	8b 45 10             	mov    0x10(%ebp),%eax
  800862:	ba 00 00 00 00       	mov    $0x0,%edx
  800867:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80086a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80086d:	39 ca                	cmp    %ecx,%edx
  80086f:	72 08                	jb     800879 <printnum+0x39>
  800871:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800874:	39 45 10             	cmp    %eax,0x10(%ebp)
  800877:	77 6a                	ja     8008e3 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800879:	8b 45 18             	mov    0x18(%ebp),%eax
  80087c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800880:	4e                   	dec    %esi
  800881:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800885:	8b 45 10             	mov    0x10(%ebp),%eax
  800888:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088c:	8b 44 24 08          	mov    0x8(%esp),%eax
  800890:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800894:	89 c3                	mov    %eax,%ebx
  800896:	89 d6                	mov    %edx,%esi
  800898:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80089b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80089e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008a9:	89 04 24             	mov    %eax,(%esp)
  8008ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8008af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b3:	e8 28 05 00 00       	call   800de0 <__udivdi3>
  8008b8:	89 d9                	mov    %ebx,%ecx
  8008ba:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008be:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008c2:	89 04 24             	mov    %eax,(%esp)
  8008c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c9:	89 fa                	mov    %edi,%edx
  8008cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008ce:	e8 6d ff ff ff       	call   800840 <printnum>
  8008d3:	eb 19                	jmp    8008ee <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8008d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008d9:	8b 45 18             	mov    0x18(%ebp),%eax
  8008dc:	89 04 24             	mov    %eax,(%esp)
  8008df:	ff d3                	call   *%ebx
  8008e1:	eb 03                	jmp    8008e6 <printnum+0xa6>
  8008e3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8008e6:	4e                   	dec    %esi
  8008e7:	85 f6                	test   %esi,%esi
  8008e9:	7f ea                	jg     8008d5 <printnum+0x95>
  8008eb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8008ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008f2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8008f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800900:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800904:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800907:	89 04 24             	mov    %eax,(%esp)
  80090a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80090d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800911:	e8 fa 05 00 00       	call   800f10 <__umoddi3>
  800916:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80091a:	0f be 80 e8 10 80 00 	movsbl 0x8010e8(%eax),%eax
  800921:	89 04 24             	mov    %eax,(%esp)
  800924:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800927:	ff d0                	call   *%eax
}
  800929:	83 c4 3c             	add    $0x3c,%esp
  80092c:	5b                   	pop    %ebx
  80092d:	5e                   	pop    %esi
  80092e:	5f                   	pop    %edi
  80092f:	5d                   	pop    %ebp
  800930:	c3                   	ret    

00800931 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800934:	83 fa 01             	cmp    $0x1,%edx
  800937:	7e 0e                	jle    800947 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800939:	8b 10                	mov    (%eax),%edx
  80093b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80093e:	89 08                	mov    %ecx,(%eax)
  800940:	8b 02                	mov    (%edx),%eax
  800942:	8b 52 04             	mov    0x4(%edx),%edx
  800945:	eb 22                	jmp    800969 <getuint+0x38>
	else if (lflag)
  800947:	85 d2                	test   %edx,%edx
  800949:	74 10                	je     80095b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80094b:	8b 10                	mov    (%eax),%edx
  80094d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800950:	89 08                	mov    %ecx,(%eax)
  800952:	8b 02                	mov    (%edx),%eax
  800954:	ba 00 00 00 00       	mov    $0x0,%edx
  800959:	eb 0e                	jmp    800969 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80095b:	8b 10                	mov    (%eax),%edx
  80095d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800960:	89 08                	mov    %ecx,(%eax)
  800962:	8b 02                	mov    (%edx),%eax
  800964:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800971:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800974:	8b 10                	mov    (%eax),%edx
  800976:	3b 50 04             	cmp    0x4(%eax),%edx
  800979:	73 0a                	jae    800985 <sprintputch+0x1a>
		*b->buf++ = ch;
  80097b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80097e:	89 08                	mov    %ecx,(%eax)
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	88 02                	mov    %al,(%edx)
}
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80098d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800990:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800994:	8b 45 10             	mov    0x10(%ebp),%eax
  800997:	89 44 24 08          	mov    %eax,0x8(%esp)
  80099b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	89 04 24             	mov    %eax,(%esp)
  8009a8:	e8 02 00 00 00       	call   8009af <vprintfmt>
	va_end(ap);
}
  8009ad:	c9                   	leave  
  8009ae:	c3                   	ret    

008009af <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	57                   	push   %edi
  8009b3:	56                   	push   %esi
  8009b4:	53                   	push   %ebx
  8009b5:	83 ec 3c             	sub    $0x3c,%esp
  8009b8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8009bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009be:	eb 14                	jmp    8009d4 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8009c0:	85 c0                	test   %eax,%eax
  8009c2:	0f 84 8a 03 00 00    	je     800d52 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  8009c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009cc:	89 04 24             	mov    %eax,(%esp)
  8009cf:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8009d2:	89 f3                	mov    %esi,%ebx
  8009d4:	8d 73 01             	lea    0x1(%ebx),%esi
  8009d7:	31 c0                	xor    %eax,%eax
  8009d9:	8a 03                	mov    (%ebx),%al
  8009db:	83 f8 25             	cmp    $0x25,%eax
  8009de:	75 e0                	jne    8009c0 <vprintfmt+0x11>
  8009e0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8009e4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8009eb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8009f2:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8009f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fe:	eb 1d                	jmp    800a1d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a00:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800a02:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800a06:	eb 15                	jmp    800a1d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a08:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a0a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800a0e:	eb 0d                	jmp    800a1d <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800a10:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a13:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a16:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a1d:	8d 5e 01             	lea    0x1(%esi),%ebx
  800a20:	31 c0                	xor    %eax,%eax
  800a22:	8a 06                	mov    (%esi),%al
  800a24:	8a 0e                	mov    (%esi),%cl
  800a26:	83 e9 23             	sub    $0x23,%ecx
  800a29:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800a2c:	80 f9 55             	cmp    $0x55,%cl
  800a2f:	0f 87 ff 02 00 00    	ja     800d34 <vprintfmt+0x385>
  800a35:	31 c9                	xor    %ecx,%ecx
  800a37:	8a 4d e0             	mov    -0x20(%ebp),%cl
  800a3a:	ff 24 8d a0 11 80 00 	jmp    *0x8011a0(,%ecx,4)
  800a41:	89 de                	mov    %ebx,%esi
  800a43:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800a48:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800a4b:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800a4f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800a52:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800a55:	83 fb 09             	cmp    $0x9,%ebx
  800a58:	77 2f                	ja     800a89 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800a5a:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800a5b:	eb eb                	jmp    800a48 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800a5d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a60:	8d 48 04             	lea    0x4(%eax),%ecx
  800a63:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a66:	8b 00                	mov    (%eax),%eax
  800a68:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a6b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800a6d:	eb 1d                	jmp    800a8c <vprintfmt+0xdd>
  800a6f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a72:	f7 d0                	not    %eax
  800a74:	c1 f8 1f             	sar    $0x1f,%eax
  800a77:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a7a:	89 de                	mov    %ebx,%esi
  800a7c:	eb 9f                	jmp    800a1d <vprintfmt+0x6e>
  800a7e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800a80:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800a87:	eb 94                	jmp    800a1d <vprintfmt+0x6e>
  800a89:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800a8c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a90:	79 8b                	jns    800a1d <vprintfmt+0x6e>
  800a92:	e9 79 ff ff ff       	jmp    800a10 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800a97:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a98:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800a9a:	eb 81                	jmp    800a1d <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800a9c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a9f:	8d 50 04             	lea    0x4(%eax),%edx
  800aa2:	89 55 14             	mov    %edx,0x14(%ebp)
  800aa5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aa9:	8b 00                	mov    (%eax),%eax
  800aab:	89 04 24             	mov    %eax,(%esp)
  800aae:	ff 55 08             	call   *0x8(%ebp)
			break;
  800ab1:	e9 1e ff ff ff       	jmp    8009d4 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800ab6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab9:	8d 50 04             	lea    0x4(%eax),%edx
  800abc:	89 55 14             	mov    %edx,0x14(%ebp)
  800abf:	8b 00                	mov    (%eax),%eax
  800ac1:	89 c2                	mov    %eax,%edx
  800ac3:	c1 fa 1f             	sar    $0x1f,%edx
  800ac6:	31 d0                	xor    %edx,%eax
  800ac8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800aca:	83 f8 09             	cmp    $0x9,%eax
  800acd:	7f 0b                	jg     800ada <vprintfmt+0x12b>
  800acf:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  800ad6:	85 d2                	test   %edx,%edx
  800ad8:	75 20                	jne    800afa <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  800ada:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ade:	c7 44 24 08 00 11 80 	movl   $0x801100,0x8(%esp)
  800ae5:	00 
  800ae6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aea:	8b 45 08             	mov    0x8(%ebp),%eax
  800aed:	89 04 24             	mov    %eax,(%esp)
  800af0:	e8 92 fe ff ff       	call   800987 <printfmt>
  800af5:	e9 da fe ff ff       	jmp    8009d4 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800afa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800afe:	c7 44 24 08 09 11 80 	movl   $0x801109,0x8(%esp)
  800b05:	00 
  800b06:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0d:	89 04 24             	mov    %eax,(%esp)
  800b10:	e8 72 fe ff ff       	call   800987 <printfmt>
  800b15:	e9 ba fe ff ff       	jmp    8009d4 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b1a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800b1d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b20:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800b23:	8b 45 14             	mov    0x14(%ebp),%eax
  800b26:	8d 50 04             	lea    0x4(%eax),%edx
  800b29:	89 55 14             	mov    %edx,0x14(%ebp)
  800b2c:	8b 30                	mov    (%eax),%esi
  800b2e:	85 f6                	test   %esi,%esi
  800b30:	75 05                	jne    800b37 <vprintfmt+0x188>
				p = "(null)";
  800b32:	be f9 10 80 00       	mov    $0x8010f9,%esi
			if (width > 0 && padc != '-')
  800b37:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800b3b:	0f 84 8c 00 00 00    	je     800bcd <vprintfmt+0x21e>
  800b41:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b45:	0f 8e 8a 00 00 00    	jle    800bd5 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b4b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b4f:	89 34 24             	mov    %esi,(%esp)
  800b52:	e8 9b f5 ff ff       	call   8000f2 <strnlen>
  800b57:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800b5a:	29 c1                	sub    %eax,%ecx
  800b5c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800b5f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800b63:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b66:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800b69:	8b 75 08             	mov    0x8(%ebp),%esi
  800b6c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b6f:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b71:	eb 0d                	jmp    800b80 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800b73:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b77:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b7a:	89 04 24             	mov    %eax,(%esp)
  800b7d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b7f:	4b                   	dec    %ebx
  800b80:	85 db                	test   %ebx,%ebx
  800b82:	7f ef                	jg     800b73 <vprintfmt+0x1c4>
  800b84:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800b87:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b8a:	89 c8                	mov    %ecx,%eax
  800b8c:	f7 d0                	not    %eax
  800b8e:	c1 f8 1f             	sar    $0x1f,%eax
  800b91:	21 c8                	and    %ecx,%eax
  800b93:	29 c1                	sub    %eax,%ecx
  800b95:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b98:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800b9b:	eb 3e                	jmp    800bdb <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b9d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800ba1:	74 1b                	je     800bbe <vprintfmt+0x20f>
  800ba3:	0f be d2             	movsbl %dl,%edx
  800ba6:	83 ea 20             	sub    $0x20,%edx
  800ba9:	83 fa 5e             	cmp    $0x5e,%edx
  800bac:	76 10                	jbe    800bbe <vprintfmt+0x20f>
					putch('?', putdat);
  800bae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bb2:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800bb9:	ff 55 08             	call   *0x8(%ebp)
  800bbc:	eb 0a                	jmp    800bc8 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800bbe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bc2:	89 04 24             	mov    %eax,(%esp)
  800bc5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bc8:	ff 4d dc             	decl   -0x24(%ebp)
  800bcb:	eb 0e                	jmp    800bdb <vprintfmt+0x22c>
  800bcd:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bd0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800bd3:	eb 06                	jmp    800bdb <vprintfmt+0x22c>
  800bd5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bd8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800bdb:	46                   	inc    %esi
  800bdc:	8a 56 ff             	mov    -0x1(%esi),%dl
  800bdf:	0f be c2             	movsbl %dl,%eax
  800be2:	85 c0                	test   %eax,%eax
  800be4:	74 1f                	je     800c05 <vprintfmt+0x256>
  800be6:	85 db                	test   %ebx,%ebx
  800be8:	78 b3                	js     800b9d <vprintfmt+0x1ee>
  800bea:	4b                   	dec    %ebx
  800beb:	79 b0                	jns    800b9d <vprintfmt+0x1ee>
  800bed:	8b 75 08             	mov    0x8(%ebp),%esi
  800bf0:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800bf3:	eb 16                	jmp    800c0b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800bf5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bf9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800c00:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800c02:	4b                   	dec    %ebx
  800c03:	eb 06                	jmp    800c0b <vprintfmt+0x25c>
  800c05:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800c08:	8b 75 08             	mov    0x8(%ebp),%esi
  800c0b:	85 db                	test   %ebx,%ebx
  800c0d:	7f e6                	jg     800bf5 <vprintfmt+0x246>
  800c0f:	89 75 08             	mov    %esi,0x8(%ebp)
  800c12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c15:	e9 ba fd ff ff       	jmp    8009d4 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c1a:	83 fa 01             	cmp    $0x1,%edx
  800c1d:	7e 16                	jle    800c35 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  800c1f:	8b 45 14             	mov    0x14(%ebp),%eax
  800c22:	8d 50 08             	lea    0x8(%eax),%edx
  800c25:	89 55 14             	mov    %edx,0x14(%ebp)
  800c28:	8b 50 04             	mov    0x4(%eax),%edx
  800c2b:	8b 00                	mov    (%eax),%eax
  800c2d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c30:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c33:	eb 32                	jmp    800c67 <vprintfmt+0x2b8>
	else if (lflag)
  800c35:	85 d2                	test   %edx,%edx
  800c37:	74 18                	je     800c51 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800c39:	8b 45 14             	mov    0x14(%ebp),%eax
  800c3c:	8d 50 04             	lea    0x4(%eax),%edx
  800c3f:	89 55 14             	mov    %edx,0x14(%ebp)
  800c42:	8b 30                	mov    (%eax),%esi
  800c44:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800c47:	89 f0                	mov    %esi,%eax
  800c49:	c1 f8 1f             	sar    $0x1f,%eax
  800c4c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c4f:	eb 16                	jmp    800c67 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800c51:	8b 45 14             	mov    0x14(%ebp),%eax
  800c54:	8d 50 04             	lea    0x4(%eax),%edx
  800c57:	89 55 14             	mov    %edx,0x14(%ebp)
  800c5a:	8b 30                	mov    (%eax),%esi
  800c5c:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800c5f:	89 f0                	mov    %esi,%eax
  800c61:	c1 f8 1f             	sar    $0x1f,%eax
  800c64:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c67:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c6a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800c6d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800c72:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c76:	0f 89 80 00 00 00    	jns    800cfc <vprintfmt+0x34d>
				putch('-', putdat);
  800c7c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c80:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800c87:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800c8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c8d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c90:	f7 d8                	neg    %eax
  800c92:	83 d2 00             	adc    $0x0,%edx
  800c95:	f7 da                	neg    %edx
			}
			base = 10;
  800c97:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c9c:	eb 5e                	jmp    800cfc <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800c9e:	8d 45 14             	lea    0x14(%ebp),%eax
  800ca1:	e8 8b fc ff ff       	call   800931 <getuint>
			base = 10;
  800ca6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800cab:	eb 4f                	jmp    800cfc <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800cad:	8d 45 14             	lea    0x14(%ebp),%eax
  800cb0:	e8 7c fc ff ff       	call   800931 <getuint>
			base = 8;
  800cb5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800cba:	eb 40                	jmp    800cfc <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800cbc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cc0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800cc7:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800cca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cce:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800cd5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800cd8:	8b 45 14             	mov    0x14(%ebp),%eax
  800cdb:	8d 50 04             	lea    0x4(%eax),%edx
  800cde:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800ce1:	8b 00                	mov    (%eax),%eax
  800ce3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ce8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800ced:	eb 0d                	jmp    800cfc <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800cef:	8d 45 14             	lea    0x14(%ebp),%eax
  800cf2:	e8 3a fc ff ff       	call   800931 <getuint>
			base = 16;
  800cf7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800cfc:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800d00:	89 74 24 10          	mov    %esi,0x10(%esp)
  800d04:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800d07:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800d0b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d0f:	89 04 24             	mov    %eax,(%esp)
  800d12:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d16:	89 fa                	mov    %edi,%edx
  800d18:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1b:	e8 20 fb ff ff       	call   800840 <printnum>
			break;
  800d20:	e9 af fc ff ff       	jmp    8009d4 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d25:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d29:	89 04 24             	mov    %eax,(%esp)
  800d2c:	ff 55 08             	call   *0x8(%ebp)
			break;
  800d2f:	e9 a0 fc ff ff       	jmp    8009d4 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d34:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d38:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800d3f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d42:	89 f3                	mov    %esi,%ebx
  800d44:	eb 01                	jmp    800d47 <vprintfmt+0x398>
  800d46:	4b                   	dec    %ebx
  800d47:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800d4b:	75 f9                	jne    800d46 <vprintfmt+0x397>
  800d4d:	e9 82 fc ff ff       	jmp    8009d4 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800d52:	83 c4 3c             	add    $0x3c,%esp
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	83 ec 28             	sub    $0x28,%esp
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d66:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d69:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d6d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d77:	85 c0                	test   %eax,%eax
  800d79:	74 30                	je     800dab <vsnprintf+0x51>
  800d7b:	85 d2                	test   %edx,%edx
  800d7d:	7e 2c                	jle    800dab <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d7f:	8b 45 14             	mov    0x14(%ebp),%eax
  800d82:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d86:	8b 45 10             	mov    0x10(%ebp),%eax
  800d89:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d8d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d90:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d94:	c7 04 24 6b 09 80 00 	movl   $0x80096b,(%esp)
  800d9b:	e8 0f fc ff ff       	call   8009af <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800da0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800da3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800da9:	eb 05                	jmp    800db0 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800dab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800db0:	c9                   	leave  
  800db1:	c3                   	ret    

00800db2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800db8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800dbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dbf:	8b 45 10             	mov    0x10(%ebp),%eax
  800dc2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd0:	89 04 24             	mov    %eax,(%esp)
  800dd3:	e8 82 ff ff ff       	call   800d5a <vsnprintf>
	va_end(ap);

	return rc;
}
  800dd8:	c9                   	leave  
  800dd9:	c3                   	ret    
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
