/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3IllusionSpawner extends CGameplayEntity
{
	
	
	
	private editable var m_illusionTemplate		: CEntityTemplate;
	editable var m_factOnDispelOverride			: string;
	private var l_illusion 						: CEntity;
	private var spawnedIllusion 				: W3IllusionaryObstacle;
	editable var	m_discoveryOneliner			: EIllusionDiscoveredOneliner;
	editable var m_factOnDiscoveryOverride		: string;
	editable var discoveryOnelinerTag			: string;
	editable var spawnedObstacleTags			: array<name>;
	
	private saved var m_wasDestroyed			: bool;
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if ( !m_wasDestroyed )
		{
			SpawnIllusion();
		}
	}
	
	
	public function SpawnIllusion()
	{
		var i : int;
		
		l_illusion = theGame.CreateEntity( m_illusionTemplate, GetWorldPosition(), GetWorldRotation() );
		
		spawnedIllusion = (W3IllusionaryObstacle) l_illusion;
		
		if( m_factOnDispelOverride != "")
		{
			spawnedIllusion.OverrideIllusionObstacleFactOnSpawn( m_factOnDispelOverride );
		}
		
		if( m_factOnDiscoveryOverride != "")
		{
			spawnedIllusion.OverrideIllusionObstacleFactOnDiscovery( m_factOnDiscoveryOverride );
		}
		
		spawnedIllusion.SetOneLinerHandling(m_discoveryOneliner);
		spawnedIllusion.SetDiscoveryOnelinerTag(discoveryOnelinerTag);
		
		for(i=0; i<spawnedObstacleTags.Size(); i+=1)
		{
			spawnedIllusion.AddTag(spawnedObstacleTags[i]);
		}
		
		spawnedIllusion.SetIllusionSpawner ( this );
	}
	
	public function ManualDispel()
	{
		spawnedIllusion.Dispel();
		spawnedIllusion.DestroyObstacle();
	}
	
	public function SetDestroyed()
	{
		m_wasDestroyed = true;
	}
	
}