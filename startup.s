.global _start

.extern write_word
.extern write_str
.extern write_byte
.extern lvector
.extern alloc

.extern hufmak
.extern hufend
.extern hufdec

.data
.balign 4
    t_decodat: .asciz "testul ce urmeaza sa fie codificat: "
    t_encodul: .asciz "textul codificat: "
    t_decodul: .asciz "textul decodificat: "
    text_de_codat: .asciz "huffman code is cool"
    tabel: .asciz "acdefhlmnou "
    nfreq: .word 1, 2, 1, 1, 2, 1, 1, 1, 1, 3, 1, 1
    nchin: .word 12
    
    ilong: .word 0
    nlong: .word 0
    
    new_line: .asciz "\r\n"
    MQ: .word 1024
	huffcode: .skip 24
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
    LDR     SP, =stack_top
    
    ldr r0, =t_decodat
    bl write_str
    ldr r0, =text_de_codat
    bl write_str
    ldr r0, =new_line
    bl write_str
    
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
    
    //hufmak(nfreq, nchin, &ilong, &nlong, hufcode)
    ldr r0, =nfreq
    ldr r1, =nchin
    ldr r1, [r1]
    ldr r2, =ilong
    ldr r3, =nlong
    ldr r4, =huffcode
    bl hufmak
    
    ldr r0, =ilong
    ldr r0, [r0]
    bl write_word
    
    ldr r0, =new_line
    bl write_str
    
    ldr r0, =nlong
    ldr r0, [r0]
    bl write_word
    
    b .
