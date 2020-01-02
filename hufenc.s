.global hufenc

.extern write_str
.extern setbit [data]
.extern ralloc

.balign 4
wordmessage1: .asciz "ich out of range in hufenc.\r\n"
wordmessage2: .asciz "Reached the esnd of the code array.\r\n"
wordmessage3: .asciz "Attempting to expand it's size.\r\n"
wordmessage4: .asciz "Size expansion failed.\r\n"

/*struct{
*icod - 0
*ncod -4
*left -8
*right-12
nch-16
nodemax-20
}huffcode*/

.text
hufenc:
/*    ich   -> r0
    **codep -> r1
    *lcode  -> r2
    *nb     -> r3
    *hcode  -> r4 //pop de pe stiva
    
    k       -> r5
    n       -> r6 in for
    nc      -> r7 in for
    l       -> r8 in the last 2 statements of for*/
    pop {r4}
    push {lr}
    //k=ich+1
    mov r5, r0
    add r5, #1 
    
    //if (k>hcode->nch || k<1) nerror("ich out of range in hufenc.");
    ldr r6, [r4, 16]
    cmp r5, r6
    bgt true1
    cmp k, #1
    bge not1
    true1: //if true
        push {r0-r4}
        ldr r0, =wordmessage1
        bl write_str
        pop {r0-r4}
    not1:
    
    //for n=hcode->ncode[k]-1
    ldr r6, [r4, 4]
    ldr r6, [r6, r5]
    sub r6, #1
    
    test_for: // n>=0 => if n<0 then break
        cmp r6, #0
        blt end_for
    
    //if (++nc >= *lcode)
    add r7, #1
    ldr r8, [r2] //aici incar val lui lcode
    cmp r7, r8
    blt not4
        push {r0-r8}
        ldr r0, =wordmessage2
        bl write_str
        ldr r0, =wordmessage3
        bl write_str
        pop {r0-r8}
        
        // *lcode *=1.5 => *lcode = *lcode + *lcode>>1
        mov r9, r8
        lsr r9, #1
        add r9, r8, r9
        str r9, [r2]
        push {r0-r8}
        mov r0, r1
        mov r1, r8
        mov r2, r9
        bl ralloc
        mov r9, r0
        
        cmp r0, #0
        bne realloc_succes
            ldr r0, =wordmessage4
            bl write_str
            pop{r0-r8}
            pop{lr} //un fel de break la functie
            bx lr
        realloc_succes:
        pop{r0-r8}
        str r9, [r1]
    
    not4:
    
    //l = *nb & 7
    ldr r8, [r3]
    adn r8, #7
    //if (!l) then *(codep)[nc]=0;
    cmp l, #0
    bne not2
        ldr r10, [r1]
        xor r9, r9, r9
        str r9, [r10, r7]
    not2:
    
    // if hcode->icode[k] & setbit[n] then (*codep)[n] |= setbit[l]
    ldr r9, [r4]
    ldr r9, [r9, r5]
    ldr r10, =setbit
    ldr r10, [r10, r6]
    and r9, r9, r10
    cmp r9, 0
    beq not3
        ldr r9, [r1]
        ldr r9, [r9, r7]
        ldr r10, =setbit
        ldr r10, [r0, r8]
        or r9, r9, r10
        ldr r10, [r1]
        str r9, [r10, r7]
    not3:
    
    increment:
         // n--, ++(*nb)
         sub r6, #1 //n--
         ldr r8, [r3]
         add r8, #1
         str r8, [r3]
         b test_for
    
    end_for:
    
    pop {lr}
    bx lr
    
    
    
    
    
    
