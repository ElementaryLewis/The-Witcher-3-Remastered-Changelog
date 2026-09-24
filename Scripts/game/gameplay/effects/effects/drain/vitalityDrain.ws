/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_VitalityDrain extends W3DamageOverTimeEffect
{
	
	default effectType 		= EET_VitalityDrain;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	public function OnDamageDealt(dealtDamage : bool)
	{
		
		if(!dealtDamage)
		{
			shouldPlayTargetEffect = false;
			StopTargetFX();
		}
		else
		{
			shouldPlayTargetEffect = true;
			PlayTargetFX();
		}
	}
}