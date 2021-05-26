	.arch armv8-a //	Sorting columns of matrix by max elements
	.data
	.align	3
n:
	.word	3
m:
	.word	5
matrix:
	.quad	4, 6, 1, 8, 2
	.quad 1, 2, 3, 4, 5
	.quad	0, -7, 3, -1, -1
maxs:
	.skip	40
	.text
	.align	2
	.global _start
	.type	_start, %function
_start:
	adr	x2, n
	mov	x0, #0
	ldr	w0, [x2]
	adr	x2, m
	mov	x1, #0
	ldr	w1, [x2]
	adr	x2, matrix
	adr	x3, maxs
	mov	x4, #0
L0:
	cmp	x4, x1
	bge	L3
	mov	x5, #0
	lsl	x6, x4, #3
	ldr	x7, [x2, x6]
	add	x6, x6, x1, lsl #3
	add	x5, x5, #1
L1:
	cmp	x5, x0
	bge	L2
	ldr	x8, [x2, x6]
	add	x6, x6, x1, lsl #3
	add	x5, x5, #1
	cmp	x7, x8
	bge	L1
	mov	x7, x8
	b	L1
L2:
	str	x7, [x3, x4, lsl #3]
	add	x4, x4, #1
	b	L0
L3:
	sub	x4, x1, #1
	mov	x5, #0
L4:
	cmp	x5, x4
	bge	L9
	mov	x6, x5
	mov	x7, x5
	ldr	x9, [x3, x7, lsl #3]
L5:
	add	x6, x6, #1
	cmp	x6, x4
	bgt	L6
	ldr	x8, [x3, x6, lsl #3]
	cmp	x8, x9
	bge	L5
	mov	x7, x6
	mov	x9, x8
	b	L5
L6:
	ldr	x8, [x3, x5, lsl #3]
	str	x8, [x3, x7, lsl #3]
	str	x9, [x3, x5, lsl #3]
	mov	x10, #0
	add	x6, x2, x5, lsl #3
	add	x7, x2, x7, lsl #3
L7:
	cmp	x10, x0
	bge	L8
	ldr	x8, [x6]
	ldr	x9, [x7]
	str	x8, [x7]
	str	x9, [x6]
	add	x6, x6, x1, lsl #3
	add	x7, x7, x1, lsl #3
	add	x10, x10, #1
	b	L7
L8:
	add	x5, x5, #1
	b	L4
L9:
	mov	x0, #0
	mov	x8, #93
	svc	#0
	.size	_start, .-_start
