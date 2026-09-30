/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EDirection
{
	D_Front,
	D_Right,
	D_Back,
	D_Left,
	D_Front_60deg,
	D_Front_30deg	
}

enum EDirectionZ
{
	DZ_Undefined,
	DZ_Up,
	DZ_Down,
	DZ_Left,
	DZ_Right
}


function AngleToDirection( angle : float ) : EDirection
{
	angle = AngleNormalize( angle );

	if( angle >= 180.0f)
	{
		angle -= 360.0f;
	}
	if ( angle <= 15.f && angle >= -15.f )
	{
		return D_Front_30deg;
	}
	if ( angle <= 30.f && angle >= -30.f )
	{
		return D_Front_60deg;
	}
	if ( angle <= 45.f && angle >= -45.f )
	{
		return D_Front;
	}
	else if ( angle > 45.f && angle <= 135.f )
	{
		return D_Right;
	}
	else if ( angle < -45.f && angle >= -135.f )
	{
		return D_Left;
	}
	else
	{
		return D_Back;
	}
}


function VectorToDirection( vec : Vector ) : EDirection
{			
	var rot : EulerAngles;
	vec.Z = 0.0f;
	rot = VecToRotation( vec );
	return AngleToDirection( -rot.Yaw );		
}


