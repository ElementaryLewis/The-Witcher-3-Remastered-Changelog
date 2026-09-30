/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ArmorStand extends W3HouseDecorationBase
{
	private editable var m_mountAllItems : bool;
	
	hint m_mountAllItems = "Should this stand mount all items, not only armor.";
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		ChangeItemSelectionMode( EISPM_ArmorStand );
		
		
		AddItemSelectionForbiddenFilterTag( 'NoShow' );	
		AddItemSelectionForbiddenFilterTag( 'Body' );	
		
		
		AddItemSelectionCategory( 'armor' );
		AddItemSelectionCategory( 'pants' );
		AddItemSelectionCategory( 'gloves' );			
		AddItemSelectionCategory( 'boots' );
		
	}

	
	public function ProcessItemReceival( optional mute : bool )
	{
		super.ProcessItemReceival();
		ProcessItemMounting( !mute );
	}
	
	
	private function ProcessItemMounting( optional playSound : bool )
	{
		if( m_mountAllItems )
		{
			MountAllStandItems( playSound );
		}
		else
		{
			MountArmorItem( playSound );
		}	
	}
	
	
	private function MountArmorItem( playSound : bool )
	{
		var items : array<SItemUniqueId>;
		var invComp : CInventoryComponent;

		invComp = GetInventory();
		
		if ( invComp )
		{
			items = invComp.GetItemsByCategory( 'armor' );
				
			if( invComp.MountItem( items[0], false, true ) )
			{
				if( playSound )
				{
					theSound.SoundEvent("gui_inventory_armor_back");
				}
			}
		}
	}

	
	private function MountAllStandItems( playSound : bool )
	{
		var items : array<SItemUniqueId>;
		var i : int;
		var itemWasMounted : bool;
		var invComp : CInventoryComponent;

		invComp = GetInventory();
		
		if ( invComp )
		{
			invComp.GetAllItems( items );
		
			for( i=0; i < items.Size(); i+= 1 )
			{
				if( invComp.MountItem( items[i], false, true ) )
				{
					itemWasMounted = true;
				}
			}
		}

		
		if( itemWasMounted && playSound )
		{
			theSound.SoundEvent("gui_inventory_armor_back");
		}
	}

	
	private function UnmountStandItems()
	{
		var items : array<SItemUniqueId>;
		var i : int;
		
		GetInventory().GetAllItems(items);
		
		for( i=0; i < items.Size(); i+= 1 )
		{
			GetInventory().UnmountItem( items[i], true );
		}
		
	}	
	
	
	private function GetIsDecoractionEmpty() : bool
	{
		return GetIsArmorStandEmpty();
	}

	
	private function GetIsArmorStandEmpty() : bool
	{
		var items : array<SItemUniqueId>;	
		var i : int;
		
		GetInventory().GetAllItems( items );
		
		for( i=0; i < items.Size(); i+= 1 )
		{
			if( GetInventory().GetItemName( items[i] ) != '_armor_stand' )
			{
				return false;
			}
		}
		
		return true;
	}
	
	
	private function GetIfPlayerHasValidItems() : bool
	{
		var i, size : int;
		var items : array<SItemUniqueId>;
		
		items = thePlayer.inv.GetItemsByCategory( 'armor' );
		
		return thePlayer.inv.GetHasValidDecorationItems( items, this );
	}	
	
	
	private function ForceTransferAllItems( triggeringItem : SItemUniqueId )
	{
		var items : array<SItemUniqueId>;	
		var i : int;
		
		GetInventory().GetAllItems( items );
		
		for( i=0; i < items.Size(); i+= 1 )
		{
			if( GetInventory().GetItemName( items[i] ) != '_armor_stand' && triggeringItem != items[i] )
			{
				GetInventory().GiveItemTo( thePlayer.GetInventory(), items[i], 1 );
			}
		}
		
	}

	
	event OnItemTaken(itemId : SItemUniqueId, quantity : int)
	{
		super.OnItemTaken(itemId, quantity);
		
		if( GetInventory().GetItemCategory( itemId ) == 'armor' )
		{
			ForceTransferAllItems( itemId );
			UpdateContainer();
		}
	}	
	
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		ProcessItemMounting( false );
	}
	
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		UnmountStandItems();
	}		

}


	

	