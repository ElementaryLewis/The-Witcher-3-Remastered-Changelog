/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state RecipePinning in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var PIN, SHOP : name;
	private var isClosing : bool;
	
		default PIN 	= 'TutorialCraftingPin';
		default SHOP	= 'TutorialCraftingPin2';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		ShowHint(PIN, POS_ALCHEMY_X, POS_ALCHEMY_Y);
	}
	
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(PIN);
		CloseStateHint(SHOP);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnMenuClosing(menuName : name)
	{
		super.OnMenuClosing(menuName);
		
		
		if(menuName == 'AlchemyMenu')
			theGame.GameplayFactsAdd("tutorial_alchemy_pin_done", 1);
		else if(menuName == 'CraftingMenu')
			theGame.GameplayFactsAdd("tutorial_craft_pin_done", 1);
		
		QuitState();
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == PIN)
		{
			ShowHint(SHOP, POS_ALCHEMY_X, POS_ALCHEMY_Y);
		}		
	}	
}