/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Choking extends W3DamageOverTimeEffect
{
	default effectType = EET_Choking;
	default resistStat = CDS_None;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		target.PauseHPRegenEffects('choking');
	}
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate(dt);
		
		
		if(target.GetStat(BCS_Air) > 0)
		{
			isActive = false;
		}
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		target.ResumeHPRegenEffects('choking');
	}
}
