/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Trap extends W3CriticalEffect
{
	default criticalStateType			= ECST_Trap;
	default effectType 					= EET_Trap;
	default isDestroyedOnInterrupt 		= true;
	default airHandling 				= ECH_HandleNow;
	default postponeHandling 			= ECH_Abort;
	default attachedHandling			= ECH_Abort;
	default onHorseHandling				= ECH_HandleNow;
	default canBeAppliedOnDeadTarget 	= true;
	default	explorationStateHandling 	= ECH_HandleNow;
	default usesFullBodyAnim			= true;
	default resistStat 					= CDS_ForceRes;
	
	public function CacheSettings()
	{
		super.CacheSettings();
		
		allowedHits[EHRT_Light] = false;
		allowedHits[EHRT_LightClose] = false;
		allowedHits[EHRT_Heavy] = false;
		allowedHits[EHRT_Igni] = false;
		
	}
	
	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		
		if(isOnPlayer)
		{
			thePlayer.OnRangedForceHolster( true, true, false );
			thePlayer.PlayEffectSingle('q704_trap_loop');
			thePlayer.BlockAllActions('W3Effect_Trap', true);
			thePlayer.FinishQuen(false);
		}

	}
	
	event OnEffectRemoved()
	{
		if(isOnPlayer)
		{
			thePlayer.StopEffect('q704_trap_loop');
			thePlayer.SetBehaviorVariable( 'bCriticalStopped', 1 );
			thePlayer.BlockAllActions('W3Effect_Trap', false);
		}
		
		
		super.OnEffectRemoved();
	}
}