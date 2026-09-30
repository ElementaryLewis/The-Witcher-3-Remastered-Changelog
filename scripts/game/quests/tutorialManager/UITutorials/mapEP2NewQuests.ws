/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state MapEP2NewQuests in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var DESCRIPTION : name;
	
		default DESCRIPTION = 'TutorialMapEP2QuestPins';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		ShowHint( DESCRIPTION, POS_MAP_X, POS_MAP_Y );
	}
			
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(DESCRIPTION);
		
		super.OnLeaveState(nextStateName);
	}	
}