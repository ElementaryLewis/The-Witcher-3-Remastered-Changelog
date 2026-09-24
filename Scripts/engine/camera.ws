/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum ECameraState
{
	CS_Exploration,
	CS_Combat,
	CS_FocusModeNC,
	CS_FocusModeCombat,
	CS_AimThrow,
	CS_Horse,
	CS_Boat,
}

enum ECameraShakeState
{
	CSS_Normal,
	CSS_Drunk,
	CSS_Elevator
}

enum ECameraShakeMagnitude
{
	CSM_0	=	0,
	CSM_1	=	1,
	CSM_2	=	2,
	CSM_3	=	3,
	CSM_4	=	4,
	CSM_5	=	5
}

import class CCamera extends CEntity
{
	var cameraState : ECameraState;
	
	import final function SetActive( blendTime : float );

	
	import final function IsActive() : bool;
	
	
	import final function IsOnStack() : bool;

	
	import final function GetCameraDirection() : Vector;

	
	import final function GetCameraPosition() : Vector;

	
	import final function GetCameraMatrixWorldSpace() : Matrix;

	
	import final function SetFov( fov : float );

	
	import final function GetFov() : float;
	
	
	import final function SetZoom( value : float );

	
	import final function GetZoom() : float;

	
	import final function Reset();
	
	
	import final function ResetRotation( optional smoothly : bool, optional horizontal : bool, optional vertical : bool, optional duration : float );
	import final function ResetRotationTo( smoothly : bool, horizontalAngle : float, optional verticalAngle : float, optional duration : float );

	
	
	
	import final function Rotate( leftRightDelta, upDownDelta : float );

	
	import final function Follow( dest : CEntity );
	
	
	import final function FollowWithRotation( dest : CEntity );

	
	import final function LookAt( target : CNode, optional duration : float, optional activatingTime : float );
	
	
	import final function LookAtStatic( staticTarget : Vector, optional duration : float, optional activatingTime : float );
	
	
	import final function LookAtBone( target : CAnimatedComponent, boneName : string, optional duration : float, optional activatingTime : float );
	
	
	import final function LookAtDeactivation( optional deactivatingTime : float );
	
	
	import final function HasLookAt() : bool;

	
	import final function GetLookAtTargetPosition() : Vector;
	
	
	import final function FocusOn( target : CNode, optional duration : float, optional activatingTime : float );
	
	
	import final function FocusOnStatic( staticTarget : Vector, optional duration : float, optional activatingTime : float );
	
	
	import final function FocusOnBone( target : CAnimatedComponent, boneName : string, optional duration : float, optional activatingTime : float );
	
	
	import final function FocusDeactivation( optional deactivatingTime : float );
	
	
	import final function IsFocused() : bool;

	
	import final function GetFocusTargetPosition() : Vector;
	
	
	
	
	final function SetCameraState( newState : ECameraState ) : bool
	{
		var lCamState : int;
		var ret : bool;
		lCamState = (int) newState;

		if ( SetBehaviorVariable( 'cameraState', (float) lCamState ) )
		{
			cameraState = newState;
			return true;
		}
		return false;
	}
	
	final function GetCameraState( ) : ECameraState
	{
		return cameraState;
	}

	final function CameraShakeLooped( strength : float, optional cameraShakeType : ECameraShakeState )
	{
		SetBehaviorVariable( 'cameraShakeState', (int)cameraShakeType );
		SetBehaviorVariable( 'cameraShakeLooped', strength );
	}

	final function GCameraShake( strength : float, optional testDistance : bool, optional shakeEpicenter : Vector, optional maxDistance : float )
	{
		var finalStrength : float;
		var distance : float;
		var camera 	: CCustomCamera = theGame.GetGameCamera();
		var animation : SCameraAnimationDefinition;
		
		if( testDistance )
		{
			if( maxDistance <= 0 )
			{
				maxDistance = 20.0f;
			}
			if( shakeEpicenter == Vector(0,0,0) )
			{
				shakeEpicenter = thePlayer.GetWorldPosition();
			}
			
			distance = VecDistance( shakeEpicenter, thePlayer.GetWorldPosition() );
			
			if( distance > maxDistance )
			{
				distance = maxDistance;
			}
			
			finalStrength = strength * (1 - distance / maxDistance);
		}
		else
		{
			finalStrength = strength;
		}
		SetBehaviorVariable( 'cameraShakeStrength', finalStrength );
		RaiseForceEvent( 'Shake' );
		
		if( camera )
		{
			if( finalStrength > 1 )
			{
				finalStrength = 1.0f;
			}
			
			animation.animation = 'camera_shake_hit_lvl3_1';
			animation.priority = CAP_High;
			animation.blendIn = 0.1f;
			animation.blendOut = 0.1f;
			animation.weight = finalStrength;
			animation.speed	= 1.0f;
			animation.additive = true;
			animation.reset = true;
			
			camera.PlayAnimation( animation );
		}
	}
	
	final function SetCameraShakeState( newState : ECameraShakeState, strength : float) : bool
	{
		var res, res2 : bool;
		
		res = SetBehaviorVariable( 'cameraShakeState', (float) ((int)newState) );
		
		if(newState == CSS_Normal)
			strength = 0;			
		
		res2 = SetBehaviorVariable( 'cameraShakeStrength', strength );
		
		return res && res2;
	}
}

function GCameraShakeLight( strength : float, optional testDistance : bool, optional shakeEpicenter : Vector, optional maxDistance : float, optional looping : bool, optional animName : name, optional speed : float )
{
	var finalStrength : float;
	var distance : float;
	var camera 	: CCustomCamera;
	var animation : SCameraAnimationDefinition;
	
	
	camera 	= theGame.GetGameCamera();
	if( camera )
	{
		return;
	}
	
	
	if( testDistance )
	{
		if( maxDistance <= 0 )
		{
			maxDistance = 20.0f;
		}
		if( shakeEpicenter == Vector(0,0,0) )
		{
			shakeEpicenter = thePlayer.GetWorldPosition();
		}
		
		distance = VecDistance( shakeEpicenter, thePlayer.GetWorldPosition() );
		
		if( distance > maxDistance )
		{
			distance = maxDistance;
		}
		
		finalStrength = strength * (1 - distance / maxDistance);
	}
	else
	{
		finalStrength = strength;
	}
	
	if( speed == 0.0f )
	{
		speed	= 1.0f;
	}
	
	
	if( finalStrength > 1 )
	{
		finalStrength = 1.0f;
	}
	
	if ( animName == '' )
	{
		animName = 'camera_shake_hit_lvl3_1';		
	}

	animation.animation = animName;	
	animation.priority = CAP_Low;
	animation.blendIn = 0.1f;
	animation.blendOut = 0.1f;
	animation.weight = finalStrength;
	animation.speed	= speed;
	animation.additive = true;
	animation.reset = true;
	animation.loop = looping;
	
	camera.PlayAnimation( animation );
}

function GCameraShake( strength : float, optional testDistance : bool, optional shakeEpicenter : Vector, optional maxDistance : float, optional looping : bool, optional animName : name, optional speed : float )
{
	var finalStrength : float;
	var distance : float;
	var camera 	: CCustomCamera;
	var animation : SCameraAnimationDefinition;
	
	
	camera 	= theGame.GetGameCamera();
	if( !camera )
	{
		return;
	}
	
	if( testDistance )
	{
		if( maxDistance <= 0 )
		{
			maxDistance = 20.0f;
		}
		if( shakeEpicenter == Vector(0,0,0) )
		{
			shakeEpicenter = thePlayer.GetWorldPosition();
		}
		
		distance = VecDistance( shakeEpicenter, thePlayer.GetWorldPosition() );
		
		if( distance > maxDistance )
		{
			distance = maxDistance;
		}
		
		finalStrength = strength * (1 - distance / maxDistance);
	}
	else
	{
		finalStrength = strength;
	}
	
	if( speed == 0.0f )
	{
		speed	= 1.0f;
	}
	
	
	if( finalStrength > 1 )
	{
		finalStrength = 1.0f;
	}
	
	if ( animName == '' )
	{
		animName = 'camera_shake_hit_lvl3_1';		
	}

	animation.animation = animName;	
	animation.priority = CAP_High;
	animation.blendIn = 0.1f;
	animation.blendOut = 0.1f;
	animation.weight = finalStrength;
	animation.speed	= speed;
	animation.additive = true;
	animation.reset = true;
	animation.loop = looping;
	
	camera.PlayAnimation( animation );
}