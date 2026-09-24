/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EQuestPlayerSkillLevel
{
	EQPSL_Skill,
	EQPSL_DialogAxiiLevel
}

enum EQuestPlayerSkillCondition
{
	EQPSC_Equipped,
	EQPSC_Learned,
	EQPSC_LearnedButNotEquipped
}

struct SQuestPlayerSkill
{
	editable var skill : ESkill;
	editable var skillLevel : int;
	editable var condition : EQuestPlayerSkillCondition;
};

class W3QuestCond_PlayerSkillLevel extends CQuestScriptedCondition
{
	editable var mode : EQuestPlayerSkillLevel;
	editable var skills : array<SQuestPlayerSkill>;
	editable var dialogAxiiLevel : int;
	
	hint mode = "Choose between skill level check and Dialog Axii Level check";

	function Evaluate() : bool
	{	
		var witcher : W3PlayerWitcher;
		var isSkill, isEquipped, knowsSkill : bool;
		var i: int;
	
		witcher = GetWitcherPlayer();
		
		if(mode == EQPSL_DialogAxiiLevel)
		{
			return witcher.GetAxiiLevel() >= dialogAxiiLevel;
		}
		else
		{
			for(i=0; i<skills.Size(); i+=1)
			{
				
				knowsSkill = witcher.HasLearnedSkill(skills[i].skill);
				
				if(!knowsSkill)
					return false;
				
				
				isEquipped = witcher.IsSkillEquipped(skills[i].skill);
			
				if(skills[i].condition == EQPSC_Equipped)
				{
					if(!isEquipped)
						return false;
				}
				else if(skills[i].condition == EQPSC_LearnedButNotEquipped)
				{
					if(isEquipped)
						return false;
				}
				
				
				if(witcher.GetSkillLevel(skills[i].skill) < skills[i].skillLevel)
					return false;
			}
			
			return true;
		}
	}
}