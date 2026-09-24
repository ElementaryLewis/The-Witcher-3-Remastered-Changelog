/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4EndScreenMenu extends CR4StartScreenMenuBase
{	
	event  OnConfigUI()
	{	
		super.OnConfigUI();
	}
	
	event  OnCloseMenu()
	{
		theGame.FadeInAsync(thePlayer.GetStartScreenFadeInDuration());
		thePlayer.SetEndScreenIsOpened(false);
		CloseMenu();
		theInput.RestoreContext( 'EMPTY_CONTEXT', true );
	}
	
	event OnKeyPress() 
	{
		
		
		
	}	
}