InitDisplayForHallOfFame:
	predef ClearBGPalettes
	call ClearTilemap
	predef ClearSprites
	call DisableLCD
	call LoadStandardFont
	call LoadFontsBattleExtra
	hlbgcoord 0, 0
	ld bc, vBGMap1 - vBGMap0
	ld a, " "
	predef ByteFill
	hlcoord 0, 0, wAttrmap
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	xor a
	predef ByteFill
	xor a
	ldh [hSCY], a
	ldh [hSCX], a
	call EnableLCD
	ld hl, .SavingRecordText
	call PrintText
	call WaitBGMap2
	call SetPalettes
	ret

.SavingRecordText:
	text_far _SavingRecordText
	text_end

InitDisplayForRedCredits:
	predef ClearBGPalettes
	call ClearTilemap
	predef ClearSprites
	call DisableLCD
	call LoadStandardFont
	call LoadFontsBattleExtra
	hlbgcoord 0, 0
	ld bc, vBGMap1 - vBGMap0
	ld a, " "
	predef ByteFill
	hlcoord 0, 0, wAttrmap
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	xor a
	predef ByteFill
	ld hl, wBGPals1
	ld c, 4 tiles
.load_white_palettes
	ld a, LOW(PALRGB_WHITE)
	ld [hli], a
	ld a, HIGH(PALRGB_WHITE)
	ld [hli], a
	dec c
	jr nz, .load_white_palettes
	xor a
	ldh [hSCY], a
	ldh [hSCX], a
	call EnableLCD
	call WaitBGMap2
	call SetPalettes
	ret

ResetDisplayBetweenHallOfFameMons:
	ldh a, [rSVBK]
	push af
	ld a, BANK(wDecompressScratch)
	ldh [rSVBK], a
	ld hl, wDecompressScratch
	ld bc, wScratchAttrmap - wDecompressScratch
	ld a, " "
	predef ByteFill
	hlbgcoord 0, 0
	ld de, wDecompressScratch
	ld b, 0
	ld c, 4 tiles
	call Request2bpp
	pop af
	ldh [rSVBK], a
	ret
