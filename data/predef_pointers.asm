; Predef routines can be used with the "predef" and "predef_jump" macros.
; This preserves registers bc, de, hl and f.

add_predef: MACRO
\1Predef::
	dab \1
ENDM

PredefPointers::
	add_predef AddTempmonToParty
	add_predef AnimateFrontpic
	add_predef AnimateHPBar
	add_predef CalcMonStatC
	add_predef CalcMonStats
	add_predef CanLearnTMHMMove
	add_predef CheckPlayerPartyForFitMon
	add_predef CheckTypeMatchup
	add_predef ComputeHPBarPixels
	add_predef ConvertMon_1to2
	add_predef CopyMonToTempMon
	add_predef DecompressGet2bpp
	add_predef DoBattleTransition
	add_predef DrawEnemyHP
	add_predef DrawPlayerHP
	add_predef DummyPredef1
	add_predef DummyPredef2F
	add_predef DummyPredef3A
	add_predef DummyPredef35
	add_predef DummyPredef36
	add_predef DummyPredef38
	add_predef DummyPredef39
	add_predef EvolveAfterBattle
	add_predef FillInExpBar
	add_predef FillMoves
	add_predef FillPP
	add_predef GetAnimatedFrontpic
	add_predef GetBattleMonBackpic
	add_predef GetEnemyMonFrontpic
	add_predef GetGender
	add_predef GetMonBackpic
	add_predef GetMonFrontpic
	add_predef GetTMHMMove
	add_predef GetTrainerPic
	add_predef GetTypeName
	add_predef GetUnownLetter
	add_predef GiveEgg
	add_predef HOF_AnimateFrontpic
	add_predef HealParty ; this is both a special and a predef
	add_predef InitSGBBorder
	add_predef LearnLevelMoves
	add_predef LearnMove
	add_predef LinkTextboxAtHL
	add_predef ListMovePP
	add_predef ListMoves
	add_predef LoadMonAnimation
	add_predef LoadPoisonBGPals
	add_predef LoadSGBLayout
	add_predef NewPokedexEntry
	add_predef PartyMonItemName
	add_predef PlaceGraphic
	add_predef PlaceNonFaintStatus
	add_predef PlaceStatusString
	add_predef PlayBattleAnim
	add_predef Pokedex_GetArea
	add_predef PrintMonTypes
	add_predef PrintMoveDescription
	add_predef PrintMoveType
	add_predef PrintTempMonStats
	add_predef PrintType
	add_predef SendGetMonIntoFromBox
	add_predef SendMonIntoBox
	add_predef SmallFarFlagAction
	add_predef StartBattle
	add_predef StatsScreenInit
	add_predef TradeAnimation
	add_predef TradeAnimationPlayer2
	add_predef TryAddMonToParty
	add_predef Unused_AnimateMon_Slow_Normal
	add_predef Unused_CheckShininess
	add_predef Unused_HOF_AnimateAlignedFrontpic
	add_predef Unused_PlaceEnemyHPLevel
	add_predef UpdateEnemyHUD
	add_predef UpdatePlayerHUD
    ; 0x49 items
	dbw -1, DummyEndPredef ; pointless
