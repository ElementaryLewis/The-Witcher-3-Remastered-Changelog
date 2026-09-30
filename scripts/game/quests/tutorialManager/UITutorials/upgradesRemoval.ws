/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state UpgradesRemoval in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var DESCRIPTION, ITEMS, UPGRADES, COST, REMOVING : name;
	private const var POS_X, POS_Y : float;
	private var isClosing : bool;
	
		default DESCRIPTION 	= 'TutorialUpgRemovalDescription';
		default ITEMS 			= 'TutorialUpgRemovalItems';
		default UPGRADES 		= 'TutorialUpgRemovalUpgrades';
		default COST 			= 'TutorialUpgRemovalCost';
		default REMOVING 		= 'TutorialUpgRemovalRemoving';
		default POS_X = .15f;
		default POS_Y = .5f;
		
	event OnEnterState( prevStateName : name )
	{	
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		ShowHint(DESCRIPTION, POS_X, POS_Y, ETHDT_Input);
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(DESCRIPTION);
		CloseStateHint(ITEMS);
		CloseStateHint(UPGRADES);
		CloseStateHint(COST);
		CloseStateHint(REMOVING);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(DESCRIPTION);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if(closedByParentMenu || isClosing)
			return true;

		QuitState();
		return true;
			
		if(hintName == DESCRIPTION)
		{
			ShowHint( ITEMS, POS_X, POS_Y, ETHDT_Input, GetHighlightBlacksmithItems() );
		}		
		else if(hintName == ITEMS)
		{
			ShowHint( UPGRADES, POS_X, POS_Y, ETHDT_Input, GetHighlightBlacksmithSockets() );
		}
		else if(hintName == UPGRADES)
		{
			ShowHint( COST, POS_X, POS_Y, ETHDT_Input, GetHighlightBlacksmithPrice() );
		}
		else if(hintName == COST)
		{
			ShowHint(REMOVING, POS_X, POS_Y, ETHDT_Input);
		}
		else if(hintName == REMOVING)
		{
			QuitState();
		}
	}
}