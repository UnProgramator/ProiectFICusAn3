.global hufmak

.extern setbit[data]
.extern hufapp
.extern lvector

.extern afis_vector
.extern afis_hcode
.extern write_byte
.extern write_str

.data
.balign 4
new_line: .asciz "\n\r"

/*struct{
    *icod - 0
    *ncod -4
    *left -8
    *right-12
    nch-16
    nodemax-20
    }huffcode*/
    
    
.text
hufmak:
	/*@param    nfreq word* -> r0
                nchin word  -> r1
                ilong word* -> r2
                nlong word* -> r3
                hcode word* -> r4
        
	  @local    ibit    word  -> variabil
                node    word  -> variabil
                up      word* -> r6
                j       word  -> variabil
                k       word  -> variabil
                index   word* -> r5
                n       word  -> variabil
                nused   word  -> r8
                nprob   word* -> r7
	*/
	
	push {lr}
	//setare hcode->nch si alocare vectori
	push {r0-r4}
	str r1, [r4, #16]
	
	lsl r4, r1, #1 // r4 -> 2*hcode->nch
	
	mov r0, #1
	mov r1, r4
	bl lvector
	mov r5, r0
	
	mov r0, #1
	mov r1, r4
	bl lvector
	mov r6, r0
	
	mov r0, #1
	mov r1, r4
	bl lvector
	mov r7, r0
	
	pop {r0-r4}
	
	//primele 2 foruri
	
	
	mov r8, #0 //nused = 0
	mov r9, #1 //j=1
	
	for1:
        cmp r9, r1 //  j <= nchin = hcode->nch
        bgt end_for1
        
        //nprob[j] = nfreq[j]
        ldr r10, [r0, r9, lsl #2]
        str r10, [r7, r9, lsl #2]
        
        //if nfreq[j]!=0 
        cmp r10, #0
        beq else1
        //then index[++nused] = j
            add r8, #1
            str r9, [r5, r8, lsl #2]
        else1:
        
        //hcode->icod[j] = hcode->ncode[j] = 0
        mov r11, #0
        ldr r12, [r4]
        str r11, [r12, r9, lsl #2] //icod[j]=0
        ldr r12, [r4, #4]
        str r11, [r12, r9, lsl #2] //ncode[j]=0
        
        add r9, #1 //j++
        b for1
    end_for1:
    
    /*push {r0-r8} //debuging
    
    add r0, #4
    bl afis_vector
    
    mov r0, r7
    add r0, #4
    bl afis_vector
    
    mov r0, r5
    add r0, #4
    bl afis_vector
    
    pop {r0-r8}*/ //pana aici e ok
    
    push {r0-r8}
    mov r9, r8 // j=nused
    
    for2: 
        cmp r9, #1
        blt end_for2
        
        mov r0, r5
        mov r1, r7
        mov r2, r8
        mov r3, r9
        bl hufapp
        
        sub r9, #1
        b for2
	
	end_for2:
	pop {r0-r8}
	
	//k = nchin == hcode->nch
    mov r9, r1
    
    push {r0-r8}
    
    //r0-r3 liber de folosit - parametrii la functie
    //r4-r9 ocupati
    //r10-r12 liberi de folosit
    
    //r10 - node in while
    
    //while nused > 1
    while:
        cmp r8, #1
        ble end_while
        
        //node = index[1]
        ldr r10, [r5, #4]
        
        //index[1] = index[nused--]
        ldr r0, [r5, r8, lsl #2]
        str r0, [r5, #4]
        sub r8, #1
        
        //hufapp(index, nprob, nused, 1)
        mov r0, r5
        mov r1, r7
        mov r2, r8
        mov r3, #1
        bl hufapp
        
        //nprob[++k] = nprob[index[1]] + nprob[node]
        add r9, #1 //++k
        ldr r0, [r5, #4] //index[1]
        ldr r1, [r7, r0, lsl #2]
        ldr r2, [r7, r10, lsl #2]
        add r1, r2
        str r1, [r7, r9, lsl #2]
        
        //hcode->left[k] = node
        ldr r1, [r4, #8]
        str r10, [r1, r9, lsl #2]
        
        //hcode->right[k] = index[1]
        ldr r1, [r4, #12]
        str r0, [r1, r9, lsl #2]
        
        // up[index[1]]] = -k
        // up[node] = index[1] = k
        mov r1, #0
        sub r1, r9
        str r1, [r6, r0, lsl #2]
        str r9, [r6, r10, lsl #2]
        str r9, [r5, #4]
        
        //hufapp(index, nprob, nused, 1)
        mov r0, r5
        mov r1, r7
        mov r2, r8
        mov r3, #1
        bl hufapp
        
        b while
    end_while:
    
    pop {r0-r8}
    
    //up[ hcode->nodemax = k] = 0
    str r9, [r4, #20]
    mov r11, #0
    str r11, [r6, r9, lsl #2] //up[k]=0
    
    //r4-r8 ocupati
    //r0-r3, r9-r12 liberi
    push {r0-r8}
    //j=1
    mov r9, #1 // j-> r9
    
    for3://for j=1 to j<=hcode->nch = nchin = r1
        cmp r9, r1
        bgt end_for3
        
        //if nprob[j]
        ldr r0, [r7, r9, lsl #2]
        cmp r0, #0
        beq else2
            
            //for n=0, ibit=0, node=up[j] to node!=0 do node=up[node], ibit++
            mov r10, #0              //n    -> r10
            mov r11, #0              //ibit -> r11
            ldr r0, [r6, r9, lsl #2] //node -> r0
            
            
            
            for4:
                cmp r0, #0
                beq end_for4
                
                //if node < 0
                cmp r0, #0
                bge else3
                
                    ldr r12, =setbit
                    ldr r12, [r12, r11, lsl #2]
                    orr r10, r10, r12
                    mov r3, #0
                    sub r0, r3, r0
                
                else3:
                ldr r0, [r6, r0, lsl #2]
                add r11, #1 //ibit++
                b for4
            end_for4:
        
            //hcode->icod[j] = n
            //hcode->ncode[j] = ibit
            
            ldr r0, [r4]
            str r10, [r0, r9, lsl #2]
            
            ldr r0, [r4, #4]
            str r11, [r0, r9, lsl #2]
            else2:
        add r9, #1
        b for3
    end_for3:
    
    
    pop {r0-r8}
    
    // *nlong = 0
    mov r9, #0
    str r9, [r3]
    

    
    //for j=1 to j <= hcode->nch == nchin -> r1
    mov r9, #1
    for5:
        cmp r9, r1
        bgt end_for5
        
        //if hcode -> ncode[j] > *nlong
        ldr r10, [r4, #4] //hcode->ncode
        ldr r11, [r10, r9, lsl #2]
        ldr r12, [r3]
        cmp r11, r12
        ble else4
            str r11, [r3]
            sub r11, r9, #1
            str r11, [r2]
        else4:
        
        add r9, #1
        b for5
    end_for5:
    
    
	pop {lr}
	bx lr
	
	
	
	
	
	
	
	
	
	
	
