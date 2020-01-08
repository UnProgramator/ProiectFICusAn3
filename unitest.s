.global afis_vector
.global afis_hcode
.global appcode
.global aloc_test
.global afis_vector_byte

.extern write_word
.extern write_str
.extern hufapp

.data
.balign 4
start_mess: .asciz "Start confirm\n\r"
new_line: .asciz "\n\r"
space: .asciz " "
index_test_app: .word 1,2,3,4,5,6,7,8
nprob_test_app: .word 2, 1, 4, 2, 1, 3, 2, 1

.text
afis_vector:
    push {lr}
    push {r2-r8}
    mov r3, r0
    mov r2, #0
    lop_afis_vector:
        cmp r2, r1
        bge fin_afis_vector
        push {r1-r3}
        ldr r0, [r3, r2, lsl #2]
        bl write_word
        ldr r0, =space
        bl write_str
        pop {r1-r3}
        add r2, #1
        b lop_afis_vector
    fin_afis_vector:
    ldr r0, =new_line
    bl write_str
    
    
    pop {r2-r8}
    pop {lr}
    bx lr
 
afis_vector_byte:
    push {lr}
    push {r2-r8}
    mov r3, r0
    mov r2, #0
    lop_afis_vector_byte:
        cmp r2, r1
        bge fin_afis_vector_byte
        push {r1-r3}
        ldrb r0, [r3, r2]
        bl write_byte
        ldr r0, =space
        bl write_str
        pop {r1-r3}
        add r2, #1
        b lop_afis_vector_byte
    fin_afis_vector_byte:
    ldr r0, =new_line
    bl write_str
    
    
    pop {r2-r8}
    pop {lr}
    bx lr
    
 
afis_hcode:
    push {lr}
    
    mov r12, r0
    mov r1, #40
    
    push {r1,r12}
    ldr r0, [r0]
    bl afis_vector
    pop {r1,r12}
    
    push {r1,r12}
    ldr r0, [r12, #4]
    bl afis_vector
    pop {r1,r12}
    
    push {r1,r12}
    ldr r0, [r12, #8]
    bl afis_vector
    pop {r1,r12}
    
    push {r1,r12}
    ldr r0, [r12, #12]
    bl afis_vector
    pop {r1,r12}
    
    push {r1,r12}
    ldr r0, [r12, #16]
    bl write_word
    ldr r0, =space
    bl write_str
    pop {r1, r12}
    
    ldr r0, [r12, #20]
    bl write_word
    
    ldr r0, =new_line
    bl write_str
    
    pop {lr}
    bx lr
        
        
appcode:
    push {lr}

    
    ldr r0, =index_test_app
    sub r0, #4
    ldr r1, =nprob_test_app
    sub r1, #4
    mov r2, #8
    mov r3, #4
    bl hufapp
    
    ldr r0, =index_test_app
    sub r0, #4
    ldr r1, =nprob_test_app
    sub r1, #4
    mov r2, #8
    mov r3, #3
    bl hufapp
    
    ldr r0, =index_test_app
    mov r1, #8
    bl afis_vector
    pop {lr}
    bx lr

    
aloc_test:
    push {lr}
    
    mov r0, #20
    bl alloc
    bl write_word
    ldr r0, =new_line
    bl write_str
    mov r0, #40
    bl alloc
    bl write_word
    ldr r0, =new_line
    bl write_str
    mov r0, #100
    bl alloc
    bl write_word
    ldr r0, =new_line
    bl write_str
    mov r0, #20
    bl alloc
    bl write_word
    
    pop {lr}
    bx lr
