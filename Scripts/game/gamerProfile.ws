/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3GamerProfile
{
	private var statistics : array<SStatistic>;
	private var achievementDefinitions : array<SAchievement>;				
	
	public function AddAchievement(a : EAchievement)
	{
		theGame.UnlockAchievement(AchievementEnumToName(a));
		LogAchievements("Achievement <<" + a + ">> unlocked!");
	}
	
	public function NoticeAchievementProgress(a : EAchievement, countNew : int, optional towards : int )
	{
		theGame.NoticeAchievementProgress(AchievementEnumToName(a), countNew, towards);
	}		
	
	
	public function Init()
	{
		LoadXMLAchievementData();
		InitStats();
		RegisterAchievements();
	}
		
	
	public function InitStats()
	{
		
		InitStat(ES_CharmedNPCKills);
		InitStat(ES_AardFallKills);
		InitStat(ES_EnvironmentKills);
		InitStat(ES_CounterattackChain);
		InitStat(ES_DragonsDreamTriggers);
		InitStat(ES_KnownPotionRecipes);
		InitStat(ES_KnownBombRecipes);
		InitStat(ES_ReadBooks);
		InitStat(ES_HeadShotKills);
		InitStat(ES_BleedingBurnedPoisoned);
		InitStat(ES_DestroyedNests);
		InitStat(ES_FundamentalsFirstKills);
		InitStat(ES_FinesseKills);
		InitStat(ES_SelfArrowKills);
		InitStat(ES_ActivePotions);
		InitStat(ES_KilledCows);
		InitStat(ES_SlideTime);
	}
	
	
	private function RegisterAchievements()
	{
		
		RegisterAchievement(ES_CharmedNPCKills, EA_EnemyOfMyFriend);
		RegisterAchievement(ES_AardFallKills, EA_FusSthSth);
		RegisterAchievement(ES_EnvironmentKills, EA_EnvironmentUnfriendly);
		RegisterAchievement(ES_CounterattackChain, EA_TrainedInKaerMorhen);
		RegisterAchievement(ES_DragonsDreamTriggers, EA_TheEvilestThing);
		RegisterAchievement(ES_KnownPotionRecipes, EA_BreakingBad);
		RegisterAchievement(ES_KnownBombRecipes, EA_Bombardier);
		RegisterAchievement(ES_BleedingBurnedPoisoned, EA_Rage);
		RegisterAchievement(ES_HeadShotKills, EA_TechnoProgress);
		RegisterAchievement(ES_ReadBooks, EA_Bookworm);
		RegisterAchievement(ES_DestroyedNests, EA_FireInTheHole);
		RegisterAchievement(ES_FundamentalsFirstKills, EA_FundamentalsFirst);
		RegisterAchievement(ES_FinesseKills, EA_Finesse);
		RegisterAchievement(ES_SelfArrowKills, EA_FeatherStrongerThanSword);
		RegisterAchievement(ES_ActivePotions, EA_Thirst);
		RegisterAchievement(ES_KilledCows, EA_WantedDeadOrBovine);
		RegisterAchievement(ES_SlideTime, EA_Slide);
	}

	private function LoadXMLAchievementData()
	{
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var i, tmpInt : int;
		var tmpName : name;
		var achievement : SAchievement;
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('achievements');

		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			
			if(!dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName))
				continue;
				
			achievement.type = AchievementNameToEnum(tmpName);
			
			
			if(achievement.type == EA_Undefined)
				continue;
				
			
			if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'requiredValue', tmpInt))
				achievement.requiredValue = tmpInt;
						
			achievementDefinitions.PushBack(achievement);
			
			achievement.type = EA_Undefined;
			achievement.requiredValue = -1;
		}
	}
	
	private function GetAchievementIndex(a : EAchievement) : int
	{
		var i : int;
		
		for(i=0; i<achievementDefinitions.Size(); i+=1)
			if(achievementDefinitions[i].type == a)
				return i;
				
		return -1;
	}
	
	public function CheckLearningTheRopes()
	{
		var doneRopes : int;
		doneRopes = 0;

		if(FactsQuerySum("ach_counter") == 1)
			doneRopes += 1;
		if(FactsQuerySum("ach_attack") == 1)
			doneRopes += 1;
		if(FactsQuerySum("ach_sign") == 1)
			doneRopes += 1;
		if(FactsQuerySum("ach_bomb") == 1)
			doneRopes += 1;
			
		if(doneRopes >= 4)
		{
			AddAchievement(EA_LearningTheRopes);
		}		
		else
		{
			NoticeAchievementProgress(EA_LearningTheRopes, doneRopes);
		}
	}
	
	public final function CheckTrialOfGrasses()
	{
		var witcher : W3PlayerWitcher;
		var doneMutagens : int;
		
		witcher = GetWitcherPlayer();
		if(!witcher)
			return;
		
		
		doneMutagens = 0;
		if(witcher.IsAnyItemEquippedOnSlot(EES_SkillMutagen4))
			doneMutagens += 1;
		if(witcher.IsAnyItemEquippedOnSlot(EES_SkillMutagen3))
			doneMutagens += 1;
		if(witcher.IsAnyItemEquippedOnSlot(EES_SkillMutagen2))
			doneMutagens += 1;
		if(witcher.IsAnyItemEquippedOnSlot(EES_SkillMutagen1))
			doneMutagens += 1;

		if(doneMutagens >= 4)
		{
			AddAchievement(EA_TrialOfGrasses);
		}
		else
		{
			NoticeAchievementProgress(EA_TrialOfGrasses, doneMutagens);
		}
	}
		
	
	
	
	
	
	public function ResetStat(statEnum : EStatistic)
	{
		var i, idx : int;
		var statName : name;
	
		idx = GetStatisticIndex(statEnum);
		if(idx < 0)
			return;
			
		statName = StatisticEnumToName(statEnum);
		FactsRemove(statName);
		FactsAdd(statName, 0);
	}
	
	public function GetStatValue(statEnum : EStatistic) : int
	{
		var idx : int;
	
		idx = GetStatisticIndex(statEnum);
		if(idx < 0)
			return -1;
			
		return FactsQuerySum(StatisticEnumToName(statEnum));
	}
	
	
	public function IncStat(statEnum : EStatistic)
	{
		var idx : int;
	
		idx = GetStatisticIndex(statEnum);
		if(idx < 0)
			return;
			
		FactsAdd(StatisticEnumToName(statEnum));
		CheckProgress(statEnum);
	}
	
	
	public function SetStat(statEnum : EStatistic, val : int)
	{
		var idx : int;
	
		idx = GetStatisticIndex(statEnum);
		if(idx < 0)
			return;
			
		FactsSet(StatisticEnumToName(statEnum), val);
		CheckProgress(statEnum);
	}
	
	
	public function DecStat(statEnum : EStatistic)
	{
		var idx : int;
	
		idx = GetStatisticIndex(statEnum);
		if(idx < 0)
			return;
			
		FactsSubstract(StatisticEnumToName(statEnum), 1);
	}
	
	
	private function CheckProgress(statEnum : EStatistic)
	{
		var i, idx : int;
		var achievementType : EAchievement;
		var statName : name;
		var currStatVal, topVal : int;
	
		idx = GetStatisticIndex(statEnum);
		statName = StatisticEnumToName(statEnum);
		currStatVal = FactsQuerySum(statName);
		
		
		for(i=statistics[idx].registeredAchievements.Size()-1; i>=0; i-=1)
		{
			achievementType = statistics[idx].registeredAchievements[i].type;
			topVal = (int)(statistics[idx].registeredAchievements[i].requiredValue);
			
			
			if(topVal <= currStatVal)
			{
				
				AddAchievement(achievementType);
			}
			else 
			{
				NoticeAchievementProgress(achievementType, currStatVal, topVal);
			}
		}		
	}
	
	public function CheckProgressOfAllStats()
	{
		var i : int;
	
		for( i = 0; i < statistics.Size(); i+=1 )
			CheckProgress( statistics[i].statType );
	}
	
	
	private function GetStatisticIndex(statEnum : EStatistic) : int
	{
		var i : int;
		
		for(i=0; i<statistics.Size(); i+=1)
		{
			if(statistics[i].statType == statEnum)
				return i;
		}
		
		return -1;
	}
		
	
	private function RegisterAchievement(statEnum : EStatistic, ac : EAchievement)
	{
		var idx, aInd : int;
		
		idx = GetStatisticIndex(statEnum);
		if(idx < 0)
		{
			LogAchievements("Cannot register achievement <<" + ac + ">> to game statistics - statistic <<" + statEnum + ">> is no longer updated!");
			return;
		}
		
		aInd = GetAchievementIndex(ac);
		if(aInd < 0)
		{
			LogAchievements("Cannot register achievement <<" + ac + ">> to game statistics - achievement already achieved!");
			return;
		}
		statistics[idx].registeredAchievements.PushBack(achievementDefinitions[aInd]);
	}
	
	
	private function InitStat(statEnum : EStatistic)
	{
		var stat : SStatistic;
	
		if(FactsQuerySum(StatisticEnumToName(statEnum)) == -1)	
			return;
		
		stat.statType = statEnum;
		statistics.PushBack(stat);
	}
	
	public final function ClearAllAchievementsForEP1()
	{
		var unlockedAchievments : array<name>;
		var i : int;
		
		theGame.GetUnlockedAchievements(unlockedAchievments);
		for(i=0; i<unlockedAchievments.Size(); i+=1)
		{
			theGame.LockAchievement(unlockedAchievments[i]);
		}
		
		
		SetStat(ES_CharmedNPCKills, 0);
		SetStat(ES_AardFallKills, 0);
		SetStat(ES_EnvironmentKills, 0);
		SetStat(ES_CounterattackChain, 0);
		SetStat(ES_DragonsDreamTriggers, 0);
		SetStat(ES_BleedingBurnedPoisoned, 0);
		SetStat(ES_HeadShotKills, 0);
		SetStat(ES_FundamentalsFirstKills, 0);
		SetStat(ES_ReadBooks, 0);
		SetStat(ES_DestroyedNests, 0);
	}
	
	public final function ClearAllAchievementsForEP2()
	{
		
		ClearAllAchievementsForEP1();
		
		
		SetStat( ES_SelfArrowKills, 0 );
		SetStat( ES_ActivePotions, 0 );
		SetStat( ES_KilledCows, 0 );
		SetStat( ES_SlideTime, 0 );
	}
	
	public final function Debug_PrintAchievements()
	{
		var achievement : EAchievement;
		var currVal, i, j, k : int;
		var goto : bool;
		var allFTs, foundFTs : array< SAvailableFastTravelMapPin >;
		var areaMapPins : array< SAreaMapPinInfo >;
		var entityMapPins : array< SEntityMapPinInfo >;
		
		LogAchievements("");
		LogAchievements("Printing current achievements' status:");
		
		
		for(i=0; i<statistics.Size(); i+=1)
		{
			for(j=0; j<statistics[i].registeredAchievements.Size(); j+=1)
			{
				achievement = statistics[i].registeredAchievements[j].type;				
				currVal = FactsQuerySum(StatisticEnumToName(statistics[i].statType));
				LogAchievements(achievement + ", progress: " + NoTrailZeros(currVal) + "/" + NoTrailZeros(statistics[i].registeredAchievements[j].requiredValue));
			}
		}
		
		
		foundFTs = theGame.GetCommonMapManager().GetFastTravelPoints(true, false, false, true, true);
		allFTs = theGame.GetCommonMapManager().GetFastTravelPoints(false, false, false, false, true);
		LogAchievements(EA_Explorer + ", progress: " + foundFTs.Size() + "/100");
		if(foundFTs.Size() < 100)
		{
			
			for(i=allFTs.Size()-1; i>=0; i-=1)
			{
				for(j=0; j<foundFTs.Size(); j+=1)
				{
					if(allFTs[i].tag == foundFTs[j].tag && allFTs[i].type == foundFTs[j].type && allFTs[i].area == foundFTs[j].area)
					{
						allFTs.EraseFast(i);
						break;
					}
				}
			}
			
			
			areaMapPins = theGame.GetCommonMapManager().GetAreaMapPins();
			LogAchievements("");
			LogAchievements(EA_Explorer + ": missing " + (100 - foundFTs.Size()) + " FT points, coords:");
			
			for(k=0; k<allFTs.Size(); k+=1)
			{
				goto = false;
				
				
				for ( i = 0; i < areaMapPins.Size(); i += 1 )
				{
					entityMapPins.Clear();
					entityMapPins = theGame.GetCommonMapManager().GetEntityMapPins( areaMapPins[ i ].worldPath );
					for ( j = 0; j < entityMapPins.Size(); j += 1 )
					{
						if(entityMapPins[j].entityType == allFTs[k].type && entityMapPins[j].entityName == allFTs[k].tag && areaMapPins[i].areaName == allFTs[k].area)
						{
							LogAchievements( SpaceFill(allFTs[k].tag,35,ESFM_JustifyLeft) + " in   " + SpaceFill(allFTs[k].area,30,ESFM_JustifyLeft) + " at:   x=" + SpaceFill(RoundMath(entityMapPins[j].entityPosition.X),5,ESFM_JustifyRight) + ", y=" + SpaceFill(RoundMath(entityMapPins[j].entityPosition.Y),5,ESFM_JustifyRight) + ", z=" + SpaceFill(RoundMath(entityMapPins[j].entityPosition.Z),5,ESFM_JustifyRight) );
							goto = true;
							break;
						}
					}
					
					if(goto)
						break;
				}
			}
		}
		
		
		LogAchievements("");
	}
}

exec function UnlockAllAchievements()
{
	var gamerProfile : W3GamerProfile;
	var i : int;
	
	gamerProfile = theGame.GetGamerProfile();
	for( i = 0; i <= EnumGetMax('EAchievement'); i += 1 )
	{
		gamerProfile.AddAchievement(i);
	}
}

exec function achieve(a : EAchievement)
{
	theGame.GetGamerProfile().AddAchievement(a);	
}

exec function achievei(i : int)
{
	var a : EAchievement;
	
	a = i;
	theGame.GetGamerProfile().AddAchievement(a);	
}

exec function printach()
{
	theGame.GetGamerProfile().Debug_PrintAchievements();
}