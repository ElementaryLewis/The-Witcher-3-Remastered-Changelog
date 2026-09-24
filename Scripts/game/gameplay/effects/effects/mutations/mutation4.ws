/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Mutation4 extends CBaseGameplayEffect
{
	private var bonusPerPoint : float;
	private var dotDuration : float;
	
	default effectType = EET_Mutation4;
	default isPositive = true;
	
	event OnEffectAddedPost()
	{
		var min, max : SAbilityAttributeValue;
		
		super.OnEffectAddedPost();
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'AcidEffect', 'DirectDamage', min, max );
		bonusPerPoint = 100 * min.valueAdditive;
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'AcidEffect', 'duration', min, max );
		dotDuration = min.valueAdditive;
	}
	
	public function GetStacks() : int
	{
		var tox : float;
		var advancedMaths : float;	
		
		tox = target.GetStat( BCS_Toxicity );
		advancedMaths = bonusPerPoint * tox * dotDuration;
		return RoundMath( MaxF( bonusPerPoint * dotDuration, advancedMaths ) );
	}
}