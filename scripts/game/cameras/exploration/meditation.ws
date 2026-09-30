/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3MeditationCameraRotationController extends ICustomCameraScriptedPivotRotationController
{
	private editable var fixedPitch, fixedYaw, fixedRoll : float;
	private editable var baseSmooth : float;
	private var desiredYaw : float;
	private var desired : bool;
	private var smooth : float;
	
		default baseSmooth = 1;

	protected function ControllerActivate( currentRotation : EulerAngles )
	{
		smooth = baseSmooth;
		desired = false;
	}
	
	protected function ControllerUpdate( out currentRotation : EulerAngles, out currentVelocity : EulerAngles, timeDelta : float )
	{
		currentRotation.Pitch = fixedPitch;
		if( desired )
		{
			DampAngleFloatSpring( currentRotation.Yaw, currentVelocity.Yaw, desiredYaw, smooth, timeDelta );
		}
		else
		{
			currentRotation.Yaw = fixedYaw;
		}
		currentRotation.Roll = fixedRoll;
	}
	protected function ControllerUpdateInput( out movedHorizontal : bool, out movedVertical : bool )
	{
		movedHorizontal = false;
		movedVertical = false;
	}
	
	protected function ControllerSetDesiredYaw( yaw : float, mult : float )
	{
		desired = true;
		desiredYaw = yaw;
		
		smooth = baseSmooth * mult;
	}
	
	public function GetFixedYaw() : float
	{
		return fixedYaw;
	}
}