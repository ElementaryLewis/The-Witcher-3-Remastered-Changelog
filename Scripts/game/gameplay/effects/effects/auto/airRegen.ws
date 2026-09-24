/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_AutoAirRegen extends W3AutoRegenEffect
{
	default effectType = EET_AutoAirRegen;
	default regenStat = CRS_Air;
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate( dt );
		
		if( target.GetStatPercents( BCS_Air ) >= 1.0f )
		{
			target.StopAirRegen();
		}
	}
}