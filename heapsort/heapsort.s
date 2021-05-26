	.arch armv8-a //	HeapSort
	.data
	.align	3
n:
	.quad	10
mas:
	.quad	8, 7, 1, 9, 5, 2, 6, 0, 4, 3
	.text
	.align	2
	.global _start
	.type	_start, %function
_start:
	adr	x0, n
	ldr	x0, [x0]
	adr	x1, mas
	lsr	x2, x0, #1
	sub	x3, x0, #1
L0:
	cbz	x2, L1
	sub	x2, x2, #1
	b	L2
L1:
	cbz	x3, L6
	ldr	x7, [x1, x2, lsl #3]
	ldr	x8, [x1, x3, lsl #3]
	str	x7, [x1, x3, lsl #3]
	str	x8, [x1, x2, lsl #3]
	sub	x3, x3, #1
	cbz	x3, L6
L2:
	mov	x4, x2
	lsl	x5, x2, #1
	ldr	x7, [x1, x2, lsl #3]
L3:
	add	x5, x5, #1
	cmp	x5, x3
	bgt	L5
	ldr	x8, [x1, x5, lsl #3]
	beq	L4
	add	x6, x5, #1
	ldr	x9, [x1, x6, lsl #3]
	cmp	x8, x9
	bge	L4
	add	x5, x5, #1
	mov	x8, x9
L4:
	cmp	x7, x8
	bge	L5
	str	x8, [x1, x4, lsl #3]
	mov	x4, x5
	lsl	x5, x5, #1
	b	L3
L5:
	str	x7, [x1, x4, lsl #3]
	b	L0
L6:
	mov	x0, #0
	mov	x8, #93
	svc	#0
	.size	_start, .-_start
