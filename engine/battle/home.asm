; move some battle functions out of home bank.

GetBattleVar_far::
	push hl
	call GetBattleVarAddr_far
	pop hl
	ret

GetBattleVarAddr_far::
; Get variable from pair a, depending on whose turn it is.
; There are 21 variable pairs.
	push bc

	ld hl, BattleVarPairs
	ld c, a
	ld b, 0
	add hl, bc
	add hl, bc

	ld a, [hli]
	ld h, [hl]
	ld l, a

; Enemy turn uses the second byte instead.
; This lets battle variable calls be side-neutral.
	ldh a, [hBattleTurn]
	and a
	jr z, .getvar
	inc hl

.getvar
; var id
	ld a, [hl]
	ld c, a
	ld b, 0

	ld hl, BattleVarLocations
	add hl, bc
	add hl, bc

	ld a, [hli]
	ld h, [hl]
	ld l, a

	ld a, [hl]

	pop bc
	ret

BattleVarPairs:
; entries correspond to BATTLE_VARS_* constants
	table_width 2, BattleVarPairs
	dw .Substatus1
	dw .Substatus2
	dw .Substatus3
	dw .Substatus4
	dw .Substatus5
	dw .Substatus1Opp
	dw .Substatus2Opp
	dw .Substatus3Opp
	dw .Substatus4Opp
	dw .Substatus5Opp
	dw .Status
	dw .StatusOpp
	dw .MoveAnim
	dw .MoveEffect
	dw .MovePower
	dw .MoveType
	dw .CurMove
	dw .LastCounter
	dw .LastCounterOpp
	dw .LastMove
	dw .LastMoveOpp
	assert_table_length NUM_BATTLE_VARS

;                   player                 enemy
.Substatus1:     db PLAYER_SUBSTATUS_1,    ENEMY_SUBSTATUS_1
.Substatus1Opp:  db ENEMY_SUBSTATUS_1,     PLAYER_SUBSTATUS_1
.Substatus2:     db PLAYER_SUBSTATUS_2,    ENEMY_SUBSTATUS_2
.Substatus2Opp:  db ENEMY_SUBSTATUS_2,     PLAYER_SUBSTATUS_2
.Substatus3:     db PLAYER_SUBSTATUS_3,    ENEMY_SUBSTATUS_3
.Substatus3Opp:  db ENEMY_SUBSTATUS_3,     PLAYER_SUBSTATUS_3
.Substatus4:     db PLAYER_SUBSTATUS_4,    ENEMY_SUBSTATUS_4
.Substatus4Opp:  db ENEMY_SUBSTATUS_4,     PLAYER_SUBSTATUS_4
.Substatus5:     db PLAYER_SUBSTATUS_5,    ENEMY_SUBSTATUS_5
.Substatus5Opp:  db ENEMY_SUBSTATUS_5,     PLAYER_SUBSTATUS_5
.Status:         db PLAYER_STATUS,         ENEMY_STATUS
.StatusOpp:      db ENEMY_STATUS,          PLAYER_STATUS
.MoveAnim:       db PLAYER_MOVE_ANIMATION, ENEMY_MOVE_ANIMATION
.MoveEffect:     db PLAYER_MOVE_EFFECT,    ENEMY_MOVE_EFFECT
.MovePower:      db PLAYER_MOVE_POWER,     ENEMY_MOVE_POWER
.MoveType:       db PLAYER_MOVE_TYPE,      ENEMY_MOVE_TYPE
.CurMove:        db PLAYER_CUR_MOVE,       ENEMY_CUR_MOVE
.LastCounter:    db PLAYER_COUNTER_MOVE,   ENEMY_COUNTER_MOVE
.LastCounterOpp: db ENEMY_COUNTER_MOVE,    PLAYER_COUNTER_MOVE
.LastMove:       db PLAYER_LAST_MOVE,      ENEMY_LAST_MOVE
.LastMoveOpp:    db ENEMY_LAST_MOVE,       PLAYER_LAST_MOVE

BattleVarLocations:
; entries correspond to PLAYER_* and ENEMY_* constants
	table_width 2 + 2, BattleVarLocations
	dw wPlayerSubStatus1,          wEnemySubStatus1
	dw wPlayerSubStatus2,          wEnemySubStatus2
	dw wPlayerSubStatus3,          wEnemySubStatus3
	dw wPlayerSubStatus4,          wEnemySubStatus4
	dw wPlayerSubStatus5,          wEnemySubStatus5
	dw wBattleMonStatus,           wEnemyMonStatus
	dw wPlayerMoveStructAnimation, wEnemyMoveStructAnimation
	dw wPlayerMoveStructEffect,    wEnemyMoveStructEffect
	dw wPlayerMoveStructPower,     wEnemyMoveStructPower
	dw wPlayerMoveStructType,      wEnemyMoveStructType
	dw wCurPlayerMove,             wCurEnemyMove
	dw wLastPlayerCounterMove,     wLastEnemyCounterMove
	dw wLastPlayerMove,            wLastEnemyMove
	assert_table_length NUM_BATTLE_VAR_LOCATION_PAIRS


; from battle.asm
GetPartyParamLocation_far::
; Get the location of parameter a from wCurPartyMon in hl
	push bc
	ld hl, wPartyMons
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [wCurPartyMon]
	call GetPartyLocation
	pop bc
	ret


UserPartyAttr_far::
	push af
	ldh a, [hBattleTurn]
	and a
	jr nz, .ot
	pop af
	jr BattlePartyAttr_far
.ot
	pop af
	jr OTPartyAttr_far

OpponentPartyAttr_far::
	push af
	ldh a, [hBattleTurn]
	and a
	jr z, .ot
	pop af
	jr BattlePartyAttr_far
.ot
	pop af
	jr OTPartyAttr_far

BattlePartyAttr_far::
; Get attribute a from the party struct of the active battle mon.
	push bc
	ld c, a
	ld b, 0
	ld hl, wPartyMons
	add hl, bc
	ld a, [wCurBattleMon]
	call GetPartyLocation
	pop bc
	ret

OTPartyAttr_far::
; Get attribute a from the party struct of the active enemy mon.
	push bc
	ld c, a
	ld b, 0
	ld hl, wOTPartyMon1Species
	add hl, bc
	ld a, [wCurOTMon]
	call GetPartyLocation
	pop bc
	ret

MobileTextBorder_far::
	; For mobile link battles only.
	ld a, [wLinkMode]
	cp LINK_MOBILE
	ret c

	; Draw a cell phone icon at the
	; top right corner of the border.
	hlcoord 19, 12
	ld [hl], $5e ; top
	hlcoord 19, 13
	ld [hl], $5f ; bottom
	ret

; why is this here?
PushLYOverrides_far::
	ldh a, [hLCDCPointer]
	and a
	ret z

	ld a, LOW(wLYOverridesBackup)
	ld [wRequested2bppSource], a
	ld a, HIGH(wLYOverridesBackup)
	ld [wRequested2bppSource + 1], a

	ld a, LOW(wLYOverrides)
	ld [wRequested2bppDest], a
	ld a, HIGH(wLYOverrides)
	ld [wRequested2bppDest + 1], a

	ld a, (wLYOverridesEnd - wLYOverrides) / LEN_2BPP_TILE
	ld [wRequested2bppSize], a
	ret
