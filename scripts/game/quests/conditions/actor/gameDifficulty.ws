/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_gameDifficulty extends CQuestScriptedCondition
{
	editable var targetDifficulty : EDifficultyMode;
	
	function Evaluate() : bool
	{
		if(theGame.GetDifficultyMode() == targetDifficulty)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
}