/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct CreatureCounterDef
{
	var entryName 		: name; default entryName = '';
	var creatureAmount  : int; default creatureAmount = 0;
}

struct CreaturesGroupDef
{
	editable var groupName 			: name; default groupName = '';
	var disabledBySources   : int; default disabledBySources = 0;
	editable var sourcesNames 		: array <name>;
}


class CEncounterDataManager extends IScriptable
{
	editable var resetOnFullRespawn : bool; default resetOnFullRespawn = true;
	editable inlined saved var disabledCreaturesGroups 		   : array <CreaturesGroupDef>;
	
	private saved var killedCreatures : int;
	private saved var currentlySpawnedCreatures : int;
	private saved var spawnedCreatures : int;
	private saved var lostCreatures : int;
	
	private saved var killedCreaturesByEntry 		   : array <CreatureCounterDef>;
	private saved var currentlySpawnedCreaturesByEntry : array <CreatureCounterDef>;
	private saved var spawnedCreaturesByEntry 		   : array <CreatureCounterDef>;
	private saved var lostCreaturesByEntry 		   	   : array <CreatureCounterDef>;
	
	
	
	private saved var disbledMonitors				   : array < ISpawnTreeSpawnMonitorInitializer >;
	
	
	 var ownerTasksToPerform					    : array <SOwnerEncounterTaskParams>;
	 var externalTasksToPerform				   		: array <SExternalEncounterTaskParams>;
	
	


	public function ProcessFullRespawn ()
	{
		if ( resetOnFullRespawn )
		{
			ResetData ();
		}
	}
	
	
	private function ResetData ()
	{
		killedCreatures = 0;
		currentlySpawnedCreatures = 0;
		spawnedCreatures = 0;
		lostCreatures = 0;
		killedCreaturesByEntry.Clear();
		currentlySpawnedCreaturesByEntry.Clear();
		spawnedCreaturesByEntry.Clear();
		lostCreaturesByEntry.Clear();
		disbledMonitors.Clear();
		
	}
	
	public function DisableMonitor ( monitor : ISpawnTreeSpawnMonitorInitializer )
	{
		disbledMonitors.PushBack ( monitor );
	}
	
	public function IsMonitorEnabled ( monitor : ISpawnTreeSpawnMonitorInitializer ) : bool
	{
		var i : int;
		
		for ( i=0; i < disbledMonitors.Size(); i+=1 )
		{
			if ( monitor == disbledMonitors[i] )
			{
				return false;
			}
		}
		return true;
	}
	
	
	
	
	public function AddOwnerTask ( _task : SOwnerEncounterTaskParams )
	{
		_task.setTime = theGame.GetGameTime();
		ownerTasksToPerform.PushBack ( _task );
	}
	
	public function AddExternalTask ( _task : SExternalEncounterTaskParams )
	{
		_task.setTime = theGame.GetGameTime();
		externalTasksToPerform.PushBack ( _task );
	}
	
	public function RemoveOwnerTask (  _task : SOwnerEncounterTaskParams )
	{
		ownerTasksToPerform.Remove ( _task );
	}
	
	public function RemoveExternalTask (  _task : SExternalEncounterTaskParams )
	{
		externalTasksToPerform.Remove ( _task );
	}
	
	function SetOwnerTaskUniqueId ( _task : SOwnerEncounterTaskParams )
	{
		var i : int;
		var ID : int;
		
		for ( i = 0; i < ownerTasksToPerform.Size(); i+=1 )
		{
			
			if ( ownerTasksToPerform[i].ID == ID )
			{
				ID += 1;
			}
			
		}
		_task.ID = ID;
	}
	
		function SetExternalTaskUniqueId ( _task : SExternalEncounterTaskParams )
	{
		var i : int;
		var ID : int;
		
		for ( i = 0; i < externalTasksToPerform.Size(); i+=1 )
		{
			
			if ( externalTasksToPerform[i].ID == ID )
			{
				ID += 1;
			}
			
		}
		_task.ID = ID;
	}
	
	public function GetOwnerTaskByID ( _id : int, out task : SOwnerEncounterTaskParams ) : bool
	{
		var i : int;
		
		for ( i = 0; i < ownerTasksToPerform.Size(); i+=1 )
		{
			
			if ( ownerTasksToPerform[i].ID == _id )
			{
				task = ownerTasksToPerform[i];
				return true;
			}
			
		}
		
		return false;
	}
	
	public function GetExternalTaskByID ( _id : int, out task : SExternalEncounterTaskParams ) : bool
	{
		var i : int;
		
		for ( i = 0; i < externalTasksToPerform.Size(); i+=1 )
		{
			
			if ( externalTasksToPerform[i].ID == _id )
			{
				task = externalTasksToPerform[i];
				return true;

			}
			
		}
		
		return false;
	}
	
	
	public function DisableCreaturesGroup ( groupName : name, sourceName : name )
	{
		var i : int;
		var k : int;
		
		var creaturesGroupEntry : CreaturesGroupDef;
		
		
		for ( i = 0; i < disabledCreaturesGroups.Size(); i+=1 )
		{
			if ( disabledCreaturesGroups[i].groupName == groupName )
			{
				if ( sourceName != '' )
				{
					for ( k = 0; k < disabledCreaturesGroups[i].sourcesNames.Size(); k += 1 )
					{
						if ( disabledCreaturesGroups[i].sourcesNames[k] == sourceName )
						{
							return;
						}
					}
					disabledCreaturesGroups[i].sourcesNames.PushBack ( sourceName );
				}
				else
				{
					disabledCreaturesGroups[i].disabledBySources +=1;
				}
				
				return;
			}
		}
		
		creaturesGroupEntry = InitCreaturesGroupEntry ( groupName );
		
		if ( sourceName != '' )
		{
			creaturesGroupEntry.sourcesNames.PushBack ( sourceName );
		}
		else
		{
			creaturesGroupEntry.disabledBySources +=1;
		}
		disabledCreaturesGroups.PushBack ( creaturesGroupEntry );
		
			
	}
	
	public function EnableCreaturesGroup ( groupName : name, sourceName : name )
	{
		var i : int;
		var k : int;
		
				
		for ( i = 0; i < disabledCreaturesGroups.Size(); i+=1 )
		{
			if ( disabledCreaturesGroups[i].groupName == groupName )
			{
			
				if ( sourceName != '' )
				{
					for ( k = 0; k < disabledCreaturesGroups[i].sourcesNames.Size(); k += 1 )
					{
						if ( disabledCreaturesGroups[i].sourcesNames[k] == sourceName  )
						{							
							disabledCreaturesGroups[i].sourcesNames.Remove ( disabledCreaturesGroups[i].sourcesNames[k] );							
						}
					}
				}
				else
				{
					if ( disabledCreaturesGroups[i].disabledBySources > 0 )
					{
						disabledCreaturesGroups[i].disabledBySources -=1;
					}
				}
				if ( disabledCreaturesGroups[i].disabledBySources <= 0 && disabledCreaturesGroups[i].sourcesNames.Size() <= 0  )
				{
					disabledCreaturesGroups.Remove( disabledCreaturesGroups[i] );
				}
				return;
			}
		}		
		
	}
	
	private function InitCreaturesGroupEntry ( groupName : name ) : CreaturesGroupDef
	{
		var creaturesGroupEntry : CreaturesGroupDef;
		
		creaturesGroupEntry.groupName = groupName;
		
		return creaturesGroupEntry;
		
	}
	
	public function GetDisabledCreaturesGroupSourcesAmount ( groupName : name ) : int
	{
		
		var i : int;
		
		for ( i = 0; i < disabledCreaturesGroups.Size(); i+=1 )
		{
			if ( disabledCreaturesGroups[i].groupName == groupName )
			{
				return disabledCreaturesGroups[i].disabledBySources;
			}
		}
		return 0;
		
	}
	
	public function IsCreatureGroupDisableByAnySource ( groupName : name ) : bool
	{
		
		var i : int;
		
		for ( i = 0; i < disabledCreaturesGroups.Size(); i+=1 )
		{
			if ( disabledCreaturesGroups[i].groupName == groupName )
			{
				if ( disabledCreaturesGroups[i].sourcesNames.Size() > 0 )
				{
					return true;
				}
			}
		}
		return false;
		
	}
	
	
	
	
	public function AddLostCreatureByEntry ( entryName : name )
	{
		var i : int;
		var creatureEntry : CreatureCounterDef;
		
		
		for ( i = 0; i < lostCreaturesByEntry.Size(); i+=1 )
		{
			if ( lostCreaturesByEntry[i].entryName == entryName )
			{
				lostCreaturesByEntry[i].creatureAmount +=1;
				return;
			}
		}
		
		creatureEntry = InitCreatureCounterEntry ( entryName );
		
		creatureEntry.creatureAmount +=1;
		lostCreaturesByEntry.PushBack ( creatureEntry );
		
			
	}
	
	public function RemoveLostCreatureByEntry ( entryName : name )
	{
		var i : int;
		var creatureEntry : CreatureCounterDef;
		
				
		for ( i = 0; i < lostCreaturesByEntry.Size(); i+=1 )
		{
			if ( lostCreaturesByEntry[i].entryName == entryName )
			{
				if ( lostCreaturesByEntry[i].creatureAmount > 0 )
				{
					lostCreaturesByEntry[i].creatureAmount -=1;
				}
				return;
			}
		}		
		
	}
	
	public function GetLostCreaturesByEntry ( entryName : name ) : int
	{
		
		var i : int;
		
		for ( i = 0; i < lostCreaturesByEntry.Size(); i+=1 )
		{
			if ( lostCreaturesByEntry[i].entryName == entryName )
			{
				return lostCreaturesByEntry[i].creatureAmount;
			}
		}
		return 0;
		
	}
	
	public function AddKilledCreatureByEntry ( entryName : name )
	{
		var i : int;
		var creatureEntry : CreatureCounterDef;
		
		
		for ( i = 0; i < killedCreaturesByEntry.Size(); i+=1 )
		{
			if ( killedCreaturesByEntry[i].entryName == entryName )
			{
				killedCreaturesByEntry[i].creatureAmount +=1;
				return;
			}
		}
		
		creatureEntry = InitCreatureCounterEntry ( entryName );
		
		creatureEntry.creatureAmount +=1;
		killedCreaturesByEntry.PushBack ( creatureEntry );
		
			
	}
	
	public function AddSpawnedCreatureByEntry ( entryName : name )
	{
		var i : int;
		var creatureEntry : CreatureCounterDef;
		
				
		for ( i = 0; i < spawnedCreaturesByEntry.Size(); i+=1 )
		{
			if ( spawnedCreaturesByEntry[i].entryName == entryName )
			{
				spawnedCreaturesByEntry[i].creatureAmount +=1;
				return;
			}
		}
		creatureEntry = InitCreatureCounterEntry ( entryName );
		creatureEntry.creatureAmount +=1;
		
		spawnedCreaturesByEntry.PushBack ( creatureEntry );
			
		
	}
	
	public function RemoveSpawnedCreatureByEntry ( entryName : name )
	{
		var i : int;
		var creatureEntry : CreatureCounterDef;
		
				
		for ( i = 0; i < spawnedCreaturesByEntry.Size(); i+=1 )
		{
			if ( spawnedCreaturesByEntry[i].entryName == entryName )
			{
				if ( spawnedCreaturesByEntry[i].creatureAmount > 0 )
				{
					spawnedCreaturesByEntry[i].creatureAmount -=1;
				}
				return;
			}
		}		
		
	}
	
	public function SetCurrentlySpawnedCreatureByEntry ( entryName : name, spawnedValue : int )
	{
		var i : int;
		var creatureEntry : CreatureCounterDef;
		
		for ( i = 0; i < currentlySpawnedCreaturesByEntry.Size(); i+=1 )
		{
			if ( currentlySpawnedCreaturesByEntry[i].entryName == entryName )
			{
				currentlySpawnedCreaturesByEntry[i].creatureAmount = spawnedValue;
				return;
			}
		}
		
		creatureEntry = InitCreatureCounterEntry ( entryName );
		creatureEntry.creatureAmount = spawnedValue;
		
		currentlySpawnedCreaturesByEntry.PushBack ( creatureEntry );
			
		
	}
	
	public function AddCurrentlySpawnedCreatureByEntry ( entryName : name )
	{
		var i : int;
		var creatureEntry : CreatureCounterDef;
		
		for ( i = 0; i < currentlySpawnedCreaturesByEntry.Size(); i+=1 )
		{
			if ( currentlySpawnedCreaturesByEntry[i].entryName == entryName )
			{
				currentlySpawnedCreaturesByEntry[i].creatureAmount +=1;
				return;
			}
		}

		creatureEntry = InitCreatureCounterEntry ( entryName );
		creatureEntry.creatureAmount +=1;
		
		currentlySpawnedCreaturesByEntry.PushBack ( creatureEntry );
		
	}
	
	public function RemoveCurrentlySpawnedCreatureByEntry ( entryName : name )
	{
		var i : int;
		var creatureEntry : CreatureCounterDef;
		
		for ( i = 0; i < currentlySpawnedCreaturesByEntry.Size(); i+=1 )
		{
			if ( currentlySpawnedCreaturesByEntry[i].entryName == entryName )
			{
				if ( currentlySpawnedCreaturesByEntry[i].creatureAmount > 0 )
				{
					currentlySpawnedCreaturesByEntry[i].creatureAmount -=1;
				}
				return;
			}
		}
			
		
	}
	
	public function GetKilledCreaturesByEntry ( entryName : name ) : int
	{
		
		var i : int;
		
		for ( i = 0; i < killedCreaturesByEntry.Size(); i+=1 )
		{
			if ( killedCreaturesByEntry[i].entryName == entryName )
			{
				return killedCreaturesByEntry[i].creatureAmount;
			}
		}
		return 0;
		
	}
	
	public function GetCurrentlySpawnedCreaturesByEntry ( entryName : name ) : int
	{
		
		var i : int;
		
		for ( i = 0; i < currentlySpawnedCreaturesByEntry.Size(); i+=1 )
		{
			if ( currentlySpawnedCreaturesByEntry[i].entryName == entryName )
			{
				return currentlySpawnedCreaturesByEntry[i].creatureAmount;
			}
		}
		return 0;
		
	}
	
	public function GetSpawnedCreaturesByEntry ( entryName : name ) : int
	{
		
		var i : int;
		
		for ( i = 0; i < spawnedCreaturesByEntry.Size(); i+=1 )
		{
			if ( spawnedCreaturesByEntry[i].entryName == entryName )
			{
				return spawnedCreaturesByEntry[i].creatureAmount;
			}
		}
		return 0;
		
	}
	
	private function InitCreatureCounterEntry ( entryName : name ) : CreatureCounterDef
	{
		var creatureEntry : CreatureCounterDef;
		
		creatureEntry.entryName = entryName;
		
		return creatureEntry;
		
	}
	
	public function AddKilledCreature ()
	{
		killedCreatures +=1;
	}
	
	public function AddSpawnedCreature ()
	{
		spawnedCreatures +=1;
	}
	
	public function RemoveSpawnedCreature ()
	{
		if ( spawnedCreatures > 0 )
		{
			spawnedCreatures -=1;
		}
	}
	
	public function GetKilledCreatures () : int
	{
		return killedCreatures;
	}
	
	public function GetCurrentlySpawnedCreatures () : int
	{
		return currentlySpawnedCreatures;
	}
	
	public function GetSpawnedCreatures () : int
	{
		return spawnedCreatures;
	}
	
	public function SetCurrentlySpawnedCreaturesAmount ( spawnedValue : int )
	{
		currentlySpawnedCreatures = spawnedValue;
	}
	

	
	
}