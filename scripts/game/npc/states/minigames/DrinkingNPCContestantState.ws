/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state DrinkingNPCContestant in CNewNPC
{
	event OnEnterState( prevStateName : name )
	{
		parent.DisableLookAt();
		DrinkingNPCContestantStateInit();
	}
	
	entry function DrinkingNPCContestantStateInit()
	{
		parent.ActivateAndSyncBehavior('drinking_contestant');
	}
}