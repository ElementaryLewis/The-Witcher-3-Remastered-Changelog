/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_PlayerHasQuenActive extends CQuestScriptedCondition
{
	editable var inverted : bool;
	
	function Evaluate() : bool
	{
		var witcher : W3PlayerWitcher;
		var quen : W3QuenEntity;
		
		witcher = GetWitcherPlayer();
		if(!witcher)
			return inverted;
		
		quen = (W3QuenEntity)witcher.GetSignEntity(ST_Quen);
		if(!quen)
			return inverted;
			
		if(inverted)
			return !quen.IsAnyQuenActive();
		
		return quen.IsAnyQuenActive();
	}
}