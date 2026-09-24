/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4StartScreenMenuBase extends CR4MenuBase
{	
	private var _fadeDuration : float;
	default _fadeDuration = 0.1;
	protected var m_fxSetFadeDuration	: CScriptedFlashFunction;
	protected var m_fxSetIsStageDemo	: CScriptedFlashFunction;
	protected var m_fxStartFade			: CScriptedFlashFunction;
	private var m_fxSetGameLogoLanguage	: CScriptedFlashFunction;
	protected var m_fxSetText			: CScriptedFlashFunction;
	
	event  OnConfigUI()
	{	
		var languageName : string;
		var audioLanguageName : string;
		super.OnConfigUI();
		
		_fadeDuration = thePlayer.GetStartScreenFadeDuration();
		m_fxSetFadeDuration = GetMenuFlash().GetMemberFlashFunction("SetFadeDuration");
		m_fxStartFade = GetMenuFlash().GetMemberFlashFunction("startClosingTimer");
		m_fxSetText = GetMenuFlash().GetMemberFlashFunction("setDisplayedText");
		SetFadeTime();
		theInput.StoreContext( 'EMPTY_CONTEXT' );
		
		setStandardtext();
		theGame.GetGuiManager().OnEnteredStartScreen();
		
		theGame.SetActiveUserPromiscuous();
		
		m_fxSetGameLogoLanguage = m_flashModule.GetMemberFlashFunction( "setGameLogoLanguage" );
		theGame.GetGameLanguageName(audioLanguageName,languageName);
		m_fxSetGameLogoLanguage.InvokeSelfOneArg( FlashArgString(languageName) );
		
		theSound.StopMusic( );
		theSound.SoundEvent( "play_music_main_menu" );
		theSound.SoundEvent( "mus_main_menu_theme_fire_only" );
		
		theGame.ResetFadeLock( "Entering start screen" );
		
		if( theGame.IsBlackscreen() )
		{
			theGame.FadeInAsync();
		}
	}
	
	event  OnCloseMenu()
	{
		if( !thePlayer.GetStartScreenEndWithBlackScreen() )
		{
			theGame.FadeInAsync(thePlayer.GetStartScreenFadeInDuration());
		}
		thePlayer.SetStartScreenIsOpened(false);
		CloseMenu();
		theInput.RestoreContext( 'EMPTY_CONTEXT', true );
		
		theGame.GetGuiManager().SetIsDuringFirstStartup( false );
		
		theSound.SoundEvent("stop_music"); 
	}

	private function SetFadeTime()
	{
		var time : int;
		time = (int)(1000 * _fadeDuration);
		m_fxSetFadeDuration.InvokeSelfOneArg(FlashArgNumber(time));
		theGame.FadeInAsync(_fadeDuration);
	}
	
	public function startFade():void
	{
		m_fxStartFade.InvokeSelf();
	}
	
	event OnKeyPress()
	{
		if (theGame.isUserSignedIn())
		{
			startFade();
		}
	}
	
	event OnPlaySoundEvent( soundName : string )
	{
	}
	
	public function setStandardtext():void
	{
		m_fxSetText.InvokeSelfOneArg( FlashArgString( GetPlatformLocString( "panel_button_press_any" ) ) );
	}
	
	public function setWaitingText()
	{
		
		m_fxSetText.InvokeSelfOneArg(FlashArgString(GetLocStringByKeyExt("panel_please_wait")));
	}
	
	function PlayOpenSoundEvent() 
	{
	}
}

exec function SetStartScreenPlatform( value : int )
{
	var guiManager : CR4GuiManager;
	var ssMenu : CR4StartScreenMenuBase;
	guiManager = theGame.GetGuiManager();
	ssMenu = (CR4StartScreenMenuBase)guiManager.GetRootMenu(); 
	if( ssMenu )
	{
		ssMenu.SetPlatformType(value);
	}
}