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
rpg   db ?        ;position of RPG (10-68, taking up 3 characters)
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
  mov cx, 4        
  ;4 rows of bugs
  reset_bugs:
    mov ax, 60       
    ;60 bugs for each row
    again1:
      mov dl, 0
      mov [di], dl
      inc di
      dec ax
      jnz again1
    loop reset_bugs
    lea di, grnds
    mov cx, 10       
  ;10 rows of grenades
  reset_grnds:
    mov ax, 58       
    ;58 grenades for each row
    again2:
      mov dl, 0
      mov [di], dl
      inc di
      dec ax
      jnz again2
    loop reset_grnds
  ;set rpg at the center of the track
  set_rpg 39
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
  push cx
  push bx
  mov ah, 02h
  mov dl, char
  int 21h
  pop bx
  pop cx
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
local draw_bugs, draw_grnds, grndgrnds, bugbugs, no_bugs, no_grnds, grnds_over, bugs_over, bugs_body
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
  
  cursor 1, 5
  display prompt_s
  numeral score
  cursor 1, 60
  display prompt_t
  numeral time

;draw grenades
  lea si, grnds
  mov bh, 10
  mov bl, 3
  grndgrnds:
    mov cx, 58
    cursor bl, 11
    draw_grnds:
      mov dl, [si]
      cmp dl, 0
      jz  no_grnds
      draw 'o'
      jmp grnds_over
      no_grnds:
        draw ' '
      grnds_over:
      inc si
      loop draw_grnds
    inc bl
    dec bh
    jnz grndgrnds

;draw bugs
  lea si, bugs
  mov bh, 4
  mov bl, 3
  bugbugs:
    mov cx, 60
    cursor bl, 10
    draw_bugs:
      mov dl, [si]
      cmp dl, 0
      jz  no_bugs
      cmp dl, 1
      jz  bug_body
      draw 2
      jmp bugs_over
      bug_body:
        draw 3
        jmp bugs_over
      no_bugs:
        draw ' '
      bugs_over:
        inc si
      loop draw_bugs
    inc bl
    dec bh
    jnz bugbugs

;draw RPG
  cursor 21, rpg
  draw '-'
  mov bl, rpg
  dec bl
  cursor 21, bl
  draw '.'
  cursor 22, bl
  draw '|'
  inc bl
  inc bl
  cursor 21, bl 
  draw '.'
  cursor 22, bl
  draw '|'


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

  mov ah, 0
  mov al, 03h
  int 10h
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
    init
    

  exit:
    mov ax, 4c00h
    int 21h
main endp
  end main


