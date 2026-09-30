/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state IngameMenuBestiary in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var OPEN_GLOSSARY, OPEN_GAME_MENU : name;
	
		default OPEN_GLOSSARY = 'TutorialBestiaryOpenGlossary';
		default OPEN_GAME_MENU = 'TutorialBestiaryOpenMenu';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		theGame.GetTutorialSystem().HideTutorialHint( OPEN_GAME_MENU );
				
		ShowHint( OPEN_GLOSSARY, 0.65f, 0.65f, ETHDT_Infinite, GetHighlightHubMenuGlossary() );
	}
		
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(OPEN_GLOSSARY);
		
		super.OnLeaveState(nextStateName);
	}

	event OnMenuClosing(menuName : name)
	{		
		QuitState();
	}
}