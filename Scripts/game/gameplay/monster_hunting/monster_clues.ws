/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EFocusClueAttributeAction
{
	FCAA_ForceSet,
	FCAA_SetToTrue,
	FCAA_SetToFalse,
	FCAA_Switch,
}

enum EClueOperation
{
	CO_Enable,
	CO_Disable,
	CO_None,
}

enum EFocusClueMedallionReaction
{
	EFCMR_FirstDiscoveryInThisSession,			
	EFCMR_FirstDiscovery,							
	EFCMR_Always,									
	EFCMR_Never										
}

enum EPlayerVoicesetType
{
	EPVT_MonsterNestDrowners,
	EPVT_MiscFreshTracks,
	EPVT_MiscFollowingTracks,
	EPVT_MiscBloodTrail,
	EPVT_MiscInvestigateArea,
	EPVT_MiscHideoutFound,
	EPVT_MiscFindOtherWay,
	EPVT_MiscAnotherVictim,
	EPVT_MiscUnevenFight,
	EPVT_MiscALotOfBlood,
	EPVT_MiscGenericRemarks,
	EPVT_About_trophy,
	EPVT_FasterHorse,
	EPVT_None,
	
}

class W3MonsterClue extends W3AnimationInteractionEntity
{
	editable saved var isAvailable			: bool;
	editable saved var isInteractive		: bool;
	editable saved var isReusable			: bool;
	editable saved var isVisible			: bool;
	editable saved var isIgnoringFM			: bool;
	
	
	editable var playerVoiceset				: EPlayerVoicesetType; default playerVoiceset = EPVT_None;
	
	editable var clueEntries				: array< string >; 

	default isAvailable						= true;
	default isInteractive					= false;
	default isReusable						= true;
	default isVisible						= true;
	default medallionVibration				= true;
	default isIgnoringFM					= false;
	
	editable var maxDetectionDistance		: float;
	editable var testLineOfSight			: bool;
	
	editable var medallionVibration			: bool;	
	editable var medallionVibrationDistance	: float;
	
	editable var medallionVibrationBehavior : EFocusClueMedallionReaction;
	
	saved var medallionVibratedEver 		: bool;
	var medallionVibratedInSession 			: bool;
	
	
	
	default maxDetectionDistance			= 5.0f;
	default testLineOfSight					= false;
	default medallionVibrationDistance		= 4.0f;
	
	const var accuracyTreshold				: float;
	default accuracyTreshold				= 0.75f;


	
	editable inlined var eventOnDetected : array < IPerformableAction >;
	
	editable var detectionDelay : float;
	default detectionDelay = 0.0f;

	hint isAvailable = "Is clue available in gameplay (both interaction and visibility depend on that).";
	hint isInteractive = "Is clue interactive.";
	hint isReusable = "Type of clue interaction: interactive only once or interactive multiple times.";
	hint isVisible = "Is clue effect visibile in focus mod";
	hint clueEntries = "Facts added to datebase after clue has been found.";
	hint medallionVibration = "Should clue trigger medallion vibration";
	hint maxDetectionDistance = "Distance for the clue to be found. Used only if clue is not interactive";
	hint testLineOfSight = "Test line of sight while checking findClueDistance (check collisions with 'Static' and 'Terrain' groups).";
	hint medallionVibrationDistance = "Distance within which medallion will increase its vibration. Ignored if equal to 0.";
	hint interactionAnim = "Name of the animation played on interaction.";
	hint interactionAnimTime = "Duration of the animation played on interaction.";
	hint animationForAllInteractions = "Should the animation be played only for interaction with Examine action assigned.";
	hint eventOnDetected = "Scripted operations to perform when detected.";
	hint isIgnoringFM = "If set to true, intraction is available outside focus mode.";
	hint detectionDelay = "If larger than 0, will delay detection actions until time has passed. Float";
	hint medallionVibration = "Should medallion vibrate when we get close to the clue.";
	hint medallionVibrationDistance = "Medallion vibration activation radius.";
	hint medallionVibrationBehavior  = "How often should the medallion vibrate.";

	
	saved var wasDetected					: bool;
	saved var wasSeen						: bool;
	default isPlayingInteractionAnim		= false;
	default wasDetected						= false;
	default wasSeen							= false;

	editable saved var isVisibleAsClue		: bool;
	default isVisibleAsClue					= true;
	hint isVisibleAsClue	 = "Should the clue use clue color highlight, if false it will highlight as interactive.";

	
	var linkedFocusArea						: W3FocusAreaTrigger;
	
	var dimmingStarted						: bool;
	default dimmingStarted					= false;
	
	var focusModeController					: CFocusModeController;
	
	const var INTERACTION_COMPONENT_NAME	: string;
	default INTERACTION_COMPONENT_NAME 		= "InteractiveClue";
	
	event OnStreamIn()
	{
		ProcessReleaseVersions();
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var tags : array< name >;
		if ( !spawnData.restored )
		{
			wasSeen = false;
			wasDetected = false;
		}
		focusModeController = theGame.GetFocusModeController();		
		UpdateInteraction();
		UpdateVisibility();
	}
	
	event OnUpdateFocus( distance : float, accuracy : float )
	{
		CheckDistances( distance, accuracy );
	}
	
	event OnInteractionAttached( interaction : CInteractionComponent )
	{
		if ( interaction && interaction.GetName() == INTERACTION_COMPONENT_NAME )
		{
			UpdateInteraction( interaction );
		}
	}
	
	event OnInteraction( actionName : string, activator : CEntity  )
	{
		if ( activator == thePlayer && thePlayer.IsActionAllowed( EIAB_InteractionAction ) )
		{
			thePlayer.OnMeleeForceHolster(false);
			thePlayer.OnRangedForceHolster(true);
			
			DetectClue();
			
			if( animationForAllInteractions == true || actionName == "Examine")
			{
				PlayInteractionAnimation();
			}
			
			UpdateInteraction();
			dimmingStarted = true;
			focusModeController.SetDimmingForClue( this );
			
			PlayClueVoiceset ( playerVoiceset );
			
			
			if(ShouldProcessTutorial('TutorialFocusClues'))
			{
				FactsAdd("tut_clue_interacted", 1, 1);
			}
		}
	}

	event OnAardHit( sign : W3AardProjectile )
	{
		ApplyAppearance( "02_on_hit" );
		super.OnAardHit(sign);
	}
	
	event OnIgniHit( sign : W3IgniProjectile )
	{
		ApplyAppearance( "02_on_hit" );
		super.OnIgniHit(sign);
	}
	
	event OnWeaponHit (act : W3DamageAction)
	{
		ApplyAppearance( "02_on_hit" );
		super.OnWeaponHit(act);
	}
	
	function ShouldBlockGameplayActionsOnInteraction() : bool
	{
		return false;
	}
		
	event OnDimmingFinished()
	{
		dimmingStarted = false;
		UpdateVisibility();
	}

	public function SetAvailable( newIsAvailable : bool )
	{
		if ( isAvailable != newIsAvailable )
		{
			isAvailable = newIsAvailable;
			UpdateInteraction();
			UpdateVisibility();
			OnAvailabilityChange();
		}	
	}
	
	public function SetInteractive( newIsInteractive : bool )
	{
		isInteractive = newIsInteractive;
		UpdateInteraction();
		UpdateVisibility();
	}

	event OnAvailabilityChange()
	{
	}
	
	public function GetIsAvailable() : bool
	{
		return isAvailable;
	}
	
	public function GetIsInteractive() : bool
	{
		return isInteractive;
	}
	
	public function GetIsReusable() : bool
	{
		return isReusable;
	}

	public function GetIsVisible() : bool
	{
		return isVisible;
	}
	
	public function GetWasDetected() : bool
	{
		return wasDetected;
	}
	
	public function GetIsIgnoringFM() : bool
	{
		return isIgnoringFM;
	}

	
	function PlayClueVoiceset (voicesetEnum : EPlayerVoicesetType )
	{
		switch ( voicesetEnum )
		{
			case EPVT_None:
				break;
			case EPVT_MonsterNestDrowners:
				thePlayer.PlayVoiceset( 90, "MonsterNestDrowners" );
				break;
			case EPVT_MiscFreshTracks:
				thePlayer.PlayVoiceset( 90, "MiscFreshTracks" );
				break;
			case EPVT_MiscFollowingTracks:
				thePlayer.PlayVoiceset( 90, "MiscFollowingTracks" );
				break;
			case EPVT_MiscBloodTrail:
				thePlayer.PlayVoiceset( 90, "MiscBloodTrail" );
				break;
			case EPVT_MiscInvestigateArea:
				thePlayer.PlayVoiceset( 90, "MiscInvestigateArea" );
				break;
			case EPVT_MiscHideoutFound:
				thePlayer.PlayVoiceset( 90, "MiscHideoutFound" );
				break;
			case EPVT_MiscFindOtherWay:
				thePlayer.PlayVoiceset( 90, "MiscFindOtherWay" );
				break;
			case EPVT_MiscAnotherVictim:
				thePlayer.PlayVoiceset( 90, "MiscAnotherVictim" );
				break;
			case EPVT_MiscUnevenFight:
				thePlayer.PlayVoiceset( 90, "MiscUnevenFight" );
				break;
			case EPVT_MiscALotOfBlood:
				thePlayer.PlayVoiceset( 90, "MiscALotOfBlood" );
				break;
			case EPVT_MiscGenericRemarks:
				thePlayer.PlayVoiceset( 90, "MiscGenericRemarks" );
				break;
			case EPVT_About_trophy:
				thePlayer.PlayVoiceset( 90, "About_trophy" );
				break;
			case EPVT_FasterHorse:
				thePlayer.PlayVoiceset( 90, "FasterHorse" );
				break;
		}
	}
	function IsInteractiveInternal() : bool
	{
		if ( isIgnoringFM )
		{
			return isAvailable && isInteractive && ( !wasDetected || isReusable );	
		}
		else
		{
			return isAvailable && isInteractive && wasSeen && ( !wasDetected || isReusable );
		}
	}

	function UpdateInteraction( optional comp : CComponent )
	{
		var enabled : bool;
		
		if ( !comp )
		{
			comp = GetComponent( INTERACTION_COMPONENT_NAME );
		}
		if ( comp )
		{
			enabled = false;
			
			if ( IsInteractiveInternal() )
			{
				
				if ( !isPlayingInteractionAnim )
				{
					enabled = true;
				}
			}
			comp.SetEnabled( enabled );							
		}
		else
		{
			LogAssert( false, "Monster clue <<" + this + ">> has no InteractiveClue component" );
		}		
	}		

	function UpdateVisibility()
	{
		var count : int;
		if ( isVisible )
		{
			if ( isVisibleAsClue )
			{
				SetFocusModeVisibility( FMV_Clue );
			}
			else
			{	
				SetFocusModeVisibility( FMV_Interactive );
			}
		}			
		else
		{
			SetFocusModeVisibility( FMV_None );
		}
	}
	
	
	function OverrideVisibilityParams( focusModeVisibility : EFocusModeVisibility )
	{
		if ( focusModeVisibility == FMV_None )
		{
			isVisible = false;
		}
		else if ( focusModeVisibility == FMV_Clue )
		{
			isVisible = true;
			isVisibleAsClue = true;
		}
		else
		{
			isVisible = true;
			isVisibleAsClue = false;		
		}
	}
	
	function ChangeAttribute( actionType : EFocusClueAttributeAction, currentValue : bool, changeFlag : bool ) : bool
	{
		if ( actionType == FCAA_ForceSet )
		{
			return changeFlag;
		}
		else if ( actionType == FCAA_SetToTrue )
		{
			if ( changeFlag )
			{
				return true;
			}
		}
		else if ( actionType == FCAA_SetToFalse )
		{
			if ( changeFlag )
			{
				return false;
			}
		}
		else if ( actionType == FCAA_Switch )
		{
			if ( changeFlag )
			{
				return !currentValue;
			}
		}
		return currentValue;
	}
	
	public function SetAttributes( actionType : EFocusClueAttributeAction, changeIsAvailable : bool, changeIsInteractive : bool, changeIsReusable : bool, changeIsVisible : bool, changeWasDetected : bool, changeisIgnoringFM : bool )
	{
		isAvailable = ChangeAttribute( actionType, isAvailable, changeIsAvailable );
		isInteractive = ChangeAttribute( actionType, isInteractive, changeIsInteractive );
		isReusable = ChangeAttribute( actionType, isReusable, changeIsReusable );
		isVisible = ChangeAttribute( actionType, isVisible, changeIsVisible );
		wasDetected = ChangeAttribute( actionType, wasDetected, changeWasDetected );
		isIgnoringFM = ChangeAttribute( actionType, isIgnoringFM, changeisIgnoringFM );
		
		UpdateInteraction();
		UpdateVisibility();
	}

	function AddFacts()
	{
		var i, size : int;		
		size = clueEntries.Size(); 		
		for ( i = 0; i < size; i += 1 )
		{
			FactsAdd( clueEntries[i] );
			LogQuest( "Fact  " + clueEntries[i] + " was added" );
		}
	}
	
	function RemoveFacts()
	{
		var i, size : int;		
		size = clueEntries.Size(); 		
		for ( i = 0; i < size; i += 1 )
		{
			FactsRemove( clueEntries[i] );
			LogQuest( "Fact  " + clueEntries[i] + " was removed" );
		}	
	}

	event OnPlayerActionEnd()
	{
		super.OnPlayerActionEnd();
		UpdateInteraction();
	}

	function CheckDistances( distance : float, accuracy : float)
	{
		var allowVibration : bool;
		var intensity : float;
		var recentDialogueTime, currentTime : GameTime;
		
		if ( isAvailable && isVisible && !wasDetected )
		{
			OnDetectionDistance( distance < maxDetectionDistance, accuracy );
			if ( medallionVibration )
			{	
				if ( distance < medallionVibrationDistance )
				{
					if( focusModeController.GetBlockVibrations() == false )
					{
						allowVibration = false;
						
						if(medallionVibrationBehavior == EFCMR_Always)
						{
							allowVibration = true;
						}
						else if(medallionVibrationBehavior == EFCMR_FirstDiscovery)
						{
							if(!medallionVibratedEver)
							{
								medallionVibratedEver = true;
								allowVibration = true;
							}
						}
						else if(medallionVibrationBehavior == EFCMR_FirstDiscoveryInThisSession)
						{
							if(!medallionVibratedInSession)
							{
								medallionVibratedInSession = true;
								allowVibration = true;
							}
						}
						
						if(allowVibration)
						{
							
							recentDialogueTime = theGame.GetRecentDialogOrCutsceneEndGameTime();
							currentTime = theGame.GetGameTime();
							
							if( GameTimeDTAtLeastRealSecs( currentTime, recentDialogueTime, 4 ) )
							{
								IndicateClue();
								focusModeController.SetBlockVibrations( true );
								
								AddTimer('ResetFocusVibrationBlockTimer', 5.5f, false);
							}
						}
					}
				}		
			}
		}
	}
	
	
	private function IndicateClue()
	{
		focusModeController.SetMedallionIntensity( this, 0.0f, 2.0f );
		focusModeController.SetFocusAreaIntensity( 1.0f );
		
	}

	timer function ResetFocusVibrationBlockTimer( delta : float , id : int)
	{
		focusModeController.SetBlockVibrations( false );
	}


	
	public function MarkSeenClues()
	{
		var nodes 		: array< CNode >;
		var i, size 	: int;
		var monsterClue : W3MonsterClue;
		
		theGame.GetNodesByTags( GetTags(), nodes, true );
		size = nodes.Size();
		for ( i = 0; i < size; i+=1 )
		{
			monsterClue = (W3MonsterClue)nodes[i];
			if ( monsterClue && monsterClue != this && !monsterClue.wasSeen)
			{
				monsterClue.wasSeen = true;
				monsterClue.UpdateInteraction();
				monsterClue.UpdateVisibility();					
			}		
		}		
	}
	
	event OnDetectionDistance( inRange : bool, accuracy : float )
	{
		if ( inRange )
		{
			if ( !isInteractive )
			{
				if ( accuracy >= accuracyTreshold )
				{
					wasSeen = true;
					if ( !wasDetected )
					{
						DetectClue();
					}				
				}
			}
			else
			{
				if ( !wasSeen && accuracy >= accuracyTreshold )
				{
					wasSeen = true;
					UpdateInteraction();
					UpdateVisibility();
					MarkSeenClues();
				}							
			}
		}
	}
		
	event OnClueDetected()
	{
		wasDetected = true;
		AddFacts();	
		focusModeController.ReusableClueDetected( this );
		TriggerPerformableEvent( eventOnDetected, this );
	}
	
	event OnManageClue( operations : array< EClueOperation > )
	{
		var i, size : int;
		
		size = operations.Size();
		for ( i = 0; i < size; i += 1 )
		{
			switch ( operations[ i ] )
			{
			case CO_Enable:
				isVisible=true;
				SetAvailable(true);
				break;
			case CO_Disable:
				isVisible=false;
				SetAvailable(false);
				break;
			case CO_None:
				break;
			default:
				break;
			}
		}
		
	}	
		
	function DetectClue()
	{
		
		if ( !wasDetected || isReusable )
		{
			if (detectionDelay>0.0)
			{
				this.AddTimer( 'DelayedClueDetection', detectionDelay, false, , , true );
			}
			else
			{
				OnClueDetected();
				
				
				if ( linkedFocusArea )
				{
					linkedFocusArea.SmartFocusAreaCheck();
				}
			}
		}
		
	}
	
	timer function DelayedClueDetection( t : float , id : int)
	{
		OnClueDetected();
				
		
		if ( linkedFocusArea )
		{
			linkedFocusArea.SmartFocusAreaCheck();
		}
	}

	public function ResetClue( removeFacts : bool, leaveVisible : bool )
	{	
		isVisibleAsClue = leaveVisible;
		
		if( medallionVibrationBehavior == EFCMR_FirstDiscoveryInThisSession )
		{
			medallionVibratedInSession = true;
		}
		else
		{
			if( medallionVibrationBehavior == EFCMR_FirstDiscovery )
			{
				medallionVibratedEver = true;
			}
		}
		
		UpdateInteraction();
		
		if ( !dimmingStarted )
		{
			UpdateVisibility();
		}
		if ( removeFacts )
		{
			RemoveFacts();
		}
	}
	
	public function GetFocusActionName() : name
	{
		if ( IsInteractiveInternal() )
		{
			return super.GetFocusActionName();
		}
		return '';
	}
	
	public function CanShowFocusInteractionIcon() : bool
	{
		return !wasDetected;
	}

	

	function ProcessReleaseVersions()
	{
		
		if( FactsQuerySum( "release_jp" ) >= 1 )
		{
			ProcessStaticMeshesReleaseVersions( 'release_jp_hide' );
			ProcessMeshesReleaseVersions( 'release_jp_hide' );	
			ProcessRigidMeshesReleaseVersions( 'release_jp_hide' );
			ProcessDecalsReleaseVersions( 'release_jp_hide' );		
		}
		
	}

	function ProcessDecalsReleaseVersions( hideTag : name, optional showTag : name )
	{
		var decals : array<CComponent>;
		var decal : CDecalComponent;
		var i : int;
		
		decals = this.GetComponentsByClassName( 'CDecalComponent' );
		
		if( decals.Size() > 0 )
		{
			for( i=0; i < decals.Size(); i+=1 )
			{
				decal = (CDecalComponent) decals[i];
				
				if( decal.HasTag( hideTag ) && hideTag != '' )
				{
					decal.SetVisible( false );
				}
				if( decal.HasTag( showTag ) && showTag != ''  )
				{
					decal.SetVisible( true );
				}
			}
		}
	}

	function ProcessStaticMeshesReleaseVersions( hideTag : name, optional showTag : name )
	{
		var meshes : array<CComponent>;
		var staticMesh : CStaticMeshComponent;
		var i : int;
		
		meshes = this.GetComponentsByClassName( 'CStaticMeshComponent' );
		
		if( meshes.Size() > 0 )
		{
			for( i=0; i < meshes.Size(); i+=1 )
			{
				staticMesh = (CStaticMeshComponent) meshes[i];
				
				if( staticMesh.HasTag( hideTag ) && hideTag != ''  )
				{
					staticMesh.SetVisible( false );
				}
				if( staticMesh.HasTag( showTag ) && showTag != '' )
				{
					staticMesh.SetVisible( true );
				}
			}
		}
	}

	function ProcessMeshesReleaseVersions( hideTag : name, optional showTag : name  )
	{
		var meshes : array<CComponent>;
		var mesh : CMeshComponent;
		var i : int;
		
		meshes = this.GetComponentsByClassName( 'CMeshComponent' );
		
		if( meshes.Size() > 0 )
		{
			for( i=0; i < meshes.Size(); i+=1 )
			{
				mesh = (CStaticMeshComponent) meshes[i];
				
				if( mesh.HasTag( hideTag ) && hideTag != '' )
				{
					mesh.SetVisible( false );
				}
				if( mesh.HasTag( showTag ) && showTag != '' )
				{
					mesh.SetVisible( true );
				}
			}
		}
	}

	function ProcessRigidMeshesReleaseVersions( hideTag : name, optional showTag : name  )
	{
		var meshes : array<CComponent>;
		var mesh : CRigidMeshComponent;
		var i : int;
		
		meshes = this.GetComponentsByClassName( 'CRigidMeshComponent' );
		
		if( meshes.Size() > 0 )
		{
			for( i=0; i < meshes.Size(); i+=1 )
			{
				mesh = (CRigidMeshComponent) meshes[i];
				
				if( mesh.HasTag( hideTag ) && hideTag != ''  )
				{
					mesh.SetVisible( false );
				}
				if( mesh.HasTag( showTag ) && showTag != '' )
				{
					mesh.SetVisible( true );
				}
				
			}
		}
	}

	

}





class W3MonsterClueScent extends W3MonsterClue
{

}



enum EMonsterClueAnim
{
	MCA_None,
	MCA_SirenTreeKill,
	MCA_WarriorDeath_01_quest,
	MCA_WarriorDeath_02_quest,
	MCA_WarriorDeath_03_quest,
	MCA_WarriorDeath_quick_01_quest,
	MCA_WarriorDeath_quick_02_quest,
	MCA_WarriorDeath_quick_03_quest,
	MCA_WarriorDeath_quick_04_quest,
	MCA_WarriorDeath_quick_05_quest,
	MCA_WarriorDeath_quick_06_quest,
	MCA_WarriorDeath_quick_07_quest,
	MCA_InjuredLeg_quest,
	MCA_WomanWalking_quest,
	MCA_ManWalking_quest,
	MCA_Avallach_kill_Nithral_quest,
	MCA_Nithral_pushed_back_quest,
	MCA_Nithral_attack_quest,
	MCA_Woman_being_hit_quest,
	MCA_Avallach_surrounded_quest,
	MCA_Ciri_surrounded_quest,
	MCA_Wildhunt1_surrounded_quest,
	MCA_Wildhunt2_surrounded_quest,
	MCA_Wildhunt3_surrounded_quest,
	MCA_Wildhunt4_surrounded_quest,
	MCA_Wildhunt5_surrounded_quest,
	MCA_Wildhunt6_surrounded_quest,
	MCA_q106_step_back,
	MCA_q106_standing_leaning,
	MCA_q106_fall_kneel,
	MCA_q106_devastated_attack,
	MCA_q106_brush_floor,
	MCA_q106_crawl
}

class W3MonsterClueAnimated extends W3MonsterClue
{
	editable var animation					: EMonsterClueAnim;			
	editable var witnessWholeAnimation 		: bool;	
	editable var animStartEvent 			: name;	
	editable var animEndEvent 				: name;	
	editable var useAccuracyTest			: bool;	
	editable var accuracyError				: float;	
	editable var stopAnimSoundEvent			: name;
	editable var activatedByFact			: name;
	
	default animation						= MCA_None;
	default witnessWholeAnimation 			= true;
	default animStartEvent 					= 'MonsterClueAnimStart';
	default animEndEvent 					= 'MonsterClueAnimEnd';
	default useAccuracyTest 				= false;
	default accuracyError 					= 0.2f;	
	default stopAnimSoundEvent 				= '';
	default activatedByFact					= '';
	
	hint animation = "Chose the animation (defined in behavior graph and EMonsterClueAnim enum)";
	hint witnessWholeAnimation = "Only if whole animation is played and player sees it, clue will add facts to database";
	hint animStartEvent = "Anim event indicating the start of the animation, needs to be set in animation timeline";
	hint animEndEvent = "Anim event indicating the end of the animation, needs to be set in animation timeline";
	hint useAccuracyTest = "Test if player actually sees the clue entity for the whole anim";
	hint accuracyError = "A 0 - 1 value. The higher it is, the more precise player has to aim with the camera";
	hint stopAnimSoundEvent = "Name of the sound event played on animation finished";
	hint activatedByFact = "Name of the fact that activates clue";
		
	saved var spawnPosWasSaved 				: bool;
	saved var spawnPos						: Vector;
	saved var spawnRot						: EulerAngles;		
	default spawnPosWasSaved				= false;
	
	var animStarted 						: bool;	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		SetBehaviorVariable( 'MonsterAnimEnum', 0 );					
		if( !spawnPosWasSaved )
		{
			spawnPosWasSaved = true;
			spawnPos = GetWorldPosition();
			spawnRot = GetWorldRotation();
		}
		animStarted = false;
		
		AddAnimEventCallback(animEndEvent,'OnAnimEvent_Custom');
	}
	
	function ResetPos()
	{
		TeleportWithRotation( spawnPos, spawnRot );
	}
	
	event OnAnimEvent_Custom( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventName == animEndEvent )
		{
			if ( witnessWholeAnimation )
			{
				theSound.SoundEvent( stopAnimSoundEvent );
				DetectClue();
			}
		}
	}
	
	event OnUpdateFocus( distance : float, accuracy : float )
	{
		var canBeSeen : bool;		
		
		canBeSeen = ( distance < maxDetectionDistance && ( !useAccuracyTest || accuracy > accuracyError ) );
		
		
		
		if ( animStarted )
		{
			if ( witnessWholeAnimation && ( !canBeSeen || !FactsDoesExist( activatedByFact ) ) )
			{
				SetBehaviorVariable( 'MonsterAnimEnum', 0 );
				animStarted = false;
				ResetPos();
			}		
		}
		else
		{
			if ( canBeSeen && FactsDoesExist( activatedByFact ) )
			{
				SetBehaviorVariable( 'MonsterAnimEnum', (int)animation );									
				if ( !witnessWholeAnimation )
				{
					theSound.SoundEvent( stopAnimSoundEvent );
					DetectClue();
				}
				else
				{
					animStarted = true;				
				}
			}
		}
	}	
}

class W3ClueStash extends W3MonsterClue
{
	editable var lootEntityTemplate : CEntityTemplate;
	editable var setInvisibleAppearanceAfterLootingStash : bool;
	editable var showLootPanelImmediately : bool;
	editable saved var isStashDisabled : bool; 
	editable var stashOpenDelay : float;
	editable var stashSpawnOffset : Vector;
	editable var lootEntityTag : name;
	
	
	saved var currentAppearance : name;
	default currentAppearance = 'undetected';
	
	var lootEntity : W3Container;
	saved var lootWasOfferedToPlayer : bool;
	saved var stashWasLooted : bool;
	

	default setInvisibleAppearanceAfterLootingStash = false;
	default showLootPanelImmediately = false;
	default stashOpenDelay = 4.0;
	
	
	hint setInvisibleAppearanceAfterLootingStash = "Appearance 'invisible' will be called when the clue is looted";
	hint showLootPanelImmediately = "Skips interaction 'Loot' and shows Loot Panel upon finding clue";

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if (wasDetected && !isStashDisabled)
		{
			UpdateAppearance(0,0);
			
			if( lootEntity )
			{
				lootEntity.RegisterClueStash( this );
			}
			
		}
		else
		{
			SetAppearance( currentAppearance );
		}
		super.OnSpawned( spawnData );
	}
	
	event OnStreamIn()
	{
		if (wasDetected && !isStashDisabled)
		{
			UpdateAppearance(0,0);
			
			if( lootEntity )
			{
				lootEntity.RegisterClueStash( this );
			}
		}
		else
		{
			SetAppearance( currentAppearance );
		}		
		super.OnStreamIn();
	}

	function SetAppearance( appearance : name )
	{
		currentAppearance = appearance;
		ApplyAppearance( appearance );
	}
	
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{	
		
		if ( isAvailable && stashWasLooted && HasTag( 'mq1058_girl_doll' ) )
		{
			
			if ( thePlayer.GetInventory().GetItemId( 'mq1058_doll' ) == GetInvalidUniqueId() )
			{
				stashWasLooted = false;
				SetAppearance( 'undetected' );			
			}
		}
		
		
	}	
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		
		if( stashOpenDelay > interactionAnimTime )
		{
			interactionAnimTime = stashOpenDelay;
		}
		
		super.OnInteraction( actionName, activator );
		
		if( !isStashDisabled )
		{
			SetAttributes( FCAA_ForceSet , false , false , false , false , true , false );
			SetAppearance ( 'detected' );
			UpdateStash();
		}
		
		if( lootEntity )
		{
			lootEntity.RegisterClueStash( this );
		}
		else
		{
			AddTimer( 'RegisterClueStash', 0.0001f, true );
		}
	}
	
	timer function RegisterClueStash( t : float , id : int)
	{
		if( lootEntity )
		{
			lootEntity.RegisterClueStash( this );
			RemoveTimer( 'RegisterClueStash' );
		}
	}
	
	event OnClueDetected()
	{
		if( isStashDisabled == false )
		{
			SetInteractive( true );
		}
		super.OnClueDetected();
	}

	function ShouldBlockGameplayActionsOnInteraction() : bool
	{
		return true;
	}

	
	function UpdateInteraction( optional comp : CComponent )
	{
		var enabled : bool;
		
		if ( !comp )
		{
			comp = GetComponent( INTERACTION_COMPONENT_NAME );
		}
		if ( comp )
		{
			enabled = false;
			
			if ( IsInteractiveInternal() )
			{
				
				if ( !isPlayingInteractionAnim )
				{
					enabled = true;
				}
			}
			
			EnableInteractionBaseOnStashState( enabled );
		}
		else
		{
			LogAssert( false, "Monster clue <<" + this + ">> has no InteractiveClue component" );
		}		
	}
	
	function UpdateStash()
	{
		if( isStashDisabled == false )
		{
			if (!showLootPanelImmediately) AddTimer( 'UpdateAppearance', stashOpenDelay, , , , true );
			else UpdateAppearance(0,0);
		}
	}
	
	public function OnContainerEvent()
	{
		if( !lootEntity || lootEntity.IsEmpty() ) 
		{
			stashWasLooted = true;
			if( setInvisibleAppearanceAfterLootingStash )
			{
				SetAppearance( 'invisible' );
			}
		}
	}
	
	timer function UpdateAppearance( td : float , id : int)
	{
		var lootPos : Vector;
		
		if (!stashWasLooted)
		{
			SetAppearance( currentAppearance );
			
			if( lootEntityTemplate && !stashWasLooted )
			{
				lootPos = this.GetWorldPosition() + stashSpawnOffset;
				
				lootEntity = (W3Container) theGame.CreateEntity( lootEntityTemplate, lootPos, this.GetWorldRotation() );
				
				if( lootEntity )
				{
					SetAttributes( FCAA_ForceSet , false , false , false , false , true , false ); 
					lootEntity.AddTag( lootEntityTag );
				}
				
				if (!lootEntity.IsEmpty() ) 
				{
					if (lootEntity.GetSkipInventoryPanel())
					{
						lootEntity.TakeAllItems();
						lootEntity.OnContainerClosed();
					}
					else
					{
						if (!lootWasOfferedToPlayer) 
						{
							lootWasOfferedToPlayer = true;
							lootEntity.ShowLoot();
						}
						
					}
				}
			}
			
			if( !lootEntity || lootEntity.IsEmpty() ) 
			{
				stashWasLooted = true;
				if( setInvisibleAppearanceAfterLootingStash )
				{
					SetAppearance( 'invisible' );
				}
			}

			RemoveTimer( 'UpdateAppearance' ); 
		}
		else
		{
			SetAppearance( 'invisible' );
		}
	}
	
	
	public function SetStashDisabled( isDisabled : bool )
	{
		isStashDisabled = isDisabled;
	}
	
	private function EnableInteractionBaseOnStashState( enable : bool )
	{
		var takeInteraction : CInteractionComponent;
		var examineInteraction : CInteractionComponent;
		
		takeInteraction = (CInteractionComponent) this.GetComponent( "Take" );
		examineInteraction = (CInteractionComponent) this.GetComponent( "InteractiveClue" );
		
		if( takeInteraction )
		{
			if( !isStashDisabled && wasDetected )
			{
				examineInteraction.SetEnabled( false );
				takeInteraction.SetEnabled( enable );
			}
			else
			{
				examineInteraction.SetEnabled( enable );
				takeInteraction.SetEnabled( false );				
			}
		}
		else
		{
			examineInteraction.SetEnabled( enable );
		}
		
	}
	
}

class W3DisarmClue extends W3MonsterClue
{
	editable var connectedTripwireTag : name;
	var connectedTripwire : W3TripwireSwitch; 
	
	event OnClueDetected()
	{
		AddTimer( 'DisarmTimer', interactionAnimTime, true, , , true );
	}
	
	timer function DisarmTimer( td : float , id : int)
	{
		isVisibleAsClue = false;
		super.OnClueDetected();
		connectedTripwire = (W3TripwireSwitch) theGame.GetEntityByTag(connectedTripwireTag);
		if (connectedTripwire) connectedTripwire.Disarm();
		this.Destroy();
	}
}


class W3SavedSoundClue extends CGameplayEntity
{
	saved var savedFocusModeSoundEffectType	: EFocusModeSoundEffectType;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{		
		
		if ( spawnData.restored )
		{
			focusModeSoundEffectType = savedFocusModeSoundEffectType;
		}
		
		else
		{
			savedFocusModeSoundEffectType = focusModeSoundEffectType;
		}
		super.OnSpawned( spawnData );
	}	
}
