/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
function _StartupPageData_CreateStringSlider( flashValueStorage : CScriptedFlashValueStorage, id:int, label:string, strings:array<string>, optional defIdx:int, optional extraParams:SPhotomodeRendererExtraParams, optional dontLocalizeValue:bool) : CScriptedFlashObject
{
	var sliderObj : CScriptedFlashObject;
	var sliderArgsArray : CScriptedFlashArray;
	var stringsArray : CScriptedFlashArray;
	var stringsArrayObj : CScriptedFlashObject;
	var i, length: int;
	
	sliderObj = flashValueStorage.CreateTempFlashObject();
	
	sliderArgsArray = flashValueStorage.CreateTempFlashArray();
	stringsArray = flashValueStorage.CreateTempFlashArray();
	stringsArrayObj = flashValueStorage.CreateTempFlashObject();
	
	sliderArgsArray.PushBackFlashInt(id);
	
	sliderArgsArray.PushBackFlashString(label);

	length = strings.Size();
	for(i = 0; i < length; i += 1)
	{
		stringsArray.PushBackFlashString( GetLocStringByKeyExt(strings[i]) );
	
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
	
	return sliderObj;
}

function _StartupPageData_CreatePatchNotesArray( flashValueStorage : CScriptedFlashValueStorage ) : CScriptedFlashArray
{
	var patchNotes : CScriptedFlashArray;
	var patchNote : CScriptedFlashObject;
	
	patchNotes = flashValueStorage.CreateTempFlashArray();

	patchNote = flashValueStorage.CreateTempFlashObject();
	patchNote.SetMemberFlashString("title", "[[panel_highlights_header_1]]");
	patchNote.SetMemberFlashString("desc", "[[panel_highlights_body_1]]");
	patchNote.SetMemberFlashInt("icon", 1);
	patchNotes.PushBackFlashObject(patchNote);

	patchNote = flashValueStorage.CreateTempFlashObject();
	patchNote.SetMemberFlashString("title", "[[panel_highlights_header_2]]");
	patchNote.SetMemberFlashString("desc", "[[panel_highlights_body_2]]");
	patchNote.SetMemberFlashInt("icon", 2);
	patchNotes.PushBackFlashObject(patchNote);

	patchNote = flashValueStorage.CreateTempFlashObject();
	patchNote.SetMemberFlashString("title", "[[panel_highlights_header_3]]");
	patchNote.SetMemberFlashString("desc", "[[panel_highlights_body_3]]");
	patchNote.SetMemberFlashInt("icon", 3);
	patchNotes.PushBackFlashObject(patchNote);

	patchNote = flashValueStorage.CreateTempFlashObject();
	patchNote.SetMemberFlashString("title", "[[panel_highlights_header_5]]");
	patchNote.SetMemberFlashString("desc", "[[panel_highlights_body_5]]");
	patchNote.SetMemberFlashInt("icon", 5);
	patchNotes.PushBackFlashObject(patchNote);
	
	patchNote = flashValueStorage.CreateTempFlashObject();
	patchNote.SetMemberFlashString("title", "[[panel_highlights_header_4]]");
	patchNote.SetMemberFlashString("desc", "[[panel_highlights_body_4]]");
	patchNote.SetMemberFlashInt("icon", 4);
	patchNotes.PushBackFlashObject(patchNote);
	
	patchNote = flashValueStorage.CreateTempFlashObject();
	patchNote.SetMemberFlashString("title", "[[panel_highlights_header_6]]");
	patchNote.SetMemberFlashString("desc", "[[panel_highlights_body_6]]");
	patchNote.SetMemberFlashInt("icon", 6);
	patchNotes.PushBackFlashObject(patchNote);
	
	return patchNotes;
}
	
function _StartupPageData_CreateIconsArray( flashValueStorage : CScriptedFlashValueStorage ) : CScriptedFlashArray
{
	var iconArray : CScriptedFlashArray;
	var icon : CScriptedFlashObject;
	
	iconArray = flashValueStorage.CreateTempFlashArray();
	
	icon = flashValueStorage.CreateTempFlashObject(); 
	icon.SetMemberFlashString("label", "[[startup_connect_label_1]]");
	icon.SetMemberFlashString("icon", "rewards");
	iconArray.PushBackFlashObject(icon);

	icon = flashValueStorage.CreateTempFlashObject(); 
	icon.SetMemberFlashString("label", "[[startup_connect_label_2]]");
	icon.SetMemberFlashString("icon", "vault");
	iconArray.PushBackFlashObject(icon);

	icon = flashValueStorage.CreateTempFlashObject(); 
	icon.SetMemberFlashString("label", "[[startup_connect_label_3]]");
	icon.SetMemberFlashString("icon", "cross");
	iconArray.PushBackFlashObject(icon);

	icon = flashValueStorage.CreateTempFlashObject(); 
	icon.SetMemberFlashString("label", "[[startup_connect_label_4]]");
	icon.SetMemberFlashString("icon", "news");
	iconArray.PushBackFlashObject(icon);
	
	return iconArray;
}

function StartupPageData_CreateConnectPageData( flashValueStorage : CScriptedFlashValueStorage ) : CScriptedFlashObject
{
	var data : CScriptedFlashObject;
	var iconArray : CScriptedFlashArray;
	var icon : CScriptedFlashObject;
	
	data = flashValueStorage.CreateTempFlashObject();
	
	data.SetMemberFlashString("cdprAccountText", "[[panel_cdpr_account]]");
	data.SetMemberFlashString("title", "[[startup_connect_title]]");

	iconArray = _StartupPageData_CreateIconsArray( flashValueStorage );
	data.SetMemberFlashArray("icons", iconArray);
	
	data.SetMemberFlashString("qrTitle", "[[startup_connect_qr_title]]");
	data.SetMemberFlashString("qrDesc", "[[startup_connect_qr_alternative]]");
	
	return data;
}

function StartupPageData_CreateConnectedPageData( flashValueStorage : CScriptedFlashValueStorage ) : CScriptedFlashObject
{
	var data : CScriptedFlashObject;
	var iconArray : CScriptedFlashArray;
	var icon : CScriptedFlashObject;
	var cloudPersona : string;
	
	data = flashValueStorage.CreateTempFlashObject();

	data.SetMemberFlashString("cdprAccountText", "[[panel_cdpr_account]]");
	data.SetMemberFlashString("title", "[[startup_connected_title]]");
	data.SetMemberFlashString("desc", "[[startup_connected_enjoy]]");
	
	cloudPersona = theGame.GetGalaxyUserDisplayName();
	data.SetMemberFlashString("user", cloudPersona);
	iconArray = _StartupPageData_CreateIconsArray( flashValueStorage );
	data.SetMemberFlashArray("icons", iconArray);

	return data;
}

function StartupPageData_CreateTelemetryPageData( flashValueStorage : CScriptedFlashValueStorage, learnMoreUrl : string ) : CScriptedFlashObject
{
	var data : CScriptedFlashObject;
	
	var l_flashSubObject : CScriptedFlashObject;
	var consentSliders : CScriptedFlashArray;
	var stringsArray : array<string>;
	var extraParams : SPhotomodeRendererExtraParams;

	stringsArray.PushBack("panel_mainmenu_option_value_off");
	stringsArray.PushBack("panel_mainmenu_option_value_on");
	
	data = flashValueStorage.CreateTempFlashObject();

	data.SetMemberFlashString("title", "[[startup_telemetry_title]]");
	data.SetMemberFlashString("desc", "[[startup_telemetry_desc]]");
	data.SetMemberFlashString("more", "[[startup_telemetry_url_desc]]");
	data.SetMemberFlashString("url", learnMoreUrl);

	
	consentSliders = flashValueStorage.CreateTempFlashArray();
	consentSliders.PushBackFlashObject(_StartupPageData_CreateStringSlider(flashValueStorage, TCI_Telemetry, "[[startup_telemetry_checkbox_label_1]]", stringsArray, 0, extraParams, true));
	consentSliders.PushBackFlashObject(_StartupPageData_CreateStringSlider(flashValueStorage, TCI_Marketing, "[[startup_telemetry_checkbox_label_2]]", stringsArray, 0, extraParams, true));

	data.SetMemberFlashArray( "options", consentSliders );
	
	return data;
}

function StartupPageData_CreatePatchNotesPageData( flashValueStorage : CScriptedFlashValueStorage ) : CScriptedFlashObject
{
	var data : CScriptedFlashObject;
	var patchNotes : CScriptedFlashArray;

	data = flashValueStorage.CreateTempFlashObject();
	data.SetMemberFlashString("title", "[[panel_highlights_title_2]]");
	patchNotes = _StartupPageData_CreatePatchNotesArray( flashValueStorage );
	data.SetMemberFlashArray("entries", patchNotes);

	return data;
}

enum ETelemetryConsentId
{
	TCI_Telemetry,
	TCI_Marketing,
}

enum EStartupPageId
{
	SPI_Connect,
	SPI_Connected,
	SPI_Telemetry,
	SPI_PatchNotes,
}

class CR4StartupExperienceMenu extends CR4MenuBase
{
	private var m_page : string;
	private var m_config : CInGameConfigWrapper;
	private var m_telemetryPrivacyUrl : string;
	private var m_initDataObject : W3StartupMenuInitData;
	
    event  OnConfigUI()
	{
		var manager : CR4GuiManager;
		var signedIn : bool;
		var overlayPopupRef  : CR4OverlayPopup;
		
		super.OnConfigUI();

		m_page = "";
		m_config = (CInGameConfigWrapper) theGame.GetInGameConfigWrapper();			
		m_telemetryPrivacyUrl = "CDPROJEKTRED.com/privacy-policy";
		m_initDataObject = (W3StartupMenuInitData) GetMenuInitData();
		
		theInput.StoreContext( 'EMPTY_CONTEXT' );
		
		overlayPopupRef = (CR4OverlayPopup) theGame.GetGuiManager().GetPopup('OverlayPopup');
		if ( !overlayPopupRef )
		{
			theGame.RequestPopup( 'OverlayPopup' );
		}
		
		theGame.GetGuiManager().RequestMouseCursor(true);
		
		
		if ( m_initDataObject )
		{
			switch ( m_initDataObject.requestPage )
			{
				case SPI_Connect:
					ShowConnectPage();
				break;
				case SPI_Connected:
					ShowConnectedPage();
				break;
				case SPI_Telemetry:
					ShowTelemetryPage();
				break;
				case SPI_PatchNotes:
					ShowPatchNotesPage();
				break;
			}
		}
		
		else
		{
			if ( theGame.GetGuiManager().EvaluateStartupLaunchCriteria() )
			{
				signedIn = theGame.IsGalaxyUserSignedIn();
				if ( signedIn )
				{
					ShowConnectedPage();
				}
				else
				{
					ShowConnectPage();
				}
			}
			else
			{
				ExitMenu();
			}
		}
	}
	
	private function ExitMenu() : void
	{
		CloseMenu();
		if (m_initDataObject.reopenMenu)
		{
			theGame.RequestMenu( m_initDataObject.reopenMenuName );
		}
	}
	
	public function ShowConnectPage():void
	{
		m_page = "connect";
		m_flashValueStorage.SetFlashObject( "startup.connect.page", StartupPageData_CreateConnectPageData( m_flashValueStorage ) );
	}

	public function ShowConnectedPage():void
	{
		m_page = "connected";
		m_flashValueStorage.SetFlashObject( "startup.connected.page", StartupPageData_CreateConnectedPageData( m_flashValueStorage ) );	
	}

	public function ShowTelemetryPage():void
	{
		var forceShow : bool = m_initDataObject.forceShow;
		
		if ( forceShow || !theTelemetry.WasConsentWindowShown() )
		{
			theTelemetry.MarkShownConsentWindow();
			
			m_page = "telemetry";
			m_flashValueStorage.SetFlashObject( "startup.telemetry.page", StartupPageData_CreateTelemetryPageData( m_flashValueStorage, m_telemetryPrivacyUrl ) );	
		}
		
		else if (m_page != "telemetry")
		{
			ExitMenu();
		}
	}
	
	public function ShowPatchNotesPage():void
	{
		var forceShow : bool = m_initDataObject.forceShow;

		if ( forceShow )
		{
			m_page = "patch_notes";
			m_flashValueStorage.SetFlashObject( "startup.patch.notes.page", StartupPageData_CreatePatchNotesPageData( m_flashValueStorage ) );
		}
		else
		{
			ExitMenu();
		}
	}

	event  OnConnectPageRequestConnect()
	{
		var manager : CR4GuiManager;
		
		manager = (CR4GuiManager) theGame.GetGuiManager();
		if (manager)
		{
			manager.GalaxyMyRewardsInitiate();
		}
	}
	
	event  OnConnectPageSkipConnect()
	{
		var manager : CR4GuiManager;
		manager = (CR4GuiManager)theGame.GetGuiManager();
		if ( manager )
		{
			manager.GalaxyQRSignInCancel();
		}
		
		ShowTelemetryPage();
	}
	
	
	public function OnGalaxyQrCodeReady( url : String ) : void
	{
		var data : CScriptedFlashObject; 
		
		data = m_flashValueStorage.CreateTempFlashObject();
		data.SetMemberFlashString( "url", url );
		
		m_flashValueStorage.SetFlashObject( "startup.qrData", data );
	}
	
	
	public function OnGalaxyAlreadyConnected( ) : void
	{
		
		m_flashValueStorage.SetFlashString("startup.qrError", "");
		
		ShowTelemetryPage();
	}
	
	
	public function OnGalaxyError( error : int ) : void
	{
		m_flashValueStorage.SetFlashString("startup.qrError", GetLocStringByKeyExt("panel_telemetry_connection_error"));
		
		showNotification( "[[panel_telemetry_connection_error]]", 5000 );
		OnPlaySoundEvent("gui_global_denied");
	}
	
	
	public function OnGalaxySignInComplete() : void
	{
		ShowTelemetryPage();
	}
	
	event  OnContinue()
	{
		if(m_page == "connected")
		{
			ShowTelemetryPage();
		}
		else
		{
			ExitMenu();
		}
	}

	event  OnTelemetryPageSubmitConsentValuesDone( )
	{
		ExitMenu();
	}

	event  OnTelemetryPageSubmitConsentValue( consentId : ETelemetryConsentId, value : bool )
	{
		switch( consentId )
		{
			case TCI_Telemetry:
				theTelemetry.TelemetryConsentChanged( value );
			break;
			case TCI_Marketing:
				theTelemetry.MarketingConsentChanged( value );
			break;
		}
	}
	
	event  OnTelemetryPageLinkClicked( )
	{	
		var manager : CR4GuiManager;
		manager = (CR4GuiManager)theGame.GetGuiManager();
		if ( manager )
		{
			manager.VisitPage( MLT_CDPRPrivacy );
		}
	}
	
	event  OnQrPanelLinkClicked( )
	{
		var manager : CR4GuiManager;
		manager = (CR4GuiManager)theGame.GetGuiManager();
		if ( manager )
		{
			manager.VisitSignInPage();
		}
	}

	event  OnClosingMenu()
	{
		super.OnClosingMenu();
		
		OnPlaySoundEvent( "gui_global_quit" );
		theGame.GetGuiManager().RequestMouseCursor(false);
		theInput.RestoreContext( 'EMPTY_CONTEXT', true );
	}
}

exec function startupexp()
{
	theGame.RequestMenu('StartupExperienceMenu');
}

exec function startupexp_connect()
{
	var initData : W3StartupMenuInitData = new W3StartupMenuInitData in theGame.GetGuiManager();				
	initData.requestPage = SPI_Connect;
	initData.reopenMenu = false;
	
	theGame.RequestMenu('StartupExperienceMenu', initData);
}

exec function startupexp_connected()
{
	var initData : W3StartupMenuInitData = new W3StartupMenuInitData in theGame.GetGuiManager();				
	initData.requestPage = SPI_Connected;
	initData.reopenMenu = false;
	
	theGame.RequestMenu('StartupExperienceMenu', initData);
}

exec function startupexp_telemetry()
{
	var initData : W3StartupMenuInitData = new W3StartupMenuInitData in theGame.GetGuiManager();				
	initData.requestPage = SPI_Telemetry;
	initData.reopenMenu = false;
	initData.forceShow = true;
	
	theGame.RequestMenu('StartupExperienceMenu', initData);
}

exec function startupexp_patchnotes()
{
	var initData : W3StartupMenuInitData = new W3StartupMenuInitData in theGame.GetGuiManager();				
	initData.requestPage = SPI_PatchNotes;
	initData.reopenMenu = false;
	initData.forceShow = true;
	
	theGame.RequestMenu('StartupExperienceMenu', initData);
}

exec function startupexp_reset()
{
	theGame.DebugFirstLaunch();
	theGame.GetGuiManager().ResetStartupLaunchCriteria();
}