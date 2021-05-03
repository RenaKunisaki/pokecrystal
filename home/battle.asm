GetPartyParamLocation::
; Get the location of parameter a from wCurPartyMon in hl
	farcall GetPartyParamLocation_far
	ret

GetPartyLocation::
; Add the length of a PartyMon struct to hl a times.
	ld bc, PARTYMON_STRUCT_LENGTH
	jp AddNTimes

UserPartyAttr::
	farcall UserPartyAttr_far
    ret

OpponentPartyAttr::
	farcall OpponentPartyAttr_far
    ret

BattlePartyAttr::
; Get attribute a from the party struct of the active battle mon.
	farcall BattlePartyAttr_far
	ret

OTPartyAttr::
; Get attribute a from the party struct of the active enemy mon.
	farcall OTPartyAttr_far
	ret

ResetDamage::
	xor a
	ld [wCurDamage], a
	ld [wCurDamage + 1], a
	ret

SetPlayerTurn::
	xor a
_setTurn:
	ldh [hBattleTurn], a
	ret

SetEnemyTurn::
	ld a, 1
	jr _setTurn

UpdateOpponentInParty::
	ldh a, [hBattleTurn]
	and a
	jr z, UpdateEnemyMonInParty
	jr UpdateBattleMonInParty

UpdateUserInParty::
	ldh a, [hBattleTurn]
	and a
	jr z, UpdateBattleMonInParty
	jr UpdateEnemyMonInParty

UpdateBattleMonInParty::
; Update level, status, current HP

	ld a, [wCurBattleMon]

UpdateBattleMon::
	ld hl, wPartyMon1Level
	call GetPartyLocation

	ld d, h
	ld e, l
	ld hl, wBattleMonLevel
	ld bc, wBattleMonMaxHP - wBattleMonLevel
	jp CopyBytes

UpdateEnemyMonInParty::
; Update level, status, current HP

; No wildmons.
	ld a, [wBattleMode]
	dec a
	ret z

	ld a, [wCurOTMon]
	ld hl, wOTPartyMon1Level
	call GetPartyLocation

	ld d, h
	ld e, l
	ld hl, wEnemyMonLevel
	ld bc, wEnemyMonMaxHP - wEnemyMonLevel
	jp CopyBytes

RefreshBattleHuds::
	call UpdateBattleHuds
	ld c, 3
	call DelayFrames
	jp WaitBGMap

UpdateBattleHuds::
	farcall UpdatePlayerHUD
	farcall UpdateEnemyHUD
	ret

INCLUDE "home/battle_vars.asm"

; why is this here?
FarCopyRadioText::
	inc hl
	ldh a, [hROMBank]
	push af
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ldh [hROMBank], a
	ld [MBC3RomBank], a
    ; why use a here? you did the same above in reverse...
	;ld a, e
	;ld l, a
    ld l, e
	;ld a, d
	;ld h, a
    ld h, d
	ld de, wRadioText
	ld bc, 2 * SCREEN_WIDTH
	call CopyBytes
	pop af
	ldh [hROMBank], a
	ld [MBC3RomBank], a
	ret

MobileTextBorder::
	; For mobile link battles only.
	farcall MobileTextBorder_far
	ret

BattleTextbox::
; Open a textbox and print text at hl.
	push hl
	call SpeechTextbox
	call MobileTextBorder
	call UpdateSprites
	call ApplyTilemap
	pop hl
	call PrintTextboxText
	ret

StdBattleTextbox::
; Open a textbox and print battle text at 20:hl.

	ldh a, [hROMBank]
	push af

	ld a, BANK(BattleText)
	rst Bankswitch

	call BattleTextbox

	pop af
	rst Bankswitch
	ret

GetBattleAnimPointer::
	ld a, BANK(BattleAnimations)
	rst Bankswitch

	ld a, [hli]
	ld [wBattleAnimAddress], a
	ld a, [hl]
	ld [wBattleAnimAddress + 1], a

	; ClearBattleAnims is the only function that calls this...
	ld a, BANK(ClearBattleAnims)
	rst Bankswitch

	ret

GetBattleAnimByte::
	push hl
	push de

	ld hl, wBattleAnimAddress
	ld e, [hl]
	inc hl
	ld d, [hl]

	ld a, BANK(BattleAnimations)
	rst Bankswitch

	ld a, [de]
	ld [wBattleAnimByte], a
	inc de

	ld a, BANK(BattleAnimCommands)
	rst Bankswitch

	ld [hl], d
	dec hl
	ld [hl], e

	pop de
	pop hl

	ld a, [wBattleAnimByte]
	ret

PushLYOverrides::
	farcall PushLYOverrides_far
	ret
