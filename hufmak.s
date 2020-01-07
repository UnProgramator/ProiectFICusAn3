.global hufmak


.extern write_str
.extern write_word
.extern setbit[data]
.extern hufapp
.extern alloc

.data
.balign 4
n: .word 0

/*setbit: .word   0x1, 0x2, 0x4, 0x8,0x10, 0x20, 0x40, 0x80,0x100, 0x200, 0x400, 0x800,0x1000, 0x2000, 0x4000, 0x8000,0x10000, 0x20000, 0x40000, 0x80000,0x100000, 0x200000, 0x400000, 0x800000,0x1000000, 0x2000000, 0x4000000, 0x8000000,0x10000000, 0x20000000, 0x40000000, 0x80000000*/
.text
hufmak:
	//; in ordine nfreq[] -> r0 -> [sp+8]
	//;			  nchin -> r1 -> [sp+12]
	//;			  *ilog -> r2 -> [sp+16]
	//; 		  *nlog -> r3 -> [sp+20]
	//;			  *hcode -> r4 -> [sp+24]
	//;					node	-> r5
	//;					j		-> r6
	//;					k		-> r7
	//;					nused	-> r8
	//;					*up		-> r9
	//;					*index	-> r10
	//;					*nprob	-> r11
	//;					ibit	-> [sp] -> r1
	//;					n		-> [sp+4] ->r2
	stmdb sp!, {r0-r12,lr}  //push r0-r12,lr
	//sub sp,sp,#8		   //rezervam 2 locati pt ibit, n
	str r1,[r4, #+16] //hcode->nch=nchin;
	
	push {r2}
	push {r3}
	push {r0}
	//index=lvector(1,(long)(2*hcode->nch-1))
	mov r0, r1  // aloca 4 byte in plus ----------------------------------------------------
	lsl r0,#3   // 2* nchin *4byte/word
	bl alloc 
	mov r10,r0
	
	//up=(long *)lvector(1,(long)(2*hcode->nch-1)); 
	mov r0, r1    // aloca 4 byte in plus  ---------------------------------------------------------
	lsl r0,#3
	bl alloc 
	mov r9,r0
	
	//nprob=lvector(1,(long)(2*hcode->nch-1));
	mov r0, r1  // aloca 4 byte in plus -------------------------------------------------------
	lsl r0,#3 
	bl alloc  
	mov r11,r0
	
	//for (nused=0,j=1;j<=hcode->nch;j++)
	mov r8, #0
	mov r6, #1
	//ldr r0, [sp, #+8]	// nfreq in r0  ---------------------------------------------------------------
	pop {r0}
	ldr r2, [r4] 		// hcode->icod in r2
	ldr r3, [r4, #+4]	// hcode->ncod in r3
for1:
	ldr r12,[r4,#+16]
	cmp r6,r12
	bgt endfor1
	
	//nprob[j]=nfreq[j]
	ldr r1, [r0,+r6]
	str r1, [r11,+r6]
	
	//if (nfreq[j]) index[++nused]=j
	cmp r1,#0
	beq endif1
	add r8,#1
	ldr r6, [r10, +r8, LSL #2]
	
endif1:	
	//hcode->icod[j]=hcode->ncod[j]=0
	mov r1,#0
	str r1,[r3,+r6, LSL #2]
	str r1,[r2,+r6, LSL #2]

	add r6,#1
	B for1
endfor1:
	
	//for (j=nused;j>=1;j--) hufapp(index,nprob,nused,j);
	mov r6,r8
for2:
	cmp r6,#1
	blt endfor2
	mov r0,r10
	mov r1,r11
	mov r2,r8
	mov r3,r6
	bl hufapp
	sub r6,r6,#1 
	b for2
endfor2:
	//k=hcode->nch;
	ldr r7, [r4,#+16]
	
	//while (nused > 1)
while1:
	cmp r8, #1
	ble endwhile1
	
	//node=index[1];
	ldr r5, [r10,#+4]
	
	//index[1]=index[nused--];
	ldr r0, [r10, +r8, LSL #2]
	str r0, [r10,#+4]
	sub r8, #1
	
	//hufapp(index,nprob,nused,1);
	mov r0,r10
	mov r1,r11
	mov r2,r8
	mov r3,#1
	bl hufapp
	
	//nprob[++k]=nprob[index[1]]+nprob[node];
	add r7,#1
	ldr r0,[r10,#+4]    		// index[1] in r0
	ldr r1,[r11,+r0, LSL #2]
	ldr r12,[r11, +r5, LSL #2]
	add r1,r1,r12
	str r1, [r11, +r7, LSL #2]
	
	//hcode->left[k]=node;
	ldr r1, [r4, #+8]
	str r5, [r1, +r7, LSL #2]
		
	//hcode->right[k]=index[1];
	ldr r1, [r4, #+12]
	str r0, [r1, +r7, LSL #2]
	
	//up[index[1]] = -(long)k;
	mov r1,#0
	sub r1,r7
	str r1, [r9, r0, LSL #2]
	
	//up[node]=index[1]=k;
	str r7, [r10,#+4]
	str r7, [r9, +r5, LSL #2]
	
	//hufapp(index,nprob,nused,1);
	mov r0,r10
	mov r1,r11
	mov r2,r8
	mov r3,r6
	bl hufapp
    
	b while1
endwhile1:
   
	//up[hcode->nodemax=k]=0;
	ldr r7,[r4, #+20]
	mov r0,#0
	ldr r0,[r9, +r7, LSL #2]
	
	//for (j=1;j<=hcode->nch;j++) 
	mov r6,#1
for3:
	ldr r12,[r4, #+16]
	cmp r6,r12
	bgt endfor3
	//if (nprob[j])
	ldr r12,[r1, +r6, LSL #2]
	cmp r0,r12
	bne endif2
	
	//for (n=0,ibit=0,node=up[j];node;node=up[node],ibit++)
	mov r1,#0	//n in r1
	mov r2,#0	// ibit in r2
	ldr r5, [r9,+r6, LSL #2]
for4:
	cmp r5,r0
	bne endfor4
	//if (node < 0)
	cmp r5,r0
	bge endif3
	//n |= setbit[ibit];
	ldr r3, =setbit
	ldr r12,[r3, +r2, LSL #2]
	orr r1,r12
	
	//node = -node;
	sub r5,r0,r5
endif3:
	ldr r5, [r9, +r5, LSL #2]
	add r2,#1
endfor4:
	//hcode->icod[j]=n;
	ldr r3, [r4]
	str r1, [r3, +r6, LSL #2]
	
	//hcode->ncod[j]=ibit;
	ldr r3, [r4,#+4]
	str r2, [r3, +r6, LSL #2]
endif2:
	add r6,#1
	b for3
endfor3:
	// *nlong=0;
	//ldr r3,[sp,#+20] //----------------------------------------------------------------------
	pop {r3}
	str r0,[r3]
	
	//for (j=1;j<=hcode->nch;j++)
	mov r6,#1
for5:
	ldr r12,[r4,#+16]
	cmp r6,r12
	bgt endfor5
	//if (hcode->ncod[j] > *nlong)
	ldr r1,[r4,#+4]
	ldr r2,[r1, +r6, LSL #2]
	ldr r12,[r3]
	
	cmp r2, r12
	ble endif4
	// *nlong=hcode->ncod[j];
	str r2, [r3]
	
	// *ilong=j-1;
	sub r0, r6, #1
	//ldr r2, [sp, #16] //-----------------------------------------------------------------------
	pop {r2}
	str r0, [r2]

endif4:	
	add r6,#1
	b for5
endfor5:
	
	
	ldmia sp!, {r0-r12,pc}  //push r0-r1,pc ; restaureaza reg si return
	
