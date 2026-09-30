/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state CharacterDevelopment in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var OPEN_CHAR_DEV, LEVELING, SKILLS, BUY_SKILL, SKILL_EQUIPPING, EQUIP_SKILL, SKILL_UNEQUIPPING, GROUPS : name;
	private var isClosing : bool;
	
		default OPEN_CHAR_DEV 		= 'TutorialCharDevOpen';
		default LEVELING 			= 'TutorialCharDevGainingLevels';
		default SKILLS 				= 'TutorialCharDevSkillPoints';
		default BUY_SKILL 			= 'TutorialCharDevBuySkill';
		default SKILL_EQUIPPING 	= 'TutorialCharDevSkillEquipping';
		default EQUIP_SKILL 		= 'TutorialCharDevEquipSkill';
		default SKILL_UNEQUIPPING 	= 'TutorialCharDevSkillUnequipping';
		default GROUPS				= 'TutorialCharDevGroups';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		theGame.GetTutorialSystem().HideTutorialHint( OPEN_CHAR_DEV );
		ShowHint(LEVELING, POS_CHAR_DEV_X + 0.065, POS_CHAR_DEV_Y - 0.3);
		
		
		theGame.GetTutorialSystem().uiHandler.UnregisterUIState('CharacterDevelopmentFastMenu');
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(OPEN_CHAR_DEV);
		CloseStateHint(LEVELING);
		CloseStateHint(SKILLS);
		CloseStateHint(BUY_SKILL);
		CloseStateHint(SKILL_EQUIPPING);
		CloseStateHint(EQUIP_SKILL);
		CloseStateHint(SKILL_UNEQUIPPING);
		CloseStateHint(GROUPS);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(BUY_SKILL);
		theGame.GetTutorialSystem().MarkMessageAsSeen(EQUIP_SKILL);
		
		super.OnLeaveState(nextStateName);
	}
		
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if(closedByParentMenu || isClosing)
			return true;
			
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		

		QuitState();
	}
	
	public final function OnBoughtSkill(skill : ESkill)
	{
		CloseStateHint(BUY_SKILL);
		theGame.GetTutorialSystem().MarkMessageAsSeen(BUY_SKILL);
		ShowHint(SKILL_EQUIPPING, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, , GetHighlightCharDevSkillSlotGroups() );
	}
	
	public final function EquippedSkill()
	{
		var i, size : int;
		
		CloseStateHint(EQUIP_SKILL);
		theGame.GetTutorialSystem().MarkMessageAsSeen(EQUIP_SKILL);
		ShowHint(SKILL_UNEQUIPPING, POS_CHAR_DEV_X, POS_CHAR_DEV_Y);
		
		
		size = EnumGetMax('EInputActionBlock')+1;
		for(i=0; i<size; i+=1)
		{
			thePlayer.UnblockAction(i, 'lvlup_tutorial');
		}
	}
}

exec function tut_chd()
{
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	TutorialScript('characterDev', '');
}