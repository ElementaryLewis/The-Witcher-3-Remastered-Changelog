/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_TutorialWasSeen extends CQuestScriptedCondition
{
	editable var tutorialScriptTag : name;
		
	function Evaluate() : bool
	{
		if(theGame.GetTutorialSystem() && theGame.GetTutorialSystem().IsRunning())
			return theGame.GetTutorialSystem().HasSeenTutorial(tutorialScriptTag);
			
		return false;
	}
}