BattleCommand_MirrorMove:
; mirrormove

	call ClearLastMove

	ld a, BATTLE_VARS_MOVE
	predef GetBattleVarAddr

	ld a, BATTLE_VARS_LAST_COUNTER_MOVE_OPP
	predef GetBattleVar
	and a
	jr z, .failed

	call CheckUserMove
	jr nz, .use

.failed
	call AnimateFailedMove

	ld hl, MirrorMoveFailedText
	call StdBattleTextbox
	jp EndMoveEffect

.use
	ld a, b
	ld [hl], a
	ld [wNamedObjectIndex], a

	push af
	ld a, BATTLE_VARS_MOVE_ANIM
	predef GetBattleVarAddr
	ld d, h
	ld e, l
	pop af

	dec a
	call GetMoveData
	call GetMoveName
	call CopyName1
	call CheckUserIsCharging
	jr nz, .done

	ld a, [wBattleAnimParam]
	push af
	call BattleCommand_LowerSub
	pop af
	ld [wBattleAnimParam], a

.done
	call BattleCommand_MoveDelay
	jp ResetTurn
