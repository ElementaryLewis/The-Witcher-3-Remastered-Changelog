/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3MonsterHuntInvestigationArea extends CGameplayEntity
{

	editable saved var enabled : bool;

	editable var investigationMusicStartEvent : string;
	editable var investigationMusicStopEvent  : string;
	editable var requiredTrackedQuest  		  : name;
 
	var active : bool;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if( enabled )
		{
			if( CheckAreaValidity() )
			{
				ProcessAreaActivation();
			}
		}
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		
		if( enabled )
		{
			
			if ( activator.GetEntity() == thePlayer )
			{
				UpdateCurrentInvestigationArea();
				ProcessAreaActivation();
			}
		}
	}	
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{	
		
		if( enabled )
		{
			if ( activator.GetEntity() == thePlayer )
			{		
				RemoveTimer( 'QuestTrackerCheckTimer' );
				SwitchInvestigationMusic( false );
			}
		}
	}
	
	
	private function CheckAreaValidity() : bool
	{
		var comp : CTriggerAreaComponent;
		
		comp = (CTriggerAreaComponent) this.GetComponentByClassName( 'CTriggerAreaComponent' );
		
		if(comp)
		{
			if( comp.TestEntityOverlap( thePlayer ) )
				return true;
			else
				return false;
		}
		else
		{
			return false;
		}
		
	}
	
	
	private function SwitchInvestigationMusic( turnOn : bool )
	{
		if( turnOn )
		{
			if( !active )
			{
				theSound.SoundEvent( investigationMusicStartEvent );
				active =  true;
			}
		}
		else
		{
			if( active )
			{
				theSound.SoundEvent( investigationMusicStopEvent );
				theSound.SoundEventClearSaved();
				active =  false;
			}				
		}
	}
	
	
	public function SetInvestigationAreaEnabled( isEnabled : bool, optional silentTurnOff : bool )
	{
		if( isEnabled )
		{
			enabled = isEnabled;
			
			if( CheckAreaValidity() )
			{
				UpdateCurrentInvestigationArea();
				ProcessAreaActivation();
			}
		}
		else
		{
			enabled = isEnabled;
			
			if( CheckAreaValidity() )
			{
				RemoveTimer( 'QuestTrackerCheckTimer' );
				
				if( !silentTurnOff )
				{
					SwitchInvestigationMusic( false );
				}
				else
				{
					active =  false;
				}
			}
		}
	}
	
	public function SetInvestigationAreaActive ( isActive : bool )
	{
		active = isActive;
	}
	
	private function ProcessAreaActivation()
	{
		if( GetIsRequiredQuestTracked() )
		{
			SwitchInvestigationMusic( true );
		}
		else
		{
			SwitchInvestigationMusic( false );		
		}
		
		if( requiredTrackedQuest != '' ) 
		{
			AddTimer( 'QuestTrackerCheckTimer', 0.5, true );
		}
		
		thePlayer.SetCurrentMonsterHuntInvestigationArea( this );	
	}
	
	private function GetIsRequiredQuestTracked() : bool
	{
		var journalManager : CWitcherJournalManager;
		var trackedQuest   : CJournalQuest;
		var requiredQuest  : CJournalQuest;
		
		if( requiredTrackedQuest == '' )
			return true;
		
		journalManager = (CWitcherJournalManager) theGame.GetJournalManager();
		trackedQuest = journalManager.GetTrackedQuest();
		
		requiredQuest = (CJournalQuest) journalManager.GetEntryByTag( requiredTrackedQuest );
		
		if( trackedQuest == requiredQuest )
			return true;
		else
			return false;
	}
	
	timer function QuestTrackerCheckTimer( dt : float , id : int)
	{
		if( GetIsRequiredQuestTracked() )
		{
			SwitchInvestigationMusic( true );
		}
		else
		{
			SwitchInvestigationMusic ( false );
		}
	}
	
	private function UpdateCurrentInvestigationArea()
	{
		var prevArea : W3MonsterHuntInvestigationArea;
		
		prevArea  = thePlayer.currentMonsterHuntInvestigationArea;
		
		
		if( prevArea && prevArea != this )
		{
			prevArea.RemoveTimer( 'QuestTrackerCheckTimer' );
			prevArea.SetInvestigationAreaActive( false );
		}	
	}
}
