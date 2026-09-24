/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3EntitySpawner extends W3UsableEntity
{
	editable var entityTemplate			: CEntityTemplate;
	editable var appearanceAfterSpawn	: name;
	editable var autoSpawn				: bool;
	editable var spawnDelay				: float;
	editable var numberOfUses			: int;
	editable var spawnNearPlayer		: bool;
	editable var avoidNodeWithTag		: name;
	
	default numberOfUses = 1;
	
	hint numberOfUses = "Set to -1 to have infinite number of uses";
	hint appearanceAfterSpawn = "Changes the appearance to given one, after number of uses is depleted";
	hint autoSpawn = "Spawns the object after spawner is created on location";
	hint spawnDelay = "Waits for specified time, before spawning the object";
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if( autoSpawn )
		{
			if( spawnDelay > 0.0f )
			{
				AddTimer('TimerSpawnEntity', spawnDelay, false );
			}
		}
		super.OnSpawned( spawnData );
	}
	
	public function CanBeUsed() : bool
	{
		return numberOfUses != 0;
	}
	
	timer function TimerSpawnEntity( td : float , id : int)
	{
		UseEntity();
	}
	
	public function UseEntity()
	{
		var spawnPosition : Vector;
		var storedZ : float;
		var nodeToAvoid : CNode;
		var nodePosition : Vector;
		var normalizedToNodeDir : Vector;
		var distance : float;
		
		spawnPosition = this.GetWorldPosition();
		storedZ = spawnPosition.Z;
		
		if( entityTemplate )
		{
			if( numberOfUses != 0 )
			{
				if( spawnNearPlayer )
				{
					spawnPosition = thePlayer.GetWorldPosition() + VecRingRand(0.0f, 7.0f);
				}
				
				nodeToAvoid = theGame.GetNodeByTag( avoidNodeWithTag );
				
				if( nodeToAvoid )
				{
					nodePosition = nodeToAvoid.GetWorldPosition();
					spawnPosition.Z = nodePosition.Z;
					
					distance = VecDistance2D( spawnPosition, nodePosition );
					if( distance < 3.0 )
					{
						normalizedToNodeDir = VecNormalize2D( thePlayer.GetWorldPosition() - nodePosition );
						spawnPosition = nodePosition + 3.0*normalizedToNodeDir;
					}
				}
				spawnPosition.Z = storedZ;
				theGame.CreateEntity( entityTemplate, spawnPosition, this.GetWorldRotation() );
			}
			if(	numberOfUses > 0 )
			{
				numberOfUses -= 1;
			}
		}
		if( appearanceAfterSpawn != '' && numberOfUses == 0 )
		{
			this.ApplyAppearance( appearanceAfterSpawn );
		}
	}
}