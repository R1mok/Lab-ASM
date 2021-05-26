	.arch armv8-a
//	Сalculating the determinant of a matrix
	.data
usage:
	.string "Usage: %s file\n"
mes:
	.string "Determinant equal %f\n"
format:
	.string	"Incorrect format of file\n"
size:
	.string	"Dimension of matrix must be less or equal 8\n"
formint:
	.string	"%d"
formdouble:
	.string "%lf"
mode:
	.string "r"
	.text
	.align	2
	.global	main
	.type	main, %function
	.equ	progname, 32
	.equ	filename, 40
	.equ	filestruct, 48
	.equ	n, 56
	.equ	per, 64
	.equ	matrix, 128
main:
	sub	sp, sp, #640
	stp	x29, x30, [sp]
	stp	x27, x28, [sp, #16]
	mov	x29, sp
	cmp	w0, #2
	beq	0f
	ldr	x2, [x1]
	adr	x0, stderr
	ldr	x0, [x0]
	adr	x1, usage
	bl	fprintf
9:
	mov	w0, #1
	ldp	x29, x30, [sp]
	ldp	x27, x28, [sp, #16]
	add	sp, sp, #640
	ret
0:
	ldr	x0, [x1]
	str	x0, [x29, progname]
	ldr	x0, [x1, #8]
	str	x0, [x29, filename]
	adr	x1, mode
	bl	fopen
	cbnz	x0, 1f
	ldr	x0, [x29, filename]
	bl	perror
	b	9b
1:
	str	x0, [x29, filestruct]
	adr	x1, formint
	add	x2, x29, n
	bl	fscanf
	cmp	w0, #1
	beq	2f
	ldr	x0, [x29, filestruct]
	bl	fclose
	adr	x0, stderr
	ldr	x0, [x0]
	adr	x1, format
	bl	fprintf
	b	9b
2:
	mov	x27, #0
	ldr	x28, [x29, n]
	cmp	x28, #0
	ble	3f
	cmp	x28, #8
	bgt	3f
	mul	x28, x28, x28
	b	4f
3:
	ldr	x0, [x29, filestruct]
	bl	fclose
	adr	x0, stderr
	ldr	x0, [x0]
	adr	x1, size
	bl	fprintf
	b	9b
4:
	ldr	x0, [x29, filestruct]
	adr	x1, formdouble
	lsl	x2, x27, #3
	add	x2, x2, x29
	add	x2, x2, matrix
	bl	fscanf
	cmp	w0, #1
	beq	5f
	ldr	x0, [x29, filestruct]
	bl	fclose
	adr	x0, stderr
	ldr	x0, [x0]
	adr	x1, format
	bl	fprintf
	b	9b
5:
	add	x27, x27, #1
	cmp	x27, x28
	bne	4b
	ldr	x0, [x29, filestruct]
	bl	fclose
	add	x0, x29, per
	mov	x1, #0
	ldr	x28, [x29, n]
6:
	str	x1, [x0, x1, lsl #3]
	add	x1, x1, #1
	cmp	x1, x28
	blt	6b
	mov	x8, #0
	add	x9, x29, matrix
	fmov	d0, xzr
	fmov	d2, #1.0
	fmov	d3, #-1.0
7:
	tst	x8, #1
	fcsel	d1, d2, d3, eq
	mov	x1, #0
8:
	lsl	x2, x1, #3
	mul	x2, x2, x28
	add	x2, x2, x9
	ldr	x3, [x0, x1, lsl #3]
	ldr	d4, [x2, x3, lsl #3]
	fmul	d1, d1, d4
	add	x1, x1, #1
	cmp	x1, x28
	blt	8b
	fadd	d0, d0, d1
	mov	x1, #0
	mov	x2, #-1
	ldr	x5, [x0, x1, lsl #3]
9:
	mov	x4, x5
	add	x1, x1, #1
	cmp	x1, x28
	beq	1f
	ldr	x5, [x0, x1, lsl #3]
	cmp	x4, x5
	blt	0f
	cmp	x5, x6
	blt	9b
	mov	x3, x1
	mov	x7, x5
	b	9b
0:
	sub	x2, x1, #1
	mov	x3, x1
	mov	x6, x4
	mov	x7, x5
	b	9b
1:
	cmp	x2, #-1
	beq	3f
	str	x7, [x0, x2, lsl #3]
	str	x6, [x0, x3, lsl #3]
	add	x8, x8, #1
	mov	x1, x2
	mov	x2, x28
2:
	add	x1, x1, #1
	sub	x2, x2, #1
	cmp	x1, x2
	bge	7b
	ldr	x4, [x0, x1, lsl #3]
	ldr	x5, [x0, x2, lsl #3]
	str	x5, [x0, x1, lsl #3]
	str	x4, [x0, x2, lsl #3]
	add	x8, x8, #1
	b	2b
3:
	adr	x0, mes
	bl	printf
	mov	w0, #0
	ldp	x29, x30, [sp]
	ldp	x27, x28, [sp, #16]
	add	sp, sp, #640
	ret
	.size	main, .-main
