/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state Map in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var OPEN_MAP, JUMP_TO_OBJECTIVE, NAVIGATE, QUEST_PINS, OBJECTIVES, AREA_MAP : name;
	private var DESCRIPTION : name;
	private var isClosing : bool;
	
		default OPEN_MAP 			= 'TutorialMapOpenMap';
		default DESCRIPTION 		= 'TutorialMapDescription';
		default JUMP_TO_OBJECTIVE 	= 'TutorialMapJumpToObjective';
		default NAVIGATE 			= 'TutorialMapNavigate';
		default QUEST_PINS 			= 'TutorialMapQuestPins';
		default OBJECTIVES			= 'TutorialMapObjectives';
		default AREA_MAP			= 'TutorialMapAreaMap';
	
	event OnEnterState( prevStateName : name )
	{	
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		
		theGame.GetTutorialSystem().HideTutorialHint( OPEN_MAP );
		
		ShowHint(DESCRIPTION, POS_MAP_X, POS_MAP_Y - 0.075f, ETHDT_Input);
		theGame.GetTutorialSystem().MarkMessageAsSeen( DESCRIPTION );
	}
	
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint( DESCRIPTION );
		CloseStateHint( JUMP_TO_OBJECTIVE );
		CloseStateHint( NAVIGATE );
		CloseStateHint( QUEST_PINS );
		CloseStateHint( OBJECTIVES );
		CloseStateHint( AREA_MAP );
		
		super.OnLeaveState(nextStateName);
	}	
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if(closedByParentMenu || isClosing)
		{
			return true;
		}		
		else if(hintName == DESCRIPTION)
		{
			QuitState();
			
		}
		else if(hintName == JUMP_TO_OBJECTIVE)
		{
			
		}
		else if(hintName == NAVIGATE)
		{
			
			QuitState();
		}
		else if(hintName == QUEST_PINS)
		{
			
		}
		else if(hintName == OBJECTIVES)
		{
			
		}
		else if(hintName == AREA_MAP)
		{
			QuitState();
		}
	}
}