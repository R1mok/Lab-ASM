	.arch armv8-a
	.data
	.align 	3

help_mesg:
	.ascii	"Command usage:\n simple-compress (operation) (input_file) (output_file)\n"
	.ascii	"operation - one of \'compress\' and \'decompress\'\n"
help_mesg_len:
	.quad	. - help_mesg
inp_open_msg:
	.ascii	"Can't open input file\n"
inp_open_msg_len:
	.quad	(. - inp_open_msg)
out_open_msg:
	.ascii	"Can't open output file\n"
out_open_msg_len:
	.quad	(. - out_open_msg)
out_dialog:
	.ascii	"Output file already exists. Rewrite it? (y/n)\n"
out_dialog_len:
	.quad	(.-out_dialog)
ok_msg:
	.ascii	"Completed\n"
ok_msg_len:
	.quad	(. - ok_msg)
src:
	.skip	4
dest:
	.skip	4
	.text
	.align	2
	.global	_start
	.type	_start, %function
_start:
	ldr		x0, [sp]
	cmp		x0, #4
	beq		0f
	bl		print_help
	mov		x0,	#0
	mov		x8,	#93
	svc		#0
0:
	ldr		x0,	[sp, #16]
	ldrb	w0,	[x0]
	cmp		w0, 'c'
	beq		1f
	cmp		w0, 'd'
	beq		1f
	bl		print_help
	mov		x0,	#0
	mov		x8, #93
	svc		#0
1:
	//open src
	mov		x0, #-100
	ldr 	x1, [sp, #24]
	mov		x2, #0
	mov		x8, #56
	svc		#0
	cmp		x0, #0
	bge		2f
	mov		x0, #1
	adr		x1, inp_open_msg
	adr		x2, inp_open_msg_len
	ldrb	w2, [x2]
	mov		x8, #64
	svc		#0
	mov		x0, #0
	mov		x8,	#93
	svc		#0
2:	
	mov		x21, x0 //save src descriptor
	//open dest
	mov		x0, #-100
	ldr 	x1, [sp, #32]
	mov		x2, #1
	mov		x8, #56
	svc		#0
	cmp		x0, #0
	blt		3f
	mov 	x8, #57 // close existing dest file
	svc		#0
	mov		x0, #1
	adr		x1, out_dialog
	adr		x2, out_dialog_len
	ldrb	w2, [x2]
	mov		x8, #64
	svc		#0
	mov		x0, #0
	bl 		fgetc
	cmp		x0, #0
	blt		1f
	cmp		x0, 'y'
	beq		3f
1:
	mov		x0, x21
	mov 	x8, #57
	svc		#0
	mov		x0, #0
	mov		x8,	#93
	svc		#0
3:
	mov		x0, #-100
	ldr 	x1, [sp, #32]
	mov		x2, #01101
	mov		x3, #00600
	mov		x8, #56
	svc		#0
	cmp		x0, #0
	bge		1f
	mov		x0, #1
	adr		x1, out_open_msg
	adr		x2, out_open_msg_len
	ldrb	w2, [x2]
	mov		x8, #64
	svc		#0
	mov		x0, x21
	mov 	x8, #57
	svc		#0
	mov		x0, #0
	mov		x8,	#93
	svc		#0	
1:
	mov		x22, x0 //save dest descriptor
	mov 	x0, x21
	mov		x1, x22
	ldr		x3, [sp, #16]
	ldrb	w3, [x3]
	cmp		w3, 'c'
	bne		4f
	bl		compress
	b 		5f
4:
	bl		decompress
5:
	mov		x0,	#1
	adr		x1, ok_msg
	adr		x2, ok_msg_len
	ldr		x2,	[x2]
	mov		x8, #64
	svc		#0
	mov		x0, x21 // close opened files
	mov 	x8, #57
	svc		#0
	mov		x0, x22
	mov 	x8, #57
	svc		#0
	mov		x0, #0
	mov		x8, #93
	svc		#0
	.size 	_start, (. - _start)

	.global print_help
	.type 	print_help, %function
print_help:
	stp		x29, x30, [sp, #-16]!
	mov		x0,	#1
	adr		x1, help_mesg
	adr		x2, help_mesg_len
	ldr		x2,	[x2]
	mov		x8, #64
	svc		#0
	ldp		x29, x30, [sp], #16
	ret
	.size	print_help, (. - print_help)

	.global	compress
	.type	compress, %function
compress:
	stp		x29, x30, [sp, #-16]!
// free space for args save
	stp		x21, x22, [sp, #-16]! // src , dest
	stp		x23, x24, [sp, #-16]! // pos , mode
	stp 	x25, x26, [sp, #-16]! // for loop counter
	mov		x21, x0
	mov 	x22, x1
	sub		sp, sp, #129 // alocate buf
	bl		fgetc
	cmp		x0, #-1
	bne		1f
	b 		end
1:
	strb	w0, [sp]
	mov		x24, #0 // set mode = UNIQUE
while:
	mov		x23, #1 // set pos = 1
	mov 	x0, x21
	bl 		fgetc
	cmp		x0, #-1
	beq		end_while
	cbnz	x24, repeat
unique:
	add		x23, x23, #1 // inc pos
	cmp		x0, #-1
	beq		end_while_2
	add 	x3, sp, x23
	strb	w0, [x3, #-1]		
	ldrb	w1, [x3, #-2]
	cmp		x1, x0
	bne		2f
	mov		x24, #1 // change mode to REPEAT
	b 		end_while_2
2:
	cmp		x23, #129
	bge		end_while_2
	mov		x0, x21
	bl		fgetc
	b 		unique
end_while_2:
	sub		x1, x23, x24
	sub 	x1, x1, #2
	cmp		x1, #0
	blt		4f
	mov		x0, x22
	add		x26, x1, #1 // set loop len
	bl 		fputc
	mov		x25, #0 // set loop counter
3: //for
	cmp		x25, x26
	bge		4f
	mov		x0,	x22
	ldrb	w1, [sp, x25]
	bl 		fputc
	add		x25, x25, #1
	b 3b
4:
	add		x3, sp, x23
	ldrb	w0, [x3, #-1]
	strb	w0, [sp]
	b 		while
repeat:
	add		x23, x23, #1 // inc pos
	cmp		x0, #-1
	beq		end_while_3
	add 	x3, sp, x23
	strb	w0, [x3, #-1]		
	ldrb	w1, [x3, #-2]
	cmp		x1, x0
	beq		2f
	b 		end_while_3
2:
	cmp		x23, #129
	bge		end_while_3
	mov		x0, x21
	bl		fgetc
	b 		repeat
end_while_3:
	add		x1, x23, #126
	mov		x0, x22
	bl 		fputc
	mov		x0, x22
	ldrb 	w1, [sp]
	bl 		fputc
	add 	x3, sp, x23
	ldrb	w0, [x3, #-1]
	strb	w0, [sp]
	mov		x24, #0 // set mode = UNIQUE
	b 		while
end_while:
	mov		x0, #0
end:
	add		sp, sp, #129
	ldp 	x25, x26, [sp], #16
	ldp		x23, x24, [sp], #16
	ldp		x21, x22, [sp], #16
	ldp		x29, x30, [sp], #16
	ret
	.size	compress, (. - compress)

	.global	decompress
	.type	decompress, %function
decompress:
	stp		x29, x30, [sp, #-16]!
// free space for args save
	stp		x21, x22, [sp, #-16]! // src , dest
	stp		x23, x24, [sp, #-16]! // len , i
	str 	x25, [sp, #-8]! // char
	mov		x21, x0
	mov		x22, x1
while_4:
	mov		x0, x21
	bl 		fgetc
	cmp		x0, #-1
	beq		end_while_4
	and		w1, w0, #0x80
	cbnz	w1, d_repeat
d_unique:
	and		w23, w0, #0x1F
	add		w23, w23, #1
	mov		x24, #0
1:	// for
	cmp		x24, x23
	bge		2f
	mov		x0, x21
	bl 		fgetc
	mov		x1, x0
	mov		x0, x22
	bl 		fputc
	add		x24, x24, #1
	b 		1b
2:
	b 		while_4
d_repeat:
	and 	w23, w0, #0x1F
	add 	w23, w23, #2
	mov 	x0, x21
	bl 		fgetc
	mov		x25, x0
	mov 	x24, #0
1:
	cmp		x24, x23
	bge		2f
	mov		x1, x25
	mov		x0, x22
	bl 		fputc
	add 	x24, x24, #1
	b 		1b
2:
	b while_4
end_while_4:
	ldr 	x25, [sp], #8
	ldp		x23, x24, [sp], #16
	ldp		x21, x22, [sp], #16
	ldp		x29, x30, [sp], #16
	ret
	.size 	decompress, (. - decompress)
	
	
	// fgetc(FILE* fd)
	.global	fgetc
	.type	fgetc, %function
fgetc:
	stp		x29, x30, [sp, #-16]!
	sub		x1, sp, #1
	mov		x2, #1
	mov		x8, #63
	svc		#0
	cmp		x0, #0
	bgt		1f
	mov		x0, #-1
	ldp		x29, x30, [sp], #16
	ret
1:
	ldrb	w0, [sp, #-1]
	ldp		x29, x30, [sp], #16
	ret
	.size	fgetc, (. - fgetc)

	// fputc(FILE* fd, char c)
	.global	fputc
	.type	fputc, %function
fputc:
	stp		x29, x30, [sp, #-16]!
	strb	w1, [sp, #-1]!
	mov		x1, sp
	mov		x2, #1
	mov		x8,	#64
	svc		#0
	cmp		x0, #0
	bgt		1f
	mov		x0, #-1
	add		sp, sp, #1
	ldp		x29, x30, [sp], #16
	ret
1:
	add		sp, sp, #1
	ldp		x29, x30, [sp], #16
	ret
	.size	fgetc, (. - fgetc)
