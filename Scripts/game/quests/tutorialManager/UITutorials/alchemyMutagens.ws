/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state AlchemyMutagens in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var MUTAGENS : name;	
	private var currentlySelectedRecipe, requiredRecipeName, selectRecipe : name;
	
		default MUTAGENS 		= 'TutorialMutagenPotion';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		currentlySelectedRecipe = '';
	}
			
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(MUTAGENS);
		super.OnLeaveState(nextStateName);
	}
		
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		QuitState();
	}
	
	public final function CookedItem(recipeName : name)
	{
		if(theGame.GetDefinitionsManager().IsRecipeForMutagenPotion(recipeName))
		{		
			ShowHint(MUTAGENS, POS_ALCHEMY_X, POS_ALCHEMY_Y);
		}
	}
}
exec function tut_alch_mut()
{
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	TutorialScript('MutagenPotion', '');
}