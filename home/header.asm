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
    ; rst padding here is mainly for me to keep track of space.
    ; it also has the very tiny bonus that stray jumps to these
    ; addresses will panic immediately, as unlikely as that is.

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
;if DEF(_DEBUG)
;    jp bankSwitchDebug ; 0010
;else
	ldh [hROMBank], a   ; 0010
	ld [MBC3RomBank], a ; 0012
	ret                 ; 0015
    rst $38             ; 0016
    rst $38             ; 0017
;endc

SECTION "rst18", ROM0[$0018] ; short farcall (was unused)
ShortFarCall::
    push af ; 0018 stack: af_in, ret
    ldh [hShortFarCallA], a ; 0019 save a_in (again)
    ld a, h ; 001B
    ldh [hShortFarCallH], a ; 001C save h_in
	jr _shortFarCallContinued ; 001E

SECTION "rst20", ROM0[$0020] ; short predef (was unused)
ShortPredef::
    jp Predef ; 0020
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
    breakpoint ; 0038
    di ; 0039
_rst38_loop:
    stop ; 003A, NOP added automatically after
    jr _rst38_loop ; 003C
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

INCLUDE "home/shortfarcall.asm"
; 00A2

if DEF(_DEBUG)
INCLUDE "home/bankswitchdebug.asm"
endc

SECTION "Header", ROM0[$0100]

Start::
; Nintendo requires all Game Boy ROMs to begin with a nop ($00) and a jp ($C3)
; to the starting address.
	nop
	jp _Start

; The Game Boy cartridge header data is patched over by rgbfix.
; This makes sure it doesn't get used for anything else.

	ds $0150 - @, $00
