/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4Test2Popup extends CR4Popup
{
	event  OnConfigUI()
	{	
		LogChannel( 'TestPopup', "OnConfigUI" );
	}
	
	event  OnClosingPopup()
	{
		LogChannel( 'TestPopup', "OnClosingPopup" );
	}

	event  OnClosePopup()
	{
		ClosePopup();
		LogChannel( 'TestPopup', "OnClosePopup" );
	}

}

exec function test2popup()
{
	theGame.RequestPopup( 'Test2Popup' );
}

exec function test2popup2()
{
	theGame.ClosePopup( 'Test2Popup' );
}