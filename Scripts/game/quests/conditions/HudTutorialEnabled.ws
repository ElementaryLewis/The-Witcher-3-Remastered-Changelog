/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_HudTutorialEnabled extends CQuestScriptedCondition
{	
	editable var inverted : bool;

	function Evaluate() : bool
	{
		if(!inverted)
		{
			return (theGame.GetInGameConfigWrapper().GetVarValue('Gameplay', 'HudTutorialEnabled') == "true");
		}
		else
		{
			return (!(theGame.GetInGameConfigWrapper().GetVarValue('Gameplay', 'HudTutorialEnabled') == "false"));
		}
	}
}