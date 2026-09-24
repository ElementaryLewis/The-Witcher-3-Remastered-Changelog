/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import abstract class ICustomCameraBaseController
{
	import const var controllerName : name;
}

import abstract class ICustomCameraPivotPositionController extends ICustomCameraBaseController
{
	import var offsetZ : float;
	
	
	import final function Update( out currPosition : Vector, out currVelocity : Vector, timeDelta : float );
	import final function SetDesiredPosition( position : Vector, optional mult : float );
	
	
	function Reset() {}
}

import abstract class ICustomCameraPivotRotationController extends ICustomCameraBaseController
{
	import var minPitch : float;
	import var maxPitch : float;
	
	import final function Update( out currRotation : EulerAngles, out currVelocity : EulerAngles, timeDelta : float );
	import final function SetDesiredHeading( heading : float, optional mult : float );
	import final function SetDesiredPitch( pitch : float, optional mult : float );
	import final function RotateHorizontal( right : bool, optional mult : float );
	import final function RotateVertical( up : bool, optional mult : float );
	import final function StopRotating();
}

import abstract class ICustomCameraPivotDistanceController extends ICustomCameraBaseController
{
	import var minDist : float;
	import var maxDist : float;
	
	import final function Update( out currDistance : float, out currVelocity : float, timeDelta : float );
	import final function SetDesiredDistance( distance : float, optional mult : float );
}




import class CCustomCameraRopePPC extends ICustomCameraPivotPositionController
{

}

import class CCustomCameraBoatPPC extends CCustomCameraRopePPC
{
	import final function SetPivotOffset( offset : Vector );
}





import abstract class ICustomCameraScriptedPivotPositionController extends ICustomCameraPivotPositionController
{
	protected function ControllerActivate( currentOffset : float );
	protected function ControllerDeactivate();
	protected function ControllerUpdate( out currentPosition : Vector, out currentVelocity : Vector, timeDelta : float );
	protected function ControllerSetDesiredPosition( position : Vector, mult : float );
}

import abstract class ICustomCameraScriptedCurveSetPivotPositionController extends ICustomCameraScriptedPivotPositionController
{
	import protected final function FindCurve( curveName : name ) : CCurve;
}



import abstract class ICustomCameraScriptedPivotRotationController extends ICustomCameraPivotRotationController
{
	protected function ControllerActivate( currentRotation : EulerAngles );
	protected function ControllerDeactivate();
	protected function ControllerUpdate( out currentRotation : EulerAngles, out currentVelocity : EulerAngles, timeDelta : float );
	protected function ControllerSetDesiredYaw( yaw : float, mult : float );
	protected function ControllerSetDesiredPitch( pitch : float, mult : float );
	protected function ControllerRotateHorizontal( right : bool, mult : float );
	protected function ControllerRotateVertical( up : bool, mult : float );
	protected function ControllerStopRotating();
	protected function ControllerGetRotationDelta() : EulerAngles;
	protected function ControllerUpdateInput( out movedHorizontal : bool, out movedVertical : bool );
}

import abstract class ICustomCameraScriptedCurveSetPivotRotationController extends ICustomCameraScriptedPivotRotationController
{
	import protected final function FindCurve( curveName : name ) : CCurve;
}



import abstract class ICustomCameraScriptedPivotDistanceController extends ICustomCameraPivotDistanceController
{
	protected function ControllerActivate( currentDistance : float );
	protected function ControllerDeactivate();
	protected function ControllerUpdate( out currentDistance : float, out currentVelocity : float, timeDelta : float );
	protected function ControllerSetDesiredDistance( dist : float, mult : float );
}

import abstract class ICustomCameraScriptedCurveSetPivotDistanceController extends ICustomCameraScriptedPivotDistanceController
{
	import protected final function FindCurve( curveName : name ) : CCurve;
}



import struct SCameraMovementData
{
	import var pivotPositionController	: ICustomCameraPivotPositionController;
	import var pivotRotationController	: ICustomCameraPivotRotationController;
	import var pivotDistanceController	: ICustomCameraPivotDistanceController;
	import var pivotPositionValue		: Vector;
	import var pivotPositionVelocity	: Vector;
	import var pivotRotationValue		: EulerAngles;
	import var pivotRotationVelocity	: EulerAngles;
	import var pivotDistanceValue		: float;
	import var pivotDistanceVelocity	: float;
	import var cameraLocalSpaceOffset	: Vector;
	import var cameraLocalSpaceOffsetVel: Vector;
}

import abstract class ICustomCameraScriptedPositionController extends ICustomCameraPositionController
{
	
	protected function ControllerUpdate( out moveData : SCameraMovementData, timeDelta : float )
	{
		moveData.pivotPositionController.Update( moveData.pivotPositionValue, moveData.pivotPositionVelocity, timeDelta );
		moveData.pivotRotationController.Update( moveData.pivotRotationValue, moveData.pivotRotationVelocity, timeDelta );
		moveData.pivotDistanceController.Update( moveData.pivotDistanceValue, moveData.pivotDistanceVelocity, timeDelta );
	}
	
	protected function ControllerSetPosition( position : Vector );
	protected function ControllerSetRotation( rotation : EulerAngles );
	protected function ControllerGetPosition() : Vector;
	protected function ControllerGetRotation() : EulerAngles;
}

import abstract class ICustomCameraScriptedCurveSetPositionController extends ICustomCameraScriptedPositionController
{
	import protected final function FindCurve( curveName : name ) : CCurve;
}


struct SCameraAnimationData
{
	editable var animation 	: name;
	editable var priority 	: ECameraAnimPriority;
	editable var blend 		: float;
	editable var weight 	: float;
	editable var loop 		: bool;
}

class CCameraParametersSet
{
	editable 			var pivotPositionControllerName	: name;
	editable 			var pivotPositionControllerBlend: float;	default	pivotPositionControllerBlend	= 0.3f;
	editable 			var pivotPosForcedBlendOnNext	: float;	default	pivotPosForcedBlendOnNext		= 0.0f;
	editable 			var pivotPositionBlendFromPos	: bool;		default	pivotPositionBlendFromPos		= false;
	editable 			var forceBlendFromPosOnNextCam	: bool;		default	forceBlendFromPosOnNextCam		= false;
	editable 			var pivotRotationController		: name;
	editable 			var pivotDistanceController		: name;
	editable 			var launchAnimation				: bool;
	editable inlined	var animationData				: SCameraAnimationData;
	editable 			var collisionOffset				: Vector;

	
	function SetToMainCamera( forcedBlend : float )
	{
		var camera	: CCustomCamera = theGame.GetGameCamera();
		var animation : SCameraAnimationDefinition;
		
		
		if( IsNameValid( pivotPositionControllerName ) && pivotPositionControllerName != camera.GetActivePivotPositionController().controllerName )
		{
			if( forcedBlend > 0.0f || pivotPositionControllerBlend > 0.0f )
			{
				if( pivotPositionBlendFromPos )
				{
					camera.ChangePivotPositionController( 'KeepRelativePositionController' );
				}
				
				if( forcedBlend > 0.0f )
				{
					camera.BlendToPivotPositionController( pivotPositionControllerName, forcedBlend );
				}
				else
				{
					camera.BlendToPivotPositionController( pivotPositionControllerName, pivotPositionControllerBlend );
				}
			}
			else
			{
				camera.ChangePivotPositionController( pivotPositionControllerName );
			}
		}
		
		
		if( IsNameValid( pivotRotationController ) && pivotRotationController != camera.GetActivePivotRotationController().controllerName )
		{
			camera.ChangePivotRotationController( pivotRotationController );
		}
		
		
		if( IsNameValid( pivotDistanceController ) && pivotDistanceController != camera.GetActivePivotDistanceController().controllerName )
		{
			camera.ChangePivotDistanceController( pivotDistanceController );
		}
		
		
		if( launchAnimation )
		{
			animation.animation = animationData.animation;
			animation.priority = animationData.priority;
			animation.blendIn = animationData.blend;
			animation.blendOut = animationData.blend;
			animation.weight = animationData.weight;
			animation.loop = animationData.loop;
			animation.speed	= 1.0f;
			animation.additive = true;
			animation.reset = true;
			
			camera.PlayAnimation( animation );
		}
	}
	
	function StopOnMainCamera()
	{
		var camera	: CCustomCamera;
		
		camera	= theGame.GetGameCamera();
		
		if( launchAnimation )
		{
			camera.StopAnimation( animationData.animation );
		}
		
		if( forceBlendFromPosOnNextCam && camera)
		{
			camera.ChangePivotPositionController( 'KeepRelativePositionController' );
		}
	}
}




