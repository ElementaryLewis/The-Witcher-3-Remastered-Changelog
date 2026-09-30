/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskSummonsManager extends IBehTreeTask
{
	private var npc : CNewNPC;
	private var summonedEntities : array<CGameplayEntity>;
	private var summonedEntitiesSearchingRange : float;
	
	private var summonedEntitiesTag : name;
	private var killEntitiesOnDistance : bool;
	private var killDistance : float;
	
	default summonedEntitiesSearchingRange = 100.0;
	



	function Initialize()
	{
		npc = GetNPC();
	}
	
	function OnDeactivate()
	{
		var i : int;

		if( !npc.IsAlive() )
		{
			GatherSummonedEntities();
			
			if( summonedEntities.Size() )
			{
				for( i = 0; i < summonedEntities.Size(); i += 1 )
				{
					((CNewNPC)summonedEntities[ i ]).Kill( 'SummonsManagerKill' );
				}
			}
		}
	}
		


	
	latent function Main() : EBTNodeStatus
	{
		while( true )
		{	
			GatherSummonedEntities();
			
			if( killEntitiesOnDistance )
			{
				KillEntitiesOnDistance();
			}
			
			Sleep( 0.5 );
		}
		
		return BTNS_Active;
	}
	



	private function GatherSummonedEntities()
	{
		var i : int;
		
		summonedEntities.Clear();
		FindGameplayEntitiesInRange( summonedEntities, npc, summonedEntitiesSearchingRange, 100, summonedEntitiesTag, FLAG_OnlyAliveActors );
	
		npc.SetBehaviorVariable( 'summonCount', summonedEntities.Size() );
	}
	
	private function KillEntitiesOnDistance()
	{
		var i : int;
		var npcPos : Vector;
		
		if( summonedEntities.Size() )
		{
			npcPos = npc.GetWorldPosition();
			for( i = 0; i < summonedEntities.Size(); i += 1 )
			{
				if( VecDistance2D( npcPos, summonedEntities[ i ].GetWorldPosition() ) > killDistance )
				{
					((CNewNPC)summonedEntities[ i ]).Kill( 'SummonsManagerKill' );
				}
			}
		}
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var i : int;
		
		if( eventName == 'OnMonsterCombatEnd' )
		{
			npc = GetNPC();
			GatherSummonedEntities();
			
			if( summonedEntities.Size() )
			{
				for( i = 0; i < summonedEntities.Size(); i += 1 )
				{
					((CNewNPC)summonedEntities[ i ]).Kill( 'SummonsManagerKill' );
				}
			}
		}
		
		return true;
	}
}




class BTTaskSummonsManagerDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSummonsManager';
	
	editable var summonedEntitiesTag : name;
	editable var killEntitiesOnDistance : bool;
	editable var killDistance : float;
	
	default killEntitiesOnDistance = false;
	default killDistance = 30.0;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'OnMonsterCombatEnd' );
	}
}