/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class AngleSpringDamper extends SpringDamper
{
	protected function CalcDiff( c : float, d : float ) : float
	{
		return AngleDistance( c, d );
	}
}

function DampAngleFloatSpring( out current : float, out velocity : float, dest : float, smoothTime : float, dt : float )
{
	var omega : float;
	var x, exp : float;
	var diff : float;
	var temp : float;
	
	if( smoothTime > 0.f )
	{
		omega = 2.f / smoothTime;
		x = omega * dt;
		exp = 1.f / ( 1.f + x + 0.48f*x*x + 0.235f*x*x*x );
		diff = AngleDistance( current, dest );
		temp = (velocity + omega * diff) * dt;
		velocity = (velocity - omega * temp) * exp;
		current = dest + (diff + temp) * exp;
	}
	else if( dt > 0.f )
	{
		velocity = AngleDistance( dest, current ) / dt;
		current = dest;
	}
}