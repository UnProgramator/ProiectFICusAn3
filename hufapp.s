.global hufapp
.global setbit



.extern write_str



.data
.balign 4
setbit: .word   0x1, 0x2, 0x4, 0x8,0x10, 0x20, 0x40, 0x80,0x100, 0x200, 0x400, 0x800, 0x1000, 0x2000, 0x4000, 0x8000, 0x10000, 0x20000, 0x40000, 0x80000, 0x100000, 0x200000, 0x400000, 0x800000, 0x1000000, 0x2000000, 0x4000000, 0x8000000, 0x10000000, 0x20000000, 0x40000000, 0x80000000
 


.text 
hufapp:
    // in ordine *index -> r0
    //           *nprob -> r1
    //            n     -> r2
    //            i     -> r3
    //            k     -> r4
    //            j     -> r5
    
    push {lr}
    push {r4-r12}
    ldr r4, [r0, r3, lsl #2] //;k = index[i]
    
    //;while i <= (n >> 1)
    while: 
        lsr r6, r2, #1
        cmp r3, r6 // i <= (n >> 1) 
        bgt end
        
        //if (j = i<<1) < n && (nprob[index[j]] > nrpob[index[j+1]])
        //(j = i<<1) < n
        lsl r5, r3, #1 // j = i << 1
        cmp r5, r2 // j < n
        bge fi1 
        //if (nprob[index[j]] > nrpob[index[j+1]]) 
        ldr r6, [r0,r5, lsl #2] //index[j]
        ldr r6, [r1,r6, lsl #2] //nprob[index[j]]
        add r5, #1 //j++
        ldr r7, [r0,r5, lsl #2] //index[j+1]
        ldr r7, [r1,r7, lsl #2] //nprob[index[j+1]]
        cmp r6, r7
        bgt fi1 //if both condition are true, then j is already j++
        
        //if first statement true and second false => (j++)--
        // stiu ca e putin ciudat, da mi s-a parut mai interesant sa optimizez codul
        sub r5, #1
        fi1: //end of first if
        
        // if nprob[k] <= nprob[index[j]]
        ldr r6, [r1,r4, lsl #2] //r6 <- nprob[k]
        ldr r7, [r0,r5, lsl #2] //r7 <- index[j]
        ldr r7, [r1,r7, lsl #2] //r7 <- nprob[index[j]]
        cmp r6, r7
        ble end // if statement true then break
        ldr r7, [r0,r5, lsl #2] //r7 <- index[j]
        str r7, [r0,r3, lsl #2] //r7 -> index[i]
        mov r3, r5      //i = j
        b while
    end:
    
    str r4, [r0,r3, lsl #2] // index[i] = k
    
    pop {r4-r12}
    pop {lr}
    bx lr
//end of hufapp
