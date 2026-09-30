/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_WellFed extends W3RegenEffect
{
	default effectType = EET_WellFed;
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	public function Init(params : SEffectInitInfo)
	{
		var ability : SAbilityAttributeValue;

		super.Init(params);

		if( GetWitcherPlayer().CanUseSkill( S_Perk_41 ) )
		{
			ability = GetWitcherPlayer().GetSkillAttributeValue( S_Perk_41, 'duration', false, false );
			duration = ability.valueAdditive * thePlayer.GetSkillLevel( S_Perk_41 );
			timeLeft = duration;
		}
	}

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		if(isOnPlayer && thePlayer == GetWitcherPlayer() && GetWitcherPlayer().HasRunewordActive('Runeword 6 _Stats'))
		{		
			iconPath = theGame.effectMgr.GetPathForEffectIconTypeName('icon_effect_Dumplings');
		}
	}

	event OnEffectRemoved()
	{
		var player : CR4Player;

		super.OnEffectRemoved();

		
		player = (CR4Player)target;
		if(player)
		{
			player.RemoveAbilityAll('GourmetEffect');
		}
	}
	
	event OnPerk15Unequipped()
	{
		SetTimeLeft( initialDuration );
		duration = initialDuration;
	}

	event OnPerk41Updated()
	{
		var player : CR4Player;
		var ability : SAbilityAttributeValue;

		player = (CR4Player)target;
		if(player && player.CanUseSkill(S_Perk_41))
		{
			ability = GetWitcherPlayer().GetSkillAttributeValue( S_Perk_41, 'duration', false, false );
			duration += ability.valueAdditive;
			timeLeft += ability.valueAdditive;
		}
	}

	
	event OnPerk41Unequipped()
	{
		timeLeft = 0;
	}
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		var min, max : SAbilityAttributeValue;
		
		super.CalculateDuration(setInitialDuration);
		
		if( isOnPlayer && GetWitcherPlayer() )
		{	
			
			if( GetWitcherPlayer().CanUseSkill( S_Perk_15 ) )
			{
				min = GetWitcherPlayer().GetSkillAttributeValue( S_Perk_15, 'duration', false, false );
				duration = min.valueAdditive;
			}

			if( GetWitcherPlayer().HasRunewordActive( 'Runeword 6 _Stats' ) )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 6 _Stats', 'runeword6_duration_bonus', min, max);
				duration *= ( 1 + min.valueMultiplicative );
			}
		}
	}
	
	protected function GetSelfInteraction( e : CBaseGameplayEffect) : EEffectInteract
	{
		var eff : W3Effect_WellFed;
		var dm : CDefinitionsManagerAccessor;
		var thisLevel, otherLevel : int;
		var min, max : SAbilityAttributeValue;
		
		dm = theGame.GetDefinitionsManager();
		eff = (W3Effect_WellFed)e;
		dm.GetAbilityAttributeValue(abilityName, 'level', min, max);
		thisLevel = RoundMath(CalculateAttributeValue(GetAttributeRandomizedValue(min, max)));
		dm.GetAbilityAttributeValue(eff.abilityName, 'level', min, max);
		otherLevel = RoundMath(CalculateAttributeValue(GetAttributeRandomizedValue(min, max)));
		
		if(otherLevel >= thisLevel)
			return EI_Cumulate;		
		else
			return EI_Deny;
	}
	
	
	protected function SetEffectValue()
	{
		var min, max : SAbilityAttributeValue;
		
		super.SetEffectValue();
		
		if( GetWitcherPlayer().HasRunewordActive( 'Runeword 6 _Stats' ) )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 6 _Stats', 'runeword6_duration_bonus', min, max);
			effectValue.valueAdditive *= ( 1 + min.valueMultiplicative );
		}
		
	}
	
}