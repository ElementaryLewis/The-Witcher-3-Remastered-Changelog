/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_BaseStat extends CQCActorScriptedCondition
{
	editable var stat : EBaseCharacterStats;
	editable var condition : ECompareOp;
	editable var percents : int;	
	
	default condition = CO_Lesser;
	
	hint percents = "Percentage of actor max stat [0-100]";

	public function Evaluate(act : CActor ) : bool
	{		
		var perc : float;
		
		perc = act.GetStatPercents(stat);
		
		
		if(perc == -1)
			return false;
			
		return ProcessCompare(condition, RoundMath(perc * 100), percents);
	}
}