/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class ConstDamper
{
	protected var destValue : float;
	protected var currValue : float;
	protected var deltaValue : float;
	
	default destValue = 0.f;
	default currValue = 0.f;
	default deltaValue = 1.0f;
	
	public final function SetDamp( _deltaValue : float )
	{
		deltaValue = ClampF( _deltaValue, 0.f, 10000.f );
	}
	
	public final function Init( curr : float, dest : float )
	{
		currValue = curr;
		destValue = dest;
	}
	
	public final function Reset()
	{
		destValue = 0.f;
		currValue = 0.f;
	}
	
	public final function SetValue( value : float )
	{
		destValue = value;
	}
	
	public final function GetValue() : float
	{
		return currValue;
	}
	
	public function Update( dt : float )
	{
		if ( currValue < destValue )
		{
			currValue = MinF( currValue + dt * deltaValue, destValue );
		}
		else
		{
			currValue = MaxF( currValue - dt * deltaValue, destValue );
		}
	}
	
	public final function UpdateAndGet( dt : float, value : float ) : float
	{
		SetValue( value );
		Update( dt );
		return GetValue();
	}
}

function DampVectorConst( out currValue, destValue : Vector, deltaValue, dt : float )
{
	var direction : Vector;
	var distance : float;
	var frameDelta : float;
	
	direction = destValue - currValue;
	distance = VecLength( direction );
	frameDelta = deltaValue * dt;
	
	if( distance <= frameDelta )
	{
		currValue = destValue;
	}
	else
	{
		currValue += (direction / distance) * frameDelta;
	}
}

class ConstVectorDamper
{
	protected var destValue : Vector;
	protected var currValue : Vector;
	protected var deltaValue : float;
	
	default deltaValue = 1.0f;
	
	public final function SetDamp( _deltaValue : float )
	{
		deltaValue = ClampF( _deltaValue, 0.f, 10000.f );
	}
	
	public final function Init( curr : Vector, dest : Vector )
	{
		currValue = curr;
		destValue = dest;
	}
	
	public final function Reset()
	{
		destValue = Vector(0.f,0.f,0.f);
		currValue = Vector(0.f,0.f,0.f);
	}
	
	public final function SetValue( value : Vector )
	{
		destValue = value;
	}
	
	public final function GetValue() : Vector
	{
		return currValue;
	}
	
	public function Update( dt : float )
	{
		var direction : Vector;
		var distance : float;
		var frameDelta : float;
		
		direction = destValue - currValue;
		distance = VecLength( direction );
		frameDelta = deltaValue * dt;
		
		if( distance <= frameDelta )
		{
			currValue = destValue;
		}
		else
		{
			currValue += (direction / distance) * frameDelta;
		}
	}
	
	public final function UpdateAndGet( dt : float, value : Vector ) : Vector
	{
		SetValue( value );
		Update( dt );
		return GetValue();
	}
}

