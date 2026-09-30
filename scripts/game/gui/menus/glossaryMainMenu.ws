/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3GlossaryInitData extends CObject
{
	public var m_subMenuName : name;
}

class CR4GlossaryMainMenu extends CR4MenuBase
{
    private var m_menuData 	   : array< SMenuTab >;
    private var m_fxSetHasMenu				: CScriptedFlashFunction;

	event  OnConfigUI()
	{		
		var initData          : W3GlossaryInitData;

		initData = (W3GlossaryInitData)GetMenuInitData();

		m_flashModule = GetMenuFlash();
		m_flashValueStorage = GetMenuFlashValueStorage();
		
		super.OnConfigUI();

        m_fxSetHasMenu 				= m_flashModule.GetMemberFlashFunction( "setHasMenu" );
		
		

        DefineMenuStructure();
        SetupMenu();

		if(initData)
		{
			OnRequestMenu(initData.m_subMenuName, '');
		}
		else 
			OnRequestMenu(thePlayer.GetDefaultGlossaryPage(), '');
	}
	
	
	function  SetButtons(){}
	
	
	event  OnClosingMenu()
	{
		var commonMenuRef : CR4CommonMenu;
		commonMenuRef = theGame.GetGuiManager().GetCommonMenu();
		
		if (commonMenuRef)
		{
			commonMenuRef.UpdateInputFeedback();			
		}

        
		
		super.OnClosingMenu();
	}

    event  OnCloseMenu() 
	{
		var commonMenu : CR4CommonMenu;
		
		commonMenu = (CR4CommonMenu)m_parentMenu;
		if(commonMenu)
		{
			commonMenu.ChildRequestCloseMenu();
		}
		
		theSound.SoundEvent( 'gui_global_quit' ); 
		CloseMenu();
	}


    private function SetupMenu() : void
	{
		var l_flashSubArray   : CScriptedFlashArray;
		
		l_flashSubArray = m_flashValueStorage.CreateTempFlashArray();
		GetGFxMenuStruct(l_flashSubArray);
		
		m_flashValueStorage.SetFlashArray( "panel.main.setup", l_flashSubArray);
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

    private function DefineMenuStructure() : void
	{
		var curMenuItem 	: SMenuTab;
		var curMenuSubItems : SMenuTab;
		
		m_menuData.Clear();
        DefineMenuItem('GlossaryBestiaryMenu', "panel_title_glossary_bestiary",'');				
        DefineMenuItem('GlossaryTutorialsMenu', "panel_title_glossary_tutorials",'');
        DefineMenuItem('GlossaryEncyclopediaMenu', "panel_title_glossary_dictionary",'');
        DefineMenuItem('GlossaryBooksMenu', "books_panel_title",'');
        DefineMenuItem('CraftingMenu', "panel_title_crafting", '');

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

    event  OnRequestMenu( MenuName : name, MenuState : string)
	{	
		var menuInitData   : W3MenuInitData;
		var currentSubMenu : CR4MenuBase;
		var parentMenuName : name;
		var ignoreSaveData : bool;
		var isUsingNewSkillTreeMenu : bool;
		
		currentSubMenu = (CR4MenuBase)GetSubMenu();
		menuInitData = (W3MenuInitData)GetMenuInitData();

		TrySetLastSubMenu(MenuName);
		SendTopBarTabSelected(MenuName, MenuState);
		
		if (menuInitData)
		{
			ignoreSaveData = menuInitData.ignoreSaveSystem;
			
			menuInitData.ignoreSaveSystem = false;
		}
		if( currentSubMenu && currentSubMenu.GetMenuName() == MenuName )
		{			
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
			
			
			
				
			
			
			if( menuInitData )
			{
				menuInitData.setDefaultState(HaxGetPanelStateName(MenuState));
				RequestSubMenu( MenuName, menuInitData );
			}
			else
			{
				if( !GetMenuInitData() && MenuState != "" && MenuState != "None" )
				{
					menuInitData = new W3MenuInitData in this;
					menuInitData.setDefaultState(HaxGetPanelStateName(MenuState));
					RequestSubMenu( MenuName, menuInitData );
				}
				else
				{
					RequestSubMenu( MenuName, GetMenuInitData());
				}
                m_fxSetHasMenu.InvokeSelfOneArg(FlashArgBool(true));
			}
			
			
			theGame.GetTutorialSystem().uiHandler.OnClosingMenu(GetMenuName());
			
			UISavedData.openedCategories.Clear();
			if( MenuState != "" && MenuState != "None" )
			{				
				UISavedData.openedCategories.PushBack( HaxGetPanelStateName(MenuState) );
			}
			
			m_guiManager.UpdateUISavedData( 'GlossaryMenu', UISavedData.openedCategories, MenuName, UISavedData.selectedModule );
		}
	}

	private function SendTopBarTabSelected(MenuName : name, MenuState : string)
	{
		var tempFlashObject : CScriptedFlashObject;
		tempFlashObject = m_flashValueStorage.CreateTempFlashObject();
		tempFlashObject.SetMemberFlashInt("id", NameToFlashUInt(MenuName));
		tempFlashObject.SetMemberFlashString("state", MenuState);
		m_flashValueStorage.SetFlashObject("panel.main.select.tab", tempFlashObject);
	}

    public  function UpdateInputDevice():void
	{
		

		var childMenu : CR4MenuBase;
		var isGamepad : bool;

		super.UpdateInputDevice();

		childMenu = GetLastChild();
		if (childMenu)
		{
			isGamepad = theInput.LastUsedGamepad();
		
			childMenu.SetControllerType(isGamepad);
			childMenu.UpdateInputDeviceType();
		}
	}

    function ChildRequestCloseMenu()
    {
        m_fxSetHasMenu.InvokeSelfOneArg(FlashArgBool(false));
    }

    event  OnHideChildMenu()
	{
		var childMenu : CR4MenuBase;
		
		childMenu = GetLastChild();
		if (childMenu)
		{
			childMenu.OnCloseMenu();
		}
        else
        {
            OnCloseMenu();
        }
	}

	function TrySetLastSubMenu(menuName:name)
	{
		if(thePlayer) thePlayer.SetLastOpenedGlossaryPage(menuName);
	}
	
}

function IsGlossaryMainSubMenu(menu : name):bool
{
	switch(menu)
	{
		case 'GlossaryBestiaryMenu':
		case 'GlossaryTutorialsMenu':
		case 'GlossaryEncyclopediaMenu':
		case 'GlossaryBooksMenu':
		case 'CraftingMenu':
			return true;
	}
	return false;
}