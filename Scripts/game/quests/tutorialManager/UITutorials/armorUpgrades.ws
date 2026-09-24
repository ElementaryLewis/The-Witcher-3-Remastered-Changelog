/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state ArmorUpgrades in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var TAB, UPGRADE, ITEM : name;
	
		default TAB 		= 'TutorialArmorSocketsSelectTab';
		default UPGRADE 	= 'TutorialArmorSocketsSelectUpgrade';
		default ITEM 		= 'TutorialArmorSocketsSelectItem';
		
	event OnEnterState( prevStateName : name )
	{
		var currentTab : int;
		
		super.OnEnterState(prevStateName);
		
		currentTab = ( (CR4InventoryMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild() ).GetCurrentlySelectedTab();
		
		if(currentTab != InventoryMenuTab_Weapons)
		{
			ShowHint(TAB, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite, GetHighlightInvTabWeapons() );
		}
		else
		{
			ShowHint(UPGRADE, .4f, .65f, ETHDT_Infinite);
		}
	}
			
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(TAB);
		CloseStateHint(UPGRADE);
		CloseStateHint(ITEM);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(TAB);
		
		super.OnLeaveState(nextStateName);
	}
		
	event OnSelectingArmor()
	{
		CloseStateHint(UPGRADE);
		ShowHint(ITEM, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite);
	}
	
	event OnSelectingArmorAborted()
	{
		CloseStateHint(ITEM);
		ShowHint(UPGRADE, .4f, .65f, ETHDT_Infinite);
	}
	
	event OnUpgradedItem()
	{
		QuitState();
	}
	
	event OnTabSelected()
	{
		CloseStateHint(TAB);
		ShowHint(UPGRADE, .4f, .65f, ETHDT_Infinite);
	}
}

exec function tut_arm_upg()
{
	thePlayer.inv.AddAnItem('Steel plate',3);
	GetWitcherPlayer().AddPoints(EExperiencePoint, 50000, false );
	thePlayer.inv.AddAnItem('Medium armor 11',1);
}