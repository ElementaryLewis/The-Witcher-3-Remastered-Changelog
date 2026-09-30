/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state MapFilters in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var SELECT, CUSTOMIZE, PIN_JUMPING : name;
	private var isClosing : bool;
	
		default SELECT 			= 'TutorialMapFiltersSelect';
		default CUSTOMIZE 		= 'TutorialMapFiltersCustomize';
		default PIN_JUMPING		= 'TutorialMapFiltersPinJumping';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		ShowHint( SELECT, 0.7f, POS_MAP_Y, ETHDT_Input, GetHighlightMapFilters() );	
	}
	
	event OnLeaveState( nextStateName : name )
	{
		var uitut : SUITutorial;
		
		isClosing = true;
		
		CloseStateHint( SELECT );
		CloseStateHint( CUSTOMIZE );
		CloseStateHint( PIN_JUMPING );
	
		super.OnLeaveState(nextStateName);
	}	
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if(closedByParentMenu || isClosing)
		{
			return true;
		}		
		
		QuitState();
		return true;

		if(hintName == SELECT)
		{
			ShowHint( CUSTOMIZE, 0.7f, POS_MAP_Y, ETHDT_Input );
		}
		else if(hintName == CUSTOMIZE)
		{
			ShowHint( PIN_JUMPING, 0.7f, POS_MAP_Y, ETHDT_Input );
		}
		else if(hintName == PIN_JUMPING)
		{
			QuitState();
		}
	}
}