
obj/user/softint:     file format elf32-i386


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
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	5d                   	pop    %ebp
  80003a:	c3                   	ret    
  80003b:	90                   	nop

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
  800067:	e8 cf 01 00 00       	call   80023b <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  80006c:	e8 4e 04 00 00       	call   8004bf <sys_getenvid>
  800071:	25 ff 03 00 00       	and    $0x3ff,%eax
  800076:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80007d:	c1 e0 07             	shl    $0x7,%eax
  800080:	29 d0                	sub    %edx,%eax
  800082:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800087:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008c:	85 db                	test   %ebx,%ebx
  80008e:	7e 07                	jle    800097 <libmain+0x5b>
		binaryname = argv[0];
  800090:	8b 06                	mov    (%esi),%eax
  800092:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800097:	89 74 24 04          	mov    %esi,0x4(%esp)
  80009b:	89 1c 24             	mov    %ebx,(%esp)
  80009e:	e8 91 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a3:	e8 08 00 00 00       	call   8000b0 <exit>
}
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    
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
  80049b:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8004a2:	00 
  8004a3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004aa:	00 
  8004ab:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8004b2:	e8 5d 02 00 00       	call   800714 <_panic>

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

008004de <sys_yield>:

void
sys_yield(void)
{
  8004de:	55                   	push   %ebp
  8004df:	89 e5                	mov    %esp,%ebp
  8004e1:	57                   	push   %edi
  8004e2:	56                   	push   %esi
  8004e3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004ee:	89 d1                	mov    %edx,%ecx
  8004f0:	89 d3                	mov    %edx,%ebx
  8004f2:	89 d7                	mov    %edx,%edi
  8004f4:	89 d6                	mov    %edx,%esi
  8004f6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8004f8:	5b                   	pop    %ebx
  8004f9:	5e                   	pop    %esi
  8004fa:	5f                   	pop    %edi
  8004fb:	5d                   	pop    %ebp
  8004fc:	c3                   	ret    

008004fd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8004fd:	55                   	push   %ebp
  8004fe:	89 e5                	mov    %esp,%ebp
  800500:	57                   	push   %edi
  800501:	56                   	push   %esi
  800502:	53                   	push   %ebx
  800503:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800506:	be 00 00 00 00       	mov    $0x0,%esi
  80050b:	b8 04 00 00 00       	mov    $0x4,%eax
  800510:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800513:	8b 55 08             	mov    0x8(%ebp),%edx
  800516:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800519:	89 f7                	mov    %esi,%edi
  80051b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80051d:	85 c0                	test   %eax,%eax
  80051f:	7e 28                	jle    800549 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800521:	89 44 24 10          	mov    %eax,0x10(%esp)
  800525:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80052c:	00 
  80052d:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800534:	00 
  800535:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80053c:	00 
  80053d:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800544:	e8 cb 01 00 00       	call   800714 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800549:	83 c4 2c             	add    $0x2c,%esp
  80054c:	5b                   	pop    %ebx
  80054d:	5e                   	pop    %esi
  80054e:	5f                   	pop    %edi
  80054f:	5d                   	pop    %ebp
  800550:	c3                   	ret    

00800551 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800551:	55                   	push   %ebp
  800552:	89 e5                	mov    %esp,%ebp
  800554:	57                   	push   %edi
  800555:	56                   	push   %esi
  800556:	53                   	push   %ebx
  800557:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80055a:	b8 05 00 00 00       	mov    $0x5,%eax
  80055f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800562:	8b 55 08             	mov    0x8(%ebp),%edx
  800565:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800568:	8b 7d 14             	mov    0x14(%ebp),%edi
  80056b:	8b 75 18             	mov    0x18(%ebp),%esi
  80056e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800570:	85 c0                	test   %eax,%eax
  800572:	7e 28                	jle    80059c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800574:	89 44 24 10          	mov    %eax,0x10(%esp)
  800578:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80057f:	00 
  800580:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800587:	00 
  800588:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80058f:	00 
  800590:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800597:	e8 78 01 00 00       	call   800714 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80059c:	83 c4 2c             	add    $0x2c,%esp
  80059f:	5b                   	pop    %ebx
  8005a0:	5e                   	pop    %esi
  8005a1:	5f                   	pop    %edi
  8005a2:	5d                   	pop    %ebp
  8005a3:	c3                   	ret    

008005a4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8005a4:	55                   	push   %ebp
  8005a5:	89 e5                	mov    %esp,%ebp
  8005a7:	57                   	push   %edi
  8005a8:	56                   	push   %esi
  8005a9:	53                   	push   %ebx
  8005aa:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005b2:	b8 06 00 00 00       	mov    $0x6,%eax
  8005b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8005bd:	89 df                	mov    %ebx,%edi
  8005bf:	89 de                	mov    %ebx,%esi
  8005c1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005c3:	85 c0                	test   %eax,%eax
  8005c5:	7e 28                	jle    8005ef <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005c7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005cb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8005d2:	00 
  8005d3:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8005da:	00 
  8005db:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005e2:	00 
  8005e3:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8005ea:	e8 25 01 00 00       	call   800714 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8005ef:	83 c4 2c             	add    $0x2c,%esp
  8005f2:	5b                   	pop    %ebx
  8005f3:	5e                   	pop    %esi
  8005f4:	5f                   	pop    %edi
  8005f5:	5d                   	pop    %ebp
  8005f6:	c3                   	ret    

008005f7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8005f7:	55                   	push   %ebp
  8005f8:	89 e5                	mov    %esp,%ebp
  8005fa:	57                   	push   %edi
  8005fb:	56                   	push   %esi
  8005fc:	53                   	push   %ebx
  8005fd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800600:	bb 00 00 00 00       	mov    $0x0,%ebx
  800605:	b8 08 00 00 00       	mov    $0x8,%eax
  80060a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80060d:	8b 55 08             	mov    0x8(%ebp),%edx
  800610:	89 df                	mov    %ebx,%edi
  800612:	89 de                	mov    %ebx,%esi
  800614:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800616:	85 c0                	test   %eax,%eax
  800618:	7e 28                	jle    800642 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80061a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80061e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800625:	00 
  800626:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  80062d:	00 
  80062e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800635:	00 
  800636:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  80063d:	e8 d2 00 00 00       	call   800714 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800642:	83 c4 2c             	add    $0x2c,%esp
  800645:	5b                   	pop    %ebx
  800646:	5e                   	pop    %esi
  800647:	5f                   	pop    %edi
  800648:	5d                   	pop    %ebp
  800649:	c3                   	ret    

0080064a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80064a:	55                   	push   %ebp
  80064b:	89 e5                	mov    %esp,%ebp
  80064d:	57                   	push   %edi
  80064e:	56                   	push   %esi
  80064f:	53                   	push   %ebx
  800650:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800653:	bb 00 00 00 00       	mov    $0x0,%ebx
  800658:	b8 09 00 00 00       	mov    $0x9,%eax
  80065d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800660:	8b 55 08             	mov    0x8(%ebp),%edx
  800663:	89 df                	mov    %ebx,%edi
  800665:	89 de                	mov    %ebx,%esi
  800667:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800669:	85 c0                	test   %eax,%eax
  80066b:	7e 28                	jle    800695 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80066d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800671:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800678:	00 
  800679:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800680:	00 
  800681:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800688:	00 
  800689:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800690:	e8 7f 00 00 00       	call   800714 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800695:	83 c4 2c             	add    $0x2c,%esp
  800698:	5b                   	pop    %ebx
  800699:	5e                   	pop    %esi
  80069a:	5f                   	pop    %edi
  80069b:	5d                   	pop    %ebp
  80069c:	c3                   	ret    

0080069d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
  8006a0:	57                   	push   %edi
  8006a1:	56                   	push   %esi
  8006a2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006a3:	be 00 00 00 00       	mov    $0x0,%esi
  8006a8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8006ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006b6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8006b9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8006bb:	5b                   	pop    %ebx
  8006bc:	5e                   	pop    %esi
  8006bd:	5f                   	pop    %edi
  8006be:	5d                   	pop    %ebp
  8006bf:	c3                   	ret    

008006c0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	57                   	push   %edi
  8006c4:	56                   	push   %esi
  8006c5:	53                   	push   %ebx
  8006c6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ce:	b8 0c 00 00 00       	mov    $0xc,%eax
  8006d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d6:	89 cb                	mov    %ecx,%ebx
  8006d8:	89 cf                	mov    %ecx,%edi
  8006da:	89 ce                	mov    %ecx,%esi
  8006dc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006de:	85 c0                	test   %eax,%eax
  8006e0:	7e 28                	jle    80070a <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006e2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006e6:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8006ed:	00 
  8006ee:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8006f5:	00 
  8006f6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8006fd:	00 
  8006fe:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800705:	e8 0a 00 00 00       	call   800714 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80070a:	83 c4 2c             	add    $0x2c,%esp
  80070d:	5b                   	pop    %ebx
  80070e:	5e                   	pop    %esi
  80070f:	5f                   	pop    %edi
  800710:	5d                   	pop    %ebp
  800711:	c3                   	ret    
  800712:	66 90                	xchg   %ax,%ax

00800714 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	56                   	push   %esi
  800718:	53                   	push   %ebx
  800719:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80071c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80071f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800725:	e8 95 fd ff ff       	call   8004bf <sys_getenvid>
  80072a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80072d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800731:	8b 55 08             	mov    0x8(%ebp),%edx
  800734:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800738:	89 74 24 08          	mov    %esi,0x8(%esp)
  80073c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800740:	c7 04 24 b8 10 80 00 	movl   $0x8010b8,(%esp)
  800747:	e8 c2 00 00 00       	call   80080e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80074c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800750:	8b 45 10             	mov    0x10(%ebp),%eax
  800753:	89 04 24             	mov    %eax,(%esp)
  800756:	e8 52 00 00 00       	call   8007ad <vcprintf>
	cprintf("\n");
  80075b:	c7 04 24 dc 10 80 00 	movl   $0x8010dc,(%esp)
  800762:	e8 a7 00 00 00       	call   80080e <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800767:	cc                   	int3   
  800768:	eb fd                	jmp    800767 <_panic+0x53>
  80076a:	66 90                	xchg   %ax,%ax

0080076c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	53                   	push   %ebx
  800770:	83 ec 14             	sub    $0x14,%esp
  800773:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800776:	8b 13                	mov    (%ebx),%edx
  800778:	8d 42 01             	lea    0x1(%edx),%eax
  80077b:	89 03                	mov    %eax,(%ebx)
  80077d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800780:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800784:	3d ff 00 00 00       	cmp    $0xff,%eax
  800789:	75 19                	jne    8007a4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80078b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800792:	00 
  800793:	8d 43 08             	lea    0x8(%ebx),%eax
  800796:	89 04 24             	mov    %eax,(%esp)
  800799:	e8 92 fc ff ff       	call   800430 <sys_cputs>
		b->idx = 0;
  80079e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8007a4:	ff 43 04             	incl   0x4(%ebx)
}
  8007a7:	83 c4 14             	add    $0x14,%esp
  8007aa:	5b                   	pop    %ebx
  8007ab:	5d                   	pop    %ebp
  8007ac:	c3                   	ret    

008007ad <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8007b6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8007bd:	00 00 00 
	b.cnt = 0;
  8007c0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8007c7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8007ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8007de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e2:	c7 04 24 6c 07 80 00 	movl   $0x80076c,(%esp)
  8007e9:	e8 a9 01 00 00       	call   800997 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8007ee:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8007f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8007fe:	89 04 24             	mov    %eax,(%esp)
  800801:	e8 2a fc ff ff       	call   800430 <sys_cputs>

	return b.cnt;
}
  800806:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80080c:	c9                   	leave  
  80080d:	c3                   	ret    

0080080e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800814:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800817:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081b:	8b 45 08             	mov    0x8(%ebp),%eax
  80081e:	89 04 24             	mov    %eax,(%esp)
  800821:	e8 87 ff ff ff       	call   8007ad <vcprintf>
	va_end(ap);

	return cnt;
}
  800826:	c9                   	leave  
  800827:	c3                   	ret    

00800828 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	57                   	push   %edi
  80082c:	56                   	push   %esi
  80082d:	53                   	push   %ebx
  80082e:	83 ec 3c             	sub    $0x3c,%esp
  800831:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800834:	89 d7                	mov    %edx,%edi
  800836:	8b 45 08             	mov    0x8(%ebp),%eax
  800839:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80083c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083f:	89 c1                	mov    %eax,%ecx
  800841:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800844:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800847:	8b 45 10             	mov    0x10(%ebp),%eax
  80084a:	ba 00 00 00 00       	mov    $0x0,%edx
  80084f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800852:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800855:	39 ca                	cmp    %ecx,%edx
  800857:	72 08                	jb     800861 <printnum+0x39>
  800859:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80085c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80085f:	77 6a                	ja     8008cb <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800861:	8b 45 18             	mov    0x18(%ebp),%eax
  800864:	89 44 24 10          	mov    %eax,0x10(%esp)
  800868:	4e                   	dec    %esi
  800869:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80086d:	8b 45 10             	mov    0x10(%ebp),%eax
  800870:	89 44 24 08          	mov    %eax,0x8(%esp)
  800874:	8b 44 24 08          	mov    0x8(%esp),%eax
  800878:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80087c:	89 c3                	mov    %eax,%ebx
  80087e:	89 d6                	mov    %edx,%esi
  800880:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800883:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800886:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80088e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800891:	89 04 24             	mov    %eax,(%esp)
  800894:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800897:	89 44 24 04          	mov    %eax,0x4(%esp)
  80089b:	e8 30 05 00 00       	call   800dd0 <__udivdi3>
  8008a0:	89 d9                	mov    %ebx,%ecx
  8008a2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008a6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008aa:	89 04 24             	mov    %eax,(%esp)
  8008ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b1:	89 fa                	mov    %edi,%edx
  8008b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008b6:	e8 6d ff ff ff       	call   800828 <printnum>
  8008bb:	eb 19                	jmp    8008d6 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8008bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008c1:	8b 45 18             	mov    0x18(%ebp),%eax
  8008c4:	89 04 24             	mov    %eax,(%esp)
  8008c7:	ff d3                	call   *%ebx
  8008c9:	eb 03                	jmp    8008ce <printnum+0xa6>
  8008cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8008ce:	4e                   	dec    %esi
  8008cf:	85 f6                	test   %esi,%esi
  8008d1:	7f ea                	jg     8008bd <printnum+0x95>
  8008d3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8008d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008da:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8008de:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008ef:	89 04 24             	mov    %eax,(%esp)
  8008f2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8008f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f9:	e8 02 06 00 00       	call   800f00 <__umoddi3>
  8008fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800902:	0f be 80 de 10 80 00 	movsbl 0x8010de(%eax),%eax
  800909:	89 04 24             	mov    %eax,(%esp)
  80090c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80090f:	ff d0                	call   *%eax
}
  800911:	83 c4 3c             	add    $0x3c,%esp
  800914:	5b                   	pop    %ebx
  800915:	5e                   	pop    %esi
  800916:	5f                   	pop    %edi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80091c:	83 fa 01             	cmp    $0x1,%edx
  80091f:	7e 0e                	jle    80092f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800921:	8b 10                	mov    (%eax),%edx
  800923:	8d 4a 08             	lea    0x8(%edx),%ecx
  800926:	89 08                	mov    %ecx,(%eax)
  800928:	8b 02                	mov    (%edx),%eax
  80092a:	8b 52 04             	mov    0x4(%edx),%edx
  80092d:	eb 22                	jmp    800951 <getuint+0x38>
	else if (lflag)
  80092f:	85 d2                	test   %edx,%edx
  800931:	74 10                	je     800943 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800933:	8b 10                	mov    (%eax),%edx
  800935:	8d 4a 04             	lea    0x4(%edx),%ecx
  800938:	89 08                	mov    %ecx,(%eax)
  80093a:	8b 02                	mov    (%edx),%eax
  80093c:	ba 00 00 00 00       	mov    $0x0,%edx
  800941:	eb 0e                	jmp    800951 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800943:	8b 10                	mov    (%eax),%edx
  800945:	8d 4a 04             	lea    0x4(%edx),%ecx
  800948:	89 08                	mov    %ecx,(%eax)
  80094a:	8b 02                	mov    (%edx),%eax
  80094c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800959:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80095c:	8b 10                	mov    (%eax),%edx
  80095e:	3b 50 04             	cmp    0x4(%eax),%edx
  800961:	73 0a                	jae    80096d <sprintputch+0x1a>
		*b->buf++ = ch;
  800963:	8d 4a 01             	lea    0x1(%edx),%ecx
  800966:	89 08                	mov    %ecx,(%eax)
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	88 02                	mov    %al,(%edx)
}
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800975:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800978:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80097c:	8b 45 10             	mov    0x10(%ebp),%eax
  80097f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800983:	8b 45 0c             	mov    0xc(%ebp),%eax
  800986:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	89 04 24             	mov    %eax,(%esp)
  800990:	e8 02 00 00 00       	call   800997 <vprintfmt>
	va_end(ap);
}
  800995:	c9                   	leave  
  800996:	c3                   	ret    

00800997 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	57                   	push   %edi
  80099b:	56                   	push   %esi
  80099c:	53                   	push   %ebx
  80099d:	83 ec 3c             	sub    $0x3c,%esp
  8009a0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8009a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009a6:	eb 14                	jmp    8009bc <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8009a8:	85 c0                	test   %eax,%eax
  8009aa:	0f 84 8a 03 00 00    	je     800d3a <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  8009b0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009b4:	89 04 24             	mov    %eax,(%esp)
  8009b7:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8009ba:	89 f3                	mov    %esi,%ebx
  8009bc:	8d 73 01             	lea    0x1(%ebx),%esi
  8009bf:	31 c0                	xor    %eax,%eax
  8009c1:	8a 03                	mov    (%ebx),%al
  8009c3:	83 f8 25             	cmp    $0x25,%eax
  8009c6:	75 e0                	jne    8009a8 <vprintfmt+0x11>
  8009c8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8009cc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8009d3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8009da:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8009e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e6:	eb 1d                	jmp    800a05 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009e8:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8009ea:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8009ee:	eb 15                	jmp    800a05 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009f0:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8009f2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8009f6:	eb 0d                	jmp    800a05 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8009f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8009fb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8009fe:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a05:	8d 5e 01             	lea    0x1(%esi),%ebx
  800a08:	31 c0                	xor    %eax,%eax
  800a0a:	8a 06                	mov    (%esi),%al
  800a0c:	8a 0e                	mov    (%esi),%cl
  800a0e:	83 e9 23             	sub    $0x23,%ecx
  800a11:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800a14:	80 f9 55             	cmp    $0x55,%cl
  800a17:	0f 87 ff 02 00 00    	ja     800d1c <vprintfmt+0x385>
  800a1d:	31 c9                	xor    %ecx,%ecx
  800a1f:	8a 4d e0             	mov    -0x20(%ebp),%cl
  800a22:	ff 24 8d a0 11 80 00 	jmp    *0x8011a0(,%ecx,4)
  800a29:	89 de                	mov    %ebx,%esi
  800a2b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800a30:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800a33:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800a37:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800a3a:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800a3d:	83 fb 09             	cmp    $0x9,%ebx
  800a40:	77 2f                	ja     800a71 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800a42:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800a43:	eb eb                	jmp    800a30 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800a45:	8b 45 14             	mov    0x14(%ebp),%eax
  800a48:	8d 48 04             	lea    0x4(%eax),%ecx
  800a4b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a4e:	8b 00                	mov    (%eax),%eax
  800a50:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a53:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800a55:	eb 1d                	jmp    800a74 <vprintfmt+0xdd>
  800a57:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a5a:	f7 d0                	not    %eax
  800a5c:	c1 f8 1f             	sar    $0x1f,%eax
  800a5f:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a62:	89 de                	mov    %ebx,%esi
  800a64:	eb 9f                	jmp    800a05 <vprintfmt+0x6e>
  800a66:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800a68:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800a6f:	eb 94                	jmp    800a05 <vprintfmt+0x6e>
  800a71:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800a74:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a78:	79 8b                	jns    800a05 <vprintfmt+0x6e>
  800a7a:	e9 79 ff ff ff       	jmp    8009f8 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800a7f:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a80:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800a82:	eb 81                	jmp    800a05 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800a84:	8b 45 14             	mov    0x14(%ebp),%eax
  800a87:	8d 50 04             	lea    0x4(%eax),%edx
  800a8a:	89 55 14             	mov    %edx,0x14(%ebp)
  800a8d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a91:	8b 00                	mov    (%eax),%eax
  800a93:	89 04 24             	mov    %eax,(%esp)
  800a96:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a99:	e9 1e ff ff ff       	jmp    8009bc <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800a9e:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa1:	8d 50 04             	lea    0x4(%eax),%edx
  800aa4:	89 55 14             	mov    %edx,0x14(%ebp)
  800aa7:	8b 00                	mov    (%eax),%eax
  800aa9:	89 c2                	mov    %eax,%edx
  800aab:	c1 fa 1f             	sar    $0x1f,%edx
  800aae:	31 d0                	xor    %edx,%eax
  800ab0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800ab2:	83 f8 09             	cmp    $0x9,%eax
  800ab5:	7f 0b                	jg     800ac2 <vprintfmt+0x12b>
  800ab7:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  800abe:	85 d2                	test   %edx,%edx
  800ac0:	75 20                	jne    800ae2 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  800ac2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ac6:	c7 44 24 08 f6 10 80 	movl   $0x8010f6,0x8(%esp)
  800acd:	00 
  800ace:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	89 04 24             	mov    %eax,(%esp)
  800ad8:	e8 92 fe ff ff       	call   80096f <printfmt>
  800add:	e9 da fe ff ff       	jmp    8009bc <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800ae2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ae6:	c7 44 24 08 ff 10 80 	movl   $0x8010ff,0x8(%esp)
  800aed:	00 
  800aee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800af2:	8b 45 08             	mov    0x8(%ebp),%eax
  800af5:	89 04 24             	mov    %eax,(%esp)
  800af8:	e8 72 fe ff ff       	call   80096f <printfmt>
  800afd:	e9 ba fe ff ff       	jmp    8009bc <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b02:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800b05:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b08:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800b0b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b0e:	8d 50 04             	lea    0x4(%eax),%edx
  800b11:	89 55 14             	mov    %edx,0x14(%ebp)
  800b14:	8b 30                	mov    (%eax),%esi
  800b16:	85 f6                	test   %esi,%esi
  800b18:	75 05                	jne    800b1f <vprintfmt+0x188>
				p = "(null)";
  800b1a:	be ef 10 80 00       	mov    $0x8010ef,%esi
			if (width > 0 && padc != '-')
  800b1f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800b23:	0f 84 8c 00 00 00    	je     800bb5 <vprintfmt+0x21e>
  800b29:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b2d:	0f 8e 8a 00 00 00    	jle    800bbd <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b33:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b37:	89 34 24             	mov    %esi,(%esp)
  800b3a:	e8 9b f5 ff ff       	call   8000da <strnlen>
  800b3f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800b42:	29 c1                	sub    %eax,%ecx
  800b44:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800b47:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800b4b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b4e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800b51:	8b 75 08             	mov    0x8(%ebp),%esi
  800b54:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b57:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b59:	eb 0d                	jmp    800b68 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800b5b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b62:	89 04 24             	mov    %eax,(%esp)
  800b65:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b67:	4b                   	dec    %ebx
  800b68:	85 db                	test   %ebx,%ebx
  800b6a:	7f ef                	jg     800b5b <vprintfmt+0x1c4>
  800b6c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800b6f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b72:	89 c8                	mov    %ecx,%eax
  800b74:	f7 d0                	not    %eax
  800b76:	c1 f8 1f             	sar    $0x1f,%eax
  800b79:	21 c8                	and    %ecx,%eax
  800b7b:	29 c1                	sub    %eax,%ecx
  800b7d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b80:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800b83:	eb 3e                	jmp    800bc3 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b85:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800b89:	74 1b                	je     800ba6 <vprintfmt+0x20f>
  800b8b:	0f be d2             	movsbl %dl,%edx
  800b8e:	83 ea 20             	sub    $0x20,%edx
  800b91:	83 fa 5e             	cmp    $0x5e,%edx
  800b94:	76 10                	jbe    800ba6 <vprintfmt+0x20f>
					putch('?', putdat);
  800b96:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b9a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800ba1:	ff 55 08             	call   *0x8(%ebp)
  800ba4:	eb 0a                	jmp    800bb0 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800ba6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800baa:	89 04 24             	mov    %eax,(%esp)
  800bad:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bb0:	ff 4d dc             	decl   -0x24(%ebp)
  800bb3:	eb 0e                	jmp    800bc3 <vprintfmt+0x22c>
  800bb5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bb8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800bbb:	eb 06                	jmp    800bc3 <vprintfmt+0x22c>
  800bbd:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bc0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800bc3:	46                   	inc    %esi
  800bc4:	8a 56 ff             	mov    -0x1(%esi),%dl
  800bc7:	0f be c2             	movsbl %dl,%eax
  800bca:	85 c0                	test   %eax,%eax
  800bcc:	74 1f                	je     800bed <vprintfmt+0x256>
  800bce:	85 db                	test   %ebx,%ebx
  800bd0:	78 b3                	js     800b85 <vprintfmt+0x1ee>
  800bd2:	4b                   	dec    %ebx
  800bd3:	79 b0                	jns    800b85 <vprintfmt+0x1ee>
  800bd5:	8b 75 08             	mov    0x8(%ebp),%esi
  800bd8:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800bdb:	eb 16                	jmp    800bf3 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800bdd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800be1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800be8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800bea:	4b                   	dec    %ebx
  800beb:	eb 06                	jmp    800bf3 <vprintfmt+0x25c>
  800bed:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800bf0:	8b 75 08             	mov    0x8(%ebp),%esi
  800bf3:	85 db                	test   %ebx,%ebx
  800bf5:	7f e6                	jg     800bdd <vprintfmt+0x246>
  800bf7:	89 75 08             	mov    %esi,0x8(%ebp)
  800bfa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bfd:	e9 ba fd ff ff       	jmp    8009bc <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c02:	83 fa 01             	cmp    $0x1,%edx
  800c05:	7e 16                	jle    800c1d <vprintfmt+0x286>
		return va_arg(*ap, long long);
  800c07:	8b 45 14             	mov    0x14(%ebp),%eax
  800c0a:	8d 50 08             	lea    0x8(%eax),%edx
  800c0d:	89 55 14             	mov    %edx,0x14(%ebp)
  800c10:	8b 50 04             	mov    0x4(%eax),%edx
  800c13:	8b 00                	mov    (%eax),%eax
  800c15:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c18:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c1b:	eb 32                	jmp    800c4f <vprintfmt+0x2b8>
	else if (lflag)
  800c1d:	85 d2                	test   %edx,%edx
  800c1f:	74 18                	je     800c39 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800c21:	8b 45 14             	mov    0x14(%ebp),%eax
  800c24:	8d 50 04             	lea    0x4(%eax),%edx
  800c27:	89 55 14             	mov    %edx,0x14(%ebp)
  800c2a:	8b 30                	mov    (%eax),%esi
  800c2c:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800c2f:	89 f0                	mov    %esi,%eax
  800c31:	c1 f8 1f             	sar    $0x1f,%eax
  800c34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c37:	eb 16                	jmp    800c4f <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800c39:	8b 45 14             	mov    0x14(%ebp),%eax
  800c3c:	8d 50 04             	lea    0x4(%eax),%edx
  800c3f:	89 55 14             	mov    %edx,0x14(%ebp)
  800c42:	8b 30                	mov    (%eax),%esi
  800c44:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800c47:	89 f0                	mov    %esi,%eax
  800c49:	c1 f8 1f             	sar    $0x1f,%eax
  800c4c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c52:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800c55:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800c5a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c5e:	0f 89 80 00 00 00    	jns    800ce4 <vprintfmt+0x34d>
				putch('-', putdat);
  800c64:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c68:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800c6f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800c72:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c75:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c78:	f7 d8                	neg    %eax
  800c7a:	83 d2 00             	adc    $0x0,%edx
  800c7d:	f7 da                	neg    %edx
			}
			base = 10;
  800c7f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c84:	eb 5e                	jmp    800ce4 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800c86:	8d 45 14             	lea    0x14(%ebp),%eax
  800c89:	e8 8b fc ff ff       	call   800919 <getuint>
			base = 10;
  800c8e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800c93:	eb 4f                	jmp    800ce4 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800c95:	8d 45 14             	lea    0x14(%ebp),%eax
  800c98:	e8 7c fc ff ff       	call   800919 <getuint>
			base = 8;
  800c9d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800ca2:	eb 40                	jmp    800ce4 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800ca4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ca8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800caf:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800cb2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cb6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800cbd:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800cc0:	8b 45 14             	mov    0x14(%ebp),%eax
  800cc3:	8d 50 04             	lea    0x4(%eax),%edx
  800cc6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800cc9:	8b 00                	mov    (%eax),%eax
  800ccb:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800cd0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800cd5:	eb 0d                	jmp    800ce4 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800cd7:	8d 45 14             	lea    0x14(%ebp),%eax
  800cda:	e8 3a fc ff ff       	call   800919 <getuint>
			base = 16;
  800cdf:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ce4:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800ce8:	89 74 24 10          	mov    %esi,0x10(%esp)
  800cec:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800cef:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800cf3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cf7:	89 04 24             	mov    %eax,(%esp)
  800cfa:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cfe:	89 fa                	mov    %edi,%edx
  800d00:	8b 45 08             	mov    0x8(%ebp),%eax
  800d03:	e8 20 fb ff ff       	call   800828 <printnum>
			break;
  800d08:	e9 af fc ff ff       	jmp    8009bc <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d0d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d11:	89 04 24             	mov    %eax,(%esp)
  800d14:	ff 55 08             	call   *0x8(%ebp)
			break;
  800d17:	e9 a0 fc ff ff       	jmp    8009bc <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d1c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d20:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800d27:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d2a:	89 f3                	mov    %esi,%ebx
  800d2c:	eb 01                	jmp    800d2f <vprintfmt+0x398>
  800d2e:	4b                   	dec    %ebx
  800d2f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800d33:	75 f9                	jne    800d2e <vprintfmt+0x397>
  800d35:	e9 82 fc ff ff       	jmp    8009bc <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800d3a:	83 c4 3c             	add    $0x3c,%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	83 ec 28             	sub    $0x28,%esp
  800d48:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d51:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d55:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	74 30                	je     800d93 <vsnprintf+0x51>
  800d63:	85 d2                	test   %edx,%edx
  800d65:	7e 2c                	jle    800d93 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d67:	8b 45 14             	mov    0x14(%ebp),%eax
  800d6a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d6e:	8b 45 10             	mov    0x10(%ebp),%eax
  800d71:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d75:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d78:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d7c:	c7 04 24 53 09 80 00 	movl   $0x800953,(%esp)
  800d83:	e8 0f fc ff ff       	call   800997 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d88:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d8b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d91:	eb 05                	jmp    800d98 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d93:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d98:	c9                   	leave  
  800d99:	c3                   	ret    

00800d9a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800da0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800da3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800da7:	8b 45 10             	mov    0x10(%ebp),%eax
  800daa:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800db5:	8b 45 08             	mov    0x8(%ebp),%eax
  800db8:	89 04 24             	mov    %eax,(%esp)
  800dbb:	e8 82 ff ff ff       	call   800d42 <vsnprintf>
	va_end(ap);

	return rc;
}
  800dc0:	c9                   	leave  
  800dc1:	c3                   	ret    
  800dc2:	66 90                	xchg   %ax,%ax
  800dc4:	66 90                	xchg   %ax,%ax
  800dc6:	66 90                	xchg   %ax,%ax
  800dc8:	66 90                	xchg   %ax,%ax
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
