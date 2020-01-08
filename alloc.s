.global alloc
.type global, %function

.global lvector
.type lvector, %function

.global ralloc
.type global, %function

.extern write_str
.extern write_word

.data 
.balign 4
stackp: .word 0
memspace: .word 65536
merror: .asciz "Memrie insuficienta\r\n"
heapspace: .skip 65536 //;spatiul pentru memoria heap



.text
alloc: //;r0 -nr de biti de alocat si rezultatul returnat
    push {r1-r2}
    ldr r1, =memspace
    ldr r2, [r1]
    cmp r0, r2
    ble if_not
    
    mov r0, #0 //;daca nu mai am memorie suficienta
    b fin
    
    if_not: //am memorie
        add r2, r0
        str r2, [r1]
        ldr r1, =heapspace
        ldr r3, =stackp
        ldr r2, [r3]
        add r1, r1, r2 // &heapspace + stack_top
        add r2, r2, r0 // stack_top += space_needed
        str r2, [r3]
        mov r0, r1
        
    fin:
    pop {r1-r2}
        bx lr
        
//end of alloc

ralloc:
    push {lr}
    //r0 last address
    //r1 last address size
    //r2 new address size
    add r5, r0, r1
    ldr r6, =stackp
    ldr r6, [r6]
    cmp r6, r5 //verifica daca mai e spatiu dupa vectorul deja alocat
    bgt real
        sub r5, r2, r1
        add r6, r6, r5
        ldr r7, =stackp
        str r6, [r7]
        pop {lr}
        bx lr
        
    real:
        mov r3, r0
        mov r0, r2
        push {r1-r3}
        bl alloc
        pop {r1-r3}
        mov r5, #0
        mov r4, r0
        //copiez vechile valori
        lop_ralloc:
        cmp r5, r1
        beq fin_ralloc
            ldr r6, [r3,r5]
            str r6, [r4,r5]
        add r5, #1
        b lop_ralloc
        fin_ralloc:
    
    pop {lr}
    bx lr
//end of ralloc

lvector:// no_start -> r0
        // no_fin   -> r1
    push {lr}    
    push {r0}
    
    sub r0, r1, r0 // r0 = no_fin - no_start
    lsl r0, #2
    
    bl alloc
    
    mov r1, r0
    pop {r0}
    sub r0, r1, r0 // r0 = mem_aloc - no_start
    
    pop {lr}
    bx lr
//end of lvector

make0:
    push {r0-r12,lr}
    
    mov r0, #0
    
    lop_make0:
        cmp r1,r2
        bgt end_make0
        str r0, [r1]
        add r1, #4
        
    end_make0:
    
    pop {r0-r12,lr}
    bx  lr
