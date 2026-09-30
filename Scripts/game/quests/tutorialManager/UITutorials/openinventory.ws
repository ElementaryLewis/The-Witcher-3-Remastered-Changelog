/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state OpenInventory in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var OPEN_FAST_MENU, OPEN_INVENTORY : name;
	
		default OPEN_FAST_MENU = 'TutorialFoodOpenFastMenu';
		default OPEN_INVENTORY = 'TutorialFoodOpenInventory';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		
		theGame.GetTutorialSystem().HideTutorialHint( OPEN_FAST_MENU );
		
		ShowHint(OPEN_INVENTORY, 0.35f, 0.6f, ETHDT_Infinite, GetHighlightHubMenuInventory() );	
	}
	
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(OPEN_INVENTORY);
		
		super.OnLeaveState(nextStateName);
	}	
}
