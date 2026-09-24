/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CCameraPivotPositionControllerKeepRelative extends ICustomCameraScriptedPivotPositionController
{
	private	var	offset	: Vector;
	private	var	isSet	: bool;		default	isSet	= false;
	
	
	protected function ControllerUpdate( out currentPosition : Vector, out currentVelocity : Vector, timeDelta : float )
	{	
		
		if( !isSet )
		{
			offset	= currentPosition - thePlayer.GetWorldPosition();
			isSet	= true;
		}
		
		
		currentPosition = thePlayer.GetWorldPosition() + offset;
	}
	
	
	protected function ControllerActivate( currentOffset : float )
	{	
		isSet	= false;	
	}
}