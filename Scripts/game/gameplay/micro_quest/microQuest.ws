/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EOcurrenceTime
{
	OT_AllDay,
	OT_DayOnly,
	OT_NightOnly,
}

struct EncounterEntryDetails
{
	editable var encounterTag		: name;
	editable var canBeRepeated		: bool;
	
	editable var occurenceTime		: EOcurrenceTime;
	editable var questFileEntry		: array< CEntityTemplate >;
	
	default canBeRepeated = true;
	
	hint encounterTag = "Tag of the specified entry";
	hint canBeRepeated = "Can the encounter / micro quest be repeated";
	hint repeatAfter = "Time set in hours. If no value set, quest will be available after 24 hours";
	hint occurenceTime = "When the encounter should occur";
	hint creatureEntries = "Set the creatures if it's simple encounter";
	hint questFileEntry = "Add quest file directory of a micro quest";
}

statemachine class W3MicroQuestActivator extends CGameplayEntity
{
	editable 	var microQuestEntries 	: array< EncounterEntryDetails >;
				var selectedEntriesList : array< EncounterEntryDetails >;
	
	var chosenMicroQuestTag	: name;
	var isPlayerInArea		: bool;
	
	default autoState = 'Inactive';
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		if ( !spawnData.restored )
		{
			GotoStateAuto();
		}
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		isPlayerInArea = false;
	}
	
	function GetCurrentTime() : int
	{
		var currentTime : GameTime;
		var currentHour : int;
		
		currentTime = theGame.GetGameTime();
		currentHour = GameTimeHours( currentTime );
		
		return currentHour;
	}	
	
	function CanMicroQuestBeStarted( mQEntry : EncounterEntryDetails ) : bool
	{
		var cTime : int = GetCurrentTime();
		var oTime : EOcurrenceTime;
		
		oTime = mQEntry.occurenceTime;
		
		if( oTime == OT_AllDay )
		{
			return true;
		}
		else if( oTime == OT_DayOnly )
		{
			if( cTime > 7 && cTime < 20 )
			{
				return true;
			}
		}
		else if( oTime == OT_NightOnly )
		{
			if( cTime > 20 && cTime < 24 || cTime > 0 && cTime < 7 )
			{
				return true;
			}
		}
		return false;
	}
	
	function QuestAvailableAgain()
	{
		var i : int;
		
		for ( i = 0; i < selectedEntriesList.Size(); i += 1 )
		{
			if( selectedEntriesList[i].canBeRepeated )
			{
				FactsRemove( NameToString( selectedEntriesList[i].encounterTag ) );
				break;
			}
		}
	}
	
	
	
	timer function BackToInactive( deltaTime : float , id : int)
	{
		
	}
}

state Processing in W3MicroQuestActivator
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.isPlayerInArea = false;
		ChooseMicroQuest();	
	}

	event OnLeaveState( nextStateName : name )
	{
		super.OnLeaveState( nextStateName );
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		parent.OnAreaExit( area, activator );
	}
	
	function ChooseMicroQuest()
	{
		var i, size			: int;
		var currentEntry	: EncounterEntryDetails;
		var selectedEntry	: EncounterEntryDetails;
		var activator		: W3MicroQuestActivator;
				
		size = parent.microQuestEntries.Size();
		
		for( i = 0; i < size; i += 1 )
		{
			currentEntry = parent.microQuestEntries[i];
			
			if( ( FactsDoesExist( NameToString( currentEntry.encounterTag ) ) ) == false )
			{
				if( parent.CanMicroQuestBeStarted( currentEntry ) )
				{
					selectedEntry = currentEntry;
					parent.selectedEntriesList.PushBack( selectedEntry );
					break;
				}
			}
		}
			
		FactsAdd( NameToString( selectedEntry.encounterTag ) );
		
	}
}

state Activated in W3MicroQuestActivator
{
	event OnEnterState( prevStateName : name )
	{
		
		ClearFacts();
		parent.AddTimer( 'BackToInactive', 25.f, , , , true );
	}

	event OnLeaveState( nextStateName : name )
	{
		super.OnLeaveState( nextStateName );
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
	}

	entry function ClearFacts()
	{
		if( parent.selectedEntriesList.Size() >= 3 )
		{
			parent.QuestAvailableAgain();
		}
	}
	
	timer function InactiveInMicroQuestActivator( deltaTime : float , id : int)
	{
		
	}
}

state Inactive in W3MicroQuestActivator
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
	}

	event OnLeaveState( nextStateName : name )
	{
		super.OnLeaveState( nextStateName );
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity = activator.GetEntity();
		
		if( (CPlayer) (activator.GetEntity()) )
		{
			parent.isPlayerInArea = true;
			
		}		
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
	}
}