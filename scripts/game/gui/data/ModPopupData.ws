/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ModTermsPopupData extends W3UrlCheckboxListPopupData
{
	private var m_menuRef : CR4IngameMenu;
	
	public function GetMenuRef():CR4IngameMenu
	{
		return m_menuRef;
	}
	
	public function SetMenuRef( ref : CR4IngameMenu )
	{
		m_menuRef = ref;
	}
	
	protected  function OnUserAccept() : void
	{
		var anyUnchecked : bool;
		var i, n : int;

		anyUnchecked = false;
		n = m_checkboxes.Size();		
		for ( i = 0; i < n; i += 1 )
		{
			if ( !m_checkboxes[ i ].checked )
			{
				anyUnchecked = true;
				break;
			}
		}

		if ( !anyUnchecked )
		{
			theGame.GetInGameConfigWrapper().SetVarValue('Hidden', 'ModioTermsAccepted', "true");
			OnEverythingAccepted();
			ClosePopup();
		}
		else
		{
			
			theGame.GetInGameConfigWrapper().SetVarValue('Hidden', 'ModioTermsAccepted', "false");
		}
	}
	
	protected  function OnUserDecline() : void
	{
		theGame.GetInGameConfigWrapper().SetVarValue('Hidden', 'ModioTermsAccepted', "false");
		ClosePopup();
	}
	
	protected function OnEverythingAccepted() : void
	{
		m_menuRef.OnModTermsAccepted();
	}
	
	protected  function DefineDefaultButtons():void
	{
		var checkboxEnablePadNavCode : string = "gamepad_X";

		if (theGame.GetPlatform() == Platform_Switch2_Ounce)
		{
			checkboxEnablePadNavCode = "gamepad_Y";
		}

		AddButtonDef( "panel_mods_connect_account", "enter-gamepad_A", IK_Enter );
		AddButtonDef( "panel_button_common_exit", "escape-gamepad_B", IK_Escape );
		AddButtonDef( "panel_checkbox_default_enable", checkboxEnablePadNavCode, IK_Space );
	}
	
}

class W3ModVerificationPopupData extends ConfirmationPopupData
{
	public var m_IGMReference : CR4IngameMenu;
	public var m_Reason : string;
	public var m_Action : string;
	public var m_acceptedMods: array<string>;
	public var m_modList : array<SModioModData>;
	public var m_UGCAllowed : bool; 	default m_UGCAllowed = true;
	public var m_hideCheckbox : bool; default m_hideCheckbox = false;

	public var m_isOutdated : bool;
	public var m_isLoadingSave : bool; 	default m_isLoadingSave = true;
	public var m_isContinue : bool; 	default m_isContinue = false;
	public var m_isFailed : bool; 		default m_isFailed = true;

	public var valid : bool; 			default valid = true;

	public function SetIngameMenu( menu : CR4IngameMenu):void
	{
		m_IGMReference = menu;
	}

	public function SetReason(reason: string) : void
	{
		m_Reason = reason;
	}
	
	public function SetAction(action: string) : void
	{
		m_Action = action;
	}
	
	public function SetIsOutdated(is : bool) : void
	{
		m_isOutdated = is;
	}
	
	public function SetIsLoadingSave(is : bool) : void
	{
		m_isLoadingSave = is;
	}
	
	public function SetIsContinue(is : bool) : void
	{
		m_isContinue = is;
	}
	
	public function SetIsFailed(is : bool) : void
	{
		m_isFailed = is;
	}

	public function SetIsUGCallowed(is : bool) : void
	{
		m_UGCAllowed = is;
	}
	
	public function SetHideCheckbox(is : bool) : void
	{
		m_hideCheckbox = is;
	}

	protected  function GetContentRef() : string 
	{
		return "ModVerificationPopupRef";
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
	
	public  function GetGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject
	{
		var l_flashObject : CScriptedFlashObject;
		var l_flashTempObject : CScriptedFlashObject;
		var l_flashTempArray : CScriptedFlashArray;
		var i : int = 0;
		
		l_flashObject = parentFlashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("ContentRef", GetContentRef());
		l_flashObject.SetMemberFlashString("TextContent", m_TextContent);
		l_flashObject.SetMemberFlashString("TextTitle", m_TextTitle);
		l_flashObject.SetMemberFlashString("TextReason", m_Reason);
		l_flashObject.SetMemberFlashString("TextAction", m_Action);
		l_flashObject.SetMemberFlashString("ImagePath", m_ImagePath);
		
		l_flashTempArray = parentFlashValueStorage.CreateTempFlashArray();
		GetGFxModsStruct(parentFlashValueStorage, l_flashTempArray);
		l_flashObject.SetMemberFlashArray("ModList", l_flashTempArray);
		
		l_flashObject.SetMemberFlashBool("backgroundVisible", m_DisplayGreyBackground);
		
		return l_flashObject;
	}
	
	protected  function OnUserAccept() : void
	{
		var saveIndex : int;
		var i : int;
		var modid : SModioModID;
		var continueAnyway : bool;

		if ( m_isFailed )
		{
			
			ClosePopup();
			valid = false;
		}
		
		if(m_isOutdated)
		{
			
			for(i = 0; i < m_acceptedMods.Size(); i+= 1)
			{
				
				modid = theGame.GetModHandlerSystem().CreateModIDFromString(m_acceptedMods[i]);
				theGame.GetModHandlerSystem().SetLocalModDisabled(modid, true);
			}
			theGame.GetModHandlerSystem().SaveLocalModConfig();
		}
		else if( m_isLoadingSave || m_isContinue )
		{
			
			for(i = 0; i < m_acceptedMods.Size(); i+= 1)
			{
				
				modid = theGame.GetModHandlerSystem().CreateModIDFromString(m_acceptedMods[i]);
				if( !theGame.GetModHandlerSystem().IsModSubscribed( modid ) )
				{
					theGame.GetModHandlerSystem().SubscribeMod(modid);
				}
				else
				{
					
					theGame.GetModHandlerSystem().SetLocalModDisabled(modid, false);
				}
			}
		}

		
		
		if(m_acceptedMods.Size() == 0)
		{
			continueAnyway = true;
		}
		
		ClosePopup();
		valid = false;

		if ( !continueAnyway )
		{
			return;
		}

		if(m_IGMReference)
		{
			
			if(m_isLoadingSave)
			{
				saveIndex = m_IGMReference.GetLastAttemptedSaveIndex();
				m_IGMReference.LoadSave( SGT_Manual, saveIndex, false ); 
			}
			
			else if (m_isContinue)
			{
				m_IGMReference.OnPopupContinueConfirmed();
			}
		}
	}
	
	protected  function OnUserDecline() : void
	{
		valid = false;
		ClosePopup();
	}
	
	protected  function GetAcceptText() : string
	{
		return "panel_button_common_accept";
	}
	
	protected  function GetDeclineText() : string
	{
		return "panel_button_common_exit";
	}
	
	public function SetModArray(mods : array <SModioModData> ) : void
	{
		m_modList = mods;
	}
	
	private function GetGFxModsStruct(parentFlashValueStorage : CScriptedFlashValueStorage, out StructGFx : CScriptedFlashArray) : void
	{
		var i				  : int;
		var l_flashObject     : CScriptedFlashObject;
		
		for ( i = 0; i < m_modList.Size(); i += 1 )
		{
			l_flashObject = parentFlashValueStorage.CreateTempFlashObject();
			GetGFxLibraryPreviewItem(m_modList, i, l_flashObject);
			StructGFx.PushBackFlashObject(l_flashObject);
		}
	}
	
	public function FindModIdFromString( modidStr:string, out modid:SModioModID):bool
	{
		var i : int;
		
		for(i = 0; i < m_modList.Size(); i+= 1)
		{
			if(theGame.GetModHandlerSystem().ConvertModIDToString(m_modList[i].id) == modidStr)
			{
				modid = m_modList[i].id;
				return true;
			}
		}
		return false;
	}
	
	private function GetGFxLibraryPreviewItem(l_ModArray : array<SModioModData>, index : int, out GFxObjectData:CScriptedFlashObject):void
	{
		var enabled : bool = !theGame.GetModHandlerSystem().IsLocalModDisabled(l_ModArray[index].id);

		GFxObjectData.SetMemberFlashUInt("id", index);
		GFxObjectData.SetMemberFlashString("modid", theGame.GetModHandlerSystem().ConvertModIDToString(l_ModArray[index].id));
		GFxObjectData.SetMemberFlashString("name", "prevName"); 
		GFxObjectData.SetMemberFlashString("label", "testlabel" + index);
		GFxObjectData.SetMemberFlashString("icon", ""); 
		GFxObjectData.SetMemberFlashString("modName", l_ModArray[index].displayname);
		GFxObjectData.SetMemberFlashString("modDesc", l_ModArray[index].summary);
		GFxObjectData.SetMemberFlashString("modVersion", l_ModArray[index].version);
		GFxObjectData.SetMemberFlashBool("hideCheckbox", m_hideCheckbox);
		GFxObjectData.SetMemberFlashBool("visible", true);
		GFxObjectData.SetMemberFlashBool("enabled", enabled);
		GFxObjectData.SetMemberFlashBool("UGCAllowed", m_UGCAllowed);
		
		if( enabled )
		{
			m_acceptedMods.PushBack(theGame.GetModHandlerSystem().ConvertModIDToString(l_ModArray[index].id));
		}
	}
	
	public function HandleModEnabledChange( modid:string, value:bool )
	{
		var i : int;
		
		for( i = 0; i < m_acceptedMods.Size(); i+=1 )
		{
			if(m_acceptedMods[i] == modid)
			{
				if(!value)
				{
					m_acceptedMods.Erase(i);
				}
				return;
			}
		}
		
		if(value)
		{
			m_acceptedMods.PushBack(modid);
		}
	}
	
	protected  function DefineDefaultButtons():void
	{
		var isSwitchPlatform : bool = theGame.GetPlatform() == Platform_Switch2_Ounce;
		var checkboxEnablePadNavCode : string = "gamepad_X";

		if (theGame.GetPlatform() == Platform_Switch2_Ounce)
		{
			checkboxEnablePadNavCode = "gamepad_Y";
		}

		if ( m_isFailed )
		{
			
			AddButtonDef("panel_button_common_accept", "enter-gamepad_A", IK_Enter);
			return;
		}

		AddButtonDef("panel_button_common_accept", "enter-gamepad_A", IK_Enter);
		AddButtonDef("panel_button_common_exit", "escape-gamepad_B", IK_Escape);
		AddButtonDef("panel_checkbox_default_enable", checkboxEnablePadNavCode, IK_Space);
	}

}

class W3RestartNeededPopupData extends ConfirmationPopupData
{
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
		
		theGame.RequestExit();
		ClosePopup();
	}
	
	protected  function OnUserDecline() : void
	{
		ClosePopup();
	}
	
	protected  function GetAcceptText() : string
	{
		return "panel_mods_restart_now";
	}
	
	protected  function GetDeclineText() : string
	{
		return "panel_mods_restart_later";
	}
	
	public function SetupForModioEnabledChange():void
	{
		SetMessageTitle("[[panel_restart_needed]]");
		SetMessageText("[[mods_enabled_change]]");
	}
	
	public function SetupForModSubscribed():void
	{
		SetMessageTitle("[[panel_restart_needed]]");
		SetMessageText("[[mods_finished_downloading]]");
	}
	
}

class W3SignoutConfirmPopupData extends ConfirmationPopupData
{
	public var m_stateMachine : CR4ModMenuStates;
	
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
		m_stateMachine.OnRequestLogout();
		ClosePopup();
	}
	
	protected  function OnUserDecline() : void
	{
		ClosePopup();
	}
	
	protected  function GetAcceptText() : string
	{
		return "ui_gog_button_signout";
	}
	
	protected  function GetDeclineText() : string
	{
		return "panel_button_common_exit";
	}
	
	public function SetupTexts():void
	{
		var desc : string;
		
		desc = GetLocStringByKeyExt("mods_panel_logout") + "&#10;" + GetLocStringByKeyExt("mods_panel_logout_delete");
	
		SetMessageTitle("[[ui_gog_button_signout]]");
		
		SetMessageText(desc);
	}
	
}

class W3ModioConfirmPopupData extends ConfirmationPopupData
{
	var m_menuRef : CR4ModMenu;

	public function SetMenuRef(ref : CR4ModMenu) : void
	{
		m_menuRef = ref;
	}


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
		ClosePopup();
	}
	
	protected  function OnUserDecline() : void
	{
		ClosePopup();
	}
	
	protected  function GetAcceptText() : string
	{
		return "panel_common_yes";
	}
	
	protected  function GetDeclineText() : string
	{
		return "panel_common_no";
	}
	
	public function SetupTexts():void
	{
		SetMessageTitle("[[panel_restart_needed]]");
		SetMessageText("[[mods_enabled_change]]");
	}
}

class W3UninstallConfirmPopupData extends W3ModioConfirmPopupData
{	
	private var m_modid:SModioModID;

	public function SetModid(modid:SModioModID)
	{
		m_modid = modid;
	}

	protected  function OnUserAccept() : void
	{
		m_menuRef.UnsubscribeConfirmed(m_modid);
		ClosePopup();
	}
	
	public function SetupTexts():void
	{
		SetMessageTitle("[[panel_mods_sure]]");
		SetMessageText("[[panel_mods_sure_uninstall]]");
	}
}

class W3HideModConfirmPopupData extends W3ModioConfirmPopupData
{	
	private var m_modid:string;

	public function SetModid(modid:string)
	{
		m_modid = modid;
	}

	protected  function OnUserAccept() : void
	{
		m_menuRef.OnHideModConfirmed(m_modid);
		ClosePopup();
	}
	
	public function SetupTexts():void
	{
		SetMessageTitle("[[panel_mods_sure]]");
		SetMessageText("[[panel_mods_sure_hide_mod]]");
	}
}


class W3HideAuthorConfirmPopupData extends W3ModioConfirmPopupData
{	
	private var m_modid:string;

	public function SetModid(modid:string)
	{
		m_modid = modid;
	}

	protected  function OnUserAccept() : void
	{
		m_menuRef.OnHideAuthorConfirmed(m_modid);
		ClosePopup();
	}
	
	public function SetupTexts():void
	{
		SetMessageTitle("[[panel_mods_sure]]");
		SetMessageText("[[panel_mods_sure_hide_author]]");
	}
}

class W3CloseReportConfirmPopupData extends W3ModioConfirmPopupData
{	
	protected  function OnUserAccept() : void
	{
		m_menuRef.OnCloseReportWindowConfirmed();
		ClosePopup();
	}
	
	public function SetupTexts():void
	{
		SetMessageTitle("[[panel_mods_sure]]");
		SetMessageText("[[panel_mods_sure_exit_report]]");
	}
}