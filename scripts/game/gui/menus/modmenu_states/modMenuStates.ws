/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
statemachine class CR4ModMenuStates extends CR4MenuBase
{
	protected var m_modHandler		: CModHandlerSystem;
	public var m_modMenuReference	: CR4ModMenu;
	protected var m_modId			: SModioModID;
	protected var m_hideModId		: SModioModID;
	public var m_imageList			: array<SModImageLoadData>;
	public var getRefresh			: bool; default getRefresh = false;
	public var getModData			: bool; default getModData = false;
	public var getFilterTags		: bool; default getFilterTags = false;
	public var refreshWithParams	: bool; default refreshWithParams = false;
	public var submitReport			: bool; default submitReport = false;
	public var logoutRequest		: bool; default logoutRequest = false;
	public var hideMod				: bool; default hideMod = false;
	public var hideAuthor			: bool; default hideAuthor = false;
	public var openUrl				: bool; default openUrl = false;
	public var m_filterParams		: SModFilterParams;
	public var m_reportParams		: SModReportParams;
	public var m_filterIndex		: EModFilterIndex;
	public var m_urlToUpen			: ETermsLinkType;
	
	default autoState = 'NullState';
	
	public function OnRefresh()
	{
		getRefresh = true;
		refreshWithParams = false;
		TryGotoState('Refresh');
	}
	
	public function OnRefreshWithParams(params : SModFilterParams)
	{
		getRefresh = true;
		refreshWithParams = true;
		m_filterParams = params;
		TryGotoState('Refresh');
	}
	
	public function SetRef(ref : CR4ModMenu)
	{
		m_modMenuReference = ref;
	}
	
	public function OnGetModData( modid : SModioModID)
	{
		m_modId = modid;
		getModData = true;
		TryGotoState('GetModData');
	}
	
	public function AddImageToList(data:SModImageLoadData)
	{
		m_imageList.PushBack(data);
		if(GetCurrentStateName() == 'NullState')
			OnNullState();
	}
	
	public function OnNullState()
	{	
		if(getRefresh)
			GotoState('Refresh');
		else if(getModData)
			GotoState('GetModData');
		else if(getFilterTags)
			GotoState('GetFilterTags');
		else if(submitReport)
			GotoState('SubmitReport');
		else if(openUrl)
			GotoState('OpenUrl');
		else if(hideMod)
			GotoState('HideMod');
		else if(hideAuthor)
			GotoState('HideAuthor');
		else if(logoutRequest)
			GotoState('Logout');
		else if(m_imageList.Size() > 0)
			GotoState('LoadImage');
		else 
			GotoState('NullState');
	}
	
	public function OnGetFilterTags(filterIndex : EModFilterIndex)
	{
		m_filterIndex = filterIndex;
		getFilterTags = true;
		TryGotoState('GetFilterTags');
	}

	public function OnOpenUrl(urlType : ETermsLinkType)
	{
		m_urlToUpen = urlType;
		openUrl = true;
		TryGotoState('OpenUrl');
	}
	
	public function OnSubmitReport(params : SModReportParams)
	{
		m_reportParams = params;
		submitReport = true;
		TryGotoState('SubmitReport');
	}
	
	public function OnHideMod(modid : SModioModID)
	{
		m_hideModId = modid;
		hideMod = true;
		TryGotoState('HideMod');
	}
	
	public function OnHideAuthor(modid : SModioModID)
	{
		m_hideModId = modid;
		hideAuthor = true;
		TryGotoState('HideAuthor');
	}
	
	public function OnRequestLogout()
	{
		logoutRequest = true;
		TryGotoState('Logout');
	}
	
	public function Init()
	{
		GotoState('NullState');
	}
	
	protected function TryGotoState(stateName : name)
	{
		if(GetCurrentStateName() == 'NullState')
			GotoState(stateName);
	}
}

state NullState in CR4ModMenuStates
{
	event OnEnterState(prevStateName : name)
	{
		super.OnEnterState( prevStateName );
	}
}

state GetFilterTags in CR4ModMenuStates
{
	event OnEnterState(prevStateName : name)
	{
		GetFilterTags();
		super.OnEnterState( prevStateName );
	}
		
	entry function GetFilterTags():void
	{
		var modTagInfos : array< SModTagInfo >;
	
		theGame.GetModHandlerSystem().RequestModTagInfos(modTagInfos);
		parent.m_modMenuReference.SetTagInfos(parent.m_filterIndex, modTagInfos);
		parent.getFilterTags = false;
		parent.OnNullState();
	}	
}

state SubmitReport in CR4ModMenuStates
{
	event OnEnterState(prevStateName : name)
	{
		SubmitReport();
		super.OnEnterState( prevStateName );
	}
		
	entry function SubmitReport():void
	{
		theGame.GetModHandlerSystem().SubmitModReport(parent.m_reportParams);
		parent.m_modMenuReference.OnReportSubmitted();
		
		parent.submitReport = false;
		parent.OnNullState();
	}	
}

state OpenUrl in CR4ModMenuStates
{
	event OnEnterState(prevStateName : name)
	{
		OpenUrl();
		super.OnEnterState( prevStateName );
	}
		
	entry function OpenUrl():void
	{
		theGame.GetModHandlerSystem().OpenLinkInBrowserLatent(parent.m_urlToUpen);
		parent.openUrl = false;
		parent.OnNullState();
	}	
}

state HideMod in CR4ModMenuStates
{
	event OnEnterState(prevStateName : name)
	{
		TryHideMod();
		super.OnEnterState( prevStateName );
	}
		
	entry function TryHideMod():void
	{
		theGame.GetModHandlerSystem().DownvoteMod(parent.m_hideModId);

		parent.hideMod = false;
		parent.OnRefreshWithParams(parent.m_filterParams);
		parent.OnNullState();
	}	
}

state HideAuthor in CR4ModMenuStates
{
	event OnEnterState(prevStateName : name)
	{
		TryHideAuthor();
		super.OnEnterState( prevStateName );
	}
		
	entry function TryHideAuthor():void
	{
		theGame.GetModHandlerSystem().MuteModioAuthorByModIDLatent(parent.m_hideModId);
		
		Sleep( 0.6f );

		parent.hideAuthor = false;
		parent.OnRefreshWithParams(parent.m_filterParams);
		parent.OnNullState();
	}	
}

state Logout in CR4ModMenuStates
{
	event OnEnterState(prevStateName : name)
	{
		Logout();
		super.OnEnterState( prevStateName );
	}
		
	entry function Logout():void
	{
		theGame.GetModHandlerSystem().LogoutUser();
		parent.m_modMenuReference.OnCloseMenu();
		parent.logoutRequest = false;
		parent.OnNullState();
	}	
}

state FilteredSearch in CR4ModMenuStates
{
	event OnEnterState(prevStateName : name)
	{
		FilteredSearch();
		super.OnEnterState( prevStateName );
	}
		
	entry function FilteredSearch():void
	{

		parent.OnNullState();
	}	
}

state Refresh in CR4ModMenuStates
{
	event OnEnterState(prevStateName : name)
	{
		if(parent.refreshWithParams)
			RefreshModsWithParams();
		else
			RefreshMods();
		super.OnEnterState( prevStateName );
	}
		
	entry function RefreshMods():void
	{
		parent.m_modMenuReference.StartLoadingIndicator("refresh");
		theGame.GetModHandlerSystem().RefreshModsLatent();
		parent.m_modMenuReference.OnBrowseMenuOpen(); 
		parent.m_modMenuReference.StopLoadingIndicator("refresh");
		parent.getRefresh = false;
		parent.OnNullState();
	}	
	
	entry function RefreshModsWithParams():void
	{
		var mods : array< SModioModData >;
		parent.m_modMenuReference.StartLoadingIndicator("refresh");
		theGame.GetModHandlerSystem().RequestModListLatent(parent.m_filterParams, mods);
		parent.m_modMenuReference.OnBrowseMenuOpen(); 
		parent.m_modMenuReference.StopLoadingIndicator("refresh");
		parent.getRefresh = false;
		parent.refreshWithParams = false;
		parent.OnNullState();
	}	
}

state GetModData in CR4ModMenuStates
{
	event OnEnterState(prevStateName : name)
	{
		GetModData();
		super.OnEnterState( prevStateName );
	}
		
	entry function GetModData():void
	{
		var modData : SModioModData;
		var rating : EModRatingType;
		var modDependencies : array<SModDependency>;
		
		rating = theGame.GetModHandlerSystem().GetSubmittedModRating(parent.m_modId);
		modData = theGame.GetModHandlerSystem().GetRemoteModDataByID(parent.m_modId);
		theGame.GetModHandlerSystem().RequestModDependencies(parent.m_modId, modDependencies);
		parent.m_modMenuReference.GetModDetailsItem(modData, rating, modDependencies);
		parent.getModData = false;
		parent.OnNullState();
	}
}

struct SLoadImageDoneData
{
	var imageData		: SModImageLoadData;
	var downloadPath 	: string;
}

state LoadImage in CR4ModMenuStates
{
	event OnEnterState(prevStateName : name)
	{
		LoadImageLoop();
		super.OnEnterState( prevStateName );
	}
		
	entry function LoadImageLoop():void
	{
		var downloadPath 	: string = "";
		var imageData		: SModImageLoadData;
		var avatarSize		: EModAvatarSize;
		var logoSize		: EModLogoSize;
		var gallerySize		: EModGallerySize;
		var loadedImgs		: array<SLoadImageDoneData>;
		var currentImg		: SLoadImageDoneData;
		var i : int;
		
		SleepOneFrame();
		
		while( parent.m_imageList.Size() > 0 )
		{
			imageData = parent.m_imageList[0];
			if(imageData.m_type == "logo")
			{
				if(imageData.m_resolution == "320p")
					logoSize = MLS_320;
				else if(imageData.m_resolution == "640p")
					logoSize = MLS_640;
				else if(imageData.m_resolution == "1280p")
					logoSize = MLS_1280;
				else
					logoSize = MLS_Original;
				downloadPath = theGame.GetModHandlerSystem().RequestModMediaLogo(imageData.m_modid,logoSize);
			}
			else if (imageData.m_type == "gallery")
			{
				if(imageData.m_resolution == "320p")
					gallerySize = MGS_320;
				else if(imageData.m_resolution == "1280p")
					gallerySize = MGS_1280;
				else
					gallerySize = MGS_Original;
				downloadPath = theGame.GetModHandlerSystem().RequestModMediaGalleryImg(imageData.m_modid, imageData.m_galleryIndex, gallerySize);
			}

			if ( downloadPath =="" )
				continue;

			currentImg.imageData = imageData;
			currentImg.downloadPath = downloadPath;
			loadedImgs.PushBack(currentImg);
			parent.m_imageList.Remove(imageData);
		}
		
		for(i = 0; i < loadedImgs.Size(); i+=1)
		{
			imageData = loadedImgs[i].imageData;
			downloadPath = loadedImgs[i].downloadPath;
			parent.m_modMenuReference.HandleImageLoad( imageData, downloadPath );
		}
		parent.OnNullState();
	}
}


statemachine class CR4ModMenuModLoadStates extends CR4MenuBase
{
	public var m_modMenuReference	: CR4ModMenu;
	public var m_ingameMenuReference : CR4IngameMenu;
	
	default autoState = 'QueryProgress';
	
	public function OnQueryProgress()
	{
		GotoState('QueryProgress');
	}
	
	public function SetRef(ref : CR4ModMenu)
	{
		m_modMenuReference = ref;
	}
	
	public function SetRefIngameMenu(ref : CR4IngameMenu)
	{
		m_ingameMenuReference = ref;
	}

}

state QueryProgress in CR4ModMenuModLoadStates
{
	event OnEnterState(prevStateName : name)
	{
		super.OnEnterState( prevStateName );
		LoadLoop();
	}
		
	entry function LoadLoop():void
	{
		var lastStage : EModProgressStage;
		var lastId	  : SModioModID;
		var progress : SModProgressInfo;
		var tempProgress : SModProgressInfo;
	
		while(true)
		{
			if(!parent.m_modMenuReference && !parent.m_ingameMenuReference)
				break;
			progress = theGame.GetModHandlerSystem().QueryCurrentModProgress();
			
			if(parent.m_modMenuReference)
			{
				if(progress.stage == MPS_Downloading || progress.stage == MPS_Extracting)
					parent.m_modMenuReference.UpdateModProgress(progress);
				else if(lastStage == MPS_Downloading || lastStage == MPS_Extracting) 
				{
					tempProgress.id = lastId;
					tempProgress.progress = 1;
					tempProgress.stage = MPS_Extracting;
					parent.m_modMenuReference.UpdateModProgress(tempProgress);
				}
					
			}
			else if (parent.m_ingameMenuReference)
			{
				parent.m_ingameMenuReference.ChangeShowModioIndicator(progress.stage == MPS_Downloading || progress.stage == MPS_Extracting);
			}
			
			lastStage = progress.stage;
			lastId = progress.id;
			
			SleepOneFrame();
		}
	}
}


statemachine class CR4ModVerificationStates extends CR4MenuBase
{
	protected var m_modHandler		: CModHandlerSystem;
	public var m_menuReference		: CR4MenuPopup;
	public var m_menuReferenceIGM	: CR4IngameMenu;
	public var m_imageList			: array<SModImageLoadData>;
	
	default autoState = 'NullState';
	
	public function SetRef(ref : CR4MenuPopup)
	{
		m_menuReference = ref;
	}
	
	public function SetRefIngameMenu(ref : CR4IngameMenu)
	{
		m_menuReferenceIGM = ref;
	}
	
	public function AddImageToList(data:SModImageLoadData)
	{
		m_imageList.PushBack(data);
		if(GetCurrentStateName() != 'LoadImage')
			OnNullState();
	}
	
	public function OnNullState()
	{
		if(m_imageList.Size() > 0)
			GotoState('LoadImage');
		else
			GotoState('NullState');
	}
}

state NullState in CR4ModVerificationStates
{
	event OnEnterState(prevStateName : name)
	{
		super.OnEnterState( prevStateName );
	}
}


state LoadImage in CR4ModVerificationStates
{
	event OnEnterState(prevStateName : name)
	{
		LoadImageLoop();
		super.OnEnterState( prevStateName );
	}
		
	entry function LoadImageLoop():void
	{
		var downloadPath 	: string = "";
		var imageData		: SModImageLoadData;
		var logoSize		: EModLogoSize;
		
		SleepOneFrame();
		
		while( parent.m_imageList.Size() > 0 )
		{
			imageData = parent.m_imageList[0];
			
			if(imageData.m_resolution == "320p")
				logoSize = MLS_320;
			else if(imageData.m_resolution == "640p")
				logoSize = MLS_640;
			else if(imageData.m_resolution == "1280p")
				logoSize = MLS_1280;
			else
				logoSize = MLS_Original;
			
			downloadPath = theGame.GetModHandlerSystem().RequestModMediaLogo(imageData.m_modid,logoSize);
			if(parent.m_menuReference)
				parent.m_menuReference.HandleImageLoad( imageData, downloadPath );
			else if(parent.m_menuReferenceIGM)
				parent.m_menuReferenceIGM.HandleImageLoad( imageData, downloadPath );
			parent.m_imageList.Remove(imageData);
		}
		parent.OnNullState();
	}
}



statemachine class CR4VirtualTextInputStates extends CR4MenuBase
{
	public var m_menu	: CR4MenuBase;
	public var m_config : SVirtualKeyboardConfig;
	public var m_flashStorage : CScriptedFlashValueStorage;
	
	default autoState = 'NullState';
	
	public function OnTextInputOpened(config : SVirtualKeyboardConfig, menu : CR4MenuBase, storage : CScriptedFlashValueStorage)
	{
		SetRef(menu);
		m_config = config;
		m_flashStorage = storage;
		GotoState('TextInputOpened');
	}
	
	public function OnNullState()
	{
		GotoState('NullState');
	}
	
	public function SetRef(ref : CR4MenuBase)
	{
		m_menu = ref;
	}
}

state NullState in CR4VirtualTextInputStates
{
	event OnEnterState(prevStateName : name)
	{
		super.OnEnterState( prevStateName );
	}
}

state TextInputOpened in CR4VirtualTextInputStates
{
	event OnEnterState(prevStateName : name)
	{
		super.OnEnterState( prevStateName );
		GetVirtualKeyboardInput();
	}

	function RequestCursor():void
	{
		var m_modMenuRef : CR4ModMenu;

		m_modMenuRef = (CR4ModMenu)parent.m_menu;

		if(theGame.GetPlatform() == Platform_PC || theGame.GetPlatform() == Platform_PC_GDK)
		{
			theGame.GetGuiManager().ForceHideMouseCursor(false);
			if(m_modMenuRef)
				m_modMenuRef.BlockAllMouseInput(false);
		}
	}

	function UnrequestCursor():void
	{
		var m_modMenuRef : CR4ModMenu;

		m_modMenuRef = (CR4ModMenu)parent.m_menu;

		if(theGame.GetPlatform() == Platform_PC || theGame.GetPlatform() == Platform_PC_GDK)
		{
			theGame.GetGuiManager().ForceHideMouseCursor(true);
			if(m_modMenuRef)
				m_modMenuRef.BlockAllMouseInput(true);
		}
	}
		
	entry function GetVirtualKeyboardInput():void
	{
		var result : string;
		UnrequestCursor();
		result = theInput.OpenVirtualKeyboard(parent.m_config);
		parent.m_flashStorage.SetFlashString("textinput.text.received", result);
		theGame.GetGuiManager().RequestMouseCursor(true);
		
		if(theGame.GetPlatform() == Platform_PC || theGame.GetPlatform() == Platform_PC_GDK)
		{
			WaitForVKBClose();
			RequestCursor();
		}
		parent.OnNullState();
	}

	latent function WaitForVKBClose():void
	{
		Sleep(0.1);
		while(theInput.IsVirtualKeyboardActive())
		{
			Sleep(0.1);
		}
	}
}