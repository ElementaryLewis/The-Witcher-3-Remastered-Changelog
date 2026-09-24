/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_DialogOrCutsceneFinished extends CQuestScriptedCondition
{
	editable var inverted		: bool;
	
	function Evaluate() : bool
	{
		if ( inverted )
		{
			return theGame.IsDialogOrCutscenePlaying();
		}
		
		return !theGame.IsDialogOrCutscenePlaying();
	}
}