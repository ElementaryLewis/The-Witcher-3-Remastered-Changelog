/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_AutoVitalityRegen extends W3AutoRegenEffect
{
	private var regenModeIsCombat : bool;		
	private var cachedPlayer : CR4Player;
	private var inGameConfigWrapper : CInGameConfigWrapper;
	private var isAccessibilityAutoHealOn : bool;
	private var accessibilityMulCurr : float;
	private var accessibilityMulConst : int;	
	private var accessibilityAutoHealThreshold : float;

		default regenStat = CRS_Vitality;	
		default effectType = EET_AutoVitalityRegen;
		default regenModeIsCombat = false;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		if(isOnPlayer)
		{		
			cachedPlayer = (CR4Player)target;
			
			inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();			
			isAccessibilityAutoHealOn =  inGameConfigWrapper.GetVarValue('Accessibility', 'LowHPAutoHealOn') == "true";
			accessibilityMulConst =  StringToInt(inGameConfigWrapper.GetVarValue('Accessibility', 'LowHPAutoHealMultiplier'));
			accessibilityAutoHealThreshold =  0.01f * StringToFloat(inGameConfigWrapper.GetVarValue('Accessibility', 'LowHPAutoHealThreshold'));
		}
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		if(isOnPlayer)
		{
			cachedPlayer = (CR4Player)target;
			
			inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();			
			isAccessibilityAutoHealOn =  inGameConfigWrapper.GetVarValue('Accessibility', 'LowHPAutoHealOn') == "true";
			accessibilityMulConst =  StringToInt(inGameConfigWrapper.GetVarValue('Accessibility', 'LowHPAutoHealMultiplier'));
			accessibilityAutoHealThreshold =  0.01f * StringToFloat(inGameConfigWrapper.GetVarValue('Accessibility', 'LowHPAutoHealThreshold'));
		}			
	}
	
	event OnUpdate(deltaTime : float)
	{
		var vitPerc : float;
		var accessibilityMulEffectScale : float;
		var vitThresholdRatio : float;

		
		if(isOnPlayer)
		{
			
			regenModeIsCombat = cachedPlayer.IsInCombat();
			if(regenModeIsCombat)
				attributeName = 'vitalityCombatRegen';
			else
				attributeName = RegenStatEnumToName(regenStat);
				
			if (isAccessibilityAutoHealOn)
			{
				vitPerc = cachedPlayer.GetStatPercents(BCS_Vitality);
				vitThresholdRatio = vitPerc / accessibilityAutoHealThreshold;
				
				if (vitThresholdRatio < 1.f )
				{
					accessibilityMulEffectScale = ClampF(1.f - vitThresholdRatio, 0.f, 1.f);
					accessibilityMulCurr = (accessibilityMulEffectScale + 0.1) * accessibilityMulConst; 
				}					
				else
				{
					accessibilityMulCurr = 1; 
				}
			}				
				
			SetEffectValue();
		}
		
		super.OnUpdate(deltaTime);
		
		if( target.GetStatPercents( BCS_Vitality ) >= 1.0f && !target.HasAbility('Runeword 4 _Stats', true))
		{
			target.StopVitalityRegen();
		}
	}
	
	public function RequestValueUpdates()
	{
		if(isOnPlayer)
		{
			cachedPlayer = (CR4Player)target;
			
			inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();			
			isAccessibilityAutoHealOn =  inGameConfigWrapper.GetVarValue('Accessibility', 'LowHPAutoHealOn') == "true";
			accessibilityMulConst =  StringToInt(inGameConfigWrapper.GetVarValue('Accessibility', 'LowHPAutoHealMultiplier'));
			accessibilityAutoHealThreshold =  0.01f * StringToFloat(inGameConfigWrapper.GetVarValue('Accessibility', 'LowHPAutoHealThreshold'));
		}
	}

	protected function SetEffectValue() 
	{
		if (isAccessibilityAutoHealOn)
		{
			effectValue = target.GetAttributeValue(attributeName);
			effectValue.valueAdditive += accessibilityMulCurr;
		}
		else
			effectValue = target.GetAttributeValue(attributeName);
	}
}