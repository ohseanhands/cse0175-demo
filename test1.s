	org 32768

; define constants
map_width: defb 15
map_height: defb 11


start:
	; call setupInterrupt
  xor a         ; Set a to 0
  ld a, 2
  out ($fe), a  ; set border color
  call 3503     ; Clear screen routine in ROM
  call callback ; Start loop

callback:
  ;ld b, 0
  ;ld c, 0
  ;ld de, wall
  ;call drawSprite
  ;ld b, 2
  ;ld c, 2
  ;call drawSprite
  call drawMap
  jp callback


drawMap:
  ld de, map
  ld b, 0
  ld c, 0
drawMap_row:
  nop
drawMap_col:
  push bc
  ld hl, spriteList
  ld a, (de)
  push de
  add a, 1
  sub a, 1
  jp z, drawMap_spriteListCounterLoop_end
drawMap_spriteListCounterLoop:
  inc hl
  inc hl
  sub a, 1
  jp nz, drawMap_spriteListCounterLoop
drawMap_spriteListCounterLoop_end:
; Note, addresses of sprites are opposite endian
  ld e, (hl)
  inc hl
  ld d, (hl)
  rl b
  rl c
; Just for testing...
  call drawSprite
  pop de
  inc de
  pop bc
  inc b
  ld a, (map_width) ; map width
  cp b
  jp nz, drawMap_col
  ld b, 0
  inc c
  ld a, (map_height) ; map height
  cp c
  jp nz, drawMap_row
  ret

; On Entry: B reg = X coord, C reg = Y coord, DE reg = sprite address
drawSprite:
  ; multiply coords by 8 to get pixel locations
  inc b
  inc c
  push BC
  push DE
  ld ixh, d
  ld ixl, e
  ld a, b
  rla
  rla
  rla
  ld b, a
  ld a, c
  rla
  rla
  rla
  ld c, a
  push bc
  call coordToScrAddr
  call blitChar
  pop bc
  ld a, b
  add a, 8
  ld b, a
  push bc
  call coordToScrAddr
  call blitChar
  pop bc
  ld a, b
  sub a, 8
  ld b, a
  ld a, c
  add a, 8
  ld c, a
  push bc
  call coordToScrAddr
  call blitChar
  pop bc
  ld a, b
  add a, 8
  ld b, a
  call coordToScrAddr
  call blitChar

  pop DE
  pop BC
  ret

coordToScrAddr:
;On Entry: B reg = X coord,  C reg = Y coord
;On Exit: HL = screen address, A = pixel position
; Calculate the high byte of the screen addressand store in H reg.
	ld a,c
	and $7
	ld h,a
	ld a,c
	rra
	rra
	rra
	and $18
	or h
	or $40
	ld h,a
; Calculate the low byte of the screen address and store in L reg.
	ld a,b
	rra
	rra
	rra
	and $1f
	ld l,a
	ld a,c
	rla
	rla
	and $e0
	or l
	ld l,a
; Calculate pixel postion and store in A reg.
	ld a,b
	and $7
	ret

;; DE is src
;; HL is dest
blitChar:
  ld b, $8 ; loop counter
blitChar_nxtr:
  ld a, (de)
  ld (hl), a
  inc de
  inc h
  djnz blitChar_nxtr
  ret

;; Define sprites (SID = Sprite ID)
;; If a sprite has ID of 0, it should be background/empty
spriteList:
  defw empty, wall, checker, brick
  
; SID 0 - empty
empty:
  defb 0, 0, 0, 0, 0, 0, 0, 0
  defb 0, 0, 0, 0, 0, 0, 0, 0
  defb 0, 0, 0, 0, 0, 0, 0, 0
  defb 0, 0, 0, 0, 0, 0, 0, 0

; SID 1 - wall
wall:
  defb $7F, $FF, $C0, $C0, $C0, $C0, $C0, $C0
  defb $FE, $FF, $03, $03, $03, $03, $03, $03
  defb $C0, $C0, $C0, $C0, $C0, $C0, $FF, $7F
  defb $03, $03, $03, $03, $03, $03, $FF, $FE

; SID 2 - checker
checker:
  defb $55, $AA, $55, $AA, $55, $AA, $55, $AA
  defb $55, $AA, $55, $AA, $55, $AA, $55, $AA
  defb $55, $AA, $55, $AA, $55, $AA, $55, $AA
  defb $55, $AA, $55, $AA, $55, $AA, $55, $AA

brick:
  defb $00, $67, $67, $67, $67, $67, $67, $00
  defb $00, $FE, $FE, $FE, $FE, $FE, $FE, $00
  defb $00, $7F, $7F, $7F, $7F, $7F, $7F, $00
  defb $00, $E6, $E6, $E6, $E6, $E6, $E6, $00

  defb $00, $4F, $4F, $4F, $00, $7C, $7C, $7F
  defb $00, $FE, $FE, $FE, $00, $FE, $FE, $FE
  defb $7F, $7F, $7F, $7F, $00, $7F, $7F, $00
  defb $FE, $CE, $CE, $CE, $00, $FC, $FC, $00

map:
  defb 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  defb 1, 0, 0, 3, 3, 3, 0, 3, 3, 3, 3, 3, 0, 0, 1
  defb 1, 0, 1, 3, 1, 3, 1, 3, 1, 0, 1, 3, 1, 0, 1
  defb 1, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 3, 3, 0, 1
  defb 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1
  defb 1, 3, 3, 3, 3, 3, 0, 0, 3, 3, 0, 3, 3, 3, 1
  defb 1, 0, 1, 3, 1, 3, 1, 0, 1, 3, 1, 3, 1, 3, 1
  defb 1, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 1
  defb 1, 3, 1, 3, 1, 0, 1, 0, 1, 3, 1, 3, 1, 0, 1
  defb 1, 3, 3, 3, 0, 0, 3, 3, 3, 3, 3, 3, 0, 0, 1
  defb 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1

