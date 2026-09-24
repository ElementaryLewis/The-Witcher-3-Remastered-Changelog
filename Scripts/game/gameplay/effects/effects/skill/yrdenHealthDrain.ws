/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_YrdenHealthDrain extends W3DamageOverTimeEffect
{
	private var hitFxDelay : float;
	
	default effectType = EET_YrdenHealthDrain;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		hitFxDelay = 0.9 + RandF() / 5;	
		
		
		SetEffectValue(); 
	}
	
	
	protected function SetEffectValue()
	{
		
		
		if(target.HasAbility( 'SkillBoss' ) || target.HasAbility( 'Boss' ) || target.HasAbility('MonsterMHBoss') || target.GetCharacterStats().HasAbilityWithTag('Boss') || (W3MonsterHuntNPC)target || (target.HasTag( 'HideHealthBarModule' ) && !target.HasTag( 'NotBoss' )) )
		{
			effectValue.valueMultiplicative *= 0.15;
		}
	}
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate(dt);
		
		hitFxDelay -= dt;
		if(hitFxDelay <= 0)
		{
			hitFxDelay = 0.9 + RandF() / 5;	
			target.PlayEffect('yrden_shock');
		}
	}
}