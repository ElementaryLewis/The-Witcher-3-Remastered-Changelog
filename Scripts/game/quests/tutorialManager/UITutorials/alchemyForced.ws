/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state ForcedAlchemy in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var ALCHEMY_GO_TO, OPEN_MENU : name;
	
		default ALCHEMY_GO_TO = 'TutorialAlchemyForcedEnterAlchemy';
		default OPEN_MENU = 'TutorialAlchemyForcedOpenMenu';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		
		theGame.GetTutorialSystem().uiHandler.LockCloseUIPanels(true);
		
		
		theGame.GetTutorialSystem().HideTutorialHint( OPEN_MENU );
		
		
		ShowHint(ALCHEMY_GO_TO, 0.35f, 0.6f, ETHDT_Infinite);	

		
		thePlayer.inv.RemoveItemByName('Thunderbolt 1', -1);
	}
	
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(ALCHEMY_GO_TO);
		
		super.OnLeaveState(nextStateName);
	}	
}
