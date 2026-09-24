/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4MainGammaMenu extends CR4MenuBase
{
	protected var mInGameConfigWrapper	: CInGameConfigWrapper;
	private var m_fxSetCurrentUsername  : CScriptedFlashFunction;
	
	event  OnConfigUI()
	{
		var m_menuInitData 	: W3MainMenuInitData;
		var username		: string;
		
		super.OnConfigUI();
		m_menuInitData = (W3MainMenuInitData)GetMenuInitData();
		MakeModal(true);
		
		mInGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		m_fxSetCurrentUsername = m_flashModule.GetMemberFlashFunction("setCurrentUsername");
		
		username = FixStringForFont(theGame.GetActiveUserDisplayName());
		m_fxSetCurrentUsername.InvokeSelfOneArg(FlashArgString(username));
		
		sendGammaValueInformation();
		
		theGame.GetGuiManager().OnEnteredConfigScreen();
	}

	event  OnCloseMenu()
	{
		theGame.SaveUserSettings();
		
		CloseMenu();
	}
	
	event  OnOptionValueChanged(groupId:int, optionName:name, optionValue:string)
	{
		mInGameConfigWrapper.SetVarValue('Visuals', 'GammaValue', optionValue);
	}
	
	event  OnRefreshActiveUserDisplayName()
	{
		var username 			: string;

		username = FixStringForFont(theGame.GetActiveUserDisplayName());
		m_fxSetCurrentUsername.InvokeSelfOneArg(FlashArgString(username));
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
}


exec function gammamenu()
{
	
	theGame.SetMenuToOpen( '' );
	theGame.RequestMenu('MainGammaMenu');
}

