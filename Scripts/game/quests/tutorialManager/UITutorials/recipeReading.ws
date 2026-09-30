/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state RecipeReading in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var OPEN_INVENTORY, SELECT_TAB, SELECT_BOOK, USE, READ : name;
	private var isClosing : bool;
	
		default OPEN_INVENTORY	= 'TutorialRecipesOpenInv';
		default SELECT_TAB 		= 'TutorialBooksSelectTab';
		default SELECT_BOOK 	= 'TutorialBooksSelectBook';
		default USE 			= 'TutorialBooksUse';
		default READ 			= 'TutorialRecipesLearned';
		
	event OnEnterState( prevStateName : name )
	{
		var highlights : array<STutorialHighlight>;
		var currentTab : int;
		
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		theGame.GetTutorialSystem().HideTutorialHint( OPEN_INVENTORY );
		
		currentTab = ( (CR4InventoryMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild() ).GetCurrentlySelectedTab();
		if(currentTab == InventoryMenuTab_Potions)
		{
			OnSelectedTab(true);
		}
		else
		{
			highlights.Resize(1);
			highlights[0].x = 0.15;
			highlights[0].y = 0.15;
			highlights[0].width = 0.05;
			highlights[0].height = 0.08;
				
			ShowHint(SELECT_TAB, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite, highlights);
		}
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(SELECT_TAB);
		CloseStateHint(SELECT_BOOK);
		CloseStateHint(USE);
		CloseStateHint(READ);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnSelectedItem(itemId : SItemUniqueId)
	{
		if(IsCurrentHint(SELECT_BOOK) && thePlayer.inv.ItemHasTag(itemId, 'ReadableItem') )
		{
			
			CloseStateHint(SELECT_BOOK);
			ShowHint(USE, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite);
		}
		else if(IsCurrentHint(USE) && !thePlayer.inv.ItemHasTag(itemId, 'ReadableItem') )
		{
			
			CloseStateHint(USE);
			ShowHint(SELECT_BOOK, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite);
		}
	}

	event OnSelectedTab(properTab : bool)
	{
		if(IsCurrentHint(SELECT_TAB) && properTab)
		{
			CloseStateHint(SELECT_TAB);
			ShowHint(SELECT_BOOK, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite);
		}
		else if(!IsCurrentHint(SELECT_TAB) && !properTab)
		{
			CloseStateHint(SELECT_BOOK);
			CloseStateHint(USE);
			ShowHint(SELECT_TAB, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite);
		}
	}
	
	event OnBookRead()
	{
		CloseStateHint(USE);
		ShowHint(READ, POS_INVENTORY_X, POS_INVENTORY_Y);		
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		var highlights : array<STutorialHighlight>;
		
		if(closedByParentMenu || isClosing)
		{
			return true;
		}		
		else if(hintName == READ)
		{
			QuitState();
		}
	}
}