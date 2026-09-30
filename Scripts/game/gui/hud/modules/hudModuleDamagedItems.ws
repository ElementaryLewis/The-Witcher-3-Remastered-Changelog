/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4HudModuleDamagedItems extends CR4HudModuleBase
{	
	private	var m_fxSetItemDamaged			: CScriptedFlashFunction;
	private var damagedItems				: array <bool>;
	private var inv							: CInventoryComponent;
	private var isDisplayed					: bool;

	event  OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		m_anchorName 			= "mcAnchorDamagedItems";
		damagedItems.Grow(6);
		super.OnConfigUI();
		inv = GetWitcherPlayer().GetInventory();
		flashModule 			= GetModuleFlash();
		
		m_fxSetItemDamaged		= flashModule.GetMemberFlashFunction( "setItemDamaged" );
		
		SetTickInterval( 1 );
		
		hud = (CR4ScriptedHud)theGame.GetHud();
						
		if (hud)
		{
			hud.UpdateHudConfig('DamagedItemsModule', true);
		}
	}

	event OnTick( timeDelta : float )
	{
		if ( !CanTick( timeDelta ) )
		{
			return true;
		}
		
		CheckDamagedItems(); 
	}

	private function CheckDamagedItems()
	{
		var i : int;
		var item : SItemUniqueId;
		var isItemDamaged : bool;
		var damagedItemsCount : int;
		var durItem : float;
		
		if(!inv)
			inv = GetWitcherPlayer().GetInventory();
		
		damagedItemsCount = 0;
		
		for ( i = EES_SilverSword; i <= EES_Gloves; i += 1 )
		{
			if( inv.GetItemEquippedOnSlot(i, item) )
			{
				if( inv.HasItemDurability(item) )
				{
					durItem = RoundMath( inv.GetItemDurability(item) / inv.GetItemMaxDurability(item) * 100);
					isItemDamaged = ( durItem <= theGame.params.ITEM_DAMAGED_DURABILITY );
				}
				else
				{
					isItemDamaged = false;
				}
				if( isItemDamaged != damagedItems[ i - 1 ] )
				{
					damagedItems[ i - 1 ] = isItemDamaged;
					m_fxSetItemDamaged.InvokeSelfTwoArgs(FlashArgInt(i),FlashArgBool(isItemDamaged));
				}
				if( isItemDamaged )
				{
					damagedItemsCount += 1;
				}
			}
		}
		if( damagedItemsCount == 0 )
		{
			if( isDisplayed )
			{
				ShowElement(false,false);
				isDisplayed = false;
			}
		}
		else
		{
			if( !isDisplayed )
			{
				ShowElement(true,false);
				isDisplayed = true;
			}
		}
	}
	
	public function OnItemUnequippedFromSlot( slot : int )
	{
		damagedItems[ slot - 1 ] = false;
		m_fxSetItemDamaged.InvokeSelfTwoArgs(FlashArgInt(slot),FlashArgBool(false));
	}
}

exec function reduceidur( durability : float )
{
	var i : int;
	var item : SItemUniqueId;
	var inv : CInventoryComponent;
	
	inv = GetWitcherPlayer().GetInventory(); 
	for ( i = EES_SilverSword; i <= EES_Gloves -4; i += 1 )
	{
		inv.GetItemEquippedOnSlot(i, item);
		inv.SetItemDurabilityScript(item, durability);
	}
}

exec function reduceidurslot( i : int, durability : float )
{
	var item : SItemUniqueId;
	var inv : CInventoryComponent;
	
	inv = GetWitcherPlayer().GetInventory(); 
	inv.GetItemEquippedOnSlot(i, item);
	inv.SetItemDurabilityScript(item, durability);
}
