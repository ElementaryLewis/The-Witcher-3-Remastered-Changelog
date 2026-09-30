/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CMovingAgentComponent extends CAnimatedComponent
{
	
	private var relativeSpeedBuffer : array<float>;

	
	import final function SetMaxMoveRotationPerSec( rotSpeed : float );
	
	
	import final function SetMoveType( moveType : EMoveType );
	
	
	
	
	

	
	import final function GetCurrentMoveSpeedAbs() : float;
	
	
	import final function TeleportBehindCamera( continueMovement : bool ) : bool;
	
	
	import final function EnableCombatMode( combat : bool ) : bool;
	
	
	import final function EnableVirtualController( virtualControllerName : CName, enabled : bool );
	
	
	import final function SetVirtualRadius( radiusName : CName, optional virtualControllerName : CName );
	
	
	import final function SetVirtualRadiusImmediately( radiusName : CName );	
	
	
	import final function ResetVirtualRadius( optional virtualControllerName : CName );
	
	
	import final function SetHeight( height : float );
	
	
	import final function ResetHeight();
	
	
	import final function CanGoStraightToDestination( destination : Vector ) : bool;
	
	
	
	import final function IsPositionValid( position : Vector ) : bool;
	
	
	import final function GetEndOfLineNavMeshPosition( pos : Vector, out outPos : Vector ) : bool;
	
	
	
	import final function IsEndOfLinePositionValid( position : Vector ) : bool;
	
	
	import final function GetPathPointInDistance( distance : float, out position : Vector ) : bool;
	
	
	final function SetEnabledRestorePosition( enabled : bool ) : bool
	{
		SetEnabled( enabled );
		if( enabled )
		{
			return IsEnabled();
		}
		else
		{
			return false;
		}
	}
	
	
	import final function GetSpeed() : float;
	
	
	import final function GetRelativeMoveSpeed() : float;
	
	
	import final function GetMoveTypeRelativeMoveSpeed( moveType : EMoveType ) : float;
	
	
	import final function ForceSetRelativeMoveSpeed( relativeMoveSpeed : float );
	
	
	import final function SetGameplayRelativeMoveSpeed( relativeMoveSpeed : float );
	
	
	import final function SetGameplayMoveDirection( actorDirection : float );
	
	
	import final function UnsetGameplayMoveDirection();

	
	import final function SetDirectionChangeRate( directionChangeRate : float );
		
	
	import final function GetMaxSpeed() : float;
	
	import final function GetVelocityHeading() : Vector;

	
	import final function GetVelocity() : Vector;
	
	
	import final function GetVelocityBasedOnRequestedMovement() : Vector;

	import final function AdjustRequestedMovementDirectionPhysics( out directionWS : Vector, out shouldStop : bool, speed : Float, angleToDeflect : Float, freeSideDistanceRequired : Float, out cornerDetected : bool, out portal : bool) : bool;
	import final function AdjustRequestedMovementDirectionNavMesh( out directionWS : Vector, speed : float, maxAngle : float, maxIteration : int, maxIterationStartSide : int, preferedDirection : Vector, optional checkExploration : bool, optional filterObstacles : bool ) : bool;
	import final function CheckLineCollisionNavmesh( pointStart : Vector, pointEnd : Vector, collisionRadius : float, optional checkExploration : bool, optional filterObstacles : bool ) : bool;
	import final function StartRoadFollowing( speed : float, maxAngle : float, maxDistance : float, out correctedDirection : Vector ) : bool;
	import final function ResetRoadFollowing();
	
	
	import final function GetAgentPosition() : Vector;
	
	import final function SnapToNavigableSpace( snap : bool );
	
	import final function IsOnNavigableSpace() : bool;
	
	import final function IsEntityRepresentationForced() : int;
		
	import final function GetLastNavigablePosition() : Vector;
	
	import final function GetMovementAdjustor() : CMovementAdjustor;

	
	import final function PredictWorldPosition( inTime : float ) : Vector;
	
	
	import final function SetTriggerActivatorRadius( radius : float );
	
	
	import final function SetTriggerActivatorHeight( height : float );
	
	
	import final function AddTriggerActivatorChannel( channel : ETriggerChannels );
	
	
	import final function RemoveTriggerActivatorChannel( channel : ETriggerChannels );

	
	import final function SetEnabledFeetIK( enable : bool, optional blendTime : float );
	import final function GetEnabledFeetIK() : bool;
	
	
	import final function SetEnabledHandsIK( enable : bool );
	import final function SetHandsIKOffsets( left : Vector, right : Vector );
	
	
	import final function SetEnabledFeetOffsetIK( enable : bool);
	import final function SetFeetIKOffsets( left : Vector, right : Vector);

	
	import final function SetEnabledSlidingOnSlopeIK( enable : bool );
	import final function GetEnabledSlidingOnSlopeIK() : bool;

	
	import final function SetOverrideIKLODLevel( LODLevel : int );

	
	import final function SetUseEntityForPelvisOffset( optional entity : CEntity );
	import final function GetUseEntityForPelvisOffset() : CEntity;

	
	import final function SetAdditionalOffsetWhenAttachingToEntity( optional entity : CEntity, optional time : float );
	import final function SetAdditionalOffsetToConsumePointWS( transformWS: Matrix, optional time : float );
	import final function SetAdditionalOffsetToConsumeMS( pos : Vector, rot : EulerAngles, time : float );
	
	
	public function ResetMoveRequests()
	{
		ForceSetRelativeMoveSpeed( 0.0f );
		SetGameplayRelativeMoveSpeed( 0.0f );
	}

	import final function Slide( dir : Vector, rot : EulerAngles, speed : float );

	import final function AddCustomDelta( deltaPosition : Vector, deltaRotation : EulerAngles);
}

import struct SCollisionData
{
	import var entity : CEntity;	
	import var point : Vector;
	import var normal : Vector;
};

import struct SVirtualControllerData
{
	import var centerPosition : Vector;
	import var boneName : name;
	import var boneIndex : int;
}

import class CMovingPhysicalAgentComponent extends CMovingAgentComponent
{
	
	import final function IsPhysicalMovementEnabled() : bool;
	
	
	import final function GetPhysicalState() : ECharacterPhysicsState;
	
	
	import final function IsAnimatedMovement() : bool;
	import final function SetAnimatedMovement( enable : bool );
	
	
	import final function SetGravity( flag : bool );
	
	
	import final function SetBehaviorCallbackNeed( flag : bool );
	
	
	import final function SetSwimming( flag : bool );
	
	
	import final function GetWaterLevel() : float;
	
	
	import final function GetSubmergeDepth() : float;
	
	
	import final function SetDiving( diving : Bool );

	
	import final function IsDiving() : bool;

	
	import final function SetEmergeSpeed( value : float );
	import final function GetEmergeSpeed() : float;
	
	
	import final function SetRagdollPushingMul( value : float );
	import final function GetRagdollPushingMul() : float;	
	
	
	import final function ApplyVelocity( vel : Vector );
	
	
	import final function RegisterEventListener( listener : IScriptable );
	
	
	import final function UnregisterEventListener( listener : IScriptable );
	
	
	import final function SetPushable( pushable : bool );
	
	
	import final function IsOnGround() : bool;
	import final function IsCollidesWithCeiling() : bool;
	import final function IsCollidesOnSide() : bool;
	
	
	import final function IsFalling() : bool;
	
	
	import final function IsSliding() : bool;
	import final function GetSlideCoef() : float;
	import final function GetSlideDir() : Vector;
	import final function SetSliding( enable : bool );
	import final function SetSlidingSpeed( speed : float );
	import final function SetSlidingLimits( min : float, max : float );
	import final function EnableAdditionalVerticalSlidingIteration( enable : bool );
	import final function IsAdditionalVerticalSlidingIterationEnabled() : bool;
	
	
	import final function GetCapsuleHeight() : float;
	import final function GetCapsuleRadius() : float;
	
	
	import final function SetTerrainLimits( min : float, max : float );
	import final function SetTerrainInfluence( mul : float );
	import final function GetSlopePitch() : float;
	import final function GetTerrainNormal( damped : bool ) : Vector;
	import final function GetTerrainNormalWide( out normalAverage : Vector, out normalGlobal : Vector, directionToCheck : Vector, separationH : float, separationF : float, separationB : float );
	
	
	import final function GetCollisionData( index : int ) : SCollisionData;
	import final function GetCollisionDataCount() : int;
	import final function GetCollisionCharacterData( index : int ) : SCollisionData;
	import final function GetCollisionCharacterDataCount() : int;
	import final function GetGroundGridCollisionOn( side : ECollisionSides ) : bool;
	import final function GetMaterialName() : CName;
	
	
	import final function EnableCollisionPrediction( enable : bool );
	
	
	import final function EnableCollisionMainController( enable : bool );

	
	import final function SetVirtualControllersPitch( pitch : Float );
	import final function ScaleVirtualControllersRadius( multiplier : Float );
	import final function EnableVirtualControllerCollision( virtualControllerName : CName, enable : bool );
	import final function EnableVirtualControllerCollisionResponse( virtualControllerName : CName, enable : bool );
	import final function GetTargetableVirtualControllers() : array< SVirtualControllerData >;
}

import class CActionAreaComponent extends CTriggerAreaComponent
{
}