/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state Inventory in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var PAPERDOLL, BAG, TABS, STATS, STATS_DETAILS, EQUIPPING : name;
	private var isClosing : bool;
	
		default PAPERDOLL 		= 'TutorialInventoryPaperdoll';
		default BAG 			= 'TutorialInventoryBag';
		default TABS 			= 'TutorialInventoryTabs';
		default STATS 			= 'TutorialInventoryStats';
		default STATS_DETAILS 	= 'TutorialInventoryStatsMore';
		default EQUIPPING 		= 'TutorialInventoryEquipping';
		
	event OnEnterState( prevStateName : name )
	{
		var highlights : array<STutorialHighlight>;
		
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		
		
		highlights.PushBack( GetHighlightForPaperdoll() );			
		ShowHint(PAPERDOLL, POS_INVENTORY_X, POS_INVENTORY_Y - 0.05f);
		
		theGame.GameplayFactsAdd( 'panel_on_since_inv_tut' );
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		
		
		CloseStateHint(PAPERDOLL);
		CloseStateHint(BAG);
		CloseStateHint(TABS);
		CloseStateHint(STATS);
		CloseStateHint(STATS_DETAILS);
		CloseStateHint(EQUIPPING);
		
		super.OnLeaveState(nextStateName);
	}
	
	private final function BlockPanels(block : bool)
	{
		if(block)
		{
			thePlayer.BlockAction(EIAB_FastTravel, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_MeditationWaiting, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenMap, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenCharacterPanel, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenJournal, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenAlchemy, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenGwint, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenFastMenu, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenGlossary, 'tutorial_inventory');
		}
		else
		{
			thePlayer.UnblockAction(EIAB_FastTravel, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_MeditationWaiting, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenMap, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenCharacterPanel, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenJournal, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenAlchemy, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenGwint, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenFastMenu, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenGlossary, 'tutorial_inventory');
		}
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		var highlights : array<STutorialHighlight>;
		
		if(closedByParentMenu || isClosing)
			return true;
				
		else if(hintName == PAPERDOLL)
		{
			
			BlockPanels(false);
			QuitState();
			
		}
		
	}
}

exec function tut_inv()
{
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	TutorialScript('inventory', '');
}