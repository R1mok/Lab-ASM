	// prog3 var 54
	.arch armv8-a
	.data
errmes1:
	.string	"Usage: (compress - c or decompress - d) (input_filename) (output_filename) \n"
errmes1len:
	.quad .-errmes1
input_errmes:
	.string "Can't open input file\n"
	.equ	input_errmeslen, .-input_errmes
output_errmes:
	.string "Can't open output file\n"
	.equ output_errmeslen, .-output_errmes
output_exist:
	.string "Output file already exist. Rewrite?\n"
output_existlen:
	.quad .-output_exist
	.text
	.align 	2
	.global	_start

	.type _start, %function
_start:
	ldr x0, [sp] // read parametrs
	cmp x0, #4 // x0=4 parametrs - good
	beq 0f
	bl printmes
ex:
	mov x0, #0
	mov x8, #93
	svc #0
0:
	ldr x0, [sp, #16] // input mode
	ldrb w0, [x0]
	cmp w0, 'c' // if compress
	beq 1f
	cmp w0, 'd' // if decompress
	beq 1f
	bl printmes
	b ex // else exit
1:
	mov x0, #-100 // get fd1
	ldr x1, [sp, #24]
	mov x2, #0
	mov x8, #56
	svc #0
	cmp x0, #0
	bge 2f // save fd1
	mov x0, #1 // error msg
	adr x1, input_errmes
	adr x2, input_errmeslen
	ldrb w2, [x2] // close file1
	mov x8, #64
	svc #0
	b ex
2:
	mov x21, x0 // save fd1 in x21
	mov x0, #-100 // get fd2
	ldr x1, [sp, #32]
	mov x2, #1
	mov x8, #56
	svc #0
	cmp x0, #0 // if file exist
	blt 3f
	mov x8, #57 // close file2
	mov x0, #1
	adr x1, output_exist
	adr x2, output_existlen
	ldrb w2, [x2]
	mov x8, #64
	svc #0
	mov x0, #0
	bl fgetc
	cmp x0, #0
	blt 1f
	cmp x0, 'y' // if input - y
	beq 3f
1:
	mov x0, x21 // dont remove file2
	mov x8, #57
	svc #0
	b ex
3:
	mov x0, #-100 // rewrite file2
	ldr x1, [sp, #32]
	mov x2, #01101
	mov x3, #00600
	mov x8, #56
	svc #0
	cmp x0, #0 // if error
	bge 4f
	mov x0, #1
	adr x1, output_errmes
	adr x2, output_errmeslen
	ldrb w2, [x2]
	mov x8, #64 // close files
	svc #0
	mov x0, #21
	mov x8, #57
	svc #0
	b ex
4:
	mov x22, x0 // save fd2
	mov x0, x21
	mov x1, x22
	ldr x3, [sp, #16]
	ldrb w3, [x3]
	cmp w3, 'c'
	bne 5f // desompress
	bl compress // compress
	b 6f
5:
	bl decompress
6:
	mov x0, x21 // close files
	mov x8, #57
	svc #0
	mov x0, x22
	mov x8, #57
	svc #0
	b ex
	.size _start, .-_start

	.global compress
	.type compress, %function
compress:
	stp x29, x30, [sp, #-16]! // save st and lr
	stp x21, x22, [sp, #-16]! // save fd1 and fd2 in sp
	stp x23, x24, [sp, #-16]! // save pos and mode
	stp x25, x26, [sp, #-16]! // save indexes
	mov x21, x0
	mov x22, x1
	sub sp, sp, #4096 //129
	bl fgetc
	cmp x0, #-1
	bne 0f
	b end
0:
	strb w0, [sp]
	mov x24, #0 // single symbol
1:
	mov x23, #1 // pos = 1
	mov x0, x21 // x0 = fd1
	bl fgetc // get char
	cmp x0, #-1
	beq exit1 // if x0 == -1
	cbnz x24, again // if x24 != 0
single:
	add x23, x23, #1 // pos = pos + 1
	cmp x0, #-1
	beq exit2 // if x0 == -1
	add x3, sp, x23 // x3 = current elem
	strb w0, [x3, #-1]
	ldrb w1, [x3, #-2]
	cmp x1, x0 // if a[i] == a[i+1]
	bne 2f
	mov x24, #1 // not single symbol
	b exit2
2:
	cmp x23, #4096 // if buf empty
	bge exit2
	mov x0, x22
	bl fputc
	mov x0, x21
	bl fgetc // can we write x0 in f2?
	b single
exit2:
	sub x1, x23, x24
	sub x1, x1, #2
	cmp x1, #0
	blt 4f
	add x26, x1, #1 // x26 - len
	mov x0, x22 // x0 - fd2
	//bl fputc // write count to file
	mov x25, #0 // index1
3:
	cmp x25, x26 // if index1 == index2
	bge 4f // exit
	mov x0, x22 // x0 - fd2
	ldrb w1, [sp, x25]
	//bl fputc // symbol
	add x25, x25, #1 // index1 = index1 + 1
	b 3b
4:
	add x3, sp, x23 // x3 = a[pos]
	ldrb w0, [x3, #-1]
	strb w0, [sp] // save to sp
	b 1b // repeat
again:
	add x23, x23, #1 // pos = pos + 1
	cmp x0, #-1
	beq exit3
	add x3, sp, x23 // x3 = a[pos]
	strb w0, [x3, #-1] // x3[0]
	ldrb w1, [x3, #-2] // x3[1]
	cmp x1, x0 // if x3[0] == x3[1]
	beq 5f
	b exit3
5:
	cmp x23, #4096 // if buf empty
	bge exit3
	mov x0, x21
	bl fgetc // get symbol
	b again
exit3:
	add x1, x23, #126 // if 48 - correct print
	mov x0, x22
	bl fputc // write count of symbols in file2
	mov x0, x22
	ldrb w1, [sp]
	bl fputc // write symbol in file2
	add x3, sp, x23 // x3 = a[pos]
	ldrb w0, [x3, #-1] //get symbol
	strb w0, [sp] // save symbol
	mov x24, #0 // single mod
	b 1b
exit1:
	mov x0, #0
end:
	add sp, sp, #4096
	ldp x25, x26, [sp], #16 // load from stack all parametrs
	ldp x23, x24, [sp], #16
	ldp x21, x22, [sp], #16
	ldp x29, x30, [sp], #16
	ret
	.size compress, .-compress

	.global decompress
	.type decompress, %function
decompress:
	stp x29, x30, [sp, #-16]! // save st, lr
	stp x21, x22, [sp, #-16]! // fd1, fd2
	stp x23, x24, [sp, #-16]! // length, index
	str x25, [sp, #-8]! // space for symbol
	mov x21, x0
	mov x22, x1
0:
	mov x0, x21 // input symbol from file1
	bl fgetc
	cmp x0, #-1
	beq exit4
	and w1, w0, #128 // 128
	cbnz w1, repeat
	cmp x23, #0//
	bne single1//
	mov x1, x0//
	mov x0, x22//
	bl fputc//
single1:
	and w23, w0, #31 // 31
	//add w23, w23, #1
	cmp x23, #1
	beq ex1
	b ex2
ex0:
	cmp x0, #65
	bne 0b
	b ex2
ex1:
	cmp x0, #97
	bne ex0
	b ex2
ex2:
	sub x24, x23, #1//
	//mov x24, #0
1:
	cmp x24, x23 // if length > index
	bge 2f
	//mov x0, x21
	//bl fgetc // input symbol from file1 in x1
	mov x1, x0
	mov x0, x22
	bl fputc // write symbol in file2
	add x24, x24, #1 // index = index + 1
	b 1b
2:
	b 0b
repeat:
	and w23, w0, #31 // 31
	add w23, w23, #2
	mov x0, x21
	bl fgetc // input symbol in x25
	mov x24, #0
	mov x25, x0
3:
	cmp x24, x23
	bge 4f
	mov x0, x22
	mov x1, x25
	bl fputc // write symbol in file2
	add x24, x24, #1 // index = index + 1
	b 3b
4:
	b 0b
exit4:
	ldr x25, [sp], #8 // load from sp all parametrs
	ldp x23, x24, [sp], #16
	ldp x21, x22, [sp], #16
	ldp x29, x30, [sp], #16
	ret
	.size decompress, .-decompress

	.global printmes
	.type printmes, %function
printmes:
	stp x29, x30, [sp, #-16]! // save sp, lr
	mov x0, #1
	adr x1, errmes1
	adr x2, errmes1len
	ldrb w2, [x2]
	mov x8, #64
	svc #0
	ldp x29, x30, [sp], #16
	ret
	.size printmes, .-printmes

	.global fgetc // function get symbol in x0
	.type fgetc, #function
fgetc:
	stp x29, x30, [sp, #-16]!
	sub x1, sp, #1
	mov x2, #1
	mov x8, #63
	svc #0
	cmp x0, #0
	bgt 0f
	mov x0, #-1
	ldp x29, x30, [sp], #16
	ret
0:
	ldrb w0, [sp, #-1]
	ldp x29, x30, [sp], #16
	ret
	.size fgetc, .-fgetc

	.global fputc // function save symbol in file
	.type fputc, %function
fputc:
	stp x29, x30, [sp, #-16]!
	strb w1, [sp, #-1]!
	mov x1, sp
	mov x2, #1
	mov x8, #64
	svc #0
	cmp x0, #0
	bgt 0f
	mov x0, #-1
	add sp, sp, #1
	ldp x29, x30, [sp], #16
	ret
0:
	add sp, sp, #1
	ldp x29, x30, [sp], #16
	ret
	.size fgetc, .-fgetc
