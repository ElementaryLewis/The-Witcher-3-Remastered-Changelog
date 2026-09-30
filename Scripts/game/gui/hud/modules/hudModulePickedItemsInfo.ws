/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4HudModulePickedItemsInfo extends CR4HudModuleBase 
{
	
	private var _RecentlyAddedItemListSize : int;
	
	public var bCurrentShowState : bool;			default bCurrentShowState = false;
	public var bShouldShowElement : bool;			default bShouldShowElement = false;
	private const var _PickedItemListSize : int;	default _PickedItemListSize = 4;

	 event OnConfigUI()
	{
		super.OnConfigUI();

		
		
		

		ShowElement(false);
	}

	event OnTick( timeDelta : float )
	{
		var inv : CInventoryComponent;
		var itemList : array<SItemUniqueId>;
		var i : int;
		var dpSize : int;
		
		inv = GetWitcherPlayer().inv;
		
		if( (inv.GetRecentlyAddedItemsListSize() != _RecentlyAddedItemListSize ) && bShouldShowElement == bCurrentShowState )
		{
			_RecentlyAddedItemListSize = inv.GetRecentlyAddedItemsListSize();
			itemList = inv.GetRecentlyAddedItems();
			
			
		}
	}
	
	public function ShowElement( bShow : bool, optional bImmediately : bool )
	{
		bShouldShowElement = bShow;
		if( bShow )
		{
			super.ShowElement( bCurrentShowState, bImmediately );
			return;
		}
		super.ShowElement( bShow, bImmediately );
	}
	
	event OnRemovePickedItemsInfoFirstItem()
	{
		var inv : CInventoryComponent;
		inv = GetWitcherPlayer().inv;
		
		
	}
}