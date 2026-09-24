/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_AutoSwimmingStaminaRegen extends W3AutoRegenEffect
{
	default effectType = EET_AutoSwimmingStaminaRegen;
	default regenStat = CRS_SwimmingStamina;
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate( dt );
		
		if( target.GetStatPercents( BCS_SwimmingStamina ) >= 1.0f )
		{
			target.StopSwimmingStaminaRegen();
		}
	}
}