/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state SpecialAttacks in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var SPECIALS, ALTERNATES : name;

		default ALTERNATES 			= 'TutorialAlternateSigns';
		default SPECIALS 			= 'TutorialSpecialAttacks';
		
	event OnLeaveState( nextStateName : name )
	{		
		CloseStateHint(SPECIALS);
		CloseStateHint(ALTERNATES);
		
		
		
		
		if(theGame.GetTutorialSystem().HasSeenTutorial(SPECIALS) && theGame.GetTutorialSystem().HasSeenTutorial(ALTERNATES))
		{
			theGame.GetTutorialSystem().uiHandler.UnregisterUIState(GetStateName());
		}
	}
		
	public final function OnBoughtSkill(skill : ESkill)
	{
		if(skill == S_Sword_s01 || skill == S_Sword_s02)
		{
			ShowHint( SPECIALS, POS_CHAR_DEV_X, 0.47f, ETHDT_Input, , , , true );
		}
		else if(skill == S_Magic_s01 || skill == S_Magic_s02 || skill == S_Magic_s03 || skill == S_Magic_s04 || skill == S_Magic_s05)
		{
			ShowHint( ALTERNATES, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Input, , , , true );
		}
	}
}