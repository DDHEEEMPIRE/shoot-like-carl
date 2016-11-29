.model small
.stack 64
.data






; void delay(mss)
; delay time in ms
; stack structure:
; [bp + 4]: number of ms
; [bp + 2]: caller IP
; [bp + 0]: caller BP
delay proc near
  push bp
  mov bp, sp
  push ax
  mov cx, 66         ; 66 * 15.08 us = 1 ms
  mov ax, [bp+4]
  mul cx
  mov cx, ax
  wait:
    in  al, 61h
    cmp al, ah
    je  wait
    mov ah, al
    loop wait
  pop ax
  pop bp
  ret
delay endp







.code
main proc far
  mov ax, @data
  mov ds, ax












  mov ax, 4c00h
  int 21h
main endp
  end main
