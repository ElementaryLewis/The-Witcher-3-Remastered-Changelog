/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EPlayerMode
{
	PM_Normal,
	PM_Safe,
	PM_Combat,
}

enum EForceCombatModeReason
{
	
	FCMR_Default    	= 1,
	FCMR_Trigger   		= 2,
	FCMR_QuestFunction  = 4,
}

class W3PlayerMode
{
	var		player				: CPlayer;

	var		currentMode			: EPlayerMode;
	default currentMode			= PM_Normal;
	
	saved var		safeMode	: bool;
	default	safeMode			= false;
	saved var 	combatMode		: bool;
	default	combatMode			= false;
			
	var combatDataComponent		: CCombatDataComponent;
	var combatModeTimer			: float;
	const var combatModeDelay	: float;
	default combatModeDelay		= 1.0f;
	
	var forceCombatMode			: int;
	default forceCombatMode		= 0;
	
	var combatModeBlockedActions	: array< EInputActionBlock >;
	var safeModeBlockedActions		: array< EInputActionBlock >;
	
	public function Initialize( playerEntity : CPlayer )
	{
		
		
		
	
		player = playerEntity;
		currentMode = PM_Normal;
		
		if( (CR4Player)playerEntity )
			((CR4Player)playerEntity).SetIsInCombat( false );	
	}
	
	public function EnableMode( mode : EPlayerMode, enable : bool )
	{
		
		var hud : CR4ScriptedHud;
		var minimapModule : CR4HudModuleMinimap2;
		var objectiveModule : CR4HudModuleQuests;
		
	
		if ( mode == PM_Combat )
		{
			if(enable)
			{
				
				
				if( thePlayer.GetTarget().IsHuman() )
				{
					thePlayer.PlayBattleCry( 'BattleCryHumansStart', 0.10f );
				}
				else
				{
					thePlayer.PlayBattleCry( 'BattleCryMonstersStart', 0.10f );
				}
				
				
				hud = (CR4ScriptedHud)theGame.GetHud();
				if(hud)
				{
					minimapModule = (CR4HudModuleMinimap2)hud.GetHudModule("Minimap2Module");
					objectiveModule = (CR4HudModuleQuests)hud.GetHudModule("QuestsModule");
					
					if(minimapModule)
					{
						minimapModule.SetIsInCombat(true);
					}
					
					if(objectiveModule)
					{
						objectiveModule.SetIsInCombat(true);
					}
				}				
				
			}
			else
			{
				
				hud = (CR4ScriptedHud)theGame.GetHud();
				if(hud)
				{
					minimapModule = (CR4HudModuleMinimap2)hud.GetHudModule("Minimap2Module");
					objectiveModule = (CR4HudModuleQuests)hud.GetHudModule("QuestsModule");
					
					if(minimapModule)
					{
						minimapModule.SetIsInCombat(false);
					}
					
					if(objectiveModule)
					{
						objectiveModule.SetIsInCombat(false);
					}
				}
				
				
			}
			
			combatMode = enable;
			UpdateCurrentMode();
		}
		else if ( mode == PM_Safe )
		{
			safeMode = enable;
			UpdateCurrentMode();
		}
		
	}
	
	public function GetCurrentMode() : EPlayerMode
	{
		return currentMode;
	}
	
	function CalcCurrentMode() : EPlayerMode
	{
		if ( combatMode )
		{
			return PM_Combat;
		}
		if ( safeMode )
		{
			return PM_Safe;
		}
		return PM_Normal;
	}
	
	function UpdateCurrentMode()
	{
		var prevMode : EPlayerMode;
		
		prevMode = currentMode;
		currentMode = CalcCurrentMode();
		if ( prevMode != currentMode )
		{
			OnModeChanged( prevMode );
		}		
	}
		
	event OnModeChanged( prevMode : EPlayerMode )
	{
		OnModeEnabled( prevMode, false );
		OnModeEnabled( currentMode, true );
		thePlayer.SetIsInCombat( combatMode );
	}
	
	function OnModeEnabled( mode : EPlayerMode, enabled : bool )
	{
		if ( mode == PM_Combat )
		{
			BlockActions( combatModeBlockedActions, enabled );
			
			
			
		}
		else if ( mode == PM_Safe )
		{
			BlockActions( safeModeBlockedActions, enabled );
			if ( enabled )
			{
				player.DisableCombatState();
			}
		}
	}
	
	function BlockActions( actions : array< EInputActionBlock >, block : bool )
	{
		var i, size	: int;
		size = actions.Size();
		for ( i = 0; i < size; i+=1 )
		{
			if( block )
			{
				player.BlockAction( actions[i], 'W3PlayerMode' );
			}
			else
			{
				player.UnblockAction( actions[i], 'W3PlayerMode' );
			}
		}
	}
	
	public function UpdateCombatMode( optional forceUpdate : bool )
	{	
		var unableToPathFind 	: bool;
	
		
		if ( thePlayer.ShouldEnableCombat( unableToPathFind, forceCombatMode ) ) 
		{
			combatModeTimer = theGame.GetEngineTimeAsSeconds();
			if ( !combatMode )
			{
				EnableMode( PM_Combat, true );
			}
			
			
			thePlayer.GoToCombatIfNeeded();
		}
		else
		{
			if ( combatMode && this.currentMode == PM_Combat )
				thePlayer.FindMoveTarget();
		
			if ( combatMode && ( ( theGame.GetEngineTimeAsSeconds() - combatModeTimer ) > combatModeDelay || ( unableToPathFind && thePlayer.IsThreatened() ) || forceUpdate ) )
			{
				EnableMode( PM_Combat, false );	
				
				if ( unableToPathFind )
				{
					unableToPathFind = false;
					thePlayer.GoToExplorationIfNeeded();
				}
			}
		}
	}
	
	public function ForceCombatMode( reason : EForceCombatModeReason )
	{
		forceCombatMode = forceCombatMode | reason;
		thePlayer.FindMoveTarget();
		UpdateCombatMode( true );
	}
	
	public function ReleaseForceCombatMode( reason : EForceCombatModeReason )
	{
		forceCombatMode = forceCombatMode & (~reason);
		thePlayer.FindMoveTarget();
		UpdateCombatMode( true );
		
		if ( !forceCombatMode )
		{
			if ( !thePlayer.IsCombatMusicEnabled() )
				thePlayer.OnCombatFinished();
		}
	}
	
	public function GetForceCombatMode() : bool
	{
		if ( forceCombatMode > 0 )
			return true;
		else
			return false;
	}	
	
	
	public function ShouldForceAlertNearStance() : bool
	{
		return forceCombatMode >= 4;
	}
}