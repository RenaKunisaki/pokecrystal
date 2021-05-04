Reset::
	di
	call InitSound
	xor a
	ldh [hMapAnims], a
	call ClearPalettes
	xor a
	ldh [rIF], a
	ld a, 1 << VBLANK
	ldh [rIE], a
	ei

	ld hl, wJoypadDisable
	set JOYPAD_DISABLE_SGB_TRANSFER_F, [hl]

	ld c, 32
	call DelayFrames

	jr Init

_Start::
	cp $11
	jr z, .cgb
	xor a ; FALSE
	jr .load

.cgb
	ld a, TRUE

.load
	ldh [hCGB], a
	ld a, TRUE
	ldh [hSystemBooted], a

Init::
	di

	xor a
	ldh [rIF], a
	ldh [rIE], a
	ldh [rRP], a
	ldh [rSCX], a
	ldh [rSCY], a
	ldh [rSB], a
	ldh [rSC], a
	ldh [rWX], a
	ldh [rWY], a
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	ldh [rTMA], a
	ldh [rTAC], a
    ; pointless, we clear WRAM soon
	;ld [wBetaTitleSequenceOpeningType], a

    ld a, %100 ; Start timer at 4096Hz
	ldh [rTAC], a

.wait
	ldh a, [rLY]
	cp LY_VBLANK + 1
	jr nz, .wait

	xor a
	ldh [rLCDC], a

; Clear WRAM bank 0
	ld hl, WRAM0_Begin
	ld bc, WRAM0_End - WRAM0_Begin
.ByteFill:
	ld [hl], 0
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, .ByteFill

	ld sp, wStackTop

; Clear HRAM
	ldh a, [hCGB]
	push af
	ldh a, [hSystemBooted]
	push af
	xor a
	ld hl, HRAM_Begin
	ld bc, HRAM_End - HRAM_Begin
	call ByteFill
	pop af
	ldh [hSystemBooted], a
	pop af
	ldh [hCGB], a

	call ClearWRAM
	ld a, 1
	ldh [rSVBK], a
	call ClearVRAM
	call ClearSprites
	call ClearsScratch

    ld a, $C3 ; a jump instruction
    ldh [hShortFarCallJump], a
    ;xor a
    ;ldh [hShortFarCallDepth], a

	ld a, BANK(WriteOAMDMACodeToHRAM) ; aka BANK(GameInit)
	rst Bankswitch

	call WriteOAMDMACodeToHRAM
    farcall Init2_far

	jp GameInit

ClearVRAM::
; Wipe VRAM banks 0 and 1
    farcall ClearVRAM_far
	ret

ClearWRAM::
; Wipe swappable WRAM banks (1-7)
; Assumes CGB or AGB
    farcall ClearWRAM_far
	ret

ClearsScratch::
; Wipe the first 32 bytes of sScratch
    farcall ClearsScratch_far
	ret
