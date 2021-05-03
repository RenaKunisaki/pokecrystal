farcall: MACRO ; bank, address
	;ld a, BANK(\1)
	;ld hl, \1
	;rst FarCall

    ; this version saves 2 bytes per instance
    ; by not having to store the "ld a" and "ld hl" opcodes.
    rst ShortFarCall
    dw \1
    db BANK(\1)
ENDM

callfar: MACRO ; address, bank
	;ld hl, \1
	;ld a, BANK(\1)
	;rst FarCall
    rst ShortFarCall
    dw \1
    db BANK(\1)
ENDM

homecall: MACRO
	ldh a, [hROMBank]
	push af
	ld a, BANK(\1)
	rst Bankswitch
	call \1
	pop af
	rst Bankswitch
ENDM
