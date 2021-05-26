.arch armv8-a
	.data
	.text
	.align 2
	.global reflectasm
	.type reflectasm, %function
reflectasm:
	stp x29, x30, [sp, #-16]!
	mov x5, #0
	mov x4, #2
	sdiv x4, x1, x4
	mov x21, #1
for1:
	cmp x5, x2
	bge exit1
	mov x6, #0
for2:
	cmp x6, x4
	bge exit2
	mov x7, #0
for3:
	cmp x7, x3
	bge exit3
	madd x8, x6, x3, x7
	mul x9, x1, x5
	mul x9, x9, x3
	add x8, x8, x9
	ldrb w11, [x0, x8]
	madd x9, x1, x3, x9
	sub x9, x9, x3
	msub x10, x6, x3, x7
	add x9, x9, x10
	ldrb w12, [x0, x9]
	strb w11, [x0, x9]
	strb w12, [x0, x8]
	add x7, x7, x21
	b for3
exit3:
	add x6, x6, x21
	b for3
exit2:
	add x5, x5, x21
	b for1
exit1:
	ldp x29, x30, [sp], #16
	ret
