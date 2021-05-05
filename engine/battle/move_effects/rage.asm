BattleCommand_Rage:
; rage
	ld a, BATTLE_VARS_SUBSTATUS4
	predef GetBattleVarAddr
	set SUBSTATUS_RAGE, [hl]
	ret
