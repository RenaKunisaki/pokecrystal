_shortFarCallStoreAHL:
    ldh [hShortFarCallA], a ; save a_in (again)
    ld a, h
    ldh [hShortFarCallH], a ; save h_in
    ld a, l
    ldh [hShortFarCallL], a ; save l_in
    ret

; Shorter version of farcall
; Saves 2 bytes per invocation, and preserves all regs/flags
; on input and output.
_shortFarCallContinued:
    ; first few instructions are at $0018 because why not
    ; take advantage of that otherwise usless space?

    call _shortFarCallStoreAHL

    pop hl ; h=a_in, l=f_in; stack: ret
    ld a, l
    ldh [hShortFarCallF], a ; save f_in (already saved a)

    ; save current bank
    ldh a, [hROMBank]
	ldh [hShortFarCallBank],a

    ; temp debug
    ;ldh a, [hShortFarCallDepth]
    ;inc a
    ;ldh [hShortFarCallDepth], a

    ; get target address
    pop hl ; get return address (actually params); stack: empty
    ld a, [hli] ; get target byte 1
    ldh [hShortFarCallTarget], a
    ld a, [hli] ; get target byte 2
    ldh [hShortFarCallTarget+1], a
    ld a, [hli] ; get bank
    push hl ; re-store corrected return address; stack: ret
    rst Bankswitch ; switch to target bank
    ;ldh [hROMBank], a
	;ld [MBC3RomBank], a

    ; save previous bank to stack, to allow recursion
    ldh a,[hShortFarCallBank]
    push af ; stack: bank, ret

    ; ShortPredef joins here.
shortFarCallDo:
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

    ld a, $C3 ; a jump instruction
    ldh [hShortFarCallJump], a

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
    ;ldh a, [hShortFarCallDepth]
    ;dec a
    ;ldh [hShortFarCallDepth], a

; Restore the working bank.
	pop bc ; b=bank; stack: ret
    push af ; keep those flags; stack: af_out, ret
	ld a, b
	rst Bankswitch
    ;ldh [hROMBank], a
	;ld [MBC3RomBank], a

; Restore the contents of bc.
	ld a, [wFarCallBC]
	ld b, a
	ld a, [wFarCallBC + 1]
	ld c, a
    pop af ; af = af_out; stack: ret
    ldh a, [hShortFarCallA]
	ret ; stack: empty
