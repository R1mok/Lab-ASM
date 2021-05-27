.arch armv8-a
	.data
	.text
	.align 2
	.global reflectasm
	.type reflectasm, %function
reflectasm: // x0 - data, x1 - x, x2 - y, x3 - n
	stp x29, x30, [sp, #-16]!
	mov x5, #0 // x5 = i
	mov x4, #2
	sdiv x4, x2, x4 // x4 = y/2
	mov x21, #1
for1:
	cmp x5, x4
	bge exit1
	mov x6, #0 // x6 = j
for2:
	cmp x6, x1
	bge exit2
	mov x7, #0 // x7 = l
for3:
	cmp x7, x3 // x3 = n
	bge exit3
	madd x8, x6, x3, x7 // j*n + l
	mul x9, x1, x5 // x*i
	mul x9, x9, x3 // x9  i*x*n
	add x8, x8, x9 // x8 = index i*x*n + j*n + l
	ldrb w11, [x0, x8] // tmp
	sub x10, x2, x5 // x10 = y-i
	mul x9, x3, x1 // x9 = x*n
	mul x9, x10, x9 // x9 = (y-i)*x*n
	sub x9, x9, x3 // x9 = (y-i)*x*n - n
	mul x10, x6, x3
	sub x9, x9, x10
	add x9, x9, x7 // x9 = index (y-i)*x*n - n - j*n + l
	ldrb w12, [x0, x9]
	strb w11, [x0, x9]
	strb w12, [x0, x8]
	add x7, x7, x21
	b for3
exit3:
	add x6, x6, x21
	b for2
exit2:
	add x5, x5, x21
	b for1
exit1:
	ldp x29, x30, [sp], #16
	ret
