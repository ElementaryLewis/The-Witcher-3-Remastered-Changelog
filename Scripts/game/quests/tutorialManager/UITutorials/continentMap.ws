/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state ContinentMap in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var TO_CONTINENT, BACK_TO_HUB, TO_ANY_HUB : name;
	private var isClosing : bool;
	
		default TO_CONTINENT 		= 'TutorialMapToContinent';
		default BACK_TO_HUB 		= 'TutorialMapBackToHub';
		default TO_ANY_HUB			= 'TutorialMapToAnyHub';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		ShowHint( TO_CONTINENT, POS_MAP_X, POS_MAP_Y, ETHDT_Infinite );	
	}
	
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint( TO_CONTINENT );
		CloseStateHint( BACK_TO_HUB );
		CloseStateHint( TO_ANY_HUB );
		
		super.OnLeaveState(nextStateName);
	}	
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if(closedByParentMenu || isClosing)
		{
			return true;
		}		

		if( hintName == BACK_TO_HUB )
		{
			ShowHint( TO_ANY_HUB, POS_MAP_X, POS_MAP_Y, ETHDT_Input );	
		}
		else if( hintName == TO_ANY_HUB )
		{
			QuitState();
		}
	}
	
	event OnWentToContinentMap()
	{
		CloseStateHint( TO_CONTINENT );
		ShowHint( BACK_TO_HUB, POS_MAP_X, POS_MAP_Y, ETHDT_Input );	
	}
}