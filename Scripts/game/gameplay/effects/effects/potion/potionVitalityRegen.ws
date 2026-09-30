/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Potion_VitalityRegen extends W3RegenEffect
{
	protected var combatRegen, nonCombatRegen : SAbilityAttributeValue;			
	protected var playerTarget : CR4Player;

	public function CacheSettings()
	{
		var i,size : int;
		var att : array<name>;
		var dm : CDefinitionsManagerAccessor;
		var atts : array<name>;
		var min, max : SAbilityAttributeValue;
							
		super.CacheSettings();
		
		
		if(regenStat == CRS_Vitality)
		{
			dm = theGame.GetDefinitionsManager();
			dm.GetAbilityAttributes(abilityName, att);
			
			for(i=0; i<att.Size(); i+=1)
			{
				if(att[i] == 'vitalityCombatRegen')
				{
					dm.GetAbilityAttributeValue(abilityName, att[i], min, max);
					combatRegen = GetAttributeRandomizedValue(min, max);
				}
				else if(att[i] == 'vitalityRegen')
				{
					dm.GetAbilityAttributeValue(abilityName, att[i], min, max);
					nonCombatRegen = GetAttributeRandomizedValue(min, max);
					attributeName = att[i];
				}
			}
		}
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		playerTarget = (CR4Player)target;
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		playerTarget = (CR4Player)target;
	}
	
	event OnUpdate(deltaTime : float)
	{
		if(playerTarget.IsInCombat())
			effectValue = combatRegen;
		else
			effectValue = nonCombatRegen;
			
		super.OnUpdate(deltaTime);
	}
}