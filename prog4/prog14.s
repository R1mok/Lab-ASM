	.arch armv8-a
//	Compare exponent from mathlib and my own implementation
	.data
mes1:
	.string	"Input x\n"
mes2:
	.string	"%lf"
mes3:
	.string	"exp(%.17g)=%.17g\n"
mes4:
	.string	"myexp(%.17g)=%.17g\n"
mes5:
	.string "0x%lx\n"
	.text
	.align	2
	.global	myexp
	.type	myexp, %function
myexp:
	fmov	d5, #1.0
	fmov	d1, d5
	fmov	d2, d5
	fmov	d3, d5
0:
	fmov	d4, d2
	fmul	d1, d1, d0
	fdiv	d1, d1, d3
	fadd	d2, d2, d1
	fadd	d3, d3, d5
	fcmp	d2, d4
	bne	0b
	fmov	d0, d2
	ret
	.size	myexp, .-myexp
	.global	main
	.type	main, %function
	.equ	x, 16
	.equ	y, 24
main:
	stp	x29, x30, [sp, #-32]!
	mov	x29, sp
	adr	x0, mes1
	bl	printf
	adr	x0, mes2
	add	x1, x29, x
	bl	scanf
	ldr	d0, [x29, x]
	bl	exp
	str	d0, [x29, y]
	adr	x0, mes3
	ldr	d0, [x29, x]
	ldr	d1, [x29, y]
	bl	printf
	adr	x0, mes5
	ldr	x1, [x29, y]
	bl	printf
	ldr	d0, [x29, x]
	bl	myexp
	str	d0, [x29, y]
	adr	x0, mes4
	ldr	d0, [x29, x]
	ldr	d1, [x29, y]
	bl	printf
	adr	x0, mes5
	ldr	x1, [x29, y]
	bl	printf
	mov	w0, #0
	ldp	x29, x30, [sp], #32
	ret
	.size	main, .-main
