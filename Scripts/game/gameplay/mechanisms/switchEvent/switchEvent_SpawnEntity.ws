/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SE_SpawnEntity extends W3SwitchEvent
{
	
	
	
	private editable 	var 	entityTemplate			: CEntityTemplate;
	private editable	var		positionOffset			: Vector;
	private editable 	var		randomOffset			: Vector;
	private editable	var 	lifeTime				: float;
	private editable	var 	maxEntitiesAtATime		: int;
	private editable	var		minDelayBetweenSpawns	: float;
	private editable	var		spawnSnapToGround		: bool;
	
	private 			var 	m_spawnedEntities		: array<CEntity>;
	
	default lifeTime				= -1;
	default maxEntitiesAtATime		= 1;
	default spawnSnapToGround		= true;

	hint  entityTemplate 	= "entity to spawn";
	hint  positionOffset 	= "Offset from the action point position (keeps the same rotation)";
	hint  randomOffset 		= "Additional random offset";
	hint  lifeTime 			= "-1 means infinite. Food entity is destroyed at the end of its lifetime";
	
	
	
	public function Perform( _Parent : CEntity )
	{	
		var	l_spawnPos	: Vector;
		var l_rotation	: EulerAngles;
		var l_normal	: Vector;
		
		if(  m_spawnedEntities.Size() >= maxEntitiesAtATime ) return;
		
		l_spawnPos = _Parent.GetWorldPosition() + positionOffset + Vector( RandF() * randomOffset.X, RandF() * randomOffset.Y, RandF() * randomOffset.Z );
		l_rotation = _Parent.GetWorldRotation();
		
		if( spawnSnapToGround )
		{
			theGame.GetWorld().StaticTrace( l_spawnPos + Vector(0,0,5), l_spawnPos - Vector(0,0,5), l_spawnPos, l_normal );
		}
		
		m_spawnedEntities.PushBack( theGame.CreateEntity ( entityTemplate, l_spawnPos, l_rotation ) );
		
		if( lifeTime > 0 )
		{
			DestroySpawnedEntity( lifeTime );
		}
	}
	
	
	private timer function DestroySpawnedEntity( _deltaTime : float , optional id : int)
	{
		if( m_spawnedEntities.Size() == 0 ) return;
		m_spawnedEntities[0].Destroy();
		m_spawnedEntities.Erase(0);
	}
}