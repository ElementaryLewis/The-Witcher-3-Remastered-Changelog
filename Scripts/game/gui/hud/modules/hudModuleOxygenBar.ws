/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4HudModuleOxygenBar extends CR4HudModuleBase
{
	private var m_fxSetOxygeneSFF 			: CScriptedFlashFunction;
	
	
	
	
	private var oxygenePerc		: float;	
		
	default oxygenePerc = -1;

	private var forceShowElement : bool;	default forceShowElement = false;
	private var bOxygeneBar : bool;		default bOxygeneBar = false;
	private var bIsBarFull : bool;		default bIsBarFull = true;
	private saved var isInGasArea		: bool;		default isInGasArea = false;
	
	 event OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		m_anchorName = "mcAnchorOxygenBar";
		
		super.OnConfigUI();

		flashModule = GetModuleFlash();
		m_fxSetOxygeneSFF = flashModule.GetMemberFlashFunction( "setOxygene" );

		
		
		hud = (CR4ScriptedHud)theGame.GetHud();
						
		if (hud)
		{
			hud.UpdateHudConfig('OxygenBarModule', true);
		}
	}

	event OnTick( timeDelta : float )
	{
		var player : CR4Player = thePlayer;
		var check : bool;
		
		
		check = forceShowElement || player.OnCheckDiving() || (!bIsBarFull && player.IsSwimming()) || isInGasArea || (!bIsBarFull && FactsQuerySum("player_was_in_gas_area"));
		
		
		if( check )
		{
			UpdateOxygene();
		}
	}
	
	private function UpdateOxygene()
	{
		var percents : float;
		
		percents = thePlayer.GetStatPercents(BCS_Air);
		
		if(percents != oxygenePerc)
		{
			oxygenePerc = percents;
			bIsBarFull = (percents == 1);
			m_fxSetOxygeneSFF.InvokeSelfOneArg( FlashArgNumber(percents) );
		}		
	}

	public function EnableElement( enable : bool )
	{
		bOxygeneBar = !enable;
		ShowElement(enable); 
	}

	public function ForceShowElement( force : bool )
	{
		forceShowElement = force;
	}
	
	public function SetIsInGasArea(b : bool)
	{
		isInGasArea = b;
	}
}
