/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4CharacterPerksMenu extends CR4MenuBase
{	
	var moduleId : int;

	event  OnConfigUI()
	{	
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		super.OnConfigUI();
		
		
		UpdatePerks();
		UpdateBookPerks();
		
		UpdatePlayerStatisticsData();
	}

	function UpdatePerks()
	{
	}
	
	function UpdateBookPerks()
	{
	}
	
	protected function GetSkillGFxObject(curSkill : SSkill, out dataObject : CScriptedFlashObject) : void
	{
		dataObject.SetMemberFlashInt('id', curSkill.skillType); 
		dataObject.SetMemberFlashInt('skillTypeId', curSkill.skillType);
		dataObject.SetMemberFlashInt('level', GetWitcherPlayer().GetSkillLevel(curSkill.skillType));
		
		dataObject.SetMemberFlashString('skillType', curSkill.skillType);
		dataObject.SetMemberFlashString('skillPath', curSkill.skillPath);
		
		dataObject.SetMemberFlashString('cost', curSkill.cost);
		dataObject.SetMemberFlashString('iconPath', curSkill.iconPath);
		dataObject.SetMemberFlashString('positionID', curSkill.positionID);
		
		
		
		
		
		
		
		
		
		dataObject.SetMemberFlashBool('isEquipped', thePlayer.IsSkillEquipped(curSkill.skillType));
	}

	function UpdatePlayerStatisticsData()
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		var attackPower, spellPower	: SAbilityAttributeValue;
		var id						: SItemUniqueId;
		
		var value 					: int;
		var valueFloat 				: float;
		
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("name",GetBaseStatLocalizedName(BCS_Vitality));
		l_flashObject.SetMemberFlashString("icon","Vitality");
		l_flashObject.SetMemberFlashString("value", RoundMath(thePlayer.GetStatMax(BCS_Vitality)));
		l_flashArray.PushBackFlashObject(l_flashObject);

		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("name",GetBaseStatLocalizedName(BCS_Stamina));
		l_flashObject.SetMemberFlashString("icon","Stamina");
		l_flashObject.SetMemberFlashString("value", RoundMath(thePlayer.GetStatMax(BCS_Stamina)));
		l_flashArray.PushBackFlashObject(l_flashObject);

		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("name",GetRegenStatLocalizedName(CRS_Vitality));
		l_flashObject.SetMemberFlashString("icon","Vitality Regeneration");		
		l_flashObject.SetMemberFlashString("value", NoTrailZeros(RoundTo(CalculateAttributeValue(thePlayer.GetAttributeValue(RegenStatEnumToName(CRS_Vitality))),1)) +" /s");
		l_flashArray.PushBackFlashObject(l_flashObject);

		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("name",GetRegenStatLocalizedName(CRS_Stamina));
		l_flashObject.SetMemberFlashString("icon","Stamina regeneration");
		l_flashObject.SetMemberFlashString("value", NoTrailZeros(RoundTo(CalculateAttributeValue(thePlayer.GetAttributeValue(RegenStatEnumToName(CRS_Stamina))),1)) +" /s");
		l_flashArray.PushBackFlashObject(l_flashObject);
		
		
		l_flashObject = GetMenuFlashValueStorage().CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("name",GetPowerStatLocalizedName(CPS_AttackPower));
		l_flashObject.SetMemberFlashString("icon","Attack power");
		attackPower = thePlayer.GetPowerStatValue(CPS_AttackPower);
		l_flashObject.SetMemberFlashString("value",RoundMath(attackPower.valueMultiplicative*100) + " %");
		l_flashArray.PushBackFlashObject(l_flashObject);
		
		l_flashObject = GetMenuFlashValueStorage().CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("name",GetPowerStatLocalizedName(CPS_SpellPower));
		l_flashObject.SetMemberFlashString("icon","Spell power");
		spellPower = thePlayer.GetPowerStatValue(CPS_AttackPower);
		l_flashObject.SetMemberFlashString("value",RoundMath(spellPower.valueMultiplicative*100) + " %");
		l_flashArray.PushBackFlashObject(l_flashObject);

		
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("name",GetLocStringByKeyExt("Steel sword damage")); 
		l_flashObject.SetMemberFlashString("icon","Steel sword damage");		
		if(GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, id))
		{
			l_flashObject.SetMemberFlashString("value", GetWeaponDamageStats(id, attackPower));
		}
		else
		{
			
			l_flashObject.SetMemberFlashString("value","-");
		}
		l_flashArray.PushBackFlashObject(l_flashObject);

		
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("name",GetLocStringByKeyExt("Silver sword damage")); 
		l_flashObject.SetMemberFlashString("icon","Silver sword damage");		
		if(GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, id))
		{
			l_flashObject.SetMemberFlashString("value", GetWeaponDamageStats(id, attackPower));
		}
		else
		{
			
			l_flashObject.SetMemberFlashString("value","-");
		}
		l_flashArray.PushBackFlashObject(l_flashObject);
		
		m_flashValueStorage.SetFlashArray( "playerstats.stats", l_flashArray );
		m_flashValueStorage.SetFlashString( "playerstats.stats.name", GetLocStringByKeyExt("panel_common_statistics_name"));
	}
	
	function UpdateStatsTooltip( statName : string ) 
	{
		m_flashValueStorage.SetFlashString("inventory.stats.title",statName);
		m_flashValueStorage.SetFlashString("inventory.stats.description",statName+"description");
	}
	
	
	event  OnGetSkillTooltipData(skillType : ESkill, compareItemType : int)
	{
		var resultGFxData 	: CScriptedFlashObject;
		var skillDisplayName : string;
		var skillDisplayDescription : string;
		var skillTemp : SSkill;
		
		
		resultGFxData = m_flashValueStorage.CreateTempFlashObject();
		resultGFxData.SetMemberFlashString('skillName', GetLocStringByKeyExt(skillTemp.localisationNameKey));
		resultGFxData.SetMemberFlashString('skillDescription', GetLocStringByKeyExt(skillTemp.localisationDescriptionKey));
		resultGFxData.SetMemberFlashString('skillLevel', GetWitcherPlayer().GetSkillLevel(skillTemp.skillType) + "/"+skillTemp.maxLevel);
		resultGFxData.SetMemberFlashString('IconPath', skillTemp.iconPath);
		m_flashValueStorage.SetFlashObject("context.tooltip.data", resultGFxData);
	}
	
	private function GetWeaponDamageStats(id : SItemUniqueId, attackPower : SAbilityAttributeValue) : string
	{
		var durabilityModifier, silverDamage, steelDamage, elementalDamage : float;
		var retString : string;
	
		
		durabilityModifier = theGame.params.GetDurabilityMultiplier(thePlayer.inv.GetItemDurabilityRatio(id), true);
	
		
		steelDamage = CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(id, theGame.params.DAMAGE_NAME_PHYSICAL));
		steelDamage += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(id, theGame.params.DAMAGE_NAME_SLASHING));
		steelDamage += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(id, theGame.params.DAMAGE_NAME_PIERCING));
		steelDamage += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(id, theGame.params.DAMAGE_NAME_BLUDGEONING));
		silverDamage = CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(id, theGame.params.DAMAGE_NAME_SILVER));
		
		elementalDamage = CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(id, theGame.params.DAMAGE_NAME_FIRE));
		elementalDamage += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(id, theGame.params.DAMAGE_NAME_FROST));
		elementalDamage += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(id, theGame.params.DAMAGE_NAME_POISON));
		elementalDamage += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(id, theGame.params.DAMAGE_NAME_SHOCK));
					
		
		steelDamage = MaxF(0, (steelDamage + attackPower.valueBase) * attackPower.valueMultiplicative + attackPower.valueAdditive);
		steelDamage *= durabilityModifier;			
		
		silverDamage = MaxF(0, (silverDamage + attackPower.valueBase) * attackPower.valueMultiplicative + attackPower.valueAdditive);
		silverDamage *= durabilityModifier;
		
		elementalDamage = MaxF(0, (elementalDamage + attackPower.valueBase) * attackPower.valueMultiplicative + attackPower.valueAdditive);
		elementalDamage *= durabilityModifier;
		
		
		retString = RoundF(steelDamage) + " + " + RoundF(silverDamage);
		if(elementalDamage > 0)
			retString += " + " + RoundF(elementalDamage);
			
		return  retString;
	}
	
	event  OnCloseMenu()
	{
		if( m_parentMenu )
		{
			m_parentMenu.OnCloseMenu();
		}
		theSound.SoundEvent( 'gui_global_quit' ); 
		CloseMenu();
	}

	event  OnUpdateCharacterButtons( skillName : string )
	{
		
	}		
	
	event  OnCharacterTabSelected( id : int )
	{
		m_flashValueStorage.SetFlashInt("character.tab.mode",id,-1);
	}
	
	event  OnModuleSelected(  moduleID : int, optional moduleBindingName : string )
	{
		super.OnModuleSelected(  moduleID, moduleBindingName );
		switch(moduleBindingName)
		{
			case "character.perks" :
				moduleId = 0;
				break;
			case "character.books" :
				moduleId = 1;
				break;
			default:
				return false;
		}
	}	
	
	event  OnPlaySound( soundKey : string )
	{
		theSound.SoundEvent( soundKey );
	}
}