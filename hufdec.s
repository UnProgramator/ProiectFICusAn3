.global hufdec

.extern write_str
.data
.balign 4
setbit8: .byte   0x1, 0x2, 0x4, 0x8,0x10, 0x20, 0x40, 0x80

.text
hufdec:
	//; in ordine	*ich	-> r0
	//;			 	*code	-> r1
	//;			  	lcode	-> r2
	//;				*nb		-> r3
	//;				*hcode	-> r4
	//;				node	-> r5 - variabile locale
	//;				nc		-> r6
	
	stmdb sp!, {r0-r8,lr}  //push r0-r1,lr
	//node=hcode->nodemax;
	ldr r5,[r4,#+20]
	//for(;;)
loop:
	// nc=(*nb >> 3);
	ldr r6,[r3]
	LSR r6,#3
	
	//if (++nc > lcode) 
	add r6,#1
	cmp r6,r2
	ble endif1
	//*ich=hcode->nch;
	ldr r7, [r4,#+16]
	str r7, [r0]
	
	//return;
	ldmia sp!, {r0-r8,pc} 
endif1:
	//node=(code[nc] & setbit[7 & (*nb)++] ? hcode->right[node] : hcode->left[node]);
	ldr r7,[r3]
	add r8,r7,#1
	str r8,[r3]
	ldr r8,=setbit8
	and r7,#7
	ldrb r7,[r8,+r7]
	ldrb r8,[r1,+r6]
	and r7,r8
	cmp r7,#0
	ldrne r7,[r4,#+12]
	ldreq r7,[r4,#+8]
	ldr r5,[r7,+r5]
	
	//if (node <= hcode->nch)
	ldr r8,[r4,#+16]
	cmp r5,r8
	bgt loop
	
	//*ich=node-1;
	sub r5,#1
	str r5, [r0]
	
	//return;
	ldmia sp!, {r0-r8,pc} 
	
