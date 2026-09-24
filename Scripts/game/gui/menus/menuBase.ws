/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SMenuButtonDef
{
	var NavigationCode : string;
	var LocalisationKey : string;
	var enabled : bool;
}

struct SKeyBinding
{
	var ActionID		 : int;
	var LocalizationKey  : string;
	var Gamepad_NavCode  : string;
	var Keyboard_KeyCode : int;
	var Enabled 		 : bool;
	var IsLocalized		 : bool;
	var IsHold           : bool;
}

enum ENotificationType
{
	NT_Info,
	NT_Warning
}

class CR4MenuBase extends CR4Menu
{
	
	
	
	protected var m_flashValueStorage 	 		: CScriptedFlashValueStorage;
	protected var m_flashModule     	 		: CScriptedFlashSprite;
	protected var m_parentMenu  		 		: CR4MenuBase;
	protected var m_fxBlurLayer 		 		: CScriptedFlashFunction;
	protected var m_fxSetState			 		: CScriptedFlashFunction;
	protected var m_fxSetColorBlindMode  		: CScriptedFlashFunction;
	protected var m_fxSetCurrentModule  		: CScriptedFlashFunction;
	protected var m_fxSetIsInCombat				: CScriptedFlashFunction;
	protected var m_fxShowSecondaryModulesSFF 	: CScriptedFlashFunction;
	protected var m_fxSetArabicAligmentMode  	: CScriptedFlashFunction;
	protected var m_fxSetGameLanguage			: CScriptedFlashFunction;
	protected var m_fxSetRestrictDirectClosing	: CScriptedFlashFunction;
	protected var m_fxSwapAcceptCancel			: CScriptedFlashFunction;
	
	protected var m_fxSetControllerType  		: CScriptedFlashFunction;
	protected var m_fxSetPlatform       		: CScriptedFlashFunction;
	protected var m_fxSetGamepadType       		: CScriptedFlashFunction;
	protected var m_fxLockControlScheme     	: CScriptedFlashFunction;
	protected var m_fxSetTooltipState			: CScriptedFlashFunction;
	
	protected var m_fxEnableDebugInput			: CScriptedFlashFunction;
	protected var m_fxSetPaperdollPreviewIcon  : CScriptedFlashFunction;
	
	protected var m_menuState			 : name;
	protected var m_notificationData 	 : W3TutorialPopupData;
	protected var m_currentContext 		 : W3UIContext;
	protected var m_defaultInputBindings : array<SKeyBinding>;
	protected var m_GFxInputBindings     : array<SKeyBinding>;
	protected var m_guiManager			 : CR4GuiManager;
	protected var m_commonMenu			 : CR4CommonMenu;
	protected var UISavedData	 		 : SUISavedData;
	
	protected var m_lastSelectedModule	 : int; default m_lastSelectedModule = 0;
	
	protected var mouseCursorType 		 : ECursorType;
	default mouseCursorType = CT_Default;
	
	protected var m_hideTutorial 		 : bool;
	protected var m_forceHideTutorial 	 : bool;
	protected var m_configUICalled		 : bool; default m_configUICalled = false;
	
	protected var m_initialSelectionsToIgnore : int; default m_initialSelectionsToIgnore = 1;
	
	protected var dontAutoCallOnOpeningMenuInOnConfigUIHaxxor : bool;		
																			
	
	
	
	event  OnConfigUI() 
	{
		var menuInitData   : W3MenuInitData;
		var defaultState   : name;
		var invMenu : CR4InventoryMenu;
		var commonMenu : CR4CommonMenu;
		var menuName : name;
		
		m_guiManager = theGame.GetGuiManager();
		
		m_flashValueStorage = GetMenuFlashValueStorage();
		m_flashModule = GetMenuFlash();
		
		m_fxSetControllerType = m_flashModule.GetMemberFlashFunction( "setControllerType" );
		m_fxSetPlatform = m_flashModule.GetMemberFlashFunction( "setPlatform" );
		
		m_fxBlurLayer 					= m_flashModule.GetMemberFlashFunction( "setBackgroundEffect" );
		m_fxSetState 					= m_flashModule.GetMemberFlashFunction( "setMenuState" );
		m_fxSetColorBlindMode 			= m_flashModule.GetMemberFlashFunction( "setColorBlindMode" );
		m_fxShowSecondaryModulesSFF		= m_flashModule.GetMemberFlashFunction( "ShowSecondaryModules" );
		m_fxSetCurrentModule 			= m_flashModule.GetMemberFlashFunction( "setCurrentModule" );
		m_fxSetArabicAligmentMode 		= m_flashModule.GetMemberFlashFunction( "setArabicAligmentMode" );
		m_fxSetGameLanguage				= m_flashModule.GetMemberFlashFunction( "setGameLanguage" );
		m_fxSetRestrictDirectClosing 	= m_flashModule.GetMemberFlashFunction( "setRestrictDirectClosing" );
		m_fxSwapAcceptCancel	 		= m_flashModule.GetMemberFlashFunction( "swapAcceptCancel" );
		m_fxSetGamepadType				= m_flashModule.GetMemberFlashFunction( "setGamepadType" );
		m_fxLockControlScheme			= m_flashModule.GetMemberFlashFunction( "lockControlScheme" );
		m_fxEnableDebugInput			= m_flashModule.GetMemberFlashFunction( "enableDebugInput" );
		m_fxSetTooltipState				= m_flashModule.GetMemberFlashFunction( "setTooltipState" );
		
		m_parentMenu = (CR4MenuBase)GetParent();
		
		menuInitData = (W3MenuInitData)GetMenuInitData();
		if (menuInitData)
		{
			defaultState = menuInitData.getDefaultState();
			if (defaultState != '')
			{
				SetMenuState(defaultState);
			}
		}
		
		GetSavedData();
		
		UpdateControlSchemeLock();
		SetControllerType(theInput.LastUsedGamepad());
		SetPlatformType(theGame.GetPlatform());
		UpdateAcceptCancelSwaping();
		UpdateInputDeviceType();
		
		
		
		PlayOpenSoundEvent();
		m_defaultInputBindings.Clear();
		SetButtons();
		
		if (m_hideTutorial)
		{
			SetTutorialVisibility(false, m_forceHideTutorial);
		}
		
		
		setColorBlindMode(theGame.getColorBlindMode());	
		setArabicAligmentMode();
		
		
		if( !dontAutoCallOnOpeningMenuInOnConfigUIHaxxor && theGame.GetTutorialSystem() && theGame.GetTutorialSystem().IsRunning() )		
		{
			invMenu = (CR4InventoryMenu)this;
			menuName = GetMenuName();
			
			
			if(invMenu)
			{
				if( (CNewNPC) ((W3InventoryInitData)GetMenuInitData()).containerNPC )
					menuName = 'ShopMenu';
			}
		
			theGame.GetTutorialSystem().uiHandler.OnOpeningMenu(menuName);
		}
		
		commonMenu = (CR4CommonMenu)m_parentMenu;
		
		if (commonMenu)
		{
			UpdateRestrictDirectClosing(commonMenu.IsLockedInMenu());
			commonMenu.ChildMenuConfigured();
		}
			
		m_configUICalled = true;
		
		if ( !theGame.IsFinalBuild() )
		{
			m_fxEnableDebugInput.InvokeSelf();
		}
	}
	
	event  OnTooltipScaleStateSave( isScaledUp : bool )
	{
		var player : CR4Player;
		
		player = thePlayer;
		player.upscaledTooltipState = isScaledUp;
	}
	
	event  OnFailedCreateMenu()
	{
	}
	
	event  OnClearSlotNewFlag(item : SItemUniqueId)
	{
	}
	
	public function UpdateRestrictDirectClosing(value:bool)
	{
		m_fxSetRestrictDirectClosing.InvokeSelfOneArg(FlashArgBool(value));
	}
	
	public function ActionBlockStateChange(action:EInputActionBlock, blocked:bool) : void
	{
	}
	
	protected function SetTutorialVisibility( value : bool, forced : bool ) : void
	{
		theGame.GetGuiManager().HideTutorial( !value, forced );
	}

	protected function SendCombatState()
	{
		if (!m_fxSetIsInCombat)
		{
			m_fxSetIsInCombat = m_flashModule.GetMemberFlashFunction( "setInCombat" );
		}
		
		m_fxSetIsInCombat.InvokeSelfOneArg(FlashArgBool(thePlayer.IsInCombat()));
	}
	
	protected function GetSavedData()
	{
		UISavedData = m_guiManager.GetUISavedData( GetSavedDataMenuName() );
	}
	
	protected function GetSavedDataMenuName() : name
	{
		return GetMenuName();
	}
	
	function OnRequestSubMenu( menuName: name, optional initData : IScriptable )
	{
		RequestSubMenu( menuName, initData );
	}
	
	protected function IsCategoryOpened( categoryName : name ) : bool
	{
		var i : int;
		for( i = 0; i < UISavedData.openedCategories.Size(); i += 1 )
		{
			if( UISavedData.openedCategories[i] == categoryName )
			{
				return true;
			}
		}
		return false;
	}
	
	protected function UpdateAcceptCancelSwaping():void
	{
		var inGameConfigWrapper : CInGameConfigWrapper;
		var configValue : bool;
		
		if (m_fxSwapAcceptCancel)
		{
			inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
			configValue = inGameConfigWrapper.GetVarValue('Controls', 'SwapAcceptCancel');
			m_fxSwapAcceptCancel.InvokeSelfOneArg( FlashArgBool(configValue) );
		}
	}
	
	protected function UpdateInputDeviceType():void
	{
		var deviceType : EInputDeviceType;
		
		if (m_fxSetGamepadType)
		{
			deviceType = theInput.GetLastUsedGamepadType();
			m_fxSetGamepadType.InvokeSelfOneArg( FlashArgUInt(deviceType) );
		}
	} 
	
	protected function UpdateControlSchemeLock():void
	{
		if (m_fxLockControlScheme && m_guiManager)
		{
			m_fxLockControlScheme.InvokeSelfOneArg( FlashArgUInt(m_guiManager.GetLockedControlScheme()) );
		}
	}
	
	public function UpdateInputDevice():void
	{
		var isGamepad:bool = theInput.LastUsedGamepad();
		
		SetControllerType(isGamepad);
	}
	
	protected function SetControllerType(isGamepad:bool):void
	{
		if (m_fxSetControllerType)	
		{
			m_fxSetControllerType.InvokeSelfOneArg( FlashArgBool(isGamepad) );
		}
	}
	
	public function SetPlatformType(platformType:Platform):void
	{
		if (m_fxSetPlatform)
		{
			m_fxSetPlatform.InvokeSelfOneArg( FlashArgInt(platformType) );
		}
	}
	
	protected function UpdateSceneEntityFromCreatureDataComponent( entity : CEntity )
	{
		var creatureDataComponent:CCreatureDataComponent;
		var environmentSunRotation : EulerAngles;
		var cameraLookAt : Vector;
		var cameraRotation : EulerAngles;
		var cameraDistance : float;
		var fov : float;
		var guiSceneController : CR4GuiSceneController;
		
		var entityPosition : Vector;
		var entityRotation : EulerAngles;
		var entityScale	: Vector;
	
		guiSceneController = theGame.GetGuiManager().GetSceneController();
		if ( guiSceneController )
		{
			creatureDataComponent = (CCreatureDataComponent)( entity.GetComponentByClassName( 'CCreatureDataComponent' ) );
			if (creatureDataComponent)
			{
				environmentSunRotation.Yaw   	= creatureDataComponent.GetEnvironmentSunRotationYaw();
				environmentSunRotation.Pitch 	= creatureDataComponent.GetEnvironmentSunRotationPitch();
				cameraLookAt.X 				 	= 0;
				cameraLookAt.Y               	= 0;
				cameraLookAt.Z               	= creatureDataComponent.GetCameraLookAtZ();
				cameraRotation.Yaw           	= creatureDataComponent.GetCameraRotationYaw();
				cameraRotation.Pitch         	= creatureDataComponent.GetCameraRotationPitch();
				cameraRotation.Roll			 	= 0;
				cameraDistance               	= creatureDataComponent.GetCameraDistance();
				fov 							= creatureDataComponent.getFov();
				
				entityPosition 					= creatureDataComponent.GetEntityPosition();
				entityRotation					= creatureDataComponent.GetEntityRotation();
				entityScale						= creatureDataComponent.getEntityScale();
				
				guiSceneController.SetEnvironmentAndSunRotation( "environment\definitions\novigrad\env_burning_village.env", environmentSunRotation );
				guiSceneController.SetCamera( cameraLookAt, cameraRotation, cameraDistance, fov );
				guiSceneController.SetEntityTransform(entityPosition, entityRotation, entityScale);
			}
		}
		
		m_flashValueStorage.SetFlashBool( "render.to.texture.texture.visible", true);
		m_flashValueStorage.SetFlashBool( "render.to.texture.loading", false );
	}
	
	protected function ShowRenderToTexture( targetName : string ) : void
	{
		var templateFilename : string;
		var appearance : name;
		var environmentFilename : string;
		var environmentSunRotation : EulerAngles;
		var cameraLookAt : Vector;
		var cameraRotation : EulerAngles;
		var cameraDistance : float;
		var fov : float;
		var guiSceneController : CR4GuiSceneController;
	
		guiSceneController = theGame.GetGuiManager().GetSceneController();
		
		m_flashValueStorage.SetFlashBool( "render.to.texture.texture.visible", false);
		
		if (targetName != "")
		{
			m_flashValueStorage.SetFlashBool( "render.to.texture.loading", true );
			
			templateFilename             = targetName;
			appearance                   = '';
			environmentSunRotation.Yaw   = 0;
			environmentSunRotation.Pitch = 0;
			cameraLookAt.Z               = 0.92;
			cameraRotation.Yaw           = 200;
			cameraRotation.Pitch         = 350;
			cameraDistance               = 3.2;
			fov 						 = 70.0f;
			
			guiSceneController.SetEntityTemplate( templateFilename );
			guiSceneController.SetCamera( cameraLookAt, cameraRotation, cameraDistance, fov );
			guiSceneController.SetEnvironmentAndSunRotation( "environment\definitions\novigrad\env_burning_village.env", environmentSunRotation );
			guiSceneController.SetEntityAppearance( appearance );
		}
	}
	
	function SetMenuNavigationEnabled(enabled:bool) : void
	{
		var commonMenuRef : CR4CommonMenu;
		commonMenuRef = theGame.GetGuiManager().GetCommonMenu();
		commonMenuRef.SetMenuNavigationEnabled(enabled);
	}
	
	function SetButtons()
	{
		var RootMenu : CR4CommonMenu;
		
		RootMenu = (CR4CommonMenu)GetRootMenu();
		if ( RootMenu )
		{
			RootMenu.UpdateDefaultButtons(m_defaultInputBindings, true);			
		}
	}
	
	event  OnMenuShown()
	{
		HandleMenuLoaded();
		
		if(theGame.GetTutorialSystem() && theGame.GetTutorialSystem().IsRunning())		
		{
			theGame.GetTutorialSystem().uiHandler.OnOpenedMenu(GetMenuName());
		}
	}
	
	public function showNotification( notificationText : string, optional duration : float, optional queue : bool ):void
	{
		theGame.GetGuiManager().ShowNotification( notificationText, duration, queue );
	}
	
	event  OnClosingMenu()
	{
		var overlayPopupRef  : CR4OverlayPopup;
		
		
		overlayPopupRef = (CR4OverlayPopup)theGame.GetGuiManager().GetPopup('OverlayPopup');
		if (overlayPopupRef)
		{
			overlayPopupRef.RemoveContextButtons(GetMenuName());
		}
		
		ResetContext();
		
		if(theGame.GetTutorialSystem() && theGame.GetTutorialSystem().IsRunning())		
		{
			theGame.GetTutorialSystem().uiHandler.OnClosingMenu(GetMenuName());
		}
		
		if (m_hideTutorial)
		{
			SetTutorialVisibility(true, m_forceHideTutorial);
		}
		
		if (mouseCursorType != CT_Default)
		{
			theGame.GetGuiManager().SetMouseCursorType( CT_Default );
		}
	}

	event OnCloseMenu() 
	{
		CloseMenu();
	}
	
	event OnChangedConstrainedState( entered : bool )
	{
	}

	function RestoreInput()
	{
		m_flashValueStorage.SetFlashBool("restore.input",true,-1);
	}	

	function SetParentMenu( menu : CR4MenuBase ) 
	{
		m_parentMenu = menu;
	}	

	function GetParentMenu() : CR4MenuBase 
	{
		return m_parentMenu;
	}
	
	event  OnBreakPoint( text : string )
	{
		LogChannel('GUIBreakpoint'," text "+text);
	}
	
	
	function UpdateButtons( ButtonsDef : array<SMenuButtonDef>)
	{}	

	
	function UpdateButton( ButtonDef : SMenuButtonDef, ID : int)
	{}
	
	
	protected function AddButtonDef(out targetList:array<SMenuButtonDef>, navCode:string, label:string)
	{
		var ButtonDef:SMenuButtonDef;
		ButtonDef.NavigationCode = navCode;
		ButtonDef.LocalisationKey = label;
		ButtonDef.enabled = true;
		targetList.PushBack(ButtonDef);
	}
	
	protected function AddInputBinding(label:string, padNavCode:string, optional keyboardKeyCode:int)
	{
		var bindingDef:SKeyBinding;
		bindingDef.Gamepad_NavCode = padNavCode;
		bindingDef.Keyboard_KeyCode = keyboardKeyCode;
		bindingDef.LocalizationKey = label;
		m_defaultInputBindings.PushBack(bindingDef);
	}
	
	public function setColorBlindMode(value:bool) : void
	{
		if (m_fxSetColorBlindMode)
		{
			m_fxSetColorBlindMode.InvokeSelfOneArg( FlashArgBool(value) );
		}
	}
	
	public function setArabicAligmentMode() : void
	{
		var language : string;
		var audioLanguage : string;
		theGame.GetGameLanguageName(audioLanguage,language);
		if (m_fxSetArabicAligmentMode)
		{
			m_fxSetArabicAligmentMode.InvokeSelfOneArg( FlashArgBool( (language == "AR") ) );
		}
		if ( m_fxSetGameLanguage )
		{
			m_fxSetGameLanguage.InvokeSelfOneArg( FlashArgString( language ) );
		}
	}
	
	
	
	public function GetLastChild():CR4MenuBase
	{
		var subMenu:CR4MenuBase;
		
		subMenu = (CR4MenuBase)GetSubMenu();
		if (subMenu)
		{
			return subMenu.GetLastChild();
		}
		else
		{
			return this;
		}
	}
	
	public function SetMenuState(newState : name) : void
	{
		m_menuState = newState;
		m_fxSetState.InvokeSelfOneArg( FlashArgString(newState) );
	}
	
	public function RefreshMenuState():void
	{
		m_fxSetState.InvokeSelfOneArg( FlashArgString(m_menuState) );
	}
	
	public function BlurLayer(value : bool)
	{
		m_fxBlurLayer.InvokeSelfOneArg( FlashArgBool(value) );
	}
	
	protected function HandleMenuLoaded():void
	{
		var RootMenu : CR4CommonMenu;
		
		RootMenu = (CR4CommonMenu)GetRootMenu();
		if ( RootMenu )
		{
			RootMenu.ShowBackground(false);
		}
	}
	
	protected function ActivateContext(targetContext:W3UIContext):void
	{
		var RootMenu : CR4CommonMenu;
		
		RootMenu = (CR4CommonMenu)GetRootMenu();
		if ( RootMenu )
		{
			RootMenu.m_contextManager.ActivateContext(targetContext);
		}
	}
	
	protected function ResetContext():void
	{
		if (m_currentContext)
		{
			m_currentContext.Deactivate();
			delete m_currentContext;
			m_currentContext = NULL;
		}
	}
	
	protected function GetRootMenu():CR4MenuBase
	{
		var curParent : CR4MenuBase;
		curParent = (CR4MenuBase)GetParent();
		if (curParent)
		{
			return curParent.GetRootMenu();
		}
		else
		{
			return this;
		}
	}	
	
	function ChildRequestCloseMenu()
	{
	}	
	
	event OnPlaySoundEvent( soundName : string )
	{
		if (soundName == "gui_global_highlight")
		{
			if (m_initialSelectionsToIgnore == 0)
			{
				theSound.SoundEvent( soundName );
			}
			else
			{
				m_initialSelectionsToIgnore -= 1;
			}
		}
		else
		{
			theSound.SoundEvent( soundName );
		}
	}
	
	function PlayOpenSoundEvent()
	{
		OnPlaySoundEvent("gui_global_panel_open");	
	}
	
	event  OnMoveMouseTo( valueX : float, valueY : float ):void
	{
		theGame.MoveMouseTo(valueX, valueY);
	}
	
	event  OnSetMouseCursorVisibility( value : bool ):void
	{
		theGame.GetGuiManager().ForceHideMouseCursor( !value );
	}
	
	event  OnSetMouseCursorType( value : int ):void
	{	
		mouseCursorType = value;
		theGame.GetGuiManager().SetMouseCursorType( value );
	}
	
	event  OnSendNotification(locKey:string)
	{
		showNotification( GetLocStringByKeyExt( locKey ) );
		
		if( locKey == "menu_cannot_perform_action_combat" ) 
		{
			OnPlaySoundEvent( "gui_global_denied" );
		}
	}
	
	event  OnModuleSelected( moduleID : int, moduleBindingName : string )
	{
		
		if (m_lastSelectedModule !=  moduleID)
		{
			OnPlaySoundEvent("gui_global_highlight");
		}
		
		m_lastSelectedModule = moduleID;
		
		LogChannel('OnModuleSelected',GetMenuName()+" UISavedData.selectedModule "+UISavedData.selectedModule+" vs moduleID "+moduleID);
		UISavedData.selectedModule = moduleID;
	}
	
	event  OnAppendButton(actionId:int, gamepadNavCode:string, keyboardKeyCode:int, label:string):void
	{
		var overlayPopupRef  : CR4OverlayPopup;
		overlayPopupRef = (CR4OverlayPopup)theGame.GetGuiManager().GetPopup('OverlayPopup');
		if (overlayPopupRef)
		{
			overlayPopupRef.AppendButton(actionId, gamepadNavCode, keyboardKeyCode, label, GetMenuName());
		}
	}
	
	event  OnRemoveButton(actionId:int)
	{
		var overlayPopupRef  : CR4OverlayPopup;
		overlayPopupRef = (CR4OverlayPopup)theGame.GetGuiManager().GetPopup('OverlayPopup');
		if (overlayPopupRef)
		{
			overlayPopupRef.RemoveButton(actionId, GetMenuName());
		}
	}
	
	event  OnCleanupButtons()
	{
		var overlayPopupRef  : CR4OverlayPopup;
		overlayPopupRef = (CR4OverlayPopup)theGame.GetGuiManager().GetPopup('OverlayPopup');
		if (overlayPopupRef)
		{
			overlayPopupRef.RemoveContextButtons(GetMenuName());
		}
	}
	
	event  OnUpdateGFxButtonsList()
	{
		var commonMenuRef : CR4CommonMenu;
		
		commonMenuRef = GetCommonMenu();		
		if (commonMenuRef)
		{
			commonMenuRef.UpdateGFxButtons(m_GFxInputBindings, true);
		}
	}
	
	event  OnAppendGFxButton(actionId:int, gamepadNavCode:String, keyboardKeyCode:int, label:String, holdPrefix:bool)
	{
		var newButtonDef:SKeyBinding;
		
		RemoveGFxButtonById(actionId);
		newButtonDef.ActionID = actionId;
		newButtonDef.Gamepad_NavCode = gamepadNavCode;
		newButtonDef.Keyboard_KeyCode = keyboardKeyCode;
		
		if (holdPrefix)
		{
			newButtonDef.LocalizationKey = GetHoldLabel() + " " + GetLocStringByKeyExt(label);
			newButtonDef.IsLocalized = true;
			newButtonDef.IsHold = true;			
		}
		else
		{
			newButtonDef.LocalizationKey = label;
		}
		m_GFxInputBindings.PushBack(newButtonDef);
	}
	
	
	event  OnRemoveGFxButton(actionId:int)
	{
		RemoveGFxButtonById(actionId);
	}
	
	protected function RemoveGFxButtonById(actionId:int):void
	{
		var idx, len:int;
		
		len = m_GFxInputBindings.Size();
		for (idx = 0; idx < len; idx+=1)
		{
			if (m_GFxInputBindings[idx].ActionID == actionId)
			{
				m_GFxInputBindings.Erase(idx);
				return;
			}
		}
	}
	
	protected function SelectCurrentModule()
	{
		m_fxSetCurrentModule.InvokeSelfOneArg(FlashArgInt(UISavedData.selectedModule));
	}
	
	protected function SelectFirstModule()
	{
		m_fxSetCurrentModule.InvokeSelfOneArg(FlashArgInt(0));
	}
	
	event  OnInputHandled(NavCode:string, KeyCode:int, ActionId:int) 
	{
		LogChannel('GUIWARNING', "Unecesary call of OnInputHandled NavCode "+NavCode+" KeyCode "+KeyCode);
	}
	
	
	function Event_OnGuiSceneEntitySpawned()
	{
		var guiSceneController : CR4GuiSceneController;

		guiSceneController = theGame.GetGuiManager().GetSceneController();
		if ( guiSceneController )
		{
			guiSceneController.OnGuiSceneEntitySpawned();
		}
	}

	
	function Event_OnGuiSceneEntityDestroyed()
	{
		var guiSceneController : CR4GuiSceneController;
		
		guiSceneController = theGame.GetGuiManager().GetSceneController();
		if ( guiSceneController )
		{
			guiSceneController.OnGuiSceneEntityDestroyed();
		}
	}
	
	protected function GetCommonMenu():CR4CommonMenu
	{
		if (!m_commonMenu)
		{
			m_commonMenu = theGame.GetGuiManager().GetCommonMenu();
		}
		return m_commonMenu;
	}
	
	protected function GetNpcInfo( npcEntity : CGameplayEntity, out dataObject : CScriptedFlashObject ) : void
	{
		var l_craftsmanComponent    : W3CraftsmanComponent;
		var l_craftsmanLevel		: ECraftsmanLevel;
		var l_craftsmanType			: ECraftsmanType;		
		var l_craftsmanLevelName	: string;
		
		var l_merchantComponent		: W3MerchantComponent;
		var l_merchantType			: string;
		var l_merchantMoney			: int;
		var l_merchantMapPinType	: name;
		
		if (!npcEntity)
		{
			return;
		}
		
		l_merchantMoney = npcEntity.GetInventory().GetMoney();
		dataObject.SetMemberFlashInt("money", l_merchantMoney);
		l_craftsmanType = ECT_Undefined;
		l_merchantComponent = (W3MerchantComponent)npcEntity.GetComponentByClassName('W3MerchantComponent');
		if (l_merchantComponent)
		{
			l_merchantMapPinType = l_merchantComponent.GetMapPinType();
			switch( l_merchantMapPinType )
			{
				case 'Shopkeeper':
					l_merchantType = "map_location_shopkeeper";
					l_craftsmanType = ECT_Undefined;
					break;
				case 'Blacksmith':
					l_merchantType = "map_location_blacksmith";
					l_craftsmanType = ECT_Smith;
					break;
				case 'Armorer':
					l_merchantType = "Armorer";
					l_craftsmanType = ECT_Armorer;
					break;
				case 'Herbalist':
					l_merchantType = "Herb_Dealer";
					l_craftsmanType = ECT_Enchanter;
					break;
				case 'Alchemist':
					l_merchantType = "map_location_alchemic";
					l_craftsmanType = ECT_Enchanter;
					break;
				case 'Enchanter':
					l_merchantType = "panel_map_enchanter_pin_name";
					l_craftsmanType = ECT_Enchanter;
					break;
				default:
					l_merchantType = "map_location_shopkeeper";
			}
			dataObject.SetMemberFlashString("typeName", GetLocStringByKeyExt(l_merchantType));
			dataObject.SetMemberFlashString("type", NameToString(l_merchantMapPinType));
		}
		
		l_craftsmanComponent = (W3CraftsmanComponent)npcEntity.GetComponentByClassName('W3CraftsmanComponent');
		if (l_craftsmanComponent)
		{
			l_craftsmanLevel = l_craftsmanComponent.GetCraftsmanLevel(l_craftsmanType); 
			switch( l_craftsmanLevel )
			{
				case ECL_Journeyman:
					l_craftsmanLevelName = GetLocStringByKeyExt("panel_shop_crating_level_journeyman");
					break;
				case ECL_Master:
					l_craftsmanLevelName = GetLocStringByKeyExt("panel_shop_crating_level_master");
					break;
				case ECL_Grand_Master:
					l_craftsmanLevelName = GetLocStringByKeyExt("panel_shop_crating_level_grand_master");
					break;
				case ECL_Arch_Master:
					l_craftsmanLevelName = GetLocStringByKeyExt("panel_shop_crating_level_arch_master");
					break;
				default:
					l_craftsmanLevelName = "";
			}
			dataObject.SetMemberFlashString("level", l_craftsmanLevelName);
		}
	}
	
}