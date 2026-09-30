/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskWander extends IBehTreeTask
{
	var minDistance, maxDistance, minSpeed, maxSpeed, absSpeed, headingChange, heading : float;
	var initialPosCheck, isMoving : bool;
	var moveType : EMoveType;
	var initialPos, newHeading, checkPos : Vector;
	
	default isMoving = false;
	default initialPosCheck = false;
	default heading = 0.f;

	function IsAvailable() : bool
	{
		return true;
	}

	latent function Main() : EBTNodeStatus
	{
		var actor : CActor = GetActor();
		var res : bool;
		var whereTo, randVec : Vector;
		var heading : float;
		var moveType : EMoveType;
		var actorToTargetAngle, distToTarget : float;
		
		isMoving = true;
		if( initialPosCheck == false )
		{
			initialPosCheck = true;
			initialPos = actor.GetWorldPosition();
		}
		
		randVec = VecRingRand(minDistance,maxDistance);
		whereTo = initialPos + randVec;
		
		absSpeed = RandRangeF( maxSpeed, minSpeed );
		
		
		
		distToTarget = VecDistance( actor.GetWorldPosition(), whereTo );
		
		res = actor.ActionMoveTo( whereTo, moveType, absSpeed );
		isMoving = false;
		if( res || distToTarget < 4 )
		{
			return BTNS_Completed;
		}
		
		return BTNS_Active;
		
		
	}
	
	function OnDeactivate() : void
	{
		if ( isMoving )
		{
			GetActor().ActionCancelAll();
			isMoving = false;
		}
	}
}

class CBTTaskWanderDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskWander';

	editable var maxDistance : float;
	editable var minDistance : float;
	editable var moveType : EMoveType;
	editable var minSpeed : float;
	editable var maxSpeed : float;
	
	default maxDistance = 12.0;
	default minDistance = 4.0;
	default minSpeed = 0.2;
	default maxSpeed = 2.0;
	default moveType = MT_Run;
}