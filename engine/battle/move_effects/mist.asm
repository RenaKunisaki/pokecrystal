BattleCommand_Mist:
; mist

	ld a, BATTLE_VARS_SUBSTATUS4
	predef GetBattleVarAddr
	bit SUBSTATUS_MIST, [hl]
	jr nz, .already_mist
	set SUBSTATUS_MIST, [hl]
	call AnimateCurrentMove
	ld hl, MistText
	jp StdBattleTextbox

.already_mist
	call AnimateFailedMove
	jp PrintButItFailed
