/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CHudEvent
{
	var moduleName		: string;
	var eventName		: string;
}

class COnQuestTrackingStartedEvent extends CHudEvent
{
	var journalQuest : CJournalQuest;
}

class COnTrackedQuestObjectiveHighlightedEvent extends CHudEvent
{
	var journalObjective : CJournalQuestObjective;
	var journalObjectiveIndex : int;
}

class CNotifyPlayerEnteredInteriorEvent extends CHudEvent
{
	var	areaPos : Vector;
	var	areaYaw : float;
	var	texture : string;
}

class CNotifyPlayerExitedInteriorEvent extends CHudEvent
{
	
}

class CNotifyPlayerMountedBoatEvent extends CHudEvent
{
}

class CNotifyPlayerDismountedBoatEvent extends CHudEvent
{
	
}

class CNotifyInputContextChangedEvent extends CHudEvent 
{
	var	inputContextName : name;
}

class CNotifyBossIndicatorShownEvent extends CHudEvent
{
	var	enable : bool;
	var	bossTag : name;
}

class COnGasAreaEvent extends CHudEvent
{
	var	entered : bool;
}

class COnSetCoatOfArmsEvent extends CHudEvent
{
	var	set : bool;
}

class COnManageHudTimeOutEvent extends CHudEvent
{
	var action : EHudTimeOutAction;
	var timeOut : float;
}



class CR4HudEventController
{
	private var delayedEvents				: array< CHudEvent >;
	
	private function FindDelayedEvent( eventName : string ) : int
	{
		var i : int;
		for ( i = 0; i < delayedEvents.Size(); i += 1 )
		{
			if ( delayedEvents[ i ].eventName == eventName )
			{
				return i;
			}
		}
		return -1;
	}

	public function RunEvent_MinimapModule_NotifyPlayerEnteredInterior( areaPos : Vector, areaYaw : float, texture : string )
	{
		var hudEvent : CNotifyPlayerEnteredInteriorEvent;
		var minimapModule : CR4HudModuleMinimap2;
		var hud : CR4ScriptedHud;
		var foundIndex : int;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			minimapModule = ( CR4HudModuleMinimap2 )hud.GetHudModule( "Minimap2Module" );
			if ( minimapModule )
			{
				minimapModule.NotifyPlayerEnteredInterior( areaPos, areaYaw, texture );
				return;
			}
		}
		
		CheckDelayedEvent();
		
		foundIndex = FindDelayedEvent( "NotifyPlayerEnteredInterior" );
		if ( foundIndex < 0 )
		{
			hudEvent = new CNotifyPlayerEnteredInteriorEvent in this;
			hudEvent.moduleName = "Minimap2Module";
			hudEvent.eventName	= "NotifyPlayerEnteredInterior";
			hudEvent.areaPos    = areaPos;
			hudEvent.areaYaw    = areaYaw;
			hudEvent.texture    = texture;
			delayedEvents.PushBack( hudEvent );
			LogChannel( 'HudEventsQueue', "queued event [" + hudEvent.moduleName + "] [" + hudEvent.eventName + "]" );
		}
		else
		{
			hudEvent = (CNotifyPlayerEnteredInteriorEvent)delayedEvents[ foundIndex ];
			hudEvent.areaPos    = areaPos;
			hudEvent.areaYaw    = areaYaw;
			hudEvent.texture    = texture;
			LogChannel( 'HudEventsQueue', "replaced queued event [" + hudEvent.moduleName + "] [" + hudEvent.eventName + "]" );
		}
	}
	
	public function RunEvent_MinimapModule_NotifyPlayerExitedInterior()
	{
		var hudEvent : CNotifyPlayerExitedInteriorEvent;
		var minimapModule : CR4HudModuleMinimap2;
		var hud : CR4ScriptedHud;

		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			minimapModule = ( CR4HudModuleMinimap2 )hud.GetHudModule( "Minimap2Module" );
			if ( minimapModule )
			{
				minimapModule.NotifyPlayerExitedInterior();
				return;
			}
		}

		CheckDelayedEvent();

		hudEvent = new CNotifyPlayerExitedInteriorEvent in this;
		hudEvent.moduleName = "Minimap2Module";
		hudEvent.eventName	= "NotifyPlayerExitedInterior";
		delayedEvents.PushBack( hudEvent );
		
		LogChannel( 'HudEventsQueue', "queued event [" + hudEvent.moduleName + "] [" + hudEvent.eventName + "]" );
	}
	
	public function RunEvent_MinimapModule_NotifyPlayerMountedBoat()
	{
		var hudEvent : CNotifyPlayerMountedBoatEvent;
		var minimapModule : CR4HudModuleMinimap2;
		var hud : CR4ScriptedHud;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			minimapModule = ( CR4HudModuleMinimap2 )hud.GetHudModule( "Minimap2Module" );
			if ( minimapModule )
			{
				minimapModule.NotifyPlayerMountedBoat();
				return;
			}
		}
		
		CheckDelayedEvent();

		hudEvent = new CNotifyPlayerMountedBoatEvent in this;
		hudEvent.moduleName = "Minimap2Module";
		hudEvent.eventName	= "NotifyPlayerMountedBoat";
		delayedEvents.PushBack( hudEvent );

		LogChannel( 'HudEventsQueue', "queued event [" + hudEvent.moduleName + "] [" + hudEvent.eventName + "]" );
	}
	
	public function RunEvent_MinimapModule_NotifyPlayerDismountedBoat()
	{
		var hudEvent : CNotifyPlayerDismountedBoatEvent;
		var minimapModule : CR4HudModuleMinimap2;
		var hud : CR4ScriptedHud;

		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			minimapModule = ( CR4HudModuleMinimap2 )hud.GetHudModule( "Minimap2Module" );
			if ( minimapModule )
			{
				minimapModule.NotifyPlayerDismountedBoat();
				return;
			}
		}
		
		CheckDelayedEvent();

		hudEvent = new CNotifyPlayerDismountedBoatEvent in this;
		hudEvent.moduleName = "Minimap2Module";
		hudEvent.eventName	= "NotifyPlayerDismountedBoat";
		delayedEvents.PushBack( hudEvent );
		
		LogChannel( 'HudEventsQueue', "queued event [" + hudEvent.moduleName + "] [" + hudEvent.eventName + "]" );
	}
	
	public function RunEvent_QuestsModule_OnQuestTrackingStarted( journalQuest : CJournalQuest )
	{
		var hudEvent : COnQuestTrackingStartedEvent;
		var questsModule : CR4HudModuleQuests;
		var hud : CR4ScriptedHud;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			questsModule = ( CR4HudModuleQuests )hud.GetHudModule( "QuestsModule" );
			if ( questsModule )
			{
				questsModule.OnQuestTrackingStarted( journalQuest );
				return;
			}
		}
		
		CheckDelayedEvent();

		hudEvent = new COnQuestTrackingStartedEvent in this;
		hudEvent.moduleName   = "QuestsModule";
		hudEvent.eventName	  = "OnQuestTrackingStarted";
		hudEvent.journalQuest = journalQuest;
		delayedEvents.PushBack( hudEvent );
		
		LogChannel( 'HudEventsQueue', "queued event [" + hudEvent.moduleName + "] [" + hudEvent.eventName + "]" );
	}
	
	public function RunEvent_QuestsModule_OnTrackedQuestObjectiveHighlighted( journalObjective : CJournalQuestObjective, journalObjectiveIndex : int )
	{
		var hudEvent : COnTrackedQuestObjectiveHighlightedEvent;
		var questsModule : CR4HudModuleQuests;
		var hud : CR4ScriptedHud;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			questsModule = ( CR4HudModuleQuests )hud.GetHudModule( "QuestsModule" );
			if ( questsModule )
			{
				questsModule.OnTrackedQuestObjectiveHighlighted( journalObjective, journalObjectiveIndex );
				return;
			}
		}
		
		CheckDelayedEvent();

		hudEvent = new COnTrackedQuestObjectiveHighlightedEvent in this;
		hudEvent.moduleName            = "QuestsModule";
		hudEvent.eventName	           = "OnTrackedQuestObjectiveHighlighted";
		hudEvent.journalObjective      = journalObjective;
		hudEvent.journalObjectiveIndex = journalObjectiveIndex;
		delayedEvents.PushBack( hudEvent );
		
		LogChannel( 'HudEventsQueue', "queued event [" + hudEvent.moduleName + "] [" + hudEvent.eventName + "]" );
	}

	public function RunEvent_ControlsFeedbackModule_Update( inputContextName : name ) 
	{
		var hudEvent : CNotifyInputContextChangedEvent;
		var controlsFeedbackModule : CR4HudModuleControlsFeedback;
		var hud : CR4ScriptedHud;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			controlsFeedbackModule = (CR4HudModuleControlsFeedback)hud.GetHudModule( "ControlsFeedbackModule" );
			if( controlsFeedbackModule )
			{
				controlsFeedbackModule.UpdateInputContext( inputContextName );
				return;
			}
		}
		
		CheckDelayedEvent();

		hudEvent = new CNotifyInputContextChangedEvent in this;
		hudEvent.moduleName = "ControlsFeedbackModule";
		hudEvent.eventName	= "UpdateInputContext";
		hudEvent.inputContextName    = inputContextName;
		delayedEvents.PushBack( hudEvent );
		
		LogChannel( 'HudEventsQueue', "queued event [" + hudEvent.moduleName + "] [" + hudEvent.eventName + "]" );
	}

	public function RunEvent_BossFocusModule_ShowBossIndicator( enable : bool, bossTag : name )
	{
		var hudEvent : CNotifyBossIndicatorShownEvent;
		var bossFocusModule : CR4HudModuleBossFocus;
		var hud : CR4ScriptedHud;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			bossFocusModule = (CR4HudModuleBossFocus)hud.GetHudModule( "BossFocusModule" );
			if( bossFocusModule )
			{
				bossFocusModule.ShowBossIndicator( enable, bossTag );
				return;
			}
		}
		
		CheckDelayedEvent();

		hudEvent = new CNotifyBossIndicatorShownEvent in this;
		hudEvent.moduleName = "BossFocusModule";
		hudEvent.eventName	= "ShowBossIndicator";
		hudEvent.enable = enable;
		hudEvent.bossTag = bossTag;
		delayedEvents.PushBack( hudEvent );
		
		LogChannel( 'HudEventsQueue', "queued event [" + hudEvent.moduleName + "] [" + hudEvent.eventName + "]" );
	}

	public function RunEvent_OxygenBarModule_SetInGasArea( entered : bool )
	{
		var hudEvent : COnGasAreaEvent;
		var oxygenBarModule : CR4HudModuleOxygenBar;
		var hud : CR4ScriptedHud;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			oxygenBarModule = (CR4HudModuleOxygenBar)hud.GetHudModule( "OxygenBarModule" );
			if( oxygenBarModule )
			{
				oxygenBarModule.SetIsInGasArea( entered );
				return;
			}
		}

		CheckDelayedEvent();
		
		hudEvent = new COnGasAreaEvent in this;
		hudEvent.moduleName = "OxygenBarModule";
		hudEvent.eventName	= "SetInGasArea";
		hudEvent.entered = entered;
		delayedEvents.PushBack( hudEvent );
		
		LogChannel( 'HudEventsQueue', "queued event [" + hudEvent.moduleName + "] [" + hudEvent.eventName + "]" );
	}
	
	public function RunEvent_WolfHeadModule_SetCoatOfArms( value : bool )
	{
		var hudEvent : COnSetCoatOfArmsEvent;
		var wolfHeadModule : CR4HudModuleWolfHead;
		var hud : CR4ScriptedHud;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			wolfHeadModule = ( CR4HudModuleWolfHead )hud.GetHudModule( "WolfHeadModule" );
			if( wolfHeadModule )
			{
				wolfHeadModule.SetCoatOfArms( value );
				return;
			}
		}

		CheckDelayedEvent();
		
		hudEvent = new COnSetCoatOfArmsEvent in this;
		hudEvent.moduleName = "WolfHeadModule";
		hudEvent.eventName	= "SetCoatOfArms";
		hudEvent.set = value;
		delayedEvents.PushBack( hudEvent );
		
		LogChannel( 'HudEventsQueue', "queued event [" + hudEvent.moduleName + "] [" + hudEvent.eventName + "]" );
	}
	
	public function RunEvent_TimeLeftModule_ManageHudTimeOut( action : EHudTimeOutAction, timeOut : float )
	{
		var hudEvent : COnManageHudTimeOutEvent;
		var timeLeftModule : CR4HudModuleTimeLeft;
		var hud : CR4ScriptedHud;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			timeLeftModule = ( CR4HudModuleTimeLeft )hud.GetHudModule( "TimeLeftModule" );
			if( timeLeftModule )
			{
				timeLeftModule.ManageHudTimeOut( action, timeOut );
				return;
			}
		}

		CheckDelayedEvent();
		
		hudEvent = new COnManageHudTimeOutEvent in this;
		hudEvent.moduleName = "TimeLeftModule";
		hudEvent.eventName	= "ManageHudTimeOut";
		hudEvent.action = action;
		hudEvent.timeOut = timeOut;
		delayedEvents.PushBack( hudEvent );
		
		LogChannel( 'HudEventsQueue', "queued event [" + hudEvent.moduleName + "] [" + hudEvent.eventName + "]" );
	}
	
	

	private function CheckDelayedEvent()
	{
		if ( delayedEvents.Size() > 200 )
		{
			delete delayedEvents[ 0 ];
			delayedEvents.Erase( 0 );
		}
	}
	
	public function RunDelayedEvents()
	{
		var i : int;
		var hud : CR4ScriptedHud;
		var module : CHudModule;

		if ( delayedEvents.Size() == 0 )
		{
			return;
		}
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( !hud )
		{
			return;
		}

		for ( i = 0; i < delayedEvents.Size(); )
		{
			module = hud.GetHudModule( delayedEvents[ i ].moduleName );
			if ( module )
			{
				RunDelayedEvent( module, delayedEvents[ i ] );
				LogChannel( 'HudEventsQueue', "executed event [" + delayedEvents[ i ].moduleName + "] [" + delayedEvents[ i ].eventName + "]" );
				delete delayedEvents[ i ];
				delayedEvents.Erase( i );
			}
			else
			{
				i += 1;
			}
		}
	}

	private function RunDelayedEvent( module : CHudModule, delayedEvent : CHudEvent )
	{
		var onQuestTrackingStartedEvent : COnQuestTrackingStartedEvent;
		var onTrackedQuestObjectiveHighlightedEvent : COnTrackedQuestObjectiveHighlightedEvent;
		var onInputContextChangedEvent : CNotifyInputContextChangedEvent;
		var notifyPlayerEnteredInteriorEvent : CNotifyPlayerEnteredInteriorEvent;
		var notifyPlayerExitedInteriorEvent : CNotifyPlayerExitedInteriorEvent;
		var notifyPlayerMountedBoatEvent : CNotifyPlayerMountedBoatEvent;
		var notifyPlayerDismountedBoatEvent : CNotifyPlayerDismountedBoatEvent;
		var onBossIndicatorShownEvent : CNotifyBossIndicatorShownEvent;
		var onGasAreaEvent : COnGasAreaEvent;
		var onSetCoatOfArmsEvent : COnSetCoatOfArmsEvent;
		var onManageHudTimeOutEvent : COnManageHudTimeOutEvent;

		var minimapModule : CR4HudModuleMinimap2;
		var questsModule : CR4HudModuleQuests;
		var controlsFeedbackModule : CR4HudModuleControlsFeedback;
		var bossFocusModule : CR4HudModuleBossFocus;
		var oxygenBarModule : CR4HudModuleOxygenBar;
		var wolfHeadModule : CR4HudModuleWolfHead;
		var timeLeftModule : CR4HudModuleTimeLeft;
	
		switch( delayedEvent.moduleName )
		{
			case "Minimap2Module":
				minimapModule = ( CR4HudModuleMinimap2 )module;
				if ( minimapModule )
				{
					switch ( delayedEvent.eventName )
					{
						case "NotifyPlayerEnteredInterior":
							notifyPlayerEnteredInteriorEvent = ( CNotifyPlayerEnteredInteriorEvent )delayedEvent;
							minimapModule.NotifyPlayerEnteredInterior( notifyPlayerEnteredInteriorEvent.areaPos, notifyPlayerEnteredInteriorEvent.areaYaw, notifyPlayerEnteredInteriorEvent.texture );
							break;
						case "NotifyPlayerExitedInterior":
							notifyPlayerExitedInteriorEvent = ( CNotifyPlayerExitedInteriorEvent )delayedEvent;
							minimapModule.NotifyPlayerExitedInterior();
							break;
						case "NotifyPlayerMountedBoat":
							notifyPlayerMountedBoatEvent = ( CNotifyPlayerMountedBoatEvent )delayedEvent;
							minimapModule.NotifyPlayerMountedBoat();
							break;
						case "NotifyPlayerDismountedBoat":
							notifyPlayerDismountedBoatEvent = ( CNotifyPlayerDismountedBoatEvent )delayedEvent;
							minimapModule.NotifyPlayerDismountedBoat();
							break;
					}
				}
				break;
			
			case "QuestsModule":
				questsModule = ( CR4HudModuleQuests )module;
				if ( questsModule )
				{
					switch ( delayedEvent.eventName )
					{
						case "OnQuestTrackingStarted":
							onQuestTrackingStartedEvent = ( COnQuestTrackingStartedEvent )delayedEvent;
							questsModule.OnQuestTrackingStarted( onQuestTrackingStartedEvent.journalQuest );
							break;
						case "OnTrackedQuestObjectiveHighlighted":
							onTrackedQuestObjectiveHighlightedEvent = ( COnTrackedQuestObjectiveHighlightedEvent )delayedEvent;
							questsModule.OnTrackedQuestObjectiveHighlighted( onTrackedQuestObjectiveHighlightedEvent.journalObjective, onTrackedQuestObjectiveHighlightedEvent.journalObjectiveIndex );
							break;
					}
				}
				break;	
			
			case "ControlsFeedbackModule":
				controlsFeedbackModule = ( CR4HudModuleControlsFeedback )module;
				if ( controlsFeedbackModule )
				{
					onInputContextChangedEvent = (CNotifyInputContextChangedEvent)delayedEvent;
					controlsFeedbackModule.UpdateInputContext(onInputContextChangedEvent.inputContextName);
				}
				break;
			
			case "BossFocusModule":
				bossFocusModule = ( CR4HudModuleBossFocus )module;
				if ( bossFocusModule )
				{
					onBossIndicatorShownEvent = (CNotifyBossIndicatorShownEvent)delayedEvent;
					bossFocusModule.ShowBossIndicator( onBossIndicatorShownEvent.enable, onBossIndicatorShownEvent.bossTag );
				}
				break;

			case "OxygenBarModule":
				oxygenBarModule = ( CR4HudModuleOxygenBar )module;
				if ( oxygenBarModule )
				{
					onGasAreaEvent = (COnGasAreaEvent)delayedEvent;
					oxygenBarModule.SetIsInGasArea( onGasAreaEvent.entered );
				}
				break;
				
			case "WolfHeadModule":
				wolfHeadModule = ( CR4HudModuleWolfHead )module;
				if ( module )
				{
					onSetCoatOfArmsEvent = ( COnSetCoatOfArmsEvent )delayedEvent;
					wolfHeadModule.SetCoatOfArms( onSetCoatOfArmsEvent.set );
				}
				break;

			case "TimeLeftModule":
				timeLeftModule = ( CR4HudModuleTimeLeft )module;
				if ( module )
				{
					onManageHudTimeOutEvent = ( COnManageHudTimeOutEvent )delayedEvent;
					timeLeftModule.ManageHudTimeOut( onManageHudTimeOutEvent.action, onManageHudTimeOutEvent.timeOut );
				}
				break;

			default:
				break;
		}
	}
	
}