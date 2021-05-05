; Syntactic sugar macros

lb: MACRO ; r, hi, lo
	ld \1, ((\2) & $ff) << 8 | ((\3) & $ff)
ENDM

ln: MACRO ; r, hi, lo
	ld \1, ((\2) & $f) << 4 | ((\3) & $f)
ENDM

pushm: MACRO ; eg pushm af, bc, de, hl
    push \1
IF _NARG > 1
    push \2
ENDC
IF _NARG > 2
    push \3
ENDC
IF _NARG > 3
    push \4
ENDC
ENDM

popm: MACRO
    pop \1
IF _NARG > 1
    pop \2
ENDC
IF _NARG > 2
    pop \3
ENDC
IF _NARG > 3
    pop \4
ENDC
ENDM


; emulator debug functions, supported by bgb and no$gmb, maybe others

; eg emu_dprint "hello, HL=%HL%"
; available vars: AF, BC, DE, HL, SP, PC, B, C, D, E, H, L, A, ZERO, ZF, Z,
; CARRY, CY, IME, ALLREGS, ROMBANK, XRAMBANK, SRAMBANK, WRAMBANK, VRAMBANK,
; TOTALCLKS, LASTCLKS, CLKS2VBLANK
; ZEROCLKS will reset the LASTCLKS counter
if DEF(_DEBUG)
emu_dprint: MACRO
    PUSHC
    SETCHARMAP ascii
    ld d,d ; signal debug message
    jr .end_\@
    dw $6464 ; additional signal
    dw $0000 ; flags: message follows
    db \1
    POPC
.end_\@:
ENDM

else
emu_dprint: MACRO
    ; do nothing
ENDM
endc

; eg emu_dprint_far addressOfMyMessage
; message can be in a different bank
if DEF(_DEBUG)
emu_dprint_far: MACRO
    ld d,d ; signal debug message
    jr .end_\@
    dw $6464 ; additional signal
    dw $0001 ; flags: pointer to message follows
    dw \1
    db BANK(\1)
.end_\@:
ENDM

else
emu_dprint_far: MACRO
    ; do nothing
ENDM
endc

if DEF(_DEBUG)
breakpoint: MACRO
    ld b, b
ENDM
else
breakpoint: MACRO
    ; nothing
ENDM
endc


; Design patterns

jumptable: MACRO
	ld a, [\2]
	ld e, a
	ld d, 0
	ld hl, \1
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl
ENDM

maskbits: MACRO
; masks just enough bits to cover the first argument
; the second argument is an optional shift amount
; e.g. "maskbits 26" becomes "and %00011111" (since 26 - 1 = %00011001)
; and "maskbits 3, 2" becomes "and %00001100" (since "maskbits 3" becomes %00000011)
; example usage in rejection sampling:
; .loop
; 	predef Random
; 	maskbits 26
; 	cp 26
; 	jr nc, .loop
	assert 0 < (\1) && (\1) <= $100, "bitmask must be 8-bit"
x = 1
rept 8
if x + 1 < (\1)
x = x << 1 | 1
endc
endr
if _NARG == 2
	and x << (\2)
else
	and x
endc
ENDM

calc_sine_wave: MACRO
; input: a = a signed 6-bit value
; output: a = d * sin(a * pi/32)
	and %111111
	cp %100000
	jr nc, .negative\@
	call .apply\@
	ld a, h
	ret
.negative\@
	and %011111
	call .apply\@
	ld a, h
	xor $ff
	inc a
	ret
.apply\@
	ld e, a
	ld a, d
	ld d, 0
if _NARG == 1
	ld hl, \1
else
	ld hl, .sinetable\@
endc
	add hl, de
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, 0
.multiply\@ ; factor amplitude
	srl a
	jr nc, .even\@
	add hl, de
.even\@
	sla e
	rl d
	and a
	jr nz, .multiply\@
	ret
if _NARG == 0
.sinetable\@
	sine_table 32
endc
ENDM
