/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state MutationsOpenMutations in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var TUTORIAL : name;
	
		default TUTORIAL = 'TutorialMutationsOpenMutations';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		ShowHint( TUTORIAL, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Infinite, GetHighlightsCharPanelMutation() );
	}
		
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint( TUTORIAL );
		
		super.OnLeaveState( nextStateName );
	}
	
	event OnMenuClosing( menuName : name )
	{
		QuitState();
	}
}