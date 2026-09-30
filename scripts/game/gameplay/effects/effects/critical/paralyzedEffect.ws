/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Paralyzed extends W3ImmobilizeEffect
{
	default effectType = EET_Paralyzed;
	default resistStat = CDS_ShockRes;
	default criticalStateType = ECST_Paralyzed;
	default isDestroyedOnInterrupt = true;
}