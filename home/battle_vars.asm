GetBattleVar::
	farcall GetBattleVar_far
	ret

GetBattleVarAddr::
; Get variable from pair a, depending on whose turn it is.
; There are 21 variable pairs.
	farcall GetBattleVarAddr_far
	ret
