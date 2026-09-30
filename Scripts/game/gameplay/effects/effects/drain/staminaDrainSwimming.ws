/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_StaminaDrainSwimming extends CBaseGameplayEffect
{
	private var effectValueMovement 			: SAbilityAttributeValue;			
	private var effectValueSprinting 			: SAbilityAttributeValue;			
	private var effectValueColdWater 			: SAbilityAttributeValue;			

	default effectType = EET_StaminaDrainSwimming;
	default attributeName = '';
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	event OnUpdate(deltaTime : float)
	{
		var drain					: float;
		var drainAdd 				: float;
		var drainMult 				: float = 0.f;
		var statee 					: CR4PlayerStateSwimming;
		var currStat  				: float;
		var rangeA, rangeB, rangeC 	: float;
		var currentWaterDepth		: float;	
		
		super.OnUpdate(deltaTime);
	
		
		
		statee = (CR4PlayerStateSwimming)thePlayer.GetCurrentState();
		
		if(!statee)
		{
			return true;
		}
		
		
		
		
		
		currStat = target.GetStat(BCS_SwimmingStamina);
		if ( currStat <= 0 )
		{
			statee.OnEmptyStamina();
		}
		else 
		{
			
		}
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		if(!isOnPlayer)
		{
			isActive = false;
			return true;
		}
		
		ReadXMLValues();
		
		
		
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		
		ReadXMLValues();
	}
	
	private function ReadXMLValues()
	{
		var min, max : SAbilityAttributeValue;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'staminaDrainMovement', min, max);
		effectValueMovement = GetAttributeRandomizedValue(min, max);
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'staminaDrainSprinting', min, max);
		effectValueSprinting = GetAttributeRandomizedValue(min, max);
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'staminaDrainColdWater', min, max);
		effectValueColdWater = GetAttributeRandomizedValue(min, max);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		target.ResumeStaminaRegen( 'SwimmingStaminaDrain' );
	}
}
