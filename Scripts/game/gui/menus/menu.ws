/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CR4Menu extends CMenu
{	
	import function GetSubMenu() : CMenu;
	import function MakeModal( make : bool ) : bool;
	import function SetRenderGameWorldOverride( override : bool ) : void;

	event  OnRefreshActiveUserDisplayName()
	{
	}
}