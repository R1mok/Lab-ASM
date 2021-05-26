	.arch armv8-a
	.data
mes1:
	.string "Input x:"
formatdouble:
	.string "%lf"
formatint:
	.string "%d "
double_in_file:
	.string "%.17lf \n"
mes3:
	.string "cos(%.17g)  =%.17g\n"
mes4:
	.string "mycos(%.17g)=%.17g\n"
mes_file:
	.string "term:%g\n"
filename:
	.string "logfile"
mode:
	.string "w"
	.text
	.align 3
	.global mycos
	.type mycos, %function
	.equ filestruct, 48
	.equ s1s2, 64
	.equ s3s4, 80
	.equ s5s6, 96
	.equ s7s8, 112
	.equ x7x10, 128
	.equ fors0, 144
mycos:
	stp x29, x30, [sp, #-32]!
	str s0, [x29, fors0]
	adr x0, filename
	adr x1, mode
	bl fopen
	cbz x0, exit
	str x0, [x29, filestruct]
	adr x1, formatint
	mov x2, #1
	bl fprintf
	ldr x0, [x29, filestruct]
	adr x1, double_in_file
	fmov d0, #1.0
	bl fprintf
	ldr s0, [x29, fors0]
//
	fmov s5, #1.0
	fmov s1, s5 // sum
	fmov s2, s5 //
	fmov s3, s5 // term
	mov x7, #0 // sign
	fsub s6, s5, s5
	fmov s8, s5
	mov x10, #1 // count of terms
	b 0f
beg:
	ldp x7, x10, [x29, x7x10]
	ldp s1, s2, [x29, s1s2]
	ldp s3, s4, [x29, s3s4]
	ldp s5, s6, [x29, s5s6]
	ldp s7, s8, [x29, s7s8]
	ldr s0, [x29, fors0]
0:
	add x10, x10, #1
	fmov s4, s1
	fmov s9, #2.0
	fadd s6, s6, s9
	fmul s2, s2, s0
	fmul s2, s2, s0
	fmul s8, s8, s6
	fmov s9, #1.0
	fsub s6, s6, s9
	fmul s8, s8, s6
	fadd s6, s6, s9
	fdiv s3, s2, s8
	cmp x7, #1
	beq 1f
	fsub s1, s1, s3
	b 2f
1:
	fadd s1, s1, s3
2:
	mov x9, #1
	sub x7, x9, x7
//save value in stack
	stp x7, x10, [x29, x7x10]
	stp s1, s2, [x29, s1s2]
	stp s3, s4, [x29, s3s4]
	stp s5, s6, [x29, s5s6]
	stp s7, s8, [x29, s7s8]
	str s0, [x29, fors0]
// write  in file
	ldr x0, [x29, filestruct]
	adr x1, formatint
	mov x2, x10
	bl fprintf
	ldp s1, s2, [x29, s1s2]
	ldr x0, [x29, filestruct]
	adr x1, double_in_file
	fcvt d0, s1
	bl fprintf
//
	ldp s1, s2, [x29, s1s2]
	ldp s3, s4, [x29, s3s4]
	fcmp s1, s4
	bne beg
	fmov s0, s1
exit:
	ldp x29, x30, [sp], #32
	ret

	.size mycos, .-mycos
	.global main
	.type main, %function
	.equ x, 32
	.equ y, 40
main:
	stp x29, x30, [sp, #-32]!
	mov x29, sp
	adr x0, mes1
	bl printf
	adr x0, formatdouble
	add x1, x29, x
	bl scanf
	ldr d0, [x29, x]
	bl cos
	str d0, [x29, y]
	adr x0, mes3
	ldr d0, [x29, x]
	ldr d1, [x29, y]
	bl printf
	ldr d0, [x29, x]
	fcvt s0, d0
	bl mycos
	fcvt d0, s0
	str d0, [x29, y]
	adr x0, mes4
	ldr d0, [x29, x]
	ldr d1, [x29, y]
	bl printf
	mov w0, #0
	ldp x29, x30, [sp], #32
	ret
	.size main, .-main

