/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SProcessedDamage
{
	import var vitalityDamage	: Float;
	import var essenceDamage	: Float;
	import var moraleDamage		: Float;
	import var staminaDamage	: Float;
};


struct SRawDamage
{
	editable var dmgType : name;
	editable var dmgVal	: Float;
};


function DamageHitsEssence(damageName : name) : bool
{
	switch(damageName)
	{
		case theGame.params.DAMAGE_NAME_PHYSICAL:
		case theGame.params.DAMAGE_NAME_SLASHING:
		case theGame.params.DAMAGE_NAME_PIERCING:
		case theGame.params.DAMAGE_NAME_BLUDGEONING:
		case theGame.params.DAMAGE_NAME_MORALE:
			return false;
		default :
			return true;
	}
}


function DamageHitsVitality(damageName : name) : bool
{
	switch(damageName)
	{
		case theGame.params.DAMAGE_NAME_SILVER:
		case theGame.params.DAMAGE_NAME_MORALE:
			return false;
		default :
			return true;
	}
}


function DamageHitsMorale(damageName : name) : bool
{
	
	return damageName == theGame.params.DAMAGE_NAME_MORALE;
}


function DamageHitsStamina(damageName : name) : bool
{
	return damageName == theGame.params.DAMAGE_NAME_STAMINA;
}


function GetBasicAttackDamageAttributeName(attackType : name, damageName : name) : name
{
	if( DamageHitsVitality(damageName) )
	{
		switch(attackType)
		{
			case theGame.params.ATTACK_NAME_LIGHT :
				return 'light_attack_damage_vitality';
			case theGame.params.ATTACK_NAME_HEAVY :
				return 'heavy_attack_damage_vitality';
			case theGame.params.ATTACK_NAME_SUPERHEAVY :
				return 'super_heavy_attack_damage_vitality';
			case theGame.params.ATTACK_NAME_SPEED_BASED :
				return 'light_attack_damage_vitality';
		}
	}
	else
	{
		switch(attackType)
		{
			case theGame.params.ATTACK_NAME_LIGHT :
				return 'light_attack_damage_essence';
			case theGame.params.ATTACK_NAME_HEAVY :
				return 'heavy_attack_damage_essence';
			case theGame.params.ATTACK_NAME_SUPERHEAVY :
				return 'super_heavy_attack_damage_essence';
			case theGame.params.ATTACK_NAME_SPEED_BASED :
				return 'light_attack_damage_essence';
		}
	}
	
	return '';
}

function IsDamageTypeAnyPhysicalType( damageName : name ) : bool
{
	switch( damageName )
	{
		case theGame.params.DAMAGE_NAME_PIERCING :
		case theGame.params.DAMAGE_NAME_BLUDGEONING :
		case theGame.params.DAMAGE_NAME_PHYSICAL :
		case theGame.params.DAMAGE_NAME_RENDING :
		case theGame.params.DAMAGE_NAME_SILVER :
		case theGame.params.DAMAGE_NAME_SLASHING :
			return true;
	}
	return false;
}


function IsDamageTypeNameValid(damageName : name) : bool
{
	switch(damageName)
	{		
		case theGame.params.DAMAGE_NAME_FROST 		:
		case theGame.params.DAMAGE_NAME_FORCE 		:
		case theGame.params.DAMAGE_NAME_POISON 		:
		case theGame.params.DAMAGE_NAME_FIRE 		:
		case theGame.params.DAMAGE_NAME_PHYSICAL 	:
		case theGame.params.DAMAGE_NAME_SILVER 		:
		case theGame.params.DAMAGE_NAME_SLASHING	:
		case theGame.params.DAMAGE_NAME_PIERCING	: 
		case theGame.params.DAMAGE_NAME_BLUDGEONING	: 
		case theGame.params.DAMAGE_NAME_RENDING		: 
		case theGame.params.DAMAGE_NAME_ELEMENTAL	: 
		case theGame.params.DAMAGE_NAME_SHOCK 		:
		case theGame.params.DAMAGE_NAME_MORALE 		:
		case theGame.params.DAMAGE_NAME_DIRECT 		: return true;
		default 									: return false;
	}
}

function DamageTypeStringToName(damageStr : string) : name
{
	if(damageStr == NameToString(theGame.params.DAMAGE_NAME_FROST))			return theGame.params.DAMAGE_NAME_FROST;
	if(damageStr == NameToString(theGame.params.DAMAGE_NAME_FORCE))			return theGame.params.DAMAGE_NAME_FORCE;
	if(damageStr == NameToString(theGame.params.DAMAGE_NAME_POISON))		return theGame.params.DAMAGE_NAME_POISON;
	if(damageStr == NameToString(theGame.params.DAMAGE_NAME_FIRE))			return theGame.params.DAMAGE_NAME_FIRE;
	if(damageStr == NameToString(theGame.params.DAMAGE_NAME_PHYSICAL))		return theGame.params.DAMAGE_NAME_PHYSICAL;
	if(damageStr == NameToString(theGame.params.DAMAGE_NAME_SILVER))		return theGame.params.DAMAGE_NAME_SILVER;
	if(damageStr == NameToString(theGame.params.DAMAGE_NAME_SLASHING))		return theGame.params.DAMAGE_NAME_SLASHING;
	if(damageStr == NameToString(theGame.params.DAMAGE_NAME_PIERCING))		return theGame.params.DAMAGE_NAME_PIERCING;
	if(damageStr == NameToString(theGame.params.DAMAGE_NAME_BLUDGEONING))	return theGame.params.DAMAGE_NAME_BLUDGEONING;
	if(damageStr == NameToString(theGame.params.DAMAGE_NAME_RENDING))		return theGame.params.DAMAGE_NAME_RENDING;
	if(damageStr == NameToString(theGame.params.DAMAGE_NAME_ELEMENTAL))		return theGame.params.DAMAGE_NAME_ELEMENTAL;
	if(damageStr == NameToString(theGame.params.DAMAGE_NAME_SHOCK))			return theGame.params.DAMAGE_NAME_SHOCK;
	if(damageStr == NameToString(theGame.params.DAMAGE_NAME_MORALE))		return theGame.params.DAMAGE_NAME_MORALE;
	if(damageStr == NameToString(theGame.params.DAMAGE_NAME_DIRECT))		return theGame.params.DAMAGE_NAME_DIRECT;
	
	return '';
}

function GetResistForDamage(damageName : name, isDoTDamage : bool) : ECharacterDefenseStats
{
	if(isDoTDamage)
	{
		if(damageName == theGame.params.DAMAGE_NAME_FIRE)
			return CDS_DoTBurningDamageRes;
		else if(damageName == theGame.params.DAMAGE_NAME_POISON)
			return CDS_DoTPoisonDamageRes;
		else if(damageName == theGame.params.DAMAGE_NAME_PHYSICAL || 
				damageName == theGame.params.DAMAGE_NAME_SLASHING ||
				damageName == theGame.params.DAMAGE_NAME_PIERCING ||
				damageName == theGame.params.DAMAGE_NAME_BLUDGEONING ||
				damageName == theGame.params.DAMAGE_NAME_SILVER)
			return CDS_DoTBleedingDamageRes;
		return CDS_None;
	}

	switch(damageName)
	{		
		case theGame.params.DAMAGE_NAME_FROST 		: return CDS_FrostRes;
		case theGame.params.DAMAGE_NAME_FORCE 		: return CDS_ForceRes;
		case theGame.params.DAMAGE_NAME_POISON 		: return CDS_PoisonRes;
		case theGame.params.DAMAGE_NAME_FIRE 		: return CDS_FireRes;
		case theGame.params.DAMAGE_NAME_PHYSICAL 	:
		case theGame.params.DAMAGE_NAME_SILVER 		: return CDS_PhysicalRes;
		case theGame.params.DAMAGE_NAME_SLASHING	: return CDS_SlashingRes;
		case theGame.params.DAMAGE_NAME_PIERCING	: return CDS_PiercingRes;
		case theGame.params.DAMAGE_NAME_BLUDGEONING	: return CDS_BludgeoningRes;
		case theGame.params.DAMAGE_NAME_RENDING		: return CDS_RendingRes;
		case theGame.params.DAMAGE_NAME_ELEMENTAL	: return CDS_ElementalRes;
		case theGame.params.DAMAGE_NAME_SHOCK 		: return CDS_ShockRes;
		case theGame.params.DAMAGE_NAME_MORALE 		:
		case theGame.params.DAMAGE_NAME_DIRECT 		: return CDS_None;
		default 									: return CDS_None;
	}
}