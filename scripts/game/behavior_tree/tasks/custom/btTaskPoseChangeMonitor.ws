/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBehTreeTaskPoseChangeMonitor extends IBehTreeTask
{
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var owner : CActor = GetActor();
		if ( animEventName == 'CombatStanceLeft' )
		{
			owner.SetBehaviorVariable( 'npcPose', (int)ENP_RightFootFront);
			return true;
		}
		else if ( animEventName == 'CombatStanceRight' )
		{
			owner.SetBehaviorVariable( 'npcPose', (int)ENP_LeftFootFront);
			return true;
		}
		else if ( animEventName == 'PunchHand_Left' )
		{
			owner.SetBehaviorVariable( 'punchHand', 0.0f );
		}		
		else if ( animEventName == 'PunchHand_Right' )
		{
			owner.SetBehaviorVariable( 'punchHand', 1.0f );
		}
		return false;
	}

}

class CBehTreeTaskPoseChangeMonitorDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeTaskPoseChangeMonitor';
}