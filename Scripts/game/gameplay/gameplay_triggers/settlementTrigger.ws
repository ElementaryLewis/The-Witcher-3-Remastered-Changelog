/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CR4JournalPlaceEntity extends CGameplayEntity
{
	import function GetJournalPlaceEntry() : CJournalBase;
}

class W3SettlementTrigger extends CR4JournalPlaceEntity
{
	var bDisplaySettlementInfo				: bool;							default bDisplaySettlementInfo = true;
	
	editable var settlementName				: name;							default settlementName = 'Narnia';
	editable var hubNameOverride			: name;							default hubNameOverride = '';
	editable var lockReenterDisplayTime		: float;						default lockReenterDisplayTime = 10.0f;
	editable var blockHorseTopSpeed			: bool;							default blockHorseTopSpeed = false;
	
	hint settlementName			= "Localisation Key, could be empty";
	hint lockReenterDisplayTime	= "Time for block messeage on reenter";
	hint hubNameOverride		= "If filled will override default hub name";

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var veh : CNewNPC;
		
		if( activator.GetEntity() != thePlayer )
		{
			return false;
		}
		
		thePlayer.EnterSettlement( true );
		
		if(IsNameValid(settlementName))
		{
			theGame.UpdateRichPresence(settlementName);
		}
		else if(IsNameValid(hubNameOverride))
		{
			theGame.UpdateRichPresence(hubNameOverride);
		}
	
		if ( bDisplaySettlementInfo )
		{
			DisplayAreaInfo();
		}
		ActivateJournalEntry();
		if( blockHorseTopSpeed )
		{
			veh = (CNewNPC)thePlayer.GetUsedVehicle();
			if(veh && veh.IsHorse())
			{
				thePlayer.GetUsedHorseComponent().OnSettlementEnter();
			}
			thePlayer.SetSettlementBlockCanter( 1 );
		}
		
		if(blockHorseTopSpeed && ShouldProcessTutorial('TutorialSettlementAreas'))
		{
			FactsAdd('tut_in_settlement');
		}
	}

	function DisplayAreaInfo()
	{
		var hud : CR4ScriptedHud;
		var timeLapseModule : CR4HudModuleTimeLapse;
		var manager: CCommonMapManager;
	    var worldPath : string;
	    var currentArea : EAreaName;
	    var hubName : string;
	    
		hud = (CR4ScriptedHud)theGame.GetHud();
		if( hud )
		{
			timeLapseModule = (CR4HudModuleTimeLapse)hud.GetHudModule("TimeLapseModule");
			if( !timeLapseModule )
			{
				SetLoadTimer();
				return;
			}
			
			timeLapseModule.SetShowTime(3);			
			if( hubNameOverride == '' )
			{
				manager = theGame.GetCommonMapManager();
				worldPath = theGame.GetWorld().GetDepotPath();
				currentArea = manager.GetAreaFromWorldPath( worldPath );
				hubName = manager.GetLocalisationNameFromAreaType( currentArea );
				timeLapseModule.SetTimeLapseAdditionalMessage(settlementName);
				timeLapseModule.SetTimeLapseMessage(hubName);	
			}
			else
			{
				timeLapseModule.SetTimeLapseAdditionalMessage(settlementName);
				timeLapseModule.SetTimeLapseMessage(hubNameOverride);
			}
		}
		else
		{
			SetLoadTimer();
		}
	}
	
	function ActivateJournalEntry()
	{
		var manager : CWitcherJournalManager;
		var journalBase : CJournalBase;

		journalBase = GetJournalPlaceEntry();
		if ( !journalBase )
		{
			return;
		}
		manager = theGame.GetJournalManager();
		if ( !manager )
		{
			return;
		}
		
		manager.ActivateEntry( journalBase, JS_Active, false );
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var veh : CNewNPC;
		
		if( activator.GetEntity() != thePlayer )
		{
			return false;
		}
			
		thePlayer.EnterSettlement( false );
		
		if(IsNameValid(settlementName))
		{
			theGame.ClearRichPresence(settlementName);
		}
		else if(IsNameValid(hubNameOverride))
		{
			theGame.ClearRichPresence(hubNameOverride);
		}
		
		SetReenterTimer();
		
		if( blockHorseTopSpeed )
		{
			veh = (CNewNPC)thePlayer.GetUsedVehicle();
			if(veh && veh.IsHorse())
			{
				thePlayer.GetUsedHorseComponent().OnSettlementExit();
			}
			thePlayer.SetSettlementBlockCanter( -1 );
		}
		
		if(blockHorseTopSpeed && ShouldProcessTutorial('TutorialSettlementAreas'))
		{
			FactsRemove('tut_in_settlement');
		}
	}
	
	function SetReenterTimer()
	{
		bDisplaySettlementInfo = false;
		AddTimer('ReenterTimer', lockReenterDisplayTime, false);
	}
	
	private timer function ReenterTimer( delta : float , id : int)
	{
		bDisplaySettlementInfo = true;
	}	

	function SetLoadTimer()
	{
		AddTimer('LoadTimer', 0.5, false);
	}
	
	private timer function LoadTimer( delta : float , id : int)
	{
		DisplayAreaInfo();
	}	
}