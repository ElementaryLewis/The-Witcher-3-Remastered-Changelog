/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state Potions in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var CAN_EQUIP, SELECT_TAB, EQUIP_POTION, EQUIP_POTION_THUNDERBOLT, ON_EQUIPPED : name;
	private var isClosing, isForcedThunderbolt, skippingTabSelection : bool;
	
		default CAN_EQUIP 		= 'TutorialPotionCanEquip1';
		default SELECT_TAB 		= 'TutorialPotionCanEquip2';
		default EQUIP_POTION 	= 'TutorialPotionCanEquip3';
		default EQUIP_POTION_THUNDERBOLT = 'TutorialPotionCanEquip3Thunderbolt';
		default ON_EQUIPPED 	= 'TutorialPotionEquipped';
		
	event OnEnterState( prevStateName : name )
	{
		var witcher : W3PlayerWitcher;
		var currentTab : int;
		var itemOne, itemTwo, itemThree, itemFour : SItemUniqueId;
		
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		skippingTabSelection = false;
		isForcedThunderbolt = (FactsQuerySum("tut_forced_preparation") > 0);
		
		if(!isForcedThunderbolt) 
		{		
			witcher = GetWitcherPlayer();
			witcher.GetItemEquippedOnSlot(EES_Potion1, itemOne);
			witcher.GetItemEquippedOnSlot(EES_Potion2, itemTwo);
			witcher.GetItemEquippedOnSlot(EES_Potion3, itemThree);
			witcher.GetItemEquippedOnSlot(EES_Potion4, itemFour);
			
			if(witcher.inv.IsItemPotion(itemOne) || witcher.inv.IsItemPotion(itemTwo) || witcher.inv.IsItemPotion(itemThree) || witcher.inv.IsItemPotion(itemFour))
			{
				skippingTabSelection = true;
				
				
				ShowHint(ON_EQUIPPED, POS_INVENTORY_X, POS_INVENTORY_Y-0.1);
				
				
				TutorialScript('secondPotionEquip', '');
			}
			else
			{
				currentTab = ( (CR4InventoryMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild() ).GetCurrentlySelectedTab();
				if(currentTab == InventoryMenuTab_Potions)
				{
					skippingTabSelection = true;
					OnPotionTabSelected();
				}
				else
				{
					ShowHint(CAN_EQUIP, POS_INVENTORY_X, POS_INVENTORY_Y);
				}
			}
		}
		else	
		{
			theGame.GetTutorialSystem().uiHandler.LockLeaveMenu(true);
			
			
			thePlayer.BlockAction(EIAB_OpenAlchemy, 'tut_forced_preparation');
			
			theGame.GetTutorialSystem().UnmarkMessageAsSeen(EQUIP_POTION);
			ShowHint(CAN_EQUIP, POS_INVENTORY_X, POS_INVENTORY_Y);
		}
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(CAN_EQUIP);
		CloseStateHint(SELECT_TAB);
		CloseStateHint(EQUIP_POTION);
		CloseStateHint(EQUIP_POTION_THUNDERBOLT);
		CloseStateHint(ON_EQUIPPED);
		
		if(!skippingTabSelection)
			theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
			
		theGame.GetTutorialSystem().MarkMessageAsSeen(EQUIP_POTION);
		
		if(isForcedThunderbolt)
			theGame.GetTutorialSystem().MarkMessageAsSeen(EQUIP_POTION_THUNDERBOLT);
		
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
		else if(hintName == ON_EQUIPPED)
		{
			
			if(isForcedThunderbolt)
			{
				theGame.GetTutorialSystem().ForcedAlchemyCleanup();
			}
			
			QuitState();
		}
	}
	
	event OnPotionTabSelected()
	{
		CloseStateHint(SELECT_TAB);
		
		if(isForcedThunderbolt)
			ShowHint(EQUIP_POTION_THUNDERBOLT, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite);
		else
			ShowHint(EQUIP_POTION, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite);
	}
	
	event OnPotionEquipped(potionItemName : name)
	{
		
		if(isForcedThunderbolt && potionItemName != 'Thunderbolt 1')
			return false;
	
		CloseStateHint(EQUIP_POTION);
		CloseStateHint(EQUIP_POTION_THUNDERBOLT);
		theGame.GetTutorialSystem().MarkMessageAsSeen(EQUIP_POTION);
		ShowHint(ON_EQUIPPED, POS_INVENTORY_X, POS_INVENTORY_Y-0.1);
	}
}

exec function tut_pot()
{
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	TutorialScript('PotionsPreparation', '');
}
