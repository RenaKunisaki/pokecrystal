; rst vectors (called through the rst instruction)

SECTION "rst0", ROM0[$0000] ; error handler
	rst $38 ; 0000
	rst $38 ; 0001
	rst $38 ; 0002
	rst $38 ; 0003
	rst $38 ; 0004
	rst $38 ; 0005
	rst $38 ; 0006
	rst $38 ; 0007

SECTION "rst8", ROM0[$0008] ; farcall
FarCall::
	jp FarCall_hl ; 0008
    rst $38 ; 000B
    rst $38 ; 000C
    rst $38 ; 000D
    rst $38 ; 000E
    rst $38 ; 000F

SECTION "rst10", ROM0[$0010] ; bankswitch
Bankswitch::
	ldh [hROMBank], a   ; 0010
	ld [MBC3RomBank], a ; 0012
	ret                 ; 0015
    rst $38             ; 0016
    rst $38             ; 0017

SECTION "rst18", ROM0[$0018] ; short farcall (was unused)
ShortFarCall::
    push af ; 0018 stack: af_in, ret
    ldh [hShortFarCallA], a ; 0019 save a_in (again)
    ld a, h ; 001B
    ldh [hShortFarCallH], a ; 001C save h_in
	jr _shortFarCallContinued ; 001E

SECTION "rst20", ROM0[$0020] ; unused
    rst $38 ; 0020
    rst $38 ; 0021
    rst $38 ; 0022
    rst $38 ; 0023
    rst $38 ; 0024
    rst $38 ; 0025
    rst $38 ; 0026
    rst $38 ; 0027

SECTION "rst28", ROM0[$0028] ; JumpTable
JumpTable::
    push de       ; 0028
    ld e, a       ; 0029
    ld d, 0       ; 002A
    add hl, de    ; 002C
    add hl, de    ; 002D
    jr _jumpTableContinued ; 002E

SECTION "rst30", ROM0[$0030] ; unused (was clobbered by JumpTable)
    rst $38 ; 0030
    rst $38 ; 0031
    rst $38 ; 0032
    rst $38 ; 0033
    rst $38 ; 0034
    rst $38 ; 0035
    rst $38 ; 0036
    rst $38 ; 0037

SECTION "rst38", ROM0[$0038] ; error handler
Panic::
    di ; 0038
_rst38_loop:
    stop ; 0039, NOP added automatically after
    jr _rst38_loop ; 003B
    rst $38 ; 003D
    rst $38 ; 003E
    rst $38 ; 003F


; Game Boy hardware interrupts

SECTION "vblank", ROM0[$0040]
	jp VBlank ; 0040
    rst $38   ; 0043
    rst $38   ; 0044
    rst $38   ; 0045
    rst $38   ; 0046
    rst $38   ; 0047

SECTION "lcd", ROM0[$0048]
	jp LCD  ; 0048
    rst $38 ; 004B
    rst $38 ; 004C
    rst $38 ; 004D
    rst $38 ; 004E
    rst $38 ; 004F

SECTION "timer", ROM0[$0050]
	jp MobileTimer ; 0050
    rst $38        ; 0053
    rst $38        ; 0054
    rst $38        ; 0055
    rst $38        ; 0056
    rst $38        ; 0057

SECTION "serial", ROM0[$0058]
	jp Serial ; 0058
    rst $38   ; 005B
    rst $38   ; 005C
    rst $38   ; 005D
    rst $38   ; 005E
    rst $38   ; 005F

SECTION "joypad", ROM0[$0060]
	jp Joypad ; 0060

; here we can stick some additional code
_jumpTableContinued:
    ld a, [hli]
    ld h, [hl]
    ld l, a
    pop de
    jp hl

_shortFarCallContinued:
    ld a, l
    ldh [hShortFarCallL], a ; save l_in

    pop hl ; h=a_in, l=f_in; stack: ret
    ld a, l
    ldh [hShortFarCallF], a ; save f_in (already saved a)

    ; save current bank
    ldh a, [hROMBank]
	ldh [hShortFarCallBank],a

    ; this is done in init instead
    ;ld a, $C3 ; a jump instruction
    ;ldh [hShortFarCallJump], a

    ; get target address
    pop hl ; get return address (actually params); stack: empty
    ld a, [hli] ; get target byte 1
    ldh [hShortFarCallTarget], a
    ld a, [hli] ; get target byte 2
    ldh [hShortFarCallTarget+1], a
    ld a, [hli] ; get bank
    push hl ; re-store corrected return address; stack: ret
    rst Bankswitch ; switch to target bank

    ; save previous bank to stack, to allow recursion
    ldh a,[hShortFarCallBank]
    push af ; stack: bank, ret

    ; restore af inputs to target
    ldh a, [hShortFarCallA]
    ld h, a
    ldh a, [hShortFarCallF]
    ld l, a
    push hl ; will pop into af; stack: af_in, bank, ret

    ; restore hl inputs
    ldh a, [hShortFarCallH]
    ld h, a
    ldh a, [hShortFarCallL]
    ld l, a
    pop af ; af = af_in; stack: bank, ret

    ; call the target
    call hShortFarCallJump

    ; We want to retain the contents of af.
    ; To do this, we can pop to bc instead of af.
    ldh [hShortFarCallA], a
    ld a, b
	ld [wFarCallBC], a
	ld a, c
	ld [wFarCallBC + 1], a

; Restore the working bank.
	pop bc ; b=bank; stack: ret
    push af ; keep those flags; stack: af_out, ret
	ld a, b
	rst Bankswitch

; Restore the contents of bc.
	ld a, [wFarCallBC]
	ld b, a
	ld a, [wFarCallBC + 1]
	ld c, a
    pop af ; af = af_out; stack: ret
    ldh a, [hShortFarCallA]
	ret ; stack: empty
; 009E

SECTION "Header", ROM0[$0100]

Start::
; Nintendo requires all Game Boy ROMs to begin with a nop ($00) and a jp ($C3)
; to the starting address.
	nop
	jp _Start

; The Game Boy cartridge header data is patched over by rgbfix.
; This makes sure it doesn't get used for anything else.

	ds $0150 - @, $00
