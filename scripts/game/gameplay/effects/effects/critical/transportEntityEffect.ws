/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_TransportEntity extends W3ImmobilizeEffect
{
	default effectType = EET_Pull;
	default resistStat = CDS_None;
	default criticalStateType = ECST_Pull;
	default isDestroyedOnInterrupt = true;
	default postponeHandling = ECH_Abort;
	default airHandling = ECH_Abort;	
	default usesFullBodyAnim			= true;
	
	public function CacheSettings()
	{
		super.CacheSettings();
				
		blockedActions.PushBack(EIAB_Dodge);
		blockedActions.PushBack(EIAB_Roll);
	}
	
	event OnEffectRemoved()
	{
		target.SetBehaviorVariable( 'bCriticalStopped', 1 );
		super.OnEffectRemoved();
	}
}