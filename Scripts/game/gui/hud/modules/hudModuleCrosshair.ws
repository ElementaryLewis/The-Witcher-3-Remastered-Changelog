/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4HudModuleCrosshair extends CR4HudModuleBase
{	
	event  OnConfigUI()
	{		
		m_anchorName = "mcAnchorCrosshair";
		super.OnConfigUI();
	}
}

exec function testcrosshair( value : bool )
{
	var hud : CR4ScriptedHud;
	var module : CR4HudModuleCrosshair;

	hud = (CR4ScriptedHud)theGame.GetHud();
	module = (CR4HudModuleCrosshair)hud.GetHudModule("CrosshairModule");
	module.ShowElement( value, false );
}