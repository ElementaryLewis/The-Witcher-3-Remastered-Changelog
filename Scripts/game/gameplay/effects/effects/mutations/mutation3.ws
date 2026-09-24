/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Mutation3 extends CBaseGameplayEffect
{
	private var stacks : int;
	private var maxCap : int;
	private var apBonus : float;
	
	default effectType = EET_Mutation3;
	default isPositive = true;
	default stacks = 1;
	
	event OnEffectAddedPost()
	{
		var min, max : SAbilityAttributeValue;
		var sword : CItemEntity;
		
		super.OnEffectAddedPost();
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation3', 'maxcap', min, max );
		maxCap = RoundMath( min.valueAdditive );
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation3', 'attack_power', min, max );
		apBonus = min.valueMultiplicative;
		
		target.AddAbility( 'Mutation3', true );
				
		target.GetInventory().GetCurrentlyHeldSwordEntity( sword );
		sword.PlayEffect( 'instant_fx' );
		
		theGame.MutationHUDFeedback( MFT_PlayRepeat );
	}
	
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		var sword : CItemEntity;
		
		super.CumulateWith(effect);
		
		if( stacks < maxCap )
		{
			stacks += 1;
			target.AddAbility( 'Mutation3', true );
			
			target.GetInventory().GetCurrentlyHeldSwordEntity( sword );
			sword.PlayEffect( 'instant_fx' );
		}
	}
	
	public function GetStacks() : int
	{
		return RoundMath( stacks * apBonus * 100 );
	}
	
	event OnEffectRemoved()
	{
		target.RemoveAbilityAll( 'Mutation3' );
		
		theGame.MutationHUDFeedback( MFT_PlayHide );
		
		super.OnEffectRemoved();
	}
}