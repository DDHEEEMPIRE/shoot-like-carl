public reset_time
public peek_time
extrn ptime: byte
extrn ctime: byte
extrn time: byte
.model small

.code
reset_time proc near
  push ax
  push bx
  push cx
  push dx
  mov ah, 2ch
  int 21h
  lea di, ptime
  mov [di], ch
  mov [di+1], cl
  mov [di+2], dh
  pop dx
  pop cx
  pop bx
  pop ax
  ret
reset_time endp

peek_time proc near
  push ax
  push bx
  push cx
  push dx
  mov ah, 2ch
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
  pop dx
  pop cx
  pop bx
  pop ax
  ret
peek_time endp

end
