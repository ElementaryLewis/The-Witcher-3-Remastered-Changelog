/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskEquipItem extends IBehTreeTask
{
	var itemCategory : name;
	
	function IsAvailable() : bool
	{
		var npc : CNewNPC;
		var itemIds : array<SItemUniqueId>;
		var inv : CInventoryComponent;
		var i : int;
		
		npc = GetNPC();
		inv = npc.GetInventory();
		
		itemIds = inv.GetAllWeapons();
		
		if( itemIds.Size() == 0 )
		{
			LogAssert(false, "CBTTaskEquipItem.IsAvailable: actor <<" + npc + ">> has no weapons at all, cannot equip");			
			return false;	
		}
		
		
		for(i=0; i<itemIds.Size(); i+=1)
			if(inv.IsItemHeld(itemIds[i]))
				return true;
			
		return npc.EquipItem(itemIds[0], EES_InvalidSlot, true);		
	}
}
class CBTTaskEquipItemDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskEquipItem';

	editable var itemCategory : name;
}