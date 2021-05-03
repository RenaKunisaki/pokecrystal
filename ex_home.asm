; misc functions moved out of home bank

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
