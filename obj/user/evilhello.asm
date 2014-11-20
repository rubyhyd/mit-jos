
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 0c 00 10 f0 	movl   $0xf010000c,(%esp)
  800049:	e8 f6 03 00 00       	call   800444 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	83 ec 10             	sub    $0x10,%esp
  800058:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005b:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  80005e:	b8 08 20 80 00       	mov    $0x802008,%eax
  800063:	2d 04 20 80 00       	sub    $0x802004,%eax
  800068:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800073:	00 
  800074:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  80007b:	e8 cf 01 00 00       	call   80024f <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  800080:	e8 4e 04 00 00       	call   8004d3 <sys_getenvid>
  800085:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800091:	c1 e0 07             	shl    $0x7,%eax
  800094:	29 d0                	sub    %edx,%eax
  800096:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a0:	85 db                	test   %ebx,%ebx
  8000a2:	7e 07                	jle    8000ab <libmain+0x5b>
		binaryname = argv[0];
  8000a4:	8b 06                	mov    (%esi),%eax
  8000a6:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000af:	89 1c 24             	mov    %ebx,(%esp)
  8000b2:	e8 7d ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 08 00 00 00       	call   8000c4 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	5b                   	pop    %ebx
  8000c0:	5e                   	pop    %esi
  8000c1:	5d                   	pop    %ebp
  8000c2:	c3                   	ret    
  8000c3:	90                   	nop

008000c4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d1:	e8 ab 03 00 00       	call   800481 <sys_env_destroy>
}
  8000d6:	c9                   	leave  
  8000d7:	c3                   	ret    

008000d8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8000de:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e3:	eb 01                	jmp    8000e6 <strlen+0xe>
		n++;
  8000e5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8000e6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8000ea:	75 f9                	jne    8000e5 <strlen+0xd>
		n++;
	return n;
}
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8000f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000fc:	eb 01                	jmp    8000ff <strnlen+0x11>
		n++;
  8000fe:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8000ff:	39 d0                	cmp    %edx,%eax
  800101:	74 06                	je     800109 <strnlen+0x1b>
  800103:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800107:	75 f5                	jne    8000fe <strnlen+0x10>
		n++;
	return n;
}
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    

0080010b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	53                   	push   %ebx
  80010f:	8b 45 08             	mov    0x8(%ebp),%eax
  800112:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800115:	89 c2                	mov    %eax,%edx
  800117:	42                   	inc    %edx
  800118:	41                   	inc    %ecx
  800119:	8a 59 ff             	mov    -0x1(%ecx),%bl
  80011c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80011f:	84 db                	test   %bl,%bl
  800121:	75 f4                	jne    800117 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800123:	5b                   	pop    %ebx
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    

00800126 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800126:	55                   	push   %ebp
  800127:	89 e5                	mov    %esp,%ebp
  800129:	53                   	push   %ebx
  80012a:	83 ec 08             	sub    $0x8,%esp
  80012d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800130:	89 1c 24             	mov    %ebx,(%esp)
  800133:	e8 a0 ff ff ff       	call   8000d8 <strlen>
	strcpy(dst + len, src);
  800138:	8b 55 0c             	mov    0xc(%ebp),%edx
  80013b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80013f:	01 d8                	add    %ebx,%eax
  800141:	89 04 24             	mov    %eax,(%esp)
  800144:	e8 c2 ff ff ff       	call   80010b <strcpy>
	return dst;
}
  800149:	89 d8                	mov    %ebx,%eax
  80014b:	83 c4 08             	add    $0x8,%esp
  80014e:	5b                   	pop    %ebx
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	56                   	push   %esi
  800155:	53                   	push   %ebx
  800156:	8b 75 08             	mov    0x8(%ebp),%esi
  800159:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80015c:	89 f3                	mov    %esi,%ebx
  80015e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800161:	89 f2                	mov    %esi,%edx
  800163:	eb 0c                	jmp    800171 <strncpy+0x20>
		*dst++ = *src;
  800165:	42                   	inc    %edx
  800166:	8a 01                	mov    (%ecx),%al
  800168:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80016b:	80 39 01             	cmpb   $0x1,(%ecx)
  80016e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800171:	39 da                	cmp    %ebx,%edx
  800173:	75 f0                	jne    800165 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800175:	89 f0                	mov    %esi,%eax
  800177:	5b                   	pop    %ebx
  800178:	5e                   	pop    %esi
  800179:	5d                   	pop    %ebp
  80017a:	c3                   	ret    

0080017b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	56                   	push   %esi
  80017f:	53                   	push   %ebx
  800180:	8b 75 08             	mov    0x8(%ebp),%esi
  800183:	8b 55 0c             	mov    0xc(%ebp),%edx
  800186:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800189:	89 f0                	mov    %esi,%eax
  80018b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80018f:	85 c9                	test   %ecx,%ecx
  800191:	75 07                	jne    80019a <strlcpy+0x1f>
  800193:	eb 18                	jmp    8001ad <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800195:	40                   	inc    %eax
  800196:	42                   	inc    %edx
  800197:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80019a:	39 d8                	cmp    %ebx,%eax
  80019c:	74 0a                	je     8001a8 <strlcpy+0x2d>
  80019e:	8a 0a                	mov    (%edx),%cl
  8001a0:	84 c9                	test   %cl,%cl
  8001a2:	75 f1                	jne    800195 <strlcpy+0x1a>
  8001a4:	89 c2                	mov    %eax,%edx
  8001a6:	eb 02                	jmp    8001aa <strlcpy+0x2f>
  8001a8:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8001aa:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8001ad:	29 f0                	sub    %esi,%eax
}
  8001af:	5b                   	pop    %ebx
  8001b0:	5e                   	pop    %esi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    

008001b3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8001bc:	eb 02                	jmp    8001c0 <strcmp+0xd>
		p++, q++;
  8001be:	41                   	inc    %ecx
  8001bf:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8001c0:	8a 01                	mov    (%ecx),%al
  8001c2:	84 c0                	test   %al,%al
  8001c4:	74 04                	je     8001ca <strcmp+0x17>
  8001c6:	3a 02                	cmp    (%edx),%al
  8001c8:	74 f4                	je     8001be <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8001ca:	25 ff 00 00 00       	and    $0xff,%eax
  8001cf:	8a 0a                	mov    (%edx),%cl
  8001d1:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8001d7:	29 c8                	sub    %ecx,%eax
}
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	53                   	push   %ebx
  8001df:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e5:	89 c3                	mov    %eax,%ebx
  8001e7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8001ea:	eb 02                	jmp    8001ee <strncmp+0x13>
		n--, p++, q++;
  8001ec:	40                   	inc    %eax
  8001ed:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8001ee:	39 d8                	cmp    %ebx,%eax
  8001f0:	74 20                	je     800212 <strncmp+0x37>
  8001f2:	8a 08                	mov    (%eax),%cl
  8001f4:	84 c9                	test   %cl,%cl
  8001f6:	74 04                	je     8001fc <strncmp+0x21>
  8001f8:	3a 0a                	cmp    (%edx),%cl
  8001fa:	74 f0                	je     8001ec <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8001fc:	8a 18                	mov    (%eax),%bl
  8001fe:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800204:	89 d8                	mov    %ebx,%eax
  800206:	8a 1a                	mov    (%edx),%bl
  800208:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80020e:	29 d8                	sub    %ebx,%eax
  800210:	eb 05                	jmp    800217 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800212:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800217:	5b                   	pop    %ebx
  800218:	5d                   	pop    %ebp
  800219:	c3                   	ret    

0080021a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	8b 45 08             	mov    0x8(%ebp),%eax
  800220:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800223:	eb 05                	jmp    80022a <strchr+0x10>
		if (*s == c)
  800225:	38 ca                	cmp    %cl,%dl
  800227:	74 0c                	je     800235 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800229:	40                   	inc    %eax
  80022a:	8a 10                	mov    (%eax),%dl
  80022c:	84 d2                	test   %dl,%dl
  80022e:	75 f5                	jne    800225 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800230:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	8b 45 08             	mov    0x8(%ebp),%eax
  80023d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800240:	eb 05                	jmp    800247 <strfind+0x10>
		if (*s == c)
  800242:	38 ca                	cmp    %cl,%dl
  800244:	74 07                	je     80024d <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800246:	40                   	inc    %eax
  800247:	8a 10                	mov    (%eax),%dl
  800249:	84 d2                	test   %dl,%dl
  80024b:	75 f5                	jne    800242 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    

0080024f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	57                   	push   %edi
  800253:	56                   	push   %esi
  800254:	53                   	push   %ebx
  800255:	8b 7d 08             	mov    0x8(%ebp),%edi
  800258:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80025b:	85 c9                	test   %ecx,%ecx
  80025d:	74 37                	je     800296 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80025f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800265:	75 29                	jne    800290 <memset+0x41>
  800267:	f6 c1 03             	test   $0x3,%cl
  80026a:	75 24                	jne    800290 <memset+0x41>
		c &= 0xFF;
  80026c:	31 d2                	xor    %edx,%edx
  80026e:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800271:	89 d3                	mov    %edx,%ebx
  800273:	c1 e3 08             	shl    $0x8,%ebx
  800276:	89 d6                	mov    %edx,%esi
  800278:	c1 e6 18             	shl    $0x18,%esi
  80027b:	89 d0                	mov    %edx,%eax
  80027d:	c1 e0 10             	shl    $0x10,%eax
  800280:	09 f0                	or     %esi,%eax
  800282:	09 c2                	or     %eax,%edx
  800284:	89 d0                	mov    %edx,%eax
  800286:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800288:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80028b:	fc                   	cld    
  80028c:	f3 ab                	rep stos %eax,%es:(%edi)
  80028e:	eb 06                	jmp    800296 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800290:	8b 45 0c             	mov    0xc(%ebp),%eax
  800293:	fc                   	cld    
  800294:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800296:	89 f8                	mov    %edi,%eax
  800298:	5b                   	pop    %ebx
  800299:	5e                   	pop    %esi
  80029a:	5f                   	pop    %edi
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	57                   	push   %edi
  8002a1:	56                   	push   %esi
  8002a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8002ab:	39 c6                	cmp    %eax,%esi
  8002ad:	73 33                	jae    8002e2 <memmove+0x45>
  8002af:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8002b2:	39 d0                	cmp    %edx,%eax
  8002b4:	73 2c                	jae    8002e2 <memmove+0x45>
		s += n;
		d += n;
  8002b6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8002b9:	89 d6                	mov    %edx,%esi
  8002bb:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8002bd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8002c3:	75 13                	jne    8002d8 <memmove+0x3b>
  8002c5:	f6 c1 03             	test   $0x3,%cl
  8002c8:	75 0e                	jne    8002d8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8002ca:	83 ef 04             	sub    $0x4,%edi
  8002cd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8002d0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8002d3:	fd                   	std    
  8002d4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8002d6:	eb 07                	jmp    8002df <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8002d8:	4f                   	dec    %edi
  8002d9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8002dc:	fd                   	std    
  8002dd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8002df:	fc                   	cld    
  8002e0:	eb 1d                	jmp    8002ff <memmove+0x62>
  8002e2:	89 f2                	mov    %esi,%edx
  8002e4:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8002e6:	f6 c2 03             	test   $0x3,%dl
  8002e9:	75 0f                	jne    8002fa <memmove+0x5d>
  8002eb:	f6 c1 03             	test   $0x3,%cl
  8002ee:	75 0a                	jne    8002fa <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8002f0:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8002f3:	89 c7                	mov    %eax,%edi
  8002f5:	fc                   	cld    
  8002f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8002f8:	eb 05                	jmp    8002ff <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8002fa:	89 c7                	mov    %eax,%edi
  8002fc:	fc                   	cld    
  8002fd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8002ff:	5e                   	pop    %esi
  800300:	5f                   	pop    %edi
  800301:	5d                   	pop    %ebp
  800302:	c3                   	ret    

00800303 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800309:	8b 45 10             	mov    0x10(%ebp),%eax
  80030c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800310:	8b 45 0c             	mov    0xc(%ebp),%eax
  800313:	89 44 24 04          	mov    %eax,0x4(%esp)
  800317:	8b 45 08             	mov    0x8(%ebp),%eax
  80031a:	89 04 24             	mov    %eax,(%esp)
  80031d:	e8 7b ff ff ff       	call   80029d <memmove>
}
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032f:	89 d6                	mov    %edx,%esi
  800331:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800334:	eb 19                	jmp    80034f <memcmp+0x2b>
		if (*s1 != *s2)
  800336:	8a 02                	mov    (%edx),%al
  800338:	8a 19                	mov    (%ecx),%bl
  80033a:	38 d8                	cmp    %bl,%al
  80033c:	74 0f                	je     80034d <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  80033e:	25 ff 00 00 00       	and    $0xff,%eax
  800343:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800349:	29 d8                	sub    %ebx,%eax
  80034b:	eb 0b                	jmp    800358 <memcmp+0x34>
		s1++, s2++;
  80034d:	42                   	inc    %edx
  80034e:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80034f:	39 f2                	cmp    %esi,%edx
  800351:	75 e3                	jne    800336 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800353:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800358:	5b                   	pop    %ebx
  800359:	5e                   	pop    %esi
  80035a:	5d                   	pop    %ebp
  80035b:	c3                   	ret    

0080035c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	8b 45 08             	mov    0x8(%ebp),%eax
  800362:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800365:	89 c2                	mov    %eax,%edx
  800367:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80036a:	eb 05                	jmp    800371 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  80036c:	38 08                	cmp    %cl,(%eax)
  80036e:	74 05                	je     800375 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800370:	40                   	inc    %eax
  800371:	39 d0                	cmp    %edx,%eax
  800373:	72 f7                	jb     80036c <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800375:	5d                   	pop    %ebp
  800376:	c3                   	ret    

00800377 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
  80037a:	57                   	push   %edi
  80037b:	56                   	push   %esi
  80037c:	53                   	push   %ebx
  80037d:	8b 55 08             	mov    0x8(%ebp),%edx
  800380:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800383:	eb 01                	jmp    800386 <strtol+0xf>
		s++;
  800385:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800386:	8a 02                	mov    (%edx),%al
  800388:	3c 09                	cmp    $0x9,%al
  80038a:	74 f9                	je     800385 <strtol+0xe>
  80038c:	3c 20                	cmp    $0x20,%al
  80038e:	74 f5                	je     800385 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800390:	3c 2b                	cmp    $0x2b,%al
  800392:	75 08                	jne    80039c <strtol+0x25>
		s++;
  800394:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800395:	bf 00 00 00 00       	mov    $0x0,%edi
  80039a:	eb 10                	jmp    8003ac <strtol+0x35>
  80039c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8003a1:	3c 2d                	cmp    $0x2d,%al
  8003a3:	75 07                	jne    8003ac <strtol+0x35>
		s++, neg = 1;
  8003a5:	8d 52 01             	lea    0x1(%edx),%edx
  8003a8:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8003ac:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8003b2:	75 15                	jne    8003c9 <strtol+0x52>
  8003b4:	80 3a 30             	cmpb   $0x30,(%edx)
  8003b7:	75 10                	jne    8003c9 <strtol+0x52>
  8003b9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8003bd:	75 0a                	jne    8003c9 <strtol+0x52>
		s += 2, base = 16;
  8003bf:	83 c2 02             	add    $0x2,%edx
  8003c2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8003c7:	eb 0e                	jmp    8003d7 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  8003c9:	85 db                	test   %ebx,%ebx
  8003cb:	75 0a                	jne    8003d7 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8003cd:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8003cf:	80 3a 30             	cmpb   $0x30,(%edx)
  8003d2:	75 03                	jne    8003d7 <strtol+0x60>
		s++, base = 8;
  8003d4:	42                   	inc    %edx
  8003d5:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  8003d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003dc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8003df:	8a 0a                	mov    (%edx),%cl
  8003e1:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8003e4:	89 f3                	mov    %esi,%ebx
  8003e6:	80 fb 09             	cmp    $0x9,%bl
  8003e9:	77 08                	ja     8003f3 <strtol+0x7c>
			dig = *s - '0';
  8003eb:	0f be c9             	movsbl %cl,%ecx
  8003ee:	83 e9 30             	sub    $0x30,%ecx
  8003f1:	eb 22                	jmp    800415 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  8003f3:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8003f6:	89 f3                	mov    %esi,%ebx
  8003f8:	80 fb 19             	cmp    $0x19,%bl
  8003fb:	77 08                	ja     800405 <strtol+0x8e>
			dig = *s - 'a' + 10;
  8003fd:	0f be c9             	movsbl %cl,%ecx
  800400:	83 e9 57             	sub    $0x57,%ecx
  800403:	eb 10                	jmp    800415 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800405:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800408:	89 f3                	mov    %esi,%ebx
  80040a:	80 fb 19             	cmp    $0x19,%bl
  80040d:	77 14                	ja     800423 <strtol+0xac>
			dig = *s - 'A' + 10;
  80040f:	0f be c9             	movsbl %cl,%ecx
  800412:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800415:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800418:	7d 0d                	jge    800427 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  80041a:	42                   	inc    %edx
  80041b:	0f af 45 10          	imul   0x10(%ebp),%eax
  80041f:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800421:	eb bc                	jmp    8003df <strtol+0x68>
  800423:	89 c1                	mov    %eax,%ecx
  800425:	eb 02                	jmp    800429 <strtol+0xb2>
  800427:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800429:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80042d:	74 05                	je     800434 <strtol+0xbd>
		*endptr = (char *) s;
  80042f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800432:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800434:	85 ff                	test   %edi,%edi
  800436:	74 04                	je     80043c <strtol+0xc5>
  800438:	89 c8                	mov    %ecx,%eax
  80043a:	f7 d8                	neg    %eax
}
  80043c:	5b                   	pop    %ebx
  80043d:	5e                   	pop    %esi
  80043e:	5f                   	pop    %edi
  80043f:	5d                   	pop    %ebp
  800440:	c3                   	ret    
  800441:	66 90                	xchg   %ax,%ax
  800443:	90                   	nop

00800444 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
  800447:	57                   	push   %edi
  800448:	56                   	push   %esi
  800449:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80044a:	b8 00 00 00 00       	mov    $0x0,%eax
  80044f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800452:	8b 55 08             	mov    0x8(%ebp),%edx
  800455:	89 c3                	mov    %eax,%ebx
  800457:	89 c7                	mov    %eax,%edi
  800459:	89 c6                	mov    %eax,%esi
  80045b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80045d:	5b                   	pop    %ebx
  80045e:	5e                   	pop    %esi
  80045f:	5f                   	pop    %edi
  800460:	5d                   	pop    %ebp
  800461:	c3                   	ret    

00800462 <sys_cgetc>:

int
sys_cgetc(void)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	57                   	push   %edi
  800466:	56                   	push   %esi
  800467:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800468:	ba 00 00 00 00       	mov    $0x0,%edx
  80046d:	b8 01 00 00 00       	mov    $0x1,%eax
  800472:	89 d1                	mov    %edx,%ecx
  800474:	89 d3                	mov    %edx,%ebx
  800476:	89 d7                	mov    %edx,%edi
  800478:	89 d6                	mov    %edx,%esi
  80047a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80047c:	5b                   	pop    %ebx
  80047d:	5e                   	pop    %esi
  80047e:	5f                   	pop    %edi
  80047f:	5d                   	pop    %ebp
  800480:	c3                   	ret    

00800481 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800481:	55                   	push   %ebp
  800482:	89 e5                	mov    %esp,%ebp
  800484:	57                   	push   %edi
  800485:	56                   	push   %esi
  800486:	53                   	push   %ebx
  800487:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80048a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80048f:	b8 03 00 00 00       	mov    $0x3,%eax
  800494:	8b 55 08             	mov    0x8(%ebp),%edx
  800497:	89 cb                	mov    %ecx,%ebx
  800499:	89 cf                	mov    %ecx,%edi
  80049b:	89 ce                	mov    %ecx,%esi
  80049d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	7e 28                	jle    8004cb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004a3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004a7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8004ae:	00 
  8004af:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8004b6:	00 
  8004b7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004be:	00 
  8004bf:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8004c6:	e8 5d 02 00 00       	call   800728 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8004cb:	83 c4 2c             	add    $0x2c,%esp
  8004ce:	5b                   	pop    %ebx
  8004cf:	5e                   	pop    %esi
  8004d0:	5f                   	pop    %edi
  8004d1:	5d                   	pop    %ebp
  8004d2:	c3                   	ret    

008004d3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8004d3:	55                   	push   %ebp
  8004d4:	89 e5                	mov    %esp,%ebp
  8004d6:	57                   	push   %edi
  8004d7:	56                   	push   %esi
  8004d8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004de:	b8 02 00 00 00       	mov    $0x2,%eax
  8004e3:	89 d1                	mov    %edx,%ecx
  8004e5:	89 d3                	mov    %edx,%ebx
  8004e7:	89 d7                	mov    %edx,%edi
  8004e9:	89 d6                	mov    %edx,%esi
  8004eb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8004ed:	5b                   	pop    %ebx
  8004ee:	5e                   	pop    %esi
  8004ef:	5f                   	pop    %edi
  8004f0:	5d                   	pop    %ebp
  8004f1:	c3                   	ret    

008004f2 <sys_yield>:

void
sys_yield(void)
{
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	57                   	push   %edi
  8004f6:	56                   	push   %esi
  8004f7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004fd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800502:	89 d1                	mov    %edx,%ecx
  800504:	89 d3                	mov    %edx,%ebx
  800506:	89 d7                	mov    %edx,%edi
  800508:	89 d6                	mov    %edx,%esi
  80050a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80050c:	5b                   	pop    %ebx
  80050d:	5e                   	pop    %esi
  80050e:	5f                   	pop    %edi
  80050f:	5d                   	pop    %ebp
  800510:	c3                   	ret    

00800511 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	57                   	push   %edi
  800515:	56                   	push   %esi
  800516:	53                   	push   %ebx
  800517:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80051a:	be 00 00 00 00       	mov    $0x0,%esi
  80051f:	b8 04 00 00 00       	mov    $0x4,%eax
  800524:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800527:	8b 55 08             	mov    0x8(%ebp),%edx
  80052a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80052d:	89 f7                	mov    %esi,%edi
  80052f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800531:	85 c0                	test   %eax,%eax
  800533:	7e 28                	jle    80055d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800535:	89 44 24 10          	mov    %eax,0x10(%esp)
  800539:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800540:	00 
  800541:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800548:	00 
  800549:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800550:	00 
  800551:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800558:	e8 cb 01 00 00       	call   800728 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80055d:	83 c4 2c             	add    $0x2c,%esp
  800560:	5b                   	pop    %ebx
  800561:	5e                   	pop    %esi
  800562:	5f                   	pop    %edi
  800563:	5d                   	pop    %ebp
  800564:	c3                   	ret    

00800565 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800565:	55                   	push   %ebp
  800566:	89 e5                	mov    %esp,%ebp
  800568:	57                   	push   %edi
  800569:	56                   	push   %esi
  80056a:	53                   	push   %ebx
  80056b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80056e:	b8 05 00 00 00       	mov    $0x5,%eax
  800573:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800576:	8b 55 08             	mov    0x8(%ebp),%edx
  800579:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80057c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80057f:	8b 75 18             	mov    0x18(%ebp),%esi
  800582:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800584:	85 c0                	test   %eax,%eax
  800586:	7e 28                	jle    8005b0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800588:	89 44 24 10          	mov    %eax,0x10(%esp)
  80058c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800593:	00 
  800594:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  80059b:	00 
  80059c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005a3:	00 
  8005a4:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8005ab:	e8 78 01 00 00       	call   800728 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8005b0:	83 c4 2c             	add    $0x2c,%esp
  8005b3:	5b                   	pop    %ebx
  8005b4:	5e                   	pop    %esi
  8005b5:	5f                   	pop    %edi
  8005b6:	5d                   	pop    %ebp
  8005b7:	c3                   	ret    

008005b8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8005b8:	55                   	push   %ebp
  8005b9:	89 e5                	mov    %esp,%ebp
  8005bb:	57                   	push   %edi
  8005bc:	56                   	push   %esi
  8005bd:	53                   	push   %ebx
  8005be:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005c6:	b8 06 00 00 00       	mov    $0x6,%eax
  8005cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8005d1:	89 df                	mov    %ebx,%edi
  8005d3:	89 de                	mov    %ebx,%esi
  8005d5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005d7:	85 c0                	test   %eax,%eax
  8005d9:	7e 28                	jle    800603 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005db:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005df:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8005e6:	00 
  8005e7:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8005ee:	00 
  8005ef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005f6:	00 
  8005f7:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8005fe:	e8 25 01 00 00       	call   800728 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800603:	83 c4 2c             	add    $0x2c,%esp
  800606:	5b                   	pop    %ebx
  800607:	5e                   	pop    %esi
  800608:	5f                   	pop    %edi
  800609:	5d                   	pop    %ebp
  80060a:	c3                   	ret    

0080060b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80060b:	55                   	push   %ebp
  80060c:	89 e5                	mov    %esp,%ebp
  80060e:	57                   	push   %edi
  80060f:	56                   	push   %esi
  800610:	53                   	push   %ebx
  800611:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800614:	bb 00 00 00 00       	mov    $0x0,%ebx
  800619:	b8 08 00 00 00       	mov    $0x8,%eax
  80061e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800621:	8b 55 08             	mov    0x8(%ebp),%edx
  800624:	89 df                	mov    %ebx,%edi
  800626:	89 de                	mov    %ebx,%esi
  800628:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80062a:	85 c0                	test   %eax,%eax
  80062c:	7e 28                	jle    800656 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80062e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800632:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800639:	00 
  80063a:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800641:	00 
  800642:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800649:	00 
  80064a:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800651:	e8 d2 00 00 00       	call   800728 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800656:	83 c4 2c             	add    $0x2c,%esp
  800659:	5b                   	pop    %ebx
  80065a:	5e                   	pop    %esi
  80065b:	5f                   	pop    %edi
  80065c:	5d                   	pop    %ebp
  80065d:	c3                   	ret    

0080065e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80065e:	55                   	push   %ebp
  80065f:	89 e5                	mov    %esp,%ebp
  800661:	57                   	push   %edi
  800662:	56                   	push   %esi
  800663:	53                   	push   %ebx
  800664:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800667:	bb 00 00 00 00       	mov    $0x0,%ebx
  80066c:	b8 09 00 00 00       	mov    $0x9,%eax
  800671:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800674:	8b 55 08             	mov    0x8(%ebp),%edx
  800677:	89 df                	mov    %ebx,%edi
  800679:	89 de                	mov    %ebx,%esi
  80067b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80067d:	85 c0                	test   %eax,%eax
  80067f:	7e 28                	jle    8006a9 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800681:	89 44 24 10          	mov    %eax,0x10(%esp)
  800685:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80068c:	00 
  80068d:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800694:	00 
  800695:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80069c:	00 
  80069d:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8006a4:	e8 7f 00 00 00       	call   800728 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8006a9:	83 c4 2c             	add    $0x2c,%esp
  8006ac:	5b                   	pop    %ebx
  8006ad:	5e                   	pop    %esi
  8006ae:	5f                   	pop    %edi
  8006af:	5d                   	pop    %ebp
  8006b0:	c3                   	ret    

008006b1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8006b1:	55                   	push   %ebp
  8006b2:	89 e5                	mov    %esp,%ebp
  8006b4:	57                   	push   %edi
  8006b5:	56                   	push   %esi
  8006b6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006b7:	be 00 00 00 00       	mov    $0x0,%esi
  8006bc:	b8 0b 00 00 00       	mov    $0xb,%eax
  8006c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8006cd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8006cf:	5b                   	pop    %ebx
  8006d0:	5e                   	pop    %esi
  8006d1:	5f                   	pop    %edi
  8006d2:	5d                   	pop    %ebp
  8006d3:	c3                   	ret    

008006d4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	57                   	push   %edi
  8006d8:	56                   	push   %esi
  8006d9:	53                   	push   %ebx
  8006da:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8006e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ea:	89 cb                	mov    %ecx,%ebx
  8006ec:	89 cf                	mov    %ecx,%edi
  8006ee:	89 ce                	mov    %ecx,%esi
  8006f0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006f2:	85 c0                	test   %eax,%eax
  8006f4:	7e 28                	jle    80071e <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006fa:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800701:	00 
  800702:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800709:	00 
  80070a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800711:	00 
  800712:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800719:	e8 0a 00 00 00       	call   800728 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80071e:	83 c4 2c             	add    $0x2c,%esp
  800721:	5b                   	pop    %ebx
  800722:	5e                   	pop    %esi
  800723:	5f                   	pop    %edi
  800724:	5d                   	pop    %ebp
  800725:	c3                   	ret    
  800726:	66 90                	xchg   %ax,%ax

00800728 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	56                   	push   %esi
  80072c:	53                   	push   %ebx
  80072d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800730:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800733:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800739:	e8 95 fd ff ff       	call   8004d3 <sys_getenvid>
  80073e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800741:	89 54 24 10          	mov    %edx,0x10(%esp)
  800745:	8b 55 08             	mov    0x8(%ebp),%edx
  800748:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80074c:	89 74 24 08          	mov    %esi,0x8(%esp)
  800750:	89 44 24 04          	mov    %eax,0x4(%esp)
  800754:	c7 04 24 b8 10 80 00 	movl   $0x8010b8,(%esp)
  80075b:	e8 c2 00 00 00       	call   800822 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800760:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800764:	8b 45 10             	mov    0x10(%ebp),%eax
  800767:	89 04 24             	mov    %eax,(%esp)
  80076a:	e8 52 00 00 00       	call   8007c1 <vcprintf>
	cprintf("\n");
  80076f:	c7 04 24 dc 10 80 00 	movl   $0x8010dc,(%esp)
  800776:	e8 a7 00 00 00       	call   800822 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80077b:	cc                   	int3   
  80077c:	eb fd                	jmp    80077b <_panic+0x53>
  80077e:	66 90                	xchg   %ax,%ax

00800780 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	53                   	push   %ebx
  800784:	83 ec 14             	sub    $0x14,%esp
  800787:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80078a:	8b 13                	mov    (%ebx),%edx
  80078c:	8d 42 01             	lea    0x1(%edx),%eax
  80078f:	89 03                	mov    %eax,(%ebx)
  800791:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800794:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800798:	3d ff 00 00 00       	cmp    $0xff,%eax
  80079d:	75 19                	jne    8007b8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80079f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8007a6:	00 
  8007a7:	8d 43 08             	lea    0x8(%ebx),%eax
  8007aa:	89 04 24             	mov    %eax,(%esp)
  8007ad:	e8 92 fc ff ff       	call   800444 <sys_cputs>
		b->idx = 0;
  8007b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8007b8:	ff 43 04             	incl   0x4(%ebx)
}
  8007bb:	83 c4 14             	add    $0x14,%esp
  8007be:	5b                   	pop    %ebx
  8007bf:	5d                   	pop    %ebp
  8007c0:	c3                   	ret    

008007c1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8007ca:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8007d1:	00 00 00 
	b.cnt = 0;
  8007d4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8007db:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8007de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ec:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8007f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f6:	c7 04 24 80 07 80 00 	movl   $0x800780,(%esp)
  8007fd:	e8 a9 01 00 00       	call   8009ab <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800802:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800808:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800812:	89 04 24             	mov    %eax,(%esp)
  800815:	e8 2a fc ff ff       	call   800444 <sys_cputs>

	return b.cnt;
}
  80081a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800820:	c9                   	leave  
  800821:	c3                   	ret    

00800822 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800828:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80082b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082f:	8b 45 08             	mov    0x8(%ebp),%eax
  800832:	89 04 24             	mov    %eax,(%esp)
  800835:	e8 87 ff ff ff       	call   8007c1 <vcprintf>
	va_end(ap);

	return cnt;
}
  80083a:	c9                   	leave  
  80083b:	c3                   	ret    

0080083c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	57                   	push   %edi
  800840:	56                   	push   %esi
  800841:	53                   	push   %ebx
  800842:	83 ec 3c             	sub    $0x3c,%esp
  800845:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800848:	89 d7                	mov    %edx,%edi
  80084a:	8b 45 08             	mov    0x8(%ebp),%eax
  80084d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800850:	8b 45 0c             	mov    0xc(%ebp),%eax
  800853:	89 c1                	mov    %eax,%ecx
  800855:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800858:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80085b:	8b 45 10             	mov    0x10(%ebp),%eax
  80085e:	ba 00 00 00 00       	mov    $0x0,%edx
  800863:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800866:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800869:	39 ca                	cmp    %ecx,%edx
  80086b:	72 08                	jb     800875 <printnum+0x39>
  80086d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800870:	39 45 10             	cmp    %eax,0x10(%ebp)
  800873:	77 6a                	ja     8008df <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800875:	8b 45 18             	mov    0x18(%ebp),%eax
  800878:	89 44 24 10          	mov    %eax,0x10(%esp)
  80087c:	4e                   	dec    %esi
  80087d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800881:	8b 45 10             	mov    0x10(%ebp),%eax
  800884:	89 44 24 08          	mov    %eax,0x8(%esp)
  800888:	8b 44 24 08          	mov    0x8(%esp),%eax
  80088c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800890:	89 c3                	mov    %eax,%ebx
  800892:	89 d6                	mov    %edx,%esi
  800894:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800897:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80089a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008a5:	89 04 24             	mov    %eax,(%esp)
  8008a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8008ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008af:	e8 2c 05 00 00       	call   800de0 <__udivdi3>
  8008b4:	89 d9                	mov    %ebx,%ecx
  8008b6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008ba:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008be:	89 04 24             	mov    %eax,(%esp)
  8008c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c5:	89 fa                	mov    %edi,%edx
  8008c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008ca:	e8 6d ff ff ff       	call   80083c <printnum>
  8008cf:	eb 19                	jmp    8008ea <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8008d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008d5:	8b 45 18             	mov    0x18(%ebp),%eax
  8008d8:	89 04 24             	mov    %eax,(%esp)
  8008db:	ff d3                	call   *%ebx
  8008dd:	eb 03                	jmp    8008e2 <printnum+0xa6>
  8008df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8008e2:	4e                   	dec    %esi
  8008e3:	85 f6                	test   %esi,%esi
  8008e5:	7f ea                	jg     8008d1 <printnum+0x95>
  8008e7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8008ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ee:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8008f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008f5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008fc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800900:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800903:	89 04 24             	mov    %eax,(%esp)
  800906:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800909:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090d:	e8 fe 05 00 00       	call   800f10 <__umoddi3>
  800912:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800916:	0f be 80 de 10 80 00 	movsbl 0x8010de(%eax),%eax
  80091d:	89 04 24             	mov    %eax,(%esp)
  800920:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800923:	ff d0                	call   *%eax
}
  800925:	83 c4 3c             	add    $0x3c,%esp
  800928:	5b                   	pop    %ebx
  800929:	5e                   	pop    %esi
  80092a:	5f                   	pop    %edi
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800930:	83 fa 01             	cmp    $0x1,%edx
  800933:	7e 0e                	jle    800943 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800935:	8b 10                	mov    (%eax),%edx
  800937:	8d 4a 08             	lea    0x8(%edx),%ecx
  80093a:	89 08                	mov    %ecx,(%eax)
  80093c:	8b 02                	mov    (%edx),%eax
  80093e:	8b 52 04             	mov    0x4(%edx),%edx
  800941:	eb 22                	jmp    800965 <getuint+0x38>
	else if (lflag)
  800943:	85 d2                	test   %edx,%edx
  800945:	74 10                	je     800957 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800947:	8b 10                	mov    (%eax),%edx
  800949:	8d 4a 04             	lea    0x4(%edx),%ecx
  80094c:	89 08                	mov    %ecx,(%eax)
  80094e:	8b 02                	mov    (%edx),%eax
  800950:	ba 00 00 00 00       	mov    $0x0,%edx
  800955:	eb 0e                	jmp    800965 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800957:	8b 10                	mov    (%eax),%edx
  800959:	8d 4a 04             	lea    0x4(%edx),%ecx
  80095c:	89 08                	mov    %ecx,(%eax)
  80095e:	8b 02                	mov    (%edx),%eax
  800960:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80096d:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800970:	8b 10                	mov    (%eax),%edx
  800972:	3b 50 04             	cmp    0x4(%eax),%edx
  800975:	73 0a                	jae    800981 <sprintputch+0x1a>
		*b->buf++ = ch;
  800977:	8d 4a 01             	lea    0x1(%edx),%ecx
  80097a:	89 08                	mov    %ecx,(%eax)
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	88 02                	mov    %al,(%edx)
}
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800989:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80098c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800990:	8b 45 10             	mov    0x10(%ebp),%eax
  800993:	89 44 24 08          	mov    %eax,0x8(%esp)
  800997:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	89 04 24             	mov    %eax,(%esp)
  8009a4:	e8 02 00 00 00       	call   8009ab <vprintfmt>
	va_end(ap);
}
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	57                   	push   %edi
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	83 ec 3c             	sub    $0x3c,%esp
  8009b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8009b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009ba:	eb 14                	jmp    8009d0 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8009bc:	85 c0                	test   %eax,%eax
  8009be:	0f 84 8a 03 00 00    	je     800d4e <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  8009c4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009c8:	89 04 24             	mov    %eax,(%esp)
  8009cb:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8009ce:	89 f3                	mov    %esi,%ebx
  8009d0:	8d 73 01             	lea    0x1(%ebx),%esi
  8009d3:	31 c0                	xor    %eax,%eax
  8009d5:	8a 03                	mov    (%ebx),%al
  8009d7:	83 f8 25             	cmp    $0x25,%eax
  8009da:	75 e0                	jne    8009bc <vprintfmt+0x11>
  8009dc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8009e0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8009e7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8009ee:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8009f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fa:	eb 1d                	jmp    800a19 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009fc:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8009fe:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800a02:	eb 15                	jmp    800a19 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a04:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a06:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800a0a:	eb 0d                	jmp    800a19 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800a0c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a0f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a12:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a19:	8d 5e 01             	lea    0x1(%esi),%ebx
  800a1c:	31 c0                	xor    %eax,%eax
  800a1e:	8a 06                	mov    (%esi),%al
  800a20:	8a 0e                	mov    (%esi),%cl
  800a22:	83 e9 23             	sub    $0x23,%ecx
  800a25:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800a28:	80 f9 55             	cmp    $0x55,%cl
  800a2b:	0f 87 ff 02 00 00    	ja     800d30 <vprintfmt+0x385>
  800a31:	31 c9                	xor    %ecx,%ecx
  800a33:	8a 4d e0             	mov    -0x20(%ebp),%cl
  800a36:	ff 24 8d a0 11 80 00 	jmp    *0x8011a0(,%ecx,4)
  800a3d:	89 de                	mov    %ebx,%esi
  800a3f:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800a44:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800a47:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800a4b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800a4e:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800a51:	83 fb 09             	cmp    $0x9,%ebx
  800a54:	77 2f                	ja     800a85 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800a56:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800a57:	eb eb                	jmp    800a44 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800a59:	8b 45 14             	mov    0x14(%ebp),%eax
  800a5c:	8d 48 04             	lea    0x4(%eax),%ecx
  800a5f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a62:	8b 00                	mov    (%eax),%eax
  800a64:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a67:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800a69:	eb 1d                	jmp    800a88 <vprintfmt+0xdd>
  800a6b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a6e:	f7 d0                	not    %eax
  800a70:	c1 f8 1f             	sar    $0x1f,%eax
  800a73:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a76:	89 de                	mov    %ebx,%esi
  800a78:	eb 9f                	jmp    800a19 <vprintfmt+0x6e>
  800a7a:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800a7c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800a83:	eb 94                	jmp    800a19 <vprintfmt+0x6e>
  800a85:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800a88:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a8c:	79 8b                	jns    800a19 <vprintfmt+0x6e>
  800a8e:	e9 79 ff ff ff       	jmp    800a0c <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800a93:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a94:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800a96:	eb 81                	jmp    800a19 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800a98:	8b 45 14             	mov    0x14(%ebp),%eax
  800a9b:	8d 50 04             	lea    0x4(%eax),%edx
  800a9e:	89 55 14             	mov    %edx,0x14(%ebp)
  800aa1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aa5:	8b 00                	mov    (%eax),%eax
  800aa7:	89 04 24             	mov    %eax,(%esp)
  800aaa:	ff 55 08             	call   *0x8(%ebp)
			break;
  800aad:	e9 1e ff ff ff       	jmp    8009d0 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800ab2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab5:	8d 50 04             	lea    0x4(%eax),%edx
  800ab8:	89 55 14             	mov    %edx,0x14(%ebp)
  800abb:	8b 00                	mov    (%eax),%eax
  800abd:	89 c2                	mov    %eax,%edx
  800abf:	c1 fa 1f             	sar    $0x1f,%edx
  800ac2:	31 d0                	xor    %edx,%eax
  800ac4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800ac6:	83 f8 09             	cmp    $0x9,%eax
  800ac9:	7f 0b                	jg     800ad6 <vprintfmt+0x12b>
  800acb:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  800ad2:	85 d2                	test   %edx,%edx
  800ad4:	75 20                	jne    800af6 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  800ad6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ada:	c7 44 24 08 f6 10 80 	movl   $0x8010f6,0x8(%esp)
  800ae1:	00 
  800ae2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae9:	89 04 24             	mov    %eax,(%esp)
  800aec:	e8 92 fe ff ff       	call   800983 <printfmt>
  800af1:	e9 da fe ff ff       	jmp    8009d0 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800af6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800afa:	c7 44 24 08 ff 10 80 	movl   $0x8010ff,0x8(%esp)
  800b01:	00 
  800b02:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b06:	8b 45 08             	mov    0x8(%ebp),%eax
  800b09:	89 04 24             	mov    %eax,(%esp)
  800b0c:	e8 72 fe ff ff       	call   800983 <printfmt>
  800b11:	e9 ba fe ff ff       	jmp    8009d0 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b16:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800b19:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b1c:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800b1f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b22:	8d 50 04             	lea    0x4(%eax),%edx
  800b25:	89 55 14             	mov    %edx,0x14(%ebp)
  800b28:	8b 30                	mov    (%eax),%esi
  800b2a:	85 f6                	test   %esi,%esi
  800b2c:	75 05                	jne    800b33 <vprintfmt+0x188>
				p = "(null)";
  800b2e:	be ef 10 80 00       	mov    $0x8010ef,%esi
			if (width > 0 && padc != '-')
  800b33:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800b37:	0f 84 8c 00 00 00    	je     800bc9 <vprintfmt+0x21e>
  800b3d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b41:	0f 8e 8a 00 00 00    	jle    800bd1 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b47:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b4b:	89 34 24             	mov    %esi,(%esp)
  800b4e:	e8 9b f5 ff ff       	call   8000ee <strnlen>
  800b53:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800b56:	29 c1                	sub    %eax,%ecx
  800b58:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800b5b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800b5f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b62:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800b65:	8b 75 08             	mov    0x8(%ebp),%esi
  800b68:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b6b:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b6d:	eb 0d                	jmp    800b7c <vprintfmt+0x1d1>
					putch(padc, putdat);
  800b6f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b73:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b76:	89 04 24             	mov    %eax,(%esp)
  800b79:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b7b:	4b                   	dec    %ebx
  800b7c:	85 db                	test   %ebx,%ebx
  800b7e:	7f ef                	jg     800b6f <vprintfmt+0x1c4>
  800b80:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800b83:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b86:	89 c8                	mov    %ecx,%eax
  800b88:	f7 d0                	not    %eax
  800b8a:	c1 f8 1f             	sar    $0x1f,%eax
  800b8d:	21 c8                	and    %ecx,%eax
  800b8f:	29 c1                	sub    %eax,%ecx
  800b91:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b94:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800b97:	eb 3e                	jmp    800bd7 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b99:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800b9d:	74 1b                	je     800bba <vprintfmt+0x20f>
  800b9f:	0f be d2             	movsbl %dl,%edx
  800ba2:	83 ea 20             	sub    $0x20,%edx
  800ba5:	83 fa 5e             	cmp    $0x5e,%edx
  800ba8:	76 10                	jbe    800bba <vprintfmt+0x20f>
					putch('?', putdat);
  800baa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bae:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800bb5:	ff 55 08             	call   *0x8(%ebp)
  800bb8:	eb 0a                	jmp    800bc4 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800bba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bbe:	89 04 24             	mov    %eax,(%esp)
  800bc1:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bc4:	ff 4d dc             	decl   -0x24(%ebp)
  800bc7:	eb 0e                	jmp    800bd7 <vprintfmt+0x22c>
  800bc9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bcc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800bcf:	eb 06                	jmp    800bd7 <vprintfmt+0x22c>
  800bd1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bd4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800bd7:	46                   	inc    %esi
  800bd8:	8a 56 ff             	mov    -0x1(%esi),%dl
  800bdb:	0f be c2             	movsbl %dl,%eax
  800bde:	85 c0                	test   %eax,%eax
  800be0:	74 1f                	je     800c01 <vprintfmt+0x256>
  800be2:	85 db                	test   %ebx,%ebx
  800be4:	78 b3                	js     800b99 <vprintfmt+0x1ee>
  800be6:	4b                   	dec    %ebx
  800be7:	79 b0                	jns    800b99 <vprintfmt+0x1ee>
  800be9:	8b 75 08             	mov    0x8(%ebp),%esi
  800bec:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800bef:	eb 16                	jmp    800c07 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800bf1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bf5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800bfc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800bfe:	4b                   	dec    %ebx
  800bff:	eb 06                	jmp    800c07 <vprintfmt+0x25c>
  800c01:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800c04:	8b 75 08             	mov    0x8(%ebp),%esi
  800c07:	85 db                	test   %ebx,%ebx
  800c09:	7f e6                	jg     800bf1 <vprintfmt+0x246>
  800c0b:	89 75 08             	mov    %esi,0x8(%ebp)
  800c0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c11:	e9 ba fd ff ff       	jmp    8009d0 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c16:	83 fa 01             	cmp    $0x1,%edx
  800c19:	7e 16                	jle    800c31 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  800c1b:	8b 45 14             	mov    0x14(%ebp),%eax
  800c1e:	8d 50 08             	lea    0x8(%eax),%edx
  800c21:	89 55 14             	mov    %edx,0x14(%ebp)
  800c24:	8b 50 04             	mov    0x4(%eax),%edx
  800c27:	8b 00                	mov    (%eax),%eax
  800c29:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c2c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c2f:	eb 32                	jmp    800c63 <vprintfmt+0x2b8>
	else if (lflag)
  800c31:	85 d2                	test   %edx,%edx
  800c33:	74 18                	je     800c4d <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800c35:	8b 45 14             	mov    0x14(%ebp),%eax
  800c38:	8d 50 04             	lea    0x4(%eax),%edx
  800c3b:	89 55 14             	mov    %edx,0x14(%ebp)
  800c3e:	8b 30                	mov    (%eax),%esi
  800c40:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800c43:	89 f0                	mov    %esi,%eax
  800c45:	c1 f8 1f             	sar    $0x1f,%eax
  800c48:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c4b:	eb 16                	jmp    800c63 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800c4d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c50:	8d 50 04             	lea    0x4(%eax),%edx
  800c53:	89 55 14             	mov    %edx,0x14(%ebp)
  800c56:	8b 30                	mov    (%eax),%esi
  800c58:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800c5b:	89 f0                	mov    %esi,%eax
  800c5d:	c1 f8 1f             	sar    $0x1f,%eax
  800c60:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c63:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c66:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800c69:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800c6e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c72:	0f 89 80 00 00 00    	jns    800cf8 <vprintfmt+0x34d>
				putch('-', putdat);
  800c78:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c7c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800c83:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800c86:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c89:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c8c:	f7 d8                	neg    %eax
  800c8e:	83 d2 00             	adc    $0x0,%edx
  800c91:	f7 da                	neg    %edx
			}
			base = 10;
  800c93:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c98:	eb 5e                	jmp    800cf8 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800c9a:	8d 45 14             	lea    0x14(%ebp),%eax
  800c9d:	e8 8b fc ff ff       	call   80092d <getuint>
			base = 10;
  800ca2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800ca7:	eb 4f                	jmp    800cf8 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800ca9:	8d 45 14             	lea    0x14(%ebp),%eax
  800cac:	e8 7c fc ff ff       	call   80092d <getuint>
			base = 8;
  800cb1:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800cb6:	eb 40                	jmp    800cf8 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800cb8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cbc:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800cc3:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800cc6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cca:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800cd1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800cd4:	8b 45 14             	mov    0x14(%ebp),%eax
  800cd7:	8d 50 04             	lea    0x4(%eax),%edx
  800cda:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800cdd:	8b 00                	mov    (%eax),%eax
  800cdf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ce4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800ce9:	eb 0d                	jmp    800cf8 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ceb:	8d 45 14             	lea    0x14(%ebp),%eax
  800cee:	e8 3a fc ff ff       	call   80092d <getuint>
			base = 16;
  800cf3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800cf8:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800cfc:	89 74 24 10          	mov    %esi,0x10(%esp)
  800d00:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800d03:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800d07:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d0b:	89 04 24             	mov    %eax,(%esp)
  800d0e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d12:	89 fa                	mov    %edi,%edx
  800d14:	8b 45 08             	mov    0x8(%ebp),%eax
  800d17:	e8 20 fb ff ff       	call   80083c <printnum>
			break;
  800d1c:	e9 af fc ff ff       	jmp    8009d0 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d21:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d25:	89 04 24             	mov    %eax,(%esp)
  800d28:	ff 55 08             	call   *0x8(%ebp)
			break;
  800d2b:	e9 a0 fc ff ff       	jmp    8009d0 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d30:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d34:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800d3b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d3e:	89 f3                	mov    %esi,%ebx
  800d40:	eb 01                	jmp    800d43 <vprintfmt+0x398>
  800d42:	4b                   	dec    %ebx
  800d43:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800d47:	75 f9                	jne    800d42 <vprintfmt+0x397>
  800d49:	e9 82 fc ff ff       	jmp    8009d0 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800d4e:	83 c4 3c             	add    $0x3c,%esp
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	83 ec 28             	sub    $0x28,%esp
  800d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d62:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d65:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d69:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d6c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d73:	85 c0                	test   %eax,%eax
  800d75:	74 30                	je     800da7 <vsnprintf+0x51>
  800d77:	85 d2                	test   %edx,%edx
  800d79:	7e 2c                	jle    800da7 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d7b:	8b 45 14             	mov    0x14(%ebp),%eax
  800d7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d82:	8b 45 10             	mov    0x10(%ebp),%eax
  800d85:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d89:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d90:	c7 04 24 67 09 80 00 	movl   $0x800967,(%esp)
  800d97:	e8 0f fc ff ff       	call   8009ab <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d9f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800da5:	eb 05                	jmp    800dac <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800da7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800dac:	c9                   	leave  
  800dad:	c3                   	ret    

00800dae <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800db4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800db7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dbb:	8b 45 10             	mov    0x10(%ebp),%eax
  800dbe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcc:	89 04 24             	mov    %eax,(%esp)
  800dcf:	e8 82 ff ff ff       	call   800d56 <vsnprintf>
	va_end(ap);

	return rc;
}
  800dd4:	c9                   	leave  
  800dd5:	c3                   	ret    
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
