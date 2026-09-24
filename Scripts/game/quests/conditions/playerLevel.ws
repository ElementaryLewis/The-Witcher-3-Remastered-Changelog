/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_PlayerLevel extends CQuestScriptedCondition
{
	editable var level : int;
	editable var comparator : ECompareOp;
	editable var useComparator : bool;
	var returnValue : bool;


	function Evaluate() : bool
	{
		var witcher : W3PlayerWitcher;
		
		if(level <= 0)
		{
			LogQuest("W3QuestCond_PlayerLevel: level must be at least 1, aborting");
			return false;
		}
		
		witcher = GetWitcherPlayer();
		if(!witcher)
		{
			return false;
		}
		
		if( useComparator )
		{
			switch ( comparator )
			{
				case CO_Lesser :
				{
					returnValue = witcher.levelManager.GetLevel() < level;
				}
				break; 
				
				case CO_LesserEq :
				{
					returnValue = witcher.levelManager.GetLevel() <= level;
				}
				break;
				
				case CO_Greater :
				{
					returnValue = witcher.levelManager.GetLevel() > level;
				}
				break;
				
				case CO_GreaterEq :
				{
					returnValue = witcher.levelManager.GetLevel() >= level;
				}
				break;	
				
				case CO_Equal :
				{
					returnValue = witcher.levelManager.GetLevel() == level;
				}
				break;	
				
				case CO_NotEqual :
				{
					returnValue = witcher.levelManager.GetLevel() != level;
				}
				break;			
				
			}
			
			return returnValue;
		}
		else
		{
			return witcher.levelManager.GetLevel() >= level;
		}
		

	}
}