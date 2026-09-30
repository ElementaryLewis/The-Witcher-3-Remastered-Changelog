/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4PopupBase extends CR4Popup
{
	protected var m_flashValueStorage 	 	: CScriptedFlashValueStorage;
	protected var m_flashModule     	 	: CScriptedFlashSprite;
	protected var m_fxSetArabicAligmentMode : CScriptedFlashFunction;
	protected var m_fxSetGameLanguage		: CScriptedFlashFunction;
	protected var m_fxSwapAcceptCancel	    : CScriptedFlashFunction;

	protected var m_fxSetControllerType  	: CScriptedFlashFunction;
	protected var m_fxSetPlatform        	: CScriptedFlashFunction;	
	protected var m_fxSetGamepadType       	: CScriptedFlashFunction;
	protected var m_fxLockControlScheme     : CScriptedFlashFunction;
	
	protected var m_guiManager : CR4GuiManager;	
	
	event  OnConfigUI() 
	{	
		m_guiManager = theGame.GetGuiManager();
	
		m_flashValueStorage = GetPopupFlashValueStorage();
		m_flashModule = GetPopupFlash();
		
		m_fxSetControllerType 	   = m_flashModule.GetMemberFlashFunction( "setControllerType" );
		m_fxSetPlatform 		   = m_flashModule.GetMemberFlashFunction( "setPlatform" );
		m_fxSetArabicAligmentMode  = m_flashModule.GetMemberFlashFunction( "setArabicAligmentMode" );
		m_fxSetGameLanguage        = m_flashModule.GetMemberFlashFunction( "setGameLanguage" );
		m_fxSwapAcceptCancel       = m_flashModule.GetMemberFlashFunction( "swapAcceptCancel" );
		m_fxSetGamepadType		   = m_flashModule.GetMemberFlashFunction( "setGamepadType" );
		m_fxLockControlScheme	   = m_flashModule.GetMemberFlashFunction( "lockControlScheme" );
		
		UpdateControlSchemeLock();
		SetControllerType(theInput.LastUsedGamepad());
		SetPlatformType(theGame.GetPlatform());
		setArabicAligmentMode();
		UpdateAcceptCancelSwaping();
		
		
		UpdateInputDeviceType();
	}
	
	event  OnClosingPopup()
	{
		var initData:IScriptable;
		initData = GetPopupInitData();
		if ( initData )
		{
			delete initData;
		}
	}
	
	public function UpdateAcceptCancelSwaping():void
	{
		var inGameConfigWrapper : CInGameConfigWrapper;
		var configValue : bool;
		
		if (m_fxSwapAcceptCancel)
		{
			inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
			configValue = inGameConfigWrapper.GetVarValue('Controls', 'SwapAcceptCancel');
			m_fxSwapAcceptCancel.InvokeSelfOneArg( FlashArgBool(configValue) );
		}
	}
	
	protected function UpdateInputDeviceType():void
	{
		var deviceType : EInputDeviceType;
		
		if (m_fxSetGamepadType)
		{
			deviceType = theInput.GetLastUsedGamepadType();
			m_fxSetGamepadType.InvokeSelfOneArg( FlashArgUInt(deviceType) );
		}
	}
	
	
	protected function UpdateControlSchemeLock():void
	{
		if (m_fxLockControlScheme && m_guiManager)
		{
			m_fxLockControlScheme.InvokeSelfOneArg( FlashArgUInt(m_guiManager.GetLockedControlScheme()) );
		}
	}
	
	protected function SetControllerType(isGamepad:bool):void
	{
		if (m_fxSetControllerType)	
		{
			m_fxSetControllerType.InvokeSelfOneArg( FlashArgBool(isGamepad) );
		}
	}
	
	protected function SetPlatformType(platformType:Platform):void
	{
		if (m_fxSetPlatform)
		{
			m_fxSetPlatform.InvokeSelfOneArg( FlashArgInt(platformType) );
		}
	}
	
	public function setArabicAligmentMode() : void
	{
		var language : string;
		var audioLanguage : string;
		theGame.GetGameLanguageName(audioLanguage,language);
		if (m_fxSetArabicAligmentMode)
		{
			m_fxSetArabicAligmentMode.InvokeSelfOneArg( FlashArgBool( (language == "AR") ) );
		}
		if ( m_fxSetGameLanguage )
		{
			m_fxSetGameLanguage.InvokeSelfOneArg( FlashArgString( language ) );
		}
	}
	
	event  OnPlaySoundEvent( soundName : string )
	{
		theSound.SoundEvent( soundName );
	}
}