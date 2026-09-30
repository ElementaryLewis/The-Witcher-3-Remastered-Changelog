/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_OverEncumbered extends CBaseGameplayEffect
{
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	default effectType = EET_OverEncumbered;
	
	private var timeSinceLastMessage : float;
	private const var OVERWEIGHT_MESSAGE_DELAY : float;
	
		default OVERWEIGHT_MESSAGE_DELAY = 10.f;
		
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{		
		super.OnEffectAdded(customParams);
		
		if(!isOnPlayer)
		{
			LogAssert(false, "W3Effect_OverEncumbered.OnEffectAdded: adding effect <<" + effectType + ">> on non-player actor - aborting!");
			timeLeft = 0;
			return false;
		}
		
		((CR4Player)target).BlockAction( EIAB_RunAndSprint, 'OverEncumbered', true );
		
		
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		((CR4Player)target).UnblockAction( EIAB_RunAndSprint, 'OverEncumbered');
	}
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate(dt);
		
		
	}
	
	
}