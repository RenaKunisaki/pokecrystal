; Audio interfaces in home bank.

; these are just overly complicated far calls.
InitSound::
    farcall _InitSound
    ret

UpdateSound::
	push hl
	push de
	push bc
	push af

	farcall _UpdateSound

pop_af_bc_de_hl_ret::
	pop af
	pop bc
	pop de
	pop hl
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
	;farcall PlayMusic_far
	;ret
    push af

    ld a, e
    and a
    jr z, .nomusic

    farcall _PlayMusic
    jr .end

.nomusic
    farcall _InitSound

.end
    pop af
    ret

PlayMusic2::
; Stop playing music, then play music de.
	push de
	ld de, MUSIC_NONE
	farcall _PlayMusic
	call DelayFrame
	pop de
	farcall _PlayMusic
    ret

PlayCry::
; Play cry de.

	push hl
	push de
	push bc
	push af

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

	pop af
	pop bc
	pop de
	pop hl
	ret

PlaySFX::
; Play sound effect de.
; Sound effects are ordered by priority (highest to lowest)

	push hl
	push de
	push bc
	push af

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
	pop af
	pop bc
	pop de
	pop hl
	ret

WaitPlaySFX::
	call WaitSFX
	call PlaySFX
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

FadeOutToMusic:: ; unreferenced
	ld a, 4
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
	;farcall FadeToMapMusic_far
	;ret
    push hl
	push de
	push bc
	push af

	call GetMapMusic_MaybeSpecial
	ld a, [wMapMusic]
	cp e
	jr z, .done

	ld a, 8
	ld [wMusicFade], a
	ld a, e
	ld [wMusicFadeID], a
	ld a, d
	ld [wMusicFadeID + 1], a
	ld a, e
	ld [wMapMusic], a

.done
	jp pop_af_bc_de_hl_ret

PlayMapMusic::
	;farcall PlayMapMusic_far
	;ret
    push hl
	push de
	push bc
	push af

	call GetMapMusic_MaybeSpecial
	ld a, [wMapMusic]
	cp e
	jp z, pop_af_bc_de_hl_ret

	push de
	ld de, MUSIC_NONE
	call PlayMusic
	call DelayFrame
	pop de
	ld a, e
	ld [wMapMusic], a
	call PlayMusic
    jp pop_af_bc_de_hl_ret

PlayMapMusicBike::
; If the player's on a bike, play the bike music instead of the map music
	;farcall PlayMapMusicBike_far
	;ret
    push hl
	push de
	push bc
	push af

	xor a
	ld [wDontPlayMapMusicOnReload], a
	ld de, MUSIC_BICYCLE
	ld a, [wPlayerState]
	cp PLAYER_BIKE
	jr z, .play
	call GetMapMusic_MaybeSpecial
.play
	push de
	ld de, MUSIC_NONE
	call PlayMusic
	call DelayFrame
	pop de

	ld a, e
	ld [wMapMusic], a
	call PlayMusic
    jp pop_af_bc_de_hl_ret

TryRestartMapMusic::
	;farcall TryRestartMapMusic_far
	;ret
    ld a, [wDontPlayMapMusicOnReload]
	and a
	jr z, RestartMapMusic
	xor a
	ld [wMapMusic], a
	ld de, MUSIC_NONE
	call PlayMusic
	call DelayFrame
	xor a
	ld [wDontPlayMapMusicOnReload], a
	ret

RestartMapMusic::
	;farcall RestartMapMusic_far
	;ret
    push hl
	push de
	push bc
	push af
	ld de, MUSIC_NONE
	call PlayMusic
	call DelayFrame
	ld a, [wMapMusic]
	ld e, a
	ld d, 0
	call PlayMusic
	jp pop_af_bc_de_hl_ret

SpecialMapMusic::
    ;farcall SpecialMapMusic_far
	;ret
    ld a, [wPlayerState]
	cp PLAYER_SURF
	jr z, .surf
	cp PLAYER_SURF_PIKA
	jr z, .surf

	ld a, [wStatusFlags2]
	bit STATUSFLAGS2_BUG_CONTEST_TIMER_F, a
	jr nz, .contest

.no
	and a
	ret

.surf
	ld de, MUSIC_SURF
	scf
	ret

.contest
	ld a, [wMapGroup]
	cp GROUP_ROUTE_35_NATIONAL_PARK_GATE
	jr nz, .no
	ld a, [wMapNumber]
	cp MAP_ROUTE_35_NATIONAL_PARK_GATE
	jr z, .ranking
	cp MAP_ROUTE_36_NATIONAL_PARK_GATE
	jr nz, .no

.ranking
	ld de, MUSIC_BUG_CATCHING_CONTEST_RANKING
	scf
	ret

GetMapMusic_MaybeSpecial::
	call SpecialMapMusic
	ret c
	call GetMapMusic
	ret

CheckSFX::
; Return carry if any SFX channels are active.
	;farcall CheckSFX_far
	;ret
    ld a, [wChannel5Flags1]
	bit 0, a
	jr nz, .playing
	ld a, [wChannel6Flags1]
	bit 0, a
	jr nz, .playing
	ld a, [wChannel7Flags1]
	bit 0, a
	jr nz, .playing
	ld a, [wChannel8Flags1]
	bit 0, a
	jr nz, .playing
	and a
	ret
.playing
	scf
	ret

TerminateExpBarSound::
	;farcall TerminateExpBarSound_far
	;ret
    xor a
	ld [wChannel5Flags1], a
	ldh [rNR10], a
	ldh [rNR11], a
	ldh [rNR12], a
	ldh [rNR13], a
	ldh [rNR14], a
setPitchSweepAndRet:
    ld [wPitchSweep], a
	ret

ChannelsOff::
; Quickly turn off music channels
	;farcall ChannelsOff_far
	;ret
    xor a
	ld [wChannel1Flags1], a
	ld [wChannel2Flags1], a
	ld [wChannel3Flags1], a
	ld [wChannel4Flags1], a
    jr setPitchSweepAndRet

SFXChannelsOff::
; Quickly turn off sound effect channels
	;farcall SFXChannelsOff_far
	;ret
    xor a
	ld [wChannel5Flags1], a
	ld [wChannel6Flags1], a
	ld [wChannel7Flags1], a
	ld [wChannel8Flags1], a
	jr setPitchSweepAndRet
