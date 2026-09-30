/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4HudModuleConsole extends CR4HudModuleBase
{
	private var m_fxHudConsoleMsg		: CScriptedFlashFunction;
	private var m_fxTestHudConsole		: CScriptedFlashFunction;
	private var m_fxCleanupHudConsole	: CScriptedFlashFunction;
	private var _iDuringDisplay : int;		default _iDuringDisplay = 0;
	private const var MAX_CONSOLE_MESSEGES_DISPLAYED : int;		default MAX_CONSOLE_MESSEGES_DISPLAYED = 3;
	private var NEW_ITEM_DELAY : float;		default NEW_ITEM_DELAY = 0.1;
	private var displayTime : float;		default displayTime = 0.0;
	private var pendingMessages : array<string>;
	
	event  OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		m_anchorName = "mcAnchorConsole";
		
		super.OnConfigUI();
		
		flashModule = GetModuleFlash();
		
		m_fxHudConsoleMsg		= flashModule.GetMemberFlashFunction( "showMessage" );
		m_fxTestHudConsole		= flashModule.GetMemberFlashFunction( "debugMessage" );
		m_fxCleanupHudConsole	= flashModule.GetMemberFlashFunction( "cleanup" );
		displayTime = NEW_ITEM_DELAY;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
						
		if (hud)
		{
			hud.UpdateHudConfig('ConsoleModule', true);
		}
	}
	
	event OnTick( timeDelta : float )
	{
		if( _iDuringDisplay < MAX_CONSOLE_MESSEGES_DISPLAYED )
		{		
			displayTime += timeDelta;
			if( CheckPendingMessages() && displayTime > NEW_ITEM_DELAY )
			{
				DisplayConsoleMsg(pendingMessages[0]);
				_iDuringDisplay += 1;
				displayTime = 0;
				LogChannel('HUD_CONSOLE',"_iDuringDisplay "+_iDuringDisplay +" " + pendingMessages[0]);
				pendingMessages.Erase(0);
			}
		}
	}
	
	function CheckPendingMessages() : bool
	{
		if( pendingMessages.Size() > 0 )
		{
			return true;
		}
		return false;
	}
	
	event  OnMessageHidden( value : string)
	{
		_iDuringDisplay = Max(0,_iDuringDisplay-1);
		LogChannel('HUD_CONSOLE'," OnMessageHidden _iDuringDisplay "+(_iDuringDisplay-1) +" displayTime "+displayTime+" value "+value);
		displayTime = 0;
		if( _iDuringDisplay == 0 )
		{
			ConsoleCleanup();
		}
	}
	
	public function ConsoleMsg( msgText : string )
	{
		pendingMessages.PushBack(msgText);
	}	
	
	public function DisplayConsoleMsg( msgText : string )
	{
		m_fxHudConsoleMsg.InvokeSelfOneArg( FlashArgString( msgText ) );
		ShowElement(true,true);
	}
	
	public function ConsoleTest()
	{
		m_fxTestHudConsole.InvokeSelf();
	}
	
	public function ConsoleCleanup()
	{
		m_fxCleanupHudConsole.InvokeSelf();
		ShowElement(false,false);
	}
	
	protected function UpdatePosition(anchorX:float, anchorY:float) : void
	{
		var l_flashModule 		: CScriptedFlashSprite;
		var tempX				: float;
		var tempY				: float;
		
		l_flashModule 	= GetModuleFlash();
		
		
		
		
		tempX = anchorX + (300.0 * (1.0 - theGame.GetUIHorizontalFrameScale()));
		tempY = anchorY;
		
		l_flashModule.SetX( tempX );
		l_flashModule.SetY( tempY );	
	}
}