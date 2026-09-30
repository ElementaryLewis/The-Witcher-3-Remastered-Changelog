/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CharacterStatsPopupData extends TextPopupData
{	
	var m_flashValueStorage : CScriptedFlashValueStorage;
	
	protected  function GetContentRef() : string 
	{
		return "StatisticsFullRef";
	}
	
	protected  function DefineDefaultButtons():void
	{
		AddButtonDef("panel_button_common_exit", "escape-gamepad_B", IK_Escape);
		AddButtonDef("input_feedback_scroll_text", "gamepad_R_Scroll");
	}
	
	public function  OnUserFeedback( KeyCode:string ) : void
	{
		if (KeyCode == "escape-gamepad_B") 
		{
			ClosePopup();
		}
	}
	
	public  function GetGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject 
	{
		var gfxData : CScriptedFlashObject;
		
		m_flashValueStorage = parentFlashValueStorage;
		
		gfxData = parentFlashValueStorage.CreateTempFlashObject();
		GetPlayerStatsGFxData(parentFlashValueStorage);
		gfxData.SetMemberFlashString("ContentRef", GetContentRef());
		
		return gfxData;
	}
}

function GetPlayerStatsGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject
{ 
	var statsArray : CScriptedFlashArray;
	var gfxData    : CScriptedFlashObject;
	
	var gfxSilverDamage : CScriptedFlashObject;
	var gfxSteelDamage  : CScriptedFlashObject;
	var gfxArmor 		: CScriptedFlashObject;
	var gfxVitality 	: CScriptedFlashObject;
	var gfxSpellPower 	: CScriptedFlashObject;
	var gfxToxicity 	: CScriptedFlashObject;
	var gfxStamina 		: CScriptedFlashObject;
	var gfxCrossbow  	: CScriptedFlashObject;
	var gfxAdditional  	: CScriptedFlashObject;
	
	var gfxSilverDamageSub : CScriptedFlashArray;
	var gfxSteelDamageSub  : CScriptedFlashArray;
	var gfxArmorSub 	   : CScriptedFlashArray;
	var gfxVitalitySub 	   : CScriptedFlashArray;
	var gfxSpellPowerSub   : CScriptedFlashArray;
	var gfxToxicitySub 	   : CScriptedFlashArray;
	var gfxStaminaSub	   : CScriptedFlashArray;
	var gfxCrossbowSub     : CScriptedFlashArray;
	var gfxAdditionalSub   : CScriptedFlashArray;
	
	var gameTime		: GameTime;
	var gameTimeHours	: string;
	var gameTimeMinutes : string;
	
	gfxData = parentFlashValueStorage.CreateTempFlashObject();
	statsArray = parentFlashValueStorage.CreateTempFlashArray();
	
	
	
	
	
	
	
	
	
	

	
	
	gfxSilverDamage = AddCharacterStatU("mainSilverStat", 'silverdamage', "panel_common_statistics_tooltip_silver_dps", "attack_silver", statsArray, parentFlashValueStorage);
	gfxSilverDamageSub = parentFlashValueStorage.CreateTempFlashArray();
	
	AddCharacterHeader("panel_common_statistics_tooltip_silver_dps", gfxSilverDamageSub, parentFlashValueStorage, true, "Red");
	AddCharacterStatU("silverStat2", 'silverFastDPS', "panel_common_statistics_tooltip_silver_fast_dps", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat3", 'silverFastCritChance', "panel_common_statistics_tooltip_silver_fast_crit_chance", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat4", 'silverFastCritDmg', "panel_common_statistics_tooltip_silver_fast_crit_dmg", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("Dummy", '', "", "", gfxSilverDamageSub, parentFlashValueStorage);
	AddCharacterStatU("silverStat5", 'silverStrongDPS', "panel_common_statistics_tooltip_silver_strong_dps", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat6", 'silverStrongCritChance', "panel_common_statistics_tooltip_silver_strong_crit_chance", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat7", 'silverStrongCritDmg', "panel_common_statistics_tooltip_silver_strong_crit_dmg", "", gfxSilverDamageSub, parentFlashValueStorage); 	
	AddCharacterStatU("Dummy", '', "", "", gfxSilverDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("silverStat9", 'silver_desc_poinsonchance_mult', "attribute_name_desc_poinsonchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU2("silverStat10", 'silver_desc_bleedingchance_mult', "attribute_name_desc_bleedingchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU2("silverStat11", 'silver_desc_burningchance_mult', "attribute_name_desc_burningchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU2("silverStat12", 'silver_desc_confusionchance_mult', "attribute_name_desc_confusionchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU2("silverStat13", 'silver_desc_freezingchance_mult', "attribute_name_desc_freezingchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU2("silverStat14", 'silver_desc_staggerchance_mult', "attribute_name_desc_staggerchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage);
	gfxSilverDamage.SetMemberFlashArray("subStats", gfxSilverDamageSub);
	
	
	
	gfxSteelDamage = AddCharacterStatU("mainSteelStat", 'steeldamage', "panel_common_statistics_tooltip_steel_dps", "attack_steel", statsArray, parentFlashValueStorage);
	gfxSteelDamageSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("panel_common_statistics_tooltip_steel_dps", gfxSteelDamageSub, parentFlashValueStorage, true, "Red");
	AddCharacterStatU("steelStat2", 'steelFastDPS', "panel_common_statistics_tooltip_steel_fast_dps", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat3", 'steelFastCritChance', "panel_common_statistics_tooltip_steel_fast_crit_chance", "", gfxSteelDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("steelStat4", 'steelFastCritDmg', "panel_common_statistics_tooltip_steel_fast_crit_dmg", "", gfxSteelDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("defStat7", '', "", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat5", 'steelStrongDPS', "panel_common_statistics_tooltip_steel_strong_dps", "", gfxSteelDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("steelStat6", 'steelStrongCritChance', "panel_common_statistics_tooltip_steel_strong_crit_chance", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat7", 'steelStrongCritDmg', "panel_common_statistics_tooltip_steel_strong_crit_dmg", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat8", '', "", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat9", 'steel_desc_poinsonchance_mult', "attribute_name_desc_poinsonchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat10", 'steel_desc_bleedingchance_mult', "attribute_name_desc_bleedingchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat11", 'steel_desc_burningchance_mult', "attribute_name_desc_burningchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat12", 'steel_desc_confusionchance_mult', "attribute_name_desc_confusionchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat13", 'steel_desc_freezingchance_mult', "attribute_name_desc_freezingchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat14", 'steel_desc_staggerchance_mult', "attribute_name_desc_staggerchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	gfxSteelDamage.SetMemberFlashArray("subStats", gfxSteelDamageSub);
	
	
	
	gfxArmor = AddCharacterStat("mainResStat", 'armor', "attribute_name_armor", "armor", statsArray, parentFlashValueStorage);
	gfxArmorSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("attribute_name_armor", gfxArmorSub, parentFlashValueStorage, true, "Red");
	AddCharacterStatF("defStat2", 'slashing_resistance_perc', "slashing_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat3", 'piercing_resistance_perc', "attribute_name_piercing_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat4", 'bludgeoning_resistance_perc', "bludgeoning_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat5", 'rending_resistance_perc', "attribute_name_rending_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat6", 'elemental_resistance_perc', "attribute_name_elemental_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatU("defStat7", '', "", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat8", 'poison_resistance_perc', "attribute_name_poison_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat9", 'bleeding_resistance_perc', "attribute_name_bleeding_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat10", 'burning_resistance_perc', "attribute_name_burning_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	gfxArmor.SetMemberFlashArray("subStats", gfxArmorSub);
	
	
	
	gfxCrossbow = AddCharacterStat("majorStat4", 'crossbow', "item_category_crossbow", "crossbow", statsArray, parentFlashValueStorage);
	gfxCrossbowSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("item_category_crossbow", gfxCrossbowSub, parentFlashValueStorage, true, "Red");
	AddCharacterStatU("steelStat17", 'crossbowCritChance', "panel_common_statistics_tooltip_crossbow_crit_chance", "", gfxCrossbowSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat18", 'crossbowSteelDmg', "attribute_name_piercingdamage", "", gfxCrossbowSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat19", 'crossbowSilverDmg', "attribute_name_silverdamage", "", gfxCrossbowSub, parentFlashValueStorage);
	gfxCrossbow.SetMemberFlashArray("subStats", gfxCrossbowSub);
	
	
	
	gfxVitality =  AddCharacterStat("majorStat1", 'vitality', "vitality", "vitality", statsArray, parentFlashValueStorage);
	gfxVitalitySub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("vitality", gfxVitalitySub, parentFlashValueStorage, true, "Green");
	AddCharacterStat("defStat12", 'vitalityRegen', "panel_common_statistics_tooltip_outofcombat_regen", "", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterStat("defStat13", 'vitalityCombatRegen', "panel_common_statistics_tooltip_incombat_regen", "", gfxVitalitySub, parentFlashValueStorage);
	gfxVitality.SetMemberFlashArray("subStats", gfxVitalitySub);
	
	
	
	gfxToxicity = AddCharacterStat("majorStat2", 'toxicity', "attribute_name_toxicity", "toxicity", statsArray, parentFlashValueStorage);
	gfxToxicitySub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("attribute_name_toxicity", gfxToxicitySub, parentFlashValueStorage, true, "Green");	
	AddCharacterStatToxicity("lockedToxicity", 'lockedToxicity', "toxicity_offset", "", gfxToxicitySub, parentFlashValueStorage);
	AddCharacterStatToxicity("toxicity", 'toxicity', "toxicity", "", gfxToxicitySub, parentFlashValueStorage);
	gfxToxicity.SetMemberFlashArray("subStats", gfxToxicitySub);
	
	
	
	gfxSpellPower = AddCharacterStat("mainMagicStat", 'spell_power', "stat_signs", "spell_power", statsArray, parentFlashValueStorage);
	gfxSpellPowerSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("stat_signs", gfxSpellPowerSub, parentFlashValueStorage, true, "Blue");
	AddCharacterHeader("Aard", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("aardStat1", 'aard_knockdownchance', "attribute_name_knockdown", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("aardStat2", 'aard_damage', "attribute_name_forcedamage", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterHeader("Igni", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("igniStat1", 'igni_damage', "attribute_name_firedamage", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("igniStat2", 'igni_burnchance', "effect_burning", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterHeader("Quen", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("quenStat1", 'quen_damageabs', "physical_resistance", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterHeader("Yrden", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("yrdenStat1", 'yrden_slowdown', "SlowdownEffect", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("yrdenStat2", 'yrden_damage', "ShockDamage", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("yrdenStat3", 'yrden_duration', "duration", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterHeader("Axii", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("axiiStat1", 'axii_duration_confusion', "duration", "", gfxSpellPowerSub, parentFlashValueStorage);
	gfxSpellPower.SetMemberFlashArray("subStats", gfxSpellPowerSub);
	
	
	
	gfxStamina = AddCharacterStat("majorStat3", 'stamina', "stamina", "stamina", statsArray, parentFlashValueStorage);
	gfxStaminaSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("stamina", gfxStaminaSub, parentFlashValueStorage, true, "Blue");
	AddCharacterStat("defStat14", 'staminaOutOfCombatRegen', "attribute_name_staminaregen_out_of_combat", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("defStat15", 'staminaRegen', "attribute_name_staminaregen", "", gfxStaminaSub, parentFlashValueStorage);
	gfxStamina.SetMemberFlashArray("subStats", gfxStaminaSub);
	
	
	
	gfxAdditional = AddCharacterStat("majorStat5", 'additional', "panel_common_statistics_category_additional", "additional", statsArray, parentFlashValueStorage);
	gfxAdditionalSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("panel_common_statistics_category_additional", gfxAdditionalSub, parentFlashValueStorage, true, "Brown");
	AddCharacterStatF("extraStat1", 'bonus_herb_chance', "bonus_herb_chance", "", gfxAdditionalSub, parentFlashValueStorage);
	AddCharacterStatU("extraStat2", 'instant_kill_chance_mult', "instant_kill_chance", "", gfxAdditionalSub , parentFlashValueStorage);
	AddCharacterStatU("extraStat3", 'human_exp_bonus_when_fatal', "human_exp_bonus_when_fatal", "", gfxAdditionalSub , parentFlashValueStorage);
	AddCharacterStatU("extraStat4", 'nonhuman_exp_bonus_when_fatal', "nonhuman_exp_bonus_when_fatal", "", gfxAdditionalSub , parentFlashValueStorage);
	gfxAdditional.SetMemberFlashArray("subStats", gfxAdditionalSub);
	
	
	
	gameTime =	theGame.CalculateTimePlayed();
	gameTimeHours = (string)(GameTimeDays(gameTime) * 24 + GameTimeHours(gameTime));
	gameTimeMinutes = (string)GameTimeMinutes(gameTime);
	
	gfxData.SetMemberFlashArray("stats", statsArray);
	gfxData.SetMemberFlashString("hoursPlayed", gameTimeHours);
	gfxData.SetMemberFlashString("minutesPlayed", gameTimeMinutes);
	
	return gfxData;
	
	
	
	
}

function AddCharacterHeader(locKey:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage, optional isSuperHeader : bool, optional color : string):void
{
	var statObject : CScriptedFlashObject;
	statObject = flashMaster.CreateTempFlashObject();
	
	statObject.SetMemberFlashString("name", GetLocStringByKeyExt(locKey));
	statObject.SetMemberFlashString("value", "");
	
	if (isSuperHeader)
	{
		statObject.SetMemberFlashString("tag", "SuperHeader");
		statObject.SetMemberFlashString("backgroundColor", color);
	}
	else
	{
		statObject.SetMemberFlashString("tag", "Header");
	}
	
	statObject.SetMemberFlashString("iconTag", "");
	toArray.PushBackFlashObject(statObject);
}

function AddCharacterStat(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var statObject 		: CScriptedFlashObject;
	var valueStr 		: string;
	var valueMaxStr 	: string;
	var valueAbility 	: float;
	var final_name 		: string;
	var sp 				: SAbilityAttributeValue;
	var itemColor		: string;
	
	var gameTime		: GameTime;
	var gameTimeDays	: string;
	var gameTimeHours	: string;
	var gameTimeMinutes	: string;
	var gameTimeSeconds	: string;
	
	statObject			= 	flashMaster.CreateTempFlashObject();
	
	gameTime			=	theGame.CalculateTimePlayed();
	gameTimeDays 		= 	(string)GameTimeDays(gameTime);
	gameTimeHours 		= 	(string)GameTimeHours(gameTime);
	gameTimeMinutes 	= 	(string)GameTimeMinutes(gameTime);
	gameTimeSeconds 	= 	(string)GameTimeSeconds(gameTime);
	
	valueMaxStr = "";
	itemColor = "";

	if ( varKey == 'vitality' )
	{
		valueStr = (string)RoundMath(thePlayer.GetStat(BCS_Vitality, true));
		valueMaxStr = (string)RoundMath(thePlayer.GetStatMax(BCS_Vitality));
		itemColor = "Green";
	}
	else if ( varKey == 'toxicity' )
	{
		valueStr = (string)RoundMath(thePlayer.GetStat(BCS_Toxicity, false));
		valueMaxStr = (string)RoundMath(thePlayer.GetStatMax(BCS_Toxicity));
		itemColor = "Green";
	}
	else if ( varKey == 'stamina' ) 	
	{ 
		valueStr = (string)RoundMath(thePlayer.GetStat(BCS_Stamina, true));
		valueMaxStr = (string)RoundMath(thePlayer.GetStatMax(BCS_Stamina)); 
		itemColor = "Blue";
	}
	else if ( varKey == 'focus' )
	{
		valueStr = (string)FloorF(thePlayer.GetStat(BCS_Focus, true));
		valueMaxStr = (string)RoundMath(thePlayer.GetStatMax(BCS_Focus));
		itemColor = "Blue";
	}
	else if ( varKey == 'spell_power' )
	{
		sp += GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_1);
		sp += GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_2);
		sp += GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
		sp += GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_4);
		sp += GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_5);
		
		valueAbility = sp.valueMultiplicative / 5 - 1;
		valueStr = "+" + (string)RoundMath(valueAbility * 100) + " %";
		
		itemColor = "Blue";
	}
	else if ( varKey == 'vitalityRegen' ) 
	{ 
		valueStr = NoTrailZeros(RoundMath(CalculateAttributeValue( GetWitcherPlayer().GetAttributeValue( varKey ) ))) + "/" + GetLocStringByKeyExt("per_second");
	}
	else if ( varKey == 'vitalityCombatRegen' ) 
	{ 
		valueStr = NoTrailZeros(RoundMath(CalculateAttributeValue( GetWitcherPlayer().GetAttributeValue( varKey ) ))) + "/" + GetLocStringByKeyExt("per_second");
	}
	else if ( varKey == 'staminaRegen' ) 
	{
		sp = GetWitcherPlayer().GetAttributeValue(varKey);
		valueAbility = sp.valueAdditive + sp.valueMultiplicative * GetWitcherPlayer().GetStatMax(BCS_Stamina);
		
		valueAbility *= 1 + GetWitcherPlayer().CalculatedArmorStaminaRegenBonus();
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "/" + GetLocStringByKeyExt("per_second"); 
	}
	else if ( varKey == 'staminaOutOfCombatRegen' ) 
	{
		sp = GetWitcherPlayer().GetAttributeValue(varKey);
		
		valueAbility = GetWitcherPlayer().GetStatMax(BCS_Stamina) * sp.valueMultiplicative + sp.valueAdditive;
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "/" + GetLocStringByKeyExt("per_second"); 
	}
	else if( varKey == 'armor')
	{	
		valueAbility =  CalculateAttributeValue( GetWitcherPlayer().GetTotalArmor() );
		valueStr = IntToString( RoundMath(  valueAbility ) );
		itemColor = "Red";
	}
	else if (varKey == 'crossbow')
	{
		valueStr = NoTrailZeros(RoundMath(GetEquippedCrossbowDamage()));
		itemColor = "Red";
	}	
	else if (varKey == 'additional')
	{
		valueStr = "";
		itemColor = "Brown";
	}
	else
	{	
		valueAbility =  CalculateAttributeValue( GetWitcherPlayer().GetAttributeValue( varKey ) );
		valueStr = IntToString( RoundMath(  valueAbility ) );
	}
	
	final_name = GetLocStringByKeyExt(locKey); if ( final_name == "#" ) { final_name = ""; }
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr);
	statObject.SetMemberFlashString("maxValue", valueMaxStr);
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	statObject.SetMemberFlashString("itemColor", itemColor);
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatToxicity(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility : float;
	
	var toxicityLocked : float;
	var toxicityNoLock : float;
	
	var sp : SAbilityAttributeValue;
	var final_name 		: string;
	var itemColor		: string;
	
	statObject = flashMaster.CreateTempFlashObject();
	
	toxicityNoLock = GetWitcherPlayer().GetStat(BCS_Toxicity, true);
	toxicityLocked = GetWitcherPlayer().GetStat(BCS_Toxicity) - toxicityNoLock;
	
	if ( varKey == 'lockedToxicity' )	
	{
		valueStr = NoTrailZeros(RoundMath(toxicityLocked));
	}
	else
	{
		valueStr = NoTrailZeros(RoundMath(toxicityNoLock));
	}
	
	final_name = GetLocStringByKeyExt(locKey); if ( final_name == "#" ) { final_name = ""; }
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr);
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	statObject.SetMemberFlashString("itemColor", itemColor);
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatSigns(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility : float;
	var final_name : string;
	var min, max : float;
	var sp, mutDmgMod, mutMin, mutMax : SAbilityAttributeValue;
	var sword : SItemUniqueId;
	
	statObject = flashMaster.CreateTempFlashObject();
	
	if( GetWitcherPlayer().IsMutationActive( EPMT_Mutation1 ) )
	{
		sword = thePlayer.inv.GetCurrentlyHeldSword();
			
		if( thePlayer.inv.GetItemCategory(sword) == 'steelsword' )
		{
			mutDmgMod += thePlayer.inv.GetItemAttributeValue(sword, theGame.params.DAMAGE_NAME_SLASHING);
		}
		else if( thePlayer.inv.GetItemCategory(sword) == 'silversword' )
		{
			mutDmgMod += thePlayer.inv.GetItemAttributeValue(sword, theGame.params.DAMAGE_NAME_SILVER);
		}
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation1', 'dmg_bonus_factor', mutMin, mutMax);
			
		mutDmgMod.valueBase *= CalculateAttributeValue(mutMin);
	}
	
	
	if ( varKey == 'aard_knockdownchance' )	
	{ 
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_1);
		valueAbility = sp.valueMultiplicative / theGame.params.MAX_SPELLPOWER_ASSUMED - 4 * theGame.params.NPC_RESIST_PER_LEVEL;  
		valueStr = (string)RoundMath( valueAbility * 100 ) + " %";
	}
	else if ( varKey == 'aard_damage' ) 	
	{  
		if ( GetWitcherPlayer().CanUseSkill(S_Magic_s06) )
		{
			valueAbility = GetWitcherPlayer().GetSkillLevel(S_Magic_s06) * CalculateAttributeValue( GetWitcherPlayer().GetSkillAttributeValue( S_Magic_s06, theGame.params.DAMAGE_NAME_FORCE, false, true ) );
			valueAbility += mutDmgMod.valueBase;			
			
			valueStr = (string)RoundMath( valueAbility );
		}
		else
			valueStr = "0";
	}
	else if ( varKey == 'igni_damage' ) 	
	{  
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_2);
		valueAbility = CalculateAttributeValue( GetWitcherPlayer().GetSkillAttributeValue( S_Magic_2, theGame.params.DAMAGE_NAME_FIRE, false, true ) );
		valueAbility += mutDmgMod.valueBase;
		valueAbility *= 1 + (sp.valueMultiplicative-1) * theGame.params.IGNI_SPELL_POWER_MILT;		
		valueStr = (string)RoundMath( valueAbility );
	}
	else if ( varKey == 'igni_burnchance' ) 	
	{  
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_2);
		
		
		valueAbility = ( 1 + LogF( sp.valueMultiplicative ) ) / theGame.params.MAX_SPELLPOWER_ASSUMED - 4 * theGame.params.NPC_RESIST_PER_LEVEL; 
		
		if (GetWitcherPlayer().CanUseSkill(S_Magic_s09))
		{
			sp = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s09, 'chance_bonus', false, false);
			valueAbility += valueAbility * sp.valueMultiplicative * GetWitcherPlayer().GetSkillLevel(S_Magic_s09) + sp.valueAdditive * GetWitcherPlayer().GetSkillLevel(S_Magic_s09);
		}
		valueStr = (string)Min(100, RoundMath(valueAbility * 100)) + " %";
	}
	else if ( varKey == 'quen_damageabs' )
	{
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_4);
		valueAbility = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_4, 'shield_health', false, false));
		valueAbility += mutDmgMod.valueBase;
		valueAbility *= sp.valueMultiplicative;
		valueStr = (string)RoundMath( valueAbility );
	}
	else if ( varKey == 'yrden_slowdown' )
	{
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
		min = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_3, 'min_slowdown', false, true));
		max = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_3, 'max_slowdown', false, true));
		valueAbility = sp.valueMultiplicative / 4;
		valueAbility =  min + (max - min) * valueAbility;
		valueAbility = ClampF( valueAbility, min, max );
		valueAbility *= 1 - ClampF(4 * theGame.params.NPC_RESIST_PER_LEVEL, 0, 1) ;
		valueStr = (string)RoundMath( valueAbility * 100 ) + " %";
	}
	else if ( varKey == 'yrden_damage' )
	{
		if (GetWitcherPlayer().CanUseSkill(S_Magic_s03))
		{
			sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_s03);
			valueAbility = CalculateAttributeValue( GetWitcherPlayer().GetSkillAttributeValue( S_Magic_s03, theGame.params.DAMAGE_NAME_SHOCK, false, true ) );
			valueAbility += mutDmgMod.valueBase;
			valueAbility *= sp.valueMultiplicative;			
			valueStr = (string)RoundMath( valueAbility );
		}
		else
			valueStr = "0";
	}
	else if ( varKey == 'yrden_duration' )
	{
		sp += GetWitcherPlayer().GetSkillAttributeValue(S_Magic_3, 'trap_duration', false, true);
		sp += GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
		sp.valueMultiplicative -= 1;
		valueStr = FloatToStringPrec( CalculateAttributeValue(sp), 2 ) + GetLocStringByKeyExt("per_second");
	}
	else if ( varKey == 'axii_duration_confusion' )
	{
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_5);
		sp += GetWitcherPlayer().GetSkillAttributeValue(S_Magic_5, 'duration', false, true);
		valueStr = FloatToStringPrec( CalculateAttributeValue(sp), 2 ) + GetLocStringByKeyExt("per_second");
	}
	
	else
	{	
		valueAbility =  CalculateAttributeValue( GetWitcherPlayer().GetAttributeValue( varKey ) );
		valueStr = IntToString( RoundF(  valueAbility ) );
	}
	
	final_name = GetLocStringByKeyExt(locKey); if ( final_name == "#" ) { final_name = ""; }
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr);
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	statObject.SetMemberFlashString("itemColor", "Blue");
	
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatF(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility, pts, perc : float;
	var final_name : string;
	var witcher : W3PlayerWitcher;
	var isPointResist : bool;
	var stat : EBaseCharacterStats;
	var resist : ECharacterDefenseStats;
	var attributeValue : SAbilityAttributeValue;
	var powerStat : ECharacterPowerStats;
	
	statObject = flashMaster.CreateTempFlashObject();
		
	
	witcher = GetWitcherPlayer();
	stat = StatNameToEnum(varKey);
	if(stat != BCS_Undefined)
	{
		valueAbility = witcher.GetStat(stat);
	}
	else
	{
		resist = ResistStatNameToEnum(varKey, isPointResist);
		if(resist != CDS_None)
		{
			witcher.GetResistValue(resist, pts, perc);
			
			if(isPointResist)
				valueAbility = pts;
			else
				valueAbility = perc;
		}
		else
		{
			powerStat = PowerStatNameToEnum(varKey);
			if(powerStat != CPS_Undefined)
			{
				attributeValue = witcher.GetPowerStatValue(powerStat);
			}
			else
			{
				attributeValue = witcher.GetAttributeValue(varKey);
			}
			
			valueAbility = CalculateAttributeValue( attributeValue );
		}
	}
	
	
	valueStr = NoTrailZeros( RoundMath(valueAbility * 100) );
	
	final_name = GetLocStringByKeyExt(locKey);
	if ( final_name == "#" )
	{
		final_name = "";
	}
	
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr + " %");
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatU(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var curStats:SPlayerOffenseStats;
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility, maxHealth, curHealth : float;
	var sp : SAbilityAttributeValue;
	var final_name : string;
	var item : SItemUniqueId;

	statObject = flashMaster.CreateTempFlashObject();
	
	
	
	
	
	
	if(varKey != 'instant_kill_chance_mult' && varKey != 'human_exp_bonus_when_fatal' && varKey != 'nonhuman_exp_bonus_when_fatal' && varKey != 'area_nml' && varKey != 'area_novigrad' && varKey != 'area_skellige')
	{
		curStats = GetWitcherPlayer().GetOffenseStatsList();
	}
	
	if ( varKey == 'silverdamage' ) 				valueStr = NoTrailZeros(RoundMath((curStats.silverFastDPS+curStats.silverStrongDPS)/2));
	else if ( varKey == 'steeldamage' ) 			valueStr = NoTrailZeros(RoundMath((curStats.steelFastDPS+curStats.steelStrongDPS)/2));	
	else if ( varKey == 'silverFastDPS' ) 			valueStr = NoTrailZeros(RoundMath(curStats.silverFastDmg));	
	else if ( varKey == 'silverFastCritChance' )	valueStr = NoTrailZeros(RoundMath(curStats.silverFastCritChance))+" %";
	else if ( varKey == 'silverFastCritDmg' )		valueStr = NoTrailZeros(RoundMath(curStats.silverFastCritDmg));
	else if ( varKey == 'silverStrongDPS' )			valueStr = NoTrailZeros(RoundMath(curStats.silverStrongDmg));
	else if ( varKey == 'silverStrongCritChance' )	valueStr = NoTrailZeros(RoundMath(curStats.silverStrongCritChance))+" %";
	else if ( varKey == 'silverStrongCritDmg' )		valueStr = NoTrailZeros(RoundMath(curStats.silverStrongCritDmg));
	else if ( varKey == 'steelFastDPS' ) 			valueStr = NoTrailZeros(RoundMath(curStats.steelFastDmg));	
	else if ( varKey == 'steelFastCritChance' )		valueStr = NoTrailZeros(RoundMath(curStats.steelFastCritChance))+" %";
	else if ( varKey == 'steelFastCritDmg' )		valueStr = NoTrailZeros(RoundMath(curStats.steelFastCritDmg));
	else if ( varKey == 'steelStrongDPS' )			valueStr = NoTrailZeros(RoundMath(curStats.steelStrongDmg));
	else if ( varKey == 'steelStrongCritChance' )	valueStr = NoTrailZeros(RoundMath(curStats.steelStrongCritChance))+" %";
	else if ( varKey == 'steelStrongCritDmg' )		valueStr = NoTrailZeros(RoundMath(curStats.steelStrongCritDmg));
	else if ( varKey == 'crossbowCritChance' )		valueStr = NoTrailZeros(RoundMath(curStats.crossbowCritChance * 100))+" %";
	else if ( varKey == 'crossbowDmg' )				valueStr = "";
	else if ( varKey == 'crossbowSteelDmg' )				
	{ 
		valueStr = NoTrailZeros(RoundMath(curStats.crossbowSteelDmg));
		switch (curStats.crossbowSteelDmgType)
		{
			case theGame.params.DAMAGE_NAME_BLUDGEONING: locKey = "attribute_name_bludgeoningdamage"; break;
			case theGame.params.DAMAGE_NAME_FIRE: locKey = "attribute_name_firedamage"; break;
			default : locKey = "attribute_name_piercingdamage"; break;
		}
	} 
	else if ( varKey == 'crossbowSilverDmg' )				
	{
		valueStr = NoTrailZeros(RoundMath(curStats.crossbowSilverDmg));
	}
	else if ( varKey == 'instant_kill_chance_mult') 
	{
		valueAbility = 0;
		if (thePlayer.CanUseSkill(S_Sword_s03))
		{
			sp += GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s03, 'instant_kill_chance', false, true);
			valueAbility = CalculateAttributeValue(sp);
			valueAbility *= thePlayer.GetSkillLevel(S_Sword_s03);
			valueAbility *= RoundF(thePlayer.GetStat(BCS_Focus));
		}
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(item, varKey)); 
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(item, varKey)); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if (varKey == 'human_exp_bonus_when_fatal' || varKey == 'nonhuman_exp_bonus_when_fatal') 
	{
		sp = thePlayer.GetAttributeValue(varKey);

		valueStr = NoTrailZeros(RoundMath(CalculateAttributeValue(sp) * 100)) + " %";
	}
	else if (varKey == 'area_nml') 
	{
		if (!thePlayer.HasAbility(varKey))
			locKey = "";
		else
		{
			
			
		}
	}
	else if (varKey == 'area_novigrad') 
	{
		if (!thePlayer.HasAbility(varKey))
			locKey = "";
		else
		{
			
			
		}
	}
	else if (varKey == 'area_skellige') 
	{
		if (!thePlayer.HasAbility(varKey))
			locKey = "";
		else
		{
			
			
		}
	}
	
	final_name = GetLocStringByKeyExt(locKey); if ( final_name == "#" ) { final_name = ""; }
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr );
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	statObject.SetMemberFlashString("itemColor", "Red");
	
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatU2(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var curStats:SPlayerOffenseStats;
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility, maxHealth, curHealth : float;
	var sp : SAbilityAttributeValue;
	var final_name : string;
	var item : SItemUniqueId;

	statObject = flashMaster.CreateTempFlashObject();
	
	if ( varKey == 'silver_desc_poinsonchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_poinsonchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'silver_desc_bleedingchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_bleedingchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'silver_desc_burningchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_burningchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'silver_desc_confusionchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_confusionchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'silver_desc_freezingchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_freezingchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'silver_desc_staggerchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_staggerchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	}
	else if ( varKey == 'steel_desc_poinsonchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_poinsonchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'steel_desc_bleedingchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_bleedingchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'steel_desc_burningchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_burningchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'steel_desc_confusionchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_confusionchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'steel_desc_freezingchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_freezingchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'steel_desc_staggerchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_staggerchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	}
	
	final_name = GetLocStringByKeyExt(locKey); if ( final_name == "#" ) { final_name = ""; }
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr );
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function GetEquippedCrossbowDamage():float
{
	var equippedBolt		  : SItemUniqueId;
	var equippedCrossbow	  : SItemUniqueId;
	var crossbowPower         : SAbilityAttributeValue;
	var crossbowStatValueMult : float;
	var primaryStatLabel      : string;
	var primaryStatValue      : float;
	var silverDamageValue	  : float;
	var min, max 			  : SAbilityAttributeValue;
	
	GetWitcherPlayer().GetItemEquippedOnSlot(EES_RangedWeapon, equippedCrossbow);
	if (!thePlayer.inv.IsIdValid(equippedCrossbow))
	{
		return 0;
	}
	
	crossbowPower = thePlayer.inv.GetItemAttributeValue(equippedCrossbow, 'attack_power');
	if(thePlayer.CanUseSkill(S_Perk_02))
	{				
		crossbowPower += thePlayer.GetSkillAttributeValue(S_Perk_02, PowerStatEnumToName(CPS_AttackPower), false, true);
	}
	if ( thePlayer.HasBuff(EET_Mutagen05) && (thePlayer.GetStat(BCS_Vitality) == thePlayer.GetStatMax(BCS_Vitality)) )
	{
		crossbowPower += thePlayer.GetAttributeValue('damageIncrease');
	}
	crossbowPower += thePlayer.GetPowerStatValue(CPS_AttackPower);
	
	if (crossbowStatValueMult == 0)
	{
		
		crossbowStatValueMult = 1;
	}
	GetWitcherPlayer().GetItemEquippedOnSlot(EES_Bolt, equippedBolt);
	if (thePlayer.inv.IsIdValid(equippedBolt))
	{
		thePlayer.inv.GetItemPrimaryStat(equippedBolt, primaryStatLabel, primaryStatValue);
		silverDamageValue = CalculateAttributeValue(GetWitcherPlayer().GetInventory().GetItemAttributeValue(equippedBolt, theGame.params.DAMAGE_NAME_SILVER));
	}
	else
	{
		thePlayer.inv.GetItemStatByName('Bodkin Bolt', 'PiercingDamage', primaryStatValue);
		thePlayer.inv.GetItemStatByName('Bodkin Bolt', 'SilverDamage', silverDamageValue);
	}
	
	
	if( GetWitcherPlayer().IsMutationActive( EPMT_Mutation9 ) )
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation9', 'damage', min, max );
		primaryStatValue += min.valueAdditive;
		silverDamageValue += min.valueAdditive;
	}
	
	primaryStatValue = (primaryStatValue + crossbowPower.valueBase) * crossbowPower.valueMultiplicative + crossbowPower.valueAdditive;
	silverDamageValue = (silverDamageValue + crossbowPower.valueBase) * crossbowPower.valueMultiplicative + crossbowPower.valueAdditive;
	
	return (primaryStatValue + silverDamageValue) / 2;
}