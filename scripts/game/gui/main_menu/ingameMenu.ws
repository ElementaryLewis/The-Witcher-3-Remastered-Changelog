/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum InGameMenuActionType
{
	IGMActionType_CommonMenu 		= 0,
	IGMActionType_Close		 		= 1,
	IGMActionType_MenuHolder 		= 2,
	IGMActionType_MenuLastHolder	= 3,
	IGMActionType_Load 				= 4,
	IGMActionType_Save 				= 5,
	IGMActionType_Quit			 	= 6,
	IGMActionType_Preset 			= 7,
	IGMActionType_Toggle 			= 8,
	IGMActionType_List 				= 9,
	IGMActionType_Slider 			= 10,
	IGMActionType_LoadLastSave 		= 11,
	IGMActionType_Tutorials 		= 12,
	IGMActionType_Credits 			= 13,
	IGMActionType_Help 				= 14,
	IGMActionType_Controls 			= 15,
	IGMActionType_ControllerHelp 	= 16,
	IGMActionType_NewGame 			= 17,
	IGMActionType_CloseGame 		= 18,
	IGMActionType_UIRescale 		= 19,
	IGMActionType_Gamma 			= 20,
	IGMActionType_DebugStartQuest 	= 21,
	IGMActionType_Gwint 			= 22,
	IGMActionType_ImportSave 		= 23,
	IGMActionType_KeyBinds 			= 24,
	IGMActionType_Back				= 25,
	IGMActionType_NewGamePlus		= 26,
	IGMActionType_InstalledDLC		= 27,
	IGMActionType_Button			= 28,
	IGMActionType_ToggleRender		= 29,
	IGMActionType_ListWithCondition = 32,
	IGMActionType_Stepper			= 33,
	IGMActionType_ToggleStepper		= 34,
	IGMActionType_Separator			= 35,
	IGMActionType_SubtleSeparator	= 36,	
	IGMActionType_PurchaseEP1		= 37,
	IGMActionType_PurchaseEP2		= 38,	
	IGMActionType_ModMenu			= 39,
	IGMActionType_ReplayTutorial	= 40,	
	IGMActionType_SwitchFeatures 	= 41,
	IGMActionType_LeaveTutorial 	= 42,

	IGMActionType_PatchNotes		= 44,

	IGMActionType_Options 			= 100
};

enum AccessibilityPresets
{
	AP_None=0 ,
	AP_BardsTale=1,
	AP_Custom=2,
}

enum GERR 
{
        GOGNoInternetConnection = 0,
        RewardsTemporaryFail = 1,
        RewardsRequestFailed = 2,
		QRCodeTemporaryFail=  3,
		QRCodeRequestFailed = 4 
};
           

enum EIngameMenuConstants
{
	IGMC_Difficulty_mask	= 	7,   
	IGMC_Tutorials_On		= 	1024,
	IGMC_Simulate_Import 	= 	2048,
	IGMC_Import_Save		= 	4096,
	IGMC_EP1_Save			=   8192,
	IGMC_New_game_plus		=   16384,
	IGMC_EP2_Save			=   32768,

	IGMC_BardsBallad_On		=   131072,
}

struct newGameConfig
{
	var tutorialsOn : bool;
	var difficulty : int;
	var simulate_import : bool;
	var import_save_index : int;
	var bardsBalladOn : bool;
}


function UpdateAO2CorrespondRT(RTEnabled: bool, justValidate: bool)
{
	var inGameConfigWrapper	: CInGameConfigWrapper;
	inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		
	if( RTEnabled )
	{
		if ((justValidate && StringToInt(inGameConfigWrapper.GetVarValue('PostProcess', 'Virtual_SSAOSolution')) == IGMOPT_AO_SSAO)
		 ||(!justValidate && StringToInt(inGameConfigWrapper.GetVarValue('PostProcess', 'Virtual_SSAOSolution')) != IGMOPT_AO_NRDRTAO)) 
		{
			inGameConfigWrapper.SetVarValue('PostProcess', 'Virtual_SSAOSolution', IntToString(IGMOPT_AO_NRDRTAO));
		}
	} else {
		if(StringToInt(inGameConfigWrapper.GetVarValue('PostProcess', 'Virtual_SSAOSolution')) >= IGMOPT_AO_RTAO)
		{
			inGameConfigWrapper.SetVarValue('PostProcess', 'Virtual_SSAOSolution', IntToString(IGMOPT_AO_SSAO));
		}
	}
}
	
class CR4IngameMenu extends CR4MenuBase
{
	protected var mInGameConfigWrapper	: CInGameConfigWrapper;
	protected var inGameConfigBufferedWrapper : CInGameConfigBufferedWrapper;
	
	protected var currentNewGameConfig 	: newGameConfig;
	
	private var m_fxNavigateBack		: CScriptedFlashFunction;
	private var m_fxSetIsMainMenu		: CScriptedFlashFunction;
	private var m_fxSetCurrentUsername  : CScriptedFlashFunction;
	private var m_fxSetVersion			: CScriptedFlashFunction;
	private var m_fxShowHelp			: CScriptedFlashFunction;
	private var m_fxSetVisible			: CScriptedFlashFunction;
	private var m_fxSetPanelMode		: CScriptedFlashFunction;
	private var m_fxRemoveOption		: CScriptedFlashFunction;
	private var m_fxSetGameLogoLanguage	: CScriptedFlashFunction;
	private var m_fxUpdateOptionValue	: CScriptedFlashFunction;
	private var m_fxUpdateOptionLabel	: CScriptedFlashFunction;
	private var m_fxUpdateInputFeedback	: CScriptedFlashFunction;
	private var m_fxOnSaveScreenshotRdy : CScriptedFlashFunction;
	private var m_fxOnSetModioBorderVis : CScriptedFlashFunction;
	private var m_fxSetIgnoreInput		: CScriptedFlashFunction;
	private var m_fxUpdateSaveSlot		: CScriptedFlashFunction;
	private var m_fxForceEnterCurEntry	: CScriptedFlashFunction;
	private var m_fxForceBackgroundVis	: CScriptedFlashFunction;
	private var m_fxSetHardwareCursorOn : CScriptedFlashFunction;
	private var m_fxSetExpansionText	: CScriptedFlashFunction;
	private	var m_fxUpdateAnchorsAspectRatio : CScriptedFlashFunction;
	private var m_fxQRCodeReadyToLoad	: CScriptedFlashFunction;
	private var m_fxShowCloudModal      : CScriptedFlashFunction;
	private var m_fxCloseGalaxySignInModalWindow: CScriptedFlashFunction;
	private var m_fxSetDLSSIsSupported	: CScriptedFlashFunction;
	private var m_fxSetXESSIsSupported	: CScriptedFlashFunction;
	private var m_fxSetRTEnabled		: CScriptedFlashFunction;
	private var m_fxHideErrorWindow		: CScriptedFlashFunction;
	private var m_fxShowModioLoadIndicator	: CScriptedFlashFunction;
	private var m_fxHandleImageLoaded			: CScriptedFlashFunction;

	private var m_fxOunceUseStyle			: CScriptedFlashFunction;
	private var m_fxUpdateBardsBalladText  : CScriptedFlashFunction;
	private var m_fxShowTelemetryDataRequestPopup		: CScriptedFlashFunction;

	protected var loadConfPopup			: W3ApplyLoadConfirmation;
	protected var saveConfPopup			: W3SaveGameConfirmation;
	protected var newGameConfPopup		: W3NewGameConfirmation;
	protected var actionConfPopup		: W3ActionConfirmation;
	protected var deleteConfPopup		: W3DeleteSaveConf;
	protected var diffChangeConfPopup	: W3DifficultyChangeConfirmation;
	protected var isShowingSaveList		: bool; default isShowingSaveList = false;
	protected var isShowingLoadList		: bool; default isShowingLoadList = false;
	
	protected var smartKeybindingEnabled : bool; default smartKeybindingEnabled = true;
	
	public var m_structureCreator		: IngameMenuStructureCreator;
	
	protected var isInLoadselector		: bool; default isInLoadselector = false;
	protected var swapAcceptCancelChanged : bool; default swapAcceptCancelChanged = false;
	protected var alternativeRadialInputChanged : bool; default alternativeRadialInputChanged = false;
	protected var EnableUberMovement : bool; default EnableUberMovement = false;
	
	protected var shouldRefreshKinect	: bool; default shouldRefreshKinect = false;
	public var isMainMenu 				: bool;
	
	protected var managingPause		: bool; default managingPause = false;
	
	protected var updateInputDeviceRequired : bool; default updateInputDeviceRequired = false;
	
	protected var hasChangedOption		: bool;
	default hasChangedOption = false;
	
	
	protected var curMenuDepth		: int; 
	default curMenuDepth = 0;
	protected var depthOptions		: int;
	default depthOptions = 10;
	
	private var ignoreInput				: bool;
	default ignoreInput = false;
	
	public var disableAccountPicker	: bool;
	default disableAccountPicker = false;
	
	protected var lastSetTag : int;
	
	protected var currentLangValue		: string;
	protected var lastUsedLangValue		: string;
	protected var currentSpeechLang		: string;
	protected var lastUsedSpeechLang	: string;
	private var languageName 			: string;
	
	private var panelMode 				: bool; default panelMode = false;
	private var postprocessRtGreyed 	: bool; default postprocessRtGreyed = false;
	private var postprocessEntered		: bool; default postprocessEntered = false;
	
	public var lastSetDifficulty		: int;
	
	private var lastTimeGetOption 		: int;	default lastTimeGetOption = 0;
	
	private var m_igmStateMachine		: CR4IngameMenuModStates;
	private var m_modLoadingStateMachine: CR4ModMenuModLoadStates;
	private var m_modVerificationStateMachine : CR4ModVerificationStates;
	private var cachedVerifData 			:	W3ModVerificationPopupData;
	private var m_popupIndex : int;
	private var m_lastRequestedSaveInfo : SSavegameInfo;
	private var m_lastAttemptedSaveId	: int;
	
	private var m_modListener : ModMenuEventListener;
	private var m_shouldOpenModMenuOnLogin : bool; default m_shouldOpenModMenuOnLogin = false;
	
	private var m_menuData 	   		: array< SMenuTab >;
	private var m_ounceUseStyle 		: int;

	
	private var btPresetMap : map<name, bool>;
	private var btPresetInitialized : bool; default btPresetInitialized = false;

	event  OnConfigUI()
	{
		var initDataObject 		: W3MenuInitData;
		var commonIngameMenu 	: CR4CommonIngameMenu;
		var commonMainMenuBase	: CR4CommonMainMenuBase;
		var deathScreenMenu 	: CR4DeathScreenMenu;
		var audioLanguageName 	: string;
		var tempLanguageName 	: string;
		var username 			: string;
		var lootPopup			: CR4LootPopup;
		var ep1StatusText		: string;
		var ep2StatusText		: string;
		var ep3StatusText		: string;
		var width				: int;
		var height				: int;
		
		super.OnConfigUI();
		
		m_igmStateMachine = new CR4IngameMenuModStates in this;
		m_igmStateMachine.SetRef(this);
		m_modLoadingStateMachine = new CR4ModMenuModLoadStates in this;
		m_modLoadingStateMachine.SetRefIngameMenu(this);
		m_modLoadingStateMachine.OnQueryProgress();
		
		m_fxNavigateBack = m_flashModule.GetMemberFlashFunction("handleNavigateBack");
		m_fxSetIsMainMenu = m_flashModule.GetMemberFlashFunction("setIsMainMenu");
		m_fxSetCurrentUsername = m_flashModule.GetMemberFlashFunction("setCurrentUsername");
		m_fxSetVersion = m_flashModule.GetMemberFlashFunction("setVersion");
		m_fxShowHelp = m_flashModule.GetMemberFlashFunction("showHelpPanel");		
		m_fxSetVisible = m_flashModule.GetMemberFlashFunction("setVisible");
		m_fxSetPanelMode = m_flashModule.GetMemberFlashFunction("setPanelMode");
		m_fxRemoveOption = m_flashModule.GetMemberFlashFunction("removeOption"); 
		m_fxSetGameLogoLanguage = m_flashModule.GetMemberFlashFunction( "setGameLogoLanguage" );
		m_fxUpdateOptionValue = m_flashModule.GetMemberFlashFunction( "updateOptionValue" );
		m_fxUpdateOptionLabel = m_flashModule.GetMemberFlashFunction( "updateOptionLabel" );
		m_fxUpdateInputFeedback = m_flashModule.GetMemberFlashFunction( "updateInputFeedback" );
		m_fxOnSetModioBorderVis = m_flashModule.GetMemberFlashFunction( "onSetModioBorderVisibility" );
		m_fxOnSaveScreenshotRdy = m_flashModule.GetMemberFlashFunction( "onSaveScreenshotLoaded" );
		m_fxSetIgnoreInput = m_flashModule.GetMemberFlashFunction( "setIgnoreInput" );
		m_fxUpdateSaveSlot = m_flashModule.GetMemberFlashFunction( "updateSaveSlot" );
		m_fxForceEnterCurEntry = m_flashModule.GetMemberFlashFunction( "forceEnterCurrentEntry" );
		m_fxForceBackgroundVis = m_flashModule.GetMemberFlashFunction( "setForceBackgroundVisible" );
		m_fxSetHardwareCursorOn = m_flashModule.GetMemberFlashFunction( "setHardwareCursorOn" );
		m_fxSetExpansionText = m_flashModule.GetMemberFlashFunction( "setExpansionText" );
		m_fxUpdateAnchorsAspectRatio = m_flashModule.GetMemberFlashFunction( "UpdateAnchorsAspectRatio" );
		m_fxQRCodeReadyToLoad = m_flashModule.GetMemberFlashFunction("QRCodeReadyToLoad");
		m_fxShowCloudModal = m_flashModule.GetMemberFlashFunction("ShowCloudModal");
		m_fxCloseGalaxySignInModalWindow = m_flashModule.GetMemberFlashFunction("closeGalaxySignInDialog");
		m_fxSetDLSSIsSupported = m_flashModule.GetMemberFlashFunction("DLSSIsSupported");
		m_fxSetXESSIsSupported = m_flashModule.GetMemberFlashFunction("XESSIsSupported");
		m_fxSetRTEnabled = m_flashModule.GetMemberFlashFunction("RTEnabled");
		m_fxHideErrorWindow = m_flashModule.GetMemberFlashFunction("hideErrorHandlingWindow");
		m_fxShowModioLoadIndicator = m_flashModule.GetMemberFlashFunction("showModioLoadIndicator");
		m_fxHandleImageLoaded = m_flashModule.GetMemberFlashFunction( "handleImageLoaded" );

		m_fxOunceUseStyle = m_flashModule.GetMemberFlashFunction("setOunceGamepadType");
		m_fxUpdateBardsBalladText = m_flashModule.GetMemberFlashFunction("updateBardsBalladText");
		m_fxShowTelemetryDataRequestPopup = m_flashModule.GetMemberFlashFunction("showTelemetryDataRequestPopup");

		m_structureCreator = new IngameMenuStructureCreator in this;
		m_structureCreator.parentMenu = this;
		m_structureCreator.m_flashValueStorage = m_flashValueStorage;
		m_structureCreator.m_flashConstructor = m_flashValueStorage.CreateTempFlashObject();
		
		m_hideTutorial = false;
		m_forceHideTutorial = false;
		disableAccountPicker = false;
		
		theGame.LoadHudSettings();

		m_ounceUseStyle = (int) theInput.GetOunceGamepadStyle();
		m_fxOunceUseStyle.InvokeSelfOneArg(FlashArgInt(m_ounceUseStyle));
		
		mInGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		inGameConfigBufferedWrapper = theGame.GetGuiManager().GetInGameConfigBufferedWrapper();
		
		lootPopup = (CR4LootPopup)theGame.GetGuiManager().GetPopup('LootPopup');
			
		if (lootPopup)
		{
			lootPopup.ClosePopup();
		}
		
		commonIngameMenu = (CR4CommonIngameMenu)(GetParent());
		commonMainMenuBase = (CR4CommonMainMenuBase)(GetParent());
		deathScreenMenu = (CR4DeathScreenMenu)(GetParent());
		
		if (commonIngameMenu)
		{
			isMainMenu = false;
			panelMode = false;
			mInGameConfigWrapper.ActivateScriptTag('inGame');
			mInGameConfigWrapper.DeactivateScriptTag('mainMenu');
			if ((!thePlayer.IsAlive() && !thePlayer.OnCheckUnconscious()) || theGame.HasBlackscreenRequested() || FactsQuerySum("nge_pause_menu_disabled") > 0  ) 
			{
				CloseMenu();
				return true;
			}
			
			
			if(theGame.IsDialogOrCutscenePlaying())
				theSound.SoundEvent("music_pause");
			
		}
		else if (commonMainMenuBase)
		{
			isMainMenu = true;
			panelMode = false;
			mInGameConfigWrapper.ActivateScriptTag('mainMenu');
			mInGameConfigWrapper.DeactivateScriptTag('inGame');
			
			StartShowingCustomDialogs();
			
			
			
			if (theGame.GetDLCManager().IsEP1Available())
			{
				ep1StatusText = GetLocStringByKeyExt("expansion_status_installed");
			}
			else
			{
				ep1StatusText = GetLocStringByKeyExt("panel_mainmenu_installing_dlc");
			}
			
			if (theGame.GetDLCManager().IsEP2Available())
			{
				ep2StatusText = GetLocStringByKeyExt("expansion_status_installed");
			}
			else
			{
				
				ep2StatusText = GetLocStringByKeyExt("panel_mainmenu_installing_dlc");
			}			

			
			
			if (theGame.AreConfigResetInThisSession() && !theGame.HasShownConfigChangedMessage())
			{
				showNotification(GetLocStringByKeyExt("update_warning_message"));
				OnPlaySoundEvent("gui_global_denied");
				theGame.SetHasShownConfigChangedMessage(true);
			}
			
			SetModdedTooltipText();
		}
		else if (deathScreenMenu)
		{
			isMainMenu = false;
			panelMode = true;
			mInGameConfigWrapper.DeactivateScriptTag('mainMenu');
			mInGameConfigWrapper.DeactivateScriptTag('inGame');
			
			deathScreenMenu.HideInputFeedback();
			
			if (hasSaveDataToLoad())
			{
				isInLoadselector = true;
				SendLoadData();
				m_fxSetPanelMode.InvokeSelfOneArg(FlashArgBool(true));
			}
			else
			{
				CloseMenu();
			}
		}
		else
		{
			initDataObject = (W3MenuInitData)GetMenuInitData();
			
			if (initDataObject && initDataObject.getDefaultState() == 'SaveGame')
			{
				isMainMenu = false;
				panelMode = true;
				
				managingPause = true;
				theInput.StoreContext( 'EMPTY_CONTEXT' );
				theGame.Pause('IngameMenu');
				
				mInGameConfigWrapper.DeactivateScriptTag('mainMenu');
				mInGameConfigWrapper.DeactivateScriptTag('inGame');
				
				SendSaveData();
				m_fxSetPanelMode.InvokeSelfOneArg(FlashArgBool(true));
			}
		}
		
		IngameMenu_UpdateDLCScriptTags();
		
		if (!panelMode)
		{
			m_fxSetIsMainMenu.InvokeSelfOneArg(FlashArgBool(isMainMenu)); 
			
			if (isMainMenu)
			{
				username = FixStringForFont(theGame.GetActiveUserDisplayName());
				m_fxSetCurrentUsername.InvokeSelfOneArg(FlashArgString(username));
				
				m_fxSetVersion.InvokeSelfOneArg(FlashArgString(theGame.GetApplicationVersion()));
			}

			lastSetDifficulty = theGame.GetDifficultyLevel();
			
			currentLangValue = mInGameConfigWrapper.GetVarValue('Localization', 'Virtual_Localization_text');
			lastUsedLangValue = currentLangValue;
			
			currentSpeechLang = mInGameConfigWrapper.GetVarValue('Localization', 'Virtual_Localization_speech');
			lastUsedSpeechLang = currentSpeechLang;
			
			theGame.GetGameLanguageName(audioLanguageName,tempLanguageName);
			if( tempLanguageName != languageName )
			{
				UpdateGameLogo();
			}
			
			PopulateMenuData();
		}
		
		theGame.GetCurrentViewportResolution( width, height );
		m_fxUpdateAnchorsAspectRatio.InvokeSelfTwoArgs( FlashArgInt( width ), FlashArgInt( height ) );
		
		theInput.RegisterListener( this, 'OnShowDeveloperMode', 'ShowDeveloperMode' );
		m_modListener = new ModMenuEventListener in this;
		m_modListener.m_ingameMenu = this;

		DefineSwitchFeatureMenuItem('Gyroscope', "menu_panel_console_features_gyroscope_title", "menu_panel_console_features_gyroscope_description");
		DefineSwitchFeatureMenuItem('Motion Patterns', "menu_panel_console_features_motionpatterns_title", "menu_panel_console_features_motionpatterns_description");
		DefineSwitchFeatureMenuItem('Mouse Sensor', "menu_panel_console_features_mouser_title", "menu_panel_console_features_mouser_description");
		DefineSwitchFeatureMenuItem('Touch Screen', "menu_panel_console_features_touch_title", "menu_panel_console_features_touch_description");
		
		SetupSwitchFeatureMenu();
	}

	event OnRefreshActiveUserDisplayName()
	{
		var username 			: string;
		
		if (isMainMenu)
		{
			username = FixStringForFont(theGame.GetActiveUserDisplayName());
			m_fxSetCurrentUsername.InvokeSelfOneArg(FlashArgString(username));
			
			UpdateUserPanelData();
		}
	}
	
	event OnRefreshHDR()
	{
		PopulateMenuData();
	}
	
	event OnRefresh()
	{
		var audioLanguageName 	: string;
		var tempLanguageName 	: string;
		var overlayPopupRef  	: CR4OverlayPopup;
		var username 			: string;
		var hud 				: CR4ScriptedHud;
		var ep1StatusText		: string;
		var ep2StatusText		: string;
		var ep3StatusText		: string;
		
		
		currentLangValue = mInGameConfigWrapper.GetVarValue('Localization', 'Virtual_Localization_text');
		lastUsedLangValue = currentLangValue;
			
		currentSpeechLang = mInGameConfigWrapper.GetVarValue('Localization', 'Virtual_Localization_speech');
		lastUsedSpeechLang = currentSpeechLang;
		
		if (isMainMenu)
		{
			username = FixStringForFont(theGame.GetActiveUserDisplayName());
			m_fxSetCurrentUsername.InvokeSelfOneArg(FlashArgString(username));
			UpdateUserPanelData();
			
			PopulateMenuData();
			
			
			
			
			
			
			
		}
		
		UpdateAcceptCancelSwaping();
		SetPlatformType(theGame.GetPlatform());
		hud = (CR4ScriptedHud)(theGame.GetHud());
		if (hud)
		{
			hud.UpdateAcceptCancelSwaping();
		}
		
		overlayPopupRef = (CR4OverlayPopup) theGame.GetGuiManager().GetPopup('OverlayPopup');
		if (overlayPopupRef)
		{
			overlayPopupRef.UpdateAcceptCancelSwaping();
		}
		
		theGame.GetGameLanguageName(audioLanguageName,tempLanguageName);
		if( tempLanguageName != languageName )
		{
			UpdateGameLogo();
			languageName = tempLanguageName;
			m_fxUpdateInputFeedback.InvokeSelf();
			if (overlayPopupRef)
			{
				overlayPopupRef.UpdateButtons();
			}
		}
		
		
		{
			
			
			if (theGame.GetDLCManager().IsEP1Available())
			{
				ep1StatusText = GetLocStringByKeyExt("expansion_status_installed");
			}
			else
			{
				ep1StatusText = GetLocStringByKeyExt("panel_mainmenu_installing_dlc");
			}
			
			if (theGame.GetDLCManager().IsEP2Available())
			{
				ep2StatusText = GetLocStringByKeyExt("expansion_status_installed");
			}
			else
			{
				
				ep2StatusText = GetLocStringByKeyExt("panel_mainmenu_installing_dlc");
			}
			

			
			m_fxSetExpansionText.InvokeSelfThreeArgs(FlashArgString(ep1StatusText), FlashArgString(ep2StatusText), FlashArgString(ep3StatusText));
		}
		setArabicAligmentMode();
	}

	event OnVisitWeibo()
	{
		theGame.VisitWeibo();
	}
	
	function OnRequestSubMenu( menuName: name, optional initData : IScriptable )
	{
		RequestSubMenu(menuName, initData);
		m_fxSetVisible.InvokeSelfOneArg(FlashArgBool(false));
	}
	
	function ChildRequestCloseMenu()
	{
		m_fxSetVisible.InvokeSelfOneArg(FlashArgBool(true));
	}
	
	event OnCloseMenu() 
	{
		
		if(theGame.IsDialogOrCutscenePlaying())
			theSound.SoundEvent("music_resume");
		
		CloseMenu();
	}
	
	public function ReopenMenu()
	{
		var commonInGameMenu : CR4CommonIngameMenu;
		var commonMainMenuBase : CR4CommonMainMenuBase;
		
		commonInGameMenu = (CR4CommonIngameMenu)m_parentMenu;
		if(commonInGameMenu)
		{
			commonInGameMenu.reopenRequested = true;
		}
		
		commonMainMenuBase = (CR4CommonMainMenuBase)m_parentMenu;
		if ( commonMainMenuBase )
		{
			commonMainMenuBase.reopenRequested = true;
		}
		
		CloseMenu();
	}
		
	event  OnClosingMenu()
	{
		var commonInGameMenu : CR4CommonIngameMenu;
		var commonMainMenuBase : CR4CommonMainMenuBase;
		var deathScreenMenu : CR4DeathScreenMenu;
		var controlsFeedbackModule : CR4HudModuleControlsFeedback;
		var interactionModule : CR4HudModuleInteractions;
		var hud : CR4ScriptedHud;
		
		theGame.SetHDRMenuActive(false);
		theGame.SetHDRMenuFadePercentage(0);
		
		SaveChangedSettings();
		
		super.OnClosingMenu();
		
		
		hud = (CR4ScriptedHud)(theGame.GetHud());
		if (hud)
		{
			controlsFeedbackModule = (CR4HudModuleControlsFeedback)(hud.GetHudModule(NameToString('ControlsFeedbackModule')));
			if (controlsFeedbackModule)
			{
				controlsFeedbackModule.ForceModuleUpdate();
			}
			
			interactionModule = (CR4HudModuleInteractions)(hud.GetHudModule(NameToString('InteractionsModule')));
			if (interactionModule)
			{
				interactionModule.ForceUpdateModule();
			}
		}
		
		if (managingPause)
		{
			managingPause = false;
			theInput.RestoreContext( 'EMPTY_CONTEXT', true );
			theGame.Unpause('IngameMenu');
		}
		
		if (theGame.GetGuiManager().potalConfirmationPending)
		{
			theGame.GetGuiManager().ResumePortalConfirmationPendingMessage();
		}
		
		if (m_structureCreator)
		{
			delete m_structureCreator;
		}
		
		if (loadConfPopup)
		{
			delete loadConfPopup;
		}
		
		if (saveConfPopup)
		{
			delete saveConfPopup;
		}
		
		if (actionConfPopup)
		{
			delete actionConfPopup;
		}
		
		if (newGameConfPopup)
		{
			delete newGameConfPopup;
		}
		
		if (deleteConfPopup)
		{
			delete deleteConfPopup;
		}
		
		if (diffChangeConfPopup)
		{
			delete diffChangeConfPopup;
		}
		
		commonInGameMenu = (CR4CommonIngameMenu)m_parentMenu;
		if(commonInGameMenu)
		{
			commonInGameMenu.ChildRequestCloseMenu();
			return true;
		}
		
		commonMainMenuBase = (CR4CommonMainMenuBase)m_parentMenu;
		if ( commonMainMenuBase )
		{
			commonMainMenuBase.ChildRequestCloseMenu();
			return true;
		}
		
		deathScreenMenu = (CR4DeathScreenMenu)m_parentMenu;
		if (deathScreenMenu)
		{
			deathScreenMenu.ChildRequestCloseMenu();
			return true;
		}
	}
	
	
	protected function CloseCurrentPopup():void
	{
		if (loadConfPopup)
		{
			loadConfPopup.ClosePopupOverlay();
		}
		else if (saveConfPopup)
		{
			saveConfPopup.ClosePopupOverlay();
		}		
		else if (actionConfPopup)
		{
			actionConfPopup.ClosePopupOverlay();
		}		
		else if (newGameConfPopup)
		{
			newGameConfPopup.ClosePopupOverlay();
		}		
		else if (deleteConfPopup)
		{
			deleteConfPopup.ClosePopupOverlay();
		}		
		else if (diffChangeConfPopup)
		{
			diffChangeConfPopup.ClosePopupOverlay();
		}
	}
	
	public function SetIgnoreInput(value : bool) : void
	{
		if (value != ignoreInput)
		{
			ignoreInput = value;
			m_fxSetIgnoreInput.InvokeSelfOneArg( FlashArgBool(value) );
		}
	}
	
	public function ForceSetIgnoreInput(value : bool) : void
	{
		ignoreInput = value;
		m_fxSetIgnoreInput.InvokeSelfOneArg( FlashArgBool(value) );
	}
	
	public function UpdateSaveSlot() : void
	{
		m_fxUpdateSaveSlot.InvokeSelf();
	}
	
	public function OnUserSignIn() : void
	{
		SetIgnoreInput(false);
		CloseCurrentPopup();
	}
	
	public function OnUserSignInCancelled() : void
	{
		SetIgnoreInput(false);
		CloseCurrentPopup();
	}
	
	public function OnSaveLoadingFailed() : void
	{
		SetIgnoreInput(false);
		CloseCurrentPopup();
	}


	
	event  OnItemActivated( actionType:int, menuTag:int ) : void
	{
		var initData : W3StartupMenuInitData;
		var currentMenu : CR4Menu;
		var l_DataFlashArray : CScriptedFlashArray;
		var manager : CR4GuiManager;
		
		if (ignoreInput)
		{
			m_fxNavigateBack.InvokeSelf();
		}
		else
		{
			postprocessEntered = false;
			
			switch (actionType)
			{
			case IGMActionType_CommonMenu:
				theGame.RequestMenu( 'CommonMenu' );
				break;
			case IGMActionType_MenuHolder:
				
				
				m_initialSelectionsToIgnore = 1;
				OnPlaySoundEvent( "gui_global_panel_open" );
				curMenuDepth += 1;
				break;
			case IGMActionType_MenuLastHolder:
				m_initialSelectionsToIgnore = 1;
				OnPlaySoundEvent( "gui_global_panel_open" );
				curMenuDepth += 1;
				break;
			case IGMActionType_Load:
				if (hasSaveDataToLoad())
				{
					SendLoadData();
				}
				else
				{
					
					m_fxNavigateBack.InvokeSelf();
				}
				isInLoadselector = true;
				break;
			case IGMActionType_Save:
				if ( !theGame.AreSavesLocked() )
				{
					SendSaveData();
				}
				else
				{
					m_fxNavigateBack.InvokeSelf();
					theGame.GetGuiManager().DisplayLockedSavePopup();
				}
				isInLoadselector = false;
				break;
			case IGMActionType_Quit:
				ShowActionConfPopup( IGMActionType_Quit, "", GetPlatformLocString( "error_message_exit_game" ) );
				break;
			case IGMActionType_Toggle:
				break;
			case IGMActionType_ListWithCondition:
				break;
			case IGMActionType_List:
				break;
			case IGMActionType_Slider:
				break;	
			case IGMActionType_LoadLastSave:
				LoadLastSave(true);
				break;
			case IGMActionType_Close:
				
				break;
			case IGMActionType_Tutorials:
				theGame.RequestMenuWithBackground( 'GlossaryTutorialsMenu', 'CommonMenu' );
				break;
			case IGMActionType_Credits:
				theGame.GetGuiManager().RequestCreditsMenu(menuTag);
				break;
			case IGMActionType_Help:
				showHelpPanel();
				break;
			case IGMActionType_ModMenu:
				OpenModMenu();
				break;
			case IGMActionType_Options:
				DLSSSupported();
				XESSSupported();
				RTEnabled();
				validatePTHairOptionValue();
				
				developerOptions = m_flashValueStorage.CreateTempFlashArray();

				UpdateBardsBalladTooltipText();
				
				showOptionsPanel();
				
				isDeveloperModeEnabled = false;
				ShowDeveloperMode( isDeveloperModeEnabled );
				break;
			case IGMActionType_ControllerHelp:
				curMenuDepth += 1;
				SendControllerData();
				break;
			case IGMActionType_NewGame:
				TryStartNewGame(menuTag);
				break;
			case IGMActionType_NewGamePlus:
				fetchNewGameConfigFromTag(menuTag);
				SendNewGamePlusSaves();
				break;
			case IGMActionType_InstalledDLC:
				SendInstalledDLCList();
				break;
			case IGMActionType_UIRescale:
				curMenuDepth += 1;
				SendRescaleData();
				break;
			case IGMActionType_DebugStartQuest:
				RequestSubMenu( 'MainDbgStartQuestMenu', GetMenuInitData() );
				break;
			case IGMActionType_Gwint:
				GetRootMenu().CloseMenu();
				theGame.RequestMenu( 'DeckBuilder' );
				break;
			case IGMActionType_ImportSave:
				lastSetTag = menuTag;
				fetchNewGameConfigFromTag( menuTag );
				SendImportSaveData( );
				break;
			case IGMActionType_CloseGame:
				if (!isMainMenu)
				{
					ShowActionConfPopup(IGMActionType_CloseGame, "", GetLocStringByKeyExt("error_message_exit_game"));
				}
				else
				{
					theGame.RequestExit();
				}
				break;

			case IGMActionType_KeyBinds:
				curMenuDepth += 1;
				SendKeybindData();
				break;
				
			case IGMActionType_ToggleRender:
				ToggleRTEnabled();
			    break;
			case IGMActionType_PurchaseEP1:
				theGame.DisplayStoreExpansionPack('ep1');
				break;
			case IGMActionType_PurchaseEP2:
				theGame.DisplayStoreExpansionPack('bob_000_000');
				break;

			case IGMActionType_ReplayTutorial:
				if(isMainMenu)
				{
					
					theGame.ReplayTutorial();
				}
				else
				{	
					
					ShowActionConfPopup(IGMActionType_ReplayTutorial, "", GetLocStringByKeyExt("popup_replay_tutorial_save_confirmation"));
				}
				break;				
			case IGMActionType_SwitchFeatures:
				
				prepareBigMessageSwitchPopUp();	
				break;
			case IGMActionType_LeaveTutorial:
				theGame.LeaveTutorialReplay();	
				OnLeaveForceSwitchSettings();
				break;
			
			case IGMActionType_PatchNotes:
				currentMenu = theGame.GetGuiManager().GetRootMenu();
				CloseMenu();
				
				initData = new W3StartupMenuInitData in theGame.GetGuiManager();
				
				initData.requestPage = SPI_PatchNotes;
				initData.reopenMenu = true;
				initData.reopenMenuName = currentMenu.GetMenuName();
				initData.forceShow = true;
				
				theGame.RequestMenu( 'StartupExperienceMenu', initData );
				break;
			}
		}
	}

	public function OnLeaveForceSwitchSettings()
	{
		var inGameConfigWrapper	: CInGameConfigWrapper;
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();

		if (theGame.GetPlatform() != Platform_Switch2_Ounce)
		{
			return;
		}
		
		inGameConfigWrapper.SetVarValue('Controls_DualGrip', 'MotionPatternsMode', "1");
		
		if(FactsDoesExist("altcast_before_switchtutorial"))
		{
			if(FactsQueryLatestValue( "altcast_before_switchtutorial" ) == 2)
			{
				inGameConfigWrapper.SetVarValue('Gameplay', 'EnableAlternateSignCasting',"1");
				thePlayer.GetInputHandler().SetIsAltSignCasting(true);
				FactsSet( "nge_alt_sign_casting_chosen", 1 );
				LogChannel('DebugTutorial',"RevertAltCastingAfterTutorial actual change On");
			}
			else if(FactsQueryLatestValue( "altcast_before_switchtutorial" ) == 1)
			{
				inGameConfigWrapper.SetVarValue('Gameplay', 'EnableAlternateSignCasting', "0");
				thePlayer.GetInputHandler().SetIsAltSignCasting(false);
				FactsSet( "nge_alt_sign_casting_chosen", 0 );
				LogChannel('DebugTutorial',"RevertAltCastingAfterTutorial actual change Off");
			}
		}		
	}

	public function CheckSwitchRevertOnQuit()
	{
		if (theGame.GetPlatform() != Platform_Switch2_Ounce)
		{
			return;
		}
		LogChannel('DebugTutorial',"CheckSwitchRevertOnQuit : " + FactsQueryLatestValue( "check_revert_on_quit" ));

		if(FactsDoesExist("check_revert_on_quit"))
		{
			if(FactsQueryLatestValue( "check_revert_on_quit" ) == 1)
			{
				OnLeaveForceSwitchSettings();
			}
		}
		FactsSet( "check_revert_on_quit", 0 );
	}
	
	
	
	
	
	
	
	public function CreateModLoadFailedPopup(mods: array< SModioModData >, UGCallowed : bool)
	{
		var verifData	: W3ModVerificationPopupData;
		var l_flashObject : CScriptedFlashObject;
		var GFxButtonsListData : CScriptedFlashArray;
		var saveIndex : int;

		if ( !UGCallowed )
		{
			return;
		}
		
		verifData = new W3ModVerificationPopupData in theGame;
		verifData.SetModArray(mods);
		verifData.SetIngameMenu(this);
		
		verifData.SetMessageTitle("[[panel_mods_verification_window]]");
		verifData.SetMessageText("[[panel_mods_failed_desc]]");

		
		
		
		verifData.SetIsOutdated(false);
		verifData.SetIsLoadingSave(false);
		verifData.SetIsContinue(false);
		verifData.SetIsFailed(true);
		verifData.SetHideCheckbox(true);
		
		l_flashObject = verifData.GetGFxData(m_flashValueStorage);
		GFxButtonsListData = verifData.GetGFxButtons(m_flashValueStorage);
		l_flashObject.SetMemberFlashArray("ButtonsList", GFxButtonsListData);
		
		cachedVerifData = verifData;
		m_flashValueStorage.SetFlashObject( "ingamemenu.bigMessageMod", l_flashObject );		
	}

	public function CreateModVerificationPopup(mods: array< SModioModData >, missing : bool, startup: bool, continu: bool, UGCallowed : bool)
	{
		var verifData	: W3ModVerificationPopupData;
		var l_flashObject : CScriptedFlashObject;
		var GFxButtonsListData : CScriptedFlashArray;
		var saveIndex : int;
		
		verifData = new W3ModVerificationPopupData in theGame;
		verifData.SetModArray(mods);
		verifData.SetIngameMenu(this);
		
		verifData.SetMessageTitle("[[panel_mods_verification_window]]");
		if(missing)
		{
			verifData.SetMessageText("[[panel_mods_verification_missing_mods_desc]]");
			verifData.SetReason("[[panel_mods_verification_missing_mods]]");
			verifData.SetAction("[[panel_mods_verification_subscribe]]");
		}
		else
		{
			verifData.SetMessageText("[[panel_mods_verification_outdated_mods_desc]]");
			verifData.SetReason("[[panel_mods_verification_outdated_mods]]");
			verifData.SetAction("[[panel_mods_verification_disable]]");
		}
		verifData.SetIsOutdated(!missing);
		verifData.SetIsLoadingSave(!startup);
		verifData.SetIsContinue(continu);
		verifData.SetIsFailed(false);

		verifData.SetIsUGCallowed(UGCallowed);
		
		if(startup)
		{
			l_flashObject = verifData.GetGFxData(m_flashValueStorage);
			GFxButtonsListData = verifData.GetGFxButtons(m_flashValueStorage);
			l_flashObject.SetMemberFlashArray("ButtonsList", GFxButtonsListData);
			
			cachedVerifData = verifData;
			m_flashValueStorage.SetFlashObject( "ingamemenu.bigMessageMod", l_flashObject );
		}
		else
		{
			RequestSubMenu( 'PopupMenu' ,verifData );
		}
	}
	
	
	
	
	
	
	
	
	

	
	

	
	
	
		
	
	
				
	
	
	
			
	
	
	
	protected function OpenModMenu() : void
	{
		m_igmStateMachine.OnLaunchModMenu();
	}

	public function OnEnsureInternetConnectionFinished( hasConnection : bool )
	{
		m_igmStateMachine.OnNetworkConnectionEnsureFinished(hasConnection);
	}

	event  OnShowSaveGameMenu() : void
	{
		LogChannel('UI', "OnShowSaveGameMenu");
	}

	event  OnShowLoadGameMenu() : void
	{
		theGame.RefreshCrossProgressionSavesList();
	}

	event  OnShowOptionSubmenu( actionType:int, menuTag:int, id:string ) : void
	{
		if (id == "settings_hdr")
		{
			theGame.SetHDRMenuActive(true);
			theGame.SetHDRMenuFadePercentage(1);
		}
		else
		{
			theGame.SetHDRMenuActive(false);
			theGame.SetHDRMenuFadePercentage(0);
		}

		if (theGame.GetPlatform() == Platform_Switch2_Ounce)
		{
			UpdateOunceControlSettings();
		}
	}
	
	public function RefreshTelemetySettingValues() : void
	{
		var settingsArray : CScriptedFlashArray;
		var setting : CScriptedFlashObject;

		var telemetryConsent : bool = mInGameConfigWrapper.GetVarValue('Gameplay', 'GameTelemetryConsent');

		settingsArray = m_flashValueStorage.CreateTempFlashArray();

		setting = m_flashValueStorage.CreateTempFlashObject();
			setting.SetMemberFlashUInt( "tag", NameToFlashUInt('GameTelemetryConsent') );
			setting.SetMemberFlashString( "current", telemetryConsent );
		settingsArray.PushBackFlashObject( setting );

		m_flashValueStorage.SetFlashArray( "options.force_update_values", settingsArray );
		theGame.GetGuiManager().ForceProcessFlashStorage();
		
		m_flashValueStorage.SetFlashBool( "options.show_spinner", false );
	}
	
	public function HandleLoadGameFailed():void
	{
		disableAccountPicker = false;
		SetIgnoreInput(false);
	}
	
	function ShowQrSignInWindow()
	{
		var menuBase 	: CR4MenuBase;
		var ingameMenu 	: CR4IngameMenu;
		
		menuBase = (CR4MenuBase)(theGame.GetGuiManager().GetRootMenu());
			
		if (menuBase){
			ingameMenu = (CR4IngameMenu)(menuBase.GetSubMenu());
			if (ingameMenu)	{
				ingameMenu.StartShowCustomDialogGalaxySignIn();
			}
		}
	}

	private function StartShowingCustomDialogs()
	{
		
		
		
		
		
		
	
		
		
		
		
		
		if (theGame.GetPlatform() == Platform_Switch2_Ounce)
		{	
			Log("Switch feature "+theGame.GetPlatform());
			if (theGame.GetInGameConfigWrapper().GetVarValue('Hidden', 'HasSeenSwitchFeaturePopUp') != "true")
			{
				theGame.GetInGameConfigWrapper().SetVarValue('Hidden', 'HasSeenSwitchFeaturePopUp', "true");
				theGame.SaveUserSettings();
				prepareBigMessageSwitchPopUp();
			}
		}
		
		if(theGame.GetModHandlerSystem() && theGame.GetModHandlerSystem().HasFailedMods() )
		{
			prepareBigMessageFailedMods();
		}

		
		
		
		
		
		
		
		
		
	}
	
	protected function prepareBigMessage( epIndex : int ):void
	{
		var l_DataFlashObject 		: CScriptedFlashObject;
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();

		l_DataFlashObject.SetMemberFlashInt( "index", epIndex );
		l_DataFlashObject.SetMemberFlashString( "tfTitle1", GetLocStringByKeyExt("ep" + epIndex + "_installed_information_title_1") );
		l_DataFlashObject.SetMemberFlashString( "tfTitle2", GetLocStringByKeyExt("ep" + epIndex + "_installed_information_title_2") );
		
		l_DataFlashObject.SetMemberFlashString( "tfTitlePath1", GetLocStringByKeyExt("ep" + epIndex + "_installed_information_title_path_1") );
		l_DataFlashObject.SetMemberFlashString( "tfTitlePath2", GetLocStringByKeyExt("ep" + epIndex + "_installed_information_title_path_2") );
		l_DataFlashObject.SetMemberFlashString( "tfTitlePath3", GetLocStringByKeyExt("ep" + epIndex + "_installed_information_title_path_3") );
		
		l_DataFlashObject.SetMemberFlashString( "tfDescPath1", GetLocStringByKeyExt("ep" + epIndex + "_installed_information_title_path_1_description") );
		l_DataFlashObject.SetMemberFlashString( "tfDescPath2", GetLocStringByKeyExt("ep" + epIndex + "_installed_information_title_path_2_description") );
		l_DataFlashObject.SetMemberFlashString( "tfDescPath3", GetLocStringByKeyExt("ep" + epIndex + "_installed_information_title_path_3_description") );
		
		l_DataFlashObject.SetMemberFlashString( "tfWarning", GetLocStringByKeyExt("ep" + epIndex + "_installed_information_warning_level") );
		l_DataFlashObject.SetMemberFlashString( "tfGoodLuck", GetLocStringByKeyExt("ep" + epIndex + "_installed_information_good_luck") );
		
		m_flashValueStorage.SetFlashObject( "ingamemenu.bigMessage" + epIndex, l_DataFlashObject );
	}
	
	
	
	private function prepareBigMessageSwitchPopUp()
	{	
		var l_DataFlashObject 		: CScriptedFlashObject;
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		m_flashValueStorage.SetFlashObject("ingamemenu.switchPopUp", l_DataFlashObject);
	}
	
	private function prepareBigMessageMods()
	{
		var modArray : array< SModioModID >;
		theGame.GetModHandlerSystem().GetOutdatedMods(modArray);
		m_igmStateMachine.GetStartupModList(modArray);
		theGame.GetGuiManager().OnInitialModVerificationWasShown();
	}

	private function prepareBigMessageFailedMods()
	{
		var modArray : array< SModioModID >;
		theGame.GetModHandlerSystem().GetFailedMods(modArray);
		m_igmStateMachine.GetFailedModList(modArray);
	}
	
	public function StartShowCustomDialogGalaxySignIn()
	{
		var l_DataFlashObject 		: CScriptedFlashObject;
		var usesQrSignIn			: bool;
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		usesQrSignIn = theGame.UsesQrSignIn();
		
		l_DataFlashObject.SetMemberFlashInt( "index", 4 );
		l_DataFlashObject.SetMemberFlashBool("isPlatformPC", !usesQrSignIn);
		l_DataFlashObject.SetMemberFlashString( "tfTitleSignIn", "[[ui_gog_qr_title]]" );
		l_DataFlashObject.SetMemberFlashString( "tfContentSignInTopA", "[[ui_gog_qr_explain_1]]" );
		l_DataFlashObject.SetMemberFlashString( "tfContentSignInTopB", "[[ui_gog_qr_explain_2]]" );
		l_DataFlashObject.SetMemberFlashString( "tfContentSignInTopC", "[[ui_gog_qr_explain_3]]" );
		if (usesQrSignIn)
		{
			l_DataFlashObject.SetMemberFlashString( "tfLink1" , "[[ui_gog_qr_pls_wait]]");
			l_DataFlashObject.SetMemberFlashString( "tfContentSignIn2", "[[ui_gog_qr_use_url]]");
			l_DataFlashObject.SetMemberFlashString( "tfContentSignIn3", "[[ui_gog_qr_scan_hint]]" );
		}
		else
		{
			l_DataFlashObject.SetMemberFlashString( "tfContentSignIn2", "[[ui_gog_red_launcher_signin_instructions]]");
		}
		
		m_flashValueStorage.SetFlashObject( "ingamemenu.bigMessage4", l_DataFlashObject );
	}

	public function StartShowCustomDialogGalaxySignInReminder()
	{
		var l_flashObject : CScriptedFlashObject;
		var content : string;
		var title : string;
		var signin : string;
		var loginInfo : string;
		var usesQrSignIn : bool;
		
		usesQrSignIn = theGame.UsesQrSignIn();
		
		title = GetLocStringByKeyExt("panel_cloud_reminder_title");
		content = GetLocStringByKeyExt("panel_cloud_reminder_body");
		
		if(usesQrSignIn)
		{
			signin = GetLocStringByKeyExt("panel_cloud_reminder_sign_in");
		}
		else
		{
			loginInfo = GetLocStringByKeyExt("ui_gog_red_launcher_signin_instructions");
			
		}

		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		
		l_flashObject.SetMemberFlashBool("isPlatformPC", !usesQrSignIn);
		l_flashObject.SetMemberFlashString("TextTitle", title);
		l_flashObject.SetMemberFlashString("TextContent", content);
		l_flashObject.SetMemberFlashString("TextSignIn", signin);
		l_flashObject.SetMemberFlashString("TextLoginInfo", loginInfo);
			
		m_flashValueStorage.SetFlashObject( "ingamemenu.ReminderWindow", l_flashObject );
	}

	public function HideErrorWindow()
	{
		m_fxHideErrorWindow.InvokeSelf();
	}

	public function ShowErrorWindow( error : int )
	{
		var l_DataFlashObject : CScriptedFlashObject;
		var errorMessage : string ;
		
		switch(error)
		{
			case RewardsRequestFailed:
			case QRCodeRequestFailed:
			case GOGNoInternetConnection:
				errorMessage = "[[ui_gog_error_no_connection]]";
			break;
			case RewardsTemporaryFail:
				errorMessage = "[[ui_gog_error_fault_retry]]";
			break;
			default:
				errorMessage = "[[ui_gog_error_smt_wrong]]";
			break;
		}
		
		
		if ( curMenuDepth < depthOptions )
		{
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
			l_DataFlashObject.SetMemberFlashString( "tfTitleError", "[[ui_gog_error_popup_title]]" );
			l_DataFlashObject.SetMemberFlashString( "tfDescription", errorMessage );
			
			m_flashValueStorage.SetFlashObject( "ingamemenu.ErrorHandleWindow", l_DataFlashObject );
		}
		
		else
		{
			showNotification( errorMessage );
			OnPlaySoundEvent( "gui_global_denied" );
		}
	}

	private function SetRewardsCellParams( out dataFObj : CScriptedFlashObject, out rewarr : array< int >, cellName: string, rewID : int )
	{
		var rewTitle : string ;
		var rewDesc : string ;
		var isPresent : bool ;
		
		
		isPresent = rewarr.Contains(rewID);
		dataFObj.SetMemberFlashBool("b"+cellName+"on", isPresent);
		if ( !isPresent ) {
			return;
		}	
		
		
		theGame.GetGuiManager().GetGalaxyRewardDesc( rewID, rewTitle, rewDesc );
		dataFObj.SetMemberFlashString("tf"+cellName+"title", rewTitle);
		dataFObj.SetMemberFlashString("tf"+cellName+"desc", rewDesc);
	}
		
	
	
	protected function LoadLastSave( allowModCheck : bool ) : void
	{
		if (theGame.GetGuiManager().GetPopup('MessagePopup') && theGame.GetGuiManager().lastMessageData.messageId == UMID_ControllerDisconnected)
		{
			return;
		}
		
		if ( !CheckModdedLastSave( allowModCheck ) )
		{
			return;
		}
		
		SetIgnoreInput(true);
		
		if (isMainMenu)
		{
			disableAccountPicker = true;
		}
		
		theGame.LoadLastGameInit();
	}
	
	protected function ShowActionConfPopup(action : int, title : string, description : string) : void
	{
		if (actionConfPopup)
		{
			delete actionConfPopup;
		}
		
		actionConfPopup = new W3ActionConfirmation in this;
		actionConfPopup.SetMessageTitle(title);
		actionConfPopup.SetMessageText(description);
		actionConfPopup.actionID = action;
		actionConfPopup.menuRef = this;
		actionConfPopup.BlurBackground = true;
			
		RequestSubMenu('PopupMenu', actionConfPopup);
	}
	
	public function OnActionConfirmed(action:int) : void
	{
		var environment : CEnvironmentDefinition;
		var parentMenu : CR4MenuBase;
		
		parentMenu = (CR4MenuBase)GetParent();
		
		switch (action)
		{
		case IGMActionType_Quit:
			{
				SetInteriorBlending(false, false, 0.5f, 0.5f);
				parentMenu.OnCloseMenu();
				CheckSwitchRevertOnQuit();
				theGame.RequestEndGame();
				break;
			}
		case IGMActionType_CloseGame:
			{
				SetInteriorBlending(false, false, 0.5f, 0.5f);
				CheckSwitchRevertOnQuit();
				theGame.RequestExit();
				break;
			}
		case IGMActionType_ReplayTutorial:
			{
				theGame.ReplayTutorial();
				break;
			}			
		}
	}

	event  OnConfirm():void
	{
		
	}
	
	event  OnPresetApplied(groupId:name, targetPresetIndex:int)
	{
		hasChangedOption = true;
		IngameMenu_ChangePresetValue(groupId, targetPresetIndex, this);
		
		if (groupId == 'Rendering' && !isMainMenu)
		{
			m_fxForceBackgroundVis.InvokeSelfOneArg(FlashArgBool(true));
		}
		
		
		if(groupId == 'PostProcess')
		{
			UpdateAO2CorrespondRT(theGame.GetRTEnabled(), true);
			UpdatePresetOptions('PostProcess', false);
		}

		updateOptionsDisableState();
	}
	
	event  OnTelemetryConsentChanged(telemetryConsent:bool)
	{
		theTelemetry.TelemetryConsentChanged( telemetryConsent );
		
	}
	
	event  OnConsentPopupWasShown(consentPopupWasShown: bool)
	{
		theTelemetry.MarkShownConsentWindow();
	}
	
	public function UpdatePresetOptions(groupId:name, applyLocks:bool)
	{
		var optionPresetChangeContainer : CScriptedFlashObject;
		
		optionPresetChangeContainer = m_flashValueStorage.CreateTempFlashObject();
		IngameMenu_GatherOptionUpdatedValues(groupId, optionPresetChangeContainer, m_flashValueStorage, applyLocks);
		
		m_flashValueStorage.SetFlashObject( "ingamemenu.optionPresetChange", optionPresetChangeContainer );
		IngameMenu_GatherOptionUpdatedValueList(groupId, m_flashValueStorage);
	}
	
	public function DLSSSupported()
	{
		var DLSSIsSupported : bool;
		DLSSIsSupported = theGame.GetIsDLSSSupported();
		m_fxSetDLSSIsSupported.InvokeSelfTwoArgs( FlashArgBool(DLSSIsSupported), FlashArgUInt(NameToFlashUInt('AAMode') ));				
	}

	public function XESSSupported()
	{
		var XESSIsSupported : bool;
		XESSIsSupported = theGame.GetIsXESSSupported();
		m_fxSetXESSIsSupported.InvokeSelfTwoArgs( FlashArgBool(XESSIsSupported), FlashArgUInt(NameToFlashUInt('AAMode') ));				
	}
	
	public function RTEnabled()
	{ 
		var RTEnabled : bool;
		RTEnabled = theGame.GetRTEnabled();
		m_fxSetRTEnabled.InvokeSelfTwoArgs( FlashArgBool(RTEnabled), FlashArgUInt(NameToFlashUInt('Virtual_SSAOSolution') ));
		if(RTEnabled == false)
		{
			if( StringToInt(mInGameConfigWrapper.GetVarValue('PostProcess', 'Virtual_SSAOSolution')) >= 2 )
			{
				mInGameConfigWrapper.SetVarValue( 'PostProcess', 'Virtual_SSAOSolution','1' );
				m_fxUpdateOptionValue.InvokeSelfTwoArgs( FlashArgUInt(NameToFlashUInt('Virtual_SSAOSolution')), FlashArgString('1') );
			}
		}
	}

	public function UpdateOunceControlSettings()
	{
		UpdateOunceControlSettingsDisabled();
		UpdateOunceControlSettingsValues();
		UpdateOunceControlSettingsVisibility();
	}
	
	public function UpdateOunceGamepadStyle( newStyle : int )
	{
		m_ounceUseStyle = newStyle;
		m_fxOunceUseStyle.InvokeSelfOneArg(FlashArgInt(m_ounceUseStyle));
	}

	private function UpdateOunceControlSettingsDisabled()
	{
		var dataObject : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;

		var gyroModeEnabled_Handheld : bool = StringToInt(mInGameConfigWrapper.GetVarValue('Controls_Handheld', 'Handheld_GyroAimingMode')) > 0;

		var gyroModeEnabled_ProController : bool = StringToInt(mInGameConfigWrapper.GetVarValue('Controls_ProController', 'ProController_GyroAimingMode')) > 0;

		var patternsModeAllEnabled_DualGrip : bool = StringToInt(mInGameConfigWrapper.GetVarValue('Controls_DualGrip', 'MotionPatternsMode')) == 1; 
		var gyroModeEnabled_DualGrip : bool = StringToInt(mInGameConfigWrapper.GetVarValue('Controls_DualGrip', 'DualGrip_GyroAimingMode')) > 0;

		var isMouserConnected : bool = theInput.GetIsMouserConnected();
		var mouserModeEnabled : bool = StringToInt(mInGameConfigWrapper.GetVarValue('Controls_Mouser', 'MouserActivationMode')) > 0 && isMouserConnected;

		dataArray = m_flashValueStorage.CreateTempFlashArray();

		
		{
			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Handheld_GyroTurningAxis') );
			dataObject.SetMemberFlashBool( "disabled", !gyroModeEnabled_Handheld );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Handheld_GyroSensitivity') );
			dataObject.SetMemberFlashBool( "disabled", !gyroModeEnabled_Handheld );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Handheld_GyroDeadzone') );
			dataObject.SetMemberFlashBool( "disabled", !gyroModeEnabled_Handheld );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Handheld_GyroInvertX') );
			dataObject.SetMemberFlashBool( "disabled", !gyroModeEnabled_Handheld );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Handheld_GyroInvertY') );
			dataObject.SetMemberFlashBool( "disabled", !gyroModeEnabled_Handheld );
			dataArray.PushBackFlashObject( dataObject );
		}

		
		{
			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('ProController_GyroTurningAxis') );
			dataObject.SetMemberFlashBool( "disabled", !gyroModeEnabled_ProController );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('ProController_GyroSensitivity') );
			dataObject.SetMemberFlashBool( "disabled", !gyroModeEnabled_ProController );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('ProController_GyroDeadzone') );
			dataObject.SetMemberFlashBool( "disabled", !gyroModeEnabled_ProController );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('ProController_GyroInvertX') );
			dataObject.SetMemberFlashBool( "disabled", !gyroModeEnabled_ProController );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('ProController_GyroInvertY') );
			dataObject.SetMemberFlashBool( "disabled", !gyroModeEnabled_ProController );
			dataArray.PushBackFlashObject( dataObject );
		}

		
		{
			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('DualGrip_GyroTurningAxis') );
			dataObject.SetMemberFlashBool( "disabled", !gyroModeEnabled_DualGrip );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('DualGrip_GyroSensitivity') );
			dataObject.SetMemberFlashBool( "disabled", !gyroModeEnabled_DualGrip );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('DualGrip_GyroDeadzone') );
			dataObject.SetMemberFlashBool( "disabled", !gyroModeEnabled_DualGrip );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('DualGrip_GyroInvertX') );
			dataObject.SetMemberFlashBool( "disabled", !gyroModeEnabled_DualGrip );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('DualGrip_GyroInvertY') );
			dataObject.SetMemberFlashBool( "disabled", !gyroModeEnabled_DualGrip );
			dataArray.PushBackFlashObject( dataObject );
		}

		
		{
			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('MouserActivationMode') );
			dataObject.SetMemberFlashBool( "disabled", !isMouserConnected );
			dataArray.PushBackFlashObject(dataObject);

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('MouserControllerScheme') );
			dataObject.SetMemberFlashBool( "disabled", !mouserModeEnabled );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('MouserSensitivityUI') );
			dataObject.SetMemberFlashBool( "disabled", !mouserModeEnabled );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('MouserSensitivityCamera') );
			dataObject.SetMemberFlashBool( "disabled", !mouserModeEnabled );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('MouserInvertX') );
			dataObject.SetMemberFlashBool( "disabled", !mouserModeEnabled );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('MouserInvertY') );
			dataObject.SetMemberFlashBool( "disabled", !mouserModeEnabled );
			dataArray.PushBackFlashObject( dataObject );
		}

		m_flashValueStorage.SetFlashArray( "options.update_disabled", dataArray );

		theGame.GetGuiManager().ForceProcessFlashStorage();
	}

	private function UpdateOunceControlSettingsVisibility()
	{
		var dataObject : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;
		var entriesObject : CScriptedFlashObject;

		 
		var patternsModeCustom_DualGrip : bool = StringToInt(mInGameConfigWrapper.GetVarValue('Controls_DualGrip', 'MotionPatternsMode')) == 3;

		dataArray = m_flashValueStorage.CreateTempFlashArray();
		
		if (!patternsModeCustom_DualGrip)
		{
			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('EnablePatternSign') );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('EnablePatternConsumablePrimary') );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('EnablePatternConsumableSecondary') );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('EnablePatternBomb') );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('EnablePatternCrossbow') );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('EnablePatternHorseSummon') );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('EnablePatternHorseAcceleration') );
			dataArray.PushBackFlashObject( dataObject );

			dataObject = m_flashValueStorage.CreateTempFlashObject();
			dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('EnablePatternHorseStop') );
			dataArray.PushBackFlashObject( dataObject );
		}

		if (dataArray.GetLength() > 0)
		{
			entriesObject = m_flashValueStorage.CreateTempFlashObject();
			entriesObject.SetMemberFlashArray( "list", dataArray );
				
			m_flashValueStorage.SetFlashObject( "options.remove_entry", entriesObject );
			theGame.GetGuiManager().ForceProcessFlashStorage();
		}
	}

	private function UpdateOunceControlSettingsValues()
	{
		var dataObject : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;

		var patternsModeVal_DualGrip : string = mInGameConfigWrapper.GetVarValue('Controls_DualGrip', 'MotionPatternsMode');
		var gyroModeVal_DualGrip : string = mInGameConfigWrapper.GetVarValue('Controls_DualGrip', 'DualGrip_GyroAimingMode');
		var mouserActivationMode : string = mInGameConfigWrapper.GetVarValue('Controls_Mouser', 'MouserActivationMode');

		dataArray = m_flashValueStorage.CreateTempFlashArray();

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('MotionPatternsMode') );
		dataObject.SetMemberFlashString( "current", patternsModeVal_DualGrip );
		dataArray.PushBackFlashObject( dataObject );

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('DualGrip_GyroAimingMode') );
		dataObject.SetMemberFlashString( "current", gyroModeVal_DualGrip );
		dataArray.PushBackFlashObject( dataObject );

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('MouserActivationMode') );
		dataObject.SetMemberFlashString( "current", mouserActivationMode );
		dataArray.PushBackFlashObject( dataObject );

		m_flashValueStorage.SetFlashArray( "options.force_update_values", dataArray );

		theGame.GetGuiManager().ForceProcessFlashStorage();
	}
	
	event  OnCancelOptionValueChange(groupId:int, optionName:name)
	{
		var groupName:name;
		var curTimeGetOption:int;
				
		groupName = mInGameConfigWrapper.GetGroupName(groupId);

		if (groupName == 'Graphics' && optionName == 'AAMode' && theGame.GetIsXESSSupported() == false)
		{
			showNotification(GetPlatformLocString("option_warning_xess_support"));
		}

		if (groupName == 'Graphics' && optionName == 'AAMode' && theGame.GetIsDLSSSupported() == false)
		{
			showNotification(GetPlatformLocString("option_warning_dlss_support"));
		}

		
		
		
		
		
		
		
		
		
		curTimeGetOption = theGame.GetLocalTimeAsMilliseconds();
		if(((curTimeGetOption - lastTimeGetOption) > 300))
		{
			lastTimeGetOption = curTimeGetOption;
			theSound.SoundEvent("gui_global_denied");
		}
	}
	
	event  OnOptionValueChanged(groupId:int, optionName:name, optionValue:string)
	{
		var groupName			: name;
		var hud 				: CR4ScriptedHud;
		var isValid 			: bool;
		var isBuffered 			: bool;
		var value 			: bool;
				
		
		var dialogModule : CR4HudModuleDialog;
		var subtitleModule : CR4HudModuleSubtitles;
		var onelinerModule : CR4HudModuleOneliners;
		
		
		
		var minimapModule : CR4HudModuleMinimap2;
		
		
		
		var objectiveModule : CR4HudModuleQuests;
		

		hasChangedOption = true;
		
		OnPlaySoundEvent( "gui_global_switch" );
		
		
		if (groupId == NameToFlashUInt('SpecialSettingsGroupId'))
		{
			HandleSpecialValueChanged(optionName, optionValue);
			return true;
		}		
		
		
		
		if( optionName == 'GameTelemetryConsent' )
		{
			m_flashValueStorage.SetFlashBool( "options.show_spinner", true );
			
			value = ( optionValue == "true" );
			OnTelemetryConsentChanged( value );
			return true;
		}
		
		if( optionName == 'MarketingTelemetryConsent' )
		{
			value = ( optionValue == "true" );
			theTelemetry.MarketingConsentChanged( value );
		}
		
		
		if (optionName == 'InvertLockOption')
		{
			if ( optionValue == "true" )
				thePlayer.SetInvertedLockOption(true);
			else
				thePlayer.SetInvertedLockOption(false);
		}
		
		if (optionName == 'InvertCameraX')
		{
			if ( optionValue == "true" )
				thePlayer.SetInvertedCameraX(true);
			else
				thePlayer.SetInvertedCameraX(false);
		}
		
		if (optionName == 'InvertCameraY')
		{
			if ( optionValue == "true" )
				thePlayer.SetInvertedCameraY(true);
			else
				thePlayer.SetInvertedCameraY(false);
		}
		
		if (optionName == 'InvertCameraXOnMouse')
		{
			if ( optionValue == "true" )
				thePlayer.SetInvertedMouseCameraX(true);
			else
				thePlayer.SetInvertedMouseCameraX(false);
		}
		
		if (optionName == 'InvertCameraYOnMouse')
		{
			if ( optionValue == "true" )
				thePlayer.SetInvertedMouseCameraY(true);
			else
				thePlayer.SetInvertedMouseCameraY(false);
		}
		
		
		
		if (optionName == 'EnableAlternateSignCasting')
		{
			if ( optionValue == "1" )
			{
				thePlayer.GetInputHandler().SetIsAltSignCasting(true);
				FactsSet( "nge_alt_sign_casting_chosen", 1 );
			}
			else
			{
				thePlayer.GetInputHandler().SetIsAltSignCasting(false);
				FactsSet( "nge_alt_sign_casting_chosen", 0 );
			}
			thePlayer.ApplyCastSettings();
		}
		
		
		
		if (optionName == 'EnableAlternateExplorationCamera')
		{
			thePlayer.SetExplorationCameraIdConfig( StringToInt( optionValue ) );
		}
		
		if (optionName == 'EnableAlternateCombatCamera')
		{
			if (!thePlayer.IsCmbtCameraForced())
			{
				thePlayer.SetCombatCameraDistanceIdConfig( StringToInt( optionValue ) );

			}
		}
		
		if (optionName == 'EnableAlternateHorseCamera')
		{
			if ( optionValue == "1" )
				thePlayer.SetHorseCamera(true);
			else
				thePlayer.SetHorseCamera(false);
		}
		
		if (optionName == 'SoftLockCameraAssist')
		{
			if ( optionValue == "true" )
				thePlayer.SetSoftLockCameraAssist(true);
			else
				thePlayer.SetSoftLockCameraAssist(false);
		}
		
		
		
		if (optionName == 'SubtitleScale')
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			
			if(hud)
			{
				dialogModule = (CR4HudModuleDialog)hud.GetHudModule("DialogModule");
				if(dialogModule)
					dialogModule.SetSubtitleScale( StringToInt(optionValue) );
				
				subtitleModule = (CR4HudModuleSubtitles)hud.GetHudModule("SubtitlesModule");
				if(subtitleModule)
					subtitleModule.SetSubtitleScale( StringToInt(optionValue) );
			}
		}
		
		if (optionName == 'DialogChoiceScale')
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			
			if(hud)
			{
				dialogModule = (CR4HudModuleDialog)hud.GetHudModule("DialogModule");
				if(dialogModule)
					dialogModule.SetDialogChoiceScale( StringToInt(optionValue) );
			}
		}
		
		if (optionName == 'OnelinerScale')
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			
			if(hud)
			{
				onelinerModule = (CR4HudModuleOneliners)hud.GetHudModule("OnelinersModule");
				if(onelinerModule)
					onelinerModule.SetOnelinerScale( StringToInt(optionValue) );
			}
		}
		
		
		if (optionName == 'WidescreenCutscene' && optionValue == "true")
		{
			theGame.GetGuiManager().ShowUserDialog(0, "", "message_widescreen_cutscene_use_cachets_disclaimer", UDB_Ok);
		}
		
		
		if (optionName == 'MinimapDuringFocusCombat')
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			
			if(hud)
			{
				minimapModule = (CR4HudModuleMinimap2)hud.GetHudModule("Minimap2Module");
				if(minimapModule)
				{
					if ( optionValue == "true" )
					{
						minimapModule.SetMinimapDuringFocusCombat( true );
					}
					else
					{
						minimapModule.SetMinimapDuringFocusCombat( false );
					}
				}					
			}
		}
		
		
		
		if (optionName == 'ObjectiveDuringFocusCombat')
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			
			if(hud)
			{
				objectiveModule = (CR4HudModuleQuests)hud.GetHudModule("QuestsModule");
				if(objectiveModule)
				{
					if ( optionValue == "true" )
					{
						objectiveModule.SetObjectiveDuringFocusCombat( true );
					}
					else
					{
						objectiveModule.SetObjectiveDuringFocusCombat( false );
					}
				}					
			}
		}
		
		
		
		if (optionName == 'LeftStickSprint')
		{
			if ( optionValue == "true" )
				thePlayer.SetLeftStickSprint(true);
			else
				thePlayer.SetLeftStickSprint(false);
		}
		
		
		
		if (optionName == 'AutoApplyBladeOils')
		{
			if ( optionValue == "true" )
				thePlayer.SetAutoApplyOils(true);
			else
				thePlayer.SetAutoApplyOils(false);
		}
		
		
		if (optionName == 'HardwareCursor')
		{
			isValid = optionValue;
			m_fxSetHardwareCursorOn.InvokeSelfOneArg(FlashArgBool(isValid));
		}
		
		if (optionName == 'SwapAcceptCancel')
		{
			swapAcceptCancelChanged = true;
		}
		
		if (optionName == 'AlternativeRadialMenuInputMode')
		{
			alternativeRadialInputChanged = true;
		}
		
		if (optionName == 'EnableUberMovement')
		{
			if ( optionValue == "1" )
				theGame.EnableUberMovement( true );
			else
				theGame.EnableUberMovement( false );
		}
		
		if (optionName == 'GwentDifficulty')
		{
			if ( optionValue == "0" )
				FactsSet( 'gwent_difficulty' , 1 );
			else if ( optionValue == "1" )
				FactsSet( 'gwent_difficulty' , 2 );
			else if ( optionValue == "2" )
				FactsSet( 'gwent_difficulty' , 3 );
			
			return true;
		}
		
		if (optionName == 'HardwareCursor')
		{
			updateInputDeviceRequired = true;
		}
		
		groupName = mInGameConfigWrapper.GetGroupName( groupId );
		
		
		isBuffered = 
			( mInGameConfigWrapper.DoGroupHasTag( groupName, 'buffered' ) || mInGameConfigWrapper.DoVarHasTag( groupName, optionName, 'buffered' ) )
			&& !mInGameConfigWrapper.DoVarHasTag( groupName, optionName, 'dropDown' )
			&& !mInGameConfigWrapper.DoVarHasTag( groupName, optionName, 'nonbuffered' );
		
		if ( groupName == 'Localization' &&
			 optionName == 'Virtual_Localization_speech' && 
			 theGame.GetVoiceLangDownloadStatus( mInGameConfigWrapper.GetVarOption( groupName, optionName, StringToInt( optionValue ) ) ) != STREAMABLE_LOADED 
			)
		{
			return true;
		}
		
		if( isBuffered == true )
		{
			inGameConfigBufferedWrapper.SetVarValue(groupName, optionName, optionValue);
		}
		else
		{
			mInGameConfigWrapper.SetVarValue(groupName, optionName, optionValue);
		}
			
		theGame.OnConfigValueChanged(optionName, optionValue);
		
		if (groupName == 'Hud' || optionName == 'Subtitles' || optionName == 'LootFeedModule')
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			
			if (hud)
			{
				hud.UpdateHudConfig(optionName, true);
			}
		}
		
		if (groupName == 'Localization')
		{
			if (optionName == 'Virtual_Localization_text')
			{
				currentLangValue = optionValue;
			}
			else if (optionName == 'Virtual_Localization_speech')
			{
				currentSpeechLang = optionValue;
			}
		}
		
		if (groupName == 'Rendering' && !isMainMenu)
		{
			m_fxForceBackgroundVis.InvokeSelfOneArg(FlashArgBool(true));
		}
		
		if (groupName == 'Rendering' && optionName == 'PreserveSystemGamma')
		{
			theGame.GetGuiManager().DisplayRestartGameToApplyAllChanges();
		}
		
		if(optionName == 'EnableRT')
		{
			
			if( optionValue == "true" )
			{
				if(StringToInt(mInGameConfigWrapper.GetVarValue('PostProcess', 'Virtual_SSAOSolution')) != IGMOPT_AO_NRDRTAO)
				{
					mInGameConfigWrapper.SetVarValue('PostProcess', 'Virtual_SSAOSolution', IntToString(IGMOPT_AO_NRDRTAO));
				}
			}
			if( optionValue == "false" )
			{
				if(StringToInt(mInGameConfigWrapper.GetVarValue('PostProcess', 'Virtual_SSAOSolution')) >= IGMOPT_AO_RTAO)
				{
					mInGameConfigWrapper.SetVarValue('PostProcess', 'Virtual_SSAOSolution', IntToString(IGMOPT_AO_SSAO));
				}
			}
			
			UpdateAO2CorrespondRT(optionValue == "true", false);
			UpdatePresetOptions('PostProcess', false);

			
			updateRTOptionEnabled(optionValue == "true");
			updatePTOptionEnabled(theGame.GetPTEnabled());
			updateRTAOOptionChanged();
			updateRTROptionChanged();
			
			updateDLSSRR( optionValue == "true" && theGame.GetDLSSEnabled() );
			updatePTHairOptionChanged();
		}
		
		if (optionName == 'AllowMotionBlur')
		{
			updateMotionBlurOptionChanged(optionValue == "true");
		}

		
		if (optionName == 'AccessibilityPreset')
		{
			UpdateBardsBalladTooltipText();
		}

		
		
		
		
		
		

		
		
		
		
		
		

		if ( optionName == 'Virtual_HairWorksLevel' )
		{
			updateHairWorksOptionChanged();
			updatePTHairOptionChanged();
		}
		
		if( optionName == 'AAMode' )
		{
			UpdatePresetOptions('PostProcess', true);
			updateAAOptionChanged();

			
			if ( theGame.GetDLSSEnabled() && theGame.GetRTEnabled() )
			{
				updateDLSSRR( true );
			}

			updatePTHairOptionChanged();
		}

		if (optionName == 'EnableDLSSRR')
		{
			updatePTHairOptionChanged();
		}

		if (optionName == 'PTEnable')
		{
			updatePTOptionEnabled(optionValue == "true");
			updateRTAOOptionChanged();
			updateRTROptionChanged();
			updatePTHairOptionChanged();

			
			if ( optionValue == "true" && theGame.GetDLSSEnabled() )
			{
				updateDLSSRR( true );
			}
		}

		if (optionName == 'RTAOEnabled')
		{
			updateRTAOOptionChanged();
		}

		if (optionName == 'SSAOEnabled')
		{
			updateSSAOOptionChanged();
		}

		if (optionName == 'Virtual_RTShadows')
		{
			updateRTShadowOptionChanged();
		}

		if (optionName == 'EnableRtRadiance')
		{
			updateRTROptionChanged();
		}
		
		if( optionName == 'DeveloperMode' )
		{
			ShowDeveloperOptions( optionValue == "true" );
		}

		if (optionName == 'GraphicsPreset')
		{
			setLocksOnPresetChanged();
		}

		if (optionName == 'Virtual_DLSSG')
		{
			updateFGorLLOptionChangedCommon();
		}

		if (optionName == 'Virtual_Reflex')
		{
			updateFGorLLOptionChangedCommon();			
		}
		
		if (optionName == 'XessFrameGeneration')
		{
			updateFGorLLOptionChangedCommon();
		}
		
		if (optionName == 'XeLowLatency')
		{
			updateFGorLLOptionChangedCommon();
		}

		if (optionName == 'XeLowLatencyFrameRateControl')
		{
			updateFGorLLOptionChangedCommon();
		}

		if (optionName == 'Virtual_FSRFramegen')
		{
			updateFGorLLOptionChangedCommon();
		}

		if (optionName == 'AMDAntiLag')
		{
			updateFGorLLOptionChangedCommon();
		}

		IngameMenu_AdditionalOptionValueChangeHandling( groupName, optionName, optionValue, m_flashValueStorage );

		
		
		
		
		
		
		if ( optionName == 'CrossProgression' )
		{
			theGame.UpdateCrossProgressionValue( optionValue );
		}
		
		if ( optionName == 'LowHPAutoHealOn'
			|| optionName == 'LowHPAutoHealThreshold'
			|| optionName == 'LowHPAutoHealMultiplier')
		{
			updateAutohealOptionChanged();
		}

		if (!btPresetInitialized)
			initializeAccessibilityPreset();
		
		if(groupName == 'Accessibility'
			&& checkAccessibilityPresetNeedUpdate(optionName, optionValue == "true"))
		{
			updateAccessibilityPresetToCustom();
		}

		if( optionName == 'AccessibilityPreset' && optionValue != IntToString(AP_Custom))
		{
			updateAccessibilityPresetValues( StringToInt(optionValue), true );
		}

		if(optionName == 'WeightlessItems' && GetWitcherPlayer())
		{
			GetWitcherPlayer().UpdateEncumbrance();
		}
		
		if(optionName == 'GodMode')
		{
			thePlayer.SetImmortalityMode( optionValue == "0" ? AIM_None : (optionValue == "1" ? AIM_Immortal : AIM_Invulnerable), AIC_Cheat, true);
		}

		if ( groupName == 'Gameplay' )
		{
			if ( optionName == 'Enabled')
			{
				updateDisableAllMods();
			}
			else if ( optionName == 'EnabledLocal')
			{
				updateEnableLocalMods();
			}
			else if ( optionName == 'EnabledWorkshop')
			{
				updateEnableWorkshopMods();
			}
		}

		if ( optionName == 'ModioEnabled')
		{
			updateEnableModIo( optionValue );
		}

		
		if ( optionName == 'CombatStyle' )
		{
			updateCombatStyle( optionValue );
			thePlayer.SetModernCombat( optionValue );
		}

		if ( optionName == 'UseMovementForKBM' )
		{
			thePlayer.SetMovementTargetingKeyboard( optionValue );
		}

		if ( optionName == 'TargetLockStyle' )
		{
			thePlayer.SetModernTargetLock( optionValue );
		}

		if ( optionName == 'TargetLockCameraSpeed' )
		{
			thePlayer.SetFastLockCamera( optionValue );
		}
		

		
		if ( optionName == 'TargetLockSwitchCooldown' )
		{
			thePlayer.SetTargetLockSwitchCooldown( StringToFloat( optionValue ) );
		}

		if ( optionName == 'UseNewAnimations' )
		{
			thePlayer.SetUseNewAnimations( optionValue );
		}

		if( optionName == 'RemasterLadderAnims' )
		{
			thePlayer.SetUseNewLadderAnimations( optionValue );
		}

		if ( optionName == 'JumpCooldown' )
		{
			thePlayer.SetJumpCooldown( StringToFloat( optionValue ) );
		}

		if ( optionName == 'LandAddCoef' )
		{
			thePlayer.SetLandAddCoefVal( StringToFloat( optionValue ) );
		}

		if ( optionName == 'LandAddTimeCoef' )
		{
			thePlayer.SetLandAddTimeCoefVal( StringToFloat( optionValue ) );
		}

		if ( optionName == 'LandAddTimeCoefFast' )
		{
			thePlayer.SetLandAddTimeCoefFast( StringToFloat( optionValue ) );
		}

		if ( optionName == 'LandAddCoefWalk' )
		{
			thePlayer.SetLandAddCoefWalk( StringToFloat( optionValue ) );
		}

		if ( optionName == 'LandAddTimeCoefWalk' )
		{
			thePlayer.SetLandAddTimeCoefWalk( StringToFloat( optionValue ) );
		}

		
		if ( optionName == 'ExplCamFov' && thePlayer.IsModernExplorationCamera() )
		{
			thePlayer.SetExplorationCameraFov( StringToFloat( optionValue ) );
		}
		
		

		if (optionName == 'UseNewControls')
		{
			updateUseNewControlsOptionChanged( optionValue == "true" );
		}
	}
	
	private function updateUseNewControlsOptionChanged(enabled:bool)
	{
		var dataObject : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;

		dataArray = m_flashValueStorage.CreateTempFlashArray();

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('SteeringSensitivity') );
		dataObject.SetMemberFlashBool( "disabled", !enabled);
		dataArray.PushBackFlashObject(dataObject);
		
		m_flashValueStorage.SetFlashArray( "options.update_disabled", dataArray );
		
		theGame.GetGuiManager().ForceProcessFlashStorage();
	}

	private function updateMotionBlurOptionChanged(enabled:bool):void
	{
		var dataObject : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;

		dataArray = m_flashValueStorage.CreateTempFlashArray();

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('MotionBlurIntensity') );
		dataObject.SetMemberFlashBool( "disabled", !enabled);
		dataArray.PushBackFlashObject(dataObject);
		
		m_flashValueStorage.SetFlashArray( "options.update_disabled", dataArray );
		
		theGame.GetGuiManager().ForceProcessFlashStorage();
	}

	private function setLocksOnPresetChanged():void
	{
		setLocksOnRTChange(theGame.GetRTEnabled());
		updateHairWorksOptionChanged();
		updateAAOptionChanged();
		updatePTHairOptionChanged();
	}

	private function setLocksOnRTChange(enabled:bool):void
	{
		UpdateAO2CorrespondRT(enabled, false);
		UpdatePresetOptions('PostProcess', true);
		updateRTOptionEnabled(enabled);
		updatePTOptionEnabled(theGame.GetPTEnabled());
		updateRTAOOptionChanged();
		updateRTROptionChanged();
	}

	private function updateOptionsDisableState():void
	{
		updateRTOptionEnabled(theGame.GetRTEnabled());
		updatePTOptionEnabled(theGame.GetPTEnabled());
		updateAAOptionChanged();
		updateHairWorksOptionChanged();
		updateRTAOOptionChanged();
		updateRTROptionChanged();
		updatePTHairOptionChanged();
		updateFGorLLOptionChangedCommon();
	}

	
	
	private function validatePTHairOptionValue():bool
	{
		var currentValue : string;

		if (IngameMenu_IsPTHairAvailable()) return false;

		
		currentValue = mInGameConfigWrapper.GetVarValue('Graphics', 'PTHairQualityMode');
		if (currentValue == "" || currentValue == "0") return false;

		mInGameConfigWrapper.SetVarValue('Graphics', 'PTHairQualityMode', "0");
		hasChangedOption = true;
		return true;
	}

	
	protected function updatePTHairOptionChanged():void
	{
		var dataObject : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;

		if (validatePTHairOptionValue())
		{
			m_fxUpdateOptionValue.InvokeSelfTwoArgs( FlashArgUInt(NameToFlashUInt('PTHairQualityMode')), FlashArgString("0") );
		}

		dataArray = m_flashValueStorage.CreateTempFlashArray();
		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('PTHairQualityMode') );
		dataObject.SetMemberFlashBool( "disabled", !IngameMenu_IsPTHairAvailable() );
		dataArray.PushBackFlashObject(dataObject);
		m_flashValueStorage.SetFlashArray( "options.update_disabled", dataArray );

		theGame.GetGuiManager().ForceProcessFlashStorage();
	}

	protected function updateRTOptionEnabled(enabled:bool):void
	{
		var dataObject : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;

		dataArray = m_flashValueStorage.CreateTempFlashArray();

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('EnableRT') );
		dataObject.SetMemberFlashBool( "disabled", !theGame.GetRTSupported() );
		if (!theGame.GetRTSupported())
		{
			
			dataObject.SetMemberFlashString( "current", "0" );
		}
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('PTEnable') );
		dataObject.SetMemberFlashBool( "disabled", !enabled);
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('RTGIPreset') );
		dataObject.SetMemberFlashBool( "disabled", !enabled);
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('EnableRtRadiance') );
		dataObject.SetMemberFlashBool( "disabled", !enabled);
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Virtual_RTShadows') );
		dataObject.SetMemberFlashBool( "disabled", !enabled);
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('RTAOEnabled') );
		dataObject.SetMemberFlashBool( "disabled", !enabled);
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Virtual_GlobalIllumination') );
		dataObject.SetMemberFlashBool( "disabled", !enabled);
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Virtual_ShadowsOptionVar') );
		dataObject.SetMemberFlashBool( "disabled", theGame.GetRTShadowsEnabled() );
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Virtual_SSREnabled') );
		dataObject.SetMemberFlashBool( "disabled", theGame.GetRTREnabled() );
		dataArray.PushBackFlashObject(dataObject);

		m_flashValueStorage.SetFlashArray( "options.update_disabled", dataArray );
		
		theGame.GetGuiManager().ForceProcessFlashStorage();
	}

	protected function updatePTOptionEnabled(enabled:bool):void
	{
		var dataObject : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;

		if ( !theGame.GetRTSupported() || !theGame.GetRTEnabled()) return; 

		dataArray = m_flashValueStorage.CreateTempFlashArray();

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('RTGIPreset') );
		dataObject.SetMemberFlashBool( "disabled", enabled);
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('EnableRtRadiance') );
		dataObject.SetMemberFlashBool( "disabled", enabled);
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Virtual_RTShadows') );
		dataObject.SetMemberFlashBool( "disabled", enabled);
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('RTAOEnabled') );
		dataObject.SetMemberFlashBool( "disabled", enabled);
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('SSAOEnabled') );
		dataObject.SetMemberFlashBool( "disabled", theGame.GetRTAOEnabled() );
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Virtual_GTAOQuality') );
		dataObject.SetMemberFlashBool( "disabled", theGame.GetRTAOEnabled() || !theGame.GetGTAOEnabled() );
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Virtual_ShadowsOptionVar') );
		dataObject.SetMemberFlashBool( "disabled", theGame.GetRTShadowsEnabled() );
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Virtual_SSREnabled') );
		dataObject.SetMemberFlashBool( "disabled", theGame.GetRTREnabled() );
		dataArray.PushBackFlashObject(dataObject);

		m_flashValueStorage.SetFlashArray( "options.update_disabled", dataArray );
		
		theGame.GetGuiManager().ForceProcessFlashStorage();
	}

	private function updateDynamicResolutionScalingEnabledOption(out StructGFx : CScriptedFlashArray) : void
	{
		var dataObject : CScriptedFlashObject;

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Virtual_DynamicResolutionScaling') );

		if ( theGame.GetDLSSEnabled()
			|| theGame.GetXESSEnabled()
			|| theGame.GetDLSSGEnabled() )
		{
			dataObject.SetMemberFlashString( "current", "false" );
			dataObject.SetMemberFlashBool( "disabled", true );
		}
		else
		{
			dataObject.SetMemberFlashString( "current", theGame.GetDynamicResolutionScalingEnabled() ? "1" : "0" );
			dataObject.SetMemberFlashBool( "disabled", false );
		}

		StructGFx.PushBackFlashObject(dataObject);
	}

	protected function updateAAOptionChanged():void
	{
		var dataObject : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;

		dataArray = m_flashValueStorage.CreateTempFlashArray();

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('FSRQuality') );
		dataObject.SetMemberFlashBool( "disabled", !theGame.GetFSREnabled());
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('DLSSQuality') );
		dataObject.SetMemberFlashBool( "disabled", !theGame.GetDLSSEnabled());
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('XESSQuality') );
		dataObject.SetMemberFlashBool( "disabled", !theGame.GetXESSEnabled());
		dataArray.PushBackFlashObject(dataObject);

		updateDynamicResolutionScalingEnabledOption( dataArray );

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Virtual_SharpenAmount') );
		dataObject.SetMemberFlashBool( "disabled", false );
		dataArray.PushBackFlashObject(dataObject);
		
		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('EnableDLSSRR') );
		dataObject.SetMemberFlashBool( "disabled", !theGame.GetDLSSEnabled() || !theGame.GetDLSSRRSupported() || !theGame.GetRTEnabled() );
		dataArray.PushBackFlashObject(dataObject);

		m_flashValueStorage.SetFlashArray( "options.update_disabled", dataArray );
		
		theGame.GetGuiManager().ForceProcessFlashStorage();
	}

	private function updateDLSSRR( setEnabled : bool ) : void
	{
		var dataObject : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;

		dataArray = m_flashValueStorage.CreateTempFlashArray();

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('EnableDLSSRR') );
		dataObject.SetMemberFlashBool( "disabled", !theGame.GetDLSSEnabled() || !theGame.GetDLSSRRSupported() || !theGame.GetRTEnabled() );

		if ( setEnabled )
		{
			dataObject.SetMemberFlashString( "current", "1" );
		}
		dataArray.PushBackFlashObject(dataObject);
		
		m_flashValueStorage.SetFlashArray( "options.update_disabled", dataArray );
		
		theGame.GetGuiManager().ForceProcessFlashStorage();
	}

	protected function updateHairWorksOptionChanged():void
	{
		var dataObject : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;

		dataArray = m_flashValueStorage.CreateTempFlashArray();

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Virtual_HairWorksAALevel') );
		dataObject.SetMemberFlashBool( "disabled", !theGame.GetHairWorksEnabled());
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Virtual_HairWorksQualityPreset') );
		dataObject.SetMemberFlashBool( "disabled", !theGame.GetHairWorksEnabled());
		dataArray.PushBackFlashObject(dataObject);

		m_flashValueStorage.SetFlashArray( "options.update_disabled", dataArray );
		
		theGame.GetGuiManager().ForceProcessFlashStorage();
	}

	protected function updateRTAOOptionChanged():void
	{
		var dataObject : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;

		dataArray = m_flashValueStorage.CreateTempFlashArray();

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('SSAOEnabled') );
		dataObject.SetMemberFlashBool( "disabled", theGame.GetRTAOEnabled() );
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Virtual_GTAOQuality') );
		dataObject.SetMemberFlashBool( "disabled", theGame.GetRTAOEnabled() || !theGame.GetGTAOEnabled() );
		dataArray.PushBackFlashObject(dataObject);

		m_flashValueStorage.SetFlashArray( "options.update_disabled", dataArray );
		
		theGame.GetGuiManager().ForceProcessFlashStorage();
	}

	protected function updateSSAOOptionChanged():void
	{
		var dataObject : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;

		dataArray = m_flashValueStorage.CreateTempFlashArray();

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Virtual_GTAOQuality') );
		dataObject.SetMemberFlashBool( "disabled", theGame.GetRTAOEnabled() || !theGame.GetGTAOEnabled() );
		dataArray.PushBackFlashObject(dataObject);

		m_flashValueStorage.SetFlashArray( "options.update_disabled", dataArray );
		
		theGame.GetGuiManager().ForceProcessFlashStorage();
	}

	protected function updateRTShadowOptionChanged():void
	{
		var dataObject : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;

		dataArray = m_flashValueStorage.CreateTempFlashArray();

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Virtual_ShadowsOptionVar') );
		dataObject.SetMemberFlashBool( "disabled", theGame.GetRTShadowsEnabled() );
		dataArray.PushBackFlashObject(dataObject);

		m_flashValueStorage.SetFlashArray( "options.update_disabled", dataArray );
		
		theGame.GetGuiManager().ForceProcessFlashStorage();
	}

	protected function initializeAccessibilityPreset() : void
	{
		btPresetMap['LowHPAutoHealOn'] = true;
		btPresetMap['NoAirDrain'] = true;
		btPresetMap['DisableDurabilityItem'] = true;
		btPresetMap['DisableDurabilityBoat'] = true;
		btPresetMap['WeightlessItems'] = true;
		btPresetMap['AutoLoot'] = true;
		btPresetMap['FastBoats'] = true;
		btPresetMap['HideHerbs'] = true;
		btPresetMap['HideCorpse'] = true;
		btPresetMap['DisableAutomaticSwordSheathe'] = false;
		btPresetMap['AutoApplyBladeOils'] = true;

		btPresetInitialized = true;
	}

	protected function checkAccessibilityPresetNeedUpdate(optionName : name, optionValue : bool) : bool
	{
		var l_curPreset : AccessibilityPresets;
		var l_btOn : bool;
		
		l_curPreset = StringToInt(mInGameConfigWrapper.GetVarValue('Accessibility', 'AccessibilityPreset'));
		
		if (l_curPreset == AP_Custom)
		 return false;

		l_btOn = l_curPreset == AP_BardsTale;

		return btPresetMap.Contains(optionName) && ((btPresetMap[optionName] != optionValue) == l_btOn);
	}

	protected function updateAccessibilityPresetToCustom() : void
	{
		var dataObject : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;

		dataArray = m_flashValueStorage.CreateTempFlashArray();

		mInGameConfigWrapper.SetVarValue('Accessibility', 'AccessibilityPreset', IntToString(AP_Custom));

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('AccessibilityPreset') );
		dataObject.SetMemberFlashString( "current", IntToString(AP_Custom));
		dataArray.PushBackFlashObject( dataObject );

		m_flashValueStorage.SetFlashArray( "options.update_disabled", dataArray );
		theGame.GetGuiManager().ForceProcessFlashStorage();
	}
	
	protected function updateAccessibilityPresetValues(newPreset : AccessibilityPresets, inSettingsMenu : bool) : void
	{
		var dataObject : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;
		
		var i : int;
		var l_optionName : name;
		var l_newValue : bool;
		
		if (!btPresetInitialized)
			initializeAccessibilityPreset();

		if (inSettingsMenu)
			dataArray = m_flashValueStorage.CreateTempFlashArray();
		else
			mInGameConfigWrapper.SetVarValue('Accessibility', 'AccessibilityPreset', IntToString(newPreset));

		for (i = 0; i < btPresetMap.Size(); i += 1)
		{
			l_optionName = btPresetMap.Key(i);
			l_newValue = btPresetMap[l_optionName] == (newPreset == AP_BardsTale);

			mInGameConfigWrapper.SetVarValue('Accessibility', l_optionName, l_newValue ? "true" : "false");
			if (inSettingsMenu)
			{
				dataObject = m_flashValueStorage.CreateTempFlashObject();
				dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt(l_optionName) );
				dataObject.SetMemberFlashString( "current", l_newValue );
				dataArray.PushBackFlashObject( dataObject );
			}
		}

		if (inSettingsMenu)
		{
			m_flashValueStorage.SetFlashArray( "options.update_disabled", dataArray );
			theGame.GetGuiManager().ForceProcessFlashStorage();
		}

		updateAutohealOptionChanged();
	}

	protected function updateFGorLLOptionChangedCommon():void
	{
		var dataObject : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;
		var vendorName : string;

		
		var reflexLLEnabled : bool;
		var dlssgEnabled : bool;
		var dlssgSupported : bool;
		var dlssgEnabledDynamic : bool;
		var DLSSGMaxNumFrames : int;

		
		var fsrFrameGenEnabled : bool;
		var amdAntiLagEnabled : bool;

		
		var xeFGEnabled : bool;
		var xeLLEnabled : bool;

		

		
		reflexLLEnabled = theGame.GetReflexEnabled();
		dlssgEnabled = theGame.GetDLSSGEnabled();
		dlssgSupported = theGame.GetDLSSGSupported();
		dlssgEnabledDynamic = theGame.GetDLSSGEnabledDynamic();
		DLSSGMaxNumFrames = theGame.GetDLSSGMaxNumFrames();
		fsrFrameGenEnabled = theGame.GetFSRFramegenEnabled();
		amdAntiLagEnabled = theGame.GetAMDAntiLagEnabled();
		xeFGEnabled = theGame.GetXESSFGEnabled();
		xeLLEnabled = theGame.GetXELLEnabled();
		vendorName = "none";

		if (reflexLLEnabled || dlssgEnabled )
		{
			
			vendorName = "nvidia";

			fsrFrameGenEnabled = false;
			amdAntiLagEnabled = false;
			xeFGEnabled = false;
			xeLLEnabled = false;
		}

		if(fsrFrameGenEnabled || amdAntiLagEnabled)
		{
			
			vendorName = "amd";

			reflexLLEnabled = false;
			dlssgEnabled = false;
			dlssgEnabledDynamic = false;
			xeFGEnabled = false;
			xeLLEnabled = false;
		}

		if ( xeLLEnabled || xeFGEnabled )
		{
			
			vendorName = "intel";

			reflexLLEnabled = false;
			dlssgEnabled = false;
			dlssgEnabledDynamic = false;
			fsrFrameGenEnabled = false;
			amdAntiLagEnabled = false;
		}
		
		dataArray = m_flashValueStorage.CreateTempFlashArray();

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('XessFrameGeneration') );
		dataObject.SetMemberFlashString( "current", xeFGEnabled ? "1" : "0" );
		dataObject.SetMemberFlashBool( "disabled", vendorName == "nvidia" || vendorName == "amd" );
		dataArray.PushBackFlashObject(dataObject);
		
		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('XeLowLatency') );
		dataObject.SetMemberFlashString( "current", xeLLEnabled ? "1" : "0" );
		dataObject.SetMemberFlashBool( "disabled", vendorName == "nvidia" || vendorName == "amd" );
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Virtual_Reflex') );
		if ( dlssgEnabled )
		{
			dataObject.SetMemberFlashString( "current", "1" );
		}
		else if ( !reflexLLEnabled )
		{
			dataObject.SetMemberFlashString( "current", "0" );
		}
		dataObject.SetMemberFlashBool( "disabled", dlssgEnabled || vendorName == "intel" || vendorName == "amd" || !theGame.GetReflexSupported() );
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Virtual_DLSSG') );
		if ( mInGameConfigWrapper.GetVarValue('Graphics', 'Virtual_DLSSG') == "-1" ) dataObject.SetMemberFlashString( "current", dlssgEnabled ? "1" : "0" );
		if ( !dlssgSupported ) dataObject.SetMemberFlashString( "current", "0" );
		dataObject.SetMemberFlashBool( "disabled", vendorName == "intel" || vendorName == "amd" || !dlssgSupported  );
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Virtual_DLSSG_Count') );
		if ( mInGameConfigWrapper.GetVarValue('Graphics', 'Virtual_DLSSG_Count') == "-1" ) dataObject.SetMemberFlashString( "current", IntToString( DLSSGMaxNumFrames - 1 ) );
		dataObject.SetMemberFlashBool( "disabled", !dlssgEnabled || dlssgEnabledDynamic );
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Virtual_FSRFramegen') );
		dataObject.SetMemberFlashString( "current", fsrFrameGenEnabled ? "1" : "0" );
		dataObject.SetMemberFlashBool( "disabled", vendorName == "nvidia" || vendorName == "intel" || !theGame.GetFSRFramegenSupported() );
		dataArray.PushBackFlashObject(dataObject);

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('AMDAntiLag') );
		dataObject.SetMemberFlashString( "current", amdAntiLagEnabled ? "1" : "0" );
		dataObject.SetMemberFlashBool( "disabled", vendorName == "nvidia" || vendorName == "intel" || !theGame.GetAMDAntiLagSupported() );
		dataArray.PushBackFlashObject(dataObject);

		updateDynamicResolutionScalingEnabledOption( dataArray );

		m_flashValueStorage.SetFlashArray( "options.update_disabled", dataArray );
		
		theGame.GetGuiManager().ForceProcessFlashStorage();
	}

	
	protected function updateAutohealOptionChanged():void
	{
		var autohealOn : bool;
		var autohealMultiplier : int;
		var autohealThreshold : float;
		var dataObject : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;
		var inGameConfigWrapper : CInGameConfigWrapper;
		var i : int;
		var effectsSize : int;
		var effects : array< CBaseGameplayEffect >;
		var regenEffect : W3Effect_AutoVitalityRegen;
		
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();	
		
		autohealOn = inGameConfigWrapper.GetVarValue('Accessibility', 'LowHPAutoHealOn') == "true";
		autohealMultiplier = StringToInt(inGameConfigWrapper.GetVarValue('Accessibility', 'LowHPAutoHealMultiplier'));
		autohealThreshold = StringToFloat(inGameConfigWrapper.GetVarValue('Accessibility', 'LowHPAutoHealThreshold'));
		
		dataArray = m_flashValueStorage.CreateTempFlashArray();
		
		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('LowHPAutoHealThreshold') );
		dataObject.SetMemberFlashBool( "disabled", !autohealOn);
		dataArray.PushBackFlashObject(dataObject);
		
		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('LowHPAutoHealMultiplier') );
		dataObject.SetMemberFlashBool( "disabled", !autohealOn);
		dataArray.PushBackFlashObject(dataObject);
		
		m_flashValueStorage.SetFlashArray( "options.update_disabled", dataArray );
		
		theGame.GetGuiManager().ForceProcessFlashStorage();
		
		
		
		effects = thePlayer.GetCurrentEffects();
		effectsSize = effects.Size();
		for( i = 0; i < effectsSize; i += 1 )
		{
			if(effects[i] && effects[i].GetEffectType() == EET_AutoVitalityRegen)
			{
				regenEffect = (W3Effect_AutoVitalityRegen) effects[i];
				if(regenEffect)
					regenEffect.RequestValueUpdates();
			}
		}
		
	}
	
	protected function updateEnableModIo( enabled:bool ):void
	{
		theGame.GetGuiManager().DisplayModRestartNeededDialog(this, "panel_restart_needed", "mods_enabled_change", MRMT_EnabledChange);
	}
	
	protected function updateDisableAllMods():void
	{	
		var dataObject : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;
		var areModsEnabled : bool;

		areModsEnabled = theGame.AreModsEnabled(); 

		dataArray = m_flashValueStorage.CreateTempFlashArray();

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt( 'ModioEnabled' ) );
		dataObject.SetMemberFlashBool( "disabled", !areModsEnabled );
		dataArray.PushBackFlashObject( dataObject );

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt( 'EnabledLocal' ) );
		dataObject.SetMemberFlashBool( "disabled", !areModsEnabled );
		dataArray.PushBackFlashObject( dataObject );
		
		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt( 'EnabledWorkshop' ) );
		dataObject.SetMemberFlashBool( "disabled", !areModsEnabled );
		dataArray.PushBackFlashObject( dataObject );

		m_flashValueStorage.SetFlashArray( "options.update_disabled", dataArray );
		
		theGame.GetGuiManager().ForceProcessFlashStorage();
		theGame.GetGuiManager().DisplayModRestartNeededDialog( this, "panel_restart_needed", "mods_enabled_change", MRMT_EnabledChange );
	}

	protected function updateEnableLocalMods():void
	{	
		theGame.GetGuiManager().DisplayModRestartNeededDialog( this, "panel_restart_needed", "mods_enabled_change", MRMT_EnabledChange );
	}

	protected function updateEnableWorkshopMods():void
	{	
		theGame.GetGuiManager().DisplayModRestartNeededDialog( this, "panel_restart_needed", "mods_enabled_change", MRMT_EnabledChange );
	}

	protected function updateCombatStyle( value: bool ):void
	{
		var dataObject : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;

		dataArray = m_flashValueStorage.CreateTempFlashArray();

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt( 'UseMovementForKBM' ) );
		dataObject.SetMemberFlashBool( "disabled", !value );
		dataArray.PushBackFlashObject( dataObject );

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt( 'EnableUberMovement' ) );
		dataObject.SetMemberFlashBool( "disabled", value );
		dataArray.PushBackFlashObject( dataObject );

		m_flashValueStorage.SetFlashArray( "options.update_disabled", dataArray );
		
		theGame.GetGuiManager().ForceProcessFlashStorage();
	}
	
	protected function updateRTROptionChanged():void
	{
		var dataObject : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;

		dataArray = m_flashValueStorage.CreateTempFlashArray();

		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Virtual_SSREnabled') );
		dataObject.SetMemberFlashBool( "disabled", theGame.GetRTREnabled() );
		dataArray.PushBackFlashObject(dataObject);

		m_flashValueStorage.SetFlashArray( "options.update_disabled", dataArray );
		
		theGame.GetGuiManager().ForceProcessFlashStorage();
	}
	
	event  OnButtonClicked( groupId:int, optionName : name )
	{
		var groupName : name = mInGameConfigWrapper.GetGroupName(groupId);
		if ( groupName == 'Gameplay' && optionName == 'RequestCollectedTelemetry' )
		{
			ShowTelemetryDataRequestPopup();
		}
		else if ( optionName == 'MoreSpeechLanguages' )
		{
			theGame.DisplayStore();
		}
	}
	
	event  OnOptionSelectionChanged( optionName : name, value : bool)
	{
		if (!postprocessEntered && optionName == 'AAMode')
		{
			UpdatePresetOptions('PostProcess', true);
			postprocessEntered = true;
			updateAAOptionChanged();
		}
		
		if ( optionName == 'EnableRT')
		{
			
			if (value && postprocessRtGreyed == true)
			{
				postprocessRtGreyed = false;
				UpdatePresetOptions('PostProcess', false);
			}
		}
		else if (value)
		{
			if (postprocessRtGreyed == false)
			{
				postprocessRtGreyed = true;
				UpdatePresetOptions('PostProcess', true);
			}
		}
	}
	
	protected function HandleSpecialValueChanged(optionName:name, optionValue:string):void
	{
		var intValue : int;
		
		if (optionName == 'GameDifficulty')
		{
			intValue = StringToInt(optionValue, 1);
			
			lastSetDifficulty = intValue + 1;
		}
	}
	
	public function OnGraphicsUpdated(keepChanges:bool):void
	{
		
		
		
		
		
	}
	
	event  OnOptionPanelNavigateBack()
	{
		var graphicChangesPending:bool;
		var hud : CR4ScriptedHud;
		
		theGame.SetHDRMenuActive(false);
		theGame.SetHDRMenuFadePercentage(0);
		
		if (inGameConfigBufferedWrapper.AnyBufferedVarHasTag('refreshViewport'))
		{
			inGameConfigBufferedWrapper.ApplyNewValues();
			theGame.GetGuiManager().ShowProgressDialog(UMID_GraphicsRefreshing, "", "message_text_confirm_option_changes", true, UDB_OkCancel, 100, UMPT_GraphicsRefresh, '');
			ReopenMenu();
			return true;
		}
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if (hud)
		{
			hud.RefreshHudConfiguration();
		}
		
		thePlayer.SetAutoCameraCenter( inGameConfigBufferedWrapper.GetVarValue( 'Gameplay', 'AutoCameraCenter' ) );
		thePlayer.SetEnemyUpscaling( inGameConfigBufferedWrapper.GetVarValue( 'Gameplay', 'EnemyUpscaling' ) );
	}
	
	event  OnNavigatedBack()
	{
		var lowestDifficultyUsed : EDifficultyMode;
		var hud : CR4ScriptedHud;
		var overlayPopupRef : CR4OverlayPopup;
		var radialMenuModule : CR4HudModuleRadialMenu;
		var confirmResult : int;
		var flashObject : CScriptedFlashObject;
		
		theGame.SetHDRMenuActive(false);
		theGame.SetHDRMenuFadePercentage(0);
		
		hud = (CR4ScriptedHud)(theGame.GetHud());
		overlayPopupRef = (CR4OverlayPopup) theGame.GetGuiManager().GetPopup('OverlayPopup');
		
		if( inGameConfigBufferedWrapper.IsEmpty() == false )
		{
			if (!inGameConfigBufferedWrapper.AnyBufferedVarHasTag('refreshViewport'))
			{
				inGameConfigBufferedWrapper.FlushBuffer();
			}
			
			hasChangedOption = true;
		}
		
		if ( theGame.GetVoiceLangDownloadStatus( mInGameConfigWrapper.GetVarOption( 'Localization', 'Virtual_Localization_speech', StringToInt( currentSpeechLang ) ) ) != STREAMABLE_LOADED )
		{
			
			currentSpeechLang = lastUsedSpeechLang;
			mInGameConfigWrapper.SetVarValue( 'Localization', 'Virtual_Localization_speech', currentSpeechLang );
			
			theGame.UpdateSpeechLanguageSlider( currentSpeechLang );
		}
		
		if (currentLangValue != lastUsedLangValue || lastUsedSpeechLang != currentSpeechLang)
		{
			lastUsedLangValue = currentLangValue;
			lastUsedSpeechLang = currentSpeechLang;
			theGame.ReloadLanguage();
			
			flashObject = m_flashValueStorage.CreateTempFlashObject();
			flashObject.SetMemberFlashUInt( "optionTag", NameToFlashUInt( 'Virtual_Localization_speech' ) );
			flashObject.SetMemberFlashString( "optionSelectedId", currentSpeechLang );	
			m_flashValueStorage.SetFlashObject( "option.changedId", flashObject );
		
			SetModdedTooltipText();
		}
		
		if (swapAcceptCancelChanged)
		{
			swapAcceptCancelChanged = false;
			UpdateAcceptCancelSwaping();
			
			if (hud)
			{
				hud.UpdateAcceptCancelSwaping();
			}
			
			if (overlayPopupRef)
			{
				overlayPopupRef.UpdateAcceptCancelSwaping();
			}
		}
		
		if (alternativeRadialInputChanged)
		{
			alternativeRadialInputChanged = false;
			
			if (hud)
			{
				radialMenuModule =  (CR4HudModuleRadialMenu)hud.GetHudModule( "RadialMenuModule" );
				if (radialMenuModule)
				{
					radialMenuModule.UpdateInputMode();
				}
			}
		}
		
		isShowingSaveList = false;
		isShowingLoadList = false;
		
		OnPlaySoundEvent( "gui_global_panel_close" );
		
		lowestDifficultyUsed = theGame.GetLowestDifficultyUsed();
		
		
		
		if (!isMainMenu && theGame.GetDifficultyLevel() != lastSetDifficulty && lowestDifficultyUsed > lastSetDifficulty && lowestDifficultyUsed > EDM_Medium)
		{
			if(theGame.GetPlatform() == Platform_Switch2_Ounce)
			{
				theGame.SetDifficultyLevel(lastSetDifficulty);
				theGame.OnDifficultyChanged(lastSetDifficulty);
			}
			else
			{
				diffChangeConfPopup = new W3DifficultyChangeConfirmation in this;
				
				diffChangeConfPopup.SetMessageTitle("");
				diffChangeConfPopup.SetMessageText( GetPlatformLocString( "difficulty_change_warning_message", "difficulty_change_warning_message_X1" ) );
				diffChangeConfPopup.menuRef = this;
				diffChangeConfPopup.targetDifficulty = lastSetDifficulty;
				diffChangeConfPopup.BlurBackground = true;
				
				RequestSubMenu('PopupMenu', diffChangeConfPopup);
			}
		}
		else if (lastSetDifficulty != theGame.GetDifficultyLevel())
		{
			theGame.SetDifficultyLevel(lastSetDifficulty);
			theGame.OnDifficultyChanged(lastSetDifficulty);
		}
		
		SaveChangedSettings();

		if (overlayPopupRef && updateInputDeviceRequired)
		{
			updateInputDeviceRequired = false;
			overlayPopupRef.UpdateInputDevice();
		}

		
		curMenuDepth -= 1;
		if (curMenuDepth < depthOptions) {
			curMenuDepth = 1;
		}
		theTelemetry.NoticeMenuDepth(curMenuDepth);
	}
	
	public function CancelDifficultyChange() : void
	{
		var difficultyIndex:int;
		var difficultyIndexAsString:string;
		
		lastSetDifficulty = theGame.GetDifficultyLevel();
		
		difficultyIndex = lastSetDifficulty - 1;
		difficultyIndexAsString = "" + difficultyIndex;
		m_fxUpdateOptionValue.InvokeSelfTwoArgs(FlashArgUInt(NameToFlashUInt('GameDifficulty')), FlashArgString(difficultyIndexAsString));
	}
	
	protected function SaveChangedSettings()
	{
		if (hasChangedOption)
		{
			hasChangedOption = false;
			theGame.SaveUserSettings();
		}
	}
	
	event  OnProfileChange()
	{
		if( !disableAccountPicker )
		{
			SetIgnoreInput(true);
			theGame.ChangeActiveUser();
		}
	}
	
	event  OnSaveGameCalled(type : ESaveGameType, saveArrayIndex : int)
	{
		var saves : array< SSavegameInfo >;
		var currentSave : SSavegameInfo;
		
		ignoreInput = true; 
		
		if ( theGame.AreSavesLocked() )
		{
			theGame.GetGuiManager().DisplayLockedSavePopup();
			SetIgnoreInput(false);
			return false;
		}
	
		if (saveArrayIndex >= 0)
		{
			if (saveConfPopup)
			{
				delete saveConfPopup;
			}
			
			theGame.GetRecentListSG( saves );
			currentSave = saves[ saveArrayIndex ];
			
			saveConfPopup = new W3SaveGameConfirmation in this;
			saveConfPopup.SetMessageTitle("");
			saveConfPopup.SetMessageText( GetPlatformLocString( "error_message_overwrite_save" ) );
			saveConfPopup.menuRef = this;
			saveConfPopup.type = currentSave.slotType;
			saveConfPopup.slot = currentSave.slotIndex;
			saveConfPopup.BlurBackground = true;
				
			RequestSubMenu('PopupMenu', saveConfPopup);
		}
		else
		{
			executeSave(type, -1);
			SetIgnoreInput(false);
		}
	}
	
	public function executeSave(type : ESaveGameType, slot : int)
	{
		theGame.SaveGame(type, slot);
		m_fxNavigateBack.InvokeSelf();
	}
	
	public function GetLastAttemptedSaveIndex() : int
	{
		return m_lastAttemptedSaveId;
	}
	
	event  OnLoadGameCalled( type : ESaveGameType, saveListIndex : int )
	{
		LoadSave(type, saveListIndex, true );
	}
	
	
	
	public function LoadSave(type : ESaveGameType, saveListIndex : int, allowModCheck : bool )
	{
		var saveGameRef : SSavegameInfo;
		var saveGames	: array< SSavegameInfo >;
		
		if (ignoreInput)
		{
			return;
		}
		
		disableAccountPicker = true;
		
		if (loadConfPopup)
		{
			delete loadConfPopup;
		}
		
		theGame.ListSavedGames( saveGames );
		saveGameRef = saveGames[saveListIndex];	
		
		if ( !CheckModdedSave( saveGameRef, allowModCheck ) )
		{
			m_lastAttemptedSaveId = saveListIndex;
			return;
		}
		
		if (panelMode || (isMainMenu && !hasValidAutosaveData()))
		{
			LoadSaveRequested(saveGameRef);
		}
		else
		{
			loadConfPopup = new W3ApplyLoadConfirmation in this;
			loadConfPopup.SetMessageTitle( GetPlatformLocString( "panel_mainmenu_popup_load_title" ) );
			
			if (isMainMenu)
			{
				loadConfPopup.SetMessageText( GetPlatformLocString("error_message_load_game_main_menu") );
			}
			else
			{
				loadConfPopup.SetMessageText( GetPlatformLocString( "error_message_load_game" ) );
			}
			
			loadConfPopup.menuRef = this;
			loadConfPopup.saveSlotRef = saveGameRef;
			loadConfPopup.BlurBackground = true;
			
			SetIgnoreInput(true);
					
			RequestSubMenu('PopupMenu', loadConfPopup);
		}
	}
	
	private function CheckModdedSave( saveGameRef : SSavegameInfo, allowModCheck : bool ) : bool
	{
		var enabled, authenticated: bool;
		var missingModIds : array< SModioModID >;
		var versionErrorModIds : array< SModioModID >;
		
		if ( !theGame.GetModHandlerSystem().IsModdedSave( saveGameRef ) )
		{
			return true;
		}

		
		
		
		
		
		if ( !theGame.GetModHandlerSystem().CheckPlatformUGCAllowed( false ) )
		{
			ForceSetIgnoreInput( false );
			OnModioNetworkError();
			return false;
		}

		enabled = theGame.GetModHandlerSystem().IsModioEnabled();
		authenticated = theGame.GetModHandlerSystem().IsAuthenticated();
		if ( allowModCheck && enabled && authenticated )
		{
			if ( !theGame.GetModHandlerSystem().CheckHasAllModsInSave( saveGameRef, missingModIds))
			{
				ForceSetIgnoreInput( false );
				m_igmStateMachine.GetMissingModList( missingModIds, false );
				return false;
			}
			
			
			
			
			
			
		}
		
		return true;
	}

	
	private function CheckModdedLastSave( allowModCheck : bool ) : bool
	{
		var enabled, authenticated: bool;
		var missingModIds : array< SModioModID >;
		var versionErrorModIds : array< SModioModID >;
		
		if ( !theGame.GetModHandlerSystem().IsModdedLatestSave() )
		{
			return true;
		}

		
		
		if ( !theGame.GetModHandlerSystem().CheckPlatformUGCAllowed( false ) )
		{
			ForceSetIgnoreInput( false );
			OnModioNetworkError();
			return false;
		}

		enabled = theGame.GetModHandlerSystem().IsModioEnabled();
		authenticated = theGame.GetModHandlerSystem().IsAuthenticated();
		if ( allowModCheck && enabled && authenticated )
		{
			if ( !theGame.GetModHandlerSystem().CheckHasAllModsInLatestSave( missingModIds))
			{
				ForceSetIgnoreInput( false );
				m_igmStateMachine.GetMissingModList( missingModIds, false );
				return false;
			}
			
			
			
			
			
			
		}
		
		return true;
	}

	public function LoadSaveRequested(saveSlotRef : SSavegameInfo) : void
	{	
		var fromDeathScreen : bool;
		
		if (theGame.GetGuiManager().GetPopup('MessagePopup') && theGame.GetGuiManager().lastMessageData.messageId == UMID_ControllerDisconnected)
		{
			SetIgnoreInput(false);
			disableAccountPicker = false;
			return;
		}
		
		SetIgnoreInput(true);
		
		if (isMainMenu)
		{
			disableAccountPicker = true;
		}

		
		fromDeathScreen = (CR4DeathScreenMenu)m_parentMenu;
		theGame.LoadGameInit( saveSlotRef , fromDeathScreen );
	}
	
	event  OnImportGameCalled(menuTag:int):void
	{
		var savesToImport : array< SSavegameInfo >;
		var difficulty:int;
		var tutorialsEnabled:bool;
		var simulateImport:bool;
		var maskResult:int;
		var progress : float;
		
		if (!theGame.IsContentAvailable('launch0'))
		{
			progress = theGame.ProgressToContentAvailable('launch0');
			theSound.SoundEvent("gui_global_denied");
			theGame.GetGuiManager().ShowProgressDialog(0, "", "error_message_new_game_not_ready", true, UDB_Ok, progress, UMPT_Content, 'launch0');
			
		}
		else
		{
			theGame.ListW2SavedGames( savesToImport );
			
			if ( menuTag < savesToImport.Size() )
			{
				disableAccountPicker = true;
				
				theGame.ClearInitialFacts();
				
				if (theGame.ImportSave( savesToImport[ menuTag ] ))
				{
					currentNewGameConfig.import_save_index = menuTag;
					
					if ((lastSetTag & IGMC_New_game_plus) == IGMC_New_game_plus)
					{
						m_fxForceEnterCurEntry.InvokeSelf();
					}
					else
					{
						
						theGame.SetDifficultyLevel(currentNewGameConfig.difficulty);
						TutorialMessagesEnable(currentNewGameConfig.tutorialsOn);
						if (currentNewGameConfig.bardsBalladOn)
							updateAccessibilityPresetValues(AP_BardsTale, false);
						
						if ( theGame.RequestNewGame( theGame.GetNewGameDefinitionFilename() ) )
						{
							OnPlaySoundEvent("gui_global_game_start");
							OnPlaySoundEvent("mus_intro_usm");
							GetRootMenu().CloseMenu();
						}
					}
				}
				else
				{
					showNotification(GetLocStringByKeyExt("import_witcher_two_failed"));
					OnPlaySoundEvent("gui_global_denied");
				}
			}
		}
	}
	
	event  OnNewGamePlusCalled(saveListIndex:int):void
	{
		var startGameStatus : ENewGamePlusStatus;
		var saveGameRef 	: SSavegameInfo;
		var saveGames		: array< SSavegameInfo >;
		var errorMessage 	: string;
		var progress : float;
		
		var requiredContent : name = 'content12';
		
		ignoreInput = true; 
		
		if (!theGame.IsContentAvailable(requiredContent))
		{
			progress = theGame.ProgressToContentAvailable(requiredContent);
			theSound.SoundEvent("gui_global_denied");
			SetIgnoreInput(false);
			theGame.GetGuiManager().ShowProgressDialog(0, "", "error_message_new_game_not_ready", true, UDB_Ok, progress, UMPT_Content, requiredContent);
		}
		else
		{
			disableAccountPicker = true;
			
			theGame.ListSavedGames( saveGames );
			saveGameRef = saveGames[saveListIndex];
			
			if (currentNewGameConfig.import_save_index == -1 && currentNewGameConfig.simulate_import)
			{
				theGame.AddInitialFact("simulate_import_ingame");
			}
			
			theGame.SetDifficultyLevel(currentNewGameConfig.difficulty);
			
			TutorialMessagesEnable(currentNewGameConfig.tutorialsOn);
			if (currentNewGameConfig.bardsBalladOn)
				updateAccessibilityPresetValues(AP_BardsTale, false);
			
			startGameStatus = theGame.StartNewGamePlus(saveGameRef);
			
			if (startGameStatus == NGP_Success)
			{
				theGame.GetGuiManager().RequestMouseCursor(false);
				OnPlaySoundEvent("gui_global_game_start");
				OnPlaySoundEvent("mus_intro_usm");
				GetRootMenu().CloseMenu();
			}
			else
			{
				errorMessage = "";
				SetIgnoreInput(false);
				disableAccountPicker = false;
				
				switch (startGameStatus)
				{
				case NGP_Invalid:
					errorMessage = GetPlatformLocString("newgame_plus_error_invalid");
					break;
				case NGP_CantLoad:
					errorMessage = GetLocStringByKeyExt("newgame_plus_error_cantload");
					break;
				case NGP_TooOld:
					errorMessage = GetLocStringByKeyExt("newgame_plus_error_too_old");
					break;
				case NGP_RequirementsNotMet:
					errorMessage = GetLocStringByKeyExt("newgame_plus_error_requirementnotmet");
					break;
				case NGP_InternalError:
					errorMessage = GetPlatformLocString("newgame_plus_error_internalerror");
					break;
				case NGP_ContentRequired:
					errorMessage = GetLocStringByKeyExt("newgame_plus_error_contentrequired");
					break;
				case NGP_OnNGP:
					errorMessage = GetLocStringByKeyExt("newgame_plus_error_on_ngp");
					break;
				}
				
				showNotification(errorMessage);
				OnPlaySoundEvent("gui_global_denied");
			}
		}
	}
	
	event  OnDeleteSaveCalled(type : ESaveGameType, saveListIndex : int, isSaveMode:bool)
	{
		if (ignoreInput)
		{
			return false;
		}
		
		SetIgnoreInput(true);
		
		disableAccountPicker = true;
		
		if (deleteConfPopup)
		{
			delete deleteConfPopup;
		}
		
		deleteConfPopup = new W3DeleteSaveConf in this;
		deleteConfPopup.SetMessageTitle("");
		
		if (theGame.GetPlatform() == Platform_PS5)
		{
			deleteConfPopup.SetMessageText( GetPlatformLocString( "error_message_delete_save_ps5" ) );
		}
		else
		{
			deleteConfPopup.SetMessageText( GetPlatformLocString( "panel_mainmenu_confirm_delete_text" ) );
		}
		deleteConfPopup.menuRef = this;
		deleteConfPopup.type = type;
		deleteConfPopup.slot = saveListIndex;
		deleteConfPopup.saveMode = isSaveMode;
		deleteConfPopup.BlurBackground = true;
			
		RequestSubMenu('PopupMenu', deleteConfPopup);
	}
	
	event  OnSyncSaveCalled(type : ESaveGameType, saveListIndex : int, isSaveMode:bool)
	{
		
		var manager : CR4GuiManager;
		manager = (CR4GuiManager)theGame.GetGuiManager();
		if (manager) {
			manager.SyncGalaxySlot(saveListIndex);
		}
	}
	
	event  OnLoginCloudCalled()
	{
		var manager : CR4GuiManager;
		
		
		if (!theGame.IsGalaxyUserSignedIn()) {
			manager = (CR4GuiManager)theGame.GetGuiManager();
			if (manager) {
				m_shouldOpenModMenuOnLogin = false;
				manager.GalaxyMyRewardsInitiate();
			}
		}
	}
	
	event  OnShowCloudModalCalled()
	{
		var manager : CR4GuiManager;

		if (!theGame.HasInternetConnection())
		{
			ShowErrorWindow( GOGNoInternetConnection );
		} 
		else if (theGame.IsGalaxyUserSignedIn()) 
		{
			
			manager = (CR4GuiManager)theGame.GetGuiManager();
			if (manager) 
			{
				manager.ShowCloudModal();
				
			}
		}
	}
	
	public function OpenModTermsPopup():void
	{
		var termsData : W3ModTermsPopupData;
		var terms : string;
		var title : string;
		terms = GetLocStringByKeyExt("panel_mods_message_1");
		terms = terms + "&#10;&#10;" + GetLocStringByKeyExt("panel_mods_message_2");
		
		if(theGame.GetPlatform() == Platform_PS5)
			terms = terms + "&#10;&#10;" + GetLocStringByKeyExt("panel_mods_message_3");
		terms = terms + "&#10;&#10;" + GetLocStringByKeyExt("panel_mods_message_4");
		
		if(theGame.GetPlatform() == Platform_PS5)
			terms = terms + "&#10;&#10;" + GetLocStringByKeyExt("panel_mods_message_5_trophies");
		else if(theGame.GetPlatform() == Platform_Xbox_SCARLETT_LOCKHART || theGame.GetPlatform() == Platform_Xbox_SCARLETT_ANACONDA || theGame.GetPlatform() == Platform_PC_GDK)
			terms = terms + "&#10;&#10;" + GetLocStringByKeyExt("panel_mods_message_5");
		
		title = GetLocStringByKeyExt("panel_mod_menu");
		
		termsData = new W3ModTermsPopupData in this;
		
		termsData.SetMessageText(terms);
		termsData.SetMessageTitle(title);
		
		termsData.AddCheckBoxText(GetLocStringByKeyExt("panel_mods_checkbox_modio_terms"));
		termsData.AddCheckBoxText(GetLocStringByKeyExt("panel_mods_checkbox_modio_pp"));
		termsData.AddCheckBoxText(GetLocStringByKeyExt("panel_mods_checkbox_red_eula"));
		
		termsData.AddUrlLink(GetLocStringByKeyExt("panel_mods_link_modio_pp"), MLT_ModioPrivacy);
		termsData.AddUrlLink(GetLocStringByKeyExt("panel_mods_link_modio_tos"), MLT_ModioTerms);
		termsData.AddUrlLink(GetLocStringByKeyExt("panel_mods_link_cdpr_ua"), MLT_CDPREula);
		termsData.AddUrlLink(GetLocStringByKeyExt("panel_mods_link_cdpr_pp"), MLT_CDPRPrivacy);
		termsData.AddUrlLink(GetLocStringByKeyExt("panel_mods_link_cdpr_cg"), MLT_CDPRFanContent);
		
		termsData.SetMenuRef(this);
		RequestSubMenu('PopupMenu', termsData);
		LogChannel('MODIO', "Opening Modio Terms Popup");
	}
	
	public function OnModTermsAccepted():void
	{
		m_igmStateMachine.OnModTermsAccepted();
	}
	
	event  OnCloudOffRequest()
	{
		ShowStartupLoginPage(false);
	}
	
	public function DeleteSave(type : ESaveGameType, saveListIndex : int, isSaveMode:bool)
	{
		var saves : array< SSavegameInfo >;
		var currentSave : SSavegameInfo;
		var numSavesBeforeDelete : int;
		
		theGame.GetRecentListSG( saves );
		
		numSavesBeforeDelete = saves.Size();
		
		if (saveListIndex < saves.Size())
		{
			currentSave = saves[ saveListIndex ];
			theGame.DeleteSavedGame(currentSave);
		}
		
		if (numSavesBeforeDelete <= 1)
		{
			m_fxRemoveOption.InvokeSelfOneArg(FlashArgInt(NameToFlashUInt('Continue')));
			m_fxRemoveOption.InvokeSelfOneArg(FlashArgInt(NameToFlashUInt('LoadGame')));
			
			if (isInLoadselector)
			{
				m_fxNavigateBack.InvokeSelf();
			}
			else
			{
				SendSaveData();
			}
		}
		else
		{
			if (isSaveMode)
			{
				SendSaveData();
			}
			else if (hasSaveDataToLoad())
			{
				SendLoadData();
			}
		}
	}
	
	protected function showOptionsPanel() : void
	{
		var l_DataFlashArray : CScriptedFlashArray;
	
		if (theGame.GetPlatform() == Platform_PC || theGame.GetPlatform() == Platform_PC_GDK)
		{
			m_fxSetHardwareCursorOn.InvokeSelfOneArg(FlashArgBool(mInGameConfigWrapper.GetVarValue('Rendering', 'HardwareCursor')));
		}
		
		l_DataFlashArray = IngameMenu_FillOptionsSubMenuData(m_flashValueStorage, isMainMenu);
		
		m_initialSelectionsToIgnore = 1;
		OnPlaySoundEvent( "gui_global_panel_open" );
		
		m_flashValueStorage.SetFlashArray( "ingamemenu.options.entries", l_DataFlashArray );
		
		
		curMenuDepth = depthOptions;
		theTelemetry.NoticeMenuDepth(curMenuDepth);
	}
	
	public function ToggleRTEnabled() : void
	{
		theGame.ToggleRTEnabled();
		RTEnabled();
		m_fxUpdateOptionLabel.InvokeSelfTwoArgs(FlashArgUInt(NameToFlashUInt('toggle_render')), FlashArgString(theGame.GetToggleButtonCaption()));
		theGame.SaveUserSettings();
	}
	
	protected function showHelpPanel() : void
	{
		m_fxNavigateBack.InvokeSelf();
		
		theGame.DisplaySystemHelp();
	}
	
	public function TryStartNewGame(optionsArray : int):void
	{
		var progress : float;
		
		if (!theGame.IsContentAvailable('launch0'))
		{
			progress = theGame.ProgressToContentAvailable('launch0');
			theSound.SoundEvent("gui_global_denied");
			theGame.GetGuiManager().ShowProgressDialog(0, "", "error_message_new_game_not_ready", true, UDB_Ok, progress, UMPT_Content, 'launch0');
			return;
		}
		
		if ((optionsArray & IGMC_EP2_Save) == IGMC_EP2_Save && !theGame.IsContentAvailable('content12'))
		{
			progress = theGame.ProgressToContentAvailable('content12');
			theSound.SoundEvent("gui_global_denied");
			theGame.GetGuiManager().ShowProgressDialog(0, "", "error_message_new_game_not_ready", true, UDB_Ok, progress, UMPT_Content, 'content12');
		}
		else if ((optionsArray & IGMC_EP1_Save) == IGMC_EP1_Save && !theGame.IsContentAvailable('content12'))
		{
			progress = theGame.ProgressToContentAvailable('content12');
			theSound.SoundEvent("gui_global_denied");
			theGame.GetGuiManager().ShowProgressDialog(0, "", "error_message_new_game_not_ready", true, UDB_Ok, progress, UMPT_Content, 'content12');
		}

		else
		{
			fetchNewGameConfigFromTag(optionsArray);
			TutorialMessagesEnable(currentNewGameConfig.tutorialsOn);
			if (currentNewGameConfig.bardsBalladOn)
				updateAccessibilityPresetValues(AP_BardsTale, false);
			
			if ((optionsArray & IGMC_EP2_Save) == IGMC_EP2_Save)
			{
				
				theGame.InitStandaloneDLCLoading('bob_000_000', currentNewGameConfig.difficulty);
				theGame.EnableUberMovement( true );
				((CInGameConfigWrapper)theGame.GetInGameConfigWrapper()).SetVarValue( 'Gameplay', 'EnableUberMovement', 1 );
			}
			else if ((optionsArray & IGMC_EP1_Save) == IGMC_EP1_Save)
			{
				
				theGame.InitStandaloneDLCLoading('ep1', currentNewGameConfig.difficulty);
				theGame.EnableUberMovement( true );
				((CInGameConfigWrapper)theGame.GetInGameConfigWrapper()).SetVarValue( 'Gameplay', 'EnableUberMovement', 1 );
			}

			else
			{
				if (hasValidAutosaveData())
				{
					if (newGameConfPopup)
					{
						delete newGameConfPopup;
					}
					
					newGameConfPopup = new W3NewGameConfirmation in this;
					newGameConfPopup.SetMessageTitle("");
					newGameConfPopup.SetMessageText( GetPlatformLocString( "error_message_start_game" ) );
					newGameConfPopup.menuRef = this;
					newGameConfPopup.BlurBackground = true;
						
					RequestSubMenu('PopupMenu', newGameConfPopup);
				}
				else
				{
					NewGameRequested();
				}
			}
		}
	}
	
	protected function fetchNewGameConfigFromTag(optionsTag : int):void
	{
		var maskResult:int;
		
		currentNewGameConfig.difficulty = optionsTag & IGMC_Difficulty_mask;
		
		maskResult = optionsTag & IGMC_Tutorials_On;
		currentNewGameConfig.tutorialsOn = (maskResult == IGMC_Tutorials_On);

		maskResult = optionsTag & IGMC_BardsBallad_On;
		currentNewGameConfig.bardsBalladOn = (maskResult == IGMC_BardsBallad_On);
		
		maskResult = optionsTag & IGMC_Import_Save;
		if (maskResult != IGMC_Import_Save)
		{
			currentNewGameConfig.import_save_index = -1;
		}
		
		maskResult = optionsTag & IGMC_Simulate_Import;
		currentNewGameConfig.simulate_import = (maskResult == IGMC_Simulate_Import);
	}
	
	public function NewGameRequested():void
	{
		disableAccountPicker = true;
		
		if (currentNewGameConfig.import_save_index == -1)
		{
			theGame.ClearInitialFacts();
		}
		
		if (currentNewGameConfig.import_save_index == -1 && currentNewGameConfig.simulate_import)
		{
			theGame.AddInitialFact("simulate_import_ingame");
		}
		
		theGame.SetDifficultyLevel(currentNewGameConfig.difficulty);
		
		TutorialMessagesEnable(currentNewGameConfig.tutorialsOn);
		if (currentNewGameConfig.bardsBalladOn)
			updateAccessibilityPresetValues(AP_BardsTale, false);
		
		StartNewGame();
	}
	
	event  OnUpdateRescale(hScale : float, vScale : float)
	{
		var hud : CR4ScriptedHud;
		var needRescale : bool;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		needRescale = false;
		
		if( theGame.GetUIHorizontalFrameScale() != hScale )
		{
			theGame.SetUIHorizontalFrameScale(hScale);
			mInGameConfigWrapper.SetVarValue('Hidden', 'uiHorizontalFrameScale', FloatToString(hScale));
			needRescale = true;
			hasChangedOption = true;
		}	
		if( theGame.GetUIVerticalFrameScale() != vScale )
		{
			theGame.SetUIVerticalFrameScale(vScale);
			mInGameConfigWrapper.SetVarValue('Hidden', 'uiVerticalFrameScale', FloatToString(vScale));
			needRescale = true;
			hasChangedOption = true;
		}	
		
		if( needRescale && hud ) 
		{
			hud.RescaleModules();
		}
	}
	
	public function ShowTutorialChosen(enabled:bool):void
	{
		TutorialMessagesEnable(enabled);
		
		StartNewGame();
	}
	
	public function StartNewGame():void
	{
		if (theGame.GetGuiManager().GetPopup('MessagePopup') && theGame.GetGuiManager().lastMessageData.messageId == UMID_ControllerDisconnected)
		{
			return;
		}
		
		if ( theGame.RequestNewGame( theGame.GetNewGameDefinitionFilename() ) )
		{
			theGame.GetGuiManager().RequestMouseCursor(false);
			OnPlaySoundEvent("gui_global_game_start");
			OnPlaySoundEvent("mus_intro_usm");
			GetRootMenu().CloseMenu();
		}
	}
	
	function PopulateMenuData()
	{
		var l_DataFlashArray		: CScriptedFlashArray;
		var l_ChildMenuFlashArray	: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		var l_subDataFlashObject	: CScriptedFlashObject;
		
		l_DataFlashArray = m_structureCreator.PopulateMenuData();
		
		m_flashValueStorage.SetFlashArray( "ingamemenu.entries", l_DataFlashArray );
	}
	
	protected function addInLoadOption():void
	{
		var l_DataFlashObject 		: CScriptedFlashObject;
		var l_ChildMenuFlashArray	: CScriptedFlashArray;
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString( "id", "mainmenu_loadgame");
		l_DataFlashObject.SetMemberFlashUInt(  "tag", NameToFlashUInt('LoadGame') );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_mainmenu_loadgame") );	
		
		l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_Load );	
		
		l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		
		m_flashValueStorage.SetFlashObject( "ingamemenu.addloading", l_DataFlashObject );
	}
	
	event  OnBack()
	{
		CloseMenu();
	}
	
	public function HasSavesToImport() : bool
	{
		var savesToImport : array< SSavegameInfo >;
		
		theGame.ListW2SavedGames( savesToImport );
		return savesToImport.Size() != 0;
	}

	protected function SendImportSaveData()
	{
		var dataFlashArray 	: CScriptedFlashArray;
		
		dataFlashArray = m_flashValueStorage.CreateTempFlashArray();
		
		IngameMenu_PopulateImportSaveData(m_flashValueStorage, dataFlashArray);
		
		m_initialSelectionsToIgnore = 1;
		OnPlaySoundEvent( "gui_global_panel_open" );
		
		isShowingSaveList = true;
		m_flashValueStorage.SetFlashArray( "ingamemenu.importSlots", dataFlashArray );
		
		m_flashValueStorage.SetFlashString("mainmenu.saves.tooltip", GetPlatformedSaveTooltipText());
	}
	
	protected function hasValidAutosaveData() : bool
	{
		var currentSave	: SSavegameInfo;
		var num : int;
		var i : int;
		
		num = theGame.GetNumSaveSlots( SGT_AutoSave );
		for ( i = 0; i < num; i = i + 1 )
		{
			if ( theGame.GetSaveInSlot( SGT_AutoSave, i, currentSave ) )
			{
				return true;
			}
		}
		
		num = theGame.GetNumSaveSlots( SGT_CheckPoint );
		for ( i = 0; i < num; i = i + 1 )
		{
			if ( theGame.GetSaveInSlot( SGT_CheckPoint, i, currentSave ) )
			{
				return true;
			}
		}
		
		return false;
	}
	
	public function HandleSaveListUpdate():void
	{
		if (isShowingSaveList)
		{
			SendSaveData();
		}
		else if (isShowingLoadList)
		{
			SendLoadData();
		}
		
		if (hasSaveDataToLoad())
		{
			addInLoadOption();
		}
	}
	
	public function QRCodeReady(UrlAdres : String):void
	{
		LogChannel('JIFIX', "QR Code ready to load: " + UrlAdres);
		m_fxQRCodeReadyToLoad.InvokeSelfOneArg(FlashArgString(UrlAdres));	
	}

	public function CloudPersonaReady(namePersona : String):void
	{
		m_fxShowCloudModal.InvokeSelfOneArg(FlashArgString(namePersona));	
	}
	
	public function CloseGalaxySignInModalWindow():void
	{
		m_fxCloseGalaxySignInModalWindow.InvokeSelf();
		
		showNotification( GetLocStringByKeyExt("ui_cloud_gog_sign_in_success"),, true );
	}
	
	event OnVisitSignInPage()
	{
		var manager : CR4GuiManager;
		manager = (CR4GuiManager)theGame.GetGuiManager();
		if ( manager )
		{
			manager.VisitSignInPage();
		}

	}
	
	event OnGalaxyQRSignInCancel()
	{
		var manager : CR4GuiManager;
		manager = (CR4GuiManager)theGame.GetGuiManager();
		if ( manager )
		{
			manager.GalaxyQRSignInCancel();
		}
	}
	
	event OnGalaxyUnlinkAccounts()
	{
		var manager : CR4GuiManager;
		manager = (CR4GuiManager)theGame.GetGuiManager();
		if ( manager )
		{
			manager.GalaxyUnlinkAccounts();
		}
	}

	public function CheckSaveAvailability(): void
	{
		if(!hasSaveDataToLoad())
		{
			m_fxRemoveOption.InvokeSelfOneArg(FlashArgInt(NameToFlashUInt('LoadGame')));
			m_fxRemoveOption.InvokeSelfOneArg(FlashArgInt(NameToFlashUInt('Continue')));
		}
		else
		{
			PopulateMenuData();
		}
	}
	
	public function GetPlatformedSaveTooltipText():string
	{
		if(theGame.GetPlatform() == Platform_PS5)
			return GetLocStringByKeyExt("mods_enabled") + " " + GetLocStringByKeyExt("mods_enabled_trophies");
		else if(theGame.GetPlatform() == Platform_Xbox_SCARLETT_LOCKHART || theGame.GetPlatform() == Platform_Xbox_SCARLETT_ANACONDA || theGame.GetPlatform() == Platform_PC_GDK)
			return GetLocStringByKeyExt("mods_enabled") + " " + GetLocStringByKeyExt("mods_enabled_achievements");
		return GetLocStringByKeyExt("mods_enabled");
	}
	
	protected function SendLoadData():void
	{
		var l_DataFlashObject : CScriptedFlashObject;
		var dataFlashArray 	: CScriptedFlashArray;
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashBool( "isUserSignedIn", theGame.IsGalaxyUserSignedIn() && theGame.GetInGameConfigWrapper().GetVarValue( 'Gameplay', 'CrossProgression' ) == "true" );
		m_flashValueStorage.SetFlashObject( "ingamemenu.gogCloudState", l_DataFlashObject );
		
		dataFlashArray = m_flashValueStorage.CreateTempFlashArray();
		
		PopulateSaveDataForSlotType(-1, dataFlashArray, false);
		
		m_initialSelectionsToIgnore = 1;
		OnPlaySoundEvent( "gui_global_panel_open" );
		
		if (dataFlashArray.GetLength() == 0)
		{
			m_fxNavigateBack.InvokeSelf();
		}
		else
		{
			isShowingLoadList = true;
			m_flashValueStorage.SetFlashArray( "ingamemenu.loadSlots", dataFlashArray );
			m_flashValueStorage.SetFlashString("mainmenu.saves.tooltip", GetPlatformedSaveTooltipText());
		}
	}
	
	
	protected function SendSaveData():void
	{
		var l_DataFlashObject : CScriptedFlashObject;
		var dataFlashArray 	: CScriptedFlashArray;
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashBool( "isUserSignedIn", theGame.IsGalaxyUserSignedIn() && theGame.GetInGameConfigWrapper().GetVarValue( 'Gameplay', 'CrossProgression' ) == "true" );
		m_flashValueStorage.SetFlashObject( "ingamemenu.gogCloudState", l_DataFlashObject );
		
		dataFlashArray = m_flashValueStorage.CreateTempFlashArray();
		
		
		
		PopulateSaveDataForSlotType(SGT_Manual, dataFlashArray, true);
		
		m_initialSelectionsToIgnore = 1;
		OnPlaySoundEvent( "gui_global_panel_open" );
		
		isShowingSaveList = true;
		m_flashValueStorage.SetFlashArray( "ingamemenu.saveSlots", dataFlashArray );
		m_flashValueStorage.SetFlashString("mainmenu.saves.tooltip", GetPlatformedSaveTooltipText());
		
		if ( theGame.ShouldShowSaveCompatibilityWarning() )
		{
			theGame.GetGuiManager().ShowUserDialog( UMID_SaveCompatWarning, "", "error_save_not_compatible", UDB_Ok );
		}
	}
	
	protected function SendNewGamePlusSaves():void
	{
		var dataFlashArray 	: CScriptedFlashArray;
		
		dataFlashArray = m_flashValueStorage.CreateTempFlashArray();
		
		PopulateSaveDataForSlotType(-1, dataFlashArray, false);
		
		theGame.GetGuiManager().ShowUserDialog(0, "", "message_new_game_plus_reminder", UDB_Ok);
		
		if (dataFlashArray.GetLength() == 0)
		{
			OnPlaySoundEvent("gui_global_denied");
			showNotification(GetLocStringByKeyExt("mainmenu_newgame_plus_no_saves"));
			m_fxNavigateBack.InvokeSelf();
		}
		else
		{
			m_initialSelectionsToIgnore = 1;
			OnPlaySoundEvent( "gui_global_panel_open" );
			m_flashValueStorage.SetFlashArray( "ingamemenu.newGamePlusSlots", dataFlashArray );
		}
	}
	
	protected function PopulateSaveDataForSlotType(saveType:int, parentObject:CScriptedFlashArray, allowEmptySlot:bool):void
	{
		IngameMenu_PopulateSaveDataForSlotType(m_flashValueStorage, saveType, parentObject, allowEmptySlot);
	}
	
	event  OnLoadSaveImageCancelled():void
	{
		theGame.FreeScreenshotData();
	}
	
	event  OnScreenshotDataRequested(saveIndex:int):void
	{
		var targetSaveInfo 	: SSavegameInfo;
		var saveGames		: array< SSavegameInfo >;
		
		theGame.GetRecentListSG( saveGames );
		UpdateSaveSlot();
		
		if (saveIndex >= 0 && saveIndex < saveGames.Size())
		{
			targetSaveInfo = saveGames[saveIndex];
			
			m_lastRequestedSaveInfo = targetSaveInfo;
			theGame.RequestScreenshotData(targetSaveInfo);
		}
	}
	
	event  OnCheckScreenshotDataReady():void
	{
		var moddedSave : bool;
	
		if (theGame.IsScreenshotDataReady())
		{
			m_fxOnSaveScreenshotRdy.InvokeSelf();
			moddedSave = theGame.GetModHandlerSystem().IsModdedSave(m_lastRequestedSaveInfo);
			m_fxOnSetModioBorderVis.InvokeSelfOneArg( FlashArgBool(moddedSave) );
		}
	}
	
	protected function SendInstalledDLCList():void
	{
		var currentData : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;
		var dlcManager : CDLCManager;
		var i : int;
		var dlcList : array<name>;
		
		var currentName : string;
		var currentDesc : string;
		
		
		
		dataArray = m_flashValueStorage.CreateTempFlashArray();
		
		dlcManager = theGame.GetDLCManager();
		dlcManager.GetDLCs(dlcList);
		
		for (i = 0; i < dlcList.Size(); i += 1)
		{
			
			
				currentData = m_flashValueStorage.CreateTempFlashObject();
				
				currentName = GetLocStringByKeyExt( "content_name_" + NameToString(dlcList[i]) );
				currentDesc = "";
				
				if (currentName != "")
				{
					currentData.SetMemberFlashString("label", currentName);
					currentData.SetMemberFlashString("desc", currentDesc);
					
					dataArray.PushBackFlashObject(currentData);
				}
			
		}
		
		
		
		m_flashValueStorage.SetFlashArray("ingamemenu.installedDLCs", dataArray);
	}
	
	protected function SendRescaleData():void
	{
		var currentData : CScriptedFlashObject;
		
		currentData = m_flashValueStorage.CreateTempFlashObject();
		
		currentData.SetMemberFlashNumber("initialHScale", theGame.GetUIHorizontalFrameScale() );
		currentData.SetMemberFlashNumber("initialVScale", theGame.GetUIVerticalFrameScale() );
		
		m_flashValueStorage.SetFlashObject("ingamemenu.uirescale", currentData);
	}
	
	protected function SendControllerData():void
	{
		var dataFlashArray : CScriptedFlashArray;
		
		if ( (W3ReplacerCiri)thePlayer )
		{
			dataFlashArray = InGameMenu_CreateControllerDataCiri(m_flashValueStorage);
		}
		else
		{
			dataFlashArray = InGameMenu_CreateControllerData(m_flashValueStorage);
		}
		
		m_flashValueStorage.SetFlashArray( "ingamemenu.gamepad.mappings", dataFlashArray );
	}
	
	protected function SendKeybindData():void
	{
		var dataFlashArray : CScriptedFlashArray;
		
		dataFlashArray = m_flashValueStorage.CreateTempFlashArray();
		
		IngameMenu_GatherKeybindData(dataFlashArray, m_flashValueStorage);
		
		m_flashValueStorage.SetFlashArray( "ingamemenu.keybindValues", dataFlashArray );
	}
	
	event  OnClearKeybind(keybindTag:name):void
	{
		hasChangedOption = true;
		mInGameConfigWrapper.SetVarValue('PCInput', keybindTag, "IK_None;IK_None"); 
		SendKeybindData();
	}
	
	
	
	protected function GetKeybindGroupTag(keybindName : name) : name
	{
		if (mInGameConfigWrapper.DoVarHasTag('PCInput', keybindName, 'input_overlap1'))
		{
			return 'input_overlap1';
		}
		else if (mInGameConfigWrapper.DoVarHasTag('PCInput', keybindName, 'input_overlap2'))
		{
			return 'input_overlap2';
		}
		else if (mInGameConfigWrapper.DoVarHasTag('PCInput', keybindName, 'input_overlap3'))
		{
			return 'input_overlap3';
		}
		else if (mInGameConfigWrapper.DoVarHasTag('PCInput', keybindName, 'input_overlap4'))
		{
			return 'input_overlap4';
		}
		else if (mInGameConfigWrapper.DoVarHasTag('PCInput', keybindName, 'input_overlap5'))
		{
			return 'input_overlap5';
		}
		
		else if (mInGameConfigWrapper.DoVarHasTag('PCInput', keybindName, 'input_overlap_potion1'))
		{
			return 'input_overlap_potion1';
		}
		else if (mInGameConfigWrapper.DoVarHasTag('PCInput', keybindName, 'input_overlap_potion2'))
		{
			return 'input_overlap_potion2';
		}
		else if (mInGameConfigWrapper.DoVarHasTag('PCInput', keybindName, 'input_overlap_potion3'))
		{
			return 'input_overlap_potion3';
		}
		else if (mInGameConfigWrapper.DoVarHasTag('PCInput', keybindName, 'input_overlap_potion4'))
		{
			return 'input_overlap_potion4';
		}
		
		
		return '';
	}
	
	event  OnChangeKeybind(keybindTag:name, newKeybindValue:EInputKey):void
	{
		var newSettingString : string;
		var exisitingKeybind : name;
		var groupIndex : int;
		var keybindChangedMessage : string;
		var numKeybinds : int;
		var i : int;
		var currentBindingTag : name;
		
		var iterator_KeybindName : name;
		var iterator_KeybindKey : string;
		
		hasChangedOption = true;
		
		newSettingString = newKeybindValue;
		
		
		
		{
			groupIndex = IngameMenu_GetPCInputGroupIndex();
		
			if (groupIndex != -1)
			{
				numKeybinds = mInGameConfigWrapper.GetVarsNumByGroupName('PCInput');
				currentBindingTag = GetKeybindGroupTag(keybindTag);
				
				for (i = 0; i < numKeybinds; i += 1)
				{
					iterator_KeybindName = mInGameConfigWrapper.GetVarName(groupIndex, i);
					iterator_KeybindKey = mInGameConfigWrapper.GetVarValue('PCInput', iterator_KeybindName);
					
					iterator_KeybindKey = StrReplace(iterator_KeybindKey, ";IK_None", ""); 
					iterator_KeybindKey = StrReplace(iterator_KeybindKey, "IK_None;", "");
					
					if (iterator_KeybindKey == newSettingString && iterator_KeybindName != keybindTag && 
						(currentBindingTag == '' || currentBindingTag != GetKeybindGroupTag(iterator_KeybindName)))
					{
						if (keybindChangedMessage != "")
						{
							keybindChangedMessage += ", ";
						}
						keybindChangedMessage += IngameMenu_GetLocalizedKeybindName(iterator_KeybindName);
						OnClearKeybind(iterator_KeybindName);
					}
				}
			}
			
			if (keybindChangedMessage != "")
			{
				keybindChangedMessage += " </br>" + GetLocStringByKeyExt("key_unbound_message");
				showNotification(keybindChangedMessage);
			}
		}
		
		newSettingString = newKeybindValue + ";IK_None"; 
		mInGameConfigWrapper.SetVarValue('PCInput', keybindTag, newSettingString);
		SendKeybindData();
		
		
		if(keybindTag == 'DrinkPotion1')
			OnChangeKeybind('DrinkPotion1Hold', newKeybindValue);
		else if(keybindTag == 'DrinkPotion2')
			OnChangeKeybind('DrinkPotion2Hold', newKeybindValue);
		else if(keybindTag == 'DrinkPotion3')
			OnChangeKeybind('DrinkPotion3Hold', newKeybindValue);
		else if(keybindTag == 'DrinkPotion4')
			OnChangeKeybind('DrinkPotion4Hold', newKeybindValue);
		
	}
	
	event  OnSmartKeybindEnabledChanged(value:bool):void
	{
		smartKeybindingEnabled = value;
	}
	
	event  OnInvalidKeybindTried(keyCode:EInputKey):void
	{
		showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_now"));
		OnPlaySoundEvent("gui_global_denied");
	}
	
	event  OnLockedKeybindTried():void
	{
		showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_now"));
		OnPlaySoundEvent("gui_global_denied");
	}
	
	event  OnResetKeybinds():void
	{
		mInGameConfigWrapper.ResetGroupToDefaults('PCInput');
		SendKeybindData();
		showNotification(inGameMenu_TryLocalize("menu_option_reset_successful"));
		
		hasChangedOption = true;
	}
	
	event OnDownloadContentRequested( groupId:int, optionName:name, optionValue:string )
	{
		var groupName : name;
		var locale : string;
	
		groupName = mInGameConfigWrapper.GetGroupName(groupId);
	
		if (groupName == 'Localization' && optionName == 'Virtual_Localization_speech')
		{
			locale = mInGameConfigWrapper.GetVarOption( groupName, optionName, StringToInt( optionValue ) );
			theGame.RequestVoiceLangDownload( locale );
		}
	}
	
	function PlayOpenSoundEvent()
	{
	}
	
	private var isDeveloperModeEnabled : bool; default isDeveloperModeEnabled = false;
	private var developerOptions : CScriptedFlashArray;
	
	public function GetDeveloperOptionsContainer() : CScriptedFlashArray
	{
		return developerOptions;
	}
	
	private function ShowDeveloperMode( show : bool )
	{
		var optionObject		: CScriptedFlashObject;
		var optionFlashArray 	: CScriptedFlashArray;
		var entriesArray		: CScriptedFlashArray;
		var entriesObject		: CScriptedFlashObject;
		var i					: int;
		
		if( show )
		{
			optionObject = m_flashValueStorage.CreateTempFlashObject();
			optionObject.SetMemberFlashUInt( "tag", NameToFlashUInt( 'DeveloperMode' ) );
			optionObject.SetMemberFlashInt( "groupID", theGame.GetInGameConfigWrapper().GetGroupIdx( 'Rendering' ) );
			optionObject.SetMemberFlashUInt( "type", IGMActionType_ToggleStepper );
			optionObject.SetMemberFlashString( "label", inGameMenu_TryLocalize( "DeveloperMode" ) );
			optionObject.SetMemberFlashString( "current", theGame.GetInGameConfigWrapper().GetVarValue( 'Rendering', 'DeveloperMode' ) );
			optionObject.SetMemberFlashString( "startingValue", "false" );
			optionObject.SetMemberFlashBool( "checkHardwareCursor", false );
			optionObject.SetMemberFlashBool( "streamable", false );	
			optionObject.SetMemberFlashBool( "isDropdownContent", false );
			optionObject.SetMemberFlashBool( "isDeveloper", true );
		
			entriesArray = m_flashValueStorage.CreateTempFlashArray();
			entriesArray.PushBackFlashObject( optionObject );
		
			entriesObject = m_flashValueStorage.CreateTempFlashObject();
			entriesObject.SetMemberFlashArray( "list", entriesArray );
			entriesObject.SetMemberFlashUInt( "masterTag", 0 );
			m_flashValueStorage.SetFlashObject( "options.insert_entry", entriesObject );
		}
		else
		{
			optionObject = m_flashValueStorage.CreateTempFlashObject();
			optionObject.SetMemberFlashUInt( "tag", NameToFlashUInt( 'DeveloperMode' ) );
		
			entriesArray = m_flashValueStorage.CreateTempFlashArray();
			entriesArray.PushBackFlashObject( optionObject );
		
			entriesObject = m_flashValueStorage.CreateTempFlashObject();
			entriesObject.SetMemberFlashArray( "list", entriesArray );
			m_flashValueStorage.SetFlashObject( "options.remove_entry", entriesObject );
		}
		
		theGame.GetGuiManager().ForceProcessFlashStorage();
		ShowDeveloperOptions( theGame.GetInGameConfigWrapper().GetVarValue( 'Rendering', 'DeveloperMode' ) == "true" );
	}
	
	public function ShowDeveloperOptions( show : bool )
	{
		var optionObject		: CScriptedFlashObject;
		var optionFlashArray 	: CScriptedFlashArray;
		var entriesArray		: CScriptedFlashArray;
		var entriesObject		: CScriptedFlashObject;
		var i					: int;
		var masterTag			: int;
	
		if( show && isDeveloperModeEnabled )
		{
			for( i = 0; i < developerOptions.GetLength(); i = i + 1 )
			{
				entriesArray = m_flashValueStorage.CreateTempFlashArray();
				entriesArray.PushBackFlashObject( developerOptions.GetElementFlashObject( i ) );
				
				entriesObject = m_flashValueStorage.CreateTempFlashObject();
				entriesObject.SetMemberFlashArray( "list", entriesArray );
				masterTag = developerOptions.GetElementFlashObject( i ).GetMemberFlashUInt( "masterTag");
				entriesObject.SetMemberFlashUInt( "masterTag", masterTag );
				
				m_flashValueStorage.SetFlashObject( "options.insert_entry", entriesObject );
				theGame.GetGuiManager().ForceProcessFlashStorage();
			}
		}
		else
		{
			for( i = 0; i < developerOptions.GetLength(); i = i + 1 )
			{
				entriesArray = m_flashValueStorage.CreateTempFlashArray();
				entriesArray.PushBackFlashObject( developerOptions.GetElementFlashObject( i ) );
				
				entriesObject = m_flashValueStorage.CreateTempFlashObject();
				entriesObject.SetMemberFlashArray( "list", entriesArray );
				
				m_flashValueStorage.SetFlashObject( "options.remove_entry", entriesObject );
				theGame.GetGuiManager().ForceProcessFlashStorage();
			}
		}
	}
	
	event OnShowDeveloperMode( action : SInputAction )
	{
		if( !IsPressed(action) || !theInput.IsActionPressed( 'ShowDeveloperModeAlt' ) )
			return false;
			
		isDeveloperModeEnabled = !isDeveloperModeEnabled;
		ShowDeveloperMode( isDeveloperModeEnabled );
	}
	
	public function ChangeShowModioIndicator(value:bool):void
	{
		m_fxShowModioLoadIndicator.InvokeSelfOneArg(FlashArgBool(value));
	}
	
	public function SetModdedTooltipText():void
	{
		var moddedText : string;
		
		if (theGame.GetModHandlerSystem().HasUninstalledMods())
		{
			moddedText = GetLocStringByKeyExt("mods_mod_uninstalled");
		}
		else
		{
			moddedText = GetLocStringByKeyExt("mods_enabled");
			if(theGame.GetPlatform() == Platform_Xbox_SCARLETT_ANACONDA || theGame.GetPlatform() == Platform_Xbox_SCARLETT_LOCKHART || theGame.GetPlatform() == Platform_PC_GDK)
				moddedText += " " + GetLocStringByKeyExt("mods_enabled_achievements");
			else if(theGame.GetPlatform() == Platform_PS5)
				moddedText += " " + GetLocStringByKeyExt("mods_enabled_trophies");
		}

		m_flashValueStorage.SetFlashString("mod.tooltip.text", moddedText);
	}
	
	event  OnRequestMediaLogo( modid:string, resolution:string )
	{
		var data : SModImageLoadData;
	
		if(!cachedVerifData || !cachedVerifData.FindModIdFromString(modid, data.m_modid))
			return false;
		data.m_resolution = resolution;
		data.m_type = "logo";
		
		if(!m_modVerificationStateMachine)
		{
			m_modVerificationStateMachine = new CR4ModVerificationStates in this;
			m_modVerificationStateMachine.SetRefIngameMenu(this);
		}
		
		m_modVerificationStateMachine.AddImageToList(data);
	}
	
	public function HandleImageLoad( data: SModImageLoadData, path:string)
	{
		var modidStr : string;
		modidStr = theGame.GetModHandlerSystem().ConvertModIDToString(data.m_modid);
	
		if(data.m_type != "gallery")
			m_fxHandleImageLoaded.InvokeSelfFourArgs( FlashArgString(modidStr),FlashArgString(data.m_resolution), FlashArgString(data.m_type), FlashArgString(path));
		else	
			m_fxHandleImageLoaded.InvokeSelfFiveArgs( FlashArgString(modidStr),FlashArgString(data.m_resolution), FlashArgString(data.m_type), FlashArgString(path), FlashArgString(data.m_galleryIndex));
	}
	
	event  OnVerificationCheckboxClicked( modid:string, value:bool)
	{
		if (cachedVerifData)
		{
			cachedVerifData.HandleModEnabledChange(modid, value);
		}
	}
	
	event  OnSetCheckboxesClicked(index:int, value : bool)
	{		
		
	}
	
	event  OnInputHandled(NavCode:string, KeyCode:int, ActionId:int)
	{
		if(cachedVerifData && cachedVerifData.valid)
		{
			cachedVerifData.OnUserFeedback(NavCode);
		}
	}
	
	public function OnPopupContinueConfirmed():void
	{
		LoadLastSave(false);
	}
	
	event  OnLicenseAgreementAccepted():void
	{
		theGame.GetInGameConfigWrapper().SetVarValue('Hidden', 'Eula410WasAccepted', "true");
		theGame.SaveUserSettings();
	}
	
	event  OnLicenseAgreementDeclined():void
	{
		
	}
	
	public function CallModVerificationPopup():void
	{
		prepareBigMessageMods();
	}

	public function CallModFailedPopup():void
	{
		prepareBigMessageFailedMods();
	}
	
	
	
	
	
	
	
	
	
	
	public function OnManagementEvent( modidScr : SModioModID, modState : EModState )
	{
		LogChannel('MODS', "OnManagementEvent was called ");
	}

	public function OnModioNetworkError()
	{
		LogChannel('MODS', "OnModioNetworkError was called ");
		showNotification(GetLocStringByKeyExt("error_modio_connection"));
	}

	public function OnModioLocalModsUpdated()
	{
		LogChannel('MODS', "OnModioLocalModsUpdated was called ");
	}
	
	public function OnCDPRAccountLoggedIn()
	{
		LogChannel('MODS', "OnCDPRAccountLoggedIn was called ");
		if(m_shouldOpenModMenuOnLogin)
			OpenModMenu();
	}
	
	public function RequestLinkLoad(link : ETermsLinkType)
	{
		m_igmStateMachine.OnOpenLink(link);
	}
	

	
	private function DefineSwitchFeatureMenuItem(itemName:name, itemLabel:string, itemDesc:string, optional parentMenuItem:name, optional menuState:name) : void
	{
		var newMenuItem 	: SMenuTab;

		newMenuItem.MenuName = itemName;
		newMenuItem.MenuLabel = itemLabel;
		newMenuItem.MenuDesc = itemDesc;
		newMenuItem.Enabled = true;
		newMenuItem.Visible = true;
		newMenuItem.MenuState = menuState;
		
		newMenuItem.ParentMenu = parentMenuItem;
		m_menuData.PushBack(newMenuItem);
	}
	
	private function SetupSwitchFeatureMenu() : void
	{
		var l_flashSubArray   : CScriptedFlashArray;
		
		l_flashSubArray = m_flashValueStorage.CreateTempFlashArray();
		GetSwitchFeatureMenuStruct(l_flashSubArray);
		
		m_flashValueStorage.SetFlashArray( "panel.switch.setup", l_flashSubArray);
	}
	
	private function GetSwitchFeatureMenuStruct(out StructGFx : CScriptedFlashArray) : void
	{
		var i				  : int;
		var l_flashObject     : CScriptedFlashObject;
		var CurDataItem : SMenuTab;
		
		for ( i = 0; i < m_menuData.Size(); i += 1 )
		{
			CurDataItem = m_menuData[i];
			
			if (CurDataItem.ParentMenu == '')
			{
				l_flashObject = m_flashValueStorage.CreateTempFlashObject();
				GetSwitchFeatureMenuItem(CurDataItem, l_flashObject);
				
				StructGFx.PushBackFlashObject(l_flashObject);
			}
		}
	}

	private function GetSwitchFeatureMenuItem(MenuItemData:SMenuTab, out GFxObjectData:CScriptedFlashObject):void
	{
		GFxObjectData.SetMemberFlashUInt("id", NameToFlashUInt(MenuItemData.MenuName));
		GFxObjectData.SetMemberFlashString("name", NameToString(MenuItemData.MenuName)); 
		GFxObjectData.SetMemberFlashString("icon", NameToString(MenuItemData.MenuName)); 
		GFxObjectData.SetMemberFlashString("label", GetLocStringByKeyExt(MenuItemData.MenuLabel));
		GFxObjectData.SetMemberFlashString("tabDesc", GetLocStringByKeyExt(MenuItemData.MenuDesc));
		GFxObjectData.SetMemberFlashString("tabNewDesc", "Nothing New");
		GFxObjectData.SetMemberFlashBool("visible", MenuItemData.Visible);
		GFxObjectData.SetMemberFlashBool("enabled", MenuItemData.Enabled && !MenuItemData.Restricted);
		GFxObjectData.SetMemberFlashString("state", MenuItemData.MenuState);
	}

	private function UpdateGameLogo():void
	{
		var audioLanguageName 	: string;
		var tempLanguageName 	: string;
		theGame.GetGameLanguageName(audioLanguageName,tempLanguageName);
		if( tempLanguageName != languageName )
		{
			languageName = tempLanguageName;
			if( languageName == "ZH")
				m_fxSetGameLogoLanguage.InvokeSelfOneArg( FlashArgString("ZHT") );			
			else if( languageName == "CN")
				m_fxSetGameLogoLanguage.InvokeSelfOneArg( FlashArgString("ZHS") );
			else if( languageName == "EN" || languageName == "CZ" || languageName == "PL" || languageName == "RU" || languageName == "UA" )
				m_fxSetGameLogoLanguage.InvokeSelfOneArg( FlashArgString(languageName) );
			else 
				m_fxSetGameLogoLanguage.InvokeSelfOneArg( FlashArgString("REST") );
		}
	}
	
	private function UpdateBardsBalladTooltipText()
	{
		var inGameConfigWrapper	: CInGameConfigWrapper;
		var value : string;
	
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();

		value = inGameConfigWrapper.GetVarValue('Accessibility', 'AccessibilityPreset');

		if(value == "0")
			m_fxUpdateBardsBalladText.InvokeSelfOneArg(FlashArgString(""));
		else 
			m_fxUpdateBardsBalladText.InvokeSelfOneArg(FlashArgString("[[accessibility_presets_bardsballad_desc]]"));
	}
	
	public function ShowMyRewardsPanel( out unlockedIds : array< int > ) : void
	{
		var flashUnlockedIds : CScriptedFlashArray;
		var i : int;
		var len : int;
		var currentId : int;
		
		flashUnlockedIds = m_flashValueStorage.CreateTempFlashArray();
		
		len = unlockedIds.Size();
		for ( i = 0; i < len; i+=1 )
		{
			currentId = unlockedIds[ i ];
			flashUnlockedIds.PushBackFlashInt( currentId );
		}
		
		m_flashValueStorage.SetFlashArray( "ingamemenu.myrewardspanel", flashUnlockedIds );
		
		UpdateUserPanelData();
	}
	
	event  OnUserPanelInit()
	{
		UpdateUserPanelData();
	}
	
	public function UpdateUserPanelData() : void
	{
		var cloudPersona : string;
		var userName : string;
		var userNameIcon : int;
		
		cloudPersona = theGame.GetGuiManager().GetNamePersona();
		userName = FixStringForFont(theGame.GetActiveUserDisplayName());
		
		userNameIcon = -1;
		
		SendUserPanelData( cloudPersona, userNameIcon, userName );
	}
	
	public function SendUserPanelData( cloudPersona : string, userNameIcon : int, userName : string ) : void
	{
		var data : CScriptedFlashObject;
		
		data = m_flashValueStorage.CreateTempFlashObject();

		data.SetMemberFlashString( "cloudPersona", cloudPersona );
		data.SetMemberFlashString( "userName", userName );
		data.SetMemberFlashInt( "userNameIcon", userNameIcon );
		
		m_flashValueStorage.SetFlashObject( "userpanel.accountData", data );
	}
	
	public function ShowStartupLoginPage( shouldOpenMods : bool ) : void
	{
		var currentMenu : CR4Menu;
		var initData : W3StartupMenuInitData;
	
		m_shouldOpenModMenuOnLogin = shouldOpenMods;
		
		currentMenu = theGame.GetGuiManager().GetRootMenu();
		CloseMenu();
		
		initData = new W3StartupMenuInitData in theGame.GetGuiManager();
		
		initData.requestPage = SPI_Connect;
		initData.reopenMenu = true;
		initData.reopenMenuName = currentMenu.GetMenuName();
		
		theGame.RequestMenu( 'StartupExperienceMenu', initData );
	}
	
	event  OnRedAccountButtonActivated()
	{
		var isSignedIn : bool;
		var rewarr : array< int >;
		
		isSignedIn = theGame.IsGalaxyUserSignedIn();
		
		
		if (!isSignedIn) 
		{
			ShowStartupLoginPage(false);
		}
		else
		{
			theGame.GetGuiManager().GetGalaxyRewardsList( rewarr );
			if ( rewarr.Size() != 0 ) 
			{				
				ShowMyRewardsPanel( rewarr );
			}
			else
			{
				Log("No rewards, did you login?");
			}
		}
	}
	
	private function ShowTelemetryDataRequestPopup():void
	{
		var qrBufferId : string;
		var description : string;
		var url : string;
	
		qrBufferId = "telemetrydatarequest.qrcode";
		description = "[[panel_telemetry_scan]]";
		url = "[[panel_telemetry_view_page]]";
		
		m_fxShowTelemetryDataRequestPopup.InvokeSelfThreeArgs( FlashArgString(qrBufferId), FlashArgString(description), FlashArgString(url) );
	}
	
	event  OnTelemetryDataRequestPopupLinkClicked()
	{
		theGame.GetGuiManager().GalaxyOpenTelemetryTakeoutLink();
	}
}

exec function mm_test_myrewards():void
{
	var rewarr : array< int >;
	var rootMenu : CR4Menu;
	var ingameMenu : CR4IngameMenu;
	
	var cloudPersona : string;
	var userName : string;
	var userNameIcon : int;
	
	rootMenu = theGame.GetGuiManager().GetRootMenu();
	if ( rootMenu )
	{
		theGame.GetGuiManager().GetGalaxyRewardsList( rewarr );
		if ( rewarr.Size() == 0) {
			Log("No rewards, did you login?");
			return;
		}

		ingameMenu = (CR4IngameMenu)rootMenu.GetSubMenu();
		if ( ingameMenu )
		{
		
			rewarr.PushBack(13);
			rewarr.PushBack(14);
			rewarr.PushBack(15);
			rewarr.PushBack(16);
			rewarr.PushBack(17);
			rewarr.PushBack(18);
			rewarr.PushBack(19);
			rewarr.PushBack(20);
			rewarr.PushBack(21);

			ingameMenu.ShowMyRewardsPanel( rewarr );
			
			cloudPersona = "Geralt_Of_Rivia_99#7420";
			userName = "Blaviken_Butcher";
			userNameIcon = 2;
			ingameMenu.SendUserPanelData( cloudPersona, userNameIcon, userName );
			
			return;
		}
	}

	Log("Ingame/Main menu must be open");
}

exec function mm_test_usernamepanel():void
{
	var rootMenu : CR4Menu;
	var ingameMenu : CR4IngameMenu;
	
	var cloudPersona : string;
	var userName : string;
	var userNameIcon : int;
	
	rootMenu = theGame.GetGuiManager().GetRootMenu();
	if ( rootMenu )
	{
		ingameMenu = (CR4IngameMenu)rootMenu.GetSubMenu();
		if ( ingameMenu )
		{
			cloudPersona = "Geralt_Of_Rivia_99#7420";
			userName = "Blaviken_Butcher";
			userNameIcon = 2;
			ingameMenu.SendUserPanelData( cloudPersona, userNameIcon, userName );
			
			return;
		}
	}

	Log("Ingame/Main menu must be open");
}

exec function mm_test_usernamepanel2( cloudPersona : string, platform : int, userName : string ):void
{
	var rootMenu : CR4Menu;
	var ingameMenu : CR4IngameMenu;
	
	rootMenu = theGame.GetGuiManager().GetRootMenu();
	if ( rootMenu )
	{
		ingameMenu = (CR4IngameMenu)rootMenu.GetSubMenu();
		if ( ingameMenu )
		{
			ingameMenu.SendUserPanelData( cloudPersona, platform, userName );
			return;
		}
	}

	Log("Ingame/Main menu must be open");
}



exec function modterms():void
{
	var rootMenu : CR4Menu;
	var ingameMenu : CR4IngameMenu;
	rootMenu = theGame.GetGuiManager().GetRootMenu();
	if ( rootMenu )
	{
		ingameMenu = (CR4IngameMenu)rootMenu.GetSubMenu();
		if ( ingameMenu )
		{
			ingameMenu.OpenModTermsPopup();
			return;
		}
	}

	Log("Ingame/Main menu most be open");
}

exec function modverif():void
{
	var rootMenu : CR4Menu;
	var ingameMenu : CR4IngameMenu;
	rootMenu = theGame.GetGuiManager().GetRootMenu();
	if ( rootMenu )
	{
		ingameMenu = (CR4IngameMenu)rootMenu.GetSubMenu();
		if ( ingameMenu )
		{
			ingameMenu.CallModVerificationPopup();
			return;
		}
	}

	Log("Ingame/Main menu most be open");
}

exec function modfailed():void
{
	var rootMenu : CR4Menu;
	var ingameMenu : CR4IngameMenu;
	rootMenu = theGame.GetGuiManager().GetRootMenu();
	if ( rootMenu )
	{
		ingameMenu = (CR4IngameMenu)rootMenu.GetSubMenu();
		if ( ingameMenu )
		{
			ingameMenu.CallModFailedPopup();
			return;
		}
	}

	Log("Ingame/Main menu most be open");
}




















exec function redreminder():void
{
	var rootMenu : CR4Menu;
	var ingameMenu : CR4IngameMenu;
	rootMenu = theGame.GetGuiManager().GetRootMenu();
	if ( rootMenu )
	{
		ingameMenu = (CR4IngameMenu)rootMenu.GetSubMenu();
		if ( ingameMenu )
		{
			ingameMenu.StartShowCustomDialogGalaxySignInReminder();
			return;
		}
	}

	Log("Ingame/Main menu most be open");
}

exec function ddd()
{
	LogChannel('asd', "[" + GetLocStringByKey( "menu_goty_starting_message_content" ) + "]" );
	LogChannel('asd', "[" + GetLocStringById( 1217650 ) + "]" );
}