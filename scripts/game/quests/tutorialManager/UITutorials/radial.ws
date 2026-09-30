/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state Radial in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var SELECT_ITEMS, SELECT_BOLTS, BUFFS : name;
	private var isClosing : bool;
	
		default SELECT_ITEMS 	= 'TutorialRadialSelectItems';
		default SELECT_BOLTS 	= 'TutorialRadialSelectBolts';
		default BUFFS			= 'TutorialRadialBuffs';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		isClosing = false;
		
		ShowHint( SELECT_ITEMS, POS_RADIAL_X, POS_RADIAL_Y, ETHDT_Input, GetHighlightRadialItems() );
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint( SELECT_ITEMS );
		CloseStateHint( SELECT_BOLTS );
		CloseStateHint( BUFFS );
		
		super.OnLeaveState(nextStateName);
	}
		
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if( closedByParentMenu || isClosing )
			return true;
			
		if( hintName == SELECT_ITEMS )
		{
			ShowHint( SELECT_BOLTS, POS_RADIAL_X, POS_RADIAL_Y, ETHDT_Input, GetHighlightRadialBolts() );
		}
		else if( hintName == SELECT_BOLTS )
		{
			if( FactsQuerySum( "new_game_started_in_1_20" ) > 0 && !theGame.IsNewGameInStandaloneDLCMode() )
			{
				QuitState();
			}
			else
			{
				ShowHint( BUFFS, POS_RADIAL_X, POS_RADIAL_Y, ETHDT_Input, GetHighlightRadialBuffs() );
			}
		}
		else if( hintName == BUFFS )
		{
			QuitState();
		}
	}	
}