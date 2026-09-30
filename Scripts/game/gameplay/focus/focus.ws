/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EFocusModeChooseEntityStrategy
{
	FMCES_ChooseNearest,
	FMCES_ChooseMostIntense,
}

import class CFocusActionComponent extends CComponent
{
	import var actionName : name;
};

class W3FocusModeEffectIntensity
{
	var chooseEntityStrategy	: EFocusModeChooseEntityStrategy;
	var bestEntity				: CEntity;
	var bestDistance			: float;
	var lastDistance			: float;
	var bestIntensity			: float;
	var	lastIntensity			: float;
		
	public function Init( strategy : EFocusModeChooseEntityStrategy )
	{
		chooseEntityStrategy = strategy;
		bestEntity = NULL;
		bestDistance = 0.0f;
		lastDistance = 0.0f;
		bestIntensity = 0.0f;
		lastIntensity = 0.0f;
	}

	public function Update( entity : CEntity, distance : float, intensity : float )
	{
		if ( IsBestEntity( distance, intensity ) )
		{
			bestEntity = entity;
			bestDistance = distance;
			bestIntensity = intensity;
		}		
	}

	public function ForceUpdate( entity : CEntity, distance : float, intensity : float )
	{
		bestEntity = entity;
		bestDistance = distance;
		bestIntensity = intensity;
	}

	public function ValueChanged() : bool
	{
		return ( bestIntensity != lastIntensity );
	}

	public function GetValue( optional reset : bool ) : float
	{
		return lastIntensity;
	}
	
	public function GetBestEntity() : CEntity
	{
		return bestEntity;
	}
	
	public function Reset()
	{
		lastIntensity = bestIntensity;
		bestIntensity = 0.0f;
		bestDistance = 0.0f;
		bestEntity = NULL;	
	}
	
	function IsBestEntity( distance : float, intensity : float ) : bool
	{
		if ( !bestEntity )
		{
			return true;
		}
		if ( chooseEntityStrategy == FMCES_ChooseMostIntense )
		{
			return ( intensity > bestIntensity );
		}
		else 
		{
			return ( distance < bestDistance );
		}
	}
}

import class CFocusSoundParam extends CGameplayEntityParam
{
	import final function GetEventStart() : name;
	import final function GetEventStop() : name;
	import final function GetHearingAngle() : float;
	import final function GetVisualEffectBoneName() : name;
}

import class CFocusModeController extends IGameSystem
{
	import final function SetActive( active : bool );
	import final function IsActive() : bool;
	import final function GetIntensity() : float;
	import final function EnableVisuals( enable : bool, optional desaturation : float , optional highlightBoos : float );
	import final function SetFadeParameters( NearFadeDistance : float, FadeDistanceRange : float, dimmingTIme : Float, dimmingSpeed : Float );
	import final function EnableExtendedVisuals( enable : bool, fadeTime : float );
	import final function SetDimming( enable : bool );
	import final function SetSoundClueEventNames( entity : CGameplayEntity, eventStart : name, eventStop : name, effectType : int ) : bool;
	import final function ActivateScentClue( entity : CEntity, effectName : name, duration : float );
	import final function DeactivateScentClue( entity : CEntity );
	
	saved var detectedCluesTags 		: array< name >;

	var medallionIntensity				: W3FocusModeEffectIntensity;	
	var dimmingClue						: W3MonsterClue;

	var blockVibrations					: bool;

	var focusAreaIntensity				: float;
	default focusAreaIntensity			= 0.0f;

	const var effectFadeTime			: float;
	default effectFadeTime				= 1.0f;

	
	
	
	const var controllerVibrationFactor	: float;
	default controllerVibrationFactor	= 0.2f;
	const var controllerVibrationDuration : float;
	default controllerVibrationDuration = 0.5f;
	
	
	var activationSoundTimer			: float;
	const var activationSoundInterval	: float;
	default activationSoundTimer		= 0.0f;
	default activationSoundInterval		= 0.4f;

	
	var fastFocusTimer					: float;
	var activateAfterFastFocus			: bool;
	const var fastFocusDuration			: float;
	default fastFocusTimer 				= 0.0f;
	default activateAfterFastFocus		= false;
	default fastFocusDuration			= 0.0f;
	
	
	private var isUnderwaterFocus		: bool;
	default isUnderwaterFocus			= false;
	private var isInCombat				: bool;
	default isInCombat					= false;
	private var isNight					: bool;
	default isNight						= false;
	
	
	private var lastDarkPlaceCheck : float;	
	private const var DARK_PLACE_CHECK_INTERVAL : float;
	default DARK_PLACE_CHECK_INTERVAL = 2.f;

	public function Activate()
	{
		lastDarkPlaceCheck = DARK_PLACE_CHECK_INTERVAL;
	
		if ( !ActivateFastFocus( true ) )
		{
			ActivateInternal();
		}
	}
	
	public function GetBlockVibrations() : bool
	{
		return blockVibrations;
	}
	
	public function SetBlockVibrations( newState : bool )
	{
		blockVibrations = newState;
	}	
	
	function ActivateFastFocus( activate : bool ) : bool
	{
		activateAfterFastFocus = activate;
		if ( activate && fastFocusDuration > 0.0f )
		{
			
			
			fastFocusTimer = fastFocusDuration;
			return true; 
		}
		return false; 
	}
	
	private function ActivateInternal()
	{
		
		var hud : CR4ScriptedHud;
		var minimapModule : CR4HudModuleMinimap2;
		var objectiveModule : CR4HudModuleQuests;
		
	
		if ( IsActive() || !CanUseFocusMode() )
		{
			return;
		}

		if(thePlayer.IsCiri())
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			if(hud)
			{
				minimapModule = (CR4HudModuleMinimap2)hud.GetHudModule("Minimap2Module");
				objectiveModule = (CR4HudModuleQuests)hud.GetHudModule("QuestsModule");
				
				if(minimapModule)
				{
					minimapModule.SetIsInFocus(true);
				}
				
				if(objectiveModule)
				{
					objectiveModule.SetIsInFocus(true);
				}
			}
			return;
		}
		
		SetActive( true );
		EnableVisuals( true );
		EnableExtendedVisuals( true, effectFadeTime );
		
		thePlayer.BlockAction( EIAB_Jump, 'focus' );
		theTelemetry.LogWithName( TE_HERO_FOCUS_ON );
	
		
		if ( theGame.GetEngineTimeAsSeconds() - activationSoundTimer > activationSoundInterval )
		{
			activationSoundTimer = theGame.GetEngineTimeAsSeconds();
			theSound.SoundEvent( 'expl_focus_start' );			
		}
		
		
		if( GetWitcherPlayer().IsInDarkPlace() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation12 ) && !thePlayer.HasBuff( EET_Mutation12Cat ) )
		{
			thePlayer.AddEffectDefault( EET_Mutation12Cat, thePlayer, "Mutation12 Senses", false );
		}
		
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if(hud)
		{
			minimapModule = (CR4HudModuleMinimap2)hud.GetHudModule("Minimap2Module");
			objectiveModule = (CR4HudModuleQuests)hud.GetHudModule("QuestsModule");
			
			if(minimapModule)
			{
				minimapModule.SetIsInFocus(true);
			}
			
			if(objectiveModule)
			{
				objectiveModule.SetIsInFocus(true);
			}
		}
		
	}

	public function Deactivate()
	{
		var hud : CR4ScriptedHud;
		var module : CR4HudModuleInteractions;
		
		
		var minimapModule : CR4HudModuleMinimap2;
		var objectiveModule : CR4HudModuleQuests;
		

		ActivateFastFocus( false );

		if(thePlayer.IsCiri())
		{
			hud = ( CR4ScriptedHud )theGame.GetHud();
			if(hud)
			{
				minimapModule = (CR4HudModuleMinimap2)hud.GetHudModule("Minimap2Module");
				objectiveModule = (CR4HudModuleQuests)hud.GetHudModule("QuestsModule");
				
				if(minimapModule)
				{
					minimapModule.SetIsInFocus(false);
				}
				
				if(objectiveModule)
				{
					objectiveModule.SetIsInFocus(false);
				}
			}
		}

		if ( !IsActive() )
		{
			return;
		}
		SetActive( false );
		EnableVisuals( false );
		EnableExtendedVisuals( false, effectFadeTime );
		
		if( isUnderwaterFocus )
		{
			isUnderwaterFocus = false;
			if( isInCombat )
			{
				theSound.LeaveGameState( ESGS_FocusUnderwaterCombat );
			}
			else
			{
				theSound.LeaveGameState( ESGS_FocusUnderwater );
			}
		}
		else
		{
			if( isNight )
			{
				theSound.LeaveGameState( ESGS_FocusNight );
			}
			else
			{
				theSound.LeaveGameState( ESGS_Focus );
			}
		}
		
		isInCombat = false;
		isUnderwaterFocus = false;
		isNight = false;

		thePlayer.UnblockAction( EIAB_Jump, 'focus' );
		theTelemetry.LogWithName( TE_HERO_FOCUS_OFF );
		theSound.SoundEvent( 'expl_focus_stop' ); 
		
		
		if ( theGame.GetEngineTimeAsSeconds() - activationSoundTimer > activationSoundInterval )
		{
			activationSoundTimer = theGame.GetEngineTimeAsSeconds();
			theSound.SoundEvent( 'expl_focus_stop_sfx' ); 
		}		
		
		hud = ( CR4ScriptedHud )theGame.GetHud();
		if ( hud )
		{
			module = (CR4HudModuleInteractions)hud.GetHudModule( "InteractionsModule" );
			if ( module )
			{
				module.RemoveAllFocusInteractionIcons();
			}
		}
		
		
		thePlayer.RemoveBuff( EET_Mutation12Cat );
		
		
		if(hud)
		{
			minimapModule = (CR4HudModuleMinimap2)hud.GetHudModule("Minimap2Module");
			objectiveModule = (CR4HudModuleQuests)hud.GetHudModule("QuestsModule");
			
			if(minimapModule)
			{
				minimapModule.SetIsInFocus(false);
			}
			
			if(objectiveModule)
			{
				objectiveModule.SetIsInFocus(false);
			}
		}
		
	}

	function CanUseFocusMode() : bool
	{
		var stateName : name;
		
		if ( theGame && theGame.IsDialogOrCutscenePlaying() )
		{
			return false;
		}
		
		if ( thePlayer )
		{
			stateName = thePlayer.GetCurrentStateName();
			return ( stateName == 'Exploration' || stateName == 'Swimming' || stateName == 'HorseRiding' || stateName == 'Sailing' || stateName == 'SailingPassive' ) && thePlayer.IsActionAllowed(EIAB_ExplorationFocus);		
		}
		
		return false;
	}

	function Init()
	{
		medallionIntensity = new W3FocusModeEffectIntensity in this;
		medallionIntensity.Init( FMCES_ChooseNearest );
		dimmingClue = NULL;
		focusAreaIntensity = 0.0f;
		activationSoundTimer = 0.f;
	}

	function DeInit()
	{
		var i, size : int;
		
		delete medallionIntensity;
		medallionIntensity = NULL;
	}

	event OnGameStarted()
	{
		Init();
		SetFadeParameters( 10.0, 30.0f, 16.0f, 40.0f );
	}
	
	event OnGameEnded()
	{
		detectedCluesTags.Clear();
		DeInit();
	}

	event OnTick( timeDelta : float )
	{	
		var desiredAudioState : ESoundGameState;
		var focusModeIntensity : float;
		
		
		if ( fastFocusTimer > 0.0f )
		{
			fastFocusTimer -= timeDelta;
			if ( fastFocusTimer < 0.0f )
			{
				fastFocusTimer = 0.0f;
				if ( activateAfterFastFocus )
				{
					activateAfterFastFocus = false;
					ActivateInternal();
				}
			}
		}
		
		if( IsActive() )
		{
			if( CanUseFocusMode() )
			{
				isInCombat = false;
				isUnderwaterFocus = thePlayer.OnIsCameraUnderwater();
				if( isUnderwaterFocus )
				{
					isInCombat = thePlayer.ShouldEnableCombatMusic();
					if( isInCombat )
					{
						desiredAudioState = ESGS_FocusUnderwaterCombat;
					}
					else
					{
						desiredAudioState = ESGS_FocusUnderwater;
					}
				}
				else
				{
					isNight = theGame.envMgr.IsNight();
					if( isNight )
					{
						desiredAudioState = ESGS_FocusNight;
					}
					else
					{
						desiredAudioState = ESGS_Focus;
					}
				}
				
				if( theSound.GetCurrentGameState() != desiredAudioState )
				{
					theSound.EnterGameState( desiredAudioState );
				}
				
				
				if( GetWitcherPlayer().IsMutationActive( EPMT_Mutation12 ) )
				{
					lastDarkPlaceCheck -= timeDelta;
					if( lastDarkPlaceCheck <= 0.f )
					{
						lastDarkPlaceCheck = DARK_PLACE_CHECK_INTERVAL;
					
						if( GetWitcherPlayer().IsInDarkPlace() && !thePlayer.HasBuff( EET_Mutation12Cat ) )
						{
							thePlayer.AddEffectDefault( EET_Mutation12Cat, thePlayer, "Mutation12 Senses", false );
						}
						else if( !GetWitcherPlayer().IsInDarkPlace() && thePlayer.HasBuff( EET_Mutation12Cat ) )
						{
							thePlayer.RemoveBuff( EET_Mutation12Cat );
						}
					}
				}
			}
			else
			{
				Deactivate();
			}
		}
		
		focusModeIntensity = GetIntensity();
		UpdateMedallion( focusModeIntensity );
	}

	public function SetDimmingForClue( clue : W3MonsterClue )
	{
		dimmingClue = clue;
		SetDimming( true );
	}
	
	event OnFocusModeDimmingFinished( timeDelta : float )
	{		
		if ( dimmingClue )
		{
			dimmingClue.OnDimmingFinished();
			dimmingClue = NULL;
		}
	}
	
	function UseControllerVibration( focusModeIntensity : float ) : bool
	{
		return ( focusAreaIntensity > 0.0f && focusModeIntensity < 1.0f && controllerVibrationFactor > 0.0f && thePlayer.GetCurrentStateName() == 'Exploration' );
	}
	
	function UpdateMedallion( focusModeIntensity : float )
	{
		var intensity : float;

		intensity = focusAreaIntensity;

		
		if ( UseControllerVibration( focusModeIntensity ) )
		{
			theGame.VibrateController( 0, intensity * ( 1.0f - focusModeIntensity ) * controllerVibrationFactor, controllerVibrationDuration );	
			
			focusAreaIntensity = 0.0f;
		}

		if ( medallionIntensity )
		{
			if ( medallionIntensity.ValueChanged() )
			{
				intensity = MaxF( intensity, medallionIntensity.GetValue() );
			}
			medallionIntensity.Reset();
		}	

		GetWitcherPlayer().GetMedallion().SetInstantIntensity( intensity );
		GetWitcherPlayer().GetMedallion().SetFocusModeFactor( 1.0f - focusModeIntensity );
	}
		
	public function SetMedallionIntensity( entity : CEntity, distance : float, intensity : float )
	{
		if ( medallionIntensity )
		{
			medallionIntensity.Update( entity, distance, intensity );
		}
	}
	
	public function SetFocusAreaIntensity( intensity : float )
	{
		focusAreaIntensity = intensity;
	}
	
	public function ReusableClueDetected( clue : W3MonsterClue )
	{
		var i, j	: int;
		var tags 	: array< name >;
		
		tags = clue.GetTags();
		for ( i = 0; i < tags.Size(); i += 1 )
		{
			j = detectedCluesTags.FindFirst( tags[i] );
			if ( j == -1 )
			{
				detectedCluesTags.PushBack( tags[i] );
				theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnReusableClueUsed, SET_Unknown, tags[i] );
			}
		}
	}
	
	public function WasReusableClueDetected( tag : name ) : bool
	{
		return detectedCluesTags.FindFirst( tag ) != -1;
	}
	
	public function ResetClue( tag : name, removeFacts : bool, leaveVisible : bool )
	{
		var nodes	: array< CNode >;
		var clue	: W3MonsterClue;
		var i, size	: int;
		
		if ( tag == '' )
		{
			LogQuest( "CFocusModeController.ResetClue: empty tag!");	
			return;
		}

		theGame.GetNodesByTag( tag, nodes );	
		size = nodes.Size();	
		for ( i = 0; i < size; i += 1 )
		{
			clue = (W3MonsterClue)nodes[i];		
			if ( clue )
			{
				clue.ResetClue( removeFacts, leaveVisible );
			}
		}
		
		i = detectedCluesTags.FindFirst( tag );
		if ( i != -1 )
		{
			detectedCluesTags.Erase( i );
		}
	}				
	
	var focusInteractionsInterval : float; default focusInteractionsInterval = 0;

	public function UpdateFocusInteractions( deltaTime : float)
	{
		var entities : array< CGameplayEntity >;
		var size : int;
		var i : int;
		var focusComponent : CFocusActionComponent;
		var hud : CR4ScriptedHud;
		var module : CR4HudModuleInteractions;
		var actionName : name;		

		if ( IsActive() )
		{
			focusInteractionsInterval -= deltaTime;
			if ( focusInteractionsInterval < 0 )
			{
				hud = ( CR4ScriptedHud )theGame.GetHud();
				module = ( CR4HudModuleInteractions )hud.GetHudModule( "InteractionsModule" );
				module.InvalidateAllFocusInteractionIcons();
				focusInteractionsInterval = module.GetFocusInteractionUpdateInterval();

				FindGameplayEntitiesInRange( entities, thePlayer, module.GetFocusInteractionRadius(), 1000 );
				size = entities.Size();
				for ( i = 0; i < size; i += 1 )
				{
					if ( entities[ i ].CanShowFocusInteractionIcon() )
					{
						actionName = entities[ i ].GetFocusActionName();
						if ( IsNameValid( actionName ) )
						{
							module.AddFocusInteractionIcon( entities[ i ], actionName );							
						}
					}
				}
			}
		}
	}

}
