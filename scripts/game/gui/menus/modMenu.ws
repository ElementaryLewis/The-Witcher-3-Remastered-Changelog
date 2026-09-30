/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EModViewMode
{
	EMVM_Grid = 0,
	EMVM_List = 1
}

enum EModFilterIndex
{
	EMFI_Browse = 1,
	EMFI_Installed = 2
}

struct SModImageLoadData
{
	var m_modid 		: SModioModID;
	var m_resolution	: string;
	var m_type 			: string;
	var m_galleryIndex 	: int;
}

class CModFilterData
{
	public var m_filterSortType : EModFilterSortType; default m_filterSortType = MFST_Rating;
	public var m_filterSortDirection : EModFilterSortDirection; default m_filterSortDirection = MFSD_Descending;
	public var m_modTagInfos : array< SModTagInfo >;
	public var m_appliedTags : array< int >;
	public var m_excludedTags : array< int >;
	public var m_searchWords : array< string >;
	public var m_filtersChanged : bool; default m_filtersChanged = true;
	public var m_cachedParams : SModFilterParams;
	public var m_view : EModViewMode;

	public var m_currentPage : int; default m_currentPage = 1;
	public var m_maxPages : int; default m_maxPages = 1;
}

struct SModDetailsData
{
	var data : SModioModData;
	var rating : EModRatingType;
	var dependencies : array<SModDependency>;
}


class CR4ModMenu extends CR4MenuBase
{
	protected var m_defaultBindings : array<SKeyBinding>;
	protected var m_contextBindings : array<SKeyBinding>;
	protected var m_GFxBindings		: array<SKeyBinding>;
	
	protected var m_modHandler		: CModHandlerSystem;
	
	private var m_menuData 	   		: array< SMenuTab >;
	private var m_libraryModData	: array< SModioModData >;
	private var m_remoteModData		: array< SModioModData >;
	private var m_lastGotModDataList: array< SModDetailsData>;
	private var m_lastGotModValid	: bool; default m_lastGotModValid = false;
	private var m_blockModDataDetailsPushOnce : bool; default m_blockModDataDetailsPushOnce = false;
	
	
	private	var m_fxStartLoadingIndicator		: CScriptedFlashFunction;
	private	var m_fxStopLoadingIndicator		: CScriptedFlashFunction;
	private var m_fxDropdownUnselect			: CScriptedFlashFunction;
	private var m_fxHandleImageLoaded			: CScriptedFlashFunction;
	private var m_fxUpdateProgressBar			: CScriptedFlashFunction;
	private var m_fxUpdateStorageIndicator		: CScriptedFlashFunction;
	private var m_fxSetInstalledTabOpenable		: CScriptedFlashFunction;
	private var m_fxCloseReportWindow			: CScriptedFlashFunction;
	private var m_fxCloseModDetails				: CScriptedFlashFunction;
	private var m_fxRequestModDetailsFromDetails: CScriptedFlashFunction;
	private var m_fxEnableCloseAllButton : CScriptedFlashFunction;
	private var m_fxBlockAllMouse : CScriptedFlashFunction;
	
	
	private var m_lastSelectedLibraryIndex		: SModioModID;
	
	private var m_modStateMachine : CR4ModMenuStates;
	private var m_modLoadStateMachine : CR4ModMenuModLoadStates;
	private var m_textInputStateMachine		 : CR4VirtualTextInputStates;
	
	private var m_reportCategoryIndex : int; default m_reportCategoryIndex = -1;
	private var m_reportSecondaryIndex : int; default m_reportSecondaryIndex = -1;
	private var m_reportDescription : string;
	
	private var m_listener : ModMenuEventListener;
	private var m_closedCount : int;

	private var m_browseFilters : CModFilterData;
	private var m_installedFilters : CModFilterData;

	private var m_installedModsAtStart : array<SModioModID>;
	private var m_enabledModsAtStart : array<SModioModID>;

	private var m_installedSelectModCallCount : int; default m_installedSelectModCallCount = 0;
	
	event  OnConfigUI()
	{	
		var flashModule : CScriptedFlashSprite;
		var installedMods : array<SModioModData>;
		var emptyFilter : CModFilterData;
		var i : int;
		var enabled : bool;
		emptyFilter.m_filterSortType = MFST_ID;
		
		
		
		

		m_browseFilters = new CModFilterData in this;
		m_installedFilters = new CModFilterData in this;
		m_installedFilters.m_filterSortType = MFST_LoadOrder;
		m_installedFilters.m_filterSortDirection = MFSD_Ascending;
		
		m_modStateMachine = new CR4ModMenuStates in this;
		m_modStateMachine.Init();
		m_modStateMachine.SetRef(this);
		m_modStateMachine.OnGetFilterTags(EMFI_Browse);
		SearchWithFilterParams(m_browseFilters, true);
		
		
		m_modLoadStateMachine = new CR4ModMenuModLoadStates in this;
		m_modLoadStateMachine.SetRef(this);
		m_modLoadStateMachine.OnQueryProgress();
		
		m_listener = new ModMenuEventListener in this;
		m_listener.m_modMenu = this;

		super.OnConfigUI();
		m_modHandler = theGame.GetModHandlerSystem();
		
		theInput.StoreContext( 'EMPTY_CONTEXT' );
		
		m_fxStartLoadingIndicator = m_flashModule.GetMemberFlashFunction( "startLoadingIndicator" );
		m_fxStopLoadingIndicator = m_flashModule.GetMemberFlashFunction( "stopLoadingIndicator" );
		m_fxDropdownUnselect = m_flashModule.GetMemberFlashFunction( "dropdownUnselect" );
		m_fxHandleImageLoaded = m_flashModule.GetMemberFlashFunction( "handleImageLoaded" );
		m_fxUpdateProgressBar = m_flashModule.GetMemberFlashFunction( "updateProgressBar" );
		m_fxUpdateStorageIndicator = m_flashModule.GetMemberFlashFunction( "updateStorageIndicator" );
		m_fxSetInstalledTabOpenable = m_flashModule.GetMemberFlashFunction( "setInstalledTabOpenable" );
		m_fxCloseReportWindow = m_flashModule.GetMemberFlashFunction( "closeReportWindow" );
		m_fxCloseModDetails = m_flashModule.GetMemberFlashFunction( "closeModDetails" );
		m_fxRequestModDetailsFromDetails = m_flashModule.GetMemberFlashFunction( "requestModDetailsFromDetails" );
		m_fxEnableCloseAllButton = m_flashModule.GetMemberFlashFunction( "enableCloseAllButton" );
		m_fxBlockAllMouse = m_flashModule.GetMemberFlashFunction( "blockAllMouse" );
		
		theGame.GetGuiManager().RequestMouseCursor(true);
		
		DefineMenuItem('BrowseMenu', "panel_title_browse"); 
		DefineMenuItem('InstalledMenu', "panel_title_installed"); 
		
		SetupMenu();
		
		GetStorageUsage();
		SendGFXReportCategories();
		SendGFXNotWorkingCategories();
		
		m_modHandler.AddListener(m_listener);

		
		m_installedModsAtStart.Clear();
		m_enabledModsAtStart.Clear();

		m_modHandler.GetInstalledModList( emptyFilter.m_cachedParams, installedMods, true );
		for ( i = 0; i < installedMods.Size(); i += 1 )
		{
			m_installedModsAtStart.PushBack( installedMods[i].id );
			enabled = !m_modHandler.IsLocalModDisabled( installedMods[i].id );
			if ( enabled )
			{
				m_enabledModsAtStart.PushBack( installedMods[i].id );
			}
		}
	}
	
	event  OnClosingMenu()
	{
		super.OnClosingMenu();
		
		OnPlaySoundEvent( "gui_global_quit" );
		theGame.GetGuiManager().RequestMouseCursor(false);
		theInput.RestoreContext( 'EMPTY_CONTEXT', true );
	}

	event  OnCloseMenu()
	{
		var ingameMenu : CR4IngameMenu;
		var hasChangedInstalledMods, hasChangedEnabledMods : bool;
		var modArray : array<SModioModData>;
		var installedMods : array<SModioModID>;
		var enabledMods : array<SModioModID>;
		var emptyFilter : CModFilterData;
		var i : int;
		var enabled : bool;
		emptyFilter.m_filterSortType = MFST_ID;
		
		
		theGame.GetGuiManager().CancelFlashbackVideo();
		theSound.LeaveGameState( ESGS_MusicOnly );
		
		m_modHandler.RemoveListener(m_listener);
		m_modHandler.SaveLocalModConfig();
		m_modHandler.SignalUGCSectionEnded();

		
		m_modHandler.GetInstalledModList( emptyFilter.m_cachedParams, modArray, false);
		for ( i = 0; i < modArray.Size(); i += 1 )
		{
			installedMods.PushBack( modArray[i].id );

			enabled = !m_modHandler.IsLocalModDisabled( modArray[i].id );
			if ( enabled )
			{
				enabledMods.PushBack( modArray[i].id );
			}
		}
		
		
		if ( installedMods != m_installedModsAtStart )
		{
			hasChangedInstalledMods = true;
		}
		
		if ( enabledMods != m_enabledModsAtStart )
		{
			hasChangedEnabledMods = true;
		}

		
		if (hasChangedInstalledMods)
		{
			
			
		}
		else if (hasChangedEnabledMods)
		{
			theGame.GetGuiManager().DisplayModRestartNeededDialog(this, "panel_restart_needed", "mods_enabled_change", MRMT_EnabledChange, true);
		}

		if(m_parentMenu)
		{
			ingameMenu = (CR4IngameMenu)m_parentMenu;
			if (ingameMenu)
			{
				ingameMenu.PopulateMenuData();
			}
			
			m_parentMenu.ChildRequestCloseMenu();
			CloseMenu();
			return true;
		}
		else
		{
			theGame.FadeOutAsync( 0 );

			theSound.SoundEvent('play_music_kaer_morhen');
			CloseMenu();
		}
	}
	
	function PlayOpenSoundEvent()
	{
		OnPlaySoundEvent( "gui_global_panel_open" );
	}
	
	function CanPostAudioSystemEvents() : bool
	{
		return false;
	}
	
	event  OnNavigatedBack()
	{
		OnCloseMenu();
	}
	
	private function DefineMenuItem(itemName:name, itemLabel:string, optional parentMenuItem:name, optional menuState:name) : void
	{
		var newMenuItem 	: SMenuTab;
		var tempDataArray : array<SModioModData>;

		newMenuItem.MenuName = itemName;
		newMenuItem.MenuLabel = itemLabel;
		newMenuItem.Enabled = true;
		if(itemName == 'InstalledMenu') 
		{
			m_modHandler.GetModDataList(tempDataArray);
			newMenuItem.Enabled = tempDataArray.Size() > 0;
		}
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
		
		m_flashValueStorage.SetFlashArray( "panel.mod.setup", l_flashSubArray);
	}
	
	private function GetGFxMenuStruct(out StructGFx : CScriptedFlashArray) : void
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
				GetGFxMenuItem(CurDataItem, l_flashObject);
				
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
	
	
	
	
	
	public function GetStorageUsage():void
	{
		var usedStorage : string;
		var usedCache	: string;
		var availableStorage : string;
		var availableCache	 : string;
		
		usedStorage = m_modHandler.GetStorageInfo(true,false);
		usedCache = m_modHandler.GetStorageInfo(true,true);
		availableStorage = m_modHandler.GetStorageInfo(false,false);
		availableCache = m_modHandler.GetStorageInfo(false,true);
		
		m_fxUpdateStorageIndicator.InvokeSelfTwoArgs(FlashArgString(usedStorage), FlashArgString(availableStorage));
	}
	
	function ValidateReport(modid:string, desc:string) : bool
	{
		if(StrLen(desc) == 0
			|| m_reportCategoryIndex == - 1
			|| (m_reportCategoryIndex == 1 && m_reportSecondaryIndex == -1))
			return false;
		return true;
	}
	
	event  OnSubmitReport(modid:string, desc:string)
	{
		var params : SModReportParams;
		if(ValidateReport(modid,desc))
		{
			params.paramType = m_reportCategoryIndex + 1;
			params.desc = desc;
			params.modIDScr = m_modHandler.CreateModIDFromString(modid);
			if(m_reportCategoryIndex == 1)
				params.notWorkingReason = m_reportSecondaryIndex + 1;
			
			this.m_modStateMachine.OnSubmitReport(params);
			LogChannel('MODS', "Submitting report successful attempt");
			m_flashValueStorage.SetFlashString("panel.mod.report.setup.form", "loading");
		}
		else
		{
			showNotification( GetLocStringByKeyExt("panel_error_not_all_filled") );
			LogChannel('MODS', "Submitting report failed attempt");
		}
	}
	
	public function OnReportSubmitted()
	{
		LogChannel('MODS', "Submitting report went through to server");
		m_flashValueStorage.SetFlashString("panel.mod.report.setup.form", "finished");
	}
	
	public function OnReportFailed()
	{
		LogChannel('MODS', "Submitting report failed completely");
		m_flashValueStorage.SetFlashString("panel.mod.report.setup.form", "failed");
	}
	
	function OnReportReasonClicked(index:int, value:int):void
	{
		var l_flashSubObject   : CScriptedFlashObject;
	
		if (value == 2)
			value = 0;
			
		if (value == 1)
			m_reportCategoryIndex = index;
		l_flashSubObject = m_flashValueStorage.CreateTempFlashObject();
		
		l_flashSubObject.SetMemberFlashInt("index", index);
		l_flashSubObject.SetMemberFlashInt("value", value);
		l_flashSubObject.SetMemberFlashBool("secondary", false);
	
		if(index == RPT_NotWorking - 1 && value == 1) 
		{
			SendGFXNotWorkingCategories();
			m_flashValueStorage.SetFlashString("panel.mod.report.setup.form", "notworking");
		}
		else 
			m_flashValueStorage.SetFlashString("panel.mod.report.setup.form", "default");
			
		m_flashValueStorage.SetFlashObject("panel.mod.report.radio.clicked", l_flashSubObject);
			
	}
	
	function OnReportSecondaryClicked(index:int, value:int):void
	{
		var l_flashSubObject   : CScriptedFlashObject;
	
		if (value == 2)
			value = 0;
			
		if (value == 1)
			m_reportSecondaryIndex = index;
		
		l_flashSubObject = m_flashValueStorage.CreateTempFlashObject();
		
		l_flashSubObject.SetMemberFlashInt("index", index);
		l_flashSubObject.SetMemberFlashInt("value", value);
		l_flashSubObject.SetMemberFlashBool("secondary", true);
		
		m_flashValueStorage.SetFlashObject("panel.mod.report.radio.clicked", l_flashSubObject);
	}
	
	event  OnUseTextInput(title : string, placeholder : string, current : string, inputScope : EVirtualKeyboardInputScope)
	{
		
		
		
		
		
		var config : SVirtualKeyboardConfig;
	
		if(!m_textInputStateMachine)
		{
			m_textInputStateMachine = new CR4VirtualTextInputStates in this;
		}
		
		config.inputScope = inputScope;
		if(StrLen(title) == 0)
			config.titleStr = "";
		else if (StrLen(title) > 0 && !StrBeginsWith(title, "["))
			config.titleStr = title;
		else
			config.titleStr = GetLocStringByKeyExt(title);
			
		if(StrLen(current) > 0)
			config.defaultStr = current;
		else if(StrLen(placeholder) == 0)
			config.defaultStr = "";
		else if (StrLen(placeholder)  > 0 && !StrBeginsWith(placeholder, "["))
			config.defaultStr = placeholder;
		else
			config.defaultStr = GetLocStringByKeyExt(placeholder);
		
		LogChannel('MODS', "Text Input opened");
		m_textInputStateMachine.OnTextInputOpened(config, this, m_flashValueStorage);
	} 
	
	event  OnLogoutRequested() : void
	{
		var popupData : W3SignoutConfirmPopupData;
		
		popupData = new W3SignoutConfirmPopupData in this;
		
		popupData.SetupTexts();
		popupData.m_stateMachine = m_modStateMachine;
	
		LogChannel('MODS', "Logout requested");
		RequestSubMenu('PopupMenu', popupData);
	}
	
	
	
	
	
	event  OnBrowseMenuOpen(optional update : bool)
	{
		var l_ModArray : array<SModioModData>;

		StartLoadingIndicator("browse");
		m_modHandler.RefreshSubmittedModRatings();
		m_modHandler.GetRemoteModDataList(l_ModArray);
		OnBrowseModDataGot(l_ModArray, update);
		PushPageInformation(EMFI_Browse);
	}

	private function TrimModListForBrowse(out modArray : array<SModioModData>) 
	{
		while(modArray.Size() > 15)
		{
			modArray.Erase(15);
		}
	}
	
	event  OnBrowseModDataGot(modArray : array<SModioModData>, update : bool)
	{
		var l_flashSubArray   : CScriptedFlashArray;
		
		TrimModListForBrowse(modArray);
		m_remoteModData = modArray;
		
		l_flashSubArray = m_flashValueStorage.CreateTempFlashArray();
		GetGFxBrowseModsStruct(l_flashSubArray);
		
		if(update)
			m_flashValueStorage.SetFlashArray( "panel.mod.browse.update_data", l_flashSubArray);
		else
			m_flashValueStorage.SetFlashArray( "panel.mod.browse.setup", l_flashSubArray);
		m_flashValueStorage.SetFlashInt("mods.update.mods.found", m_modHandler.GetLastFilteredResultCount());
		SendGFxFilterStruct(m_browseFilters);
		StopLoadingIndicator("browse");
		LogChannel('MODS', "Browse menu data received with a count of " + modArray.Size());
	}
	
	public function SetTagInfos(filterIndex : EModFilterIndex, modTagInfos : array< SModTagInfo >)
	{
		var filters : CModFilterData = GetCurrentFilterData(filterIndex);
		filters.m_modTagInfos = modTagInfos;
		SendGFxFilterStruct(filters);
	}
	
	private function SendGFxFilterStruct(filters : CModFilterData) : void
	{
		var l_flashSubArray   : CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		var l_GroupTag				: string;
		var l_Label					: string;
		
		var i					: int;
		var j 					: int;
		var catArr				: array<string>;
		var catIdArr			: array<int>;
		var arr					: array<string>;
		var tagInfo				: SModTagInfo;
		var enabledCount		: int;
		var filterIndex			: EModFilterIndex = GetFilterDataIndex(filters);
				
		arr.PushBack("mods_filters_sort_by_id");
		arr.PushBack("mods_filters_sort_by_load_order");
		arr.PushBack("mods_filters_sort_by_downloads_today");
		arr.PushBack("mods_filters_sort_by_subscribers");
		arr.PushBack("mods_filters_sort_by_rating");
		arr.PushBack("mods_filters_sort_by_release");
		arr.PushBack("mods_filters_sort_by_update");
		arr.PushBack("mods_filters_sort_by_downloads_total");
		arr.PushBack("mods_filters_sort_by_name");
		catIdArr.PushBack(arr.Size());
		
		arr.PushBack("mods_filters_sort_ascending"); 
		arr.PushBack("mods_filters_sort_descending");
		catIdArr.PushBack(arr.Size());

		
		
		
		catArr.PushBack("mods_filters_sort_method");
		catArr.PushBack("mods_filters_sort_direction");
		
		
		
		l_flashSubArray = m_flashValueStorage.CreateTempFlashArray();
		
		
		for( i = 0; i < arr.Size(); i+= 1 )
		{
			if(i == 0 || i == 8 || (i == 1 && filterIndex == 1))
				continue;
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
				
			for( j = 0; j < catIdArr.Size(); j+= 1 )
			{
				if(i < catIdArr[j])
				{
					l_GroupTag = catArr[j];
					break;
				}
			}
				
			l_DataFlashObject.SetMemberFlashBool(  "radio",  j <= 2 );
			l_DataFlashObject.SetMemberFlashString(  "dropDownLabel", GetLocStringByKeyExt(l_GroupTag) );
			l_DataFlashObject.SetMemberFlashString(  "categoryPostfix", " | " + 1 + " |" ); 
			l_DataFlashObject.SetMemberFlashUInt(  "dropDownTag", i );
			l_DataFlashObject.SetMemberFlashBool(  "dropDownOpened",  true );
			l_DataFlashObject.SetMemberFlashString(  "dropDownIcon", "icons/monsters/ICO_MonsterDefault.png" );
			l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt(arr[i]));
			if(i < 9)
			{
				if(i == filters.m_filterSortType)
					l_DataFlashObject.SetMemberFlashInt(  "value", 1);
				else
					l_DataFlashObject.SetMemberFlashInt(  "value", 0);
			}
			else if (i < 11)
			{
				if(i - 9 == filters.m_filterSortDirection)
					l_DataFlashObject.SetMemberFlashInt(  "value", 1);
				else
					l_DataFlashObject.SetMemberFlashInt(  "value", 0);
			}
			else
			{
				if(i - 11 == filters.m_view)
					l_DataFlashObject.SetMemberFlashInt("value", 1);
				else
					l_DataFlashObject.SetMemberFlashInt("value", 0);
			}
			l_DataFlashObject.SetMemberFlashInt("index",i);
			l_DataFlashObject.SetMemberFlashInt("filterIndex", (int)filterIndex);
			if(j == 0)
				l_DataFlashObject.SetMemberFlashInt("sortTag", -1);
			else
				l_DataFlashObject.SetMemberFlashInt("sortTag", -2);
			
			l_flashSubArray.PushBackFlashObject(l_DataFlashObject);
		}
		
		
		for( i = 0; i < filters.m_modTagInfos.Size(); i+= 1 )
		{
			tagInfo = filters.m_modTagInfos[i];
			
			l_GroupTag = m_modHandler.GetLocalizedGroupNameFromTagInfo(tagInfo);
				
			for( j = 0; j < tagInfo.tagGroupValues.Size(); j+= 1 )
			{
				l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
				l_Label = m_modHandler.GetLocalizedTagNameFromTagInfo(tagInfo, tagInfo.tagGroupValues[j]);
				enabledCount = GetEnabledTagCountForCategory(filters, i);
			
				l_DataFlashObject.SetMemberFlashBool(  "radio",  !tagInfo.allowMultipleSelect );
				l_DataFlashObject.SetMemberFlashString(  "dropDownLabel", l_GroupTag );
				if(enabledCount > 0)
					l_DataFlashObject.SetMemberFlashString(  "categoryPostfix", " | " + enabledCount + " |" );
				else
					l_DataFlashObject.SetMemberFlashString(  "categoryPostfix", "" );
				l_DataFlashObject.SetMemberFlashUInt(  "dropDownTag",  GetIndexForTag(i, j) ); 
				l_DataFlashObject.SetMemberFlashBool(  "dropDownOpened",  true );
				l_DataFlashObject.SetMemberFlashString(  "dropDownIcon", "icons/monsters/ICO_MonsterDefault.png" );
				l_DataFlashObject.SetMemberFlashString(  "label", l_Label);
				if(IsTagEnabled(filters, i, j))
					l_DataFlashObject.SetMemberFlashInt( "value", 1 );
				else if(IsTagExcluded(filters, i, j))
					l_DataFlashObject.SetMemberFlashInt( "value", 2 );
				else
					l_DataFlashObject.SetMemberFlashInt( "value", 0 );
				l_DataFlashObject.SetMemberFlashInt("index", GetIndexForTag(i, j));
				l_DataFlashObject.SetMemberFlashInt("filterIndex", (int)filterIndex);
				l_DataFlashObject.SetMemberFlashInt("sortTag", i);
				l_flashSubArray.PushBackFlashObject(l_DataFlashObject);
			}			
		}
		m_flashValueStorage.SetFlashArray(GetCurrentFilterDataBindingKey(filterIndex), l_flashSubArray);
		LogChannel('MODS', "Filters received");
	}
	
	function SendGFXReportCategories():void
	{
		var l_flashSubArray   		: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		var l_GroupTag				: string;
		var l_Label					: string;
		
		var i					: int;
		var arr					: array<string>;
		
		arr.PushBack("mods_report_dd_dmca");
		arr.PushBack("mods_report_dd_not_working");
		arr.PushBack("mods_report_dd_inappropriate");
		arr.PushBack("mods_report_dd_illegal");
		arr.PushBack("mods_report_dd_stolen");
		arr.PushBack("mods_report_dd_false");
		arr.PushBack("mods_report_dd_other");
		
		l_flashSubArray = m_flashValueStorage.CreateTempFlashArray();
		if(m_reportCategoryIndex != -1)
			l_GroupTag = GetLocStringByKeyExt(arr[m_reportCategoryIndex]);
		
		
		l_GroupTag = GetLocStringByKeyExt("mods_report_reason");
		for( i = 0; i < arr.Size(); i+= 1 )
		{
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
				
			l_Label = GetLocStringByKeyExt(arr[i]);
				
			l_DataFlashObject.SetMemberFlashBool(  "radio",  true );
			l_DataFlashObject.SetMemberFlashString(  "dropDownLabel", l_GroupTag );
			l_DataFlashObject.SetMemberFlashString(  "categoryPostfix", "" );
			
			l_DataFlashObject.SetMemberFlashUInt(  "dropDownTag", -1 );
			l_DataFlashObject.SetMemberFlashBool(  "dropDownOpened",  false );
			l_DataFlashObject.SetMemberFlashString(  "dropDownIcon", "icons/monsters/ICO_MonsterDefault.png" );
			l_DataFlashObject.SetMemberFlashString(  "label", l_Label); 
			if(m_reportCategoryIndex == i)
				l_DataFlashObject.SetMemberFlashInt(  "value", 1);
			else
				l_DataFlashObject.SetMemberFlashInt(  "value", 0);
			l_DataFlashObject.SetMemberFlashInt("index",i);
			l_DataFlashObject.SetMemberFlashInt("category",1);
			
			
			l_flashSubArray.PushBackFlashObject(l_DataFlashObject);
		}
		m_flashValueStorage.SetFlashArray( "mods.report.reasons.list", l_flashSubArray);	
	}
	
	function SendGFXNotWorkingCategories():void
	{
		var l_flashSubArray   : CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		var l_GroupTag				: string;
		var l_Label					: string;
		
		var i					: int;
		var arr					: array<string>;
		
		arr.PushBack("mods_report_dd_crashes");
		arr.PushBack("mods_report_dd_no_load");
		arr.PushBack("mods_report_dd_conflict");
		arr.PushBack("mods_report_dd_missing");
		arr.PushBack("mods_report_dd_installation");
		arr.PushBack("mods_report_dd_buggy");
		arr.PushBack("mods_report_dd_incompatible");
		arr.PushBack("mods_report_dd_corrupted");
		
		l_flashSubArray = m_flashValueStorage.CreateTempFlashArray();
		
		l_GroupTag = GetLocStringByKeyExt("mods_report_reason_not_working");
		if(m_reportSecondaryIndex != -1)
			l_GroupTag = GetLocStringByKeyExt(arr[m_reportSecondaryIndex]);
		
		for( i = 0; i < arr.Size(); i+= 1 )
		{
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
				
			l_Label = GetLocStringByKeyExt(arr[i]);
				
			l_DataFlashObject.SetMemberFlashBool(  "radio",  true );
			l_DataFlashObject.SetMemberFlashString(  "dropDownLabel", l_GroupTag );
			l_DataFlashObject.SetMemberFlashString(  "categoryPostfix", "" );
			
			l_DataFlashObject.SetMemberFlashUInt(  "dropDownTag", -2 );
			l_DataFlashObject.SetMemberFlashBool(  "dropDownOpened",  false );
			l_DataFlashObject.SetMemberFlashString(  "dropDownIcon", "icons/monsters/ICO_MonsterDefault.png" );
			l_DataFlashObject.SetMemberFlashString(  "label", l_Label); 
			if(m_reportSecondaryIndex == i)
				l_DataFlashObject.SetMemberFlashInt(  "value", 1);
			else
				l_DataFlashObject.SetMemberFlashInt(  "value", 0);
			l_DataFlashObject.SetMemberFlashInt("index",i);
			l_DataFlashObject.SetMemberFlashInt("category",2);
			
			
			l_flashSubArray.PushBackFlashObject(l_DataFlashObject);
		}
		m_flashValueStorage.SetFlashArray( "mods.report.secondary.list", l_flashSubArray);	
	}
	
	public function GetCurrentFilterData(filterIndex : EModFilterIndex) : CModFilterData
	{
		
		if(filterIndex == 1)
			return m_browseFilters;
		else
			return m_installedFilters;
	}

	public function GetCurrentFilterDataBindingKey(filterIndex : EModFilterIndex) : string
	{
		
		if(filterIndex == 1)
			return "mods.filters.list";
		else
			return "mods.filters.list.installed";
	}

	public function GetFilterDataIndex(filter : CModFilterData) : int
	{
		
		if(filter == m_browseFilters)
			return 1;
		else if (filter == m_installedFilters)
			return 2;
		
		return 0;
	}

	private function DecideFilterAction(filterIndex : EModFilterIndex)
	{
		var filters : CModFilterData = GetCurrentFilterData(filterIndex);

		if(filterIndex == 1)
			SearchWithFilterParams(filters, false);
		else if(filters.m_filtersChanged)
		{
			OnInstalledMenuOpen();
		}
	}

	event  OnResetFilters(filterIndex : EModFilterIndex)
	{
		var filters : CModFilterData = GetCurrentFilterData(filterIndex);

		filters.m_filtersChanged = filters.m_searchWords.Size() > 0 || filters.m_appliedTags.Size() > 0 || filters.m_excludedTags.Size() > 0;
		filters.m_searchWords.Clear();
		filters.m_appliedTags.Clear();
		filters.m_excludedTags.Clear();
		SendGFxFilterStruct(filters);
		OnApplyFilters(filterIndex);
	}
	
	event  OnApplyFilters(filterIndex : EModFilterIndex)
	{
		var filters : CModFilterData = GetCurrentFilterData(filterIndex);
		filters.m_currentPage = 1;
		DecideFilterAction(filterIndex);
		PostAppliedFilters();
	}
	
	private function GetIndexForTag(i:int, j:int):int
	{
		var test: int;
		
		return 10 + i * 50 + j;
	}
	
	private function GetTagForIndex(filters : CModFilterData, index:int):string
	{
		var i : int;
		var j : int;
		j = (index - 10) % 50;
		i = (index - 10) / 50;
		
		if(filters.m_modTagInfos.Size() <= i || filters.m_modTagInfos[i].tagGroupValues.Size() <= j)
			return "INVALID";
		
		return filters.m_modTagInfos[i].tagGroupValues[j];
	}
	
	private function IsTagEnabled(filters : CModFilterData, i:int, j:int):bool
	{
		var index: int;
		var k : int;
		
		index = GetIndexForTag(i, j);
		for(k = 0; k < filters.m_appliedTags.Size(); k+=1)
		{
			if (filters.m_appliedTags[k] == index)
				return true;
		}
		return false;
	}
	
	private function IsTagExcluded(filters : CModFilterData,i:int, j:int):bool
	{
		var index: int;
		var k : int;
		
		index = GetIndexForTag(i, j);
		for(k = 0; k < filters.m_excludedTags.Size(); k+=1)
		{
			if (filters.m_excludedTags[k] == index)
				return true;
		}
		return false;
	}
	
	private function GetEnabledTagCountForCategory(filters : CModFilterData, i:int):int
	{
		var k : int;
		var count : int;
	
		if(filters.m_modTagInfos.Size() <= i)
			return -1;
			
		for(k = 0; k < filters.m_modTagInfos[i].tagGroupValues.Size(); k+=1)
		{
			if (IsTagEnabled(filters, i, k) || IsTagExcluded(filters, i, k))
				count+=1;
		}
		
		return count;
	}
	
	private function GetGFxBrowseModsStruct(out StructGFx : CScriptedFlashArray) : void
	{
		var i				  : int;
		var l_flashObject     : CScriptedFlashObject;
			
		for ( i = 0; i < m_remoteModData.Size(); i += 1 )
		{
			l_flashObject = m_flashValueStorage.CreateTempFlashObject();
			GetGFxBrowsePreviewItem(i, l_flashObject);
			StructGFx.PushBackFlashObject(l_flashObject);
		}
	}
	
	private function GetGFxBrowsePreviewItem( index : int, out GFxObjectData:CScriptedFlashObject):void
	{
		ConvertModDataToScaleform(m_remoteModData[index], GFxObjectData);
		GFxObjectData.SetMemberFlashUInt("id", index);
	}
	
	protected function GetPageInformation(filterData : CModFilterData, out GFxObjectData:CScriptedFlashObject):void
	{
		filterData.m_maxPages = m_modHandler.GetLastFilteredPageCount();
		GFxObjectData.SetMemberFlashInt("numPages", filterData.m_maxPages);
		GFxObjectData.SetMemberFlashInt("currentPage", filterData.m_currentPage);
	}
	
	protected function PushPageInformation(filterIndex:EModFilterIndex):void
	{
		var l_flashObject     : CScriptedFlashObject;
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		GetPageInformation(GetCurrentFilterData(filterIndex), l_flashObject);

		if(filterIndex == EMFI_Browse)
			m_flashValueStorage.SetFlashObject( "panel.mod.browse.pages.setup", l_flashObject);
	}
	
	event  OnPageClick(filterIndex : EModFilterIndex, page : int)
	{
		var filters : CModFilterData = GetCurrentFilterData(filterIndex);

		LogChannel('MODS', "On Page Click");
		filters.m_currentPage = page;
		SearchWithFilterParams(GetCurrentFilterData(1), true, true);
	}
	
	event  OnSubscribeModDetails()
	{
		var l_flashSubArray   : CScriptedFlashArray;
		var lastItem : SModDetailsData = GetLastDetailsItem();
	
		if (m_lastGotModValid)
		{
			LogChannel('MODS', "Subscribe Mod from Details page");
			m_modHandler.SubscribeMod(lastItem.data.id);
		}		
	}
	
	event  OnSubscribeMod( index : int )
	{
		var l_flashSubArray   : CScriptedFlashArray;
		
		LogChannel('MODS', "Subscribe Mod");
		m_modHandler.SubscribeMod(m_remoteModData[index].id);
		
		
		
		
		
		
	}
	
	event  OnMoreFromAuthor()
	{
		var filters : CModFilterData = GetCurrentFilterData(EMFI_Browse);
		var lastItem : SModDetailsData = GetLastDetailsItem();

		LogChannel('MODS', "More from author");
		filters.m_cachedParams.author = lastItem.data.uploaderUser;
		filters.m_currentPage = 1;
		filters.m_filtersChanged = true;
		SearchWithFilterParams(filters, true, true);
	}
	
	event OnCategoryOpened( categoryName : int, opened : bool )
	{
		var l_flashSubObject   : CScriptedFlashObject;
	
		if (categoryName == -1)
		{
			l_flashSubObject = m_flashValueStorage.CreateTempFlashObject();
			l_flashSubObject.SetMemberFlashBool("opened", opened);
			l_flashSubObject.SetMemberFlashString("type", "primary");
			m_flashValueStorage.SetFlashObject( "panel.mod.report.position.bg", l_flashSubObject);
		}
		else if (categoryName == -2)
		{
			l_flashSubObject = m_flashValueStorage.CreateTempFlashObject();
			l_flashSubObject.SetMemberFlashBool("opened", opened);
			l_flashSubObject.SetMemberFlashString("type", "secondary");
			m_flashValueStorage.SetFlashObject( "panel.mod.report.position.bg", l_flashSubObject);
		}
		else
		{
			
		}
	}
	
	event  OnSearchInputClear(filterIndex:EModFilterIndex)
	{	
		var filters : CModFilterData = GetCurrentFilterData(filterIndex);
		filters.m_searchWords.Clear();
	}
	
	event  OnSearchInputAddWord(filterIndex:EModFilterIndex, word:string)
	{
		var filters : CModFilterData = GetCurrentFilterData(filterIndex);
		filters.m_searchWords.PushBack(word);
	}
	
	event  OnSearchInputTextFinalized(filterIndex:EModFilterIndex)
	{
		var filters : CModFilterData = GetCurrentFilterData(filterIndex);
		filters.m_filtersChanged = true;
	}
	
	event  OnFilterCheckboxClicked( filterIndex : EModFilterIndex, index:int, value:int )
	{		
		var l_flashSubArray   : CScriptedFlashArray;
		var filters : CModFilterData = GetCurrentFilterData(filterIndex);
		
		filters.m_filtersChanged = true;
		
		if(value == 1)
		{
			filters.m_appliedTags.PushBack(index);
			filters.m_excludedTags.Remove(index);
		}
		else if(value == 2)
		{
			filters.m_appliedTags.Remove(index);
			filters.m_excludedTags.PushBack(index);
		}
		else
		{
			filters.m_appliedTags.Remove(index);
			filters.m_excludedTags.Remove(index);
		}
	}
	
	event  OnRadioClicked( filterIndex:EModFilterIndex, index:int, value:int, category:int )
	{		
		var l_flashSubArray   : CScriptedFlashArray;
		var i : int;
		var j : int;
		var altIndex : int;
		var l_flashObject     : CScriptedFlashObject;
		var filters : CModFilterData = GetCurrentFilterData(filterIndex);
		
		if(category == 1)
		{
			OnReportReasonClicked(index, value);
			return false;
		}
		else if (category == 2)
		{
			OnReportSecondaryClicked(index, value);
			return false;
		}
			
		
		filters.m_filtersChanged = true;
		
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		
		if(index < 13 && value == 2)
			value = 1;

		l_flashObject.SetMemberFlashInt("index", index);
		l_flashObject.SetMemberFlashInt("value", value);
		l_flashObject.SetMemberFlashInt("filterIndex", (int)filterIndex);
		m_flashValueStorage.SetFlashObject("panel.mod.filters.radio.clicked", l_flashObject);
		
		switch(index)
		{
			case 0: filters.m_filterSortType = MFST_ID; break;
			case 1: filters.m_filterSortType = MFST_LoadOrder; break;
			case 2: filters.m_filterSortType = MFST_DownloadsToday; break;
			case 3: filters.m_filterSortType = MFST_SubscriberCount; break;
			case 4: filters.m_filterSortType = MFST_Rating; break;
			case 5: filters.m_filterSortType = MFST_DateMarkedLive; break;
			case 6: filters.m_filterSortType = MFST_DateUpdated; break;
			case 7: filters.m_filterSortType = MFST_DownloadsTotal; break;
			case 8: filters.m_filterSortType = MFST_Alphabetical; break;
			case 9: filters.m_filterSortDirection = MFSD_Ascending; break;
			case 10: filters.m_filterSortDirection = MFSD_Descending; break;
			case 11: filters.m_view = EMVM_Grid; break;
			case 12: filters.m_view = EMVM_List; break;
		}
		
		if(index >= 13)
		{
			i = (index - 10) / 50;
			if (i < filters.m_modTagInfos.Size())
			{
				for(j = 0; j < filters.m_modTagInfos[i].tagGroupValues.Size(); j+= 1)
				{
					if(value == 1)
					{
						altIndex = GetIndexForTag(i, j);
						filters.m_appliedTags.Remove(altIndex);
					}
				}
				if(value == 1)
				{
					filters.m_appliedTags.PushBack(index);
					filters.m_excludedTags.Remove(index);
				}
				else if (value == 2)
				{
					filters.m_appliedTags.Remove(index);
					filters.m_excludedTags.PushBack(index);
				}
				else
				{
					filters.m_appliedTags.Remove(index);
					filters.m_excludedTags.Remove(index);
				}
			}
			
		}
	}

	private function CreateCachedParams(filters : CModFilterData, optional useCached: bool):void
	{
		var params : SModFilterParams;
		var i : int;
		var tag : string;
		var pageElemCount : int;
			
		pageElemCount = 15;

		if(filters == m_installedFilters)
			pageElemCount = 100;
		
		if(!useCached)
			filters.m_filtersChanged = false;
		
		if(useCached)
		{
			params = filters.m_cachedParams;
		}
		else
		{
			params.sortDirection = filters.m_filterSortDirection;
			params.sortType = filters.m_filterSortType;
			
			for(i = 0; i < filters.m_appliedTags.Size(); i+=1)
			{
				tag = GetTagForIndex(filters, filters.m_appliedTags[i]);
				if (tag != "INVALID")
					params.allowedTags.PushBack(tag);
			}
			
			for(i = 0; i < filters.m_excludedTags.Size(); i+=1)
			{
				tag = GetTagForIndex(filters, filters.m_excludedTags[i]);
				if (tag != "INVALID")
					params.excludedTags.PushBack(tag);
			}
				
			params.filterStrings = filters.m_searchWords;
		}
		
		params.isPaged = true;
		params.elementCount = pageElemCount;
		params.startIndex = (filters.m_currentPage - 1);
		
		filters.m_cachedParams = params;
	}
	
	private function SearchWithFilterParams(filters : CModFilterData, pageSwap : bool, optional useCached: bool):void
	{
		var params : SModFilterParams;
		var i : int;
		var tag : string;
		var pageElemCount : int;
		
		if(!filters.m_filtersChanged && !pageSwap)
			return;
			
		LogChannel('MODS', "Search with filter params");
			
		CreateCachedParams(filters, useCached);
		
		m_modStateMachine.OnRefreshWithParams(filters.m_cachedParams);
	}
	
	
	
	
	
	event  OnInstalledMenuOpen()
	{
		var l_ModArray : array<SModioModData>;

		if( m_installedFilters.m_modTagInfos.Size() == 0 )
				m_modStateMachine.OnGetFilterTags(EMFI_Installed);

		StartLoadingIndicator("library");
		CreateCachedParams(m_installedFilters, false);
		PostAppliedFilters();

		
		m_modHandler.RefreshSubmittedModRatings();
		m_modHandler.GetInstalledModList(m_installedFilters.m_cachedParams, l_ModArray, true);
		OnInstalledModDataGot(l_ModArray);
	}

	public function PostAppliedFilters()
	{
		var l_flashObject     : CScriptedFlashObject;
		var noAllowed : bool = m_installedFilters.m_cachedParams.allowedTags.Size() == 0;
		var noExcluded : bool = m_installedFilters.m_cachedParams.excludedTags.Size() == 0;
		var noFilters : bool = m_installedFilters.m_cachedParams.filterStrings.Size() == 0;
		var noAuthor : bool = !theGame.GetModHandlerSystem().IsModioUserValid(m_installedFilters.m_cachedParams.author);
		var isAnyFilterApplied : bool = !(noAllowed && noExcluded && noFilters && noAuthor);

		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashBool("isAnyFilterApplied", isAnyFilterApplied);
		l_flashObject.SetMemberFlashInt("sortingType", (int)m_installedFilters.m_cachedParams.sortType);
		m_flashValueStorage.SetFlashObject("panel.mod.filters.updated", l_flashObject);
	}
	
	public function OnInstalledModDataGot(modList : array<SModioModData>)
	{
		var l_flashSubArray   : CScriptedFlashArray;
		
		m_libraryModData = modList;
		RefreshModOrder();
		
		l_flashSubArray = m_flashValueStorage.CreateTempFlashArray();
		GetGFxInstalledModsStruct(l_flashSubArray);
		
		m_flashValueStorage.SetFlashArray( "panel.mod.installed.setup", l_flashSubArray);
		StopLoadingIndicator("library");
		
		LogChannel('MODS', "Installed mods data received with a fcount of " + modList.Size());
	}
	
	private function GetGFxInstalledModsStruct(out StructGFx : CScriptedFlashArray) : void
	{
		var i				  : int;
		var l_flashObject     : CScriptedFlashObject;
		
		for ( i = 0; i < m_libraryModData.Size(); i += 1 )
		{
			l_flashObject = m_flashValueStorage.CreateTempFlashObject();
			GetGFxLibraryPreviewItem(i, l_flashObject);
			StructGFx.PushBackFlashObject(l_flashObject);
		}
	}
	
	private function GetGFxLibraryPreviewItem( index : int, out GFxObjectData:CScriptedFlashObject):void
	{
		ConvertModDataToScaleform(m_libraryModData[index], GFxObjectData);
		GFxObjectData.SetMemberFlashUInt("id", index);
	}
	
	event  OnRequestInstalledModData( index:int )
	{		
		var l_flashObject     : CScriptedFlashObject;
		
		
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		
		if(m_libraryModData.Size() == 0)
			return false;
		m_lastSelectedLibraryIndex = m_libraryModData[index].id;
		GetGFxLibraryPreviewItem(index, l_flashObject);
		
		m_flashValueStorage.SetFlashObject("panel.mod.details.setup",l_flashObject);
	}
	
	private function UpdateInstalledModsData( needListUpdate: bool ) : void
	{
		var l_flashSubArray   : CScriptedFlashArray;
		var l_ModArray : array<SModioModData>;
		
		if( needListUpdate )
		{
			m_modHandler.GetInstalledModList(m_installedFilters.m_cachedParams, l_ModArray, false);
			m_libraryModData = l_ModArray;
			RefreshModOrder();
		}
		
		LogChannel('MODS', "Installed list size is " + m_libraryModData.Size() );
		
		l_flashSubArray = m_flashValueStorage.CreateTempFlashArray();
		GetGFxInstalledModsStruct(l_flashSubArray);
		m_flashValueStorage.SetFlashArray( "panel.mod.installed.update_data", l_flashSubArray);
	}
	
	event  OnLibraryModCheckboxClicked( index:int, enabled:bool )
	{		
		m_modHandler.SetLocalModDisabled(this.m_libraryModData[index].id, !enabled);
			
		UpdateInstalledModsData(false);
	}
	
	event  OnUnsubscribeInstalledMod( index:int )
	{					
		OnUnsubscribeConfirm(m_libraryModData[index].id);	
	}
	
	event  OnUnsubscribeInstalledModDetails()
	{
		var lastItem : SModDetailsData = GetLastDetailsItem();
		if(m_lastGotModValid) {			
			OnUnsubscribeConfirm(lastItem.data.id);
		}
	}
	
	event  OnUnsubscribeConfirm( modid:SModioModID )
	{
		
		var popupData : W3UninstallConfirmPopupData;

		popupData = new W3UninstallConfirmPopupData in this;
		popupData.SetMenuRef(this);
		popupData.SetModid(modid);
		popupData.SetupTexts();

		RequestSubMenu('PopupMenu', popupData);
	}

	event  OnModOrderChange( index:int, orderUp:bool )
	{
		var l_flashObject : CScriptedFlashObject = m_flashValueStorage.CreateTempFlashObject();
		var l_ModArray : array<SModioModData>;
		var updatedIndex : int = ChangeModOrder(m_libraryModData[index].id, m_installedFilters.m_cachedParams.sortDirection == MFSD_Ascending ? orderUp : !orderUp);
		var indexToUse : int = m_installedFilters.m_cachedParams.sortDirection == MFSD_Ascending ? updatedIndex : m_libraryModData.Size() - 1 - updatedIndex;

		m_modHandler.GetInstalledModList(m_installedFilters.m_cachedParams, l_ModArray, true);
		OnInstalledModDataGot(l_ModArray);

		SelectInstalledModByModid(m_libraryModData[indexToUse].id);
		l_flashObject.SetMemberFlashInt("index", indexToUse);
		l_flashObject.SetMemberFlashBool("orderUp", orderUp);
		m_flashValueStorage.SetFlashObject( "panel.mod.installed.update_order", l_flashObject);
	}

	public function UnsubscribeConfirmed( modid:SModioModID )
	{
		LogChannel('MODS', "Unsubscribe " + m_modHandler.ConvertModIDToString(modid));
		m_modHandler.UnsubscribeMod(modid);
		
		OnInstalledMenuOpen();
	}

	public function SelectInstalledModByModid( modid:SModioModID )
	{
		var flashObject : CScriptedFlashObject;
		var modidStr : string;

		modidStr = m_modHandler.ConvertModIDToString(modid);
		flashObject = m_flashValueStorage.CreateTempFlashObject();

		flashObject.SetMemberFlashString("modid", modidStr);
		flashObject.SetMemberFlashInt("counter", m_installedSelectModCallCount); 

		m_installedSelectModCallCount += 1;

		m_flashValueStorage.SetFlashObject("panel.mod.installed.select.mod.by.modid", flashObject);
	}

	public function SelectInstalledModById( id:int )
	{
		var flashObject : CScriptedFlashObject;

		flashObject = m_flashValueStorage.CreateTempFlashObject();

		flashObject.SetMemberFlashInt("id", id);
		flashObject.SetMemberFlashInt("counter", m_installedSelectModCallCount); 

		m_installedSelectModCallCount += 1;

		m_flashValueStorage.SetFlashObject("panel.mod.installed.select.mod.by.id", flashObject);
	}
	
	
	
	
	
	private function GetGFxModDetailsStruct(index:string) : void
	{
		var l_flashObject     : CScriptedFlashObject;
		
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		
		StartLoadingIndicator("details");
		m_modStateMachine.OnGetModData(m_modHandler.CreateModIDFromString(index));
	}

	private function ReplaceModDetailsItem(detailsData : SModDetailsData):void
	{
		var i : int = 0;

		for(i = 0; i < m_lastGotModDataList.Size(); i+= 1)
		{
			if(m_lastGotModDataList[i].data.id == detailsData.data.id)
			{
				m_lastGotModDataList[i] = detailsData;
				return;
			}
		}
	}
	
	public function GetModDetailsItem( data : SModioModData, rating:EModRatingType, dependencies:array<SModDependency>, optional update : bool):void
	{
		var GFxObjectData :CScriptedFlashObject;
		var GFxObjectArray :CScriptedFlashArray;
		var GFxObjectSubData :CScriptedFlashObject;
		var i : int = 0;
		var detailsData : SModDetailsData;
		
		detailsData.data = data;
		detailsData.rating = rating;
		detailsData.dependencies = dependencies;

		if(update)
		{
			ReplaceModDetailsItem(detailsData);
		}
		else if(!m_blockModDataDetailsPushOnce)
		{
			m_lastGotModDataList.PushBack(detailsData);
			m_lastGotModValid = true;
			if(m_lastGotModDataList.Size() > 1)
				m_fxEnableCloseAllButton.InvokeSelfOneArg(FlashArgBool(true));
		}
		m_blockModDataDetailsPushOnce = false;
		GFxObjectData = m_flashValueStorage.CreateTempFlashObject();

		GFxObjectArray = m_flashValueStorage.CreateTempFlashArray();
		for(i = 0; i < dependencies.Size(); i+= 1)
		{
			GFxObjectSubData = m_flashValueStorage.CreateTempFlashObject();
			GFxObjectSubData.SetMemberFlashString("modName", dependencies[i].displayName);
			GFxObjectSubData.SetMemberFlashString("modid", m_modHandler.ConvertModIDToString(dependencies[i].id));
			GFxObjectArray.PushBackFlashObject(GFxObjectSubData);
		}
		
		ConvertModDataToScaleform(data, GFxObjectData);
		GFxObjectData.SetMemberFlashArray("dependencies", GFxObjectArray);
		GFxObjectData.SetMemberFlashBool("upvoted", rating == MRT_Upvote);
		GFxObjectData.SetMemberFlashBool("downvoted", rating == MRT_Downvote);
		
		if(update)
			m_flashValueStorage.SetFlashObject( "panel.mod.details.data.update", GFxObjectData);
		else
			m_flashValueStorage.SetFlashObject( "panel.mod.details.data", GFxObjectData);
		StopLoadingIndicator("details");
		LogChannel('MODS', "Mod details have been received for " + m_modHandler.ConvertModIDToString(data.id));
	}

	event  OnRequestModDetails( id:string )
	{
		GetGFxModDetailsStruct(id);
	}

	public function GetLastDetailsItem() : SModDetailsData
	{
		return m_lastGotModDataList[m_lastGotModDataList.Size() - 1];
	}

	event  OnClearCachedDetails()
	{
		m_lastGotModDataList.Clear();
		m_fxCloseModDetails.InvokeSelf();
	}

	event  OnDetailsBack()
	{
		var id : string;
		var lastItem : SModDetailsData;
		if(m_lastGotModDataList.Size() > 1)
		{
			m_lastGotModDataList.Erase(m_lastGotModDataList.Size() - 1);

			lastItem = GetLastDetailsItem();

			m_blockModDataDetailsPushOnce = true;
			GetModDetailsItem(lastItem.data, lastItem.rating, lastItem.dependencies);

			if(m_lastGotModDataList.Size() == 1)
				m_fxEnableCloseAllButton.InvokeSelfOneArg(FlashArgBool(false));
		}
		else
		{
			CloseDetails();
		}
	}

	event  OnDetailsFullClose()
	{
		CloseDetails();
	}

	private function CloseDetails()
	{
		m_lastGotModDataList.Clear();
		m_fxCloseModDetails.InvokeSelf();
	}
	
	event  OnVotingStatusChanged( status:string )
	{
		var modid : SModioModID;
		var lastItem : SModDetailsData;
		
		if(m_lastGotModValid)
		{
			lastItem = GetLastDetailsItem();
			modid = lastItem.data.id;
		}
		else return false;
		
		LogChannel('MODS', "Voting status changed to " + status + " for " + m_modHandler.ConvertModIDToString(modid));
	
		if(status == "upvoted")
		{
			m_modHandler.UpvoteMod(modid);
		}
		else if (status == "downvoted")
		{
			m_modHandler.DownvoteMod(modid);
		}
		else if (status == "not_voted")
		{
			m_modHandler.ClearvoteMod(modid);
		}
	}
	
	
	
	
	
	public function ConvertModDataToScaleform(data : SModioModData, out GFxObjectData:CScriptedFlashObject):void
	{
		var l_TagArray : CScriptedFlashArray;
		var i : int;
	
		GFxObjectData.SetMemberFlashString("modid", m_modHandler.ConvertModIDToString(data.id));
		GFxObjectData.SetMemberFlashString("modName", data.displayname);
		GFxObjectData.SetMemberFlashString("modSummary", data.summary);
		GFxObjectData.SetMemberFlashString("modDesc", data.desc);
		GFxObjectData.SetMemberFlashString("modVersion", data.version);
		GFxObjectData.SetMemberFlashBool("visible", true);
		GFxObjectData.SetMemberFlashBool("enabled", !m_modHandler.IsLocalModDisabled(data.id));
		
		if(m_modHandler.IsModSubscribed(data.id))
			GFxObjectData.SetMemberFlashInt("state", 200);
		else
			GFxObjectData.SetMemberFlashInt("state", -1);
		GFxObjectData.SetMemberFlashInt("percent", 1);
		
		GFxObjectData.SetMemberFlashString("downloads", data.downloadsTotal);
		GFxObjectData.SetMemberFlashString("size", data.filesize);
		GFxObjectData.SetMemberFlashString("likes", data.upvotes);
		GFxObjectData.SetMemberFlashString("subscribers", data.subscribersTotal);
		
		if(data.uploaderPlatformLinked && theGame.GetPlatform() == Platform_PS5)
			GFxObjectData.SetMemberFlashString("platform", "ps");
		else if(data.uploaderPlatformLinked && (theGame.GetPlatform() == Platform_Xbox_SCARLETT_ANACONDA || theGame.GetPlatform() == Platform_Xbox_SCARLETT_LOCKHART))
			GFxObjectData.SetMemberFlashString("platform", "xbox");
		else 
			GFxObjectData.SetMemberFlashString("platform", "pc");
			
		GFxObjectData.SetMemberFlashString("author", data.uploaderUserName);
		GFxObjectData.SetMemberFlashString("firstUploadTime", data.uploadDate);
		GFxObjectData.SetMemberFlashString("lastUpdateTime", data.lastUpdateDate);
		
		l_TagArray = m_flashValueStorage.CreateTempFlashArray();
		for(i = 0; i < data.tags.Size(); i+= 1)
		{
			l_TagArray.PushBackFlashString(data.tags[i]);
		}
		GFxObjectData.SetMemberFlashArray("tags", l_TagArray);
		
		GFxObjectData.SetMemberFlashInt("gallerySize", data.galleryImgsURLs.Size());
	}

	event  OnOpenUrlByCode( urlCode : string )
	{
		var linkType : ETermsLinkType;

		if(urlCode == "pp")
			linkType = MLT_ModioPrivacy;
		else if (urlCode == "tos")
			linkType = MLT_ModioTerms;
		
		m_modStateMachine.OnOpenUrl(linkType);
	}
	
	event  OnReportMod( )
	{
		
		m_reportCategoryIndex = -1;
		m_reportSecondaryIndex = -1;
		m_reportDescription = "";
		SendGFXReportCategories();
	}

	event  OnCloseReportWindow( )
	{
		
		var popupData : W3CloseReportConfirmPopupData;

		popupData = new W3CloseReportConfirmPopupData in this;
		popupData.SetMenuRef(this);
		popupData.SetupTexts();

		RequestSubMenu('PopupMenu', popupData);
	}

	event  OnCloseReportWindowConfirmed( )
	{
		m_fxCloseReportWindow.InvokeSelf();
	}
	
	event  OnHideMod( id:string )
	{
		var popupData : W3HideModConfirmPopupData;

		popupData = new W3HideModConfirmPopupData in this;
		popupData.SetMenuRef(this);
		popupData.SetModid(id);
		popupData.SetupTexts();

		RequestSubMenu('PopupMenu', popupData);
	}

	public function OnHideModConfirmed ( id : string)
	{
		var modid : SModioModID;
		
		modid = m_modHandler.CreateModIDFromString(id);
		
		LogChannel('MODS', "OnHideMod " + id);
		this.m_modStateMachine.OnHideMod(modid);
	}
	
	event  OnHideAuthor( id:string )
	{
		var popupData : W3HideAuthorConfirmPopupData;

		popupData = new W3HideAuthorConfirmPopupData in this;
		popupData.SetMenuRef(this);
		popupData.SetModid(id);
		popupData.SetupTexts();

		RequestSubMenu('PopupMenu', popupData);
	}

	public function OnHideAuthorConfirmed ( id : string)
	{
		var modid : SModioModID;
		
		modid = m_modHandler.CreateModIDFromString(id);
		
		LogChannel('MODS', "OnHideAuthor " + id);
		this.m_modStateMachine.OnHideAuthor(modid);
	}

	public function StartLoadingIndicator(reason:string):void
	{
		m_fxStartLoadingIndicator.InvokeSelfOneArg(FlashArgString(reason));
	}

	public function StopLoadingIndicator(reason:string):void
	{
		m_fxStopLoadingIndicator.InvokeSelfOneArg(FlashArgString(reason));
	}
	
	public function UpdateModProgress( progress:SModProgressInfo ):void
	{
		m_fxUpdateProgressBar.InvokeSelfThreeArgs( FlashArgString(m_modHandler.ConvertModIDToString(progress.id)), FlashArgInt(progress.stage), FlashArgNumber(progress.progress));
	}
	
	public function FindModIdFromString( modidStr:string, out modid:SModioModID):bool
	{
		var i : int;
		
		for(i = 0; i < m_remoteModData.Size(); i+= 1)
		{
			if(m_modHandler.ConvertModIDToString(m_remoteModData[i].id) == modidStr)
			{
				modid = m_remoteModData[i].id;
				return true;
			}
		}
		return false;
	}
	
	event  OnRequestMediaLogo( modid:string, resolution:string )
	{
		var data : SModImageLoadData;
		
		data.m_modid = m_modHandler.CreateModIDFromString(modid);
		data.m_resolution = resolution;
		data.m_type = "logo";
		
		LogChannel('MODS', "Request logo for " + modid);
		m_modStateMachine.AddImageToList(data);
	}
	
	event  OnRequestMediaGallery( modid:string, resolution:string, index:int )
	{
		var data : SModImageLoadData;
		
		data.m_modid = m_modHandler.CreateModIDFromString(modid);
		data.m_resolution = resolution;
		data.m_type = "gallery";
		data.m_galleryIndex = index;
		LogChannel('MODS', "Request gallery image for " + modid + " with id " + index);
		m_modStateMachine.AddImageToList(data);
	}
	
	public function HandleImageLoad( data: SModImageLoadData, path:string)
	{
		var modidStr : string;
		modidStr = m_modHandler.ConvertModIDToString(data.m_modid);
	
		if(data.m_type != "gallery")
			m_fxHandleImageLoaded.InvokeSelfFourArgs( FlashArgString(modidStr),FlashArgString(data.m_resolution), FlashArgString(data.m_type), FlashArgString(path));
		else	
			m_fxHandleImageLoaded.InvokeSelfFiveArgs( FlashArgString(modidStr),FlashArgString(data.m_resolution), FlashArgString(data.m_type), FlashArgString(path), FlashArgString(data.m_galleryIndex));
	}
	
	private function CheckInstalledTabAvailability():void
	{
		var tempDataList : array<SModioModData>;
		m_modHandler.GetModDataList(tempDataList);
		m_fxSetInstalledTabOpenable.InvokeSelfOneArg( FlashArgBool(tempDataList.Size() > 0) );
		if(tempDataList.Size() == 0)
			LogChannel('MODS', "There are no installed mods. Restricting access to installed tab.");
	}

	public function BlockAllMouseInput(value:bool):void
	{
		m_fxBlockAllMouse.InvokeSelfOneArg(FlashArgBool(value));
	}
	
	private function OnSubscribedToMod()
	{
		theGame.GetGuiManager().DisplayModRestartNeededDialog(this, "panel_restart_needed", "mods_finished_downloading", MRMT_Install);
		UpdateInstalledModsData(true);
		CheckInstalledTabAvailability();
		LogChannel('MODS', "Just finished downloading a mod...");
	}
	
	private function OnUnsubscribedFromMod()
	{
		theGame.GetGuiManager().DisplayModRestartNeededDialog(this, "panel_restart_needed", "mods_mod_uninstalled", MRMT_Uninstall);
		UpdateInstalledModsData(true);
		CheckInstalledTabAvailability();
		LogChannel('MODS', "Just finished removing a mod...");
	}
	
	public function OnManagementEvent( modidScr : SModioModID, modState : EModState )
	{
		LogChannel('JIFIX', "MODSTATE: " + modState);
		if(modState == MS_Installed || modState == MS_Updated)
		{
			OnSubscribedToMod();
			m_fxUpdateProgressBar.InvokeSelfThreeArgs( FlashArgString(m_modHandler.ConvertModIDToString(modidScr)), FlashArgInt(2), FlashArgNumber(1));
		}
		else if(modState == MS_Uninstalled)
		{
			OnUnsubscribedFromMod();
			m_fxUpdateProgressBar.InvokeSelfThreeArgs( FlashArgString(m_modHandler.ConvertModIDToString(modidScr)), FlashArgInt(101), FlashArgNumber(1));
			
			if(m_modHandler.ConvertModIDToString(m_lastSelectedLibraryIndex) == m_modHandler.ConvertModIDToString(modidScr))
			{
				m_closedCount += 1;
				m_flashValueStorage.SetFlashInt( "panel.mod.deselect.details", m_closedCount); 
			}
				
		}
		GetStorageUsage();
	}

	public function OnModioNetworkError()
	{
		showNotification(GetLocStringByKeyExt("error_modio_connection"));
		LogChannel('MODS', "OnModioNetworkError was called ");
	}

	public function OnModioLocalModsUpdated()
	{
		UpdateInstalledModsData(true);
		CheckInstalledTabAvailability();
		LogChannel('MODS', "OnModioLocalModsUpdated was called ");
	}

	public function OnModioRemoteModsUpdated()
	{
		var l_ModArray : array<SModioModData>;
		var rating : EModRatingType;
		var modDependencies : array<SModDependency>;
		var modData : SModioModData;
		var lastItem : SModDetailsData = GetLastDetailsItem();
	
		m_modHandler.GetRemoteModDataList(l_ModArray);
		OnBrowseModDataGot(l_ModArray, true);

		rating = theGame.GetModHandlerSystem().GetCachedModRatingByID(lastItem.data.id);
		modData = theGame.GetModHandlerSystem().GetCachedRemoteModDataByID(lastItem.data.id);
		theGame.GetModHandlerSystem().GetCachedModDependenciesByID(lastItem.data.id, modDependencies);
		
		GetModDetailsItem(modData, rating, modDependencies, true);
	}

	private function RefreshModOrder()
	{
		var modOrder : array<Uint64> = GetModOrder();
		var itemsToRemove : array<int>;
		var i,j : int;
		var foundMod : bool = false;
		var noAllowed : bool = m_installedFilters.m_cachedParams.allowedTags.Size() == 0;
		var noExcluded : bool = m_installedFilters.m_cachedParams.excludedTags.Size() == 0;
		var noFilters : bool = m_installedFilters.m_cachedParams.filterStrings.Size() == 0;
		var noAuthor : bool = !theGame.GetModHandlerSystem().IsModioUserValid(m_installedFilters.m_cachedParams.author);

		if (noAllowed && noExcluded && noFilters && noAuthor)
		{
			for (i = 0; i < modOrder.Size(); i += 1)
			{
				foundMod = false;
				for (j = 0; j < m_libraryModData.Size(); j += 1)
				{
					if (m_libraryModData[j].id.modIDInt == modOrder[i])
					{
						foundMod = true;
						break;
					}
				}

				if (!foundMod)
				{
					itemsToRemove.PushBack(i);
				}
			}

			for (i = itemsToRemove.Size() - 1; i >= 0; i -= 1)
			{
				modOrder.Erase(itemsToRemove[i]);
			}
		}

		for (i = 0; i < m_libraryModData.Size(); i += 1)
		{
			if (!modOrder.Contains(m_libraryModData[i].id.modIDInt))
			{
				modOrder.PushBack(m_libraryModData[i].id.modIDInt);
			}
		}

		SaveModOrder(modOrder);
	}

	private function ChangeModOrder( modid: SModioModID, raise: bool ) : int
	{
		var modOrder : array<Uint64> = GetModOrder();
		var modOrderSize : int = modOrder.Size();
		var currentIndex, newIndex : int;

		if (!modOrder.Contains(modid.modIDInt))
		{
			return 0;
		}

		currentIndex = modOrder.FindFirst(modid.modIDInt);
		modOrder.Erase(currentIndex);
		newIndex = raise ? Max(0, currentIndex - 1) : Min(currentIndex + 1, modOrderSize);
		modOrder.Insert(newIndex, modid.modIDInt);

		SaveModOrder(modOrder);

		return newIndex;
	}

	private function GetModOrder() : array<Uint64>
	{
		var orderedList : array<Uint64>;
		
		theGame.GetModHandlerSystem().GetLoadOrder( orderedList );

		return orderedList;
	}

	private function SaveModOrder( orderedList : array<Uint64> )
	{
		theGame.GetModHandlerSystem().SetLoadOrder( orderedList );
	}
}

exec function modmenu()
{
	theGame.GetModHandlerSystem().SetModManagementEnabled(true);
	theGame.RequestMenu('ModMenu');
}

class ModMenuEventListener extends IModEventScriptListener
{
	public var m_modMenu : CR4ModMenu;
	public var m_ingameMenu : CR4IngameMenu;
	
	event  OnModManagementChangedScriptEvent( modidScr : SModioModID, modState : EModState )
	{
		if(m_modMenu)
			m_modMenu.OnManagementEvent(modidScr, modState);
		if(m_ingameMenu)
			m_ingameMenu.OnManagementEvent(modidScr, modState);
	}

	event  OnModioNetworkErrorScriptEvent()
	{
		if(m_modMenu)
			m_modMenu.OnModioNetworkError();
		if(m_ingameMenu)
			m_ingameMenu.OnModioNetworkError();
	}

	event  OnModioLocalModsUpdatedScriptEvent()
	{
		if(m_modMenu)
			m_modMenu.OnModioLocalModsUpdated();
		if(m_ingameMenu)
			m_ingameMenu.OnModioLocalModsUpdated();
	}

	event  OnModioRemoteModsUpdatedScriptEvent()
	{
		
		if(m_modMenu)
			m_modMenu.OnModioRemoteModsUpdated();
	}
	
	event  OnCDPRAccountLoggedInScriptEvent()
	{
		if(m_ingameMenu)
			m_ingameMenu.OnCDPRAccountLoggedIn();
	}
}