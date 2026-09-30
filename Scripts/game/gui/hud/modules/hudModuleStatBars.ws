/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4HudModuleStatBars extends CR4HudModuleBase 
{	
	
	
	private var 	m_fxSetVitalitySFF							: CScriptedFlashFunction;
	private var 	m_fxSetStaminaSFF							: CScriptedFlashFunction;
	private var 	m_fxSetToxicitySFF							: CScriptedFlashFunction;
	private var 	m_fxSetExperienceSFF						: CScriptedFlashFunction;
	private var 	m_fxSetLevelUpVisibleSFF					: CScriptedFlashFunction;
	private var 	m_fxStartHeavyAttackIndicatorAnimationSFF	: CScriptedFlashFunction;
	private var 	m_fxStopHeavyAttackIndicatorAnimationSFF	: CScriptedFlashFunction;
	private var 	m_fxShowStatbarsGlowSFF						: CScriptedFlashFunction;
	private var 	m_fxHideStatbarsGlowSFF						: CScriptedFlashFunction;
	private var 	m_fxShowStaminaIndicatorSFF					: CScriptedFlashFunction;

	
	
	
	private var _vitality 		: float;
	private var _stamina 		: float;
	private var _toxicity 		: float;
	private var _experience 	: int;
	
	private var _maxVitality 	: float;
	private var _maxStamina 	: float;
	private var _maxToxicity 	: float;
	private var _maxExperience 	: int;
	private var _showLevelUp 	: bool;
	private var _currentLevel 	: int;
	
	private var _heavyAttackIndicatorSpeed : int;
	private var _heavyAttackGlowDurration : int;
	private var _heavyAttackSecondLevelIndicatorSpeed : int;
	private var _heavyAttackSecondLevelGlowDurration : int;
	private var _duringHeavyAttackAnimation : bool;
	private var _bHeavyAttackFirstLevel : bool;
	
	defaults
	{
		_vitality = -1.0;
		_stamina = -1.0;
		_toxicity = -1.0;
		_experience = -1;
		_maxVitality = -1.0;
		_maxStamina = -1.0;
		_maxToxicity = -1.0;
		_maxExperience = -1;
		_showLevelUp = false;
		_currentLevel = 0;
		
		_heavyAttackIndicatorSpeed = 1300;
		_heavyAttackGlowDurration = 700; 
		_heavyAttackSecondLevelIndicatorSpeed = 600;
		_heavyAttackSecondLevelGlowDurration = 700; 
		_duringHeavyAttackAnimation = false;
		_bHeavyAttackFirstLevel = true;
	}

	
	
	 event OnConfigUI()
	{		
		var flashModule : CScriptedFlashSprite;
		
		super.OnConfigUI();

		flashModule = GetModuleFlash();	
		
		m_fxSetVitalitySFF							= flashModule.GetMemberFlashFunction( "setVitality" );
		m_fxSetStaminaSFF							= flashModule.GetMemberFlashFunction( "setStamina" );
		m_fxSetToxicitySFF							= flashModule.GetMemberFlashFunction( "setToxicity" );
		m_fxSetExperienceSFF						= flashModule.GetMemberFlashFunction( "setExperience" );
		m_fxSetLevelUpVisibleSFF					= flashModule.GetMemberFlashFunction( "setLevelUpVisible" );
		m_fxStartHeavyAttackIndicatorAnimationSFF	= flashModule.GetMemberFlashFunction( "StartHeavyAttackIndicatorAnimation" );
		m_fxStopHeavyAttackIndicatorAnimationSFF	= flashModule.GetMemberFlashFunction( "StopHeavyAttackIndicatorAnimation" );
		m_fxShowStatbarsGlowSFF						= flashModule.GetMemberFlashFunction( "ShowStatbarsGlow" );
		m_fxHideStatbarsGlowSFF						= flashModule.GetMemberFlashFunction( "HideStatbarsGlow" );
		m_fxShowStaminaIndicatorSFF					= flashModule.GetMemberFlashFunction( "ShowStaminaIndicator" );

		GetCurrentLevel();

		ShowElement( true );
	}
	
	
	
	
	
	
	event OnTick( timeDelta : float )
	{
		UpdateStats();		
		if( GetWitcherPlayer().GetDisplayHeavyAttackIndicator() != _duringHeavyAttackAnimation )
		{
			_duringHeavyAttackAnimation = !_duringHeavyAttackAnimation;
			if( _duringHeavyAttackAnimation )
			{
				m_fxHideStatbarsGlowSFF.InvokeSelf();
				if( GetWitcherPlayer().GetDisplayHeavyAttackFirstLevelTimer() )
				{
					m_fxStartHeavyAttackIndicatorAnimationSFF.InvokeSelfOneArg(FlashArgInt(_heavyAttackIndicatorSpeed));
				}
				else
				{
					m_fxStartHeavyAttackIndicatorAnimationSFF.InvokeSelfOneArg(FlashArgInt(_heavyAttackSecondLevelIndicatorSpeed));
				}
			}
			
		}
		if( GetWitcherPlayer().GetShowToLowStaminaIndication() > 0.0f )
		{
			updateStaminaIndicator();
			GetWitcherPlayer().SetShowToLowStaminaIndication( 0.0f );
		}
	}
	
	private function GetCurrentLevel()
	{
		var levelManager : W3LevelManager;
		
		levelManager = GetWitcherPlayer().levelManager;
		
		_currentLevel = levelManager.GetLevel();
	}
	
	private function UpdateStats()
	{	
		UpdateVitality();
		UpdateStamina();
		UpdateToxicity();
		UpdateExperience();
		UpdateLevelUp();
	}
	
	private function UpdateVitality()
	{
		var curVitality : float = thePlayer.GetStat( BCS_Vitality );
		var curMaxVitality : float = thePlayer.GetStatMax( BCS_Vitality );
				
		if ( _vitality != curVitality || _maxVitality != curMaxVitality )
		{
			_vitality =  curVitality;
			_maxVitality = curMaxVitality;
			
			m_fxSetVitalitySFF.InvokeSelfTwoArgs( FlashArgNumber( _vitality ), FlashArgNumber( _maxVitality ) );
		}
	}
	
	private function UpdateStamina()
	{
		var curStamina : float = thePlayer.GetStat( BCS_Stamina );
		var curMaxStamina : float = thePlayer.GetStatMax( BCS_Stamina );
		
		if ( _stamina != curStamina || _maxStamina != curMaxStamina )
		{
			_stamina = curStamina;
			_maxStamina = curMaxStamina;
			
			m_fxSetStaminaSFF.InvokeSelfTwoArgs( FlashArgNumber( _stamina ), FlashArgNumber( _maxStamina ) );
		}
	}
	
	private function updateStaminaIndicator()
	{
		var curMaxStamina : float = thePlayer.GetStatMax( BCS_Stamina );
		
		m_fxShowStaminaIndicatorSFF.InvokeSelfTwoArgs(FlashArgNumber(GetWitcherPlayer().GetShowToLowStaminaIndication()),FlashArgNumber( _maxStamina ));
	}
	
	private function UpdateToxicity()
	{
		var curToxicity : float = thePlayer.GetStat( BCS_Toxicity );
		var curMaxToxicity : float = thePlayer.GetStatMax( BCS_Toxicity );
		
		if ( _toxicity != curToxicity || _maxToxicity != curMaxToxicity )
		{
			_toxicity = curToxicity;
			_maxToxicity = curMaxToxicity;
			
			m_fxSetToxicitySFF.InvokeSelfTwoArgs( FlashArgNumber( _toxicity ), FlashArgNumber( _maxToxicity ) );
		}
	}

	
	private function UpdateExperience()
	{
		var levelManager : W3LevelManager;
		var curExperience : int;
		var curMaxExperience : int;

		levelManager = GetWitcherPlayer().levelManager;
	
		if ( levelManager )
		{
			curExperience = levelManager.GetPointsFree(EExperiencePoint);
			curMaxExperience = levelManager.GetTotalExpForNextLevel() - levelManager.GetPointsUsed(EExperiencePoint);
			
			if ( _experience != curExperience || _maxExperience != curMaxExperience )
			{
				_experience = curExperience;
				_maxExperience = curMaxExperience;
				
				m_fxSetExperienceSFF.InvokeSelfTwoArgs( FlashArgInt( _experience ), FlashArgInt( _maxExperience ) );
			}
		}
	}
	
	private function UpdateLevelUp()
	{
		var curShowLevelUp : bool;
		var levelManager : W3LevelManager;
		var curLevel : int;
		
		levelManager = GetWitcherPlayer().levelManager;
		
		if ( levelManager )
		{
			
			
			
			
			curLevel = levelManager.GetLevel();
			
			if( _currentLevel < curLevel )
			{
				curShowLevelUp = true;
			}
			else
			{
				curShowLevelUp = false;
			}
		}
		
		if ( _showLevelUp != curShowLevelUp )
		{
			_showLevelUp = curShowLevelUp;
			
			m_fxSetLevelUpVisibleSFF.InvokeSelfOneArg( FlashArgBool( _showLevelUp ) );
		}
	}
	
	public function OnHeavyAttackAnimationFinished()
	{
		LogChannel('HEAVYATTACKDEBUG',"OnHeavyAttackAnimationFinished");
		
		m_fxShowStatbarsGlowSFF.InvokeSelfOneArg(FlashArgInt(_heavyAttackGlowDurration));
		_duringHeavyAttackAnimation = false;
		GetWitcherPlayer().SetDisplayHeavyAttackIndicator( false );
	}
	
	public function OnHeavyAttackGlowFinished()
	{
		
	}
}