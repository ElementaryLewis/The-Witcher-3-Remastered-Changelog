/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4StartScreenMenu extends CR4StartScreenMenuBase
{	
}

exec function TheBegining()
{
	theGame.RequestMenu('StartScreenMenu');
}