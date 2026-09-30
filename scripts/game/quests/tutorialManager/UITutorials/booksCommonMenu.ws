/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state BooksCommonMenu in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var OPEN_COMMON_MENU, SELECT_GLOSSARY : name;
		
		default OPEN_COMMON_MENU	= 'TutorialBooksOpenCommonMenu';
		default SELECT_GLOSSARY		= 'TutorialBooksSelectGlossary';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		
		theGame.GetTutorialSystem().HideTutorialHint( OPEN_COMMON_MENU );
		theGame.GetTutorialSystem().MarkMessageAsSeen( OPEN_COMMON_MENU );
		
		
		ShowHint( SELECT_GLOSSARY, 0.35f, 0.65f, ETHDT_Infinite, GetHighlightHubMenuGlossary(), , , true );		
	}
	
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(SELECT_GLOSSARY);
		
		super.OnLeaveState(nextStateName);
	}	
}