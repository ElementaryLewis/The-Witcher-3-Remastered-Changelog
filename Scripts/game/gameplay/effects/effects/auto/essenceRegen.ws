/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_AutoEssenceRegen extends W3AutoRegenEffect
{
	default effectType = EET_AutoEssenceRegen;
	default regenStat = CRS_Essence;
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate( dt );
		
		if( target.GetStatPercents( BCS_Essence ) >= 1.0f )
		{
			target.StopEssenceRegen();
		}
	}
}