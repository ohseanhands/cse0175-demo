	org 32768

init:
	; call setupInterrupt
  di
  ld a, 0
  out ($fe), a  ; set border color
  call 3503     ; Clear screen routine in ROM
  
  ;call drawMap
  call interruptSetup
  ;jp callback ; Start loop
  jp startScreen
  ei
  xor a
  halt


startScreen_hasDrawn: defb 0
startScreen_counter: defb 0
startScreen:
  di
    
  ld de, map2
  ld a, (startScreen_hasDrawn)
  or a
  cp a
  call z, drawMap
  inc a
  ld (startScreen_hasDrawn), a

  ld hl, startScreen_counter
  inc (hl)

  ld a, (hl)
  and $1F
  call z, newBorder

  ; Check if player wants to start game
  call isEnterKeyPressed
  or a
  jp z, startScreen2 ; start game
  ;call newBorder

  ei
  xor a
  halt

  jp startScreen
  ret ; should never actually be taken

startScreen2_hasDrawn: defb 0
startScreen2:
  di
    
  ld de, map3
  ld a, (startScreen2_hasDrawn)
  or a
  cp a
  call z, drawMap
  inc a
  ld (startScreen_hasDrawn), a

  ;call newBorder

  ; BEGIN DRAW START SCREEN

  ;ld de, brick
  ;ld bc, $3030
  ;call coordToScrAddr
  ;call blitChar
  ;ld bc, $3030
  ;call setAttribute


  ;; END DRAW START SCREEN

  ; Check if player wants to start game
  call isEnterKeyPressed
  or a
  jp z, initLevel ; 
  ;call newBorder

  ei
  xor a
  halt

  jp startScreen2
  ret ; should never actually be taken

helloString: defb 'Bomberman'
helloString_end: equ $
pressAnyKeyString: defb 'Press A Key'
pressAnyKeyString_end: equ$

interrupt:
  reti

interruptSetup:
  ld hl, $fdfd
  ld bc, interrupt
  ld (hl), $c3
  inc hl
  ld (hl), c
  inc hl
  ld (hl), b

  ld hl, $FE00
  ld bc, $FD
interruptSetup_lp1:
  ld (hl), c
  inc hl
  djnz interruptSetup_lp1
  ld (hl), c
  ld a, $fe
  ld i, a
  im 2
  ret

; define constants
map_width: defb 15
map_height: defb 11
hasDrawnMap: defb 0

player1Coords: defb 24, 24
player1KeyMap: defb 0
player1KeysReady: defb 0
player1BombSize: defb 1
player1BombsMax: defb 1
player1BombsOut: defb 0

player2Coords: defb 200, 152
player2KeyMap: defb 0
player2KeysReady: defb 0
player2BombSize: defb 1
player2BombsMax: defb 1
player2BombsOut: defb 0

brdrColor: defb 0

frameCounter: defb 0


bombs: ; Each bomb is 5 bytes
;; Define all the bombs
bomb1:
bomb1_pos: defb 0,0   ; pos of 0,0 means no bomb (2 bytes)
bomb1_player: defb 0  ; which player owns the bomb (1 byte)
bomb1_life: defb 0    ; how long the bomb has been on screen (1 byte)
bomb1_size: defb 0    ; how many spaces the bomb extends to (1 byte)
bomb2:
bomb2_pos: defb 0,0   ; pos of 0,0 means no bomb (2 bytes)
bomb2_player: defb 0  ; which player owns the bomb (1 byte)
bomb2_life: defb 0    ; how long the bomb has been on screen (1 byte)
bomb2_size: defb 0    ; how many spaces the bomb extends to (1 byte)
bomb3:
bomb3_pos: defb 0,0   ; pos of 0,0 means no bomb (2 bytes)
bomb3_player: defb 0  ; which player owns the bomb (1 byte)
bomb3_life: defb 0    ; how long the bomb has been on screen (1 byte)
bomb3_size: defb 0    ; how many spaces the bomb extends to (1 byte)

initLevel:
  call 3503     ; Clear screen routine in ROM
  jp callback

callback:
  di
  ;call newBorder
  ld a, (frameCounter)
  sub 50
  call z, resetFrameCounter
  ;call newBorder
  call doFrame
  ;call newBorder

  ei
  xor a
  halt
  jp callback
  ret

doFrame:
  ld a, (hasDrawnMap)
  ld de, map
  or a
  call z, drawMap
  ld a, 1
  ld (hasDrawnMap), a


  ld hl, player1Coords
  ld de, empty
  call drawPlayer

  ld hl, player2Coords
  ld de, empty
  call drawPlayer
  
  call gameLogic

  ld hl, player1Coords
  ld de, bob
  call drawPlayer

  ld hl, player2Coords
  ld de, greg
  call drawPlayer

  ;ld a, (player2Coords)
  ;ld b, (player1Coords)
  ;cp b
  ;jp nz, doFrame_continue
  ;ld a, (player2Coords+1)
  ;ld b, (player1Coords+1)
  ;cp b

doFrame_continue:
  call drawBombs

  ld a, (frameCounter)
  inc a
  ld (frameCounter), a

  ret

resetFrameCounter:
  ld (frameCounter), a
  ret




;bomb1_pos: defb 0,0   ; pos of 0,0 means no bomb (2 bytes)
;bomb1_player: defb 0  ; which player owns the bomb (1 byte)
;bomb1_life: defb 0    ; how long the bomb has been on screen (1 byte)
;bomb1_size: defb 0    ; how many spaces the bomb extends to (1 byte)

drawBombs:
  ;ret ; Not implemented!
drawBombs_1:
  ld hl, bombs
  ld a, (hl)
  or a
  jp z, drawBombs_2 ; no bomb here
  ld b, a
  inc hl
  ld c, (hl)
  inc hl
  inc hl
  ; increase the timer of the bomb
  ld a, $90
  inc (hl)
  cp (hl)
  jp z, bomb1Explode
  bit 4, (hl)
  jp z, drawBombs_1_big
  push hl
drawBombs_1_small:
  ld de, bombSmall
  call drawSprite
  pop hl
  inc hl
  inc hl
  jp drawBombs_2
drawBombs_1_big:
  ld de, bombBig
  call drawSprite
  pop hl
  inc hl
  inc hl
  
drawBombs_2:
  ret
  ld a, (hl)
  or a
  jp z, drawBombs_3 ; no bomb here
  ld b, a
  inc hl
  ld c, (hl)
  inc hl
  inc hl
  ; increase the timer of the bomb
  ld a, $90
  inc (hl)
  cp (hl)
  jp z, bomb2Explode
  bit 4, (hl)
  jp z, drawBombs_2_big
drawBombs_2_small:
  ld de, bombSmall
  call drawSprite
  jp drawBombs_3
drawBombs_2_big:
  ld de, bombBig
  call drawSprite


drawBombs_3:
  ld a, (hl)
  or a
  jp z, drawBombs_end ; no bomb here
  ld b, a
  inc hl
  ld c, (hl)
  inc hl
  inc hl
  ; increase the timer of the bomb
  ld a, $90
  inc (hl)
  cp (hl)
  jp z, bomb3Explode
  bit 4, (hl)
  jp z, drawBombs_3_big
drawBombs_3_small:
  ld de, bombSmall
  call drawSprite
  pop hl
  inc hl
  inc hl
  jp drawBombs_end
drawBombs_3_big:
  ld de, bombBig
  call drawSprite
  pop hl
  inc hl
  inc hl


drawBombs_end:
  ret



bomb1Explode:
  ld hl, bombs
  ld (hl), 0
  ld de, empty
  call drawSprite
  ret ; not implemented

bomb2Explode:
  ld hl, bombs
  inc hl
  inc hl
  inc hl
  inc hl
  inc hl
  ld (hl), 0
  ld de, empty
  call drawSprite
  ret ; not implemented

bomb3Explode:
  ld hl, bombs
  inc hl
  inc hl
  inc hl
  inc hl
  inc hl
  inc hl
  inc hl
  inc hl
  inc hl
  inc hl
  ld (hl), 0
  ld de, empty
  call drawSprite
  ret ; not implemented




pollKeyboard:
  ; Get player 1's keys
  ld a, $FB
  in a, ($fe)
  and $03 ; Get Q and W keys
  rla
  rla
  rla
  ld b, a
  ld a, $FD
  in a, ($fe)
  and $07
  or b
  ld (player1KeyMap), a

  ; Get player 2's keys
  ld a, $DF
  in a, ($fe)
  and $0C
  rla
  ld b, a
  ld a, $BF
  in a, ($fe)
  and $0E
  rra
  or b
  ld (player2KeyMap), a

  ret

isEnterKeyPressed:
  LD BC,$BFFE        ; Load BC with the row port address
  IN A,(C)           ; Read the port into the accumulator
  AND $01            ; Mask out the key we are interested in
  ret

newBorder:
  ld a, (brdrColor)
  out ($fe), a
  inc a
  and $03 ; only affect border color bits
  ld (brdrColor), a
  ret

;; BEGIN GAME LOGIC FUNCTION

gameLogic:
  ;call isEnterKeyPressed
  ;push af

  call pollKeyboard
gameLogic_p1Keys:
  ld a, (player1KeysReady)
  ; out ($fe), a
  or a
  jp nz, gameLogic_postp1Keys

  ld hl, player1Coords
  ld b, (hl)
  inc hl
  ld c, (hl)

  rr b
  rr b
  rr b
  rr b
  rr c
  rr c
  rr c
  rr c

  
  ld a, (player1KeyMap)
  ld e, a
  ld a, 0
  bit 0, e
  call z, playerMoveLeft
  bit 1, e
  call z, playerMoveDown
  bit 2, e
  call z, playerMoveRight
  bit 3, e
  call z, player1Bomb
  bit 4, e
  call z, playerMoveUp


  rl b
  rl c
  ld a, b
  or 1
  ld b, a

  ld a, c
  or 1
  ld c, a
  
  rl b
  rl b
  rl b
  rl c
  rl c
  rl c

  ld (hl), c
  dec hl
  ld (hl), b

gameLogic_postp1Keys:
  ld a, (player1KeyMap)
  xor $1F
  ld (player1KeysReady), a

gameLogic_p2Keys:
  ld a, (player2KeysReady)
  ; out ($fe), a
  or a
  jp nz, gameLogic_postp2Keys

  ld hl, player2Coords
  ld b, (hl)
  inc hl
  ld c, (hl)

  rr b
  rr b
  rr b
  rr b
  rr c
  rr c
  rr c
  rr c

  
  ld a, (player2KeyMap)
  ld e, a
  ld a, 1
  bit 0, e
  call z, playerMoveRight
  bit 1, e
  call z, playerMoveDown
  bit 2, e
  call z, playerMoveLeft
  bit 3, e
  call z, playerMoveUp
  bit 4, e
  call z, player2Bomb


  rl b
  rl c
  ld a, b
  or 1
  ld b, a

  ld a, c
  or 1
  ld c, a
  
  rl b
  rl b
  rl b
  rl c
  rl c
  rl c

  ld (hl), c
  dec hl
  ld (hl), b


gameLogic_postp2Keys:
  ld a, (player2KeyMap)
  xor $1F
  ld (player2KeysReady), a
 
gameLogic_postKeys:

gameLogic_doneAnim:
  ret

gameLogic_keyboardState: defb 0

;; END GAME LOGIC FUNCTION

playerMoveRight:
  ld a, b
  add 1
  ld b, a
  call getSpriteTypeAtPosition
  or a
  ret z ; if a is zero, the it is an empty space

  ld a, b
  sub 1
  ld b, a
  ret

playerMoveLeft:
  ld a, b
  sub 1
  ld b, a
  call getSpriteTypeAtPosition
  or a
  ret z ; if a is zero, the it is an empty space

  ld a, b
  add 1
  ld b, a
  ret

playerMoveUp:
  ld a, c
  sub 1
  ld c, a
  call getSpriteTypeAtPosition
  or a
  ret z

  ld a, c
  add 1
  ld c, a
  ret

playerMoveDown:
  ld a, c
  add 1
  ld c, a
  call getSpriteTypeAtPosition
  or a
  ret z

  ld a, c
  sub 1
  ld c, a
  ret


;bomb1_pos: defb 0,0   ; pos of 0,0 means no bomb (2 bytes)
;bomb1_player: defb 0  ; which player owns the bomb (1 byte)
;bomb1_life: defb 0    ; how long the bomb has been on screen (1 byte)
;bomb1_size: defb 0    ; how many spaces the bomb extends to (1 byte)

player1Bomb:
  ld a, (player1BombsMax)
  ld hl, player1BombsOut
  cp (hl)
  ret z ; if no more bombs, return

  ld hl, bombs
  xor a
  cp (hl) ; check if X coord of first bomb is zero
  jp z, player1Bomb_setupBomb

  inc hl
  inc hl
  inc hl
  inc hl
  inc hl

  cp (hl) ; check if X coord of second bomb is zero
  jp z, player1Bomb_setupBomb

  inc hl
  inc hl
  inc hl
  inc hl
  inc hl

  cp (hl) ; check if X coord of third bomb is zero
  jp z, player1Bomb_setupBomb
  
  ret
  
player1Bomb_setupBomb:
  push bc
  rl b
  rr c
  rr c
  ld (hl), b
  inc hl
  ld (hl), c
  inc (hl)
  inc hl
  ld (hl), 0 ; set player
  inc hl
  ld (hl), 0 ; set life
  inc hl
  ld a, (player1BombSize)
  ld (hl), a
  

  pop bc
  ret


player2Bomb:
  ld a, (player2BombsMax)
  ld hl, player2BombsOut
  cp (hl)
  ret z ; if no more bombs, return

  ld hl, bombs
  xor a
  cp (hl) ; check if X coord of first bomb is zero
  jp z, player2Bomb_setupBomb

  inc hl
  inc hl
  inc hl
  inc hl
  inc hl

  cp (hl) ; check if X coord of second bomb is zero
  jp z, player2Bomb_setupBomb

  inc hl
  inc hl
  inc hl
  inc hl
  inc hl

  cp (hl) ; check if X coord of third bomb is zero
  jp z, player2Bomb_setupBomb
  
  ret
  
player2Bomb_setupBomb:
  ld (hl), b
  inc hl
  ld (hl), c
  inc hl
  ld (hl), 0 ; set player
  inc hl
  ld (hl), 0 ; set life
  inc hl
  ld a, (player2BombSize)
  ld (hl), a

  ret




drawUpdates:
  ret ; Not implemented!
  ld hl, updateList

drawPlayer:
  ;ld hl, player1Coords
  ld b, (hl)
  inc hl
  ld c, (hl)
  push bc
  ;ld de, bob

  push BC
  call coordToScrAddr
  call blitChar
  pop bc
  call setAttribute
  ld a, b
  add a, 8
  ld b, a
  push bc
  call coordToScrAddr
  call blitChar
  pop bc
  call setAttribute
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
  call setAttribute
  ld a, b
  add a, 8
  ld b, a
  push bc
  call coordToScrAddr
  call blitChar
  pop bc
  call setAttribute

  pop bc
  ret


drawMap:
  ld b, 0
  ld c, 0
drawMap_row:
drawMap_col:
  push bc
  ld hl, spriteList
  ld a, (de)
  push de
  or a
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
  call setAttribute
  ld a, b
  add a, 8
  ld b, a
  push bc
  call coordToScrAddr
  call blitChar
  pop bc
  call setAttribute
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
  call setAttribute
  ld a, b
  add a, 8
  ld b, a
  push bc
  call coordToScrAddr
  call blitChar
  pop bc
  call setAttribute

  pop DE
  pop BC
  ret

coordToScrAddr:
;On Entry: B reg = X coord,  C reg = Y coord
;On Exit: HL = screen address, A = pixel position
  ;push bc
  ;ld a, b
  ;ld (coordToScrAddr_Xcoord), a
  ;rl c
  ;ld l, c
  ;ld h, 0
  ;ld bc, lineLookup
  ;add hl, bc
  ;ld b, 0
  ;ld a, (coordToScrAddr_Xcoord)
  ;ld c, a
  ;rr c
  ;rr c
  ;rr c
  ;add hl, bc
  ;pop bc
  ;ret
  
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

  coordToScrAddr_Xcoord: defb 0

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

;; DE is src ptr
;; B is X coord
;; C is Y coord
setAttribute:
  ; ret ; NOT IMPLEMENTED!
  push bc
  push de
  ; Convert from x8 in screen coords to character coords
  ld a, c
  rra
  rra
  rra
  ld l, a
  ld a, b
  rra
  rra
  rra
  ld b, a

  ; Multiply Y coord by 32 (num bytes per line)
  ld h, 0
  add hl, hl
  add hl, hl
  add hl, hl
  add hl, hl
  add hl, hl

  ; Save attribute and attribute pointer
  ld a, (de)

  ld d, 0
  ld e, b
  add hl, de
  ld de, $5800
  add hl, de
  ld (hl), a
  pop de
  pop bc
  inc de
  ret


;; Before: BC = coordinates
;; After: A = sprite type
getSpriteTypeAtPosition:
  push hl
  push bc
  ; No idea why we need to increment the coordinates, but it works!
  inc b
  inc c
  ld a, 0
  ld h, b
  ld b, c
  inc b
  djnz getSpriteTypeAtPosition_rowAddLoop
  jp getSpriteTypeAtPosition_rowAddLoopEnd
getSpriteTypeAtPosition_rowAddLoop:
  add 15
  djnz getSpriteTypeAtPosition_rowAddLoop
getSpriteTypeAtPosition_rowAddLoopEnd:
  add h
  ld h, 0
  ld l, a
  ld bc, map
  add hl, bc
  ld a, (hl)
  pop bc
  pop hl

  ret


;; Before: BC = coordinates, A = sprite type
setSpriteTypeAtPosition:
  push hl
  push bc
  push af
  ; No idea why we need to increment the coordinates, but it works!
  inc b
  inc c
  ld a, 0
  ld h, b
  ld b, c
  inc b
  djnz getSpriteTypeAtPosition_rowAddLoop
  jp getSpriteTypeAtPosition_rowAddLoopEnd
setSpriteTypeAtPosition_rowAddLoop:
  add 15
  djnz getSpriteTypeAtPosition_rowAddLoop
setSpriteTypeAtPosition_rowAddLoopEnd:
  add h
  ld h, 0
  ld l, a
  ld bc, map
  add hl, bc
  pop af
  ;ld a, (hl)
  ld (hl), a
  pop bc
  pop hl

  ret


;; Define sprites (SID = Sprite ID)
;; If a sprite has ID of 0, it should be background/empty
spriteList:
  defw empty, wall, checker, brick, bob

;charO:

; Sprite bomberman pattern 1
  ;defb $00,$00,$00,$00,$00,$00,$00,$00,$47
  ;defb $00,$00,$00,$00,$00,$00,$00,$00,$47
  ;defb $00,$00,$00,$00,$00,$00,$00,$00,$47
  ;defb $00,$00,$00,$00,$00,$00,$00,$00,$47
  
spriteType_empty: defb 0
spriteType_wall: defb 1
spriteType_checker: defb 2
spriteType_brick: defb 3

; SID 0 - empty
empty:
  defb 0, 0, 0, 0, 0, 0, 0, 0, $47
  defb 0, 0, 0, 0, 0, 0, 0, 0, $47
  defb 0, 0, 0, 0, 0, 0, 0, 0, $47
  defb 0, 0, 0, 0, 0, 0, 0, 0, $47

; SID 1 - wall
wall:
  defb $7F, $FF, $C0, $C0, $C0, $C0, $C0, $C0, $47
  defb $FE, $FF, $03, $03, $03, $03, $03, $03, $47
  defb $C0, $C0, $C0, $C0, $C0, $C0, $FF, $7F, $47
  defb $03, $03, $03, $03, $03, $03, $FF, $FE, $47

; SID 2 - checker
checker:
  defb $55, $AA, $55, $AA, $55, $AA, $55, $AA, $47
  defb $55, $AA, $55, $AA, $55, $AA, $55, $AA, $47
  defb $55, $AA, $55, $AA, $55, $AA, $55, $AA, $47
  defb $55, $AA, $55, $AA, $55, $AA, $55, $AA, $47

brick:
  defb $00, $67, $67, $67, $67, $67, $67, $00, $42
  defb $00, $FE, $FE, $FE, $FE, $FE, $FE, $00, $42
  defb $00, $7F, $7F, $7F, $7F, $7F, $7F, $00, $42
  defb $00, $E6, $E6, $E6, $E6, $E6, $E6, $00, $42

bombSmall:
  defb $00, $00, $00, $04, $0A, $1D, $0F, $0E, $07
  defb $00, $00, $00, $00, $E0, $F0, $38, $28, $07
  defb $0F, $0F, $0F, $07, $03, $00, $00, $00, $07
  defb $A8, $F8, $F0, $F0, $C0, $00, $00, $00, $07

bombBig:
  defb $00, $18, $2C, $77, $3B, $1F, $0F, $0F, $07
  defb $00, $00, $E0, $F0, $F8, $FC, $3E, $2E, $07
  defb $1F, $1F, $1F, $1F, $0F, $07, $03, $00, $07
  defb $AE, $FE, $FC, $F8, $F8, $F0, $C0, $00, $07

bob:
  defb $00, $0F, $1F, $1D, $1F, $1D, $0E, $03, $45
  defb $00, $F0, $F8, $B8, $F8, $B8, $70, $C0, $45
  defb $01, $03, $0F, $0D, $01, $03, $02, $00, $45
  defb $98, $F8, $E0, $80, $80, $C0, $40, $00, $45
greg:
  defb $00, $0F, $1F, $1D, $1F, $1E, $0D, $03, $44
  defb $00, $F0, $F8, $B8, $F8, $78, $B0, $C0, $44
  defb $01, $03, $0F, $0D, $01, $03, $02, $00, $44
  defb $98, $F8, $E0, $80, $80, $C0, $40, $00, $44

maporig:
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
map:
  defb 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  defb 1, 0, 0, 3, 3, 3, 0, 3, 3, 3, 3, 3, 0, 0, 1
  defb 1, 0, 1, 3, 1, 3, 1, 3, 1, 0, 1, 3, 1, 0, 1
  defb 1, 0, 0, 0, 3, 3, 3, 3, 3, 0, 0, 3, 3, 0, 1
  defb 1, 3, 1, 0, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1
  defb 1, 3, 3, 0, 0, 0, 0, 0, 3, 3, 0, 3, 3, 3, 1
  defb 1, 0, 1, 3, 1, 3, 1, 0, 1, 3, 1, 3, 1, 3, 1
  defb 1, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 1
  defb 1, 3, 1, 3, 1, 0, 1, 0, 1, 3, 1, 3, 1, 0, 1
  defb 1, 3, 3, 3, 0, 0, 3, 3, 3, 3, 3, 3, 0, 0, 1
  defb 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1

map2:
  defb 3, 3, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 3, 3, 0
  defb 3, 0, 3, 0, 1, 0, 1, 0, 1, 1, 1, 0, 3, 0, 3
  defb 3, 3, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 3, 3, 0
  defb 3, 0, 3, 0, 1, 0, 1, 0, 1, 0, 1, 0, 3, 0, 3
  defb 3, 3, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 3, 3, 0
  defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  defb 1, 1, 1, 0, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0
  defb 1, 0, 0, 0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0
  defb 1, 1, 1, 0, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0
  defb 1, 0, 0, 0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0
  defb 1, 1, 1, 0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0

map3:
  defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  defb 1, 0, 1, 0, 2, 2, 2, 0, 3, 0, 0, 3, 0, 4, 0
  defb 1, 1, 1, 0, 2, 0, 2, 0, 3, 3, 0, 3, 0, 4, 0
  defb 1, 0, 1, 0, 2, 2, 2, 0, 3, 3, 0, 3, 0, 4, 0
  defb 1, 0, 1, 0, 2, 0, 2, 0, 3, 0, 3, 3, 0, 0, 0
  defb 1, 0, 1, 0, 2, 0, 2, 0, 3, 0, 3, 3, 0, 4, 0
  defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

updateList:
  defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

