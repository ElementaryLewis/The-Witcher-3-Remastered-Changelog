/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Mutagen13_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen13;
	
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var buffs : array<CBaseGameplayEffect>;
		var i : int;
		
		super.OnEffectAdded(customParams);
		
		buffs = target.GetBuffs();
		for(i=0; i<buffs.Size(); i+=1)
		{
			if(IsEffectTypeAffected(buffs[i].GetEffectType()))
				buffs[i].SetTimeLeft(GetForcedDuration());
		}
	}
	
	
	public function GetForcedDuration() : float
	{
		
		
		
		return 0.5;
	}
	
	
	public function IsEffectTypeAffected(effectType : EEffectType) : bool
	{
		switch(effectType)
		{
			case EET_Blindness:
			case EET_WraithBlindness:
			case EET_Confusion:
			case EET_CounterStrikeHit:
			case EET_HeavyKnockdown:
			case EET_Hypnotized:
			case EET_Immobilized:
			case EET_Knockdown:
			case EET_LongStagger:
			case EET_Paralyzed:
			case EET_Stagger:
			case EET_Slowdown:				
				return true;
			default :
				return false;
		}
	}
}