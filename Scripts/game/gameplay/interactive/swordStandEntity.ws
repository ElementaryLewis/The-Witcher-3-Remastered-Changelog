/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SwordStand extends W3HouseDecorationBase
{

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		ChangeItemSelectionMode( EISPM_SwordStand );
		
		
		AddItemSelectionFilterTag( 'sword1h' );
		AddItemSelectionForbiddenFilterTag( 'SecondaryWeapon' );		
	}

	
	public function ProcessItemReceival( optional mute : bool )
	{
		super.ProcessItemReceival();
		MountNewItem( !mute );
	}
	
	
	private function MountNewItem( optional playSound : bool )
	{
		var items : array<SItemUniqueId>;
		
		items = GetInventory().GetItemsByCategory( 'steelsword' );
		
		if( items.Size() >= 1 )
		{
			if( GetInventory().MountItem( items[0], false, true ) )
			{
				if( playSound )
				{
					theSound.SoundEvent("gui_inventory_steelsword_back");
				}
			}
		}
		else
		{
			items = GetInventory().GetItemsByCategory( 'silversword' );
			
			if( items.Size() >= 1 )
			{
				if( GetInventory().MountItem( items[0], false, true ) )
				{
					if( playSound )
					{				
						theSound.SoundEvent("gui_inventory_silversword_back");
					}
				}	
			}
		}
		
	}

	
	private function GetIsDecoractionEmpty() : bool
	{
		return GetIsWeaponStandEmpty();
	}

	
	private function GetIsWeaponStandEmpty() : bool
	{		
		var items : array<SItemUniqueId>;
		
		items = GetInventory().GetItemsByTag( 'sword1h' );
		
		if( items.Size() == 0 )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	
	private function GetIfPlayerHasValidItems() : bool
	{
		var items : array<SItemUniqueId>;
		
		items = thePlayer.inv.GetItemsByTag( 'sword1h' );
		
		return thePlayer.inv.GetHasValidDecorationItems( items, this );
	}		
	
	
}


	