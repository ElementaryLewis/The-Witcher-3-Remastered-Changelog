/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state NewGeekpage in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var STATS, SUBSTATS, CONTROLS : name;
	private var isClosing : bool;
	
		default STATS 		= 'TutorialGeekpageStats';
		default SUBSTATS 	= 'TutorialGeekpageSubStats';
		default CONTROLS	= 'TutorialGeekpageControls';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		isClosing = false;
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint( STATS );
		CloseStateHint( SUBSTATS );
		CloseStateHint( CONTROLS );
		
		super.OnLeaveState(nextStateName);
	}
		
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if( closedByParentMenu || isClosing )
			return true;
			
		if( hintName == STATS )
		{
			ShowHint( SUBSTATS, POS_GEEKPAGE_X, POS_GEEKPAGE_Y, ETHDT_Input, GetHighlightGeekPageSecondary() );
		}
		else if( hintName == SUBSTATS )
		{
			ShowHint( CONTROLS, POS_GEEKPAGE_X, POS_GEEKPAGE_Y, ETHDT_Input );
		}
	}
	
	event OnGeekpageOpened()
	{
		ShowHint( STATS, POS_GEEKPAGE_X, POS_GEEKPAGE_Y, ETHDT_Input, GetHighlightGeekPagePrimary(), , , true );		
	}
	
	event OnGeekpageClosed()
	{
		QuitState();
	}
}