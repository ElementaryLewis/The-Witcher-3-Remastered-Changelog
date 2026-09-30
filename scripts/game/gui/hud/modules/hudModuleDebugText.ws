/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4HudModuleDebugText extends CR4HudModuleBase
{
	public var bCurrentShowState : bool;		default bCurrentShowState = false;
	public var bShouldShowElement : bool;		default bShouldShowElement = false;
	public var bOpenDebugText : bool;			default bOpenDebugText = false;

	event  OnConfigUI()
	{
		super.OnConfigUI();

		ShowElement( false );
	}

	event OnTick( timeDelta : float )
	{
	}

	public function ShowElement( bShow : bool, optional bImmediately : bool )
	{
		bShouldShowElement = bShow;
		if( bShow )
		{
			super.ShowElement( bCurrentShowState, bImmediately );
			return;
		}
		else
		{
			bCurrentShowState = false;
		}
		super.ShowElement( bShow, bImmediately );
	}

	public function ShowDebugText( text : string ) : void
	{
		var flashValueStorage : CScriptedFlashValueStorage = GetModuleFlashValueStorage();

		flashValueStorage.SetFlashString( 'debugtext.text', text, -1 );
		
		bCurrentShowState = true;
		ShowElement( true );
	}

	public function HideDebugText() : void
	{
		ShowElement( false );
	}
}

exec function showdebugtext()
{
	var hud : CR4ScriptedHud;
	var debugTextModule : CR4HudModuleDebugText;

	hud = (CR4ScriptedHud)theGame.GetHud();
	debugTextModule = (CR4HudModuleDebugText)hud.GetHudModule("DebugTextModule");
	debugTextModule.ShowDebugText( ";]" );
}

exec function hidedebugtext()
{
	var hud : CR4ScriptedHud;
	var debugTextModule : CR4HudModuleDebugText;

	hud = (CR4ScriptedHud)theGame.GetHud();
	debugTextModule = (CR4HudModuleDebugText)hud.GetHudModule("DebugTextModule");
	debugTextModule.HideDebugText();
}