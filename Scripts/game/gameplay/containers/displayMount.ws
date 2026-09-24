/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3DisplayMount extends W3Container
{
	var ids    				 : array<SItemUniqueId>;
	var i					 : int;
	
	
	event OnSpawned( spawnData : SEntitySpawnData ) 
	{		
		super.OnSpawned(spawnData);

		
		lockedByKey = false;
		UpdateDisplayMount();
	}
	
	event OnStreamIn()
	{
		super.OnStreamIn();
	}
	
	event OnUpdateContainer()
	{
		super.OnUpdateContainer();
		
		UpdateDisplayMount();
	}
	
	function UpdateDisplayMount()
	{
		if( inv && !inv.IsEmpty() )
		{
			inv.GetAllItems(ids);
			
			inv.MountItem(ids[0],true);
			
			for (i=ids.Size()-1; i>0; i-=1)
			{
				if ((inv.GetItemCategory(ids[i]) == 'steel_scabbards') ||  ( inv.GetItemCategory(ids[i]) == 'silver_scabbards'))
				{
					inv.RemoveItem(ids[i]);
					
				}
			}
		}
	}
}