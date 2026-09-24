/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Potion_KillerWhale extends W3ChangeMaxStatEffect
{
	private var visionStrength : float;

	default effectType = EET_KillerWhale;
	default stat = BCS_Air;
		
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		SetUnderWaterBrightness(visionStrength);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		SetUnderWaterBrightness(1);
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		var min, max : SAbilityAttributeValue;
		
		super.OnLoad(t, eff);
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'vision_strength', min, max);
		visionStrength = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
	}
		
	public function CacheSettings()
	{
		var min, max : SAbilityAttributeValue;
	
		super.CacheSettings();
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'vision_strength', min, max);
		visionStrength = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
	}
}