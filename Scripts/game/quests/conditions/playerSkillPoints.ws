/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_PlayerSkillPoints extends CQuestScriptedCondition
{
	editable var freeSkillPoints : int;
	editable var comparator : ECompareOp;

	function Evaluate() : bool
	{
		var witcher : W3PlayerWitcher;
		
		witcher = GetWitcherPlayer();
		if(!witcher)
		{
			return false;
		}
		
		return ProcessCompare( comparator, witcher.levelManager.GetPointsFree(ESkillPoint), freeSkillPoints );
	}
}