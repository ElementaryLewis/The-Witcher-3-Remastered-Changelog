/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state AlchemyBuy in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var BUY : name;
	private var isClosing : bool;
	
		default BUY = 'TutorialAlchemyBuy';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;		
	}
	
	
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint( BUY );
		
		LogTutorial( "UIHandler: leaving state <" + this + ">, next will be <" + nextStateName + ">" );
		
		if( theGame.GetTutorialSystem().HasSeenTutorial( BUY ) )
		{
			theGame.GetTutorialSystem().uiHandler.UnregisterUIState(GetStateName());
		}
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if(closedByParentMenu || isClosing)
			return true;
			
		if( hintName == BUY )
		{
			QuitState();
		}
	}
	
	event OnCanSellSomething()
	{
		ShowHint( BUY, POS_ALCHEMY_X, POS_ALCHEMY_Y, ETHDT_Input, GetHighlightCraftingIngredients(), , , true );
	}
}