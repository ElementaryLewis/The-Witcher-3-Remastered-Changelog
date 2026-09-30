/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SHouseDecorationItemData
{
	editable var decorationItemName : name;
	editable var decorationAppearance : name;
}

class W3HouseGenericDecoration extends W3HouseDecorationBase
{
	private editable var m_itemFilterTag : name;
	private editable var m_decorationItems : array<SHouseDecorationItemData>;
	private saved var m_currentApperance : name;
	
	hint m_itemFilterTag = "Tag that an item needs to have to be a valid decoration for this entity."; 
	hint m_itemFilterTag = "Definitions of decoration items and their corresponding appearances."; 
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		if( m_itemFilterTag )
		{
			AddItemSelectionFilterTag( m_itemFilterTag );
		}
		
		ChangeItemSelectionMode( EISPM_Painting );
		
		
		ApplyAppearance( m_currentApperance );
	}
	
	
	event OnItemTaken(itemId : SItemUniqueId, quantity : int)
	{
		super.OnItemTaken(itemId, quantity);
		ApplyNewPaintingAppearance( true );
	}
	
	
	public function ProcessItemReceival( optional mute : bool )
	{
		super.ProcessItemReceival();
		ApplyNewPaintingAppearance( false, !mute );
	}
	
	
	private function ApplyNewPaintingAppearance( optional reset : bool, optional playSound : bool )
	{
		var i, size : int;
		var items : array<SItemUniqueId>;
		var itemName : name;
		
		if( reset )
		{
			m_currentApperance = 'empty';
			ApplyAppearance( m_currentApperance  );
			
			return;
		}
		
		GetInventory().GetAllItems( items );
		size = m_decorationItems.Size();
		
		itemName = GetInventory().GetItemName( items[0] );
		
		for( i=0; i < size; i+=1 )
		{
			if( m_decorationItems[i].decorationItemName == itemName )
			{
				m_currentApperance  = m_decorationItems[i].decorationAppearance;
				ApplyAppearance( m_currentApperance  );
				
				if( playSound )
				{
					theSound.SoundEvent("gui_inventory_other_back");
				}
				
				return;
			}
		}
		
		
		m_currentApperance  = 'empty';
		ApplyAppearance( m_currentApperance );
	}

	
	private function GetIfPlayerHasValidItems() : bool
	{
		var items : array<SItemUniqueId>;
		
		
		if( !IsNameValid( m_itemFilterTag ) )
		{
			LogChannel( 'houseDecorations', "No valid item filter tag provided!" );
			return false;
		}
		
		items = thePlayer.inv.GetItemsByTag( m_itemFilterTag );
		
		return thePlayer.inv.GetHasValidDecorationItems( items, this );
		
	}

}