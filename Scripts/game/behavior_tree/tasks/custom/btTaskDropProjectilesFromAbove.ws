/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskDropProjectilesFromAbove extends IBehTreeTask
{
	public var resourceName 					: name;
	public var activeOnAnimEvent 				: name;
	public var chanceToGuaranteePlayerHit 		: float;
	public var timeBetweenSpawn 				: float;
	public var timeBetweenSpawnRandomizationPerc: float;
	public var minDistFromTarget 				: float;
	public var maxDistFromTarget 				: float;
	public var minDistFromEachOther 			: float;
	public var minYOffset 						: float;
	public var maxYOffset 						: float;
	public var useCombatTarget 					: bool;
	public var useOwnerAsTarget 				: bool;
	
	private var target 							: CActor;
	private var entityTemplate 					: CEntityTemplate;
	private var usedPos 						: array<Vector>;
	private var activated 						: bool;
	
	
	function Initialize()
	{
		entityTemplate = (CEntityTemplate)LoadResource( resourceName );	
	}
	
	function OnActivate() : EBTNodeStatus
	{
		activated = false;
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var pos 			: Vector;
		var spawnInterval 	: float;
		var i 				: int;
		
		
		usedPos.Clear();
		timeBetweenSpawnRandomizationPerc = timeBetweenSpawn * timeBetweenSpawnRandomizationPerc;
		if ( useOwnerAsTarget )
		{
			target = GetNPC();
		}
		else if ( useCombatTarget )
		{
			target = GetCombatTarget();
		}
		else
		{
			target = (CActor) GetActionTarget();
		}
		
		if ( !IsNameValid( activeOnAnimEvent ) )
		{
			activated = true;
		}
		else
		{
			while ( !activated )
			{
				SleepOneFrame();
			}
		}
		
		while( activated )
		{
			pos = FindPosition();
			
			while( !IsPositionValid( pos ) )
			{
				SleepOneFrame();
				pos = FindPosition();
			}
			
			Spawn( pos );
			usedPos.PushBack( pos );
			if( usedPos.Size() > 5 )
				usedPos.Clear();
			
			if ( timeBetweenSpawnRandomizationPerc > 0 )
			{
				spawnInterval = RandRangeF( timeBetweenSpawn + timeBetweenSpawnRandomizationPerc, timeBetweenSpawn - timeBetweenSpawnRandomizationPerc );
				Sleep( spawnInterval );
			}
			else
			{
				Sleep( timeBetweenSpawn );
			}
		}
		
		return BTNS_Active;
	}
	
	final function Spawn( position : Vector )
	{
		var entity 				: CEntity;
		var projectile 			: W3AdvancedProjectile;
		var spawnPos 			: Vector;
		var traceStart 			: Vector;
		var traceOffset			: Vector;
		var normal 				: Vector;
		var rotation 			: EulerAngles;
		var collisionGroups 	: array<name>;
		var randY 				: float;
		
		if( entityTemplate )
		{
			collisionGroups.PushBack( 'Terrain' );
			collisionGroups.PushBack( 'Static' );
			collisionGroups.PushBack( 'Ragdoll' );
			collisionGroups.PushBack( 'Character' );
			
			randY = RandRangeF( maxYOffset, minYOffset );
			traceOffset = position;
			traceOffset.Y += randY;
			traceStart = traceOffset;
			traceStart.Z += 1;
			traceOffset.Z += 50;
			
			theGame.GetWorld().StaticTrace( traceStart, traceOffset, spawnPos, normal );
			spawnPos.Z -= 1.5;
			
			entity = theGame.CreateEntity( entityTemplate, spawnPos, rotation );
			projectile = (W3AdvancedProjectile)entity;
			if( projectile )
			{
				projectile.Init( NULL );
				projectile.ShootProjectileAtPosition( projectile.projAngle, projectile.projSpeed, position, 500, collisionGroups );
			}
		}
	}
	
	final function FindPosition() : Vector
	{
		var randVec 	: Vector = Vector( 0.f, 0.f, 0.f );
		var targetPos 	: Vector;
		var outPos 		: Vector;
		
		if ( RandF() > chanceToGuaranteePlayerHit )
		{
			targetPos = target.GetWorldPosition();
			randVec = VecRingRand( minDistFromTarget, maxDistFromTarget );
			outPos = targetPos + randVec;
		}
		else
		{
			outPos = thePlayer.GetWorldPosition();
		}
		
		return outPos;
	}
	
	final function IsPositionValid( out whereTo : Vector ) : bool
	{
		var newPos 	: Vector;
		var z 		: float;
		var i 		: int;
		
		
		if( !theGame.GetWorld().NavigationFindSafeSpot( whereTo, -1, 1, newPos ) )
		{
			if( theGame.GetWorld().NavigationComputeZ( whereTo, whereTo.Z - 5.0, whereTo.Z + 5.0, z ) )
			{
				whereTo.Z = z;
				if( !theGame.GetWorld().NavigationFindSafeSpot( whereTo, 0, 1, newPos ) )
					return false;
			}
		}
		
		for( i = 0; i < usedPos.Size(); i += 1 )
		{
			if( VecDistance2D( newPos, usedPos[i] ) < minDistFromEachOther )
				return false;
		}
		
		whereTo = newPos;
		return true;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( IsNameValid( activeOnAnimEvent ) && animEventName == activeOnAnimEvent )
		{
			activated = true;
			return true;
		}
		
		return false;
	}
};

class CBTTaskDropProjectilesFromAboveDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskDropProjectilesFromAbove';
	
	editable var resourceName 						: name;
	editable var activeOnAnimEvent 					: name;
	editable var chanceToGuaranteePlayerHit 		: float;
	editable var timeBetweenSpawn 					: float;
	editable var timeBetweenSpawnRandomizationPerc	: float;
	editable var minDistFromTarget 					: float;
	editable var maxDistFromTarget 					: float;
	editable var minDistFromEachOther 				: float;
	editable var minYOffset 						: float;
	editable var maxYOffset 						: float;
	editable var useCombatTarget 					: bool;
	editable var useOwnerAsTarget 					: bool;
	
	default resourceName 							= 'sharley_stone_proj';
	default chanceToGuaranteePlayerHit 				= 0.2;
	default timeBetweenSpawn 						= 1.0;
	default timeBetweenSpawnRandomizationPerc 		= 1.0;
	default minDistFromTarget 						= 0.0;
	default maxDistFromTarget 						= 50.0;
	default minDistFromEachOther 					= 3.0;
	default useCombatTarget 						= true;
};


class CBTTaskDropSummonFromAbove extends IBehTreeTask
{
	protected var entityToSpawn 				: CEntityTemplate;
	protected var spawnBehVarName				: name;
	protected var spawnBehVar					: float;
	protected var initialSpawnDelay				: SRangeF;
	protected var betweenSpawnDelay				: SRangeF;
	protected var activeOnAnimEvent 			: name;
	protected var shouldForceBehaviorOnSpawn	: bool;
	protected var shouldCheckArenaOveralap		: bool;
	protected var arenaAreaTag					: name;
	protected var numToCreate					: int;

	protected var m_Npc							: CNewNPC;
	protected var m_CreateEntityHelper			: CCreateEntityHelper;
	protected var ArenaAreaEntity 				: CEntity;
	protected var ArenaAreaComp 				: CAreaComponent;
	protected var summonPos 					: array<Vector>;
	protected var activated						: bool;
	protected var m_IsSpawned					: bool;
	
	function Initialize()
	{
		m_Npc = GetNPC();
		m_CreateEntityHelper = new CCreateEntityHelper in this;
		if (shouldCheckArenaOveralap)
		{
			
			ArenaAreaEntity = theGame.GetEntityByTag ( arenaAreaTag );
			ArenaAreaComp = (CAreaComponent)ArenaAreaEntity.GetComponentByClassName( 'CAreaComponent' );
		}
	}
	
	latent function Main() : EBTNodeStatus
	{
		var pos 			: Vector;
		var spawnInterval 	: float;
		var i 				: int;
		
		m_IsSpawned = false;
		activated = false;
		
		if ( !IsNameValid( activeOnAnimEvent ) )
		{
			activated = true;
		}
		else
		{
			while ( !activated )
			{
				SleepOneFrame();
			}
		}
		
		if( !m_IsSpawned )
		{
			SpawnCreatures();
		}
		
		return BTNS_Active;
	}
	
	protected latent function SpawnCreatures()
	{
		var i 						: int;
		var l_maxDelay 				: int;
		var l_position				: Vector;
		var l_rotation				: EulerAngles;
		var l_createdEntity			: CEntity;
		var l_summonerComponent		: W3SummonerComponent;
		var l_summonedComponent 	: W3SummonedEntityComponent;
		var l_summons				: array<CEntity>;

		m_IsSpawned = true;

		l_summonerComponent = (W3SummonerComponent) m_Npc.GetComponentByClassName('W3SummonerComponent');
		
		if ( l_summonerComponent.GetNumberOfSummonedEntities() > 4 )
			return;
		
		Sleep( RandRangeF( initialSpawnDelay.max, initialSpawnDelay.min ) );

		for( i = 0; i < numToCreate; i += 1 )
		{
			m_CreateEntityHelper.Reset();
			
			if( shouldForceBehaviorOnSpawn )
			{
				m_CreateEntityHelper.SetPostAttachedCallback( this, 'ForceBehavior' );
			}
			
			l_summons	= l_summonerComponent.GetSummonedEntities();
			summonPos.Clear();
			
			for ( i = 0; i < l_summons.Size(); i += 1 )
			{	
				summonPos.PushBack( l_summons[i].GetWorldPosition() );
			}

			l_position = FindSummonPosition();
			
			while( !IsSummonPositionValid( l_position ) )
			{
				SleepOneFrame();
				l_position = FindSummonPosition();
			}

			l_rotation = VecToRotation( GetActionTarget().GetWorldPosition() - l_position );
			theGame.CreateEntityAsync( m_CreateEntityHelper, entityToSpawn, l_position, l_rotation, true, false, false, PM_DontPersist );
	
			l_maxDelay = 0;
			while( m_CreateEntityHelper.IsCreating() )
			{
				SleepOneFrame();
					
				l_maxDelay += 1;
				if( l_maxDelay >= 120 )
				{
					return;
				}
			}
	
			l_createdEntity = m_CreateEntityHelper.GetCreatedEntity();
	
			if( IsNameValid( spawnBehVarName ) )
			{
				l_createdEntity.SetBehaviorVariable( spawnBehVarName, spawnBehVar );
			}
	
			if ( l_summonerComponent )
			{
				l_summonerComponent.AddEntity ( l_createdEntity );
			}
	
			l_summonedComponent	= (W3SummonedEntityComponent) l_createdEntity.GetComponentByClassName( 'W3SummonedEntityComponent' );
			if( l_summonedComponent )
			{
				l_summonedComponent.Init( m_Npc );
			}
	
			((CNewNPC)l_createdEntity).SignalGameplayEventParamObject( 'ForceTarget', GetCombatTarget() );
	
			Sleep( RandRangeF( betweenSpawnDelay.max, betweenSpawnDelay.min ) );
		}
	}

	function FindSummonPosition() : Vector
	{
		var randVec 	: Vector = Vector( 0.f, 0.f, 0.f );
		var targetPos 	: Vector;
		var outPos 		: Vector;
		

		targetPos = m_Npc.GetWorldPosition();
		randVec = VecRingRand( 3, 6 );
		outPos = targetPos + randVec;

		return outPos;
	}

	function IsSummonPositionValid( out whereTo : Vector ) : bool
	{
		var newPos 	: Vector;
		var z 		: float;
		var i 		: int;
		
		
		
		if( !theGame.GetWorld().NavigationFindSafeSpot( whereTo, -1, 1, newPos ) )
		{
			if( theGame.GetWorld().NavigationComputeZ( whereTo, whereTo.Z - 2.5, whereTo.Z + 2.5, z ) )
			{
				whereTo.Z = z;
				if( !theGame.GetWorld().NavigationFindSafeSpot( whereTo, 0, 1, newPos ) )
					return false;
			}
		}
		
		for( i = 0; i < summonPos.Size(); i += 1 )
		{
			if( VecDistance2D( newPos, summonPos[i] ) < 3 )
				return false;
		}
		
		if (shouldCheckArenaOveralap)
		{
			if (!ArenaAreaComp.TestPointOverlap(newPos))
				return false;
		}
		
		whereTo = newPos;
		return true;
	}
	
	function ForceBehavior( l_summonEntity : CEntity)
	{
		var l_summon 		: CNewNPC;
		var l_spawnTree 	: CAICustomSpawnActionDecorator;

		l_summon = ( CNewNPC ) l_summonEntity;
		l_spawnTree = new CAICustomSpawnActionDecorator in l_summonEntity;
		l_spawnTree.OnCreated();
		l_summon.ForceAIBehavior( l_spawnTree, BTAP_Emergency );
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( IsNameValid( activeOnAnimEvent ) && animEventName == activeOnAnimEvent )
		{
			activated = true;
			return true;
		}
		
		return false;
	}
}

class CBTTaskDropSummonFromAboveDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskDropSummonFromAbove';
	
	protected editable var entityToSpawn 					: CEntityTemplate;
	protected editable var numToCreate						: int;
	protected editable var activeOnAnimEvent 				: name;
	protected editable var spawnBehVarName					: name;
	protected editable var spawnBehVar						: float;
	protected editable var shouldForceBehaviorOnSpawn		: bool;
	protected editable var shouldCheckArenaOveralap			: bool;
	protected editable var arenaAreaTag						: name;
	protected editable var initialSpawnDelay				: SRangeF;
	protected editable var betweenSpawnDelay				: SRangeF;
	
	default numToCreate = 1;
}