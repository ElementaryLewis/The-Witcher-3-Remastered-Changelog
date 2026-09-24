/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state SetItemsUnlocked in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var UNLOCKED : name;
	private var isClosing : bool;
	
		default UNLOCKED	= 'TutorialSetBonusesUnlocked';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		isClosing = false;
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint( UNLOCKED );
		
		super.OnLeaveState(nextStateName);
	}
		
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if( closedByParentMenu || isClosing )
			return true;
			
		QuitState();
	}
	
	event OnSetBonusCompleted()
	{
		ShowHint( UNLOCKED, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input, , , , true );		
	}
}