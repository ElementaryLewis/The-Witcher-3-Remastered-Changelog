/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4HudModuleAreaInfo extends CR4HudModuleBase 
{	
	private var m_fxSetTextSFF	: CScriptedFlashFunction;
	private var dt	: float;
	private var showTime	: float;
	private var bShow	: bool;
	

	event  OnConfigUI()
	{		
		var flashModule : CScriptedFlashSprite;
		m_anchorName = "mcAnchorAreaInfo";
		super.OnConfigUI();
	
		flashModule = GetModuleFlash();	
		m_fxSetTextSFF = flashModule.GetMemberFlashFunction( "SetText" );
	}

	function ShowAreaInfo( localisationKey : string )
	{
		var text : string;
		
		text = GetLocStringByKeyExt( localisationKey );
		m_fxSetTextSFF.InvokeSelfOneArg(FlashArgString(text));
		ShowElement(true);
		showTime = 3;
		dt = 0;
		bShow = true;
	}

	event  OnTick( timeDelta : float )
	{
		if( bShow )
		{
			dt += timeDelta;
			if( dt > showTime )
			{
				ShowElement(false);
				bShow = false;
			}
		}
	}
}

exec function testarea( text : string )
{
	var hud : CR4ScriptedHud;
	var module : CR4HudModuleAreaInfo;

	hud = (CR4ScriptedHud)theGame.GetHud();
	module = (CR4HudModuleAreaInfo)hud.GetHudModule("AreaInfoModule");
	module.ShowAreaInfo( text );
}
