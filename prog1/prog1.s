	.arch armv8-a
//	res = ((a + b)*(a + b) - (c - d)*(c - d))/(a + e*e*e - c)
//  all signed
	.data
	.align	3
res:
	.skip	8
a:
	.short	20000
b:
	.short	30000
c:
	.short	30000
d:
	.short	-20000
e:
	.short	20000
	.text
	.align	2
	.global _start
	.type	_start, %function
_start:
	adr	x0, a
	ldrsh	w1, [x0]
	adr	x0, b
	ldrsh	w2, [x0]
	adr	x0, c
	ldrsh	w3, [x0]
	adr	x0, d
	ldrsh	w4, [x0]
	adr	x0, e
	ldrsh	w5, [x0]
	adds w6, w1, w2 // a+b
	mul	x7, x6, x6 // (a+b)(a+b)
	subs w8, w3, w4 // (c-d)
	mul x10, x8, x8 // (c-d)*(c-d)
	subs x9, x7, x10 // (a+b)(a+b) - (c-d)(c-d)
	bvs overflow_detected
	mul w8, w5, w5 // e*e 
	mul x8, x8, x5 // e*e*e
	adds w8, w8, w1 // a + e*e*e
	subs w8, w8, w3, sxtw // a+e*e*e - c
	sdiv x9, x9, x8 // ((a+b)(a+b)-(c-d)(c-d)) / (a+e*e*e-c)
	cbz w8, div_by_zero // result in w9
	adr x0, res
	str x9, [x0]
	mov x8, #93
	mov x0, #0
	svc #0
div_by_zero:
	mov x0, #1
	svc #0
overflow_detected:
	mov x0, #2
	svc #0
	//smull	x8, w6, w7
	//sdiv	x8, x8, x3
	//add	w6, w3, w4
	//sdiv	w6, w6, w1
	//sub	x8, x8, w6, sxtw
	
	.size	_start, .-_start
