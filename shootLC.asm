;-----enabling you to shoot like Carl, in your dreams--------------------------

.model small
  include allmacro.inc
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


