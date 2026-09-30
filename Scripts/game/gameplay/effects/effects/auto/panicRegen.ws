/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_AutoPanicRegen extends W3AutoRegenEffect
{
	default effectType = EET_AutoPanicRegen;
	default regenStat = CRS_Panic;
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate( dt );
		
		if( target.GetStatPercents( BCS_Panic ) >= 1.0f )
		{
			target.StopPanicRegen();
		}
	}
}