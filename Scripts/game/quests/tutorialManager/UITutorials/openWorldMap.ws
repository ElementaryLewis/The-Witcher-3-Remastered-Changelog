/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state OpenWorldMap in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var OPEN_FAST_MENU, OPEN_MAP : name;
	
		default OPEN_FAST_MENU = 'TutorialMapOpenFastMenu';
		default OPEN_MAP = 'TutorialMapOpenMap';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		
		theGame.GetTutorialSystem().HideTutorialHint( OPEN_FAST_MENU );
		
		
	}
	
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(OPEN_MAP);
		
		super.OnLeaveState(nextStateName);
	}	
}