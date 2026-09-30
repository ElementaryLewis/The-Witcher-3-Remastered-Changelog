/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CCameraPivotPositionControllerSlide extends ICustomCameraScriptedPivotPositionController
{
	private		var	originalPosition	: Vector;	
	editable	var	blendSpeed			: float;	default	blendSpeed			= 20.0f;
	private		var	timeCur				: float;
	
	
	
	protected function ControllerUpdate( out currentPosition : Vector, out currentVelocity : Vector, timeDelta : float )
	{
		
		var	blendXYCoef			: float;
		var blendZSpeed			:float;
		var	blendZCoef			: float;
		var targetPosition		: Vector;
		var preset				: SCustomCameraPreset;
		
		
		if( timeCur	== 0.0f )
		{
			originalPosition	= currentPosition;
		}
		
		
		
		
		
		targetPosition		=  thePlayer.GetWorldPosition();
		
		
		
		originalPosition	= Vector( BlendF( originalPosition.X, targetPosition.X, blendSpeed * timeDelta )
									, BlendF( originalPosition.Y, targetPosition.Y, blendSpeed * timeDelta )
									, BlendF( originalPosition.Z, targetPosition.Z, blendSpeed * timeDelta ) );
		
		
		currentPosition = originalPosition;
		
		timeCur			+= timeDelta;
	}
	
	
	protected function ControllerActivate( currentOffset : float )
	{		
		timeCur	= 0.0f;
	}
}