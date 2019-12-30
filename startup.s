.global _start
.extern write_str
.extern write_byte
.global heapspace

.data
.balign 4
    new_line: .asciz "\r\n"
    heapspace: .skip 65536 //;spatiul pentru memoria heap

.text
_start:
    B .
