/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3GuiAddSocketsInventoryComponent extends W3GuiPlayerInventoryComponent
{
	public var merchantInv : CInventoryComponent;
	private var maxUpgradedItems : array<SItemUniqueId>;
	
	protected  function ShouldShowItem( item : SItemUniqueId ):bool
	{
		var itemTags    	 : array <name>;
		var showItem 		 : bool;
		var slotsCount  	 : int;
		var isArmorOrWeapon  : bool;
		
		_inv.GetItemTags( item, itemTags );
		slotsCount = _inv.GetItemEnhancementSlotsCount( item );
		isArmorOrWeapon = _inv.IsItemAnyArmor(item) || _inv.IsItemWeapon(item);
		
		showItem = !itemTags.Contains( theGame.params.TAG_DONT_SHOW )
				&& !itemTags.Contains( theGame.params.TAG_DONT_SHOW_ONLY_IN_PLAYERS )
				&& !_inv.IsItemQuest( item )
				&& (slotsCount < _inv.GetSlotItemsLimit( item ) || maxUpgradedItems.Contains(item)) && isArmorOrWeapon;
		
		return showItem;
	}
	
	public  function SetInventoryFlashObjectForItem( item : SItemUniqueId, out flashObject : CScriptedFlashObject) : void
	{
		var invItem 	      : SInventoryItem;
		var isEquipped        : bool;
		var targetGridSection : int;
		
		super.SetInventoryFlashObjectForItem( item, flashObject );
		
		isEquipped = GetWitcherPlayer().IsItemEquipped(item);
		
		
		invItem = _inv.GetItem( item );
		flashObject.SetMemberFlashInt( "actionPrice", merchantInv.GetItemPriceAddSlot( invItem ) );
		flashObject.SetMemberFlashBool( "isEquipped",  isEquipped);
		flashObject.SetMemberFlashInt( "socketsMaxCount", _inv.GetSlotItemsLimit( item ) );
		
		if ( maxUpgradedItems.Contains(item) )
		{
			flashObject.SetMemberFlashBool( "isReaded", true ); 
			flashObject.SetMemberFlashBool( "disableAction", true );
		}
		
		if( GetWitcherPlayer().IsItemEquipped( item ) )
		{
			targetGridSection = 0;
		}
		else
		{
			targetGridSection = 1;
		}
		
		flashObject.SetMemberFlashInt( "sectionId", targetGridSection );
	}
	
	public function AddSocket(item : SItemUniqueId) : void
	{
		_inv.AddSlot(item);
		
		if ( _inv.GetItemEnhancementSlotsCount( item ) >= _inv.GetSlotItemsLimit( item ) )
		{
			maxUpgradedItems.PushBack( item );
		}
	}
}