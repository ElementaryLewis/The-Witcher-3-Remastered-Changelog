/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3GuiPreparationOilsInventoryComponent extends W3GuiPlayerInventoryComponent
{	
	protected function ShouldShowItem( item : SItemUniqueId ):bool
	{
		var bShow : bool;
		var itemName : name;
		itemName = _inv.GetItemName(item);
		return isOilItem(item);
	}
}