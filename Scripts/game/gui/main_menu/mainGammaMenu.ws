/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4MainGammaMenu extends CR4MenuBase
{
	protected var mInGameConfigWrapper	: CInGameConfigWrapper;
	protected var m_hdrEnabled : bool; default m_hdrEnabled = false;

	protected var m_fxSetHDRMode 	: CScriptedFlashFunction;
	protected var m_fxSetUsername 	: CScriptedFlashFunction;
	

	protected var m_createdVars : int;
	private var m_fxSetCurrentUsername  : CScriptedFlashFunction;
	
	event  OnConfigUI()
	{
		var username : string;
		var m_menuInitData 	: W3MainMenuInitData;
		
		super.OnConfigUI();
		
		m_hdrEnabled = theGame.GetHDREnabled();

		m_fxSetHDRMode = m_flashModule.GetMemberFlashFunction( "setHDRMode" );
		m_fxSetUsername = m_flashModule.GetMemberFlashFunction( "setUsername" );
		
		m_createdVars = 0;

		setHDRMode(m_hdrEnabled);
		
		m_menuInitData = (W3MainMenuInitData)GetMenuInitData();
		MakeModal(true);

		mInGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		m_fxSetCurrentUsername = m_flashModule.GetMemberFlashFunction("setCurrentUsername");
		
		username = FixStringForFont(theGame.GetActiveUserDisplayName());
		m_fxSetCurrentUsername.InvokeSelfOneArg(FlashArgString(username));
		
		if(m_hdrEnabled)
			sendHDRValueInformation();
		else
			sendGammaValueInformation();

		
		theGame.GetGuiManager().OnEnteredConfigScreen();
	}

	event  OnCloseMenu()
	{
		theGame.SaveUserSettings();

		theGame.SetHDRMenuActive(false);
		theGame.SetHDRMenuActiveAsStandalone(false);
		
		CloseMenu();
	}
	
	event  OnOptionValueChanged(groupId:int, optionName:name, optionValue:string)
	{
		if(m_hdrEnabled)
			OnOptionValueChangedHDR(groupId, optionName, optionValue);
		else
			mInGameConfigWrapper.SetVarValue('Visuals', 'GammaValue', optionValue);
	}
	
	event  OnRefreshActiveUserDisplayName()
	{
		var username 			: string;
		
		username = FixStringForFont(theGame.GetActiveUserDisplayName());
		m_fxSetCurrentUsername.InvokeSelfOneArg(FlashArgString(username));
	}

	protected function setHDRMode(value : bool)
	{
		m_fxSetHDRMode.InvokeSelfOneArg(FlashArgBool(value));

		theGame.SetHDRMenuActive(value);
		theGame.SetHDRMenuActiveAsStandalone(value);
	}

	protected function sendGammaValueInformation():void
	{
		var objectToSend 		: CScriptedFlashObject;
		var groupID		 		: int;
		var groupName			: name;
		var numOptionsGroups	: int;
		
		objectToSend = m_flashValueStorage.CreateTempFlashObject();
		
		FillSubMenuOptionsList('Visuals', 'GammaValue', objectToSend);
		
		m_flashValueStorage.SetFlashObject( "gammamenu.setvalues", objectToSend );
	}

	protected function sendHDRValueInformation():void
	{
		var tempFlashObject 	: CScriptedFlashObject;
		var flashArray			: CScriptedFlashArray;
		var groupID		 		: int;
		var groupName			: name;
		var numOptionsGroups	: int;

		flashArray = m_flashValueStorage.CreateTempFlashArray();

		
		
		
		tempFlashObject = CreateOptionObject('HDR', 'MaxTVBrightness');
		flashArray.PushBackFlashObject(tempFlashObject);

		
		tempFlashObject = CreateOptionObject('HDR', 'HdrPaperWhite');
		flashArray.PushBackFlashObject(tempFlashObject);

		
		tempFlashObject = CreateOptionObject('HDR', 'HdrSaturation');
		flashArray.PushBackFlashObject(tempFlashObject);
		
		m_flashValueStorage.SetFlashArray( "hdrmenu.setvalues", flashArray );
	}
	
	protected function FillSubMenuOptionsList(groupName:name, optionName:name, groupRootObject : CScriptedFlashObject):void
	{
		var groupDisplayName	: string;
		var groupOptionArray	: CScriptedFlashArray;
		var optionFlashArray 	: CScriptedFlashArray;
		var optionValueObject	: CScriptedFlashObject;
		var presetNum			: int;
		var numOptions			: int;
		var i					: int;
		var option_it			: int;
		var numOptionValues		: int;
		var optionDisplayType	: string;
		var optionValue			: string;
		var optionVarValue		: string;
		
		optionValue = mInGameConfigWrapper.GetVarValue(groupName, optionName);
		
		groupRootObject.SetMemberFlashString( "id", "" + i );
		groupRootObject.SetMemberFlashString( "label", "" );
		groupRootObject.SetMemberFlashUInt( "type", IGMActionType_Gamma );
		groupRootObject.SetMemberFlashString(  "description", "" );
		groupRootObject.SetMemberFlashUInt( "tag", NameToFlashUInt(optionName) );
		groupRootObject.SetMemberFlashString( "current", optionValue);
		groupRootObject.SetMemberFlashString( "startingValue", optionValue);
		groupRootObject.SetMemberFlashInt( "groupID", 0 );
		groupRootObject.SetMemberFlashBool( "isConfig", true );
		
		numOptionValues = mInGameConfigWrapper.GetVarOptionsNum(groupName, optionName);
		
		optionFlashArray = m_flashValueStorage.CreateTempFlashArray();
		
		for (option_it = 0; option_it < numOptionValues; option_it += 1)
		{
			optionVarValue = mInGameConfigWrapper.GetVarOption(groupName, optionName, option_it);
			optionFlashArray.PushBackFlashString(optionVarValue);
		}
		
		groupRootObject.SetMemberFlashArray( "subElements", optionFlashArray );
	}

	protected function GetGroupIDByGroupName(wantedGroupName:name):int
	{
		var i 						: int;
		var numOptionsGroups		: int;
		var groupName				: name;

		numOptionsGroups = mInGameConfigWrapper.GetGroupsNum();
	
		for (i = 0; i < numOptionsGroups; i += 1)
		{
			groupName = mInGameConfigWrapper.GetGroupName(i);
			
			if (groupName == wantedGroupName) 
			{
				return i;
			}
		}
		return -1;
	}

	protected function CreateOptionObject(groupName:name, optionName:name):CScriptedFlashObject
	{
		var groupDisplayName	: string;
		var groupOptionArray	: CScriptedFlashArray;
		var optionFlashArray 	: CScriptedFlashArray;
		var optionValueObject	: CScriptedFlashObject;
		var presetNum			: int;
		var numOptions			: int;
		var i					: int;
		var option_it			: int;
		var numOptionValues		: int;
		var optionDisplayName	: string;
		var optionDisplayType	: string;
		var optionValue			: string;
		var optionVarValue		: string;
		var optionObject 		: CScriptedFlashObject;
		var customDisplayName 	: bool;
		var noLocalizationName 	: bool;
		var groupID : int;

		optionDisplayName = mInGameConfigWrapper.GetVarDisplayName(groupName, optionName);
		optionDisplayType = mInGameConfigWrapper.GetVarDisplayType(groupName, optionName);
		optionValue = mInGameConfigWrapper.GetVarValue(groupName, optionName);
		numOptionValues = mInGameConfigWrapper.GetVarOptionsNum(groupName, optionName);

		customDisplayName = mInGameConfigWrapper.DoVarHasTag(groupName, optionName, 'customDisplayName');
		noLocalizationName = mInGameConfigWrapper.DoVarHasTag(groupName, optionName, 'nonLocalizedName');
		groupID = GetGroupIDByGroupName(groupName);
		
		optionObject = m_flashValueStorage.CreateTempFlashObject();
		optionObject.SetMemberFlashString( "id", "" + m_createdVars );
		optionObject.SetMemberFlashUInt( "type", IngameMenu_GetOptionTypeFromString(optionDisplayType) );
		optionObject.SetMemberFlashUInt( "tag", NameToFlashUInt(optionName) );
		optionObject.SetMemberFlashString( "current", optionValue);
		optionObject.SetMemberFlashString( "startingValue", optionValue);
		optionObject.SetMemberFlashBool( "checkHardwareCursor", false );
		optionObject.SetMemberFlashBool( "isDropdownContent", false );
		optionObject.SetMemberFlashBool( "streamable", false);	
		optionObject.SetMemberFlashInt( "groupID", groupID );
		optionObject.SetMemberFlashBool( "disabled", false);
		optionObject.SetMemberFlashBool( "indent", false );

		optionFlashArray = m_flashValueStorage.CreateTempFlashArray();
		for (option_it = 0; option_it < numOptionValues; option_it += 1)
		{
			optionVarValue = mInGameConfigWrapper.GetVarOption(groupName, optionName, option_it);
			
			optionFlashArray.PushBackFlashString( optionVarValue );
		}
		optionObject.SetMemberFlashArray( "subElements", optionFlashArray );

		if (customDisplayName)
		{
			optionObject.SetMemberFlashString( "label", inGameMenu_TryLocalize(optionDisplayName) );
		}
		else
		{
			if (noLocalizationName)
			{
				optionObject.SetMemberFlashString( "label", optionDisplayName );
			}
			else
			{
				optionObject.SetMemberFlashString( "label", inGameMenu_TryLocalize("option_" + optionDisplayName) );
			}
		}


		m_createdVars+=1;
		return optionObject;
	}

	event  OnOptionSelectionChanged( optionName : name, value : bool)
	{
		
	}

	private function OnOptionValueChangedHDR(groupId:int, optionName:name, optionValue:string)
	{
		var groupName			: name;

		OnPlaySoundEvent( "gui_global_switch" );	
		
		groupName = mInGameConfigWrapper.GetGroupName( groupId );
		
		mInGameConfigWrapper.SetVarValue(groupName, optionName, optionValue);
		theGame.OnConfigValueChanged(optionName, optionValue);

		IngameMenu_AdditionalOptionValueChangeHandling( groupName, optionName, optionValue, m_flashValueStorage );
	}

	event  OnFadeAnimationPercentageChanged(value:float)
	{
		theGame.SetHDRMenuFadePercentage(value);
	}
}


exec function gammamenu()
{
	
	theGame.SetMenuToOpen( '' );
	theGame.RequestMenu('MainGammaMenu');
}