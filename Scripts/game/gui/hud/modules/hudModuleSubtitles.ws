/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4HudModuleSubtitles extends CR4HudModuleBase
{
	private var m_fxAddSubtitleSFF		: CScriptedFlashFunction;
	private var m_fxRemoveSubtitleSFF	: CScriptedFlashFunction;
	private var m_fxUpdateWidthSFF		: CScriptedFlashFunction;

	event  OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var configValue : string;
		var inGameConfigWrapper : CInGameConfigWrapper;
		
		m_anchorName = "ScaleOnly";
		
		flashModule = GetModuleFlash();	
		m_fxAddSubtitleSFF		= flashModule.GetMemberFlashFunction( "addSubtitle" );
		m_fxRemoveSubtitleSFF	= flashModule.GetMemberFlashFunction( "removeSubtitle" );
		m_fxUpdateWidthSFF		= flashModule.GetMemberFlashFunction( "updateWidth" );
		
		super.OnConfigUI();
		
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		configValue = inGameConfigWrapper.GetVarValue('Localization', 'Subtitles');
		SetEnabled(configValue == "true");
		
		
		subScale = StringToInt(inGameConfigWrapper.GetVarValue('Hud', 'SubtitleScale'));
	}

	event  OnSubtitleAdded( id : int, speakerNameDisplayText : string, htmlString : string, alternativeUI : bool )
	{
		if (alternativeUI)
		{
			speakerNameDisplayText = "<FONT COLOR='#5ACCF6'>" + GetLocStringByKeyExt("Witold")  + ": </FONT>";
			htmlString = "<FONT COLOR='#5ACCF6'>" + htmlString + "</FONT>";
		}
		else
		{
			
			if(speakerNameDisplayText != "" && speakerNameDisplayText != " ")
				htmlString = ": "  + htmlString;
		}
		
		
		speakerNameDisplayText = "<font size = '"+ IntToString( 26 + subScale ) + "' >" + speakerNameDisplayText + "</font>";
		htmlString = "<font size = '"+ IntToString( 26 + subScale ) + "' >" + htmlString + "</font>";
		
		if( theGame.isDialogDisplayDisabled )
		{
			speakerNameDisplayText = "";
			htmlString = "";
		}
		m_fxAddSubtitleSFF.InvokeSelfThreeArgs( FlashArgInt( id ), FlashArgString( speakerNameDisplayText ), FlashArgString( htmlString ) );
		
		AddSubtitleToPosterHack( speakerNameDisplayText, htmlString );
	}
	
	event  OnSubtitleRemoved( id : int )
	{
		m_fxRemoveSubtitleSFF.InvokeSelfOneArg( FlashArgInt( id ) );
		
		RemoveSubtitleFromPosterHack();
	}
	
	private function AddSubtitleToPosterHack( speakerNameDisplayText : string, htmlString : string )
	{
		var manager : CR4GuiManager;
		var posterMenu : CR4PosterMenu;
		
		manager = theGame.GetGuiManager();
		if ( manager )
		{
			posterMenu = (CR4PosterMenu)manager.GetRootMenu();
			if ( posterMenu )
			{
				posterMenu.AddSubtitle( speakerNameDisplayText, htmlString );
			}
		}
	}
	
	private function RemoveSubtitleFromPosterHack()
	{
		var manager : CR4GuiManager;
		var posterMenu : CR4PosterMenu;
		
		manager = theGame.GetGuiManager();
		if ( manager )
		{
			posterMenu = (CR4PosterMenu)manager.GetRootMenu();
			if ( posterMenu )
			{
				posterMenu.RemoveSubtitle();
			}
		}
	}

	protected function UpdateScale( scale : float, flashModule : CScriptedFlashSprite ) : bool
	{		
		m_fxUpdateWidthSFF.InvokeSelfOneArg( FlashArgNumber( theGame.GetUIHorizontalFrameScale() ) );
		
		return super.UpdateScale( scale, flashModule );
	}
	
	
	private var subScale : int;
	default subScale = 0;
	
	public function SetSubtitleScale(scale : int)
	{
		subScale = scale;
	}
}


exec function subscale( s : int )
{
	var hud : CR4ScriptedHud;
	var module : CR4HudModuleSubtitles;

	hud = (CR4ScriptedHud)theGame.GetHud();
	module = (CR4HudModuleSubtitles)hud.GetHudModule("SubtitlesModule");
	module.SetSubtitleScale( s );
}

exec function hud_addsub( speaker : string, text : string , optional alternativeUI : bool )
{
	var hud : CR4ScriptedHud;
	var subtitlesModule : CR4HudModuleSubtitles;

	hud = (CR4ScriptedHud)theGame.GetHud();
	subtitlesModule = (CR4HudModuleSubtitles)hud.GetHudModule("SubtitlesModule");
	subtitlesModule.OnSubtitleAdded( 1, speaker, text, alternativeUI );
}

exec function hud_remsub()
{
	var hud : CR4ScriptedHud;
	var subtitlesModule : CR4HudModuleSubtitles;

	hud = (CR4ScriptedHud)theGame.GetHud();
	subtitlesModule = (CR4HudModuleSubtitles)hud.GetHudModule("SubtitlesModule");
	subtitlesModule.OnSubtitleRemoved( 1 );
}

exec function asub()
{
	var hud : CR4ScriptedHud;
	
	hud = (CR4ScriptedHud)theGame.GetHud();
	if ( hud )
	{
		hud.OnSubtitleAdded( 123, "Geralt", "Raz dwa trzy, test napisów", false );
	}
}

exec function rsub()
{
	var hud : CR4ScriptedHud;
	
	hud = (CR4ScriptedHud)theGame.GetHud();
	if ( hud )
	{
		hud.OnSubtitleRemoved( 123 );
	}
}