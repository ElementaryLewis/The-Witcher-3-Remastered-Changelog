/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class ThrowingCamera extends ICustomCameraScriptedPivotPositionController
{
	protected function ControllerUpdate( out currentPosition : Vector, out currentVelocity : Vector, timeDelta : float )
	{
		var playerPos, OTSoffset, Zoffset, XYoffset : Vector;
	
		playerPos = thePlayer.GetWorldPosition();
		OTSoffset = VecCross( Vector(0,0,-1), VecNormalize(theCamera.GetCameraDirection()) );		
		Zoffset = Vector(0, 0, 1.5);																	
		
		
		XYoffset = VecNormalize(theCamera.GetCameraDirection());
		XYoffset.X = XYoffset.X * 0.2;
		XYoffset.Y = XYoffset.Y * 0.2;
		XYoffset.Z = 0;		
		
		currentPosition = playerPos + OTSoffset + Zoffset + XYoffset;
	}
}