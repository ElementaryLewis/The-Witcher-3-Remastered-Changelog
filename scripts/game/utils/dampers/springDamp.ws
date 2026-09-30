/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class SpringDamper
{
	protected var destValue : float;
	protected var currValue : float;
	protected var velValue	: float;
	
	protected var smoothTime : float;
	
	default destValue = 0.f;
	default currValue = 0.f;
	default velValue = 0.f;
	
	default smoothTime = 1.f;
	
	public final function SetSmoothTime( value : float )
	{
		smoothTime = value;
	}
	
	public final function Init( curr : float, dest : float )
	{
		currValue = curr;
		destValue = dest;
		velValue = 0.f;
	}
	
	public final function Reset()
	{
		destValue = 0.f;
		currValue = 0.f;
		velValue = 0.f;
	}
	
	public final function SetValue( value : float )
	{
		destValue = value;
	}
	
	public final function GetValue() : float
	{
		return currValue;
	}
	
	public final function GetDestValue() : float
	{
		return destValue;
	}
	
	public final function Update( dt : float )
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
			diff = currValue - destValue;
			temp = (velValue + omega * diff) * dt;
			velValue = (velValue - omega * temp) * exp;
			currValue = destValue + (diff + temp) * exp;
		}
		else if( dt > 0.f )
		{
			velValue = (destValue - currValue) / dt;
			currValue = destValue;
		}
	}
	
	public final function UpdateAndGet( dt : float, value : float ) : float
	{
		SetValue( value );
		Update( dt );
		return GetValue();
	}
	
	public function UpdateManual( out current : float, out velocity : float, dest : float, dt : float )
	{
		currValue = current;
		velValue = velocity;
		destValue = dest;
		
		Update( dt );
		
		current = currValue;
		velocity = velValue;
	}
}

function DampFloatSpring( out current : float, out velocity : float, dest : float, smoothTime : float, dt : float )
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
		diff = current - dest;
		temp = (velocity + omega * diff) * dt;
		velocity = (velocity - omega * temp) * exp;
		current = dest + (diff + temp) * exp;
	}
	else if( dt > 0.f )
	{
		velocity = (dest - current) / dt;
		current = dest;
	}
}

class VectorSpringDamper
{
	protected var destValue : Vector;
	protected var currValue : Vector;
	protected var velValue	: Vector;
	
	protected var smoothTime : float;
	
	default smoothTime = 1.f;
	
	public final function SetSmoothTime( value : float )
	{
		smoothTime = value;
	}
	
	public final function Init( curr : Vector, dest : Vector )
	{
		currValue = curr;
		destValue = dest;
		velValue = Vector( 0.f, 0.f, 0.f );
	}
	
	public final function Reset()
	{
		destValue = Vector( 0.f, 0.f, 0.f );
		currValue = Vector( 0.f, 0.f, 0.f );
		velValue = Vector( 0.f, 0.f, 0.f );
	}
	
	public final function SetValue( value : Vector )
	{
		destValue = value;
	}
	
	public final function GetValue() : Vector
	{
		return currValue;
	}
	
	public final function GetDestValue() : Vector
	{
		return destValue;
	}
	
	public final function Update( dt : float )
	{
		var omega : float;
		var x, exp : float;
		var diff : Vector;
		var temp : Vector;
		
		if( smoothTime > 0.f )
		{
			omega = 2.f / smoothTime;
			x = omega * dt;
			exp = 1.f / ( 1.f + x + 0.48f*x*x + 0.235f*x*x*x );
			diff = currValue - destValue;
			temp = (velValue + omega * diff) * dt;
			velValue = (velValue - omega * temp) * exp;
			currValue = destValue + (diff + temp) * exp;
		}
		else if( dt > 0.f )
		{
			velValue = (destValue - currValue) / dt;
			currValue = destValue;
		}
	}
	
	public final function UpdateAndGet( dt : float, value : Vector ) : Vector
	{
		SetValue( value );
		Update( dt );
		return GetValue();
	}
	
	public function UpdateManual( out current : Vector, out velocity : Vector, dest : Vector, dt : float )
	{
		currValue = current;
		velValue = velocity;
		destValue = dest;
		
		Update( dt );
		
		current = currValue;
		velocity = velValue;
	}
}

function DampVectorSpring( out current : Vector, out velocity : Vector, dest : Vector, smoothTime : float, dt : float )
{
	var omega : float;
	var x, exp : float;
	var diff : Vector;
	var temp : Vector;
	
	if( smoothTime > 0.f )
	{
		omega = 2.f / smoothTime;
		x = omega * dt;
		exp = 1.f / ( 1.f + x + 0.48f*x*x + 0.235f*x*x*x );
		diff = current - dest;
		temp = (velocity + omega * diff) * dt;
		velocity = (velocity - omega * temp) * exp;
		current = dest + (diff + temp) * exp;
	}
	else if( dt > 0.f )
	{
		velocity = (dest - current) / dt;
		current = dest;
	}
}

function EulerMult( angle : EulerAngles, value : float ) : EulerAngles
{
	return EulerAngles( angle.Pitch * value, angle.Yaw * value , angle.Roll * value);
}

function EulerNeg( angle1 : EulerAngles, angle2 : EulerAngles ) : EulerAngles
{
	return EulerAngles(angle1.Pitch - angle2.Pitch, angle1.Yaw - angle2.Yaw, angle1.Roll - angle2.Roll);
}

function EulerAdd( angle1 : EulerAngles, angle2 : EulerAngles ) : EulerAngles
{
	return EulerAngles(angle1.Pitch + angle2.Pitch, angle1.Yaw + angle2.Yaw, angle1.Roll + angle2.Roll);
}

class EulerAnglesSpringDamper
{
	protected var destValue : EulerAngles;
	protected var currValue : EulerAngles;
	protected var velValue	: EulerAngles;
	
	protected var smoothTime : float;
	
	default smoothTime = 1.f;
	
	public final function SetSmoothTime( value : float )
	{
		smoothTime = value;
	}
	
	public final function Init( curr : EulerAngles, dest : EulerAngles )
	{
		currValue = curr;
		destValue = dest;
		velValue = EulerAngles( 0.f, 0.f, 0.f );
	}
	
	public final function Reset()
	{
		destValue = EulerAngles( 0.f, 0.f, 0.f );
		currValue = EulerAngles( 0.f, 0.f, 0.f );
		velValue = EulerAngles( 0.f, 0.f, 0.f );
	}
	
	public final function SetValue( value : EulerAngles )
	{
		destValue = value;
	}
	
	public final function GetValue() : EulerAngles
	{
		return currValue;
	}
	
	public final function GetDestValue() : EulerAngles
	{
		return destValue;
	}
	
	public final function Update( dt : float )
	{
		var omega : float;
		var x, exp : float;
		var diff : EulerAngles;
		var temp : EulerAngles;
		
		if( smoothTime > 0.f )
		{
			omega = 2.f / smoothTime;
			x = omega * dt;
			exp = 1.f / ( 1.f + x + 0.48f*x*x + 0.235f*x*x*x );
			diff = EulerAngles( AngleDistance( currValue.Pitch, destValue.Pitch ), AngleDistance( currValue.Yaw, destValue.Yaw ), AngleDistance( currValue.Roll, destValue.Roll ) );
			temp = EulerMult( EulerAdd(velValue, EulerMult(diff, omega)), dt );
			velValue = EulerMult( EulerNeg(velValue, EulerMult(temp, omega)), exp );
			currValue = EulerAdd( destValue, EulerMult(EulerAdd(diff, temp), exp) );
		}
		else if( dt > 0.f )
		{
			velValue = EulerMult( EulerAngles( AngleDistance( destValue.Pitch, currValue.Pitch ), AngleDistance( destValue.Yaw, currValue.Yaw ), AngleDistance( destValue.Roll, currValue.Roll ) ), 1.f / dt );
			currValue = destValue;
		}
	}
	
	public final function UpdateAndGet( dt : float, value : EulerAngles ) : EulerAngles
	{
		SetValue( value );
		Update( dt );
		return GetValue();
	}
	
	public function UpdateManual( out current : EulerAngles, out velocity : EulerAngles, dest : EulerAngles, dt : float )
	{
		currValue = current;
		velValue = velocity;
		destValue = dest;
		
		Update( dt );
		
		current = currValue;
		velocity = velValue;
	}
}