/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskDrawItem extends IBehTreeTask
{
	var owner : CNewNPC;
	var inventory : CInventoryComponent;
	var temp : array<SItemUniqueId>;
	
	var itemName : CName;
	var eventName : CName; 
	
	latent function Main() : EBTNodeStatus
	{
		owner = GetNPC();
		inventory = owner.GetInventory();
		AddItemIfNeeded();
		temp = inventory.GetItemsIds( itemName );
		owner.itemToEquip = temp[0];
		owner.RaiseEvent( eventName );
		
		return BTNS_Completed;
	}
	
	function AddItemIfNeeded()
	{
		if( inventory.HasItem( itemName ) )
		{
			return;
		}
		else
		{
			inventory.AddAnItem( itemName );
		}
	}
}

class CBTTaskDrawItemDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskDrawItem';

	default instanceClass = 'CBTTaskDrawItem';
	
	editable var itemName : CName;
	editable var eventName : CName;
}

class CBTTaskHideItem extends IBehTreeTask
{
	var owner : CNewNPC;
	
	var eventName : CName;
	
	latent function Main() : EBTNodeStatus
	{
		owner = GetNPC();
		owner.RaiseEvent( eventName );
		
		return BTNS_Completed;
	}
}

class CBTTaskHideItemDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskHideItem';

	editable var eventName : CName;
}