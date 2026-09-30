/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state JournalQuest in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var TUTORIAL : name;
	
		default TUTORIAL = 'TutorialJournalQuests';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		ShowHint(TUTORIAL, POS_QUESTS_X, POS_QUESTS_Y, ETHDT_Infinite);
	}
		
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(TUTORIAL);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnMenuClosing(menuName : name)
	{
		if(menuName == 'JournalQuestMenu')
			QuitState();
	}
}




exec function jour()
{
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	TutorialScript('journal', '');
}