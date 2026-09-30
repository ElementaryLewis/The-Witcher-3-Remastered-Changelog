/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CCityLightManager extends IGameSystem
{
	import function SetEnabled		(toggle:bool) 	: void;
	import function IsEnabled		() 				: bool;
	import function ForceUpdate		() 				: void;
	import function SetUpdateEnabled(value:bool) 	: void;
	import function DebugToggleAll	(toggle:bool) 	: void;	

}

exec function ToggleAll(toggle:bool)
{
	theGame.GetCityLightManager().DebugToggleAll(toggle);
}