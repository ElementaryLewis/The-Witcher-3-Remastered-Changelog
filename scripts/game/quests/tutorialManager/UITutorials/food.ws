/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state Food in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var SELECT_TAB, SELECT_FOOD, EQUIP_FOOD, USAGE : name;
	private var isClosing : bool;	
	
		default SELECT_TAB 		= 'TutorialFoodSelectTab';
		default SELECT_FOOD 	= 'TutorialFoodSelectFood';
		default EQUIP_FOOD 		= 'TutorialFoodEquip';
		default USAGE 			= 'TutorialFoodUsage';
		
	event OnEnterState( prevStateName : name )
	{
		var witcher : W3PlayerWitcher;
		var currentTab : int;
		var hasFood : bool;
		var item : SItemUniqueId;
		
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		hasFood = false;
		witcher = GetWitcherPlayer();
		
		
		if(witcher.GetItemEquippedOnSlot(EES_Potion1, item))
		{
			if(witcher.inv.IsItemFood(item))
				hasFood = true;
		}
		
		if(!hasFood && witcher.GetItemEquippedOnSlot(EES_Potion2, item))
		{
			if(witcher.inv.IsItemFood(item))
				hasFood = true;
		}
		
		if(!hasFood && witcher.GetItemEquippedOnSlot(EES_Potion3, item))
		{
			if(witcher.inv.IsItemFood(item))
				hasFood = true;
		}
		
		if(!hasFood && witcher.GetItemEquippedOnSlot(EES_Potion4, item))
		{
			if(witcher.inv.IsItemFood(item))
				hasFood = true;
		}
		
		if(hasFood)
		{
			ShowHint(USAGE, POS_INVENTORY_X, POS_INVENTORY_Y);
		}
		else
		{
			
			if( witcher.inv.GetItemQuantityByTag('Edibles') == 0 )
			{
				witcher.inv.AddAnItem('Bread', 1, true, false);
			}
			
			currentTab = ( (CR4InventoryMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild() ).GetCurrentlySelectedTab();
			if(currentTab == InventoryMenuTab_Potions)
			{
				OnPotionTabSelected();
			}
			else
			{
				ShowHint( SELECT_TAB, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite, GetHighlightInvTabMisc() );
			}
		}		
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(SELECT_TAB);
		CloseStateHint(SELECT_FOOD);
		CloseStateHint(EQUIP_FOOD);
		CloseStateHint(USAGE);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
		
		super.OnLeaveState(nextStateName);
	}
		
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		var highlights : array<STutorialHighlight>;		
		
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == USAGE)
		{
			QuitState();
		}
	}
	
	event OnPotionTabSelected()
	{
		CloseStateHint(SELECT_TAB);
		
		ShowHint(SELECT_FOOD, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite);
	}
	
	event OnSelectedItem(itemId : SItemUniqueId)
	{
		if(IsCurrentHint(SELECT_FOOD) && thePlayer.inv.IsItemFood(itemId))
		{
			
			CloseStateHint(SELECT_FOOD);
			ShowHint(EQUIP_FOOD, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite);
		}
		else if(IsCurrentHint(EQUIP_FOOD) && !thePlayer.inv.IsItemFood(itemId))
		{
			
			CloseStateHint(EQUIP_FOOD);
			ShowHint(SELECT_FOOD, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite);
		}
	}
	
	event OnFoodEquipped()
	{
		CloseStateHint(EQUIP_FOOD);
		ShowHint(USAGE, POS_INVENTORY_X, POS_INVENTORY_Y);
	}
}