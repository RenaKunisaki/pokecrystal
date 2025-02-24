InsertPokemonIntoBox:
	ld a, BANK(sBoxCount)
	predef OpenSRAM
	ld hl, sBoxCount
	call InsertSpeciesIntoBoxOrParty
	ld a, [sBoxCount]
	dec a
	ld [wNextBoxOrPartyIndex], a
	ld hl, sBoxMonNicknames
	ld bc, MON_NAME_LENGTH
	ld de, wBufferMonNickname
	call InsertDataIntoBoxOrParty
	ld a, [sBoxCount]
	dec a
	ld [wNextBoxOrPartyIndex], a
	ld hl, sBoxMonOTs
	ld bc, NAME_LENGTH
	ld de, wBufferMonOT
	call InsertDataIntoBoxOrParty
	ld a, [sBoxCount]
	dec a
	ld [wNextBoxOrPartyIndex], a
	ld hl, sBoxMons
	ld bc, BOXMON_STRUCT_LENGTH
	ld de, wBufferMon
	call InsertDataIntoBoxOrParty
	ld hl, wBufferMonMoves
	ld de, wTempMonMoves
	ld bc, NUM_MOVES
	predef CopyBytes
	ld hl, wBufferMonPP
	ld de, wTempMonPP
	ld bc, NUM_MOVES
	predef CopyBytes
	ld a, [wCurPartyMon]
	ld b, a
	farcall RestorePPOfDepositedPokemon
	jp CloseSRAM

InsertPokemonIntoParty:
	ld hl, wPartyCount
	call InsertSpeciesIntoBoxOrParty
	ld a, [wPartyCount]
	dec a
	ld [wNextBoxOrPartyIndex], a
	ld hl, wPartyMonNicknames
	ld bc, MON_NAME_LENGTH
	ld de, wBufferMonNickname
	call InsertDataIntoBoxOrParty
	ld a, [wPartyCount]
	dec a
	ld [wNextBoxOrPartyIndex], a
	ld hl, wPartyMonOTs
	ld bc, NAME_LENGTH
	ld de, wBufferMonOT
	call InsertDataIntoBoxOrParty
	ld a, [wPartyCount]
	dec a
	ld [wNextBoxOrPartyIndex], a
	ld hl, wPartyMons
	ld bc, PARTYMON_STRUCT_LENGTH
	ld de, wBufferMon
	call InsertDataIntoBoxOrParty
	ret

InsertSpeciesIntoBoxOrParty:
	inc [hl]
	inc hl
	ld a, [wCurPartyMon]
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [wCurPartySpecies]
	ld c, a
.loop
	ld a, [hl]
	ld [hl], c
	inc hl
	inc c
	ld c, a
	jr nz, .loop
	ret

InsertDataIntoBoxOrParty:
	push de
	push hl
	push bc
	ld a, [wNextBoxOrPartyIndex]
	dec a
	predef AddNTimes
	push hl
	add hl, bc
	ld d, h
	ld e, l
	pop hl
.loop
	push bc
	ld a, [wNextBoxOrPartyIndex]
	ld b, a
	ld a, [wCurPartyMon]
	cp b
	pop bc
	jr z, .insert
	push hl
	push de
	push bc
	predef CopyBytes
	pop bc
	pop de
	pop hl
	push hl
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	pop de
	ld a, [wNextBoxOrPartyIndex]
	dec a
	ld [wNextBoxOrPartyIndex], a
	jr .loop

.insert
	pop bc
	pop hl
	ld a, [wCurPartyMon]
	predef AddNTimes
	ld d, h
	ld e, l
	pop hl
	predef CopyBytes
	ret
