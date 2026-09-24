/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CCameraDirector
{
	
	import final function ViewCoordsToWorldVector( x, y : int, out rayStart : Vector, out rayDirection : Vector );
	
	
	import final function WorldVectorToViewCoords( worldPos : Vector, out x : int, out y : int );
	
	
	import final function WorldVectorToViewRatio( worldPos : Vector, out x : float, out y : float ) : bool;
	
	import final function GetCameraPosition() : Vector;
	import final function GetCameraRotation() : EulerAngles;
	import final function GetCameraForward() : Vector;
	import final function GetCameraRight() : Vector;
	import final function GetCameraUp() : Vector;
	import final function GetCameraHeading() : float;
	import final function GetCameraDirection() : Vector;
	
	import final function GetFov() : float;
	
	import final function GetTopmostCameraObject() : IScriptable;
	import final function GetTopmostCamera() : CCustomCamera;
	
	
	
	public function GetCameraForwardOnHorizontalPlane() : Vector
	{
		var l_ForwardV	: Vector;
		
		l_ForwardV		= GetCameraForward();
		l_ForwardV.Z	= 0.0f;		
		
		return VecNormalize( l_ForwardV );
	}
}