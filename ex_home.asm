; misc functions moved out of home bank

; ========== clear_sprites.asm ==========

;ClearSprites_far::
;; Erase OAM data
;	ld hl, wVirtualOAM
;	ld b, wVirtualOAMEnd - wVirtualOAM
;	xor a
;.loop
;	ld [hli], a
;	dec b
;	jr nz, .loop
;	ret

HideSprites_far::
; Set all OAM y-positions to 160 to hide them offscreen
	ld hl, wVirtualOAMSprite00YCoord
	ld de, SPRITEOAMSTRUCT_LENGTH
	ld b, NUM_SPRITE_OAM_STRUCTS
	ld a, SCREEN_WIDTH_PX
.loop
	ld [hl], a ; y
	add hl, de
	dec b
	jr nz, .loop
	ret


; ========== double_speed.asm ==========

DoubleSpeed_far::
	ld hl, rKEY1
	bit 7, [hl]
	jr z, SwitchSpeed_far
	ret

NormalSpeed_far::
	ld hl, rKEY1
	bit 7, [hl]
	ret z

SwitchSpeed_far::
	set 0, [hl]
	xor a
	ldh [rIF], a
	ldh [rIE], a
	ld a, $30
	ldh [rJOYP], a
	stop ; rgbasm adds a nop after this instruction by default
	ret

; ========== flag.asm ==========

ResetFlashIfOutOfCave_far::
	ld a, [wEnvironment]
	cp ROUTE
	jr z, .outdoors
	cp TOWN
	jr z, .outdoors
	ret

.outdoors
	ld hl, wStatusFlags
	res STATUSFLAGS_FLASH_F, [hl]
	ret

; ========== game_time.asm ==========

ResetGameTime_far::
	xor a
	ld [wGameTimeCap], a
	ld [wGameTimeHours], a
	ld [wGameTimeHours + 1], a
	ld [wGameTimeMinutes], a
	ld [wGameTimeSeconds], a
	ld [wGameTimeFrames], a
	ret

GameTimer_far::
	ldh a, [rSVBK]
	push af
	ld a, BANK(wGameTime)
	ldh [rSVBK], a

	call .Function

	pop af
	ldh [rSVBK], a
	ret

.Function:
; Increment the game timer by one frame.
; The game timer is capped at 9999:59:59.00.

; Don't update if game logic is paused.
	ld a, [wGameLogicPaused]
	and a
	ret nz

; Is the timer paused?
	ld hl, wGameTimerPaused
	bit GAME_TIMER_PAUSED_F, [hl]
	ret z

; Is the timer already capped?
	ld hl, wGameTimeCap
	bit 0, [hl]
	ret nz

; +1 frame
	ld hl, wGameTimeFrames
	ld a, [hl]
	inc a

	cp 60 ; frames/second
	jr nc, .second

	ld [hl], a
	ret

.second
	xor a
	ld [hl], a

; +1 second
	ld hl, wGameTimeSeconds
	ld a, [hl]
	inc a

	cp 60 ; seconds/minute
	jr nc, .minute

	ld [hl], a
	ret

.minute
	xor a
	ld [hl], a

; +1 minute
	ld hl, wGameTimeMinutes
	ld a, [hl]
	inc a

	cp 60 ; minutes/hour
	jr nc, .hour

	ld [hl], a
	ret

.hour
	xor a
	ld [hl], a

; +1 hour
	ld a, [wGameTimeHours]
	ld h, a
	ld a, [wGameTimeHours + 1]
	ld l, a
	inc hl

; Cap the timer after 1000 hours.
	ld a, h
	cp HIGH(10000)
	jr c, .ok

	ld a, l
	cp LOW(10000)
	jr c, .ok

	ld hl, wGameTimeCap
	set 0, [hl]

	ld a, 59 ; 9999:59:59.00
	ld [wGameTimeMinutes], a
	ld [wGameTimeSeconds], a
	ret

.ok
	ld a, h
	ld [wGameTimeHours], a
	ld a, l
	ld [wGameTimeHours + 1], a
	ret

; ========== hm_moves.asm ==========

IsHM_far::
	cp HM01
	jr c, .NotHM
	scf
	ret
.NotHM:
	and a
	ret

IsHMMove_far::
	ld hl, .HMMoves
	ld de, 1
	jp IsInArray

.HMMoves:
	db CUT
	db FLY
	db SURF
	db STRENGTH
	db FLASH
	db WATERFALL
	db WHIRLPOOL
	db -1 ; end

; ========== init.asm ==========

Init2_far::
    xor a
	ldh [hMapAnims], a
	ldh [hSCX], a
	ldh [hSCY], a
	ldh [rJOYP], a

	ld a, $8 ; HBlank int enable
	ldh [rSTAT], a

	ld a, $90
	ldh [hWY], a
	ldh [rWY], a

	ld a, 7
	ldh [hWX], a
	ldh [rWX], a

	ld a, LCDC_DEFAULT ; %11100011
	; LCD on
	; Win tilemap 1
	; Win on
	; BG/Win tiledata 0
	; BG Tilemap 0
	; OBJ 8x8
	; OBJ on
	; BG on
	ldh [rLCDC], a

	ld a, CONNECTION_NOT_ESTABLISHED
	ldh [hSerialConnectionStatus], a

	farcall InitCGBPals

	ld a, HIGH(vBGMap1)
	ldh [hBGMapAddress + 1], a
	xor a ; LOW(vBGMap1)
	ldh [hBGMapAddress], a

	farcall StartClock

	xor a ; SRAM_DISABLE
	ld [MBC3LatchClock], a
	ld [MBC3SRamEnable], a

	ldh a, [hCGB]
	and a
	jr z, .no_double_speed
	call NormalSpeed
.no_double_speed

	xor a
	ldh [rIF], a
	ld a, IE_DEFAULT
	ldh [rIE], a
	ei

	call DelayFrame

	predef InitSGBBorder

	call InitSound
	xor a
	ld [wMapMusic], a

ClearVRAM_far::
    ld a, 1
	ldh [rVBK], a
	call .clear

	xor a ; 0
	ldh [rVBK], a
.clear
	ld hl, VRAM_Begin
	ld bc, VRAM_End - VRAM_Begin
	xor a
	call ByteFill
	ret

ClearWRAM_far::
    ld a, 1
.bank_loop
	push af
	ldh [rSVBK], a
	xor a
	ld hl, WRAM1_Begin
	ld bc, WRAM1_End - WRAM1_Begin
	call ByteFill
	pop af
	inc a
	cp 8
	;jr nc, .bank_loop ; Should be jr c
	jr c, .bank_loop
	ret

ClearsScratch_far::
; Wipe the first 32 bytes of sScratch

	ld a, BANK(sScratch)
	call OpenSRAM
	ld hl, sScratch
	ld bc, $20
	xor a
	call ByteFill
	call CloseSRAM
	ret

; ========== joypad.asm ==========

BlinkCursor_far::
	push bc
	ld a, [hl]
	ld b, a
	ld a, "▼"
	cp b
	pop bc
	jr nz, .place_arrow
	ldh a, [hMapObjectIndex]
	dec a
	ldh [hMapObjectIndex], a
	ret nz
	ldh a, [hObjectStructIndex]
	dec a
	ldh [hObjectStructIndex], a
	ret nz
	ld a, "─"
	ld [hl], a
	ld a, -1
	ldh [hMapObjectIndex], a
	ld a, 6
	ldh [hObjectStructIndex], a
	ret

.place_arrow
	ldh a, [hMapObjectIndex]
	and a
	ret z
	dec a
	ldh [hMapObjectIndex], a
	ret nz
	dec a
	ldh [hMapObjectIndex], a
	ldh a, [hObjectStructIndex]
	dec a
	ldh [hObjectStructIndex], a
	ret nz
	ld a, 6
	ldh [hObjectStructIndex], a
	ld a, "▼"
	ld [hl], a
	ret

; ========== map_objects.asm ==========

;GetObjectStruct_far::
;	ld bc, OBJECT_LENGTH
;	ld hl, wObjectStructs
;	call AddNTimes
;	ld b, h
;	ld c, l
;	ret
;
;DoesObjectHaveASprite_far::
;	ld hl, OBJECT_SPRITE
;	add hl, bc
;	ld a, [hl]
;	and a
;	ret
;
;SetSpriteDirection_far::
;	; preserves other flags
;	push af
;	ld hl, OBJECT_FACING
;	add hl, bc
;	ld a, [hl]
;	and %11110011
;	ld e, a
;	pop af
;	maskbits NUM_DIRECTIONS, 2
;	or e
;	ld [hl], a
;	ret
;
;GetSpriteDirection_far::
;	ld hl, OBJECT_FACING
;	add hl, bc
;	ld a, [hl]
;	maskbits NUM_DIRECTIONS, 2
;	ret
