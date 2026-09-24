/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3GuiEnchantingInventoryComponent extends W3GuiBaseInventoryComponent
{
	private var REQUIRED_SLOTS_COUNTS : int;
	default REQUIRED_SLOTS_COUNTS = 3;
	
	public function CheckSlotsCount( item : SItemUniqueId ):bool
	{		
		return _inv.GetItemEnhancementSlotsCount( item ) >= REQUIRED_SLOTS_COUNTS;
	}
	
	
	public function ShouldShowItem( item : SItemUniqueId ) : bool
	{
		var catName:name;
		
		catName = _inv.GetItemCategory(item);
		return super.ShouldShowItem(item) && (catName== 'steelsword' || catName== 'silversword' || catName== 'armor') && !_inv.ItemHasTag(item, 'SecondaryWeapon');
	}
	
	
	public function SetInventoryFlashObjectForItem( item : SItemUniqueId, out flashObject : CScriptedFlashObject) : void
	{
		var isEquipped:bool;
		var isNotEnoughSockets:bool;
		var slotsCount:int;
		
		super.SetInventoryFlashObjectForItem(item, flashObject);
		
		slotsCount = _inv.GetItemEnhancementSlotsCount( item );
		isNotEnoughSockets = slotsCount < REQUIRED_SLOTS_COUNTS;
		isEquipped = GetWitcherPlayer().IsItemEquipped(item);
		
		flashObject.SetMemberFlashString( "itemName", GetLocStringByKeyExt( _inv.GetItemLocalizedNameByUniqueID( item ) ) );
		flashObject.SetMemberFlashString( "description", GetLocStringByKeyExt("panel_enchanting_warning_not_enough_sockets") + " " + slotsCount + " / " + REQUIRED_SLOTS_COUNTS);
		flashObject.SetMemberFlashBool( "isEquipped",  isEquipped);
		flashObject.SetMemberFlashBool( "isNotEnoughSockets",  isNotEnoughSockets);
		flashObject.SetMemberFlashBool( "disableAction", isNotEnoughSockets);
		flashObject.SetMemberFlashUInt( "enchantmentId", NameToFlashUInt(_inv.GetEnchantment(item)));
		
	}
}