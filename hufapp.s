.global hufapp

.extern write_str

.data
.balign 4

.text 
hufapp:
    // in ordine *index -> r0
    //           *nprob -> r1
    //            n     -> r2
    //            i     -> r3
    //            k     -> r4
    //            j     -> r5
    
    push {lr}
    ldr r4, [r3, r0] //;k = index[i]
    
    mov r8, r2 // r8 <- copy of n
    rsh r8, #1
    
    //;while i <= (n >> 1)
    while: 
        cmp r3, r8 // i <= (n >> 1) 
        bgt end
        
        //if (j = i<<1) < n && (nprob[index[j]] > nrpob[index[j+1]])
        //(j = i<<1) < n
        mov r5, r3 // j = i
        lsh r5, #1 // j = i << 1
        cmp r5, r2 // j < n
        bge fi1
        //(nprob[index[j]] > nrpob[index[j+1]])
        ldr r6, [r0,r5] //index[j]
        ldr r6, [r1,r6] //nprob[index[j]]
        add r5, #1 //j++
        ldr r7, [r0,r5] //index[j+1]
        ldr r7, [r1,r7] //nprob[index[j+1]]
        cmp r6, r7
        bgt fi1 //if both condition are true, then j is already j++
        
        //if first statement true and second false => (j++)--
        // stiu ca e putin ciudat, da mi s-a parut mai interesant sa optimizez codul
        sub r5, #1
        fi1: //end of first if
        
        // if nprob[k] <= nprob[index[j]]
        ldr r6, [r1,r4] //r6 <- nprob[k]
        ldr r7, [r0,r5] //r7 <- index[j]
        ldr r7, [r1,r7] //r7 <- nprob[index[j]]
        cmp r6, r7
        ble end // if statement true then break
        ldr r7, [r0,r5] //r7 <- index[j]
        str r7, [r0,r3] //r7 -> index[i]
        mov r3, r5      //i = j
        
    end:
    
    str r4, [r0,r3] // index[i] = k
    
    pop {lr}
    bx lr
//end of hufapp
