/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_BattleTrance extends CBaseGameplayEffect
{
	private saved var currentFocusLevel : int;
	
	default effectType = EET_BattleTrance;
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;

	
	event OnUpdate(deltaTime : float)
	{
		var focus : float;
		var newLevel, delta, skillLevel : int;
	
		super.OnUpdate(deltaTime);
		
		
		focus = target.GetStat(BCS_Focus);
		newLevel = FloorF(focus);
		delta = newLevel - currentFocusLevel;
		skillLevel = thePlayer.GetSkillLevel(S_Perk_40);
		
		
		if(delta != 0)
		{
			if(delta < 0)
			{
				if(GetWitcherPlayer().CanUseSkill(S_Perk_19))
					target.RemoveAbilityMultiple(thePlayer.GetSkillAbilityName(S_Perk_19), Abs(delta));
				else if(GetWitcherPlayer().CanUseSkill(S_Perk_40))
				{
					target.RemoveAbilityAll( thePlayer.GetSkillAbilityName(S_Perk_40) );
					target.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Perk_40), newLevel * skillLevel);
				}
				else
					target.RemoveAbilityMultiple(thePlayer.GetSkillAbilityName(S_Sword_5), Abs(delta));
				
				if(thePlayer.CanUseSkill(S_Magic_s07))
					thePlayer.RemoveAbilityMultiple(thePlayer.GetSkillAbilityName(S_Magic_s07), Abs(delta));
				
				if(thePlayer.CanUseSkill(S_Perk_11))
					thePlayer.RemoveAbilityMultiple(thePlayer.GetSkillAbilityName(S_Perk_11), Abs(delta));

				if(thePlayer.CanUseSkill(S_Magic_s38))
					thePlayer.RemoveAbilityMultiple(thePlayer.GetSkillAbilityName(S_Magic_s38), Abs(delta) * thePlayer.GetSkillLevel(S_Magic_s38));
			}
			else
			{
				if(GetWitcherPlayer().CanUseSkill(S_Perk_19))
					target.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Perk_19), delta);
				else if(GetWitcherPlayer().CanUseSkill(S_Perk_40))
				{
					target.RemoveAbilityAll( thePlayer.GetSkillAbilityName(S_Perk_40) );
					target.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Perk_40), newLevel * skillLevel);
				}
				else
					target.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Sword_5), delta);
				
				if(thePlayer.CanUseSkill(S_Magic_s07))
					thePlayer.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Magic_s07), delta);
				
				if(thePlayer.CanUseSkill(S_Perk_11))
					thePlayer.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Perk_11), delta);

				if(thePlayer.CanUseSkill(S_Magic_s38))
					thePlayer.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Magic_s38), delta * thePlayer.GetSkillLevel(S_Magic_s38));
			}
			
			
			if(newLevel == 0)
			{
				isActive = false;
				return true;
			}
			
			currentFocusLevel = newLevel;
		}
	}
	
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var player : CR4Player;
		var skillLevel : int;
	
		player = (CR4Player)target;
		if(!player)
		{
			LogEffects("W3Effect_BattleTrance.OnEffectAdded: effect added on non-CR4Player object - aborting!");
			return false;
		}
			
		super.OnEffectAdded(customParams);
		
		currentFocusLevel = FloorF(target.GetStat(BCS_Focus));
		skillLevel = thePlayer.GetSkillLevel(S_Perk_40);

		if(player.CanUseSkill(S_Perk_19))
			target.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Perk_19), currentFocusLevel);
		else if(player.CanUseSkill(S_Perk_40))
			target.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Perk_40), currentFocusLevel * skillLevel);
		else
			target.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Sword_5), currentFocusLevel);
		
		if( player.CanUseSkill(S_Magic_s07) )
			player.AddAbilityMultiple( player.GetSkillAbilityName(S_Magic_s07), currentFocusLevel);
			
		if(player.CanUseSkill(S_Perk_11))
			player.AddAbilityMultiple(player.GetSkillAbilityName(S_Perk_11), currentFocusLevel);

		if(player.CanUseSkill(S_Magic_s38))
			player.AddAbilityMultiple(player.GetSkillAbilityName(S_Magic_s38), currentFocusLevel * player.GetSkillLevel(S_Magic_s38));
	}
	
	event OnEffectRemoved()
	{
		var player : CR4Player;
		
		super.OnEffectRemoved();
		
		player = (CR4Player)target;
		player.RemoveAbilityAll( player.GetSkillAbilityName(S_Magic_s07) );
		player.RemoveAbilityAll( player.GetSkillAbilityName(S_Perk_11) );
		player.RemoveAbilityAll( player.GetSkillAbilityName(S_Magic_s38) );
		player.RemoveAbilityAll( player.GetSkillAbilityName(S_Sword_5) );
		player.RemoveAbilityAll( player.GetSkillAbilityName(S_Perk_19) );
		player.RemoveAbilityAll( player.GetSkillAbilityName(S_Perk_40) );
	}
	
	public function OnPerk11Equipped()
	{
		thePlayer.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Perk_11), FloorF(thePlayer.GetStat(BCS_Focus)));
	}
	
	public function OnPerk11Unequipped()
	{
		thePlayer.RemoveAbilityAll(thePlayer.GetSkillAbilityName(S_Perk_11) );
	}

	public function OnMagic38Equipped()
	{
		thePlayer.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Magic_s38), FloorF(thePlayer.GetStat(BCS_Focus) * thePlayer.GetSkillLevel(S_Magic_s38)));
	}
	
	public function OnMagic38Unequipped()
	{
		thePlayer.RemoveAbilityAll(thePlayer.GetSkillAbilityName(S_Magic_s38) );
	}
	
	protected function SetEffectValue()
	{
		var skillLevel : int;

		if(GetWitcherPlayer().CanUseSkill(S_Perk_19))
			effectValue = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_19, theGame.params.CRITICAL_HIT_CHANCE, false, true);
		else if(GetWitcherPlayer().CanUseSkill(S_Perk_40))
		{
			skillLevel = thePlayer.GetSkillLevel(S_Perk_40);
			effectValue = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_40, theGame.params.CRITICAL_HIT_CHANCE, false, true);
			effectValue.valueAdditive *= skillLevel;
		}
		else
			effectValue = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_5, PowerStatEnumToName(CPS_AttackPower), false, true);
	}
}