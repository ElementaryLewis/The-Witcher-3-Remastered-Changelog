/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4CharacterSkillsMenu extends CR4MenuBase
{	
	event  OnConfigUI()
	{	
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		super.OnConfigUI();
		

		UpdateSkills();
		UpdatePlayerStatisticsData();
		
		m_flashValueStorage.SetFlashString("character.points.description",GetLocStringByKeyExt('panel_character_availablepoints'));
	}
	
	function UpdateSkills()
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArraySword			: CScriptedFlashArray;
		var l_flashArraySigns			: CScriptedFlashArray;
		var l_flashArrayAlchemy			: CScriptedFlashArray;
		var skills 					: array<SSkill>;
		var i : int;
		var posID : int;
		var abilityName : name;

		skills = GetWitcherPlayer().GetPlayerSkills();

		l_flashArraySword = m_flashValueStorage.CreateTempFlashArray();
		l_flashArraySigns = m_flashValueStorage.CreateTempFlashArray();
		l_flashArrayAlchemy = m_flashValueStorage.CreateTempFlashArray();
		
		for( i = 0; i < skills.Size(); i += 1 )
		{
			l_flashObject = m_flashValueStorage.CreateTempFlashObject("red.game.witcher3.menus.common.SkillDataStub");
			l_flashObject.SetMemberFlashUInt("abilityName",NameToFlashUInt(skills[i].abilityName));
			if(skills[i].iconPath != "FIXME")
			{
				l_flashObject.SetMemberFlashString("iconPath",skills[i].iconPath);
			}
			else
			{
				l_flashObject.SetMemberFlashString("iconPath","icons\perks\ICON_SkillTemp.png");
			}
			l_flashObject.SetMemberFlashBool("acquired", GetWitcherPlayer().GetSkillLevel(i) > 0);
			l_flashObject.SetMemberFlashBool("avialable",CheckIfAvailable(skills[i])); 
			l_flashObject.SetMemberFlashBool("isNew",skills[i].isNew);
			l_flashObject.SetMemberFlashBool("isSkill",true);
			posID = skills[i].positionID;
			abilityName = skills[i].abilityName;
			l_flashObject.SetMemberFlashInt("positonID",posID);

			switch(skills[i].skillPath)
			{
				case ESP_Sword :
					l_flashArraySword.PushBackFlashObject(l_flashObject);
					break;			
				case ESP_Signs :
					l_flashArraySigns.PushBackFlashObject(l_flashObject);
					break;		
				case ESP_Alchemy :
					l_flashArrayAlchemy.PushBackFlashObject(l_flashObject);
					break;
			}
		}
		m_flashValueStorage.SetFlashInt("character.points.value",GetCurrentSkillPoints());	
		m_flashValueStorage.SetFlashArray( "character.tree.skills.sword", l_flashArraySword );
		m_flashValueStorage.SetFlashArray( "character.tree.skills.signs", l_flashArraySigns );
		m_flashValueStorage.SetFlashArray( "character.tree.skills.alchemy", l_flashArrayAlchemy );
		m_flashValueStorage.SetFlashString("character.tree.skills.sword.name",GetLocStringByKeyExt('panel_character_skill_sword'));
		m_flashValueStorage.SetFlashString("character.tree.skills.signs.name",GetLocStringByKeyExt('panel_character_skill_signs'));
		m_flashValueStorage.SetFlashString("character.tree.skills.alchemy.name",GetLocStringByKeyExt('panel_character_skill_alchemy'));	
	}

	private function CheckIfAvailable( skill : SSkill ) : bool
	{
		var skillType : ESkill;
		skillType = SkillNameToEnum(skill.abilityName);
		return ( GetCurrentSkillPoints() > 0 ) && GetWitcherPlayer().CanLearnSkill(skillType);
	}

	private function GetCurrentSkillPoints() : int
	{
		var levelManager : W3LevelManager;
		
		levelManager = GetWitcherPlayer().levelManager;
		
		return levelManager.GetPointsFree(ESkillPoint);
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
		m_flashValueStorage.SetFlashString( "playerstats.stats.name", GetLocStringByKeyExt("panel_common_statistics_name"),-1 );
	}
	
	function UpdateStatsTooltip( statName : string ) 
	{
		m_flashValueStorage.SetFlashString("inventory.stats.title",statName,-1);
		m_flashValueStorage.SetFlashString("inventory.stats.description",statName+"description",-1);
	}	

	function UpdateSkillTooltip( skillName : name )
	{
		var skillDisplayName : string;
		var skillDisplayDescription : string;
		var skillType : ESkill;
		var skillTemp : SSkill;
		
		skillType = SkillNameToEnum(skillName);

		skillDisplayName = GetLocStringByKeyExt(GetWitcherPlayer().GetSkillLocalisationKeyName(skillType));
		skillDisplayDescription = GetLocStringByKeyExt(GetWitcherPlayer().GetSkillLocalisationKeyDescription(skillType));

		m_flashValueStorage.SetFlashString("character.tooltip.title",skillDisplayName,-1);
		m_flashValueStorage.SetFlashString("character.tooltip.description",skillDisplayDescription,-1);
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

	event  OnBuySkill( skillName : name )
	{
		var skillType : ESkill;
		
		skillType = SkillNameToEnum(skillName);
		if( GetWitcherPlayer().CanLearnSkill(skillType) )
		{
			GetWitcherPlayer().AddSkill(skillType);
			UpdateSkills(); 
			UpdateSkillTooltip(skillName);
			UpdatePlayerStatisticsData();
		}
		else
		{
			LogChannel('SKILLS',"You can't buy skill "+skillName);
		}
	}	
	
	event  OnUpdateSkillTooltip( skillName : name )
	{
		UpdateSkillTooltip(skillName);
	}	

	event  OnCharacterTabSelected( id : int )
	{
		m_flashValueStorage.SetFlashInt("character.tab.mode",id,-1);
	}
	
	event  OnPlaySound( soundKey : string )
	{
		theSound.SoundEvent( soundKey );
	}
}
