/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Mutagen20_Effect extends W3Mutagen_Effect
{	
	default effectType = EET_Mutagen20;
	default dontAddAbilityOnTarget = true;
	
	private var burningPoints, burningPercents, poisonPoints, poisonPercents, bleedingPoints, bleedingPercents : SAbilityAttributeValue;
	private var burningResistanceCounter, poisonResistanceCounter, bleedingResistanceCounter : float;
	private var player : CR4Player;
	
		default bleedingResistanceCounter = 0;
		default burningResistanceCounter = 0;
		default poisonResistanceCounter = 0;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var dm : CDefinitionsManagerAccessor;
		var min, max : SAbilityAttributeValue;
		
		super.OnEffectAdded(customParams);
		
		dm = theGame.GetDefinitionsManager();
		
		dm.GetAbilityAttributeValue(abilityName, ResistStatEnumToName(CDS_DoTBurningDamageRes, true), min, max);
		burningPoints = GetAttributeRandomizedValue(min, max);
		
		dm.GetAbilityAttributeValue(abilityName, ResistStatEnumToName(CDS_DoTBurningDamageRes, false), min, max);
		burningPercents = GetAttributeRandomizedValue(min, max);
		
		dm.GetAbilityAttributeValue(abilityName, ResistStatEnumToName(CDS_DoTPoisonDamageRes, true), min, max);
		poisonPoints = GetAttributeRandomizedValue(min, max);
		
		dm.GetAbilityAttributeValue(abilityName, ResistStatEnumToName(CDS_DoTPoisonDamageRes, false), min, max);
		poisonPercents = GetAttributeRandomizedValue(min, max);
		
		dm.GetAbilityAttributeValue(abilityName, ResistStatEnumToName(CDS_DoTBleedingDamageRes, true), min, max);
		bleedingPoints = GetAttributeRandomizedValue(min, max);
		
		dm.GetAbilityAttributeValue(abilityName, ResistStatEnumToName(CDS_DoTBleedingDamageRes, false), min, max);
		bleedingPercents = GetAttributeRandomizedValue(min, max);
		
		player = (CR4Player)target;
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		player = (CR4Player)target;
	}
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate(dt);
		
		if(!player.IsInCombat())
		{
			burningResistanceCounter = 0;
			bleedingResistanceCounter = 0;
			poisonResistanceCounter = 0;
		}
		else
		{		
			if(target.HasBuff(EET_Burning))
				burningResistanceCounter += dt;
			if(target.HasBuff(EET_Bleeding))
				bleedingResistanceCounter += dt;
			if(target.HasBuff(EET_PoisonCritical))
				poisonResistanceCounter += dt;
			if(target.HasBuff(EET_Poison))
				poisonResistanceCounter += dt;
		}
	}
	
	public function GetResistBonus(resist : ECharacterDefenseStats, out points : SAbilityAttributeValue, out percents : SAbilityAttributeValue)
	{
		if(resist == CDS_DoTBurningDamageRes)
		{
			points = burningPoints;
			percents = burningPercents;
			
			points = points * burningResistanceCounter;
			percents = percents * burningResistanceCounter;
		}
		else if(resist == CDS_DoTPoisonDamageRes)
		{
			points = poisonPoints;
			percents = poisonPercents;
			
			points = points * poisonResistanceCounter;
			percents = percents * poisonResistanceCounter;
		}
		else if(resist == CDS_DoTBleedingDamageRes)
		{
			points = bleedingPoints;
			percents = bleedingPercents;
			
			points = points * bleedingResistanceCounter;
			percents = percents * bleedingResistanceCounter;
		}
	}
}