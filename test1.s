	org 32768

; define constants
map_width: defb 15
map_height: defb 11
hasDrawnMap: defb 0

player1Coords: defw 0

brdrColor: defb 0

start:
	; call setupInterrupt
  di
  ld a, 2
  out ($fe), a  ; set border color
  call 3503     ; Clear screen routine in ROM
  
  jp callback ; Start loop

callback:
  ld a, (hasDrawnMap)
  call z, drawMap

  call newBorder

  jp callback

newBorder:
  ld a, (brdrColor)
  out ($fe), a
  inc a
  and $07 ; only affect border color bits
  ld (brdrColor), a
  ret

initLevel:
  call drawMap
  ret

drawUpdates:
  ret ; Not implemented!
  ld hl, updateList

drawMap:
  ld de, map
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
  ld a, 1
  ld (hasDrawnMap), a
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

;; Define sprites (SID = Sprite ID)
;; If a sprite has ID of 0, it should be background/empty
spriteList:
  defw empty, wall, checker, brick
  
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

lineLookup:
DEFW 24576	;y=0
DEFW 24832	;y=1
DEFW 25088	;y=2
DEFW 25344	;y=3
DEFW 25600	;y=4
DEFW 25856	;y=5
DEFW 26112	;y=6
DEFW 26368	;y=7
DEFW 24608	;y=8
DEFW 24864	;y=9
DEFW 25120	;y=10
DEFW 25376	;y=11
DEFW 25632	;y=12
DEFW 25888	;y=13
DEFW 26144	;y=14
DEFW 26400	;y=15
DEFW 24640	;y=16
DEFW 24896	;y=17
DEFW 25152	;y=18
DEFW 25408	;y=19
DEFW 25664	;y=20
DEFW 25920	;y=21
DEFW 26176	;y=22
DEFW 26432	;y=23
DEFW 24672	;y=24
DEFW 24928	;y=25
DEFW 25184	;y=26
DEFW 25440	;y=27
DEFW 25696	;y=28
DEFW 25952	;y=29
DEFW 26208	;y=30
DEFW 26464	;y=31
DEFW 24704	;y=32
DEFW 24960	;y=33
DEFW 25216	;y=34
DEFW 25472	;y=35
DEFW 25728	;y=36
DEFW 25984	;y=37
DEFW 26240	;y=38
DEFW 26496	;y=39
DEFW 24736	;y=40
DEFW 24992	;y=41
DEFW 25248	;y=42
DEFW 25504	;y=43
DEFW 25760	;y=44
DEFW 26016	;y=45
DEFW 26272	;y=46
DEFW 26528	;y=47
DEFW 24768	;y=48
DEFW 25024	;y=49
DEFW 25280	;y=50
DEFW 25536	;y=51
DEFW 25792	;y=52
DEFW 26048	;y=53
DEFW 26304	;y=54
DEFW 26560	;y=55
DEFW 24800	;y=56
DEFW 25056	;y=57
DEFW 25312	;y=58
DEFW 25568	;y=59
DEFW 25824	;y=60
DEFW 26080	;y=61
DEFW 26336	;y=62
DEFW 26592	;y=63
DEFW 26624	;y=64
DEFW 26880	;y=65
DEFW 27136	;y=66
DEFW 27392	;y=67
DEFW 27648	;y=68
DEFW 27904	;y=69
DEFW 28160	;y=70
DEFW 28416	;y=71
DEFW 26656	;y=72
DEFW 26912	;y=73
DEFW 27168	;y=74
DEFW 27424	;y=75
DEFW 27680	;y=76
DEFW 27936	;y=77
DEFW 28192	;y=78
DEFW 28448	;y=79
DEFW 26688	;y=80
DEFW 26944	;y=81
DEFW 27200	;y=82
DEFW 27456	;y=83
DEFW 27712	;y=84
DEFW 27968	;y=85
DEFW 28224	;y=86
DEFW 28480	;y=87
DEFW 26720	;y=88
DEFW 26976	;y=89
DEFW 27232	;y=90
DEFW 27488	;y=91
DEFW 27744	;y=92
DEFW 28000	;y=93
DEFW 28256	;y=94
DEFW 28512	;y=95
DEFW 26752	;y=96
DEFW 27008	;y=97
DEFW 27264	;y=98
DEFW 27520	;y=99
DEFW 27776	;y=100
DEFW 28032	;y=101
DEFW 28288	;y=102
DEFW 28544	;y=103
DEFW 26784	;y=104
DEFW 27040	;y=105
DEFW 27296	;y=106
DEFW 27552	;y=107
DEFW 27808	;y=108
DEFW 28064	;y=109
DEFW 28320	;y=110
DEFW 28576	;y=111
DEFW 26816	;y=112
DEFW 27072	;y=113
DEFW 27328	;y=114
DEFW 27584	;y=115
DEFW 27840	;y=116
DEFW 28096	;y=117
DEFW 28352	;y=118
DEFW 28608	;y=119
DEFW 26848	;y=120
DEFW 27104	;y=121
DEFW 27360	;y=122
DEFW 27616	;y=123
DEFW 27872	;y=124
DEFW 28128	;y=125
DEFW 28384	;y=126
DEFW 28640	;y=127
