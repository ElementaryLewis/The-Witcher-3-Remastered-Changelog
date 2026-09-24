/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4DeathScreenMenu extends CR4MenuBase
{
	public var hasSaveData : bool;
	
	private var m_fxShowInputFeedback : CScriptedFlashFunction;
	
	event  OnConfigUI()
	{
		var tutorialPopupRef  : CR4TutorialPopup;
		
		super.OnConfigUI();
		
		PopulateData();
		
		m_fxShowInputFeedback = m_flashModule.GetMemberFlashFunction("showInputFeedback");
		
		tutorialPopupRef = (CR4TutorialPopup)theGame.GetGuiManager().GetPopup('TutorialPopup');
		if (tutorialPopupRef)
		{
			tutorialPopupRef.ClosePopup();
		}
		
		
		
		
		theGame.Pause( "DeathScreen" );
		
		theGame.ResetFadeLock('DeathScreenMenu');
		theGame.FadeInAsync( 1.2f );
		
		m_guiManager.RequestMouseCursor(true);
	}
	
	private function updateHudConfigs():void
	{
	}
	
	event  OnClosingMenu()
	{
		m_guiManager.RequestMouseCursor(false);
		
		theInput.RestoreContext( 'EMPTY_CONTEXT', true );
		super.OnClosingMenu();
		
		theGame.Unpause( "DeathScreen" );
	}

	function OnRequestSubMenu( menuName: name, optional initData : IScriptable )
	{
		RequestSubMenu( menuName, initData );
	}

	event  OnCloseMenu()
	{
		var menu			: CR4MenuBase;
		
		menu = (CR4MenuBase)GetSubMenu();
		if( menu )
		{
			menu.CloseMenu();
		}
		CloseMenu();
	}
	
	function CloseMenuRequest():void
	{
		var menu			: CR4MenuBase;
		
		menu = (CR4MenuBase)GetSubMenu();
		if( !menu )
		{
			CloseMenu();
		}
	}
	
	function ChildRequestCloseMenu()
	{
		var menu			: CR4MenuBase;
		var menuToOpen		: name;
		
		if (hasSaveData != hasSaveDataToLoad())
		{
			PopulateData();
		}
		
		m_fxShowInputFeedback.InvokeSelfOneArg(FlashArgBool(true));
		
		
	}
	
	function PopulateData()
	{
		var l_FlashArray			: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;	
		
		l_FlashArray = m_flashValueStorage.CreateTempFlashArray();
				
		hasSaveData = hasSaveDataToLoad();
		if( hasSaveData )
		{
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();	
			l_DataFlashObject.SetMemberFlashString	( "label", GetLocStringByKeyExt("panel_button_deathscreen_respawn") );
			l_DataFlashObject.SetMemberFlashUInt	( "tag", NameToFlashUInt('Respawn') );
			l_FlashArray.PushBackFlashObject( l_DataFlashObject );
			
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();	
			l_DataFlashObject.SetMemberFlashString( "label", GetPlatformLocString("panel_button_deathscreen_load" ) );
			l_DataFlashObject.SetMemberFlashUInt	( "tag", NameToFlashUInt('Load') );
			l_FlashArray.PushBackFlashObject( l_DataFlashObject );
		
			
		}
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();	
		l_DataFlashObject.SetMemberFlashString	( "label", GetLocStringByKeyExt("panel_button_common_quittomainmenu") );
		l_DataFlashObject.SetMemberFlashUInt	( "tag", NameToFlashUInt('Quit') );
		l_FlashArray.PushBackFlashObject( l_DataFlashObject );
		
		if( theGame.IsDebugQuestMenuEnabled() && !theGame.IsFinalBuild() )
		{
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
			l_DataFlashObject.SetMemberFlashString	( "label", "***Debug Resurrect***" );
			l_DataFlashObject.SetMemberFlashUInt	( "tag", NameToFlashUInt('DebugResurrect') );
			l_FlashArray.PushBackFlashObject( l_DataFlashObject );
		}
		
		m_flashValueStorage.SetFlashArray( "hud.deathscreen.list", l_FlashArray );
	}
	
	function PlayOpenSoundEvent()
	{
	}
	
	public function SetMenuAlpha( value : int ) : void
	{
		m_flashModule.SetAlpha(value);
	}
	
	event  OnPress( tag : name )
	{
		switch( tag )
		{
			case 'Load' :
				OnLoad();
				break;
			case 'Respawn' :
				OnRespawn();
				
				break;
			case 'Quit' :
				OnQuit();
				
				break;
			case 'DebugResurrect' :
				thePlayer.CheatResurrect();
				break;
		}
	}
	
	public function HideInputFeedback() : void
	{
		m_fxShowInputFeedback.InvokeSelfOneArg(FlashArgBool(false));
	}
	
	event  OnLoad()
	{
		var initData : W3MenuInitData = new W3MenuInitData in this;
		initData.setDefaultState('LoadGame');
		RequestSubMenu( 'IngameMenu', initData );
	}		

	event  OnQuit()
	{
		theGame.GetGuiManager().TryQuitGame();
	}		
	
	event  OnRespawn()
	{
		theGame.SetIsRespawningInLastCheckpoint();
		theGame.LoadLastGameInit( true );
	}
}

exec function deathscreen()
{
	theGame.RequestMenu('DeathScreenMenu');
}