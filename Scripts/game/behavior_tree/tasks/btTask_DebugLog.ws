/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTask_DebugLog extends IBehTreeTask
{
	var taskName : string;
	
	function OnActivate() : EBTNodeStatus
	{
		Log( "Activate " + taskName );
		return BTNS_Completed;
	}
	
	latent function Main(): EBTNodeStatus
	{
		while( true )
		{
			Log( "Main " + taskName );
			Sleep( 1.0f );
		}
	
		return BTNS_Completed;
	}
	
	function OnDeactivate()
	{
		Log( "Deactivate " + taskName );
	}
}

class BTTask_DebugLogDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTask_DebugLog';

	editable var taskName : string;
}
