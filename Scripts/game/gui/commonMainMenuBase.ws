/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4CommonMainMenuBase extends CR4MenuBase
{
	private var m_menuData 	  : array< SMenuTab >;
	
	private var m_fxSetMovieData : CScriptedFlashFunction;
	
	public var importSelected : bool;
	public var reopenRequested	: bool; default reopenRequested = false;
	
	protected var currentMenuName : name;
	
	event  OnConfigUI()
	{
		var menuName : name;
		var inGameConfigWrapper	: CInGameConfigWrapper;
		var overlayPopupRef  : CR4OverlayPopup;
		var menuType : int;
		
		super.OnConfigUI();
		m_flashModule = GetMenuFlash();
		theGame.GetGuiManager().OnEnteredMainMenu();
		
		
		
		
		
		
		
		{
			menuName = 'IngameMenu';
		}
		
		overlayPopupRef = (CR4OverlayPopup)theGame.GetGuiManager().GetPopup('OverlayPopup');
		if (!overlayPopupRef)
		{
			theGame.RequestPopup( 'OverlayPopup' );
		}
		
		theGame.GetGuiManager().RequestMouseCursor(true);
		
		if (theInput.LastUsedPCInput())
		{
			theGame.MoveMouseTo(0.17, 0.36);
		}
		
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		inGameConfigWrapper.SetVarValue('Hidden', 'HasSetup', "true");
		theGame.SaveUserSettings();
		
		SetupMenu();
		OnRequestSubMenu( menuName, GetMenuInitData() );
		
		theGame.FadeInAsync(300); 
		
		theInput.StoreContext( 'Exploration' );
		
		theGame.ReleaseNoSaveLock(theGame.deathSaveLockId);
		
		
		updateHudConfigs();
		
		theSound.SoundEvent( "play_music_main_menu" );
		
		menuType = theGame.GetChosenMainMenuType();
		switch ( menuType )
		{
			case 1:
				theSound.SoundEvent( "mus_main_menu_theme_ep1" );
				break;
			case 2:
				theSound.SoundEvent( "play_music_toussaint" );
				theSound.SoundEvent( "mus_main_menu_ep2" );
				break;
			case 0:
			default:
				theSound.SoundEvent( "mus_main_menu_theme" );
				break;
		}
	}
	
	private function updateHudConfigs():void
	{
		var hud : CR4ScriptedHud;
		hud = (CR4ScriptedHud)theGame.GetHud();
		
		if (hud)
		{
			hud.UpdateHudConfigs();
		}
	}
	
	function GetCurrentBackgroundMovie() : string
	{
		return "mainmenu.usm"; 
	}
	
	event  OnClosingMenu()
	{
		if (m_configUICalled)
		{
			theInput.RestoreContext( 'Exploration', true );
		}
		
		theGame.GetGuiManager().RequestMouseCursor(false);
		
		super.OnClosingMenu();
	}

	function OnRequestSubMenu( menuName: name, optional initData : IScriptable )
	{
		RequestSubMenu( menuName, initData );
		currentMenuName = menuName;
	}

	

	event  OnSwipe( swipe : int )
	{
	}

	private function DefineMenuItem(itemName:name, itemLabel:string, optional parentMenuItem:name) : void
	{
		var newMenuItem 	: SMenuTab;

		newMenuItem.MenuName = itemName;
		newMenuItem.MenuLabel = itemLabel;
		newMenuItem.Enabled = true;
		newMenuItem.Visible = true;
		
		newMenuItem.ParentMenu = parentMenuItem;
		m_menuData.PushBack(newMenuItem);
	}
	
	private function SetupMenu() : void
	{
		
	}

	event  OnCloseMenu()
	{
		var menu			: CR4MenuBase;
		
		menu = (CR4MenuBase)GetSubMenu();
		if( menu )
		{
			menu.CloseMenu();
		}
		CloseMenu();
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
	
	function ChildRequestCloseMenu()
	{
		var menu			: CR4MenuBase;
		var menuToOpen		: name;
		
		if (reopenRequested)
		{
			reopenRequested = false;
			OnRequestSubMenu( 'IngameMenu', GetMenuInitData() );
		}
		else
		{
			menu = (CR4MenuBase)GetSubMenu();
		
			if( menu )
			{
				
				menuToOpen = GetParentMenuName(currentMenuName);
				if( menuToOpen )
				{
					OnRequestSubMenu( menuToOpen, GetMenuInitData() );
				}
				else
				{
					CloseMenu();
				}
			}
		}
	}
	
	function GetParentMenuName( menu : name ) : name
	{
		var i : int;
		var parentName : name;
		var CurDataItem : SMenuTab;
		
		for ( i = 0; i < m_menuData.Size(); i += 1 )
		{
			CurDataItem = m_menuData[i];
			
			if ( CurDataItem.MenuName == menu )
			{
				parentName = CurDataItem.ParentMenu;
			}
		}
		return parentName;
	}
	
	protected function GatherBindersArray(out resultArray : CScriptedFlashArray, bindersList : array<SKeyBinding>, optional isContextBinding:bool)
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
			bindingGFxData.SetMemberFlashString("label", GetLocStringByKeyExt(curBinding.LocalizationKey) );
			bindingGFxData.SetMemberFlashString("isContextBinding", isContextBinding);
			resultArray.PushBackFlashObject(bindingGFxData);
		}
	}
	
	protected function UpdateInputFeedback():void
	{
		var gfxDataList	: CScriptedFlashArray;
		gfxDataList = m_flashValueStorage.CreateTempFlashArray();
		GatherBindersArray(gfxDataList, m_defaultInputBindings);
		m_flashValueStorage.SetFlashArray("mainmenu.buttons.setup", gfxDataList);
	}
		
	function SetButtons()
	{
		AddInputBinding("panel_button_common_exit", "escape-gamepad_B", IK_Escape);
		AddInputBinding("panel_button_common_use", "enter-gamepad_A", IK_Enter);
		AddInputBinding("panel_button_common_navigation", "gamepad_L3");
		UpdateInputFeedback();
	}	

	function PlayOpenSoundEvent()
	{
	}
	
	public function SetMenuAlpha( value : int ) : void
	{
		m_flashModule.SetAlpha(value);
	}
}
