/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum ECameraAnimPriority
{
	CAP_Lowest,
	CAP_Low,
	CAP_Normal,
	CAP_High,
	CAP_Highest
};

struct SQuestCameraRequest
{
	editable var requestYaw		: bool;
	editable var yaw			: float;
	editable var requestPitch	: bool;
	editable var pitch			: float;
	editable var lookAtTag		: name;
	editable var duration		: float;
	
	var requestTimeStamp 		: float;
	
	default duration = -1.f;
	
	hint lookAtTag = "Tag of an object that the camera should look at (overrides the yaw and pitch)";
}

import struct SCustomCameraPreset
{
	import var pressetName 	: name;
	import var distance		: float;
	import var offset		: Vector;
}

import struct SCameraAnimationDefinition
{
	import var animation	: name;
	import var priority		: int;
	import var blendIn		: float;
	import var blendOut		: float;
	import var weight		: float;
	import var speed		: float;
	import var loop			: bool;
	import var reset		: bool;
	import var additive		: bool;
	import var exclusive	: bool;
}

import class CCustomCamera extends CEntity
{
	import var allowAutoRotation	: bool;
	import var fov					: float;
	
	import final function Activate( optional blendTime : float, optional resetPosition : bool );
	
	import final function GetActivePivotPositionController() : ICustomCameraPivotPositionController;
	import final function GetActivePivotRotationController() : ICustomCameraPivotRotationController;
	import final function GetActivePivotDistanceController() : ICustomCameraPivotDistanceController;
	
	import final function ChangePivotPositionController( _name : name ): bool;
	import final function ChangePivotRotationController( _name : name ): bool;
	import final function ChangePivotDistanceController( _name : name ): bool;
	
	import final function BlendToPivotPositionController( _name : name, blendTime : float ) : bool;
	
	import final function PlayAnimation( animation : SCameraAnimationDefinition );
	import final function StopAnimation( animation : name );
	
	import final function FindCurve( curveName : name ) : CCurve;
	
	import final function SetManualRotationHorTimeout( timeOut : float );
	import final function SetManualRotationVerTimeout( timeOut : float );
	import final function GetManualRotationHorTimeout() : float;
	import final function GetManualRotationVerTimeout() : float;
	import final function IsManualControledHor() : bool;
	import final function IsManualControledVer() : bool;
	import final function ForceManualControlHorTimeout();
	import final function ForceManualControlVerTimeout();

	import final function EnableManualControl( enable : bool );
	
	import final function ChangePreset( preset : name );
	import final function NextPreset();
	import final function PrevPreset();
	
	import final function GetTilt() : float;
	import final function SetTilt( tilt : float );

	import final function SetCollisionOffset( offset : Vector );
	
	
	function ResetCollisionOffset()
	{
		SetCollisionOffset( Vector( 0.0f, 0.0f, 1.5f ) );
	}
	
	import final function EnableScreenSpaceCorrection( enable : bool );
	
	function SetFov( val : float )
	{
		fov = val;
	}
	
	

	timer function TimerTurnOnEffect( td : float , id : int)
	{
		PlayEffect('focus_mode');
	}
	
	import final function GetActivePreset() : SCustomCameraPreset;
	
	
	
	
		function ChangePivotController( controllerName : name, optional blendTime : float, optional forcePosition : bool ) : bool { return false; }
		function ChangeMovementController( controllerName : name ) : bool { return false; }
	
	
	
	import final function SetAllowAutoRotation( allow : bool );
}