/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4HudModuleDeathScreen extends CR4HudModuleBase
{
	private var m_fxSetShowBlackscreenSFF			: CScriptedFlashFunction;
	public var m_flashValueStorage : CScriptedFlashValueStorage;	
	public var hasSaveData : bool;	
	public var isOpened : bool;
	
	
	
	
	
	
	
	
	
	
	

	event  OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		
		isOpened = false;
		m_anchorName = "ScaleOnly";
		m_flashValueStorage = GetModuleFlashValueStorage();
		super.OnConfigUI();
		flashModule = GetModuleFlash();	
		m_fxSetShowBlackscreenSFF			= flashModule.GetMemberFlashFunction( "setShowBlackscreen" );
		PopulateData();
		SetTickInterval( 1 );
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
			l_DataFlashObject.SetMemberFlashString( "label", GetPlatformLocString( "panel_button_deathscreen_load" ) );
			l_DataFlashObject.SetMemberFlashUInt( "tag", NameToFlashUInt('Load') );
			l_FlashArray.PushBackFlashObject( l_DataFlashObject );
		
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();	
			l_DataFlashObject.SetMemberFlashString	( "label", GetLocStringByKeyExt("panel_button_deathscreen_respawn") );
			l_DataFlashObject.SetMemberFlashUInt	( "tag", NameToFlashUInt('Respawn') );
			l_FlashArray.PushBackFlashObject( l_DataFlashObject );
		}
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();	
		l_DataFlashObject.SetMemberFlashString	( "label", GetLocStringByKeyExt("panel_button_common_quittomainmenu") );
		l_DataFlashObject.SetMemberFlashUInt	( "tag", NameToFlashUInt('Quit') );
		l_FlashArray.PushBackFlashObject( l_DataFlashObject );
		
		m_flashValueStorage.SetFlashArray( "hud.deathscreen.list", l_FlashArray );
	}
	
	event OnTick( timeDelta : float )
	{
		if (isOpened)
		{
			if ( !CanTick( timeDelta ) )
			{
				return true;
			}
			
			if( hasSaveData != hasSaveDataToLoad() )
			{
				PopulateData();
			}
			
			if( theGame.IsBlackscreen() || theGame.IsFading() )
			{
				m_fxSetShowBlackscreenSFF.InvokeSelfOneArg(FlashArgBool(true));
				theGame.FadeInAsync(0);
			}
		}
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
		}
	}
	
	event  OnOpened( opened : bool )
	{	
		var tutorialPopupRef  : CR4TutorialPopup;
		if ( opened )
		{
			tutorialPopupRef = (CR4TutorialPopup)theGame.GetGuiManager().GetPopup('TutorialPopup');
			if (tutorialPopupRef)
			{
				tutorialPopupRef.ClosePopup();
			}
			PopulateData();
			
			theSound.EnterGameState(ESGS_Death);
			theSound.SoundEvent( 'gui_global_player_death_thump' );
			
			theGame.Pause( "DeathScreen" );
		}
		else
		{
			theGame.Unpause( "DeathScreen" );
		}
		isOpened = opened;
	}		

	event  OnLoad()
	{
		var initData : W3MenuInitData = new W3MenuInitData in this;
		initData.setDefaultState('LoadGame');
		theGame.RequestMenuWithBackground( 'IngameMenu', 'CommonIngameMenu', initData );
	}		

	event  OnQuit()
	{
		theGame.GetGuiManager().TryQuitGame();
		isOpened = false;
	}		
	
	event  OnRespawn()
	{
		theGame.SetIsRespawningInLastCheckpoint();
		theGame.LoadLastGameInit( true );
	}
}
