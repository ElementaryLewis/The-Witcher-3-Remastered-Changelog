/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state BooksCommonMenuSubmenu in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var SELECT_BOOKS : name;
		
		default SELECT_BOOKS 		= 'TutorialBooksOpenBooks';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		ShowHint( SELECT_BOOKS, 0.35f, 0.65f, ETHDT_Infinite, GetHighlightHubMenuBooks() );	
	}
	
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(SELECT_BOOKS);
		
		super.OnLeaveState(nextStateName);
	}	
}