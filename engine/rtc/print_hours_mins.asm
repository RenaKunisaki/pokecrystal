PrintFiveDigitNumber: ; unreferenced
; Debug function?
; Input: bc = value, de = destination
	ld a, b
	ld b, c
	ld c, a
	push bc ; de points to this on the stack for PrintNum
	push de
	ld hl, sp+2
	ld d, h
	ld e, l
	pop hl
	lb bc, PRINTNUM_LEADINGZEROS | 2, 5
	predef PrintNum
	pop bc
	ret

PrintHoursMins:
; Hours in b, minutes in c
    ld l, 12
    ld a, [wOptions]
    bit CLOCK_24_HOURS,a
    jr z, .do_12hr
    ld l, 99

.do_12hr:
    ld a, b
    cp l
	push af
	jr c, .AM
	jr z, .PM
	sub 12
	jr .PM
.AM:
	or a
	jr nz, .PM
	ld a, 12
.PM:
	ld b, a
; Crazy stuff happening with the stack
	push bc
	ld hl, sp+1
	push de
	push hl
	pop de
	pop hl
	ld [hl], " "
	lb bc, 1, 2
	predef PrintNum
	ld [hl], ":"
	inc hl
	ld d, h
	ld e, l
	ld hl, sp+0
	push de
	push hl
	pop de
	pop hl
	lb bc, PRINTNUM_LEADINGZEROS | 1, 2
	predef PrintNum
	pop bc
	ld de, String_AM
	pop af
	jr c, .place_am_pm
	ld de, String_PM
.place_am_pm
	inc hl
	predef PlaceString
	ret

String_AM: db "AM@"
String_PM: db "PM@"
