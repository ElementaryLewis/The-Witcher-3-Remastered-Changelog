/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state FastTravel in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var FAST_TRAVEL, INTERACTION : name;
	private var isClosing : bool;
	
		default INTERACTION = 'TutorialFastTravelInteraction';
		default FAST_TRAVEL = 'TutorialFastTravelHighlight';
	
	event OnEnterState( prevStateName : name )
	{
		isClosing = false;
		
		super.OnEnterState(prevStateName);
		
		theGame.GetTutorialSystem().HideTutorialHint( INTERACTION );
		theGame.GetTutorialSystem().MarkMessageAsSeen(INTERACTION);
		FactsAdd("tut_FT_interaction_finish");	
		ShowHint(FAST_TRAVEL, POS_MAP_X, POS_MAP_Y, ETHDT_Input);
	}
		
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(FAST_TRAVEL);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(FAST_TRAVEL);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if(closedByParentMenu || isClosing)
		{
			return true;
		}		

		if( hintName == FAST_TRAVEL )
		{
			QuitState();
		}
	}
}

exec function tut_ft()
{
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	TutorialScript('fast_travel', '');
}