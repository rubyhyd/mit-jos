
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
  800049:	e8 e2 03 00 00       	call   800430 <sys_cputs>
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
  80007b:	e8 bb 01 00 00       	call   80023b <memset>

	thisenv = 0;
	thisenv = &envs[0];
  800080:	c7 05 04 20 80 00 00 	movl   $0xeec00000,0x802004
  800087:	00 c0 ee 
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008a:	85 db                	test   %ebx,%ebx
  80008c:	7e 07                	jle    800095 <libmain+0x45>
		binaryname = argv[0];
  80008e:	8b 06                	mov    (%esi),%eax
  800090:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800095:	89 74 24 04          	mov    %esi,0x4(%esp)
  800099:	89 1c 24             	mov    %ebx,(%esp)
  80009c:	e8 93 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a1:	e8 0a 00 00 00       	call   8000b0 <exit>
}
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	5b                   	pop    %ebx
  8000aa:	5e                   	pop    %esi
  8000ab:	5d                   	pop    %ebp
  8000ac:	c3                   	ret    
  8000ad:	66 90                	xchg   %ax,%ax
  8000af:	90                   	nop

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bd:	e8 ab 03 00 00       	call   80046d <sys_env_destroy>
}
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8000ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cf:	eb 01                	jmp    8000d2 <strlen+0xe>
		n++;
  8000d1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8000d2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8000d6:	75 f9                	jne    8000d1 <strlen+0xd>
		n++;
	return n;
}
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    

008000da <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8000e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e8:	eb 01                	jmp    8000eb <strnlen+0x11>
		n++;
  8000ea:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8000eb:	39 d0                	cmp    %edx,%eax
  8000ed:	74 06                	je     8000f5 <strnlen+0x1b>
  8000ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8000f3:	75 f5                	jne    8000ea <strnlen+0x10>
		n++;
	return n;
}
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	53                   	push   %ebx
  8000fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8000fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800101:	89 c2                	mov    %eax,%edx
  800103:	42                   	inc    %edx
  800104:	41                   	inc    %ecx
  800105:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800108:	88 5a ff             	mov    %bl,-0x1(%edx)
  80010b:	84 db                	test   %bl,%bl
  80010d:	75 f4                	jne    800103 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80010f:	5b                   	pop    %ebx
  800110:	5d                   	pop    %ebp
  800111:	c3                   	ret    

00800112 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800112:	55                   	push   %ebp
  800113:	89 e5                	mov    %esp,%ebp
  800115:	53                   	push   %ebx
  800116:	83 ec 08             	sub    $0x8,%esp
  800119:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80011c:	89 1c 24             	mov    %ebx,(%esp)
  80011f:	e8 a0 ff ff ff       	call   8000c4 <strlen>
	strcpy(dst + len, src);
  800124:	8b 55 0c             	mov    0xc(%ebp),%edx
  800127:	89 54 24 04          	mov    %edx,0x4(%esp)
  80012b:	01 d8                	add    %ebx,%eax
  80012d:	89 04 24             	mov    %eax,(%esp)
  800130:	e8 c2 ff ff ff       	call   8000f7 <strcpy>
	return dst;
}
  800135:	89 d8                	mov    %ebx,%eax
  800137:	83 c4 08             	add    $0x8,%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5d                   	pop    %ebp
  80013c:	c3                   	ret    

0080013d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	56                   	push   %esi
  800141:	53                   	push   %ebx
  800142:	8b 75 08             	mov    0x8(%ebp),%esi
  800145:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800148:	89 f3                	mov    %esi,%ebx
  80014a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80014d:	89 f2                	mov    %esi,%edx
  80014f:	eb 0c                	jmp    80015d <strncpy+0x20>
		*dst++ = *src;
  800151:	42                   	inc    %edx
  800152:	8a 01                	mov    (%ecx),%al
  800154:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800157:	80 39 01             	cmpb   $0x1,(%ecx)
  80015a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80015d:	39 da                	cmp    %ebx,%edx
  80015f:	75 f0                	jne    800151 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800161:	89 f0                	mov    %esi,%eax
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5d                   	pop    %ebp
  800166:	c3                   	ret    

00800167 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	8b 75 08             	mov    0x8(%ebp),%esi
  80016f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800172:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800175:	89 f0                	mov    %esi,%eax
  800177:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80017b:	85 c9                	test   %ecx,%ecx
  80017d:	75 07                	jne    800186 <strlcpy+0x1f>
  80017f:	eb 18                	jmp    800199 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800181:	40                   	inc    %eax
  800182:	42                   	inc    %edx
  800183:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800186:	39 d8                	cmp    %ebx,%eax
  800188:	74 0a                	je     800194 <strlcpy+0x2d>
  80018a:	8a 0a                	mov    (%edx),%cl
  80018c:	84 c9                	test   %cl,%cl
  80018e:	75 f1                	jne    800181 <strlcpy+0x1a>
  800190:	89 c2                	mov    %eax,%edx
  800192:	eb 02                	jmp    800196 <strlcpy+0x2f>
  800194:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800196:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800199:	29 f0                	sub    %esi,%eax
}
  80019b:	5b                   	pop    %ebx
  80019c:	5e                   	pop    %esi
  80019d:	5d                   	pop    %ebp
  80019e:	c3                   	ret    

0080019f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8001a8:	eb 02                	jmp    8001ac <strcmp+0xd>
		p++, q++;
  8001aa:	41                   	inc    %ecx
  8001ab:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8001ac:	8a 01                	mov    (%ecx),%al
  8001ae:	84 c0                	test   %al,%al
  8001b0:	74 04                	je     8001b6 <strcmp+0x17>
  8001b2:	3a 02                	cmp    (%edx),%al
  8001b4:	74 f4                	je     8001aa <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8001b6:	25 ff 00 00 00       	and    $0xff,%eax
  8001bb:	8a 0a                	mov    (%edx),%cl
  8001bd:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8001c3:	29 c8                	sub    %ecx,%eax
}
  8001c5:	5d                   	pop    %ebp
  8001c6:	c3                   	ret    

008001c7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	53                   	push   %ebx
  8001cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d1:	89 c3                	mov    %eax,%ebx
  8001d3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8001d6:	eb 02                	jmp    8001da <strncmp+0x13>
		n--, p++, q++;
  8001d8:	40                   	inc    %eax
  8001d9:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8001da:	39 d8                	cmp    %ebx,%eax
  8001dc:	74 20                	je     8001fe <strncmp+0x37>
  8001de:	8a 08                	mov    (%eax),%cl
  8001e0:	84 c9                	test   %cl,%cl
  8001e2:	74 04                	je     8001e8 <strncmp+0x21>
  8001e4:	3a 0a                	cmp    (%edx),%cl
  8001e6:	74 f0                	je     8001d8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8001e8:	8a 18                	mov    (%eax),%bl
  8001ea:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8001f0:	89 d8                	mov    %ebx,%eax
  8001f2:	8a 1a                	mov    (%edx),%bl
  8001f4:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8001fa:	29 d8                	sub    %ebx,%eax
  8001fc:	eb 05                	jmp    800203 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8001fe:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800203:	5b                   	pop    %ebx
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	8b 45 08             	mov    0x8(%ebp),%eax
  80020c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80020f:	eb 05                	jmp    800216 <strchr+0x10>
		if (*s == c)
  800211:	38 ca                	cmp    %cl,%dl
  800213:	74 0c                	je     800221 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800215:	40                   	inc    %eax
  800216:	8a 10                	mov    (%eax),%dl
  800218:	84 d2                	test   %dl,%dl
  80021a:	75 f5                	jne    800211 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80021c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    

00800223 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	8b 45 08             	mov    0x8(%ebp),%eax
  800229:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80022c:	eb 05                	jmp    800233 <strfind+0x10>
		if (*s == c)
  80022e:	38 ca                	cmp    %cl,%dl
  800230:	74 07                	je     800239 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800232:	40                   	inc    %eax
  800233:	8a 10                	mov    (%eax),%dl
  800235:	84 d2                	test   %dl,%dl
  800237:	75 f5                	jne    80022e <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800239:	5d                   	pop    %ebp
  80023a:	c3                   	ret    

0080023b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	57                   	push   %edi
  80023f:	56                   	push   %esi
  800240:	53                   	push   %ebx
  800241:	8b 7d 08             	mov    0x8(%ebp),%edi
  800244:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800247:	85 c9                	test   %ecx,%ecx
  800249:	74 37                	je     800282 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80024b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800251:	75 29                	jne    80027c <memset+0x41>
  800253:	f6 c1 03             	test   $0x3,%cl
  800256:	75 24                	jne    80027c <memset+0x41>
		c &= 0xFF;
  800258:	31 d2                	xor    %edx,%edx
  80025a:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80025d:	89 d3                	mov    %edx,%ebx
  80025f:	c1 e3 08             	shl    $0x8,%ebx
  800262:	89 d6                	mov    %edx,%esi
  800264:	c1 e6 18             	shl    $0x18,%esi
  800267:	89 d0                	mov    %edx,%eax
  800269:	c1 e0 10             	shl    $0x10,%eax
  80026c:	09 f0                	or     %esi,%eax
  80026e:	09 c2                	or     %eax,%edx
  800270:	89 d0                	mov    %edx,%eax
  800272:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800274:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800277:	fc                   	cld    
  800278:	f3 ab                	rep stos %eax,%es:(%edi)
  80027a:	eb 06                	jmp    800282 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80027c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027f:	fc                   	cld    
  800280:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800282:	89 f8                	mov    %edi,%eax
  800284:	5b                   	pop    %ebx
  800285:	5e                   	pop    %esi
  800286:	5f                   	pop    %edi
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	57                   	push   %edi
  80028d:	56                   	push   %esi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	8b 75 0c             	mov    0xc(%ebp),%esi
  800294:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800297:	39 c6                	cmp    %eax,%esi
  800299:	73 33                	jae    8002ce <memmove+0x45>
  80029b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80029e:	39 d0                	cmp    %edx,%eax
  8002a0:	73 2c                	jae    8002ce <memmove+0x45>
		s += n;
		d += n;
  8002a2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8002a5:	89 d6                	mov    %edx,%esi
  8002a7:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8002a9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8002af:	75 13                	jne    8002c4 <memmove+0x3b>
  8002b1:	f6 c1 03             	test   $0x3,%cl
  8002b4:	75 0e                	jne    8002c4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8002b6:	83 ef 04             	sub    $0x4,%edi
  8002b9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8002bc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8002bf:	fd                   	std    
  8002c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8002c2:	eb 07                	jmp    8002cb <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8002c4:	4f                   	dec    %edi
  8002c5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8002c8:	fd                   	std    
  8002c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8002cb:	fc                   	cld    
  8002cc:	eb 1d                	jmp    8002eb <memmove+0x62>
  8002ce:	89 f2                	mov    %esi,%edx
  8002d0:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8002d2:	f6 c2 03             	test   $0x3,%dl
  8002d5:	75 0f                	jne    8002e6 <memmove+0x5d>
  8002d7:	f6 c1 03             	test   $0x3,%cl
  8002da:	75 0a                	jne    8002e6 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8002dc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8002df:	89 c7                	mov    %eax,%edi
  8002e1:	fc                   	cld    
  8002e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8002e4:	eb 05                	jmp    8002eb <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8002e6:	89 c7                	mov    %eax,%edi
  8002e8:	fc                   	cld    
  8002e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8002eb:	5e                   	pop    %esi
  8002ec:	5f                   	pop    %edi
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8002f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800303:	8b 45 08             	mov    0x8(%ebp),%eax
  800306:	89 04 24             	mov    %eax,(%esp)
  800309:	e8 7b ff ff ff       	call   800289 <memmove>
}
  80030e:	c9                   	leave  
  80030f:	c3                   	ret    

00800310 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	56                   	push   %esi
  800314:	53                   	push   %ebx
  800315:	8b 55 08             	mov    0x8(%ebp),%edx
  800318:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031b:	89 d6                	mov    %edx,%esi
  80031d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800320:	eb 19                	jmp    80033b <memcmp+0x2b>
		if (*s1 != *s2)
  800322:	8a 02                	mov    (%edx),%al
  800324:	8a 19                	mov    (%ecx),%bl
  800326:	38 d8                	cmp    %bl,%al
  800328:	74 0f                	je     800339 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  80032a:	25 ff 00 00 00       	and    $0xff,%eax
  80032f:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800335:	29 d8                	sub    %ebx,%eax
  800337:	eb 0b                	jmp    800344 <memcmp+0x34>
		s1++, s2++;
  800339:	42                   	inc    %edx
  80033a:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80033b:	39 f2                	cmp    %esi,%edx
  80033d:	75 e3                	jne    800322 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80033f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800344:	5b                   	pop    %ebx
  800345:	5e                   	pop    %esi
  800346:	5d                   	pop    %ebp
  800347:	c3                   	ret    

00800348 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
  80034b:	8b 45 08             	mov    0x8(%ebp),%eax
  80034e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800351:	89 c2                	mov    %eax,%edx
  800353:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800356:	eb 05                	jmp    80035d <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800358:	38 08                	cmp    %cl,(%eax)
  80035a:	74 05                	je     800361 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80035c:	40                   	inc    %eax
  80035d:	39 d0                	cmp    %edx,%eax
  80035f:	72 f7                	jb     800358 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800361:	5d                   	pop    %ebp
  800362:	c3                   	ret    

00800363 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800363:	55                   	push   %ebp
  800364:	89 e5                	mov    %esp,%ebp
  800366:	57                   	push   %edi
  800367:	56                   	push   %esi
  800368:	53                   	push   %ebx
  800369:	8b 55 08             	mov    0x8(%ebp),%edx
  80036c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80036f:	eb 01                	jmp    800372 <strtol+0xf>
		s++;
  800371:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800372:	8a 02                	mov    (%edx),%al
  800374:	3c 09                	cmp    $0x9,%al
  800376:	74 f9                	je     800371 <strtol+0xe>
  800378:	3c 20                	cmp    $0x20,%al
  80037a:	74 f5                	je     800371 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80037c:	3c 2b                	cmp    $0x2b,%al
  80037e:	75 08                	jne    800388 <strtol+0x25>
		s++;
  800380:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800381:	bf 00 00 00 00       	mov    $0x0,%edi
  800386:	eb 10                	jmp    800398 <strtol+0x35>
  800388:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80038d:	3c 2d                	cmp    $0x2d,%al
  80038f:	75 07                	jne    800398 <strtol+0x35>
		s++, neg = 1;
  800391:	8d 52 01             	lea    0x1(%edx),%edx
  800394:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800398:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80039e:	75 15                	jne    8003b5 <strtol+0x52>
  8003a0:	80 3a 30             	cmpb   $0x30,(%edx)
  8003a3:	75 10                	jne    8003b5 <strtol+0x52>
  8003a5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8003a9:	75 0a                	jne    8003b5 <strtol+0x52>
		s += 2, base = 16;
  8003ab:	83 c2 02             	add    $0x2,%edx
  8003ae:	bb 10 00 00 00       	mov    $0x10,%ebx
  8003b3:	eb 0e                	jmp    8003c3 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  8003b5:	85 db                	test   %ebx,%ebx
  8003b7:	75 0a                	jne    8003c3 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8003b9:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8003bb:	80 3a 30             	cmpb   $0x30,(%edx)
  8003be:	75 03                	jne    8003c3 <strtol+0x60>
		s++, base = 8;
  8003c0:	42                   	inc    %edx
  8003c1:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  8003c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8003cb:	8a 0a                	mov    (%edx),%cl
  8003cd:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8003d0:	89 f3                	mov    %esi,%ebx
  8003d2:	80 fb 09             	cmp    $0x9,%bl
  8003d5:	77 08                	ja     8003df <strtol+0x7c>
			dig = *s - '0';
  8003d7:	0f be c9             	movsbl %cl,%ecx
  8003da:	83 e9 30             	sub    $0x30,%ecx
  8003dd:	eb 22                	jmp    800401 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  8003df:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8003e2:	89 f3                	mov    %esi,%ebx
  8003e4:	80 fb 19             	cmp    $0x19,%bl
  8003e7:	77 08                	ja     8003f1 <strtol+0x8e>
			dig = *s - 'a' + 10;
  8003e9:	0f be c9             	movsbl %cl,%ecx
  8003ec:	83 e9 57             	sub    $0x57,%ecx
  8003ef:	eb 10                	jmp    800401 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  8003f1:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8003f4:	89 f3                	mov    %esi,%ebx
  8003f6:	80 fb 19             	cmp    $0x19,%bl
  8003f9:	77 14                	ja     80040f <strtol+0xac>
			dig = *s - 'A' + 10;
  8003fb:	0f be c9             	movsbl %cl,%ecx
  8003fe:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800401:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800404:	7d 0d                	jge    800413 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800406:	42                   	inc    %edx
  800407:	0f af 45 10          	imul   0x10(%ebp),%eax
  80040b:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80040d:	eb bc                	jmp    8003cb <strtol+0x68>
  80040f:	89 c1                	mov    %eax,%ecx
  800411:	eb 02                	jmp    800415 <strtol+0xb2>
  800413:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800415:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800419:	74 05                	je     800420 <strtol+0xbd>
		*endptr = (char *) s;
  80041b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80041e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800420:	85 ff                	test   %edi,%edi
  800422:	74 04                	je     800428 <strtol+0xc5>
  800424:	89 c8                	mov    %ecx,%eax
  800426:	f7 d8                	neg    %eax
}
  800428:	5b                   	pop    %ebx
  800429:	5e                   	pop    %esi
  80042a:	5f                   	pop    %edi
  80042b:	5d                   	pop    %ebp
  80042c:	c3                   	ret    
  80042d:	66 90                	xchg   %ax,%ax
  80042f:	90                   	nop

00800430 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	57                   	push   %edi
  800434:	56                   	push   %esi
  800435:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800436:	b8 00 00 00 00       	mov    $0x0,%eax
  80043b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043e:	8b 55 08             	mov    0x8(%ebp),%edx
  800441:	89 c3                	mov    %eax,%ebx
  800443:	89 c7                	mov    %eax,%edi
  800445:	89 c6                	mov    %eax,%esi
  800447:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800449:	5b                   	pop    %ebx
  80044a:	5e                   	pop    %esi
  80044b:	5f                   	pop    %edi
  80044c:	5d                   	pop    %ebp
  80044d:	c3                   	ret    

0080044e <sys_cgetc>:

int
sys_cgetc(void)
{
  80044e:	55                   	push   %ebp
  80044f:	89 e5                	mov    %esp,%ebp
  800451:	57                   	push   %edi
  800452:	56                   	push   %esi
  800453:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800454:	ba 00 00 00 00       	mov    $0x0,%edx
  800459:	b8 01 00 00 00       	mov    $0x1,%eax
  80045e:	89 d1                	mov    %edx,%ecx
  800460:	89 d3                	mov    %edx,%ebx
  800462:	89 d7                	mov    %edx,%edi
  800464:	89 d6                	mov    %edx,%esi
  800466:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800468:	5b                   	pop    %ebx
  800469:	5e                   	pop    %esi
  80046a:	5f                   	pop    %edi
  80046b:	5d                   	pop    %ebp
  80046c:	c3                   	ret    

0080046d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80046d:	55                   	push   %ebp
  80046e:	89 e5                	mov    %esp,%ebp
  800470:	57                   	push   %edi
  800471:	56                   	push   %esi
  800472:	53                   	push   %ebx
  800473:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800476:	b9 00 00 00 00       	mov    $0x0,%ecx
  80047b:	b8 03 00 00 00       	mov    $0x3,%eax
  800480:	8b 55 08             	mov    0x8(%ebp),%edx
  800483:	89 cb                	mov    %ecx,%ebx
  800485:	89 cf                	mov    %ecx,%edi
  800487:	89 ce                	mov    %ecx,%esi
  800489:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80048b:	85 c0                	test   %eax,%eax
  80048d:	7e 28                	jle    8004b7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80048f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800493:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80049a:	00 
  80049b:	c7 44 24 08 4a 0e 80 	movl   $0x800e4a,0x8(%esp)
  8004a2:	00 
  8004a3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004aa:	00 
  8004ab:	c7 04 24 67 0e 80 00 	movl   $0x800e67,(%esp)
  8004b2:	e8 29 00 00 00       	call   8004e0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8004b7:	83 c4 2c             	add    $0x2c,%esp
  8004ba:	5b                   	pop    %ebx
  8004bb:	5e                   	pop    %esi
  8004bc:	5f                   	pop    %edi
  8004bd:	5d                   	pop    %ebp
  8004be:	c3                   	ret    

008004bf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8004bf:	55                   	push   %ebp
  8004c0:	89 e5                	mov    %esp,%ebp
  8004c2:	57                   	push   %edi
  8004c3:	56                   	push   %esi
  8004c4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ca:	b8 02 00 00 00       	mov    $0x2,%eax
  8004cf:	89 d1                	mov    %edx,%ecx
  8004d1:	89 d3                	mov    %edx,%ebx
  8004d3:	89 d7                	mov    %edx,%edi
  8004d5:	89 d6                	mov    %edx,%esi
  8004d7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8004d9:	5b                   	pop    %ebx
  8004da:	5e                   	pop    %esi
  8004db:	5f                   	pop    %edi
  8004dc:	5d                   	pop    %ebp
  8004dd:	c3                   	ret    
  8004de:	66 90                	xchg   %ax,%ax

008004e0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	56                   	push   %esi
  8004e4:	53                   	push   %ebx
  8004e5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8004e8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004eb:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8004f1:	e8 c9 ff ff ff       	call   8004bf <sys_getenvid>
  8004f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800500:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800504:	89 74 24 08          	mov    %esi,0x8(%esp)
  800508:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050c:	c7 04 24 78 0e 80 00 	movl   $0x800e78,(%esp)
  800513:	e8 c2 00 00 00       	call   8005da <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800518:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051c:	8b 45 10             	mov    0x10(%ebp),%eax
  80051f:	89 04 24             	mov    %eax,(%esp)
  800522:	e8 52 00 00 00       	call   800579 <vcprintf>
	cprintf("\n");
  800527:	c7 04 24 9c 0e 80 00 	movl   $0x800e9c,(%esp)
  80052e:	e8 a7 00 00 00       	call   8005da <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800533:	cc                   	int3   
  800534:	eb fd                	jmp    800533 <_panic+0x53>
  800536:	66 90                	xchg   %ax,%ax

00800538 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800538:	55                   	push   %ebp
  800539:	89 e5                	mov    %esp,%ebp
  80053b:	53                   	push   %ebx
  80053c:	83 ec 14             	sub    $0x14,%esp
  80053f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800542:	8b 13                	mov    (%ebx),%edx
  800544:	8d 42 01             	lea    0x1(%edx),%eax
  800547:	89 03                	mov    %eax,(%ebx)
  800549:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80054c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800550:	3d ff 00 00 00       	cmp    $0xff,%eax
  800555:	75 19                	jne    800570 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800557:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80055e:	00 
  80055f:	8d 43 08             	lea    0x8(%ebx),%eax
  800562:	89 04 24             	mov    %eax,(%esp)
  800565:	e8 c6 fe ff ff       	call   800430 <sys_cputs>
		b->idx = 0;
  80056a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800570:	ff 43 04             	incl   0x4(%ebx)
}
  800573:	83 c4 14             	add    $0x14,%esp
  800576:	5b                   	pop    %ebx
  800577:	5d                   	pop    %ebp
  800578:	c3                   	ret    

00800579 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800579:	55                   	push   %ebp
  80057a:	89 e5                	mov    %esp,%ebp
  80057c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800582:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800589:	00 00 00 
	b.cnt = 0;
  80058c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800593:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800596:	8b 45 0c             	mov    0xc(%ebp),%eax
  800599:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80059d:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005a4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ae:	c7 04 24 38 05 80 00 	movl   $0x800538,(%esp)
  8005b5:	e8 a9 01 00 00       	call   800763 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005ba:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8005c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005ca:	89 04 24             	mov    %eax,(%esp)
  8005cd:	e8 5e fe ff ff       	call   800430 <sys_cputs>

	return b.cnt;
}
  8005d2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005d8:	c9                   	leave  
  8005d9:	c3                   	ret    

008005da <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005da:	55                   	push   %ebp
  8005db:	89 e5                	mov    %esp,%ebp
  8005dd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005e0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ea:	89 04 24             	mov    %eax,(%esp)
  8005ed:	e8 87 ff ff ff       	call   800579 <vcprintf>
	va_end(ap);

	return cnt;
}
  8005f2:	c9                   	leave  
  8005f3:	c3                   	ret    

008005f4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005f4:	55                   	push   %ebp
  8005f5:	89 e5                	mov    %esp,%ebp
  8005f7:	57                   	push   %edi
  8005f8:	56                   	push   %esi
  8005f9:	53                   	push   %ebx
  8005fa:	83 ec 3c             	sub    $0x3c,%esp
  8005fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800600:	89 d7                	mov    %edx,%edi
  800602:	8b 45 08             	mov    0x8(%ebp),%eax
  800605:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800608:	8b 45 0c             	mov    0xc(%ebp),%eax
  80060b:	89 c1                	mov    %eax,%ecx
  80060d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800610:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800613:	8b 45 10             	mov    0x10(%ebp),%eax
  800616:	ba 00 00 00 00       	mov    $0x0,%edx
  80061b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800621:	39 ca                	cmp    %ecx,%edx
  800623:	72 08                	jb     80062d <printnum+0x39>
  800625:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800628:	39 45 10             	cmp    %eax,0x10(%ebp)
  80062b:	77 6a                	ja     800697 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80062d:	8b 45 18             	mov    0x18(%ebp),%eax
  800630:	89 44 24 10          	mov    %eax,0x10(%esp)
  800634:	4e                   	dec    %esi
  800635:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800639:	8b 45 10             	mov    0x10(%ebp),%eax
  80063c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800640:	8b 44 24 08          	mov    0x8(%esp),%eax
  800644:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800648:	89 c3                	mov    %eax,%ebx
  80064a:	89 d6                	mov    %edx,%esi
  80064c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80064f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800652:	89 44 24 08          	mov    %eax,0x8(%esp)
  800656:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80065a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80065d:	89 04 24             	mov    %eax,(%esp)
  800660:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800663:	89 44 24 04          	mov    %eax,0x4(%esp)
  800667:	e8 24 05 00 00       	call   800b90 <__udivdi3>
  80066c:	89 d9                	mov    %ebx,%ecx
  80066e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800672:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800676:	89 04 24             	mov    %eax,(%esp)
  800679:	89 54 24 04          	mov    %edx,0x4(%esp)
  80067d:	89 fa                	mov    %edi,%edx
  80067f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800682:	e8 6d ff ff ff       	call   8005f4 <printnum>
  800687:	eb 19                	jmp    8006a2 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800689:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80068d:	8b 45 18             	mov    0x18(%ebp),%eax
  800690:	89 04 24             	mov    %eax,(%esp)
  800693:	ff d3                	call   *%ebx
  800695:	eb 03                	jmp    80069a <printnum+0xa6>
  800697:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80069a:	4e                   	dec    %esi
  80069b:	85 f6                	test   %esi,%esi
  80069d:	7f ea                	jg     800689 <printnum+0x95>
  80069f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8006aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006ad:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006bb:	89 04 24             	mov    %eax,(%esp)
  8006be:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c5:	e8 f6 05 00 00       	call   800cc0 <__umoddi3>
  8006ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ce:	0f be 80 9e 0e 80 00 	movsbl 0x800e9e(%eax),%eax
  8006d5:	89 04 24             	mov    %eax,(%esp)
  8006d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006db:	ff d0                	call   *%eax
}
  8006dd:	83 c4 3c             	add    $0x3c,%esp
  8006e0:	5b                   	pop    %ebx
  8006e1:	5e                   	pop    %esi
  8006e2:	5f                   	pop    %edi
  8006e3:	5d                   	pop    %ebp
  8006e4:	c3                   	ret    

008006e5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006e5:	55                   	push   %ebp
  8006e6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006e8:	83 fa 01             	cmp    $0x1,%edx
  8006eb:	7e 0e                	jle    8006fb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8006ed:	8b 10                	mov    (%eax),%edx
  8006ef:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006f2:	89 08                	mov    %ecx,(%eax)
  8006f4:	8b 02                	mov    (%edx),%eax
  8006f6:	8b 52 04             	mov    0x4(%edx),%edx
  8006f9:	eb 22                	jmp    80071d <getuint+0x38>
	else if (lflag)
  8006fb:	85 d2                	test   %edx,%edx
  8006fd:	74 10                	je     80070f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006ff:	8b 10                	mov    (%eax),%edx
  800701:	8d 4a 04             	lea    0x4(%edx),%ecx
  800704:	89 08                	mov    %ecx,(%eax)
  800706:	8b 02                	mov    (%edx),%eax
  800708:	ba 00 00 00 00       	mov    $0x0,%edx
  80070d:	eb 0e                	jmp    80071d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80070f:	8b 10                	mov    (%eax),%edx
  800711:	8d 4a 04             	lea    0x4(%edx),%ecx
  800714:	89 08                	mov    %ecx,(%eax)
  800716:	8b 02                	mov    (%edx),%eax
  800718:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80071d:	5d                   	pop    %ebp
  80071e:	c3                   	ret    

0080071f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800725:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800728:	8b 10                	mov    (%eax),%edx
  80072a:	3b 50 04             	cmp    0x4(%eax),%edx
  80072d:	73 0a                	jae    800739 <sprintputch+0x1a>
		*b->buf++ = ch;
  80072f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800732:	89 08                	mov    %ecx,(%eax)
  800734:	8b 45 08             	mov    0x8(%ebp),%eax
  800737:	88 02                	mov    %al,(%edx)
}
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800741:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800744:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800748:	8b 45 10             	mov    0x10(%ebp),%eax
  80074b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80074f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800752:	89 44 24 04          	mov    %eax,0x4(%esp)
  800756:	8b 45 08             	mov    0x8(%ebp),%eax
  800759:	89 04 24             	mov    %eax,(%esp)
  80075c:	e8 02 00 00 00       	call   800763 <vprintfmt>
	va_end(ap);
}
  800761:	c9                   	leave  
  800762:	c3                   	ret    

00800763 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	57                   	push   %edi
  800767:	56                   	push   %esi
  800768:	53                   	push   %ebx
  800769:	83 ec 3c             	sub    $0x3c,%esp
  80076c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80076f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800772:	eb 14                	jmp    800788 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800774:	85 c0                	test   %eax,%eax
  800776:	0f 84 8a 03 00 00    	je     800b06 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  80077c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800780:	89 04 24             	mov    %eax,(%esp)
  800783:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800786:	89 f3                	mov    %esi,%ebx
  800788:	8d 73 01             	lea    0x1(%ebx),%esi
  80078b:	31 c0                	xor    %eax,%eax
  80078d:	8a 03                	mov    (%ebx),%al
  80078f:	83 f8 25             	cmp    $0x25,%eax
  800792:	75 e0                	jne    800774 <vprintfmt+0x11>
  800794:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800798:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80079f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007a6:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8007ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b2:	eb 1d                	jmp    8007d1 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b4:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8007b6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8007ba:	eb 15                	jmp    8007d1 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bc:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007be:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8007c2:	eb 0d                	jmp    8007d1 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8007c4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007c7:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8007ca:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d1:	8d 5e 01             	lea    0x1(%esi),%ebx
  8007d4:	31 c0                	xor    %eax,%eax
  8007d6:	8a 06                	mov    (%esi),%al
  8007d8:	8a 0e                	mov    (%esi),%cl
  8007da:	83 e9 23             	sub    $0x23,%ecx
  8007dd:	88 4d e0             	mov    %cl,-0x20(%ebp)
  8007e0:	80 f9 55             	cmp    $0x55,%cl
  8007e3:	0f 87 ff 02 00 00    	ja     800ae8 <vprintfmt+0x385>
  8007e9:	31 c9                	xor    %ecx,%ecx
  8007eb:	8a 4d e0             	mov    -0x20(%ebp),%cl
  8007ee:	ff 24 8d 40 0f 80 00 	jmp    *0x800f40(,%ecx,4)
  8007f5:	89 de                	mov    %ebx,%esi
  8007f7:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8007fc:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8007ff:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800803:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800806:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800809:	83 fb 09             	cmp    $0x9,%ebx
  80080c:	77 2f                	ja     80083d <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80080e:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80080f:	eb eb                	jmp    8007fc <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800811:	8b 45 14             	mov    0x14(%ebp),%eax
  800814:	8d 48 04             	lea    0x4(%eax),%ecx
  800817:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80081a:	8b 00                	mov    (%eax),%eax
  80081c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800821:	eb 1d                	jmp    800840 <vprintfmt+0xdd>
  800823:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800826:	f7 d0                	not    %eax
  800828:	c1 f8 1f             	sar    $0x1f,%eax
  80082b:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082e:	89 de                	mov    %ebx,%esi
  800830:	eb 9f                	jmp    8007d1 <vprintfmt+0x6e>
  800832:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800834:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80083b:	eb 94                	jmp    8007d1 <vprintfmt+0x6e>
  80083d:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800840:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800844:	79 8b                	jns    8007d1 <vprintfmt+0x6e>
  800846:	e9 79 ff ff ff       	jmp    8007c4 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80084b:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084c:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80084e:	eb 81                	jmp    8007d1 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800850:	8b 45 14             	mov    0x14(%ebp),%eax
  800853:	8d 50 04             	lea    0x4(%eax),%edx
  800856:	89 55 14             	mov    %edx,0x14(%ebp)
  800859:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80085d:	8b 00                	mov    (%eax),%eax
  80085f:	89 04 24             	mov    %eax,(%esp)
  800862:	ff 55 08             	call   *0x8(%ebp)
			break;
  800865:	e9 1e ff ff ff       	jmp    800788 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80086a:	8b 45 14             	mov    0x14(%ebp),%eax
  80086d:	8d 50 04             	lea    0x4(%eax),%edx
  800870:	89 55 14             	mov    %edx,0x14(%ebp)
  800873:	8b 00                	mov    (%eax),%eax
  800875:	89 c2                	mov    %eax,%edx
  800877:	c1 fa 1f             	sar    $0x1f,%edx
  80087a:	31 d0                	xor    %edx,%eax
  80087c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80087e:	83 f8 07             	cmp    $0x7,%eax
  800881:	7f 0b                	jg     80088e <vprintfmt+0x12b>
  800883:	8b 14 85 a0 10 80 00 	mov    0x8010a0(,%eax,4),%edx
  80088a:	85 d2                	test   %edx,%edx
  80088c:	75 20                	jne    8008ae <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  80088e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800892:	c7 44 24 08 b6 0e 80 	movl   $0x800eb6,0x8(%esp)
  800899:	00 
  80089a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	89 04 24             	mov    %eax,(%esp)
  8008a4:	e8 92 fe ff ff       	call   80073b <printfmt>
  8008a9:	e9 da fe ff ff       	jmp    800788 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8008ae:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008b2:	c7 44 24 08 bf 0e 80 	movl   $0x800ebf,0x8(%esp)
  8008b9:	00 
  8008ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	89 04 24             	mov    %eax,(%esp)
  8008c4:	e8 72 fe ff ff       	call   80073b <printfmt>
  8008c9:	e9 ba fe ff ff       	jmp    800788 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ce:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8008d1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8008d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008da:	8d 50 04             	lea    0x4(%eax),%edx
  8008dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e0:	8b 30                	mov    (%eax),%esi
  8008e2:	85 f6                	test   %esi,%esi
  8008e4:	75 05                	jne    8008eb <vprintfmt+0x188>
				p = "(null)";
  8008e6:	be af 0e 80 00       	mov    $0x800eaf,%esi
			if (width > 0 && padc != '-')
  8008eb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8008ef:	0f 84 8c 00 00 00    	je     800981 <vprintfmt+0x21e>
  8008f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008f9:	0f 8e 8a 00 00 00    	jle    800989 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008ff:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800903:	89 34 24             	mov    %esi,(%esp)
  800906:	e8 cf f7 ff ff       	call   8000da <strnlen>
  80090b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80090e:	29 c1                	sub    %eax,%ecx
  800910:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800913:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800917:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80091a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  80091d:	8b 75 08             	mov    0x8(%ebp),%esi
  800920:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800923:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800925:	eb 0d                	jmp    800934 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800927:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80092b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80092e:	89 04 24             	mov    %eax,(%esp)
  800931:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800933:	4b                   	dec    %ebx
  800934:	85 db                	test   %ebx,%ebx
  800936:	7f ef                	jg     800927 <vprintfmt+0x1c4>
  800938:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80093b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80093e:	89 c8                	mov    %ecx,%eax
  800940:	f7 d0                	not    %eax
  800942:	c1 f8 1f             	sar    $0x1f,%eax
  800945:	21 c8                	and    %ecx,%eax
  800947:	29 c1                	sub    %eax,%ecx
  800949:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80094c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80094f:	eb 3e                	jmp    80098f <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800951:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800955:	74 1b                	je     800972 <vprintfmt+0x20f>
  800957:	0f be d2             	movsbl %dl,%edx
  80095a:	83 ea 20             	sub    $0x20,%edx
  80095d:	83 fa 5e             	cmp    $0x5e,%edx
  800960:	76 10                	jbe    800972 <vprintfmt+0x20f>
					putch('?', putdat);
  800962:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800966:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80096d:	ff 55 08             	call   *0x8(%ebp)
  800970:	eb 0a                	jmp    80097c <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800972:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800976:	89 04 24             	mov    %eax,(%esp)
  800979:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80097c:	ff 4d dc             	decl   -0x24(%ebp)
  80097f:	eb 0e                	jmp    80098f <vprintfmt+0x22c>
  800981:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800984:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800987:	eb 06                	jmp    80098f <vprintfmt+0x22c>
  800989:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80098c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80098f:	46                   	inc    %esi
  800990:	8a 56 ff             	mov    -0x1(%esi),%dl
  800993:	0f be c2             	movsbl %dl,%eax
  800996:	85 c0                	test   %eax,%eax
  800998:	74 1f                	je     8009b9 <vprintfmt+0x256>
  80099a:	85 db                	test   %ebx,%ebx
  80099c:	78 b3                	js     800951 <vprintfmt+0x1ee>
  80099e:	4b                   	dec    %ebx
  80099f:	79 b0                	jns    800951 <vprintfmt+0x1ee>
  8009a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a4:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8009a7:	eb 16                	jmp    8009bf <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8009a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009ad:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009b4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009b6:	4b                   	dec    %ebx
  8009b7:	eb 06                	jmp    8009bf <vprintfmt+0x25c>
  8009b9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8009bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8009bf:	85 db                	test   %ebx,%ebx
  8009c1:	7f e6                	jg     8009a9 <vprintfmt+0x246>
  8009c3:	89 75 08             	mov    %esi,0x8(%ebp)
  8009c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009c9:	e9 ba fd ff ff       	jmp    800788 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009ce:	83 fa 01             	cmp    $0x1,%edx
  8009d1:	7e 16                	jle    8009e9 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  8009d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d6:	8d 50 08             	lea    0x8(%eax),%edx
  8009d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8009dc:	8b 50 04             	mov    0x4(%eax),%edx
  8009df:	8b 00                	mov    (%eax),%eax
  8009e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009e4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009e7:	eb 32                	jmp    800a1b <vprintfmt+0x2b8>
	else if (lflag)
  8009e9:	85 d2                	test   %edx,%edx
  8009eb:	74 18                	je     800a05 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  8009ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f0:	8d 50 04             	lea    0x4(%eax),%edx
  8009f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8009f6:	8b 30                	mov    (%eax),%esi
  8009f8:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8009fb:	89 f0                	mov    %esi,%eax
  8009fd:	c1 f8 1f             	sar    $0x1f,%eax
  800a00:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a03:	eb 16                	jmp    800a1b <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800a05:	8b 45 14             	mov    0x14(%ebp),%eax
  800a08:	8d 50 04             	lea    0x4(%eax),%edx
  800a0b:	89 55 14             	mov    %edx,0x14(%ebp)
  800a0e:	8b 30                	mov    (%eax),%esi
  800a10:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800a13:	89 f0                	mov    %esi,%eax
  800a15:	c1 f8 1f             	sar    $0x1f,%eax
  800a18:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a1e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a21:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a2a:	0f 89 80 00 00 00    	jns    800ab0 <vprintfmt+0x34d>
				putch('-', putdat);
  800a30:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a34:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a3b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a41:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a44:	f7 d8                	neg    %eax
  800a46:	83 d2 00             	adc    $0x0,%edx
  800a49:	f7 da                	neg    %edx
			}
			base = 10;
  800a4b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a50:	eb 5e                	jmp    800ab0 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a52:	8d 45 14             	lea    0x14(%ebp),%eax
  800a55:	e8 8b fc ff ff       	call   8006e5 <getuint>
			base = 10;
  800a5a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a5f:	eb 4f                	jmp    800ab0 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800a61:	8d 45 14             	lea    0x14(%ebp),%eax
  800a64:	e8 7c fc ff ff       	call   8006e5 <getuint>
			base = 8;
  800a69:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800a6e:	eb 40                	jmp    800ab0 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800a70:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a74:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a7b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a7e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a82:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a89:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a8c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8f:	8d 50 04             	lea    0x4(%eax),%edx
  800a92:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a95:	8b 00                	mov    (%eax),%eax
  800a97:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a9c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800aa1:	eb 0d                	jmp    800ab0 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800aa3:	8d 45 14             	lea    0x14(%ebp),%eax
  800aa6:	e8 3a fc ff ff       	call   8006e5 <getuint>
			base = 16;
  800aab:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ab0:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800ab4:	89 74 24 10          	mov    %esi,0x10(%esp)
  800ab8:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800abb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800abf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ac3:	89 04 24             	mov    %eax,(%esp)
  800ac6:	89 54 24 04          	mov    %edx,0x4(%esp)
  800aca:	89 fa                	mov    %edi,%edx
  800acc:	8b 45 08             	mov    0x8(%ebp),%eax
  800acf:	e8 20 fb ff ff       	call   8005f4 <printnum>
			break;
  800ad4:	e9 af fc ff ff       	jmp    800788 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ad9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800add:	89 04 24             	mov    %eax,(%esp)
  800ae0:	ff 55 08             	call   *0x8(%ebp)
			break;
  800ae3:	e9 a0 fc ff ff       	jmp    800788 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ae8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aec:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800af3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800af6:	89 f3                	mov    %esi,%ebx
  800af8:	eb 01                	jmp    800afb <vprintfmt+0x398>
  800afa:	4b                   	dec    %ebx
  800afb:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800aff:	75 f9                	jne    800afa <vprintfmt+0x397>
  800b01:	e9 82 fc ff ff       	jmp    800788 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800b06:	83 c4 3c             	add    $0x3c,%esp
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	83 ec 28             	sub    $0x28,%esp
  800b14:	8b 45 08             	mov    0x8(%ebp),%eax
  800b17:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b1d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b21:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b24:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b2b:	85 c0                	test   %eax,%eax
  800b2d:	74 30                	je     800b5f <vsnprintf+0x51>
  800b2f:	85 d2                	test   %edx,%edx
  800b31:	7e 2c                	jle    800b5f <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b33:	8b 45 14             	mov    0x14(%ebp),%eax
  800b36:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b3a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b3d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b41:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b44:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b48:	c7 04 24 1f 07 80 00 	movl   $0x80071f,(%esp)
  800b4f:	e8 0f fc ff ff       	call   800763 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b54:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b57:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b5d:	eb 05                	jmp    800b64 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b5f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b64:	c9                   	leave  
  800b65:	c3                   	ret    

00800b66 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b6c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b73:	8b 45 10             	mov    0x10(%ebp),%eax
  800b76:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b81:	8b 45 08             	mov    0x8(%ebp),%eax
  800b84:	89 04 24             	mov    %eax,(%esp)
  800b87:	e8 82 ff ff ff       	call   800b0e <vsnprintf>
	va_end(ap);

	return rc;
}
  800b8c:	c9                   	leave  
  800b8d:	c3                   	ret    
  800b8e:	66 90                	xchg   %ax,%ax

00800b90 <__udivdi3>:
  800b90:	55                   	push   %ebp
  800b91:	57                   	push   %edi
  800b92:	56                   	push   %esi
  800b93:	83 ec 0c             	sub    $0xc,%esp
  800b96:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800b9a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800b9e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800ba2:	8b 44 24 28          	mov    0x28(%esp),%eax
  800ba6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800baa:	89 ea                	mov    %ebp,%edx
  800bac:	89 0c 24             	mov    %ecx,(%esp)
  800baf:	85 c0                	test   %eax,%eax
  800bb1:	75 2d                	jne    800be0 <__udivdi3+0x50>
  800bb3:	39 e9                	cmp    %ebp,%ecx
  800bb5:	77 61                	ja     800c18 <__udivdi3+0x88>
  800bb7:	89 ce                	mov    %ecx,%esi
  800bb9:	85 c9                	test   %ecx,%ecx
  800bbb:	75 0b                	jne    800bc8 <__udivdi3+0x38>
  800bbd:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc2:	31 d2                	xor    %edx,%edx
  800bc4:	f7 f1                	div    %ecx
  800bc6:	89 c6                	mov    %eax,%esi
  800bc8:	31 d2                	xor    %edx,%edx
  800bca:	89 e8                	mov    %ebp,%eax
  800bcc:	f7 f6                	div    %esi
  800bce:	89 c5                	mov    %eax,%ebp
  800bd0:	89 f8                	mov    %edi,%eax
  800bd2:	f7 f6                	div    %esi
  800bd4:	89 ea                	mov    %ebp,%edx
  800bd6:	83 c4 0c             	add    $0xc,%esp
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    
  800bdd:	8d 76 00             	lea    0x0(%esi),%esi
  800be0:	39 e8                	cmp    %ebp,%eax
  800be2:	77 24                	ja     800c08 <__udivdi3+0x78>
  800be4:	0f bd e8             	bsr    %eax,%ebp
  800be7:	83 f5 1f             	xor    $0x1f,%ebp
  800bea:	75 3c                	jne    800c28 <__udivdi3+0x98>
  800bec:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bf0:	39 34 24             	cmp    %esi,(%esp)
  800bf3:	0f 86 9f 00 00 00    	jbe    800c98 <__udivdi3+0x108>
  800bf9:	39 d0                	cmp    %edx,%eax
  800bfb:	0f 82 97 00 00 00    	jb     800c98 <__udivdi3+0x108>
  800c01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c08:	31 d2                	xor    %edx,%edx
  800c0a:	31 c0                	xor    %eax,%eax
  800c0c:	83 c4 0c             	add    $0xc,%esp
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    
  800c13:	90                   	nop
  800c14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c18:	89 f8                	mov    %edi,%eax
  800c1a:	f7 f1                	div    %ecx
  800c1c:	31 d2                	xor    %edx,%edx
  800c1e:	83 c4 0c             	add    $0xc,%esp
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    
  800c25:	8d 76 00             	lea    0x0(%esi),%esi
  800c28:	89 e9                	mov    %ebp,%ecx
  800c2a:	8b 3c 24             	mov    (%esp),%edi
  800c2d:	d3 e0                	shl    %cl,%eax
  800c2f:	89 c6                	mov    %eax,%esi
  800c31:	b8 20 00 00 00       	mov    $0x20,%eax
  800c36:	29 e8                	sub    %ebp,%eax
  800c38:	88 c1                	mov    %al,%cl
  800c3a:	d3 ef                	shr    %cl,%edi
  800c3c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c40:	89 e9                	mov    %ebp,%ecx
  800c42:	8b 3c 24             	mov    (%esp),%edi
  800c45:	09 74 24 08          	or     %esi,0x8(%esp)
  800c49:	d3 e7                	shl    %cl,%edi
  800c4b:	89 d6                	mov    %edx,%esi
  800c4d:	88 c1                	mov    %al,%cl
  800c4f:	d3 ee                	shr    %cl,%esi
  800c51:	89 e9                	mov    %ebp,%ecx
  800c53:	89 3c 24             	mov    %edi,(%esp)
  800c56:	d3 e2                	shl    %cl,%edx
  800c58:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c5c:	88 c1                	mov    %al,%cl
  800c5e:	d3 ef                	shr    %cl,%edi
  800c60:	09 d7                	or     %edx,%edi
  800c62:	89 f2                	mov    %esi,%edx
  800c64:	89 f8                	mov    %edi,%eax
  800c66:	f7 74 24 08          	divl   0x8(%esp)
  800c6a:	89 d6                	mov    %edx,%esi
  800c6c:	89 c7                	mov    %eax,%edi
  800c6e:	f7 24 24             	mull   (%esp)
  800c71:	89 14 24             	mov    %edx,(%esp)
  800c74:	39 d6                	cmp    %edx,%esi
  800c76:	72 30                	jb     800ca8 <__udivdi3+0x118>
  800c78:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c7c:	89 e9                	mov    %ebp,%ecx
  800c7e:	d3 e2                	shl    %cl,%edx
  800c80:	39 c2                	cmp    %eax,%edx
  800c82:	73 05                	jae    800c89 <__udivdi3+0xf9>
  800c84:	3b 34 24             	cmp    (%esp),%esi
  800c87:	74 1f                	je     800ca8 <__udivdi3+0x118>
  800c89:	89 f8                	mov    %edi,%eax
  800c8b:	31 d2                	xor    %edx,%edx
  800c8d:	e9 7a ff ff ff       	jmp    800c0c <__udivdi3+0x7c>
  800c92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c98:	31 d2                	xor    %edx,%edx
  800c9a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c9f:	e9 68 ff ff ff       	jmp    800c0c <__udivdi3+0x7c>
  800ca4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ca8:	8d 47 ff             	lea    -0x1(%edi),%eax
  800cab:	31 d2                	xor    %edx,%edx
  800cad:	83 c4 0c             	add    $0xc,%esp
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    
  800cb4:	66 90                	xchg   %ax,%ax
  800cb6:	66 90                	xchg   %ax,%ax
  800cb8:	66 90                	xchg   %ax,%ax
  800cba:	66 90                	xchg   %ax,%ax
  800cbc:	66 90                	xchg   %ax,%ax
  800cbe:	66 90                	xchg   %ax,%ax

00800cc0 <__umoddi3>:
  800cc0:	55                   	push   %ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	83 ec 14             	sub    $0x14,%esp
  800cc6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800cca:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800cce:	89 c7                	mov    %eax,%edi
  800cd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800cd8:	8b 44 24 30          	mov    0x30(%esp),%eax
  800cdc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800ce0:	89 34 24             	mov    %esi,(%esp)
  800ce3:	89 c2                	mov    %eax,%edx
  800ce5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ce9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800ced:	85 c0                	test   %eax,%eax
  800cef:	75 17                	jne    800d08 <__umoddi3+0x48>
  800cf1:	39 fe                	cmp    %edi,%esi
  800cf3:	76 4b                	jbe    800d40 <__umoddi3+0x80>
  800cf5:	89 c8                	mov    %ecx,%eax
  800cf7:	89 fa                	mov    %edi,%edx
  800cf9:	f7 f6                	div    %esi
  800cfb:	89 d0                	mov    %edx,%eax
  800cfd:	31 d2                	xor    %edx,%edx
  800cff:	83 c4 14             	add    $0x14,%esp
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    
  800d06:	66 90                	xchg   %ax,%ax
  800d08:	39 f8                	cmp    %edi,%eax
  800d0a:	77 54                	ja     800d60 <__umoddi3+0xa0>
  800d0c:	0f bd e8             	bsr    %eax,%ebp
  800d0f:	83 f5 1f             	xor    $0x1f,%ebp
  800d12:	75 5c                	jne    800d70 <__umoddi3+0xb0>
  800d14:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d18:	39 3c 24             	cmp    %edi,(%esp)
  800d1b:	0f 87 f7 00 00 00    	ja     800e18 <__umoddi3+0x158>
  800d21:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d25:	29 f1                	sub    %esi,%ecx
  800d27:	19 c7                	sbb    %eax,%edi
  800d29:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d2d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d31:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d35:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d39:	83 c4 14             	add    $0x14,%esp
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    
  800d40:	89 f5                	mov    %esi,%ebp
  800d42:	85 f6                	test   %esi,%esi
  800d44:	75 0b                	jne    800d51 <__umoddi3+0x91>
  800d46:	b8 01 00 00 00       	mov    $0x1,%eax
  800d4b:	31 d2                	xor    %edx,%edx
  800d4d:	f7 f6                	div    %esi
  800d4f:	89 c5                	mov    %eax,%ebp
  800d51:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d55:	31 d2                	xor    %edx,%edx
  800d57:	f7 f5                	div    %ebp
  800d59:	89 c8                	mov    %ecx,%eax
  800d5b:	f7 f5                	div    %ebp
  800d5d:	eb 9c                	jmp    800cfb <__umoddi3+0x3b>
  800d5f:	90                   	nop
  800d60:	89 c8                	mov    %ecx,%eax
  800d62:	89 fa                	mov    %edi,%edx
  800d64:	83 c4 14             	add    $0x14,%esp
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    
  800d6b:	90                   	nop
  800d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d70:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800d77:	00 
  800d78:	8b 34 24             	mov    (%esp),%esi
  800d7b:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d7f:	89 e9                	mov    %ebp,%ecx
  800d81:	29 e8                	sub    %ebp,%eax
  800d83:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d87:	89 f0                	mov    %esi,%eax
  800d89:	d3 e2                	shl    %cl,%edx
  800d8b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800d8f:	d3 e8                	shr    %cl,%eax
  800d91:	89 04 24             	mov    %eax,(%esp)
  800d94:	89 e9                	mov    %ebp,%ecx
  800d96:	89 f0                	mov    %esi,%eax
  800d98:	09 14 24             	or     %edx,(%esp)
  800d9b:	d3 e0                	shl    %cl,%eax
  800d9d:	89 fa                	mov    %edi,%edx
  800d9f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800da3:	d3 ea                	shr    %cl,%edx
  800da5:	89 e9                	mov    %ebp,%ecx
  800da7:	89 c6                	mov    %eax,%esi
  800da9:	d3 e7                	shl    %cl,%edi
  800dab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800daf:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800db3:	8b 44 24 10          	mov    0x10(%esp),%eax
  800db7:	d3 e8                	shr    %cl,%eax
  800db9:	09 f8                	or     %edi,%eax
  800dbb:	89 e9                	mov    %ebp,%ecx
  800dbd:	8b 7c 24 10          	mov    0x10(%esp),%edi
  800dc1:	d3 e7                	shl    %cl,%edi
  800dc3:	f7 34 24             	divl   (%esp)
  800dc6:	89 d1                	mov    %edx,%ecx
  800dc8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dcc:	f7 e6                	mul    %esi
  800dce:	89 c7                	mov    %eax,%edi
  800dd0:	89 d6                	mov    %edx,%esi
  800dd2:	39 d1                	cmp    %edx,%ecx
  800dd4:	72 2e                	jb     800e04 <__umoddi3+0x144>
  800dd6:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800dda:	72 24                	jb     800e00 <__umoddi3+0x140>
  800ddc:	89 ca                	mov    %ecx,%edx
  800dde:	89 e9                	mov    %ebp,%ecx
  800de0:	8b 44 24 08          	mov    0x8(%esp),%eax
  800de4:	29 f8                	sub    %edi,%eax
  800de6:	19 f2                	sbb    %esi,%edx
  800de8:	d3 e8                	shr    %cl,%eax
  800dea:	89 d6                	mov    %edx,%esi
  800dec:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800df0:	d3 e6                	shl    %cl,%esi
  800df2:	89 e9                	mov    %ebp,%ecx
  800df4:	09 f0                	or     %esi,%eax
  800df6:	d3 ea                	shr    %cl,%edx
  800df8:	83 c4 14             	add    $0x14,%esp
  800dfb:	5e                   	pop    %esi
  800dfc:	5f                   	pop    %edi
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    
  800dff:	90                   	nop
  800e00:	39 d1                	cmp    %edx,%ecx
  800e02:	75 d8                	jne    800ddc <__umoddi3+0x11c>
  800e04:	89 d6                	mov    %edx,%esi
  800e06:	89 c7                	mov    %eax,%edi
  800e08:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  800e0c:	1b 34 24             	sbb    (%esp),%esi
  800e0f:	eb cb                	jmp    800ddc <__umoddi3+0x11c>
  800e11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e18:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  800e1c:	0f 82 ff fe ff ff    	jb     800d21 <__umoddi3+0x61>
  800e22:	e9 0a ff ff ff       	jmp    800d31 <__umoddi3+0x71>
