/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_GlobalAttitude extends CQuestScriptedCondition
{

	editable var srcGroup : name;
	editable var dstGroup : name;
	editable var attitude : EAIAttitude;
	

	function Evaluate() : bool
	{		
		return ( theGame.GetGlobalAttitude( srcGroup, dstGroup ) == attitude );
	}
}