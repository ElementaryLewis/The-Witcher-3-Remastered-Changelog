/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_StaminaDrain extends CBaseGameplayEffect
{
	private var effectValueDrain	: SAbilityAttributeValue;

	default effectType = EET_StaminaDrain;
	default attributeName = '';
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	
	event OnUpdate(deltaTime : float)
	{
		var drain					: float;
		var drainAdd 				: float;
		var drainMult 				: float = 0.f;
		
		super.OnUpdate(deltaTime);
		
		
		drainAdd += effectValueDrain.valueAdditive;
		drainMult += effectValueDrain.valueMultiplicative;
		
		drain = MaxF(0.f, drainAdd );
		drain += MaxF(0.f, target.GetStatMax(BCS_Stamina) * drainMult );
		drain *= deltaTime;
		
		if ( drain > 0 )
			effectManager.CacheStatUpdate(BCS_Stamina, -drain);
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
		target.PauseStaminaRegen( 'StaminaDrain' );
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		
		target.PauseStaminaRegen( 'StaminaDrain' );
		ReadXMLValues();
	}
	
	private function ReadXMLValues()
	{
		var min, max : SAbilityAttributeValue;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'staminaDrain', min, max);
		effectValueDrain = GetAttributeRandomizedValue(min, max);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		target.ResumeStaminaRegen( 'StaminaDrain' );
	}
}