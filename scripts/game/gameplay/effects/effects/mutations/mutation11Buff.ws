/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Mutation11Buff extends CBaseGameplayEffect
{
	default effectType = EET_Mutation11Buff;
	default isPositive = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		var min, max			: SAbilityAttributeValue;		
		
		super.OnEffectAdded( customParams );
		
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation11', 'health_prc', min, max );		
		target.ForceSetStat( BCS_Vitality, target.GetMaxHealth() * min.valueAdditive );
	}

	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		
		
		GetWitcherPlayer().Mutation11StartAnimation();
		
		
		target.ResumeHPRegenEffects( '', true );
		
		
		target.StartVitalityRegen();
		
		
		target.AddEffectDefault( EET_Mutation11Immortal, target, "Mutation 11", false );
		
		theGame.MutationHUDFeedback( MFT_PlayRepeat );
	}
	
	event OnEffectRemoved()
	{
		
		target.RemoveBuff( EET_Mutation11Immortal );
		
		
		target.AddEffectDefault( EET_Mutation11Debuff, NULL, "Mutation 11 Debuff", false );
		
		super.OnEffectRemoved();
	}
}