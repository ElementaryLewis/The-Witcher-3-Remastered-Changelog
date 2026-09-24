/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EEncounterMonitorCounterType
{
	EMCT_KIlledByEntry,
	EMCT_SpawnedByEntry,
	EMCT_CurrentlySpawnedByEntry,
	EMCT_LostByEntry,
}

struct SOwnerEncounterTaskParams
{
	editable var triggerWhenOutsideOwnerEncounterArea 	: bool;
	editable var deactivateEncounter		 			: bool;
	editable inlined var delay    			 			: GameTimeWrapper;
	editable var factOnTaskPerformed		 			: string;
	
	editable var spawnTreeNodesToActivate 	 			: array <name>;
	editable var spawnTreeNodesToDeactivate  			: array <name>;
	editable var encounterPhasetoActivate	 			: name;
	editable var creaturesGroupToDisable				: array <name>;
	editable var creaturesGroupToEnable					: array <name>;
	editable var sourceName								: name;
	editable var forceDespawn							: bool;
	 var ID							 		 			: int;
	 var setTime							 			: GameTime;
	
}

struct SExternalEncounterTaskParams
{
	editable var triggerWhenOutsideOwnerEncounterArea 	: bool;
	editable var shouldEncounterChangeState				: bool; default shouldEncounterChangeState = true;
	editable var enableEncounter 	 		 			: bool;
	editable var encounterTag		 		 			: name;
	editable inlined var delay    						: GameTimeWrapper;
	editable var factOnTaskPerformed		 			: string;

	editable var spawnTreeNodesToActivate 	 			: array <name>;
	editable var spawnTreeNodesToDeactivate  			: array <name>;
	
	editable var creaturesGroupToDisable				: array <name>;
	editable var creaturesGroupToEnable					: array <name>;
	editable var sourceName								: name;
	editable var forceDespawn							: bool;
	editable var encounterPhasetoActivate	 			: name;
	
	var ID							 		 			: int;
	var setTime							 				: GameTime;
	
}

import class ISpawnTreeSpawnMonitorBaseInitializer extends ISpawnTreeInitializer
{
};


import class ISpawnTreeSpawnMonitorInitializer extends ISpawnTreeSpawnMonitorBaseInitializer
{
	function MonitorCreatureSpawned( actor : CActor, spawnTreeEntry : CBaseCreatureEntry, encounter : CEncounter ) {}
	function MonitorCreatureLost( actor : CActor, spawnTreeEntry : CBaseCreatureEntry, encounter : CEncounter ) {}
	function MonitorCreatureKilled( actor : CActor, spawnTreeEntry : CBaseCreatureEntry, encounter : CEncounter ) {}
	
	function GetFriendlyName() : string
	{
		return "Monitor";
	}
	
	import final function GetNumCreaturesSpawned() : int;
	import final function GetNumCreaturesToSpawn() : int;
	import final function GetNumCreaturesDead() : int;
};

class CSpawnTreeMonsterNestMonitorInitializer extends ISpawnTreeSpawnMonitorInitializer
{
	editable var monsterNestTag 			  : name;
	editable var disableRebuildingOnBossDeath : bool; default disableRebuildingOnBossDeath = true;
	
	
	function MonitorCreatureSpawned( actor : CActor, spawnTreeEntry : CBaseCreatureEntry, encounter : CEncounter )
	{
		var numCreaturesSpawned : int;
		var numCreaturesToSpawn : int;
		var numCreaturesDead : int;
		
		numCreaturesSpawned = GetNumCreaturesSpawned();
		numCreaturesToSpawn = GetNumCreaturesToSpawn();
		numCreaturesDead = GetNumCreaturesDead();
	
		Log( "Spawned " + numCreaturesSpawned + "/" + numCreaturesToSpawn + " dead: " + numCreaturesDead );
	}
	function MonitorCreatureLost( actor : CActor, spawnTreeEntry : CBaseCreatureEntry, encounter : CEncounter )
	{
		var numCreaturesSpawned : int;
		var numCreaturesToSpawn : int;
		var numCreaturesDead : int;
		
		numCreaturesSpawned = GetNumCreaturesSpawned();
		numCreaturesToSpawn = GetNumCreaturesToSpawn();
		numCreaturesDead = GetNumCreaturesDead();
	
		Log( "Lost " + numCreaturesSpawned + "/" + numCreaturesToSpawn + " dead: " + numCreaturesDead );
	}
	function MonitorCreatureKilled( actor : CActor, spawnTreeEntry : CBaseCreatureEntry, encounter : CEncounter )
	{
		var monsterNest : CMonsterNestEntity;
		var deadCount : int;
		var numCreaturesSpawned : int;
		var numCreaturesToSpawn : int;
		var numCreaturesDead : int;
		
		numCreaturesSpawned = GetNumCreaturesSpawned();
		numCreaturesToSpawn = GetNumCreaturesToSpawn();
		numCreaturesDead = GetNumCreaturesDead();
		
		
		monsterNest = GetNestInsideEncounter( encounter );
		monsterNest.IncrementBossKilledCounter ();
		
		deadCount = monsterNest.GetBossKilledCounter();
		
		if ( deadCount >= numCreaturesToSpawn )
		{
			monsterNest.SetBossKilled( true);
			monsterNest.SetRebuild ( !disableRebuildingOnBossDeath );
		}
	}
	
	function GetNestInsideEncounter ( encounter : CEncounter ) : CMonsterNestEntity
	{
		var nests   		: array <CEntity>;
		var nest			: CMonsterNestEntity;
		var i 				: int;
		var encounterArea 	: CTriggerAreaComponent;
		
		theGame.GetEntitiesByTag( monsterNestTag, nests );
		
		for ( i = 0; i < nests.Size(); i+=1 )
		{
			nest = (CMonsterNestEntity)nests[i];
			
			if ( nest )
			{
				encounterArea = encounter.GetEncounterArea();
				
				if ( encounterArea.TestEntityOverlap ( nest ))
				{
					return nest;
				}
			}
		}
		return NULL;
	
		
	}
	function GetFriendlyName() : string
	{
		return "MonsterNestMonitor";
	}
};


class CSpawnTreeDeathCountMonitorInitializer extends ISpawnTreeSpawnMonitorInitializer
{
	
	function MonitorCreatureKilled( actor : CActor, spawnTreeEntry : CBaseCreatureEntry, encounter : CEncounter )
	{
		var encDatamanager : CEncounterDataManager;
		
		
		encDatamanager = encounter.GetEncounterDataManager();
		
		if ( !encDatamanager )
		{
			encounter.InitializeEncounterDataManager();
			encDatamanager = encounter.GetEncounterDataManager();
		}
		
		encDatamanager.AddKilledCreature();
		
	}
	
	function GetFriendlyName() : string
	{
		return "KilledCounterMonitor";
	}
};

class CSpawnTreeKilledCounterByEntryMonitorInitializer extends ISpawnTreeSpawnMonitorInitializer
{
	
	function MonitorCreatureKilled( actor : CActor, spawnTreeEntry : CBaseCreatureEntry, encounter : CEncounter )
	{
		var encDatamanager : CEncounterDataManager;
		var entryName : name;
		
		entryName = spawnTreeEntry.nodeName;
		
		encDatamanager = encounter.GetEncounterDataManager();
		
		if ( !encDatamanager )
		{
			encounter.InitializeEncounterDataManager();
			encDatamanager = encounter.GetEncounterDataManager();
		}
		
		encDatamanager.AddKilledCreatureByEntry( entryName );
		
	}
	
	function GetFriendlyName() : string
	{
		return "KilledCounterByEntryMonitor";
	}
};


class CSpawnTreeSpawnedCounterMonitorInitializer extends ISpawnTreeSpawnMonitorInitializer
{
	
	function MonitorCreatureSpawned( actor : CActor, spawnTreeEntry : CBaseCreatureEntry, encounter : CEncounter )
	{
		var encDatamanager : CEncounterDataManager;
		var entryName : name;
		
		entryName = spawnTreeEntry.nodeName;
		
		encDatamanager = encounter.GetEncounterDataManager();
		
		if ( !encDatamanager )
		{
			encounter.InitializeEncounterDataManager();
			encDatamanager = encounter.GetEncounterDataManager();
		}
		
		encDatamanager.AddSpawnedCreature( );
		
	}
	
	function GetFriendlyName() : string
	{
		return "SpawnedCounterMonitor";
	}
};

class CSpawnTreeSpawnedCounterByEntryMonitorInitializer extends ISpawnTreeSpawnMonitorInitializer
{
	
	function MonitorCreatureSpawned( actor : CActor, spawnTreeEntry : CBaseCreatureEntry, encounter : CEncounter )
	{
		var encDatamanager : CEncounterDataManager;
		var entryName : name;
		
		entryName = spawnTreeEntry.nodeName;
		
		encDatamanager = encounter.GetEncounterDataManager();
		
		if ( !encDatamanager )
		{
			encounter.InitializeEncounterDataManager();
			encDatamanager = encounter.GetEncounterDataManager();
		}
		
		encDatamanager.AddSpawnedCreatureByEntry( entryName );
		
	}
	
	function GetFriendlyName() : string
	{
		return "SpawnedCounterByEntryMonitor";
	}
};

class CSpawnTreeCurrentlySpawnedCounterMonitorInitializer extends ISpawnTreeSpawnMonitorInitializer
{
	
	function MonitorCreatureSpawned( actor : CActor, spawnTreeEntry : CBaseCreatureEntry, encounter : CEncounter )
	{
		var encDatamanager : CEncounterDataManager;
		var numCreaturesSpawned : int;
		
		
		numCreaturesSpawned = GetNumCreaturesSpawned();
		
		
		encDatamanager = encounter.GetEncounterDataManager();
		
		if ( !encDatamanager )
		{
			encounter.InitializeEncounterDataManager();
			encDatamanager = encounter.GetEncounterDataManager();
		}
		
		encDatamanager.SetCurrentlySpawnedCreaturesAmount( numCreaturesSpawned );
		
	}
	
	
	function GetFriendlyName() : string
	{
		return "CurrentlySpawnedCounterMonitor";
	}
};


class CSpawnTreeCurrentlySpawnedCounterByEntryMonitorInitializer extends ISpawnTreeSpawnMonitorInitializer
{
	
	function MonitorCreatureSpawned( actor : CActor, spawnTreeEntry : CBaseCreatureEntry, encounter : CEncounter )
	{
		var encDatamanager : CEncounterDataManager;
		var numCreaturesSpawned : int;
		var entryName : name;
		
		entryName = spawnTreeEntry.nodeName;
		
		
		
		encDatamanager = encounter.GetEncounterDataManager();
		
		if ( !encDatamanager )
		{
			encounter.InitializeEncounterDataManager();
			encDatamanager = encounter.GetEncounterDataManager();
		}
		
		encDatamanager.AddCurrentlySpawnedCreatureByEntry( entryName );
		
	}
	
	function MonitorCreatureKilled( actor : CActor, spawnTreeEntry : CBaseCreatureEntry, encounter : CEncounter )
	{
		var encDatamanager : CEncounterDataManager;
		var entryName : name;
		
				
		entryName = spawnTreeEntry.nodeName;
		
		encDatamanager = encounter.GetEncounterDataManager();
		
		if ( !encDatamanager )
		{
			encounter.InitializeEncounterDataManager();
			encDatamanager = encounter.GetEncounterDataManager();
		}
		
		encDatamanager.RemoveCurrentlySpawnedCreatureByEntry( entryName );
			
	
	}
	
	function MonitorCreatureLost( actor : CActor, spawnTreeEntry : CBaseCreatureEntry, encounter : CEncounter )
	{
		var encDatamanager 		: CEncounterDataManager;
		var entryName 			: name;
		var spawnedCreatures 	: int;
		
				
		entryName = spawnTreeEntry.nodeName;
					
		encDatamanager = encounter.GetEncounterDataManager();
		
		if ( !encDatamanager )
		{
			encounter.InitializeEncounterDataManager();
			encDatamanager = encounter.GetEncounterDataManager();
		}
	
		encDatamanager.RemoveCurrentlySpawnedCreatureByEntry( entryName );
		spawnedCreatures = encDatamanager.GetCurrentlySpawnedCreaturesByEntry ( entryName );
			
					
			
	}
	function GetFriendlyName() : string
	{
		return "CurrentlySpawnedCounterByEntryMonitor";
	}
};

class CSpawnTreeEncunterStateByEntryMonitorInitializer extends ISpawnTreeSpawnMonitorInitializer
{
	editable var counterType 				 		:  EEncounterMonitorCounterType;
	editable var referenceValue 			 		: int;
	editable var operator 					 		: EOperator;
	editable var disableMonitorAfterTasksFinished 	: bool; default disableMonitorAfterTasksFinished = true;
	editable var factOnConditionMet			 		: string;
	
	editable inlined var ownerEncounterTasks 		: 	array < SOwnerEncounterTaskParams >;	
	editable inlined var externalEncounterTasks 	: 	array < SExternalEncounterTaskParams >;	
	
	
	
	function MonitorCreatureKilled( actor : CActor, spawnTreeEntry : CBaseCreatureEntry, encounter : CEncounter )
	{
		var encDatamanager : CEncounterDataManager;
		var entryName : name;
		var killedCreatures : int;
		
		if ( counterType ==  EMCT_KIlledByEntry || counterType == EMCT_LostByEntry || counterType == EMCT_CurrentlySpawnedByEntry )
		{
			entryName = spawnTreeEntry.nodeName;
			
			encDatamanager = encounter.GetEncounterDataManager();
			
			if ( !encDatamanager )
			{
				encounter.InitializeEncounterDataManager();
				encDatamanager = encounter.GetEncounterDataManager();
			}
			
			if ( !encDatamanager.IsMonitorEnabled( this ) )
			{
				return;
			}
			
			if ( counterType ==  EMCT_KIlledByEntry )
			{
				encDatamanager.AddKilledCreatureByEntry( entryName );
				
				killedCreatures = encDatamanager.GetKilledCreaturesByEntry( entryName );
			}	
			else if ( counterType == EMCT_LostByEntry )
			{
				encDatamanager.AddLostCreatureByEntry( entryName );
				killedCreatures = encDatamanager.GetLostCreaturesByEntry ( entryName );
			}
			else if ( counterType == EMCT_CurrentlySpawnedByEntry )
			{
				encDatamanager.RemoveCurrentlySpawnedCreatureByEntry( entryName );
				
				killedCreatures = encDatamanager.GetCurrentlySpawnedCreaturesByEntry ( entryName );
			}
			
			if ( TestCondition( killedCreatures ))
			{
				SetTasks( encounter );
				
				if ( disableMonitorAfterTasksFinished )
				{
					encDatamanager.DisableMonitor ( this );
				}
			}
		}
		
	}
	function MonitorCreatureSpawned( actor : CActor, spawnTreeEntry : CBaseCreatureEntry, encounter : CEncounter )
	{
		var encDatamanager 		: CEncounterDataManager;
		var entryName 			: name;
		var spawnedCreatures 	: int;
		
		
		
		if ( counterType == EMCT_SpawnedByEntry || counterType == EMCT_CurrentlySpawnedByEntry || counterType == EMCT_LostByEntry )
		{
			entryName = spawnTreeEntry.nodeName;
			
			encDatamanager = encounter.GetEncounterDataManager();
			
			if ( !encDatamanager )
			{
				encounter.InitializeEncounterDataManager();
				encDatamanager = encounter.GetEncounterDataManager();
			}
			
			if ( !encDatamanager.IsMonitorEnabled( this ) )
			{
				return;
			}
			
			if ( counterType == EMCT_CurrentlySpawnedByEntry )
			{
				encDatamanager.AddCurrentlySpawnedCreatureByEntry( entryName );
				
				spawnedCreatures = encDatamanager.GetCurrentlySpawnedCreaturesByEntry ( entryName );
			}
			else if ( counterType == EMCT_SpawnedByEntry )
			{
				encDatamanager.AddSpawnedCreatureByEntry( entryName );
				spawnedCreatures = encDatamanager.GetSpawnedCreaturesByEntry ( entryName );
			}
			
			else if ( counterType == EMCT_LostByEntry )
			{
				encDatamanager.RemoveLostCreatureByEntry( entryName );
				spawnedCreatures = encDatamanager.GetLostCreaturesByEntry ( entryName );
			}
			
			if ( TestCondition( spawnedCreatures ))
			{
				SetTasks( encounter );	
				if ( disableMonitorAfterTasksFinished )
				{
					encDatamanager.DisableMonitor ( this );
				}
				
			}
		}	
		
	}
	
	function MonitorCreatureLost( actor : CActor, spawnTreeEntry : CBaseCreatureEntry, encounter : CEncounter )
	{
		var encDatamanager 		: CEncounterDataManager;
		var entryName 			: name;
		var spawnedCreatures 	: int;
		
		
		
		if ( counterType == EMCT_LostByEntry || counterType == EMCT_CurrentlySpawnedByEntry )
		{
			entryName = spawnTreeEntry.nodeName;
						
			encDatamanager = encounter.GetEncounterDataManager();
			
			if ( !encDatamanager )
			{
				encounter.InitializeEncounterDataManager();
				encDatamanager = encounter.GetEncounterDataManager();
			}
			
			if ( !encDatamanager.IsMonitorEnabled( this ) )
			{
				return;
			}
			
			if ( counterType == EMCT_CurrentlySpawnedByEntry )
			{
				encDatamanager.RemoveCurrentlySpawnedCreatureByEntry( entryName );
				spawnedCreatures = encDatamanager.GetCurrentlySpawnedCreaturesByEntry ( entryName );
			}
			else if ( counterType == EMCT_LostByEntry )
			{
				encDatamanager.AddLostCreatureByEntry( entryName );
				spawnedCreatures = encDatamanager.GetLostCreaturesByEntry ( entryName );
			}
			
			if ( TestCondition( spawnedCreatures ))
			{
				SetTasks( encounter );	
				
				if ( disableMonitorAfterTasksFinished )
				{
					encDatamanager.DisableMonitor ( this );
				}
				
			}
		}	
	}
	
	function TestCondition( value : int ) : bool
	{
			
		switch ( operator )
		{
			case EO_Equal:			return value == referenceValue;
			case EO_NotEqual:		return value != referenceValue;
			case EO_Less:			return value < referenceValue;
			case EO_LessEqual:		return value <= referenceValue;
			case EO_Greater:		return value > referenceValue;
			case EO_GreaterEqual:	return value >= referenceValue;
			default : 				return false;
		}
	}
	
	function SetTasks ( encounter : CEncounter )
	{
		var  i : int;
		var encDatamanager 		: CEncounterDataManager;
		
		encDatamanager = encounter.GetEncounterDataManager();
		
		for ( i=0; i < ownerEncounterTasks.Size(); i+=1 )
		{
			encDatamanager.AddOwnerTask ( ownerEncounterTasks[i]);
		}
		
		for ( i=0; i < externalEncounterTasks.Size(); i+=1 )
		{
			encDatamanager.AddExternalTask ( externalEncounterTasks[i]);
		}
		
		encounter.ProcessTasks ();
		
		if ( !FactsDoesExist ( factOnConditionMet ))
		{
			FactsAdd ( factOnConditionMet, 1, -1 );
		}
		
		
	}
	
	
	
	function GetFriendlyName() : string
	{
		return "EncounterStateByEntryMonitor";
	}
};

class CSpawnTreeRiftSpawnedCounterMonitorInitializer extends ISpawnTreeSpawnMonitorInitializer
{
	editable var riftTag : name;
	editable var spawnLimit : int;
	
	default spawnLimit = 10;

	function MonitorCreatureSpawned( actor : CActor, spawnTreeEntry : CBaseCreatureEntry, encounter : CEncounter )
	{
		var rift : CRiftEntity;
			
		if( !rift )
		{
			rift = GetRiftInsideEncounter( encounter );
			if( rift )
				rift.SetSpawnLimit( spawnLimit );
		}
	
		if( rift )
		{
			rift.IncrementSpawnCounter();
		}
	}

	function GetRiftInsideEncounter( encounter : CEncounter ) : CRiftEntity
	{
		var rifts : array <CEntity>;
		var rift : CRiftEntity;
		var i : int;
		var encounterArea : CTriggerAreaComponent;
		
		theGame.GetEntitiesByTag( riftTag, rifts );
		
		for( i = 0; i < rifts.Size(); i+=1 )
		{
			rift = (CRiftEntity)rifts[i];
			
			if( rift )
			{
				encounterArea = encounter.GetEncounterArea();
				
				if( encounterArea.TestEntityOverlap( rift ) )
				{
					return rift;
				}
			}
		}
		
		return NULL;
	}
	
	function GetFriendlyName() : string
	{
		return "RiftMonitor";
	}
};
