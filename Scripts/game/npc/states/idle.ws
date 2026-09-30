/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state NewIdle in CNewNPC extends Base
{
	
	
	
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
	
		this.IdleInit();
	}
	
	
	event OnLeaveState( nextStateName : name )
	{ 
		
		super.OnLeaveState(nextStateName);
	}
	
	
	entry function IdleInit()
	{
		
		parent.ActivateAndSyncBehavior('Exploration');
		StateIdle();
	}	

	
	latent function StateIdle()
	{
		while ( true )
		{
			Sleep( 10.0f );
		}
	}
}
