/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Bleeding extends W3DamageOverTimeEffect
{	
	default effectType = EET_Bleeding;
	default resistStat = CDS_BleedingRes;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		if( target == thePlayer)
		 Log("");
	}
	
	public function OnDamageDealt(dealtDamage : bool)
	{
		
		if(!dealtDamage)
		{
			shouldPlayTargetEffect = false;
			
			if(target.IsEffectActive(targetEffectName))
				StopTargetFX();
		}
		else
		{
			shouldPlayTargetEffect = true;
			
			if(!target.IsEffectActive(targetEffectName))
				PlayTargetFX();
		}		
	}
}




class W3Effect_Bleeding1 extends W3DamageOverTimeEffect
{	
	default effectType = EET_Bleeding1;
	default resistStat = CDS_BleedingRes;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		if( target == thePlayer)
		 Log("");
	}
	
	public function OnDamageDealt(dealtDamage : bool)
	{
		
		if(!dealtDamage)
		{
			shouldPlayTargetEffect = false;
			
			if(target.IsEffectActive(targetEffectName))
				StopTargetFX();
		}
		else
		{
			shouldPlayTargetEffect = true;
			
			if(!target.IsEffectActive(targetEffectName))
				PlayTargetFX();
		}		
	}
}

class W3Effect_Bleeding2 extends W3DamageOverTimeEffect
{	
	default effectType = EET_Bleeding2;
	default resistStat = CDS_BleedingRes;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		if( target == thePlayer)
		 Log("");
	}
	
	public function OnDamageDealt(dealtDamage : bool)
	{
		
		if(!dealtDamage)
		{
			shouldPlayTargetEffect = false;
			
			if(target.IsEffectActive(targetEffectName))
				StopTargetFX();
		}
		else
		{
			shouldPlayTargetEffect = true;
			
			if(!target.IsEffectActive(targetEffectName))
				PlayTargetFX();
		}		
	}
}

class W3Effect_Bleeding3 extends W3DamageOverTimeEffect
{	
	default effectType = EET_Bleeding3;
	default resistStat = CDS_BleedingRes;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		if( target == thePlayer)
		 Log("");
	}
	
	public function OnDamageDealt(dealtDamage : bool)
	{
		
		if(!dealtDamage)
		{
			shouldPlayTargetEffect = false;
			
			if(target.IsEffectActive(targetEffectName))
				StopTargetFX();
		}
		else
		{
			shouldPlayTargetEffect = true;
			
			if(!target.IsEffectActive(targetEffectName))
				PlayTargetFX();
		}		
	}
}

