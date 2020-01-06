.global _start

.extern write_str
.extern write_byte
.extern lvector

.extern hufmak
.extern hufend
.extern hufdec

.data
.balign 4
    text_de_codat: .asciz "huffman code is cool"
    tabel: .asciz "acdefhlmnou "
    nfreq: .word 1, 2, 1, 1, 2, 1, 1, 1, 1, 3, 1, 1
    nchin: .word 12
    
    ilong: .word
    nlong: .word
    
    text_decodat: .skip 100
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
    ldr r5, =MQ
    ldr r6, =huffcode
    
    ldr r0, =text_de_codat
    bl write_str
    ldr r0, =new_line
    bl write_str
    
    //huffcode.icod = (long*)lvector(1, MQ)
    mov r0, #1
    ldr r1, [r5]
    bl lvector
    str r0, [r6]
    
    ldr r0, =tabel
    bl write_str
    ldr r0, =new_line
    bl write_str
    
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
    bl write_byte
    
    ldr r0, =nlong
    ldr r0, [r0]
    bl write_byte
    
    b .
