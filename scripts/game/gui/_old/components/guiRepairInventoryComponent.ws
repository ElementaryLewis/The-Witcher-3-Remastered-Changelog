/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3GuiRepairInventoryComponent extends W3GuiBaseInventoryComponent
{	
	public var merchantInv  : CInventoryComponent;
	public var masteryLevel : int;
	public var repairSwords : bool;
	public var repairArmors : bool;
	
	public  function SetInventoryFlashObjectForItem( item : SItemUniqueId, out flashObject : CScriptedFlashObject) : void
	{
		var durabilityValue	  : string;
		var costOfService	  : int;
		var costRepairPoint   : int;
		var isEquipped        : bool;
		var invItem 	 	  : SInventoryItem;
		var targetGridSection : int;
		
		super.SetInventoryFlashObjectForItem( item, flashObject );
		
		invItem = _inv.GetItem( item );
		merchantInv.GetItemPriceRepair( invItem, costRepairPoint, costOfService );		
		isEquipped = GetWitcherPlayer().IsItemEquipped( item );
		
		flashObject.SetMemberFlashBool( "enableComparison", _inv.CanBeCompared( item ) );
		flashObject.SetMemberFlashBool( "isEquipped",  isEquipped);		
		flashObject.SetMemberFlashBool( "disableAction", _inv.GetItemQuality( item ) > masteryLevel );
		flashObject.SetMemberFlashInt( "actionPrice", costOfService );
		flashObject.SetMemberFlashInt( "gridPosition", -1 );
		
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
	
	public function GetTotalRepairCost() : int
	{
		var i 			: int;
		var rawItems 	: array< SItemUniqueId >;
		var item 		: SItemUniqueId;
		var invItem		: SInventoryItem;
		var costOfService	: int;
		var costRepairPoint : int;
		var totalCost 	: int;
		
		_inv.GetAllItems( rawItems );
		totalCost = 0;
		
		for ( i = 0; i < rawItems.Size(); i += 1 )
		{		
			item = rawItems[i];
			
			if ( ShouldShowItem( item ) && GetWitcherPlayer().IsItemEquipped( item ) )
			{
				invItem = _inv.GetItem( item );
				merchantInv.GetItemPriceRepair( invItem, costRepairPoint, costOfService );
				totalCost += costOfService;
			}
		}
		
		return totalCost;
	}
	
	protected function ShouldShowItem( item : SItemUniqueId ) : bool
	{	
		var durabilityFlag : bool;
		var itemName : name;		
		itemName = GetItemName( item );
		durabilityFlag = false;
		
		if( CanRepairItem( item ) )
		{
			if( _inv.HasItemDurability(item) )
			{
				if( _inv.GetItemDurability(item) < _inv.GetItemMaxDurability( item ) )
				{
					durabilityFlag = true;
				}
			}
		}
		durabilityFlag = super.ShouldShowItem( item ) && durabilityFlag;
		return durabilityFlag;
	}
	
	function RepairItem( item : SItemUniqueId, priceModiffier : float  )
	{
		_inv.SetItemDurabilityScript(item, _inv.GetItemMaxDurability(item) );
		_inv.RemoveMoney( (int)(_inv.GetRepairPrice( item ) * priceModiffier) );
	}
	
	function RepairAllItems( priceModiffier : float )
	{
		var items     : array<SItemUniqueId>;
		var curItemId : SItemUniqueId;
		var i : int;
		
		_inv.GetAllItems(items);
		
		for( i = 0; i < items.Size(); i += 1 )
		{
			curItemId = items[i];
			
			if( CanRepairItem( curItemId ) && _inv.HasItemDurability( curItemId ) && GetWitcherPlayer().IsItemEquipped( curItemId )  )
			{					
				if( _inv.GetItemDurability( curItemId ) < _inv.GetItemMaxDurability( curItemId ) )
				{
					RepairItem( curItemId, priceModiffier );
				}	
			}
		}
	}
	
	function CanRepairItem( item : SItemUniqueId ) : bool
	{		
		if(( repairArmors && _inv.IsItemAnyArmor( item ))
		|| repairSwords && ( _inv.IsItemSteelSwordUsableByPlayer( item ) || _inv.IsItemSilverSwordUsableByPlayer( item ) || _inv.IsItemSecondaryWeapon(item) ) )
		{
			
			
			
			
			
			return true;
		}
		return false;
	}

	function GetRepairPrice( item : SItemUniqueId ) : float
	{
		return _inv.GetRepairPrice( item );
	}
	
	function GetRepairAllPrice() : float
	{
		var items : array<SItemUniqueId>;
		var i : int;
		var price : float;
		
		price = 0;
		_inv.GetAllItems(items);
		
		for( i = 0; i < items.Size(); i += 1 )
		{
			if( CanRepairItem(items[i]) )
			{
				if( _inv.HasItemDurability(items[i]) )
				{					
					if( _inv.GetItemDurability(items[i]) < _inv.GetItemMaxDurability(items[i]) )
					{
						price += GetRepairPrice(items[i]);
					}	
				}
			}	
		}
		return price;
	}
}