/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskMoveToWaypoint extends IBehTreeTask
{
	var waypoint : name;
	var moveType : EMoveType;
	var moveSpeed : float;
	var isMoving, gotTarget : bool;
	
	default isMoving = false;
	default gotTarget = true;
	
	latent function Main() : EBTNodeStatus
	{
		var actor : CActor = GetActor();
		var wp : CEntity;
		var wpPos : Vector;
		var distToWp : float;
		var res : bool;
		
		isMoving = true;
		
		wp = theGame.GetEntityByTag( waypoint );
		
		wpPos = wp.GetWorldPosition();
		distToWp = VecDistance( actor.GetWorldPosition(), wpPos );
		
		if( moveSpeed > 0 && moveType == MT_AbsSpeed && gotTarget )
		{
			gotTarget = false;
			res = actor.ActionMoveTo( wpPos, moveType, moveSpeed, 3 );
		}
		else if( gotTarget )
		{
			gotTarget = false;
			res = actor.ActionMoveTo( wpPos, moveType, 3 );
		}
		
		isMoving = false;
		if( res || distToWp < 4 )
		{
			gotTarget = true;
			return BTNS_Completed;
		}
		gotTarget = true;
		return BTNS_Failed;
	}
	
	function OnDeactivate() : void
	{
		var actor : CActor = GetActor();
		
		if ( isMoving )
		{
			actor.ActionCancelAll();
			isMoving = false;
		}
	}
}

class CBTTaskMoveToWaypointDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskMoveToWaypoint';

	editable var waypoint : name;
	editable var moveType : EMoveType;
	editable var moveSpeed : float;
	
	default moveSpeed = 1.0;
	default moveType = MT_Run;
}