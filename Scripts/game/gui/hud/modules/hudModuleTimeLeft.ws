/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4HudModuleTimeLeft extends CR4HudModuleBase
{	
	private	var m_fxSetTimeOutPercent				: CScriptedFlashFunction;
	
	 event OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		m_anchorName = "mcAnchorBossFocus";
		
		super.OnConfigUI();
		
		flashModule 			= GetModuleFlash();

		m_fxSetTimeOutPercent = flashModule.GetMemberFlashFunction( "setTimeOutPercent" );
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if (hud)
		{
			hud.UpdateHudConfig('TimeLeftModule', true);
		}
		
		if ( thePlayer.GetCurrentTimeOut() )
		{
			ShowElement( true );
		}
	}
	
	public function ManageHudTimeOut( action : EHudTimeOutAction, timeOut : float )
	{
		if ( action == EHTOA_Start )
		{
			Show( timeOut );
		}
		else if ( action == EHTOA_Stop )
		{
			Hide();
		}
		else if ( action == EHTOA_Add )
		{
			AddTime( timeOut );
		}
	}

	public function Show( timeOut : float )
	{
		
		thePlayer.SetInitialTimeOut( timeOut );
		thePlayer.SetCurrentTimeOut( timeOut );
		
		m_fxSetTimeOutPercent.InvokeSelfOneArg( FlashArgNumber( 100 ) );
		ShowElement( true );
	}

	public function Hide()
	{
		thePlayer.SetCurrentTimeOut( 0 );
		
		ShowElement( false );
	}

	public function AddTime( timeOut : float )
	{
		var currentTimeOut : float;
		var newTimeOut : float;
		
		currentTimeOut = thePlayer.GetCurrentTimeOut();
		if ( currentTimeOut <= 0 )
		{
			
			return;
		}
		newTimeOut = currentTimeOut + timeOut;
		if ( newTimeOut > thePlayer.GetInitialTimeOut() )
		{
			
			newTimeOut = thePlayer.GetInitialTimeOut();
		}
		thePlayer.SetCurrentTimeOut( newTimeOut );
	}
	
	event OnTick(timeDelta : float)
	{
		var currentTimeOut : float;
		
		currentTimeOut = thePlayer.GetCurrentTimeOut();
		if ( currentTimeOut > 0 )
		{
			if ( theGame.IsPaused() )
			{
				return false;
			}
			
			currentTimeOut -= ( timeDelta * theGame.GetTimeScale( false ) );
			thePlayer.SetCurrentTimeOut( currentTimeOut );

			if ( currentTimeOut < 0 )
			{
				theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnHudTimeOut );
				Hide();
			}
			m_fxSetTimeOutPercent.InvokeSelfOneArg( FlashArgNumber( 100 * currentTimeOut / thePlayer.GetInitialTimeOut() ) );
		}
	}
}

exec function stl( timeOut : float )
{
	var hud : CR4ScriptedHud;
	var module : CR4HudModuleTimeLeft;
	
	hud = (CR4ScriptedHud)theGame.GetHud();
	if ( hud )
	{
		module = (CR4HudModuleTimeLeft)hud.GetHudModule("TimeLeftModule");
		if ( module )
		{
			module.Show( timeOut );
		}
	}
}

exec function htl()
{
	var hud : CR4ScriptedHud;
	var module : CR4HudModuleTimeLeft;
	
	hud = (CR4ScriptedHud)theGame.GetHud();
	if ( hud )
	{
		module = (CR4HudModuleTimeLeft)hud.GetHudModule("TimeLeftModule");
		if ( module )
		{
			module.Hide();
		}
	}
}