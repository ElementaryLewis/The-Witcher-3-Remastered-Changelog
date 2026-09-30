/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3AnimationTestSpawner extends CSpawner
{

	editable var stationaryAnim : bool;
	editable var EditorSpawn : bool;
	editable var arrayAnims : bool;
	editable var sourceCSV 			: C2dArray;
	
	editable var TeleportEntity : CEntityTemplate;
	
	editable var names : array< name >;

	
	default count = 1;
	default immortalityMode = AIM_None;
	default attitudeToPlayer = AIA_Hostile;
	default respawnDelay = 3.0f;
	default initialHealth = 100;
	default spawnAnimation = EM_Ground;
	
	default stationaryAnim = true;
	default arrayAnims = false;
	default EditorSpawn = false;
	
	event OnSpawnedEditor( spawnData : SEntitySpawnData )
	{
		var i : int;
		
		for ( i = spawnedNPCs.Size() - 1; i >=0 ; i -= 1 )
		{
			spawnedNPCs[i].Destroy();
		}
		
		spawnedNPCs.Clear();
		respawnTime.Clear();
		respawnNeeded.Clear();
		
		if(arrayAnims)
		{
			count = names.Size();
		}
		else
		{
			count = sourceCSV.GetNumRows();
		}
		
		
		spawnedNPCs.Grow(count);
		respawnTime.Grow(count);
		respawnNeeded.Grow(count);

		for ( i = 0; i < count; i += 1 )
		{
			respawnNeeded[i] = true;
		}

		if( entityTemplate )
		{
			if(EditorSpawn)
			{
				RespawnAnim(0.0f, 1);
			}	
		}
		

	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var i : int;
		var j : int;
		var entitiesToDelete : array<CEntity> ;
		var animName : name;
		
		for ( i = spawnedNPCs.Size() - 1; i >=0 ; i -= 1 )
		{
			spawnedNPCs[i].Destroy();
		}
		
		
		spawnedNPCs.Clear();
		respawnTime.Clear();
		respawnNeeded.Clear();
		
		if(arrayAnims)
		{
			count = names.Size();
		}
		else
		{
			count = sourceCSV.GetNumRows();
		}
		
		for ( i = 0; i < count; i += 1 )
		{
		
			if(arrayAnims)
			{
				animName = names[i];
			}
			else
			{
				animName = sourceCSV.GetValueAtAsName(0,i);
			}
		
			theGame.GetEntitiesByTag(animName,  entitiesToDelete);
			
			for(j=0; j<entitiesToDelete.Size(); j+=1)
			{
				entitiesToDelete[j].Destroy();
			}
			entitiesToDelete.Clear();
			
		}
		
		
		spawnedNPCs.Grow(count);
		respawnTime.Grow(count);
		respawnNeeded.Grow(count);

		for ( i = 0; i < count; i += 1 )
		{
			respawnNeeded[i] = true;
		}

		if( entityTemplate )
		{
			AddTimer( 'RespawnAnim', 1.f, respawn );
		}
	}

	timer function RespawnAnim( t : float , id : int)
	{
		var i : int;
		var entity : CEntity;
		var npc : CNewNPC;
		var tags : array<name>;
		
		var startingPosition : Vector;
		var nextPosition : Vector;
		
		var animName : name;

		
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
		
		
		startingPosition = GetComponentByClassName('CSpawnPointComponent').GetWorldPosition();
		
		
		for ( i = 1; i < count + 1; i += 1 )
		{
			if( respawnNeeded[i] && theGame.GetEngineTime() > respawnTime[i] )
			{
				
				nextPosition = startingPosition + Vector(i * 3, 0.0f, 0.0f);
				entity = theGame.CreateEntity( entityTemplate, nextPosition , GetWorldRotation(), true, false, false, PM_DontPersist );
				entity.AddTag(animName);
				npc = ( CNewNPC ) entity;
				if ( npc )
				{
					if(arrayAnims)
					{
						animName = names[i];
					}
					else
					{
						animName = sourceCSV.GetValueAtAsName(0,i);
					}
					
					
					entity = theGame.CreateEntity( TeleportEntity, nextPosition , GetWorldRotation(), true, false, false, PM_DontPersist );
					entity.AddTag(animName);
					ForceBehavior(npc, animName, animName);
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
				}
			}
		}

		OnSpawnFinished();
	}

	protected function OnSpawnFinished()
	{

	}
	

	function ForceBehavior( l_summonEntity : CNewNPC, aName : name, aTeleportTag : name)
	{
		var l_loopTree : 		CAIActionLoop;
		var l_spawnTree 		: CAIPlayAnimationSlotTeleportAction;		
	
		l_loopTree = new CAIActionLoop in l_summonEntity;
		l_loopTree.OnCreated();
	
		l_spawnTree = new CAIPlayAnimationSlotTeleportAction in l_summonEntity;
		l_spawnTree.OnCreated();
		l_spawnTree.animName = aName;
		l_spawnTree.TeleportTag = aTeleportTag;
		if(stationaryAnim)
		{
			l_spawnTree.slotName = 'NPC_ANIM_STATIONARY_SLOT';
		}
		else
		{
			l_spawnTree.slotName = 'NPC_ANIM_SLOT';
		}
		
		l_spawnTree.blendInTime = 0;
		l_spawnTree.blendOutTime = 0;
		
		l_loopTree.loopedAction = l_spawnTree;
		
		
		
		l_summonEntity.ForceAIBehavior( l_loopTree, BTAP_AboveCombat );
	}
};