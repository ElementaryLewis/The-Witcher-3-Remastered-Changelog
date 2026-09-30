/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4HudModuleWatermark extends CR4HudModuleBase
{
	 event OnConfigUI()
	{
		m_anchorName = "mcAnchorWatermark";
		super.OnConfigUI();

		
	}
}

exec function hud_testwatermark( show : bool )
{
	var hud : CR4ScriptedHud;
	var watermarkModule : CR4HudModuleWatermark;

	hud = (CR4ScriptedHud)theGame.GetHud();
	watermarkModule = (CR4HudModuleWatermark)hud.GetHudModule("WatermarkModule");
	watermarkModule.ShowElement( show );
}
