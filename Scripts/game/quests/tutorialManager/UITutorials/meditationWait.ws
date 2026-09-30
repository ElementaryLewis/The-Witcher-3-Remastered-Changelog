/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state MeditationWait in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var WAIT : name;
	
		default WAIT = 'TutorialMeditation';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		ShowHint(WAIT, 0.6, 0.6, ETHDT_Input);
	}
		
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(WAIT);
		
		super.OnLeaveState(nextStateName);
	}
}