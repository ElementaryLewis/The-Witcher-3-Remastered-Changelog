/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4MeditationMenu extends CR4MenuBase
{	


	event  OnConfigUI()
	{
		initMeditationState();
		m_flashModule = GetMenuFlash();
		m_flashValueStorage = GetMenuFlashValueStorage();
		
		super.OnConfigUI();
		
		setMenuMode();
	}
	
	private function setMenuMode()
	{
		var RootMenu : CR4CommonMenu;
		
		RootMenu = (CR4CommonMenu)GetRootMenu();
		if ( RootMenu )
		{
			
		}
	}
	
	public function MeditatingEnd()
	{
		
	}
	
	private function initMeditationState()
	{
		var medState : W3PlayerWitcherStateMeditation;
		medState = (W3PlayerWitcherStateMeditation)GetMenuInitData();
		
	}
	
	event  OnClosingMenu()
	{
		theGame.GetGuiManager().SendCustomUIEvent( 'ClosedMeditationMenu' );
	}

	event  OnCloseMenu()
	{
		var medd : W3PlayerWitcherStateMeditation;
		var waitt : W3PlayerWitcherStateMeditationWaiting;
		
		theSound.SoundEvent( 'gui_global_quit' ); 
		CloseMenu();
		if( m_parentMenu )
		{
			m_parentMenu.CloseMenu();
		}
		
		if(thePlayer.GetCurrentStateName() == 'MeditationWaiting')
		{
			waitt = (W3PlayerWitcherStateMeditationWaiting)thePlayer.GetCurrentState();
			if(waitt)
			{
				waitt.StopRequested();
			}
		}
		else
		{
			medd = (W3PlayerWitcherStateMeditation)GetWitcherPlayer().GetCurrentState();
			if(medd)
			{
				medd.StopRequested();
			}
		}
		
		
	}
	
	


}
