/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CFocusModeCombatCamera_CurveDamp_MC 
{
	editable var distanceCurveName : name;
	editable var yawCurveName : name;
	editable var pitchCurveName : name;
	editable var fovCurveName : name;
	
	editable var desiredPitch : float;
	editable var autoTimeUpdate : bool;

	protected var distanceDamper : CurveDamper;
	protected var yawDamper 	: AngleCurveDamper;
	protected var pitchDamper 	: AngleCurveDamper;
	protected var fovDamper : CurveDamper;
	
	protected var distanceStart	: float;
	protected var pitchStart	: float;
	protected var yawStart		: float;
	
	protected var position		: Vector;
	protected var rotation		: EulerAngles;
	
	protected var timeScale		: float;
	
	
	default desiredPitch = -15.f;
	default autoTimeUpdate = true;
	default timeScale = 1.f;
	
	
	
	protected function ControllerUpdate( timeDelta : float ) 
	{
		if ( autoTimeUpdate )
		{
			timeDelta = theTimer.timeDeltaUnscaled;
			
			InternalUpdate( timeDelta );	
		}
	}
	
	protected function ControllerRotate( hasYaw : bool, angleYaw : float, hasPitch : bool, anglePitch : float ) 
	{
		
	}
	
	protected function ControllerSetDesiredYaw( yaw : float ) 
	{
		yawDamper.SetValue( yaw );
	}
	
	protected function ControllerSetDesiredPitch( pitch : float )
	{
		pitchDamper.SetValue( desiredPitch );
	}
	
	protected function ControllerSetDesiredDistance( distance : float ) 
	{
		distanceDamper.SetValue( distance );
	}
	
	protected function ControllerGetPosition( out posOut : Vector )
	{
		posOut = position;
	}
	
	protected function ControllerGetRotation( out rotOut : EulerAngles ) 
	{
		rotOut = rotation;
	}
	
	protected function ControllerGetDistance( out distance : float ) 
	{
		distance = distanceDamper.GetValue();
	}
	
	protected function ControllerSetRotation( rotation : EulerAngles ) 
	{
		pitchDamper.Init( rotation.Pitch, rotation.Pitch );
		yawDamper.Init( rotation.Yaw, rotation.Yaw );
		
		UpdatePositionAndRotation();
	}
	
	protected function ControllerSetDistance( distance : float )
	{
		distanceDamper.Init( distance, distance );
		
		UpdatePositionAndRotation();
	}
	
	protected function ControllerSetFov( inFov : float )
	{
		if ( fovDamper )
		{
			fovDamper.Init( inFov, inFov );
		}
		else
		{
			
		}
	}
	
	protected function ControllerGetFov( out outFov : float )
	{
		if ( fovDamper )
		{
			outFov = fovDamper.GetValue();
		}
		else
		{
			
		}
	}
	
	
	
	public function ManualUpdate( timeDelta : float )
	{
		InternalUpdate( timeDelta );
	}
	
	public function SetManualMode( flag : bool )
	{
		autoTimeUpdate = flag;
	}
	
	public function SetTimeScale( scale : float )
	{
		timeScale = scale;
	}
	
	public function IsInterpolating() : bool
	{
		return distanceDamper.IsRunning() || yawDamper.IsRunning() || pitchDamper.IsRunning();
	}
	
	public function GetProgress() : float
	{
		var pA, pB, pC : float;
		
		pA = distanceDamper.GetProgress();
		pB = yawDamper.GetProgress();
		pC = pitchDamper.GetProgress();
		
		return ( pA + pB + pC ) / 3.f;
	}
	
	public function ResetValues( yaw, pitch, distance : float )
	{
		yawDamper.ResetValue( yaw );
		pitchDamper.ResetValue( pitch );
		distanceDamper.ResetValue( distance );
	}
	
	public function ResetDistanceValue( distance : float )
	{
		distanceDamper.ResetValue( distance );
	}
	
	
	
	protected function InternalUpdate( timeDelta : float )
	{
		timeDelta *= timeScale;
		
		distanceDamper.Update( timeDelta );
		yawDamper.Update( timeDelta );
		pitchDamper.Update( timeDelta );
		fovDamper.Update( timeDelta );
		
		UpdatePositionAndRotation();
		
		
	}
	
	protected function CheckDampers()
	{
		var curveD, curveY, curveP, curveF : CCurve;
		
		if ( !distanceDamper )
		{
			
		
			distanceDamper = new CurveDamper in this;
			distanceDamper.SetCurve( curveD );
		}
		
		if ( !yawDamper )
		{
			
			
			yawDamper = new AngleCurveDamper in this;
			yawDamper.SetCurve( curveY );
		}
		
		if ( !pitchDamper )
		{
			
			
			pitchDamper = new AngleCurveDamper in this;
			pitchDamper.SetCurve( curveP );
		}
		
		if ( !fovDamper )
		{
			
			
			fovDamper = new CurveDamper in this;
			fovDamper.SetCurve( curveF );
		}
	}
	
	protected function GetDistanceForUpdate() : float
	{
		return distanceDamper.GetValue();
	}
	
	protected function UpdatePositionAndRotation()
	{
		var mat : Matrix;
		var newDistance, newYaw, newPitch : float;
		
		newDistance = GetDistanceForUpdate();
		newPitch = pitchDamper.GetValue();
		newYaw = yawDamper.GetValue();
			
		newPitch = AngleNormalize180( newPitch );
		newYaw = AngleNormalize180( newYaw );
			
		
		rotation.Pitch = newPitch;
		rotation.Yaw = newYaw;
		rotation.Roll = 0.f;
			
		
		position = RotForward( rotation ) * (-newDistance);
	}
}




class CFocusModeCombatCamera_CurveDamp_Rot_MC extends CFocusModeCombatCamera_CurveDamp_MC
{
	editable var rollCurveName 	: name;
	editable var posCurveName 	: name;
	
	protected var rollDamper 	: AngleCurveDamper;
	protected var posDamper 	: CurveDamper3d;
	
	
	
	
	
	
	
	protected function InternalUpdate( timeDelta : float )
	{
		rollDamper.Update( timeDelta * timeScale );
		posDamper.Update( timeDelta * timeScale );
		
		super.InternalUpdate( timeDelta );
	}
	
	protected function CheckDampers()
	{
		var curve : CCurve;
		
		super.CheckDampers();
		
		if ( !rollDamper )
		{
			
			
			rollDamper = new AngleCurveDamper in this;
			rollDamper.SetCurve( curve );
		}
		
		if ( !posDamper )
		{
			
			
			posDamper = new CurveDamper3d in this;
			posDamper.SetCurve( curve );
		}
	}
	
	protected function UpdatePositionAndRotation()
	{
		var newYaw, newPitch, newRoll : float;
		
		newPitch = pitchDamper.GetValue();
		newYaw = yawDamper.GetValue();
		newRoll = rollDamper.GetValue();
		
		newPitch = AngleNormalize180( newPitch );
		newYaw = AngleNormalize180( newYaw );
		newRoll = AngleNormalize180( newRoll );
		
		
		rotation.Pitch = newPitch;
		rotation.Yaw = newYaw;
		rotation.Roll = newRoll;
		
		
		position = posDamper.GetValue();
	}
}




class CFocusModeCombatCamera_CurveDamp_PC 
{	
	editable var pivotCurveName : name;
	editable var autoTimeUpdate : bool;

	var pivotDamper : CurveDamper3d;
	
	var timeScale : float;
	

	default autoTimeUpdate = true;
	default timeScale = 1.f;
	
	
	
	protected function ControllerUpdate( timeDelta : float ) 
	{
		if ( autoTimeUpdate )
		{
			timeDelta = theTimer.timeDeltaUnscaled;
			
			InternalUpdate( timeDelta );
		}
	}
	
	protected function ControllerSetPosition( position : Vector ) 
	{
		
	}
	
	protected function ControllerSetDesiredPosition( position : Vector ) 
	{
		pivotDamper.SetValue( position );
	}
	
	protected function ControllerGetPosition( out position : Vector ) 
	{
		position = pivotDamper.GetValue();
	}
	
	
	
	public function ManualUpdate( timeDelta : float )
	{
		InternalUpdate( timeDelta );
	}
	
	public function IsInterpolating() : bool
	{
		return pivotDamper.IsRunning();
	}
	
	public function ResetValue( pivot : Vector )
	{
		pivotDamper.ResetValue( pivot );
	}
	
	public function SetTimeScale( scale : float )
	{
		timeScale = scale;
	}
	
	
	
	private final function InternalUpdate( timeDelta : float )
	{
		pivotDamper.Update( timeScale * timeDelta );
	}
	
	private final function CheckDampers()
	{
		var curveP : CCurve;
		
		if ( !pivotDamper )
		{
			
		
			pivotDamper = new CurveDamper3d in this;
			pivotDamper.SetCurve( curveP );
		}
	}
}