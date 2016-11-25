;-----enabling you to shoot like Carl, in your dreams--------------------------

.model small
;-----------------------------------------------
.data
;welcome
string_hints db "              Press direction keys to move your RPG", 13, 10
             db "              Press blank space to shoot", 13, 10
             db "              Press s to start", 13, 10
             db "              Press q to quit", 13, 10
             db '$'
prompt_s     db "SCORE: ",'$'
prompt_t     db "TIME: ",'$'

;current game
ptime db ?, ?, ?  ;hours, minutes, seconds
ctime db ?, ?, ?  ;hours, minutes, seconds
time  db ?        ;in minutes
rpg   db ?        ;position of RPG (10-68, taking up 3 pixels)
score db ?
bugs  db 60 dup(?)
      db 60 dup(?)
      db 60 dup(?)
      db 60 dup(?)
grnds db 58 dup(?)
      db 58 dup(?)
      db 58 dup(?)
      db 58 dup(?)
      db 58 dup(?)
      db 58 dup(?)
      db 58 dup(?)
      db 58 dup(?)
      db 58 dup(?)
      db 58 dup(?)


;-----------------------------------------------
;initialize game
init macro
local reset_bugs, reset_grnds, again1, again2
  clr_scr
  mov ah, 2ch
  int 21h
  lea di, ptime
  mov [di], ch
  mov [di+1], cl
  mov [di+2], dl
  mov score, 0
  lea di, bugs
  mov cx, 4        ;4 rows of bugs
reset_bugs:
  mov ax, 60       ;60 bugs for each row
  again1:
    mov dl, 0
    mov [di], dl
    inc di
    dec ax
    jnz again1
  loop reset_bugs
  lea di, grnds
  mov cx, 10       ;10 rows of grenades
reset_grnds:
  mov ax, 58       ;58 grenades for each row
  again2:
    mov dl, 0
    mov [di], dl
    inc di
    dec ax
    jnz again2
  loop reset_grnds
  set_rpg 39       ;set rpg at the center of the track
  refresh
endm

;set the position of the RPG
set_rpg macro position
  mov dl, position
  mov rpg, dl
endm

;-------view-------------------------------------
;clear screen
clr_scr macro
  mov ax, 0600h
  mov bh, 07
  mov cx, 0
  mov dx, 184fh
  int 10h
endm

;display string
display macro string
  mov ah, 09
  lea dx, string
  int 21h
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

;display char
draw macro char
  push ax
  push dx
  mov ah, 02
  mov dl, char
  int 21h
  pop dx
  pop ax
endm 

;display numeral
numeral macro nume
local push_htol, pop_ltoh
  mov ah, 0
  mov al, nume
  mov bx, 10
  mov cx, 0
push_htol:
  mov dx, 0
  div bx
  push dx
  inc cx
  cmp ax, 0
  jnz push_htol
pop_ltoh:
  pop dx
  add dx, '0'
  mov ah, 02
  int 21h
  dec cx
  jnz pop_ltoh
endm

;refresh view
refresh macro
local draw_bugs, draw_grnds
  ;get time
  mov ah, 2ch
  int 21h
  lea di, ctime
  mov [di], ch
  mov [di+1], cl
  mov [di+2], dl
  mov ax, 0
  lea si, ptime
  lea di, ctime
  add ax, [si]
  sub ax, [di]
  mov bl, 60
  mul bl
  add ax, [si+1]
  sub ax, [di+1]
  mov bl, 60
  mul bl
  add ax, [si+2]
  sub ax, [di+2]
  mov time, al
  
  cursor 1, 1
  display prompt_s
  numeral score
  cursor 1, 60
  display prompt_t
  numeral time

  lea si, bugs
  mov cx, 60
  cursor 3, 10
draw_bugs:
  cmp [si], 0
  jnz  no_bugs
  draw 2
  no_bugs:
  inc si
  loop draw_bugs

endm





;-------every loop-------------------------------
;forward bugs
fwd_bugs macro

endm

;forward grenades
fwd_grnds macro

endm

;judge and count if present grenades hit
judge macro

endm




;-----------------------------------------------
.code
main proc far
  mov ax, @data
  mov ds, ax

  clr_scr
  cursor 15, 0
  display string_hints

  ;wait for operation
waittostart:
  mov ah, 01
  int 16h
  jz  waittostart
  mov ah, 0
  int 16h
  cmp al, 'Q'
  je  exit
  cmp al, 'q'
  je  exit
  cmp al, 'S'
  je  starto
  cmp al, 's'
  je  starto
  jmp waittostart

starto:
    clr_scr
  mov ah, 2ch
  int 21h
  lea di, ptime
  mov [di], ch
  mov [di+1], cl
  mov [di+2], dl
  mov score, 0
  lea di, bugs
  mov cx, 4        ;4 rows of bugs
reset_bugs:
  mov ax, 60       ;60 bugs for each row
  again1:
    mov dl, 0
    mov [di], dl
    inc di
    dec ax
    jnz again1
  loop reset_bugs
  lea di, grnds
  mov cx, 10       ;10 rows of grenades
reset_grnds:
  mov ax, 58       ;58 grenades for each row
  again2:
    mov dl, 0
    mov [di], dl
    inc di
    dec ax
    jnz again2
  loop reset_grnds
  set_rpg 39  
  mov ah, 2ch
  int 21h
  lea di, ctime
  mov [di], ch
  mov [di+1], cl
  mov [di+2], dl
  mov ax, 0
  lea si, ptime
  lea di, ctime
  add ax, [si]
  sub ax, [di]
  mov bl, 60
  mul bl
  add ax, [si+1]
  sub ax, [di+1]
  mov bl, 60
  mul bl
  add ax, [si+2]
  sub ax, [di+2]
  mov time, al
  
  cursor 1, 1
  display prompt_s
  numeral score
  cursor 1, 60
  display prompt_t
  numeral time

  lea si, bugs
  mov bl, 4
  mov bh, 3
bugbugs:
  mov cx, 60
  cursor bh, 10
  push bh
draw_bugs:
  mov dx, [si]
  cmp dx, 0
  jz  no_bugs
  draw 2
  jmp bugs_over
  no_bugs:
    draw 2
  bugs_over:
  inc si
  loop draw_bugs
  pop 
  inc bh
  dec bl
  jnz bugbugs

exit:
  mov ax, 4c00h
  int 21h
main endp
  end main




