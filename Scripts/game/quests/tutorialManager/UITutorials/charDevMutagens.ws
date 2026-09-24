/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state CharDevMutagens in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var DESCRIPTION, SELECT_TAB, EQUIP, BONUSES, MATCH_SKILL_COLOR, MULTIPLE_SKILLS, WRONG_COLOR, POTIONS, MUTAGENS_JOURNAL : name;
	private var isClosing : bool;
	private var savedEquippedSkills : array<STutorialSavedSkill>;					
	
		default DESCRIPTION 		= 'TutorialMutagenDescription';
		default SELECT_TAB			= 'TutorialMutagenSelectTab';
		default EQUIP				= 'TutorialMutagenEquip';
		default BONUSES				= 'TutorialMutagenBonuses';
		default MATCH_SKILL_COLOR	= 'TutorialMutagenMatchSkillColor';
		default MULTIPLE_SKILLS		= 'TutorialMutagenMultipleSkills';
		default WRONG_COLOR			= 'TutorialMutagenWrongColor';
		default POTIONS				= 'TutorialMutagenPotions';
		default MUTAGENS_JOURNAL	= 'TutorialJournalCharDevMutagens';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		ShowHint(DESCRIPTION, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Input);		
		
		theGame.GetTutorialSystem().ActivateJournalEntry(MUTAGENS_JOURNAL);
	}
			
	event OnLeaveState( nextStateName : name )
	{		
		isClosing = true;
		
		CloseStateHint(DESCRIPTION);
		CloseStateHint(SELECT_TAB);
		CloseStateHint(EQUIP);
		CloseStateHint(BONUSES);
		CloseStateHint(MATCH_SKILL_COLOR);
		CloseStateHint(MULTIPLE_SKILLS);
		CloseStateHint(WRONG_COLOR);
		CloseStateHint(POTIONS);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(DESCRIPTION);
		
		GetWitcherPlayer().TutorialMutagensCleanupTempSkills(savedEquippedSkills);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		var highlights : array< STutorialHighlight >;
		
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == DESCRIPTION)
		{
			ShowHint(SELECT_TAB, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Infinite, GetHighlightCharDevTabMutagens() );
		}
		else if(hintName == EQUIP)
		{
			savedEquippedSkills = GetWitcherPlayer().TutorialMutagensUnequipPlayerSkills();
			
			ShowHint(BONUSES, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Input, GetHighlightCharDevMutagenBonusString() );
		}
		else if(hintName == BONUSES)
		{
			highlights = GetHighlightCharDevMutagenBonusString();
			AddHighlight( highlights, .568f, .14f, .08f, .15f );
			
			GetWitcherPlayer().TutorialMutagensEquipOneGoodSkill();
			
			ShowHint(MATCH_SKILL_COLOR, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Input, highlights);
		}
		else if(hintName == MATCH_SKILL_COLOR)
		{
			highlights = GetHighlightCharDevMutagenBonusString();
			AddHighlight( highlights, .568f, .24f, .08f, .15f );
			
			GetWitcherPlayer().TutorialMutagensEquipOneGoodOneBadSkill();
			
			ShowHint(WRONG_COLOR, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Input, highlights);
		}
		else if(hintName == WRONG_COLOR)
		{
			GetWitcherPlayer().TutorialMutagensEquipThreeGoodSkills();
			
			ShowHint(MULTIPLE_SKILLS, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Input, GetHighlightCharDevMutagenBonusString() );
		}		
		else if(hintName == MULTIPLE_SKILLS)
		{
			ShowHint(POTIONS, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Input);
		}
		else if(hintName == POTIONS)
		{
			QuitState();
		}
	}

	public final function SelectedMutagensTab()
	{
		var highlights : array<STutorialHighlight>;
		
		if(IsCurrentHint(SELECT_TAB))
		{
			CloseStateHint(SELECT_TAB);
			
			highlights = GetHighlightCharDevSkills();
			HighlightsCombine( highlights, GetHighlightCharDevTabMutagens() );
			
			ShowHint(EQUIP, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Infinite, highlights);
		}
	}
	
	public final function EquippedMutagen()
	{
		CloseStateHint(EQUIP);
		ShowHint(BONUSES, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Input, GetHighlightCharDevMutagenBonusString() );
	}
}




exec function tut_ch_m(optional color : ESkillColor, optional equipSkillsFirst : bool)
{
	GetWitcherPlayer().AddPoints(EExperiencePoint, 1500, false );
	
	if(equipSkillsFirst)
	{
		skilleq_internal(S_Alchemy_s01, 1);
		skilleq_internal(S_Alchemy_s02, 2);
		skilleq_internal(S_Sword_s01, 3);
	}
	
	if(color == SC_None || color == SC_Yellow)
		color = SC_Green;
		
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
		
	if(color == SC_Green)
		thePlayer.inv.AddAnItem('Ekimma mutagen',1);
	else if(color == SC_Blue)
		thePlayer.inv.AddAnItem('Fogling 1 mutagen',1);
	else if(color == SC_Red)
		thePlayer.inv.AddAnItem('Doppler mutagen',1);
	
	TutorialScript('charDevMutagens', '');
}