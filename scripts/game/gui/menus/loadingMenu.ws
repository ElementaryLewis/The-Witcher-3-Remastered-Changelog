/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4LoadingMenu extends CR4MenuBase
{
	
	
	
	
	private var guiManager : CR4GuiManager;
	
	event  OnConfigUI()
	{
		
		
		theInput.StoreContext( 'EMPTY_CONTEXT' );
		
		super.OnConfigUI();
		
		m_flashModule = GetMenuFlash();
		MakeModal(true);
	}

	event  OnCloseMenu()
	{
		CloseMenu();
	}	
	
	event  OnClosingMenu()
	{
		theInput.RestoreContext( 'EMPTY_CONTEXT', true );
	}
	
	event OnPlaySoundEvent( soundName : string )
	{
	}
}

exec function loadingmenu()
{
	theGame.RequestMenu('LoadingMenu');
}

exec function loadingmenuclose()
{
	var guiManager : CR4GuiManager;
	guiManager = theGame.GetGuiManager();
	guiManager.CancelFlashbackVideo();
	theGame.CloseMenu('LoadingMenu');
}