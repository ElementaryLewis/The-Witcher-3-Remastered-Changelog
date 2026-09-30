/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_TutorialSystemIsAvailable extends CQuestScriptedCondition
{
	function Evaluate() : bool
	{
		var b : bool;
		
		b = theGame.GetTutorialSystem();
		b = b && theGame.GetTutorialSystem().IsRunning();
		b = b && !theGame.GetTutorialSystem().IsOnTickOptimalizationEnabled();
		b = b && theGame.GetTutorialSystem().AreMessagesEnabled();
		
		return b;
	}
}