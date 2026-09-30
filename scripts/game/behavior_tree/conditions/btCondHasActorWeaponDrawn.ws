/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondHasActorWeaponDrawn extends IBehTreeTask
{	
	function IsAvailable() : bool
	{
		var actor : CActor = GetActor();
		
		if( actor.HasWeaponDrawn( false ) ) 
		{	
			return true;
		}
		return false;
	}
};

class CBTCondHasActorWeaponDrawnDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondHasActorWeaponDrawn';
};