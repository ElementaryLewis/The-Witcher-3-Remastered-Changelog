/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state BooksNew in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var BOOKS_PANEL, NAVIGATION, OPEN_GLOSSARY : name;
	private var isClosing : bool;
	
		default BOOKS_PANEL 	= 'TutorialBooksPanel';
		default NAVIGATION 		= 'TutorialBooksNavigation';
		default OPEN_GLOSSARY	= 'TutorialBooksOpenCommonMenu';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		theGame.GetTutorialSystem().HideTutorialHint( OPEN_GLOSSARY );
		theGame.GetTutorialSystem().MarkMessageAsSeen( OPEN_GLOSSARY );
		
		ShowHint(BOOKS_PANEL, 0.4, 0.7, ETHDT_Input);
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(BOOKS_PANEL);
		CloseStateHint(NAVIGATION);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(BOOKS_PANEL);
		
		super.OnLeaveState(nextStateName);
	}

	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == BOOKS_PANEL)
		{
			ShowHint(NAVIGATION, 0.4, 0.7, ETHDT_Input);
		}
		else
		{
			QuitState();
		}
	}
}