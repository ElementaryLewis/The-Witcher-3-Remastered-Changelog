/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class AngleConstDamper extends ConstDamper
{
	public function Update( dt : float )
	{
		var dist, diff : float;
		
		diff = AngleDistance( destValue, currValue );
		
		if ( diff > 0.f )
		{
			dist = MinF( dt * deltaValue, diff );
		}
		else
		{
			dist = MaxF( -dt * deltaValue, diff );
		}
		
		currValue = currValue + dist;
		
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
