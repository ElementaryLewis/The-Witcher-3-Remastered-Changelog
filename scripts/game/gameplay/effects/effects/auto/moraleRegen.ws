/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_AutoMoraleRegen extends W3AutoRegenEffect
{
	default effectType = EET_AutoMoraleRegen;
	default regenStat = CRS_Morale;
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate( dt );
		
		if( target.GetStatPercents( BCS_Morale ) >= 1.0f )
		{
			target.StopMoraleRegen();
		}
	}
}