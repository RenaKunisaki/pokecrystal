ClearSprites::
; Erase OAM data
; XXX why doesn't this work when moved to ex_home?
	ld hl, wVirtualOAM
	ld b, wVirtualOAMEnd - wVirtualOAM
	xor a
.loop
	ld [hli], a
	dec b
	jr nz, .loop
	ret

HideSprites::
; Set all OAM y-positions to 160 to hide them offscreen
	farcall HideSprites_far
	ret
