/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3TrapSpawnEntity extends W3Trap
{
	
	
	
	private editable var spawnOnlyOnAreaEnter			: bool;
	private editable var maxSpawns						: float;
	private editable var entityToSpawn					: CEntityTemplate;
	private editable var offsetVector					: Vector;
	private editable var excludedActorsTags				: array <name>;
	private editable var ignoreFlyingActors : bool;
	
	private editable var appearanceAfterFirstSpawn		: string;
	
	
	private var m_Spawns	: int;
	private var ignoredActors : array<CActor>;
	private var ignoredActorsTimerActive: bool;

	
	default spawnOnlyOnAreaEnter 		= true;
	default maxSpawns 					= -1;
	hint	spawnOnlyOnAreaEnter		= "Even if the trap is active, only spawn entity when an actor enters the area trigger";
	hint 	maxSpawns 					= "-1 means infinite. Maximum time the entity that can be spawn during trap lifetime";
	hint 	offsetVector 				= "spawn position offset";
	hint 	excludedActorsTags 			= "actors with these tags won't trigger the trap when entering the area";
	hint 	ignoreFlyingActors			= "if true, flying actors wont trigger the trap unless they've been knocked out in the air";
	
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		var l_actor	: CActor;
		
		if ( m_isPlayingAnimation )
		{
			return false;
		}
		l_actor = (CActor) activator.GetEntity();
		
		if ( !l_actor )
		{
			return false;
		}

		if ( m_isArmed  )
		{
			if (ignoreFlyingActors && l_actor.GetBehaviorVariable( 'npcStance' ) == (int)NS_Fly && !l_actor.HasBuff(EET_Knockdown))
			{
				AddActorToPeriodicCheck(l_actor);
				return false;
			}

			if( l_actor && ShouldExcludeActor( l_actor ) )
			{
				return false;
			}
			
			SpawnEntity();
			Activate();
		}
	}	

	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var l_actor	: CActor;
		
		l_actor = (CActor) activator.GetEntity();		

		if (l_actor && m_isArmed && ignoreFlyingActors)
			ignoredActors.Remove(l_actor);
	}
	
	

	private function ShouldExcludeActor( _Actor : CActor ) : bool
	{
		var i			: int;
		var actorTags	: array <name>;
		
		if( _Actor && excludedActorsTags.Size() > 0 )
		{
			actorTags = _Actor.GetTags();
			for ( i = 0; i < excludedActorsTags.Size(); i += 1 )
			{
				if( actorTags.Contains( excludedActorsTags[i] ) )
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	
	
	public function Activate( optional _Target: CNode ):void
	{
		if( !m_IsActive && !spawnOnlyOnAreaEnter )
		{
			SpawnEntity();
		}
		
		super.Activate( _Target );
	}
	
	
	function SpawnEntity()
	{
		var l_spawnPos 			: Vector;
		var l_entity 				: CEntity;
		var l_damageAreaEntity 	: CDamageAreaEntity;
		
		if( m_Spawns == 0 )
		{
			ApplyAppearance( appearanceAfterFirstSpawn );
		}
		
		if ( maxSpawns < 0 || maxSpawns > m_Spawns ) 
		{
			l_spawnPos 	= GetWorldPosition();
			l_spawnPos += offsetVector;
			l_entity 	= theGame.CreateEntity( entityToSpawn, l_spawnPos, GetWorldRotation() );
			l_damageAreaEntity = (CDamageAreaEntity) l_entity;
			if ( l_damageAreaEntity )
			{
				l_damageAreaEntity.owner = NULL;
			}
			
			m_Spawns += 1;
		}
		else
		{
			if (maxSpawns > 0 && maxSpawns >= m_Spawns) m_isArmed = false;
		}
	}
	
	
	private function AddActorToPeriodicCheck(actor : CActor)
	{
		if (!ignoredActors.Contains(actor))
			ignoredActors.PushBack(actor);
		
		if (!ignoredActorsTimerActive)
		{
			ignoredActorsTimerActive = true;
			AddTimer('FlyingActorsCheck', 0.05f, true, , , true, true);
		}
	}

	private timer function FlyingActorsCheck( dt : float, optional id : int)
	{
		var i : int;
		var l_actor : CActor;

		if (ignoredActors.Size() == 0)
		{
			RemoveTimer('FlyingActorsCheck');
			ignoredActorsTimerActive = false;
			return;
		}

		for (i = 0; i < ignoredActors.Size(); i += 1)
		{
			l_actor = ignoredActors[i];

			if (!l_actor)
			{
				ignoredActors.Remove(l_actor);
				continue;
			}

			if (l_actor.GetBehaviorVariable( 'npcStance' ) != (int)NS_Fly || (l_actor.GetBehaviorVariable( 'npcStance' ) == (int)NS_Fly && l_actor.HasBuff(EET_Knockdown)))
			{
				ignoredActors.Clear();
				RemoveTimer('FlyingActorsCheck');
				ignoredActorsTimerActive = false;
				SpawnEntity();
				Activate();
				return;
			}
		}
	}
}