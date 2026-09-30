/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CR4LootManager extends IGameSystem
{
	import final function SetCurrentArea( areaName : string );
	import final function GetCurrentArea() : string;

	public function OnAreaChanged(newArea : name)
	{
		SetCurrentArea( NameToString( newArea ) );
		LogRandomLoot("CR4LootManager.OnAreaChanged: active area is now <<" + GetCurrentArea() + ">>" );
	}	
}