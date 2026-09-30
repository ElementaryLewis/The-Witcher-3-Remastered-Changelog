/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3PlayerAbilityManager extends W3AbilityManager
{
	private   saved var skills : array<SSkill>;									
	
	private   saved var resistStatsItems : array<array<SResistanceValue>>;		
	private   saved var toxicityOffset : float;									
	private 		var pathPointsSpent : array<int>;							
	private   saved var skillSlots : array<SSkillSlot>;							
	protected saved var skillAbilities : array<name>;							
	private 		var totalSkillSlotsCount : int;								
	private 		var tempSkills : array<ESkill>;								
	private   saved var mutagenSlots : array<SMutagenSlot>;						
	private			var temporaryTutorialSkills : array<STutorialTemporarySkill>;	
	private   saved var ep1SkillsInitialized : bool;
	private   saved var ep2SkillsInitialized : bool;
	private   saved var baseGamePerksGUIPosUpdated : bool;
	private	  saved var remasterSkillsNeedInit : bool;
	private   saved var mutagenBonuses : array< SMutagenBonusAlchemy19 >;		
	private   saved var alchemy19OptimizationDone : bool;						
	
	
	private   saved var isMutationSystemEnabled : bool;							
	private   saved var equippedMutation : EPlayerMutationType;					
	private   saved var mutations : array< SMutation >;							
	private   saved var mutationUnlockedSlotsIndexes : array< int >;			
	private   saved var mutationSkillSlotsInitialized : bool;					
	
	
	private const var LINK_BONUS_BLUE, LINK_BONUS_GREEN, LINK_BONUS_RED : name;	
	private const var MUTATION_SKILL_GROUP_ID : int;							
	
		default LINK_BONUS_BLUE = 'SkillLinkBonus_Blue';
		default LINK_BONUS_GREEN = 'SkillLinkBonus_Green';
		default LINK_BONUS_RED = 'SkillLinkBonus_Red';
		default MUTATION_SKILL_GROUP_ID = 5;
		
		default ep1SkillsInitialized = false;
		default ep2SkillsInitialized = false;
		default baseGamePerksGUIPosUpdated = false;
		default remasterSkillsNeedInit = false;
		
		
	
	public final function Init(ownr : CActor, cStats : CCharacterStats, isFromLoad : bool, diff : EDifficultyMode) : bool
	{
		var skillDefs : array<name>;
		var i : int;
		
		isInitialized = false;	
		
		if(!ownr)
		{
			LogAssert(false, "W3PlayerAbilityManager.Init: owner is NULL!!!!");
			return false;
		}
		else if(!( (CPlayer)ownr ))
		{
			LogAssert(false, "W3PlayerAbilityManager.Init: trying to create for non-player object!! Aborting!!");
			return false;
		}
		
		
		resistStatsItems.Resize(EnumGetMax('EEquipmentSlots')+1);
		pathPointsSpent.Resize(EnumGetMax('ESkillPath')+1);		
		
		
		ownr.AddAbility(theGame.params.GLOBAL_PLAYER_ABILITY);
		
		if(!super.Init(ownr,cStats, isFromLoad, diff))
			return false;
			
		LogChannel('CHR', "Init W3PlayerAbilityManager "+isFromLoad);		
		
		
		InitSkillSlots( isFromLoad );
		
		if(!isFromLoad)
		{	
			
			charStats.GetAbilitiesWithTag('SkillDefinitionName', skillDefs);
			LogAssert(skillDefs.Size()>0, "W3PlayerAbilityManager.Init: actor <<" + owner + ">> has no skills!!");
			
			for(i=0; i<skillDefs.Size(); i+=1)
				CacheSkills(skillDefs[i], skills);
				
			LoadMutagenSlotsDataFromXML();
			
			
			
			mutagenBonuses.Resize( GetSkillGroupsCount() + 5 );
			
			
			InitSkills();
			
			PrecacheModifierSkills();

			FactsAdd("RemasterSkillResetAndRefund");
		}
		else
		{
			if (skills.Size() != S_Perk_MAX)
			{
				
				skills.Clear();
				remasterSkillsNeedInit = true;
			}
			tempSkills.Clear();
			temporaryTutorialSkills.Clear();
			
			if ( !ep1SkillsInitialized && theGame.GetDLCManager().IsEP1Available() )
			{				
				ep1SkillsInitialized = FixMissingSkills();
			}
			if ( !ep2SkillsInitialized && theGame.GetDLCManager().IsEP2Available() )
			{
				ep2SkillsInitialized = FixMissingSkills();
			}
			if (remasterSkillsNeedInit)
			{
				FixMissingSkills();
				remasterSkillsNeedInit = false;
			}
			if ( !baseGamePerksGUIPosUpdated )
			{
				baseGamePerksGUIPosUpdated = FixBaseGamePerksGUIPos();
			}
			if( !alchemy19OptimizationDone )
			{
				Alchemy19OptimizationRetro();
				alchemy19OptimizationDone = true;
			}
		}
		
		
		LoadMutationData();		

		isInitialized = true;
		
		return true;	
	}

	public function AddSkillPassiveBonusesForEquipped()
	{
		var i : int;
		var skill : ESkill;

		
		owner.RemoveAbilityAll('sword_adrenalinegain');
		owner.RemoveAbilityAll('magic_staminaregen');
		owner.RemoveAbilityAll('alchemy_potionduration');
		owner.RemoveAbilityAll('survival_vitality');

		for( i = 0; i < skills.Size(); i += 1 )
		{
			skill = skills[i].skillType;

			if (IsSkillEquipped(skill) && !IsCoreSkill(skill) && ( skills[i].isReworked || skills[i].isUnchangedLegacy ) )
			{
				
				if(GetSkillPathType(skill) == ESP_Sword)
				{
					owner.AddAbilityMultiple('sword_adrenalinegain', GetSkillLevel(skill) );
				}
		
				
				if(GetSkillPathType(skill) == ESP_Signs)
				{
					owner.AddAbilityMultiple('magic_staminaregen', GetSkillLevel(skill) );
				}
		
				
				if(GetSkillPathType(skill) == ESP_Alchemy)
				{
					owner.AddAbilityMultiple('alchemy_potionduration', GetSkillLevel(skill) );
				}

				
				if(GetSkillPathType(skill) == ESP_Perks)
				{
					owner.AddAbilityMultiple('survival_vitality', GetSkillLevel(skill) );
				}
			}
		}
	}
	
	private function FixMissingSkills() : bool
	{
		var i : int;
		var newSkills : array<SSkill>;
		var skillDefs : array<name>;
		var fixedSomething : bool;
		
		charStats.GetAbilitiesWithTag('SkillDefinitionName', skillDefs);
		LogAssert(skillDefs.Size()>0, "W3PlayerAbilityManager.Init: actor <<" + owner + ">> has no skills!!");
		fixedSomething = false;
		
		for( i = 0; i < skillDefs.Size(); i+=1 )
			CacheSkills(skillDefs[i], newSkills);	

		for(i=0; i<newSkills.Size(); i+=1)
		{
			
			if(i >= skills.Size())
			{
				skills.PushBack( newSkills[i] );
				fixedSomething = true;
				continue;
			}
	
			
			if(skills[i].skillType == S_SUndefined && newSkills[i].skillType != S_SUndefined)
			{
				skills[i] = newSkills[i];
				fixedSomething = true;
			}
		}
		
		return fixedSomething;
	}
	
	private final function FixBaseGamePerksGUIPos() : bool
	{
		var i, j, size, size2, tmpInt : int;
		var fixedSomething : bool;
		var dm : CDefinitionsManagerAccessor;
		var sks, main : SCustomNode;
		var skillType : ESkill;
		var tmpName : name;
		
		dm = theGame.GetDefinitionsManager();
		sks = dm.GetCustomDefinition('skills');
		
		
		size = sks.subNodes.Size();		
		for( i = 0; i < size; i += 1 )
		{
			if(dm.GetCustomNodeAttributeValueName(sks.subNodes[i], 'def_name', tmpName))
			{
				if(tmpName == 'GeraltSkills')
				{
					main = sks.subNodes[i];
					size2 = main.subNodes.Size();
					for( j = 0; j < size2; j += 1 )
					{
						dm.GetCustomNodeAttributeValueName(main.subNodes[j], 'skill_name', tmpName);
						skillType = SkillNameToEnum(tmpName);
						
						switch( skillType )
						{
							case S_Perk_01 :
							case S_Perk_02 :
							case S_Perk_03 :
							case S_Perk_04 :
							case S_Perk_05 :
							case S_Perk_06 :
							case S_Perk_07 :
							case S_Perk_08 :
							case S_Perk_09 :
							case S_Perk_10 :
							case S_Perk_11 :
							case S_Perk_12 :
								dm.GetCustomNodeAttributeValueInt(main.subNodes[j], 'guiPositionID', tmpInt);
								skills[ skillType ].positionID = tmpInt;
								fixedSomething = true;
						}
					}
					break;
				}
			}
		}
		
		return fixedSomething;
	}
	
	public function OnOwnerRevived()
	{
		var i : int;
		
		super.OnOwnerRevived();
		
		if(owner == GetWitcherPlayer())
			GetWitcherPlayer().RemoveTemporarySkills();
	}
	
	private final function PrecacheModifierSkills()
	{
		var i, j : int;
		var dm : CDefinitionsManagerAccessor;
		var skill : SSkill;
		var skillIT : int;
		
		dm = theGame.GetDefinitionsManager();
		if( !dm )
		{
			return;
		}
		
		for( skillIT = 0; skillIT < skills.Size(); skillIT += 1 )
		{
			
			
			for( i = 0; i < skills.Size(); i += 1 )
			{
				if( i != skillIT )
				{
					for( j = 0; j < skills[ skillIT ].modifierTags.Size(); j += 1)
					{
						
						if( dm.AbilityHasTag( skills[ i ].abilityName, skills[ skillIT ].modifierTags[ j ] ) )
						{
							skills[ skillIT ].precachedModifierSkills.PushBack( i );
						}
					}
				}
			}
		}
	}
	
	
	public final function PostInit()
	{		
		var i, used, free, mutationPoints, skillPoints : int;
	
		if(CanUseSkill(S_Sword_5))
			AddPassiveSkillBuff(S_Sword_5);
			
		
		if( (W3PlayerWitcher)owner )
		{
			
			
			
			used = GetWitcherPlayer().levelManager.GetPointsUsed(ESkillPoint);
			free = GetWitcherPlayer().levelManager.GetPointsFree(ESkillPoint);	
			mutationPoints = GetMutationsUsedSkillPoints();

			skillPoints = free + used + mutationPoints;
			
			for(i=0; i<skillSlots.Size(); i+=1)
			{
				if( skillSlots[ i ].groupID != MUTATION_SKILL_GROUP_ID )
				{
					skillSlots[i].unlocked = ( skillPoints >= skillSlots[i].unlockedOnLevel);
				}
			}
		}
		
		
		if( FactsQuerySum( "154531" ) <= 0 )
		{
			mutationUnlockedSlotsIndexes.Clear();
			FactsAdd( "154531" );
		}
		if( FactsQuerySum( "154975" ) <= 0 )
		{
			mutationUnlockedSlotsIndexes.Clear();
			FactsAdd( "154975" );
		}
		
		
		if( mutationUnlockedSlotsIndexes.Size() == 0 )
		{
			for( i=0; i<skillSlots.Size(); i+=1 )
			{
				if( skillSlots[ i ].groupID == MUTATION_SKILL_GROUP_ID )
				{
					mutationUnlockedSlotsIndexes.PushBack( i );
				}
			}
		}
		
		
		if( !mutationSkillSlotsInitialized && theGame.GetDLCManager().IsEP2Enabled() && theGame.GetDLCManager().IsEP2Available() )
		{
			UpdateMutationSkillSlots();
			mutationSkillSlotsInitialized = true;
		}
	}
	
	public final function GetPlayerSkills() : array<SSkill> 
	{
		return skills;
	}
	
	public final function AddTempNonAlchemySkills() : array<SSimpleSkill>
	{
		var i, cnt, j : int;
		var ret : array<SSimpleSkill>;
		var temp : SSimpleSkill;
	
		tempSkills.Clear();
	
		for(i=0; i<skills.Size(); i+=1)
		{
			if(skills[i].skillPath == ESP_Signs && skills[i].level < skills[i].maxLevel)
			{
				temp.skillType = skills[i].skillType;
				temp.level = skills[i].level;
				ret.PushBack(temp);
				
				tempSkills.PushBack(skills[i].skillType);
				
				cnt = skills[i].maxLevel - skills[i].level;
				for(j=0; j<cnt; j+=1)
					AddSkill(skills[i].skillType, true);
			}
		}
		
		return ret;
	}

	public final function AddIndividualSignSkillsTemporary() : array<SSimpleSkill>
	{
		var i, cnt, j : int;
		var ret : array<SSimpleSkill>;
		var temp : SSimpleSkill;
	
		tempSkills.Clear();

		for(i=0; i<skills.Size(); i+=1)
		{
			if(skills[i].skillType == S_Magic_s20 || skills[i].skillType == S_Magic_s08 || skills[i].skillType == S_Magic_s42 || skills[i].skillType == S_Magic_s13 || skills[i].skillType == S_Magic_s17 ||
			   skills[i].skillType == S_Magic_s01 || skills[i].skillType == S_Magic_s28 || skills[i].skillType == S_Magic_s03 || skills[i].skillType == S_Magic_s04 || skills[i].skillType == S_Magic_s31 ||
			   skills[i].skillType == S_Magic_s11 || skills[i].skillType == S_Magic_s33 || skills[i].skillType == S_Magic_s19)
			{
				temp.skillType = skills[i].skillType;
				temp.level = skills[i].level;
				ret.PushBack(temp);
				
				tempSkills.PushBack(skills[i].skillType);
				
				cnt = skills[i].maxLevel - skills[i].level;
				for(j=0; j<cnt; j+=1)
					AddSkill(skills[i].skillType, true);
			}
		}
		
		return ret;
	}

	public final function GetPlayerSkill(type : ESkill) : SSkill 
	{
		return skills[type];
	}
	
	
	private final function AddPassiveSkillBuff(skill : ESkill)
	{
		if(skill == S_Sword_5 && GetStat(BCS_Focus) >= 1)
			owner.AddEffectDefault(EET_BattleTrance, owner, "BattleTranceSkill");
	}

	private final function ReloadAcquiredSkills(out acquiredSkills : array<SRestoredSkill>)
	{
		var i, j : int;
		
		for(j=acquiredSkills.Size()-1; j>=0; j-=1)		
		{
			for(i=0; i<skills.Size(); i+=1)
			{
				if(skills[i].skillType == acquiredSkills[j].skillType)
				{
					skills[i].level = acquiredSkills[j].level;
					skills[i].isNew = acquiredSkills[j].isNew;
					skills[i].remainingBlockedTime = acquiredSkills[j].remainingBlockedTime;
					
					if(!skills[i].isCoreSkill)
						pathPointsSpent[skills[i].skillPath] = pathPointsSpent[skills[i].skillPath] + 1;
					
					acquiredSkills.Erase(j);
					
					break;
				}
			}
		}
	}
	
	
	
	
		
	
	protected final function OnFocusChanged()
	{
		var points : float;
		var buff : W3Effect_Toxicity;
		
		points = GetStat(BCS_Focus);
		
		if(points < 1 && owner.HasBuff(EET_BattleTrance))
		{
			owner.RemoveBuff(EET_BattleTrance);
		}
		else if(points >= 1 && !owner.HasBuff(EET_BattleTrance))
		{
			if(CanUseSkill(S_Sword_5))
				owner.AddEffectDefault(EET_BattleTrance, owner, "BattleTranceSkill");
		}
		
		if ( points >= owner.GetStatMax(BCS_Focus) && owner.HasAbility('Runeword 8 _Stats', true) && !owner.HasBuff(EET_Runeword8) )
		{
			owner.AddEffectDefault(EET_Runeword8, owner, "max focus");
		}
		
		
		if( points >= 1.f && GetWitcherPlayer().IsMutationActive( EPMT_Mutation5 ) && !owner.HasBuff( EET_Mutation5 ) && owner.IsInCombat() )
		{
			owner.AddEffectDefault( EET_Mutation5, owner, "", false );
		}
		else if( points < 1.f && GetWitcherPlayer().IsMutationActive( EPMT_Mutation5 ) )
		{
			owner.RemoveBuff( EET_Mutation5 );
		}

		
		thePlayer.OnFocusChanged();
	}
	
	
	protected final function OnVitalityChanged()
	{
		var vitPerc : float;
		
		vitPerc = GetStatPercents(BCS_Vitality);		
		
		if(vitPerc < theGame.params.LOW_HEALTH_EFFECT_SHOW && !owner.HasBuff(EET_LowHealth))
			owner.AddEffectDefault(EET_LowHealth, owner, 'vitality_change');
		else if(vitPerc >= theGame.params.LOW_HEALTH_EFFECT_SHOW && owner.HasBuff(EET_LowHealth))
			owner.RemoveBuff(EET_LowHealth);
			
		if(vitPerc < 1.f)
			ResetOverhealBonus();
	
		theTelemetry.SetCommonStatFlt(CS_VITALITY, GetStat(BCS_Vitality));
	}
	
	protected final function OnAirChanged()
	{
		if(GetStat(BCS_Air) > 0)
		{
			if ( owner.HasBuff(EET_Drowning) )
				owner.RemoveBuff(EET_Drowning);
				
			if( owner.HasBuff(EET_Choking) )
				owner.RemoveBuff(EET_Choking);
		}
	}
	
	
	protected final function OnToxicityChanged()
	{
		var tox : float;
		var enemies : array< CActor >;
	
		if( !((W3PlayerWitcher)owner) )
			return;
			
		tox = GetStat(BCS_Toxicity);
	
		
		if( tox == 0.f && owner.HasBuff( EET_Toxicity ) )
		{
			owner.RemoveBuff( EET_Toxicity );			
		}
		else if(tox > 0.f && !owner.HasBuff(EET_Toxicity))
		{
			owner.AddEffectDefault(EET_Toxicity,owner,'toxicity_change');
		}	
		
		
		if( tox == 0.f )
		{
			owner.RemoveBuff( EET_Mutation10 );
		}
		else if( (W3PlayerWitcher)owner && GetWitcherPlayer().IsMutationActive( EPMT_Mutation10 ) && !owner.HasBuff( EET_Mutation10 ) && owner.IsInCombat() )
		{
			enemies = GetWitcherPlayer().GetEnemies();
			
			
			if( enemies.Size() > 0 )
			{
				owner.AddEffectDefault( EET_Mutation10, NULL, "Mutation 10" );
			}
		}
			
		theTelemetry.SetCommonStatFlt(CS_TOXICITY, GetStat(BCS_Toxicity));
	}
	
	
	
	
	
	public final function GetPlayerSkillMutagens() : array<SMutagenSlot>
	{
		return mutagenSlots;
	}
	
	public final function GetSkillGroupIdOfMutagenSlot(eqSlot : EEquipmentSlots) : int
	{
		var i : int;
		
		i = GetMutagenSlotIndex(eqSlot);
		if(i<0)
			return -1;
			
		return mutagenSlots[i].skillGroupID;
	}
	
	
	public final function IsSkillMutagenSlotUnlocked( eqSlot : EEquipmentSlots ) : bool
	{
		var i, used, free, mutationPoints, skillPoints : int;

		used = GetWitcherPlayer().levelManager.GetPointsUsed(ESkillPoint);
		free = GetWitcherPlayer().levelManager.GetPointsFree(ESkillPoint);	
		mutationPoints = GetMutationsUsedSkillPoints();

		skillPoints = free + used + mutationPoints;
		
		i = GetMutagenSlotIndex( eqSlot );
		if( i<0 )
		{
			return false;
		}
		
		
		
		return skillPoints >= mutagenSlots[ i ].unlockedAtLevel;
	}
	
	private final function GetMutagenSlotForGroupId(groupID : int) : EEquipmentSlots
	{
		var i : int;
		
		for(i=0; i<mutagenSlots.Size(); i+=1)
		{
			if(mutagenSlots[i].skillGroupID == groupID)
			{
				return mutagenSlots[i].equipmentSlot;
			}
		}
		
		return EES_InvalidSlot;
	}
	
	public final function GetSkillGroupsCount() : int
	{
		return mutagenSlots.Size();
	}
	
	public final function GetSkillGroupIDFromIndex(idx : int) : int
	{
		if(idx >= 0 && idx <mutagenSlots.Size())
			return mutagenSlots[idx].skillGroupID;
			
		return -1;
	}
	
	
	private final function GetMutagenSlotIndex(eqSlot : EEquipmentSlots) : int
	{
		var i : int;
		
		for(i=0; i<mutagenSlots.Size(); i+=1)
			if(mutagenSlots[i].equipmentSlot == eqSlot)
				return i;
				
		return -1;
	}
	
	
	private final function GetMutagenSlotIndexFromItemId(item : SItemUniqueId) : int
	{
		var i : int;
		
		for(i=0; i<mutagenSlots.Size(); i+=1)
			if(mutagenSlots[i].item == item)
				return i;
				
		return -1;
	}	
	
	public final function OnSkillMutagenEquipped(item : SItemUniqueId, slot : EEquipmentSlots, prevColor : ESkillColor)
	{
		var i, skillLevelSynergyFromAlchemy, skillLevelSynergyFromPerks : int;
		var tutState : W3TutorialManagerUIHandlerStateCharDevMutagens;
		
		i = GetMutagenSlotIndex(slot);
		if(i<0)
			return;
		
		mutagenSlots[i].item = item;
		
		
		if(CanUseSkill(S_Alchemy_s19) || CanUseSkill(S_Perk_43))
		{
			skillLevelSynergyFromAlchemy = GetSkillLevel( S_Alchemy_s19);
			skillLevelSynergyFromPerks = GetSkillLevel( S_Perk_43);
			if (skillLevelSynergyFromAlchemy > skillLevelSynergyFromPerks)
			{
				MutagensSyngergyBonusUpdate( mutagenSlots[i].skillGroupID, skillLevelSynergyFromAlchemy );
			}
			else
			{
				MutagensSyngergyBonusUpdate( mutagenSlots[i].skillGroupID, skillLevelSynergyFromPerks );
			}
		}
		
		
		if(ShouldProcessTutorial('TutorialCharDevMutagens'))
		{
			tutState = (W3TutorialManagerUIHandlerStateCharDevMutagens)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
			if(tutState)
			{
				tutState.EquippedMutagen(slot);
			}
		}
		
		theTelemetry.LogWithValueStr(TE_HERO_MUTAGEN_USED, owner.GetInventory().GetItemName( item ) );
		
		
		theGame.GetGamerProfile().CheckTrialOfGrasses();
		
		thePlayer.inv.SetItemStackable( item, false );
	}
	
	public final function OnSkillMutagenUnequipped( out item : SItemUniqueId, slot : EEquipmentSlots, prevColor : ESkillColor, optional dontMerge : bool )
	{
		var i, skillLevelSynergyFromAlchemy, skillLevelSynergyFromPerks : int;
		var ids : array< SItemUniqueId >;
		var itemName : name;
		
		i = GetMutagenSlotIndex(slot);
		if(i<0)
			return;
		
		
		if(CanUseSkill(S_Alchemy_s19) || CanUseSkill(S_Perk_43))
		{
			skillLevelSynergyFromAlchemy = GetSkillLevel( S_Alchemy_s19);
			skillLevelSynergyFromPerks = GetSkillLevel( S_Perk_43);
			if (skillLevelSynergyFromAlchemy > skillLevelSynergyFromPerks)
			{
				MutagensSyngergyBonusUpdate( mutagenSlots[i].skillGroupID, skillLevelSynergyFromAlchemy );
			}
			else
			{
				MutagensSyngergyBonusUpdate( mutagenSlots[i].skillGroupID, skillLevelSynergyFromPerks );
			}
		}
		
		mutagenSlots[i].item = GetInvalidUniqueId();

		theGame.GetGuiManager().IgnoreNewItemNotifications( true );
		
		
		
		if (!dontMerge)
		{
			itemName = thePlayer.inv.GetItemName( item );
			thePlayer.inv.RemoveItem( item );
			ids = thePlayer.inv.AddAnItem( itemName, 1, true, true );
			item = ids[0];
		}
		
		theGame.GetGuiManager().IgnoreNewItemNotifications( false );
	}
	
	
	public final function OnSwappedMutagensPost(a : SItemUniqueId, b : SItemUniqueId)
	{
		var oldSlotIndexA, oldSlotIndexB : int;
	
		oldSlotIndexA = GetMutagenSlotIndexFromItemId(a);
		oldSlotIndexB = GetMutagenSlotIndexFromItemId(b);
		
		mutagenSlots[oldSlotIndexA].item = b;
		mutagenSlots[oldSlotIndexB].item = a;
	}
	
	private final function Alchemy19OptimizationRetro()
	{
		var i, skillLevelSynergyFromAlchemy, skillLevelSynergyFromPerks : int;
		var mutagenItemID : SItemUniqueId;
		
		
		for( i=0; i<mutagenSlots.Size(); i+=1 )
		{
			mutagenItemID = GetMutagenItemIDFromGroupID( mutagenSlots[i].skillGroupID );		
			if( owner.GetInventory().IsIdValid( mutagenItemID ) )
			{			
				owner.RemoveAbilityAll( GetMutagenBonusAbilityName( mutagenItemID ) );
			}
		}
			
		
		
		mutagenBonuses.Resize( GetSkillGroupsCount() + 5 );
		
		
		if( CanUseSkill( S_Alchemy_s19 ) || CanUseSkill(S_Perk_43) )
		{
			skillLevelSynergyFromAlchemy = GetSkillLevel( S_Alchemy_s19);
			skillLevelSynergyFromPerks = GetSkillLevel( S_Perk_43);
			if ( skillLevelSynergyFromAlchemy > skillLevelSynergyFromPerks )
			{
				MutagensSyngergyBonusUpdate( -1, skillLevelSynergyFromAlchemy );
			}
			else
			{
				MutagensSyngergyBonusUpdate( -1, skillLevelSynergyFromPerks );
			}
		}
	}
	
	
	
	private final function MutagensSyngergyBonusUpdate( skillGroupID : int, skillLevel : int )
	{
		var i : int;

		if( skillGroupID != -1 )
		{
			if (IsMutagenRare(GetMutagenItemIDFromGroupID( skillGroupID )))
			{
				MutagensSyngergyBonusUpdateMultiple( skillGroupID, skillLevel );
			}
			else
				MutagensSyngergyBonusUpdateSingle( skillGroupID, skillLevel );
		}
		else
		{
			for( i=0; i<mutagenSlots.Size(); i+=1 )
			{
				if (IsMutagenRare(GetMutagenItemIDFromGroupID( mutagenSlots[i].skillGroupID )))
				{
					MutagensSyngergyBonusUpdateMultiple( mutagenSlots[i].skillGroupID, skillLevel );
				}
				else
					MutagensSyngergyBonusUpdateSingle( mutagenSlots[i].skillGroupID, skillLevel );
			}
		}
	}
	
	
	private final function MutagensSyngergyBonusUpdateSingle( skillGroupID : int, skillLevel : int )
	{
		var current : SMutagenBonusAlchemy19;
		var color : ESkillColor;
		var mutagenItemID : SItemUniqueId;
		var delta : int;
		
		if( skillGroupID < 0 )
		{
			return;
		}
		
		
		mutagenItemID = GetMutagenItemIDFromGroupID( skillGroupID );
		
		if( owner.GetInventory().IsIdValid( mutagenItemID ) )
		{	
			current.abilityName = GetMutagenBonusAbilityName( mutagenItemID );
			
			if( skillLevel > 0 )
			{
				color = owner.GetInventory().GetSkillMutagenColor( mutagenItemID );
				
				current.count = skillLevel * ( GetSkillGroupColorCount(color, skillGroupID) + 1 ); 
			}
		}
		
		
		if( current.abilityName != mutagenBonuses[skillGroupID].abilityName )
		{
			
			if( IsNameValid( mutagenBonuses[skillGroupID].abilityName ) && mutagenBonuses[skillGroupID].count > 0 )
			{
				owner.RemoveAbilityMultiple( mutagenBonuses[skillGroupID].abilityName, mutagenBonuses[skillGroupID].count );
			}
			
			
			if( IsNameValid( current.abilityName ) && current.count > 0 )
			{
				owner.AddAbilityMultiple( current.abilityName, current.count );
			}
		}
		
		else if( IsNameValid( current.abilityName ) )
		{
			
			delta = current.count - mutagenBonuses[skillGroupID].count;
			
			if( delta > 0 )
			{
				owner.AddAbilityMultiple( current.abilityName, delta );
			}
			else if( delta < 0 )
			{
				owner.RemoveAbilityMultiple( current.abilityName, -delta );
			}
		}
		
		
		mutagenBonuses[skillGroupID] = current;
	}

	
	private final function MutagensSyngergyBonusUpdateMultiple( skillGroupID : int, skillLevel : int )
	{
		var bonusA : SMutagenBonusAlchemy19;
		var bonusB : SMutagenBonusAlchemy19;
		var skillGroupIDB : int;
		var mutagenBonusesNames : array<name>;
		var color : ESkillColor;
		var mutagenItemID : SItemUniqueId;
		var delta : int;
		
		
		skillGroupIDB = skillGroupID + 4;

		if( skillGroupID < 0 )
		{
			return;
		}
		
		
		mutagenItemID = GetMutagenItemIDFromGroupID( skillGroupID );
		
		if( owner.GetInventory().IsIdValid( mutagenItemID ) )
		{	
			
			mutagenBonusesNames = GetMutagenBonusAbilityNames( mutagenItemID );
			bonusA.abilityName = mutagenBonusesNames[0];
			bonusB.abilityName = mutagenBonusesNames[1];
			
			if( skillLevel > 0 )
			{
				color = owner.GetInventory().GetSkillMutagenColor( mutagenItemID );
				bonusA.count = skillLevel * ( GetSkillGroupColorCount(color, skillGroupID) + 1 );
				bonusB.count = skillLevel * ( GetSkillGroupColorCount(color, skillGroupIDB) + 1 );
			}
		}
		

		
		
		if( bonusA.abilityName != mutagenBonuses[skillGroupID].abilityName )
		{
			
			if( IsNameValid( mutagenBonuses[skillGroupID].abilityName ) && mutagenBonuses[skillGroupID].count > 0 )
			{
				owner.RemoveAbilityMultiple( mutagenBonuses[skillGroupID].abilityName, mutagenBonuses[skillGroupID].count );
			}
			
			
			if( IsNameValid( bonusA.abilityName ) && bonusA.count > 0 )
			{
				owner.AddAbilityMultiple( bonusA.abilityName, bonusA.count );
			}
		}
		
		else if( IsNameValid( bonusA.abilityName ) )
		{
			
			delta = bonusA.count - mutagenBonuses[skillGroupID].count;
			
			if( delta > 0 )
			{
				owner.AddAbilityMultiple( bonusA.abilityName, delta );
			}
			else if( delta < 0 )
			{
				owner.RemoveAbilityMultiple( bonusA.abilityName, -delta );
			}
		}
		
		
		mutagenBonuses[skillGroupID] = bonusA;


		
		
		if( bonusB.abilityName != mutagenBonuses[skillGroupIDB].abilityName )
		{
			
			if( IsNameValid( mutagenBonuses[skillGroupIDB].abilityName ) && mutagenBonuses[skillGroupIDB].count > 0 )
			{
				owner.RemoveAbilityMultiple( mutagenBonuses[skillGroupIDB].abilityName, mutagenBonuses[skillGroupIDB].count );
			}
			
			
			if( IsNameValid( bonusB.abilityName ) && bonusB.count > 0 )
			{
				owner.AddAbilityMultiple( bonusB.abilityName, bonusB.count );
			}
		}
		
		else if( IsNameValid( bonusB.abilityName ) )
		{
			
			delta = bonusB.count - mutagenBonuses[skillGroupIDB].count;
			
			if( delta > 0 )
			{
				owner.AddAbilityMultiple( bonusB.abilityName, delta );
			}
			else if( delta < 0 )
			{
				owner.RemoveAbilityMultiple( bonusB.abilityName, -delta );
			}
		}
		
		
		mutagenBonuses[skillGroupIDB] = bonusB;
	}
		
	
	public final function GetMutagenBonusAbilityName( mutagenItemId : SItemUniqueId ) : name
	{
		var i : int;
		var abs : array<name>;
		owner.GetInventory().GetItemContainedAbilities(mutagenItemId, abs);
		
		for(i=0; i<abs.Size(); i+=1)
		{
			if(theGame.GetDefinitionsManager().AbilityHasTag(abs[i], 'alchemy_s19') || theGame.GetDefinitionsManager().AbilityHasTag(abs[i], 'perk_43'))
				return abs[i];
		}
		return '';
	}

	
	public final function GetMutagenBonusAbilityNames( mutagenItemId : SItemUniqueId ) : array<name>
	{
		var i : int;
		var abs : array<name>;
		var bonusAbilities : array<name>;

		owner.GetInventory().GetItemContainedAbilities(mutagenItemId, abs);
		
		for(i=0; i<abs.Size(); i+=1)
		{
			if(theGame.GetDefinitionsManager().AbilityHasTag(abs[i], 'alchemy_s19') || theGame.GetDefinitionsManager().AbilityHasTag(abs[i], 'perk_43'))
				bonusAbilities.PushBack(abs[i]);
		}

		return bonusAbilities;
	}

	
	public final function GetRareMutagenConnectionsCount(mutagenItemId : SItemUniqueId, optional out leftCount : int, optional out rightCount : int)
	{
		var leftColorCount : int;
		var rightColorcount : int;
		var color : ESkillColor;
		var mutagenSlotID 	: int;
		var groupID : int;
		
		color = owner.GetInventory().GetSkillMutagenColor(mutagenItemId);
		mutagenSlotID = GetMutagenSlotIndexFromItemId(mutagenItemId);
		groupID = mutagenSlots[mutagenSlotID].skillGroupID;
		if (color == SC_RedGreen)
		{
			leftColorCount = GetSkillGroupColorCount(SC_Red, groupID);
			rightColorcount = GetSkillGroupColorCount(SC_Green, groupID);
		}
		else if (color == SC_RedBlue)
		{
			leftColorCount = GetSkillGroupColorCount(SC_Red, groupID);
			rightColorcount = GetSkillGroupColorCount(SC_Blue, groupID);
		}
		else if (color == SC_BlueGreen)
		{
			leftColorCount = GetSkillGroupColorCount(SC_Blue, groupID);
			rightColorcount = GetSkillGroupColorCount(SC_Green, groupID);
		}
		else if (color == SC_RedWhite)
		{
			leftColorCount = GetSkillGroupColorCount(SC_Red, groupID);
			rightColorcount = GetSkillGroupColorCount(SC_Yellow, groupID);
		}
		else if (color == SC_BlueWhite)
		{
			leftColorCount = GetSkillGroupColorCount(SC_Blue, groupID);
			rightColorcount = GetSkillGroupColorCount(SC_Yellow, groupID);
		}
		else if (color == SC_GreenWhite)
		{
			leftColorCount = GetSkillGroupColorCount(SC_Green, groupID);
			rightColorcount = GetSkillGroupColorCount(SC_Yellow, groupID);
		}
		
		leftCount = leftColorCount;
		rightCount = rightColorcount;
	}
	public final function IsMutagenRare(mutagenItemId : SItemUniqueId) : bool
	{
		var color : ESkillColor;
		color = owner.GetInventory().GetSkillMutagenColor(mutagenItemId);
		
		return (color == SC_RedGreen || color == SC_RedBlue || color == SC_BlueGreen || color == SC_BlueWhite || color == SC_RedWhite || color == SC_GreenWhite);
	}
	
	
	
	
	
	public final function GetSkillGroupIdFromSkill( skillType : ESkill ) : int
	{
		var i : int;
		
		for(i=0; i<skillSlots.Size(); i+=1)
		{
			if(skillSlots[i].socketedSkill == skillType)
			{
				return skillSlots[i].groupID;
			}
		}
		
		return -1;
	}
	
	public final function GetSkillGroupIdFromSkillSlotId(skillSlotId : int) : int
	{
		var i : int;
		
		for(i=0; i<skillSlots.Size(); i+=1)
		{
			if(skillSlots[i].id == skillSlotId)
			{
				return skillSlots[i].groupID;
			}
		}
		
		return -1;
	}
	
	public final function GetMutagenItemIDFromGroupID( skillGroupID : int ) : SItemUniqueId
	{
		var i : int;
		
		for( i=0; i<mutagenSlots.Size(); i+=1 )
		{
			if( mutagenSlots[i].skillGroupID == skillGroupID )
			{
				return mutagenSlots[i].item;
			}
		}
		
		return GetInvalidUniqueId();
	}
	
	public function GetMutagenSlotIDFromGroupID(groupID : int) : int
	{
		return GetMutagenSlotForGroupId(groupID);
	}
	
	public final function GetGroupBonus(groupID : int) : name
	{
		var groupColor : ESkillColor;
		var item : SItemUniqueId;
		
		groupColor = GetSkillGroupColor(groupID);
		
		
		
		switch (groupColor)
		{
			case SC_None: return '';
			case SC_Blue: return LINK_BONUS_BLUE;
			case SC_Green: return LINK_BONUS_GREEN;
			case SC_Red: return LINK_BONUS_RED;
		}
	}

	
	public final function GetSkillGroupColor(groupID : int) : ESkillColor
	{
		var i : int;
		var commonColor : ESkillColor;
		var mutagenSlot : EEquipmentSlots;
		var skillColors : array<ESkillColor>;
		var item : SItemUniqueId;
		
		
		for(i=0; i<skillSlots.Size(); i+=1)
		{
			if(skillSlots[i].unlocked && skillSlots[i].groupID == groupID)
			{
				skillColors.PushBack(GetSkillColor(skillSlots[i].socketedSkill));
			}
		}
		
		
		commonColor = SC_None;
		for(i=0; i<skillColors.Size(); i+=1)
		{
			if(skillColors[i] != SC_None && skillColors[i] != SC_Yellow)	
			{
				if(commonColor == SC_None)
				{
					commonColor = skillColors[i];
				}
				else if(skillColors[i] != commonColor)
				{
					
					commonColor = SC_None;
					break;
				}
			}
		}
		
		
		if(commonColor == SC_None)
			return SC_None;
			
		
		mutagenSlot = GetMutagenSlotForGroupId(groupID);
		if(IsSkillMutagenSlotUnlocked(mutagenSlot))
		{
			if(GetWitcherPlayer().GetItemEquippedOnSlot(mutagenSlot, item))
				return owner.GetInventory().GetSkillMutagenColor( item );
		}
		
		return commonColor;
	}
	
	
	public final function GetSkillGroupColorCount(commonColor : ESkillColor, groupID : int) : ESkillColor
	{
		var count, i : int;
		var mutagenSlot : EEquipmentSlots;
		var skillColors : array<ESkillColor>;
		var item : SItemUniqueId;
		
		
		for(i=0; i<skillSlots.Size(); i+=1)
		{
			if(skillSlots[i].unlocked && skillSlots[i].groupID == groupID && skillSlots[i].socketedSkill != S_SUndefined )
			{
				skillColors.PushBack(GetSkillColor(skillSlots[i].socketedSkill));
			}
		}
		
		
		count = 0;
		for(i=0; i<skillColors.Size(); i+=1)
		{
			if(skillColors[i] == commonColor )	
			{
				count = count + 1;
			}
		}
		
		return count;
	}
	
	
	private final function LinkUpdate(newColor : ESkillColor, prevColor : ESkillColor)
	{
		
		if(newColor == prevColor)
			return;
		
		
		UpdateLinkBonus(prevColor, false);
		UpdateLinkBonus(newColor, true);
	}
	
	
	private final function UpdateLinkBonus(a : ESkillColor, added : bool)
	{	
		return;
		if(added)
		{
			if(a == SC_Blue)
				charStats.AddAbility(LINK_BONUS_BLUE, true);
			else if(a == SC_Green)
				charStats.AddAbility(LINK_BONUS_GREEN, true);
			else if(a == SC_Red)
				charStats.AddAbility(LINK_BONUS_RED, true);
		}
		else
		{
			if(a == SC_Blue)
				charStats.RemoveAbility(LINK_BONUS_BLUE);
			else if(a == SC_Green)
				charStats.RemoveAbility(LINK_BONUS_GREEN);
			else if(a == SC_Red)
				charStats.RemoveAbility(LINK_BONUS_RED);
		}
	}
	
	public final function GetSkillColor(skill : ESkill) : ESkillColor
	{
		switch(skills[skill].skillPath)
		{
			case ESP_Sword :		return SC_Red;
			case ESP_Signs :		return SC_Blue;
			case ESP_Alchemy : 		return SC_Green;
			case ESP_Perks :        return SC_Yellow;
			default :				return SC_None;
		}
	}
	
	
	
	
	
	
	
	public final function GetSkillLevel(skill : ESkill) : int
	{
		return skills[skill].level;
	}
	
	public final function GetBoughtSkillLevel(skill : ESkill) : int
	{
		return skills[skill].level;
	}
	
	public final function GetSkillMaxLevel(skill : ESkill) : int
	{
		return skills[skill].maxLevel;
	}
	
	public final function GetSkillStaminaUseCost(skill : ESkill, optional isPerSec : bool) : float
	{
		var reductionCounter : int;
		var ability, attributeName : name;
		var ret, costReduction : SAbilityAttributeValue;
	
		ability = '';
		
		
		if(CanUseSkill(skill))
			ability = GetSkillAbilityName(skill);
		
		if(isPerSec)
			attributeName = theGame.params.STAMINA_COST_PER_SEC_DEFAULT;
		else 
			attributeName = theGame.params.STAMINA_COST_DEFAULT;
		
		ret = GetSkillAttributeValue(ability, attributeName, true, true);
		
		
		reductionCounter = GetSkillLevel(skill) - 1;
		if(reductionCounter > 0)
		{
			costReduction = GetSkillAttributeValue(ability, 'stamina_cost_reduction_after_1', false, false) * reductionCounter;
			ret -= costReduction;
		}
		
		return CalculateAttributeValue(ret);
	}
	
	public final function GetSkillAttributeValue(abilityName: name, attributeName : name, addBaseCharAttribute : bool, addSkillModsAttribute : bool) : SAbilityAttributeValue
	{
		
		var min, max, ret : SAbilityAttributeValue;
		var i, j : int;
		var dm : CDefinitionsManagerAccessor;
		var skill : SSkill;
		var skillEnum : ESkill;
		var skillLevel : int;
	
		
		ret = super.GetSkillAttributeValue(abilityName, attributeName, addBaseCharAttribute, addSkillModsAttribute);
				
		
		if(addSkillModsAttribute)
		{
			
			
			skillEnum = SkillNameToEnum( abilityName );
			if( skillEnum != S_SUndefined )
			{
				skill = skills[skillEnum];
			}
			else
			{
				LogAssert(false, "W3PlayerAbilityManager.GetSkillAttributeValue: cannot find skill for ability <<" + abilityName + ">>! Aborting");
				return min;
			}
			
			dm = theGame.GetDefinitionsManager();
			
			for( j = 0; j < skill.precachedModifierSkills.Size(); j += 1 )
			{
				i = skill.precachedModifierSkills[ j ];
			
				if( CanUseSkill( skills[i].skillType ) )
				{
					dm.GetAbilityAttributeValue(skills[i].abilityName, attributeName, min, max);

					skillLevel = GetSkillLevel(i);
					ret += GetAttributeRandomizedValue( min * skillLevel, max * skillLevel );
				}
			}
		}
		
		
		if(addBaseCharAttribute)
		{
			ret += GetAttributeValueInternal(attributeName);
		}
		
		return ret;
	}
	
	protected final function GetStaminaActionCostInternal(action : EStaminaActionType, isPerSec : bool, out cost : SAbilityAttributeValue, out delay : SAbilityAttributeValue, optional abilityName : name)
	{
		var attributeName : name;
		var skill : ESkill;
		var blizzard : W3Potion_Blizzard;
		
		
		var deny : bool;
		var toxicityThreshold : float;
		
	
		super.GetStaminaActionCostInternal(action, isPerSec, cost, delay, abilityName);
		
		if(isPerSec)
		{
			attributeName = theGame.params.STAMINA_COST_PER_SEC_DEFAULT;
		}
		else
		{
			attributeName = theGame.params.STAMINA_COST_DEFAULT;
		}
		
		if(action == ESAT_LightAttack && CanUseSkill(S_Sword_1) )
			cost += GetSkillAttributeValue(SkillEnumToName(S_Sword_1), attributeName, false, true);
		else if(action == ESAT_HeavyAttack && CanUseSkill(S_Sword_2) )
			cost += GetSkillAttributeValue(SkillEnumToName(S_Sword_2), attributeName, false, true);
		else if ((action == ESAT_Sprint || action == ESAT_Jump) && thePlayer.HasBuff(EET_Mutagen24) && !thePlayer.IsInCombat())
		{
			cost.valueAdditive = 0;
			cost.valueBase = 0;
			cost.valueMultiplicative = 0;
		}
		

		
		if ( CanUseSkill( S_Alchemy_s03 ) )
		{
			toxicityThreshold = thePlayer.GetStatMax(BCS_Toxicity) * GetWitcherPlayer().GetAlchemyS03Threshold();
			if ( thePlayer.GetStat(BCS_Toxicity, true) > toxicityThreshold && GetWitcherPlayer().IsMutationActive( EPMT_Mutation7 ) )
			{
				deny = true;
			}
		}
		
		
		
		if( !deny && thePlayer.HasBuff( EET_Blizzard ) && owner == GetWitcherPlayer() && GetWitcherPlayer().GetPotionBuffLevel( EET_Blizzard ) == 3 && GetWitcherPlayer().GetStat( BCS_Focus ) >= 3 && thePlayer.HasBuff( EET_BattleTrance ) )
		
		{
			blizzard = ( W3Potion_Blizzard )thePlayer.GetBuff( EET_Blizzard );
			if( blizzard.IsSlowMoActive() )
			{
				cost.valueAdditive = 0;
				cost.valueBase = 0;
				cost.valueMultiplicative = 0;
			}
		}
	}
		
	
	
	
	protected final function GetNonBlockedSkillAbilitiesList( optional tags : array<name> ) : array<name>
	{
		var i, j : int;
		var ret : array<name>;
		var dm : CDefinitionsManagerAccessor;
		var abilityName : name;
		
		if(tags.Size() == 0)
			return ret;
	
		dm = theGame.GetDefinitionsManager();
		for(i=0; i<skillAbilities.Size(); i+=1)		
		{
			abilityName = skillAbilities[i];
			
			for(j=0; j<tags.Size(); j+=1)
			{
				if(dm.AbilityHasTag(abilityName, tags[j]))
				{
					ret.PushBack(abilityName);
				}
			}
		}
		
		return ret;
	}
	
	public final function IsSkillBlocked(skill : ESkill) : bool
	{
		return skills[skill].remainingBlockedTime != 0;
	}
	
	
	public final function BlockSkill(skill : ESkill, block : bool, optional cooldown : float) : bool
	{
		var i : int;
		var min : float;
	
		if(block)
		{
			if(skills[skill].remainingBlockedTime == -1 || (cooldown > 0 && cooldown <= skills[skill].remainingBlockedTime) )
				return false;	
			
			
			if(cooldown > 0)
				skills[skill].remainingBlockedTime = cooldown;
			else
				skills[skill].remainingBlockedTime = -1;
				
			
			min = 1000000;
			for(i=0; i<skills.Size(); i+=1)
			{
				if(skills[i].remainingBlockedTime > 0)
				{
					min = MinF(min, skills[i].remainingBlockedTime);
				}
			}
			
			
			if(min != 1000000)
				GetWitcherPlayer().AddTimer('CheckBlockedSkills', min, , , , true);
			
			
			if(theGame.GetDefinitionsManager().IsAbilityDefined(skills[skill].abilityName) && charStats.HasAbility(skills[skill].abilityName))
				BlockAbility(GetSkillAbilityName(skill), block, cooldown);
			
			if(IsSkillEquipped(skill))
				OnSkillUnequip(skill);
			
			return true;
		}
		else
		{
			if(skills[skill].remainingBlockedTime == 0)
				return false;		
		
			skills[skill].remainingBlockedTime = 0;
			
			if(theGame.GetDefinitionsManager().IsAbilityDefined(skills[skill].abilityName) && charStats.HasAbility(skills[skill].abilityName))
				BlockAbility(GetSkillAbilityName(skill), false);
			
			if(IsSkillEquipped(skill))
				OnSkillEquip(skill);
				
			return true;
		}
	}
	
	
	
	public final function CheckBlockedSkills(dt : float) : float
	{
		var i : int;
		var cooldown, min : float;
		
		min = 1000000;
		for(i=0; i<skills.Size(); i+=1)
		{
			if(skills[i].remainingBlockedTime > 0)
			{
				skills[i].remainingBlockedTime = MaxF(0, skills[i].remainingBlockedTime - dt);
				
				if(skills[i].remainingBlockedTime == 0)
				{
					BlockSkill(skills[i].skillType, false);
				}
				else
				{
					min = MinF(min, skills[i].remainingBlockedTime);
				}
			}
		}
		
		if(min == 1000000)
			min = -1;
			
		return min;
	}
	
	
	public final function BlockAbility(abilityName : name, block : bool, optional cooldown : float) : bool
	{
		var i : int;
	
		if( super.BlockAbility(abilityName, block, cooldown))
		{
			
			if(block)
			{
				skillAbilities.Remove(abilityName);
			}
			else
			{
				
				for(i=0; i<skills.Size(); i+=1)
				{	
					if(skills[i].abilityName == abilityName)
					{
						if(!theGame.GetDefinitionsManager().AbilityHasTag(skills[i].abilityName, theGame.params.SKILL_GLOBAL_PASSIVE_TAG))
							skillAbilities.PushBack(abilityName);
							
						break;
					}
				}
			}
			
			return true;			
		}
		
		return false;
	}
		
	
	protected final function InitSkills()
	{
		var atts : array<name>;
		var i, size : int;
		var skillEnum : ESkill;
		
		charStats.GetAllContainedAbilities(atts);
		size = atts.Size();
		for( i = 0; i < size; i += 1 )
		{
			skillEnum = SkillNameToEnum( atts[i] );
			if( skillEnum != S_SUndefined )
			{
				if( !IsAbilityBlocked( atts[i] ) )
				{
					AddSkillInternal( skillEnum, false, false, true );
				}
				continue;
			}
		}
	}
	
	protected final function IsCoreSkill(skill : ESkill) : bool
	{
		return skills[skill].isCoreSkill;
	}

	protected final function IsReworked(skill : ESkill) : bool
	{
		return skills[skill].isReworked;
	}

	protected final function IsUnchangedLegacy(skill : ESkill) : bool
	{
		return skills[skill].isUnchangedLegacy;
	}

	protected final function GetGridRow(skill : ESkill) : float
	{
		return skills[skill].gridRow;
	}

	protected final function GetGridColumn(skill : ESkill) : float
	{
		return skills[skill].gridColumn;
	}
	
	
	protected final function CacheSkills(skillDefinitionName : name, out cache : array<SSkill>)
	{
		var dm : CDefinitionsManagerAccessor;
		var main, sks : SCustomNode;
		var i, size, size2, j : int;
		var skillType : ESkill;
		var bFound : bool;
		var tmpName : name;
		var skillDefs : array<name>;
		
		dm = theGame.GetDefinitionsManager();
		sks = dm.GetCustomDefinition('skills');
		
		
		bFound = false;
		size = sks.subNodes.Size();		
		cache.Clear();
		cache.Resize( S_Perk_MAX );
		for( i = 0; i < size; i += 1 )
		{
			if(dm.GetCustomNodeAttributeValueName(sks.subNodes[i], 'def_name', tmpName))
			{
				if(tmpName == skillDefinitionName)
				{
					bFound = true;
					main = sks.subNodes[i];
					
					
					size2 = main.subNodes.Size();
					for( j = 0; j < size2; j += 1 )
					{
						dm.GetCustomNodeAttributeValueName(main.subNodes[j], 'skill_name', tmpName);
						skillType = SkillNameToEnum(tmpName);
						
						if( skillType != S_SUndefined )
						{
							if( cache[skillType].skillType == skillType )
							{
								LogChannel('Skills', "W3AbilityManager.CacheSkills: actor's <<" + this + ">> skill <<" + skillType + ">> is already defined!!! Skipping!!!");
								continue;
							}
							
							CacheSkill( skillType, tmpName, main.subNodes[j], cache[skillType] );
						}
						else
						{
							LogAssert(false, "W3PlayerAbilityManager.CacheSkills: skill <<" + tmpName + ">> is not defined in PST enum, ignoring skill!");
						}
					}
				}
			}
		}
		
		if( !bFound )
		{
			LogAssert(false, "W3AbilityManager.CacheSkills: cannot find skill definition named <<" + skillDefinitionName + ">> aborting!");
		}
	}
	
	private final function CacheSkill( skillType : int, abilityName : name, definitionNode : SCustomNode, out skill : SSkill )
	{
		var dm : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var modifiers, reqSkills : SCustomNode;
		var pathType : ESkillPath;
		var subpathType : ESkillSubPath;
		var tmpName : name;
		var tmpInt, k, size : int;
		var tmpString : string;
		var tmpBool : bool;
		
		skill.wasEquippedOnUIEnter = false;
		skill.level = 0;
		
		
		skill.skillType = skillType;
		skill.abilityName = abilityName;
		
		
		if(dm.GetCustomNodeAttributeValueName(definitionNode, 'pathType_name', tmpName))
		{
			pathType = SkillPathNameToType(tmpName);
			if(pathType != ESP_NotSet)
				skill.skillPath = pathType;
			else if(skill.skillType != S_Perk_08)	
				LogAssert(false, "W3PlayerAbilityManager.CacheSkill: skill <<" + skill.skillType + ">> has wrong path type set <<" + tmpName + ">>");
		}
		
		
		if(dm.GetCustomNodeAttributeValueName(definitionNode, 'subpathType_name', tmpName))
		{
			subpathType = SkillSubPathNameToType(tmpName);
			if(subpathType != ESSP_NotSet)
				skill.skillSubPath = subpathType;
			else if(skill.skillType != S_Perk_08)	
				LogAssert(false, "W3PlayerAbilityManager.CacheSkill: skill <<" + skill.skillType + ">> has wrong subpath type set <<" + tmpName + ">>");
		}
		
		
		reqSkills = dm.GetCustomDefinitionSubNode(definitionNode,'required_skills');
		if(reqSkills.values.Size() > 0)
		{
			size = reqSkills.values.Size();
			for(k=0; k<size; k+=1)
			{
				if(IsNameValid(reqSkills.values[k]))
				{
					skill.requiredSkills.PushBack(SkillNameToEnum(reqSkills.values[k]));
				}
			}
		}
		
		
		if(dm.GetCustomNodeAttributeValueBool(definitionNode, 'isAlternative', tmpBool))
			skill.requiredSkillsIsAlternative = tmpBool;
		
		
		if(dm.GetCustomNodeAttributeValueInt(definitionNode, 'priority', tmpInt))
			skill.priority = tmpInt;
		
		
		if(dm.GetCustomNodeAttributeValueInt(definitionNode, 'requiredPointsSpent', tmpInt))
			skill.requiredPointsSpent = tmpInt;
		
		
		if(dm.GetCustomNodeAttributeValueString(definitionNode, 'localisationName', tmpString))
			skill.localisationNameKey = tmpString;
		if(dm.GetCustomNodeAttributeValueString(definitionNode, 'localisationDescription', tmpString))
			skill.localisationDescriptionKey = tmpString;
		if(dm.GetCustomNodeAttributeValueString(definitionNode, 'localisationDescriptionLevel2', tmpString))
			skill.localisationDescriptionLevel2Key = tmpString;
		if(dm.GetCustomNodeAttributeValueString(definitionNode, 'localisationDescriptionLevel3', tmpString))
			skill.localisationDescriptionLevel3Key = tmpString;
			
		
		if(dm.GetCustomNodeAttributeValueInt(definitionNode, 'cost', tmpInt))
			skill.cost = tmpInt;
			
		
		if(dm.GetCustomNodeAttributeValueInt(definitionNode, 'maxLevel', tmpInt))
			skill.maxLevel = tmpInt;
		else
			skill.maxLevel = 1;
			
		
		if(dm.GetCustomNodeAttributeValueBool(definitionNode, 'isCoreSkill', tmpBool))
			skill.isCoreSkill = tmpBool;

		
		if(dm.GetCustomNodeAttributeValueBool(definitionNode, 'isReworked', tmpBool))
			skill.isReworked = tmpBool;

		
		if(dm.GetCustomNodeAttributeValueBool(definitionNode, 'isUnchangedLegacy', tmpBool))
			skill.isUnchangedLegacy = tmpBool;

		if(dm.GetCustomNodeAttributeValueInt(definitionNode, 'gridRow', tmpInt))
			skill.gridRow = tmpInt;

		if(dm.GetCustomNodeAttributeValueInt(definitionNode, 'gridColumn', tmpInt))
			skill.gridColumn = tmpInt;
			
		
		if(dm.GetCustomNodeAttributeValueInt(definitionNode, 'guiPositionID', tmpInt))
			skill.positionID = tmpInt;
	
		
		modifiers = dm.GetCustomDefinitionSubNode(definitionNode,'modifier_tags');
		if(modifiers.values.Size() > 0)
		{
			size = modifiers.values.Size();
			for(k=0; k<size; k+=1)
			{
				if(IsNameValid(modifiers.values[k]))
				{
					skill.modifierTags.PushBack(modifiers.values[k]);
				}
			}
		}
		
		
		if(dm.GetCustomNodeAttributeValueString(definitionNode, 'iconPath', tmpString))
			skill.iconPath = tmpString;

		if(dm.GetCustomNodeAttributeValueString(definitionNode, 'iconPathTest', tmpString))
			skill.iconPathTest = tmpString;
			
		
		
	}
	
	private final function LoadMutagenSlotsDataFromXML()
	{		
		var mut : SCustomNode;
		var i : int;
		var mutagen : SMutagenSlot;
		var dm : CDefinitionsManagerAccessor;
	
		
		dm = theGame.GetDefinitionsManager();
		mut = dm.GetCustomDefinition('mutagen_slots');		
		
		for(i=0; i<mut.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueInt(mut.subNodes[i], 'skillGroup', mutagen.skillGroupID);
			dm.GetCustomNodeAttributeValueInt(mut.subNodes[i], 'unlockedAtLevel', mutagen.unlockedAtLevel);
			
			mutagen.item = GetInvalidUniqueId();
			mutagen.equipmentSlot = EES_SkillMutagen1 + i;
			
			if(mutagen.equipmentSlot > EES_SkillMutagen4)
			{
				LogAssert(false, "W3PlayerAbilityManager.LoadMutagenSlotsDataFromXML: too many slots defined in XML!!! Aborting");
				return;
			}
		
			mutagenSlots.PushBack(mutagen);
		}
	}
	
	
	
	public final function AddSkill(skill : ESkill, isTemporary : bool)
	{
		var i : int;
		var doneSkl, countInTree  : int;
		var learnedAll, ret : bool;
		var tree : ESkillPath;
		var uiStateCharDev : W3TutorialManagerUIHandlerStateCharacterDevelopment;
		var uiStateSpecialAttacks : W3TutorialManagerUIHandlerStateSpecialAttacks;
	
		ret = AddSkillInternal(skill, true, isTemporary);
		
		if(!ret)
			return;
			
		
		doneSkl = 0;
		countInTree = 0;
		if( !isTemporary )
		{
			learnedAll = true;
			tree = GetSkillPathType(skill);
			for(i=0; i<skills.Size(); i+=1)
			{
				if( skills[i].skillPath == tree && (skills[i].isUnchangedLegacy || skills[i].isReworked))
				{
					countInTree+=1;
					if (skills[i].level == 0 || skills[i].isTemporary )
					{
						learnedAll = false;
					}
					else
					{
						doneSkl+=1;
					}
				}
			}
			
			if(learnedAll) 
			{
				theGame.GetGamerProfile().AddAchievement(EA_Dendrology);
			}
			else
			{
				theGame.GetGamerProfile().NoticeAchievementProgress(EA_Dendrology, doneSkl, countInTree);
			}
		}
		
		
		if(ShouldProcessTutorial('TutorialCharDevBuySkill'))
		{
			uiStateCharDev = (W3TutorialManagerUIHandlerStateCharacterDevelopment)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
			if(uiStateCharDev)
			{
				uiStateCharDev.OnBoughtSkill(skill);
			}
		}
		if(ShouldProcessTutorial('TutorialSpecialAttacks') || ShouldProcessTutorial('TutorialAlternateSigns'))
		{
			uiStateSpecialAttacks = (W3TutorialManagerUIHandlerStateSpecialAttacks)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
			if(uiStateSpecialAttacks)
				uiStateSpecialAttacks.OnBoughtSkill(skill);
		}
	}
	
	protected final function AddSkillInternal(skill : ESkill, spendPoints : bool, isTemporary : bool, optional skipTutorialMessages : bool) : bool
	{
		if(skill == S_SUndefined )
		{
			LogAssert(false,"W3AbilityManager.AddSkill: trying to add undefined skill, aborting!");
			return false;
		}	
		if(HasLearnedSkill(skill) && skills[skill].level >= skills[skill].maxLevel)
		{
			LogAssert(false,"W3AbilityManager.AddSkill: trying to add skill already known <<" + SkillEnumToName(skill) + ">>, aborting!");
			return false;
		}
		
		
		skills[skill].level += 1;
		skills[skill].isTemporary = isTemporary;
		
		
		if(!skills[skill].isCoreSkill)
			pathPointsSpent[skills[skill].skillPath] = pathPointsSpent[skills[skill].skillPath] + 1;
		
		if(!isTemporary)
		{
			LogSkills("Skill <<" + skills[skill].abilityName + ">> learned");
			
			if(spendPoints)
				((W3PlayerWitcher)owner).levelManager.SpendPoints(ESkillPoint, skills[skill].cost);
			if ( this.IsSkillEquipped(skill) )
				OnSkillEquippedLevelChange(skill, GetSkillLevel(skill) - 1, GetSkillLevel(skill));
			theTelemetry.LogWithValueStr(TE_HERO_SKILL_UP, SkillEnumToName(skill));
		}
		
		return true;
	}	
		
	
	
	public final function RemoveTemporarySkill(skill : SSimpleSkill) : bool
	{
		var ind : int;
		
		LogAssert( skill.skillType >= S_SUndefined, "W3AbilityManager.RemoveTemporarySkill: trying to remove undefined skill" );
		
		if(!skills[skill.skillType].isCoreSkill)
			pathPointsSpent[skills[skill.skillType].skillPath] = pathPointsSpent[skills[skill.skillType].skillPath] - (skills[skill.skillType].level - skill.level);
			
		skills[skill.skillType].level = skill.level;
		
		if(skills[skill.skillType].level < 1)
		{
			ind = GetSkillSlotID(skill.skillType);
			if(ind >= 0)
				UnequipSkill(ind);
		}
		
		tempSkills.Remove(skill.skillType);
		GetWitcherPlayer().SetFloodOfAngerSucceeded(false);
		return true;
	}
		
	public final function HasLearnedSkill(skill : ESkill) : bool
	{
		return skills[skill].level > 0;
	}
	
	private final function GetSkillFromAbilityName(abilityName : name) : ESkill
	{
		var i : int;
		
		for(i=0; i<skills.Size(); i+=1)
			if(skills[i].abilityName == abilityName)
				return skills[i].skillType;
				
		return S_SUndefined;
	}
	
	public final function CanLearnSkill(skill : ESkill) : bool
	{
		var j : int;
		var hasSomeRequiredSkill : bool;
		
		
		if(skill == S_SUndefined)
			return false;

		
		if(skills[skill].isCoreSkill)
			return false;
		
		
		if(skills[skill].level >= skills[skill].maxLevel)
			return false;
			
		
		if(skills[skill].isReworked || skills[skill].isUnchangedLegacy)
		{
			if(skills[skill].requiredSkills.Size() > 0)
			{
				if(skills[skill].requiredSkillsIsAlternative)
					hasSomeRequiredSkill = false;
				else
					hasSomeRequiredSkill = true;

				for(j=0; j<skills[skill].requiredSkills.Size(); j+=1)
				{
					if(skills[skill].requiredSkillsIsAlternative)
					{
						if(HasLearnedSkill(skills[skill].requiredSkills[j]))
						{
							hasSomeRequiredSkill = true;
							break;
						}
					}
					else if(!HasLearnedSkill(skills[skill].requiredSkills[j]))
					{
						return false;	
					}
				}

				if(!hasSomeRequiredSkill)
					return false;		
			}
		}
		
		
		if (!skills[skill].isReworked && !skills[skill].isUnchangedLegacy)
		{
			if(skills[skill].requiredPointsSpent > 0 && pathPointsSpent[skills[skill].skillPath] < skills[skill].requiredPointsSpent)
				return false;
		}
			
		
		if(((W3PlayerWitcher)owner).levelManager.GetPointsFree(ESkillPoint) < skills[skill].cost)
			return false;
			
		
		return true;
	}

	public final function IsSkillUnlockedByDependency(skill : ESkill) : bool
	{
		var j : int;
		var hasSomeRequiredSkill : bool;

		
		if(skills[skill].isReworked || skills[skill].isUnchangedLegacy)
		{
			if(skills[skill].requiredSkills.Size() > 0)
			{
				if(skills[skill].requiredSkillsIsAlternative)
					hasSomeRequiredSkill = false;
				else
					hasSomeRequiredSkill = true;

				for(j=0; j<skills[skill].requiredSkills.Size(); j+=1)
				{
					if(skills[skill].requiredSkillsIsAlternative)
					{
						if(HasLearnedSkill(skills[skill].requiredSkills[j]))
						{
							hasSomeRequiredSkill = true;
							break;
						}
					}
					else if(!HasLearnedSkill(skills[skill].requiredSkills[j]))
					{
						return false;	
					}
				}

				if(!hasSomeRequiredSkill)
					return false;		
			}
		}

		
		return true;
	}
	
	public final function HasSpentEnoughPoints(skill : ESkill) : bool 
	{
		if (skills[skill].requiredPointsSpent > 0 && pathPointsSpent[skills[skill].skillPath] < skills[skill].requiredPointsSpent)
		{
			return false;
		}
	
		return true;
	}
	
	public final function GetPathPointsSpent(skillPath : ESkillPath) : int
	{
		return pathPointsSpent[skillPath];
	}
	
	public final function PathPointsSpentInSkillPathOfSkill(skill : ESkill) : int 
	{
		return pathPointsSpent[skills[skill].skillPath];
	}
	
	
	public final function GetSkillAbilityName(skill : ESkill) : name
	{
		return skills[skill].abilityName;
	}

	public final function GetSkillLocalisationKeyName(skill : ESkill) : string 
	{
		return skills[skill].localisationNameKey;
	}

	public final function GetSkillLocalisationKeyDescription(skill : ESkill, optional level : int) : string 
	{
		switch (level)
		{
			case 2:
				return skills[skill].localisationDescriptionLevel2Key;
			case 3: 
				return skills[skill].localisationDescriptionLevel3Key;
			case 4: 
				return skills[skill].localisationDescriptionLevel3Key;
			case 5: 
				return skills[skill].localisationDescriptionLevel3Key;
			default:
				return skills[skill].localisationDescriptionKey;
		}
	}

	public final function GetSkillIconPath(skill : ESkill) : string 
	{
		return skills[skill].iconPath;
	}
	
	public final function GetSkillSubPathType(skill : ESkill) : ESkillSubPath
	{
		return skills[skill].skillSubPath;
	}
	
	public final function GetSkillPathType(skill : ESkill) : ESkillPath
	{
		return skills[skill].skillPath;
	}
	
	
	
	
	
	protected function GetItemResistStatIndex( slot : EEquipmentSlots, stat : ECharacterDefenseStats ) : int
	{
		var i, size : int;
		size = resistStatsItems[slot].Size();
		for ( i = 0; i < size; i+=1 )
		{
			if ( resistStatsItems[slot][i].type == stat )
			{
				return i;
			}
		}				
		return -1;
	}
	
	
	
	protected final function RecalcResistStat(stat : ECharacterDefenseStats)
	{		
		var witcher : W3PlayerWitcher;
		var item : SItemUniqueId;
		var slot, idxItems : int;
		var itemResists : array<ECharacterDefenseStats>;
		var resistStat : SResistanceValue;

		
		super.RecalcResistStat(stat);
		
		
		witcher = (W3PlayerWitcher)owner;
		if(!witcher)
			return;

		GetResistStat( stat, resistStat );
		
		for(slot=0; slot < resistStatsItems.Size(); slot+=1)
		{
			
			if( witcher.GetItemEquippedOnSlot(slot, item) && witcher.inv.HasItemDurability(item))
			{
				itemResists = witcher.inv.GetItemResistanceTypes(item);
				
				if(itemResists.Contains(stat))
				{			
					
					resistStat.points.valueBase -= CalculateAttributeValue(witcher.inv.GetItemAttributeValue(item, ResistStatEnumToName(stat, true)));
					resistStat.percents.valueBase -= CalculateAttributeValue(witcher.inv.GetItemAttributeValue(item, ResistStatEnumToName(stat, false)));

					
					SetItemResistStat(slot, stat);

					
					idxItems = GetItemResistStatIndex( slot, stat );
					if(idxItems >= 0)
					{
						resistStat.percents.valueBase += CalculateAttributeValue(resistStatsItems[slot][idxItems].percents);
						resistStat.points.valueBase   += CalculateAttributeValue(resistStatsItems[slot][idxItems].points);
					}
				}
			}
		}
		
		SetResistStat( stat, resistStat );
	}
	
	
	private final function SetItemResistStat(slot : EEquipmentSlots, stat : ECharacterDefenseStats)
	{
		var item : SItemUniqueId;
		var tempResist : SResistanceValue;
		var witcher : W3PlayerWitcher;
		var i : int;
		
		witcher = (W3PlayerWitcher)owner;
		if(!witcher)
			return;
			
		
		i = GetItemResistStatIndex( slot, stat );
		
		
		if( witcher.GetItemEquippedOnSlot(slot, item) && witcher.inv.HasItemDurability(item) )
		{
			
			if(i >= 0)
			{
				
				witcher.inv.GetItemResistStatWithDurabilityModifiers(item, stat, resistStatsItems[slot][i].points, resistStatsItems[slot][i].percents);
			}
			else
			{
				
				witcher.inv.GetItemResistStatWithDurabilityModifiers(item, stat, tempResist.points, tempResist.percents);
				tempResist.type = stat;
				resistStatsItems[slot].PushBack(tempResist);
			}			
		}
		else if(i >= 0)
		{
			
			resistStatsItems[slot].Erase(i);
		}
	}
		
	
	public final function RecalcItemResistDurability(slot : EEquipmentSlots, itemId : SItemUniqueId)
	{
		var i : int;
		var witcher : W3PlayerWitcher;
		var itemResists : array<ECharacterDefenseStats>;
	
		witcher = (W3PlayerWitcher)owner;
		if(!witcher)
			return;
			
		itemResists = witcher.inv.GetItemResistanceTypes(itemId);
		for(i=0; i<itemResists.Size(); i+=1)
		{
			if(itemResists[i] != CDS_None)
			{
				RecalcResistStatFromItem(itemResists[i], slot);
			}
		}
	}
	
	
	private final function RecalcResistStatFromItem(stat : ECharacterDefenseStats, slot : EEquipmentSlots)
	{
		var deltaResist, prevCachedResist : SResistanceValue;
		var idx : int;
		var resistStat : SResistanceValue;
		
		idx = GetItemResistStatIndex( slot, stat );
		prevCachedResist = resistStatsItems[slot][idx];
						
		
		SetItemResistStat(slot, stat);
		
		
		deltaResist.points = resistStatsItems[slot][idx].points - prevCachedResist.points;
		deltaResist.percents = resistStatsItems[slot][idx].percents - prevCachedResist.percents;
		
		
		if ( GetResistStat( stat, resistStat ) )
		{
			resistStat.percents += deltaResist.percents;
			resistStat.points += deltaResist.points;
			SetResistStat( stat, resistStat );
		}
	}
		
	
	
	
	
	public final function DrainStamina(action : EStaminaActionType, optional fixedCost : float, optional fixedDelay : float, optional abilityName : name, optional dt : float, optional costMult : float) : float
	{	
		var cost : float;
		var mutagen : W3Mutagen21_Effect;
		var min, max : SAbilityAttributeValue;
		var signEntity : W3SignEntity;
		
		if(FactsDoesExist("debug_fact_stamina_boy"))
			return 0;
			
		cost = super.DrainStamina(action, fixedCost, fixedDelay, abilityName, dt, costMult);
		
		if(cost > 0 && dt > 0)
		{
			
			owner.AddTimer('AbilityManager_FloorStaminaSegment', 0.1, , , , true);
		}
		
		
		if (cost > 0 && dt <= 0 && owner == thePlayer && thePlayer.HasBuff(EET_Mutagen21) && abilityName != 'sword_s1' && abilityName != 'sword_s2')
		{	
			mutagen = (W3Mutagen21_Effect)thePlayer.GetBuff(EET_Mutagen21);
			mutagen.Heal();
		}
		
		
		
		if(owner == GetWitcherPlayer() && GetStat(BCS_Stamina, true) <= 0.f)
		{
			signEntity = GetWitcherPlayer().GetSignEntity(GetWitcherPlayer().GetCurrentlyCastSign());
			
			
			if( !( ( W3QuenEntity ) signEntity ) || !owner.HasBuff( EET_Mutation11Buff ) )
			{
				signEntity.OnSignAborted(true);
			}
		}
		
		return cost;
	}
	
	public function GainStat( stat : EBaseCharacterStats, amount : float )
	{
		
		if(stat == BCS_Focus && owner.HasBuff(EET_Runeword8))
			return;
			
		super.GainStat(stat, amount);
	}
	
	
	public final function FloorStaminaSegment()
	{
		
		
	}
	
	
	public final function GetStat(stat : EBaseCharacterStats, optional skipLock : bool) : float	
	{
		var value, lock : float;
		var i : int;
	
		value = super.GetStat(stat, skipLock);
		
		if(stat == BCS_Toxicity && !skipLock && toxicityOffset > 0)
		{
			value += toxicityOffset;
		}
		
		return value;
	}
	
	public final function AddToxicityOffset(val : float)
	{
		if(val > 0)
			toxicityOffset += val;
	}
	
	public final function SetToxicityOffset( val : float)
	{
		if(val >= 0)
			toxicityOffset = val;
	}
		
	public final function RemoveToxicityOffset(val : float)
	{
		if(val > 0)
			toxicityOffset -= val;
		
		if (toxicityOffset < 0)
			toxicityOffset = 0;
	}
	
	
	public final function GetOffenseStat():int
	{
		var steelDmg, silverDmg : float;
		var steelCritChance, steelCritDmg : float;
		var silverCritChance, silverCritDmg : float;
		var attackPower	: SAbilityAttributeValue;
		var item : SItemUniqueId;
		var value : SAbilityAttributeValue;
		
		
		if (CanUseSkill(S_Sword_s04))
			attackPower += GetSkillAttributeValue(SkillEnumToName(S_Sword_s04), PowerStatEnumToName(CPS_AttackPower), false, true) * GetSkillLevel(S_Sword_s04);
		if (CanUseSkill(S_Sword_s21))
			attackPower += GetSkillAttributeValue(SkillEnumToName(S_Sword_s21), PowerStatEnumToName(CPS_AttackPower), false, true) * GetSkillLevel(S_Sword_s21); 
		attackPower = attackPower * 0.5;
		
		
		if (CanUseSkill(S_Sword_s08)) 
		{
			steelCritChance += CalculateAttributeValue(GetSkillAttributeValue(SkillEnumToName(S_Sword_s08), theGame.params.CRITICAL_HIT_CHANCE, false, true)) * GetSkillLevel(S_Sword_s08);
			steelCritDmg += CalculateAttributeValue(GetSkillAttributeValue(SkillEnumToName(S_Sword_s08), theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true)) * GetSkillLevel(S_Sword_s08);
		}
		if (CanUseSkill(S_Sword_s17)) 
		{
			steelCritChance += CalculateAttributeValue(GetSkillAttributeValue(SkillEnumToName(S_Sword_s17), theGame.params.CRITICAL_HIT_CHANCE, false, true)) * GetSkillLevel(S_Sword_s17);
			steelCritDmg += CalculateAttributeValue(GetSkillAttributeValue(SkillEnumToName(S_Sword_s17), theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true)) * GetSkillLevel(S_Sword_s17);
		}
		steelCritChance /= 2;
		steelCritDmg /= 2;
		silverCritChance = steelCritChance;
		silverCritDmg = steelCritDmg;
		
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
		{
			value = thePlayer.GetInventory().GetItemAttributeValue(item, theGame.params.DAMAGE_NAME_SLASHING);
			steelDmg += value.valueBase;
			steelCritChance += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_CHANCE));
			steelCritDmg += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
		}
		else
		{
			steelDmg += 0;
			steelCritChance += 0;
			steelCritDmg +=0;
		}
		
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
		{
			value = thePlayer.GetInventory().GetItemAttributeValue(item, theGame.params.DAMAGE_NAME_SILVER);
			silverDmg += value.valueBase;
			silverCritChance += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_CHANCE));
			silverCritDmg += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
		}
		else
		{
			silverDmg += 0;
			silverCritChance += 0;
			silverCritDmg +=0;
		}
		
		steelCritChance += CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue(theGame.params.CRITICAL_HIT_CHANCE));
		silverCritChance += CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue(theGame.params.CRITICAL_HIT_CHANCE));
		steelCritDmg += CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue(theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
		silverCritDmg += CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue(theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
		attackPower += GetWitcherPlayer().GetPowerStatValue(CPS_AttackPower);
		
		steelCritChance *= 100;
		silverCritChance *= 100;
		steelDmg = steelDmg * (100 - steelCritChance) + steelDmg * (1 + steelCritDmg) * steelCritChance;
		steelDmg *= attackPower.valueMultiplicative;
		steelDmg /= 100;
		silverDmg = silverDmg * (100 - silverCritChance) + silverDmg * (1 + silverCritDmg) * silverCritChance;
		silverDmg *= attackPower.valueMultiplicative;
		silverDmg /= 100;
		return RoundMath((steelDmg + silverDmg)/2);
	}
	
	
	public final function GetDefenseStat():int
	{
		var valArmor : SAbilityAttributeValue;
		var valResists : float;
		var fVal1, fVal2 : float;
		
		valArmor = thePlayer.GetTotalArmor();
		thePlayer.GetResistValue(CDS_SlashingRes, fVal1, fVal2);
		valResists += fVal2;
		thePlayer.GetResistValue(CDS_PiercingRes, fVal1, fVal2);
		valResists += fVal2;
		thePlayer.GetResistValue(CDS_BludgeoningRes, fVal1, fVal2);
		valResists += fVal2;
		thePlayer.GetResistValue(CDS_RendingRes, fVal1, fVal2);
		valResists += fVal2;
		thePlayer.GetResistValue(CDS_ElementalRes, fVal1, fVal2);
		valResists += fVal2;
		
		valResists = valResists / 5;
		
		fVal1 = 100 - valArmor.valueBase;
		fVal1 *= valResists;
		fVal1 += valArmor.valueBase;
		
		return RoundMath(fVal1);
	}
	
	
	public final function GetSignsStat():float
	{
		var sp : SAbilityAttributeValue;
		
		sp += thePlayer.GetSkillAttributeValue(S_Magic_1, PowerStatEnumToName(CPS_SpellPower), true, true);
		sp += thePlayer.GetSkillAttributeValue(S_Magic_2, PowerStatEnumToName(CPS_SpellPower), true, true);
		sp += thePlayer.GetSkillAttributeValue(S_Magic_3, PowerStatEnumToName(CPS_SpellPower), true, true);
		sp += thePlayer.GetSkillAttributeValue(S_Magic_4, PowerStatEnumToName(CPS_SpellPower), true, true);
		sp += thePlayer.GetSkillAttributeValue(S_Magic_5, PowerStatEnumToName(CPS_SpellPower), true, true);
		sp.valueMultiplicative /= 5;
		
		return sp.valueMultiplicative;
	}
		
	
	
	
	
	event OnLevelGained(currentLevel : int)
	{
		UpdateSkillSlots();
	}

	
	public function UpdateSkillSlots()
	{
		var i, used, free, mutationPoints, skillPoints : int;

		used = GetWitcherPlayer().levelManager.GetPointsUsed(ESkillPoint);
		free = GetWitcherPlayer().levelManager.GetPointsFree(ESkillPoint);	
		mutationPoints = GetMutationsUsedSkillPoints();

		skillPoints = free + used + mutationPoints;

		for(i=0; i<skillSlots.Size(); i+=1)
		{
			if(skillPoints >= skillSlots[i].unlockedOnLevel)
				skillSlots[i].unlocked = true;
		}
	}

	public function RemasterSkillSlotReset()
	{
		var i, used, free, mutationPoints, skillPoints : int;
		var skill : ESkill;

		used = GetWitcherPlayer().levelManager.GetPointsUsed(ESkillPoint);
		free = GetWitcherPlayer().levelManager.GetPointsFree(ESkillPoint);	
		mutationPoints = GetMutationsUsedSkillPoints();

		skillPoints = free + used + mutationPoints;

		for(i=0; i<skillSlots.Size(); i+=1)
		{
			if (skillSlots[i].socketedSkill != S_SUndefined)
			{
				skill = skillSlots[i].socketedSkill;
				skillSlots[i].socketedSkill = S_SUndefined;
				OnSkillUnequip(skill);
			}
			if( skillSlots[ i ].groupID != MUTATION_SKILL_GROUP_ID )
			{
				skillSlots[i].unlocked = skillSlots[i].unlockedOnLevel <= skillPoints;
			}
		}
		for(i=0; i<mutagenSlots.Size(); i+=1)
		{
			if (mutagenSlots[i].item != GetInvalidUniqueId())
			{
				GetWitcherPlayer().UnequipItemFromSlot(mutagenSlots[i].equipmentSlot);
			}
		}

		UpdateMutationSkillSlotsLocks();
	}
	
	
	private final function InitSkillSlots( isFromLoad : bool )
	{
		var slot : SSkillSlot;
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var i, j : int;
		var inGame : bool;
		var xmlSlots : array< SSkillSlot >;
	
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition( 'skill_slots' );
		
		for( i=0; i<main.subNodes.Size(); i+=1 )
		{
			if( !dm.GetCustomNodeAttributeValueInt( main.subNodes[ i ], 'id', slot.id ) )			
			{
				LogAssert( false, "W3PlayerAbilityManager.InitSkillSlots: slot definition is not valid!" );
				continue;
			}
						
			if( !dm.GetCustomNodeAttributeValueInt( main.subNodes[ i ], 'unlockedOnLevel', slot.unlockedOnLevel ) )
			{
				slot.unlockedOnLevel = 0;
			}
			
			if( !dm.GetCustomNodeAttributeValueInt( main.subNodes[ i ], 'group', slot.groupID ) )
			{
				slot.groupID = -1;
			}
	
			
			totalSkillSlotsCount = Max( totalSkillSlotsCount, slot.id );
			LogChannel( 'CHR', "Init W3PlayerAbilityManager, totalSkillSlotsCount " + totalSkillSlotsCount );
			xmlSlots.PushBack( slot );
			
			slot.id = -1;
			slot.unlockedOnLevel = 0;
			slot.groupID = -1;
		}
		
		if( !isFromLoad )
		{
			
			skillSlots = xmlSlots;
		}
		else
		{
			
			for( i=0; i<xmlSlots.Size(); i+=1 )
			{
				
				inGame = false;
				for( j=0; j<skillSlots.Size(); j+=1 )
				{
					if( xmlSlots[ i ].id == skillSlots[ j ].id )
					{
						inGame = true;
						break;
					}
				}
				
				
				if( !inGame )
				{
					skillSlots.PushBack( xmlSlots[ i ] );
				}
			}
		}
	}
	
	
	public final function GetSkillSlotID(skill : ESkill) : int
	{
		var i : int;
		
		if(skill == S_SUndefined)
			return -1;
		
		for(i=0; i<skillSlots.Size(); i+=1)
		{
			if(skillSlots[i].socketedSkill == skill)
			{
				if(skillSlots[i].unlocked)
					return skillSlots[i].id;
				else
					return -1;
			}
		}
		
		return -1;
	}
	
	public final function GetSkillSlotIDFromIndex(skillSlotIndex : int) : int
	{
		if(skillSlotIndex >= 0 && skillSlotIndex < skillSlots.Size())
			return skillSlots[skillSlotIndex].id;
			
		return -1;
	}
	
	
	public final function GetSkillSlotIndex(slotID : int, checkIfUnlocked : bool) : int
	{
		var i : int;
		
		for(i=0; i<skillSlots.Size(); i+=1)
		{
			if(skillSlots[i].id == slotID)
			{
				if(!checkIfUnlocked)
					return i;
				
				if(skillSlots[i].unlocked)
					return i;
				else
					return -1;
			}
		}
		
		return -1;
	}
		
	public final function GetSkillSlotIndexFromSkill(skill : ESkill) : int
	{
		var i : int;
	
		for(i=0; i<skillSlots.Size(); i+=1)
			if(skillSlots[i].socketedSkill == skill)
				return i;
				
		return -1;
	}
	
	
	public final function EquipSkill(skill : ESkill, slotID : int) : bool
	{
		var idx : int;
		var prevColor : ESkillColor;
		
		if(!HasLearnedSkill(skill) || IsCoreSkill(skill))
			return false;
			
		idx = GetSkillSlotIndex(slotID, true);		
		
		if(idx < 0)
			return false;
		
		prevColor = GetSkillGroupColor(skillSlots[idx].groupID);
		
		UnequipSkill(slotID);
	
		skillSlots[idx].socketedSkill = skill;
		
		OnSkillEquip(skill);
		
		return true;
	}
	
	
	public final function UnequipSkill(slotID : int) : bool
	{
		var idx : int;
		var prevColor : ESkillColor;
		var skill : ESkill;
	
		idx = GetSkillSlotIndex(slotID, true);
		if(idx < 0)
			return false;
		
		
		skill = skillSlots[idx].socketedSkill;	
		if( skill == S_SUndefined )
		{
			return false;
		}
		
		
		skillSlots[idx].socketedSkill = S_SUndefined;
		prevColor = GetSkillGroupColor(skillSlots[idx].groupID);
		OnSkillUnequip(skill);
		
		return true;
	}
	
	
	private final function OnSkillEquip(skill : ESkill)
	{
		var skillName : name;
		var names, abs : array<name>;
		var buff : W3Effect_Toxicity;
		var witcher : W3PlayerWitcher;
		var i, skillLevel, skillLevelSynergyFromAlchemy, skillLevelSynergyFromPerks : int;
		var isPassive, isNight : bool;
		var m_alchemyManager : W3AlchemyManager;
		var recipe : SAlchemyRecipe;
		var uiState : W3TutorialManagerUIHandlerStateCharacterDevelopment;
		var battleTrance : W3Effect_BattleTrance;
		var mutagens : array<CBaseGameplayEffect>;
		var trophy : SItemUniqueId;
		var horseManager : W3HorseManager;
		var weapon, armor : W3RepairObjectEnhancement;
		var foodBuff : W3Effect_WellFed;
		var shrineBuffs : array<CBaseGameplayEffect>;
		var shrineTimeLeft, highestShrineTime : float;
		var shrineEffectIndex : int;
		var hud : CR4ScriptedHud;
		
		
		if(IsCoreSkill(skill))
			return;
		
		witcher = GetWitcherPlayer();
	
		
		AddPassiveSkillBuff(skill);
		
		
		isPassive = theGame.GetDefinitionsManager().AbilityHasTag(skills[skill].abilityName, theGame.params.SKILL_GLOBAL_PASSIVE_TAG);
		
		for( i = 0; i < GetSkillLevel(skill); i += 1 )
		{
			if(isPassive)
				owner.AddAbility(skills[skill].abilityName, true);
			else
				skillAbilities.PushBack(skills[skill].abilityName);
		}
		
		
		if(GetSkillPathType(skill) == ESP_Sword)
		{
			owner.AddAbilityMultiple('sword_adrenalinegain', GetSkillLevel(skill) );
		}
		
		
		if(GetSkillPathType(skill) == ESP_Signs)
		{
			owner.AddAbilityMultiple('magic_staminaregen', GetSkillLevel(skill) );
		}
		
		
		if(GetSkillPathType(skill) == ESP_Alchemy)
		{
			owner.AddAbilityMultiple('alchemy_potionduration', GetSkillLevel(skill) );
		}

		
		if(GetSkillPathType(skill) == ESP_Perks)
		{
			owner.AddAbilityMultiple('survival_vitality', GetSkillLevel(skill) );
		}
		
		
		if ( CanUseSkill(S_Alchemy_s19) || CanUseSkill(S_Perk_43) )
		{
			skillLevelSynergyFromAlchemy = GetSkillLevel( S_Alchemy_s19);
			skillLevelSynergyFromPerks = GetSkillLevel( S_Perk_43);
			if ( skillLevelSynergyFromAlchemy > skillLevelSynergyFromPerks )
			{
				MutagensSyngergyBonusUpdate( GetSkillGroupIdFromSkill( skill ), skillLevelSynergyFromAlchemy );
			}
			else
			{
				MutagensSyngergyBonusUpdate( GetSkillGroupIdFromSkill( skill ), skillLevelSynergyFromPerks );
			}
		}
		else if(skill == S_Alchemy_s20)
		{
			if ( GetWitcherPlayer().GetStatPercents(BCS_Toxicity) >= GetWitcherPlayer().GetToxicityDamageThreshold() )
				owner.AddEffectDefault(EET_IgnorePain, owner, 'IgnorePain');
		}
		
		if(skill == S_Alchemy_s18)
		{
			m_alchemyManager = new W3AlchemyManager in this;
			m_alchemyManager.Init();
			names = witcher.GetAlchemyRecipes();
			skillName = SkillEnumToName(S_Alchemy_s18);
			for(i=0; i<names.Size(); i+=1)
			{
				m_alchemyManager.GetRecipe(names[i], recipe);
				if ((recipe.cookedItemType != EACIT_Bolt) && (recipe.cookedItemType != EACIT_Undefined) && (recipe.cookedItemType != EACIT_Dye) && (recipe.level <= GetSkillLevel(S_Alchemy_s18)))
					charStats.AddAbility(skillName, true);
			}
		}
		else if(skill == S_Alchemy_s15 && owner.HasBuff(EET_Toxicity))
		{
			buff = (W3Effect_Toxicity)owner.GetBuff(EET_Toxicity);
			buff.RecalcEffectValue();
		}
		else if(skill == S_Alchemy_s13)
		{
			mutagens = GetWitcherPlayer().GetDrunkMutagens();
			if(mutagens.Size() > 0)	
			{
				charStats.AddAbilityMultiple( GetSkillAbilityName( skill ), (GetSkillLevel( skill ) * mutagens.Size() ));
			}
		}		
		else if(skill == S_Alchemy_s06)
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			if ( hud )
			{
				hud.OnRelevantSkillChanged( skill, true );
			}
		}
		else if(skill == S_Magic_s11)		
		{
			((W3YrdenEntity) (witcher.GetSignEntity(ST_Yrden))).SkillEquipped(skill);
		}
		else if(skill == S_Magic_s07)		
		{
			if(owner.HasBuff(EET_BattleTrance))
				owner.AddAbility( GetSkillAbilityName(S_Magic_s07) );
		}
		else if(skill == S_Perk_08)
		{
			
			thePlayer.ChangeAlchemyItemsAbilities(true);
		}
		else if(skill == S_Alchemy_s19 || skill == S_Perk_43)
		{
			skillLevelSynergyFromAlchemy = GetSkillLevel( S_Alchemy_s19);
			skillLevelSynergyFromPerks = GetSkillLevel( S_Perk_43);
			if ( skillLevelSynergyFromAlchemy > skillLevelSynergyFromPerks )
			{
				MutagensSyngergyBonusUpdate( -1, skillLevelSynergyFromAlchemy );
			}
			else
			{
				MutagensSyngergyBonusUpdate( -1, skillLevelSynergyFromPerks );
			}
		}
		else if(skill == S_Perk_01)
		{
			isNight = theGame.envMgr.IsNight();
			SetPerk01Abilities(!isNight, isNight);
		}
		else if(skill == S_Perk_05)
		{
			SetPerkArmorBonus(S_Perk_05);
		}
		else if(skill == S_Perk_06)
		{
			SetPerkArmorBonus(S_Perk_06);
		}
		else if(skill == S_Perk_07)
		{
			SetPerkArmorBonus(S_Perk_07);
		}
		else if(skill == S_Perk_23)
		{
			SetPerkArmorBonus(S_Perk_23);
		}
		else if(skill == S_Perk_24)
		{
			SetPerkArmorBonus(S_Perk_24);
		}
		else if(skill == S_Perk_25)
		{
			SetPerkArmorBonus(S_Perk_25);
		}
		else if(skill == S_Perk_26)
		{
			SetPerkArmorBonus(S_Perk_26);
		}
		else if(skill == S_Perk_27)
		{
			SetPerkArmorBonus(S_Perk_27);
		}
		else if(skill == S_Perk_28)
		{
			SetPerkArmorBonus(S_Perk_28);
		}
		else if(skill == S_Perk_11)
		{
			battleTrance = (W3Effect_BattleTrance)owner.GetBuff(EET_BattleTrance);
			if(battleTrance)
				battleTrance.OnPerk11Equipped();
		}
		else if(skill == S_Magic_s38)
		{
			battleTrance = (W3Effect_BattleTrance)owner.GetBuff(EET_BattleTrance);
			if(battleTrance)
				battleTrance.OnMagic38Equipped();
		}
		else if( skill == S_Perk_14 )
		{
			highestShrineTime = 0.f;
			shrineBuffs = GetWitcherPlayer().GetShrineBuffs();
			for( i = 0; i<shrineBuffs.Size() ; i+=1 )
			{
				shrineTimeLeft = shrineBuffs[i].GetDurationLeft();
				if( shrineTimeLeft > highestShrineTime )
				{
					highestShrineTime = shrineTimeLeft;
					shrineEffectIndex = i;
				}
			}
			for( i = 0; i<shrineBuffs.Size() ; i+=1 )
			{
				if( i != shrineEffectIndex )
				{
					GetWitcherPlayer().RemoveEffect( shrineBuffs[i] );
				}
			}
		}
		else if((skill == S_Perk_19 || skill == S_Perk_40) && witcher.HasBuff(EET_BattleTrance))
		{
			skillLevel = FloorF(witcher.GetStat(BCS_Focus));
			witcher.RemoveAbilityMultiple(thePlayer.GetSkillAbilityName(S_Sword_5), skillLevel);
			witcher.AddAbilityMultiple(thePlayer.GetSkillAbilityName(skill), skillLevel);
		}		
		else if(skill == S_Perk_20)
		{
			thePlayer.SkillReduceBombAmmoBonus();
		}
		else if(skill == S_Perk_22 || skill == S_Perk_35)
		{
			RefreshEncumbrance();
		}
		else if(skill == S_Perk_38)
		{
			isNight = theGame.envMgr.IsNight();
			SetPerk38Abilities( !isNight, isNight );
		}
		
		if(GetSkillPathType(skill) == ESP_Alchemy)
			witcher.RecalcPotionsDurations();
		
		
		if(ShouldProcessTutorial('TutorialCharDevEquipSkill'))
		{
			uiState = (W3TutorialManagerUIHandlerStateCharacterDevelopment)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
			if(uiState)
				uiState.EquippedSkill();
		}
		
		
		theGame.GetGamerProfile().CheckTrialOfGrasses();
	}
	
	private final function OnSkillUnequip(skill : ESkill)
	{
		var i, skillLevel, skillLevelSynergyFromAlchemy, skillLevelSynergyFromPerks : int;
		var isPassive : bool;
		var petard : W3Petard;
		var ents : array<CGameplayEntity>;
		var mutagens : array<CBaseGameplayEffect>;
		var tox : W3Effect_Toxicity;
		var names, abs : array<name>;
		var skillName : name;
		var battleTrance : W3Effect_BattleTrance;
		var trophy : SItemUniqueId;
		var horseManager : W3HorseManager;
		var witcher : W3PlayerWitcher;
		var weapon, armor : W3RepairObjectEnhancement;
		var foodBuff : W3Effect_WellFed;
		var catsFeastBuff : W3Effect_CatsFeast;
		var hud : CR4ScriptedHud;
		var shrineBuffs : array<CBaseGameplayEffect>;
		var shrineBuffTimeLeft : float;
		var min, max : SAbilityAttributeValue;
		
		var id : SItemUniqueId; 
		
		witcher = GetWitcherPlayer();	
		
		
		if(IsCoreSkill(skill))
			return;
			
		
		isPassive = theGame.GetDefinitionsManager().AbilityHasTag(skills[skill].abilityName, theGame.params.SKILL_GLOBAL_PASSIVE_TAG);
		
		skillLevel = skills[skill].level;
			
		for( i = 0; i < skillLevel; i += 1 )
		{
			if(isPassive)
				owner.RemoveAbility(skills[skill].abilityName);
			else
				skillAbilities.Remove(skills[skill].abilityName);
		}
		
		
		if(GetSkillPathType(skill) == ESP_Sword)
		{
			owner.RemoveAbilityMultiple('sword_adrenalinegain', skillLevel );
		}
		
		
		if(GetSkillPathType(skill) == ESP_Signs)
		{
			owner.RemoveAbilityMultiple('magic_staminaregen', GetSkillLevel(skill) );
		}
		
		
		if(GetSkillPathType(skill) == ESP_Alchemy)
		{
			owner.RemoveAbilityMultiple('alchemy_potionduration', GetSkillLevel(skill) );
		}

		
		if(GetSkillPathType(skill) == ESP_Perks)
		{
			owner.RemoveAbilityMultiple('survival_vitality', GetSkillLevel(skill) );
		}
		
		
		if(skill == S_Magic_s11)		
		{
			((W3YrdenEntity) (GetWitcherPlayer().GetSignEntity(ST_Yrden))).SkillUnequipped(skill);
		}
		else if(skill == S_Magic_s07)	
		{
			owner.RemoveAbility( GetSkillAbilityName(S_Magic_s07) );
		}
		else if(skill == S_Alchemy_s04)	
		{
			owner.RemoveEffect(GetWitcherPlayer().GetSkillBonusPotionEffect());
		}
		
		else if(skill == S_Alchemy_s13)
		{
			mutagens = GetWitcherPlayer().GetDrunkMutagens();
			
			if(mutagens.Size() > 0)
			{
				charStats.RemoveAbilityMultiple( GetSkillAbilityName( S_Alchemy_s13 ), ( GetSkillLevel( skill ) * mutagens.Size() ));
			}
		}
		else if(skill == S_Alchemy_s06)
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			if ( hud )
			{
				hud.OnRelevantSkillChanged( skill, false );
			}
			
			
			if( witcher.GetItemEquippedOnSlot( EES_SteelSword, id ) )
			{
				witcher.RemoveExtraOilsFromItem( id );
			}
			if( witcher.GetItemEquippedOnSlot( EES_SilverSword, id ) )
			{
				witcher.RemoveExtraOilsFromItem( id );
			}
			
		}
		else if(skill == S_Alchemy_s20)
		{
			owner.RemoveBuff(EET_IgnorePain);
		}
		else if(skill == S_Alchemy_s15 && owner.HasBuff(EET_Toxicity))
		{
			tox = (W3Effect_Toxicity)owner.GetBuff(EET_Toxicity);
			tox.RecalcEffectValue();
		}
		else if(skill == S_Alchemy_s18)			
		{			
			skillName = SkillEnumToName(S_Alchemy_s18);		
			charStats.RemoveAbilityAll(skillName);
		}
		else if(skill == S_Sword_s13)			
		{
			theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_ThrowingAim) );
		}
		else if(skill == S_Alchemy_s08)
		{
			skillLevel = GetSkillLevel(S_Alchemy_s08);
			for (i=0; i < skillLevel; i+=1)
				thePlayer.SkillReduceBombAmmoBonus();
		}
		else if(skill == S_Perk_08)
		{
			
			thePlayer.ChangeAlchemyItemsAbilities(false);
		}
		else if(skill == S_Alchemy_s19 || skill == S_Perk_43)
		{
			MutagensSyngergyBonusUpdate( -1, 0 );
		}
		else if(skill == S_Perk_01)
		{
			SetPerk01Abilities(false, false);
		}
		else if(skill == S_Perk_05)
		{
			UpdatePerkArmorBonus(S_Perk_05, 0);	
		}
		else if(skill == S_Perk_06)
		{
			UpdatePerkArmorBonus(S_Perk_06, 0);	
		}
		else if(skill == S_Perk_07)
		{
			UpdatePerkArmorBonus(S_Perk_07, 0);	
		}
		else if(skill == S_Perk_23)
		{
			UpdatePerkArmorBonus(S_Perk_23, 0);	
		}
		else if(skill == S_Perk_24)
		{
			UpdatePerkArmorBonus(S_Perk_24, 0);	
		}
		else if(skill == S_Perk_25)
		{
			UpdatePerkArmorBonus(S_Perk_25, 0);	
		}
		else if(skill == S_Perk_26)
		{
			UpdatePerkArmorBonus(S_Perk_26, 0);	
		}
		else if(skill == S_Perk_27)
		{
			UpdatePerkArmorBonus(S_Perk_27, 0);	
		}
		else if(skill == S_Perk_28)
		{
			UpdatePerkArmorBonus(S_Perk_28, 0);	
		}
		else if(skill == S_Perk_11)
		{
			battleTrance = (W3Effect_BattleTrance)owner.GetBuff(EET_BattleTrance);
			if(battleTrance)
				battleTrance.OnPerk11Unequipped();
		}		
		else if(skill == S_Magic_s38)
		{
			battleTrance = (W3Effect_BattleTrance)owner.GetBuff(EET_BattleTrance);
			if(battleTrance)
				battleTrance.OnMagic38Unequipped();
		}	
		else if( skill == S_Perk_15 )
		{
			foodBuff = (W3Effect_WellFed)owner.GetBuff( EET_WellFed );
			if( foodBuff )
			{
				foodBuff.OnPerk15Unequipped();
			}
		}
		else if( skill == S_Perk_40 )
		{
			owner.RemoveAbilityAll( thePlayer.GetSkillAbilityName(S_Perk_40) );
		}
		else if( skill == S_Perk_41 )
		{
			foodBuff = (W3Effect_WellFed)owner.GetBuff( EET_WellFed );
			if( foodBuff )
			{
				foodBuff.OnPerk41Unequipped();
			}
		}
		else if((skill == S_Perk_19 || skill == S_Perk_40) && owner.HasBuff(EET_BattleTrance))
		{
			skillLevel = FloorF(owner.GetStat(BCS_Focus));
			owner.RemoveAbilityMultiple(thePlayer.GetSkillAbilityName(skill), skillLevel);
			owner.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Sword_5), skillLevel);
		}
		else if(skill == S_Perk_22 || skill == S_Perk_35)
		{
			RefreshEncumbrance();
		}
		else if(skill == S_Perk_29)
		{
			catsFeastBuff = (W3Effect_CatsFeast) owner.GetBuff( EET_CatPerk29 );
			if ( catsFeastBuff )
			{
				catsFeastBuff.OnPerk29Unequipped();
			}
		}
		else if(skill == S_Perk_36)
		{
			shrineBuffs = GetWitcherPlayer().GetShrineBuffs();
			for ( i = 0; i < shrineBuffs.Size(); i += 1 )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( shrineBuffs[i].GetAbilityName(), 'duration', min, max );
				shrineBuffTimeLeft = CalculateAttributeValue( GetAttributeRandomizedValue( min, max ) ) - shrineBuffs[i].GetTimeActive();
				if ( shrineBuffTimeLeft <= 0 )
					owner.RemoveBuff( shrineBuffs[i].GetEffectType() );
				else
					shrineBuffs[i].SetTimeLeft( shrineBuffTimeLeft );
			}
		}
		else if(skill == S_Perk_38)
		{
			SetPerk38Abilities( false, false );
		}
		
		if(GetSkillPathType(skill) == ESP_Alchemy)
			GetWitcherPlayer().RecalcPotionsDurations();
		
		
		if ( CanUseSkill(S_Alchemy_s19) || CanUseSkill(S_Perk_43) )
		{
			skillLevelSynergyFromAlchemy = GetSkillLevel( S_Alchemy_s19);
			skillLevelSynergyFromPerks = GetSkillLevel( S_Perk_43);
			if ( skillLevelSynergyFromAlchemy > skillLevelSynergyFromPerks )
			{
				MutagensSyngergyBonusUpdate( GetSkillGroupIdFromSkill( skill ), skillLevelSynergyFromAlchemy );
			}
			else
			{
				MutagensSyngergyBonusUpdate( GetSkillGroupIdFromSkill( skill ), skillLevelSynergyFromPerks );
			}
		}
	}

	public final function RefreshEncumbrance()
	{
		var commonMenu : CR4CommonMenu;
		var guiMan : CR4GuiManager;

		GetWitcherPlayer().UpdateEncumbrance();
		guiMan = theGame.GetGuiManager();
		if(guiMan)
		{
			commonMenu = theGame.GetGuiManager().GetCommonMenu();
			if(commonMenu)
			{
				commonMenu.UpdateItemsCounter();
			}
		}
	}
	
	
	public final function SetPerkArmorBonus(skill : ESkill, optional spawnPlayerEntity : W3PlayerWitcher )
	{
		var item : SItemUniqueId;
		var armors : array<SItemUniqueId>;
		var light, medium, heavy, i, cnt : int;
		var armorType : EArmorType;
		var witcher : W3PlayerWitcher;
		var inventory : CInventoryComponent;
		
		if(skill != S_Perk_05 && skill != S_Perk_06 && skill != S_Perk_07
		&& skill != S_Perk_23 && skill != S_Perk_24 && skill != S_Perk_25
		&& skill != S_Perk_26 && skill != S_Perk_27 && skill != S_Perk_28)
		{
			return;
		}
		
		if( !CanUseSkill( skill ) )
		{
			cnt = 0;
		}
		else
		{
			if( spawnPlayerEntity ) 
			{
				witcher = spawnPlayerEntity;
			}
			else
			{
				witcher = GetWitcherPlayer();
			}
			
			armors.Resize(4);
			
			if(witcher.GetItemEquippedOnSlot(EES_Armor, item))
				armors[0] = item;
				
			if(witcher.GetItemEquippedOnSlot(EES_Boots, item))
				armors[1] = item;
				
			if(witcher.GetItemEquippedOnSlot(EES_Pants, item))
				armors[2] = item;
				
			if(witcher.GetItemEquippedOnSlot(EES_Gloves, item))
				armors[3] = item;
			
			light = 0;
			medium = 0;
			heavy = 0;
			inventory = witcher.GetInventory();
			for(i=0; i<armors.Size(); i+=1)
			{
				armorType = inventory.GetArmorType(armors[i]);
				if(armorType == EAT_Light)
					light += 1;
				else if(armorType == EAT_Medium)
					medium += 1;
				else if(armorType == EAT_Heavy)
					heavy += 1;
			}
			
			if(skill == S_Perk_05)
				cnt = light;
			else if(skill == S_Perk_23)
				cnt = light * GetSkillLevel(skill);
			else if(skill == S_Perk_06)
				cnt = medium;
			else if(skill == S_Perk_24 || skill == S_Perk_26 || skill == S_Perk_27 || skill == S_Perk_28)
				cnt = medium * GetSkillLevel(skill);
			else if(skill == S_Perk_07)
				cnt = heavy;
			else if(skill == S_Perk_25)
				cnt = heavy * GetSkillLevel(skill);
		}
		
		UpdatePerkArmorBonus(skill, cnt);		
	}
	
	
	protected final function UpdatePerkArmorBonus(skill : ESkill, count : int)
	{
		var abilityName : name;
		var currAbs : int;
		
		abilityName = GetSkillAbilityName(skill);
		
		if(count == 0)
		{
			charStats.RemoveAbilityAll( abilityName );
		}
		else
		{
			currAbs = charStats.GetAbilityCount( abilityName );
			
			if(currAbs < count)
			{
				charStats.AddAbilityMultiple( abilityName, count - currAbs );
			}
			else if(currAbs > count)
			{
				charStats.RemoveAbilityMultiple( abilityName, currAbs - count );
			}
		}
	}	
	
	
	public final function SetPerk01Abilities(enableDay : bool, enableNight : bool)
	{
		var abilityName : name;
		var i : int;
		var dm : CDefinitionsManagerAccessor;
		var abs : array<name>;
		var enable : bool;
		
		abilityName = GetSkillAbilityName(S_Perk_01);
		dm = theGame.GetDefinitionsManager();
		dm.GetContainedAbilities(abilityName, abs);
		
		for(i=0; i<abs.Size(); i+=1)
		{
			if(dm.AbilityHasTag(abs[i], 'Day'))
				enable = enableDay;
			else
				enable = enableNight;
				
			if(enable)
				charStats.AddAbility(abs[i], false);
			else
				charStats.RemoveAbility(abs[i]);
		}
	}

	
	public final function SetPerk38Abilities( enableDay : bool, enableNight : bool )
	{
		var abilityName : name;
		var i : int;
		var dm : CDefinitionsManagerAccessor;
		var abs : array<name>;
		var enable : bool;

		var abilityCount : int;
		var abilitiesToAdd : int;
		
		abilityName = GetSkillAbilityName( S_Perk_38 );
		dm = theGame.GetDefinitionsManager();
		dm.GetContainedAbilities( abilityName, abs );
		
		for( i = 0; i < abs.Size(); i += 1 )
		{
			if( dm.AbilityHasTag( abs[i], 'Day' ) )
				enable = enableDay;
			else
				enable = enableNight;
				
			if( enable )
			{
				abilityCount = charStats.GetAbilityCount( abs[i] );
				abilitiesToAdd = GetSkillLevel( S_Perk_38 ) - abilityCount;

				if ( abilitiesToAdd > 0 )
					charStats.AddAbilityMultiple( abs[i], abilitiesToAdd );
				else if ( abilitiesToAdd < 0 )
					charStats.RemoveAbilityMultiple( abs[i], Abs( abilitiesToAdd ) );
			}
			else
			{
				charStats.RemoveAbilityAll( abs[i] );
			}
		}
	}
	
	
	private final function OnSkillEquippedLevelChange(skill : ESkill, prevLevel : int, currLevel : int)
	{
		var cnt, i : int;
		var names : array<name>;
		var skillAbilityName : name;
		var mutagens : array<CBaseGameplayEffect>;
		var recipe : SAlchemyRecipe;
		var m_alchemyManager : W3AlchemyManager;
		var tox : W3Effect_Toxicity;
		var ignorePain : W3Effect_IgnorePain;
		var foodBuff : W3Effect_WellFed;
		
		var hud : CR4ScriptedHud;
		var isNight : bool;
		
		
		if(IsCoreSkill(skill))
			return;
		
		if(skill == S_Alchemy_s08)
		{
			if(currLevel < prevLevel)
				thePlayer.SkillReduceBombAmmoBonus();
		}
		
		else if(skill == S_Alchemy_s06)
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			if ( hud )
			{
				hud.OnRelevantSkillChanged( skill, true );
			}
		}
		else if(skill == S_Alchemy_s15 && owner.HasBuff(EET_Toxicity))
		{
			tox = (W3Effect_Toxicity)owner.GetBuff(EET_Toxicity);
			tox.RecalcEffectValue();
		}
		else if(skill == S_Alchemy_s18)
		{
			m_alchemyManager = new W3AlchemyManager in this;
			m_alchemyManager.Init();
			names = GetWitcherPlayer().GetAlchemyRecipes();
			skillAbilityName = SkillEnumToName(S_Alchemy_s18);
			cnt = 0;
			
			
			for(i=0; i<names.Size(); i+=1)
			{
				m_alchemyManager.GetRecipe(names[i], recipe);
				if ((recipe.cookedItemType != EACIT_Bolt) && (recipe.cookedItemType != EACIT_Undefined) && (recipe.cookedItemType != EACIT_Dye) && (recipe.level <= GetSkillLevel(S_Alchemy_s18)))
					cnt += 1;
			}
			
			
			cnt -= owner.GetAbilityCount(skillAbilityName);
			if(cnt > 0)
				charStats.AddAbilityMultiple(skillAbilityName, cnt);
			else if(cnt < 0)
				charStats.RemoveAbilityMultiple(skillAbilityName, -cnt);
		}
		else if(skill == S_Alchemy_s13)
		{
			mutagens = GetWitcherPlayer().GetDrunkMutagens();
			skillAbilityName = GetSkillAbilityName(S_Alchemy_s13);			
			
			if(mutagens.Size() > 0)
				charStats.AddAbilityMultiple(skillAbilityName, mutagens.Size());
			else
				charStats.RemoveAbilityMultiple(skillAbilityName, mutagens.Size());						
		}
		else if(skill == S_Alchemy_s19)
		{
			
			if ( CanUseSkill(S_Alchemy_s19) )
			{
				MutagensSyngergyBonusUpdate( -1, currLevel );
			}
		}
		else if( skill == S_Perk_41 )
		{
			foodBuff = (W3Effect_WellFed)owner.GetBuff( EET_WellFed );
			if( foodBuff )
			{
				foodBuff.OnPerk41Updated();
			}
		}
		else if(skill == S_Perk_43)
		{
			
			if ( CanUseSkill(S_Perk_43) )
			{
				MutagensSyngergyBonusUpdate( -1, currLevel );
			}
		}
		else if(skill == S_Alchemy_s20)
		{
			if(owner.HasBuff(EET_IgnorePain))
			{
				ignorePain = (W3Effect_IgnorePain)owner.GetBuff(EET_IgnorePain);
				ignorePain.OnSkillLevelChanged(currLevel - prevLevel);
			}
		}
		else if(skill == S_Perk_08)
		{
			if(currLevel == 3)
				thePlayer.ChangeAlchemyItemsAbilities(true);
			else if(currLevel == 2 && prevLevel == 3)
				thePlayer.ChangeAlchemyItemsAbilities(false);
		}
		else if(skill == S_Perk_30 || skill == S_Perk_33)
		{
			AdjustAbilitiesOnLevelChange( skill, prevLevel, currLevel );
		}
		else if(skill == S_Perk_35)
		{
			AdjustAbilitiesOnLevelChange( skill, prevLevel, currLevel );
			
			RefreshEncumbrance();
		}
		else if(skill == S_Perk_23)
		{
			SetPerkArmorBonus(S_Perk_23);
		}
		else if(skill == S_Perk_24)
		{
			SetPerkArmorBonus(S_Perk_24);
		}
		else if(skill == S_Perk_25)
		{
			SetPerkArmorBonus(S_Perk_25);
		}
		else if(skill == S_Perk_26)
		{
			SetPerkArmorBonus(S_Perk_26);
		}
		else if(skill == S_Perk_27)
		{
			SetPerkArmorBonus(S_Perk_27);
		}
		else if(skill == S_Perk_28)
		{
			SetPerkArmorBonus(S_Perk_28);
		}
		else if(skill == S_Perk_38)
		{
			isNight = theGame.envMgr.IsNight();
			SetPerk38Abilities( !isNight, isNight );
		}
		
		
		if(GetSkillPathType(skill) == ESP_Sword)
		{
			if ( (currLevel - prevLevel) > 0)
				owner.AddAbilityMultiple('sword_adrenalinegain', currLevel - prevLevel );
			else if ( (currLevel - prevLevel) < 0)
				owner.RemoveAbilityMultiple('sword_adrenalinegain', currLevel - prevLevel );
		}
		
		
		if(GetSkillPathType(skill) == ESP_Signs)
		{
			if ( (currLevel - prevLevel) > 0)
				owner.AddAbilityMultiple('magic_staminaregen', currLevel - prevLevel );
			else if ( (currLevel - prevLevel) < 0)
				owner.RemoveAbilityMultiple('magic_staminaregen', currLevel - prevLevel );
		}
		
		
		if(GetSkillPathType(skill) == ESP_Alchemy)
		{
			if ( (currLevel - prevLevel) > 0)
				owner.AddAbilityMultiple('alchemy_potionduration', currLevel - prevLevel );
			else if ( (currLevel - prevLevel) < 0)
				owner.RemoveAbilityMultiple('alchemy_potionduration', currLevel - prevLevel );
		}

		
		if(GetSkillPathType(skill) == ESP_Perks)
		{
			if ( (currLevel - prevLevel) > 0)
				owner.AddAbilityMultiple('survival_vitality', currLevel - prevLevel );
			else if ( (currLevel - prevLevel) < 0)
				owner.RemoveAbilityMultiple('survival_vitality', currLevel - prevLevel );
		}
		
		if(GetSkillPathType(skill) == ESP_Alchemy)
			GetWitcherPlayer().RecalcPotionsDurations();
	}

	public final function AdjustAbilitiesOnLevelChange( skill : ESkill, prevLevel : int, currLevel : int )
	{
		if ( currLevel > prevLevel )
			owner.AddAbilityMultiple( SkillEnumToName( skill ), currLevel - prevLevel );
		else if ( currLevel < prevLevel )
			owner.RemoveAbilityMultiple( SkillEnumToName( skill ), prevLevel - currLevel );
	}
	
	public final function CanUseSkill(skill : ESkill) : bool
	{
		var ind : int;
		
		if(!IsSkillEquipped(skill))
			return false;
			
		if(skills[skill].level < 1 && !skills[skill].isCoreSkill)
			return false;
			
		if(skills[skill].remainingBlockedTime != 0)
			return false;
			
		if(theGame.GetDefinitionsManager().IsAbilityDefined(skills[skill].abilityName) && charStats.HasAbility(skills[skill].abilityName))
			return !IsAbilityBlocked(skills[skill].abilityName);
		
		return true;
	}
		
	public final function IsSkillEquipped(skill : ESkill) : bool
	{
		var i, idx : int;
				
		
		if(IsCoreSkill(skill))
			return true;
		
		
		for(i=0; i<skillSlots.Size(); i+=1)
			if(skillSlots[i].socketedSkill == skill)
				return true;
		
		
		if(tempSkills.Contains(skill))
			return true;
		
		return false;
	}
	
	
	public final function GetSkillOnSlot(slotID : int, out skill : ESkill) : bool
	{
		var idx : int;
			
		if(slotID > 0 && slotID <= totalSkillSlotsCount)
		{
			idx = GetSkillSlotIndex(slotID, true);
			if(idx >= 0)
			{
				skill = skillSlots[idx].socketedSkill;
				return true;
			}
		}
		
		skill = S_SUndefined;
		return false;
	}
	
	public final function GetSkillSlots() : array<SSkillSlot>
	{
		return skillSlots;
	}
	
	public final function GetSkillSlotsCount() : int
	{
		return totalSkillSlotsCount;
	}
	
	public final function IsSkillSlotUnlocked(slotIndex : int) : bool
	{
		if(slotIndex >= 0 && slotIndex < skillSlots.Size())
			return skillSlots[slotIndex].unlocked;
			
		return false;
	}
	
	
	public final function ResetCharacterDev()
	{
		var i : int;
		var skillType : ESkill;
		
		for(i=0; i<skills.Size(); i+=1)
		{			
			skillType = skills[i].skillType;
			
			if(IsCoreSkill(skillType))
				continue;
			
			if(IsSkillEquipped(skillType))
				UnequipSkill(GetSkillSlotID(skillType));
				
			skills[i].level = 0;
		}
		
		for(i=0; i<pathPointsSpent.Size(); i+=1)
		{
			pathPointsSpent[i] = 0;
		}
		
		owner.RemoveAbilityAll('sword_adrenalinegain');
		owner.RemoveAbilityAll('magic_staminaregen');
		owner.RemoveAbilityAll('alchemy_potionduration');
		owner.RemoveAbilityAll('survival_vitality');
	}
	
	
	public function NGEFixSkillPoints()
	{
		var i, j : int;
		var skillType : ESkill;
		var equippedSkills : array<STempSkill>;
		var tempSkill : STempSkill;
		var skillPointsToAdd : int;
		var skillDefs : array<name>;
		var canContinue : bool;
		
		var used, free : int;
		
		used = GetWitcherPlayer().levelManager.GetPointsUsed(ESkillPoint);
		free = GetWitcherPlayer().levelManager.GetPointsFree(ESkillPoint);	

		skillPointsToAdd += free;

		for(i=0; i<skills.Size(); i+=1)
		{			
			skillType = skills[i].skillType;
			
			if(IsCoreSkill(skillType))
				continue;
				
			if(skillType == S_SUndefined)
				continue;
			
			
			if(IsSkillEquipped(skillType))
			{
				tempSkill.skillType = skillType;				
				tempSkill.skillSlot = GetSkillSlotID(skillType);
				tempSkill.equipped = true;	
				tempSkill.temporary = skills[i].isTemporary;
					
				if(skillType == S_Sword_s10)
				{
					if(skills[i].level >= 2)
						tempSkill.skillLevel = 2;
					else
						tempSkill.skillLevel = 1;
				}
				else if(skillType == S_Sword_s09)
				{
					tempSkill.skillLevel = 1;
				}
				else if(skillType == S_Sword_s13)
				{
					tempSkill.skillLevel = 1;
				}
				else if(skillType == S_Alchemy_s09)
				{			
					tempSkill.skillLevel = 1;
				}				
				else if(skills[i].level >= 3)
					tempSkill.skillLevel = 3;
				else
					tempSkill.skillLevel = skills[i].level;
				
				equippedSkills.PushBack(tempSkill);
				
				
				UnequipSkill(GetSkillSlotID(skillType));
			}
			else if(HasLearnedSkill(skillType))
			{
				tempSkill.skillType = skillType;				
				tempSkill.skillSlot = GetSkillSlotID(skillType);
				tempSkill.equipped = false;		
				tempSkill.temporary = skills[i].isTemporary;
					
				if(skillType == S_Sword_s10)
				{
					if(skills[i].level >= 2)
						tempSkill.skillLevel = 2;
					else
						tempSkill.skillLevel = 1;
				}
				else if(skillType == S_Sword_s09)
				{
					tempSkill.skillLevel = 1;
				}
				else if(skillType == S_Sword_s13)
				{
					tempSkill.skillLevel = 1;
				}
				else if(skillType == S_Alchemy_s09)
				{			
					tempSkill.skillLevel = 1;
				}				
				else if(skills[i].level >= 3)
					tempSkill.skillLevel = 3;
				else
					tempSkill.skillLevel = skills[i].level;
								
				equippedSkills.PushBack(tempSkill);
			}

			if(skillType == S_Sword_s10) 
			{
				if(skills[i].level == 3)
				{
					skillPointsToAdd += 1;
					skills[i].level = 2;	
				}
			}
			else if(skillType == S_Sword_s09) 
			{
				if(skills[i].level == 5)
				{
					skillPointsToAdd += 4;
					skills[i].level = 1;		
				}
				else if(skills[i].level == 4)
				{
					skillPointsToAdd += 3;
					skills[i].level = 1;		
				}
				else if(skills[i].level == 3)
				{
					skillPointsToAdd += 2;
					skills[i].level = 1;	
				}
				else if(skills[i].level == 2)
				{
					skillPointsToAdd += 1;
					skills[i].level = 1;	
				}
			}
			else if(skillType == S_Sword_s13) 
			{
				if(skills[i].level == 3)
				{
					skillPointsToAdd += 2;
					skills[i].level = 1;	
				}
				else if(skills[i].level == 2)
				{
					skillPointsToAdd += 1;
					skills[i].level = 1;	
				}
			}
			else if(skillType == S_Alchemy_s09) 
			{
				if(skills[i].level == 3)
				{
					skillPointsToAdd += 2;
					skills[i].level = 1;	
				}
				else if(skills[i].level == 2)
				{
					skillPointsToAdd += 1;
					skills[i].level = 1;	
				}				
			}
			else if(skills[i].level == 5)
			{
				skills[i].level = 3;
				skillPointsToAdd += 2;
			}
			else if(skills[i].level == 4)
			{
				skills[i].level = 3;
				skillPointsToAdd += 1;
			}
		}
		
		
		for(i=0; i<pathPointsSpent.Size(); i+=1)
		{
			pathPointsSpent[i] = 0;
		}

		
		owner.RemoveAbilityAll('sword_adrenalinegain');
		owner.RemoveAbilityAll('magic_staminaregen');
		owner.RemoveAbilityAll('alchemy_potionduration');
		owner.RemoveAbilityAll('survival_vitality');
		
		
		charStats.GetAbilitiesWithTag('SkillDefinitionName', skillDefs);
		for(i=0; i<skillDefs.Size(); i+=1)
			CacheSkills(skillDefs[i], skills);
		InitSkills();	
		PrecacheModifierSkills();	
		
		
		for(i=0; i<equippedSkills.Size(); i+=1)
		{
			skillType = equippedSkills[i].skillType;
			if(skillType == S_SUndefined)
				continue;
			
			for(j=0; j<equippedSkills[i].skillLevel;j+=1)
			{
				AddSkill(skillType,equippedSkills[i].temporary);				
			}			
			
			if(equippedSkills[i].equipped)
				EquipSkill(skillType, equippedSkills[i].skillSlot);
		}

		
		GetWitcherPlayer().AddPoints(ESkillPoint, skillPointsToAdd, true);
		
		GetWitcherPlayer().levelManager.NGE_SetUsedPoints( used - Abs(skillPointsToAdd - free) );
		GetWitcherPlayer().levelManager.NGE_SetFreePoints( skillPointsToAdd );
		
		
		SetToxicityOffset(0.f);
	}	

	
	public function RemasterCheckAndFixSkillStatsOnLoadedSave()
	{
		var i, j : int;
		var newSkills : array<SSkill>;
		var skillDefs : array<name>;
		var fixedSomething : bool;
		
		charStats.GetAbilitiesWithTag('SkillDefinitionName', skillDefs);
		LogAssert(skillDefs.Size()>0, "W3PlayerAbilityManager.Init: actor <<" + owner + ">> has no skills!!");
		fixedSomething = false;
		
		for( i = 0; i < skillDefs.Size(); i+=1 )
			CacheSkills(skillDefs[i], newSkills);	

		for( i = 0; i < newSkills.Size(); i+=1 )
		{
			if ( newSkills[ i ].isUnchangedLegacy || newSkills[ i ].isReworked )
			{
				for( j = 0; j < skills.Size(); j+=1 )
				{
					if( newSkills[ i ].skillType == skills[ j ].skillType )
					{
						
						skills[ j ].gridRow = newSkills[ i ].gridRow;
						skills[ j ].gridColumn = newSkills[ i ].gridColumn;
						skills[ j ].requiredSkills = newSkills[ i ].requiredSkills;
						skills[ j ].requiredSkillsIsAlternative = newSkills[ i ].requiredSkillsIsAlternative;
						skills[ j ].localisationNameKey = newSkills[ i ].localisationNameKey;
						skills[ j ].localisationDescriptionKey = newSkills[ i ].localisationDescriptionKey;
						skills[ j ].localisationDescriptionLevel2Key = newSkills[ i ].localisationDescriptionLevel2Key;
						skills[ j ].localisationDescriptionLevel3Key = newSkills[ i ].localisationDescriptionLevel3Key;
					}
				}
			}
		}
	}
	
	
	public function RemasterSkillResetAndRefund()
	{
		var i, j : int;
		var skillType : ESkill;
		var equippedSkills : array<STempSkill>;
		var tempSkill : STempSkill;
		var skillPointsToAdd : int;
		var skillDefs : array<name>;
		var canContinue : bool;
		
		var used, free, mutationPoints : int;
		
		used = GetWitcherPlayer().levelManager.GetPointsUsed(ESkillPoint);
		free = GetWitcherPlayer().levelManager.GetPointsFree(ESkillPoint);	
		mutationPoints = GetMutationsUsedSkillPoints();

		skillPointsToAdd += free + used - mutationPoints;
		ResetCharacterDev();
		
		
		charStats.GetAbilitiesWithTag('SkillDefinitionName', skillDefs);
		for(i=0; i<skillDefs.Size(); i+=1)
			CacheSkills(skillDefs[i], skills);
		InitSkills();	
		PrecacheModifierSkills();	

		
		GetWitcherPlayer().AddPoints(ESkillPoint, skillPointsToAdd, true);
		
		
		GetWitcherPlayer().levelManager.NGE_SetUsedPoints( used - Abs(skillPointsToAdd - free) );
		GetWitcherPlayer().levelManager.NGE_SetFreePoints( skillPointsToAdd );
		
		
		SetToxicityOffset(0.f);

		
		RemasterSkillSlotReset();
	}

	public function GetToxicityOffset() : float
	{
		return toxicityOffset;
	}
	
	
	
	
	
	
	
	public final function TutorialMutagensUnequipPlayerSkills() : array<STutorialSavedSkill>
	{
		var savedSkills : array<STutorialSavedSkill>;		
		var i : int;
		var slots : array<int>;								
		var equippedSkill : ESkill;
		var savedSkill : STutorialSavedSkill;
		
		
		slots = TutorialGetConnectedSkillsSlotsIDs();
		
		
		for(i=0; i<slots.Size(); i+=1)
		{			
			if(GetSkillOnSlot(slots[i], equippedSkill) && equippedSkill != S_SUndefined)
			{
				
				savedSkill.skillType = equippedSkill;
				savedSkill.skillSlotID = slots[i];
				savedSkills.PushBack(savedSkill);
				
				
				UnequipSkill(slots[i]);
			}
		}
		
		
		TutorialUpdateUI();
		
		return savedSkills;
	}
	
	
	public final function TutorialMutagensEquipOneGoodSkill()
	{		
		var slots : array<int>;
				
		
		slots = TutorialGetConnectedSkillsSlotsIDs();
		
		
		TutorialSelectAndAddTempSkill();
				
		
		EquipSkill(temporaryTutorialSkills[0].skillType, ArrayFindMinInt(slots));
		
		
		TutorialUpdateUI();
	}
	
	
	public final function TutorialMutagensEquipOneGoodOneBadSkill()
	{
		var slots : array<int>;
		
		
		TutorialSelectAndAddTempSkill(true);
		
		
		slots = TutorialGetConnectedSkillsSlotsIDs();
		ArraySortInts(slots);
		EquipSkill(temporaryTutorialSkills[1].skillType, slots[1] );
		
		
		TutorialUpdateUI();		
	}
	
	
	public final function TutorialMutagensEquipThreeGoodSkills()
	{
		var slots : array<int>;		
		
		
		TutorialGetRidOfTempSkill(1);
				
		
		TutorialSelectAndAddTempSkill(false, 1);
		TutorialSelectAndAddTempSkill(false, 2);
		
		
		slots = TutorialGetConnectedSkillsSlotsIDs();
		ArraySortInts(slots);
		EquipSkill(temporaryTutorialSkills[1].skillType, slots[1]);
		EquipSkill(temporaryTutorialSkills[2].skillType, slots[2]);
		
		
		TutorialUpdateUI();	
	}
	
	
	public final function TutorialMutagensCleanupTempSkills(savedEquippedSkills : array<STutorialSavedSkill>)
	{
		
		TutorialGetRidOfTempSkill(2);
		TutorialGetRidOfTempSkill(1);
		TutorialGetRidOfTempSkill(0);
		
		
		EquipSkill(savedEquippedSkills[0].skillType, savedEquippedSkills[0].skillSlotID);
		EquipSkill(savedEquippedSkills[1].skillType, savedEquippedSkills[1].skillSlotID);
		EquipSkill(savedEquippedSkills[2].skillType, savedEquippedSkills[2].skillSlotID);
		
		TutorialUpdateUI();
	}
	
	private final function TutorialGetRidOfTempSkill(tutTempArrIdx : int)
	{
		var tempSkill : ESkill;
		var i, ind : int;
		
		tempSkill = temporaryTutorialSkills[tutTempArrIdx].skillType;
		if(temporaryTutorialSkills[tutTempArrIdx].wasLearned)
		{
			if(!skills[tempSkill].isCoreSkill)
				pathPointsSpent[skills[tempSkill].skillPath] = pathPointsSpent[skills[tempSkill].skillPath] - 1;
			
			skills[tempSkill].level = 0;
		}
		
		ind = GetSkillSlotID(tempSkill);
		if(ind >= 0)
			UnequipSkill(ind);
			
		temporaryTutorialSkills.EraseFast(tutTempArrIdx);
		tempSkills.Remove(tempSkill);
	}
	
	
	
	
	private final function TutorialSelectAndAddTempSkill(optional ofWrongColor : bool, optional index : int)
	{
		var witcher : W3PlayerWitcher;
		var mutagenColor : ESkillColor;				
		var tempSkill : ESkill;
		var tutSkill : STutorialTemporarySkill;
		var mutagenItemId : SItemUniqueId;
		
		
		witcher = GetWitcherPlayer();
		witcher.GetItemEquippedOnSlot(EES_SkillMutagen1, mutagenItemId);
		mutagenColor = witcher.inv.GetSkillMutagenColor(mutagenItemId);
		
		if(!ofWrongColor)
		{
			if(mutagenColor == SC_Blue)
			{
				if(index == 0)			tempSkill = S_Magic_s01;
				else if(index == 1)		tempSkill = S_Magic_s02;
				else if(index == 2)		tempSkill = S_Magic_s03;
			}
			else if(mutagenColor == SC_Red)
			{
				if(index == 0)			tempSkill = S_Sword_s01;
				else if(index == 1)		tempSkill = S_Sword_s02;
				else if(index == 2)		tempSkill = S_Sword_s03;
			}
			else if(mutagenColor == SC_Green)
			{
				if(index == 0)			tempSkill = S_Alchemy_s01;
				else if(index == 1)		tempSkill = S_Alchemy_s02;
				else if(index == 2)		tempSkill = S_Alchemy_s03;
			}
		}
		else
		{
			if(mutagenColor == SC_Green)
				tempSkill = S_Magic_s01;
			else
				tempSkill = S_Alchemy_s01;
		}
					
		
		if(GetSkillLevel(tempSkill) <= 0)
		{
			tempSkills.PushBack(tempSkill);
			AddSkill(tempSkill, true);
			tutSkill.wasLearned = true;
		}
		else
		{
			tutSkill.wasLearned = false;
		}
		
		tutSkill.skillType = tempSkill;
		temporaryTutorialSkills.PushBack(tutSkill);
	}
	
	
	private final function TutorialGetConnectedSkillsSlotsIDs() : array<int>
	{
		var i, connectedSkillsGroupID, processedSlots : int;
		var slots : array<int>;
		
		connectedSkillsGroupID = GetSkillGroupIdOfMutagenSlot(EES_SkillMutagen1);
		
		for(i=0; i<skillSlots.Size(); i+=1)
		{
			if(skillSlots[i].groupID == connectedSkillsGroupID)
			{
				slots.PushBack(skillSlots[i].id);
				processedSlots += 1;
				
				if(processedSlots == 3)
					break;
			}
		}
		
		return slots;
	}
	
	private final function TutorialUpdateUI()
	{
		( (CR4CharacterMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild() ).UpdateData(false);
	}
	
	
	public function DEBUG_DevelopAndEquipMutation( mut : EPlayerMutationType )
	{
		var player : W3PlayerWitcher;
		var tempInt : int;
		
		player = GetWitcherPlayer();
		
		tempInt = GetMutationIndex( mut );
		mutations[ tempInt ].progress.overallProgress = 100;
		mutations[ tempInt ].progress.blueUsed = mutations[ tempInt ].progress.blueRequired;
		mutations[ tempInt ].progress.greenUsed = mutations[ tempInt ].progress.greenRequired;
		mutations[ tempInt ].progress.redUsed = mutations[ tempInt ].progress.redRequired;
		mutations[ tempInt ].progress.skillpointsUsed = mutations[ tempInt ].progress.skillpointsRequired;
		OnMutationFullyResearched( mut );
		
		DEBUG_SetEquippedMutation( mut );
	}
	
	
	
	
	
	public final function ResetMutationsDev()
	{
		var i : int;
		
		
		for( i=0; i<mutationUnlockedSlotsIndexes.Size(); i+=1 )
		{
			UnequipSkill( mutationUnlockedSlotsIndexes[ i ] );
		}
		
		
		SetEquippedMutation( EPMT_None );
		
		
		for( i=0; i<mutations.Size(); i+=1 )
		{
			mutations[i].progress.redUsed = 0;
			mutations[i].progress.blueUsed = 0;
			mutations[i].progress.greenUsed = 0;
			mutations[i].progress.skillpointsUsed = 0;
			mutations[i].progress.overallProgress = -1;	
		}
	}
	
	public final function GetMutationsUsedSkillPoints() : int
	{
		var total, i : int;
		
		total = 0;
		for( i=0; i<mutations.Size(); i+=1 )
		{
			total += mutations[i].progress.skillpointsUsed;
		}
		
		return total;
	}
	
	
	private final function LoadMutationData()
	{
		var xmlMutations : array< SMutation >;
		var i, j : int;
		var foundInXML : bool;
		
		LoadMutationDataFromXML( xmlMutations );
		
		
		for( i=mutations.Size()-1; i>=0; i-=1 )
		{
			foundInXML = false;
			
			
			for( j=xmlMutations.Size()-1; j>=0; j-=1 )
			{
				if( mutations[ i ].type == xmlMutations[ j ].type )
				{
					mutations[ i ].progress.redRequired = xmlMutations[ j ].progress.redRequired;
					mutations[ i ].progress.blueRequired = xmlMutations[ j ].progress.blueRequired;
					mutations[ i ].progress.greenRequired = xmlMutations[ j ].progress.greenRequired;
					mutations[ i ].progress.skillpointsRequired = xmlMutations[ j ].progress.skillpointsRequired;
					mutations[ i ].progress.overallProgress = -1;
					mutations[ i ].localizationNameKey = xmlMutations[ j ].localizationNameKey;
					mutations[ i ].localizationDescriptionKey = xmlMutations[ j ].localizationDescriptionKey;
					mutations[ i ].iconPath = xmlMutations[ j ].iconPath;
					mutations[ i ].soundbank = xmlMutations[ j ].soundbank;
					
					mutations[ i ].colors.Clear();
					mutations[ i ].requiredMutations.Clear();
					
					mutations[ i ].requiredMutations = xmlMutations[ j ].requiredMutations;
					mutations[ i ].colors = xmlMutations[ j ].colors;
					
					xmlMutations.EraseFast( j );
					foundInXML = true;
					break;
				}
			}
			
			
			if( !foundInXML )
			{
				
				if( mutations[ i ].progress.skillpointsUsed > 0 )
				{
					GetWitcherPlayer().AddPoints( ESkillPoint, mutations[ i ].progress.skillpointsUsed, false );
				}
				
				mutations.EraseFast( i );
			}
		}
		
		
		for( i=0; i<xmlMutations.Size(); i+=1 )
		{
			mutations.PushBack( xmlMutations[ i ] );
		}
	}
	
	private final function LoadMutationDataFromXML( out xmlMutations : array< SMutation > )
	{
		var dm : CDefinitionsManagerAccessor;
		var main, subNode : SCustomNode;
		var xmlMutation : SMutation;
		var i, tmpInt, j : int;
		var tmpName : name;
		var tmpStr : string;
		var skillColor : ESkillColor;
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition( 'mutations' );
		
		xmlMutation.progress.redUsed = 0;
		xmlMutation.progress.blueUsed = 0;
		xmlMutation.progress.greenUsed = 0;
		xmlMutation.progress.skillpointsUsed = 0;
		xmlMutation.progress.overallProgress = -1;
			
		
		for( i=0; i<main.subNodes.Size(); i+=1 )
		{
			dm.GetCustomNodeAttributeValueName( main.subNodes[ i ], 'type_name', tmpName );
			xmlMutation.type = MutationNameToType( tmpName );
			
			dm.GetCustomNodeAttributeValueInt( main.subNodes[ i ], 'redMutagenPoints', tmpInt );
			xmlMutation.progress.redRequired = tmpInt;
			
			dm.GetCustomNodeAttributeValueInt( main.subNodes[ i ], 'blueMutagenPoints', tmpInt );
			xmlMutation.progress.blueRequired = tmpInt;
			
			dm.GetCustomNodeAttributeValueInt( main.subNodes[ i ], 'greenMutagenPoints', tmpInt );
			xmlMutation.progress.greenRequired = tmpInt;
			
			dm.GetCustomNodeAttributeValueInt( main.subNodes[ i ], 'skillPoints', tmpInt );
			xmlMutation.progress.skillpointsRequired = tmpInt;
			
			dm.GetCustomNodeAttributeValueName( main.subNodes[ i ], 'localizationNameKey_name', tmpName );
			xmlMutation.localizationNameKey = tmpName;
			
			dm.GetCustomNodeAttributeValueName( main.subNodes[ i ], 'localizationDescriptionKey_name', tmpName );
			xmlMutation.localizationDescriptionKey = tmpName;
			
			dm.GetCustomNodeAttributeValueName( main.subNodes[ i ], 'iconPath_name', tmpName );
			xmlMutation.iconPath = tmpName;
			
			dm.GetCustomNodeAttributeValueString( main.subNodes[ i ], 'soundbank', tmpStr );
			xmlMutation.soundbank = tmpStr;
			
			
			subNode = dm.GetCustomDefinitionSubNode( main.subNodes[ i ], 'colors' );
			for( j=0; j<subNode.values.Size(); j+=1 )
			{
				skillColor = SkillColorStringToType( subNode.values[ j ] );
				if( skillColor == SC_Blue || skillColor == SC_Red || skillColor == SC_Green )
				{
					xmlMutation.colors.PushBack( skillColor );
				}
			}
			
			
			subNode = dm.GetCustomDefinitionSubNode( main.subNodes[ i ], 'required_mutations' );
			for( j=0; j<subNode.values.Size(); j+=1 )
			{
				xmlMutation.requiredMutations.PushBack( MutationNameToType( subNode.values[ j ] ) );
			}
			
			xmlMutations.PushBack( xmlMutation );
			
			xmlMutation.colors.Clear();
			xmlMutation.requiredMutations.Clear();
		}
	}
	
	public final function SetEquippedMutation( mutationType : EPlayerMutationType ) : bool
	{
		if( mutationType == EPMT_None && !( ( CR4Player ) owner ).IsInCombat() )
		{
			if( equippedMutation != EPMT_None )
			{
				OnMutationUnequippedPre( equippedMutation );				
			}
			
			equippedMutation = EPMT_None;
			MutationsDisable();
			
			return true;
		}
		else if( CanEquipMutation( mutationType ) )
		{
			if( equippedMutation != EPMT_None )
			{
				OnMutationUnequippedPre( equippedMutation );
			}
			
			MutationsEnable();
			equippedMutation = mutationType;
			OnMutationEquippedPost( equippedMutation );
			return true;
		}
		
		return false;
	}
	
	public final function DEBUG_SetEquippedMutation( mutationType : EPlayerMutationType )
	{
		if( mutationType == EPMT_None )
		{
			if( equippedMutation != EPMT_None )
			{
				OnMutationUnequippedPre( equippedMutation );
				MutationsDisable();
			}
			
			equippedMutation = EPMT_None;
		}
		else
		{
			if( equippedMutation != EPMT_None )
			{
				OnMutationUnequippedPre( equippedMutation );
			}
			
			MutationsEnable();
			equippedMutation = mutationType;
			OnMutationEquippedPost( equippedMutation );
		}
	}
	
	
	private final function OnMutationUnequippedPre( mutationType : EPlayerMutationType )
	{
		var bank			: string;
		var i 				: int;
		var buffs			: array< CBaseGameplayEffect >;
		
		
		bank = GetMutationSoundBank( mutationType );
		if( bank != "" && theSound.SoundIsBankLoaded( bank ) )
		{
			theSound.SoundUnloadBank( bank );
		}
		
		if( mutationType == EPMT_Mutation5 )
		{
			owner.RemoveBuff( EET_Mutation5 );
		}
		else if( mutationType == EPMT_Mutation10 )
		{
			owner.RemoveBuff( EET_Mutation10 );
			owner.StopEffect( 'mutation_10' );
		}
		else if( mutationType == EPMT_Mutation12 )
		{
			buffs = GetWitcherPlayer().GetDrunkMutagens( "Mutation12" );
			for( i=buffs.Size()-1; i>=0; i-=1 )
			{
				owner.RemoveEffect( buffs[i] );
			}
		}
		
		owner.RemoveBuff( EET_Mutation3 );
		
		
		theGame.MutationHUDFeedback( MFT_PlayHide );
	}
	
	
	private final function OnMutationEquippedPost( mutationType : EPlayerMutationType )
	{
		var tutEquipping : W3TutorialManagerUIHandlerStateMutationsEquipping;
		var tutEquipped : W3TutorialManagerUIHandlerStateMutationsEquippedAfter;
		var bank : string;
		
		
		bank = GetMutationSoundBank( mutationType );
		if( bank != "" )
		{
			theSound.SoundLoadBank( bank, true );
		}
		
		UpdateMutationSkillSlots();
		
		if( GetWitcherPlayer().IsMutationActive( EPMT_Mutation10 ) && GetStat( BCS_Toxicity ) != 0 && owner.IsInCombat() )
		{
			owner.AddEffectDefault( EET_Mutation10, NULL, "Mutation 10" );
		}
		
		
		if( ShouldProcessTutorial( 'TutorialMutationsEquippingOnlyOne' ) )
		{
			tutEquipping = ( W3TutorialManagerUIHandlerStateMutationsEquipping ) theGame.GetTutorialSystem().uiHandler.GetCurrentState();
			if( tutEquipping )
			{
				tutEquipping.OnMutationEquippedPost();
			}
			
			tutEquipped = ( W3TutorialManagerUIHandlerStateMutationsEquippedAfter ) theGame.GetTutorialSystem().uiHandler.GetCurrentState();
			if( tutEquipped )
			{
				tutEquipped.OnMutationEquippedPost();
			}
			
			GameplayFactsAdd( "tutorial_mutations_equipped_mutation" );
		}
	}
	
	public final function GetMutationSoundBank( mut : EPlayerMutationType ) : string
	{
		var idx : int;
		
		idx = GetMutationIndex( mut );
		if( idx == -1 )
		{
			return "";
		}
		
		return mutations[idx].soundbank;
	}
	
	private final function MutationsEnable()
	{
		var witcher : W3PlayerWitcher;
		
		witcher = GetWitcherPlayer();
		
		
		
		
		
		
		
		
		UpdateMutationSkillSlots();
	}
	
	private final function MutationsDisable()
	{
		UpdateMutationSkillSlots();
	}
	
	public final function GetEquippedMutationType() : EPlayerMutationType
	{
		return equippedMutation;
	}
	
	public final function CanEquipMutation( mutationType : EPlayerMutationType ) : bool
	{
		
		if( mutationType == EPMT_MutationMaster )
		{
			return false;
		}
		
		if( !IsMutationResearched( mutationType ) )
		{
			return false;
		}

		if( ( ( CR4Player ) owner ).IsInCombat() )
		{
			return false;
		}
		
		return true;
	}
	
	public final function CanResearchMutation( mutationType : EPlayerMutationType ) : bool
	{
		var curMutation : SMutation;
		var curRequiredMutations : array< EPlayerMutationType >;
		var i, count : int;
		
		if( owner.IsInCombat() )
		{
			return false;
		}
		
		curMutation = GetMutation( mutationType );
		curRequiredMutations = curMutation.requiredMutations;
		count = curRequiredMutations.Size();
		
		for( i = 0; i < count; i += 1 )
		{
			if( !IsMutationResearched( curRequiredMutations[i] ) )
			{
				return false;
			}
		}
		
		return true;
	}
	
	public final function GetMutationColors( mutationType : EPlayerMutationType ) : array< ESkillColor >
	{
		var idx : int;
		var colors : array< ESkillColor >;
		
		idx = GetMutationIndex( mutationType );
		if( idx == -1 )
		{
			return colors;
		}
		
		if( mutations[idx].progress.redRequired > 0 )
		{
			colors.PushBack( SC_Red );
		}
		if( mutations[idx].progress.greenRequired > 0 )
		{
			colors.PushBack( SC_Green );
		}
		if( mutations[idx].progress.blueRequired > 0 )
		{
			colors.PushBack( SC_Blue );
		}
		
		return colors;
	}
	
	public final function IsMutationResearched( mutationType : EPlayerMutationType ) : bool
	{
		return GetMutationResearchProgress( mutationType ) >= 100;
	}
	
	
	public final function GetMutationResearchProgress( mutationType : EPlayerMutationType ) : int
	{
		var mutation : SMutation;
		var idx, researchedMutations, stage : int;
		var progress, progressRequired : float;
	
		idx = GetMutationIndex( mutationType );
		if( idx == -1 )
		{
			return 0;
		}
		
		mutation = mutations[ idx ];	
		
		
		if( mutation.type == EPMT_MutationMaster )
		{
			researchedMutations = GetResearchedMutationsCount();
			stage = GetMasterMutationStage();
			
			
			progress = researchedMutations - GetMutationsRequiredForMasterStage( stage );
			progressRequired = GetMutationsRequiredForMasterStage( stage + 1 ) - GetMutationsRequiredForMasterStage( stage );
		}
		else
		{
			
			if( mutation.progress.overallProgress >= 0 )
			{
				return mutation.progress.overallProgress;
			}
			
			progress = mutation.progress.redUsed + mutation.progress.blueUsed + mutation.progress.greenUsed + mutation.progress.skillpointsUsed;
			progressRequired = mutation.progress.redRequired + mutation.progress.blueRequired + mutation.progress.greenRequired + mutation.progress.skillpointsRequired;
		}
		
		
		progress = FloorF( ( 100 * progress ) / progressRequired );
		
		
		mutations[ idx ].progress.overallProgress = ( int )progress;
		
		return ( int )progress;
	}
	
	
	public final function GetMutationsRequiredForMasterStage( stage : int ) : int
	{
		var dm : CDefinitionsManagerAccessor;
		var min, max : SAbilityAttributeValue;
		var attributeName : name;
		
		switch( stage )
		{
			case 1:
				attributeName = 'mutationsRequiredForSlot1';
				break;
			case 2:
				attributeName = 'mutationsRequiredForSlot2';
				break;
			case 3:
				attributeName = 'mutationsRequiredForSlot3';
				break;
			case 4:
				attributeName = 'mutationsRequiredForSlot4';
				break;
			default:
				return 0;		
		}
		
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributeValue('Mutation Master', attributeName, min, max);
		return (int)min.valueAdditive;
	}
	
	public final function MutationSystemEnable( enable : bool )
	{
		isMutationSystemEnabled = enable;
	}
	
	public final function IsMutationSystemEnabled() : bool
	{
		return isMutationSystemEnabled;
	}
	
	public final function GetMasterMutationStage() : int
	{
		var idx, researchedMutations, i : int;
		
		idx = GetMutationIndex( EPMT_MutationMaster );
		if( idx == -1 )
		{
			return 0;
		}
	
		researchedMutations = GetResearchedMutationsCount();
		
		for( i=4; i>0; i-= 1)
		{
			if(researchedMutations >= GetMutationsRequiredForMasterStage( i ) )
			{
				return i;
			}
		}
		
		return 0;
	}
	
	public final function GetResearchedMutationsCount() : int
	{
		var researchedMutations, i : int;
		
		researchedMutations = 0;
		for( i=0; i<mutations.Size(); i+=1 )
		{
			if( mutations[ i ].type != EPMT_MutationMaster && GetMutationResearchProgress( mutations[ i ].type ) == 100 )
			{
				researchedMutations += 1;
			}
		}
		
		return researchedMutations;
	}
	
	
	private final function GetMutationIndex( mutationType : EPlayerMutationType ) : int
	{
		var i : int;
		
		if( mutationType == EPMT_None )
		{
			return -1;
		}
	
		for( i=0; i<mutations.Size(); i+=1 )
		{
			if( mutations[ i ].type == mutationType )
				return i;
		}
		
		return -1;
	}
	
	public final function GetMutation( mutationType : EPlayerMutationType ) : SMutation
	{
		var null : SMutation;
		var idx : int;
		
		idx = GetMutationIndex( mutationType );
		if( idx != -1 )
		{
			return mutations[ idx ];
		}
	
		return null;
	}
	
	public final function GetMutations() : array< SMutation >
	{
		return mutations;
	}
	
	public final function MutationResearchWithSkillPoints( mutation : EPlayerMutationType, skillPoints : int ) : bool
	{
		var witcher : W3PlayerWitcher;
		var availableSkillPoints, idx, progress : int;
		
		
		witcher = GetWitcherPlayer();
		if( owner != witcher )
		{
			return false;
		}
	
		
		idx = GetMutationIndex( mutation );
		if( idx == -1 )
		{
			return false;
		}
		
		
		if( mutations[ idx ].progress.skillpointsRequired == 0 )
		{
			return false;
		}
	
		
		if( skillPoints <= 0 )
		{
			return false;
		}
		
		
		availableSkillPoints = witcher.levelManager.GetPointsFree( ESkillPoint );
		if( availableSkillPoints < skillPoints )
		{
			return false;
		}
	
		
		if( mutations[ idx ].progress.skillpointsRequired <= mutations[ idx ].progress.skillpointsUsed )
		{
			return false;
		}
	
		
		if( mutations[ idx ].progress.skillpointsUsed + skillPoints > mutations[ idx ].progress.skillpointsRequired )
		{
			return false;
		}
	
		
		witcher.levelManager.SpendPoints( ESkillPoint, skillPoints );
		mutations[ idx ].progress.skillpointsUsed += skillPoints;
		mutations[ idx ].progress.overallProgress = -1;	
		
		
		progress = GetMutationResearchProgress( mutation );
		if( progress == 100 )
		{
			OnMutationFullyResearched( mutation );
		}
		
		return true;
	}
	
	public final function MutationResearchWithItem( mutation : EPlayerMutationType, item : SItemUniqueId, optional quantity : int ) : bool
	{
		var witcher : W3PlayerWitcher;
		var idx, redPoints, bluePoints, greenPoints, progress, missingRed, missingBlue, missingGreen : int;
		
		
		witcher = GetWitcherPlayer();
		if( owner != witcher )
		{
			return false;
		}
	
		
		idx = GetMutationIndex( mutation );
		if( idx == -1 )
		{
			return false;
		}
		
		
		if( !witcher.inv.IsIdValid( item ) )
		{
			return false;
		}
		
		
		if( mutations[ idx ].progress.blueRequired + mutations[ idx ].progress.redRequired + mutations[ idx ].progress.greenRequired == 0 )
		{
			return false;
		}
		
		
		redPoints = witcher.inv.GetMutationResearchPoints( SC_Red, item );
		greenPoints = witcher.inv.GetMutationResearchPoints( SC_Green, item );
		bluePoints = witcher.inv.GetMutationResearchPoints( SC_Blue, item );
		
		
		if(redPoints < 0 || greenPoints < 0 || bluePoints < 0 )
		{
			return false;
		}
		
		
		if( redPoints + greenPoints + bluePoints == 0 )
		{
			return false;
		}
		
		
		if( ( redPoints > 0 && mutations[ idx ].progress.redRequired == 0 ) && ( bluePoints > 0 && mutations[ idx ].progress.blueRequired == 0 ) && ( greenPoints > 0 && mutations[ idx ].progress.greenRequired == 0 ) )
		{
			return false;
		}
	
		
		if( ( redPoints > 0 && mutations[ idx ].progress.redRequired <= mutations[ idx ].progress.redUsed ) && ( bluePoints > 0 && mutations[ idx ].progress.blueRequired <= mutations[ idx ].progress.blueUsed ) && ( greenPoints > 0 && mutations[ idx ].progress.greenRequired <= mutations[ idx ].progress.greenUsed ) )
		{
			return false;
		}
		
		
		if( quantity == 0 )
		{
			quantity = 1;
		}
		
		
		missingRed = mutations[ idx ].progress.redRequired - mutations[ idx ].progress.redUsed;
		missingGreen = mutations[ idx ].progress.greenRequired - mutations[ idx ].progress.greenUsed;
		missingBlue = mutations[ idx ].progress.blueRequired - mutations[ idx ].progress.blueUsed;
		
		
		if( ( redPoints * quantity > missingRed ) || ( bluePoints * quantity > missingBlue ) || ( greenPoints * quantity > missingGreen ) )
		{
			return false;
		}
	
		
		witcher.inv.RemoveUnusedMutagensCountById( item, quantity );
		mutations[ idx ].progress.redUsed += redPoints * quantity;
		mutations[ idx ].progress.greenUsed += greenPoints * quantity;
		mutations[ idx ].progress.blueUsed += bluePoints * quantity;
		mutations[ idx ].progress.overallProgress = -1;	
		
		
		progress = GetMutationResearchProgress( mutation );
		if( progress == 100 )
		{
			OnMutationFullyResearched( mutation );
		}
		
		return true;
	}
	
	public final function GetMutationNameLocalizationKey( mutationType : EPlayerMutationType ) : name
	{
		var idx : int;
		
		idx = GetMutationIndex( mutationType );
		if( idx < 0 )
		{
			return '';
		}
		
		return mutations[ idx ].localizationNameKey;
	}
	
	public final function GetMutationDescriptionLocalizationKey( mutationType : EPlayerMutationType ) : name
	{
		var idx : int;
		
		idx = GetMutationIndex( mutationType );
		if( idx < 0 )
		{
			return '';
		}
		
		return mutations[ idx ].localizationDescriptionKey;
	}

	
	
	private final function OnMutationFullyResearched( mutationType : EPlayerMutationType )
	{
		var idx, firstLockedSlotIdx, i : int;
		var attributeName : name;
		var min, max : SAbilityAttributeValue;
		var tutEquip : W3TutorialManagerUIHandlerStateMutationsEquipping;
		
		
		idx = GetMutationIndex( EPMT_MutationMaster );
		if( idx < 0 )
		{
			return;
		}
		
		
		GetMutationResearchProgress( EPMT_MutationMaster );
		
		UpdateMutationSkillSlots();
		
		
		theGame.GetGamerProfile().AddAchievement( EA_SchoolOfTheMutant );
		
		
		if( GetResearchedMutationsCount() == 1 && !theGame.GetTutorialSystem().AreMessagesEnabled() )
		{
			SetEquippedMutation( mutationType );
		}
		
		
		if( ShouldProcessTutorial( 'TutorialMutationsEquipping' ) )
		{
			tutEquip = ( W3TutorialManagerUIHandlerStateMutationsEquipping ) theGame.GetTutorialSystem().uiHandler.GetCurrentState();
			if( tutEquip )
			{
				tutEquip.OnMutationFullyResearched();
			}
		}
	}
	
	private final function UpdateMutationSkillSlots()
	{
		var i : int;
		var skillType : ESkill;
		var skillColor : ESkillColor;
		var mutationColors : array< ESkillColor >;
		var mutType : EPlayerMutationType;
		
		UpdateMutationSkillSlotsLocks();
				
		mutType = GetEquippedMutationType();
		if( mutType != EPMT_None )
		{
			
			mutationColors = GetMutationColors( mutType );
			for( i=0; i<mutationUnlockedSlotsIndexes.Size(); i+=1 )
			{
				
				skillType = skillSlots[ mutationUnlockedSlotsIndexes[ i ] ].socketedSkill;
				if( skillType != S_SUndefined )
				{
					
					skillColor = GetSkillColor( skillType );					
					if( !mutationColors.Contains( skillColor ) )
					{
						UnequipSkill( GetSkillSlotID( skillType ) );
					}
				}
			}
		}
		else
		{
			
			for( i=0; i<mutationUnlockedSlotsIndexes.Size(); i+=1 )
			{
				skillType = skillSlots[ mutationUnlockedSlotsIndexes[ i ] ].socketedSkill;
				UnequipSkill( GetSkillSlotID( skillType ) );
			}
		}
	}
	
	private final function UpdateMutationSkillSlotsLocks()
	{
		var i, researchedCount, masterStage, unlockedCount : int;
		var tutEquip : W3TutorialManagerUIHandlerStateMutationsUnlockedSkillSlot;
		
		
		if( GetEquippedMutationType() == EPMT_None )
		{
			for( i=0; i<mutationUnlockedSlotsIndexes.Size(); i+=1 )
			{
				skillSlots[ mutationUnlockedSlotsIndexes[ i ] ].unlocked = false;
			}
		}		
		else
		{
			researchedCount = GetResearchedMutationsCount();
			masterStage = GetMasterMutationStage();
			
			for( i=0; i<mutationUnlockedSlotsIndexes.Size(); i+=1 )
			{
				if( masterStage >= i+1 && researchedCount >= GetMutationsRequiredForMasterStage( i+1 ) )
				{
					skillSlots[ mutationUnlockedSlotsIndexes[ i ] ].unlocked = true;
					
					if( ShouldProcessTutorial( 'TutorialMutationsMasterLevelUp' ) )
					{
						tutEquip = ( W3TutorialManagerUIHandlerStateMutationsUnlockedSkillSlot ) theGame.GetTutorialSystem().uiHandler.GetCurrentState();
						if( tutEquip )
						{
							tutEquip.OnMutationSkillSlotUnlocked();
						}
					}
				}
				else
				{
					skillSlots[ mutationUnlockedSlotsIndexes[ i ] ].unlocked = false;
				}
			}
		}
		
		if( ShouldProcessTutorial( 'TutorialMutationsAdditionalSkillSlot' ) )
		{
			unlockedCount = 0;
			for( i=0; i<mutationUnlockedSlotsIndexes.Size(); i+=1 )
			{
				if( skillSlots[ mutationUnlockedSlotsIndexes[ i ] ].unlocked )
				{
					unlockedCount += 1;
				}
			}
			GameplayFactsSet( "tutorial_mutations_unlocked_skill_slots", unlockedCount );
		}
	}
	
	
	
	
	
	final function Debug_HAX_UnlockSkillSlot(slotIndex : int) : bool
	{
		if(!IsSkillSlotUnlocked(slotIndex))
		{
			skillSlots[slotIndex].unlocked = true;
			LogSkills("W3PlayerAbilityManager.Debug_HAX_UnlockSkillSlot: unlocking skill slot " + slotIndex + " for debug purposes");
			return true;
		}
		
		return false;
	}
	
	final function DBG_SkillSlots()
	{
		var i : int;
		
		for(i=0; i<skillSlots.Size(); i+=1)
		{
			LogChannel('DEBUG_SKILLS', i + ") ID=" + skillSlots[i].id + " | skill=" + skillSlots[i].socketedSkill + " | groupID=" + skillSlots[i].groupID + " | unlockedAt=" + skillSlots[i].unlockedOnLevel);
		}
		
		LogChannel('DEBUG_SKILLS',"");
	}
	
	public final function DEBUG_PrintMutationSkillSlotsLocks()
	{
		var i : int;
		
		for( i=0; i<mutationUnlockedSlotsIndexes.Size(); i+=1 )
		{
			LogMutation( "Slot [" + mutationUnlockedSlotsIndexes[ i ] + "] = " + skillSlots[ mutationUnlockedSlotsIndexes[ i ] ].unlocked );
		}
	}	
}


struct STempSkill
{
	var skillType : ESkill;
	var skillLevel : int;
	var skillSlot : int;
	var equipped : bool;
	var temporary : bool;
}


exec function dbgskillslots()
{
	thePlayer.DBG_SkillSlots();
}

exec function dbgmutslots()
{
	((W3PlayerAbilityManager)thePlayer.abilityManager).DEBUG_PrintMutationSkillSlotsLocks();
}