/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_IsRadialMenuOpened extends CQuestScriptedCondition
{
	editable var inverted : bool;
	
	function Evaluate() : bool
	{
		var hud    : CR4ScriptedHud;
		var module : CR4HudModuleRadialMenu;
		var ret	   : bool;
		
		hud = ( CR4ScriptedHud )theGame.GetHud();
		ret = false;
		
		if ( hud )
		{
			module = (CR4HudModuleRadialMenu)hud.GetHudModule( "RadialMenuModule" );
			if ( module )
			{
				ret = module.IsRadialMenuOpened();
			}
		}
		
		if( inverted )
		{
			return !ret;
		}
		
		return ret;
	}
}