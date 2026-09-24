/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SE_ManageOilBarrel extends W3SwitchEvent
{
	editable var oilBarrelTag	: name;
	editable var operations	: array< EOilBarrelOperation >;
	
	hint oilBarrelTag	= "Tag of the oil barrel";
	hint operations	= "Operations to perform on oil barrel";
	
	public function Perform( parnt : CEntity)
	{
		var oilBarrelEntity	: COilBarrelEntity;
		var entities	: array<CEntity>;
		var i 			: int;
		
		theGame.GetEntitiesByTag( oilBarrelTag, entities );
		
		if ( entities.Size() == 0 )
		{
			LogAssert(false, "No entity found with tag <" + oilBarrelTag + ">" );
			return;
		}
		
		for ( i = 0; i < entities.Size(); i += 1 )
		{
			oilBarrelEntity = (COilBarrelEntity)entities[ i ];
			if ( !oilBarrelEntity )
			{
				LogAssert(false, "Entity with tag <" + oilBarrelTag + "> is not a W3TrapProjectileStatue" );
				return;
			}
			oilBarrelEntity.OnManageOilBarrel( operations );
		}
	}
}