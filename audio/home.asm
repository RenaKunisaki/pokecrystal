; move some audio functions out of home bank.

PlayMusic_far::
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


WaitSFX_far::
; infinite loop until sfx is done playing

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


IsSFXPlaying_far::
; Return carry if no sound effect is playing.
; The inverse of CheckSFX.
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

FadeToMapMusic_far::
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

PlayMapMusic_far::
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
	call PlayMusic_far
	call DelayFrame
	pop de
	ld a, e
	ld [wMapMusic], a
	call PlayMusic_far
    jp pop_af_bc_de_hl_ret


PlayMapMusicBike_far::
; If the player's on a bike, play the bike music instead of the map music
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
	call PlayMusic_far
	call DelayFrame
	pop de

	ld a, e
	ld [wMapMusic], a
	call PlayMusic_far
    jp pop_af_bc_de_hl_ret


TryRestartMapMusic_far::
	ld a, [wDontPlayMapMusicOnReload]
	and a
	jr z, RestartMapMusic_far
	xor a
	ld [wMapMusic], a
	ld de, MUSIC_NONE
	call PlayMusic_far
	call DelayFrame
	xor a
	ld [wDontPlayMapMusicOnReload], a
	ret

RestartMapMusic_far::
	push hl
	push de
	push bc
	push af
	ld de, MUSIC_NONE
	call PlayMusic_far
	call DelayFrame
	ld a, [wMapMusic]
	ld e, a
	ld d, 0
	call PlayMusic_far
	jp pop_af_bc_de_hl_ret


SpecialMapMusic_far::
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

;.bike ; unreferenced
;	ld de, MUSIC_BICYCLE
;	scf
;	ret

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


CheckSFX_far::
; Return carry if any SFX channels are active.
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

TerminateExpBarSound_far::
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

ChannelsOff_far::
; Quickly turn off music channels
	xor a
	ld [wChannel1Flags1], a
	ld [wChannel2Flags1], a
	ld [wChannel3Flags1], a
	ld [wChannel4Flags1], a
    jr setPitchSweepAndRet

SFXChannelsOff_far::
; Quickly turn off sound effect channels
	xor a
	ld [wChannel5Flags1], a
	ld [wChannel6Flags1], a
	ld [wChannel7Flags1], a
	ld [wChannel8Flags1], a
	jr setPitchSweepAndRet
