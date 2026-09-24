/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SMovieData
{
	var movieName : string;
	var isSkipable : bool;
	var showLogo : bool;
};

class CR4StartupMoviesMenu extends CR4MenuBase
{
	private var m_fxSetGameLogoLanguage	: CScriptedFlashFunction;
	private var m_MovieData 		: array<SMovieData>;
	private var m_CurrentMovieID	: int;
	default m_CurrentMovieID		= 0;
	private var guiManager 			: CR4GuiManager;
	private var wasSkipped 			: bool;
	default wasSkipped 				= false;
	private var languageName : string;
	
	event  OnConfigUI()
	{
		var menuName : name;
		var audioLanguageName : string;
		SetupMoviesData();
		m_flashValueStorage = GetMenuFlashValueStorage();
		super.OnConfigUI();
		m_flashModule = GetMenuFlash();
		guiManager = theGame.GetGuiManager();
		
		if (m_MovieData.Size() == 0)
		{
			CloseMenu();
		}
		else
		{
			m_fxSetGameLogoLanguage = m_flashModule.GetMemberFlashFunction( "setGameLogoLanguage" );
			
			theGame.GetGameLanguageName(audioLanguageName,languageName);
			m_fxSetGameLogoLanguage.InvokeSelfTwoArgs( FlashArgBool(m_MovieData[m_CurrentMovieID].showLogo), FlashArgString(languageName) );
			guiManager.PlayFlashbackVideoAsync(GetCurrentBackgroundMovie());
			
		}
		
		theInput.StoreContext( 'EMPTY_CONTEXT' );
	}
	
	private function SetupMoviesData() 
	{
		var movieData : SMovieData;
		
		m_MovieData.Clear();
		
		
		if( theGame.GetPlatform() == Platform_PC ) 
		{
			movieData.movieName = "gamestart/epilepsy/epilepsy.usm";
			movieData.isSkipable = true;
			movieData.showLogo = false;
			m_MovieData.PushBack(movieData);

			movieData.movieName = "gamestart/bumpers/bumpers.usm";
			m_MovieData.PushBack(movieData);
		}
	}
	
	function GetCurrentBackgroundMovie() : string
	{
		return m_MovieData[m_CurrentMovieID].movieName;
	}
	
	event  OnClosingMenu()
	{
		super.OnClosingMenu();
		guiManager.CancelFlashbackVideo();
		theInput.RestoreContext( 'EMPTY_CONTEXT', true );
	}	
	
	event  OnSkipMovie()
	{
		m_CurrentMovieID += 1;
		if( m_CurrentMovieID >= m_MovieData.Size() )
		{
			CloseMenu();
			return false;
		}
		SetButtons();
		m_fxSetGameLogoLanguage.InvokeSelfTwoArgs( FlashArgBool(m_MovieData[m_CurrentMovieID].showLogo), FlashArgString(languageName) );
		guiManager.PlayFlashbackVideoAsync(GetCurrentBackgroundMovie());
		wasSkipped = true;
	}

	

	event  OnSwipe( swipe : int )
	{
	}

	event  OnCloseMenu()
	{
		CloseMenuRequest();
	}
	
	function CloseMenuRequest():void
	{
		var menu			: CR4MenuBase;
		
		menu = (CR4MenuBase)GetSubMenu();
		if( !menu )
		{
			CloseMenu();
		}
		else
		{
			
			
			
		}
	}
	
	event OnVideoSubtitles( subtitles : string )
	{
		
		
	}
	
	protected function GatherBindersArray(out resultArray : CScriptedFlashArray, bindersList : array<SKeyBinding>, optional isContextBinding:bool)
	{
		var tempFlashObject	: CScriptedFlashObject;
		var bindingGFxData  : CScriptedFlashObject;
		var curBinding	    : SKeyBinding;
		var bindingsCount   : int;
		var i			    : int;
		
		bindingsCount = bindersList.Size();
		for( i =0; i < bindingsCount; i += 1 )
		{
			curBinding = bindersList[i];
			tempFlashObject = m_flashValueStorage.CreateTempFlashObject();
			bindingGFxData = tempFlashObject.CreateFlashObject("red.game.witcher3.data.KeyBindingData");
			bindingGFxData.SetMemberFlashString("gamepad_navEquivalent", curBinding.Gamepad_NavCode );
			bindingGFxData.SetMemberFlashInt("keyboard_keyCode", curBinding.Keyboard_KeyCode );
			bindingGFxData.SetMemberFlashString("label", GetLocStringByKeyExt(curBinding.LocalizationKey) );
			bindingGFxData.SetMemberFlashString("isContextBinding", isContextBinding);
			resultArray.PushBackFlashObject(bindingGFxData);
		}
	}
	
	protected function UpdateInputFeedback():void
	{
		var gfxDataList	: CScriptedFlashArray;
		gfxDataList = m_flashValueStorage.CreateTempFlashArray();
		GatherBindersArray(gfxDataList, m_defaultInputBindings);
		m_flashValueStorage.SetFlashArray("startup.movies.buttons.setup", gfxDataList);
	}
		
	function SetButtons()
	{	
		var ButtonsDef	: array<SMenuButtonDef>;
		m_defaultInputBindings.Clear();
		if( m_MovieData[m_CurrentMovieID].isSkipable )
		{
			AddInputBinding("panel_button_dialogue_skip", "gamepad_X", 32 );
		}
		UpdateInputFeedback();
	}	
	
	protected function AddInputBinding(label:string, padNavCode:string, optional keyboardKeyCode:int)
	{
		var bindingDef:SKeyBinding;
		bindingDef.Gamepad_NavCode = padNavCode;
		bindingDef.Keyboard_KeyCode = keyboardKeyCode;
		bindingDef.LocalizationKey = label;
		m_defaultInputBindings.PushBack(bindingDef);
	}
	
	function PlayOpenSoundEvent()
	{
	}
	
	event OnVideoStarted()
	{
		LogChannel('MOVIES',"OnVideoStarted");
	}
	
	event OnVideoStopped()
	{
		LogChannel('MOVIES',"OnVideoStopped");
		if( !wasSkipped )
		{
			OnSkipMovie();
		}
		wasSkipped = false;
	}
}


exec function startupmovies()
{
	theGame.RequestMenu( 'StartupMoviesMenu' );
}