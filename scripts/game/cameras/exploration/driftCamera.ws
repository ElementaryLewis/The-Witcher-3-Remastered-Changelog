/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CCameraPivotPositionControllerDrift extends ICustomCameraScriptedPivotPositionController
{
	editable	var	zOffset					: float;	default	zOffset					= 1.5f;
	private		var	originalPosition		: Vector;
	
	editable	var	blendSpeed				: float;	default	blendSpeed				= 3.0f;
	editable	var	blendOutMult			: float;	default	blendOutMult			= 2.0f;
	
	
	editable 	var	sideDistance			: float;	default	sideDistance			= 1.2f;
	editable 	var	backDistance			: float;	default	backDistance			= 0.8f;
	editable 	var	upDistance				: float;	default	upDistance				= 0.7f;
	
	editable 	var	sideDistanceCur			: float;
	editable 	var	backDistanceCur			: float;
	editable 	var	upDistanceCur			: float;
	editable 	var	sideDistanceBlendSpeed	: float;	default	sideDistanceBlendSpeed	= 5.0f;
	editable 	var	backDistanceBlendSpeed	: float;	default	backDistanceBlendSpeed	= 3.0f;
	editable 	var	upDistanceBlendSpeed	: float;	default	upDistanceBlendSpeed	= 7.0f;
	
	editable 	var	timeToDispMax			: float;	default	timeToDispMax			= 0.75f;
	private		var	timeOfsetCur			: float;
	
	private		var	timeCur					: float;
	
	
	
	protected function ControllerUpdate( out currentPosition : Vector, out currentVelocity : Vector, timeDelta : float )
	{
		var offsetVec			: Vector;
		var targetPosition		: Vector;
		var displacementCoef	: float;
		
		
		
		if( timeCur	== 0.0f )
		{
			originalPosition	= currentPosition;
		}
		
		
		UpdateDistances( timeDelta );
		
		
		targetPosition	= GetTargetPosition( timeDelta );		
		
		
		originalPosition	= LerpV( originalPosition, targetPosition, blendSpeed *timeDelta );
		
		
		currentPosition = originalPosition;
		
		
		
		timeCur	+= timeDelta;
	}
	
	
	protected function UpdateDistances( timeDelta : float )
	{
		var incrementCoef	: float;
		
		
		if( thePlayer.substateManager.m_SharedDataO.m_SkateGlobalC.m_Drifting )
		{
			incrementCoef	= 1.0f;
			if( thePlayer.substateManager.m_SharedDataO.m_SkateGlobalC.m_DrifIsLeft )
			{
				sideDistanceCur	= ClampF( sideDistanceCur + timeDelta * incrementCoef * sideDistanceBlendSpeed, -sideDistance, sideDistance );
			}
			else
			{
				sideDistanceCur	= ClampF( sideDistanceCur - timeDelta * incrementCoef * sideDistanceBlendSpeed, -sideDistance, sideDistance );
			}
		}
		else
		{
			incrementCoef	= -blendOutMult;
			if( sideDistanceCur > 0.0f )
			{
				sideDistanceCur	= MaxF( sideDistanceCur + timeDelta * incrementCoef * sideDistanceBlendSpeed, 0.0f );
			}
			else
			{
				sideDistanceCur	= MinF( sideDistanceCur - timeDelta * incrementCoef * sideDistanceBlendSpeed, 0.0f );
			}
		}
		
		
		backDistanceCur	= ClampF( backDistanceCur + timeDelta * incrementCoef * backDistanceBlendSpeed, 0.0f, backDistance );
		upDistanceCur	= ClampF( upDistanceCur + timeDelta * incrementCoef * upDistanceBlendSpeed, 0.0f, upDistance );
	}
	
	
	protected function GetTargetPosition( timeDelta : float ) : Vector
	{
		var offsetVec			: Vector;
		var targetPosition		: Vector;
		
		offsetVec	=  thePlayer.GetWorldUp() * ( zOffset - upDistanceCur );
		offsetVec	-= thePlayer.GetWorldForward() * backDistanceCur;
		offsetVec	+=  thePlayer.GetWorldRight() * sideDistanceCur;
		
		
		
		targetPosition	=  thePlayer.GetWorldPosition() + offsetVec;
		
		return targetPosition;
	}
	
	
	protected function ControllerActivate( currentOffset : float )
	{	
		timeCur			= 0.0f;
		timeOfsetCur	= 0.0f;
	}
}





class CCameraRotationControllerDrift extends ICustomCameraScriptedPivotRotationController
{
	private editable			var	fixedPitch		: float;		default	fixedPitch		= -20.0f;
	private	editable 			var	rollBase		: float;		default	rollBase		= 2.0f;
	private	editable 			var	rollExtraTurn	: float;		default	rollExtraTurn	= 6.0f;
	private	editable 			var	yawTotal		: float;		default	yawTotal		= 10.0f;
	private						var	timeCur			: float;
	private editable			var	blendSpeedRoll	: float;		default	blendSpeedRoll	= 15.0f;
	private editable			var	blendSpeedYaw	: float;		default	blendSpeedYaw	= 15.0f;
	private						var turnLast		: float;
	
	
	
	protected function ControllerUpdate( out currentRotation : EulerAngles, out currentVelocity : EulerAngles, timeDelta : float )
	{
		var rollTarget	: float;
		var yawTarget	: float;
		
		
		
		if( turnLast * thePlayer.substateManager.m_SharedDataO.m_SkateGlobalC.m_TurnF < 0.0f )
		{
			timeCur	= 0.0f;
		}
		
		turnLast	= thePlayer.substateManager.m_SharedDataO.m_SkateGlobalC.m_TurnF;
		yawTarget				= turnLast * yawTotal;
		rollTarget				= SignOrZeroF( turnLast ) * rollBase + turnLast * rollExtraTurn;
		currentRotation.Yaw		= LerpAngleF(  MinF( 1.0f, blendSpeedYaw * timeDelta ), currentRotation.Yaw, thePlayer.GetHeading() + yawTarget );
		currentRotation.Roll	= LerpAngleF( MinF( 1.0f, blendSpeedRoll * timeDelta ) , currentRotation.Roll, rollTarget);
		currentRotation.Pitch	= fixedPitch;
		
		timeCur	+= timeDelta;
	}
	
	
	protected function ControllerActivate( currentRotation : EulerAngles )
	{		
		timeCur		= 0.0f;
		turnLast	= 0.0f;
	}
}