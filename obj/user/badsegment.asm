
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
  80006b:	e8 cf 01 00 00       	call   80023f <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  800070:	e8 4e 04 00 00       	call   8004c3 <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800081:	c1 e0 07             	shl    $0x7,%eax
  800084:	29 d0                	sub    %edx,%eax
  800086:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800090:	85 db                	test   %ebx,%ebx
  800092:	7e 07                	jle    80009b <libmain+0x5b>
		binaryname = argv[0];
  800094:	8b 06                	mov    (%esi),%eax
  800096:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80009f:	89 1c 24             	mov    %ebx,(%esp)
  8000a2:	e8 8d ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a7:	e8 08 00 00 00       	call   8000b4 <exit>
}
  8000ac:	83 c4 10             	add    $0x10,%esp
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5d                   	pop    %ebp
  8000b2:	c3                   	ret    
  8000b3:	90                   	nop

008000b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c1:	e8 ab 03 00 00       	call   800471 <sys_env_destroy>
}
  8000c6:	c9                   	leave  
  8000c7:	c3                   	ret    

008000c8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8000ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d3:	eb 01                	jmp    8000d6 <strlen+0xe>
		n++;
  8000d5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8000d6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8000da:	75 f9                	jne    8000d5 <strlen+0xd>
		n++;
	return n;
}
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8000e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ec:	eb 01                	jmp    8000ef <strnlen+0x11>
		n++;
  8000ee:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8000ef:	39 d0                	cmp    %edx,%eax
  8000f1:	74 06                	je     8000f9 <strnlen+0x1b>
  8000f3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8000f7:	75 f5                	jne    8000ee <strnlen+0x10>
		n++;
	return n;
}
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	53                   	push   %ebx
  8000ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800102:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800105:	89 c2                	mov    %eax,%edx
  800107:	42                   	inc    %edx
  800108:	41                   	inc    %ecx
  800109:	8a 59 ff             	mov    -0x1(%ecx),%bl
  80010c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80010f:	84 db                	test   %bl,%bl
  800111:	75 f4                	jne    800107 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800113:	5b                   	pop    %ebx
  800114:	5d                   	pop    %ebp
  800115:	c3                   	ret    

00800116 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	53                   	push   %ebx
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800120:	89 1c 24             	mov    %ebx,(%esp)
  800123:	e8 a0 ff ff ff       	call   8000c8 <strlen>
	strcpy(dst + len, src);
  800128:	8b 55 0c             	mov    0xc(%ebp),%edx
  80012b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80012f:	01 d8                	add    %ebx,%eax
  800131:	89 04 24             	mov    %eax,(%esp)
  800134:	e8 c2 ff ff ff       	call   8000fb <strcpy>
	return dst;
}
  800139:	89 d8                	mov    %ebx,%eax
  80013b:	83 c4 08             	add    $0x8,%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5d                   	pop    %ebp
  800140:	c3                   	ret    

00800141 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	56                   	push   %esi
  800145:	53                   	push   %ebx
  800146:	8b 75 08             	mov    0x8(%ebp),%esi
  800149:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80014c:	89 f3                	mov    %esi,%ebx
  80014e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800151:	89 f2                	mov    %esi,%edx
  800153:	eb 0c                	jmp    800161 <strncpy+0x20>
		*dst++ = *src;
  800155:	42                   	inc    %edx
  800156:	8a 01                	mov    (%ecx),%al
  800158:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80015b:	80 39 01             	cmpb   $0x1,(%ecx)
  80015e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800161:	39 da                	cmp    %ebx,%edx
  800163:	75 f0                	jne    800155 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800165:	89 f0                	mov    %esi,%eax
  800167:	5b                   	pop    %ebx
  800168:	5e                   	pop    %esi
  800169:	5d                   	pop    %ebp
  80016a:	c3                   	ret    

0080016b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	8b 75 08             	mov    0x8(%ebp),%esi
  800173:	8b 55 0c             	mov    0xc(%ebp),%edx
  800176:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800179:	89 f0                	mov    %esi,%eax
  80017b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80017f:	85 c9                	test   %ecx,%ecx
  800181:	75 07                	jne    80018a <strlcpy+0x1f>
  800183:	eb 18                	jmp    80019d <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800185:	40                   	inc    %eax
  800186:	42                   	inc    %edx
  800187:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80018a:	39 d8                	cmp    %ebx,%eax
  80018c:	74 0a                	je     800198 <strlcpy+0x2d>
  80018e:	8a 0a                	mov    (%edx),%cl
  800190:	84 c9                	test   %cl,%cl
  800192:	75 f1                	jne    800185 <strlcpy+0x1a>
  800194:	89 c2                	mov    %eax,%edx
  800196:	eb 02                	jmp    80019a <strlcpy+0x2f>
  800198:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80019a:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80019d:	29 f0                	sub    %esi,%eax
}
  80019f:	5b                   	pop    %ebx
  8001a0:	5e                   	pop    %esi
  8001a1:	5d                   	pop    %ebp
  8001a2:	c3                   	ret    

008001a3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8001ac:	eb 02                	jmp    8001b0 <strcmp+0xd>
		p++, q++;
  8001ae:	41                   	inc    %ecx
  8001af:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8001b0:	8a 01                	mov    (%ecx),%al
  8001b2:	84 c0                	test   %al,%al
  8001b4:	74 04                	je     8001ba <strcmp+0x17>
  8001b6:	3a 02                	cmp    (%edx),%al
  8001b8:	74 f4                	je     8001ae <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8001ba:	25 ff 00 00 00       	and    $0xff,%eax
  8001bf:	8a 0a                	mov    (%edx),%cl
  8001c1:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8001c7:	29 c8                	sub    %ecx,%eax
}
  8001c9:	5d                   	pop    %ebp
  8001ca:	c3                   	ret    

008001cb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	53                   	push   %ebx
  8001cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d5:	89 c3                	mov    %eax,%ebx
  8001d7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8001da:	eb 02                	jmp    8001de <strncmp+0x13>
		n--, p++, q++;
  8001dc:	40                   	inc    %eax
  8001dd:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8001de:	39 d8                	cmp    %ebx,%eax
  8001e0:	74 20                	je     800202 <strncmp+0x37>
  8001e2:	8a 08                	mov    (%eax),%cl
  8001e4:	84 c9                	test   %cl,%cl
  8001e6:	74 04                	je     8001ec <strncmp+0x21>
  8001e8:	3a 0a                	cmp    (%edx),%cl
  8001ea:	74 f0                	je     8001dc <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8001ec:	8a 18                	mov    (%eax),%bl
  8001ee:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8001f4:	89 d8                	mov    %ebx,%eax
  8001f6:	8a 1a                	mov    (%edx),%bl
  8001f8:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8001fe:	29 d8                	sub    %ebx,%eax
  800200:	eb 05                	jmp    800207 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800202:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800207:	5b                   	pop    %ebx
  800208:	5d                   	pop    %ebp
  800209:	c3                   	ret    

0080020a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
  80020d:	8b 45 08             	mov    0x8(%ebp),%eax
  800210:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800213:	eb 05                	jmp    80021a <strchr+0x10>
		if (*s == c)
  800215:	38 ca                	cmp    %cl,%dl
  800217:	74 0c                	je     800225 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800219:	40                   	inc    %eax
  80021a:	8a 10                	mov    (%eax),%dl
  80021c:	84 d2                	test   %dl,%dl
  80021e:	75 f5                	jne    800215 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800220:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800225:	5d                   	pop    %ebp
  800226:	c3                   	ret    

00800227 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	8b 45 08             	mov    0x8(%ebp),%eax
  80022d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800230:	eb 05                	jmp    800237 <strfind+0x10>
		if (*s == c)
  800232:	38 ca                	cmp    %cl,%dl
  800234:	74 07                	je     80023d <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800236:	40                   	inc    %eax
  800237:	8a 10                	mov    (%eax),%dl
  800239:	84 d2                	test   %dl,%dl
  80023b:	75 f5                	jne    800232 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80023d:	5d                   	pop    %ebp
  80023e:	c3                   	ret    

0080023f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	57                   	push   %edi
  800243:	56                   	push   %esi
  800244:	53                   	push   %ebx
  800245:	8b 7d 08             	mov    0x8(%ebp),%edi
  800248:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80024b:	85 c9                	test   %ecx,%ecx
  80024d:	74 37                	je     800286 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80024f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800255:	75 29                	jne    800280 <memset+0x41>
  800257:	f6 c1 03             	test   $0x3,%cl
  80025a:	75 24                	jne    800280 <memset+0x41>
		c &= 0xFF;
  80025c:	31 d2                	xor    %edx,%edx
  80025e:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800261:	89 d3                	mov    %edx,%ebx
  800263:	c1 e3 08             	shl    $0x8,%ebx
  800266:	89 d6                	mov    %edx,%esi
  800268:	c1 e6 18             	shl    $0x18,%esi
  80026b:	89 d0                	mov    %edx,%eax
  80026d:	c1 e0 10             	shl    $0x10,%eax
  800270:	09 f0                	or     %esi,%eax
  800272:	09 c2                	or     %eax,%edx
  800274:	89 d0                	mov    %edx,%eax
  800276:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800278:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80027b:	fc                   	cld    
  80027c:	f3 ab                	rep stos %eax,%es:(%edi)
  80027e:	eb 06                	jmp    800286 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800280:	8b 45 0c             	mov    0xc(%ebp),%eax
  800283:	fc                   	cld    
  800284:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800286:	89 f8                	mov    %edi,%eax
  800288:	5b                   	pop    %ebx
  800289:	5e                   	pop    %esi
  80028a:	5f                   	pop    %edi
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    

0080028d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	57                   	push   %edi
  800291:	56                   	push   %esi
  800292:	8b 45 08             	mov    0x8(%ebp),%eax
  800295:	8b 75 0c             	mov    0xc(%ebp),%esi
  800298:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80029b:	39 c6                	cmp    %eax,%esi
  80029d:	73 33                	jae    8002d2 <memmove+0x45>
  80029f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8002a2:	39 d0                	cmp    %edx,%eax
  8002a4:	73 2c                	jae    8002d2 <memmove+0x45>
		s += n;
		d += n;
  8002a6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8002a9:	89 d6                	mov    %edx,%esi
  8002ab:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8002ad:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8002b3:	75 13                	jne    8002c8 <memmove+0x3b>
  8002b5:	f6 c1 03             	test   $0x3,%cl
  8002b8:	75 0e                	jne    8002c8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8002ba:	83 ef 04             	sub    $0x4,%edi
  8002bd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8002c0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8002c3:	fd                   	std    
  8002c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8002c6:	eb 07                	jmp    8002cf <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8002c8:	4f                   	dec    %edi
  8002c9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8002cc:	fd                   	std    
  8002cd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8002cf:	fc                   	cld    
  8002d0:	eb 1d                	jmp    8002ef <memmove+0x62>
  8002d2:	89 f2                	mov    %esi,%edx
  8002d4:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8002d6:	f6 c2 03             	test   $0x3,%dl
  8002d9:	75 0f                	jne    8002ea <memmove+0x5d>
  8002db:	f6 c1 03             	test   $0x3,%cl
  8002de:	75 0a                	jne    8002ea <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8002e0:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8002e3:	89 c7                	mov    %eax,%edi
  8002e5:	fc                   	cld    
  8002e6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8002e8:	eb 05                	jmp    8002ef <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8002ea:	89 c7                	mov    %eax,%edi
  8002ec:	fc                   	cld    
  8002ed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8002f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	8b 45 0c             	mov    0xc(%ebp),%eax
  800303:	89 44 24 04          	mov    %eax,0x4(%esp)
  800307:	8b 45 08             	mov    0x8(%ebp),%eax
  80030a:	89 04 24             	mov    %eax,(%esp)
  80030d:	e8 7b ff ff ff       	call   80028d <memmove>
}
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031f:	89 d6                	mov    %edx,%esi
  800321:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800324:	eb 19                	jmp    80033f <memcmp+0x2b>
		if (*s1 != *s2)
  800326:	8a 02                	mov    (%edx),%al
  800328:	8a 19                	mov    (%ecx),%bl
  80032a:	38 d8                	cmp    %bl,%al
  80032c:	74 0f                	je     80033d <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  80032e:	25 ff 00 00 00       	and    $0xff,%eax
  800333:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800339:	29 d8                	sub    %ebx,%eax
  80033b:	eb 0b                	jmp    800348 <memcmp+0x34>
		s1++, s2++;
  80033d:	42                   	inc    %edx
  80033e:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80033f:	39 f2                	cmp    %esi,%edx
  800341:	75 e3                	jne    800326 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800343:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800348:	5b                   	pop    %ebx
  800349:	5e                   	pop    %esi
  80034a:	5d                   	pop    %ebp
  80034b:	c3                   	ret    

0080034c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	8b 45 08             	mov    0x8(%ebp),%eax
  800352:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800355:	89 c2                	mov    %eax,%edx
  800357:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80035a:	eb 05                	jmp    800361 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  80035c:	38 08                	cmp    %cl,(%eax)
  80035e:	74 05                	je     800365 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800360:	40                   	inc    %eax
  800361:	39 d0                	cmp    %edx,%eax
  800363:	72 f7                	jb     80035c <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
  80036a:	57                   	push   %edi
  80036b:	56                   	push   %esi
  80036c:	53                   	push   %ebx
  80036d:	8b 55 08             	mov    0x8(%ebp),%edx
  800370:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800373:	eb 01                	jmp    800376 <strtol+0xf>
		s++;
  800375:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800376:	8a 02                	mov    (%edx),%al
  800378:	3c 09                	cmp    $0x9,%al
  80037a:	74 f9                	je     800375 <strtol+0xe>
  80037c:	3c 20                	cmp    $0x20,%al
  80037e:	74 f5                	je     800375 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800380:	3c 2b                	cmp    $0x2b,%al
  800382:	75 08                	jne    80038c <strtol+0x25>
		s++;
  800384:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800385:	bf 00 00 00 00       	mov    $0x0,%edi
  80038a:	eb 10                	jmp    80039c <strtol+0x35>
  80038c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800391:	3c 2d                	cmp    $0x2d,%al
  800393:	75 07                	jne    80039c <strtol+0x35>
		s++, neg = 1;
  800395:	8d 52 01             	lea    0x1(%edx),%edx
  800398:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80039c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8003a2:	75 15                	jne    8003b9 <strtol+0x52>
  8003a4:	80 3a 30             	cmpb   $0x30,(%edx)
  8003a7:	75 10                	jne    8003b9 <strtol+0x52>
  8003a9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8003ad:	75 0a                	jne    8003b9 <strtol+0x52>
		s += 2, base = 16;
  8003af:	83 c2 02             	add    $0x2,%edx
  8003b2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8003b7:	eb 0e                	jmp    8003c7 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  8003b9:	85 db                	test   %ebx,%ebx
  8003bb:	75 0a                	jne    8003c7 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8003bd:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8003bf:	80 3a 30             	cmpb   $0x30,(%edx)
  8003c2:	75 03                	jne    8003c7 <strtol+0x60>
		s++, base = 8;
  8003c4:	42                   	inc    %edx
  8003c5:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  8003c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8003cf:	8a 0a                	mov    (%edx),%cl
  8003d1:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8003d4:	89 f3                	mov    %esi,%ebx
  8003d6:	80 fb 09             	cmp    $0x9,%bl
  8003d9:	77 08                	ja     8003e3 <strtol+0x7c>
			dig = *s - '0';
  8003db:	0f be c9             	movsbl %cl,%ecx
  8003de:	83 e9 30             	sub    $0x30,%ecx
  8003e1:	eb 22                	jmp    800405 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  8003e3:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8003e6:	89 f3                	mov    %esi,%ebx
  8003e8:	80 fb 19             	cmp    $0x19,%bl
  8003eb:	77 08                	ja     8003f5 <strtol+0x8e>
			dig = *s - 'a' + 10;
  8003ed:	0f be c9             	movsbl %cl,%ecx
  8003f0:	83 e9 57             	sub    $0x57,%ecx
  8003f3:	eb 10                	jmp    800405 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  8003f5:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8003f8:	89 f3                	mov    %esi,%ebx
  8003fa:	80 fb 19             	cmp    $0x19,%bl
  8003fd:	77 14                	ja     800413 <strtol+0xac>
			dig = *s - 'A' + 10;
  8003ff:	0f be c9             	movsbl %cl,%ecx
  800402:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800405:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800408:	7d 0d                	jge    800417 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  80040a:	42                   	inc    %edx
  80040b:	0f af 45 10          	imul   0x10(%ebp),%eax
  80040f:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800411:	eb bc                	jmp    8003cf <strtol+0x68>
  800413:	89 c1                	mov    %eax,%ecx
  800415:	eb 02                	jmp    800419 <strtol+0xb2>
  800417:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800419:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80041d:	74 05                	je     800424 <strtol+0xbd>
		*endptr = (char *) s;
  80041f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800422:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800424:	85 ff                	test   %edi,%edi
  800426:	74 04                	je     80042c <strtol+0xc5>
  800428:	89 c8                	mov    %ecx,%eax
  80042a:	f7 d8                	neg    %eax
}
  80042c:	5b                   	pop    %ebx
  80042d:	5e                   	pop    %esi
  80042e:	5f                   	pop    %edi
  80042f:	5d                   	pop    %ebp
  800430:	c3                   	ret    
  800431:	66 90                	xchg   %ax,%ax
  800433:	90                   	nop

00800434 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	57                   	push   %edi
  800438:	56                   	push   %esi
  800439:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80043a:	b8 00 00 00 00       	mov    $0x0,%eax
  80043f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800442:	8b 55 08             	mov    0x8(%ebp),%edx
  800445:	89 c3                	mov    %eax,%ebx
  800447:	89 c7                	mov    %eax,%edi
  800449:	89 c6                	mov    %eax,%esi
  80044b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80044d:	5b                   	pop    %ebx
  80044e:	5e                   	pop    %esi
  80044f:	5f                   	pop    %edi
  800450:	5d                   	pop    %ebp
  800451:	c3                   	ret    

00800452 <sys_cgetc>:

int
sys_cgetc(void)
{
  800452:	55                   	push   %ebp
  800453:	89 e5                	mov    %esp,%ebp
  800455:	57                   	push   %edi
  800456:	56                   	push   %esi
  800457:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800458:	ba 00 00 00 00       	mov    $0x0,%edx
  80045d:	b8 01 00 00 00       	mov    $0x1,%eax
  800462:	89 d1                	mov    %edx,%ecx
  800464:	89 d3                	mov    %edx,%ebx
  800466:	89 d7                	mov    %edx,%edi
  800468:	89 d6                	mov    %edx,%esi
  80046a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80046c:	5b                   	pop    %ebx
  80046d:	5e                   	pop    %esi
  80046e:	5f                   	pop    %edi
  80046f:	5d                   	pop    %ebp
  800470:	c3                   	ret    

00800471 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800471:	55                   	push   %ebp
  800472:	89 e5                	mov    %esp,%ebp
  800474:	57                   	push   %edi
  800475:	56                   	push   %esi
  800476:	53                   	push   %ebx
  800477:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80047a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80047f:	b8 03 00 00 00       	mov    $0x3,%eax
  800484:	8b 55 08             	mov    0x8(%ebp),%edx
  800487:	89 cb                	mov    %ecx,%ebx
  800489:	89 cf                	mov    %ecx,%edi
  80048b:	89 ce                	mov    %ecx,%esi
  80048d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80048f:	85 c0                	test   %eax,%eax
  800491:	7e 28                	jle    8004bb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800493:	89 44 24 10          	mov    %eax,0x10(%esp)
  800497:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80049e:	00 
  80049f:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8004a6:	00 
  8004a7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004ae:	00 
  8004af:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8004b6:	e8 5d 02 00 00       	call   800718 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8004bb:	83 c4 2c             	add    $0x2c,%esp
  8004be:	5b                   	pop    %ebx
  8004bf:	5e                   	pop    %esi
  8004c0:	5f                   	pop    %edi
  8004c1:	5d                   	pop    %ebp
  8004c2:	c3                   	ret    

008004c3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8004c3:	55                   	push   %ebp
  8004c4:	89 e5                	mov    %esp,%ebp
  8004c6:	57                   	push   %edi
  8004c7:	56                   	push   %esi
  8004c8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ce:	b8 02 00 00 00       	mov    $0x2,%eax
  8004d3:	89 d1                	mov    %edx,%ecx
  8004d5:	89 d3                	mov    %edx,%ebx
  8004d7:	89 d7                	mov    %edx,%edi
  8004d9:	89 d6                	mov    %edx,%esi
  8004db:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8004dd:	5b                   	pop    %ebx
  8004de:	5e                   	pop    %esi
  8004df:	5f                   	pop    %edi
  8004e0:	5d                   	pop    %ebp
  8004e1:	c3                   	ret    

008004e2 <sys_yield>:

void
sys_yield(void)
{
  8004e2:	55                   	push   %ebp
  8004e3:	89 e5                	mov    %esp,%ebp
  8004e5:	57                   	push   %edi
  8004e6:	56                   	push   %esi
  8004e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ed:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004f2:	89 d1                	mov    %edx,%ecx
  8004f4:	89 d3                	mov    %edx,%ebx
  8004f6:	89 d7                	mov    %edx,%edi
  8004f8:	89 d6                	mov    %edx,%esi
  8004fa:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8004fc:	5b                   	pop    %ebx
  8004fd:	5e                   	pop    %esi
  8004fe:	5f                   	pop    %edi
  8004ff:	5d                   	pop    %ebp
  800500:	c3                   	ret    

00800501 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800501:	55                   	push   %ebp
  800502:	89 e5                	mov    %esp,%ebp
  800504:	57                   	push   %edi
  800505:	56                   	push   %esi
  800506:	53                   	push   %ebx
  800507:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80050a:	be 00 00 00 00       	mov    $0x0,%esi
  80050f:	b8 04 00 00 00       	mov    $0x4,%eax
  800514:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800517:	8b 55 08             	mov    0x8(%ebp),%edx
  80051a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80051d:	89 f7                	mov    %esi,%edi
  80051f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800521:	85 c0                	test   %eax,%eax
  800523:	7e 28                	jle    80054d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800525:	89 44 24 10          	mov    %eax,0x10(%esp)
  800529:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800530:	00 
  800531:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800538:	00 
  800539:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800540:	00 
  800541:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800548:	e8 cb 01 00 00       	call   800718 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80054d:	83 c4 2c             	add    $0x2c,%esp
  800550:	5b                   	pop    %ebx
  800551:	5e                   	pop    %esi
  800552:	5f                   	pop    %edi
  800553:	5d                   	pop    %ebp
  800554:	c3                   	ret    

00800555 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800555:	55                   	push   %ebp
  800556:	89 e5                	mov    %esp,%ebp
  800558:	57                   	push   %edi
  800559:	56                   	push   %esi
  80055a:	53                   	push   %ebx
  80055b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80055e:	b8 05 00 00 00       	mov    $0x5,%eax
  800563:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800566:	8b 55 08             	mov    0x8(%ebp),%edx
  800569:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80056c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80056f:	8b 75 18             	mov    0x18(%ebp),%esi
  800572:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800574:	85 c0                	test   %eax,%eax
  800576:	7e 28                	jle    8005a0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800578:	89 44 24 10          	mov    %eax,0x10(%esp)
  80057c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800583:	00 
  800584:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  80058b:	00 
  80058c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800593:	00 
  800594:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  80059b:	e8 78 01 00 00       	call   800718 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8005a0:	83 c4 2c             	add    $0x2c,%esp
  8005a3:	5b                   	pop    %ebx
  8005a4:	5e                   	pop    %esi
  8005a5:	5f                   	pop    %edi
  8005a6:	5d                   	pop    %ebp
  8005a7:	c3                   	ret    

008005a8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8005a8:	55                   	push   %ebp
  8005a9:	89 e5                	mov    %esp,%ebp
  8005ab:	57                   	push   %edi
  8005ac:	56                   	push   %esi
  8005ad:	53                   	push   %ebx
  8005ae:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005b6:	b8 06 00 00 00       	mov    $0x6,%eax
  8005bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005be:	8b 55 08             	mov    0x8(%ebp),%edx
  8005c1:	89 df                	mov    %ebx,%edi
  8005c3:	89 de                	mov    %ebx,%esi
  8005c5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005c7:	85 c0                	test   %eax,%eax
  8005c9:	7e 28                	jle    8005f3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005cb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005cf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8005d6:	00 
  8005d7:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8005de:	00 
  8005df:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005e6:	00 
  8005e7:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8005ee:	e8 25 01 00 00       	call   800718 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8005f3:	83 c4 2c             	add    $0x2c,%esp
  8005f6:	5b                   	pop    %ebx
  8005f7:	5e                   	pop    %esi
  8005f8:	5f                   	pop    %edi
  8005f9:	5d                   	pop    %ebp
  8005fa:	c3                   	ret    

008005fb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8005fb:	55                   	push   %ebp
  8005fc:	89 e5                	mov    %esp,%ebp
  8005fe:	57                   	push   %edi
  8005ff:	56                   	push   %esi
  800600:	53                   	push   %ebx
  800601:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800604:	bb 00 00 00 00       	mov    $0x0,%ebx
  800609:	b8 08 00 00 00       	mov    $0x8,%eax
  80060e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800611:	8b 55 08             	mov    0x8(%ebp),%edx
  800614:	89 df                	mov    %ebx,%edi
  800616:	89 de                	mov    %ebx,%esi
  800618:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80061a:	85 c0                	test   %eax,%eax
  80061c:	7e 28                	jle    800646 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80061e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800622:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800629:	00 
  80062a:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800631:	00 
  800632:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800639:	00 
  80063a:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800641:	e8 d2 00 00 00       	call   800718 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800646:	83 c4 2c             	add    $0x2c,%esp
  800649:	5b                   	pop    %ebx
  80064a:	5e                   	pop    %esi
  80064b:	5f                   	pop    %edi
  80064c:	5d                   	pop    %ebp
  80064d:	c3                   	ret    

0080064e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80064e:	55                   	push   %ebp
  80064f:	89 e5                	mov    %esp,%ebp
  800651:	57                   	push   %edi
  800652:	56                   	push   %esi
  800653:	53                   	push   %ebx
  800654:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800657:	bb 00 00 00 00       	mov    $0x0,%ebx
  80065c:	b8 09 00 00 00       	mov    $0x9,%eax
  800661:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800664:	8b 55 08             	mov    0x8(%ebp),%edx
  800667:	89 df                	mov    %ebx,%edi
  800669:	89 de                	mov    %ebx,%esi
  80066b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80066d:	85 c0                	test   %eax,%eax
  80066f:	7e 28                	jle    800699 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800671:	89 44 24 10          	mov    %eax,0x10(%esp)
  800675:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80067c:	00 
  80067d:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800684:	00 
  800685:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80068c:	00 
  80068d:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800694:	e8 7f 00 00 00       	call   800718 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800699:	83 c4 2c             	add    $0x2c,%esp
  80069c:	5b                   	pop    %ebx
  80069d:	5e                   	pop    %esi
  80069e:	5f                   	pop    %edi
  80069f:	5d                   	pop    %ebp
  8006a0:	c3                   	ret    

008006a1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8006a1:	55                   	push   %ebp
  8006a2:	89 e5                	mov    %esp,%ebp
  8006a4:	57                   	push   %edi
  8006a5:	56                   	push   %esi
  8006a6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006a7:	be 00 00 00 00       	mov    $0x0,%esi
  8006ac:	b8 0b 00 00 00       	mov    $0xb,%eax
  8006b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8006b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006ba:	8b 7d 14             	mov    0x14(%ebp),%edi
  8006bd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8006bf:	5b                   	pop    %ebx
  8006c0:	5e                   	pop    %esi
  8006c1:	5f                   	pop    %edi
  8006c2:	5d                   	pop    %ebp
  8006c3:	c3                   	ret    

008006c4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	57                   	push   %edi
  8006c8:	56                   	push   %esi
  8006c9:	53                   	push   %ebx
  8006ca:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8006d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8006da:	89 cb                	mov    %ecx,%ebx
  8006dc:	89 cf                	mov    %ecx,%edi
  8006de:	89 ce                	mov    %ecx,%esi
  8006e0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006e2:	85 c0                	test   %eax,%eax
  8006e4:	7e 28                	jle    80070e <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ea:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8006f1:	00 
  8006f2:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8006f9:	00 
  8006fa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800701:	00 
  800702:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800709:	e8 0a 00 00 00       	call   800718 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80070e:	83 c4 2c             	add    $0x2c,%esp
  800711:	5b                   	pop    %ebx
  800712:	5e                   	pop    %esi
  800713:	5f                   	pop    %edi
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    
  800716:	66 90                	xchg   %ax,%ax

00800718 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	56                   	push   %esi
  80071c:	53                   	push   %ebx
  80071d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800720:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800723:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800729:	e8 95 fd ff ff       	call   8004c3 <sys_getenvid>
  80072e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800731:	89 54 24 10          	mov    %edx,0x10(%esp)
  800735:	8b 55 08             	mov    0x8(%ebp),%edx
  800738:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80073c:	89 74 24 08          	mov    %esi,0x8(%esp)
  800740:	89 44 24 04          	mov    %eax,0x4(%esp)
  800744:	c7 04 24 b8 10 80 00 	movl   $0x8010b8,(%esp)
  80074b:	e8 c2 00 00 00       	call   800812 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800750:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800754:	8b 45 10             	mov    0x10(%ebp),%eax
  800757:	89 04 24             	mov    %eax,(%esp)
  80075a:	e8 52 00 00 00       	call   8007b1 <vcprintf>
	cprintf("\n");
  80075f:	c7 04 24 dc 10 80 00 	movl   $0x8010dc,(%esp)
  800766:	e8 a7 00 00 00       	call   800812 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80076b:	cc                   	int3   
  80076c:	eb fd                	jmp    80076b <_panic+0x53>
  80076e:	66 90                	xchg   %ax,%ax

00800770 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	53                   	push   %ebx
  800774:	83 ec 14             	sub    $0x14,%esp
  800777:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80077a:	8b 13                	mov    (%ebx),%edx
  80077c:	8d 42 01             	lea    0x1(%edx),%eax
  80077f:	89 03                	mov    %eax,(%ebx)
  800781:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800784:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800788:	3d ff 00 00 00       	cmp    $0xff,%eax
  80078d:	75 19                	jne    8007a8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80078f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800796:	00 
  800797:	8d 43 08             	lea    0x8(%ebx),%eax
  80079a:	89 04 24             	mov    %eax,(%esp)
  80079d:	e8 92 fc ff ff       	call   800434 <sys_cputs>
		b->idx = 0;
  8007a2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8007a8:	ff 43 04             	incl   0x4(%ebx)
}
  8007ab:	83 c4 14             	add    $0x14,%esp
  8007ae:	5b                   	pop    %ebx
  8007af:	5d                   	pop    %ebp
  8007b0:	c3                   	ret    

008007b1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8007ba:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8007c1:	00 00 00 
	b.cnt = 0;
  8007c4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8007cb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8007ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007dc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8007e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e6:	c7 04 24 70 07 80 00 	movl   $0x800770,(%esp)
  8007ed:	e8 a9 01 00 00       	call   80099b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8007f2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8007f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800802:	89 04 24             	mov    %eax,(%esp)
  800805:	e8 2a fc ff ff       	call   800434 <sys_cputs>

	return b.cnt;
}
  80080a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800818:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80081b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	89 04 24             	mov    %eax,(%esp)
  800825:	e8 87 ff ff ff       	call   8007b1 <vcprintf>
	va_end(ap);

	return cnt;
}
  80082a:	c9                   	leave  
  80082b:	c3                   	ret    

0080082c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	57                   	push   %edi
  800830:	56                   	push   %esi
  800831:	53                   	push   %ebx
  800832:	83 ec 3c             	sub    $0x3c,%esp
  800835:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800838:	89 d7                	mov    %edx,%edi
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800840:	8b 45 0c             	mov    0xc(%ebp),%eax
  800843:	89 c1                	mov    %eax,%ecx
  800845:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800848:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80084b:	8b 45 10             	mov    0x10(%ebp),%eax
  80084e:	ba 00 00 00 00       	mov    $0x0,%edx
  800853:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800856:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800859:	39 ca                	cmp    %ecx,%edx
  80085b:	72 08                	jb     800865 <printnum+0x39>
  80085d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800860:	39 45 10             	cmp    %eax,0x10(%ebp)
  800863:	77 6a                	ja     8008cf <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800865:	8b 45 18             	mov    0x18(%ebp),%eax
  800868:	89 44 24 10          	mov    %eax,0x10(%esp)
  80086c:	4e                   	dec    %esi
  80086d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800871:	8b 45 10             	mov    0x10(%ebp),%eax
  800874:	89 44 24 08          	mov    %eax,0x8(%esp)
  800878:	8b 44 24 08          	mov    0x8(%esp),%eax
  80087c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800880:	89 c3                	mov    %eax,%ebx
  800882:	89 d6                	mov    %edx,%esi
  800884:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800887:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80088a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800892:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800895:	89 04 24             	mov    %eax,(%esp)
  800898:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80089b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80089f:	e8 2c 05 00 00       	call   800dd0 <__udivdi3>
  8008a4:	89 d9                	mov    %ebx,%ecx
  8008a6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008aa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008ae:	89 04 24             	mov    %eax,(%esp)
  8008b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b5:	89 fa                	mov    %edi,%edx
  8008b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008ba:	e8 6d ff ff ff       	call   80082c <printnum>
  8008bf:	eb 19                	jmp    8008da <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8008c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008c5:	8b 45 18             	mov    0x18(%ebp),%eax
  8008c8:	89 04 24             	mov    %eax,(%esp)
  8008cb:	ff d3                	call   *%ebx
  8008cd:	eb 03                	jmp    8008d2 <printnum+0xa6>
  8008cf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8008d2:	4e                   	dec    %esi
  8008d3:	85 f6                	test   %esi,%esi
  8008d5:	7f ea                	jg     8008c1 <printnum+0x95>
  8008d7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8008da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008de:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8008e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008e5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008f3:	89 04 24             	mov    %eax,(%esp)
  8008f6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8008f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fd:	e8 fe 05 00 00       	call   800f00 <__umoddi3>
  800902:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800906:	0f be 80 de 10 80 00 	movsbl 0x8010de(%eax),%eax
  80090d:	89 04 24             	mov    %eax,(%esp)
  800910:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800913:	ff d0                	call   *%eax
}
  800915:	83 c4 3c             	add    $0x3c,%esp
  800918:	5b                   	pop    %ebx
  800919:	5e                   	pop    %esi
  80091a:	5f                   	pop    %edi
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800920:	83 fa 01             	cmp    $0x1,%edx
  800923:	7e 0e                	jle    800933 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800925:	8b 10                	mov    (%eax),%edx
  800927:	8d 4a 08             	lea    0x8(%edx),%ecx
  80092a:	89 08                	mov    %ecx,(%eax)
  80092c:	8b 02                	mov    (%edx),%eax
  80092e:	8b 52 04             	mov    0x4(%edx),%edx
  800931:	eb 22                	jmp    800955 <getuint+0x38>
	else if (lflag)
  800933:	85 d2                	test   %edx,%edx
  800935:	74 10                	je     800947 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800937:	8b 10                	mov    (%eax),%edx
  800939:	8d 4a 04             	lea    0x4(%edx),%ecx
  80093c:	89 08                	mov    %ecx,(%eax)
  80093e:	8b 02                	mov    (%edx),%eax
  800940:	ba 00 00 00 00       	mov    $0x0,%edx
  800945:	eb 0e                	jmp    800955 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800947:	8b 10                	mov    (%eax),%edx
  800949:	8d 4a 04             	lea    0x4(%edx),%ecx
  80094c:	89 08                	mov    %ecx,(%eax)
  80094e:	8b 02                	mov    (%edx),%eax
  800950:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80095d:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800960:	8b 10                	mov    (%eax),%edx
  800962:	3b 50 04             	cmp    0x4(%eax),%edx
  800965:	73 0a                	jae    800971 <sprintputch+0x1a>
		*b->buf++ = ch;
  800967:	8d 4a 01             	lea    0x1(%edx),%ecx
  80096a:	89 08                	mov    %ecx,(%eax)
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	88 02                	mov    %al,(%edx)
}
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800979:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80097c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800980:	8b 45 10             	mov    0x10(%ebp),%eax
  800983:	89 44 24 08          	mov    %eax,0x8(%esp)
  800987:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	89 04 24             	mov    %eax,(%esp)
  800994:	e8 02 00 00 00       	call   80099b <vprintfmt>
	va_end(ap);
}
  800999:	c9                   	leave  
  80099a:	c3                   	ret    

0080099b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	57                   	push   %edi
  80099f:	56                   	push   %esi
  8009a0:	53                   	push   %ebx
  8009a1:	83 ec 3c             	sub    $0x3c,%esp
  8009a4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8009a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009aa:	eb 14                	jmp    8009c0 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8009ac:	85 c0                	test   %eax,%eax
  8009ae:	0f 84 8a 03 00 00    	je     800d3e <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  8009b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009b8:	89 04 24             	mov    %eax,(%esp)
  8009bb:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8009be:	89 f3                	mov    %esi,%ebx
  8009c0:	8d 73 01             	lea    0x1(%ebx),%esi
  8009c3:	31 c0                	xor    %eax,%eax
  8009c5:	8a 03                	mov    (%ebx),%al
  8009c7:	83 f8 25             	cmp    $0x25,%eax
  8009ca:	75 e0                	jne    8009ac <vprintfmt+0x11>
  8009cc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8009d0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8009d7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8009de:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8009e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ea:	eb 1d                	jmp    800a09 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ec:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8009ee:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8009f2:	eb 15                	jmp    800a09 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009f4:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8009f6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8009fa:	eb 0d                	jmp    800a09 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8009fc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8009ff:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a02:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a09:	8d 5e 01             	lea    0x1(%esi),%ebx
  800a0c:	31 c0                	xor    %eax,%eax
  800a0e:	8a 06                	mov    (%esi),%al
  800a10:	8a 0e                	mov    (%esi),%cl
  800a12:	83 e9 23             	sub    $0x23,%ecx
  800a15:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800a18:	80 f9 55             	cmp    $0x55,%cl
  800a1b:	0f 87 ff 02 00 00    	ja     800d20 <vprintfmt+0x385>
  800a21:	31 c9                	xor    %ecx,%ecx
  800a23:	8a 4d e0             	mov    -0x20(%ebp),%cl
  800a26:	ff 24 8d a0 11 80 00 	jmp    *0x8011a0(,%ecx,4)
  800a2d:	89 de                	mov    %ebx,%esi
  800a2f:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800a34:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800a37:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800a3b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800a3e:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800a41:	83 fb 09             	cmp    $0x9,%ebx
  800a44:	77 2f                	ja     800a75 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800a46:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800a47:	eb eb                	jmp    800a34 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800a49:	8b 45 14             	mov    0x14(%ebp),%eax
  800a4c:	8d 48 04             	lea    0x4(%eax),%ecx
  800a4f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a52:	8b 00                	mov    (%eax),%eax
  800a54:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a57:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800a59:	eb 1d                	jmp    800a78 <vprintfmt+0xdd>
  800a5b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a5e:	f7 d0                	not    %eax
  800a60:	c1 f8 1f             	sar    $0x1f,%eax
  800a63:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a66:	89 de                	mov    %ebx,%esi
  800a68:	eb 9f                	jmp    800a09 <vprintfmt+0x6e>
  800a6a:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800a6c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800a73:	eb 94                	jmp    800a09 <vprintfmt+0x6e>
  800a75:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800a78:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a7c:	79 8b                	jns    800a09 <vprintfmt+0x6e>
  800a7e:	e9 79 ff ff ff       	jmp    8009fc <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800a83:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a84:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800a86:	eb 81                	jmp    800a09 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800a88:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8b:	8d 50 04             	lea    0x4(%eax),%edx
  800a8e:	89 55 14             	mov    %edx,0x14(%ebp)
  800a91:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a95:	8b 00                	mov    (%eax),%eax
  800a97:	89 04 24             	mov    %eax,(%esp)
  800a9a:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a9d:	e9 1e ff ff ff       	jmp    8009c0 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800aa2:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa5:	8d 50 04             	lea    0x4(%eax),%edx
  800aa8:	89 55 14             	mov    %edx,0x14(%ebp)
  800aab:	8b 00                	mov    (%eax),%eax
  800aad:	89 c2                	mov    %eax,%edx
  800aaf:	c1 fa 1f             	sar    $0x1f,%edx
  800ab2:	31 d0                	xor    %edx,%eax
  800ab4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800ab6:	83 f8 09             	cmp    $0x9,%eax
  800ab9:	7f 0b                	jg     800ac6 <vprintfmt+0x12b>
  800abb:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  800ac2:	85 d2                	test   %edx,%edx
  800ac4:	75 20                	jne    800ae6 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  800ac6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aca:	c7 44 24 08 f6 10 80 	movl   $0x8010f6,0x8(%esp)
  800ad1:	00 
  800ad2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ad6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad9:	89 04 24             	mov    %eax,(%esp)
  800adc:	e8 92 fe ff ff       	call   800973 <printfmt>
  800ae1:	e9 da fe ff ff       	jmp    8009c0 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800ae6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800aea:	c7 44 24 08 ff 10 80 	movl   $0x8010ff,0x8(%esp)
  800af1:	00 
  800af2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800af6:	8b 45 08             	mov    0x8(%ebp),%eax
  800af9:	89 04 24             	mov    %eax,(%esp)
  800afc:	e8 72 fe ff ff       	call   800973 <printfmt>
  800b01:	e9 ba fe ff ff       	jmp    8009c0 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b06:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800b09:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b0c:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800b0f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b12:	8d 50 04             	lea    0x4(%eax),%edx
  800b15:	89 55 14             	mov    %edx,0x14(%ebp)
  800b18:	8b 30                	mov    (%eax),%esi
  800b1a:	85 f6                	test   %esi,%esi
  800b1c:	75 05                	jne    800b23 <vprintfmt+0x188>
				p = "(null)";
  800b1e:	be ef 10 80 00       	mov    $0x8010ef,%esi
			if (width > 0 && padc != '-')
  800b23:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800b27:	0f 84 8c 00 00 00    	je     800bb9 <vprintfmt+0x21e>
  800b2d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b31:	0f 8e 8a 00 00 00    	jle    800bc1 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b37:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b3b:	89 34 24             	mov    %esi,(%esp)
  800b3e:	e8 9b f5 ff ff       	call   8000de <strnlen>
  800b43:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800b46:	29 c1                	sub    %eax,%ecx
  800b48:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800b4b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800b4f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b52:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800b55:	8b 75 08             	mov    0x8(%ebp),%esi
  800b58:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b5b:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b5d:	eb 0d                	jmp    800b6c <vprintfmt+0x1d1>
					putch(padc, putdat);
  800b5f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b63:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b66:	89 04 24             	mov    %eax,(%esp)
  800b69:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b6b:	4b                   	dec    %ebx
  800b6c:	85 db                	test   %ebx,%ebx
  800b6e:	7f ef                	jg     800b5f <vprintfmt+0x1c4>
  800b70:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800b73:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b76:	89 c8                	mov    %ecx,%eax
  800b78:	f7 d0                	not    %eax
  800b7a:	c1 f8 1f             	sar    $0x1f,%eax
  800b7d:	21 c8                	and    %ecx,%eax
  800b7f:	29 c1                	sub    %eax,%ecx
  800b81:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b84:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800b87:	eb 3e                	jmp    800bc7 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b89:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800b8d:	74 1b                	je     800baa <vprintfmt+0x20f>
  800b8f:	0f be d2             	movsbl %dl,%edx
  800b92:	83 ea 20             	sub    $0x20,%edx
  800b95:	83 fa 5e             	cmp    $0x5e,%edx
  800b98:	76 10                	jbe    800baa <vprintfmt+0x20f>
					putch('?', putdat);
  800b9a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b9e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800ba5:	ff 55 08             	call   *0x8(%ebp)
  800ba8:	eb 0a                	jmp    800bb4 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800baa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bae:	89 04 24             	mov    %eax,(%esp)
  800bb1:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bb4:	ff 4d dc             	decl   -0x24(%ebp)
  800bb7:	eb 0e                	jmp    800bc7 <vprintfmt+0x22c>
  800bb9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bbc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800bbf:	eb 06                	jmp    800bc7 <vprintfmt+0x22c>
  800bc1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bc4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800bc7:	46                   	inc    %esi
  800bc8:	8a 56 ff             	mov    -0x1(%esi),%dl
  800bcb:	0f be c2             	movsbl %dl,%eax
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	74 1f                	je     800bf1 <vprintfmt+0x256>
  800bd2:	85 db                	test   %ebx,%ebx
  800bd4:	78 b3                	js     800b89 <vprintfmt+0x1ee>
  800bd6:	4b                   	dec    %ebx
  800bd7:	79 b0                	jns    800b89 <vprintfmt+0x1ee>
  800bd9:	8b 75 08             	mov    0x8(%ebp),%esi
  800bdc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800bdf:	eb 16                	jmp    800bf7 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800be1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800be5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800bec:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800bee:	4b                   	dec    %ebx
  800bef:	eb 06                	jmp    800bf7 <vprintfmt+0x25c>
  800bf1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800bf4:	8b 75 08             	mov    0x8(%ebp),%esi
  800bf7:	85 db                	test   %ebx,%ebx
  800bf9:	7f e6                	jg     800be1 <vprintfmt+0x246>
  800bfb:	89 75 08             	mov    %esi,0x8(%ebp)
  800bfe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c01:	e9 ba fd ff ff       	jmp    8009c0 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c06:	83 fa 01             	cmp    $0x1,%edx
  800c09:	7e 16                	jle    800c21 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  800c0b:	8b 45 14             	mov    0x14(%ebp),%eax
  800c0e:	8d 50 08             	lea    0x8(%eax),%edx
  800c11:	89 55 14             	mov    %edx,0x14(%ebp)
  800c14:	8b 50 04             	mov    0x4(%eax),%edx
  800c17:	8b 00                	mov    (%eax),%eax
  800c19:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c1c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c1f:	eb 32                	jmp    800c53 <vprintfmt+0x2b8>
	else if (lflag)
  800c21:	85 d2                	test   %edx,%edx
  800c23:	74 18                	je     800c3d <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800c25:	8b 45 14             	mov    0x14(%ebp),%eax
  800c28:	8d 50 04             	lea    0x4(%eax),%edx
  800c2b:	89 55 14             	mov    %edx,0x14(%ebp)
  800c2e:	8b 30                	mov    (%eax),%esi
  800c30:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800c33:	89 f0                	mov    %esi,%eax
  800c35:	c1 f8 1f             	sar    $0x1f,%eax
  800c38:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c3b:	eb 16                	jmp    800c53 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800c3d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c40:	8d 50 04             	lea    0x4(%eax),%edx
  800c43:	89 55 14             	mov    %edx,0x14(%ebp)
  800c46:	8b 30                	mov    (%eax),%esi
  800c48:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800c4b:	89 f0                	mov    %esi,%eax
  800c4d:	c1 f8 1f             	sar    $0x1f,%eax
  800c50:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c53:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c56:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800c59:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800c5e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c62:	0f 89 80 00 00 00    	jns    800ce8 <vprintfmt+0x34d>
				putch('-', putdat);
  800c68:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c6c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800c73:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800c76:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c79:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c7c:	f7 d8                	neg    %eax
  800c7e:	83 d2 00             	adc    $0x0,%edx
  800c81:	f7 da                	neg    %edx
			}
			base = 10;
  800c83:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c88:	eb 5e                	jmp    800ce8 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800c8a:	8d 45 14             	lea    0x14(%ebp),%eax
  800c8d:	e8 8b fc ff ff       	call   80091d <getuint>
			base = 10;
  800c92:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800c97:	eb 4f                	jmp    800ce8 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800c99:	8d 45 14             	lea    0x14(%ebp),%eax
  800c9c:	e8 7c fc ff ff       	call   80091d <getuint>
			base = 8;
  800ca1:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800ca6:	eb 40                	jmp    800ce8 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800ca8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cac:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800cb3:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800cb6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cba:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800cc1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800cc4:	8b 45 14             	mov    0x14(%ebp),%eax
  800cc7:	8d 50 04             	lea    0x4(%eax),%edx
  800cca:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800ccd:	8b 00                	mov    (%eax),%eax
  800ccf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800cd4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800cd9:	eb 0d                	jmp    800ce8 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800cdb:	8d 45 14             	lea    0x14(%ebp),%eax
  800cde:	e8 3a fc ff ff       	call   80091d <getuint>
			base = 16;
  800ce3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ce8:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800cec:	89 74 24 10          	mov    %esi,0x10(%esp)
  800cf0:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800cf3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800cf7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cfb:	89 04 24             	mov    %eax,(%esp)
  800cfe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d02:	89 fa                	mov    %edi,%edx
  800d04:	8b 45 08             	mov    0x8(%ebp),%eax
  800d07:	e8 20 fb ff ff       	call   80082c <printnum>
			break;
  800d0c:	e9 af fc ff ff       	jmp    8009c0 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d11:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d15:	89 04 24             	mov    %eax,(%esp)
  800d18:	ff 55 08             	call   *0x8(%ebp)
			break;
  800d1b:	e9 a0 fc ff ff       	jmp    8009c0 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d20:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d24:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800d2b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d2e:	89 f3                	mov    %esi,%ebx
  800d30:	eb 01                	jmp    800d33 <vprintfmt+0x398>
  800d32:	4b                   	dec    %ebx
  800d33:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800d37:	75 f9                	jne    800d32 <vprintfmt+0x397>
  800d39:	e9 82 fc ff ff       	jmp    8009c0 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800d3e:	83 c4 3c             	add    $0x3c,%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	83 ec 28             	sub    $0x28,%esp
  800d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d52:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d55:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d59:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d5c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d63:	85 c0                	test   %eax,%eax
  800d65:	74 30                	je     800d97 <vsnprintf+0x51>
  800d67:	85 d2                	test   %edx,%edx
  800d69:	7e 2c                	jle    800d97 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d6b:	8b 45 14             	mov    0x14(%ebp),%eax
  800d6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d72:	8b 45 10             	mov    0x10(%ebp),%eax
  800d75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d79:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d80:	c7 04 24 57 09 80 00 	movl   $0x800957,(%esp)
  800d87:	e8 0f fc ff ff       	call   80099b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d8f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d95:	eb 05                	jmp    800d9c <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d9c:	c9                   	leave  
  800d9d:	c3                   	ret    

00800d9e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800da4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800da7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dab:	8b 45 10             	mov    0x10(%ebp),%eax
  800dae:	89 44 24 08          	mov    %eax,0x8(%esp)
  800db2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800db9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbc:	89 04 24             	mov    %eax,(%esp)
  800dbf:	e8 82 ff ff ff       	call   800d46 <vsnprintf>
	va_end(ap);

	return rc;
}
  800dc4:	c9                   	leave  
  800dc5:	c3                   	ret    
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
