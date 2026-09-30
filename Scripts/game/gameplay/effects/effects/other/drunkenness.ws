/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Drunkenness extends CBaseGameplayEffect
{
	default effectType = EET_Drunkenness;
	default isNegative = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		EnableDrunkFx(1.f);
	}
	
	event OnEffectRemoved()
	{
		DisableDrunkFx(1.f);
		
		super.OnEffectRemoved();
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);		
		
		if(!IsPaused())
			EnableDrunkFx(1.f);
	}
	
	protected function OnPaused()
	{
		super.OnPaused();
		DisableDrunkFx();			
	}
	
	protected function OnResumed()
	{
		super.OnResumed();
		EnableDrunkFx();			
	}
}