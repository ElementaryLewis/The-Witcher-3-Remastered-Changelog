/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state Radial in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var SELECT_ITEMS, SELECT_BOLTS, BUFFS : name;
	private var closedItems : bool; default closedItems = false;
	private var boltsShown : bool; default boltsShown = false;
	private var buffsShown : bool; default buffsShown = false;
	private var isClosing : bool;
	
		default SELECT_ITEMS 	= 'TutorialRadialSelectItems';
		default SELECT_BOLTS 	= 'TutorialRadialSelectBolts';
		default BUFFS			= 'TutorialRadialBuffs';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		isClosing = false;
		
		ExecuteRadial();
	}

	entry function ExecuteRadial():void
	{
		var rangedId : SItemUniqueId;

		if(ShouldProcessTutorial(SELECT_ITEMS)) {
			ShowHint( SELECT_ITEMS, POS_RADIAL_X, POS_RADIAL_Y, ETHDT_Input, GetHighlightRadialItems(), , true );
			theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_ITEMS);
		}

		while(!closedItems || !thePlayer.inv.IsIdValid(rangedId))
		{
			ExecuteRadialLoop(rangedId);
			
		}

		ShowHint( SELECT_BOLTS, POS_RADIAL_X, POS_RADIAL_Y, ETHDT_Input, GetHighlightRadialBolts(), , true );
		theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_BOLTS);
		boltsShown = true;
	}

	latent function ExecuteRadialLoop(out rangedId : SItemUniqueId)
	{
		GetWitcherPlayer().GetItemEquippedOnSlot(EES_RangedWeapon, rangedId);
		if(closedItems && !thePlayer.inv.IsIdValid(rangedId))
		{
			TryShowBuffs();
		}
		Sleep(0.1);
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
			closedItems = true;
			
		}
		else if( hintName == SELECT_BOLTS )
		{
			if(!buffsShown)
				TryShowBuffs();
			else
				QuitState();
		}
		else if( hintName == BUFFS )
		{
			QuitState();
		}
	}	

	private function TryShowBuffs():void
	{
		if( FactsQuerySum( "new_game_started_in_1_20" ) > 0 && !theGame.IsNewGameInStandaloneDLCMode() )
		{
			if(boltsShown)
				QuitState();
		}
		else
		{
			if(ShouldProcessTutorial(BUFFS))
			{
				ShowHint( BUFFS, POS_RADIAL_X, POS_RADIAL_Y, ETHDT_Input, GetHighlightRadialBuffs(), , true );
				theGame.GetTutorialSystem().MarkMessageAsSeen(BUFFS);
			}
		}
		buffsShown = true;
	}
}