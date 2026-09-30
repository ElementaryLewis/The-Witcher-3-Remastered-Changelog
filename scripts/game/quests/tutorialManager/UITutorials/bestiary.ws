/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state Bestiary in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var BESTIARY_DESCRIPTION, BESTIARY_CLOSE, OPEN_BESTIARY : name;
	private var isClosing : bool;
	
		default OPEN_BESTIARY = 'TutorialBestiaryOpenBestiary';
		default BESTIARY_DESCRIPTION = 'TutorialBestiary';
		default BESTIARY_CLOSE = 'TutorialBestiaryClose';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		theGame.GetTutorialSystem().HideTutorialHint( OPEN_BESTIARY );
		ShowHint(BESTIARY_DESCRIPTION, 0.02f, 0.65f);
	}
		
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(BESTIARY_DESCRIPTION);
		CloseStateHint(BESTIARY_CLOSE);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if(closedByParentMenu || isClosing)
			return true;
			
		
		
	}
	
	event OnMenuClosing(menuName : name)
	{
		if(menuName == 'GlossaryBestiaryMenu')
			QuitState();
	}
}