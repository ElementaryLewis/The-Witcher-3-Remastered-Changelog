/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4TestPopup extends CR4Popup
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

exec function testpopup()
{
	theGame.RequestPopup( 'TestPopup' );
}

exec function testpopup2()
{
	theGame.ClosePopup( 'TestPopup' );
}