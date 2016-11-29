;-----enabling you to shoot like Carl, in your dreams--------------------------
public ptime
public ctime
public time
extrn reset_time: near
extrn peek_time: near
.model small
.stack 64
;-----------------------------------------------
.data
;welcome
string_hints db "                     Press direction keys to move your RPG", 13, 10
             db "                     Press blank space to shoot", 13, 10
             db "                     Press s to start", 13, 10
             db "                     Press q to quit", 13, 10
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
hhh   db 10 dup(0)
bugs_generator_count db ?
bugs_mover_count    db ?
grenades_left db ?
prompt_g      db "AMMO: ",'$'
flipflop db 0

;-----------------------------------------------
;initialize game
init macro
local reset_bugs, reset_grnds, again1, again2
  clr_scr
  call reset_time
  mov score, 0
  mov bugs_generator_count, 48
  mov bugs_mover_count, 3
  mov grenades_left, 10
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
  push ax
  push bx
  push cx
  push dx
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
  pop dx
  pop cx
  pop bx
  pop ax
endm

;refresh view
refresh macro
local drawbng, draw_bugs1, bug_body1, no_bugs1, bugs_over1, drawbng0, bug_body, no_bugs, no_grnds, bng_over, draw_bugs2, bug_body2, no_bugs2, bugs_over2, drawrestofgs, draw_restofgs, no_restofgs, restofgs_over 
  call peek_time
  
  cursor 1, 5
  display prompt_s
  numeral score
  cursor 1, 60
  display prompt_t
  numeral time
  cursor 1, 33
  display prompt_g
  numeral grenades_left
  draw ' '

;draw bugs and grenades
  lea di, bugs
  lea si, grnds
  mov bl, 5
  mov cx, 5
  drawbng:
    push cx
    cursor bl, 10
    draw_bugs1:
      mov dl, [di]
      cmp dl, 0
      jz  no_bugs1
      cmp dl, 1
      jz  bug_body1
      draw 2
      jmp bugs_over1
      bug_body1:
        draw 3
        jmp bugs_over1
      no_bugs1:
        draw ' '
      bugs_over1:
      inc di
    mov cx, 58
    drawbng0:
      mov dl, [si]
      mov dh, [di]
      cmp dh, 0
      jz no_bugs
      cmp dh, 1
      jz  bug_body
      draw 2
      jmp bng_over
      bug_body:
      draw 3
      jmp bng_over
      no_bugs:
      cmp dl, 0
      jz  no_grnds
      draw 'o'
      jmp bng_over
      no_grnds:
      draw ' '  
      bng_over:
      inc di
      inc si
      loop drawbng0
    draw_bugs2:
      mov dl, [di]
      cmp dl, 0
      jz  no_bugs2
      cmp dl, 1
      jz  bug_body2
      draw 2
      jmp bugs_over2
      bug_body2:
        draw 3
        jmp bugs_over2
      no_bugs2:
        draw ' '
      bugs_over2:
    inc bl
    inc di
    pop cx
    dec cx
    jnz drawbng
  mov cx, 11
  mov bl, 10
  drawrestofgs:
    push cx
    mov cx, 58
    cursor bl, 11
    draw_restofgs:
      mov dl, [si]
      cmp dl, 0
      jz  no_restofgs
      draw 'o'
      jmp restofgs_over
      no_restofgs:
        draw ' '
      restofgs_over:
      inc si
      loop draw_restofgs
    inc bl
    pop cx
    loop drawrestofgs

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
  dec bugs_generator_count
  jnz bugs_mover_test
  jmp bugs_generator
  bugs_mover_test:
  dec bugs_mover_count
  jnz bugs_over
  jmp bugs_mover
  ;when bugs_generator_count equals 0, generate a random bug
  bugs_generator:
    ;get random line
    mov ah, 2ch
    int 21h
    mov al, dl
    mov ah, 0
    mov bl, 5
    div bl
    ;generate a new bug
    mov cl, ah
    mov ax, 60
    mul cl
    add ax, 57
    lea di, bugs
    add di, ax
    mov dl, 2
    mov [di], dl
    mov dl, 1
    mov [di+1], dl
    mov [di+2], dl
    mov bugs_generator_count, 48
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
      mov bugs_mover_count, 3
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
local clear_row, clear_bugs, nothing_happens_here, clearbng
  push ax
  push bx
  push cx
  push dx
  lea si, grnds
  lea di, bugs
  mov cx, 5
  clear_row:
    push cx
    inc di
    mov cx, 58
    clear_bugs:
      mov ah, [di]
      mov al, [si]
      cmp al, 1
      jnz nothing_happens_here
      cmp ah, 0
      jz nothing_happens_here
      ;hit bug
      mov dl, score
      add dl, 3
      cmp ah, 1
      jz clearbng
      ;hit jackpot
      add dl, 2
      clearbng:
      mov score, dl
      mov dl, 0
      mov [si], dl
      mov [di], dl
      mov [di+1], dl
      mov [di+2], dl
      mov [di-1], dl
      mov [di-2], dl
      nothing_happens_here:
      inc di
      inc si
      loop clear_bugs
    inc di
    pop cx
    loop clear_row
  pop dx
  pop cx
  pop bx
  pop ax
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
  dec grenades_left
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
  
  ;wait for operation
  waittostart:
  clr_scr
  cursor 15, 0
  display string_hints
  mov al, flipflop
  cmp al, 0
  jz  first_time_discount
  cursor 9, 33
  display prompt_s
  numeral score
  first_time_discount:
  mov ah, 01
  int 16h
  jz  first_time_discount
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
  jmp first_time_discount

  starto:
  mov flipflop, 1
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
      mov ah, grenades_left
      cmp ah, 0
      jz  waittostart
      cmp al, ' '
      jz  rpg_fire
      cmp al, 'r'
      jz  reload
      cmp al, 'R'
      jz  reload
      cmp al, 'q'
      jz  waittostart
      cmp al, 'Q'
      jz  waittostart
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
      reload:
      mov grenades_left, 10
      jmp continue_delay
  exit:
  mov ax, 4c00h
  int 21h
main endp
  end main


