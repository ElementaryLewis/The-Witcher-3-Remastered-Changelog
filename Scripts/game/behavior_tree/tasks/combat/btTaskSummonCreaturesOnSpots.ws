/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskSummonCreaturesOnSpots extends IBehTreeTask
{
	
	
	
	protected var entityToSpawn 				: CEntityTemplate;
	protected var summonOnAnimEvent 			: name;
	protected var spotTag 						: name;
	protected var minDistance					: float;
	protected var maxDistance					: float;
	protected var maxSpawnQuantity				: int;
	protected var betweenSpawnDelay				: SRangeF;
	protected var completeAfterSpawn			: bool;
	protected var spawnAreaCenter				: ETargetName;
	protected var minDistanceFromSpawner		: float;
	protected var spawnBehVarName				: name;
	protected var spawnBehVar					: float;
	protected var shouldForceBehaviorOnSpawn	: bool;

	protected var m_Npc						: CNewNPC;
	protected var m_AllSpots				: array<CNode>;
	protected var m_CreateEntityHelper		: CCreateEntityHelper;
	protected var m_WaitingToSpawn			: bool;
	protected var m_IsSpawned				: bool;

	
	
	function Initialize()
	{
		m_Npc = GetNPC();
		m_CreateEntityHelper = new CCreateEntityHelper in this;
	}
	
	
	function IsAvailable() : bool
	{
		var i 					: int;

		theGame.GetNodesByTag( spotTag, m_AllSpots);

		if ( m_AllSpots.Size() <= 0 )
			return false;

		if( maxDistance < 0 && minDistance < 0  )
			return true;

		SortNodesByDistance( GetAreaCenter(), m_AllSpots );

		
		if( maxDistance > 0 && VecDistance( GetAreaCenter(), m_AllSpots[0].GetWorldPosition() ) > maxDistance )
			return false;

		
		if( minDistance > 0 && VecDistance( GetAreaCenter(), m_AllSpots[ m_AllSpots.Size() - 1].GetWorldPosition() ) < minDistance )
			return false;

		return true;
	}
	
	
	protected function GetAreaCenter() : Vector
	{
		var customTarget 	: Vector;
		var customHeading 	: float;
		var ActionTarget	: CNode;

		ActionTarget = GetActionTarget();

		switch ( spawnAreaCenter )
		{
			case TN_Me:
				return m_Npc.GetWorldPosition();
			case TN_CombatTarget:
				return GetCombatTarget().GetWorldPosition();
			case TN_ActionTarget:
				return GetActionTarget().GetWorldPosition();
			case TN_CustomTarget:
				GetCustomTarget( customTarget, customHeading );
				return customTarget;
			case TN_NamedTarget:
				
				return Vector(0,0,0);
			default:
				return Vector(0,0,0);
		}
	}
	
	
	latent function Main() : EBTNodeStatus
	{
		m_WaitingToSpawn = IsNameValid( summonOnAnimEvent );

		while( m_WaitingToSpawn )
		{
			SleepOneFrame();
		}

		if( !m_IsSpawned )
		{
			SpawnCreatures();
		}

		if( completeAfterSpawn )
			return BTNS_Completed;


		return BTNS_Active;
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if( animEventName == summonOnAnimEvent )
		{
			m_WaitingToSpawn = false;
		}

		return true;
	}
	
	
	protected function OnDeactivate()
	{
		m_IsSpawned = false;
	}
	
	
	protected latent function SpawnCreatures()
	{
		var i 					: int;
		var l_maxDelay 			: int;
		var l_availableSpots 	: array<CNode>;
		var l_createdEntity		: CEntity;
		var l_summonerComponent	: W3SummonerComponent;
		var l_summonedComponent : W3SummonedEntityComponent;
		var l_numToCreate		: int;

		m_IsSpawned = true;

		l_availableSpots = m_AllSpots;

		l_summonerComponent = (W3SummonerComponent) m_Npc.GetComponentByClassName('W3SummonerComponent');

		for( i = l_availableSpots.Size() - 1; i >= 0 ; i -= 1 )
		{
			if( maxDistance > 0 && VecDistance( GetAreaCenter(), l_availableSpots[i].GetWorldPosition() ) > maxDistance )
			{
				l_availableSpots.EraseFast( i );
			}
			else if( minDistance > 0 && VecDistance( GetAreaCenter(), l_availableSpots[ i ].GetWorldPosition() ) < minDistance )
			{
				l_availableSpots.EraseFast( i );
			}
			else if( minDistanceFromSpawner > 0 && VecDistance( m_Npc.GetWorldPosition(), l_availableSpots[ i ].GetWorldPosition() ) < minDistanceFromSpawner )
			{
				l_availableSpots.EraseFast( i );
			}
		}

		SortNodesByDistance( GetAreaCenter(), l_availableSpots );


		if( maxSpawnQuantity >= 0 )
			l_numToCreate = Min( maxSpawnQuantity, l_availableSpots.Size() );
		else
			l_numToCreate = l_availableSpots.Size();

		for( i = 0; i < l_numToCreate; i += 1 )
		{

			m_CreateEntityHelper.Reset();
			if( shouldForceBehaviorOnSpawn )
			{
				m_CreateEntityHelper.SetPostAttachedCallback( this, 'ForceBehavior' );
			}
			theGame.CreateEntityAsync( m_CreateEntityHelper, entityToSpawn, l_availableSpots[i].GetWorldPosition(), l_availableSpots[i].GetWorldRotation(), true, false, false, PM_DontPersist );

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
	function ForceBehavior( l_summonEntity : CEntity)
	{
		var l_summon 		: CNewNPC;
		var l_spawnTree 	: CAICustomSpawnActionDecorator;

		l_summon = ( CNewNPC ) l_summonEntity;
		l_spawnTree = new CAICustomSpawnActionDecorator in l_summonEntity;
		l_spawnTree.OnCreated();
		l_summon.ForceAIBehavior( l_spawnTree, BTAP_Emergency );
	}

}



class BTTaskSummonCreaturesOnSpotsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSummonCreaturesOnSpots';

	protected editable var entityToSpawn 				: CEntityTemplate;
	protected editable var summonOnAnimEvent 			: name;
	protected editable var spotTag 						: name;
	protected editable var minDistance					: float;
	protected editable var maxDistance					: float;
	protected editable var maxSpawnQuantity				: int;
	protected editable var betweenSpawnDelay			: SRangeF;
	protected editable var completeAfterSpawn			: bool;
	protected editable var spawnAreaCenter				: ETargetName;
	protected editable var minDistanceFromSpawner		: float;
	protected editable var spawnBehVarName				: name;
	protected editable var spawnBehVar					: float;
	protected editable var shouldForceBehaviorOnSpawn	: bool;

	default minDistance 			= -1;
	default maxDistance 			= -1;
	default maxSpawnQuantity 		= -1;
	default minDistanceFromSpawner 	= -1;

	hint maxSpawnQuantity = "N.B: doesn't spawn more than the amount of available spawn points";
}