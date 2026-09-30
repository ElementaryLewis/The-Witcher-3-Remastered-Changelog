/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskMoveToEnemy extends IBehTreeTask
{
	var maxDistance : float;
	var moveType : EMoveType;
	var absSpeed : float;
	var isMoving : bool;
	
	default isMoving = false;

	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		var pos : Vector = target.GetWorldPosition();
		var res : bool;
		
		isMoving = true;
		
		
		
		res = npc.ActionMoveTo( pos, moveType, absSpeed, maxDistance );
		isMoving = false;
		if( res )
		{
			
			return BTNS_Completed;
		}
		
		return BTNS_Failed;
	}
	
	function OnDeactivate() : void
	{
		if ( isMoving )
		{
			GetNPC().ActionCancelAll();
			isMoving = false;
		}
	}
}

class CBTTaskMoveToEnemyDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskMoveToEnemy';

	editable var maxDistance : float;
	editable var moveType : EMoveType;
	editable var absSpeed : float;
	
	default maxDistance = 1.0;
	default absSpeed = 1.0;
	default moveType = MT_Run;
}




class CBTTaskPursueTarget extends IBehTreeTask
{
	var moveType : EMoveType;
	var minDistance	: float;
	var keepDistance	: bool;
	var isMoving : bool;

	
	
	default moveType = MT_Run;
	default minDistance = 2.0f;
	default keepDistance = false;
	default isMoving = false;

	latent function Main() : EBTNodeStatus
	{
		var target : CActor;
		var npc : CNewNPC;
		
		
		
		npc = GetNPC();
		target = GetCombatTarget();
		
		isMoving = true;
		npc.ActionMoveToDynamicNode( target, moveType, 5.0f, minDistance, keepDistance, MFA_EXIT );
		
		isMoving = false;
		
		return BTNS_Completed;
	}
	function OnDeactivate() : void
	{
		
		if ( isMoving )
		{
			GetNPC().ActionCancelAll();
			isMoving = false;
		}
	}
}

class CBTTaskPursueTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskPursueTarget';

	editable var moveType 		: EMoveType;
	editable var minDistance	: CBehTreeValFloat;
	editable var keepDistance	: CBehTreeValBool;
	
	function Initialize()
	{
		SetValFloat( minDistance, 0.75 );
		SetValBool( keepDistance, false );
	}
}





class CBTTaskFlyPursueTarget extends IBehTreeTask
{
	var useCustom 						: bool;
	var distanceFromTarget				: float;
	var heightFromTarget				: float;
	var distanceTolerance				: float;
	var predictPositionTime				: float;
	var multiplyPredictTimeByDistance	: float;

	var npcPosition 			: Vector;	
	var targetPosition			: Vector;
	var npcToTargetDistance2D 	: float;
	var movePos 				: Vector;
	var cachedTime				: float;
	var randomHeight			: int;
	
	var randomVectorFromTarget	: Vector;
	
	var flySpeed				: float;
	
	default flySpeed = 0.f;
	default useCustom = false;
	default distanceFromTarget = 10.f;
	default heightFromTarget = 5.f;
	default distanceTolerance = 0.5f;
	default randomHeight = 13;

	
	function OnActivate() : EBTNodeStatus
	{
		var npc 	: CNewNPC = GetNPC();
		var target 	: CActor = npc.GetTarget();
		
		if ( !useCustom )
		{			
			randomVectorFromTarget   = VecRingRand( 20.f, 25.f );
			randomVectorFromTarget.Z = randomVectorFromTarget.Z + 2.f + RandRange(13);
		}
				
		cachedTime = this.GetLocalTime();
		
		((CMovingAgentComponent)npc.GetMovingAgentComponent()).SnapToNavigableSpace( false );
		
		return BTNS_Active;
	}

	latent function Main() : EBTNodeStatus
	{
		var npc 					: CNewNPC = GetNPC();
		var target 					: CActor = npc.GetTarget();
		var npcToMovePosVector 		: Vector;
		var npcToMovePosVector2		: Vector;	
		var flyPitch, flyYaw 		: float;
		
		var localTime 				: float;
		
		var turnSpeedScale			: float;
		
		var npcToMovePosDistance	: float;
		var npcToTargetHeight		: float;
		
		var attackerToTargetAngle	: float;
		
		var targetToNpcVector		: Vector;
		
		var positionOnPath			: Vector;
		
		
		while( true )
		{
			if( predictPositionTime <= 0 )
			{
				targetPosition = target.GetWorldPosition();
			}
			else
			{
				targetPosition = target.PredictWorldPosition( predictPositionTime );
			}
			
			npcPosition = npc.GetWorldPosition();
			
			
			
			if ( useCustom )
			{
				targetToNpcVector = npcPosition - targetPosition;
				targetToNpcVector.Z = 0;
				
				movePos = VecNormalize( targetToNpcVector ) * distanceFromTarget + targetPosition ;
				movePos.Z = movePos.Z + heightFromTarget;
			}
			else
			{
				movePos = targetPosition + randomVectorFromTarget;
			}
			
			
			positionOnPath = movePos;			
			
			if( theGame.GetVolumePathManager().IsPathfindingNeeded( npcPosition, movePos ) )
			{
				positionOnPath = theGame.GetVolumePathManager().GetPointAlongPath( npcPosition, movePos, 2.0f );
			}
			
			movePos = positionOnPath;
			
			
			if ( ( targetPosition.Z - npcPosition.Z ) >= 5.f )
			{
				movePos = npcPosition;
				movePos.Z = movePos.Z + 15.f;
			}
			
			npcToMovePosVector = movePos - npcPosition;		
			npcToMovePosVector2 = npcToMovePosVector;
			npcToMovePosVector2.Z = 0;
			npcToMovePosDistance = VecDistance( npcPosition, movePos );
		
			
			if ( npcToMovePosDistance <= 20.f )
			{
				flySpeed = 1.f;
				turnSpeedScale = 2.f;
			}
			else
			{
				flySpeed = 2.f;
				turnSpeedScale = 1.5f;			
			}
			
			if ( useCustom )
			{
				if ( npcToMovePosDistance <= 20.f )
				{
					attackerToTargetAngle = AbsF( AngleDistance( VecHeading( targetPosition - npc.GetWorldPosition() ), VecHeading( npc.GetHeadingVector() ) ) );
					if ( attackerToTargetAngle > 60 || attackerToTargetAngle < -60 )
					{
						flySpeed = 1.f;
					}
					else
					{
						flySpeed = 2.f;
					}
				}
				
				turnSpeedScale = 3.0f;
			}
		
			
			flyPitch = Rad2Deg( AcosF( VecDot( VecNormalize(npcToMovePosVector), VecNormalize(npcToMovePosVector2) ) ) );
			if ( npcPosition.X == movePos.X && npcPosition.Y == movePos.Y )
			{
				flyPitch = 90;
			}
			
			flyPitch = flyPitch/90;
			flyPitch = flyPitch * PowF( turnSpeedScale, flyPitch );

			if ( flyPitch > 1 )
			{
				flyPitch = 1.f;
			}
			else if ( flyPitch < -1 )
			{
				flyPitch = -1.f;
			}
			
			if ( movePos.Z < npcPosition.Z )
			{
				flyPitch *= -1;
			}
			
		
			
			flyYaw = AngleDistance( VecHeading( npcToMovePosVector ), VecHeading( npc.GetHeadingVector() ) ) ;
			flyYaw = flyYaw / 180;
			flyYaw = flyYaw * PowF( turnSpeedScale , AbsF( flyYaw ) );
			
			if ( flyYaw > 1 )
			{
				flyYaw = 1.f;
			}
			else if ( flyYaw < -1 )
			{
				flyYaw = -1.f;
			}			
				
			npc.SetBehaviorVariable( 'FlyYaw', flyYaw );
			
			
			npc.SetBehaviorVariable( 'FlyPitch', flyPitch );
			npc.SetBehaviorVariable( 'FlySpeed', flySpeed );
			
			localTime = this.GetLocalTime();
			
			if ( useCustom )
			{
				npcToTargetDistance2D = VecDistance2D( npcPosition, targetPosition );
				npcToTargetHeight = npcPosition.Z - targetPosition.Z;
				
				if ( npcToTargetDistance2D <= distanceFromTarget + distanceTolerance && npcToTargetDistance2D >= distanceFromTarget - distanceTolerance && 
					npcToTargetHeight <= heightFromTarget + distanceTolerance && npcToTargetHeight >= heightFromTarget - distanceTolerance )
				{
					
					return BTNS_Completed;
				}
			}
			else
			{
				if ( localTime >= cachedTime + 4 )
				{
					cachedTime = localTime;
					movePos = targetPosition + VecRingRand( 5.f, 12.f );
					movePos.Z = movePos.Z + heightFromTarget + RandRange(randomHeight);
				}
			}
			
			npc.GetVisualDebug().AddSphere( 'destination', 1.f, movePos, true, Color( 0, 0, 255 ), 0.2f );
			
			Sleep( 0.1f );
		}
		return BTNS_Completed;
	}

	function DoTrace( out movePos : Vector )
	{
		var groundPosition, offsetGroundPosition, ceilingPosition, ceilingTrace, normal : Vector;
		var npc : CNewNPC = GetNPC();
		var vecDiff : Vector;
		
		((CMovingAgentComponent)npc.GetMovingAgentComponent()).GetPathPointInDistance( 10.f, groundPosition );
		
		offsetGroundPosition = groundPosition;
		offsetGroundPosition.Z += 1.5f;
		
		ceilingTrace = offsetGroundPosition;
		ceilingTrace.Z += 20.f;
		
		if( !theGame.GetWorld().StaticTrace( ceilingTrace, offsetGroundPosition, ceilingPosition, normal ) )
		{
			movePos = groundPosition;
			movePos.Z += heightFromTarget + randomHeight;
		}
		else
		{
			movePos = groundPosition;
			vecDiff = ceilingPosition - groundPosition;
			if ( vecDiff.Z < ( heightFromTarget + randomHeight + 3 ) )
			{
				movePos.Z += vecDiff.Z / 2.f;
			}
			else
			{
				movePos.Z += heightFromTarget + randomHeight;
			}			
		}
		
		npc.GetVisualDebug().AddSphere( 'ground', 1.f, offsetGroundPosition, true, Color( 255, 0, 0 ), 0.2f );
		npc.GetVisualDebug().AddLine( 'line', offsetGroundPosition, ceilingTrace, true, Color( 255, 0, 0 ), 0.2f );
		npc.GetVisualDebug().AddSphere( 'ceiling', 1.f, ceilingPosition, true, Color( 0, 255, 0 ), 0.2f );
		npc.GetVisualDebug().AddSphere( 'destination', 1.f, movePos, true, Color( 0, 0, 255 ), 0.2f );
	}
	
	function OnDeactivate() : void
	{
		
		
		((CMovingAgentComponent)GetNPC().GetMovingAgentComponent()).SnapToNavigableSpace( true );
	}
}

class CBTTaskFlyPursueTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskFlyPursueTarget';

	editable var useCustom 				: bool;
	editable var distanceFromTarget		: float;
	editable var heightFromTarget		: float;
	editable var distanceTolerance		: float;
	editable var randomHeight			: int;
	editable var predictPositionTime	: float;

	default useCustom = false;
	default distanceFromTarget = 10.f;
	default heightFromTarget = 5.f;
	default distanceTolerance = 0.5f;
	default randomHeight = 13;
	
	hint predictPositionTime = "Pursue the position the combat target will be in this amount of time. If <= 0, it will use the current position of target";
}




class CBTTaskUnderwaterPursueTarget extends IBehTreeTask
{
	var useCustom 				: bool;
	var distanceFromTarget		: float;
	var heightFromTarget		: float;
	var distanceTolerance		: float;

	var npcPosition 			: Vector;	
	var targetPosition			: Vector;
	var npcToTargetDistance2D 	: float;
	var movePos 				: Vector;
	var cachedTime				: float;
	var randomHeight			: int;
	
	var flySpeed				: float;
	
	default flySpeed = 0.f;
	default useCustom = false;
	default distanceFromTarget = 10.f;
	default heightFromTarget = 5.f;
	default distanceTolerance = 0.5f;
	default randomHeight = 13;

	
	function OnActivate() : EBTNodeStatus
	{
		var npc 	: CNewNPC = GetNPC();
		var target 	: CActor = npc.GetTarget();
		
		if ( !useCustom )
		{
			movePos = target.GetWorldPosition() + VecRingRand( 20.f, 25.f );
			movePos.Z = movePos.Z + 2.f + RandRange(13);
		}
				
		cachedTime = this.GetLocalTime();
		
		((CMovingAgentComponent)npc.GetMovingAgentComponent()).SnapToNavigableSpace( false );
		
		return BTNS_Active;
	}

	latent function Main() : EBTNodeStatus
	{
		var npc 					: CNewNPC = GetNPC();
		var target 					: CActor = npc.GetTarget();
		var npcToMovePosVector 		: Vector;
		var npcToMovePosVector2		: Vector;	
		var flyPitch, flyYaw 		: float;
		
		var localTime 				: float;
		
		var turnSpeedScale			: float;
		
		var npcToMovePosDistance	: float;
		var npcToTargetHeight		: float;
		
		var attackerToTargetAngle	: float;
		
		var targetToNpcVector		: Vector;
		
		var world					: CWorld;
		
		var waterLevel 				: float;
		
		world = theGame.GetWorld();
		
		while( true )
		{
		
			
			targetPosition = target.GetWorldPosition();
			npcPosition = npc.GetWorldPosition();
			waterLevel = world.GetWaterLevel(npcPosition);
			
			
			
			movePos = theGame.GetVolumePathManager().GetPointAlongPath( npcPosition, targetPosition + Vector( 0.0f, 0.0f, 1.5f ), 2.0f, waterLevel - 4 );
			
			
			
			
			npcToMovePosVector = movePos - npcPosition;		
			npcToMovePosVector2 = npcToMovePosVector;
			npcToMovePosVector2.Z = 0;
			npcToMovePosDistance = VecDistance( npcPosition, movePos );
		
			
			if ( npcToMovePosDistance <= 20.f )
			{
				flySpeed = 1.f;
				turnSpeedScale = 2.f;
			}
			else
			{
				flySpeed = 2.f;
				turnSpeedScale = 1.5f;			
			}
			
			if ( useCustom )
			{
				if ( npcToMovePosDistance <= 20.f )
				{
					attackerToTargetAngle = AbsF( AngleDistance( VecHeading( targetPosition - npc.GetWorldPosition() ), VecHeading( npc.GetHeadingVector() ) ) );
					if ( attackerToTargetAngle > 60 || attackerToTargetAngle < -60 )
					{
						flySpeed = 1.f;
					}
					else
					{
						flySpeed = 2.f;
					}
				}
				
				turnSpeedScale = 3.0f;
			}
		
			
			flyPitch = Rad2Deg( AcosF( VecDot( VecNormalize(npcToMovePosVector), VecNormalize(npcToMovePosVector2) ) ) );
			if ( npcPosition.X == movePos.X && npcPosition.Y == movePos.Y )
			{
				flyPitch = 90;
			}
			
			flyPitch = flyPitch/90;
			flyPitch = flyPitch * PowF( turnSpeedScale, flyPitch );

			if ( flyPitch > 1 )
			{
				flyPitch = 1.f;
			}
			else if ( flyPitch < -1 )
			{
				flyPitch = -1.f;
			}
			
			if ( movePos.Z < npcPosition.Z )
			{
				flyPitch *= -1;
			}
			
		
			
			flyYaw = AngleDistance( VecHeading( npcToMovePosVector ), VecHeading( npc.GetHeadingVector() ) ) ;
			flyYaw = flyYaw / 180;
			flyYaw = flyYaw * PowF( turnSpeedScale , AbsF( flyYaw ) );
			
			if ( flyYaw > 1 )
			{
				flyYaw = 1.f;
			}
			else if ( flyYaw < -1 )
			{
				flyYaw = -1.f;
			}			
				
			npc.SetBehaviorVariable( 'FlyYaw', flyYaw );
			
			
			npc.SetBehaviorVariable( 'FlyPitch', flyPitch );
			npc.SetBehaviorVariable( 'FlySpeed', flySpeed );
			
			localTime = this.GetLocalTime();
			
			if ( useCustom )
			{
				npcToTargetDistance2D = VecDistance2D( npcPosition, targetPosition );
				npcToTargetHeight = npcPosition.Z - targetPosition.Z;
				
				if ( npcToTargetDistance2D <= distanceFromTarget + distanceTolerance && 
					npcToTargetDistance2D >= distanceFromTarget - distanceTolerance && 
					npcToTargetHeight <= heightFromTarget + distanceTolerance && 
					npcToTargetHeight >= heightFromTarget - distanceTolerance )
				{
					
					return BTNS_Completed;
				}
			}
			else
			{
				if ( localTime >= cachedTime + 4 )
				{
					cachedTime = localTime;
					movePos = targetPosition + VecRingRand( 5.f, 12.f );
					movePos.Z = movePos.Z + heightFromTarget + RandRange(randomHeight);
				}
			}
			
			npc.GetVisualDebug().AddSphere( 'destination', 1.f, movePos, true, Color( 0, 0, 255 ), 0.2f );
			
			Sleep( 0.1f );
		}
		return BTNS_Completed;
	}

	function DoTrace( out movePos : Vector )
	{
		var groundPosition, offsetGroundPosition, ceilingPosition, ceilingTrace, normal : Vector;
		var npc : CNewNPC = GetNPC();
		var vecDiff : Vector;
		
		((CMovingAgentComponent)npc.GetMovingAgentComponent()).GetPathPointInDistance( 10.f, groundPosition );
		
		offsetGroundPosition = groundPosition;
		offsetGroundPosition.Z += 1.5f;
		
		ceilingTrace = offsetGroundPosition;
		ceilingTrace.Z += 20.f;
		
		if( !theGame.GetWorld().StaticTrace( ceilingTrace, offsetGroundPosition, ceilingPosition, normal ) )
		{
			movePos = groundPosition;
			movePos.Z += heightFromTarget + randomHeight;
		}
		else
		{
			movePos = groundPosition;
			vecDiff = ceilingPosition - groundPosition;
			if ( vecDiff.Z < ( heightFromTarget + randomHeight + 3 ) )
			{
				movePos.Z += vecDiff.Z / 2.f;
			}
			else
			{
				movePos.Z += heightFromTarget + randomHeight;
			}			
		}
		
		npc.GetVisualDebug().AddSphere( 'ground', 1.f, offsetGroundPosition, true, Color( 255, 0, 0 ), 0.2f );
		npc.GetVisualDebug().AddLine( 'line', offsetGroundPosition, ceilingTrace, true, Color( 255, 0, 0 ), 0.2f );
		npc.GetVisualDebug().AddSphere( 'ceiling', 1.f, ceilingPosition, true, Color( 0, 255, 0 ), 0.2f );
		npc.GetVisualDebug().AddSphere( 'destination', 1.f, movePos, true, Color( 0, 0, 255 ), 0.2f );
	}
	
	function OnDeactivate() : void
	{
		
		
		((CMovingAgentComponent)GetNPC().GetMovingAgentComponent()).SnapToNavigableSpace( true );
	}
}

class CBTTaskUnderwaterPursueTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskUnderwaterPursueTarget';

	editable var useCustom 				: bool;
	editable var distanceFromTarget		: float;
	editable var heightFromTarget		: float;
	editable var distanceTolerance		: float;
	editable var randomHeight			: int;

	default useCustom = false;
	default distanceFromTarget = 10.f;
	default heightFromTarget = 5.f;
	default distanceTolerance = 0.5f;
	default randomHeight = 13;
}




class CMoveTRGPursueFlee extends CMoveTRGScript
{
	public var dangerNode : CNode;
	public var distance : float;
	public var flee : bool;
	
	default flee = false;
	
	
	function UpdateChannels( out goal : SMoveLocomotionGoal )
	{
		var newHeading : Vector;
		
		if( VecDistance( ((CActor)dangerNode).GetBoneWorldPosition('pelvis'), agent.GetWorldPosition() ) > distance )
		{
			SetFulfilled( goal, true );
			return;
		}
		else
		{
			SetFulfilled( goal, false );
		}
		
		if ( !flee )
		{
			newHeading = Pursue( ((CActor)dangerNode).GetMovingAgentComponent() );
		}
		else
		{
			newHeading = Flee( ((CActor)dangerNode).GetBoneWorldPosition('pelvis') );
		}
		
		
		SetSpeedGoal( goal, 1.0f );
		SetHeadingGoal( goal, newHeading );
		SetOrientationGoal( goal, VecHeading( newHeading ) );
	}
};

class CBTTaskMoveTRG extends IBehTreeTask
{
	public var activationDistance, fleeDistance : float;
	public var ignoreEntityWithTag : name;
	private var dangerNode : CNode;
	
	var flee : bool;
	
	function IsAvailable() : bool
	{
		var owner : CActor = GetActor();
		var actors : array< CActor >;
		var i : int;
		
		actors = GetActorsInRange(owner, activationDistance, 1000000, '', true);
		
		if ( VecDistance( dangerNode.GetWorldPosition(), owner.GetWorldPosition() ) > fleeDistance )
		{
			return false;
		}
		
		for( i = 0; i < actors.Size(); i+=1 )
		{
			if ( VecDistance( actors[i].GetWorldPosition(), owner.GetWorldPosition() ) < activationDistance )
			{
				if( actors[i].HasTag( ignoreEntityWithTag ) && ignoreEntityWithTag != '' )
				{
					return false;
				}
				else if( actors[i].IsInCombat() || GetAttitudeBetween( owner, actors[i] ) == AIA_Hostile )
				{
					dangerNode = actors[i];
					return true;
				}
			}
		}		
		return false;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var owner : CActor = GetActor();
		var targeter : CMoveTRGPursueFlee;
		
		targeter = new CMoveTRGPursueFlee in owner;
		targeter.dangerNode = dangerNode;
		targeter.distance = fleeDistance;
		targeter.flee = flee;
		
		owner.ActionMoveCustom( targeter );
		
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		GetActor().ActionCancelAll();
	}
};


class CBTTaskMoveTRGDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskMoveTRG';

	editable var fleeDistance : float;
	editable var activationDistance : float;
	editable var ignoreEntityWithTag : name;
	editable var flee : bool;
	
	default flee = false;
};




class CMoveTRGFollowLocomotion extends CMoveTRGScript
{
	public var attractor : CNode;
	public var minimumDistance : float;
	
	
	function UpdateChannels( out goal : SMoveLocomotionGoal )
	{
		var newHeading : Vector;
		
		if( VecDistance( ((CActor)attractor).GetWorldPosition(), agent.GetWorldPosition() ) > minimumDistance )
		{
			SetFulfilled( goal, true );
			return;
		}
		else
		{
			SetFulfilled( goal, false );
		}
		
		newHeading = Pursue( ((CActor)attractor).GetMovingAgentComponent() );
		
		SetSpeedGoal( goal, 1.0f );
		SetHeadingGoal( goal, newHeading );
		SetOrientationGoal( goal, VecHeading( newHeading ) );
	}
};

class CBTTaskFollowOwnerTRG extends IBehTreeTask
{
	public var activationDistance, minimumDistance : float;
	public var ignoreEntityWithTag : name;
	public var attractor : CActor;
	
	function IsAvailable() : bool
	{
		var owner : CActor = GetActor();
		var horseComponent : W3HorseComponent;
		
		horseComponent = GetNPC().GetHorseComponent();
		attractor = horseComponent.GetCurrentUser();
		
		if ( VecDistance( attractor.GetWorldPosition(), owner.GetWorldPosition() ) < minimumDistance )
		{
			return false;
		}
		
		if ( VecDistance( attractor.GetWorldPosition(), owner.GetWorldPosition() ) > activationDistance )
		{
			if( attractor.HasTag( ignoreEntityWithTag ) && ignoreEntityWithTag != '' )
			{
				return false;
			}
			if( attractor.IsInCombat() || GetAttitudeBetween( owner, attractor ) == AIA_Hostile )
			{
				return false;
			}
			return true;
		}	
		return false;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var owner : CActor = GetActor();
		var targeter : CMoveTRGFollowLocomotion;
		
		targeter = new CMoveTRGFollowLocomotion in owner;
		targeter.attractor = attractor;
		targeter.minimumDistance = minimumDistance;
		
		owner.ActionMoveCustom( targeter );
		
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		GetActor().ActionCancelAll();
	}
};


class CBTTaskFollowOwnerTRGDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskFollowOwnerTRG';

	editable var activationDistance : float;
	editable var minimumDistance : float;
	editable var ignoreEntityWithTag : name;
};