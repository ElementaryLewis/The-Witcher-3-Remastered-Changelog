/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Mutation11Debuff extends CBaseGameplayEffect
{
	default effectType = EET_Mutation11Debuff;
	default isNeutral = true;
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		super.CalculateDuration( setInitialDuration );

		
		if( FactsQuerySum( "debug_mut11_no_cooldown" ) )
		{
			duration = 0.00001f;
			initialDuration = duration;
		}
	}
	
	event OnEffectRemoved()
	{
		theGame.MutationHUDFeedback( MFT_PlayHide );
		
		super.OnEffectRemoved();
	}
}	