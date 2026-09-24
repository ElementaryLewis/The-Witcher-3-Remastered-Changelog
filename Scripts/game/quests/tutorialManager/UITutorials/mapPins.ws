/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state MapPins in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var PLACE_PINS, CUSTOM_PINS, PINS_MAX_COUNT : name;
	private var isClosing : bool;
	
		default PLACE_PINS 			= 'TutorialMapPins';
		default CUSTOM_PINS 		= 'TutorialMapPinsCustom';
		default PINS_MAX_COUNT 		= 'TutorialMapPinsMaxCount';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		ShowHint(PLACE_PINS, POS_MAP_X, POS_MAP_Y, ETHDT_Input);	
	}
	
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint( PLACE_PINS );
		CloseStateHint( CUSTOM_PINS );
		CloseStateHint( PINS_MAX_COUNT );
		
		super.OnLeaveState(nextStateName);
	}	
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if(closedByParentMenu || isClosing)
		{
			return true;
		}		
		
		else if(hintName == PLACE_PINS)
		{
			ShowHint(CUSTOM_PINS, POS_MAP_X, POS_MAP_Y, ETHDT_Input);
		}
		else if(hintName == CUSTOM_PINS)
		{
			ShowHint(PINS_MAX_COUNT, POS_MAP_X, POS_MAP_Y, ETHDT_Input);
		}
		else if(hintName == PINS_MAX_COUNT)
		{
			QuitState();
		}
	}
}
