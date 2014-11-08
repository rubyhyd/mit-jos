
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0xf0100000 = 0;
  800037:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003e:	00 00 00 
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    
  800043:	90                   	nop

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	56                   	push   %esi
  800048:	53                   	push   %ebx
  800049:	83 ec 10             	sub    $0x10,%esp
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  800052:	b8 08 20 80 00       	mov    $0x802008,%eax
  800057:	2d 04 20 80 00       	sub    $0x802004,%eax
  80005c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800060:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800067:	00 
  800068:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  80006f:	e8 bb 01 00 00       	call   80022f <memset>

	thisenv = 0;
	thisenv = &envs[0];
  800074:	c7 05 04 20 80 00 00 	movl   $0xeec00000,0x802004
  80007b:	00 c0 ee 
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 db                	test   %ebx,%ebx
  800080:	7e 07                	jle    800089 <libmain+0x45>
		binaryname = argv[0];
  800082:	8b 06                	mov    (%esi),%eax
  800084:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800089:	89 74 24 04          	mov    %esi,0x4(%esp)
  80008d:	89 1c 24             	mov    %ebx,(%esp)
  800090:	e8 9f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	5b                   	pop    %ebx
  80009e:	5e                   	pop    %esi
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    
  8000a1:	66 90                	xchg   %ax,%ax
  8000a3:	90                   	nop

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b1:	e8 ab 03 00 00       	call   800461 <sys_env_destroy>
}
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8000be:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c3:	eb 01                	jmp    8000c6 <strlen+0xe>
		n++;
  8000c5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8000c6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8000ca:	75 f9                	jne    8000c5 <strlen+0xd>
		n++;
	return n;
}
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    

008000ce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8000d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000dc:	eb 01                	jmp    8000df <strnlen+0x11>
		n++;
  8000de:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8000df:	39 d0                	cmp    %edx,%eax
  8000e1:	74 06                	je     8000e9 <strnlen+0x1b>
  8000e3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8000e7:	75 f5                	jne    8000de <strnlen+0x10>
		n++;
	return n;
}
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	53                   	push   %ebx
  8000ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8000f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8000f5:	89 c2                	mov    %eax,%edx
  8000f7:	42                   	inc    %edx
  8000f8:	41                   	inc    %ecx
  8000f9:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8000fc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8000ff:	84 db                	test   %bl,%bl
  800101:	75 f4                	jne    8000f7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800103:	5b                   	pop    %ebx
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    

00800106 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	53                   	push   %ebx
  80010a:	83 ec 08             	sub    $0x8,%esp
  80010d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800110:	89 1c 24             	mov    %ebx,(%esp)
  800113:	e8 a0 ff ff ff       	call   8000b8 <strlen>
	strcpy(dst + len, src);
  800118:	8b 55 0c             	mov    0xc(%ebp),%edx
  80011b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80011f:	01 d8                	add    %ebx,%eax
  800121:	89 04 24             	mov    %eax,(%esp)
  800124:	e8 c2 ff ff ff       	call   8000eb <strcpy>
	return dst;
}
  800129:	89 d8                	mov    %ebx,%eax
  80012b:	83 c4 08             	add    $0x8,%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    

00800131 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800131:	55                   	push   %ebp
  800132:	89 e5                	mov    %esp,%ebp
  800134:	56                   	push   %esi
  800135:	53                   	push   %ebx
  800136:	8b 75 08             	mov    0x8(%ebp),%esi
  800139:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80013c:	89 f3                	mov    %esi,%ebx
  80013e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800141:	89 f2                	mov    %esi,%edx
  800143:	eb 0c                	jmp    800151 <strncpy+0x20>
		*dst++ = *src;
  800145:	42                   	inc    %edx
  800146:	8a 01                	mov    (%ecx),%al
  800148:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80014b:	80 39 01             	cmpb   $0x1,(%ecx)
  80014e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800151:	39 da                	cmp    %ebx,%edx
  800153:	75 f0                	jne    800145 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800155:	89 f0                	mov    %esi,%eax
  800157:	5b                   	pop    %ebx
  800158:	5e                   	pop    %esi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	8b 75 08             	mov    0x8(%ebp),%esi
  800163:	8b 55 0c             	mov    0xc(%ebp),%edx
  800166:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800169:	89 f0                	mov    %esi,%eax
  80016b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80016f:	85 c9                	test   %ecx,%ecx
  800171:	75 07                	jne    80017a <strlcpy+0x1f>
  800173:	eb 18                	jmp    80018d <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800175:	40                   	inc    %eax
  800176:	42                   	inc    %edx
  800177:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80017a:	39 d8                	cmp    %ebx,%eax
  80017c:	74 0a                	je     800188 <strlcpy+0x2d>
  80017e:	8a 0a                	mov    (%edx),%cl
  800180:	84 c9                	test   %cl,%cl
  800182:	75 f1                	jne    800175 <strlcpy+0x1a>
  800184:	89 c2                	mov    %eax,%edx
  800186:	eb 02                	jmp    80018a <strlcpy+0x2f>
  800188:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80018a:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80018d:	29 f0                	sub    %esi,%eax
}
  80018f:	5b                   	pop    %ebx
  800190:	5e                   	pop    %esi
  800191:	5d                   	pop    %ebp
  800192:	c3                   	ret    

00800193 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800199:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80019c:	eb 02                	jmp    8001a0 <strcmp+0xd>
		p++, q++;
  80019e:	41                   	inc    %ecx
  80019f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8001a0:	8a 01                	mov    (%ecx),%al
  8001a2:	84 c0                	test   %al,%al
  8001a4:	74 04                	je     8001aa <strcmp+0x17>
  8001a6:	3a 02                	cmp    (%edx),%al
  8001a8:	74 f4                	je     80019e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8001aa:	25 ff 00 00 00       	and    $0xff,%eax
  8001af:	8a 0a                	mov    (%edx),%cl
  8001b1:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8001b7:	29 c8                	sub    %ecx,%eax
}
  8001b9:	5d                   	pop    %ebp
  8001ba:	c3                   	ret    

008001bb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	53                   	push   %ebx
  8001bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c5:	89 c3                	mov    %eax,%ebx
  8001c7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8001ca:	eb 02                	jmp    8001ce <strncmp+0x13>
		n--, p++, q++;
  8001cc:	40                   	inc    %eax
  8001cd:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8001ce:	39 d8                	cmp    %ebx,%eax
  8001d0:	74 20                	je     8001f2 <strncmp+0x37>
  8001d2:	8a 08                	mov    (%eax),%cl
  8001d4:	84 c9                	test   %cl,%cl
  8001d6:	74 04                	je     8001dc <strncmp+0x21>
  8001d8:	3a 0a                	cmp    (%edx),%cl
  8001da:	74 f0                	je     8001cc <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8001dc:	8a 18                	mov    (%eax),%bl
  8001de:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8001e4:	89 d8                	mov    %ebx,%eax
  8001e6:	8a 1a                	mov    (%edx),%bl
  8001e8:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8001ee:	29 d8                	sub    %ebx,%eax
  8001f0:	eb 05                	jmp    8001f7 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8001f2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8001f7:	5b                   	pop    %ebx
  8001f8:	5d                   	pop    %ebp
  8001f9:	c3                   	ret    

008001fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800200:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800203:	eb 05                	jmp    80020a <strchr+0x10>
		if (*s == c)
  800205:	38 ca                	cmp    %cl,%dl
  800207:	74 0c                	je     800215 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800209:	40                   	inc    %eax
  80020a:	8a 10                	mov    (%eax),%dl
  80020c:	84 d2                	test   %dl,%dl
  80020e:	75 f5                	jne    800205 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800210:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800215:	5d                   	pop    %ebp
  800216:	c3                   	ret    

00800217 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	8b 45 08             	mov    0x8(%ebp),%eax
  80021d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800220:	eb 05                	jmp    800227 <strfind+0x10>
		if (*s == c)
  800222:	38 ca                	cmp    %cl,%dl
  800224:	74 07                	je     80022d <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800226:	40                   	inc    %eax
  800227:	8a 10                	mov    (%eax),%dl
  800229:	84 d2                	test   %dl,%dl
  80022b:	75 f5                	jne    800222 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    

0080022f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	8b 7d 08             	mov    0x8(%ebp),%edi
  800238:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80023b:	85 c9                	test   %ecx,%ecx
  80023d:	74 37                	je     800276 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80023f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800245:	75 29                	jne    800270 <memset+0x41>
  800247:	f6 c1 03             	test   $0x3,%cl
  80024a:	75 24                	jne    800270 <memset+0x41>
		c &= 0xFF;
  80024c:	31 d2                	xor    %edx,%edx
  80024e:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800251:	89 d3                	mov    %edx,%ebx
  800253:	c1 e3 08             	shl    $0x8,%ebx
  800256:	89 d6                	mov    %edx,%esi
  800258:	c1 e6 18             	shl    $0x18,%esi
  80025b:	89 d0                	mov    %edx,%eax
  80025d:	c1 e0 10             	shl    $0x10,%eax
  800260:	09 f0                	or     %esi,%eax
  800262:	09 c2                	or     %eax,%edx
  800264:	89 d0                	mov    %edx,%eax
  800266:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800268:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80026b:	fc                   	cld    
  80026c:	f3 ab                	rep stos %eax,%es:(%edi)
  80026e:	eb 06                	jmp    800276 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800270:	8b 45 0c             	mov    0xc(%ebp),%eax
  800273:	fc                   	cld    
  800274:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800276:	89 f8                	mov    %edi,%eax
  800278:	5b                   	pop    %ebx
  800279:	5e                   	pop    %esi
  80027a:	5f                   	pop    %edi
  80027b:	5d                   	pop    %ebp
  80027c:	c3                   	ret    

0080027d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	57                   	push   %edi
  800281:	56                   	push   %esi
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	8b 75 0c             	mov    0xc(%ebp),%esi
  800288:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80028b:	39 c6                	cmp    %eax,%esi
  80028d:	73 33                	jae    8002c2 <memmove+0x45>
  80028f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800292:	39 d0                	cmp    %edx,%eax
  800294:	73 2c                	jae    8002c2 <memmove+0x45>
		s += n;
		d += n;
  800296:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800299:	89 d6                	mov    %edx,%esi
  80029b:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80029d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8002a3:	75 13                	jne    8002b8 <memmove+0x3b>
  8002a5:	f6 c1 03             	test   $0x3,%cl
  8002a8:	75 0e                	jne    8002b8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8002aa:	83 ef 04             	sub    $0x4,%edi
  8002ad:	8d 72 fc             	lea    -0x4(%edx),%esi
  8002b0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8002b3:	fd                   	std    
  8002b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8002b6:	eb 07                	jmp    8002bf <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8002b8:	4f                   	dec    %edi
  8002b9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8002bc:	fd                   	std    
  8002bd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8002bf:	fc                   	cld    
  8002c0:	eb 1d                	jmp    8002df <memmove+0x62>
  8002c2:	89 f2                	mov    %esi,%edx
  8002c4:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8002c6:	f6 c2 03             	test   $0x3,%dl
  8002c9:	75 0f                	jne    8002da <memmove+0x5d>
  8002cb:	f6 c1 03             	test   $0x3,%cl
  8002ce:	75 0a                	jne    8002da <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8002d0:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8002d3:	89 c7                	mov    %eax,%edi
  8002d5:	fc                   	cld    
  8002d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8002d8:	eb 05                	jmp    8002df <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8002da:	89 c7                	mov    %eax,%edi
  8002dc:	fc                   	cld    
  8002dd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8002df:	5e                   	pop    %esi
  8002e0:	5f                   	pop    %edi
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8002e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fa:	89 04 24             	mov    %eax,(%esp)
  8002fd:	e8 7b ff ff ff       	call   80027d <memmove>
}
  800302:	c9                   	leave  
  800303:	c3                   	ret    

00800304 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	56                   	push   %esi
  800308:	53                   	push   %ebx
  800309:	8b 55 08             	mov    0x8(%ebp),%edx
  80030c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030f:	89 d6                	mov    %edx,%esi
  800311:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800314:	eb 19                	jmp    80032f <memcmp+0x2b>
		if (*s1 != *s2)
  800316:	8a 02                	mov    (%edx),%al
  800318:	8a 19                	mov    (%ecx),%bl
  80031a:	38 d8                	cmp    %bl,%al
  80031c:	74 0f                	je     80032d <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  80031e:	25 ff 00 00 00       	and    $0xff,%eax
  800323:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800329:	29 d8                	sub    %ebx,%eax
  80032b:	eb 0b                	jmp    800338 <memcmp+0x34>
		s1++, s2++;
  80032d:	42                   	inc    %edx
  80032e:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80032f:	39 f2                	cmp    %esi,%edx
  800331:	75 e3                	jne    800316 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800333:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800338:	5b                   	pop    %ebx
  800339:	5e                   	pop    %esi
  80033a:	5d                   	pop    %ebp
  80033b:	c3                   	ret    

0080033c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	8b 45 08             	mov    0x8(%ebp),%eax
  800342:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800345:	89 c2                	mov    %eax,%edx
  800347:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80034a:	eb 05                	jmp    800351 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  80034c:	38 08                	cmp    %cl,(%eax)
  80034e:	74 05                	je     800355 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800350:	40                   	inc    %eax
  800351:	39 d0                	cmp    %edx,%eax
  800353:	72 f7                	jb     80034c <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	57                   	push   %edi
  80035b:	56                   	push   %esi
  80035c:	53                   	push   %ebx
  80035d:	8b 55 08             	mov    0x8(%ebp),%edx
  800360:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800363:	eb 01                	jmp    800366 <strtol+0xf>
		s++;
  800365:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800366:	8a 02                	mov    (%edx),%al
  800368:	3c 09                	cmp    $0x9,%al
  80036a:	74 f9                	je     800365 <strtol+0xe>
  80036c:	3c 20                	cmp    $0x20,%al
  80036e:	74 f5                	je     800365 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800370:	3c 2b                	cmp    $0x2b,%al
  800372:	75 08                	jne    80037c <strtol+0x25>
		s++;
  800374:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800375:	bf 00 00 00 00       	mov    $0x0,%edi
  80037a:	eb 10                	jmp    80038c <strtol+0x35>
  80037c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800381:	3c 2d                	cmp    $0x2d,%al
  800383:	75 07                	jne    80038c <strtol+0x35>
		s++, neg = 1;
  800385:	8d 52 01             	lea    0x1(%edx),%edx
  800388:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80038c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800392:	75 15                	jne    8003a9 <strtol+0x52>
  800394:	80 3a 30             	cmpb   $0x30,(%edx)
  800397:	75 10                	jne    8003a9 <strtol+0x52>
  800399:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80039d:	75 0a                	jne    8003a9 <strtol+0x52>
		s += 2, base = 16;
  80039f:	83 c2 02             	add    $0x2,%edx
  8003a2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8003a7:	eb 0e                	jmp    8003b7 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  8003a9:	85 db                	test   %ebx,%ebx
  8003ab:	75 0a                	jne    8003b7 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8003ad:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8003af:	80 3a 30             	cmpb   $0x30,(%edx)
  8003b2:	75 03                	jne    8003b7 <strtol+0x60>
		s++, base = 8;
  8003b4:	42                   	inc    %edx
  8003b5:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  8003b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003bc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8003bf:	8a 0a                	mov    (%edx),%cl
  8003c1:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8003c4:	89 f3                	mov    %esi,%ebx
  8003c6:	80 fb 09             	cmp    $0x9,%bl
  8003c9:	77 08                	ja     8003d3 <strtol+0x7c>
			dig = *s - '0';
  8003cb:	0f be c9             	movsbl %cl,%ecx
  8003ce:	83 e9 30             	sub    $0x30,%ecx
  8003d1:	eb 22                	jmp    8003f5 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  8003d3:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8003d6:	89 f3                	mov    %esi,%ebx
  8003d8:	80 fb 19             	cmp    $0x19,%bl
  8003db:	77 08                	ja     8003e5 <strtol+0x8e>
			dig = *s - 'a' + 10;
  8003dd:	0f be c9             	movsbl %cl,%ecx
  8003e0:	83 e9 57             	sub    $0x57,%ecx
  8003e3:	eb 10                	jmp    8003f5 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  8003e5:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8003e8:	89 f3                	mov    %esi,%ebx
  8003ea:	80 fb 19             	cmp    $0x19,%bl
  8003ed:	77 14                	ja     800403 <strtol+0xac>
			dig = *s - 'A' + 10;
  8003ef:	0f be c9             	movsbl %cl,%ecx
  8003f2:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8003f5:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  8003f8:	7d 0d                	jge    800407 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8003fa:	42                   	inc    %edx
  8003fb:	0f af 45 10          	imul   0x10(%ebp),%eax
  8003ff:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800401:	eb bc                	jmp    8003bf <strtol+0x68>
  800403:	89 c1                	mov    %eax,%ecx
  800405:	eb 02                	jmp    800409 <strtol+0xb2>
  800407:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800409:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80040d:	74 05                	je     800414 <strtol+0xbd>
		*endptr = (char *) s;
  80040f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800412:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800414:	85 ff                	test   %edi,%edi
  800416:	74 04                	je     80041c <strtol+0xc5>
  800418:	89 c8                	mov    %ecx,%eax
  80041a:	f7 d8                	neg    %eax
}
  80041c:	5b                   	pop    %ebx
  80041d:	5e                   	pop    %esi
  80041e:	5f                   	pop    %edi
  80041f:	5d                   	pop    %ebp
  800420:	c3                   	ret    
  800421:	66 90                	xchg   %ax,%ax
  800423:	90                   	nop

00800424 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	57                   	push   %edi
  800428:	56                   	push   %esi
  800429:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80042a:	b8 00 00 00 00       	mov    $0x0,%eax
  80042f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800432:	8b 55 08             	mov    0x8(%ebp),%edx
  800435:	89 c3                	mov    %eax,%ebx
  800437:	89 c7                	mov    %eax,%edi
  800439:	89 c6                	mov    %eax,%esi
  80043b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80043d:	5b                   	pop    %ebx
  80043e:	5e                   	pop    %esi
  80043f:	5f                   	pop    %edi
  800440:	5d                   	pop    %ebp
  800441:	c3                   	ret    

00800442 <sys_cgetc>:

int
sys_cgetc(void)
{
  800442:	55                   	push   %ebp
  800443:	89 e5                	mov    %esp,%ebp
  800445:	57                   	push   %edi
  800446:	56                   	push   %esi
  800447:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800448:	ba 00 00 00 00       	mov    $0x0,%edx
  80044d:	b8 01 00 00 00       	mov    $0x1,%eax
  800452:	89 d1                	mov    %edx,%ecx
  800454:	89 d3                	mov    %edx,%ebx
  800456:	89 d7                	mov    %edx,%edi
  800458:	89 d6                	mov    %edx,%esi
  80045a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80045c:	5b                   	pop    %ebx
  80045d:	5e                   	pop    %esi
  80045e:	5f                   	pop    %edi
  80045f:	5d                   	pop    %ebp
  800460:	c3                   	ret    

00800461 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800461:	55                   	push   %ebp
  800462:	89 e5                	mov    %esp,%ebp
  800464:	57                   	push   %edi
  800465:	56                   	push   %esi
  800466:	53                   	push   %ebx
  800467:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80046a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80046f:	b8 03 00 00 00       	mov    $0x3,%eax
  800474:	8b 55 08             	mov    0x8(%ebp),%edx
  800477:	89 cb                	mov    %ecx,%ebx
  800479:	89 cf                	mov    %ecx,%edi
  80047b:	89 ce                	mov    %ecx,%esi
  80047d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80047f:	85 c0                	test   %eax,%eax
  800481:	7e 28                	jle    8004ab <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800483:	89 44 24 10          	mov    %eax,0x10(%esp)
  800487:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80048e:	00 
  80048f:	c7 44 24 08 4a 0e 80 	movl   $0x800e4a,0x8(%esp)
  800496:	00 
  800497:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80049e:	00 
  80049f:	c7 04 24 67 0e 80 00 	movl   $0x800e67,(%esp)
  8004a6:	e8 29 00 00 00       	call   8004d4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8004ab:	83 c4 2c             	add    $0x2c,%esp
  8004ae:	5b                   	pop    %ebx
  8004af:	5e                   	pop    %esi
  8004b0:	5f                   	pop    %edi
  8004b1:	5d                   	pop    %ebp
  8004b2:	c3                   	ret    

008004b3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8004b3:	55                   	push   %ebp
  8004b4:	89 e5                	mov    %esp,%ebp
  8004b6:	57                   	push   %edi
  8004b7:	56                   	push   %esi
  8004b8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004be:	b8 02 00 00 00       	mov    $0x2,%eax
  8004c3:	89 d1                	mov    %edx,%ecx
  8004c5:	89 d3                	mov    %edx,%ebx
  8004c7:	89 d7                	mov    %edx,%edi
  8004c9:	89 d6                	mov    %edx,%esi
  8004cb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8004cd:	5b                   	pop    %ebx
  8004ce:	5e                   	pop    %esi
  8004cf:	5f                   	pop    %edi
  8004d0:	5d                   	pop    %ebp
  8004d1:	c3                   	ret    
  8004d2:	66 90                	xchg   %ax,%ax

008004d4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
  8004d7:	56                   	push   %esi
  8004d8:	53                   	push   %ebx
  8004d9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8004dc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004df:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8004e5:	e8 c9 ff ff ff       	call   8004b3 <sys_getenvid>
  8004ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ed:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8004f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f8:	89 74 24 08          	mov    %esi,0x8(%esp)
  8004fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800500:	c7 04 24 78 0e 80 00 	movl   $0x800e78,(%esp)
  800507:	e8 c2 00 00 00       	call   8005ce <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800510:	8b 45 10             	mov    0x10(%ebp),%eax
  800513:	89 04 24             	mov    %eax,(%esp)
  800516:	e8 52 00 00 00       	call   80056d <vcprintf>
	cprintf("\n");
  80051b:	c7 04 24 9c 0e 80 00 	movl   $0x800e9c,(%esp)
  800522:	e8 a7 00 00 00       	call   8005ce <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800527:	cc                   	int3   
  800528:	eb fd                	jmp    800527 <_panic+0x53>
  80052a:	66 90                	xchg   %ax,%ax

0080052c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052c:	55                   	push   %ebp
  80052d:	89 e5                	mov    %esp,%ebp
  80052f:	53                   	push   %ebx
  800530:	83 ec 14             	sub    $0x14,%esp
  800533:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800536:	8b 13                	mov    (%ebx),%edx
  800538:	8d 42 01             	lea    0x1(%edx),%eax
  80053b:	89 03                	mov    %eax,(%ebx)
  80053d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800540:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800544:	3d ff 00 00 00       	cmp    $0xff,%eax
  800549:	75 19                	jne    800564 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80054b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800552:	00 
  800553:	8d 43 08             	lea    0x8(%ebx),%eax
  800556:	89 04 24             	mov    %eax,(%esp)
  800559:	e8 c6 fe ff ff       	call   800424 <sys_cputs>
		b->idx = 0;
  80055e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800564:	ff 43 04             	incl   0x4(%ebx)
}
  800567:	83 c4 14             	add    $0x14,%esp
  80056a:	5b                   	pop    %ebx
  80056b:	5d                   	pop    %ebp
  80056c:	c3                   	ret    

0080056d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80056d:	55                   	push   %ebp
  80056e:	89 e5                	mov    %esp,%ebp
  800570:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800576:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80057d:	00 00 00 
	b.cnt = 0;
  800580:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800587:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80058a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80058d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800591:	8b 45 08             	mov    0x8(%ebp),%eax
  800594:	89 44 24 08          	mov    %eax,0x8(%esp)
  800598:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80059e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a2:	c7 04 24 2c 05 80 00 	movl   $0x80052c,(%esp)
  8005a9:	e8 a9 01 00 00       	call   800757 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005ae:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8005b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005be:	89 04 24             	mov    %eax,(%esp)
  8005c1:	e8 5e fe ff ff       	call   800424 <sys_cputs>

	return b.cnt;
}
  8005c6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005cc:	c9                   	leave  
  8005cd:	c3                   	ret    

008005ce <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005ce:	55                   	push   %ebp
  8005cf:	89 e5                	mov    %esp,%ebp
  8005d1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005d4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005db:	8b 45 08             	mov    0x8(%ebp),%eax
  8005de:	89 04 24             	mov    %eax,(%esp)
  8005e1:	e8 87 ff ff ff       	call   80056d <vcprintf>
	va_end(ap);

	return cnt;
}
  8005e6:	c9                   	leave  
  8005e7:	c3                   	ret    

008005e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005e8:	55                   	push   %ebp
  8005e9:	89 e5                	mov    %esp,%ebp
  8005eb:	57                   	push   %edi
  8005ec:	56                   	push   %esi
  8005ed:	53                   	push   %ebx
  8005ee:	83 ec 3c             	sub    $0x3c,%esp
  8005f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005f4:	89 d7                	mov    %edx,%edi
  8005f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ff:	89 c1                	mov    %eax,%ecx
  800601:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800604:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800607:	8b 45 10             	mov    0x10(%ebp),%eax
  80060a:	ba 00 00 00 00       	mov    $0x0,%edx
  80060f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800612:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800615:	39 ca                	cmp    %ecx,%edx
  800617:	72 08                	jb     800621 <printnum+0x39>
  800619:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80061c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80061f:	77 6a                	ja     80068b <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800621:	8b 45 18             	mov    0x18(%ebp),%eax
  800624:	89 44 24 10          	mov    %eax,0x10(%esp)
  800628:	4e                   	dec    %esi
  800629:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80062d:	8b 45 10             	mov    0x10(%ebp),%eax
  800630:	89 44 24 08          	mov    %eax,0x8(%esp)
  800634:	8b 44 24 08          	mov    0x8(%esp),%eax
  800638:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80063c:	89 c3                	mov    %eax,%ebx
  80063e:	89 d6                	mov    %edx,%esi
  800640:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800643:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800646:	89 44 24 08          	mov    %eax,0x8(%esp)
  80064a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80064e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800651:	89 04 24             	mov    %eax,(%esp)
  800654:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800657:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065b:	e8 30 05 00 00       	call   800b90 <__udivdi3>
  800660:	89 d9                	mov    %ebx,%ecx
  800662:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800666:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80066a:	89 04 24             	mov    %eax,(%esp)
  80066d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800671:	89 fa                	mov    %edi,%edx
  800673:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800676:	e8 6d ff ff ff       	call   8005e8 <printnum>
  80067b:	eb 19                	jmp    800696 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80067d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800681:	8b 45 18             	mov    0x18(%ebp),%eax
  800684:	89 04 24             	mov    %eax,(%esp)
  800687:	ff d3                	call   *%ebx
  800689:	eb 03                	jmp    80068e <printnum+0xa6>
  80068b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80068e:	4e                   	dec    %esi
  80068f:	85 f6                	test   %esi,%esi
  800691:	7f ea                	jg     80067d <printnum+0x95>
  800693:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800696:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80069a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80069e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006a1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006af:	89 04 24             	mov    %eax,(%esp)
  8006b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b9:	e8 02 06 00 00       	call   800cc0 <__umoddi3>
  8006be:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c2:	0f be 80 9e 0e 80 00 	movsbl 0x800e9e(%eax),%eax
  8006c9:	89 04 24             	mov    %eax,(%esp)
  8006cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006cf:	ff d0                	call   *%eax
}
  8006d1:	83 c4 3c             	add    $0x3c,%esp
  8006d4:	5b                   	pop    %ebx
  8006d5:	5e                   	pop    %esi
  8006d6:	5f                   	pop    %edi
  8006d7:	5d                   	pop    %ebp
  8006d8:	c3                   	ret    

008006d9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006dc:	83 fa 01             	cmp    $0x1,%edx
  8006df:	7e 0e                	jle    8006ef <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8006e1:	8b 10                	mov    (%eax),%edx
  8006e3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006e6:	89 08                	mov    %ecx,(%eax)
  8006e8:	8b 02                	mov    (%edx),%eax
  8006ea:	8b 52 04             	mov    0x4(%edx),%edx
  8006ed:	eb 22                	jmp    800711 <getuint+0x38>
	else if (lflag)
  8006ef:	85 d2                	test   %edx,%edx
  8006f1:	74 10                	je     800703 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006f3:	8b 10                	mov    (%eax),%edx
  8006f5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006f8:	89 08                	mov    %ecx,(%eax)
  8006fa:	8b 02                	mov    (%edx),%eax
  8006fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800701:	eb 0e                	jmp    800711 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800703:	8b 10                	mov    (%eax),%edx
  800705:	8d 4a 04             	lea    0x4(%edx),%ecx
  800708:	89 08                	mov    %ecx,(%eax)
  80070a:	8b 02                	mov    (%edx),%eax
  80070c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800711:	5d                   	pop    %ebp
  800712:	c3                   	ret    

00800713 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
  800716:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800719:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80071c:	8b 10                	mov    (%eax),%edx
  80071e:	3b 50 04             	cmp    0x4(%eax),%edx
  800721:	73 0a                	jae    80072d <sprintputch+0x1a>
		*b->buf++ = ch;
  800723:	8d 4a 01             	lea    0x1(%edx),%ecx
  800726:	89 08                	mov    %ecx,(%eax)
  800728:	8b 45 08             	mov    0x8(%ebp),%eax
  80072b:	88 02                	mov    %al,(%edx)
}
  80072d:	5d                   	pop    %ebp
  80072e:	c3                   	ret    

0080072f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800735:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800738:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073c:	8b 45 10             	mov    0x10(%ebp),%eax
  80073f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800743:	8b 45 0c             	mov    0xc(%ebp),%eax
  800746:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074a:	8b 45 08             	mov    0x8(%ebp),%eax
  80074d:	89 04 24             	mov    %eax,(%esp)
  800750:	e8 02 00 00 00       	call   800757 <vprintfmt>
	va_end(ap);
}
  800755:	c9                   	leave  
  800756:	c3                   	ret    

00800757 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	57                   	push   %edi
  80075b:	56                   	push   %esi
  80075c:	53                   	push   %ebx
  80075d:	83 ec 3c             	sub    $0x3c,%esp
  800760:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800763:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800766:	eb 14                	jmp    80077c <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800768:	85 c0                	test   %eax,%eax
  80076a:	0f 84 8a 03 00 00    	je     800afa <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  800770:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800774:	89 04 24             	mov    %eax,(%esp)
  800777:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80077a:	89 f3                	mov    %esi,%ebx
  80077c:	8d 73 01             	lea    0x1(%ebx),%esi
  80077f:	31 c0                	xor    %eax,%eax
  800781:	8a 03                	mov    (%ebx),%al
  800783:	83 f8 25             	cmp    $0x25,%eax
  800786:	75 e0                	jne    800768 <vprintfmt+0x11>
  800788:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80078c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800793:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80079a:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8007a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a6:	eb 1d                	jmp    8007c5 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a8:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8007aa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8007ae:	eb 15                	jmp    8007c5 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b0:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007b2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8007b6:	eb 0d                	jmp    8007c5 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8007b8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007bb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8007be:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c5:	8d 5e 01             	lea    0x1(%esi),%ebx
  8007c8:	31 c0                	xor    %eax,%eax
  8007ca:	8a 06                	mov    (%esi),%al
  8007cc:	8a 0e                	mov    (%esi),%cl
  8007ce:	83 e9 23             	sub    $0x23,%ecx
  8007d1:	88 4d e0             	mov    %cl,-0x20(%ebp)
  8007d4:	80 f9 55             	cmp    $0x55,%cl
  8007d7:	0f 87 ff 02 00 00    	ja     800adc <vprintfmt+0x385>
  8007dd:	31 c9                	xor    %ecx,%ecx
  8007df:	8a 4d e0             	mov    -0x20(%ebp),%cl
  8007e2:	ff 24 8d 40 0f 80 00 	jmp    *0x800f40(,%ecx,4)
  8007e9:	89 de                	mov    %ebx,%esi
  8007eb:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8007f0:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8007f3:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8007f7:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8007fa:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8007fd:	83 fb 09             	cmp    $0x9,%ebx
  800800:	77 2f                	ja     800831 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800802:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800803:	eb eb                	jmp    8007f0 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800805:	8b 45 14             	mov    0x14(%ebp),%eax
  800808:	8d 48 04             	lea    0x4(%eax),%ecx
  80080b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80080e:	8b 00                	mov    (%eax),%eax
  800810:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800813:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800815:	eb 1d                	jmp    800834 <vprintfmt+0xdd>
  800817:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80081a:	f7 d0                	not    %eax
  80081c:	c1 f8 1f             	sar    $0x1f,%eax
  80081f:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800822:	89 de                	mov    %ebx,%esi
  800824:	eb 9f                	jmp    8007c5 <vprintfmt+0x6e>
  800826:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800828:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80082f:	eb 94                	jmp    8007c5 <vprintfmt+0x6e>
  800831:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800834:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800838:	79 8b                	jns    8007c5 <vprintfmt+0x6e>
  80083a:	e9 79 ff ff ff       	jmp    8007b8 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80083f:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800840:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800842:	eb 81                	jmp    8007c5 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800844:	8b 45 14             	mov    0x14(%ebp),%eax
  800847:	8d 50 04             	lea    0x4(%eax),%edx
  80084a:	89 55 14             	mov    %edx,0x14(%ebp)
  80084d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800851:	8b 00                	mov    (%eax),%eax
  800853:	89 04 24             	mov    %eax,(%esp)
  800856:	ff 55 08             	call   *0x8(%ebp)
			break;
  800859:	e9 1e ff ff ff       	jmp    80077c <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80085e:	8b 45 14             	mov    0x14(%ebp),%eax
  800861:	8d 50 04             	lea    0x4(%eax),%edx
  800864:	89 55 14             	mov    %edx,0x14(%ebp)
  800867:	8b 00                	mov    (%eax),%eax
  800869:	89 c2                	mov    %eax,%edx
  80086b:	c1 fa 1f             	sar    $0x1f,%edx
  80086e:	31 d0                	xor    %edx,%eax
  800870:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800872:	83 f8 07             	cmp    $0x7,%eax
  800875:	7f 0b                	jg     800882 <vprintfmt+0x12b>
  800877:	8b 14 85 a0 10 80 00 	mov    0x8010a0(,%eax,4),%edx
  80087e:	85 d2                	test   %edx,%edx
  800880:	75 20                	jne    8008a2 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  800882:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800886:	c7 44 24 08 b6 0e 80 	movl   $0x800eb6,0x8(%esp)
  80088d:	00 
  80088e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800892:	8b 45 08             	mov    0x8(%ebp),%eax
  800895:	89 04 24             	mov    %eax,(%esp)
  800898:	e8 92 fe ff ff       	call   80072f <printfmt>
  80089d:	e9 da fe ff ff       	jmp    80077c <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8008a2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008a6:	c7 44 24 08 bf 0e 80 	movl   $0x800ebf,0x8(%esp)
  8008ad:	00 
  8008ae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b5:	89 04 24             	mov    %eax,(%esp)
  8008b8:	e8 72 fe ff ff       	call   80072f <printfmt>
  8008bd:	e9 ba fe ff ff       	jmp    80077c <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8008c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8008c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ce:	8d 50 04             	lea    0x4(%eax),%edx
  8008d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d4:	8b 30                	mov    (%eax),%esi
  8008d6:	85 f6                	test   %esi,%esi
  8008d8:	75 05                	jne    8008df <vprintfmt+0x188>
				p = "(null)";
  8008da:	be af 0e 80 00       	mov    $0x800eaf,%esi
			if (width > 0 && padc != '-')
  8008df:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8008e3:	0f 84 8c 00 00 00    	je     800975 <vprintfmt+0x21e>
  8008e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008ed:	0f 8e 8a 00 00 00    	jle    80097d <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008f3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008f7:	89 34 24             	mov    %esi,(%esp)
  8008fa:	e8 cf f7 ff ff       	call   8000ce <strnlen>
  8008ff:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800902:	29 c1                	sub    %eax,%ecx
  800904:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800907:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80090b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80090e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800911:	8b 75 08             	mov    0x8(%ebp),%esi
  800914:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800917:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800919:	eb 0d                	jmp    800928 <vprintfmt+0x1d1>
					putch(padc, putdat);
  80091b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80091f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800922:	89 04 24             	mov    %eax,(%esp)
  800925:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800927:	4b                   	dec    %ebx
  800928:	85 db                	test   %ebx,%ebx
  80092a:	7f ef                	jg     80091b <vprintfmt+0x1c4>
  80092c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80092f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800932:	89 c8                	mov    %ecx,%eax
  800934:	f7 d0                	not    %eax
  800936:	c1 f8 1f             	sar    $0x1f,%eax
  800939:	21 c8                	and    %ecx,%eax
  80093b:	29 c1                	sub    %eax,%ecx
  80093d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800940:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800943:	eb 3e                	jmp    800983 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800945:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800949:	74 1b                	je     800966 <vprintfmt+0x20f>
  80094b:	0f be d2             	movsbl %dl,%edx
  80094e:	83 ea 20             	sub    $0x20,%edx
  800951:	83 fa 5e             	cmp    $0x5e,%edx
  800954:	76 10                	jbe    800966 <vprintfmt+0x20f>
					putch('?', putdat);
  800956:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80095a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800961:	ff 55 08             	call   *0x8(%ebp)
  800964:	eb 0a                	jmp    800970 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800966:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80096a:	89 04 24             	mov    %eax,(%esp)
  80096d:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800970:	ff 4d dc             	decl   -0x24(%ebp)
  800973:	eb 0e                	jmp    800983 <vprintfmt+0x22c>
  800975:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800978:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80097b:	eb 06                	jmp    800983 <vprintfmt+0x22c>
  80097d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800980:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800983:	46                   	inc    %esi
  800984:	8a 56 ff             	mov    -0x1(%esi),%dl
  800987:	0f be c2             	movsbl %dl,%eax
  80098a:	85 c0                	test   %eax,%eax
  80098c:	74 1f                	je     8009ad <vprintfmt+0x256>
  80098e:	85 db                	test   %ebx,%ebx
  800990:	78 b3                	js     800945 <vprintfmt+0x1ee>
  800992:	4b                   	dec    %ebx
  800993:	79 b0                	jns    800945 <vprintfmt+0x1ee>
  800995:	8b 75 08             	mov    0x8(%ebp),%esi
  800998:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80099b:	eb 16                	jmp    8009b3 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80099d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009a1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009a8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009aa:	4b                   	dec    %ebx
  8009ab:	eb 06                	jmp    8009b3 <vprintfmt+0x25c>
  8009ad:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8009b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b3:	85 db                	test   %ebx,%ebx
  8009b5:	7f e6                	jg     80099d <vprintfmt+0x246>
  8009b7:	89 75 08             	mov    %esi,0x8(%ebp)
  8009ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009bd:	e9 ba fd ff ff       	jmp    80077c <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009c2:	83 fa 01             	cmp    $0x1,%edx
  8009c5:	7e 16                	jle    8009dd <vprintfmt+0x286>
		return va_arg(*ap, long long);
  8009c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ca:	8d 50 08             	lea    0x8(%eax),%edx
  8009cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8009d0:	8b 50 04             	mov    0x4(%eax),%edx
  8009d3:	8b 00                	mov    (%eax),%eax
  8009d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009d8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009db:	eb 32                	jmp    800a0f <vprintfmt+0x2b8>
	else if (lflag)
  8009dd:	85 d2                	test   %edx,%edx
  8009df:	74 18                	je     8009f9 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  8009e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e4:	8d 50 04             	lea    0x4(%eax),%edx
  8009e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ea:	8b 30                	mov    (%eax),%esi
  8009ec:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8009ef:	89 f0                	mov    %esi,%eax
  8009f1:	c1 f8 1f             	sar    $0x1f,%eax
  8009f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009f7:	eb 16                	jmp    800a0f <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  8009f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8009fc:	8d 50 04             	lea    0x4(%eax),%edx
  8009ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800a02:	8b 30                	mov    (%eax),%esi
  800a04:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800a07:	89 f0                	mov    %esi,%eax
  800a09:	c1 f8 1f             	sar    $0x1f,%eax
  800a0c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a12:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a15:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a1a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a1e:	0f 89 80 00 00 00    	jns    800aa4 <vprintfmt+0x34d>
				putch('-', putdat);
  800a24:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a28:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a2f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a32:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a35:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a38:	f7 d8                	neg    %eax
  800a3a:	83 d2 00             	adc    $0x0,%edx
  800a3d:	f7 da                	neg    %edx
			}
			base = 10;
  800a3f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a44:	eb 5e                	jmp    800aa4 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a46:	8d 45 14             	lea    0x14(%ebp),%eax
  800a49:	e8 8b fc ff ff       	call   8006d9 <getuint>
			base = 10;
  800a4e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a53:	eb 4f                	jmp    800aa4 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800a55:	8d 45 14             	lea    0x14(%ebp),%eax
  800a58:	e8 7c fc ff ff       	call   8006d9 <getuint>
			base = 8;
  800a5d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800a62:	eb 40                	jmp    800aa4 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800a64:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a68:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a6f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a72:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a76:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a7d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a80:	8b 45 14             	mov    0x14(%ebp),%eax
  800a83:	8d 50 04             	lea    0x4(%eax),%edx
  800a86:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a89:	8b 00                	mov    (%eax),%eax
  800a8b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a90:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a95:	eb 0d                	jmp    800aa4 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a97:	8d 45 14             	lea    0x14(%ebp),%eax
  800a9a:	e8 3a fc ff ff       	call   8006d9 <getuint>
			base = 16;
  800a9f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800aa4:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800aa8:	89 74 24 10          	mov    %esi,0x10(%esp)
  800aac:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800aaf:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ab3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ab7:	89 04 24             	mov    %eax,(%esp)
  800aba:	89 54 24 04          	mov    %edx,0x4(%esp)
  800abe:	89 fa                	mov    %edi,%edx
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	e8 20 fb ff ff       	call   8005e8 <printnum>
			break;
  800ac8:	e9 af fc ff ff       	jmp    80077c <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800acd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ad1:	89 04 24             	mov    %eax,(%esp)
  800ad4:	ff 55 08             	call   *0x8(%ebp)
			break;
  800ad7:	e9 a0 fc ff ff       	jmp    80077c <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800adc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ae0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ae7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aea:	89 f3                	mov    %esi,%ebx
  800aec:	eb 01                	jmp    800aef <vprintfmt+0x398>
  800aee:	4b                   	dec    %ebx
  800aef:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800af3:	75 f9                	jne    800aee <vprintfmt+0x397>
  800af5:	e9 82 fc ff ff       	jmp    80077c <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800afa:	83 c4 3c             	add    $0x3c,%esp
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	83 ec 28             	sub    $0x28,%esp
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b11:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b15:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b18:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b1f:	85 c0                	test   %eax,%eax
  800b21:	74 30                	je     800b53 <vsnprintf+0x51>
  800b23:	85 d2                	test   %edx,%edx
  800b25:	7e 2c                	jle    800b53 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b27:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b2e:	8b 45 10             	mov    0x10(%ebp),%eax
  800b31:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b35:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b38:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3c:	c7 04 24 13 07 80 00 	movl   $0x800713,(%esp)
  800b43:	e8 0f fc ff ff       	call   800757 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b48:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b4b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b51:	eb 05                	jmp    800b58 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b58:	c9                   	leave  
  800b59:	c3                   	ret    

00800b5a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b60:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b63:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b67:	8b 45 10             	mov    0x10(%ebp),%eax
  800b6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b75:	8b 45 08             	mov    0x8(%ebp),%eax
  800b78:	89 04 24             	mov    %eax,(%esp)
  800b7b:	e8 82 ff ff ff       	call   800b02 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b80:	c9                   	leave  
  800b81:	c3                   	ret    
  800b82:	66 90                	xchg   %ax,%ax
  800b84:	66 90                	xchg   %ax,%ax
  800b86:	66 90                	xchg   %ax,%ax
  800b88:	66 90                	xchg   %ax,%ax
  800b8a:	66 90                	xchg   %ax,%ax
  800b8c:	66 90                	xchg   %ax,%ax
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
