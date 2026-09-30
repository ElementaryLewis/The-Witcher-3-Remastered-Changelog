/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskWaitFor extends IBehTreeTask
{
	var waitForTag : CName;
	var timeout : float;
	var testDistance : float;
	var timeoutCounter : float;

	latent function Main() : EBTNodeStatus
	{	
		var npc : CNewNPC = GetNPC();
		var target : CEntity;
		
		timeoutCounter = GetLocalTime() + timeout;
		target = theGame.GetEntityByTag( waitForTag );
		
		while( true )
		{
			if ( !target )
			{
				return BTNS_Failed;
			}
			
			if( timeout > 0.0f && timeoutCounter > GetLocalTime() )
			{
				return BTNS_Completed;
			}
			
			
			if( VecDistance2D( target.GetWorldPosition(), npc.GetWorldPosition() ) < testDistance )
			{
				return BTNS_Completed;
			}
			Sleep( 1.0f );
		}
		
		return BTNS_Active;
	}
}

class CBTTaskWaitForDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskWaitFor';

	editable var waitForTag : CBehTreeValCName;
	editable var timeout : CBehTreeValFloat;
	editable var testDistance : CBehTreeValFloat;
}