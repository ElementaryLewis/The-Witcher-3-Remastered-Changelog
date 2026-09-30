/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskSummonCreaturesOnSpots extends IBehTreeTask
{
	
	
	
	private var entityToSpawn 				: CEntityTemplate;
	private var summonOnAnimEvent 			: name;
	private var spotTag 					: name;
	private var minDistance					: float;
	private var maxDistance					: float;
	private var maxSpawnQuantity			: int;
	private var betweenSpawnDelay			: SRangeF;
	private var completeAfterSpawn			: bool;
	private var spawnAreaCenter				: ETargetName;
	private var minDistanceFromSpawner		: float;
	private var spawnBehVarName				: name;
	private var spawnBehVar					: float;
	private var shouldForceBehaviorOnSpawn	: bool;
	
	private var m_Npc					: CNewNPC;
	private var m_AllSpots				: array<CNode>;
	private var m_CreateEntityHelper	: CCreateEntityHelper;
	private var m_WaitingToSpawn		: bool;
	private var m_IsSpawned				: bool;
	
	
	
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
	
	
	private function GetAreaCenter() : Vector
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
	
	
	private function OnDeactivate()
	{
		m_IsSpawned = false;
	}
	
	
	final latent function SpawnCreatures()
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
	
	private editable var entityToSpawn 				: CEntityTemplate;
	private editable var summonOnAnimEvent 			: name;
	private editable var spotTag 					: name;
	private editable var minDistance				: float;
	private editable var maxDistance				: float;
	private editable var maxSpawnQuantity			: int;
	private editable var betweenSpawnDelay			: SRangeF;
	private editable var completeAfterSpawn			: bool;
	private editable var spawnAreaCenter			: ETargetName;
	private editable var minDistanceFromSpawner		: float;
	private editable var spawnBehVarName			: name;
	private editable var spawnBehVar				: float;
	private editable var shouldForceBehaviorOnSpawn	: bool;
	
	default minDistance 			= -1;
	default maxDistance 			= -1;
	default maxSpawnQuantity 		= -1;
	default minDistanceFromSpawner 	= -1;
	
	hint maxSpawnQuantity = "N.B: doesn't spawn more than the amount of available spawn points";
}