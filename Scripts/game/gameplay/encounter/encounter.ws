/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CEncounter extends CGameplayEntity
{
	import public saved var enabled : bool;
	import final function GetPlayerDistFromArea()	: float;
	import final function GetEncounterArea()		: CTriggerAreaComponent;
	import final function IsPlayerInEncounterArea()	: bool;
	import final function EnterArea();
	import final function LeaveArea();
	import final function IsEnabled() : bool;
	import final function EnableEncounter( enable  : bool );
	import final function EnableMember( memberName : CName, enable : bool);
	import final function ForceDespawnDetached();
	import final function SetSpawnPhase( phaseName : name ) : bool;
	
	editable inlined saved var dataManager 				    : CEncounterDataManager;
	private saved var ownerTasksToPerformOnLeaveEncounter	: array <SOwnerEncounterTaskParams>;
	private  var externalTasksToPerformOnLeaveEncounter		: array <SExternalEncounterTaskParams>;
	
	private saved var isUpdating 							: bool; default isUpdating = false;
	
	
	

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		
		if ( enabled && activator.GetEntity() == thePlayer )
		{
			EnterArea();
		}
	}

	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		
		if( activator.GetEntity() == thePlayer )
		{
			if ( enabled )
			{
				LeaveArea();
			}
			 UpdateDelayedTasks ();
		}
	}
	
	function UpdateDelayedTasks ()
	{
		var i : int;
		
		for ( i = 0; i < ownerTasksToPerformOnLeaveEncounter.Size(); i += 1 )
		{
			RunOwnerTask ( ownerTasksToPerformOnLeaveEncounter[i] );
		}
		
		for ( i = 0; i < externalTasksToPerformOnLeaveEncounter.Size(); i += 1 )
		{
			RunExternalTask ( externalTasksToPerformOnLeaveEncounter[i] );
		}
		RemoveTimer ( 'CheckMeditationTimer' );
	}
	
	function OnFullRespawn()
	{
		if ( dataManager && dataManager.resetOnFullRespawn )
		{
			dataManager.ProcessFullRespawn();
		}
	}
	
	function GetEncounterDataManager () : CEncounterDataManager
	{
		return dataManager;
	}
    function ForceDespawnDetachedWithDelay ( realTimeDelay : float )
	{
		AddTimer ( 'ForceDespawnWithDelayTimer', realTimeDelay, false,,,true, true );
	}
	
	timer function ForceDespawnWithDelayTimer ( timeDelta : float, id : int )
	{
		ForceDespawnDetached ();
	}
	
	public function InitializeEncounterDataManager ()
	{
		dataManager = new CEncounterDataManager;
	}
	
	public function ProcessTasks ()
	{
		var i 	       	  : int;
		var delay         : int;
		var ownerTask     : SOwnerEncounterTaskParams;
		var externalTask  : SExternalEncounterTaskParams;
		var taskID		  : int;
		
		while (  i < dataManager.ownerTasksToPerform.Size() )
		{
			ownerTask = dataManager.ownerTasksToPerform[i];
			
			delay = GameTimeToSeconds (ownerTask.delay.gameTime);
			
			if ( delay <= 0 )
			{
				if ( ownerTask.triggerWhenOutsideOwnerEncounterArea && IsPlayerInEncounterArea() && FactsQuerySum ( "MeditationStarted" ) <= 0 )
				{
					ownerTasksToPerformOnLeaveEncounter.PushBack ( ownerTask );
					i+=1;
					AddTimer( 'CheckMeditationTimer', 1.0f, true , , , true, true ); 
				}
				else
				{
					RunOwnerTask ( ownerTask );
					continue;
				}
				
			}
			else
			{
				taskID = AddGameTimeTimer( 'RunOwnerTaskTimer', ownerTask.delay.gameTime,false , , , true, false );
				dataManager.ownerTasksToPerform[i].ID = 	taskID;
				i+=1;
				
			}
		}
		
		i = 0;
		
		while ( i < dataManager.externalTasksToPerform.Size() )
		{
			externalTask = dataManager.externalTasksToPerform[i];
			
			delay = GameTimeToSeconds (externalTask.delay.gameTime);
			
			if ( delay <= 0 )
			{
				if ( externalTask.triggerWhenOutsideOwnerEncounterArea && IsPlayerInEncounterArea() && FactsQuerySum ( "MeditationStarted" ) <= 0 )
				{
					externalTasksToPerformOnLeaveEncounter.PushBack ( externalTask );
					i+=1;
					AddTimer( 'CheckMeditationTimer', 1.0f, true , , , true, true ); 
				}
				else
				{
					RunExternalTask ( externalTask );
					continue;
				}
			}
			else
			{
				taskID = AddGameTimeTimer( 'RunExternalTaskTimer', externalTask.delay.gameTime, false , , , true, false );
				dataManager.externalTasksToPerform[i].ID = 	taskID;
				i+=1;
			}
		}
	}
	
	function RunOwnerTask ( task : SOwnerEncounterTaskParams )
	{
		var i : int;
		var delay : int;
		
		dataManager.RemoveOwnerTask( task );
		
		
		if ( task.creaturesGroupToEnable.Size() > 0 )
		{
			i = 0;
								
			for ( i=0; i < task.creaturesGroupToEnable.Size(); i+=1 )
			{
				dataManager.EnableCreaturesGroup ( task.creaturesGroupToEnable[i], task.sourceName );
			}
							
		}
		
		if ( task.creaturesGroupToDisable.Size() > 0 )
		{
			i = 0;
								
			for ( i=0; i < task.creaturesGroupToDisable.Size(); i+=1 )
			{
				dataManager.DisableCreaturesGroup ( task.creaturesGroupToDisable[i], task.sourceName );
				
			}
							
		}
		
		if ( task.factOnTaskPerformed != "" && !FactsDoesExist ( task.factOnTaskPerformed ) )
		{
			FactsAdd ( task.factOnTaskPerformed, 1, -1 );
		}
		
		if ( task.forceDespawn )
		{
			ForceDespawnDetachedWithDelay ( 3.0f );
		}
		
		if ( task.deactivateEncounter )
		{
			EnableEncounter ( false );
			return;
			
		}
		if ( !task.deactivateEncounter )
		{
			if ( !IsEnabled())
			{
				EnableEncounter ( true );				
			}
		}
		if ( task.spawnTreeNodesToActivate.Size() > 0 )
		{
			i = 0;
								
			for ( i=0; i < task.spawnTreeNodesToActivate.Size(); i+=1 )
			{
				EnableMember( task.spawnTreeNodesToActivate[i], true );
			}
		}
		if ( task.spawnTreeNodesToDeactivate.Size() > 0 )
		{
			i = 0;
								
			for ( i=0; i < task.spawnTreeNodesToDeactivate.Size(); i+=1 )
			{
				EnableMember( task.spawnTreeNodesToDeactivate[i], false );
			}
							
		}
		
		if ( task.encounterPhasetoActivate != '' )
		{
			SetSpawnPhase( task.encounterPhasetoActivate );
		}
	}
	
	function RunExternalTask ( task: SExternalEncounterTaskParams )
	{
		var i : int;
		var encounter : CEncounter;
		var externalDataManager : CEncounterDataManager;
		
		dataManager.RemoveExternalTask( task );
		
		if ( task.encounterTag != '' )
		{
			encounter = ( CEncounter)theGame.GetEntityByTag ( task.encounterTag );
			
			if ( !encounter )
			{
				return;
			}
		}
		else
		{
			return;
		}
		
		externalDataManager = encounter.dataManager;
			
		if ( !externalDataManager )
		{
			encounter.InitializeEncounterDataManager();
			externalDataManager = encounter.dataManager;
		}
		
		if ( task.creaturesGroupToEnable.Size() > 0 )
		{
		
			i = 0;
								
			for ( i=0; i < task.creaturesGroupToEnable.Size(); i+=1 )
			{
				externalDataManager.EnableCreaturesGroup ( task.creaturesGroupToEnable[i], task.sourceName );
			}
							
		}
		
		if ( task.creaturesGroupToDisable.Size() > 0 )
		{
			i = 0;
								
			for ( i=0; i < task.creaturesGroupToDisable.Size(); i+=1 )
			{
				externalDataManager.DisableCreaturesGroup ( task.creaturesGroupToDisable[i], task.sourceName );
			}
							
		}
		if ( task.factOnTaskPerformed != "" && !FactsDoesExist ( task.factOnTaskPerformed ) )
		{
			FactsAdd ( task.factOnTaskPerformed, 1, -1 );
		}
		if ( task.forceDespawn )
		{
			ForceDespawnDetachedWithDelay ( 3.0f );
		}
		
		if ( task.shouldEncounterChangeState )
		{
			encounter.EnableEncounter ( task.enableEncounter );
			
			if ( !task.enableEncounter )
			{
				return;
			}
		}
			
		if ( task.spawnTreeNodesToActivate.Size() > 0 )
		{
			i = 0;
								
			for ( i=0; i < task.spawnTreeNodesToActivate.Size(); i+=1 )
			{
				encounter.EnableMember( task.spawnTreeNodesToActivate[i], true );
			}
		}
		if ( task.spawnTreeNodesToDeactivate.Size() > 0 )
		{
			i = 0;
								
			for ( i=0; i < task.spawnTreeNodesToDeactivate.Size(); i+=1 )
			{
				encounter.EnableMember( task.spawnTreeNodesToDeactivate[i], false );
			}
							
		}
		if ( task.encounterPhasetoActivate != '' )
		{
			encounter.SetSpawnPhase( task.encounterPhasetoActivate );
		}
	}
	
	
	
	timer function RunOwnerTaskTimer ( timeDelta : GameTime , id : int )
	{
		
		var ownerTask  : SOwnerEncounterTaskParams;
	
		if ( dataManager.GetOwnerTaskByID( id, ownerTask ))
		{
			if ( ownerTask.triggerWhenOutsideOwnerEncounterArea && IsPlayerInEncounterArea() && FactsQuerySum ( "MeditationStarted" ) <= 0 )
			{
				ownerTasksToPerformOnLeaveEncounter.PushBack ( ownerTask );
				AddTimer( 'CheckMeditationTimer', 1.0f, true , , , true, true ); 
			}
			else
			{
				RunOwnerTask ( ownerTask );
			}
		}
		
	}
	
	timer function RunExternalTaskTimer ( timeDelta : GameTime , id : int )
	{
		
		var externalTask  : SExternalEncounterTaskParams;
	
		if ( dataManager.GetExternalTaskByID( id, externalTask ))
		{
			if ( externalTask.triggerWhenOutsideOwnerEncounterArea && IsPlayerInEncounterArea() && FactsQuerySum ( "MeditationStarted" ) <= 0 )
			{
				externalTasksToPerformOnLeaveEncounter.PushBack ( externalTask );
				AddTimer( 'CheckMeditationTimer', 1.0f, true , , , true, true ); 
			}
			else
			{
				RunExternalTask ( externalTask );
			}
		}
		
	}
	
	timer function CheckMeditationTimer ( timeDelta : float , id : int )
	{
		if ( FactsQuerySum ( "MeditationStarted" ) > 0 )
		{
			UpdateDelayedTasks();
		}
	}
	
	
}




class CEncounterActivator extends CGameplayEntity
{

	public editable var encounterAreaTag : name;
	public editable var phaseToActivate : name;
	public editable var disableEncounterOnExit : bool; default disableEncounterOnExit = true;
	
	var encounter : CEncounter;
	
	saved var isPlayerInArea : bool;
	default isPlayerInArea = false;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		
		if ( !((CPlayer)(activator.GetEntity())) )
			return false;
		
		isPlayerInArea = true;
		ActivateEncounter();
	}

	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		
		if ( !((CPlayer)(activator.GetEntity())) )
			return false;
		
		isPlayerInArea = false;
		if ( disableEncounterOnExit )
		{
			DeactivateEncounter();
		}
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );

		if ( isPlayerInArea )
		{
			ActivateEncounter();
		}
	}
	
	private function FindEncounter()
	{
		if ( !encounter && encounterAreaTag != '' )
		{
			encounter = (CEncounter)theGame.GetEntityByTag( encounterAreaTag );
		}
	}
	
	private function ActivateEncounter()
	{
		ChangeEncounterActiveState( true );
	}
	
	private function DeactivateEncounter()
	{
		ChangeEncounterActiveState( false );
	}
	
	private function ChangeEncounterActiveState( isEncounterEnabled : bool )
	{
		if ( !encounter )
		{
			FindEncounter();
		}
		if ( encounter )
		{
			encounter.EnableEncounter( isEncounterEnabled );
			if ( phaseToActivate != '' )
			{
				encounter.SetSpawnPhase ( phaseToActivate );
			}
		}
		else
		{
			LogChannel( 'encounter', "Cannot find encounter with specified tag: " + encounterAreaTag );
		}
	}
	

}



class CEncounterStateRequest extends CScriptedEntityStateChangeRequest
{
	saved var enable : bool;
	default enable = true;
	
	function Execute( entity : CGameplayEntity )
	{
		var encounter : CEncounter;
		encounter = (CEncounter)entity;
	
		if ( encounter )
		{
			encounter.EnableEncounter( enable );
		}
	}
};

function ForceCleanupAllEncounters();
