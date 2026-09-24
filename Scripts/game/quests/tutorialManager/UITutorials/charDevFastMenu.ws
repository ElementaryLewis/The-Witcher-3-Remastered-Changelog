/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state CharacterDevelopmentFastMenu in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var PANEL, CHAR_DEV_OPEN : name;
	
		default PANEL 				= 'TutorialCharDevPanel';
		default CHAR_DEV_OPEN 		= 'TutorialCharDevOpen';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		theGame.GetTutorialSystem().HideTutorialHint( CHAR_DEV_OPEN );
		
		ShowHint(PANEL, 0.5, 0.7, ETHDT_Infinite, GetHighlightHubMenuCharDev() );
	}

	event OnLeaveState( nextStateName : name )
	{		
		CloseStateHint(PANEL);
		
		super.OnLeaveState(nextStateName);
	}		
}