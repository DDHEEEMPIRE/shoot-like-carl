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
bugs  db 5  dup(60 dup(?))
grnds db 17 dup(58 dup(?))
bugs_generator_count db ?
bugs_mover_count    db ?

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
  mov [di+2], dh
  mov score, 0
  mov bugs_generator_count, 24
  mov bugs_mover_count, 4
  lea di, bugs
  mov cx, 5        
  ;5 rows of bugs
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
    mov cx, 17       
  ;17 rows of grenades
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
local draw_bugs, draw_grnds, grndgrnds, bugbugs, no_bugs, no_grnds, grnds_over, bugs_over, bug_body
  ;get time
  mov ah, 2ch
  int 21h
  lea di, ctime
  mov [di], ch
  mov [di+1], cl
  mov [di+2], dh
  mov ax, 0
  lea si, ptime
  lea di, ctime
  add ax, [di]
  sub ax, [si]
  mov bl, 60
  mul bl
  add ax, [di+1]
  sub ax, [si+1]
  mov bl, 60
  mul bl
  add ax, [di+2]
  sub ax, [si+2]
  mov time, al
  
  cursor 1, 5
  display prompt_s
  numeral score
  cursor 1, 60
  display prompt_t
  numeral time

;draw grenades
  lea si, grnds
  mov bh, 16
  mov bl, 5
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
  mov bh, 5
  mov bl, 5
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
  cursor 21, 10     ;left edge
  draw ' '
  cursor 22, 10
  draw ' '
  cursor 21, 11 
  draw ' '
  cursor 22, 11
  draw ' '
  cursor 21, 12
  draw ' '
  cursor 22, 12
  draw ' '
  cursor 21, 67     ;right edge
  draw ' '
  cursor 22, 67
  draw ' '
  cursor 21, 68 
  draw ' '
  cursor 22, 68
  draw ' '
  cursor 21, 69
  draw ' '
  cursor 22, 69
  draw ' '
  cursor 21, rpg    ;center
  draw '-'
  cursor 22, rpg
  draw ' '
  mov bl, rpg
  dec bl
  cursor 21, bl     ;center-1
  draw '.'
  cursor 22, bl
  draw '|'
  dec bl
  cursor 21, bl     ;center-2
  draw ' '
  cursor 22, bl
  draw ' '
  mov bl, rpg
  inc bl
  cursor 21, bl     ;center+1
  draw '.'
  cursor 22, bl
  draw '|'
  inc bl
  cursor 21, bl     ;center+2
  draw ' '
  cursor 22, bl
  draw ' '

;  ret
;refresh endp
endm




;-------every loop-------------------------------
;forward bugs
fwd_bugs macro
local forward_bug_lines, forward_bugs, bugs_mover_test, bugs_generator, bugs_mover, bugs_over
  push cx
  push ax
  push dx
  push di
  push si
    cursor 0, 0
    numeral cl
  dec bugs_generator_count
  dec bugs_mover_count
  cmp bugs_generator_count, 0
  jz  bugs_generator
  bugs_mover_test:
  cmp bugs_mover_count, 0
  jz  bugs_mover
  jmp bugs_over
  ;when bugs_generator_count equals 0, generate a random bug
  bugs_generator:
    ;get random line
    mov ah, 2ch
    int 21h
    mov ax, dx
    mov bl, 5
    div bl
    mov cl, ah
    ;generate a new bug
    mov ax, 60
    inc cl
    mul cl
    dec ax
    lea di, bugs
    add di, ax
    mov al, 1
    mov [di], al
    dec di
    mov [di], al
    dec di
    mov al, 2
    mov [di], al
    mov bugs_generator_count, 24
    jmp bugs_mover_test
  ;when bugs_mover_count equals 0, move all bugs forward
  bugs_mover:
    lea di, bugs
    mov cx, 5
    forward_bug_lines:
      push cx
      mov cx, 59
      forward_bugs:
        mov ax, [di+1]
        mov [di], ax
        inc di
        loop forward_bugs
      mov ax, 0
      mov [di], ax
      inc di
      pop cx
      loop forward_bug_lines
      mov bugs_mover_count, 4
  bugs_over:
  pop si
  pop di
  pop dx
  pop ax
  pop cx
endm

;forward grenades
fwd_grnds macro
local forward_grnds, lastrowofgrnds
  push di
  push si
  push cx
  push ax
  lea di, grnds
  lea si, grnds
  add si, 58
  mov cx, 928
  forward_grnds:
    mov ax, [si]
    mov [di], ax
    inc si
    inc di
    loop forward_grnds
  mov cx, 58
  lastrowofgrnds:
    mov ax, 0
    mov [di], ax
    inc di
    loop lastrowofgrnds
  pop ax
  pop cx
  pop si
  pop di
endm

;judge and count if present grenades hit
judge macro

endm

;10-68
;move rpg to the left
left_rpg macro
local outofleftedge, out1
  push ax
  mov al, rpg
  cmp al, 11
  jz  outofleftedge
  dec al
  jmp out1
  outofleftedge:
  mov al, 68
  out1:
  mov rpg, al
  pop ax
endm

;move rpg to the right
right_rpg macro
local outofrightedge, out2
  push ax
  mov al, rpg
  cmp al, 68
  jz  outofrightedge
  inc al
  jmp out2
  outofrightedge:
  mov al, 11
  out2:
  mov rpg, al
  pop ax
endm

;fire one grenade
fire_rpg macro
  push di
  push bx
  push dx
  mov bh, 0
  mov bl, rpg
  lea di, grnds
  add di, 917
  mov dl, 1
  mov [di+bx], dl
  pop dx
  pop bx
  pop di
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
  
  mov cx, 3000
  running:
    mov ax, 0fffh  ;speed
    mov cx, 66 
    mul cx
    mov cx, ax
    L1:           
      in al, 61h
      and al, 10h
      push ax
      mov ah, 01
      int 16h
      jnz operated 
      continue_delay:
      pop ax        
      cmp al, ah
      je L1
      mov ah, al
      loop L1
    fwd_bugs
    fwd_grnds
    judge
    refresh
    jmp running
          operated:
                          fwd_bugs
                          fwd_grnds
                          judge
                          refresh
          push ax
          mov ah, 0
          int 16h
          cmp ah, 4bh
          jz  rpg_left
          cmp ah, 4dh
          jz  rpg_right
          cmp al, ' '
          jz  rpg_fire
          cmp al, 'q'
          jz  exit
          cmp al, 'Q'
          jz  exit
          mov cx, 0
          jmp continue_delay
          rpg_left:
          left_rpg
          refresh
          pop ax
          mov cx, 0
          jmp continue_delay
          rpg_right:
          right_rpg
          refresh
          pop ax
          mov cx, 0
          jmp continue_delay
          rpg_fire:
          fire_rpg
          refresh
          pop ax
          mov cx, 0
          jmp continue_delay






  exit:
  mov ax, 4c00h
  int 21h
main endp
  end main


