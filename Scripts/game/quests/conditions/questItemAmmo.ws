/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_ItemAmmo_AmmoListener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_ItemAmmo;
	
	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name )
	{
		if ( condition )
		{
			condition.EvaluateImpl();
		}	
	}
}

class W3QuestCond_ItemAmmo_InventoryListener extends IInventoryScriptedListener
{
	public var condition : W3QuestCond_ItemAmmo;
	
	event OnInventoryScriptedEvent( eventType : EInventoryEventType, itemId : SItemUniqueId, quantity : int, fromAssociatedInventory : bool )
	{
		if ( condition )
		{
			condition.EvaluateImpl();
		}
	}
}

class W3QuestCond_ItemAmmo extends CQuestScriptedCondition
{
	editable var itemName 		: name;
	editable var ammoQuantity 	: int;
	editable var comparator 	: ECompareOp;

	saved var isFulfilled		: bool;
	var ammoListener			: W3QuestCond_ItemAmmo_AmmoListener;
	var inventoryListener		: W3QuestCond_ItemAmmo_InventoryListener;

	function RegisterAmmoListener( flag : bool )
	{
		if ( flag )
		{
			ammoListener = new W3QuestCond_ItemAmmo_AmmoListener in this;
			ammoListener.condition = this;
			theGame.GetGlobalEventsManager().AddListener( GetGlobalEventCategory( SEC_OnAmmoChanged ), ammoListener );				
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListener( GetGlobalEventCategory( SEC_OnAmmoChanged ), ammoListener );
			delete ammoListener;
			ammoListener = NULL;
		}
	}

	function RegisterInventoryListener( flag : bool )
	{
		var inventory : CInventoryComponent;
		inventory = thePlayer.GetInventory();
		if ( !inventory )
		{
			return;
		}
		if ( flag )
		{
			inventoryListener = new W3QuestCond_ItemAmmo_InventoryListener in this;
			inventoryListener.condition = this;
			inventory.AddListener( inventoryListener );
			EvaluateImpl();
		}
		else
		{
			inventory.RemoveListener( inventoryListener );
			delete inventoryListener;
			inventoryListener = NULL;
		}
	}
	
	function Activate()
	{
		EvaluateImpl();
		if ( !isFulfilled )
		{
			RegisterAmmoListener( true );
			RegisterInventoryListener( true );
		}		
	}
	
	function Deactivate()
	{
		if ( ammoListener )
		{
			RegisterAmmoListener( false );
		}
		if ( inventoryListener )
		{
			RegisterInventoryListener( false );
		}
	}

	function Evaluate() : bool
	{
		if ( !isFulfilled )
		{
			if ( !ammoListener )
			{
				RegisterAmmoListener( true );
			}
			if ( !inventoryListener )
			{
				RegisterInventoryListener( true );
			}
		}
		return isFulfilled;
	}

	function EvaluateImpl()
	{
		var ammo : int;
		var ids : array<SItemUniqueId>;
		
		ids = thePlayer.inv.GetItemsByName( itemName );
		ammo = thePlayer.inv.SingletonItemGetAmmo( ids[0] );
		isFulfilled = ProcessCompare( comparator, ammo, ammoQuantity );
	}
}