/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EPreporationItemType
{
	PIT_Undefined,
	PIT_Bomb,
	PIT_Potion,
	PIT_Oil,
	PIT_Mutagen,
};

class W3GuiPreparationInventoryComponent extends W3GuiPlayerInventoryComponent
{
	protected var _equippedFilter      :  bool;
	protected var _categoryFilter 	   :  bool;
	protected var _categoryFilterValue :  EPreporationItemType;
	
	public function GetContainerItems(out flashArray : CScriptedFlashArray, flashObject : CScriptedFlashObject, optional groupFilter : EPreporationItemType) : void
	{
		SetupFilter(false, groupFilter);
		GetInventoryFlashArray(flashArray, flashObject);
	}
	
	public function GetSlotsItems(out flashArray : CScriptedFlashArray, flashObject : CScriptedFlashObject, optional groupFilter : EPreporationItemType) : void
	{
		SetupFilter(true, groupFilter);
		GetInventoryFlashArray(flashArray, flashObject);
		GetOilSlotItemsFlashArray(flashArray, flashObject);
	}
	
	protected function GetOilSlotItemsFlashArray(out flashArray : CScriptedFlashArray, flashObject : CScriptedFlashObject)
	{
		var weaponId : SItemUniqueId;
		var l_flashObject : CScriptedFlashObject;
		var oilName : name;
	
		
		if (_inv.GetItemEquippedOnSlot(EES_SilverSword, weaponId))
		{
			oilName = _inv.GetOldestOilAppliedOnItem( weaponId, false ).GetOilItemName();
			if (oilName != '')
			{
				l_flashObject = flashObject.CreateFlashObject("red.game.witcher3.menus.common.ItemDataStub");
				FillItemInfoFromOilName( oilName, EES_SilverSword, l_flashObject );
				flashArray.PushBackFlashObject(l_flashObject);
			}
		}
		
		
		if (_inv.GetItemEquippedOnSlot(EES_SteelSword, weaponId))
		{
			oilName = _inv.GetOldestOilAppliedOnItem( weaponId, false ).GetOilItemName();
			if (oilName != '')
			{
				l_flashObject = flashObject.CreateFlashObject("red.game.witcher3.menus.common.ItemDataStub");
				FillItemInfoFromOilName( oilName, EES_SteelSword, l_flashObject );
				flashArray.PushBackFlashObject(l_flashObject);
			}
		}
	}
	
	
	protected function FillItemInfoFromOilName(oilName:name, slotType : EEquipmentSlots, out flashObject : CScriptedFlashObject):void
	{
		flashObject.SetMemberFlashInt( "prepItemType", PIT_Oil );
		flashObject.SetMemberFlashInt( "sortIdx", PIT_Oil );
		flashObject.SetMemberFlashString( "dropDownLabel", GetPrepCategoryLabel(PIT_Oil) );
		flashObject.SetMemberFlashInt( "equipped", slotType );
		flashObject.SetMemberFlashInt( "id", -1 );
		flashObject.SetMemberFlashInt( "quantity", 1 ); 
		flashObject.SetMemberFlashString( "iconPath",  _inv.GetItemIconPathByName(oilName) );
		flashObject.SetMemberFlashInt( "gridPosition", 0 );
		flashObject.SetMemberFlashInt( "gridSize", 1 );
		flashObject.SetMemberFlashInt( "slotType", slotType );
		flashObject.SetMemberFlashBool( "isNew", false );
		flashObject.SetMemberFlashBool( "isOilApplied", false );
		flashObject.SetMemberFlashInt( "quality", 1 ); 
		flashObject.SetMemberFlashInt( "socketsCount", 0 );
		flashObject.SetMemberFlashInt( "socketsUsedCount", 0 );
	}

	public function SetInventoryFlashObjectForItem( item : SItemUniqueId, out flashObject : CScriptedFlashObject) : void
	{
		var equipped 			: int;
		var slotType 			: EEquipmentSlots;
		var itemPrepType		: EPreporationItemType;
		var itemCategoryLabel	: string;
		var itemName			: name;
		
		var itemTags			: array<name>;
		var i					: int;
		var silverOil			: bool;
		var steelOil			: bool;
		
		super.SetInventoryFlashObjectForItem( item, flashObject );
		
		itemName = _inv.GetItemName(item);
		equipped = (int)GetWitcherPlayer().GetItemSlot( item );
		itemPrepType = GetItemPrepCategory( item );
		itemCategoryLabel = GetPrepCategoryLabel( itemPrepType );
		
		flashObject.SetMemberFlashInt( "prepItemType", itemPrepType );
		flashObject.SetMemberFlashInt( "sortIdx", itemPrepType );
		flashObject.SetMemberFlashString( "dropDownLabel", itemCategoryLabel );
		
		silverOil = false;
		steelOil = false;
			
		if (isOilItem(item) && _inv.GetItemTags(item, itemTags))
		{
			for( i = 0; i < itemTags.Size(); i += 1 )
			{
				if (itemTags[i] == 'SteelOil')
				{
					steelOil = true;
				}
				else if (itemTags[i] == 'SilverOil')
				{
					silverOil = true;
				}
			}
		}
		
		flashObject.SetMemberFlashBool( "steelOil", steelOil );
		flashObject.SetMemberFlashBool( "silverOil", silverOil );
	}
	
	public function GetItemPrepCategory( item : SItemUniqueId ):EPreporationItemType
	{
		var itemName : name;
		itemName = _inv.GetItemName(item);
		
		if (isOilItem(item))
			return PIT_Oil;
		else if (isPotionItem( item ))
			return PIT_Potion;
		else if (_inv.IsItemBomb(item))
			return PIT_Bomb;
		else if (_inv.ItemHasTag( item, 'Mutagen'))
			return PIT_Mutagen;
		else
			return PIT_Undefined;
	}
	
	
	public function AddDummyCategoryItem(item : SItemUniqueId, out flashObject : CScriptedFlashObject, out flashArray : CScriptedFlashArray) : void
	{
		var l_flashObject		: CScriptedFlashObject;
		var itemPrepType		: EPreporationItemType;
		var itemCategoryLabel	: string;
		
		l_flashObject = flashObject.CreateFlashObject("red.game.witcher3.menus.common.ItemDataStub");
		itemPrepType = GetItemPrepCategory( item );
		itemCategoryLabel = GetPrepCategoryLabel( itemPrepType );
		
		l_flashObject.SetMemberFlashInt( "prepItemType", itemPrepType );
		l_flashObject.SetMemberFlashInt( "sortIdx", itemPrepType );
		l_flashObject.SetMemberFlashBool( "invisible", true );
		l_flashObject.SetMemberFlashString( "dropDownLabel", itemCategoryLabel );		
		
		flashArray.PushBackFlashObject(l_flashObject);
	}
	
	protected function SetupFilter( checkEquipped : bool, groupFilter : EPreporationItemType ) : void
	{
		_equippedFilter = checkEquipped;
		if (groupFilter != PIT_Undefined)
		{
			_categoryFilter = true;
			_categoryFilterValue = groupFilter;
		}
		else
		{
			_categoryFilter = false;
		}
	}
	
	protected function GetPrepCategoryLabel( targetCategory : EPreporationItemType):string 
	{
		switch (targetCategory)
		{
			case PIT_Bomb:
				return "[[item_category_petard]]";
				break;
			case PIT_Potion:
				return "[[item_category_potion]]";
				break;
			case PIT_Oil:
				return "[[item_category_oil]]";
				break;
			case PIT_Mutagen:
				return "[[panel_preparation_mutagens_sublist_name]]"; 
				break;
		}
		return "";
	}
	
	protected function ShouldShowItem( item : SItemUniqueId ):bool
	{
		var	l_CategoryCheck : bool;
		var	l_EquippedCheck : bool;
		var l_IsEquipped	: bool;
		var l_ItemCategory	: EPreporationItemType;
		
		l_IsEquipped = isEquipped( item );
		l_ItemCategory = GetItemPrepCategory(item);
		l_EquippedCheck = (_equippedFilter && l_IsEquipped) || (!_equippedFilter && !l_IsEquipped);
		l_CategoryCheck = !_categoryFilter || (_categoryFilterValue == l_ItemCategory);
		
		return l_ItemCategory != PIT_Undefined && l_EquippedCheck && l_CategoryCheck;
	}
	
	public function GetItemActionType( item : SItemUniqueId, optional bGetDefault : bool ) : EInventoryActionType
	{
		if( _inv.ItemHasTag( item, 'Mutagen') )
		{
			return IAT_Equip;
		}
		return super.GetItemActionType( item, bGetDefault );
	}
}
