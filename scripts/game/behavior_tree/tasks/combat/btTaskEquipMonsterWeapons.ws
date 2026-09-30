/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBehTreeTaskEquipMonsterWeapons extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		var ids : array<SItemUniqueId>;
		var inv : CInventoryComponent;
		var i : int;
	
		inv = GetNPC().GetInventory();
		ids = inv.GetItemsByCategory('monster_weapon');
		
		
		for(i=0; i<ids.Size(); i+=1)
			if(!inv.IsItemHeld(ids[i]))
				return true;
				
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{		
		var slots, items : array<name>;
		var ids : array<SItemUniqueId>;
		var inv : CInventoryComponent;
		var i : int;
		var itemName : name;
		var dm : CDefinitionsManagerAccessor;
				
		inv = GetNPC().GetInventory();
		ids = inv.GetItemsByCategory('monster_weapon');
		dm = theGame.GetDefinitionsManager();
		
		for(i=0; i<ids.Size(); i+=1)
		{
			itemName = inv.GetItemName(ids[i]);
			slots.PushBack( dm.GetItemHoldSlot(itemName, false) );	
			items.PushBack(itemName);
		}
		GetNPC().IssueRequiredItemsGeneric(items, slots);
		
		return BTNS_Active;
	}
}

class CBehTreeTaskEquipMonsterWeaponsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeTaskEquipMonsterWeapons';
}