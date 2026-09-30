/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_DoppelgangerEssenceRegen extends CBaseGameplayEffect
{
	private var usesVitality : bool;

	default effectType = EET_DoppelgangerEssenceRegen;	
	default isActive = true;
	
	default duration = -1;
	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		usesVitality = target.UsesVitality();
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		usesVitality = target.UsesVitality();
	}
	
	event OnUpdate( deltaTime : float )
	{
		var l_summonerComponent : W3SummonerComponent;
		var l_doppelgangers		: array<CEntity>;
		var i					: int;		
		var l_amountToHeal		: float;
		var stat 				: EBaseCharacterStats;
		
		l_summonerComponent = (W3SummonerComponent) target.GetComponentByClassName('W3SummonerComponent');
		l_doppelgangers 	= l_summonerComponent.GetSummonedEntities();
		
		for	( i = 0; i < l_doppelgangers.Size(); i += 1 )
		{
			if( l_doppelgangers[i].GetBehaviorVariable('isDancing') == 1 )
			{
				
				l_amountToHeal += 0.01f;
			}
		}
		
		if( l_amountToHeal > 0 )
		{
			if(usesVitality)
				stat = BCS_Vitality;
			else
				stat = BCS_Essence;
				
			effectManager.CacheStatUpdate(stat, deltaTime * target.GetMaxHealth() * l_amountToHeal);
		}
	}
}