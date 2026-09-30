/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SpawnMarker extends CGameplayEntity
{
	
	
	
	public editable var spawnDelay		: float;
	public editable var destroyDelay	: float;
	public editable var entitiesToSpawn	: array<CEntityTemplate>;
	public editable var spawnOnGround	: bool;
	
	private var m_summonedEntityCmp		:  W3SummonedEntityComponent;
	
	default spawnDelay 		= 2;
	default destroyDelay 	= 5;
	
	default spawnOnGround	= true;
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{		
		m_summonedEntityCmp = (W3SummonedEntityComponent) GetComponentByClassName('W3SummonedEntityComponent');
		AddTimer( 'SpawnEntity', spawnDelay, false,,, true );		
		AddTimer( 'DestroyTimer', destroyDelay, false,,, true );		
	}
	
	
	private timer function SpawnEntity( optional _DeltaTime : float , id : int)
	{
		var l_summoner					: CActor;
		var l_pos, l_spawnPos			: Vector;
		var l_spawnedEntity 			: CEntity;
		var l_damageAreaEntity 			: CDamageAreaEntity;
		var l_summonedEntityComponent	: W3SummonedEntityComponent;
		var l_normal					: Vector;
		var l_entityToSpawn				: CEntityTemplate;
		var l_randValue					: int;
		
		l_spawnPos = l_pos = GetWorldPosition();
		
		if( spawnOnGround )
		{
			theGame.GetWorld().StaticTrace( l_pos + Vector(0,0,5), l_pos - Vector(0,0,5), l_spawnPos, l_normal );
		}
		
		l_randValue		= RandRange( entitiesToSpawn.Size() );		
		l_entityToSpawn = entitiesToSpawn[ l_randValue ];
		
		l_spawnedEntity = theGame.CreateEntity( l_entityToSpawn, l_spawnPos, GetWorldRotation() );
		
		l_summoner = m_summonedEntityCmp.GetSummoner();
		
		l_damageAreaEntity = (CDamageAreaEntity) l_spawnedEntity;
		if ( l_damageAreaEntity && m_summonedEntityCmp )
		{
			l_damageAreaEntity.owner = l_summoner;
		}
		
		l_summonedEntityComponent = (W3SummonedEntityComponent) l_spawnedEntity.GetComponentByClassName('W3SummonedEntityComponent');
		if( l_summonedEntityComponent && m_summonedEntityCmp)
		{
			l_summonedEntityComponent.Init( l_summoner );
		}
	}
	
}