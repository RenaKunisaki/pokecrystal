; Audio interfaces in home bank.

; these are just overly complicated far calls.
InitSound::
    farcall _InitSound
    ret

UpdateSound::
    pushm hl, de, bc, af

	farcall _UpdateSound

pop_af_bc_de_hl_ret::
    popm af, bc, de, hl
	ret

_LoadMusicByte::
; [wCurMusicByte] = [a:de]
	ldh [hROMBank], a
	ld [MBC3RomBank], a

	ld a, [de]
	ld [wCurMusicByte], a
	ld a, BANK(LoadMusicByte)

	ldh [hROMBank], a
	ld [MBC3RomBank], a
	ret

PlayMusic::
; Play music de.
	farcall PlayMusic_far
	ret

PlayMusic2::
; Stop playing music, then play music de.
	push de
	ld de, MUSIC_NONE
	farcall _PlayMusic
	predef DelayFrame
	pop de
	farcall _PlayMusic
    ret

PlayCry::
; Play cry de.

    pushm hl, de, bc, af

	ldh a, [hROMBank]
	push af

	; Cries are stuck in one bank.
	ld a, BANK(PokemonCries)
	ldh [hROMBank], a
	ld [MBC3RomBank], a

	ld hl, PokemonCries
rept MON_CRY_LENGTH
	add hl, de
endr

	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl

	ld a, [hli]
	ld [wCryPitch], a
	ld a, [hli]
	ld [wCryPitch + 1], a
	ld a, [hli]
	ld [wCryLength], a
	ld a, [hl]
	ld [wCryLength + 1], a

	ld a, BANK(_PlayCry)
	ldh [hROMBank], a
	ld [MBC3RomBank], a

	call _PlayCry

	pop af
	ldh [hROMBank], a
	ld [MBC3RomBank], a

	jp pop_af_bc_de_hl_ret

PlaySFX::
; Play sound effect de.
; Sound effects are ordered by priority (highest to lowest)

    pushm hl, de, bc, af

	; Is something already playing?
	call CheckSFX
	jr nc, .play

	; Does it have priority?
	ld a, [wCurSFX]
	cp e
	jr c, .done

.play
	ldh a, [hROMBank]
	push af
	ld a, BANK(_PlaySFX)
	ldh [hROMBank], a
	ld [MBC3RomBank], a

	ld a, e
	ld [wCurSFX], a
	call _PlaySFX

	pop af
	ldh [hROMBank], a
	ld [MBC3RomBank], a

.done
    jp pop_af_bc_de_hl_ret

WaitPlaySFX::
	predef WaitSFX
	predef PlaySFX
	ret

WaitSFX::
; infinite loop until sfx is done playing
    ;farcall WaitSFX_far
	;ret
    push hl

.wait
	ld hl, wChannel5Flags1
	bit 0, [hl]
	jr nz, .wait
	ld hl, wChannel6Flags1
	bit 0, [hl]
	jr nz, .wait
	ld hl, wChannel7Flags1
	bit 0, [hl]
	jr nz, .wait
	ld hl, wChannel8Flags1
	bit 0, [hl]
	jr nz, .wait

	pop hl
	ret

IsSFXPlaying::
; Return carry if no sound effect is playing.
; The inverse of CheckSFX.
	;farcall IsSFXPlaying_far
	;ret
    push hl

	ld hl, wChannel5Flags1
	bit 0, [hl]
	jr nz, .playing
	ld hl, wChannel6Flags1
	bit 0, [hl]
	jr nz, .playing
	ld hl, wChannel7Flags1
	bit 0, [hl]
	jr nz, .playing
	ld hl, wChannel8Flags1
	bit 0, [hl]
	jr nz, .playing

	pop hl
	scf
	ret

.playing
	pop hl
	and a
	ret

MaxVolume::
	ld a, MAX_VOLUME
_storeVolume:
	ld [wVolume], a
	ret

LowVolume::
	ld a, $33 ; 50%
    jr _storeVolume

MinVolume::
	xor a
    jr _storeVolume

;FadeOutToMusic:: ; unreferenced
;	ld a, 4
_setMusicFade:
	ld [wMusicFade], a
	ret

FadeInToMusic::
	ld a, 4 | (1 << MUSIC_FADE_IN_F)
    jr _setMusicFade

SkipMusic::
; Skip a frames of music.
.loop
	and a
	ret z
	dec a
	call UpdateSound
	jr .loop

FadeToMapMusic::
	farcall FadeToMapMusic_far
	ret

PlayMapMusic::
	farcall PlayMapMusic_far
	ret

PlayMapMusicBike::
; If the player's on a bike, play the bike music instead of the map music
	farcall PlayMapMusicBike_far
	ret

TryRestartMapMusic::
	farcall TryRestartMapMusic_far
	ret

RestartMapMusic::
	farcall RestartMapMusic_far
	ret

SpecialMapMusic::
    farcall SpecialMapMusic_far
	ret

GetMapMusic_MaybeSpecial::
	farcall SpecialMapMusic_far
	ret c
	call GetMapMusic
	ret

CheckSFX::
; Return carry if any SFX channels are active.
	farcall CheckSFX_far
	ret

TerminateExpBarSound::
	farcall TerminateExpBarSound_far
	ret

ChannelsOff::
; Quickly turn off music channels
	farcall ChannelsOff_far
	ret

SFXChannelsOff::
; Quickly turn off sound effect channels
	farcall SFXChannelsOff_far
	ret
