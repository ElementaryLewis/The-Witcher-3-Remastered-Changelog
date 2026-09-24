/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3GuiItemSelectComponent extends W3GuiPlayerInventoryComponent
{	
	protected var _filterData:W3ItemSelectMenuInitData;

	public function InitFilter(filterValue:W3ItemSelectMenuInitData)
	{
		_filterData = filterValue;
	}

	protected function ShouldShowItem( item : SItemUniqueId ) : bool
	{
		if (!_filterData) 
		{
			return true;
		}
		else
		if (_filterData.onlyEquipped && !isEquipped(item))
		{
			return false;
		}
		else
		if (_filterData.onlyUnequipped && isEquipped(item))
		{
			return false;
		}
		else
		if (!chekTags(item, _filterData.containTags))
		{
			return false;
		}
		return true;
	}
	
	protected function isEquipped( item : SItemUniqueId ) : bool
	{
		return GetWitcherPlayer().IsItemEquipped(item);
	}
	
	protected function chekTags( item : SItemUniqueId, targetTags : array<name> ) : bool
	{
		var idx:int;
		for (idx = 0; idx < targetTags.Size(); idx += 1)
		{
			if (!_inv.ItemHasTag( item, targetTags[idx]))
			{
				return false;
			}
		}
		return true;
	}
}