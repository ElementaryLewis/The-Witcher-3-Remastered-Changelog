/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class IngameMenuStructureCreator
{
	public var parentMenu 				: CR4IngameMenu;
	public var m_flashValueStorage		: CScriptedFlashValueStorage;
	public var m_flashConstructor 		: CScriptedFlashObject;

	private function IsRunningModdedGame():bool
	{
		var modList : array<string>;

		theGame.GetModHandlerSystem().GetStartupModNames( modList );

		return modList.Size() > 0;
	}
	
	protected function CreateMenuItem(id : string, label : string, tag : int, type : int, createEmptyChildList : bool, optional listTitle : string) : CScriptedFlashObject
	{
		var l_DataFlashObject 		: CScriptedFlashObject;
		var l_ChildMenuFlashArray	: CScriptedFlashArray;
		var l_label : string;
		
		l_label = GetLocStringByKeyExt(label);
		
		if (l_label == "")
		{
			l_label = "#" + label;
		}
		
		l_DataFlashObject = m_flashConstructor.CreateFlashObject("red.game.witcher3.menus.mainmenu.IngameMenuEntry");
		l_DataFlashObject.SetMemberFlashString( "id", id);
		l_DataFlashObject.SetMemberFlashString(  "label", l_label );		
		l_DataFlashObject.SetMemberFlashUInt(  "tag", tag );
		l_DataFlashObject.SetMemberFlashUInt( "type", type );	
		
		if (listTitle)
		{
			l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt(listTitle) );
		}
		else
		{
			l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt(label) );
		}
		
		if (createEmptyChildList)
		{
			l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
			l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		}
		
		return l_DataFlashObject;
	}
	
	function PopulateMenuData() : CScriptedFlashArray
	{
		var l_DataFlashArray		: CScriptedFlashArray;
		var l_ChildMenuFlashArray	: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		var l_subDataFlashObject	: CScriptedFlashObject;
		var l_titleString			: string;
		
		l_DataFlashArray = m_flashValueStorage.CreateTempFlashArray();
		
		if (parentMenu.isMainMenu)
		{
			if (hasSaveDataToLoad())
			{
				
				l_DataFlashObject = CreateMenuItem("continue", "panel_continue", NameToFlashUInt('Continue'), IGMActionType_LoadLastSave, true);
				l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
				
			}
			
			
			{
				l_DataFlashObject = CreateMenuItem("NewGameTopLevel", "panel_newgame", NameToFlashUInt('NewGame'), IGMActionType_MenuHolder, false, "panel_newgame");
				l_DataFlashObject.SetMemberFlashBool("isNewGameAndModded", IsRunningModdedGame());
				l_DataFlashObject.SetMemberFlashBool( "unavailable", theGame.GetModHandlerSystem().HasUninstalledMods() );
				l_ChildMenuFlashArray = CreateNewGameListArray();
			}
			l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			
		}
		else
		{
			
			l_DataFlashObject = CreateMenuItem("resume", "panel_resume", NameToFlashUInt('Resume'), IGMActionType_Close, true);
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			
		}
		
		if (!parentMenu.isMainMenu)
		{
			
			switch( theGame.GetPlatform() )
			{
				case Platform_PS5:	
				case Platform_PS4:
					l_titleString = "panel_mainmenu_savegame_ps4";
					break;
				case Platform_Xbox1:
				case Platform_Xbox_SCARLETT_ANACONDA:
				case Platform_Xbox_SCARLETT_LOCKHART:
					l_titleString = "panel_mainmenu_savegame_x1";
					break;
				default:
					l_titleString = "panel_mainmenu_savegame";
			}	
			
			l_DataFlashObject = CreateMenuItem("mainmenu_savegame", l_titleString, NameToFlashUInt('SaveGame'), IGMActionType_Save, true);
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			
		}
		
		if (hasSaveDataToLoad())
		{
			
			l_DataFlashObject = CreateMenuItem("mainmenu_loadgame", "panel_mainmenu_loadgame", NameToFlashUInt('LoadGame'), IGMActionType_Load, true);
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			
		}
		
		
		l_DataFlashObject = CreateMenuItem("mainmenu_options", "panel_mainmenu_options", NameToFlashUInt('Options'), IGMActionType_Options, true);
		l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
		
		
		
		if (!parentMenu.isMainMenu)
		{
			if( thePlayer.IsActionAllowed( EIAB_OpenGlossary ) && !theGame.IsDialogOrCutscenePlaying() ) 
			{
				
				l_DataFlashObject = CreateMenuItem("mainmenu_Tutorials", "panel_mainmenu_tutorials", NameToFlashUInt('Tutorials'), IGMActionType_Tutorials, true);
				l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
				
			}
			
			
			if ( !theGame.IsDialogOrCutscenePlaying() && (theGame.GetGwintManager().GetHasDoneTutorial() || FactsQuerySum("standalone_ep1") > 0 || FactsQuerySum("standalone_ep2") > 0 || FactsQuerySum("standalone_ep3") > 0|| FactsQuerySum("NewGamePlus") > 0))  
			{
				l_DataFlashObject = CreateMenuItem("mainmenu_Gwent", "panel_mainmenu_gwent", NameToFlashUInt('Gwent'), IGMActionType_Gwint, true);
				l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			}
			
			
		}

		
		if (theGame.GetPlatform() == Platform_Switch2_Ounce)
		{	
				l_DataFlashObject = CreateMenuItem("mainmenu_SwitchFeatures", "menu_panel_console_features_switch2_title", NameToFlashUInt('SwitchFeatures'), IGMActionType_SwitchFeatures, true);
				l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
		}

		
		if (theGame.GetPlatform() == Platform_Switch2_Ounce)
		{	
			if(theGame.IsPatternTutorial())
			{
				l_DataFlashObject = CreateMenuItem("mainmenu_LeaveTutorial", "menuitem_leave_tutorial", NameToFlashUInt('LeaveTutorial'), IGMActionType_LeaveTutorial, true);
				l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			}
			else
			{
				l_DataFlashObject = CreateMenuItem("mainmenu_ReplayTutorial", "menuitem_replay_tutorial", NameToFlashUInt('ReplayTutorial'), IGMActionType_ReplayTutorial, true);
				if(!parentMenu.isMainMenu)
				{
					l_DataFlashObject.SetMemberFlashBool("unavailable", theGame.AreSavesLocked());
				}
				else
				{
					l_DataFlashObject.SetMemberFlashBool("unavailable",false);
				}
				l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);	
			}
		}		
		
		
		if (parentMenu.isMainMenu)
		{
				l_DataFlashObject = CreateMenuItem("mainmenu_mods", "panel_mainmenu_mods", NameToFlashUInt('Mods'), IGMActionType_ModMenu, true); 
				l_DataFlashObject.SetMemberFlashBool( "unavailable", !theGame.GetModHandlerSystem().IsModioActive() );
				l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
		}
		
		
		
		if (parentMenu.isMainMenu)
		{
			l_DataFlashObject = CreateMenuItem("mainmenu_patchnotes", "menu_panel_patchnotes", NameToFlashUInt('PatchNotes'), IGMActionType_PatchNotes, true);
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
		}

		

		if (parentMenu.isMainMenu)
		{
			l_DataFlashObject = CreateMenuItem("credits", "panel_mainmenu_extras_credits", CreditsIndex_Wither3, IGMActionType_MenuHolder, true, "panel_mainmenu_extras_credits");
			l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
			IngameMenu_FillCreditsSubGroup(m_flashValueStorage, l_ChildMenuFlashArray);
			
			l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
			
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
		}

		


		
		
		
		
		
		
		
		
		
		if (!parentMenu.isMainMenu)
		{
			
			l_DataFlashObject = CreateMenuItem("button_common_quittomainmenu", "panel_button_common_quittomainmenu", NameToFlashUInt('DLC'), IGMActionType_Quit, true);
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			
		}

		
		
		

		if ( parentMenu.isMainMenu && theGame.IsExpansionPackMenuSupported() && (!theGame.GetDLCManager().IsEP1Enabled() || !theGame.GetDLCManager().IsEP2Enabled()) )
		{
			
			l_DataFlashObject = CreateMenuItem("panel_expansion_packs", "panel_mainmenu_item_expansion_purchase", NameToFlashUInt('ExpansionPacks'), IGMActionType_MenuHolder, false, "panel_mainmenu_item_expansion_purchase");
			l_ChildMenuFlashArray = CreateExpansionPacksSubElements();
			l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			
		}
		
		if (theGame.GetPlatform() == Platform_PC || theGame.GetPlatform() == Platform_PC_GDK)
		{
			
			l_DataFlashObject = CreateMenuItem("button_closeGame", "menu_main_quit", NameToFlashUInt('CloseGame'), IGMActionType_CloseGame, true);
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			
		}
	
		if (theGame.DebugQuestMenuEnable())
		{
			
			l_DataFlashObject = CreateMenuItem("debug_menu", "DBG Quest Menu", NameToFlashUInt('DebugMenu'), IGMActionType_DebugStartQuest, true);
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			
		}
		
		return l_DataFlashArray;
	}
	
	protected function CreateNewGameListArray() : CScriptedFlashArray
	{
		var l_optionChildList 		: CScriptedFlashArray;
		var l_ChildMenuFlashArray	: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		
		l_optionChildList = m_flashValueStorage.CreateTempFlashArray();
		
		
		l_DataFlashObject = CreateMenuItem("NewGame", "new_game_tw3", NameToFlashUInt('NewGame'), IGMActionType_MenuHolder, false, "newgame_difficulty");
		l_ChildMenuFlashArray = CreateNewGameSubMenuListArray(0);
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		l_DataFlashObject.SetMemberFlashString( "description", GetLocStringByKeyExt("panel_mainmenu_start_newgame_description") );
		
		l_optionChildList.PushBackFlashObject(l_DataFlashObject);
		
		
		
		
		{
			l_DataFlashObject = CreateMenuItem("NewGame", "new_game_ep1", NameToFlashUInt('NewGameEP1'), IGMActionType_MenuHolder, false, "newgame_difficulty");
			l_ChildMenuFlashArray = CreateNewGameSubMenuListArray(IGMC_EP1_Save);
			l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
			l_DataFlashObject.SetMemberFlashString( "description", GetLocStringByKeyExt("panel_mainmenu_start_ep1_description") );
			
			l_optionChildList.PushBackFlashObject(l_DataFlashObject);
		}
		
		{
			l_DataFlashObject = CreateMenuItem("NewGame", "new_game_ep2", NameToFlashUInt('NewGameEP2'), IGMActionType_MenuHolder, false, "newgame_difficulty");
			l_ChildMenuFlashArray = CreateNewGameSubMenuListArray(IGMC_EP2_Save);
			l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
			l_DataFlashObject.SetMemberFlashString( "description", GetLocStringByKeyExt("panel_mainmenu_start_ep2_description") );
			
			l_optionChildList.PushBackFlashObject(l_DataFlashObject);
		}
		
		{
			l_DataFlashObject = CreateMenuItem("NewGame", "newgame_plus", NameToFlashUInt('NewGamePlus'), IGMActionType_MenuHolder, false, "newgame_difficulty");
			l_ChildMenuFlashArray = CreateNewGameSubMenuListArray(IGMC_New_game_plus);
			l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
			l_DataFlashObject.SetMemberFlashString( "description", GetLocStringByKeyExt("panel_mainmenu_start_ngplus_description") );
			
			l_optionChildList.PushBackFlashObject(l_DataFlashObject);
		}
		
		



		
		
		return l_optionChildList;
	}
			
	protected function CreateNewGameSubMenuListArray( initialTag:int ) : CScriptedFlashArray
	{
		var l_optionChildList : CScriptedFlashArray  = m_flashValueStorage.CreateTempFlashArray();
		
		
		
		
		
		

		AddDifficultyOptionItem(initialTag, EDM_Easy, l_optionChildList);
		AddDifficultyOptionItem(initialTag, EDM_Medium, l_optionChildList);
		AddDifficultyOptionItem(initialTag, EDM_Hard, l_optionChildList);
		AddDifficultyOptionItem(initialTag, EDM_Hardcore, l_optionChildList);
		
		return l_optionChildList;
	}
	
	protected function AddDifficultyOptionItem( tag:int, difficulty:EDifficultyMode, parentArray:CScriptedFlashArray ):void
	{
		var l_ChildMenuFlashArray	: CScriptedFlashArray = m_flashValueStorage.CreateTempFlashArray();
		var l_DataFlashObject 		: CScriptedFlashObject = m_flashValueStorage.CreateTempFlashObject();
		var displayName				: string;
		var descriptionText			: string;

		

		switch (difficulty)
		{
		case EDM_Easy:
			displayName = "panel_mainmenu_dificulty_easy_title";
			descriptionText = "panel_mainmenu_dificulty_easy_description";
			break;
		case EDM_Medium:
			displayName = "panel_mainmenu_dificulty_normal_title";
			descriptionText = "panel_mainmenu_dificulty_normaldescription_description";
			break;
		case EDM_Hard:
			displayName = "panel_mainmenu_dificulty_hard_title";
			descriptionText = "panel_mainmenu_dificulty_hard_description";
			break;
		case EDM_Hardcore:
			displayName = "panel_mainmenu_dificulty_hardcore_title";
			descriptionText = "panel_mainmenu_dificulty_hardcore_description";
			break;
		}
		
		tag += difficulty;
		
		l_DataFlashObject.SetMemberFlashString( "id", "mainmenu_Tutorials");
		l_DataFlashObject.SetMemberFlashUInt(  "tag", tag );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt(displayName) );
		l_DataFlashObject.SetMemberFlashString(  "description", GetLocStringByKeyExt(descriptionText) );
		l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_MenuHolder );

		
		
		l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt("newgame_tutorials") );

		AddNewgameTutorialOption(tag, l_ChildMenuFlashArray);
		
		
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		
		parentArray.PushBackFlashObject(l_DataFlashObject);
	}

	function IsBardsBalladTag(tag:int) : bool
	{
		
		
		return (tag & EDM_Easy) == EDM_Easy && (tag & EDM_Medium) != EDM_Medium;
	}

	function IsEp1SaveGame(tag:int) : bool
	{
		return (tag & IGMC_EP1_Save) == IGMC_EP1_Save;
	}

	function IsEp2SaveGame(tag:int) : bool
	{
		return (tag & IGMC_EP2_Save) == IGMC_EP2_Save;
	}



	function IsNewGamePlus(tag:int) : bool
	{
		return (tag & IGMC_New_game_plus) == IGMC_New_game_plus;
	}

	protected function AddNewgameTutorialOption(tag : int, parentArray : CScriptedFlashArray) : void
	{
		var l_ChildMenuFlashArray	: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		var currentTag : int;
		var type : InGameMenuActionType = IGMActionType_NewGame;
		var needsBardsBallad : bool = IsBardsBalladTag(tag);


		
		
		
		currentTag = tag;
		currentTag += IGMC_Tutorials_On;

		if(needsBardsBallad)
		{
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
			l_DataFlashObject.SetMemberFlashString( "id", "mainmenu_Tutorials");
			l_DataFlashObject.SetMemberFlashUInt(  "tag", currentTag );
			l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_mainmenu_option_value_on") );
			l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt("panel_mainmenu_bard_title") );
			
			l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_MenuHolder );
			l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
			AddNewgameBardsBalladOption(currentTag, l_ChildMenuFlashArray);
			l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
			
			parentArray.PushBackFlashObject(l_DataFlashObject);
		}
		else
		{
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
			l_DataFlashObject.SetMemberFlashString( "id", "mainmenu_BardsBallad");
			l_DataFlashObject.SetMemberFlashUInt(  "tag", currentTag );
			l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_mainmenu_option_value_on") );
			l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt("newgame_import") );
			
			
			if ( !(IsEp1SaveGame(tag) || IsEp2SaveGame(tag) 

			) )
			{
				l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_MenuHolder );
				l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
				AddNewgameSimulateImportOption(currentTag, l_ChildMenuFlashArray);
				l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
			}
			else
			{
				l_DataFlashObject.SetMemberFlashUInt( "type", type );
			}
			
			parentArray.PushBackFlashObject(l_DataFlashObject);
		}
		
		
		
		currentTag = tag;

		if(needsBardsBallad)
		{
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
			l_DataFlashObject.SetMemberFlashString( "id", "mainmenu_Tutorials");
			l_DataFlashObject.SetMemberFlashUInt(  "tag", currentTag );
			l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_mainmenu_option_value_off") );
			l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt("panel_mainmenu_bard_title") );

			l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_MenuHolder );
			l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
			AddNewgameBardsBalladOption(currentTag, l_ChildMenuFlashArray);
			l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );

			parentArray.PushBackFlashObject(l_DataFlashObject);
		}
		else
		{
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
			l_DataFlashObject.SetMemberFlashString( "id", "mainmenu_Tutorials");
			l_DataFlashObject.SetMemberFlashUInt(  "tag", currentTag );
			l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_mainmenu_option_value_off") );
			l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt("newgame_import") );
			l_DataFlashObject.SetMemberFlashUInt( "type", type );

			if ( !(IsEp1SaveGame(tag) || IsEp2SaveGame(tag) 

			) )
			{
				l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_MenuHolder );
				l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
				AddNewgameSimulateImportOption(currentTag, l_ChildMenuFlashArray);
				l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
				l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt("newgame_import") );
			}
			else
			{
				l_DataFlashObject.SetMemberFlashUInt( "type", type );
			}

			parentArray.PushBackFlashObject(l_DataFlashObject);
		}
	}

	protected function AddNewgameBardsBalladOption(tag : int, parentArray : CScriptedFlashArray) : void
	{
		var l_ChildMenuFlashArray	: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		var currentTag : int;
		var type : InGameMenuActionType = IGMActionType_NewGame;


		
		
		
		currentTag = tag;
		currentTag += IGMC_BardsBallad_On;

		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString( "id", "mainmenu_BardsBallad");
		l_DataFlashObject.SetMemberFlashUInt(  "tag", currentTag );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_common_yes") );
		l_DataFlashObject.SetMemberFlashString(  "description", GetLocStringByKeyExt("panel_mainmenu_bard_desc") );
		l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt("newgame_import") );
		
		
		if ( !(IsEp1SaveGame(tag) || IsEp2SaveGame(tag) 

		) )
		{
			l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_MenuHolder );
			l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
			AddNewgameSimulateImportOption(currentTag, l_ChildMenuFlashArray);
			l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		}
		else
		{
			l_DataFlashObject.SetMemberFlashUInt( "type", type );
		}
		
		parentArray.PushBackFlashObject(l_DataFlashObject);
		
		
		
		currentTag = tag;

		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString( "id", "mainmenu_BardsBallad");
		l_DataFlashObject.SetMemberFlashUInt(  "tag", currentTag );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_common_no") );
		l_DataFlashObject.SetMemberFlashString(  "description", GetLocStringByKeyExt("panel_mainmenu_bard_desc") );
		l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt("newgame_import") );
		l_DataFlashObject.SetMemberFlashUInt( "type", type );

		if ( !(IsEp1SaveGame(tag) || IsEp2SaveGame(tag) 

		) )
		{
			l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_MenuHolder );
			l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
			AddNewgameSimulateImportOption(currentTag, l_ChildMenuFlashArray);
			l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
			l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt("newgame_import") );
		}
		else
		{
			l_DataFlashObject.SetMemberFlashUInt( "type", type );
		}

		parentArray.PushBackFlashObject(l_DataFlashObject);
	}
	
	protected function AddNewgameSimulateImportOption(tag:int, parentArray : CScriptedFlashArray) : void
	{
		var l_ChildMenuFlashArray	: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		var savesToImport : array< SSavegameInfo >;
		var currentTag : int;
		
		
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
		l_DataFlashObject.SetMemberFlashString( "id", "mainmenu_simulate_on");
		
		currentTag = tag;
		currentTag += IGMC_Simulate_Import;

		l_DataFlashObject.SetMemberFlashUInt(  "tag", currentTag );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_mainmenu_option_value_on") );
		
		
		if ( IsNewGamePlus(tag) )
		{
			l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_MenuHolder );
			l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt("newgame_plus") );
			AddNewGamePlusOption(currentTag, l_ChildMenuFlashArray);
		}
		else
		{
			l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_NewGame );
		}
		
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		
		parentArray.PushBackFlashObject(l_DataFlashObject);
		
		
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
		l_DataFlashObject.SetMemberFlashString( "id", "mainmenu_simulate_off");
		
		currentTag = tag;
		
		l_DataFlashObject.SetMemberFlashUInt(  "tag", currentTag );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_mainmenu_option_value_off") );	
		
		
		if ( IsNewGamePlus(tag) )
		{
			l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_MenuHolder );
			l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt("newgame_plus") );
			AddNewGamePlusOption(currentTag, l_ChildMenuFlashArray);
		}
		else
		{
			l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_NewGame );
		}
		
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		
		parentArray.PushBackFlashObject(l_DataFlashObject);
		
		
		if (theGame.GetPlatform() == Platform_PC || theGame.GetPlatform() == Platform_PC_GDK)
		{
			theGame.ListW2SavedGames( savesToImport );
			
			if (savesToImport.Size() != 0)
			{
				currentTag = tag;
				currentTag += IGMC_Import_Save;
				l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
				l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
				l_DataFlashObject.SetMemberFlashString( "id", "mainmenu_import_witcher_two");
				l_DataFlashObject.SetMemberFlashUInt(  "tag", currentTag );
				l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_importsave") );
	
				if ((tag & IGMC_New_game_plus) == IGMC_New_game_plus)
				{
					l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_ImportSave );
					l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt("newgame_plus") );
					AddNewGamePlusOption(currentTag, l_ChildMenuFlashArray);
				}
				else
				{
					l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_ImportSave );
				}
				
				l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
				parentArray.PushBackFlashObject(l_DataFlashObject);
			}
		}
	}
	
	protected function AddNewGamePlusOption(tag:int, parentArray : CScriptedFlashArray):void
	{
		var l_ChildMenuFlashArray	: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		
		
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString( "id", "panel_common_ok");
		
		l_DataFlashObject.SetMemberFlashUInt(  "tag", tag );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_continue") );
		l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_NewGamePlus );
		
		l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		
		parentArray.PushBackFlashObject(l_DataFlashObject);
	}
	
	protected function CreateImortedSaveGamesArray() : CScriptedFlashArray
	{
		var i 				: int;
		var flashObject		: CScriptedFlashObject;
		var savedGames		: CScriptedFlashArray;
		var savedGamesList	: array< SSavegameInfo >;
	
		savedGames = m_flashValueStorage.CreateTempFlashArray();
		
		theGame.ListW2SavedGames( savedGamesList );
		for ( i = 0; i < savedGamesList.Size(); i += 1 )
		{
			flashObject = m_flashValueStorage.CreateTempFlashObject();
			flashObject.SetMemberFlashString( "id", savedGamesList[ i ].filename );
			flashObject.SetMemberFlashString( "label", savedGamesList[ i ].filename );
			flashObject.SetMemberFlashString( "tag", i );
			flashObject.SetMemberFlashString( "iconPath", "" );
			flashObject.SetMemberFlashString( "description", "");
			savedGames.PushBackFlashObject( flashObject );
		}	
		
		return savedGames;
	}
	
	protected function CreateExpansionPacksSubElements() : CScriptedFlashArray
	{
		var l_optionChildList 		: CScriptedFlashArray;
		var l_ChildMenuFlashArray	: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		
		l_optionChildList = m_flashValueStorage.CreateTempFlashArray();
				
		
		{
			l_DataFlashObject = CreateMenuItem("PurchaseEP1", "panel_mainmenu_item_purchase_ep1", NameToFlashUInt('PurchaseEP1'), IGMActionType_PurchaseEP1, false);
			l_DataFlashObject.SetMemberFlashBool( "unavailable", theGame.GetDLCManager().IsEP1Enabled());	
			l_optionChildList.PushBackFlashObject(l_DataFlashObject);
		}
		
		{
			l_DataFlashObject = CreateMenuItem("PurchaseEP2", "panel_mainmenu_item_purchase_bob", NameToFlashUInt('PurchaseEP2'), IGMActionType_PurchaseEP2, false);
			l_DataFlashObject.SetMemberFlashBool( "unavailable", theGame.GetDLCManager().IsEP2Enabled() );
			
			l_optionChildList.PushBackFlashObject(l_DataFlashObject);
		}
		
		
		return l_optionChildList;
	}

	protected function CreateDLCSubElements() : CScriptedFlashArray
	{
		var l_optionChildList 	: CScriptedFlashArray;
		var i				  	: int;
		var dlcOptionIndex		: array<int>;
		var l_DataFlashObject	: CScriptedFlashObject;
		var hasChildOptions		: bool;
		var inGameConfigWrapper	: CInGameConfigWrapper;
		var groupName			: name;
		
		hasChildOptions = false;
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		
		l_optionChildList = m_flashValueStorage.CreateTempFlashArray();
		
		l_DataFlashObject = CreateMenuItem("installed_dlc", "panel_mainmenu_installed_dlc", NameToFlashUInt('InstalledDLC'), IGMActionType_InstalledDLC, true);
		l_optionChildList.PushBackFlashObject(l_DataFlashObject);
		
		for (i = 0; i < inGameConfigWrapper.GetGroupsNum(); i += 1)
		{
			groupName = inGameConfigWrapper.GetGroupName(i);
			if (groupName == 'DLC' || groupName == 'DLCOptions')
			{			
				dlcOptionIndex.PushBack(i);		
			}
		}
		
		if(dlcOptionIndex.Size()>0)
		{
			l_DataFlashObject = CreateMenuItem("dlc_options", "panel_mainmenu_options", NameToFlashUInt('DLCOptions'), IGMActionType_MenuLastHolder, true);
			for (i = 0; i < dlcOptionIndex.Size(); i += 1)
			{
				groupName = inGameConfigWrapper.GetGroupName(dlcOptionIndex[i]);
				hasChildOptions = IngameMenu_FillSubMenuOptionsList(m_flashValueStorage, dlcOptionIndex[i], groupName, l_DataFlashObject);
			}				
			if (hasChildOptions)
			{
				l_optionChildList.PushBackFlashObject(l_DataFlashObject);
			}
		}
		
		
		return l_optionChildList;
	}

	function IngameMenu_FillCreditsSubGroup(flashStorageUtility : CScriptedFlashValueStorage, rootFlashArray:CScriptedFlashArray):void
	{
		var l_ChildMenuFlashArray	: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		
		
		l_DataFlashObject = flashStorageUtility.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString( "id", "credits_witcher");
		l_DataFlashObject.SetMemberFlashUInt(  "tag", CreditsIndex_Wither3 );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("TW3") );	
		
		l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_Credits );	
		
		l_ChildMenuFlashArray = flashStorageUtility.CreateTempFlashArray();
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		
		rootFlashArray.PushBackFlashObject(l_DataFlashObject);
		
		
		if (theGame.GetDLCManager().IsEP1Available())
		{
			
			l_DataFlashObject = flashStorageUtility.CreateTempFlashObject();
			l_DataFlashObject.SetMemberFlashString( "id", "credits_heart_of_stone");
			l_DataFlashObject.SetMemberFlashUInt(  "tag", CreditsIndex_Ep1 );
			l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("dlc_hearts_of_stone") );	
			
			l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_Credits );	
			
			l_ChildMenuFlashArray = flashStorageUtility.CreateTempFlashArray();
			l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
			
			rootFlashArray.PushBackFlashObject(l_DataFlashObject);
			
		}
		
		if ( theGame.GetDLCManager().IsEP2Available() )
		{
			
			l_DataFlashObject = flashStorageUtility.CreateTempFlashObject();
			l_DataFlashObject.SetMemberFlashString( "id", "credits_blood_and_wine");
			l_DataFlashObject.SetMemberFlashUInt(  "tag", CreditsIndex_Ep2 );
			l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("dlc_blood_and_wine") );	
			
			l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_Credits );	
			
			l_ChildMenuFlashArray = flashStorageUtility.CreateTempFlashArray();
			l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
			
			rootFlashArray.PushBackFlashObject(l_DataFlashObject);
			
		}
		
		
		l_DataFlashObject = flashStorageUtility.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString( "id", "credits_witcher_ng" );
		l_DataFlashObject.SetMemberFlashUInt(  "tag", CreditsIndex_Witcher3_NG );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("nge_credits_title") );	
		l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_Credits );	
			
		l_ChildMenuFlashArray = flashStorageUtility.CreateTempFlashArray();
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
			
		rootFlashArray.PushBackFlashObject(l_DataFlashObject);
		

		
		l_DataFlashObject = flashStorageUtility.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString( "id", "credits_witcher_re" );
		l_DataFlashObject.SetMemberFlashUInt(  "tag", CreditsIndex_Witcher3_RE );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("tw3re_credits_title") );	
		l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_Credits );	
			
		l_ChildMenuFlashArray = flashStorageUtility.CreateTempFlashArray();
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
			
		rootFlashArray.PushBackFlashObject(l_DataFlashObject);
		



	}
}