/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state NewInventory in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var TAB_CRAFTING, TAB_QUEST, TAB_MISC, TAB_ALCHEMY, TAB_WEAPONS, TOOLTIPS, PREVIEW, PREVIEW2, SORTING, GEEKPAGE : name;
	private var isClosing : bool;
	
		default TAB_CRAFTING 	= 'TutorialNewInvTabCrafting';
		default TAB_QUEST 		= 'TutorialNewInvTabQuest';
		default TAB_MISC 		= 'TutorialNewInvTabMisc';
		default TAB_ALCHEMY 	= 'TutorialNewInvTabAlchemy';
		default TAB_WEAPONS 	= 'TutorialNewInvTabWeapons';
		default TOOLTIPS 		= 'TutorialNewInvTooltips';
		default PREVIEW			= 'TutorialNewInvPreview';
		default PREVIEW2		= 'TutorialNewInvPreview2';
		default SORTING			= 'TutorialNewInvSorting';
		default GEEKPAGE		= 'TutorialNewInvGeekpage';
		
	event OnEnterState( prevStateName : name )
	{
		var highlights : array<STutorialHighlight>;
		
		super.OnEnterState( prevStateName );
		
		isClosing = false;
		
		highlights.Resize( 1 );
		highlights[0].x = 0.05f;
		highlights[0].y = 0.14f;
		highlights[0].width = 0.33f;
		highlights[0].height = 0.65f;

		
		
		ShowHint( TAB_CRAFTING, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input, GetHighlightInvTabCrafting() );		
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint( TOOLTIPS );
		CloseStateHint( PREVIEW );
		CloseStateHint( PREVIEW2 );
		CloseStateHint( SORTING );
		CloseStateHint( GEEKPAGE );
		
		super.OnLeaveState(nextStateName);
	}
		
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if( closedByParentMenu || isClosing )
			return true;
			
		if( hintName == TAB_CRAFTING )
		{
			ShowHint( TAB_QUEST, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input, GetHighlightInvTabQuest() );
		}
		else if( hintName == TAB_QUEST )
		{
			ShowHint( TAB_MISC, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input, GetHighlightInvTabMisc() );
		}
		else if( hintName == TAB_MISC )
		{
			ShowHint( TAB_ALCHEMY, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input, GetHighlightInvTabAlchemy() );
		}
		else if( hintName == TAB_ALCHEMY )
		{
			ShowHint( TAB_WEAPONS, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input, GetHighlightInvTabWeapons() );
		}
		else if( hintName == TAB_WEAPONS )
		{
			ShowHint( TOOLTIPS, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input );
		}
		else if( hintName == TOOLTIPS )
		{
			ShowHint( PREVIEW, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input );
		}
		else if( hintName == PREVIEW )
		{
			ShowHint( PREVIEW2, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input );
		}
		else if( hintName == PREVIEW2 )
		{
			ShowHint( SORTING, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input );
		}
		else if( hintName == SORTING )
		{
			ShowHint( GEEKPAGE, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input );
		}		
		else if( hintName == GEEKPAGE )
		{
			QuitState();
		}
	}
}

exec function tut_newinv()
{
	TutorialMessagesEnable( true );
	theGame.GetTutorialSystem().TutorialStart( false );
	TutorialScript( 'newInventory', '' );
}