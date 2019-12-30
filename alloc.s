.extern heapspace [data]
.extern write_str

.global alloc
.type global, %function

.global lvector
.type lvector, %function

.data 
.balign 4
stackp: .word 0
memspace: .word 65536
merror: .asciz "Memrie insuficienta\r\n"


.text
alloc: //;r0 -nr de biti de alocat si rezultatul returnat
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
        bx lr
//end of alloc
    
lvector:
    push {lr}
    // no_start -> r0
    // no_fin   -> r1
    
    push {r0}
    
    sub r0, r1, r0 // r0 = no_fin - no_start
    bl alloc
    
    mov r1, r0
    pop {r0}
    sub r0, r0, r1 // r0 = r0 - no_start
    
    pop {lr}
    bx lr
//end of lvector
