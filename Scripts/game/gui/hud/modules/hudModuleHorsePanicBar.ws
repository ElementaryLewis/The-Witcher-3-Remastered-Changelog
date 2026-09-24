/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4HudModuleHorsePanicBar extends CR4HudModuleBase
{	
	private var m_fxSetPanicSFF	: CScriptedFlashFunction;
	private var _panic : float;
	private var horseMounted : bool;
	private var elementShown : bool;
	
	defaults
	{
		_panic = 0.0;
	}
	
	event  OnConfigUI()
	{		
		var hud : CR4ScriptedHud;
		var flashModule : CScriptedFlashSprite;

		m_anchorName = "mcAnchorHorsePanicBar";
		super.OnConfigUI();
		flashModule = GetModuleFlash();	
		m_fxSetPanicSFF	= flashModule.GetMemberFlashFunction( "setPanic" );

		hud = (CR4ScriptedHud)theGame.GetHud();
		if (hud)
		{
			hud.UpdateHudConfig('HorsePanicBarModule', true);
		}
	}

	event OnTick( timeDelta : float )
	{
		
		if ( thePlayer.GetCurrentStateName() == 'HorseRiding' )
			UpdatePanic();
		else
			_panic = 0.0;
	}

	private function UpdatePanic()
	{
		var curPanic : float;
		curPanic = GetCurrentPanic();

		if ( _panic != curPanic )
		{
			_panic = curPanic;
			m_fxSetPanicSFF.InvokeSelfOneArg( FlashArgNumber( _panic ) );
		}
	}
	
	private function GetCurrentPanic() : float
	{
		var vehicle : W3HorseComponent;
		var horse : CActor;
		var curPanic : float;
		
		
		vehicle = thePlayer.GetUsedHorseComponent();
		curPanic = vehicle.GetPanicPercent();

		return curPanic;
	}	
	
	protected function UpdatePosition(anchorX:float, anchorY:float) : void
	{
		var l_flashModule 		: CScriptedFlashSprite;
		l_flashModule 	= GetModuleFlash();
		
		l_flashModule.SetX( anchorX );
		l_flashModule.SetY( anchorY );	
	}	
}