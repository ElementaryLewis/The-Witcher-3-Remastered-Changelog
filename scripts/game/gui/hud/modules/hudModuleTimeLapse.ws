/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4HudModuleTimeLapse extends CR4HudModuleBase
{
	private var m_fxSetShowTimeSFF						: CScriptedFlashFunction;
	private var m_fxSetTimeLapseMessage					: CScriptedFlashFunction;
	private var m_fxSetTimeLapseAdditionalMessage		: CScriptedFlashFunction;	


	event  OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		m_anchorName = "mcAnchorTimelapse";
		super.OnConfigUI();
		flashModule = GetModuleFlash();	
		m_fxSetShowTimeSFF 		= flashModule.GetMemberFlashFunction( "SetShowTime" ); 
		m_fxSetTimeLapseMessage = flashModule.GetMemberFlashFunction( "handleTimelapseTextSet" );
		m_fxSetTimeLapseAdditionalMessage = flashModule.GetMemberFlashFunction( "handleTimelapseAdditionalTextSet" );
		

		hud = (CR4ScriptedHud)theGame.GetHud();
						
		if (hud)
		{
			hud.UpdateHudConfig('TimeLapseModule', true);
		}
	}

	
	public function SetShowTime( showTime : float )
	{
		
		m_fxSetShowTimeSFF.InvokeSelfOneArg(FlashArgNumber(showTime*1000));
	}	
	
	public function SetTimeLapseMessage( localisationKey : string )
	{
		var str : string;
		str = GetLocStringByKeyExt(localisationKey);
		if(str == "#" || StrUpper(str) == "#NONE")
		{
			m_fxSetTimeLapseMessage.InvokeSelfOneArg(FlashArgString(""));
		}
		else
		{
			m_fxSetTimeLapseMessage.InvokeSelfOneArg(FlashArgString(str));
		}
	}			

	public function SetTimeLapseAdditionalMessage( localisationKey : string )
	{
		var str : string;
		str = GetLocStringByKeyExt(localisationKey);
		if(str == "#" || StrUpper(str) == "#NONE")
		{
			m_fxSetTimeLapseAdditionalMessage.InvokeSelfOneArg(FlashArgString(""));
		}
		else
		{
			m_fxSetTimeLapseAdditionalMessage.InvokeSelfOneArg(FlashArgString(str));
		}
	}		
	
	public function Show( bShow : bool )
	{
		ShowElement(bShow);
	}
	
	public function SetTimeLapseMessageTest( localisationKey : string, optional doNotTranslate : bool )
	{
		var str : string;
		
		if ( doNotTranslate )
		{
			str = localisationKey;
		}
		else
		{
			str = GetLocStringByKeyExt(localisationKey);
		}
		if(str == "#" || StrUpper(str) == "#NONE")
		{
			m_fxSetTimeLapseMessage.InvokeSelfOneArg(FlashArgString(""));
		}
		else
		{
			m_fxSetTimeLapseMessage.InvokeSelfOneArg(FlashArgString(str));
		}
	}	
}

exec function testTurkish1()
{
	var hud : CR4ScriptedHud;
	var timeLapseModule : CR4HudModuleTimeLapse;
	
	hud = (CR4ScriptedHud)theGame.GetHud();
	if( hud )
	{
		timeLapseModule = (CR4HudModuleTimeLapse)hud.GetHudModule("TimeLapseModule");
		if ( timeLapseModule )
		{
			timeLapseModule.SetTimeLapseMessageTest( GetLocStringById( 339458 ), true );
		}
	}
}

exec function testTurkish2()
{
	var hud : CR4ScriptedHud;
	var timeLapseModule : CR4HudModuleTimeLapse;
	
	hud = (CR4ScriptedHud)theGame.GetHud();
	if( hud )
	{
		timeLapseModule = (CR4HudModuleTimeLapse)hud.GetHudModule("TimeLapseModule");
		if ( timeLapseModule )
		{
			timeLapseModule.SetTimeLapseMessageTest( "iiiııı", true );
		}
	}
}