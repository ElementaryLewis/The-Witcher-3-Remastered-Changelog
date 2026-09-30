/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state DrinkingPlayerContestant in CPlayer
{
	event OnEnterState( prevStateName : name )
	{
		parent.DisableLookAt();
		theSound.EnterGameState( ESGS_Minigame );
		
		Init();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		theSound.LeaveGameState( ESGS_Minigame );
	}
	
	entry function Init()
	{
		parent.ActivateAndSyncBehavior('drinking_contestant');
	}
}