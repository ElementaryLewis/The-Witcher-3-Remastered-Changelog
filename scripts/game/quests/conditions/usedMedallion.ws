/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_UsedMedallion extends CQuestScriptedCondition
{
	var medallion : W3MedallionController;
		
	function Evaluate() : bool
	{	
		if ( !medallion && GetWitcherPlayer() )
		{
			medallion = GetWitcherPlayer().GetMedallion();
		}
		if ( medallion )
		{
			return medallion.IsActive();
		}
		return false;
	}
}