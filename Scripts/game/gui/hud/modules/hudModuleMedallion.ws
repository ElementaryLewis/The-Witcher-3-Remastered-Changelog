/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4HudModuleMedallion extends CR4HudModuleBase 
{	
	private var		m_fxSetFocusPointsSFF			: CScriptedFlashFunction;
	
	private var		m_fxSetVitalitySFF				: CScriptedFlashFunction;
	private var		m_fxSetMedallionActiveSFF		: CScriptedFlashFunction;
	private var		m_fxSetMedallionThresholdSFF	: CScriptedFlashFunction;
	
	private var		m_focusPoints : int;
	private var		m_medallionActivated : bool;
	private var		m_vitality : float;
	private var		m_maxVitality : float;
	private var		m_medallionThreshold : float;
	
	defaults
	{
		m_focusPoints = -1;
		m_vitality = -1.0;
		m_maxVitality = -1.0;
		m_medallionActivated = false;
		m_medallionThreshold = 4.0;
	}

	 event OnConfigUI()
	{		
		var flashModule : CScriptedFlashSprite;

		super.OnConfigUI();

		flashModule = GetModuleFlash();	
		m_fxSetFocusPointsSFF			= flashModule.GetMemberFlashFunction( "setFocusPoints" );
		
		m_fxSetVitalitySFF				= flashModule.GetMemberFlashFunction( "setVitality" );
		m_fxSetMedallionActiveSFF		= flashModule.GetMemberFlashFunction( "setMedallionActive" );
		m_fxSetMedallionThresholdSFF	= flashModule.GetMemberFlashFunction( "setMedallionThreshold" );
		

		
	}

	event OnTick( timeDelta : float )
	{
		UpdateMedalionShakeThreshold();
		UpdateActivation();
		UpdateFocusPoints();
		UpdateVitality();
	}
	
	private function UpdateActivation()
	{
		var curMedallionActivated : bool = GetWitcherPlayer().GetMedallion().IsActive();
		
		if( m_medallionActivated != curMedallionActivated )
		{
			m_medallionActivated = curMedallionActivated;
			m_fxSetMedallionActiveSFF.InvokeSelfOneArg( FlashArgBool( m_medallionActivated ) );
		}
	}
	
	private function UpdateFocusPoints()
	{
		var curFocusPoints : int = FloorF( GetWitcherPlayer().GetStat( BCS_Focus ) );
		
		
		if ( m_focusPoints != curFocusPoints )
		{
			m_focusPoints = curFocusPoints;
			
			m_fxSetFocusPointsSFF.InvokeSelfOneArg( FlashArgInt( m_focusPoints ) );
		}
		
	}
	
	private function UpdateVitality()
	{
		var curVitality : float = thePlayer.GetStat( BCS_Vitality );
		var curMaxVitality : float = thePlayer.GetStatMax( BCS_Vitality );
				
		if ( m_vitality != curVitality || m_maxVitality != curMaxVitality )
		{
			m_vitality =  curVitality;
			m_maxVitality = curMaxVitality;
			
			m_fxSetVitalitySFF.InvokeSelfTwoArgs( FlashArgNumber( m_vitality ), FlashArgNumber( m_maxVitality ) );
		}
	}	

	private function UpdateMedalionShakeThreshold()
	{
		var curMedallionThreshold : float = GetWitcherPlayer().GetMedallion().GetTreshold();
		
		if( m_medallionThreshold != curMedallionThreshold )
		{
			m_medallionThreshold = curMedallionThreshold;
			m_fxSetMedallionThresholdSFF.InvokeSelfOneArg( FlashArgNumber( m_medallionThreshold ) );
		}
	}

}