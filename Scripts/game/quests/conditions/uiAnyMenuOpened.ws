/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_UIAnyMenuOpened extends CQuestScriptedCondition
{
	editable var inverted : bool;

	public function Evaluate() : bool
	{
		var anyMenu : bool;
		
		anyMenu = theGame.GetGuiManager().IsAnyMenu();
		
		if(inverted)
			return !anyMenu;
			
		return anyMenu;
	}
}