/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CSpawner extends CEntity
{
	editable var entityTemplate : CEntityTemplate;
	editable var count : int;
	editable var immortalityMode : EActorImmortalityMode;
	editable var attitudeOverride : bool;
	editable var attitudeToPlayer : EAIAttitude;
	editable var hostileSpawnerTag : name;
	editable var spawnTags : array< name >;
	editable var respawn : bool;
	editable var respawnDelay : float;
	editable var initialHealth : int;
	editable var spawnAnimation : EExplorationMode;
	private var spawnedNPCs : array< CNewNPC >;
	private var respawnTime : array< EngineTime >;
	private var respawnNeeded : array< bool >;
	
	default count = 1;
	default immortalityMode = AIM_None;
	default attitudeToPlayer = AIA_Hostile;
	default respawnDelay = 3.0f;
	default initialHealth = 100;
	default spawnAnimation = EM_Ground;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		var i : int;
		spawnedNPCs.Clear();
		respawnTime.Clear();
		respawnNeeded.Clear();
		
		spawnedNPCs.Grow(count);
		respawnTime.Grow(count);
		respawnNeeded.Grow(count);
		
		for ( i = 0; i < count; i += 1 )
		{
			respawnNeeded[i] = true;
		}
		
		if( entityTemplate )
		{
			AddTimer( 'Respawn', 1.f, respawn );
		}	
	}
	
	timer function Respawn( t : float , id : int)
	{
		var i : int;		
		var entity : CEntity;
		var npc : CNewNPC;
		var tags : array<name>;
	
		
		for ( i = spawnedNPCs.Size() - 1; i >=0 ; i -= 1 )
		{
			if( !respawnNeeded[i] )
			{
				if ( !spawnedNPCs[ i ] || !spawnedNPCs[ i ].IsAlive() )
				{
					respawnTime[i] = theGame.GetEngineTime() + respawnDelay;					
					spawnedNPCs[i] = NULL;
					respawnNeeded[i] = true;
				}
			}
		}
	
		
		for ( i = 0; i < count; i += 1 )
		{
			if( respawnNeeded[i] && theGame.GetEngineTime() > respawnTime[i] )
			{
				entity = theGame.CreateEntity( entityTemplate, GetWorldPosition(), GetWorldRotation(), true, false, false, PM_DontPersist );
				
				npc = ( CNewNPC ) entity;
				if ( npc )
				{
					spawnedNPCs[i] = npc;
					respawnNeeded[i] = false;
					npc.SetImmortalityMode( immortalityMode, AIC_Default );
					if ( attitudeOverride )
					{
						npc.SetAttitude( thePlayer, attitudeToPlayer );
					}
					npc.SetBehaviorVariable( 'SpawnAnim', (int)spawnAnimation );
					
					
					tags = npc.GetTags();
					ArrayOfNamesAppendUnique(tags, spawnTags);					
					npc.SetTags( tags );
					
					if ( npc.GetBehaviorVariable( 'SpawnAnim' ) == 1.f && npc.IsFlying() )
					{
						
					}
				}
			}		
		}
		
	}
	
};