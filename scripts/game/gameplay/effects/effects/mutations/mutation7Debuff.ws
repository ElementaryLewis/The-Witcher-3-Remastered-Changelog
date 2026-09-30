/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Mutation7Debuff extends W3Mutation7BaseEffect
{
	private var minCapStacks : int;
	
	default effectType = EET_Mutation7Debuff;
	default isNegative = true;
	default isSonarIncreasing = true;
	default enemyFlashFX = 'buff';
	
	event OnEffectAdded( optional customParams : W3BuffCustomParams )
	{
		var fxEntity : CEntity;
		var min, max : SAbilityAttributeValue;
		
		super.OnEffectAdded( customParams );
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation7Debuff', 'minCapStacks', min, max );
		minCapStacks = (int) min.valueAdditive;
		
		target.AddAbilityMultiple( 'Mutation7Debuff', Min( minCapStacks, actorsCount - 1 ) );
		
		target.PauseHPRegenEffects( 'Mutation 7 Debuff' );
		
		fxEntity = target.CreateFXEntityAtPelvis( 'mutation7_flash', false );
		fxEntity.PlayEffect( 'debuff' );
		fxEntity.DestroyAfter( 10.f );
		target.PlayEffect( 'mutation_7_debaff' );
		target.SoundEvent( 'ep2_mutations_07_berserk_debuff' );
	}
	
	
	public function GetStacks() : int
	{
		return (int)( Min( minCapStacks, actorsCount - 1 ) * 100 * apBonus );
	}
	
	event OnEffectAddedPost()
	{
		var min, max : SAbilityAttributeValue;
		
		super.OnEffectAddedPost();
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation7Debuff', 'attack_power', min, max );
		apBonus = min.valueMultiplicative;
	}
	
	event OnUpdate(deltaTime : float)
	{
		if( timeActive <= 1.f )
		{
			scale = MinF( timeActive / 1.f, 1.f );
			scale = 1.f + 14.f * scale;
		}
		
		super.OnUpdate( deltaTime );
	}
	
	event OnEffectRemoved()
	{
		target.RemoveAbilityAll( 'Mutation7Debuff' );
		target.ResumeHPRegenEffects( 'Mutation 7 Debuff' );
		
		theGame.MutationHUDFeedback( MFT_PlayHide );
		
		target.StopEffect( 'mutation_7_debaff' );
		
		super.OnEffectRemoved();
	}
}

class W3Mutation7DebuffParams extends W3BuffCustomParams
{
	var actorsCount : int;
}