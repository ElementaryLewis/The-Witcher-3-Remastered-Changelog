/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSirenTakeOff extends IBehTreeTask
{
	var eventReceived : bool;

	default eventReceived = false;
	
	function OnDeactivate()
	{
		eventReceived = false;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var owner : CNewNPC;
		
		if ( !eventReceived && animEventName == 'GoesBackToFly' )
		{
			owner = GetNPC();
			eventReceived = true;
			owner.SetBehaviorVariable( 'npcStance', (int)NS_Fly );
			((CMovingPhysicalAgentComponent)owner.GetMovingAgentComponent()).SetAnimatedMovement( true );
			owner.EnableFinishComponent( false );
			thePlayer.AddToFinishableEnemyList( owner, false );
			return false;
		}
		return false;
	}
}

class CBTTaskSirenTakeOffDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSirenTakeOff';
}