/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CMoveTRGAnimalFlee extends CMoveTRGScript
{
}

class CBTTaskAnimalFlee extends IBehTreeTask
{
	var maxDistance, heading : float;
	var initialPosCheck, isMoving : bool;
	var alertRadius : float;
	var ignoreEntitiesWithTag : name;
	var moveType : EMoveType;
	var initialPos, checkPos : Vector;
	
	default isMoving = false;
	default initialPosCheck = false;
	default heading = 0.f;
	default moveType = MT_Run;

	function IsAvailable() : bool
	{
		return true;
	}

	latent function Main() : EBTNodeStatus
	{
		var actor : CActor = GetActor();
		var dangerActors : array< CActor >;
		var dangerSource : CActor;
		var res : bool;
		var whereFrom, whereTo, randVec : Vector;
		var heading : float;
		var headingAngle : EulerAngles; 
		var actorToTargetAngle, distToTarget : float;
		var safeSpots : array <CNode>;
		var i : int;
		
		dangerActors = GetActorsInRange( actor, alertRadius, 10000, '', true );
		for ( i = 0; i < dangerActors.Size(); i += 1 )
		{
			if( !dangerActors[i].HasTag( ignoreEntitiesWithTag ) )
			{
				dangerSource = dangerActors[i];
				break;
			}
		}
		
		isMoving = true;
		
		if( initialPosCheck == false )
		{
			initialPosCheck = true;
			initialPos = actor.GetWorldPosition();
		}
		
		whereFrom = dangerSource.GetWorldPosition();
		whereTo = initialPos + VecNormalize( initialPos - whereFrom ) * ( maxDistance*4.f );
		heading = whereTo.Y;		
		
		distToTarget = VecDistance( actor.GetWorldPosition(), whereFrom );
		res = actor.ActionMoveToWithHeading( whereTo, heading, moveType, 0.f, 2.f );
		
		Sleep( 5.f );
		
		isMoving = false;
		return BTNS_Completed;
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

class CBTTaskAnimalFleeDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskAnimalFlee';

	editable var maxDistance : float;
	editable var alertRadius : float;
	editable var ignoreEntitiesWithTag : name;
	editable var moveType : EMoveType;
	
	default maxDistance = 12.0;
	default alertRadius = 25.f;
	default moveType = MT_Run;
}