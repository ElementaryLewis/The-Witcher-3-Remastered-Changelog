/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_PoisonCritical extends W3CriticalDOTEffect
{
	default criticalStateType 	= ECST_PoisonCritical;
	default effectType 			= EET_PoisonCritical;
	default powerStatType 		= CPS_SpellPower;
	default resistStat 			= CDS_PoisonRes;
	default postponeHandling 	= ECH_Postpone;
	default airHandling 		= ECH_Postpone;
	default attachedHandling 	= ECH_Postpone;
	default onHorseHandling	 	= ECH_Postpone;
	
	public function CacheSettings()
	{
		super.CacheSettings();
	
		blockedActions.PushBack(EIAB_Jump);
		blockedActions.PushBack(EIAB_RunAndSprint);
		blockedActions.PushBack(EIAB_Parry);
		blockedActions.PushBack(EIAB_Sprint);
		blockedActions.PushBack(EIAB_Counter);
	}
}