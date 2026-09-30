/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state SecondPotionEquip in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var CAN_EQUIP, SELECT_TAB, EQUIP_POTION : name;
	private var isClosing : bool;
	
		default CAN_EQUIP 		= 'TutorialPotionCanEquip1';
		default SELECT_TAB 		= 'TutorialPotionCanEquip2';
		default EQUIP_POTION 	= 'TutorialPotionCanEquip3';
	
	event OnEnterState( prevStateName : name )
	{
		var currentTab : int;
		
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		theGame.GetTutorialSystem().UnmarkMessageAsSeen(EQUIP_POTION);
		
		currentTab = ( (CR4InventoryMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild() ).GetCurrentlySelectedTab();
		if(currentTab == InventoryMenuTab_Potions)
		{
			OnPotionTabSelected();
		}
		else
		{
			ShowHint(CAN_EQUIP, POS_INVENTORY_X, POS_INVENTORY_Y);
		}
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(CAN_EQUIP);
		CloseStateHint(SELECT_TAB);
		CloseStateHint(EQUIP_POTION);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(CAN_EQUIP);
		theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
		theGame.GetTutorialSystem().MarkMessageAsSeen(EQUIP_POTION);
		
		GameplayFactsRemove("tutorial_equip_potion");
		
		super.OnLeaveState(nextStateName);
	}
		
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == CAN_EQUIP)
		{
			ShowHint( SELECT_TAB, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite, GetHighlightInvTabAlchemy() );
		}		
	}
	
	event OnPotionTabSelected()
	{
		CloseStateHint(SELECT_TAB);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
		
		ShowHint(EQUIP_POTION, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite);
	}
	
	event OnPotionEquipped(potionItemName : name)
	{
		QuitState();
	}
}