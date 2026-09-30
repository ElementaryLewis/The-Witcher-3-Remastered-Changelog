/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class AngleDeltaDamper extends DeltaDamper
{
	public function Update( dt : float )
	{
		currValue = currValue + ClampF( dt * dampFactor, 0.f, 1.f ) * AngleDistance( destValue, currValue );
		
		if( currValue < -180.0f ) 
		{
			currValue += 360.0f;
		}
		else if( currValue  > 180.0f )
		{
			currValue -= 360.0f;
		}
	}
}
