_shortFarCallContinued:
    ld a, l
    ldh [hShortFarCallL], a ; save l_in

    pop hl ; h=a_in, l=f_in; stack: ret
    ld a, l
    ldh [hShortFarCallF], a ; save f_in (already saved a)

    ; save current bank
    ldh a, [hROMBank]
	ldh [hShortFarCallBank],a

    ; temp debug
    ldh a, [hShortFarCallDepth]
    inc a
    ldh [hShortFarCallDepth], a

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
    ;rst Bankswitch ; switch to target bank
    ldh [hROMBank], a   ; 0010
	ld [MBC3RomBank], a ; 0012

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
    ld l, a ; hl = hl_in
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

    ; temp debug
    ldh a, [hShortFarCallDepth]
    dec a
    ldh [hShortFarCallDepth], a

; Restore the working bank.
	pop bc ; b=bank; stack: ret
    push af ; keep those flags; stack: af_out, ret
	ld a, b
	;rst Bankswitch
    ldh [hROMBank], a   ; 0010
	ld [MBC3RomBank], a ; 0012

; Restore the contents of bc.
	ld a, [wFarCallBC]
	ld b, a
	ld a, [wFarCallBC + 1]
	ld c, a
    pop af ; af = af_out; stack: ret
    ldh a, [hShortFarCallA]
	ret ; stack: empty
