
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
  80004a:	e8 e5 03 00 00       	call   800434 <sys_cputs>
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
  80007f:	e8 bb 01 00 00       	call   80023f <memset>

	thisenv = 0;
	thisenv = &envs[0];
  800084:	c7 05 08 20 80 00 00 	movl   $0xeec00000,0x802008
  80008b:	00 c0 ee 
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008e:	85 db                	test   %ebx,%ebx
  800090:	7e 07                	jle    800099 <libmain+0x45>
		binaryname = argv[0];
  800092:	8b 06                	mov    (%esi),%eax
  800094:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  800099:	89 74 24 04          	mov    %esi,0x4(%esp)
  80009d:	89 1c 24             	mov    %ebx,(%esp)
  8000a0:	e8 8f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a5:	e8 0a 00 00 00       	call   8000b4 <exit>
}
  8000aa:	83 c4 10             	add    $0x10,%esp
  8000ad:	5b                   	pop    %ebx
  8000ae:	5e                   	pop    %esi
  8000af:	5d                   	pop    %ebp
  8000b0:	c3                   	ret    
  8000b1:	66 90                	xchg   %ax,%ax
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
  80049f:	c7 44 24 08 58 0e 80 	movl   $0x800e58,0x8(%esp)
  8004a6:	00 
  8004a7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004ae:	00 
  8004af:	c7 04 24 75 0e 80 00 	movl   $0x800e75,(%esp)
  8004b6:	e8 29 00 00 00       	call   8004e4 <_panic>

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
  8004e2:	66 90                	xchg   %ax,%ax

008004e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	56                   	push   %esi
  8004e8:	53                   	push   %ebx
  8004e9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8004ec:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ef:	8b 35 04 20 80 00    	mov    0x802004,%esi
  8004f5:	e8 c9 ff ff ff       	call   8004c3 <sys_getenvid>
  8004fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004fd:	89 54 24 10          	mov    %edx,0x10(%esp)
  800501:	8b 55 08             	mov    0x8(%ebp),%edx
  800504:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800508:	89 74 24 08          	mov    %esi,0x8(%esp)
  80050c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800510:	c7 04 24 84 0e 80 00 	movl   $0x800e84,(%esp)
  800517:	e8 c2 00 00 00       	call   8005de <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80051c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800520:	8b 45 10             	mov    0x10(%ebp),%eax
  800523:	89 04 24             	mov    %eax,(%esp)
  800526:	e8 52 00 00 00       	call   80057d <vcprintf>
	cprintf("\n");
  80052b:	c7 04 24 4c 0e 80 00 	movl   $0x800e4c,(%esp)
  800532:	e8 a7 00 00 00       	call   8005de <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800537:	cc                   	int3   
  800538:	eb fd                	jmp    800537 <_panic+0x53>
  80053a:	66 90                	xchg   %ax,%ax

0080053c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	53                   	push   %ebx
  800540:	83 ec 14             	sub    $0x14,%esp
  800543:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800546:	8b 13                	mov    (%ebx),%edx
  800548:	8d 42 01             	lea    0x1(%edx),%eax
  80054b:	89 03                	mov    %eax,(%ebx)
  80054d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800550:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800554:	3d ff 00 00 00       	cmp    $0xff,%eax
  800559:	75 19                	jne    800574 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80055b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800562:	00 
  800563:	8d 43 08             	lea    0x8(%ebx),%eax
  800566:	89 04 24             	mov    %eax,(%esp)
  800569:	e8 c6 fe ff ff       	call   800434 <sys_cputs>
		b->idx = 0;
  80056e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800574:	ff 43 04             	incl   0x4(%ebx)
}
  800577:	83 c4 14             	add    $0x14,%esp
  80057a:	5b                   	pop    %ebx
  80057b:	5d                   	pop    %ebp
  80057c:	c3                   	ret    

0080057d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80057d:	55                   	push   %ebp
  80057e:	89 e5                	mov    %esp,%ebp
  800580:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800586:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80058d:	00 00 00 
	b.cnt = 0;
  800590:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800597:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80059a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005a8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b2:	c7 04 24 3c 05 80 00 	movl   $0x80053c,(%esp)
  8005b9:	e8 a9 01 00 00       	call   800767 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005be:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8005c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005ce:	89 04 24             	mov    %eax,(%esp)
  8005d1:	e8 5e fe ff ff       	call   800434 <sys_cputs>

	return b.cnt;
}
  8005d6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005dc:	c9                   	leave  
  8005dd:	c3                   	ret    

008005de <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005de:	55                   	push   %ebp
  8005df:	89 e5                	mov    %esp,%ebp
  8005e1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005e4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ee:	89 04 24             	mov    %eax,(%esp)
  8005f1:	e8 87 ff ff ff       	call   80057d <vcprintf>
	va_end(ap);

	return cnt;
}
  8005f6:	c9                   	leave  
  8005f7:	c3                   	ret    

008005f8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005f8:	55                   	push   %ebp
  8005f9:	89 e5                	mov    %esp,%ebp
  8005fb:	57                   	push   %edi
  8005fc:	56                   	push   %esi
  8005fd:	53                   	push   %ebx
  8005fe:	83 ec 3c             	sub    $0x3c,%esp
  800601:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800604:	89 d7                	mov    %edx,%edi
  800606:	8b 45 08             	mov    0x8(%ebp),%eax
  800609:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80060f:	89 c1                	mov    %eax,%ecx
  800611:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800614:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800617:	8b 45 10             	mov    0x10(%ebp),%eax
  80061a:	ba 00 00 00 00       	mov    $0x0,%edx
  80061f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800622:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800625:	39 ca                	cmp    %ecx,%edx
  800627:	72 08                	jb     800631 <printnum+0x39>
  800629:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80062c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80062f:	77 6a                	ja     80069b <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800631:	8b 45 18             	mov    0x18(%ebp),%eax
  800634:	89 44 24 10          	mov    %eax,0x10(%esp)
  800638:	4e                   	dec    %esi
  800639:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80063d:	8b 45 10             	mov    0x10(%ebp),%eax
  800640:	89 44 24 08          	mov    %eax,0x8(%esp)
  800644:	8b 44 24 08          	mov    0x8(%esp),%eax
  800648:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80064c:	89 c3                	mov    %eax,%ebx
  80064e:	89 d6                	mov    %edx,%esi
  800650:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800653:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800656:	89 44 24 08          	mov    %eax,0x8(%esp)
  80065a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80065e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800661:	89 04 24             	mov    %eax,(%esp)
  800664:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800667:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066b:	e8 30 05 00 00       	call   800ba0 <__udivdi3>
  800670:	89 d9                	mov    %ebx,%ecx
  800672:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800676:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80067a:	89 04 24             	mov    %eax,(%esp)
  80067d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800681:	89 fa                	mov    %edi,%edx
  800683:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800686:	e8 6d ff ff ff       	call   8005f8 <printnum>
  80068b:	eb 19                	jmp    8006a6 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80068d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800691:	8b 45 18             	mov    0x18(%ebp),%eax
  800694:	89 04 24             	mov    %eax,(%esp)
  800697:	ff d3                	call   *%ebx
  800699:	eb 03                	jmp    80069e <printnum+0xa6>
  80069b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80069e:	4e                   	dec    %esi
  80069f:	85 f6                	test   %esi,%esi
  8006a1:	7f ea                	jg     80068d <printnum+0x95>
  8006a3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006aa:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8006ae:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006bf:	89 04 24             	mov    %eax,(%esp)
  8006c2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c9:	e8 02 06 00 00       	call   800cd0 <__umoddi3>
  8006ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d2:	0f be 80 a8 0e 80 00 	movsbl 0x800ea8(%eax),%eax
  8006d9:	89 04 24             	mov    %eax,(%esp)
  8006dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006df:	ff d0                	call   *%eax
}
  8006e1:	83 c4 3c             	add    $0x3c,%esp
  8006e4:	5b                   	pop    %ebx
  8006e5:	5e                   	pop    %esi
  8006e6:	5f                   	pop    %edi
  8006e7:	5d                   	pop    %ebp
  8006e8:	c3                   	ret    

008006e9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006ec:	83 fa 01             	cmp    $0x1,%edx
  8006ef:	7e 0e                	jle    8006ff <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8006f1:	8b 10                	mov    (%eax),%edx
  8006f3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006f6:	89 08                	mov    %ecx,(%eax)
  8006f8:	8b 02                	mov    (%edx),%eax
  8006fa:	8b 52 04             	mov    0x4(%edx),%edx
  8006fd:	eb 22                	jmp    800721 <getuint+0x38>
	else if (lflag)
  8006ff:	85 d2                	test   %edx,%edx
  800701:	74 10                	je     800713 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800703:	8b 10                	mov    (%eax),%edx
  800705:	8d 4a 04             	lea    0x4(%edx),%ecx
  800708:	89 08                	mov    %ecx,(%eax)
  80070a:	8b 02                	mov    (%edx),%eax
  80070c:	ba 00 00 00 00       	mov    $0x0,%edx
  800711:	eb 0e                	jmp    800721 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800713:	8b 10                	mov    (%eax),%edx
  800715:	8d 4a 04             	lea    0x4(%edx),%ecx
  800718:	89 08                	mov    %ecx,(%eax)
  80071a:	8b 02                	mov    (%edx),%eax
  80071c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800721:	5d                   	pop    %ebp
  800722:	c3                   	ret    

00800723 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800729:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80072c:	8b 10                	mov    (%eax),%edx
  80072e:	3b 50 04             	cmp    0x4(%eax),%edx
  800731:	73 0a                	jae    80073d <sprintputch+0x1a>
		*b->buf++ = ch;
  800733:	8d 4a 01             	lea    0x1(%edx),%ecx
  800736:	89 08                	mov    %ecx,(%eax)
  800738:	8b 45 08             	mov    0x8(%ebp),%eax
  80073b:	88 02                	mov    %al,(%edx)
}
  80073d:	5d                   	pop    %ebp
  80073e:	c3                   	ret    

0080073f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800745:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800748:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074c:	8b 45 10             	mov    0x10(%ebp),%eax
  80074f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800753:	8b 45 0c             	mov    0xc(%ebp),%eax
  800756:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075a:	8b 45 08             	mov    0x8(%ebp),%eax
  80075d:	89 04 24             	mov    %eax,(%esp)
  800760:	e8 02 00 00 00       	call   800767 <vprintfmt>
	va_end(ap);
}
  800765:	c9                   	leave  
  800766:	c3                   	ret    

00800767 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	57                   	push   %edi
  80076b:	56                   	push   %esi
  80076c:	53                   	push   %ebx
  80076d:	83 ec 3c             	sub    $0x3c,%esp
  800770:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800773:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800776:	eb 14                	jmp    80078c <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800778:	85 c0                	test   %eax,%eax
  80077a:	0f 84 8a 03 00 00    	je     800b0a <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  800780:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800784:	89 04 24             	mov    %eax,(%esp)
  800787:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80078a:	89 f3                	mov    %esi,%ebx
  80078c:	8d 73 01             	lea    0x1(%ebx),%esi
  80078f:	31 c0                	xor    %eax,%eax
  800791:	8a 03                	mov    (%ebx),%al
  800793:	83 f8 25             	cmp    $0x25,%eax
  800796:	75 e0                	jne    800778 <vprintfmt+0x11>
  800798:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80079c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8007a3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007aa:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8007b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b6:	eb 1d                	jmp    8007d5 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b8:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8007ba:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8007be:	eb 15                	jmp    8007d5 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c0:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007c2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8007c6:	eb 0d                	jmp    8007d5 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8007c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007cb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8007ce:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d5:	8d 5e 01             	lea    0x1(%esi),%ebx
  8007d8:	31 c0                	xor    %eax,%eax
  8007da:	8a 06                	mov    (%esi),%al
  8007dc:	8a 0e                	mov    (%esi),%cl
  8007de:	83 e9 23             	sub    $0x23,%ecx
  8007e1:	88 4d e0             	mov    %cl,-0x20(%ebp)
  8007e4:	80 f9 55             	cmp    $0x55,%cl
  8007e7:	0f 87 ff 02 00 00    	ja     800aec <vprintfmt+0x385>
  8007ed:	31 c9                	xor    %ecx,%ecx
  8007ef:	8a 4d e0             	mov    -0x20(%ebp),%cl
  8007f2:	ff 24 8d 40 0f 80 00 	jmp    *0x800f40(,%ecx,4)
  8007f9:	89 de                	mov    %ebx,%esi
  8007fb:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800800:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800803:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800807:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80080a:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80080d:	83 fb 09             	cmp    $0x9,%ebx
  800810:	77 2f                	ja     800841 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800812:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800813:	eb eb                	jmp    800800 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800815:	8b 45 14             	mov    0x14(%ebp),%eax
  800818:	8d 48 04             	lea    0x4(%eax),%ecx
  80081b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80081e:	8b 00                	mov    (%eax),%eax
  800820:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800823:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800825:	eb 1d                	jmp    800844 <vprintfmt+0xdd>
  800827:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80082a:	f7 d0                	not    %eax
  80082c:	c1 f8 1f             	sar    $0x1f,%eax
  80082f:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800832:	89 de                	mov    %ebx,%esi
  800834:	eb 9f                	jmp    8007d5 <vprintfmt+0x6e>
  800836:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800838:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80083f:	eb 94                	jmp    8007d5 <vprintfmt+0x6e>
  800841:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800844:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800848:	79 8b                	jns    8007d5 <vprintfmt+0x6e>
  80084a:	e9 79 ff ff ff       	jmp    8007c8 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80084f:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800850:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800852:	eb 81                	jmp    8007d5 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800854:	8b 45 14             	mov    0x14(%ebp),%eax
  800857:	8d 50 04             	lea    0x4(%eax),%edx
  80085a:	89 55 14             	mov    %edx,0x14(%ebp)
  80085d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800861:	8b 00                	mov    (%eax),%eax
  800863:	89 04 24             	mov    %eax,(%esp)
  800866:	ff 55 08             	call   *0x8(%ebp)
			break;
  800869:	e9 1e ff ff ff       	jmp    80078c <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80086e:	8b 45 14             	mov    0x14(%ebp),%eax
  800871:	8d 50 04             	lea    0x4(%eax),%edx
  800874:	89 55 14             	mov    %edx,0x14(%ebp)
  800877:	8b 00                	mov    (%eax),%eax
  800879:	89 c2                	mov    %eax,%edx
  80087b:	c1 fa 1f             	sar    $0x1f,%edx
  80087e:	31 d0                	xor    %edx,%eax
  800880:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800882:	83 f8 07             	cmp    $0x7,%eax
  800885:	7f 0b                	jg     800892 <vprintfmt+0x12b>
  800887:	8b 14 85 a0 10 80 00 	mov    0x8010a0(,%eax,4),%edx
  80088e:	85 d2                	test   %edx,%edx
  800890:	75 20                	jne    8008b2 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  800892:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800896:	c7 44 24 08 c0 0e 80 	movl   $0x800ec0,0x8(%esp)
  80089d:	00 
  80089e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a5:	89 04 24             	mov    %eax,(%esp)
  8008a8:	e8 92 fe ff ff       	call   80073f <printfmt>
  8008ad:	e9 da fe ff ff       	jmp    80078c <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8008b2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008b6:	c7 44 24 08 c9 0e 80 	movl   $0x800ec9,0x8(%esp)
  8008bd:	00 
  8008be:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	89 04 24             	mov    %eax,(%esp)
  8008c8:	e8 72 fe ff ff       	call   80073f <printfmt>
  8008cd:	e9 ba fe ff ff       	jmp    80078c <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8008d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8008d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008db:	8b 45 14             	mov    0x14(%ebp),%eax
  8008de:	8d 50 04             	lea    0x4(%eax),%edx
  8008e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e4:	8b 30                	mov    (%eax),%esi
  8008e6:	85 f6                	test   %esi,%esi
  8008e8:	75 05                	jne    8008ef <vprintfmt+0x188>
				p = "(null)";
  8008ea:	be b9 0e 80 00       	mov    $0x800eb9,%esi
			if (width > 0 && padc != '-')
  8008ef:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8008f3:	0f 84 8c 00 00 00    	je     800985 <vprintfmt+0x21e>
  8008f9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008fd:	0f 8e 8a 00 00 00    	jle    80098d <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  800903:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800907:	89 34 24             	mov    %esi,(%esp)
  80090a:	e8 cf f7 ff ff       	call   8000de <strnlen>
  80090f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800912:	29 c1                	sub    %eax,%ecx
  800914:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800917:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80091b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80091e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800921:	8b 75 08             	mov    0x8(%ebp),%esi
  800924:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800927:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800929:	eb 0d                	jmp    800938 <vprintfmt+0x1d1>
					putch(padc, putdat);
  80092b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80092f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800932:	89 04 24             	mov    %eax,(%esp)
  800935:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800937:	4b                   	dec    %ebx
  800938:	85 db                	test   %ebx,%ebx
  80093a:	7f ef                	jg     80092b <vprintfmt+0x1c4>
  80093c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80093f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800942:	89 c8                	mov    %ecx,%eax
  800944:	f7 d0                	not    %eax
  800946:	c1 f8 1f             	sar    $0x1f,%eax
  800949:	21 c8                	and    %ecx,%eax
  80094b:	29 c1                	sub    %eax,%ecx
  80094d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800950:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800953:	eb 3e                	jmp    800993 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800955:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800959:	74 1b                	je     800976 <vprintfmt+0x20f>
  80095b:	0f be d2             	movsbl %dl,%edx
  80095e:	83 ea 20             	sub    $0x20,%edx
  800961:	83 fa 5e             	cmp    $0x5e,%edx
  800964:	76 10                	jbe    800976 <vprintfmt+0x20f>
					putch('?', putdat);
  800966:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80096a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800971:	ff 55 08             	call   *0x8(%ebp)
  800974:	eb 0a                	jmp    800980 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800976:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80097a:	89 04 24             	mov    %eax,(%esp)
  80097d:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800980:	ff 4d dc             	decl   -0x24(%ebp)
  800983:	eb 0e                	jmp    800993 <vprintfmt+0x22c>
  800985:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800988:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80098b:	eb 06                	jmp    800993 <vprintfmt+0x22c>
  80098d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800990:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800993:	46                   	inc    %esi
  800994:	8a 56 ff             	mov    -0x1(%esi),%dl
  800997:	0f be c2             	movsbl %dl,%eax
  80099a:	85 c0                	test   %eax,%eax
  80099c:	74 1f                	je     8009bd <vprintfmt+0x256>
  80099e:	85 db                	test   %ebx,%ebx
  8009a0:	78 b3                	js     800955 <vprintfmt+0x1ee>
  8009a2:	4b                   	dec    %ebx
  8009a3:	79 b0                	jns    800955 <vprintfmt+0x1ee>
  8009a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a8:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8009ab:	eb 16                	jmp    8009c3 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8009ad:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009b1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009b8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009ba:	4b                   	dec    %ebx
  8009bb:	eb 06                	jmp    8009c3 <vprintfmt+0x25c>
  8009bd:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8009c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c3:	85 db                	test   %ebx,%ebx
  8009c5:	7f e6                	jg     8009ad <vprintfmt+0x246>
  8009c7:	89 75 08             	mov    %esi,0x8(%ebp)
  8009ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009cd:	e9 ba fd ff ff       	jmp    80078c <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009d2:	83 fa 01             	cmp    $0x1,%edx
  8009d5:	7e 16                	jle    8009ed <vprintfmt+0x286>
		return va_arg(*ap, long long);
  8009d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009da:	8d 50 08             	lea    0x8(%eax),%edx
  8009dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8009e0:	8b 50 04             	mov    0x4(%eax),%edx
  8009e3:	8b 00                	mov    (%eax),%eax
  8009e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009e8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009eb:	eb 32                	jmp    800a1f <vprintfmt+0x2b8>
	else if (lflag)
  8009ed:	85 d2                	test   %edx,%edx
  8009ef:	74 18                	je     800a09 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  8009f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f4:	8d 50 04             	lea    0x4(%eax),%edx
  8009f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8009fa:	8b 30                	mov    (%eax),%esi
  8009fc:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8009ff:	89 f0                	mov    %esi,%eax
  800a01:	c1 f8 1f             	sar    $0x1f,%eax
  800a04:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a07:	eb 16                	jmp    800a1f <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800a09:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0c:	8d 50 04             	lea    0x4(%eax),%edx
  800a0f:	89 55 14             	mov    %edx,0x14(%ebp)
  800a12:	8b 30                	mov    (%eax),%esi
  800a14:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800a17:	89 f0                	mov    %esi,%eax
  800a19:	c1 f8 1f             	sar    $0x1f,%eax
  800a1c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a22:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a25:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a2a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a2e:	0f 89 80 00 00 00    	jns    800ab4 <vprintfmt+0x34d>
				putch('-', putdat);
  800a34:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a38:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a3f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a42:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a45:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a48:	f7 d8                	neg    %eax
  800a4a:	83 d2 00             	adc    $0x0,%edx
  800a4d:	f7 da                	neg    %edx
			}
			base = 10;
  800a4f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a54:	eb 5e                	jmp    800ab4 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a56:	8d 45 14             	lea    0x14(%ebp),%eax
  800a59:	e8 8b fc ff ff       	call   8006e9 <getuint>
			base = 10;
  800a5e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a63:	eb 4f                	jmp    800ab4 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800a65:	8d 45 14             	lea    0x14(%ebp),%eax
  800a68:	e8 7c fc ff ff       	call   8006e9 <getuint>
			base = 8;
  800a6d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800a72:	eb 40                	jmp    800ab4 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800a74:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a78:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a7f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a82:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a86:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a8d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a90:	8b 45 14             	mov    0x14(%ebp),%eax
  800a93:	8d 50 04             	lea    0x4(%eax),%edx
  800a96:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a99:	8b 00                	mov    (%eax),%eax
  800a9b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800aa0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800aa5:	eb 0d                	jmp    800ab4 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800aa7:	8d 45 14             	lea    0x14(%ebp),%eax
  800aaa:	e8 3a fc ff ff       	call   8006e9 <getuint>
			base = 16;
  800aaf:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ab4:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800ab8:	89 74 24 10          	mov    %esi,0x10(%esp)
  800abc:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800abf:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ac3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ac7:	89 04 24             	mov    %eax,(%esp)
  800aca:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ace:	89 fa                	mov    %edi,%edx
  800ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad3:	e8 20 fb ff ff       	call   8005f8 <printnum>
			break;
  800ad8:	e9 af fc ff ff       	jmp    80078c <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800add:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ae1:	89 04 24             	mov    %eax,(%esp)
  800ae4:	ff 55 08             	call   *0x8(%ebp)
			break;
  800ae7:	e9 a0 fc ff ff       	jmp    80078c <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800aec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800af0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800af7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800afa:	89 f3                	mov    %esi,%ebx
  800afc:	eb 01                	jmp    800aff <vprintfmt+0x398>
  800afe:	4b                   	dec    %ebx
  800aff:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800b03:	75 f9                	jne    800afe <vprintfmt+0x397>
  800b05:	e9 82 fc ff ff       	jmp    80078c <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800b0a:	83 c4 3c             	add    $0x3c,%esp
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	83 ec 28             	sub    $0x28,%esp
  800b18:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b21:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b25:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b28:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	74 30                	je     800b63 <vsnprintf+0x51>
  800b33:	85 d2                	test   %edx,%edx
  800b35:	7e 2c                	jle    800b63 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b37:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b3e:	8b 45 10             	mov    0x10(%ebp),%eax
  800b41:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b45:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b48:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b4c:	c7 04 24 23 07 80 00 	movl   $0x800723,(%esp)
  800b53:	e8 0f fc ff ff       	call   800767 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b58:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b5b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b61:	eb 05                	jmp    800b68 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b63:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b68:	c9                   	leave  
  800b69:	c3                   	ret    

00800b6a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b70:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b73:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b77:	8b 45 10             	mov    0x10(%ebp),%eax
  800b7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b85:	8b 45 08             	mov    0x8(%ebp),%eax
  800b88:	89 04 24             	mov    %eax,(%esp)
  800b8b:	e8 82 ff ff ff       	call   800b12 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b90:	c9                   	leave  
  800b91:	c3                   	ret    
  800b92:	66 90                	xchg   %ax,%ax
  800b94:	66 90                	xchg   %ax,%ax
  800b96:	66 90                	xchg   %ax,%ax
  800b98:	66 90                	xchg   %ax,%ax
  800b9a:	66 90                	xchg   %ax,%ax
  800b9c:	66 90                	xchg   %ax,%ax
  800b9e:	66 90                	xchg   %ax,%ax

00800ba0 <__udivdi3>:
  800ba0:	55                   	push   %ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800baa:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800bae:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800bb2:	8b 44 24 28          	mov    0x28(%esp),%eax
  800bb6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bba:	89 ea                	mov    %ebp,%edx
  800bbc:	89 0c 24             	mov    %ecx,(%esp)
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	75 2d                	jne    800bf0 <__udivdi3+0x50>
  800bc3:	39 e9                	cmp    %ebp,%ecx
  800bc5:	77 61                	ja     800c28 <__udivdi3+0x88>
  800bc7:	89 ce                	mov    %ecx,%esi
  800bc9:	85 c9                	test   %ecx,%ecx
  800bcb:	75 0b                	jne    800bd8 <__udivdi3+0x38>
  800bcd:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd2:	31 d2                	xor    %edx,%edx
  800bd4:	f7 f1                	div    %ecx
  800bd6:	89 c6                	mov    %eax,%esi
  800bd8:	31 d2                	xor    %edx,%edx
  800bda:	89 e8                	mov    %ebp,%eax
  800bdc:	f7 f6                	div    %esi
  800bde:	89 c5                	mov    %eax,%ebp
  800be0:	89 f8                	mov    %edi,%eax
  800be2:	f7 f6                	div    %esi
  800be4:	89 ea                	mov    %ebp,%edx
  800be6:	83 c4 0c             	add    $0xc,%esp
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    
  800bed:	8d 76 00             	lea    0x0(%esi),%esi
  800bf0:	39 e8                	cmp    %ebp,%eax
  800bf2:	77 24                	ja     800c18 <__udivdi3+0x78>
  800bf4:	0f bd e8             	bsr    %eax,%ebp
  800bf7:	83 f5 1f             	xor    $0x1f,%ebp
  800bfa:	75 3c                	jne    800c38 <__udivdi3+0x98>
  800bfc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c00:	39 34 24             	cmp    %esi,(%esp)
  800c03:	0f 86 9f 00 00 00    	jbe    800ca8 <__udivdi3+0x108>
  800c09:	39 d0                	cmp    %edx,%eax
  800c0b:	0f 82 97 00 00 00    	jb     800ca8 <__udivdi3+0x108>
  800c11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c18:	31 d2                	xor    %edx,%edx
  800c1a:	31 c0                	xor    %eax,%eax
  800c1c:	83 c4 0c             	add    $0xc,%esp
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    
  800c23:	90                   	nop
  800c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c28:	89 f8                	mov    %edi,%eax
  800c2a:	f7 f1                	div    %ecx
  800c2c:	31 d2                	xor    %edx,%edx
  800c2e:	83 c4 0c             	add    $0xc,%esp
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    
  800c35:	8d 76 00             	lea    0x0(%esi),%esi
  800c38:	89 e9                	mov    %ebp,%ecx
  800c3a:	8b 3c 24             	mov    (%esp),%edi
  800c3d:	d3 e0                	shl    %cl,%eax
  800c3f:	89 c6                	mov    %eax,%esi
  800c41:	b8 20 00 00 00       	mov    $0x20,%eax
  800c46:	29 e8                	sub    %ebp,%eax
  800c48:	88 c1                	mov    %al,%cl
  800c4a:	d3 ef                	shr    %cl,%edi
  800c4c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c50:	89 e9                	mov    %ebp,%ecx
  800c52:	8b 3c 24             	mov    (%esp),%edi
  800c55:	09 74 24 08          	or     %esi,0x8(%esp)
  800c59:	d3 e7                	shl    %cl,%edi
  800c5b:	89 d6                	mov    %edx,%esi
  800c5d:	88 c1                	mov    %al,%cl
  800c5f:	d3 ee                	shr    %cl,%esi
  800c61:	89 e9                	mov    %ebp,%ecx
  800c63:	89 3c 24             	mov    %edi,(%esp)
  800c66:	d3 e2                	shl    %cl,%edx
  800c68:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c6c:	88 c1                	mov    %al,%cl
  800c6e:	d3 ef                	shr    %cl,%edi
  800c70:	09 d7                	or     %edx,%edi
  800c72:	89 f2                	mov    %esi,%edx
  800c74:	89 f8                	mov    %edi,%eax
  800c76:	f7 74 24 08          	divl   0x8(%esp)
  800c7a:	89 d6                	mov    %edx,%esi
  800c7c:	89 c7                	mov    %eax,%edi
  800c7e:	f7 24 24             	mull   (%esp)
  800c81:	89 14 24             	mov    %edx,(%esp)
  800c84:	39 d6                	cmp    %edx,%esi
  800c86:	72 30                	jb     800cb8 <__udivdi3+0x118>
  800c88:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c8c:	89 e9                	mov    %ebp,%ecx
  800c8e:	d3 e2                	shl    %cl,%edx
  800c90:	39 c2                	cmp    %eax,%edx
  800c92:	73 05                	jae    800c99 <__udivdi3+0xf9>
  800c94:	3b 34 24             	cmp    (%esp),%esi
  800c97:	74 1f                	je     800cb8 <__udivdi3+0x118>
  800c99:	89 f8                	mov    %edi,%eax
  800c9b:	31 d2                	xor    %edx,%edx
  800c9d:	e9 7a ff ff ff       	jmp    800c1c <__udivdi3+0x7c>
  800ca2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ca8:	31 d2                	xor    %edx,%edx
  800caa:	b8 01 00 00 00       	mov    $0x1,%eax
  800caf:	e9 68 ff ff ff       	jmp    800c1c <__udivdi3+0x7c>
  800cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cb8:	8d 47 ff             	lea    -0x1(%edi),%eax
  800cbb:	31 d2                	xor    %edx,%edx
  800cbd:	83 c4 0c             	add    $0xc,%esp
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    
  800cc4:	66 90                	xchg   %ax,%ax
  800cc6:	66 90                	xchg   %ax,%ax
  800cc8:	66 90                	xchg   %ax,%ax
  800cca:	66 90                	xchg   %ax,%ax
  800ccc:	66 90                	xchg   %ax,%ax
  800cce:	66 90                	xchg   %ax,%ax

00800cd0 <__umoddi3>:
  800cd0:	55                   	push   %ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	83 ec 14             	sub    $0x14,%esp
  800cd6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800cda:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800cde:	89 c7                	mov    %eax,%edi
  800ce0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800ce8:	8b 44 24 30          	mov    0x30(%esp),%eax
  800cec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800cf0:	89 34 24             	mov    %esi,(%esp)
  800cf3:	89 c2                	mov    %eax,%edx
  800cf5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cf9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800cfd:	85 c0                	test   %eax,%eax
  800cff:	75 17                	jne    800d18 <__umoddi3+0x48>
  800d01:	39 fe                	cmp    %edi,%esi
  800d03:	76 4b                	jbe    800d50 <__umoddi3+0x80>
  800d05:	89 c8                	mov    %ecx,%eax
  800d07:	89 fa                	mov    %edi,%edx
  800d09:	f7 f6                	div    %esi
  800d0b:	89 d0                	mov    %edx,%eax
  800d0d:	31 d2                	xor    %edx,%edx
  800d0f:	83 c4 14             	add    $0x14,%esp
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    
  800d16:	66 90                	xchg   %ax,%ax
  800d18:	39 f8                	cmp    %edi,%eax
  800d1a:	77 54                	ja     800d70 <__umoddi3+0xa0>
  800d1c:	0f bd e8             	bsr    %eax,%ebp
  800d1f:	83 f5 1f             	xor    $0x1f,%ebp
  800d22:	75 5c                	jne    800d80 <__umoddi3+0xb0>
  800d24:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d28:	39 3c 24             	cmp    %edi,(%esp)
  800d2b:	0f 87 f7 00 00 00    	ja     800e28 <__umoddi3+0x158>
  800d31:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d35:	29 f1                	sub    %esi,%ecx
  800d37:	19 c7                	sbb    %eax,%edi
  800d39:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d3d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d41:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d45:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d49:	83 c4 14             	add    $0x14,%esp
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    
  800d50:	89 f5                	mov    %esi,%ebp
  800d52:	85 f6                	test   %esi,%esi
  800d54:	75 0b                	jne    800d61 <__umoddi3+0x91>
  800d56:	b8 01 00 00 00       	mov    $0x1,%eax
  800d5b:	31 d2                	xor    %edx,%edx
  800d5d:	f7 f6                	div    %esi
  800d5f:	89 c5                	mov    %eax,%ebp
  800d61:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d65:	31 d2                	xor    %edx,%edx
  800d67:	f7 f5                	div    %ebp
  800d69:	89 c8                	mov    %ecx,%eax
  800d6b:	f7 f5                	div    %ebp
  800d6d:	eb 9c                	jmp    800d0b <__umoddi3+0x3b>
  800d6f:	90                   	nop
  800d70:	89 c8                	mov    %ecx,%eax
  800d72:	89 fa                	mov    %edi,%edx
  800d74:	83 c4 14             	add    $0x14,%esp
  800d77:	5e                   	pop    %esi
  800d78:	5f                   	pop    %edi
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    
  800d7b:	90                   	nop
  800d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d80:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800d87:	00 
  800d88:	8b 34 24             	mov    (%esp),%esi
  800d8b:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d8f:	89 e9                	mov    %ebp,%ecx
  800d91:	29 e8                	sub    %ebp,%eax
  800d93:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d97:	89 f0                	mov    %esi,%eax
  800d99:	d3 e2                	shl    %cl,%edx
  800d9b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800d9f:	d3 e8                	shr    %cl,%eax
  800da1:	89 04 24             	mov    %eax,(%esp)
  800da4:	89 e9                	mov    %ebp,%ecx
  800da6:	89 f0                	mov    %esi,%eax
  800da8:	09 14 24             	or     %edx,(%esp)
  800dab:	d3 e0                	shl    %cl,%eax
  800dad:	89 fa                	mov    %edi,%edx
  800daf:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800db3:	d3 ea                	shr    %cl,%edx
  800db5:	89 e9                	mov    %ebp,%ecx
  800db7:	89 c6                	mov    %eax,%esi
  800db9:	d3 e7                	shl    %cl,%edi
  800dbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dbf:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800dc3:	8b 44 24 10          	mov    0x10(%esp),%eax
  800dc7:	d3 e8                	shr    %cl,%eax
  800dc9:	09 f8                	or     %edi,%eax
  800dcb:	89 e9                	mov    %ebp,%ecx
  800dcd:	8b 7c 24 10          	mov    0x10(%esp),%edi
  800dd1:	d3 e7                	shl    %cl,%edi
  800dd3:	f7 34 24             	divl   (%esp)
  800dd6:	89 d1                	mov    %edx,%ecx
  800dd8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ddc:	f7 e6                	mul    %esi
  800dde:	89 c7                	mov    %eax,%edi
  800de0:	89 d6                	mov    %edx,%esi
  800de2:	39 d1                	cmp    %edx,%ecx
  800de4:	72 2e                	jb     800e14 <__umoddi3+0x144>
  800de6:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800dea:	72 24                	jb     800e10 <__umoddi3+0x140>
  800dec:	89 ca                	mov    %ecx,%edx
  800dee:	89 e9                	mov    %ebp,%ecx
  800df0:	8b 44 24 08          	mov    0x8(%esp),%eax
  800df4:	29 f8                	sub    %edi,%eax
  800df6:	19 f2                	sbb    %esi,%edx
  800df8:	d3 e8                	shr    %cl,%eax
  800dfa:	89 d6                	mov    %edx,%esi
  800dfc:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800e00:	d3 e6                	shl    %cl,%esi
  800e02:	89 e9                	mov    %ebp,%ecx
  800e04:	09 f0                	or     %esi,%eax
  800e06:	d3 ea                	shr    %cl,%edx
  800e08:	83 c4 14             	add    $0x14,%esp
  800e0b:	5e                   	pop    %esi
  800e0c:	5f                   	pop    %edi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    
  800e0f:	90                   	nop
  800e10:	39 d1                	cmp    %edx,%ecx
  800e12:	75 d8                	jne    800dec <__umoddi3+0x11c>
  800e14:	89 d6                	mov    %edx,%esi
  800e16:	89 c7                	mov    %eax,%edi
  800e18:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  800e1c:	1b 34 24             	sbb    (%esp),%esi
  800e1f:	eb cb                	jmp    800dec <__umoddi3+0x11c>
  800e21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e28:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  800e2c:	0f 82 ff fe ff ff    	jb     800d31 <__umoddi3+0x61>
  800e32:	e9 0a ff ff ff       	jmp    800d41 <__umoddi3+0x71>
