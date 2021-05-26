	// prog2 var 37
	.arch armv8-a
	.data
	.align	3
n:
	.word	2 // x11
m:
	.word	10 // 5
matrix:
	.quad	20, 19, 18, 17, 16, 15, 14, 13, 12, 11
	.quad	5, 1, 2, 7, 3, 7, -1, 2, 6, 12
	.text
	.align 2
	.global _start
	.type _start, %function
_start:
	adr 	x11, n
	ldr	w11, [x11]
	adr	x1, matrix
	adr	x0, m
	ldr	w0, [x0]
	mov	x12, #0 // current line
L12: // main loop
	sub	x11, x11, #1
	lsr	x2, x0, #1
	sub	x3, x0, #1
	mul	x13, x12, x0 // a[m][n] = a*m + n x13 = a*m
L0:
	cbz	x2, L1 // while heap not build
	sub	x2, x2, #1
	b	L2
L1:
	cbz	x3, L6 // heap built
	mov	x15, #0
	mov	x14, #0
	add	x15, x13, x2 // x15 and x14 = a*i + j
	add	x14, x13, x3
	ldr	x7, [x1, x15, lsl #3] // a[i], a[largest] =
	ldr	x8, [x1, x14, lsl #3] // a[largest], a[i]
	str	x7, [x1, x14, lsl #3]
	str	x8, [x1, x15, lsl #3]
	sub	x3, x3, #1
	cbz	x3, L6
L2:
	mov	x4, x2
	lsl	x5, x2, #1
	mov	x14, #0
	add	x14, x13, x2
	ldr	x7, [x1, x14, lsl #3]
L3:
	add	x5, x5, #1
	cmp	x5, x3
	bgt	L5
	mov	x14, #0
	add	x14, x13, x5
	ldr	x8, [x1, x14, lsl #3]
	beq	L4
	add	x6, x5, #1
	mov	x14, #0
	add	x14, x13, x6
	ldr	x9, [x1, x14, lsl #3]
	cmp	x8, x9
	bge	L4
	add	x5, x5, #1
	mov	x8, x9
L4:
	cmp	x7, x8
	bge	L5
	mov	x14, #0
	add	x14, x13, x4
	str	x8, [x1, x14, lsl #3]
	mov	x4, x5
	lsl	x5, x5, #1
	b	L3
L5:
	mov	x14, #0
	add	x14, x13, x4
	str	x7, [x1, x14, lsl #3]
	b	L0
L6:
	add	x12, x12, #1 // line = line + 1
	cbnz	x11, L12
	mov	x0, #0
	mov	x8, #93
	svc	#0
	.size	_start, .-_start
