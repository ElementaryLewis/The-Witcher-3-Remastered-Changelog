/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4HudModuleAnchors extends CR4HudModuleBase
{
	
	
	
	private	var m_fxUpdateAnchorsPositions			: CScriptedFlashFunction;
	private	var m_fxUpdateAnchorsAspectRatio		: CScriptedFlashFunction;
	
	
	
	 event OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		flashModule 		= GetModuleFlash();
		m_fxUpdateAnchorsPositions		= flashModule.GetMemberFlashFunction( "UpdateAnchorsPositions" );
		m_fxUpdateAnchorsAspectRatio 	= flashModule.GetMemberFlashFunction( "UpdateAnchorsAspectRatio" );
		
		hud = ( CR4ScriptedHud )theGame.GetHud();
		if (hud)
		{
			hud.UpdateHudScale();
		}
	}
	
	public function GetAnchorSprite( _AnchorName : string ) : CScriptedFlashSprite
	{
		var flashModule : CScriptedFlashSprite;
		
		flashModule 		= GetModuleFlash();
		return flashModule.GetChildFlashSprite( _AnchorName );
	}
	
	public function UpdateAnchorsPositions()
	{
		m_fxUpdateAnchorsPositions.InvokeSelf();
	}
	
	public function UpdateAnchorsAspectRatio()
	{
		var width : int;
		var height : int;
		theGame.GetCurrentViewportResolution( width, height );
		m_fxUpdateAnchorsAspectRatio.InvokeSelfTwoArgs(FlashArgInt(width), FlashArgInt(height));
	}
}