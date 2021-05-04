bankSwitchDebug:
    ; on each bank switch, check if the caller is in bank 0.
    ; if not, we hit a breakpoint, because that's almost
    ; definitely a bug.

    ; save bank, hl, flags
    ; it's important to not clobber the flags.
    ldh [hShortFarCallBank], a
    ld a, h
    ldh [hShortFarCallH], a
    ld a, l
    ldh [hShortFarCallL], a
    push af
    pop hl
    ld a, l
    ldh [hShortFarCallF], a

    pop hl ; get return addr
    push hl ; balance stack


    ld a, h
    ;emu_dprint "%ROMBANK%:%HL% BankSwitch(%A%)"
    cp $3F
    jr c, .doSwitch

    ; caller address is >= 0x4000!
    breakpoint

.doSwitch:
    ; restore hl
    ldh a, [hShortFarCallF]
    ld l, a
    push hl
    pop af ; restore flags
    ldh a, [hShortFarCallH]
    ld h, a
    ldh a, [hShortFarCallL]
    ld l, a

    ; do bank switch
    ldh a, [hShortFarCallBank]
    ldh [hROMBank], a   ; 0010
	ld [MBC3RomBank], a ; 0012
    ret
