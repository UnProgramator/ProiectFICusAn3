.global _start
.global new_line

.extern write_word
.extern write_str
.extern write_byte
.extern lvector
.extern alloc
.extern appcode
.extern afis_hcode
.extern afis_vector
.extern afis_vector_byte
.extern aloc_test

.extern hufmak
.extern hufenc
.extern hufdec


.data
.balign 4
    t_decodat: .asciz "testul ce urmeaza sa fie codificat: "
    t_encodul: .asciz "textul codificat: "
    t_decodul: .asciz "textul decodificat: "
    pard: .asciz "( "
    pari: .asciz " biti )"
    text_de_codat: .asciz "huffman code cool"
    tabel: .asciz "acdefhlmnou "
                // 01234567890
    nfreq: .word 0, 1, 2, 1, 1, 2, 1, 1, 1, 1, 3, 1, 1
    nchin: .word 12
    
    ilong: .word 0
    nlong: .word 0
    
    codep: .word 0
    lcode: .word 256
    nb: .word 0
    ich: .word 0
    
    text_decodat: .skip 100
    
    new_line: .asciz "\r\n"
    MQ: .word 1024
	huffcode: .skip 24
	
	space: .asciz " "
	
	/*struct{
    *icod - 0
    *ncod -4
    *left -8
    *right-12
    nch-16
    nodemax-20
    }huffcode*/
    
.text
_start:
    ldr SP, =stack_top
    
    ldr r5, =MQ
    ldr r6, =huffcode
    
    //huffcode.icod = (long*)lvector(1, MQ)
    mov r0, #1
    ldr r1, [r5]
    bl lvector
    str r0, [r6]
    
    
     //huffcode.ncod = (long*)lvector(1, MQ)
    mov r0, #1
    ldr r1, [r5]
    bl lvector
    str r0, [r6, #4]
    
    //huffcode.left = (long*)lvector(1, MQ)
    mov r0, #1
    ldr r1, [r5]
    bl lvector
    str r0, [r6, #8]
    
    //huffcode.right = (long*)lvector(1, MQ)
    mov r0, #1
    ldr r1, [r5]
    bl lvector
    str r0, [r6, #12]
    
    ldr r0, =t_decodat
    bl write_str
    
    ldr r0, =space
    bl write_str
    
    ldr r0, =text_de_codat
    bl write_str
    
    ldr r0, =new_line
    bl write_str
    
    ldr r0, =nfreq
    ldr r1, =nchin
    ldr r1, [r1]
    ldr r2, =ilong
    ldr r3, =nlong
    ldr r4, =huffcode
    bl hufmak
    
    //encode
    ldr r0, =lcode
    ldr r0, [r0]
    add r0, #1
    bl alloc
    ldr r1, =codep
    str r0, [r1]
    
    mov r10, #0
    ldr r11, =text_de_codat
    for_char:
        cmp r10, #17
        beq exit_char
        
        ldrb r9, [r11, r10]
        mov r0, #0
        ldr r2, =tabel
        for_ich:
            ldrb r1, [r2, r0]
            cmp r1, r9
            beq gasit
            add r0, #1
            b for_ich
        gasit:
        ldr r1, =codep
        ldr r2, =lcode
        ldr r3, =nb
        ldr r4, =huffcode
        bl hufenc
        
        add r10, #1
        b for_char
    exit_char:
    
    ldr r0, =t_encodul
    bl write_str
    
    ldr r0, =space
    bl write_str
    
    ldr r0, =codep
    ldr r1, =nb
    ldr r1, [r1]
    lsr r1, #3
    bl afis_vector_byte
    
    ldr r0, =pard
    bl write_str
    
    ldr r0, =nb
    ldr r0, [r0]
    bl write_word
    
    ldr r0, =pari
    bl write_str
    
    ldr r0, =new_line
    bl write_str
    
    //decodul
    
    
    mov r0, #0
    ldr r1, =nb
    str r0, [r1] // nb=0
    
    mov r11, #0
    ldr r10, =text_decodat
    
    for_dec1:
        ldr r0, =ich
        ldr r1, =codep
        ldr r1, [r1]
        ldr r2, =lcode
        ldr r2, [r2]
        ldr r3, =nb
        ldr r4, =huffcode
        bl hufdec
        
        ldr r0, =ich 
        ldr r0, [r0]
        ldr r12, =huffcode
        ldr r12, [r12, #16]
        
        cmp r0, r12
        beq finish
        
        ldr r1, =tabel
        ldrb r2, [r1, r0]
        strb r2, [r10, r11]
        add r11, #1
        
        b for_dec1
    finish:
    mov r0, #0
    strb r0, [r10, r11]
    ldr r0, =t_decodul
    bl write_str
    ldr r0, =text_decodat
    bl write_str
    
    /*ldr r0, =new_line //debuging
    bl write_str
    
    ldr r0, =huffcode 
    bl afis_hcode*/
    
    /*ldr r0, =nlong
    ldr r0, [r0]
    bl write_word
    ldr r0, =space
    bl write_str
    ldr r0, =ilong
    ldr r0, [r0]
    bl write_word
    ldr r0, =new_line
    bl write_str
    
    ldr r0, =lcode
    ldr r0, [r0]
    bl alloc
    ldr r1, =codep
    str r0, [r1]
    
    ldr r0, =huffcode
    ldr r0, [r0, #16]
    bl write_word
    
    
    mov r0, #9
    ldr r1, =codep
    ldr r2, =lcode
    ldr r3, =nb
    ldr r4, =huffcode
    bl hufenc
    
    ldr r0, =codep
    mov r1, #10
    bl afis_vector
    
    mov r0, #-1
    bl write_word
    
    ldr r0, =new_line
    bl write_str*/
    
    b .
