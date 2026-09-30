/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3RootsEntrance extends CGameplayEntity
{
	saved var isOpened : bool;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if( spawnData.restored )
		{
			if( isOpened )
				Open();
		}
	}
	
	public function Open()
	{
		SetBehaviorVariable( 'moveRootsAway', 1.0 );
		isOpened = true;
	}
	public function Close()
	{
		SetBehaviorVariable( 'moveRootsAway', 0.0 );
		isOpened = false;
	}
}