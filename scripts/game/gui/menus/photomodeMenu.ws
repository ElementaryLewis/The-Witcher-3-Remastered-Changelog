/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3PhotomodeExitConfirmPopupData extends ConfirmationPopupData
{
	public var m_photomodeMenuRef : CR4PhotomodeMenu;
	
	protected  function GetContentRef() : string 
	{
		return "ConfirmationPopupRef";
	}
	
	public function  OnUserFeedback( KeyCode:string ) : void
	{
		LogChannel('GFX ',"OnUserFeedback  "+KeyCode);
		if (KeyCode == "enter-gamepad_A") 
		{								  
			OnUserAccept();				  
		}
		else if (KeyCode == "escape-gamepad_B") 
		{
			OnUserDecline();
		}
	}
	
	protected  function OnUserAccept() : void
	{
		if(m_photomodeMenuRef)
			m_photomodeMenuRef.OnConfirmExit();
		ClosePopup();
	}
	
	protected  function OnUserDecline() : void
	{
		ClosePopup();
	}
	
	protected  function GetAcceptText() : string
	{
		return "photomode_exit_confirm";
	}
	
	protected  function GetDeclineText() : string
	{
		return "panel_button_common_exit";
	}
	
	public function SetupTexts():void
	{
		SetMessageTitle("[[photomode_exit_prompt_title]]");
		SetMessageText("[[photomode_exit_prompt_desc]]");
	}
	
}

struct SNPCLocationPair
{
	var m_npc : CNewNPC;
	var m_location : Vector;
}

struct SNPCAppearancePair
{
	var m_npc : CActor;
	var m_appearance : name;
}

struct SPhotomodeRendererExtraParams
{
	var m_callbackFunctionName : string;
	var m_callbackFunctionNameSecondary : string;
	var m_callbackDelay : float;
	var m_disabled : bool; default m_disabled = false;
}

struct SPhotoAspectRatio
{
	var width : int;
	var height : int;
}

struct SSpawnableCharacter
{
	var m_displayName : string;
	var m_displayNameLocKey : string;
	var m_entityName : string;
	var m_icon : string;
	var m_categories : string;
	var m_poseset : string;
	var m_mimicset : string;
}

struct SSpawnedCharacter
{
	var m_slot : int;
	var m_index : int;
	var m_actor : CNewNPC;
	var m_entityName : string;
	var m_location : Vector;
	var m_rotation : EulerAngles;
	var m_relativeLocation : Vector;
	var m_relativeRotation : float;
	var m_lookAtCamera : bool;
	var m_snapToCamera : bool;
	var m_disableGravity : bool;
	var m_appearance : name;
	var m_pose : name;
	var m_poseDetails : SSpawnableCharacterPose;
	var m_posesets : array<string>;
	var m_mimic : name;
	var m_mimic_id : int;
	var m_mimicsets : array<string>;
	var m_hidden : bool;
}

struct SSpawnableCharacterPose
{
	var m_poseset : string;
	var m_pose : name;
	var m_poseName : name;
	var m_startTime : float;
}

struct SSlotedSpawnable
{
	var id : string;
	var spawnableName : string;
	var iconPath : string;	
}

enum ECharacterFiltering
{
	ECF_All,
	ECF_Main,
	ECF_Men,
	ECF_Women,
	ECF_Animal,
	ECF_Monster
}

enum EAddCharacterFiltering
{
	EACF_All,
	EACF_Main,
	EACF_Side,
	EACF_WildHunt,
}

struct SSpawnableProp
{
	var m_displayName : string;
	var m_displayNameLocKey : string;
	var m_entityName : string;
	var m_icon : string;
	var m_categories : int;
}

struct SSpawnedProp
{
	var m_slot : int;
	var m_index : int;
	var m_entity : CEntity;
	var m_location : Vector;
	var m_rotation : EulerAngles;
	var m_relativeLocation : Vector;
	var m_relativeRotation : float;
	var m_snapToCamera : bool;
	var m_disableGravity : bool;
}

enum EPropFiltering
{
	EPF_All,
	EPF_Furniture,
	EPF_Headwear,
	EPF_Holdable,
	EPF_LightSources,
	EPF_Occult,
	EPF_Paper,
	EPF_Weapons,
}

class CR4PhotomodeMenu extends CR4MenuBase
{	
	private var _cachedTutorialVisibility : bool; default _cachedTutorialVisibility = false;
	private var	m_fxOnScreenshotSaved 				: CScriptedFlashFunction;
	private var m_fxSetCurrentFrameScale 			: CScriptedFlashFunction;
	private	var m_fxSetThirdsLinesAspectRatio		: CScriptedFlashFunction;
	private	var m_fxSetThirdsLinesVisibility		: CScriptedFlashFunction;
	private var m_fxSetCoords						: CScriptedFlashFunction;
	private var m_fxUpdateParam						: CScriptedFlashFunction;
	private var m_fxSetCurrentCharacter				: CScriptedFlashFunction;
	private var m_fxSetCurrentProp					: CScriptedFlashFunction;
	private var m_fxSetCharacterHighlightVisibility	: CScriptedFlashFunction;
	private var m_fxSetCharacterHighlightPosition	: CScriptedFlashFunction;
	private var m_fxSetPhotoAspectRatio				: CScriptedFlashFunction;
	private var m_fxSetBlackbarVisible				: CScriptedFlashFunction;
	private var m_fxStartExitDelayTimer				: CScriptedFlashFunction;

	private	var m_updatePhotoModeState				: CScriptedFlashFunction;
	private var m_photoModeState					: PhotomodeState; default m_photoModeState = PMS_TabSelection;

	private var m_queuedOverrideElements : CScriptedFlashArray;
	private var m_queuedCharUpdate : bool;
	private var m_queuedFakeTickN : int;
	private var m_queuedSelectedCharacterVisibility : bool;
	private var m_queuedSpawnedCharacterVisibility : bool;
	private var m_queuedSpawnedPropVisibility : bool;
	private var m_queuedReapplyAnimation : bool;

	private var m_exitDelayTimeMs : int; default m_exitDelayTimeMs = 1000; 
	private var m_clothsWarmupTime : float; default m_clothsWarmupTime = 1.f;

	private var m_defaultUIValues : map<int, float>;
	private var m_UIValues : map<int, float>;
	private var m_exludeFromPreset : array<int>;

	
	private var m_noPresetUIValues : map<int, float>;
	private var m_noLocationPresetPos : Vector;
	private var m_noLocationPresetRot : EulerAngles;
	
	private var m_cachedWeatherNames : array<string>;
	private var m_raycastCollisionGroupsNames : array<name>;
	
	private var m_lastMouseX : float;
	private var m_lastMouseY : float;
	private var m_lastCameraPosition : Vector;
	private var m_lastCameraRotation : EulerAngles;
	private var m_isCursorVisible : bool; default m_isCursorVisible = false;
	
	private var m_cameraLocked : bool; default m_cameraLocked = false;
	private var m_cameraDraggable : bool; default m_cameraDraggable = false;

	private var m_targetCameraPosition : Vector;
	private var m_targetCameraRotation : EulerAngles;
	private var m_cameraBlendSmoothTime : float; default m_cameraBlendSmoothTime = 0.1f;
	private var m_cameraBlendInProgress : bool; default m_cameraBlendInProgress = false;
	private var m_cameraPositionDamper : VectorSpringDamper;
	private var m_cameraRotationDamper : EulerAnglesSpringDamper;
	private var m_lastLocationSlot : int; default m_lastLocationSlot = 0;

	private var m_hideNPCsEnabled : bool;
	private var m_hiddenNPCs : array< CNewNPC >;
	
	private var m_envDefs : array<string>;
	private var m_originalNPCAppearances : array < SNPCAppearancePair >;
	
	private var m_cachedCharacterList : array < CActor >;
	private var m_cachedUncensorableCharacterList : array < CActor >;
	private var m_characterFiltering : ECharacterFiltering; default m_characterFiltering = ECF_All;
	private var m_addCharacterFiltering : EAddCharacterFiltering; default m_addCharacterFiltering = EACF_All;
	private var m_cachedAppearanceList : array < name >;
	private var m_maxNPCDistance : float; default m_maxNPCDistance = 30;
	
	private var m_censoredAppearances : C2dArray;
	private var m_isCharacterSelected : bool; default m_isCharacterSelected = false;
	private var m_aspectRatios : array<SPhotoAspectRatio>;

	private var m_maxLocationSlots : int; default m_maxLocationSlots = 5;
	private var m_locationPresets : array<string>;
	private var m_locationSlotToId : map<int, int>;

	private var m_spawnableCharacterSettings : C2dArray;
	private var m_spawnableCharacterPosesSettings : C2dArray;
	private var m_spawnableCharacterMimicsSettings : C2dArray;
	private var m_spawnableCharacterList : array<SSpawnableCharacter>;
	private var m_spawnableCharacterPosesets : map<string, string>;
	private var m_spawnableCharacterMimicsets : map<string, string>;
	private var m_spawnableCharactersPoses : array<SSpawnableCharacterPose>;
	private var m_spawnableCharactersMimics : array<SSpawnableCharacterPose>;

	private var m_currentCharacterSlotId : int;
	private var m_currentPropSlotId : int;
	private var m_characterToSpawnID : int;
	private var m_lastPhotomodeTab : int;

	private var m_selectedCharacterPoses : array<name>;
	private var m_selectedCharacterPoseDetails : array<SSpawnableCharacterPose>;
	private var m_selectedCharacterPoseNames : array<name>;
	private var m_selectedCharacterMimics : array<name>;
	private var m_selectedCharacterMimicNames : array<name>;

	private var m_spawnCameraOffset : float; default m_spawnCameraOffset = 4;
	private var m_spawnCameraSnapMaxLength : float; default m_spawnCameraSnapMaxLength = 10.f;
	private var m_spawnedCharacters : array < SSpawnedCharacter >;
	private var m_spawnedCharactersBySlot : map < int, SSpawnedCharacter >;
	private var m_selectedSpawnedCharacter : SSpawnedCharacter;
	private var m_spawnedProps		: array<SSpawnedProp>;
	private var m_spawnedPropsBySlot : map < int, SSpawnedProp >;
	private var m_selectedSpawnedProp : SSpawnedProp;

	private var m_slotedCharacters : array<SSlotedSpawnable>;
	private var m_slotedProps : array<SSlotedSpawnable>;
	private var m_cachedPropList : array < CEntity >;
	private var m_propFiltering : EPropFiltering; default m_propFiltering = EPF_All;

	private var m_selectedCharacter, m_selectedCharacter_World, m_selectedCharacter_Spawned : CActor;
	private var m_selectedCharValid, m_selectedCharValid_World, m_selectedCharValid_Spawned : bool;
	default m_selectedCharValid = false; default m_selectedCharValid_World = false; default m_selectedCharValid_Spawned = false;
	private var m_selectedProp : CEntity;
	private var m_selectedPropValid : bool; default m_selectedPropValid = false;

	private var m_spawnablePropSettings : C2dArray;
	private var m_spawnablePropList : array<SSpawnableProp>;
	
	event OnConfigUI()
	{
		super.OnConfigUI();

		m_queuedOverrideElements = m_flashValueStorage.CreateTempFlashArray();

		LoadCensoredAppearances();
		GetAllEnvironmentDefinitions(m_envDefs);
		FilterEnvDefinitionsByLocalization();
		HideTutorial();

		
		FillAllSlotWithDefault();

		FillTabbedMenu();	

		FillPlacableCharacterList();
		FillPlacablePropList();
		FillPlacableLightList();

		FillCharFilterSelector();
		FillPropFilterSelector();

		UpdateParamWithEvent( PM_Camera_FOV, m_defaultUIValues[PM_Camera_FOV] );
		UpdateParamWithEvent( PM_Camera_Noclip, m_defaultUIValues[PM_Camera_Noclip] );
		RefreshLocationPresets();

		m_exludeFromPreset.PushBack( PM_Camera_Preset );

		m_fxOnScreenshotSaved = GetMenuFlash().GetMemberFlashFunction( "onScreenshotSaved" );
		m_fxSetCurrentFrameScale = GetMenuFlash().GetMemberFlashFunction( "setCurrentFrameScale" );
		m_fxSetCurrentFrameScale.InvokeSelfTwoArgs( FlashArgNumber( theGame.GetUIVerticalFrameScale() ), FlashArgNumber( theGame.GetUIHorizontalFrameScale() ) );
		m_fxSetThirdsLinesAspectRatio  = GetMenuFlash().GetMemberFlashFunction( "setThirdsLinesAspectRatio" );
		m_fxSetThirdsLinesVisibility  = GetMenuFlash().GetMemberFlashFunction( "setThirdsLinesVisibility" );
		m_fxSetCoords = GetMenuFlash().GetMemberFlashFunction( "setCoords" );
		m_fxUpdateParam = GetMenuFlash().GetMemberFlashFunction( "updateParam" );
		m_fxSetCurrentCharacter = GetMenuFlash().GetMemberFlashFunction( "setCurrentCharacter" );
		m_fxSetCurrentProp = GetMenuFlash().GetMemberFlashFunction( "setCurrentProp" );
		m_fxSetCharacterHighlightVisibility = GetMenuFlash().GetMemberFlashFunction( "setCharacterHighlightVisibility" );
		m_fxSetCharacterHighlightPosition = GetMenuFlash().GetMemberFlashFunction( "setCharacterHighlightPosition" );
		m_fxSetPhotoAspectRatio = GetMenuFlash().GetMemberFlashFunction( "setPhotoAspectRatio" );
		m_fxSetBlackbarVisible = GetMenuFlash().GetMemberFlashFunction( "setBlackbarVisible" );
		m_updatePhotoModeState = GetMenuFlash().GetMemberFlashFunction( "updatePhotoModeState" );
		m_fxStartExitDelayTimer = GetMenuFlash().GetMemberFlashFunction( "startExitDelayTimer" );

		OnRequestCursor(true);

		UpdateThirdsLinesAspectRatio();
		UpdatePhotoAspectRatio(-1, -1);

		InitCollisionGroups();
		CacheOriginalAppearances();
		SaveCurrentCameraPosition( m_noLocationPresetPos, m_noLocationPresetRot );

		m_cameraPositionDamper = new VectorSpringDamper in this;
		m_cameraRotationDamper = new EulerAnglesSpringDamper in this;
		m_cameraPositionDamper.SetSmoothTime(m_cameraBlendSmoothTime);
		m_cameraRotationDamper.SetSmoothTime(m_cameraBlendSmoothTime);
	}

	public function FillAllSlotWithDefault()
	{
		var newSlot : SSlotedSpawnable;

		newSlot.spawnableName ="none";
		newSlot.iconPath = "";
		newSlot.id = 0;
		m_slotedCharacters.PushBack(newSlot);
		newSlot.id = 1;
		m_slotedCharacters.PushBack(newSlot);
		newSlot.id = 2;
		m_slotedCharacters.PushBack(newSlot);

		newSlot.id = 0;
		m_slotedProps.PushBack(newSlot);
		newSlot.id = 1;
		m_slotedProps.PushBack(newSlot);
		newSlot.id = 2;
		m_slotedProps.PushBack(newSlot);
		newSlot.id = 3;
		m_slotedProps.PushBack(newSlot);
		newSlot.id = 4;
		m_slotedProps.PushBack(newSlot);
		newSlot.id = 5;
		m_slotedProps.PushBack(newSlot);
		newSlot.id = 6;
		m_slotedProps.PushBack(newSlot);
		newSlot.id = 7;
		m_slotedProps.PushBack(newSlot);
		newSlot.id = 8;
		m_slotedProps.PushBack(newSlot);
		newSlot.id = 9;
		m_slotedProps.PushBack(newSlot);
	}
	
	private function CreatePhotoAspectRatio(width:int, height:int):void
	{
		var asp : SPhotoAspectRatio;
		asp.width = width;
		asp.height = height;
		m_aspectRatios.PushBack(asp);
	}
	
	private function FilterEnvDefinitionsByLocalization()
	{
		var rawEnvName : string;
		var localizedEnvName : string;
		var i : int;
		var filteredEnvDefs : array<string>;
		var alreadyUsedLocalizations : array<string>;

		for(i = 0; i < m_envDefs.Size(); i+=1)
		{
			rawEnvName = StrAfterLast(m_envDefs[i], BackslashChar());
			rawEnvName = StrReplaceAll(rawEnvName, ".env", "");
			localizedEnvName = GetLocStringByKeyExt(rawEnvName);
			if (localizedEnvName != "" && filteredEnvDefs.FindFirst(m_envDefs[i]) == -1 && alreadyUsedLocalizations.FindFirst(localizedEnvName) == -1)
			{
				filteredEnvDefs.PushBack(m_envDefs[i]);
				alreadyUsedLocalizations.PushBack(localizedEnvName);
			}
		}
		m_envDefs = filteredEnvDefs;
	}

	private function InitCollisionGroups()
	{
		m_raycastCollisionGroupsNames.PushBack( 'RigidBody' );
		m_raycastCollisionGroupsNames.PushBack( 'Static' );
		m_raycastCollisionGroupsNames.PushBack( 'Dynamic' );
		m_raycastCollisionGroupsNames.PushBack( 'Destructible' );	
		m_raycastCollisionGroupsNames.PushBack( 'Terrain' );
		m_raycastCollisionGroupsNames.PushBack( 'Phantom' );
		m_raycastCollisionGroupsNames.PushBack( 'Water' );
		m_raycastCollisionGroupsNames.PushBack( 'Boat' );
		m_raycastCollisionGroupsNames.PushBack( 'BoatDocking' );
		m_raycastCollisionGroupsNames.PushBack( 'Door' );
		m_raycastCollisionGroupsNames.PushBack( 'Platforms' );
		m_raycastCollisionGroupsNames.PushBack( 'Fence' );
		m_raycastCollisionGroupsNames.PushBack( 'Debris' );
	}

	event OnScreenShotRequested()
	{
		if( theGame.GetPlatform() != Platform_PC && theGame.GetPlatform() != Platform_PC_GDK)
			return false;
	
		theGame.TakeScreenshot();
		m_fxOnScreenshotSaved.InvokeSelf();
	}
	
	event OnMenuShown()
	{
		super.OnMenuShown();

		theGame.GetPhotomodeEffects().SetPhotomodeMenu( this );
		theGame.GetPhotomodeEffects().SetEnabled( true );
	}
	
	event OnClosingMenu()
	{
		super.OnClosingMenu();

		if ( m_UIValues[PM_Camera_Preset] >= 1)
		{
			SavePreset( m_UIValues[PM_Camera_Preset] );
		}

		ShowNPCs();
		ShowTutorial();
		theGame.GetPhotomodeEffects().SetEnabled( false );
		OnRequestCursor(false);
		RestoreOriginalAppearances();
	}
	
	private function SetPhotoAspectRatioIndexed(index:int)
	{
		var asp : SPhotoAspectRatio;
		if(index > 0 && index < m_aspectRatios.Size())
		{
			asp = m_aspectRatios[index];
			UpdatePhotoAspectRatio(asp.width, asp.height);
			theGame.GetPhotomodeEffects().SetPhotomodeCustomAspect(true, asp.width, asp.height);
		}
		else
		{
			UpdatePhotoAspectRatio(-1, -1);
			theGame.GetPhotomodeEffects().SetPhotomodeCustomAspect(false, 1, 1);
		}
	}
	
	event OnParameterChanged(paramId:int, value:float)
	{
		var prevValue : float;

		prevValue = m_UIValues[paramId];
		m_UIValues[paramId] = value;

		switch( paramId )
		{
			case PM_Camera_FOV:
				theGame.GetPhotomodeCamera().SetFov( value );
				break;
			case PM_Camera_Tilt:
				theGame.SetPhotomodeCameraCanMove(true);
				theGame.GetPhotomodeCamera().SetTilt( value );
				theGame.SetPhotomodeCameraCanMove(CanPhotomodeCameraMove());
				break;
			case PM_Exposure:
				theGame.GetPhotomodeEffects().SetExposure( value );
				break;
			case PM_Highlights:
				theGame.GetPhotomodeEffects().SetHighlights( value );
				break;
			case PM_Saturation:
				theGame.GetPhotomodeEffects().SetSaturation( value );
				break;
			case PM_Vignette:
				theGame.GetPhotomodeEffects().SetVignette( value );
				break;
			case PM_Contrast:
				theGame.GetPhotomodeEffects().SetContrast( value );
				break;
			case PM_Temperature:
				theGame.GetPhotomodeEffects().SetTemperature( BinToTemperature( value ) );
				break;
			case PM_ChromaticAberration:
				theGame.GetPhotomodeEffects().SetChromaticAberration( value );
				break;
			case PM_Grain:
				theGame.GetPhotomodeEffects().SetFilmGrain( value );
				break;
			case PM_DOF_Enable:
				theGame.GetPhotomodeEffects().SetDofEnabled( (bool)value );
				break;
			case PM_DOF_Aperture:
				theGame.GetPhotomodeEffects().SetAperture( value );
				break;
			case PM_DOF_FocusDistance:
				theGame.GetPhotomodeEffects().SetFocusDistance( value );
				break;
			case PM_DOF_Autofocus:
				theGame.GetPhotomodeEffects().SetAutoFocus( (bool)value );
				break;
			case PM_Weather:
				if(value == 0)
					theGame.GetPhotomodeEffects().RestoreWeather();
				else
					theGame.GetPhotomodeEffects().SetWeather( m_cachedWeatherNames[(int)(value - 1)] );
				break;
			case PM_TimeOfDay:
				theGame.GetPhotomodeEffects().SetTimeOfDay( value );
				theGame.GetCityLightManager().SetUpdateEnabled( true );
				theGame.GetCityLightManager().ForceUpdate();
				break;
			case PM_EnvDef:
				if(AbsF(value) <= 0.001)
					theGame.GetPhotomodeEffects().SetEnvDefNull();
				else 
					theGame.GetPhotomodeEffects().SetEnvDefUsingPath(m_envDefs[ (int)(value - 1) ]);
				break;
			case PM_UI_Thirds:
				UpdateThirdsLinesVisibility(AbsF(value - 1) < 0.01);
				break;
			case PM_Hide_NPCs:
				if(value == 1.f)
				{
					HideNPCs();
				}
				else
				{
					ShowNPCs();
				}
				break;
			case PM_NPC_Filtering:
				if(m_characterFiltering != (ECharacterFiltering)RoundF(value))
				{
					m_characterFiltering = (ECharacterFiltering)RoundF(value);
					OnCharacterFilteringChanged();
				}
				break;
			case PM_AddCharacter_Filtering:
				if(m_addCharacterFiltering != (EAddCharacterFiltering)RoundF(value))
				{
					m_addCharacterFiltering = (EAddCharacterFiltering)RoundF(value);
					OnAddCharacterFilteringChanged();
				}
				break;
			case PM_Prop_Filtering:
				if(m_propFiltering != (EPropFiltering)RoundF(value))
				{
					m_propFiltering = (EPropFiltering)RoundF(value);
					OnPropFilteringChanged();
				}
				break;
			case PM_Selected_NPC:
				if(value >= 0 && value <= m_cachedCharacterList.Size() - 1)
				{
					if(!m_selectedCharValid || m_selectedCharacter != m_cachedCharacterList[(int)value])
					{
						m_selectedCharacter = m_cachedCharacterList[(int)value];
						m_selectedCharacter_World = m_selectedCharacter;
						OnCharacterChanged();
					}
				}
				break;
			case PM_Appearance:
				ApplyAppearance(value);
				break;
			case PM_AddChar_Appearance:
				ApplyAppearance(value);
				m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_appearance = m_selectedCharacter.GetAppearance();
				m_selectedSpawnedCharacter = m_spawnedCharactersBySlot[m_currentCharacterSlotId];
				PlayCurrentAnimation();
				break;
			case PM_Char_SlotSelector:
				break;
			case PM_Char_TempSelector:
				
				break;	
			case PM_Char_FacialExpression:
				OnFacialExpressionChanged(value);
				break;
			case PM_Char_PoseCategory:
				OnPoseCategoryChanged();
				break;
			case PM_Char_Pose:
				OnPoseChanged(value);
				break;
			case PM_Char_LookAtCamera:
				OnCharacterLookCameraChanged(value);
				break;
			case PM_Char_Transform_Rotate:
				OnCharacterTransformRotateChanged(value);
				break;
			case PM_Char_Transform_LeftRight:
				OnCharacterTransformLeftRightChanged(value);
				break;
			case PM_Char_Transform_CloseFar:
				OnCharacterTransformCloseFarChanged(value);
				break;
			case PM_Char_Transform_UpDown:
				OnCharacterTransformUpDownChanged(value);
				break;	
			case PM_Prop_SlotSelector:
				break;
			case PM_Prop_TempSelector:
				
				break;
			case PM_Prop_Transform_Rotate:
				m_spawnedPropsBySlot[m_currentPropSlotId].m_relativeRotation = value;
				OnPropsTransformChanged();
				break;
			case PM_Prop_Transform_LeftRight:
				m_spawnedPropsBySlot[m_currentPropSlotId].m_relativeLocation.X = value;
				OnPropsTransformChanged();
				break;
			case PM_Prop_Transform_CloseFar:
				m_spawnedPropsBySlot[m_currentPropSlotId].m_relativeLocation.Y = value;
				OnPropsTransformChanged();
				break;
			case PM_Prop_Transform_UpDown:
				m_spawnedPropsBySlot[m_currentPropSlotId].m_relativeLocation.Z = value;
				OnPropsTransformChanged();
				break;
			case PM_Light_SlotSelector:
				break;
			case PM_Light_State:
				OnLightStateChanged();
				break;
			case PM_Light_Shadow:
				OnLightShadowChanged();
				break;
			case PM_Light_Brightness:
				OnLightParameterChanged();
				break;
			case PM_Light_Range:
				OnLightParameterChanged();
				break;
			case PM_Light_Hue:
				OnLightParameterChanged();
				break;
			case PM_Light_Saturation:
				OnLightParameterChanged();
				break;
			case PM_Light_Luminance:
				OnLightParameterChanged();
				break;
			case PM_Hide_AddCharacters:
				m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_hidden = value;
				OnCharacterHiddenChanged();
				break;
			case PM_Camera_Noclip:
				theGame.GetPhotomodeCamera().SetNoclip( value == 1 );
				break;
			case PM_PhotoAspectRatio:
				SetPhotoAspectRatioIndexed((int)value);
				break;
			case PM_Blackbars:
				m_fxSetBlackbarVisible.InvokeSelfOneArg(FlashArgBool(value == 1));
				break;
			case PM_Camera_Location:
				HandleLocationPresetChanged( prevValue, value );
				break;
			case PM_Camera_Preset:
				HandlePresetChanged( prevValue, value );
				break;
			case PM_Char_ResetButtons:
				break;
			case PM_Prop_ResetButtons:
				break;
			case PM_Light_ResetButtons:
				break;
			case PM_Char_SnapCamera:
				OnCharacterSnapToCameraChanged(value);
				break;
			case PM_Prop_SnapCamera:
				OnPropSnapToCameraChanged(value);
				break;
			case PM_Light_SnapCamera:
				break;
			case PM_Char_EnableGravity:
				OnCharacterEnableGravityChanged(value);
				break;
			case PM_Prop_EnableGravity:
				OnPropEnableGravityChanged(value);
				break;
		}
	}
	
	event OnParameterSelected(paramId:int)
	{
		switch(paramId)
		{
			case PM_AddCharacter_Filtering:
			case PM_Char_SlotSelector:
			case PM_Char_TempSelector:
			case PM_Hide_AddCharacters:
			case PM_AddChar_Appearance:
			case PM_Char_FacialExpression:
			case PM_Char_PoseCategory:
			case PM_Char_SnapCamera:
			case PM_Char_Pose:
			case PM_Char_LookAtCamera:
			case PM_Char_Transform_Rotate:
			case PM_Char_Transform_LeftRight:
			case PM_Char_Transform_CloseFar:
			case PM_Char_Transform_UpDown:
			case PM_Char_ResetButtons:
			case PM_NPC_Filtering:
			case PM_Selected_NPC:
			case PM_Camera_Noclip:
			case PM_Appearance:
				EnableCharacterHighlight(true);
				break;
			case PM_Char_EnableGravity:
				EnableCharacterHighlight(m_selectedCharValid);
				break;

			case PM_Camera_FOV:
			case PM_Hide_NPCs:
				
				break;

			case PM_Prop_SlotSelector:
			case PM_Prop_TempSelector:
			case PM_Prop_Filtering:
			case PM_Prop_SnapCamera:
			case PM_Prop_EnableGravity:
			case PM_Prop_Transform_Rotate:
			case PM_Prop_Transform_LeftRight:
			case PM_Prop_Transform_CloseFar:
			case PM_Prop_Transform_UpDown:
			case PM_Prop_ResetButtons:
			case PM_Light_SlotSelector:
			case PM_Light_SnapCamera:
			case PM_Light_State:
			case PM_Light_Shadow:
			case PM_Light_Brightness:
			case PM_Light_Range:
			case PM_Light_Hue:
			case PM_Light_Saturation:
			case PM_Light_Luminance:
			case PM_Light_ResetButtons:
			default:
				EnableCharacterHighlight(false);
				break;
		}
	}

	private function HandlePresetChanged( prevValue : float, value : float )
	{
		var presetMap : map<int, float>;
		var locationSlot : int;
		var prevLocationSlot : int;

		if ( prevValue == value )
			return;

		if ( prevValue == 0 )
			CreatePresetMapFromCurrent( m_noPresetUIValues );
		else if ( prevValue >= 1 )
			SavePreset( prevValue );

		if ( value == 0 )
		{
			locationSlot = (int) m_noPresetUIValues[PM_Camera_Location];
			RefreshLocationPresets( false, locationSlot );
			LoadPresetFromMap( m_noPresetUIValues );
		}
		else
		{
			GetPresetMapFromConfig( (int) value, presetMap );
			locationSlot = (int) presetMap[PM_Camera_Location];
			RefreshLocationPresets( false, locationSlot );
			LoadPresetFromMap( presetMap );
		}

		if (m_lastLocationSlot == 0)
			SaveCurrentCameraPosition( m_noLocationPresetPos, m_noLocationPresetRot );

		if (locationSlot == 0)
			RestoreNoneLocationPreset();
		else
			LoadCameraLocationFromString( m_locationPresets[m_locationSlotToId[locationSlot]] );

		m_lastLocationSlot = locationSlot;
	}

	private function HandleLocationPresetChanged( prevValue : float, value : float )
	{
		if ( prevValue == value )
			return;

		if ( prevValue == 0 )
			SaveCurrentCameraPosition( m_noLocationPresetPos, m_noLocationPresetRot );

		if ( value == 0 )
			RestoreNoneLocationPreset();
		else
			LoadCameraLocationFromString( m_locationPresets[m_locationSlotToId[(int)value]] );

		m_lastLocationSlot = (int) value;
	}
	
	private function EnableCharacterHighlight(value : bool)
	{
		if ( m_isCharacterSelected != value )
			m_fxSetCharacterHighlightVisibility.InvokeSelfOneArg(FlashArgBool(value));
		m_isCharacterSelected = value;
	}
	
	
	private function TemperatureToBin( tempf:float ) : float
	{
		var temp:int;
		temp = (int)tempf;
		if( temp >= 10000 )
		{
			return ( (temp - 5000) / -1000 );
		}
		else
		{
			switch( temp )
			{
				case 9000 	: 	return -4;
			
				case 8000 	: 	return -3;
			
				case 7500 	: 	return -2;
			
				case 7000 	: 	return -1;

				case 6550 	:  	return 0;

				case 5000 	:  	return 1;
	
				case 4500 	:  	return 2;

				case 4000 	:	return 3;

				case 3500 	:	return 4;

				case 3000 	: 	return 5;

				case 2500 	: 	return 6;

				case 2300 	: 	return 7;
			
				case 2000 	:	return 8;

				case 1500 	: 	return 9;

				case 1000 	: 	return 10;
			}
		}
	}

	
	private function BinToTemperature( tempf:float ) : float
	{
		var temp:int;
		temp = (int)tempf;
		if( temp <= -5 )
		{
			return ( (temp * -1000) + 5000 );
		}
		else
		{
			switch( temp )
			{
				case -5 	:	return ( (temp * -1000.0) + 5000.0 ); 

				case -4		: 	return 9000;
			
				case -3		: 	return 8000;
			
				case -2		: 	return 7500;
			
				case -1		: 	return 7000;

				case 0		:  	return 6550;

				case 1		:  	return 5000;
	
				case 2		:  	return 4500;

				case 3		:	return 4000;

				case 4 		:	return 3500;

				case 5 		: 	return 3000;

				case 6 		: 	return 2500;

				case 7 		: 	return 2300;
			
				case 8 		:	return 2000;

				case 9 		: 	return 1500;

				case 10 	: 	return 1000;
			}
		}
	}

	private function ConvertWeatherTemplateToHumanString(inp : name):string
	{
		var ret : string;
	
		switch(inp)
		{
			case 'WT_Clear': ret = "photomode_weather_clear"; break;
			case 'WT_Rain_Storm': ret = "photomode_weather_rain_storm"; break;
			case 'WT_Light_Rain': ret = "photomode_weather_light_rain"; break;
			case 'WT_Light_Clouds': ret = "photomode_weather_light_clouds"; break;
			case 'WT_Mid_Clouds': ret = "photomode_weather_mid_clouds"; break;
			case 'WT_Heavy_Clouds': ret = "photomode_weather_heavy_clouds"; break;
			case 'WT_Grey_Sky': ret = "photomode_weather_grey_sky"; break;
			case 'WT_Heavy_Clouds_Dark': ret = "photomode_weather_heavy_clouds_dark"; break;
			case 'WT_Blizzard': ret = "photomode_weather_blizzard"; break;
			case 'WT_Battle': ret = "photomode_weather_battle"; break;
			case 'WT_Battle_Forest': ret = "photomode_weather_battle_forest"; break;
			case 'WT_Mid_Clouds_Dark': ret = "photomode_weather_mid_clouds_dark"; break;
			case 'WT_Snow': ret = "photomode_weather_snow"; break;
			case 'WT_Mid_Clouds_Fog': ret = "photomode_weather_mid_clouds_fog"; break;
			case 'WT_Wild_Hunt': ret = "photomode_weather_wild_hunt"; break;
			case 'WT_Fog': ret = "photomode_weather_fog"; break;
			case 'WT_Heavy_Distant': ret = "photomode_heavy_distant"; break;
		}

		ret = GetLocStringByKeyExt(ret);

		return ret;
	}
	
	private function GetFilteredNameList(): array<name>
	{
		var ret : array<name>;

		ret.PushBack('WT_q501_Blizzard');
		ret.PushBack('WT_q501_Storm');
		ret.PushBack('WT_q501_Blizzard2');
		ret.PushBack('WT_lessun_forest');
		ret.PushBack('WT_q501_fight_ship_18_00');
		ret.PushBack('WT_q501_storm_arena');
		ret.PushBack('WT_q604_Snow');
		ret.PushBack('WT_q605_Hell');
		ret.PushBack('WT_Vesemir_burial_hour_3_30');
		ret.PushBack('q704_Cloud');
		ret.PushBack('q704_Detlaff_arena');
		ret.PushBack('q704_main');
		ret.PushBack('q704_Cloud_Rain');
		ret.PushBack('q704_Cloud_Sunny');

		return ret;
	}

	private function GetNamesOfWeather() : array < string >
	{
		var result : array< string >;
		var weatherNames : array< name >;
		var filteredNames : array< name >;
		var i : int = 0;

		
		result.PushBack(GetLocStringByKeyExt("input_device_key_name_IK_none")); 

		if(GetWeatherNames(weatherNames))
		{
			filteredNames = GetFilteredNameList();
			for(i = 0; i < weatherNames.Size(); i += 1)
			{
				if(filteredNames.Contains(weatherNames[i]))
					continue;
				result.PushBack(ConvertWeatherTemplateToHumanString(weatherNames[i]));
				m_cachedWeatherNames.PushBack(NameToString(weatherNames[i]));
			}
		}
		return result;
	}
	
	private function GetTimesStrings(out stringsArray : array<string>)
	{
		var hour, min : int;
		var b24HRFormat : bool;
		var altHour : int;
		var timeText : string;

		b24HRFormat = GetCurrentTextLocCode() != "EN";

		for(hour = 0; hour < 24; hour+=1)
		{
			for(min = 0; min < 60; min+=1) 
			{
				if(b24HRFormat)
				{
					timeText = "" + hour + ":";
					if(min < 10)
						timeText += "0";
					timeText += min;
				}
				else
				{

					altHour = hour % 12;
					if(altHour == 0)
						altHour = 12;
					timeText = "" + altHour + ":";
					if(min < 10)
						timeText += "0";
					timeText += min;
			
					if(hour < 12)
						timeText += " AM";
					else
						timeText += " PM";
				}
		
				stringsArray.PushBack(timeText);
			}
		}
	}
	
	private function GetCharacterList(out stringsArray : array<string>, out selected : int) : void
	{
		var charList : array<CActor>;
		var char : CActor;
		var i : int;
		var found : bool;
		theGame.GetPhotomodeEffects().GetEditableCharacterList(m_maxNPCDistance, charList);

		

		for(i = charList.Size() - 1; i >= 0; i-=1)
		{
			char = charList[i];
			if(m_characterFiltering == ECF_Main && !char.IsImportantCharacter())
				charList.Erase(i);
			else if(m_characterFiltering == ECF_Men && !char.IsMan())
				charList.Erase(i);
			else if(m_characterFiltering == ECF_Women && !char.IsWoman())
				charList.Erase(i);
			else if(m_characterFiltering == ECF_Animal && !char.IsAnimal())
				charList.Erase(i);
			else if(m_characterFiltering == ECF_Monster && !char.IsMonster())
				charList.Erase(i);
		}

		m_cachedCharacterList = charList;

		m_cachedUncensorableCharacterList.Clear();
		for(i = 0; i < m_cachedCharacterList.Size(); i+=1)
		{
			if (IsAppearanceCensored(m_cachedCharacterList[i].GetAppearance()))
				m_cachedUncensorableCharacterList.PushBack(m_cachedCharacterList[i]);
		}

		stringsArray.Clear();
		for(i = 0; i < charList.Size(); i+=1)
		{
			stringsArray.PushBack(charList[i].GetDisplayName());
			if(!found && charList[i] == m_selectedCharacter)
			{
				selected = i;
				found = true;
			}
		}

		if(!found)
		{
			if(charList.Size() > 0)
			{
				selected = 0;
				m_selectedCharacter = charList[0];
				m_selectedCharValid = true;
			}
			else
			{
				selected = 0;
				m_selectedCharacter = NULL;
				m_selectedCharValid = false;
			}
			m_selectedCharacter_World = m_selectedCharacter;
			m_selectedCharValid_World = m_selectedCharValid;
		}
	}
	
	private function GetAppearanceList(out stringsArray : array<string>, out selected : int, useNames : bool) : void
	{
		var currentAppearance : name;
		var i : int;
		var unfilteredList : array<name>;
		var localizedString : string;
	
		if(!m_selectedCharValid)
		{
			m_cachedAppearanceList.Clear();
			stringsArray.Clear();
			selected = 0;
			return;
		}
		currentAppearance = m_selectedCharacter.GetAppearance();
		theGame.GetPhotomodeEffects().GetCharacterAppearanceList(m_selectedCharacter, unfilteredList);

		m_cachedAppearanceList.Clear();
		if (m_cachedUncensorableCharacterList.Contains(m_selectedCharacter))
		{
			
			m_cachedAppearanceList.PushBack(currentAppearance);
		}
		else
		{
			
			for(i = 0; i < unfilteredList.Size(); i+=1)
			{
				if(IsAppearanceCensored(unfilteredList[i]))
					continue;
				m_cachedAppearanceList.PushBack(unfilteredList[i]);
			}
		}

		stringsArray.Clear();
		for(i = 0; i < m_cachedAppearanceList.Size(); i+=1)
		{
			localizedString = GetLocStringByKeyExt("pm_appearance_" + NameToString(m_cachedAppearanceList[i]));
			if (useNames && localizedString != "")
			{
				
				stringsArray.PushBack(localizedString);
			}
			else
			{
				stringsArray.PushBack(IntToString(i+1));
			}
			if(m_cachedAppearanceList[i] == currentAppearance)
			{
				selected = i;
			}
		}
	}

	private function ApplyAppearance(value : float)
	{
		if(value >= 0 && value <= m_cachedAppearanceList.Size() - 1)
		{
			if(m_selectedCharValid && m_cachedAppearanceList[(int)value] != m_selectedCharacter.GetAppearance())
			{
				m_selectedCharacter.SetVisibility(false);
				m_selectedCharacter.ApplyAppearance(NameToString(m_cachedAppearanceList[(int)value]));
				WarmupClothsSimulation();
				m_queuedSelectedCharacterVisibility = true;
				m_queuedFakeTickN = 1;
			}
		}
	}

	private function GetPoseList(out stringsArray : array<string>, out selected : int) : void
	{
		var i : int;
		for (i = 0; i < m_selectedCharacterPoseNames.Size(); i += 1)
		{
			
			stringsArray.PushBack(IntToString(i+1)); 
			if (m_selectedCharacterPoses[i] == m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_pose)
			{
				selected = i;
			}
		}
	}

	private function GetFacialExressionList(out stringsArray : array<string>, out selected : int) : void
	{
		var i : int;
		for (i = 0; i < m_selectedCharacterMimicNames.Size(); i += 1)
		{
			
			stringsArray.PushBack(IntToString(i+1)); 
			if (m_selectedCharacterMimics[i] == m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_mimic)
			{
				selected = i;
			}
		}
	}

	private function GetPoseCategoryList(out stringsArray : array<string>, out selected : int) : void
	{
		
	}

	private function OnSelectedCharacterChanged(out tabData : CScriptedFlashArray)
	{
		var stringsArray : array<string>;
		var extraParams : SPhotomodeRendererExtraParams;
		var selected : int;

		stringsArray.Clear();
		GetAppearanceList(stringsArray, selected, false);
		if(stringsArray.Size() == 0) stringsArray.PushBack(GetLocStringByKeyExt("input_device_key_name_IK_none"));
		extraParams.m_disabled = m_cachedAppearanceList.Size() < 2;
		extraParams.m_callbackFunctionName = "OnRequestFakeTick";
		extraParams.m_callbackDelay = 0.01;
		tabData.PushBackFlashObject(CreateStringSelector(PM_Appearance, "photomode_params_selected_appearance" , stringsArray, selected, extraParams, true));
	}

	private function UpdateAddCharacterTab()
	{
		var elemObj : CScriptedFlashObject;	
		var extraParams : SPhotomodeRendererExtraParams;

		elemObj = CreateCharacterSlotSelector(PM_Char_SlotSelector, "photomode_params_character_selector", 0 ,extraParams, true);
		QueueOverrideElement( elemObj, PM_Char_SlotSelector );
	}

	private function UpdatePropTab()
	{
		var elemObj : CScriptedFlashObject;	
		var extraParams : SPhotomodeRendererExtraParams;

		elemObj = CreatePropSlotSelector(PM_Prop_SlotSelector, "photomode_params_prop_selector", 0 ,extraParams, true);
		QueueOverrideElement( elemObj, PM_Prop_SlotSelector );
	}

	private function CreateCameraTab(rootArray : CScriptedFlashArray)
	{
		var tabData : CScriptedFlashArray;
		var stringsArray : array<string>;
	
		
		tabData = m_flashValueStorage.CreateTempFlashArray();

		tabData.PushBackFlashObject(CreateBasicSlider(PM_Camera_FOV, "photomode_params_fov", 15.0, 90.0, 1.0, 60.0)); 	
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Camera_Tilt, "photomode_params_tilt", -180.0, 180.0, 1.0, 0.0));  

		stringsArray.Clear();
		stringsArray.PushBack("panel_mainmenu_option_value_off");
		stringsArray.PushBack("panel_mainmenu_option_value_on");
		tabData.PushBackFlashObject(CreateStringSlider(PM_Camera_Noclip, "photomode_params_noclip", stringsArray, 0));

		rootArray.PushBackFlashObject(CreateTab("photomode_tabs_camera", tabData, "camera")); 
	}
	
	private function CreateCharactersTab(rootArray : CScriptedFlashArray)
	{
		var tabData : CScriptedFlashArray;
		var extraParams : SPhotomodeRendererExtraParams;

		var stringsArray : array<string>;
		var selected : int;
		var charList : array<CActor>;
	
		
		tabData = m_flashValueStorage.CreateTempFlashArray();

		stringsArray.Clear();
		stringsArray.PushBack("panel_mainmenu_option_value_off");
		stringsArray.PushBack("panel_mainmenu_option_value_on");

		tabData.PushBackFlashObject(CreateStringSlider(PM_Hide_NPCs, "photomode_params_hide_npcs", stringsArray, 0));

		theGame.GetPhotomodeEffects().GetEditableCharacterList(m_maxNPCDistance, charList);

		stringsArray.Clear();
		stringsArray.PushBack("photomode_params_npc_filter_all");
		stringsArray.PushBack("photomode_params_npc_filter_main");
		stringsArray.PushBack("photomode_params_npc_filter_men");
		stringsArray.PushBack("photomode_params_npc_filter_women");
		stringsArray.PushBack("photomode_params_npc_filter_animal");
		stringsArray.PushBack("photomode_params_npc_filter_monster");
		tabData.PushBackFlashObject(CreateStringSlider(PM_NPC_Filtering, "photomode_params_npc_filter", stringsArray, 0));

		stringsArray.Clear();
		GetCharacterList(stringsArray, selected);
		if(stringsArray.Size() == 0) stringsArray.PushBack(GetLocStringByKeyExt("input_device_key_name_IK_none"));
		extraParams.m_disabled = m_cachedCharacterList.Size() < 2;
		tabData.PushBackFlashObject(CreateStringSelector(PM_Selected_NPC, "photomode_params_selected_npc", stringsArray, selected, extraParams, true));

		OnSelectedCharacterChanged(tabData);

		rootArray.PushBackFlashObject(CreateTab("photomode_tabs_character", tabData, "character")); 
	}

	private function CreateAddCharactersTab(rootArray : CScriptedFlashArray)
	{
		var tabData : CScriptedFlashArray;
		var extraParams : SPhotomodeRendererExtraParams;

		var stringsArray : array<string>;
		var selected : int;

		
		tabData = m_flashValueStorage.CreateTempFlashArray();

		tabData.PushBackFlashObject(CreateCharacterSlotSelector(PM_Char_SlotSelector, "photomode_params_character_selector", 0 ,extraParams, true));

		
		extraParams.m_disabled = false;
		stringsArray.Clear();
		stringsArray.PushBack("photomode_params_char_snapcamera_off"); 
		stringsArray.PushBack("photomode_params_char_snapcamera_on");  
		tabData.PushBackFlashObject(CreateStringSlider(PM_Char_EnableGravity, "photomode_params_char_enable_gravity", stringsArray, (int)(!m_selectedSpawnedCharacter.m_disableGravity), extraParams));

		extraParams.m_disabled = !m_selectedCharValid;
		stringsArray.Clear();
		stringsArray.PushBack("panel_mainmenu_option_value_off");
		stringsArray.PushBack("panel_mainmenu_option_value_on");
		tabData.PushBackFlashObject(CreateStringSlider(PM_Hide_AddCharacters, "photomode_params_hide_addcharacters", stringsArray, (int)m_selectedSpawnedCharacter.m_hidden, extraParams));

		extraParams.m_callbackFunctionName = "OnRequestFakeTick";
		extraParams.m_callbackDelay = 0.01;

		stringsArray.Clear();
		GetAppearanceList(stringsArray, selected, true);
		if(stringsArray.Size() == 0) stringsArray.PushBack(GetLocStringByKeyExt("input_device_key_name_IK_none"));
		extraParams.m_disabled = stringsArray.Size() < 2;
		tabData.PushBackFlashObject(CreateStringSelector(PM_AddChar_Appearance, "photomode_params_addchar_appearance", stringsArray, selected, extraParams, true));

		stringsArray.Clear();
		GetFacialExressionList(stringsArray, selected);
		if(stringsArray.Size() == 0) stringsArray.PushBack(GetLocStringByKeyExt("input_device_key_name_IK_none"));
		extraParams.m_disabled = stringsArray.Size() < 2;
		tabData.PushBackFlashObject(CreateStringSelector(PM_Char_FacialExpression, "photomode_params_selected_facialexpression", stringsArray, selected, extraParams, true));

		
		
		
		
		
		

		stringsArray.Clear();
		GetPoseList(stringsArray, selected);
		if(stringsArray.Size() == 0) stringsArray.PushBack(GetLocStringByKeyExt("input_device_key_name_IK_none"));
		extraParams.m_disabled = stringsArray.Size() < 2;
		tabData.PushBackFlashObject(CreateStringSelector(PM_Char_Pose, "photomode_params_selected_pose", stringsArray, selected, extraParams, true));

		extraParams.m_callbackFunctionName = "";
		extraParams.m_callbackDelay = 0;
		extraParams.m_disabled = !m_selectedCharValid;

		stringsArray.Clear();
		stringsArray.PushBack("photomode_params_char_lookcamera_off"); 
		stringsArray.PushBack("photomode_params_char_lookcamera_on");  
		tabData.PushBackFlashObject(CreateStringSlider(PM_Char_LookAtCamera, "photomode_params_char_lookcamera", stringsArray, (int)m_selectedSpawnedCharacter.m_lookAtCamera, extraParams));

		stringsArray.Clear();
		stringsArray.PushBack("photomode_params_char_snapcamera_off"); 
		stringsArray.PushBack("photomode_params_char_snapcamera_on");  
		tabData.PushBackFlashObject(CreateStringSlider(PM_Char_SnapCamera, "photomode_params_char_snapcamera", stringsArray, (int)m_selectedSpawnedCharacter.m_snapToCamera, extraParams)); 

		extraParams.m_disabled = !m_selectedCharValid;
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Char_Transform_Rotate, "photomode_params_char_rotate", -360.0, 360.0, 5.0, m_selectedSpawnedCharacter.m_relativeRotation, extraParams));
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Char_Transform_LeftRight, "photomode_params_char_leftright", -10.0, 10.0, 0.05, m_selectedSpawnedCharacter.m_relativeLocation.X, extraParams));
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Char_Transform_CloseFar, "photomode_params_char_closefar",-10.0, 10.0, 0.05, m_selectedSpawnedCharacter.m_relativeLocation.Y, extraParams));
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Char_Transform_UpDown, "photomode_params_char_updown", -10.0, 10.0, 0.05, m_selectedSpawnedCharacter.m_relativeLocation.Z, extraParams));

		extraParams.m_callbackFunctionName = "OnResetAddCharacterTransformToOrigin";
		extraParams.m_callbackFunctionNameSecondary = "OnResetAddCharacterTransformToCamera";
	
		tabData.PushBackFlashObject(CreateButtonRenderer(PM_Char_ResetButtons,"photomode_char_reset_transform_origin","photomode_char_reset_transform_camera", 0 ,extraParams, true));

		rootArray.PushBackFlashObject(CreateTab("photomode_tabs_addcharacter", tabData, "addcharacter"));

		PostSelectCharacterBySlot();
	}
	
	private function CreatePropsTab(rootArray : CScriptedFlashArray)
	{
		var tabData : CScriptedFlashArray;
		var extraParams : SPhotomodeRendererExtraParams;
		var stringsArray : array<string>;

		
		tabData = m_flashValueStorage.CreateTempFlashArray();	

		
		tabData.PushBackFlashObject(CreatePropSlotSelector(PM_Prop_SlotSelector, "photomode_params_prop_selector", 0 ,extraParams, true));

		
		extraParams.m_disabled = false;
		stringsArray.Clear();
		stringsArray.PushBack("photomode_params_prop_snapcamera_off"); 
		stringsArray.PushBack("photomode_params_prop_snapcamera_on");  
		tabData.PushBackFlashObject(CreateStringSlider(PM_Prop_EnableGravity, "photomode_params_char_enable_gravity", stringsArray, (int)(!m_selectedSpawnedProp.m_disableGravity), extraParams));

		extraParams.m_disabled = !m_selectedPropValid;
		stringsArray.Clear();
		stringsArray.PushBack("photomode_params_prop_snapcamera_off"); 
		stringsArray.PushBack("photomode_params_prop_snapcamera_on");  
		tabData.PushBackFlashObject(CreateStringSlider(PM_Prop_SnapCamera, "photomode_params_prop_snapcamera", stringsArray, (int)m_selectedSpawnedProp.m_snapToCamera, extraParams)); 

		tabData.PushBackFlashObject(CreateBasicSlider(PM_Prop_Transform_Rotate, "photomode_params_prop_rotate", -360.0, 360.0, 5.0, m_selectedSpawnedProp.m_relativeRotation, extraParams));

		extraParams.m_disabled = !m_selectedPropValid || m_selectedSpawnedProp.m_snapToCamera;
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Prop_Transform_LeftRight, "photomode_params_prop_leftright", -10.0, 10.0, 0.05, m_selectedSpawnedProp.m_relativeLocation.X, extraParams));
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Prop_Transform_CloseFar, "photomode_params_prop_closefar",-10.0, 10.0, 0.05, m_selectedSpawnedProp.m_relativeLocation.Y, extraParams));
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Prop_Transform_UpDown, "photomode_params_prop_updown", -10.0, 10.0, 0.05, m_selectedSpawnedProp.m_relativeLocation.Z, extraParams));

		extraParams.m_callbackFunctionName = "OnResetPropTransformToOrigin";
		extraParams.m_callbackFunctionNameSecondary = "OnResetPropTransformToCamera";

		tabData.PushBackFlashObject(CreateButtonRenderer(PM_Prop_ResetButtons,"photomode_props_reset_transform_origin","photomode_props_reset_transform_camera", 0 ,extraParams, true));

		rootArray.PushBackFlashObject(CreateTab("photomode_tabs_prop", tabData, "prop"));
		
		PostSelectPropBySlot();
	}

	private function CreateLightsTab(rootArray : CScriptedFlashArray)
	{
		var tabData : CScriptedFlashArray;
		var extraParams : SPhotomodeRendererExtraParams;
		var stringsArray : array<string>;

		
		tabData = m_flashValueStorage.CreateTempFlashArray();

		tabData.PushBackFlashObject(CreateLightSlotSelector(PM_Light_SlotSelector, "photomode_params_light_selector", 0 ,extraParams, true));

		stringsArray.Clear();
		stringsArray.PushBack("photomode_params_light_snapcamera_off"); 
		stringsArray.PushBack("photomode_params_light_snapcamera_on");  
		tabData.PushBackFlashObject(CreateStringSlider(PM_Light_SnapCamera, "photomode_params_light_snapcamera", stringsArray, 0)); 

		stringsArray.Clear();
		stringsArray.PushBack("photomode_params_light_state_off"); 
		stringsArray.PushBack("photomode_params_light_state_on");  
		tabData.PushBackFlashObject(CreateStringSlider(PM_Light_State, "photomode_params_light_state", stringsArray, 0)); 

		stringsArray.Clear();
		stringsArray.PushBack("photomode_params_light_shadow_off"); 
		stringsArray.PushBack("photomode_params_light_shadow_on");  
		tabData.PushBackFlashObject(CreateStringSlider(PM_Light_Shadow, "photomode_params_light_shadow", stringsArray, 0)); 

		tabData.PushBackFlashObject(CreateBasicSlider(PM_Light_Brightness, "photomode_params_light_brightness", 0.0, 100.0, 1.0, 50.0)); 
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Light_Range, "photomode_params_light_range", 0.0, 100.0, 1.0, 100.0)); 

		tabData.PushBackFlashObject(CreateColorSlider(PM_Light_Hue, "photomode_params_light_hue", 0.0, 360.0, 5.0, "hue", 180.0)); 
		tabData.PushBackFlashObject(CreateColorSlider(PM_Light_Saturation, "photomode_params_light_saturation",0.0, 100.0, 1.0, "saturation", 50.0)); 
		tabData.PushBackFlashObject(CreateColorSlider(PM_Light_Luminance, "photomode_params_light_luminance", 0.0, 100.0, 1.0, "luminance", 50.0)); 
	
		

		rootArray.PushBackFlashObject(CreateTab("photomode_tabs_light", tabData, "light")); 
	}
	
	private function CreateTimeAndWeatherTab(rootArray : CScriptedFlashArray)
	{
		var tabData : CScriptedFlashArray;
		var extraParams : SPhotomodeRendererExtraParams;

		var stringsArray : array<string>;
		var hour, min : int;
		var currentTime : int;
		var gameTime : GameTime = theGame.GetGameTime();
		var weatherNames : array<string> = GetNamesOfWeather();
		var rawEnvName : string;
		var localizedEnvName : string;
		var i : int;
	
		
		tabData = m_flashValueStorage.CreateTempFlashArray();
	
		
		stringsArray.Clear();
		GetTimesStrings(stringsArray);

		hour = GameTimeHours( gameTime );
		min = GameTimeMinutes( gameTime );
		currentTime = hour * 60 + min;
		tabData.PushBackFlashObject(CreateStringSlider(PM_TimeOfDay, "photomode_params_timeofday", stringsArray, currentTime, extraParams, true)); 

		
		stringsArray.Clear();
		for(i = 0; i < weatherNames.Size(); i+=1)
		{
			stringsArray.PushBack(weatherNames[i]);
		}

		tabData.PushBackFlashObject(CreateStringSelector(PM_Weather, "photomode_params_weather", stringsArray, 0, extraParams, true));

		
		stringsArray.Clear();
		for(i = -1; i < m_envDefs.Size(); i+=1)
		{
			if(i==-1)
			{
				stringsArray.PushBack(GetLocStringByKeyExt("input_device_key_name_IK_none")); 
			}
			else
			{
				rawEnvName = StrAfterLast(m_envDefs[i], BackslashChar());
				rawEnvName = StrReplaceAll(rawEnvName, ".env", "");
				localizedEnvName = GetLocStringByKeyExt(rawEnvName);
				stringsArray.PushBack(localizedEnvName != "" ? localizedEnvName : rawEnvName);
			}
		}

		tabData.PushBackFlashObject(CreateStringSelector(PM_EnvDef, "photomode_params_env_def", stringsArray, 0, extraParams, true));

		rootArray.PushBackFlashObject(CreateTab("photomode_tabs_time_weather", tabData, "time_weather")); 
	}
	
	private function CreateDofTab(rootArray : CScriptedFlashArray)
	{
		var tabData : CScriptedFlashArray;
		var extraParams : SPhotomodeRendererExtraParams;

		var stringsArray : array<string>;
		
		tabData = m_flashValueStorage.CreateTempFlashArray();

		stringsArray.Clear();
		stringsArray.PushBack("panel_mainmenu_option_value_off"); 
		stringsArray.PushBack("panel_mainmenu_option_value_on");  
		tabData.PushBackFlashObject(CreateStringSlider(PM_DOF_Enable, "option_allow_dof", stringsArray)); 

		tabData.PushBackFlashObject(CreateStringSlider(PM_DOF_Autofocus, "photomode_params_autofocus", stringsArray)); 

		stringsArray.Clear();
		stringsArray.PushBack("f/1.0");
		stringsArray.PushBack("f/1.4");
		stringsArray.PushBack("f/2.0");
		stringsArray.PushBack("f/2.8");
		stringsArray.PushBack("f/4.0");
		stringsArray.PushBack("f/5.6");
		stringsArray.PushBack("f/8.0");
		stringsArray.PushBack("f/11.0");
		stringsArray.PushBack("f/16.0");
		stringsArray.PushBack("f/22.0");
		stringsArray.PushBack("f/32.0");
		tabData.PushBackFlashObject(CreateStringSlider(PM_DOF_Aperture, "photomode_params_aperture", stringsArray, 4, extraParams, true)); 

		tabData.PushBackFlashObject(CreateBasicSlider(PM_DOF_FocusDistance, "photomode_params_focus_distance", 0.0, 150.0, 0.1, theGame.GetPhotomodeEffects().GetFocusDistance())); 

		rootArray.PushBackFlashObject(CreateTab("option_allow_dof", tabData, "dof")); 
	}
	
	private function CreateEffectTab(rootArray : CScriptedFlashArray)
	{
		var tabData : CScriptedFlashArray;
		
		tabData = m_flashValueStorage.CreateTempFlashArray();

		tabData.PushBackFlashObject(CreateBasicSlider(PM_Exposure, "photomode_params_exposure", -4.0, 4.0, 0.1, theGame.GetPhotomodeEffects().GetExposure())); 
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Contrast, "photomode_params_contrast", 0.8, 1.2, 0.01, theGame.GetPhotomodeEffects().GetContrast())); 
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Highlights, "photomode_params_highlights", 0.3, 3.0, 0.05, theGame.GetPhotomodeEffects().GetHighlights())); 
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Temperature, "photomode_params_temperature", -10.0, 10.0, 1.0, TemperatureToBin( theGame.GetPhotomodeEffects().GetTemperature() )) ); 
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Saturation, "photomode_params_saturation", 0.0, 2.0, 0.05, theGame.GetPhotomodeEffects().GetSaturation())); 
		tabData.PushBackFlashObject(CreateBasicSlider(PM_ChromaticAberration, "photomode_params_chromatic_aberration", 0.0, 20.0, 0.2, theGame.GetPhotomodeEffects().GetChromaticAberration())); 
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Grain, "photomode_params_grain", 0.0, 0.1, 0.001, 0.0)); 

		rootArray.PushBackFlashObject(CreateTab("photomode_tabs_effect", tabData, "effect")); 
	}
	
	private function CreateOverlayTab(rootArray : CScriptedFlashArray)
	{
		var tabData : CScriptedFlashArray;
		var stringsArray : array<string>;
		
		tabData = m_flashValueStorage.CreateTempFlashArray();

		
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Vignette, "photomode_params_vignette", -0.7, 0.7, 0.01, 0.0)); 

		
		stringsArray.Clear();
		stringsArray.PushBack("panel_mainmenu_option_value_off"); 
		stringsArray.PushBack("panel_mainmenu_option_value_on");  
		tabData.PushBackFlashObject(CreateStringSlider(PM_UI_Thirds, "photomode_params_thirds_lines", stringsArray, 1)); 

		
		stringsArray.Clear();
		CreatePhotoAspectRatio(0,0);
		stringsArray.PushBack("photomode_aspect_ratio_fullscreen");
		CreatePhotoAspectRatio(16,9);
		stringsArray.PushBack("photomode_aspect_ratio_16_9");
		CreatePhotoAspectRatio(235,100);
		stringsArray.PushBack("photomode_aspect_ratio_235_1");
		CreatePhotoAspectRatio(4,3);
		stringsArray.PushBack("photomode_aspect_ratio_4_3");
		CreatePhotoAspectRatio(9,16);
		stringsArray.PushBack("photomode_aspect_ratio_9_16");
		CreatePhotoAspectRatio(4,5);
		stringsArray.PushBack("photomode_aspect_ratio_4_5");
		CreatePhotoAspectRatio(2,3);
		stringsArray.PushBack("photomode_aspect_ratio_2_3");
		tabData.PushBackFlashObject(CreateStringSlider(PM_PhotoAspectRatio, "photomode_params_aspect_ratio", stringsArray, 0)); 

		
		stringsArray.Clear();
		stringsArray.PushBack("panel_mainmenu_option_value_off"); 
		stringsArray.PushBack("panel_mainmenu_option_value_on");  
		tabData.PushBackFlashObject(CreateStringSlider(PM_Blackbars, "photomode_params_black_bars", stringsArray, 0)); 

		rootArray.PushBackFlashObject(CreateTab("photomode_tabs_overlay", tabData, "overlay")); 
	}
	
	private function CreateLoadSaveTab(rootArray : CScriptedFlashArray)
	{
		var tabData : CScriptedFlashArray;
		var stringsArray : array<string>;
		var extraParams : SPhotomodeRendererExtraParams;

		stringsArray.PushBack("input_device_key_name_IK_none");
		stringsArray.PushBack("photomode_params_slot_0");
		stringsArray.PushBack("photomode_params_slot_1");
		stringsArray.PushBack("photomode_params_slot_2");
		stringsArray.PushBack("photomode_params_slot_3");
		stringsArray.PushBack("photomode_params_slot_4");

		tabData = m_flashValueStorage.CreateTempFlashArray();
		tabData.PushBackFlashObject(CreateStringSelector(PM_Camera_Preset, "photomode_params_camera_presets", stringsArray, 0, extraParams));

		stringsArray.Clear();
		stringsArray.PushBack(GetLocStringByKeyExt("input_device_key_name_IK_none"));
		tabData.PushBackFlashObject(CreateStringSelector(PM_Camera_Location, "photomode_params_camera_location", stringsArray, 0, extraParams, true));
		tabData.PushBackFlashObject(CreateSaver(PM_Camera_Location, "photomode_params_camera_location_saver", ""));

		rootArray.PushBackFlashObject(CreateTab("photomode_tabs_load_save", tabData, "load_save"));
	}

	private function FillTabbedMenu()
	{
		var rootObj : CScriptedFlashObject;
		var rootArray : CScriptedFlashArray;	

		var tabData : CScriptedFlashArray;

		rootObj = m_flashValueStorage.CreateTempFlashObject();
		rootArray = m_flashValueStorage.CreateTempFlashArray();

		CreateCameraTab(rootArray);
		CreateTimeAndWeatherTab(rootArray);
		CreateCharactersTab(rootArray);
		CreateAddCharactersTab(rootArray);
		CreatePropsTab(rootArray);
		
		CreateDofTab(rootArray);
		CreateEffectTab(rootArray);
		CreateOverlayTab(rootArray);
		CreateLoadSaveTab(rootArray);

		rootObj.SetMemberFlashArray("tabs", rootArray);
		m_flashValueStorage.SetFlashObject( "photomode.tabs", rootObj );
	}

	private function FillCharFilterSelector()
	{
		var flashArray : CScriptedFlashArray;
		var stringsArray : array<string>;

		flashArray = m_flashValueStorage.CreateTempFlashArray();

		stringsArray.PushBack("photomode_char_filter_main");
		stringsArray.PushBack("photomode_char_filter_side");
		stringsArray.PushBack("photomode_char_filter_witchers");

		flashArray.PushBackFlashObject(CreateStringSlider(PM_NPC_Filtering, "photomode_char_filter", stringsArray, 0));

		m_flashValueStorage.SetFlashArray( "photomode.character.filter", flashArray );
	}

	private function FillPropFilterSelector()
	{
		var flashArray : CScriptedFlashArray;
		var stringsArray : array<string>;

		flashArray = m_flashValueStorage.CreateTempFlashArray();

		stringsArray.PushBack("photomode_props_filter_furniture");
		stringsArray.PushBack("photomode_props_filter_headwear");
		stringsArray.PushBack("photomode_props_filter_holdable");
		stringsArray.PushBack("photomode_props_filter_lightsources");
		stringsArray.PushBack("photomode_props_filter_occult");
		stringsArray.PushBack("photomode_props_filter_paper");
		stringsArray.PushBack("photomode_props_filter_weapon");

		flashArray.PushBackFlashObject(CreateStringSlider(PM_Prop_Filtering, "photomode_props_filter", stringsArray, 0));

		m_flashValueStorage.SetFlashArray( "photomode.props.filter", flashArray );
	}

	private function FillPlacableCharacterList()
	{
		var characterSlotsList  : CScriptedFlashArray;
		var i 					: int;
		var characterSlot       : CScriptedFlashObject;
		var newCharacter : SSpawnableCharacter;
		var newSlot : SSlotedSpawnable;
		var newPose : SSpawnableCharacterPose;

		characterSlotsList = m_flashValueStorage.CreateTempFlashArray();

		newSlot.spawnableName ="";
		newSlot.iconPath = "";
		newSlot.id = 0;
		m_slotedCharacters.PushBack(newSlot);
		newSlot.id = 1;
		m_slotedCharacters.PushBack(newSlot);
		newSlot.id = 2;
		m_slotedCharacters.PushBack(newSlot);

		m_spawnableCharacterSettings = LoadCSV("game\photomode_characters.csv");
		for (i = 0; i < m_spawnableCharacterSettings.GetNumRows(); i += 1)
		{
			newCharacter.m_displayName = m_spawnableCharacterSettings.GetValueAt(0, i);
			newCharacter.m_displayNameLocKey = m_spawnableCharacterSettings.GetValueAt(1, i);
			newCharacter.m_entityName = m_spawnableCharacterSettings.GetValueAt(2, i);
			newCharacter.m_icon = m_spawnableCharacterSettings.GetValueAt(3, i);
			newCharacter.m_poseset = m_spawnableCharacterSettings.GetValueAt(5, i);
			newCharacter.m_mimicset = m_spawnableCharacterSettings.GetValueAt(6, i);
			m_spawnableCharacterList.PushBack(newCharacter);
			m_spawnableCharacterPosesets[newCharacter.m_entityName] = newCharacter.m_poseset;
			m_spawnableCharacterMimicsets[newCharacter.m_entityName] = newCharacter.m_mimicset;
		}
	
		m_spawnableCharacterPosesSettings = LoadCSV("game\photomode_poses.csv");
		for (i = 0; i < m_spawnableCharacterPosesSettings.GetNumRows(); i += 1)
		{
			newPose.m_poseset = m_spawnableCharacterPosesSettings.GetValueAt(0, i);
			newPose.m_pose = m_spawnableCharacterPosesSettings.GetValueAtAsName(1, i);
			newPose.m_startTime = StringToFloat(m_spawnableCharacterPosesSettings.GetValueAt(2, i), 0);
			newPose.m_poseName = m_spawnableCharacterPosesSettings.GetValueAtAsName(3, i);
			m_spawnableCharactersPoses.PushBack(newPose);
		}

		m_spawnableCharacterMimicsSettings = LoadCSV("game\photomode_mimics.csv");
		for (i = 0; i < m_spawnableCharacterMimicsSettings.GetNumRows(); i += 1)
		{
			newPose.m_poseset = m_spawnableCharacterMimicsSettings.GetValueAt(0, i);
			newPose.m_pose = m_spawnableCharacterMimicsSettings.GetValueAtAsName(1, i);
			newPose.m_poseName = m_spawnableCharacterMimicsSettings.GetValueAtAsName(2, i);
			m_spawnableCharactersMimics.PushBack(newPose);
		}

		characterSlot = m_flashValueStorage.CreateTempFlashObject("red.game.witcher3.menus.common.ItemDataStub");

		characterSlot.SetMemberFlashInt( "gridPosition", 0 );
		characterSlot.SetMemberFlashInt( "id", 0 );
		characterSlot.SetMemberFlashString("iconPath", "icons/characters/none_icon.png" );
		characterSlot.SetMemberFlashString("displayName", "[[photomode_charlist_selectedchar_none]]" );
		characterSlot.SetMemberFlashString("entityName", "none" );
		
		
	
		characterSlot.SetMemberFlashString('color', SC_None);
		characterSlotsList.PushBackFlashObject(characterSlot);


		for (i = 0; i < m_spawnableCharacterList.Size(); i += 1)
		{
			characterSlot = m_flashValueStorage.CreateTempFlashObject("red.game.witcher3.menus.common.ItemDataStub");

			characterSlot.SetMemberFlashInt( "gridPosition", i + 1 );
			characterSlot.SetMemberFlashInt( "id",i + 1);
			characterSlot.SetMemberFlashString("iconPath", m_spawnableCharacterList[i].m_icon );
			characterSlot.SetMemberFlashString("displayName", GetLocStringByKeyExt(m_spawnableCharacterList[i].m_displayNameLocKey) );
			characterSlot.SetMemberFlashString("entityName", m_spawnableCharacterList[i].m_entityName );
			
			
	
			characterSlot.SetMemberFlashString('color', SC_None);
	
			characterSlotsList.PushBackFlashObject(characterSlot);
		}

		m_flashValueStorage.SetFlashArray( "photomode.character.list.update", characterSlotsList);
	}

	public function FillPlacablePropList()
	{
		var propSlotsList   : CScriptedFlashArray;
		var propSlot        : CScriptedFlashObject;
		var i               : int;
		var newProp 		: SSpawnableProp;

		propSlotsList = m_flashValueStorage.CreateTempFlashArray();

		m_spawnablePropSettings = LoadCSV("game\photomode_props.csv");
		for (i = 0; i < m_spawnablePropSettings.GetNumRows(); i += 1)
		{
			newProp.m_displayName = m_spawnablePropSettings.GetValueAt(0, i);
			newProp.m_displayNameLocKey = m_spawnablePropSettings.GetValueAt(1, i);
			newProp.m_entityName = m_spawnablePropSettings.GetValueAt(2, i);
			newProp.m_icon = m_spawnablePropSettings.GetValueAt(3, i);
			
			m_spawnablePropList.PushBack(newProp);
		}

		propSlot = m_flashValueStorage.CreateTempFlashObject("red.game.witcher3.menus.common.ItemDataStub");

		
		propSlot.SetMemberFlashInt( "gridPosition", 0 );
		propSlot.SetMemberFlashInt( "id", 0 );
		propSlot.SetMemberFlashString("iconPath", "icons/characters/none_icon.png" );
		propSlot.SetMemberFlashString("displayName", "[[photomode_proplist_selectedprop_none]]" );
		propSlot.SetMemberFlashString("entityName", "none" );
		
	
		
		propSlotsList.PushBackFlashObject(propSlot);

		for (i = 0; i < m_spawnablePropList.Size(); i += 1)
		{
			propSlot = m_flashValueStorage.CreateTempFlashObject("red.game.witcher3.menus.common.ItemDataStub");
			propSlot.SetMemberFlashInt( "gridPosition", i + 1 );
			propSlot.SetMemberFlashInt( "id", i + 1 );
			propSlot.SetMemberFlashString("iconPath", m_spawnablePropList[i].m_icon );
			propSlot.SetMemberFlashString("displayName", GetLocStringByKeyExt(m_spawnablePropList[i].m_displayNameLocKey) );
			propSlot.SetMemberFlashString("entityName", m_spawnablePropList[i].m_entityName );
			

			

			propSlotsList.PushBackFlashObject(propSlot);
		}

		m_flashValueStorage.SetFlashArray( "photomode.props.list.update", propSlotsList);
	}

	public function FillPlacableLightList()
	{

	}

	private function CreateSaver(id:int, label:string, date:string) : CScriptedFlashObject
	{
		var sliderObj : CScriptedFlashObject;
		var sliderArgsObj : CScriptedFlashObject;

      	sliderObj = m_flashValueStorage.CreateTempFlashObject();
		sliderArgsObj = m_flashValueStorage.CreateTempFlashObject();

		sliderArgsObj.SetMemberFlashInt("id", id);
		sliderArgsObj.SetMemberFlashString("label", GetLocStringByKeyExt(label));
		sliderArgsObj.SetMemberFlashString("date", date);

		sliderObj.SetMemberFlashObject("args", sliderArgsObj);
		sliderObj.SetMemberFlashString("rendererType", "saver");

		return sliderObj;
	}
	
	private function CreateBasicSlider(id:int, label:string, minVal:float, maxVal:float, step:float, optional defVal:float, optional extraParams:SPhotomodeRendererExtraParams, optional dontLocalizeValue:bool) : CScriptedFlashObject
	{
		var sliderObj : CScriptedFlashObject;
		var sliderArgsArray : CScriptedFlashArray;

		

      	sliderObj = m_flashValueStorage.CreateTempFlashObject();
		sliderArgsArray = m_flashValueStorage.CreateTempFlashArray();

		sliderArgsArray.PushBackFlashInt(id);
		sliderArgsArray.PushBackFlashString(dontLocalizeValue ? label : GetLocStringByKeyExt(label));
		sliderArgsArray.PushBackFlashNumber(minVal);
		sliderArgsArray.PushBackFlashNumber(maxVal);
		sliderArgsArray.PushBackFlashNumber(step);
		sliderArgsArray.PushBackFlashNumber(defVal);

		if(StrLen(extraParams.m_callbackFunctionName) > 0)
		{
			sliderObj.SetMemberFlashString("callback", extraParams.m_callbackFunctionName);
			sliderObj.SetMemberFlashString("callbackDelay", extraParams.m_callbackDelay);
		}
		if(extraParams.m_disabled)
			sliderObj.SetMemberFlashBool("disabled", true);

		sliderObj.SetMemberFlashArray("args", sliderArgsArray);
		sliderObj.SetMemberFlashString("rendererType", "slider");

		m_defaultUIValues[id] = defVal;

		return sliderObj;
	}

	private function CreateColorSlider(id:int, label:string, minVal:float, maxVal:float, step:float, sliderType: string, optional defVal:float, optional extraParams:SPhotomodeRendererExtraParams) : CScriptedFlashObject
	{
		var sliderObj : CScriptedFlashObject;
		var sliderArgsArray : CScriptedFlashArray;

		

      	sliderObj = m_flashValueStorage.CreateTempFlashObject();
		sliderArgsArray = m_flashValueStorage.CreateTempFlashArray();

		sliderArgsArray.PushBackFlashInt(id);
		sliderArgsArray.PushBackFlashString(GetLocStringByKeyExt(label));
		sliderArgsArray.PushBackFlashNumber(minVal);
		sliderArgsArray.PushBackFlashNumber(maxVal);
		sliderArgsArray.PushBackFlashNumber(step);
		sliderArgsArray.PushBackFlashNumber(defVal);

		sliderObj.SetMemberFlashString("colorSliderType", sliderType);

		if(StrLen(extraParams.m_callbackFunctionName) > 0)
		{
			sliderObj.SetMemberFlashString("callback", extraParams.m_callbackFunctionName);
			sliderObj.SetMemberFlashString("callbackDelay", extraParams.m_callbackDelay);
		}
		if(extraParams.m_disabled)
			sliderObj.SetMemberFlashBool("disabled", true);

		sliderObj.SetMemberFlashArray("args", sliderArgsArray);
		sliderObj.SetMemberFlashString("rendererType", "colorSlider");

		m_defaultUIValues[id] = defVal;

		return sliderObj;
	}
	
	private function CreateStringSlider(id:int, label:string, strings:array<string>, optional defIdx:int, optional extraParams:SPhotomodeRendererExtraParams, optional dontLocalizeValue:bool) : CScriptedFlashObject
	{
		var sliderObj : CScriptedFlashObject;
		var sliderArgsArray : CScriptedFlashArray;
		var stringsArray : CScriptedFlashArray;
		var stringsArrayObj : CScriptedFlashObject;
		var i, length: int;

		

		sliderObj = m_flashValueStorage.CreateTempFlashObject();
		sliderArgsArray = m_flashValueStorage.CreateTempFlashArray();
		stringsArray = m_flashValueStorage.CreateTempFlashArray();
		stringsArrayObj = m_flashValueStorage.CreateTempFlashObject();;

		sliderArgsArray.PushBackFlashInt(id);
		sliderArgsArray.PushBackFlashString(GetLocStringByKeyExt(label));

		length = strings.Size();
		for(i = 0; i < length; i += 1)
		{
			if( dontLocalizeValue )
			{
				stringsArray.PushBackFlashString( strings[i] );
			}
			else
			{
				stringsArray.PushBackFlashString( GetLocStringByKeyExt(strings[i]) );
			}
		}

		stringsArrayObj.SetMemberFlashArray("strings", stringsArray);
		sliderArgsArray.PushBackFlashObject(stringsArrayObj);
		sliderArgsArray.PushBackFlashInt(defIdx);

		if(StrLen(extraParams.m_callbackFunctionName) > 0)
		{
			sliderObj.SetMemberFlashString("callback", extraParams.m_callbackFunctionName);
			sliderObj.SetMemberFlashString("callbackDelay", extraParams.m_callbackDelay);
		}
		if(extraParams.m_disabled)
			sliderObj.SetMemberFlashBool("disabled", true);

		sliderObj.SetMemberFlashArray("args", sliderArgsArray);
		sliderObj.SetMemberFlashString("rendererType", "slider");

		m_defaultUIValues[id] = defIdx;

		return sliderObj;
	}
	
	private function CreateStringSelector(id:int, label:string, strings:array<string>, optional defIdx:int, optional extraParams:SPhotomodeRendererExtraParams, optional dontLocalizeValue:bool) : CScriptedFlashObject
	{
		var sliderObj : CScriptedFlashObject;
		var sliderArgsArray : CScriptedFlashArray;
		var stringsArray : CScriptedFlashArray;
		var stringsArrayObj : CScriptedFlashObject;
		var i, length: int;

		

		sliderObj = m_flashValueStorage.CreateTempFlashObject();
		sliderArgsArray = m_flashValueStorage.CreateTempFlashArray();
		stringsArray = m_flashValueStorage.CreateTempFlashArray();
		stringsArrayObj = m_flashValueStorage.CreateTempFlashObject();;

		sliderArgsArray.PushBackFlashInt(id);
		sliderArgsArray.PushBackFlashString(GetLocStringByKeyExt(label));

		length = strings.Size();
		for(i = 0; i < length; i += 1)
		{
			if( dontLocalizeValue )
			{
				stringsArray.PushBackFlashString( strings[i] );
			}
			else
			{
				stringsArray.PushBackFlashString( GetLocStringByKeyExt(strings[i]) );
			}
		}

		stringsArrayObj.SetMemberFlashArray("strings", stringsArray);
		sliderArgsArray.PushBackFlashObject(stringsArrayObj);
		sliderArgsArray.PushBackFlashInt(defIdx);

		if(StrLen(extraParams.m_callbackFunctionName) > 0)
		{
			sliderObj.SetMemberFlashString("callback", extraParams.m_callbackFunctionName);
			sliderObj.SetMemberFlashString("callbackDelay", extraParams.m_callbackDelay);
		}
		if(extraParams.m_disabled)
			sliderObj.SetMemberFlashBool("disabled", true);

		sliderObj.SetMemberFlashArray("args", sliderArgsArray);
		sliderObj.SetMemberFlashString("rendererType", "selector");

		m_defaultUIValues[id] = defIdx;

		return sliderObj;
	}

	private function CreateCharacterSlotSelector(id:int, label:string, optional defIdx:int, optional extraParams:SPhotomodeRendererExtraParams, optional dontLocalizeValue:bool) : CScriptedFlashObject
	{
		var slotSelectorObj : CScriptedFlashObject;
		var slotSelectorArgsObj : CScriptedFlashObject;
		var slotSelectorCharList : CScriptedFlashArray;
		var i: int;

		

		slotSelectorObj = m_flashValueStorage.CreateTempFlashObject();
		slotSelectorArgsObj = m_flashValueStorage.CreateTempFlashObject();
		slotSelectorCharList = m_flashValueStorage.CreateTempFlashArray();
	
		slotSelectorArgsObj.SetMemberFlashInt("id", id);
		slotSelectorArgsObj.SetMemberFlashString("label", GetLocStringByKeyExt(label));
		slotSelectorArgsObj.SetMemberFlashString("defIdx", defIdx);
		slotSelectorArgsObj.SetMemberFlashString("currentSlotId", m_currentCharacterSlotId);

		for (i = 0; i < 3; i += 1)
		{
   			AddSpawnableSlotData(
				slotSelectorCharList,
				m_slotedCharacters[i].spawnableName,
				m_slotedCharacters[i].iconPath
			);
		}

		slotSelectorArgsObj.SetMemberFlashArray("slotData", slotSelectorCharList);

		if(StrLen(extraParams.m_callbackFunctionName) > 0)
		{
			slotSelectorObj.SetMemberFlashString("callback", extraParams.m_callbackFunctionName);
			slotSelectorObj.SetMemberFlashString("callbackDelay", extraParams.m_callbackDelay);
		}
		if(extraParams.m_disabled)
			slotSelectorObj.SetMemberFlashBool("disabled", true);

		slotSelectorObj.SetMemberFlashObject("args", slotSelectorArgsObj);
		slotSelectorObj.SetMemberFlashString("rendererType", "charSlotSelector");

		m_defaultUIValues[id] = defIdx;

		return slotSelectorObj;
	}

	private function CreateButtonRenderer(
		id:int, 
		button1Label:string,
		button2Label:string,
		optional defIdx:int,
	 	optional extraParams:SPhotomodeRendererExtraParams, 
	 	optional dontLocalizeValue:bool) : CScriptedFlashObject
	{
		var buttonRendererObj : CScriptedFlashObject;
		var buttonRendererArgsObj : CScriptedFlashObject;
	
		

		buttonRendererObj = m_flashValueStorage.CreateTempFlashObject();
		buttonRendererArgsObj = m_flashValueStorage.CreateTempFlashObject();
	
		buttonRendererArgsObj.SetMemberFlashInt("id", id);
		buttonRendererArgsObj.SetMemberFlashString("defIdx", defIdx);

		if(StrLen(extraParams.m_callbackFunctionName) > 0)
		{
			buttonRendererObj.SetMemberFlashString("callback", extraParams.m_callbackFunctionName);
		}
		if(StrLen(extraParams.m_callbackFunctionNameSecondary) > 0)
		{
			buttonRendererObj.SetMemberFlashString("callbackSecondary", extraParams.m_callbackFunctionNameSecondary);
		}

		buttonRendererArgsObj.SetMemberFlashString("label1", GetLocStringByKeyExt(button1Label));
		buttonRendererArgsObj.SetMemberFlashString("label2", GetLocStringByKeyExt(button2Label));

		if(extraParams.m_disabled)
			buttonRendererObj.SetMemberFlashBool("disabled", true);

		buttonRendererObj.SetMemberFlashObject("args", buttonRendererArgsObj);
		buttonRendererObj.SetMemberFlashString("rendererType", "buttonRenderer");

		m_defaultUIValues[id] = defIdx;

		return buttonRendererObj;
	}

	private function AddSpawnableSlotData(out dataArray: CScriptedFlashArray, spawnableName : string, iconPath : string)
	{
		var overObj : CScriptedFlashObject;

		overObj = m_flashValueStorage.CreateTempFlashObject();

		overObj.SetMemberFlashString("spawnableName", spawnableName);
		overObj.SetMemberFlashString("iconPath", iconPath);

		dataArray.PushBackFlashObject( overObj );
	}

	private function CreatePropSlotSelector(id:int, label:string, optional defIdx:int, optional extraParams:SPhotomodeRendererExtraParams, optional dontLocalizeValue:bool) : CScriptedFlashObject
	{
		var slotSelectorObj : CScriptedFlashObject;
		var slotSelectorArgsObj : CScriptedFlashObject;
		var slotSelectorPropList : CScriptedFlashArray;
		var i: int;

		

		slotSelectorObj = m_flashValueStorage.CreateTempFlashObject();
		slotSelectorArgsObj = m_flashValueStorage.CreateTempFlashObject();
		slotSelectorPropList = m_flashValueStorage.CreateTempFlashArray();
	
		slotSelectorArgsObj.SetMemberFlashInt("id", id);
		slotSelectorArgsObj.SetMemberFlashString("label", GetLocStringByKeyExt(label));
		slotSelectorArgsObj.SetMemberFlashString("defIdx", defIdx);
		slotSelectorArgsObj.SetMemberFlashString("currentSlotId", m_currentPropSlotId);

		for (i = 0; i < 10; i += 1)
		{
   			AddSpawnableSlotData(
				slotSelectorPropList,
				m_slotedProps[i].spawnableName,
				m_slotedProps[i].iconPath
			);
		}

		slotSelectorArgsObj.SetMemberFlashArray("slotData", slotSelectorPropList);

		if(StrLen(extraParams.m_callbackFunctionName) > 0)
		{
			slotSelectorObj.SetMemberFlashString("callback", extraParams.m_callbackFunctionName);
			slotSelectorObj.SetMemberFlashString("callbackDelay", extraParams.m_callbackDelay);
		}
		if(extraParams.m_disabled)
			slotSelectorObj.SetMemberFlashBool("disabled", true);

		slotSelectorObj.SetMemberFlashObject("args", slotSelectorArgsObj);
		slotSelectorObj.SetMemberFlashString("rendererType", "propsSlotSelector");

		m_defaultUIValues[id] = defIdx;

		return slotSelectorObj;
	}

	private function CreateLightSlotSelector(id:int, label:string, optional defIdx:int, optional extraParams:SPhotomodeRendererExtraParams, optional dontLocalizeValue:bool) : CScriptedFlashObject
	{
		var slotSelectorObj : CScriptedFlashObject;
		var slotSelectorArgsObj : CScriptedFlashObject;
	
		

		slotSelectorObj = m_flashValueStorage.CreateTempFlashObject();
		slotSelectorArgsObj = m_flashValueStorage.CreateTempFlashObject();
	
		slotSelectorArgsObj.SetMemberFlashInt("id", id);
		slotSelectorArgsObj.SetMemberFlashString("label", GetLocStringByKeyExt(label));
		slotSelectorArgsObj.SetMemberFlashString("defIdx", defIdx);

		if(StrLen(extraParams.m_callbackFunctionName) > 0)
		{
			slotSelectorObj.SetMemberFlashString("callback", extraParams.m_callbackFunctionName);
			slotSelectorObj.SetMemberFlashString("callbackDelay", extraParams.m_callbackDelay);
		}
		if(extraParams.m_disabled)
			slotSelectorObj.SetMemberFlashBool("disabled", true);

		slotSelectorObj.SetMemberFlashObject("args", slotSelectorArgsObj);
		slotSelectorObj.SetMemberFlashString("rendererType", "lightSlotSelector");

		m_defaultUIValues[id] = defIdx;

		return slotSelectorObj;
	}

	private function QueueOverrideElement(dataObj : CScriptedFlashObject, id:int)
	{
		var overObj : CScriptedFlashObject;

		overObj = m_flashValueStorage.CreateTempFlashObject();

		overObj.SetMemberFlashObject("item", dataObj);
		overObj.SetMemberFlashInt("id", id);

		m_queuedOverrideElements.PushBackFlashObject( overObj );
	}
	
	private function ProcessQueuedOverrideElements()
	{
		m_flashValueStorage.SetFlashArray( "photomode.override.elements", m_queuedOverrideElements );
		m_queuedOverrideElements = m_flashValueStorage.CreateTempFlashArray();
	}
	
	private function CreateTab( label:string, data:CScriptedFlashArray, tabId : string ) : CScriptedFlashObject
	{
		var tabObj : CScriptedFlashObject;	

		tabObj = m_flashValueStorage.CreateTempFlashObject();
		tabObj.SetMemberFlashString( "label", GetLocStringByKeyExt(label) );
		tabObj.SetMemberFlashArray( "data", data );
		tabObj.SetMemberFlashString( "tabId", tabId );

		return tabObj;
	}
	
	private function OnCharacterFilteringChanged():void
	{
		OnCharacterFilteringChanged_SelectedNPC();
		OnCharacterFilteringChanged_Appearance();
	}

	private function OnCharacterFilteringChanged_SelectedNPC():void
	{
		var elemObj : CScriptedFlashObject;	
		var extraParams : SPhotomodeRendererExtraParams;
		var stringsArray : array<string>;
		var selected : int;

		GetCharacterList(stringsArray, selected);
		if(stringsArray.Size() == 0) stringsArray.PushBack(GetLocStringByKeyExt("input_device_key_name_IK_none"));
		extraParams.m_disabled = m_cachedCharacterList.Size() < 2;
		elemObj = CreateStringSelector(PM_Selected_NPC, "photomode_params_selected_npc", stringsArray, selected, extraParams, true);
		QueueOverrideElement(elemObj, PM_Selected_NPC);
	}

	private function OnCharacterFilteringChanged_Appearance():void
	{
		var elemObj : CScriptedFlashObject;	
		var extraParams : SPhotomodeRendererExtraParams;
		var stringsArray : array<string>;
		var selected : int;

		GetAppearanceList(stringsArray, selected, false);
		if(stringsArray.Size() == 0) stringsArray.PushBack(GetLocStringByKeyExt("input_device_key_name_IK_none"));
		extraParams.m_callbackFunctionName = "OnRequestFakeTick";
		extraParams.m_callbackDelay = 0.01;
		extraParams.m_disabled = m_cachedAppearanceList.Size() < 2;
		elemObj = CreateStringSelector(PM_Appearance, "photomode_params_selected_appearance", stringsArray, selected, extraParams, true);
		QueueOverrideElement(elemObj, PM_Appearance);
	}

	private function OnSelectedAddCharacterChanged():void
	{
		OnSelectedAddCharacterChanged_EnableGravity();
		OnSelectedAddCharacterChanged_Appearance();
		OnSelectedAddCharacterChanged_FacialAnimations();
		OnSelectedAddCharacterChanged_HideCharacter();
		
		OnSelectedAddCharacterChanged_Pose();
		OnSelectedAddCharacterChanged_LookAtCamera();
		OnSelectedAddCharacterChanged_SnapToCamera();
		OnSelectedAddCharacterChanged_Rotation();
		OnSelectedAddCharacterChanged_Position();
	}

	private function OnSelectedAddCharacterChanged_Transform():void
	{
		OnSelectedAddCharacterChanged_Rotation();
		OnSelectedAddCharacterChanged_Position();
	}

	private function OnSelectedAddCharacterChanged_Appearance():void
	{
		var elemObj : CScriptedFlashObject;	
		var extraParams : SPhotomodeRendererExtraParams;
		var stringsArray : array<string>;
		var selected : int;
	
		GetAppearanceList(stringsArray, selected, true);
		if(stringsArray.Size() == 0) stringsArray.PushBack(GetLocStringByKeyExt("input_device_key_name_IK_none"));
		extraParams.m_callbackFunctionName = "OnRequestFakeTick";
		extraParams.m_callbackDelay = 0.01;
		extraParams.m_disabled = m_cachedAppearanceList.Size() < 2;
		elemObj = CreateStringSelector(PM_AddChar_Appearance, "photomode_params_addchar_appearance", stringsArray, selected, extraParams, true);
		QueueOverrideElement(elemObj, PM_AddChar_Appearance);
	}

	private function OnSelectedAddCharacterChanged_FacialAnimations():void
	{
		var elemObj : CScriptedFlashObject;	
		var extraParams : SPhotomodeRendererExtraParams;
		var stringsArray : array<string>;
		var selected : int;

		GetFacialExressionList(stringsArray, selected);
		if(stringsArray.Size() == 0) stringsArray.PushBack(GetLocStringByKeyExt("input_device_key_name_IK_none"));
		extraParams.m_callbackFunctionName = "OnRequestFakeTick";
		extraParams.m_callbackDelay = 0.01;
		extraParams.m_disabled = stringsArray.Size() < 2;
		elemObj = CreateStringSelector(PM_Char_FacialExpression, "photomode_params_selected_facialexpression", stringsArray, selected, extraParams, true);
		QueueOverrideElement(elemObj, PM_Char_FacialExpression);
	}

	private function OnSelectedAddCharacterChanged_HideCharacter():void
	{
		var elemObj : CScriptedFlashObject;	
		var extraParams : SPhotomodeRendererExtraParams;
		var stringsArray : array<string>;

		stringsArray.PushBack("panel_mainmenu_option_value_off");
		stringsArray.PushBack("panel_mainmenu_option_value_on");
		extraParams.m_disabled = !m_selectedCharValid;
		elemObj = CreateStringSlider(PM_Hide_AddCharacters, "photomode_params_hide_addcharacters", stringsArray, (int)m_selectedSpawnedCharacter.m_hidden, extraParams);
		QueueOverrideElement(elemObj, PM_Hide_AddCharacters);
	}

	private function OnSelectedAddCharacterChanged_PoseCategory():void
	{
		var elemObj : CScriptedFlashObject;	
		var extraParams : SPhotomodeRendererExtraParams;
		var stringsArray : array<string>;
		var selected : int;

		GetPoseCategoryList(stringsArray, selected);
		if(stringsArray.Size() == 0) stringsArray.PushBack(GetLocStringByKeyExt("input_device_key_name_IK_none"));
		extraParams.m_callbackFunctionName = "OnRequestFakeTick";
		extraParams.m_callbackDelay = 0.01;
		extraParams.m_disabled = stringsArray.Size() < 2;
		elemObj = CreateStringSelector(PM_Char_PoseCategory, "photomode_params_selected_posecategory", stringsArray, selected, extraParams, true);
		QueueOverrideElement(elemObj, PM_Char_PoseCategory);
	}

	private function OnSelectedAddCharacterChanged_Pose():void
	{
		var elemObj : CScriptedFlashObject;	
		var extraParams : SPhotomodeRendererExtraParams;
		var stringsArray : array<string>;
		var selected : int;

		GetPoseList(stringsArray, selected);
		if(stringsArray.Size() == 0) stringsArray.PushBack(GetLocStringByKeyExt("input_device_key_name_IK_none"));
		extraParams.m_callbackFunctionName = "OnRequestFakeTick";
		extraParams.m_callbackDelay = 0.01;
		extraParams.m_disabled = stringsArray.Size() < 2;
		elemObj = CreateStringSelector(PM_Char_Pose, "photomode_params_selected_pose", stringsArray, selected, extraParams, true);
		QueueOverrideElement(elemObj, PM_Char_Pose);
	}

	private function OnSelectedAddCharacterChanged_LookAtCamera():void
	{
		var elemObj : CScriptedFlashObject;	
		var extraParams : SPhotomodeRendererExtraParams;
		var stringsArray : array<string>;

		stringsArray.PushBack("photomode_params_char_lookcamera_off"); 
		stringsArray.PushBack("photomode_params_char_lookcamera_on");  
		extraParams.m_disabled = !m_selectedCharValid;
		elemObj = CreateStringSlider(PM_Char_LookAtCamera, "photomode_params_char_lookcamera", stringsArray, (int)m_selectedSpawnedCharacter.m_lookAtCamera, extraParams);
		QueueOverrideElement(elemObj, PM_Char_LookAtCamera);
	}

	private function OnSelectedAddCharacterChanged_SnapToCamera():void
	{
		var elemObj : CScriptedFlashObject;	
		var extraParams : SPhotomodeRendererExtraParams;
		var stringsArray : array<string>;

		stringsArray.PushBack("photomode_params_char_snapcamera_off"); 
		stringsArray.PushBack("photomode_params_char_snapcamera_on");  
		extraParams.m_disabled = !m_selectedCharValid;
		elemObj = CreateStringSlider(PM_Char_SnapCamera, "photomode_params_char_snapcamera", stringsArray, (int)m_selectedSpawnedCharacter.m_snapToCamera, extraParams);
		QueueOverrideElement(elemObj, PM_Char_SnapCamera);
	}

	private function OnSelectedAddCharacterChanged_EnableGravity():void
	{
		var elemObj : CScriptedFlashObject;	
		var extraParams : SPhotomodeRendererExtraParams;
		var stringsArray : array<string>;

		extraParams.m_disabled = false;
		stringsArray.PushBack("photomode_params_char_snapcamera_off"); 
		stringsArray.PushBack("photomode_params_char_snapcamera_on");  
		elemObj = CreateStringSlider(PM_Char_EnableGravity, "photomode_params_char_enable_gravity", stringsArray, (int)(!m_selectedSpawnedCharacter.m_disableGravity), extraParams);
		QueueOverrideElement(elemObj, PM_Char_EnableGravity);
	}

	private function OnSelectedAddCharacterChanged_Rotation():void
	{
		var elemObj : CScriptedFlashObject;
		var extraParams : SPhotomodeRendererExtraParams;

		extraParams.m_disabled = !m_selectedCharValid || m_selectedSpawnedCharacter.m_lookAtCamera;
		elemObj = CreateBasicSlider(PM_Char_Transform_Rotate, "photomode_params_char_rotate", -360.0, 360.0, 5.0, m_selectedSpawnedCharacter.m_relativeRotation, extraParams);
		QueueOverrideElement(elemObj, PM_Char_Transform_Rotate);
	}

	private function OnSelectedAddCharacterChanged_Position():void
	{
		var elemObj : CScriptedFlashObject;	
		var extraParams : SPhotomodeRendererExtraParams;

		extraParams.m_disabled = !m_selectedCharValid || m_selectedSpawnedCharacter.m_snapToCamera;
		elemObj = CreateBasicSlider(PM_Char_Transform_LeftRight, "photomode_params_char_leftright", -10.0, 10.0, 0.05, m_selectedSpawnedCharacter.m_relativeLocation.X, extraParams);
		QueueOverrideElement(elemObj, PM_Char_Transform_LeftRight);
		elemObj = CreateBasicSlider(PM_Char_Transform_CloseFar, "photomode_params_char_closefar",-10.0, 10.0, 0.05, m_selectedSpawnedCharacter.m_relativeLocation.Y, extraParams);
		QueueOverrideElement(elemObj, PM_Char_Transform_CloseFar);
		elemObj = CreateBasicSlider(PM_Char_Transform_UpDown, "photomode_params_char_updown", -10.0, 10.0, 0.05, m_selectedSpawnedCharacter.m_relativeLocation.Z, extraParams);
		QueueOverrideElement(elemObj, PM_Char_Transform_UpDown);
	}


	private function OnSelectedAddPropChanged():void
	{
		OnSelectedAddPropChanged_EnableGravity();
		OnSelectedAddPropChanged_SnapToCamera();
		OnSelectedAddPropChanged_Rotation();
		OnSelectedAddPropChanged_Position();
	}

	private function OnSelectedAddPropChanged_Transform():void
	{
		OnSelectedAddPropChanged_Rotation();
		OnSelectedAddPropChanged_Position();
	}

	private function OnSelectedAddPropChanged_SnapToCamera():void
	{
		var elemObj : CScriptedFlashObject;	
		var extraParams : SPhotomodeRendererExtraParams;
		var stringsArray : array<string>;

		extraParams.m_disabled = !m_selectedPropValid;
		stringsArray.PushBack("photomode_params_prop_snapcamera_off"); 
		stringsArray.PushBack("photomode_params_prop_snapcamera_on");  
		elemObj = CreateStringSlider(PM_Prop_SnapCamera, "photomode_params_prop_snapcamera", stringsArray, (int)m_selectedSpawnedProp.m_snapToCamera, extraParams); 
		QueueOverrideElement(elemObj, PM_Prop_SnapCamera);
	}

	private function OnSelectedAddPropChanged_EnableGravity():void
	{
		var elemObj : CScriptedFlashObject;	
		var extraParams : SPhotomodeRendererExtraParams;
		var stringsArray : array<string>;

		extraParams.m_disabled = false;
		stringsArray.PushBack("photomode_params_prop_snapcamera_off"); 
		stringsArray.PushBack("photomode_params_prop_snapcamera_on");  
		elemObj = CreateStringSlider(PM_Prop_EnableGravity, "photomode_params_char_enable_gravity", stringsArray, (int)(!m_selectedSpawnedProp.m_disableGravity), extraParams); 
		QueueOverrideElement(elemObj, PM_Prop_EnableGravity);
	}

	private function OnSelectedAddPropChanged_Rotation():void
	{
		var elemObj : CScriptedFlashObject;	
		var extraParams : SPhotomodeRendererExtraParams;

		extraParams.m_disabled = !m_selectedPropValid;
		elemObj = CreateBasicSlider(PM_Prop_Transform_Rotate, "photomode_params_prop_rotate", -360, 360.0, 5.0, m_selectedSpawnedProp.m_relativeRotation, extraParams);
		QueueOverrideElement(elemObj, PM_Prop_Transform_Rotate);
	}

	private function OnSelectedAddPropChanged_Position():void
	{
		var elemObj : CScriptedFlashObject;	
		var extraParams : SPhotomodeRendererExtraParams;

		extraParams.m_disabled = !m_selectedPropValid || m_selectedSpawnedProp.m_snapToCamera;
		elemObj = CreateBasicSlider(PM_Prop_Transform_LeftRight, "photomode_params_prop_leftright", -10.0, 10.0, 0.05, m_selectedSpawnedProp.m_relativeLocation.X, extraParams);
		QueueOverrideElement(elemObj, PM_Prop_Transform_LeftRight);
		elemObj = CreateBasicSlider(PM_Prop_Transform_CloseFar, "photomode_params_prop_closefar",-10.0, 10.0, 0.05, m_selectedSpawnedProp.m_relativeLocation.Y, extraParams);
		QueueOverrideElement(elemObj, PM_Prop_Transform_CloseFar);
		elemObj = CreateBasicSlider(PM_Prop_Transform_UpDown, "photomode_params_prop_updown", -10.0, 10.0, 0.05, m_selectedSpawnedProp.m_relativeLocation.Z, extraParams);
		QueueOverrideElement(elemObj, PM_Prop_Transform_UpDown);
	}

	private function OnAddCharacterFilteringChanged():void
	{

	}
	
	private function OnCharacterChanged():void
	{
		var extraParams : SPhotomodeRendererExtraParams;

		var stringsArray : array<string>;
		var selected : int;

		var elemObj : CScriptedFlashObject;	
	
		GetAppearanceList(stringsArray, selected, false);
		if(stringsArray.Size() == 0) stringsArray.PushBack(GetLocStringByKeyExt("input_device_key_name_IK_none"));
		extraParams.m_callbackFunctionName = "OnRequestFakeTick";
		extraParams.m_callbackDelay = 0.01;
		extraParams.m_disabled = m_cachedAppearanceList.Size() < 2;
		elemObj = CreateStringSelector(PM_Appearance, "photomode_params_selected_appearance", stringsArray, selected, extraParams, true);
		QueueOverrideElement(elemObj, PM_Appearance);
	}

	event OnSelectCharacterFromList( entityName : String, iconPath : String, index : int)
	{
		UpdatePhotoModeState(PMS_TabSelection);

		m_slotedCharacters[m_currentCharacterSlotId].spawnableName = entityName;
		m_slotedCharacters[m_currentCharacterSlotId].iconPath = iconPath;

		SpawnCharacter(entityName, index);
		UpdateAddCharacterTab();
	}

	event OnSelectPropFromList( entityName : String, iconPath : String, index : int) 
	{
		UpdatePhotoModeState(PMS_TabSelection);

		m_slotedProps[m_currentPropSlotId].spawnableName = entityName;
		m_slotedProps[m_currentPropSlotId].iconPath = iconPath;

		SpawnProp(entityName, index);
		UpdatePropTab();
	}

	private function OnPropFilteringChanged():void
	{
		
	}

	private function OnFacialExpressionChanged(value : float):void
	{
		var newMimic : name = m_selectedCharacterMimics[(int)value];

		if (newMimic == m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_mimic)
			return;

		m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_mimic = newMimic;
		m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_mimic_id = (int)value;
		m_selectedSpawnedCharacter = m_spawnedCharactersBySlot[m_currentCharacterSlotId];
		PlayCurrentAnimation();

		m_queuedFakeTickN = 3;
		m_queuedReapplyAnimation = true;
	}

	private function OnPoseCategoryChanged():void
	{
		
	}

	private function OnPoseChanged(value : float):void
	{
		var animatedComponent : CAnimatedComponent;
		var newPose : name = m_selectedCharacterPoses[(int)value];

		if (newPose == m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_pose)
			return;

		m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_pose = newPose;
		m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_poseDetails = m_selectedCharacterPoseDetails[(int)value];
		m_selectedSpawnedCharacter = m_spawnedCharactersBySlot[m_currentCharacterSlotId];
		PlayCurrentAnimation();
		WarmupClothsSimulation();

		m_queuedCharUpdate = true;
	}
	
	private function OnCharacterLookCameraChanged(value : float):void
	{
		var cachedValue : bool = m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_lookAtCamera;
		m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_lookAtCamera = value;
		if (value == 1.0f)
		{
			m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_relativeRotation = 0.f;
		}
		m_selectedSpawnedCharacter = m_spawnedCharactersBySlot[m_currentCharacterSlotId];
		if (cachedValue != (bool)value)
		{
			OnSelectedAddCharacterChanged_Transform();
			VecSetZeros(m_lastCameraPosition);
		}
		DoFakeTick();
	}

	private function OnCharacterSnapToCameraChanged(value : float):void
	{
		var cachedValue : bool = m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_snapToCamera;
		m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_snapToCamera = value;
		if (value == 1.0f)
		{
			m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_relativeLocation = Vector(0,0,0);
		}
		m_selectedSpawnedCharacter = m_spawnedCharactersBySlot[m_currentCharacterSlotId];
		if (cachedValue != (bool)value)
		{
			OnSelectedAddCharacterChanged_Position();
			VecSetZeros(m_lastCameraPosition);
		}
	}

	private function OnPropSnapToCameraChanged(value : float):void
	{
		var cachedValue : bool = m_spawnedPropsBySlot[m_currentPropSlotId].m_snapToCamera;
		m_spawnedPropsBySlot[m_currentPropSlotId].m_snapToCamera = value;
		if (value == 1.0f)
		{
			m_spawnedPropsBySlot[m_currentPropSlotId].m_relativeLocation = Vector(0,0,0);
		}
		m_selectedSpawnedProp = m_spawnedPropsBySlot[m_currentPropSlotId];
		if (cachedValue != (bool)value)
		{
			OnSelectedAddPropChanged_Position();
		}
	}

	private function OnCharacterEnableGravityChanged(value : float):void
	{
		var cachedValue : bool = !m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_disableGravity;
		if (cachedValue == (bool)value)
			return;

		m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_disableGravity = !((bool)value);
		if ((bool)value)
		{
			
			m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_location = SnapLocationToGround(m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_actor, m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_location);
			OnCharacterTransformChanged();
			DoFakeTick();
		}
		m_selectedSpawnedCharacter = m_spawnedCharactersBySlot[m_currentCharacterSlotId];
		if ((bool)value)
		{
			OnSelectedAddCharacterChanged_Position();
		}
	}

	private function OnPropEnableGravityChanged(value : float):void
	{
		var cachedValue : bool = !m_spawnedPropsBySlot[m_currentPropSlotId].m_disableGravity;
		if (cachedValue == (bool)value)
			return;

		m_spawnedPropsBySlot[m_currentPropSlotId].m_disableGravity = !((bool)value);
		if ((bool)value)
		{
			
			m_spawnedPropsBySlot[m_currentPropSlotId].m_location = SnapLocationToGround(m_spawnedPropsBySlot[m_currentPropSlotId].m_entity, m_spawnedPropsBySlot[m_currentPropSlotId].m_location);
			OnPropsTransformChanged();
			DoFakeTick();
		}
		m_selectedSpawnedProp = m_spawnedPropsBySlot[m_currentPropSlotId];
	}

	private function OnCharacterHiddenChanged():void
	{
		
		if (m_queuedSpawnedCharacterVisibility)
			return;

		m_selectedSpawnedCharacter = m_spawnedCharactersBySlot[m_currentCharacterSlotId];
		m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_actor.SetVisibility( !m_selectedSpawnedCharacter.m_hidden );
		DoFakeTick();
	}

	private function OnCharacterTransformRotateChanged(value : float):void
	{
		m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_relativeRotation = value;
		OnCharacterTransformChanged();
	}

	private function OnCharacterTransformLeftRightChanged(value : float):void
	{
		m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_relativeLocation.X = value;
		OnCharacterTransformChanged();
	}

	private function OnCharacterTransformCloseFarChanged(value : float):void
	{
		m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_relativeLocation.Y = value;
		OnCharacterTransformChanged();
	}

	private function OnCharacterTransformUpDownChanged(value : float):void
	{
		m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_relativeLocation.Z = value;
		OnCharacterTransformChanged();
	}

	private function OnCharacterTransformChanged():void
	{
		var newLocation : Vector;
		var newRotation : EulerAngles;

		m_selectedSpawnedCharacter = m_spawnedCharactersBySlot[m_currentCharacterSlotId];

		newLocation = m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_location + m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_relativeLocation;
		newRotation = m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_rotation;
		newRotation.Yaw += m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_relativeRotation;

		m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_actor.TeleportWithRotation(newLocation, newRotation);

		RecalculateCharacterHighlightPosition();
		UpdateCharacterHighlightPosition();

		DoFakeTick();
		WarmupClothsSimulation();
	}

	private function OnPropsTransformChanged():void
	{
		var newLocation : Vector;
		var newRotation : EulerAngles;

		m_selectedSpawnedProp = m_spawnedPropsBySlot[m_currentPropSlotId];

		newLocation = m_selectedSpawnedProp.m_location + m_selectedSpawnedProp.m_relativeLocation;
		newRotation = m_selectedSpawnedProp.m_rotation;
		newRotation.Yaw += m_selectedSpawnedProp.m_relativeRotation;

		m_selectedSpawnedProp.m_entity.TeleportWithRotation(newLocation, newRotation);

		DoFakeTick();
	}

	private function OnLightStateChanged():void
	{
		
	}

	private function OnLightShadowChanged():void
	{
		
	}

	private function OnLightParameterChanged():void
	{
		
		
	}

	event  OnResetAddCharacterTransformToOrigin()
	{
		if (!m_selectedCharValid)
			return false;

		m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_relativeLocation = Vector(0,0,0);
		m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_relativeRotation = 0;
		OnCharacterTransformChanged();
		OnSelectedAddCharacterChanged_Transform();
	}

	event   OnResetPropTransformToOrigin()
	{
		if (!m_selectedPropValid)
			return false;

		m_spawnedPropsBySlot[m_currentPropSlotId].m_relativeLocation = Vector(0,0,0);
		m_spawnedPropsBySlot[m_currentPropSlotId].m_relativeRotation = 0;
		OnPropsTransformChanged();
		OnSelectedAddPropChanged_Position();
	}

	event   OnResetAddCharacterTransformToCamera()
	{
		LogChannel('PHOTOMODE', "Debug UI OnResetAddCharacterTransformToCamera");

		if (!m_selectedCharValid)
			return false;

		m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_relativeLocation = Vector(0,0,0);
		m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_relativeRotation = 0;
		m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_location = GetSpawnLocation(m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_actor, m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_disableGravity);
		m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_rotation = GetSpawnRotation(m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_location);
		OnCharacterTransformChanged();
		OnSelectedAddCharacterChanged_Transform();
	}

	event  OnResetPropTransformToCamera()
	{
		if (!m_selectedPropValid)
			return false;

		m_spawnedPropsBySlot[m_currentPropSlotId].m_relativeLocation = Vector(0,0,0);
		m_spawnedPropsBySlot[m_currentPropSlotId].m_relativeRotation = 0;
		m_spawnedPropsBySlot[m_currentPropSlotId].m_location = GetSpawnLocation(m_spawnedPropsBySlot[m_currentPropSlotId].m_entity, m_spawnedPropsBySlot[m_currentPropSlotId].m_disableGravity);
		m_spawnedPropsBySlot[m_currentPropSlotId].m_rotation = GetSpawnRotation(m_spawnedPropsBySlot[m_currentPropSlotId].m_location);
		OnPropsTransformChanged();
		OnSelectedAddPropChanged_Transform();
	}
	
	private function DoFakeTick() : void
	{
		
		
		theGame.GetPhotomodeEffects().SetPhotomodeTickTime(0.00001);
	}

	private function WarmupClothsSimulation() : void
	{
		theGame.GetPhotomodeEffects().SetPhotomodeClothsSimulationTime(m_clothsWarmupTime);
	}
	
	event  OnRequestFakeTick()
	{
		thePlayer.GetPhotomodeManager().DoFakeTick();
	}
	
	event  OnSaveOnSlot(idx : int)
	{
		LogChannel('PHOTOMODE', "Saving on Slot " + idx);

		switch ( idx )
		{
			case PM_Camera_Location:
				if ( m_UIValues[PM_Camera_Location] == 0 ) 
					CreateNewCameraLocationSave();
				else
					SaveCameraLocationToSlot( (int) m_UIValues[PM_Camera_Location] );

				break;
		}
	}
	
	event  OnLoadOnSlot(idx : int)
	{
		
		
		
		
		
		
		
		

		LogChannel('PHOTOMODE', "Loading Slot " + idx);

		switch ( idx )
		{
			case PM_Camera_Location:
				if ( m_UIValues[PM_Camera_Location] == 0 ) 
					break;

				DeleteCameraLocation( (int) m_UIValues[PM_Camera_Preset], (int) m_UIValues[PM_Camera_Location] );
				break;
		}
	}

	event OnCharSlotSelect(slotId : int )
	{	
		if(m_currentCharacterSlotId != slotId)
		{
			m_currentCharacterSlotId = slotId;
			UpdateCharacterSelectorTab();
		}
		else
		{
			UpdatePhotoModeState(PMS_CharacterSelection);
		}
	}

	event OnPropSlotSelect(slotId : int)
	{
		if(m_currentPropSlotId != slotId)
		{
			m_currentPropSlotId = slotId;
			UpdatePropsSelectorTab();
		}
		else
		{
			UpdatePhotoModeState(PMS_PropSelection);
		}
	}

	event OnLightSlotSelect(slotId : int)
	{	

	}

	private function UpdateCharacterSelectorTab()
	{
		SelectCharacterBySlot();
	}

	private function UpdatePropsSelectorTab()
	{
		SelectPropBySlot();
	}

	private function UpdatePhotoModeState( newState : PhotomodeState)
	{
		m_photoModeState = newState;
		m_updatePhotoModeState.InvokeSelfOneArg(FlashArgInt((int)newState));
	}
	
	private function HideTutorial()
	{
		var tutorialPopupRef : CR4TutorialPopup;

		tutorialPopupRef = (CR4TutorialPopup) theGame.GetGuiManager().GetPopup('TutorialPopup');
		if (tutorialPopupRef && tutorialPopupRef.isVisible)
		{
			tutorialPopupRef.SetInvisible(true, true);
			_cachedTutorialVisibility = true;
		}
	}
	
	private function ShowTutorial()
	{
		var tutorialPopupRef : CR4TutorialPopup;

		tutorialPopupRef = (CR4TutorialPopup) theGame.GetGuiManager().GetPopup('TutorialPopup');
		if (tutorialPopupRef && !tutorialPopupRef.isVisible && _cachedTutorialVisibility == true)
		{
			tutorialPopupRef.SetInvisible(false, true);
			_cachedTutorialVisibility = false;
		}
	}
	
	public function UpdateParam( paramId : int, paramValue : float, optional enabled : bool )
	{
		m_fxUpdateParam.InvokeSelfTwoArgs( FlashArgUInt(paramId), FlashArgNumber(paramValue));
	}

	private function UpdateParamWithEvent( paramId : int, paramValue : float, optional enabled : bool )
	{
		UpdateParam( paramId, paramValue, enabled );
		OnParameterChanged( paramId, paramValue );
	}

	private function UpdateThirdsLinesVisibility(value:bool) : void
	{
		m_fxSetThirdsLinesVisibility.InvokeSelfOneArg(FlashArgBool(value));
	}
	
	private function UpdateThirdsLinesAspectRatio() : void
	{
		var width : int;
		var height : int;
		theGame.GetCurrentViewportResolution( width, height );
		m_fxSetThirdsLinesAspectRatio.InvokeSelfTwoArgs(FlashArgInt(width), FlashArgInt(height));
	}
	
	private function UpdatePhotoAspectRatio(width : int, height: int) : void
	{
		if(width < 0 || height < 0)
			theGame.GetCurrentViewportResolution( width, height );
		m_fxSetPhotoAspectRatio.InvokeSelfTwoArgs(FlashArgInt(width), FlashArgInt(height));
	}
	
	private function CacheOriginalAppearances()
	{
		var charList : array<CActor>;
		var char : CActor;
		var i : int;
		var appearancePair : SNPCAppearancePair;

		theGame.GetPhotomodeEffects().GetEditableCharacterList(m_maxNPCDistance, charList);

		for(i = 0; i < charList.Size(); i+=1)
		{
			char = charList[i];
	
			appearancePair.m_npc = char;
			appearancePair.m_appearance = char.GetAppearance();
	
			m_originalNPCAppearances.PushBack(appearancePair);
	
		}
	}
	
	private function RestoreOriginalAppearances()
	{
		var char : CActor;
		var i : int;

		for(i = 0; i < m_originalNPCAppearances.Size(); i+=1)
		{
			char = m_originalNPCAppearances[i].m_npc;
	
			char.ApplyAppearance(m_originalNPCAppearances[i].m_appearance);	
		}
	}

	private function HideNPCs()
	{
		var i : int;
		var npcPos : Vector;
		var npcLocationPair : SNPCLocationPair;
		var actor : CNewNPC;
		var npcs : array< CNewNPC >;
		var compList : array<CComponent>;

		if( m_hideNPCsEnabled )
		{
			return;
		}

		theGame.GetAllNPCs( npcs );
		for( i=0; i < npcs.Size(); i+=1 )
		{
			actor = npcs[i];
			if( actor && actor != thePlayer.GetHorseCurrentlyMounted() )
			{
				if ( !actor.GetVisibility() )
				{
					continue;
				}
		
				actor.SetVisibility( false );
				m_hiddenNPCs.PushBack( actor );
			}
		}

		m_hideNPCsEnabled = m_hiddenNPCs.Size() > 0;

		if(m_hideNPCsEnabled)
		{
			thePlayer.GetPhotomodeManager().DoFakeTick();
		}
	}

	private function ShowNPCs()
	{
		var i : int;
		var actor : CNewNPC;
		var npcs : array< CNewNPC >;
		var compList : array<CComponent>;
		var npcLocationPair : SNPCLocationPair;

		if( !m_hideNPCsEnabled )
		{
			return;
		}

		for( i=0; i < m_hiddenNPCs.Size(); i+=1 )
		{
			if( m_hiddenNPCs[i] )
			{
				m_hiddenNPCs[i].SetVisibility( true );
			}
		}

		m_hiddenNPCs.Clear();
		m_hideNPCsEnabled = false;

		thePlayer.GetPhotomodeManager().DoFakeTick();
	}

	private function PlayCurrentAnimation()
	{
		var animatedComponent : CAnimatedComponent;

		animatedComponent = ( CAnimatedComponent ) m_selectedCharacter.GetComponentByClassName( 'CAnimatedComponent' );
		animatedComponent.PlayAnimationOnSkeleton(m_selectedSpawnedCharacter.m_pose, m_selectedSpawnedCharacter.m_poseDetails.m_startTime);
		m_selectedSpawnedCharacter.m_actor.PlayMimicAnimationAsync(m_selectedSpawnedCharacter.m_mimic, 0, 0.5);

		DoFakeTick();
	}

	public function SpawnCharacter(characterToSpawn: string, index : int)
	{	
		var spawnLocation, finalSpawnLocation : Vector;
		var spawnRotation, finalSpawnRotation : EulerAngles;

		var entityTemplate : CEntityTemplate;

		var movingComponent 	: CMovingPhysicalAgentComponent;
		var spawnedEntity : CEntity;
		var spawnedCharacter, lastSpawnedCharacter : SSpawnedCharacter;

		spawnedCharacter.m_disableGravity = m_selectedSpawnedCharacter.m_disableGravity;
		if (m_spawnedCharactersBySlot.Contains(m_currentCharacterSlotId))
		{
			m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_actor.Destroy();
			lastSpawnedCharacter = m_spawnedCharactersBySlot[m_currentCharacterSlotId];
		}

		if (characterToSpawn == "" || characterToSpawn == "none")
		{
			m_spawnedCharactersBySlot[m_currentCharacterSlotId] = spawnedCharacter;
			m_selectedSpawnedCharacter = spawnedCharacter;
			m_selectedCharacter = NULL;
			m_selectedCharacter_Spawned = NULL;
			m_selectedCharValid = false;
			m_selectedCharValid_Spawned = false;
			UpdateSelectedCharacterPoses();
			UpdateSelectedCharacterMimics();
			OnSelectedAddCharacterChanged();
			return;
		}

		if (lastSpawnedCharacter.m_entityName != "")
		{
			spawnedCharacter.m_relativeLocation = lastSpawnedCharacter.m_relativeLocation;
			spawnedCharacter.m_relativeRotation = lastSpawnedCharacter.m_relativeRotation;
			spawnedCharacter.m_lookAtCamera = lastSpawnedCharacter.m_lookAtCamera;
			spawnedCharacter.m_snapToCamera = lastSpawnedCharacter.m_snapToCamera;
			spawnedCharacter.m_disableGravity = lastSpawnedCharacter.m_disableGravity;
			spawnLocation = lastSpawnedCharacter.m_location;
			spawnRotation = lastSpawnedCharacter.m_rotation;
		}
		else
		{
			spawnLocation = GetSpawnLocation(NULL, spawnedCharacter.m_disableGravity);
			spawnRotation = GetSpawnRotation(spawnLocation);
		}

		finalSpawnLocation = spawnLocation + spawnedCharacter.m_relativeLocation;
		finalSpawnRotation = spawnRotation;
		finalSpawnRotation.Yaw += spawnedCharacter.m_relativeRotation;

		entityTemplate = (CEntityTemplate)LoadResource(characterToSpawn);
		spawnedEntity = theGame.CreateEntity(entityTemplate, finalSpawnLocation, finalSpawnRotation);

		spawnedCharacter.m_slot = m_currentCharacterSlotId;
		spawnedCharacter.m_index = index;
		spawnedCharacter.m_actor = (CNewNPC)spawnedEntity;
		spawnedCharacter.m_actor.EnableCharacterCollisions(false);
		
		spawnedCharacter.m_entityName = characterToSpawn;
		spawnedCharacter.m_location = spawnLocation;
		spawnedCharacter.m_rotation = spawnRotation;
		spawnedCharacter.m_appearance = spawnedCharacter.m_actor.GetAppearance();
		spawnedCharacter.m_posesets = StrSplit(m_spawnableCharacterPosesets[characterToSpawn], "|");
		spawnedCharacter.m_mimicsets = StrSplit(m_spawnableCharacterMimicsets[characterToSpawn], "|");
		spawnedCharacter.m_mimic_id = lastSpawnedCharacter.m_mimic_id;

		if (spawnedCharacter.m_posesets == lastSpawnedCharacter.m_posesets)
		{
			spawnedCharacter.m_pose = lastSpawnedCharacter.m_pose;
			m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_poseDetails = lastSpawnedCharacter.m_poseDetails;
		}

		if (spawnedCharacter.m_entityName == lastSpawnedCharacter.m_entityName)
		{
			spawnedCharacter.m_appearance = lastSpawnedCharacter.m_appearance;
			spawnedCharacter.m_actor.ApplyAppearance(spawnedCharacter.m_appearance);
		}

		m_spawnedCharacters.PushBack(spawnedCharacter);
		m_spawnedCharactersBySlot[m_currentCharacterSlotId] = spawnedCharacter;

		SelectCharacterBySlot();

		if (spawnedCharacter.m_posesets != lastSpawnedCharacter.m_posesets)
		{
			m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_pose = m_selectedCharacterPoses[0];
			m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_poseDetails = m_selectedCharacterPoseDetails[0];
		}

		m_selectedSpawnedCharacter = m_spawnedCharactersBySlot[m_currentCharacterSlotId];
		PlayCurrentAnimation();
		movingComponent = ( CMovingPhysicalAgentComponent ) spawnedCharacter.m_actor.GetMovingAgentComponent();
		movingComponent.SetAnimatedMovement(true);

		
		DoFakeTick();
		WarmupClothsSimulation();
		m_queuedFakeTickN = 5;
		m_queuedSpawnedCharacterVisibility = true;
	}

	public function SpawnProp(propToSpawn: string, index : int)
	{
		var spawnLocation : Vector;
		var spawnRotation : EulerAngles;

		var entityTemplate	: CEntityTemplate;
		var spawnedEntity	: CEntity;
		var spawnedProp		: SSpawnedProp;

		spawnedProp.m_disableGravity = m_selectedSpawnedProp.m_disableGravity;
		if (m_spawnedPropsBySlot.Contains(m_currentPropSlotId))
		{
			m_spawnedPropsBySlot[m_currentPropSlotId].m_entity.Destroy();
			m_selectedSpawnedProp = spawnedProp;
		}

		if (propToSpawn == "" || propToSpawn == "none")
		{
			m_spawnedPropsBySlot[m_currentPropSlotId] = spawnedProp;
			m_selectedSpawnedProp = spawnedProp;
			m_selectedProp = NULL;
			m_selectedPropValid = false;
			OnSelectedAddPropChanged();
			return;
		}

		entityTemplate = (CEntityTemplate)LoadResource( propToSpawn );
		if (!entityTemplate)
		{
			Log("EntityTemplate for prop '" + propToSpawn + "' failed to be loaded!");
			return;
		}

		spawnLocation = GetSpawnLocation(NULL, spawnedProp.m_disableGravity);
		spawnRotation = GetSpawnRotation(spawnLocation);

		spawnedEntity = theGame.CreateEntity( entityTemplate, spawnLocation, spawnRotation );
		if (!spawnedEntity)
		{
			Log("Prop '" + propToSpawn + "' failed to be created!");
			return;
		}

		spawnedProp.m_slot = m_currentPropSlotId;
		spawnedProp.m_index = index;
		spawnedProp.m_entity = spawnedEntity;
		spawnedProp.m_location = spawnLocation;
		spawnedProp.m_rotation = spawnRotation;

		m_selectedProp = spawnedProp.m_entity;
		m_selectedPropValid = true;
		m_spawnedProps.PushBack( spawnedProp );
		m_spawnedPropsBySlot[m_currentPropSlotId] = spawnedProp;

		SelectPropBySlot();

		m_selectedSpawnedProp = m_spawnedPropsBySlot[m_currentPropSlotId];

		DoFakeTick();
		m_queuedFakeTickN = 5;
		m_queuedSpawnedPropVisibility = true;
	}

	public function ClearAllSpawnedCharacters()
	{
		var i : int;

		for (i = 0; i < m_spawnedCharacters.Size(); i += 1)
		{
			m_spawnedCharacters[i].m_actor.SetHideInGame(true, true);
			m_spawnedCharacters[i].m_actor.Destroy();
		}

		m_spawnedCharacters.Clear();
		m_spawnedCharactersBySlot.Clear();
	}

	private function GetSpawnLocation(referenceEntity : CEntity, disableGravity : bool) : Vector
	{
		var cameraWorldPosition : Vector;
		var cameraWorldRotation : EulerAngles;
		var cameraForwardVector : Vector;
		var spawnLocation : Vector;
		var bbox : Box;
		var hitResults : array<SRaycastHitResult>;
		var m_spawnCameraZOffset : float = 0;

		cameraWorldPosition = theGame.GetPhotomodeCamera().GetCameraWorldPosition();
		cameraWorldRotation = theGame.GetPhotomodeCamera().GetCameraWorldRotation();
		cameraForwardVector = RotForward(cameraWorldRotation);

		if (referenceEntity)
		{
			referenceEntity.CalcBoundingBox(bbox);
			m_spawnCameraZOffset = (bbox.Max.Z - bbox.Min.Z) / 2;
		}

		

		
		spawnLocation = cameraWorldPosition;

		if (disableGravity)
		{
			spawnLocation += cameraForwardVector * m_spawnCameraOffset;
			spawnLocation += Vector(0,0,-m_spawnCameraZOffset);
		}
		else
		{
			hitResults = RaycastForWorld(spawnLocation, cameraForwardVector, m_spawnCameraOffset);
			if (hitResults.Size() != 0)
			{
				spawnLocation = hitResults[0].position;
			}
			else
			{
				spawnLocation += cameraForwardVector * m_spawnCameraOffset;
				spawnLocation = SnapLocationToGround(referenceEntity, spawnLocation);
			}
		}

		return spawnLocation;
	}

	private function SnapLocationToGround(referenceEntity : CEntity, inLocation : Vector) : Vector
	{
		var result : Vector = inLocation;
		var hitResults : array<SRaycastHitResult> = RaycastForWorld(inLocation, Vector(0,0,-1), m_spawnCameraSnapMaxLength);
		var bbox : Box;

		if (hitResults.Size() > 0)
		{
			result.Z = hitResults[0].position.Z;
		}
		else if (referenceEntity)
		{
			referenceEntity.CalcBoundingBox(bbox);
			result.Z = result.Z - ((bbox.Max.Z - bbox.Min.Z) / 2);
		}
		return result;
	}

	private function RaycastForWorld(inLocation : Vector, raycastDirection : Vector, raycastLength : float) : array<SRaycastHitResult>
	{
		var raycastEnd : Vector = inLocation + raycastDirection * raycastLength;
		var hitResults : array<SRaycastHitResult>;

		theGame.GetWorld().GetTraceManager().RayCastSync(inLocation, raycastEnd, hitResults, m_raycastCollisionGroupsNames);

		return hitResults;
	}

	private function GetSpawnRotation(referencePosition : Vector) : EulerAngles
	{
		var cameraPosition : Vector = theGame.GetPhotomodeCamera().GetCameraWorldPosition();
		var directionToCamera : Vector = VecNormalize(cameraPosition - referencePosition);
		var spawnRotation : EulerAngles = VecToRotation(directionToCamera);

		spawnRotation.Pitch = 0;
		spawnRotation.Roll = 0;

		return spawnRotation;
	}

	private function SelectCharacterBySlot()
	{
		m_selectedCharacter = m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_actor;
		m_selectedCharValid = !(!m_selectedCharacter);
		m_selectedCharacter_Spawned = m_selectedCharacter;
		m_selectedCharValid_Spawned = m_selectedCharValid;
		m_fxSetCurrentCharacter.InvokeSelfOneArg( FlashArgUInt(m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_index) );
		PostSelectCharacterBySlot();
	}

	private function PostSelectCharacterBySlot()
	{
		var noCharacterData : SSpawnedCharacter;

		if (m_selectedCharValid)
		{
			m_selectedSpawnedCharacter = m_spawnedCharactersBySlot[m_currentCharacterSlotId];
			EnableCharacterHighlight(true);
		}
		else
		{
			m_selectedSpawnedCharacter = noCharacterData;
			EnableCharacterHighlight(false);
		}

		UpdateSelectedCharacterPoses();
		UpdateSelectedCharacterMimics();
		UpdateAddCharacterTab();
		OnSelectedAddCharacterChanged();
	}

	private function SelectPropBySlot()
	{
		m_selectedProp = m_spawnedPropsBySlot[m_currentPropSlotId].m_entity;
		m_selectedPropValid = !(!m_selectedProp);
		m_fxSetCurrentProp.InvokeSelfOneArg( FlashArgUInt(m_spawnedPropsBySlot[m_currentPropSlotId].m_index) );
		PostSelectPropBySlot();
	}

	private function PostSelectPropBySlot()
	{
		var noPropData : SSpawnedProp;

		if (m_selectedPropValid)
		{
			
			m_selectedSpawnedProp = m_spawnedPropsBySlot[m_currentPropSlotId];
		}
		else
		{
			m_selectedSpawnedProp = noPropData;
		}

		UpdatePropTab();
		OnSelectedAddPropChanged();
	}

	private function UpdateSelectedCharacterPoses()
	{
		var i : int;

		m_selectedCharacterPoses.Clear();
		m_selectedCharacterPoseNames.Clear();
		m_selectedCharacterPoseDetails.Clear();

		if (!m_selectedCharValid)
			return;

		for (i = 0; i < m_spawnableCharactersPoses.Size(); i += 1)
		{
			if (m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_posesets.Contains(m_spawnableCharactersPoses[i].m_poseset))
			{
				m_selectedCharacterPoseNames.PushBack(m_spawnableCharactersPoses[i].m_poseName);
				m_selectedCharacterPoses.PushBack(m_spawnableCharactersPoses[i].m_pose);
				m_selectedCharacterPoseDetails.PushBack(m_spawnableCharactersPoses[i]);
			}
		}	
	}

	private function UpdateSelectedCharacterMimics()
	{
		var i : int;

		m_selectedCharacterMimics.Clear();
		m_selectedCharacterMimicNames.Clear();

		if (!m_selectedCharValid)
			return;

		for (i = 0; i < m_spawnableCharactersMimics.Size(); i += 1)
		{
			if (m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_mimicsets.Contains(m_spawnableCharactersMimics[i].m_poseset))
			{
				m_selectedCharacterMimicNames.PushBack(m_spawnableCharactersMimics[i].m_poseName);
				m_selectedCharacterMimics.PushBack(m_spawnableCharactersMimics[i].m_pose);
			}
		}

		if (m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_mimic_id < m_selectedCharacterMimics.Size())
		{
			m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_mimic = m_selectedCharacterMimics[m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_mimic_id];
		}
		else
		{
			if (m_selectedCharacterMimics.Size() > 0)
			{
				m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_mimic = m_selectedCharacterMimics[0];
				m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_mimic_id = 0;
			}
		}
	}

	private function ClearAllSpawnedProps()
	{
		var i : int;
		for (i = 0; i < m_spawnedProps.Size(); i += 1)
		{
			m_spawnedProps[i].m_entity.SetHideInGame(true, true);
			m_spawnedProps[i].m_entity.Destroy();
		}
		m_spawnedProps.Clear();
		m_spawnedPropsBySlot.Clear();
	}

	private function RecalculateCharacterHighlightPosition()
	{
		var hud : CR4ScriptedHud;
		var highlightPosition : Vector;
		var headBoneIdx : int;

		
 		headBoneIdx = m_selectedCharacter.GetHeadBoneIndex();
		if ( headBoneIdx >= 0 )
		{
			highlightPosition = MatrixGetTranslation( m_selectedCharacter.GetBoneWorldMatrixByIndex( headBoneIdx ) );
			hud = (CR4ScriptedHud)theGame.GetHud();
			hud.SetCachedPositionForEntity(m_selectedCharacter, highlightPosition);
		}
	}

	private function UpdateCharacterHighlightPosition()
	{
		var charHighlightScreenPos : Vector;

		GetBaseScreenPosition( charHighlightScreenPos, m_selectedCharacter );
	
		
		charHighlightScreenPos.X = ClampF(charHighlightScreenPos.X, 0, 1920); 
		charHighlightScreenPos.Y = ClampF(charHighlightScreenPos.Y, 0, 1080); 
	
		m_fxSetCharacterHighlightPosition.InvokeSelfTwoArgs(FlashArgNumber(charHighlightScreenPos.X), FlashArgNumber(charHighlightScreenPos.Y));
	}

	private function UpdateSpawnedCharactersTransformsIfNeeded(cameraPosition : Vector, cameraRotation : EulerAngles, timeDelta : float)
	{
		var cameraRelativeLocation : Vector;
		var newCharacterLocation : Vector;
		var finalRotation : EulerAngles;
		var transformUpdateNeeded : bool;
		var transformUpdateNeededForAny : bool;
		var i : int;

		for (i = 0; i < m_spawnedCharactersBySlot.Size(); i += 1)
		{
			transformUpdateNeeded = false;
			if (m_spawnedCharactersBySlot[i].m_snapToCamera)
			{
				newCharacterLocation = InterpTo_V( m_spawnedCharactersBySlot[i].m_location, GetSpawnLocation(m_spawnedCharactersBySlot[i].m_actor, m_spawnedCharactersBySlot[i].m_disableGravity), timeDelta, 15.f );
				m_spawnedCharactersBySlot[i].m_location = newCharacterLocation;
				transformUpdateNeeded = true;
			}
			if (m_spawnedCharactersBySlot[i].m_lookAtCamera)
			{
				m_spawnedCharactersBySlot[i].m_rotation = GetSpawnRotation(m_spawnedCharactersBySlot[i].m_location + m_spawnedCharactersBySlot[i].m_relativeLocation);
				transformUpdateNeeded = true;
			}

			if (transformUpdateNeeded)
			{
				transformUpdateNeededForAny = true;
				cameraRelativeLocation = m_spawnedCharactersBySlot[i].m_location + m_spawnedCharactersBySlot[i].m_relativeLocation;
				finalRotation = m_spawnedCharactersBySlot[i].m_rotation;
				finalRotation.Yaw += m_spawnedCharactersBySlot[i].m_relativeRotation;
				m_spawnedCharactersBySlot[i].m_actor.TeleportWithRotation(cameraRelativeLocation, finalRotation);

				if (m_selectedCharacter == m_spawnedCharactersBySlot[i].m_actor)
				{
					m_selectedSpawnedCharacter = m_spawnedCharactersBySlot[i];
					RecalculateCharacterHighlightPosition();
				}
			}
		}
	
		if (transformUpdateNeededForAny && (cameraPosition != m_lastCameraPosition || cameraRotation != m_lastCameraRotation))
		{
			WarmupClothsSimulation();
			DoFakeTick();
		}
	}

	private function UpdateSpawnedPropTransformsIfNeeded(cameraPosition : Vector, cameraRotation : EulerAngles, timeDelta : float)
	{
		var cameraRelativeLocation : Vector;
		var newPropLocation : Vector;
		var finalRotation : EulerAngles;
		var transformUpdateNeeded : bool;
		var i : int;

		for (i = 0; i < m_spawnedPropsBySlot.Size(); i += 1)
		{
			transformUpdateNeeded = false;
			if (m_spawnedPropsBySlot[i].m_snapToCamera)
			{
				newPropLocation = InterpTo_V( m_spawnedPropsBySlot[i].m_location, GetSpawnLocation(m_spawnedPropsBySlot[i].m_entity, m_spawnedPropsBySlot[i].m_disableGravity), timeDelta, 15.f );
				m_spawnedPropsBySlot[i].m_location = newPropLocation;
				transformUpdateNeeded = true;
			}

			if (transformUpdateNeeded)
			{
				cameraRelativeLocation = m_spawnedPropsBySlot[i].m_location + m_spawnedPropsBySlot[i].m_relativeLocation;
				finalRotation = m_spawnedPropsBySlot[i].m_rotation;
				finalRotation.Yaw += m_spawnedPropsBySlot[i].m_relativeRotation;
				m_spawnedPropsBySlot[i].m_entity.TeleportWithRotation(cameraRelativeLocation, finalRotation);

				if (m_selectedProp == m_spawnedPropsBySlot[i].m_entity)
				{
					m_selectedSpawnedProp = m_spawnedPropsBySlot[i];
				}
			}
		}
	}

	private function BlendCameraTransform(cameraPosition : Vector, cameraRotation : EulerAngles, timeDelta : float)
	{
		var newCameraPosition : Vector = m_cameraPositionDamper.UpdateAndGet(timeDelta, m_targetCameraPosition);
		var newCameraRotation : EulerAngles = m_cameraRotationDamper.UpdateAndGet(timeDelta, m_targetCameraRotation);

		theGame.GetPhotomodeCamera().SetCameraWorldPosition(newCameraPosition);
		theGame.GetPhotomodeCamera().SetCameraWorldRotation(newCameraRotation);
		theGame.GetPhotomodeCamera().UpdateWithoutInput( true );

		
		if ( VecDistance( theGame.GetPhotomodeCamera().GetCameraWorldPosition(), cameraPosition ) <= 0.01f )
		{
			m_cameraBlendInProgress = false;
			theGame.GetPhotomodeCamera().SetCameraWorldPosition(m_targetCameraPosition);
			theGame.GetPhotomodeCamera().SetCameraWorldRotation(m_targetCameraRotation);
			theGame.GetPhotomodeCamera().UpdateWithoutInput( true );
			UpdateParamWithEvent( PM_Camera_Noclip, 1 ); 
			theGame.GetPhotomodeCamera().SetNoclip( m_UIValues[PM_Camera_Noclip] == 1 );
			theGame.SetPhotomodeCameraCanMove(CanPhotomodeCameraMove());
		}
	}

	public function CanPhotomodeCameraMove() : bool
	{
		return !m_cameraLocked && m_cameraDraggable && !m_cameraBlendInProgress;
	}
	
	public function LoadCensoredAppearances():void
	{
		m_censoredAppearances = LoadCSV("game\censored_appearances.csv");
	}
	
	public function IsAppearanceCensored(appearance : name) : bool
	{
		var i : int;
		var match : name;

		for(i = 0; i < m_censoredAppearances.GetNumRows(); i+=1) {
			match = m_censoredAppearances.GetValueAtAsName(0,i);
	
			if(match == appearance)
				return true;
		}
		return false;
	}

	public function HaveChangesBeenMade() : bool
	{
		var i : int = 0;
	
		if(theGame.GetPhotomodeEffects().HaveChangesBeenMade())
			return true;
	
		
		for(i = 0; i < m_originalNPCAppearances.Size(); i+=1)
		{
			if(m_originalNPCAppearances[i].m_npc.GetAppearance() != m_originalNPCAppearances[i].m_appearance)
				return true;
		}

		
		for (i = 0; i < m_spawnedCharactersBySlot.Size(); i += 1)
		{
			if(!(!m_spawnedCharactersBySlot[i].m_actor))
				return true;
		}

		
		for (i = 0; i < m_spawnedPropsBySlot.Size(); i += 1)
		{
			if(!(!m_spawnedPropsBySlot[i].m_entity))
				return true;
		}

		

		return false;
	}
	
	public function ShowExitPopup() : void
	{
		var popupData : W3PhotomodeExitConfirmPopupData;

		popupData = new W3PhotomodeExitConfirmPopupData in this;

		popupData.SetupTexts();
		popupData.m_photomodeMenuRef = this;

		RequestSubMenu('PopupMenu', popupData);
	}
	
	public function OnConfirmExit() : void
	{
		var delayExit : bool = false;

		if (m_spawnedCharacters.Size() > 0)
		{
			ClearAllSpawnedCharacters();
			
		}

		if (m_spawnedProps.Size() > 0)
		{
			ClearAllSpawnedProps();
			delayExit = true;
		}

		if(delayExit)
		{
			m_fxStartExitDelayTimer.InvokeSelfOneArg(FlashArgInt(m_exitDelayTimeMs));
		}
		else
		{
			OnExitPhotomode();
		}
	}

	private function SavePreset( id: float )
	{
		var saveString : string;
		var i : int;
		var value : float;
		var varName : string;

		varName = "PhotomodePreset" + FloatToString( id );

		for ( i = 0; i < PM_Max; i = i + 1 )
		{
			if ( m_exludeFromPreset.Contains(i) )
				continue;

			if ( m_UIValues.Contains( i ) )
				value = m_UIValues[i];
			else if ( m_defaultUIValues.Contains(i) )
				value = m_defaultUIValues[i];
			else
				continue;
		
			saveString = saveString + i + "-" + FloatToString( value ) + "|";
		}

		theGame.GetInGameConfigWrapper().SetRawConfigValueByStr( "PhotomodePresets", varName, saveString );
	}

	private function GetPresetMapFromConfig( id : int, out presetMap : map<int, float> )
	{
		var saveString : string;
		var setting : string;
		var paramIdString : string;
		var valueString : string;
		var varName : string;

		varName = "PhotomodePreset" + IntToString( id );

		saveString = theGame.GetInGameConfigWrapper().GetRawConfigValueByStr( "PhotomodePresets", varName );

		if ( !StrEndsWith( saveString, "|" ) )
		{
			
			return;
		}

		while ( StrLen( saveString ) > 0 )
		{
			StrSplitFirst( saveString, "|", setting, saveString );
			StrSplitFirst( setting, "-", paramIdString, valueString );
	
			presetMap[StringToInt( paramIdString )] = StringToFloat( valueString );
		}
	}

	private function CreatePresetMapFromCurrent( out presetMap : map<int, float> )
	{
		var i : int;

		for ( i = 0; i < PM_Max; i = i + 1 )
		{
			if ( m_UIValues.Contains( i ) )
			{
				presetMap[i] = m_UIValues[i];
			}
		}
	}

	private function LoadPresetFromMap( optional presetMap : map<int, float> )
	{
		var i : int;

		for (i = 0; i < PM_Max; i = i + 1)
		{
			if ( m_exludeFromPreset.Contains( i ) )
				continue;

			if ( presetMap.Contains( i ) )
				UpdateParamWithEvent( i, presetMap[i] );
			else if ( m_defaultUIValues.Contains( i ) )
				UpdateParamWithEvent( i, m_defaultUIValues[i] );
		}
	}

	private function CreateCameraLocationSaveString() : string
	{
		var cameraWorldPosition : Vector;
		var cameraWorldRotation : EulerAngles;
		var playerWorldRotation : EulerAngles;

		var posDiff : Vector;
		var playerRotationYawRadian : float;

		var relativePos : Vector;
		var relativeYaw : float;

		var saveString : string;

		cameraWorldPosition = theGame.GetPhotomodeCamera().GetCameraWorldPosition();
		cameraWorldRotation = theGame.GetPhotomodeCamera().GetCameraWorldRotation();
		playerWorldRotation = thePlayer.GetWorldRotation();

		posDiff = cameraWorldPosition - thePlayer.GetWorldPosition();
		playerRotationYawRadian = playerWorldRotation.Yaw * ( Pi() / 180.f );

		relativePos.X = CosF( playerRotationYawRadian ) * posDiff.X + SinF( playerRotationYawRadian ) * posDiff.Y;
		relativePos.Y = -SinF( playerRotationYawRadian ) * posDiff.X + CosF( playerRotationYawRadian ) * posDiff.Y;
		relativePos.Z = posDiff.Z;

		relativeYaw = cameraWorldRotation.Yaw - playerWorldRotation.Yaw;

		saveString = VecToString( relativePos ) + "|" + FloatToString( relativeYaw ) + "|" + EulerAnglesToString( cameraWorldRotation );

		return saveString;
	}

	private function CreateNewCameraLocationSave()
	{
		var locationId : int;	
		var slotId : int;		

		locationId = FindFirstEmptyLocationId();
		slotId = locationId + 1;

		if ( locationId < 0 )
			return; 	

		SaveCameraLocationToConfig( locationId );

		RefreshLocationPresetsUI( false, slotId );
	}

	private function SaveCameraLocationToSlot( slotId : int )
	{
		var locationId : int;

		locationId = GetLocationIdFromSlot( slotId );

		if ( locationId < 0 )
		{
			
			CreateNewCameraLocationSave();
			return;
		}

		SaveCameraLocationToConfig( locationId );

		RefreshLocationPresetsUI( false, slotId );
	}

	private function SaveCameraLocationToConfig( locationId : int )
	{
		var saveString : string;
		var varName : string;
		var timestamp : int;

		saveString = CreateCameraLocationSaveString();

		varName = "PhotomodePreset" + FloatToString( m_UIValues[PM_Camera_Preset] ) + "Location" + FloatToString( locationId );
		theGame.GetInGameConfigWrapper().SetRawConfigValueByStr( "PhotomodePresets", varName, saveString );

		m_locationPresets[locationId] = saveString;
	}

	private function LoadCameraLocationFromString( saveString: string )
	{
		var value : string;

		var savedRelativePos : Vector;
		var savedRelativeYaw : float;
		var savedCameraWorldRotation : EulerAngles;

		var playerRotationYawRadian : float;
		var cameraWorldRotation : EulerAngles;
		var playerWorldRotation : EulerAngles;

		var posDiff : Vector;
		var newWorldPos : Vector;
		var newRotation : EulerAngles;

		StrSplitFirst( saveString, "|", value, saveString );
		savedRelativePos = StringToVector( value );

		StrSplitFirst( saveString, "|", value, saveString );
		savedRelativeYaw = StringToFloat( value );
		savedCameraWorldRotation = StringToEulerAngles( saveString );

		playerWorldRotation = thePlayer.GetWorldRotation();
		playerRotationYawRadian = playerWorldRotation.Yaw * ( Pi() / 180.f );

		posDiff.X = CosF( playerRotationYawRadian ) * savedRelativePos.X - SinF( playerRotationYawRadian ) * savedRelativePos.Y;
		posDiff.Y = SinF( playerRotationYawRadian) * savedRelativePos.X + CosF( playerRotationYawRadian ) * savedRelativePos.Y;
		posDiff.Z = savedRelativePos.Z;
		newWorldPos = thePlayer.GetWorldPosition() + posDiff;
	
		m_targetCameraPosition = newWorldPos;

		cameraWorldRotation = theGame.GetPhotomodeCamera().GetCameraWorldRotation();
		newRotation.Pitch = savedCameraWorldRotation.Pitch;
		newRotation.Roll = cameraWorldRotation.Roll; 
		newRotation.Yaw = savedRelativeYaw + playerWorldRotation.Yaw;

		m_targetCameraRotation = newRotation;

		m_cameraBlendInProgress = true;
		m_cameraPositionDamper.Init(theGame.GetPhotomodeCamera().GetCameraWorldPosition(), m_targetCameraPosition);
		m_cameraRotationDamper.Init(cameraWorldRotation, m_targetCameraRotation);
		theGame.GetPhotomodeCamera().SetNoclip( true );
		theGame.SetPhotomodeCameraCanMove(CanPhotomodeCameraMove());
	}

	private function DeleteCameraLocation( presetId : int, slot : int )
	{
		var varName : string;
		var locationId : int;

		locationId = m_locationSlotToId[(int)slot];

		varName = "PhotomodePreset" + IntToString( presetId ) + "Location" + IntToString( locationId );
		theGame.GetInGameConfigWrapper().SetRawConfigValueByStr( "PhotomodePresets", varName, "" );

		m_locationPresets[(int) locationId] = "";

		RefreshLocationPresetsUI( true );
	}

	private function SaveCurrentCameraPosition( out pos : Vector, out rot : EulerAngles )
	{
		pos = theGame.GetPhotomodeCamera().GetCameraWorldPosition();
		rot = theGame.GetPhotomodeCamera().GetCameraWorldRotation();
	}

	private function RestoreNoneLocationPreset()
	{
		var rot : EulerAngles = m_noLocationPresetRot;

		if ( m_UIValues.Contains( PM_Camera_Tilt ) )
			rot.Roll = m_UIValues[PM_Camera_Tilt];
		else
			rot.Roll = m_defaultUIValues[PM_Camera_Tilt];

		m_targetCameraPosition = m_noLocationPresetPos;
		m_targetCameraRotation = rot;

		m_cameraBlendInProgress = true;
		m_cameraPositionDamper.Init(theGame.GetPhotomodeCamera().GetCameraWorldPosition(), m_targetCameraPosition);
		m_cameraRotationDamper.Init(theGame.GetPhotomodeCamera().GetCameraWorldRotation(), m_targetCameraRotation);
		theGame.GetPhotomodeCamera().SetNoclip( true );
		theGame.SetPhotomodeCameraCanMove(CanPhotomodeCameraMove());
	}

	private function GetLocationPresets( presetId : float, out locations : array<string> )
	{
		var i : int;
		var varName : string;
		var val : string;

		locations.Clear();

		for ( i = 0; i < m_maxLocationSlots; i = i + 1 )
		{
			varName = "PhotomodePreset" + FloatToString( presetId ) + "Location" + IntToString( i );
			val = theGame.GetInGameConfigWrapper().GetRawConfigValueByStr( "PhotomodePresets", varName );
			locations.PushBack( val );
		}
	}

	private function RefreshLocationPresets( optional setToNone : bool, optional defaultLocationId : int )
	{
		GetLocationPresets( m_UIValues[PM_Camera_Preset], m_locationPresets );

		RefreshLocationPresetsUI( setToNone, defaultLocationId );
	}

	private function RefreshLocationPresetsUI( optional setToNone : bool, optional defaultSlotId : int )
	{
		var i : int;
		var slotCounter : int;

		var stringsArray : array<string>;
		var extraParams : SPhotomodeRendererExtraParams;

		var elemObj : CScriptedFlashObject;

		stringsArray.PushBack(GetLocStringByKeyExt("input_device_key_name_IK_none"));
		for ( i = 0; i < m_locationPresets.Size(); i = i + 1 )
		{
			if ( StrLen( m_locationPresets[i] ) )
			{
				slotCounter = slotCounter + 1;

				stringsArray.PushBack( IntToString( slotCounter ) );
				m_locationSlotToId[slotCounter] = i;
			}
		}

		extraParams.m_callbackFunctionName = "OnRequestFakeTick";
		extraParams.m_callbackDelay = 0.01;

		elemObj = CreateStringSelector( PM_Camera_Location, "photomode_params_camera_location", stringsArray, defaultSlotId, extraParams, true );
		QueueOverrideElement( elemObj, PM_Camera_Location );

		m_UIValues[PM_Camera_Location] = defaultSlotId;
	}

	private function FindFirstEmptyLocationId() : int
	{
		var i : int;

		for ( i = 0; i < m_locationPresets.Size(); i = i + 1 )
		{
			if ( StrLen( m_locationPresets[i] ) == 0 )
				return i;
		}

		return -1; 
	}

	private function GetLocationIdFromSlot( slot : int ) : int
	{
		if ( !m_locationSlotToId.Contains( slot ) )
			return -1;

		return m_locationSlotToId[slot];
	}

	event  OnTick(timeDelta : float)
	{
		var cameraPosition : Vector = theGame.GetPhotomodeCamera().GetWorldPosition();
		var cameraRotation : EulerAngles = theGame.GetPhotomodeCamera().GetWorldRotation();
		var finalSpawnLocation : Vector;
		var finalSpawnRotation : EulerAngles;

		m_fxSetCoords.InvokeSelfThreeArgs(FlashArgNumber(cameraPosition.X), FlashArgNumber(cameraPosition.Y), FlashArgNumber(cameraPosition.Z));

		UpdateSpawnedCharactersTransformsIfNeeded(cameraPosition, cameraRotation, timeDelta);
		UpdateSpawnedPropTransformsIfNeeded(cameraPosition, cameraRotation, timeDelta);

		if (m_cameraBlendInProgress)
		{
			BlendCameraTransform(cameraPosition, cameraRotation, timeDelta);
		}

		if (m_isCharacterSelected && m_selectedCharValid)
		{
			UpdateCharacterHighlightPosition();
		}

		if (m_queuedOverrideElements.GetLength() > 0)
		{
			ProcessQueuedOverrideElements();
		}

		if (m_queuedCharUpdate)
		{
			m_queuedCharUpdate = false;
			RecalculateCharacterHighlightPosition();
			UpdateCharacterHighlightPosition();
		}

		if (m_queuedFakeTickN > 0)
		{
			m_queuedFakeTickN -= 1;
			DoFakeTick();
			if (m_queuedFakeTickN == 0)
			{
				if (m_queuedSpawnedCharacterVisibility)
				{
					m_queuedSpawnedCharacterVisibility = false;
					m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_actor.SetVisibility( true );
					PlayCurrentAnimation();
					if (m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_disableGravity)
					{
						finalSpawnLocation = GetSpawnLocation(m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_actor, true);
						m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_location = finalSpawnLocation;
						finalSpawnLocation = finalSpawnLocation + m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_relativeLocation;
						finalSpawnRotation = m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_rotation;
						finalSpawnRotation.Yaw += m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_relativeRotation;
						m_spawnedCharactersBySlot[m_currentCharacterSlotId].m_actor.TeleportWithRotation(finalSpawnLocation, finalSpawnRotation);
						m_selectedSpawnedCharacter = m_spawnedCharactersBySlot[m_currentCharacterSlotId];
					}
				}

				if (m_queuedSpawnedPropVisibility)
				{
					m_queuedSpawnedPropVisibility = false;
					if (m_spawnedPropsBySlot[m_currentPropSlotId].m_disableGravity)
					{
						finalSpawnLocation = GetSpawnLocation(m_spawnedPropsBySlot[m_currentPropSlotId].m_entity, true);
						m_spawnedPropsBySlot[m_currentPropSlotId].m_location = finalSpawnLocation;
						finalSpawnLocation = finalSpawnLocation + m_spawnedPropsBySlot[m_currentPropSlotId].m_relativeLocation;
						finalSpawnRotation = m_spawnedPropsBySlot[m_currentPropSlotId].m_rotation;
						finalSpawnRotation.Yaw += m_spawnedPropsBySlot[m_currentPropSlotId].m_relativeRotation;
						m_spawnedPropsBySlot[m_currentPropSlotId].m_entity.TeleportWithRotation(finalSpawnLocation, finalSpawnRotation);
						m_selectedSpawnedProp = m_spawnedPropsBySlot[m_currentPropSlotId];
					}
				}

				if (m_queuedSelectedCharacterVisibility)
				{
					m_queuedSelectedCharacterVisibility = false;
					m_selectedCharacter.SetVisibility(true);
				}

				if (m_queuedReapplyAnimation)
				{
					m_queuedReapplyAnimation = false;
					PlayCurrentAnimation();
				}
			}
		}

		m_lastCameraPosition = cameraPosition;
		m_lastCameraRotation = cameraRotation;
	}

	event  OnExitPhotomode()
	{
		thePlayer.GetPhotomodeManager().DisablePhotomode();
	}
	
	event  OnRequestCursor(val : bool)
	{
		
		if (m_isCursorVisible && val)
			return false;

		theGame.GetGuiManager().RequestMouseCursor(val);
		m_isCursorVisible = val;
	}
	
	event  OnRequestResetCursorPos(val : bool)
	{
		if(val)
			theGame.MoveMouseTo(m_lastMouseX,m_lastMouseY);
	}
	
	event  OnSaveLastMouseCoords(x : float, y : float)
	{
		m_lastMouseX = x / 1920;
		m_lastMouseY = y / 1080;
		LogChannel('PHOTOMODE', "Test");
	}
	
	event  OnSetCameraDraggable(val : bool)
	{
		m_cameraDraggable = val;

		theGame.SetPhotomodeCameraCanMove(CanPhotomodeCameraMove());
	}
	
	event  OnSwapLockCamera()
	{
		m_cameraLocked = !m_cameraLocked;

		theGame.SetPhotomodeCameraCanMove(CanPhotomodeCameraMove());
	}

	event  OnPhotomodeTabChanged(index : int)
	{
		
		if (m_lastPhotomodeTab == index || index == 0)
			return false;

		m_lastPhotomodeTab = index;
		LogChannel('PHOTOMODE', "OnPhotomodeTabChanged: " + IntToString(index));

		switch(index)
		{
			case 2:
				m_selectedCharacter = m_selectedCharacter_World;
				m_selectedCharValid = m_selectedCharValid_World;
				OnCharacterChanged();
				EnableCharacterHighlight(m_selectedCharValid);
				m_queuedCharUpdate = true;
				break;
			case 3:
				m_selectedCharacter = m_selectedCharacter_Spawned;
				m_selectedCharValid = m_selectedCharValid_Spawned;
				PostSelectCharacterBySlot();
				break;
			default:
				break;
		}
	}

	event  OnTryClosingMenu()
	{
		if (m_photoModeState != PMS_TabSelection)
		{
			UpdatePhotoModeState(PMS_TabSelection);
			return true;
		}

		if(HaveChangesBeenMade())
			ShowExitPopup();
		else
			OnConfirmExit();
	}
}

exec function fakeskipframe()
{
	thePlayer.GetPhotomodeManager().DoFakeTick();
}

exec function setPmAspect(custom:bool,x:int,y:int)
{
	theGame.GetPhotomodeEffects().SetPhotomodeCustomAspect(custom,x,y);
}