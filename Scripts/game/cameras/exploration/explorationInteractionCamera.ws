/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CCameraPivotPositionControllerExplorationInteraction extends CCameraPivotPositionControllerJump
{
	private	editable	var	collisionOffsetF		: float;	default	collisionOffsetF	= 1.0f;
	private				var explorationDirection	: Vector;
	private				var collisionOffset			: Vector;
	
	
	
	protected function ControllerActivate( currentOffset : float )
	{		
		var camera		: CCustomCamera;
		var player		: CR4Player;
		var exploration : SExplorationQueryToken;
		
		
		player	= ( CR4Player ) thePlayer;
		camera	= theGame.GetGameCamera();
		
		
		exploration				= player.substateManager.m_SharedDataO.GetLastExploration();
		explorationDirection	= exploration.normal;
		
		collisionOffset			= explorationDirection * collisionOffsetF; 
		collisionOffset.Z		+= zOffset;
		
		
		camera.SetCollisionOffset( collisionOffset );
		
		super.ControllerActivate( currentOffset );
	}
	
	
	
	
	protected function ControllerDeactivate()
	{
		var camera		: CCustomCamera;
		
		camera.ResetCollisionOffset();
	}
}





class CCameraRotationControllerInteraction extends ICustomCameraScriptedPivotRotationController
{
	
	editable					var pitchMaxSpeed		: float;	default	pitchMaxSpeed		= 200.0f;
	
	editable					var blendTodesiredPitch	: bool;		default	blendTodesiredPitch	= false;
	editable					var desiredPitch		: float;	default	desiredPitch		= -20.0f;
	editable					var desiredPitchSpeed	: float;	default	desiredPitchSpeed	= 5.0f;
	
	
	editable					var yawMaxSpeed			: float;	default	yawMaxSpeed			= 300.0f;
	
	
	
	
	protected function ControllerUpdate( out currentRotation : EulerAngles, out currentVelocity : EulerAngles, timeDelta : float )
	{
		if( blendTodesiredPitch )
		{
			currentRotation.Pitch	= LerpAngleF( MinF( timeDelta * desiredPitchSpeed, 1.0f ), currentRotation.Pitch, desiredPitch );
		}
		currentRotation.Pitch	+= pitchMaxSpeed * theInput.GetActionValue( 'GI_AxisRightY' ) * timeDelta;
		currentRotation.Pitch	= ClampF( currentRotation.Pitch, minPitch, maxPitch );
		currentRotation.Yaw		-= yawMaxSpeed * theInput.GetActionValue( 'GI_AxisRightX' ) * timeDelta;
	}
	
	
	protected function ControllerActivate( currentRotation : EulerAngles )
	{		
	}
}
