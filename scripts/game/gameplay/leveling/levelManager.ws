/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3LevelManager
{
	private var owner : W3PlayerWitcher;
	private saved var levelDefinitions : array< SLevelDefinition >;		
	private saved var level : int;										
	private saved var points : array< SSpendablePoints >;				
	private saved var lastCustomLevel : int;							
	
	public function Initialize()
	{
		var tmp : SSpendablePoints;
		var i : int;
		
		tmp.free = 0;
		tmp.used = 0;
			
		for(i=0; i<=EnumGetMax('ESpendablePointType'); i+=1)
			points.PushBack(tmp);
	}
	
	public function PostInit(own : W3PlayerWitcher, bFromLoad : bool, enableInfiniteLevels : bool)
	{
		var i, expForCurrentLevel, pool, usedPoints, freePoints, temp, expDiff : int;
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var levelDef : SLevelDefinition;
		
		owner = own;

		
		if(!bFromLoad || (enableInfiniteLevels && lastCustomLevel == 0) )
		{
			levelDefinitions.Clear();
			LoadLevelingDataFromXML();
			
			
			for(i=levelDefinitions.Size(); i>=0; i-=1)
			{
				if(levelDefinitions[i].number > lastCustomLevel)
					lastCustomLevel = levelDefinitions[i].number;
			}
		}
		
		
		if(!bFromLoad)
		{	
			level = levelDefinitions[1].number;		
		}		
		
		
		if( bFromLoad && levelDefinitions[0].number != -1 )
		{
			dm = theGame.GetDefinitionsManager();
			main = dm.GetCustomDefinition('leveling');
			
			for(i=0; i<main.subNodes.Size(); i+=1)
			{
				if( dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'number', temp) && temp == -1 )
				{
					levelDef.number = temp;
					dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'requiredTotalExp', temp);
					levelDef.requiredTotalExp = temp;
					dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'addedSkillPoints', temp);			
					levelDef.addedSkillPoints = temp;
					dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'requiredExp', temp);			
					levelDef.requiredExp = temp;
					
					levelDefinitions.Insert( 0, levelDef );
					break;
				}
			}
		}
		
		
		if( bFromLoad && levelDefinitions.Size() > 51 )
		{
			lastCustomLevel = 50;
			
			for( i=levelDefinitions.Size()-1; i>=0; i-=1 )
			{
				if( levelDefinitions[i].number > lastCustomLevel )
				{
					levelDefinitions.EraseFast(i);
				}
			}
		}
		
		
		expForCurrentLevel = GetTotalExpForCurrLevel();
		usedPoints = points[EExperiencePoint].used;
		if( bFromLoad && usedPoints < expForCurrentLevel )
		{
			
			if( FactsQuerySum( "standalone_ep1" ) > 0 )
			{
				points[EExperiencePoint].used = expForCurrentLevel;
				expDiff = expForCurrentLevel - usedPoints;
				
				
				if( expDiff > 48000 )
				{
					points[EExperiencePoint].free = expDiff - 48000;
				}
				else
				{
					points[EExperiencePoint].free = 0;
				}
			}
			else
			{
				points[EExperiencePoint].used = expForCurrentLevel;
			}
		}

		
		theTelemetry.LogWithValue(TE_HERO_LEVEL_UP, level);
	}
	
	public final function ResetCharacterDev()
	{
		var mutPoints : int;
		
		mutPoints = ( ( W3PlayerAbilityManager ) owner.abilityManager ).GetMutationsUsedSkillPoints();
		points[ ESkillPoint].free += points[ ESkillPoint ].used - mutPoints;
		points[ ESkillPoint ].used = mutPoints;	
		
		
		
		
	}
	
	public final function ResetMutationsDev()
	{
		var mutPoints : int;
		
		mutPoints = ( ( W3PlayerAbilityManager ) owner.abilityManager ).GetMutationsUsedSkillPoints();
		points[ ESkillPoint].free += mutPoints;
		points[ ESkillPoint ].used -= mutPoints;	
		
		
		
		
	}
	
	
	private function LoadLevelingDataFromXML()
	{	
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var i, temp : int;
		var levelDef : SLevelDefinition;
		var tmpLevels : array<int>;
							
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('leveling');
		
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'number', temp);	
			tmpLevels.PushBack(temp);
		}
		
		ArraySortInts(tmpLevels);
		
		
		for(i=2; i<tmpLevels.Size()-1; i+=1)
		{
			if(tmpLevels[i-1]+1 != tmpLevels[i])
			{
				LogAssert(false,"W3LevelManager.LoadLevelingDataFromXML: There is a gap in levels definitions - between levels " + tmpLevels[i-1] + " and " + tmpLevels[i]);
				return;
			}
		}
		
		
		LogChannel('Leveling',"W3LevelManager.LoadLevelingDataFromXML: min level is " + tmpLevels[0] + ", max level is " + tmpLevels[tmpLevels.Size()-1]);
		
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'number', temp);				
			levelDef.number = temp;
			dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'requiredTotalExp', temp);
			levelDef.requiredTotalExp = temp;
			dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'addedSkillPoints', temp);			
			levelDef.addedSkillPoints = temp;
			dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'requiredExp', temp);			
			levelDef.requiredExp = temp;
			
			levelDefinitions.PushBack(levelDef);
			
			levelDef.requiredExp = 0;
			levelDef.requiredTotalExp = 0;
		}
	}
	
	public function SetFreeSkillPoints(amount : int)
	{
		points[ESkillPoint].free = amount;
	}
		
	
	public function AddPoints(type : ESpendablePointType, amount : int, show : bool )
	{
		var total : int;
		var arrInt : array<int>;
		var hudWolfHeadModule : CR4HudModuleWolfHead;		
		var hud : CR4ScriptedHud;
		var extraLevels: int;
		hud = (CR4ScriptedHud)theGame.GetHud();
	
		if(amount <= 0)
		{
			LogAssert(false, "W3LevelManager.AddPoints: amount of <<" + type + ">> is <= 0 !!!");
			return;
		}
		
		if( type == EExperiencePoint && GetLevel() == GetMaxLevel() )
		{
			return;				
		}

		points[type].free += amount;

		if(type == EExperiencePoint)
		{
			
			if ( FactsQuerySum("NewGamePlus") > 0 )
			{
				if ( theGame.params.GetNewGamePlusLevel() - theGame.params.NEW_GAME_PLUS_MIN_LEVEL > 0 )
				{
					extraLevels = theGame.params.GetNewGamePlusLevel() - theGame.params.NEW_GAME_PLUS_MIN_LEVEL;
				}
			}
			
			if(FactsQuerySum("NewGamePlus") > 0 && GetLevel() < 50 + extraLevels)
			{
				points[type].free += amount;
				amount *= 2;
			}
			
			
			while(true)
			{
				total = GetTotalExpForNextLevel();
				if(total > 0 && GetPointsTotal(EExperiencePoint) >= total)
				{
					if( GainLevel( show ) )
					{
						GetWitcherPlayer().AddAbility( GetWitcherPlayer().GetLevelupAbility( GetWitcherPlayer().GetLevel() ) );
					}
					else
					{
						break;
					}
				}
				else
				{
					break;
				}
			}
			
			
			if( GetLevel() == GetMaxLevel() )
			{
				amount -= 2 * points[type].free;	
				points[type].free = 0;
			}
		
			theTelemetry.LogWithValue(TE_HERO_EXP_EARNED, amount);
			
			arrInt.PushBack(amount);
			
			
			hud.OnExperienceUpdate(amount, show);
		}
		else if(type == ESkillPoint)
		{
			theTelemetry.LogWithValue(TE_HERO_SKILL_POINT_EARNED, amount);
			
			
			hudWolfHeadModule = (CR4HudModuleWolfHead)hud.GetHudModule( "WolfHeadModule" );
			if ( hudWolfHeadModule )
			{
				hudWolfHeadModule.ShowLevelUpIndicator(show);
			}
		}
	}
	
	
	public function SpendPoints(type : ESpendablePointType, amount : int)
	{
		if(amount <= 0)
		{
			LogAssert(false, "W3LevelManager.SpendPoints: amount to spend is <=0");
			return;
		}
		if( points[type].free >= amount )
		{
			points[type].free -= amount;
			points[type].used += amount;
		}
		else
		{
			LogAssert(false, "W3LevelManager.SpendPoints: trying to spend more than you have!");
		}
	}
	
	
	public final function UnspendPoints(type : ESpendablePointType, amount : int)
	{
		if(amount <= 0)
		{
			LogAssert(false, "W3LevelManager.UnspendPoints: amount to restore is <=0");
			return;
		}
		if( points[type].used >= amount )
		{
			points[type].free += amount;
			points[type].used -= amount;
		}
		else
		{
			LogAssert(false, "W3LevelManager.UnspendPoints: trying to restore more than you have spent!");
		}
	}
	
	public function GetPointsFree(type : ESpendablePointType) : int			{return points[type].free;}	
	public function GetPointsUsed(type : ESpendablePointType) : int			{return points[type].used;}
	public function GetPointsTotal(type : ESpendablePointType) : int		{return points[type].free + points[type].used;}
	public function GetLevel() : int										{return level;}
	public function GetMaxLevel() : int										{return 100;}
	
	private final function GetLevelDefinition(level : int) : SLevelDefinition
	{
		var temp : SLevelDefinition;
		var levelsOverMax : int;
		
		
		if(level > lastCustomLevel)
		{
			levelsOverMax = level - lastCustomLevel;
		
			temp.number = level;
			temp.addedSkillPoints = levelDefinitions[0].addedSkillPoints;
			temp.requiredTotalExp = levelDefinitions[lastCustomLevel].requiredTotalExp + levelsOverMax * levelDefinitions[0].requiredExp;
			
			return temp;
		}
		else
		{
			return levelDefinitions[level];
		}
	}
	
	
	public function GetTotalExpForCurrLevel() : int
	{
		var levelDef : SLevelDefinition;
		
		levelDef = GetLevelDefinition(level);
		return levelDef.requiredTotalExp;
	}
	
	
	public function GetTotalExpForNextLevel() : int							
	{
		var nextLevelDef : SLevelDefinition;
		
		nextLevelDef = GetLevelDefinition(level + 1);
		return nextLevelDef.requiredTotalExp;
	}
	
	public function GetTotalExpForGivenLevel( i : int ) : int
	{
		var levelDef		: SLevelDefinition;
		
		levelDef = GetLevelDefinition( i );
		return levelDef.requiredTotalExp;
	}
		
	public function GainLevel( show : bool ) : bool
	{
		var totalExp : int;
		var newLevelDef : SLevelDefinition;
	
		if(level == GetMaxLevel())
		{
			LogAssert(false, "W3LevelManager.GainLevel: already at max level, so why trying to gain a level?");
			return false;
		}
		
		level += 1;
		
		newLevelDef = GetLevelDefinition(level);
		
		totalExp = points[EExperiencePoint].used + points[EExperiencePoint].free;
		
		points[EExperiencePoint].used = newLevelDef.requiredTotalExp;
		points[EExperiencePoint].free = totalExp - points[EExperiencePoint].used;
		
		theTelemetry.LogWithValue(TE_HERO_LEVEL_UP, level);
		
		if(newLevelDef.addedSkillPoints > 0)
			AddPoints(ESkillPoint, newLevelDef.addedSkillPoints, show);
			
		owner.OnLevelGained(level, show);
		
		return true;
	}
	
	public function AutoLevel()
	{
		var dm 									: CDefinitionsManagerAccessor;
		var main 								: SCustomNode;
		var skills 								: array<SSkill>;
		var skillType							: ESkill;
		var i, priority, freePoints, tmpInt		: int;
		var tmpName								: name;
		var type								: ESpendablePointType;
		
		skills = thePlayer.GetPlayerSkills();
		dm = theGame.GetDefinitionsManager();
		type = ESkillPoint;
		
		freePoints = GetPointsFree( type );
		tmpInt = 1;
		
		for( i=0; i<skills.Size(); i+=1 )
		{
			dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'priority', priority);
			dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'skill_name', tmpName);
			skillType = SkillNameToEnum(tmpName);
			
			if( freePoints > 0 && GetWitcherPlayer().CanLearnSkill( skills[i].skillType ) && priority == tmpInt )
			{
				tmpInt += 1;
				GetWitcherPlayer().AddSkill(skills[i].skillType, true);
				skills.Erase(i);
			}			
		}
	}
	
	public function Hack_EP2StandaloneLevelShrink( lev : int )
	{
		var l_expForEP2Level	: int;
		var l_i					: int;
		
		for( l_i = GetLevel() ; l_i > lev ; l_i -= 1 )
		{
			GetWitcherPlayer().RemoveAbility( GetWitcherPlayer().GetLevelupAbility( l_i ) );
		} 
		
		
		level = 1;
		points[ EExperiencePoint ].free = 0;
		points[ EExperiencePoint ].used = 0;		
		points[ ESkillPoint ].free = 0;
		points[ ESkillPoint ].used = 0;
		
		l_expForEP2Level = GetTotalExpForGivenLevel( lev );
		AddPoints( EExperiencePoint, l_expForEP2Level, false );
		
		AddPoints( ESkillPoint, 10, false );
	}
	
	
	public function NGE_SetUsedPoints(amount : int)
	{
		points[ ESkillPoint ].used = amount;
	}
	
	public function NGE_SetFreePoints(amount : int)
	{
		points[ ESkillPoint ].free = amount;
	}
	
}