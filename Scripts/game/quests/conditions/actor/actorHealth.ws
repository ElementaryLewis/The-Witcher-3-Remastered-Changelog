/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_Health extends CQCActorScriptedCondition
{
	editable var condition : ECompareOp;
	editable var percents : int;	
	
	default condition = CO_Lesser;
	
	hint percents = "Percentage of actor max health [0-100]";

	function Evaluate(act : CActor ) : bool
	{		
		var hpp : float;
		var hppi : int;

		hpp = act.GetHealthPercents();
		
		if(hpp == -1)
			return false;
			
		hppi = FloorF(100 * hpp);
	
		return ProcessCompare(condition, hppi, percents);
	}
}