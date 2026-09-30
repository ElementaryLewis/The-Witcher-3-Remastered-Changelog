/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SMenuTab
{
	var MenuName   : name;
	var MenuLabel  : string;
	var Visible    : bool;
	var Enabled    : bool;
	var Restricted : bool;
	var ParentMenu : name;
	var MenuState  : name; 
};

class CR4CommonMenu extends CR4MenuBase
{
	private var m_menuData 	   : array< SMenuTab >;
	private var m_subMenuData  : array< SMenuTab >;
	private var m_lastMenuName : name;
	
	public var m_hubEnabled   : bool;
	
	private var m_lockedInHub : bool; default m_lockedInHub = false;
	private var m_lockedInMenu : bool; default m_lockedInMenu = false;
	
	public var m_contextInputBlocked : bool; default m_contextInputBlocked = false;
	
	private var m_fxSubMenuClosed				: CScriptedFlashFunction;
	private var m_fxUpdateLevel					: CScriptedFlashFunction;
	private var m_fxUpdateMoney					: CScriptedFlashFunction;
	private var m_fxUpdateWeight				: CScriptedFlashFunction;
	private var m_fxNavigateNext				: CScriptedFlashFunction;
	private var m_fxNavigatePrior				: CScriptedFlashFunction;
	private var m_fxSelectSubMenuTab			: CScriptedFlashFunction;
	private var m_fxSetShopInventory			: CScriptedFlashFunction;
	private var m_fxUpdateTabEnabled			: CScriptedFlashFunction;
	private var m_fxLockOpenTabNavigation 		: CScriptedFlashFunction;
	private var m_fxBlockMenuClosing   			: CScriptedFlashFunction;
	private var m_fxBlockHubClosing    			: CScriptedFlashFunction;
	private var m_fxSetInputFeedbackVisibility 	: CScriptedFlashFunction;
	private var m_fxSetPlayerDefailsVis 		: CScriptedFlashFunction;
	private var m_fxSetMeditationBackgroundMode	: CScriptedFlashFunction;
	private var m_fxOnChildMenuConfigured		: CScriptedFlashFunction;
	private var m_fxUpdateMenuBackgroundImage	: CScriptedFlashFunction;
	private var m_fxBlockBackNavigation			: CScriptedFlashFunction;
	
	
	private var m_fxSelectTab	: CScriptedFlashFunction;
	private var m_fxEnterCurrentTab	: CScriptedFlashFunction;
	
	protected var m_defaultBindings : array<SKeyBinding>;
	protected var m_contextBindings : array<SKeyBinding>;
	protected var m_GFxBindings		: array<SKeyBinding>;
	
	public var m_contextManager  	: W3ContextManager;
	public var m_mode_meditation 	: bool; default m_mode_meditation = false;
	public var m_had_meditation		: bool; default m_had_meditation = false;
	private var noSaveLock			: int;		
	
	private var isCiri : bool;
	
	protected var inventoryHotkey:EInputKey;
	protected var characterHotkey:EInputKey;
	protected var mapHotkey:EInputKey;
	protected var journalHotkey:EInputKey;
	protected var alchemyHotkey:EInputKey;
	protected var bestiaryHotkey:EInputKey;
	protected var glossaryHotkey:EInputKey;
	protected var meditationHotkey:EInputKey;
	protected var craftingHotkey:EInputKey;
	
	
	protected var isInNpcContext:bool;
	protected var isEnchantingAvailable:bool;
	protected var isShopAvailable:bool;
	protected var isRepairAvailable:bool;
	protected var isCraftingAvailable:bool;
	protected var isAlchemyAvailable:bool;
	
	protected var isPlayerMeditatingInBed:bool;
	
	event  OnConfigUI()
	{
		var stateName     : name;
		var menuName      : name;
		var shouldSkipHub : bool;
		var lootPopup	  : CR4LootPopup;
		
		var initData          : W3MenuInitData;
		var initMapData       : W3MapInitData;
		var initSingleData    : W3SingleMenuInitData;
		var selectionPopupRef : CR4ItemSelectionPopup;
		
		if (!thePlayer.IsAlive() || theGame.HasBlackscreenRequested() || theGame.IsFading())
		{
			CloseMenu();
			return true;
		}
		
		theGame.CreateNoSaveLock( "fullscreen_ui_panels", noSaveLock, false, false );
		theGame.GameplayFactsRemove("closingHubMenu");
		theSound.SoundEvent("system_pause");
		
		fetchCurrentHotkeys();
		
		m_initialSelectionsToIgnore = 2;
		m_hideTutorial = true;
		m_forceHideTutorial = false;
		
		menuName = theGame.GetMenuToOpen();
		shouldSkipHub = menuName != '';
		
		CheckNpcTags();
		
		if( isInNpcContext )
		{
			theGame.GameplayFactsAdd("shopMode", 1);
		}
		else
		{
			theGame.GameplayFactsRemove("shopMode");
		}
		
		lootPopup = (CR4LootPopup)theGame.GetGuiManager().GetPopup('LootPopup');
			
		if (lootPopup)
		{
			lootPopup.ClosePopup();
		}
		
		super.OnConfigUI();
		
		if ((W3ReplacerCiri)thePlayer)
		{
			isCiri = true;
		}
		else
		{
			isCiri = false;
		}
		
		m_hubEnabled = true;
		
		GameplayFactsSet("GamePausedNotByUI", (int)theGame.IsGameTimePaused());
		theGame.Pause("menus");
		
		m_flashModule = GetMenuFlash();
		m_fxSubMenuClosed 				= m_flashModule.GetMemberFlashFunction( "onSubMenuClosed" );
		m_fxUpdateLevel 				= m_flashModule.GetMemberFlashFunction( "updatePlayerLevel" );
		m_fxUpdateMoney 				= m_flashModule.GetMemberFlashFunction( "updateMoney" );
		m_fxUpdateWeight 				= m_flashModule.GetMemberFlashFunction( "updateWeight" );
		m_fxNavigateNext 				= m_flashModule.GetMemberFlashFunction( "handleForceNextTab" );
		m_fxNavigatePrior 				= m_flashModule.GetMemberFlashFunction( "handleForcePriorTab" );
		m_fxSelectSubMenuTab 			= m_flashModule.GetMemberFlashFunction( "enterCurrentlySelectedTab" );
		m_fxSetShopInventory 			= m_flashModule.GetMemberFlashFunction( "setShopInventory" );
		m_fxUpdateTabEnabled 			= m_flashModule.GetMemberFlashFunction( "updateTabEnabled" );
		m_fxLockOpenTabNavigation 		= m_flashModule.GetMemberFlashFunction( "lockOpenTabNavigation" );		
		m_fxBlockMenuClosing 			= m_flashModule.GetMemberFlashFunction( "blockMenuClosing" );
		m_fxBlockHubClosing 			= m_flashModule.GetMemberFlashFunction( "blockHubClosing" );
		m_fxSetInputFeedbackVisibility 	= m_flashModule.GetMemberFlashFunction( "SetInputFeedbackVisibility" );
		m_fxSetPlayerDefailsVis 		= m_flashModule.GetMemberFlashFunction( "setPlayerDetailsVisible" );
		m_fxSetMeditationBackgroundMode	= m_flashModule.GetMemberFlashFunction( "setMeditationBackgroundMode" );
		m_fxSelectTab 					= m_flashModule.GetMemberFlashFunction( "setSelectedTab" );
		m_fxEnterCurrentTab 			= m_flashModule.GetMemberFlashFunction( "enterCurrentlySelectedTab" );
		m_fxOnChildMenuConfigured 		= m_flashModule.GetMemberFlashFunction( "onChildMenuConfigured" );
		m_fxUpdateMenuBackgroundImage	= m_flashModule.GetMemberFlashFunction( "updateMenuBackgroundImage" );
		m_fxBlockBackNavigation			= m_flashModule.GetMemberFlashFunction( "blockBackNavigation" );
		
		stateName = '';
		initData = (W3MenuInitData)GetMenuInitData();
		if (initData)
		{
			stateName = initData.getDefaultState();
		}
		
		if (theGame.GameplayFactsQuerySum("stashMode") == 1)
		{
			m_hubEnabled = false;
			shouldSkipHub = true;
			DefineMenuItem('InventoryMenu', "panel_title_stash");
		}
		else if( isInNpcContext )
		{
			AddMerchantTagIfMissing_HACK();
			
			DefineSceneMenuStructure();
		}	
		else
		{			
			DefineMenuStructure();
			
			initMapData = (W3MapInitData)initData;
			initSingleData = (W3SingleMenuInitData)initData;
			
			SetMenuTabeEnable( 'InventoryMenu', false, 'HorseInventory');
			
			if (menuName == 'MapMenu' && initMapData && ( initMapData.GetTriggeredExitEntity() || initMapData.GetUsedFastTravelEntity() ) )
			{
				
				m_menuData.Clear();
				DefineMenuItem('MapMenu', "panel_title_fullmap", '', 'FastTravel');
				
				SetSingleMenuTabEnabled( 'MapMenu' );
				m_hubEnabled = false;
			}
			
			if( initSingleData )
			{
				if( initSingleData.GetBlockOtherPanels() )
				{
					m_menuData.Clear();
					
					if (menuName == 'MeditationClockMenu')
					{
						DefineMenuItem('MeditationClockMenu', "panel_name_sleep", '');
					}
					else
					if (menuName == 'GlossaryBooksMenu')
					{
						DefineMenuItem('GlossaryBooksMenu', "books_panel_title", '');
					}
					
					shouldSkipHub = true;
					m_hubEnabled = false;
					
					SetSingleMenuTabEnabled( initSingleData.fixedMenuName );
				}
				
				if( initSingleData.ignoreMeditationCheck )
				{
					isPlayerMeditatingInBed = true;
				}
				
				if( initSingleData.unlockCraftingMenu )
				{
					m_menuData.Clear();
					DefineMenuItem( 'CraftingParent', "panel_title_crafting" );
					DefineMenuItem( 'BlacksmithMenu', "panel_title_blacksmith_disassamble", 'CraftingParent', 'Disassemble' );
				}
			}
		}
		
		DisableNotAllowedTabs();
		UpdateTabs();
		SetMenuBackground();
		
		if( menuName == '')
		{
			if (stateName != '')
			{
				menuName = GetMenuParentName(stateName);
			}
			else
			{
				menuName = 'MapMenu';
				stateName = 'GlobalMap';
				
			}
		}
		else if (menuName == 'MeditationClockMenu')
		{
			SetMeditationMode(true);
		}
		
		if( m_menuData.Size() < 1 )
		{
			m_hubEnabled = false;
			shouldSkipHub = true;
			
			
			if (menuName == 'InventoryMenu')
			{
				DefineMenuItem('InventoryMenu', "panel_inventory", '');
			}
		}
		
		SetupMenu();
		
		if (isCiri)
		{
			m_hubEnabled = false;
			m_fxSetPlayerDefailsVis.InvokeSelfOneArg(FlashArgBool(false));
			
			
			
			
				shouldSkipHub = true;
				m_fxSelectTab.InvokeSelfTwoArgs(FlashArgUInt(NameToFlashUInt('MapMenu')), FlashArgString('GlobalMap'));
			
		}
		else
		{
			m_fxSelectTab.InvokeSelfTwoArgs(FlashArgUInt(NameToFlashUInt(menuName)), FlashArgString(stateName));
		}
		
		if( shouldSkipHub ) 
		{
			m_fxEnterCurrentTab.InvokeSelf();
		}
		
		theInput.StoreContext( 'EMPTY_CONTEXT' );
		
		m_contextManager = new W3ContextManager in this;
		m_contextManager.Init(this);
		
		m_guiManager.RequestMouseCursor(true);
		
		if (theInput.LastUsedPCInput())
		{
			theGame.MoveMouseTo(0.475, 0.48); 
		}
		
		theSound.SoundLoadBank( "gui_ep2.bnk", true );
		
		selectionPopupRef = (CR4ItemSelectionPopup)theGame.GetGuiManager().GetPopup('ItemSelectionPopup');
		if (selectionPopupRef)
		{
			theGame.ClosePopup('ItemSelectionPopup');
		}
		
		if( !m_hubEnabled )
		{
			m_fxBlockBackNavigation.InvokeSelf();
		}
	}
	
	public function GetIsPlayerMeditatingInBed() : bool
	{
		return isPlayerMeditatingInBed;
	}
	
	protected function GetSavedDataMenuName() : name
	{
		return theGame.GetMenuToOpen(); 
	}
	
	function SaveStateData()
	{
		m_guiManager.UpdateUISavedData( GetMenuName(), UISavedData.openedCategories, '', UISavedData.selectedModule );
	}	
		
	protected function GetFirstChildMenuName( parentName : name ) : name
	{
		var i : int;
		
		for ( i = 0; i < m_menuData.Size(); i += 1 )	
		{
			if( m_menuData[i].ParentMenu == parentName )
			{
				return m_menuData[i].MenuName;
			}
		}
		return parentName;
	}	

	protected function GetMenuParentName( menuName : name ) : name
	{
		var i : int;
		
		for ( i = 0; i < m_menuData.Size(); i += 1 )	
		{
			if( m_menuData[i].MenuName == menuName )
			{
				if( m_menuData[i].ParentMenu != '' )
				{
					return m_menuData[i].ParentMenu;
				}
			}	
			else if( m_menuData[i].MenuState == menuName )
			{
				if( m_menuData[i].ParentMenu != '' )
				{
					return m_menuData[i].ParentMenu;
				}
			}
		}
		return menuName;
	}
	
	protected function HasMenuDefined( menuName : name ) : bool
	{
		var i : int;
		
		for ( i = 0; i < m_menuData.Size(); i += 1 )
		{
			if ( m_menuData[i].MenuName == menuName )
			{
				return true;
			}
		}
		
		return false;
	}
	
	protected function HasMenuWithStateDefined( menuName : name, stateName : name ) : bool
	{
		var i : int;
		
		for ( i = 0; i < m_menuData.Size(); i += 1 )
		{
			if ( m_menuData[i].MenuName == menuName && m_menuData[i].MenuState == stateName )
			{
				return true;
			}
		}
		
		return false;
	}

	protected function GetSavedMenuFromParentName( parentMenuName : name ) : name
	{
		UISavedData = m_guiManager.GetUISavedData( parentMenuName );
		if( UISavedData.selectedTag != '' && HasMenuDefined(UISavedData.selectedTag) )
		{
			return UISavedData.selectedTag;
		}
		return parentMenuName;
	}	
	
	event  OnClosingMenu()
	{	
		var menuInitData : W3MenuInitData;
		var fastForward : CGameFastForwardSystem;
		var waitt : W3PlayerWitcherStateMeditationWaiting;
		
		theSound.SoundEvent("system_resume");
		OnPlaySoundEvent( "gui_global_panel_close" );
		
		theGame.GameplayFactsRemove("stashMode");
		
		if(thePlayer.GetCurrentStateName() == 'MeditationWaiting')
		{
			waitt = (W3PlayerWitcherStateMeditationWaiting)thePlayer.GetCurrentState();
			if(waitt)
				waitt.RequestWaitStop();
		}
		
		
		menuInitData = (W3MenuInitData)GetMenuInitData();
		if (menuInitData)
		{
			
			delete menuInitData;
		}
		if (m_contextManager)
		{
			delete m_contextManager;
		}
		
		StopMeditation();
		
		
		fastForward = theGame.GetFastForwardSystem();
		fastForward.RequestFastForwardShutdown( true );
		
		theGame.Unpause("menus");
		
		if (m_configUICalled)
		{
			theInput.RestoreContext( 'EMPTY_CONTEXT', true );
		}
		
		theGame.SetMenuToOpen( '' );
		
		theGame.ReleaseNoSaveLock(noSaveLock);
		
		
		theGame.GameplayFactsAdd("closingHubMenu",1);
		
		m_guiManager.RequestMouseCursor(false);
		m_guiManager.ClearNotificationsQueue();
		
		theSound.SoundUnloadBank( "gui_ep2.bnk" );
		
		super.OnClosingMenu();
		
		
		theGame.FadeOutAsync( 0 ); 
		theGame.FadeInAsync( 0.2 );
	}
	
	public function SetInputFeedbackVisibility( value : bool ):void
	{
		m_fxSetInputFeedbackVisibility.InvokeSelfOneArg( FlashArgBool(value) );
	}
	
	public function SwitchToSubMenu( MenuName : name, MenuState : string)
	{
		m_fxSelectTab.InvokeSelfTwoArgs(FlashArgUInt(NameToFlashUInt(MenuName)), FlashArgString(MenuState));
		m_fxEnterCurrentTab.InvokeSelf(); 
	}
	
	event  OnHideChildMenu()
	{
		var childMenu : CR4MenuBase;
		
		childMenu = GetLastChild();
		if (childMenu)
		{
			childMenu.CloseMenu();
		}
		
		if (!m_hubEnabled)
		{
			CloseMenu();
			return true;
		}
		
		m_fxSubMenuClosed.InvokeSelf();
		m_GFxBindings.Clear();
		m_defaultBindings.Clear();
		m_contextBindings.Clear();
		UpdateInputFeedback();		
	}
	
	event  OnRequestMenu( MenuName : name, MenuState : string)
	{	
		var menuInitData   : W3MenuInitData;
		var currentSubMenu : CR4MenuBase;
		var parentMenuName : name;
		var ignoreSaveData : bool;
		
		currentSubMenu = (CR4MenuBase)GetSubMenu();
		menuInitData = (W3MenuInitData)GetMenuInitData();
		
		if (menuInitData)
		{
			ignoreSaveData = menuInitData.ignoreSaveSystem;
			
			menuInitData.ignoreSaveSystem = false;
		}
		if( currentSubMenu && currentSubMenu.GetMenuName() == MenuName )
		{
			parentMenuName = GetMenuParentName(MenuName);
			if ( MenuState != NameToString( GetSavedMenuFromParentName( parentMenuName ) ) )
			{
				MenuName = GetSavedMenuFromParentName( parentMenuName );
			}
			
			UISavedData.openedCategories.Clear();
			if( MenuState != "" )
			{
				UISavedData.openedCategories.PushBack( HaxGetPanelStateName(MenuState) );
			}
			m_guiManager.UpdateUISavedData( parentMenuName, UISavedData.openedCategories, MenuName, UISavedData.selectedModule );
				
			if( MenuState != "" )
			{
				currentSubMenu.SetMenuState(HaxGetPanelStateName(MenuState));
				OnPlaySoundEvent( "gui_global_submenu_whoosh" );
			}
		}
		else
		{
			if (currentSubMenu)
			{
				OnPlaySoundEvent( "gui_global_submenu_whoosh" );
			}
			else
			{
				OnPlaySoundEvent( "gui_global_panel_open" );
			}
			
			parentMenuName = GetMenuParentName(MenuName);
			
			if( MenuName == parentMenuName) 
			{
				if (!ignoreSaveData)
				{
					MenuName = GetSavedMenuFromParentName( parentMenuName );
				}
				if( MenuName == parentMenuName )
				{
					MenuName = GetFirstChildMenuName( parentMenuName );
				}
			}
			
			
			
				
			
			
			if( menuInitData )
			{
				menuInitData.setDefaultState(HaxGetPanelStateName(MenuState));
				m_lastMenuName = MenuName;
				RequestSubMenu( MenuName, menuInitData );
			}
			else
			{
				if( !GetMenuInitData() && MenuState != "" && MenuState != "None" )
				{
					menuInitData = new W3MenuInitData in this;
					menuInitData.setDefaultState(HaxGetPanelStateName(MenuState));
					m_lastMenuName = MenuName;
					RequestSubMenu( MenuName, menuInitData );
				}
				else
				{
					m_lastMenuName = MenuName;
					RequestSubMenu( MenuName, GetMenuInitData());
				}
			}
			
			m_fxLockOpenTabNavigation.InvokeSelfOneArg(FlashArgBool(true));
			
			theGame.GetTutorialSystem().uiHandler.OnClosingMenu(GetMenuName());
			
			UISavedData.openedCategories.Clear();
			if( MenuState != "" && MenuState != "None" )
			{				
				UISavedData.openedCategories.PushBack( HaxGetPanelStateName(MenuState) );
			}
			
			if( MenuName != parentMenuName ) 
			{
				m_fxSelectSubMenuTab.InvokeSelfTwoArgs(FlashArgUInt(NameToFlashUInt(MenuName)), FlashArgString(MenuState));
			}
			
			m_guiManager.UpdateUISavedData( GetMenuParentName(parentMenuName), UISavedData.openedCategories, MenuName, UISavedData.selectedModule );
		}
		m_GFxBindings.Clear();
	}
	
	public function ChildMenuConfigured() : void
	{
		m_fxLockOpenTabNavigation.InvokeSelfOneArg(FlashArgBool(false));
		m_fxOnChildMenuConfigured.InvokeSelf();
	}
	
	public function SetMenuBackground()
	{
	   	var worldPath : string;
	   	var imagePath: string;
		
		worldPath = theGame.GetWorld().GetDepotPath();
		switch( worldPath )
		{
				case "levels\novigrad\novigrad.w2w":
					imagePath = "img://icons/menubackground/panorama_novigrad.png";
					break;
				case "levels\skellige\skellige.w2w":
					imagePath = "img://icons/menubackground/panorama_skellige.png";
					break;
				case "levels\kaer_morhen\kaer_morhen.w2w":
					imagePath = "img://icons/menubackground/panorama_kaer_morhen.png";
					break;
				case "levels\prolog_village\prolog_village.w2w":
					imagePath = "img://icons/menubackground/panorama_prolog_village.png";
					break;
				case "levels\wyzima_castle\wyzima_castle.w2w":
					imagePath = "img://icons/menubackground/panorama_wyzima_castle.png";
					break;
				case "levels\island_of_mist\island_of_mist.w2w":
					imagePath = "img://icons/menubackground/panorama_island_of_mist.png";
					break;
				case "levels\the_spiral\spiral.w2w":
					imagePath = "img://icons/menubackground/panorama_spiral.png";
					break;
				case "levels\prolog_village_winter\prolog_village.w2w":
					imagePath = "img://icons/menubackground/panorama_prologue_snow.png";
					break;
				case "dlc\bob\data\levels\bob\bob.w2w":
					imagePath = "img://icons/menubackground/panorama_toussaint.png";
					break;
		}
		if( imagePath != "" )
		{
			m_fxUpdateMenuBackgroundImage.InvokeSelfOneArg( FlashArgString( imagePath ) );
		}
	}

	function HaxGetPanelStateName( stateName : string ) : name
	{
		switch(stateName)
		{
			case "CharacterInventory" :
				return 'CharacterInventory';
			case "HorseInventory" :
				return 'HorseInventory';
			case "GlobalMap" :
				return 'GlobalMap';
			case "FastTravel" :
				return 'FastTravel';
			case "Objectives" :
				return 'Objectives';
			case "Sockets" :
				return 'Sockets';
			case "Repair" :
				return 'Repair';
			case "Disassemble" :
				return 'Disassemble';
			case "AddSockets":
				return 'AddSockets';
		}
		return '';
	}

	

	event  OnSwipe( swipe : int )
	{
		var subMenu : CR4MenuBase;

		LogChannel( 'Gui', "CR4CommonMenu::OnSwipe " + swipe );

		if ( swipe == 0 ) 
		{
			
			GoPriorMenu();
		}
		else if ( swipe == 1 ) 
		{
			
			GoNextMenu();
		}
		else if ( swipe == 3 ) 
		{
			
			
			subMenu = (CR4MenuBase)GetSubMenu();
			if ( subMenu )
			{
				subMenu.OnCloseMenu();
			}
		}
	}
	
	event  OnInputHandled(NavCode:string, KeyCode:int, ActionId:int)
	{
		LogChannel('GFX', "OnInputHandled, NavCode: "+NavCode+"; actionId: "+ActionId);
		if (m_contextManager && !m_contextInputBlocked)
		{
			m_contextManager.HandleUserInput(NavCode, ActionId);
		}
	}
	
	public function SetMenuNavigationEnabled(enabled:bool) : void
	{
		m_flashValueStorage.SetFlashBool( "common.input.navigation.enabled", enabled );
	}
	
	public function UpdateTutorialRestruction():void
	{
		CheckTutorialRestrictions();
		SetupMenu();
	}
	
	
	private function DefineMenuStructure() : void
	{
		var curMenuItem 	: SMenuTab;
		var curMenuSubItems : SMenuTab;
		
		m_menuData.Clear();
		if (!isCiri)
		{
			DefineMenuItem('GlossaryParent', "panel_title_glossary"); 
				DefineMenuItem('GlossaryBestiaryMenu', "panel_title_glossary_bestiary",'GlossaryParent');
				
				
				
				
				
				DefineMenuItem('GlossaryTutorialsMenu', "panel_title_glossary_tutorials",'GlossaryParent');
				DefineMenuItem('GlossaryEncyclopediaMenu', "panel_title_glossary_dictionary",'GlossaryParent');
				DefineMenuItem('GlossaryBooksMenu', "books_panel_title",'GlossaryParent');
				DefineMenuItem('CraftingMenu', "panel_title_crafting", 'GlossaryParent');
				
			DefineMenuItem('AlchemyMenu', "panel_title_alchemy", '');
			
			
			DefineMenuItem('InventoryMenu', "panel_inventory", '', 'CharacterInventory');
		}
		
		
		DefineMenuItem('MapMenu', "panel_title_fullmap", '', 'GlobalMap');
			
			
		
		if (!isCiri)
		{
			DefineMenuItem('JournalQuestMenu', "panel_title_journal_quest", '');
			
				
			DefineMenuItem('CharacterMenu', "panel_title_character", '');
			
			DefineMenuItem('MeditationClockMenu', "panel_title_meditation", '');
				
				
				
				
				
		}
			
			
		CheckTutorialRestrictions();
	}
	
	private function DisableNotAllowedTabs()
	{
		if( !thePlayer.IsActionAllowed( EIAB_OpenGlossary ))
		{
			SetMenuTabeEnable( 'GlossaryParent',	false );
		}
		if( !thePlayer.IsActionAllowed( EIAB_OpenJournal ))
		{
			SetMenuTabeEnable( 'JournalQuestMenu',		false );
		}
		if( !thePlayer.IsActionAllowed( EIAB_OpenMap ) && !isCiri) 
		{
			SetMenuTabeEnable( 'MapMenu', false, 'GlobalMap' );
		}
		if( !thePlayer.IsActionAllowed( EIAB_OpenInventory ))
		{
			SetMenuTabeEnable( 'InventoryMenu',	false, 'CharacterInventory' );				
		}	
		if( !thePlayer.IsActionAllowed( EIAB_OpenAlchemy ))
		{
			SetMenuTabeEnable( 'AlchemyMenu',	false );				
		}	
		if( !thePlayer.IsActionAllowed( EIAB_OpenCharacterPanel ))
		{
			SetMenuTabeEnable( 'CharacterMenu',	false );				
		}		
		if( !thePlayer.IsActionAllowed( EIAB_OpenPreparation ))
		{
			SetMenuTabeEnable( 'PreparationMenu',	false );				
		}
		if( !thePlayer.IsActionAllowed( EIAB_OpenMeditation ) && !GetIsPlayerMeditatingInBed() )
		{
			SetMenuTabeEnable( 'MeditationClockMenu',	false );				
		}
		
	}
	
	public function ActionBlockStateChange(action:EInputActionBlock, blocked:bool) : void
	{
		var tabName:name;
		var subTabName:name;
		
		if( action == EIAB_OpenGlossary )
		{
			SetMenuTabeEnable( 'GlossaryParent', blocked );
			tabName = 'GlossaryParent';
			subTabName = '';
		}
		if( action == EIAB_OpenJournal )
		{
			SetMenuTabeEnable( 'JournalQuestMenu', blocked );
			tabName = 'JournalQuestMenu';
			subTabName = '';
		}
		if( action ==  EIAB_OpenMap )
		{
			SetMenuTabeEnable( 'MapMenu', blocked, 'GlobalMap' );
			tabName = 'MapMenu';
			subTabName = 'GlobalMap';
		}
		if( action == EIAB_OpenInventory )
		{
			SetMenuTabeEnable( 'InventoryMenu',	blocked, 'CharacterInventory' );
			tabName = 'InventoryMenu';
			subTabName = 'CharacterInventory';
		}	
		if( action == EIAB_OpenAlchemy )
		{
			SetMenuTabeEnable( 'AlchemyMenu', blocked );
			tabName = 'AlchemyMenu';
			subTabName = '';
		}	
		if( action == EIAB_OpenCharacterPanel )
		{
			SetMenuTabeEnable( 'CharacterMenu',	blocked );
			tabName = 'CharacterMenu';
			subTabName = '';
		}		
		if( action == EIAB_OpenPreparation )
		{
			SetMenuTabeEnable( 'PreparationMenu', blocked );
			tabName = 'PreparationMenu';
			subTabName = '';
		}
		if( action == EIAB_OpenMeditation )
		{
			SetMenuTabeEnable( 'MeditationClockMenu', blocked );
			tabName = 'MeditationClockMenu';
			subTabName = '';
		}
		
		m_fxUpdateTabEnabled.InvokeSelfThreeArgs(FlashArgUInt(NameToFlashUInt(tabName)), FlashArgString(subTabName), FlashArgBool(!blocked));
	}
	
	private function CheckTutorialRestrictions():void 
	{
		var allowedMenus:array<name>;
		var tutorialMgr : CR4TutorialSystem;
		var restrictionEnabled:bool;
		var curRestriction:bool;
		var i, len:int;
		
		tutorialMgr = theGame.GetTutorialSystem();
		if(tutorialMgr && tutorialMgr.IsRunning())
		{
			restrictionEnabled = tutorialMgr.IsMenuRestrictionsEnable();
			allowedMenus = tutorialMgr.GetAllowedMenuList();
			len = m_menuData.Size();
			for (i = 0; i < len; i+=1)
			{
				curRestriction = restrictionEnabled && !allowedMenus.Contains(m_menuData[i].MenuName);
				m_menuData[i].Restricted = curRestriction;
			}
		}
	}

	private function DefineSceneMenuStructure() : void
	{
		var curMenuItem 	: SMenuTab;
		var curMenuSubItems : SMenuTab;
		
		m_menuData.Clear();
		if( isShopAvailable )
		{
			DefineMenuItem('InventoryMenu', "panel_title_shop");
		}
		if ( isAlchemyAvailable )
		{
			DefineMenuItem('AlchemyMenu', "panel_title_alchemy", '');
		}
		if( isCraftingAvailable )
		{
			DefineMenuItem('CraftingParent', "panel_title_crafting");
			DefineMenuItem('CraftingMenu', "panel_title_crafting", 'CraftingParent');
			
			DefineMenuItem('BlacksmithMenu', "panel_title_blacksmith_repair", 'CraftingParent', 'Repair');
			DefineMenuItem('BlacksmithMenu', "panel_title_blacksmith_sockets", 'CraftingParent', 'Sockets');
			DefineMenuItem('BlacksmithMenu', "panel_title_blacksmith_disassamble", 'CraftingParent', 'Disassemble');
		}
		if ( isEnchantingAvailable )
		{
			DefineMenuItem('EnchantingParent', "panel_title_enchanting");
			DefineMenuItem('EnchantingMenu', "panel_title_enchanting" ,'EnchantingParent');
			DefineMenuItem('BlacksmithMenu', "panel_title_blacksmith_add_sockets", 'EnchantingParent', 'AddSockets');
		}
	}
	
	private function GetInitGameplayEntity():IScriptable
	{
		var l_obj      : IScriptable;
		var l_entity   : IScriptable;
		var l_initData : W3InventoryInitData;
		
		l_obj = GetMenuInitData();
		l_initData = (W3InventoryInitData)l_obj;
		if (l_initData)
		{
			l_entity = (IScriptable)l_initData.containerNPC;
		}
		else
		{
			l_entity = l_obj;
		}
		return l_entity;
	}
	
	private function AddMerchantTagIfMissing_HACK():void 
	{
		var l_entity : W3MerchantNPC;
		var shopInventory : CInventoryComponent;
		
		l_entity = (W3MerchantNPC)GetInitGameplayEntity();
		
		if (l_entity && !l_entity.HasTag('Merchant'))
		{
			shopInventory = l_entity.GetInventory();
			if (shopInventory && !shopInventory.IsEmpty())
			{
				l_entity.AddTag('Merchant');
			}
		}
	}
	
	private function CheckNpcTags():void
	{
		var l_npc : W3MerchantNPC;
		var l_entity : CGameplayEntity;
		var l_component : W3CraftsmanComponent;
		var invComponent : CInventoryComponent;
		
		l_entity = (CGameplayEntity)GetInitGameplayEntity();
		
		if( l_entity )
		{
			isInNpcContext = true;
			
			isCraftingAvailable = false;
			
			l_npc = (W3MerchantNPC)l_entity;
			if (l_npc && !l_npc.IsCraftingDisabled() )
			{
				l_component = (W3CraftsmanComponent)l_npc.GetComponentByClassName('W3CraftsmanComponent');
				if ( l_component)
				{
					isCraftingAvailable = true;
				}
			}
			
			isRepairAvailable = l_entity.HasTag('Armorer') || l_entity.HasTag('Blacksmith');
			isEnchantingAvailable = l_entity.HasTag('type_enchanter');
			
			invComponent = l_entity.GetInventory();
			
			if (invComponent)
			{
				isShopAvailable = isShopAvailable || invComponent.HasTag('Merchant');
				isAlchemyAvailable = isAlchemyAvailable || invComponent.HasTag('type_herbalist') || invComponent.HasTag('type_alchemist');
				isEnchantingAvailable = isEnchantingAvailable || invComponent.HasTag('type_enchanter');
			}
			
			isShopAvailable = isShopAvailable || l_entity.HasTag('Merchant') || isRepairAvailable || isEnchantingAvailable;
			
			
			
		}
		else
		{
			isInNpcContext = false;
		}
	}
	
	private function DefineMenuItem(itemName:name, itemLabel:string, optional parentMenuItem:name, optional menuState:name) : void
	{
		var newMenuItem 	: SMenuTab;

		newMenuItem.MenuName = itemName;
		newMenuItem.MenuLabel = itemLabel;
		newMenuItem.Enabled = true;
		newMenuItem.Visible = true;
		newMenuItem.MenuState = menuState;
		
		newMenuItem.ParentMenu = parentMenuItem;
		m_menuData.PushBack(newMenuItem);
	}
	
	private function SetupMenu() : void
	{
		var l_flashSubArray   : CScriptedFlashArray;
		
		l_flashSubArray = m_flashValueStorage.CreateTempFlashArray();
		GetGFxMenuStruct(l_flashSubArray);
		
		m_flashValueStorage.SetFlashArray( "panel.main.setup", l_flashSubArray);
		OnRefreshHubInfo(false);
	}
	
	private function GetGFxMenuStruct(out StructGFx : CScriptedFlashArray) : void
	{
		var i, j : int;
		var subLen : int;
		var l_flashObject     : CScriptedFlashObject;
		var l_flashSubObject  : CScriptedFlashObject;
		var l_flashSubArray   : CScriptedFlashArray;
		var CurDataItem : SMenuTab;
		var CurSubDataItem : SMenuTab;
		
		for ( i = 0; i < m_menuData.Size(); i += 1 )
		{
			CurDataItem = m_menuData[i];
			
			if (CurDataItem.ParentMenu == '')
			{
				l_flashObject = m_flashValueStorage.CreateTempFlashObject();
				GetGFxMenuItem(CurDataItem, l_flashObject);
				
				
				l_flashSubArray = m_flashValueStorage.CreateTempFlashArray();
				for (j = 0; j < m_menuData.Size(); j+=1)
				{
					CurSubDataItem = m_menuData[j];
					if (CurSubDataItem.ParentMenu == CurDataItem.MenuName)
					{
						l_flashSubObject = m_flashValueStorage.CreateTempFlashObject();
						GetGFxMenuItem(CurSubDataItem, l_flashSubObject);
						l_flashSubArray.PushBackFlashObject(l_flashSubObject);
					}
				}
				subLen = l_flashSubArray.GetLength();
				l_flashObject.SetMemberFlashArray("subItems", l_flashSubArray);
				StructGFx.PushBackFlashObject(l_flashObject);
			}
		}
	}

	private function GetGFxMenuItem(MenuItemData:SMenuTab, out GFxObjectData:CScriptedFlashObject):void
	{
		GFxObjectData.SetMemberFlashUInt("id", NameToFlashUInt(MenuItemData.MenuName));
		GFxObjectData.SetMemberFlashString("name", NameToString(MenuItemData.MenuName)); 
		GFxObjectData.SetMemberFlashString("icon", NameToString(MenuItemData.MenuName)); 
		GFxObjectData.SetMemberFlashString("label", GetLocStringByKeyExt(MenuItemData.MenuLabel));
		GFxObjectData.SetMemberFlashString("tabDesc", GetLocStringByKeyExt(MenuItemData.MenuLabel + "_desc"));
		GFxObjectData.SetMemberFlashString("tabNewDesc", "Nothing New");
		GFxObjectData.SetMemberFlashBool("visible", MenuItemData.Visible);
		GFxObjectData.SetMemberFlashBool("enabled", MenuItemData.Enabled && !MenuItemData.Restricted);
		GFxObjectData.SetMemberFlashString("state", MenuItemData.MenuState);
	}
	
	
	private function UpdateTabs()
	{
		UpdatePlayerOrens();
		UpdatePlayerLevel();
		UpdateItemsCounter();
	}
	
	public function SetMenuTabVisible(tabName:name, value:bool) : void
	{
		var j : int;
		
		for (j = 0; j < m_menuData.Size(); j+=1)
		{
			if (m_menuData[j].MenuName == tabName)
			{
				m_menuData[j].Visible = value;
			}
		}
	}
	
	public function SetMenuTabeEnable(tabName:name, value:bool, optional stateName:name) : void
	{
		var j : int;
		
		for (j = 0; j < m_menuData.Size(); j+=1)
		{
			if (m_menuData[j].MenuName == tabName && m_menuData[j].MenuState == stateName)
			{
				m_menuData[j].Enabled = value;
			}
		}
	}

	public function SetSingleMenuTabEnabled( tabName:name ) : void
	{
		var j 		   : int;
		var curTab     : SMenuTab;
		var curParent  : name;
		var menuCount  : int;
		
		curParent =  '';
		menuCount = m_menuData.Size();
		
		for( j = 0; j < menuCount; j+=1 )
		{
			curTab = m_menuData[j];
			
			if( curTab.MenuName == tabName )
			{
				curTab.Enabled = true;
				
				if (curTab.ParentMenu != '')
				{
					
					curParent = curTab.ParentMenu;
				}
			}
			else			
			{
				if( curTab.ParentMenu != curParent )
				{
					curTab.Enabled = false;
				}
				else
				{
					curParent = '';
				}
			}
		}
		
		if( curParent != '')
		{
			for( j = 0; j < menuCount; j+=1 )
			{
				curTab = m_menuData[j];
				
				if( curTab.MenuName == curParent )
				{
					curTab.Enabled = true;
					break;
				}
			}
		}
	}

	public function GoNextMenu() : void
	{
		m_fxNavigateNext.InvokeSelf();
	}

	public function GoPriorMenu() : void
	{
		m_fxNavigatePrior.InvokeSelf();
	}

	public function ShowBackground(value:bool) : void
	{
		m_flashValueStorage.SetFlashBool( "panel.main.background.shows", value); 
	}
	
	public function UpdatePlayerOrens()
	{
		var orens:int;
		orens = thePlayer.GetMoney();
		
		m_fxUpdateMoney.InvokeSelfOneArg(FlashArgNumber(orens));
	}

	public function UpdatePlayerLevel()
	{
		var curLevel:int;
		var curExp:float;
		var levelExp:float;
		var targetExp:float;
		
		curLevel = GetCurrentLevel();
		curExp = GetCurrentExperience();
		levelExp = GetLevelExperience();
		targetExp = GetTargetExperience();
		
		m_fxUpdateLevel.InvokeSelfThreeArgs( FlashArgUInt( curLevel ), FlashArgNumber( curExp - levelExp ), FlashArgNumber( targetExp - levelExp ) );
	}
	
	public function UpdateItemsCounter() : int 
	{
		var encumbrance 	: int;
		var encumbranceMax  : int;
		var _inv : CInventoryComponent;
		var hasHorseUpgrade : bool;
		
		_inv = thePlayer.GetInventory();
		
		encumbrance = (int)GetWitcherPlayer().GetEncumbrance();
		encumbranceMax = (int)GetWitcherPlayer().GetMaxRunEncumbrance(hasHorseUpgrade);
		
		m_fxUpdateWeight.InvokeSelfTwoArgs( FlashArgUInt(encumbrance), FlashArgUInt(encumbranceMax) );
		
		return encumbrance;
	}
	
	private function GetCurrentLevel() : int
	{
		var levelManager : W3LevelManager;
		
		levelManager = GetWitcherPlayer().levelManager;
		
		return levelManager.GetLevel();
	}

	private function GetCurrentExperience() : float
	{
		var levelManager : W3LevelManager;
		
		levelManager = GetWitcherPlayer().levelManager;
		
		return levelManager.GetPointsTotal(EExperiencePoint);;
	}
	
	private function GetLevelExperience() : float
	{
		var levelManager : W3LevelManager;
		
		levelManager = GetWitcherPlayer().levelManager;
		return levelManager.GetTotalExpForCurrLevel();
	}

	private function GetTargetExperience() : float
	{
		var levelManager : W3LevelManager;
		
		levelManager = GetWitcherPlayer().levelManager;
		return levelManager.GetTotalExpForNextLevel();
	}	
	
	public function SetMenuAlpha( value : int ) : void
	{
		m_flashModule.SetAlpha(value);
	}
	
	function CloseMenuRequest():void
	{
		var menu			: CR4MenuBase;
		
		menu = (CR4MenuBase)GetSubMenu();
		if( !menu )
		{
			CloseMenu();
		}
	}
	
	event  OnFailedCreateMenu()
	{
		
		
			m_fxSubMenuClosed.InvokeSelf();
			m_GFxBindings.Clear();
			m_defaultBindings.Clear();
			m_contextBindings.Clear();
			UpdateInputFeedback();
		
	}

	function ChildRequestCloseMenu()
	{
		if (!m_hubEnabled)
		{
			CloseMenu();
		}
		else
		{
			theGame.GetTutorialSystem().uiHandler.OnOpeningMenu(GetMenuName());
		}
		
		m_fxSubMenuClosed.InvokeSelf();
		m_GFxBindings.Clear();
		m_defaultBindings.Clear();
		m_contextBindings.Clear();
		UpdateInputFeedback();
		
		if( m_parentMenu )
		{
			m_parentMenu.ChildRequestCloseMenu();
		}
		OnPlaySoundEvent("gui_global_panel_close");
	}
	
	public function UpdateGFxButtons(gfxButtonsList : array<SKeyBinding>, optional populateData:bool):void
	{
		m_GFxBindings = gfxButtonsList;
		if (populateData)
		{
			UpdateInputFeedback();
		}
	}
	
	public function UpdateDefaultButtons(defaultButtonsList : array<SKeyBinding>, optional populateData:bool):void
	{
		m_defaultBindings = defaultButtonsList;
		if (populateData)
		{
			UpdateInputFeedback();
		}
	}
	
	public function UpdateContextButtons(contextButtonsList : array<SKeyBinding>, optional populateData:bool):void
	{
		m_contextBindings = contextButtonsList;
		if (populateData)
		{
			UpdateInputFeedback();
		}
	}
	
	protected function GatherBindersArray(out resultArray : CScriptedFlashArray, bindersList : array<SKeyBinding>, optional level:int, optional isContextBinding:bool)
	{
		var tempFlashObject	: CScriptedFlashObject;
		var bindingGFxData  : CScriptedFlashObject;
		var curBinding	    : SKeyBinding;
		var bindingsCount   : int;
		var i			    : int;
		
		bindingsCount = bindersList.Size();
		for( i =0; i < bindingsCount; i += 1 )
		{
			curBinding = bindersList[i];
			tempFlashObject = m_flashValueStorage.CreateTempFlashObject();
			
			bindingGFxData = tempFlashObject.CreateFlashObject("red.game.witcher3.data.KeyBindingData");
			bindingGFxData.SetMemberFlashString("gamepad_navEquivalent", curBinding.Gamepad_NavCode );
			bindingGFxData.SetMemberFlashInt("keyboard_keyCode", curBinding.Keyboard_KeyCode );
			bindingGFxData.SetMemberFlashBool( "hasHoldPrefix", curBinding.IsHold );
			if (curBinding.IsLocalized)
			{
				bindingGFxData.SetMemberFlashString("label", curBinding.LocalizationKey );
			}
			else
			{
				bindingGFxData.SetMemberFlashString("label", GetLocStringByKeyExt(curBinding.LocalizationKey) );
			}
			bindingGFxData.SetMemberFlashString("isContextBinding", isContextBinding);
			bindingGFxData.SetMemberFlashInt("level", level);
			
			resultArray.PushBackFlashObject(bindingGFxData);
		}
	}
	
	public function UpdateInputFeedback():void
	{
		var gfxDataList	: CScriptedFlashArray;
		gfxDataList = m_flashValueStorage.CreateTempFlashArray();	
		GatherBindersArray(gfxDataList, m_contextBindings, 2, true);
		GatherBindersArray(gfxDataList, m_GFxBindings, 1);
		GatherBindersArray(gfxDataList, m_defaultBindings, 0);
		m_flashValueStorage.SetFlashArray("common.input.feedback.setup", gfxDataList);
	}
	
	function PlayOpenSoundEvent()
	{
		if (theGame.GetMenuToOpen() == '')
		{
			OnPlaySoundEvent( "gui_global_panel_open" );
		}
	}
	
	event OnPlaySoundEvent( soundName : string )
	{
		var currentSubMenu : CR4MenuBase;
		
		currentSubMenu = (CR4MenuBase)GetSubMenu();
		
		
		if (soundName != "gui_global_highlight" || !currentSubMenu)
		{
			super.OnPlaySoundEvent( soundName );
		}
	}
	
	event  OnOpenSubPanel(menuName:name)
	{
		
		if(theGame.GetTutorialSystem() && theGame.GetTutorialSystem().IsRunning())
		{
			theGame.GetTutorialSystem().uiHandler.OnClosingMenu(GetMenuName());
			theGame.GetTutorialSystem().uiHandler.OnOpeningMenu(menuName);
		}
			
		LogChannel( 'Gui', "OnOpenSubPanel " + menuName );
	}
	
	event  OnCloseSubPanel(menuName:name)
	{
		
		if(theGame.GetTutorialSystem() && theGame.GetTutorialSystem().IsRunning())
		{
			theGame.GetTutorialSystem().uiHandler.OnClosingMenu(menuName);
			theGame.GetTutorialSystem().uiHandler.OnOpeningMenu(GetMenuName());
		}
	
		LogChannel( 'Gui', "OnCloseSubPanel");
	}
	
	event  OnControllerChanged(isGamepad:bool)
	{
		
	}
	
	
	public function SetMeditationMode(value:bool):void
	{	
		if (m_mode_meditation != value)
		{
			m_mode_meditation = value;
			
			
			
			
			
			if (m_mode_meditation)
			{
				m_had_meditation = true;
			}
		}
	}
	
	private function StopMeditation()
	{
		var medd : W3PlayerWitcherStateMeditation;
		var waitt : W3PlayerWitcherStateMeditationWaiting;
		
		if (m_had_meditation)
		{		
			SetMeditationMode(false);
			if(thePlayer.GetCurrentStateName() == 'MeditationWaiting')
			{
				waitt = (W3PlayerWitcherStateMeditationWaiting)thePlayer.GetCurrentState();
				if(waitt)
				{
					waitt.StopRequested();
				}
			}
			else
			{
				medd = (W3PlayerWitcherStateMeditation)GetWitcherPlayer().GetCurrentState();
				if(medd)
				{
					medd.StopRequested();
				}
			}
		}
	}
	
	
		
	private function SendLastItemInfoData() : void
	{
		var l_flashSubArray   : CScriptedFlashArray;
		
		l_flashSubArray = m_flashValueStorage.CreateTempFlashArray();
		GetNewItemsGFxMenuStruct(l_flashSubArray);
		
		m_flashValueStorage.SetFlashArray( "panel.main.panelinfo.newestitems", l_flashSubArray);
	}
		
	private function SendQuestsInfoData() : void
	{
		var l_flashSubArray   : CScriptedFlashArray;
		
		l_flashSubArray = m_flashValueStorage.CreateTempFlashArray();
		GetTrackedQuestGFxMenuStruct(l_flashSubArray);
		
		m_flashValueStorage.SetFlashArray( "panel.main.panelinfo.quests", l_flashSubArray);
	}	
	
	private function SendGlossaryInfoData() : void
	{
		var l_flashSubArray   : CScriptedFlashArray;
		
		l_flashSubArray = m_flashValueStorage.CreateTempFlashArray();
		GetGlossaryGFxMenuStruct(l_flashSubArray);
		
		m_flashValueStorage.SetFlashArray( "panel.main.panelinfo.glossary", l_flashSubArray);
	}	

	private function SendAlchemyInfoData() : void
	{
		var l_flashSubArray   : CScriptedFlashArray;
		
		l_flashSubArray = m_flashValueStorage.CreateTempFlashArray();
		GetAlchemyGFxMenuStruct(l_flashSubArray);
		
		m_flashValueStorage.SetFlashArray( "panel.main.panelinfo.alchemy", l_flashSubArray);
	}

	private function SendSkillsInfoData() : void
	{
		var l_flashSubArray   : CScriptedFlashArray;
		
		l_flashSubArray = m_flashValueStorage.CreateTempFlashArray();
		GetSkillGFxMenuStruct(l_flashSubArray);
		
		m_flashValueStorage.SetFlashArray( "panel.main.panelinfo.skills", l_flashSubArray);
	}

	private function SendMappinInfoData() : void
	{
		var l_flashSubArray   : CScriptedFlashArray;
		
		l_flashSubArray = m_flashValueStorage.CreateTempFlashArray();
		GetMappinGFxMenuStruct(l_flashSubArray);
		
		m_flashValueStorage.SetFlashArray( "panel.main.panelinfo.map", l_flashSubArray);
	}
	
	private function GetNewItemsGFxMenuStruct( out StructGFx : CScriptedFlashArray ) : void
	{
		var i : int;
		var l_flashObject     : CScriptedFlashObject;
		var newestItems 	  : array < SItemUniqueId >;
		var _inv			  : CInventoryComponent;
		var item			  : SItemUniqueId;
		var iconPath		  : string;
		var itemsDisplayed	  : int;
		var m_guiManager 	  : CR4GuiManager;	
		
		_inv = thePlayer.GetInventory();
		m_guiManager = theGame.GetGuiManager();
		
		if( !isCraftingAvailable && !isRepairAvailable && !isShopAvailable )
		{
			newestItems = m_guiManager.GetNewestItems();
		}
		for ( i = 0; i < newestItems.Size(); i += 1 )
		{	
			item = newestItems[i];		 
			if( _inv.IsIdValid(item) && !( _inv.ItemHasTag( item, 'NoShow' )) )
			{
				l_flashObject = m_flashValueStorage.CreateTempFlashObject();
				
				iconPath = _inv.GetItemIconPathByUniqueID( item );
				l_flashObject.SetMemberFlashString( "iconName", iconPath );
				l_flashObject.SetMemberFlashString( "category", GetLocStringByKeyExt( "item_category_" + _inv.GetItemCategory( item ) ) + " " + GetItemRarityDescriptionFromInt( _inv.GetItemQuality(item) ) );
				l_flashObject.SetMemberFlashString( "itemName", GetLocStringByKeyExt( _inv.GetItemLocalizedNameByUniqueID( item ) ) );
				StructGFx.PushBackFlashObject(l_flashObject);
			}
		}
		m_fxSetShopInventory.InvokeSelfOneArg(FlashArgBool( isShopAvailable || isCraftingAvailable ));
	}
	
	private function GetTrackedQuestGFxMenuStruct( out StructGFx : CScriptedFlashArray ) : void
	{
		var l_flashObject     : CScriptedFlashObject;
		var curTrackedQuest : CJournalQuest;
		var curHighlightedObjective : CJournalQuestObjective;
		
		curTrackedQuest = theGame.GetJournalManager().GetTrackedQuest();
		curHighlightedObjective = theGame.GetJournalManager().GetHighlightedObjective();
		
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		if( curTrackedQuest )
		{
			l_flashObject.SetMemberFlashString( "questName", GetLocStringById( curTrackedQuest.GetTitleStringId() ));
			l_flashObject.SetMemberFlashString( "objectiveName", GetLocStringById( curHighlightedObjective.GetTitleStringId()));
		}
		else
		{
			l_flashObject.SetMemberFlashString( "questName", "");
			l_flashObject.SetMemberFlashString( "objectiveName", "");
		}
		StructGFx.PushBackFlashObject(l_flashObject);
	}	

	private function GetGlossaryGFxMenuStruct( out StructGFx : CScriptedFlashArray ) : void
	{
		var l_flashObject     : CScriptedFlashObject;	
		var m_guiManager 	  : CR4GuiManager;	
		var glossaryEntries   : array < SGlossaryEntry >;
		var i 				  : int;
		var m_definitionsManager	: CDefinitionsManagerAccessor;
		
		m_guiManager = theGame.GetGuiManager();
		glossaryEntries = m_guiManager.GetNewGlossaryEntries();
		for( i = 0; i < glossaryEntries.Size(); i += 1 )
		{
			l_flashObject = m_flashValueStorage.CreateTempFlashObject();
			l_flashObject.SetMemberFlashString( "topText", GetLocStringByKeyExt( glossaryEntries[i].panelName ));
			if( glossaryEntries[i].newEntry )
			{
				l_flashObject.SetMemberFlashString( "bottomText", GetEntryTitle( glossaryEntries[i].newEntry ));
			}
			else
			{
				m_definitionsManager = theGame.GetDefinitionsManager();
				l_flashObject.SetMemberFlashString( "bottomText", GetLocStringByKeyExt( m_definitionsManager.GetItemLocalisationKeyName( glossaryEntries[i].tag ) ));
			}
			StructGFx.PushBackFlashObject(l_flashObject);
		}
	}
	
	private function GetAlchemyGFxMenuStruct( out StructGFx : CScriptedFlashArray ) : void
	{
		var l_flashObject     : CScriptedFlashObject;	
		var m_guiManager 	  : CR4GuiManager;	
		var alchemyEntries   : array < SGlossaryEntry >;
		var i 				  : int;
		var m_definitionsManager	: CDefinitionsManagerAccessor;
		
		m_guiManager = theGame.GetGuiManager();
		alchemyEntries = m_guiManager.GetNewAlchemyEntries();
		for( i = 0; i < alchemyEntries.Size(); i += 1 )
		{
			l_flashObject = m_flashValueStorage.CreateTempFlashObject();
			l_flashObject.SetMemberFlashString( "topText", GetLocStringByKeyExt( alchemyEntries[i].panelName ));
			m_definitionsManager = theGame.GetDefinitionsManager();
			
			
			if(alchemyEntries[i].tag == 'Recipe for Signs Enhancement')
				l_flashObject.SetMemberFlashString( "bottomText", GetLocStringByKeyExt('item_name_signs_enhancement') );				
			else
			
				l_flashObject.SetMemberFlashString( "bottomText", GetLocStringByKeyExt( m_definitionsManager.GetItemLocalisationKeyName( alchemyEntries[i].tag ) ));
							
			StructGFx.PushBackFlashObject(l_flashObject);
		}
	}
	
	function GetEntryTitle( journalBase : CJournalBase ) : string
	{
		var journalCreature : CJournalCreature;
		var journalCharacter : CJournalCharacter;
		var journalGlossary : CJournalGlossary;
		
		journalCreature = (CJournalCreature)journalBase;
		if( journalCreature )
		{
			return GetLocStringById( journalCreature.GetNameStringId() );
		}
		
		journalCharacter = (CJournalCharacter)journalBase;
		if( journalCharacter )
		{
			return GetLocStringById( journalCharacter.GetNameStringId() );
		}	
		
		journalGlossary = (CJournalGlossary)journalBase;
		if( journalGlossary )
		{
			return GetLocStringById( journalGlossary.GetTitleStringId() );
		}
		return "";
	}
		
	private function GetSkillGFxMenuStruct( out StructGFx : CScriptedFlashArray ) : void
	{
		var l_flashObject     : CScriptedFlashObject;	
		var m_guiManager 	  : CR4GuiManager;	
		var skillEntries  	  : array < ESkill >;
		var skillStruct  	  : SSkill;
		var i 				  : int;
		var m_definitionsManager	: CDefinitionsManagerAccessor;
		
		m_guiManager = theGame.GetGuiManager();
		skillEntries = m_guiManager.GetNewSkillsEntries();
		for( i = 0; i < skillEntries.Size(); i += 1 )
		{
			l_flashObject = m_flashValueStorage.CreateTempFlashObject();
			skillStruct = thePlayer.GetPlayerSkill( skillEntries[i] );
			l_flashObject.SetMemberFlashString( "topText", GetLocStringByKeyExt( skillStruct.localisationNameKey ));
			
			l_flashObject.SetMemberFlashString( "bottomText", GetLocStringByKeyExt( SkillPathTypeToLocalisationKey(skillStruct.skillPath)));
			StructGFx.PushBackFlashObject(l_flashObject);
		}
	}

	private function GetMappinGFxMenuStruct( out StructGFx : CScriptedFlashArray ) : void
	{
		var l_flashObject     : CScriptedFlashObject;	
		var m_guiManager 	  : CR4GuiManager;	
		var mappinEntries  	  : array < SMappinEntry >;
		var i 				  : int;
		var m_definitionsManager	: CDefinitionsManagerAccessor;
		
		m_guiManager = theGame.GetGuiManager();
		mappinEntries = m_guiManager.GetNewMappinEntries();
		for( i = 0; i < mappinEntries.Size(); i += 1 )
		{
			l_flashObject = m_flashValueStorage.CreateTempFlashObject();
			
			l_flashObject.SetMemberFlashString( "topText", GetLocStringByKeyExt( StrLower("map_location_"+mappinEntries[i].newMappin) ));
			if( mappinEntries[i].newMappinType != '' )
			{
				l_flashObject.SetMemberFlashString( "bottomText", GetLocStringByKeyExt( StrLower("map_location_"+mappinEntries[i].newMappinType) ) );
				l_flashObject.SetMemberFlashString( "type",  mappinEntries[i].newMappinType );
			}
			else
			{			
				l_flashObject.SetMemberFlashString( "bottomText", "" );
				l_flashObject.SetMemberFlashString( "type",  mappinEntries[i].newMappin );
			}
			StructGFx.PushBackFlashObject(l_flashObject);
		}
	}
	
	event OnRefreshHubInfo( fromAs : bool )
	{
		SendQuestsInfoData();
		SendSkillsInfoData();
		SendLastItemInfoData();
		if( !fromAs ) 
		{
			SendGlossaryInfoData(); 
			SendAlchemyInfoData();
			SendMappinInfoData();
		}
	}
	
	event OnVideoStopped()
	{
		var menuSprite : CScriptedFlashSprite;
		var menuSprite2 : CScriptedFlashSprite;
		var menuStorybook : CR4GlossaryStorybookMenu;	
		menuStorybook = (CR4GlossaryStorybookMenu)GetSubMenu();
		if( menuStorybook.bMovieIsPlaying )
		{	
			menuSprite2 = this.GetMenuFlash();
			menuSprite2.SetVisible(true);
			menuStorybook.SetMovieIsPlaying( false );
			menuStorybook.ShowMenuAgain();
		}
	}
	
	public function SetLockedInHub(value:bool) : void
	{
		m_lockedInHub = value;
		
		m_fxBlockHubClosing.InvokeSelfOneArg( FlashArgBool(value) );
	}
	
	public function SetLockedInMenu(value:bool)
	{
		var childMenu : CR4MenuBase; 
		
		m_lockedInMenu = value;
		
		childMenu = GetLastChild();
		
		if (childMenu)
		{
			childMenu.UpdateRestrictDirectClosing(value);
		}
		
		m_fxBlockMenuClosing.InvokeSelfOneArg( FlashArgBool(value) );
	}
	
	public function IsLockedInHub() : bool
	{
		return m_lockedInHub;
	}
	
	public function IsLockedInMenu() : bool
	{
		return m_lockedInMenu;
	}
	
	protected function fetchCurrentHotkeys() : void
	{
		var outKeys	: array< EInputKey >;
		
		outKeys.Clear();
		theInput.GetPCKeysForAction('PanelInv', outKeys);
		if (outKeys.Size() > 0)
		{
			inventoryHotkey = outKeys[0];
		}
		else
		{
			inventoryHotkey = IK_None;
		}
		
		outKeys.Clear();
		theInput.GetPCKeysForAction('PanelChar', outKeys);
		if (outKeys.Size() > 0)
		{
			characterHotkey = outKeys[0];
		}
		else
		{
			characterHotkey = IK_None;
		}
		
		outKeys.Clear();
		theInput.GetPCKeysForAction('PanelMapPC', outKeys);
		if (outKeys.Size() > 0)
		{
			mapHotkey = outKeys[0];
		}
		else
		{
			mapHotkey = IK_None;
		}	
		
		outKeys.Clear();
		theInput.GetPCKeysForAction('PanelJour', outKeys);
		if (outKeys.Size() > 0)
		{
			journalHotkey = outKeys[0];
		}
		else
		{
			journalHotkey = IK_None;
		}
		
		outKeys.Clear();
		theInput.GetPCKeysForAction('PanelAlch', outKeys);
		if (outKeys.Size() > 0)
		{
			alchemyHotkey = outKeys[0];
		}
		else
		{
			alchemyHotkey = IK_None;
		}
		
		outKeys.Clear();
		theInput.GetPCKeysForAction('PanelBestiary', outKeys);
		if (outKeys.Size() > 0)
		{
			bestiaryHotkey = outKeys[0];
		}
		else
		{
			bestiaryHotkey = IK_None;
		}	
		
		outKeys.Clear();
		theInput.GetPCKeysForAction('PanelGlossary', outKeys);
		if (outKeys.Size() > 0)
		{
			glossaryHotkey = outKeys[0];
		}
		else
		{
			glossaryHotkey = IK_None;
		}
		
		outKeys.Clear();
		theInput.GetPCKeysForAction('PanelMeditation', outKeys);
		if (outKeys.Size() > 0)
		{
			meditationHotkey = outKeys[0];
		}
		else
		{
			meditationHotkey = IK_None;
		}
		
		outKeys.Clear();
		theInput.GetPCKeysForAction('PanelCrafting', outKeys);
		if (outKeys.Size() > 0)
		{
			craftingHotkey = outKeys[0];
		}
		else
		{
			craftingHotkey = IK_None;
		}
	}
	
	
	
	event  OnHotkeyTriggered(keyCode:EInputKey)
	{
		var childMenu : CR4MenuBase;
		var invMenu : CR4InventoryMenu;
		var charMenu : CR4CharacterMenu;
		var mapMenu : CR4MapMenu;
		var jourMenu : CR4JournalQuestMenu;
		var alchMenu : CR4AlchemyMenu;
		var bestMenu : CR4GlossaryBestiaryMenu;
		var glossMenu : CR4GlossaryEncyclopediaMenu;
		var medMenu : CR4MeditationClockMenu;
		var craftMenu : CR4CraftingMenu;
		
		childMenu = GetLastChild();
		
		if (childMenu && !IsLockedInHub() && !IsLockedInMenu())
		{
			if (keyCode == inventoryHotkey && theGame.GameplayFactsQuerySum("shopMode") == 0)
			{
				invMenu = (CR4InventoryMenu)childMenu;
				if (invMenu)
				{
					invMenu.CloseMenu();
					CloseMenu();
				}
				else if (HasMenuWithStateDefined('InventoryMenu', 'CharacterInventory') && thePlayer.IsActionAllowed( EIAB_OpenInventory ))
				{
					m_fxSelectTab.InvokeSelfTwoArgs(FlashArgUInt(NameToFlashUInt('InventoryMenu')), FlashArgString('CharacterInventory'));
					m_fxEnterCurrentTab.InvokeSelf();
				}
			}
			else if (keyCode == characterHotkey)
			{
				charMenu = (CR4CharacterMenu)childMenu;
				
				if (charMenu)
				{
					charMenu.CloseMenu();
					CloseMenu();
				}
				else if (HasMenuDefined('CharacterMenu') && thePlayer.IsActionAllowed( EIAB_OpenCharacterPanel ))
				{
					m_fxSelectTab.InvokeSelfTwoArgs(FlashArgUInt(NameToFlashUInt('CharacterMenu')), FlashArgString(''));
					m_fxEnterCurrentTab.InvokeSelf();
				}
			}
			else if (keyCode == mapHotkey)
			{
				mapMenu = (CR4MapMenu)childMenu;
				
				if (mapMenu)
				{
					mapMenu.CloseMenu();
					CloseMenu();
				}
				else if (HasMenuWithStateDefined('MapMenu', 'GlobalMap') && thePlayer.IsActionAllowed( EIAB_OpenMap ))
				{
					m_fxSelectTab.InvokeSelfTwoArgs(FlashArgUInt(NameToFlashUInt('MapMenu')), FlashArgString('GlobalMap'));
					m_fxEnterCurrentTab.InvokeSelf();
				}
			}
			else if (keyCode == journalHotkey)
			{
				jourMenu = (CR4JournalQuestMenu)childMenu;
				
				if (jourMenu)
				{
					jourMenu.CloseMenu();
					CloseMenu();
				}
				else if (HasMenuDefined('JournalQuestMenu') && thePlayer.IsActionAllowed( EIAB_OpenJournal ))
				{
					m_fxSelectTab.InvokeSelfTwoArgs(FlashArgUInt(NameToFlashUInt('JournalQuestMenu')), FlashArgString(''));
					m_fxEnterCurrentTab.InvokeSelf();
				}
			}
			else if (keyCode == alchemyHotkey)
			{
				alchMenu = (CR4AlchemyMenu)childMenu;
				
				if (alchMenu)
				{
					alchMenu.CloseMenu();
					CloseMenu();
				}
				else if (HasMenuDefined('AlchemyMenu') && thePlayer.IsActionAllowed( EIAB_OpenAlchemy ))
				{
					m_fxSelectTab.InvokeSelfTwoArgs(FlashArgUInt(NameToFlashUInt('AlchemyMenu')), FlashArgString(''));
					m_fxEnterCurrentTab.InvokeSelf();
				}
			}
			else if (keyCode == bestiaryHotkey)
			{
				bestMenu = (CR4GlossaryBestiaryMenu)childMenu;
				
				if (bestMenu)
				{
					bestMenu.CloseMenu();
					CloseMenu();
				}
				else if (HasMenuDefined('GlossaryBestiaryMenu') && thePlayer.IsActionAllowed( EIAB_OpenGlossary ))
				{
					m_fxSelectTab.InvokeSelfTwoArgs(FlashArgUInt(NameToFlashUInt('GlossaryBestiaryMenu')), FlashArgString(''));
					m_fxEnterCurrentTab.InvokeSelf();
				}
			}
			else if (keyCode == glossaryHotkey)
			{
				glossMenu = (CR4GlossaryEncyclopediaMenu)childMenu;
				
				if (glossMenu)
				{
					glossMenu.CloseMenu();
					CloseMenu();
				}
				else if (HasMenuDefined('GlossaryEncyclopediaMenu') && thePlayer.IsActionAllowed( EIAB_OpenGlossary ))
				{
					m_fxSelectTab.InvokeSelfTwoArgs(FlashArgUInt(NameToFlashUInt('GlossaryEncyclopediaMenu')), FlashArgString(''));
					m_fxEnterCurrentTab.InvokeSelf();
				}
			}
			else if (keyCode == meditationHotkey)
			{
				medMenu = (CR4MeditationClockMenu)childMenu;
				
				if (medMenu)
				{
					medMenu.CloseMenu();
					CloseMenu();
				}
				else if (HasMenuDefined('MeditationClockMenu') && thePlayer.IsActionAllowed( EIAB_OpenMeditation ))
				{
					m_fxSelectTab.InvokeSelfTwoArgs(FlashArgUInt(NameToFlashUInt('MeditationClockMenu')), FlashArgString(''));
					m_fxEnterCurrentTab.InvokeSelf();
				}
			}
			else if (keyCode == craftingHotkey && theGame.GameplayFactsQuerySum("shopMode") == 0)
			{
				craftMenu = (CR4CraftingMenu)childMenu;
				
				if (craftMenu)
				{
					craftMenu.CloseMenu();
					CloseMenu();
				}
				else if (HasMenuDefined('CraftingMenu') && thePlayer.IsActionAllowed( EIAB_OpenGlossary ))
				{
					m_fxSelectTab.InvokeSelfTwoArgs(FlashArgUInt(NameToFlashUInt('CraftingMenu')), FlashArgString(''));
					m_fxEnterCurrentTab.InvokeSelf();
				}
			}
		}
	}
	
	event OnCloseMenu()
	{
		if (!m_lockedInHub)
		{
			CloseMenu();
		}
	}
}

exec function testLockInHub(locked:bool)
{
	var guiManager : CR4GuiManager;
	var rootMenu : CR4CommonMenu;
		
	guiManager = theGame.GetGuiManager();
			
	if (guiManager && guiManager.IsAnyMenu())
	{
		rootMenu = (CR4CommonMenu)guiManager.GetRootMenu();
		
		if (rootMenu)
		{
			rootMenu.SetLockedInHub(locked);
		}
	}
}

exec function testLockInMenu(locked:bool)
{
	var guiManager : CR4GuiManager;
	var rootMenu : CR4CommonMenu;
		
	guiManager = theGame.GetGuiManager();
			
	if (guiManager && guiManager.IsAnyMenu())
	{
		rootMenu = (CR4CommonMenu)guiManager.GetRootMenu();
		
		if (rootMenu)
		{
			rootMenu.SetLockedInMenu(locked);
		}
	}
}