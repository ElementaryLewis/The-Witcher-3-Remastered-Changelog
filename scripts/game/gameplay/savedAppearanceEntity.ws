/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SavedAppearanceEntity extends CGameplayEntity
{
	saved var appearanceName	: name;
	default appearanceName		= '';
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{		
		
		if ( IsNameValid( appearanceName ) && spawnData.restored )
		{
			ApplyAppearance( appearanceName );		
		}
	}
	
	public function SetAppearance( appName : name )
	{
		appearanceName = appName;
		ApplyAppearance( appName );
	}
}