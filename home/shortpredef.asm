_shortPredefContinued:
    pop hl ; h=a_in, l=f_in; stack: ret
    ld a, l
    ldh [hShortFarCallF], a ; save f_in (already saved a)

    ; get target address
    pop hl ; get return address (actually params); stack: empty
    ld a, [hli] ; get target func ID
    ld [wPredefID], a
    push hl ; re-store corrected return address; stack: ret

    ; save ROM bank to stack, to allow recursion
    ldh a, [hROMBank]
    push af ; stack: bank, ret

    ld a, BANK(GetPredefPointer)
    rst Bankswitch
    call GetPredefPointer
    ; now a=bank, wPredefAddress=addr, wPredefHL=hl
    and a
    jr nz, .doBankSwitch
    ; for home calls there's no need to change bank.
    ; but we did already change it for GetPredefPointer.
    ; so change back to what it used to be.
    ; this allows predefs for functions that read from
    ; arbitrary ROM banks such as CopyBytes.
    pop af
    push af
.doBankSwitch:
    rst Bankswitch

    ; store the pointer
    ld a, [wPredefAddress + 1] ; byte swapped...
    ldh [hShortFarCallTarget], a
    ld a, [wPredefAddress]
    ldh [hShortFarCallTarget + 1], a
    ld a, $C3 ; a jump instruction
    ldh [hShortFarCallJump], a

    ; rest of the code is identical to ShortFarCall
    jp shortFarCallDo
