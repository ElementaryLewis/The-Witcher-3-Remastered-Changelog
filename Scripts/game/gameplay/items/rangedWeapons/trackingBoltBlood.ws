/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3DynamicBlood extends W3MonsterClue
{
	editable var lifetime : float;
	
	default lifetime = 30;
	hint lifetime = "Time since creation after which this entity will be destroyed, must be set";
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{		
		super.OnSpawned( spawnData );
		
		if(lifetime <= 0)
			lifetime = 30;
			
		DestroyAfter(lifetime);
	}
}

class W3Blood extends CEntity
{
	editable var lifetime : float;
	
	default lifetime = 30;
	hint lifetime = "Time since creation after which this entity will be destroyed, must be set";
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{		
		super.OnSpawned( spawnData );
		
		if(lifetime <= 0)
			lifetime = 30;
			
		AddTimer('DestroyTimer2', 30);
	}
	
	timer function DestroyTimer2(dt : float, id : int)
	{
		if(thePlayer.WasVisibleInScaledFrame(this, 1, 1))
			AddTimer('DestroyWhenNotVisible', 2, true);
		else
			Destroy();
	}
	
	timer function DestroyWhenNotVisible(dt : float, id : int)
	{
		if(!thePlayer.WasVisibleInScaledFrame(this, 1, 1))
		{
			Destroy();
			RemoveTimer('DestroyWhenNotVisible');
		}
	}
}