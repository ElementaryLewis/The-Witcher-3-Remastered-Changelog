/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Rat extends CNewNPC
{
	editable saved var hasCollision : bool; default hasCollision = false;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{		
		super.OnSpawned( spawnData );
		SetInteractionPriority(IP_Prio_0);
		EnableCharacterCollisions(hasCollision);
	}
	
	
	
	event OnChangeDyingInteractionPriorityIfNeeded()
	{
		this.EnableCollisions(false);
	}
}