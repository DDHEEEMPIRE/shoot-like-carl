.model small
.stack 64
.data
string_hints db "                     Press numeral keys to sound", 13, 10
             db "                     Press q to quit", 13, 10, '$'
string_keys  db "1  2  3  4  5  6  7  8", '$'
string_tunes db "C4 D4 E4 F4 G4 A4 B4 C5", '$'
pitch_table  dw 4560, 4063, 3620, 3416, 3044, 2712, 2415, 2280
speed        db 2       ; (speed * 0.5)s per pitch

;clear screen
clr_scr macro
  push ax
  push bx
  push cx
  push dx
  mov ax, 0600h
  mov bh, 07
  mov cx, 0
  mov dx, 184fh
  int 10h
  pop dx
  pop cx
  pop bx
  pop ax
endm

;display string
display macro string
  push ax
  push dx
  mov ah, 09
  lea dx, string
  int 21h
  pop dx
  pop ax
endm

;set_cursor
cursor macro row, column
  push ax
  push bx
  push dx
  mov ah, 02
  mov bh, 0
  mov dh, row
  mov dl, column
  int 10h
  pop dx
  pop bx
  pop ax
endm



;---------------------------------------------
.code

; void delay(mss)
; delay time for mss * 1ms
; mss has to be less than 992
; stack structure:
; [bp + 4]: number of ms
; [bp + 2]: caller IP
; [bp + 0]: caller BP
delay proc near
  push bp
  mov bp, sp
  push ax
  push cx
  mov cx, 66        ; 66 * 15.08 us = 1 ms
  mov ax, [bp+4]
  mul cx
  mov cx, ax
  wait0:
    in  al, 61h
    and al, 10h
    cmp al, ah
    je  wait0
    mov ah, al
    loop wait0
  pop cx
  pop ax
  pop bp
  ret
delay endp

; void sound(pitch)
; sound at a certain pitch
; stack structure:
; [bp + 4]: pitch
; [bp + 2]: caller IP
; [bp + 0]: caller BP
sound proc near
  push bp
  mov bp, sp
  push ax
  push cx
  push bx

  ;get the corresponding frequency for the pitch
  mov [bp+4], ax
  mov ah, 0
  lea si, pitch_table
  add si, ax
  add si, ax

  mov al, 0b6h
  out 43h, al
  mov ax, [si]
  out 42h, al
  mov al, ah
  out 42h, al
  ;turn on speaker
  in  al, 61h
  mov ah, al
  or  al, 03h
  out 61h, al
  push ax
  mov ch, 0
  mov cl, speed
  ;after a while
  delay1:
    mov ax, 500
    push ax
    call delay
    pop  ax
    loop delay1
  pop ax
  ;turn off speaker
  mov al, ah
  out 61h, al

  pop bx
  pop cx
  pop ax
  pop bp
  ret
sound endp

main proc far
  mov ax, @data
  mov ds, ax

  clr_scr
  cursor 15, 0
  display string_hints
  cursor 9, 23
  display string_tunes
  cursor 10, 23
  display string_keys

  wait_for_musician:  ; wait for player to press a key
  mov ah, 01
  int 16h
  jz wait_for_musician
  mov ah, 0
  int 16h
  ; if 1~8 is pressed, set the corresponding variable to notify sound
  cmp al, '1'
  jb  next
  cmp al, '8'
  ja  next
  sub al, '1'
  push ax
  call sound
  jmp wait_for_musician
  next:
  cmp al, 'q'
  jz  exit
  cmp al, 'Q'
  jz  exit
  jmp wait_for_musician
  
  exit:
  mov ax, 4c00h
  int 21h
main endp
  end main
  