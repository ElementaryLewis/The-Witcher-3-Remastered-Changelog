/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class Damper
{
	private var destValue : float;
	private var currValue : float;
	private var dampFactor : float;
	
	default destValue = 0.f;
	default currValue = 0.f;
	default dampFactor = 0.1f;
	
	final function SetDamp( factor : float )
	{
		dampFactor = ClampF( factor, 0.f, 1.f );
	}
	
	final function Init( curr : float, dest : float )
	{
		currValue = curr;
		destValue = dest;
	}
	
	final function Reset()
	{
		destValue = 0.f;
		currValue = 0.f;
	}
	
	final function SetValue( value : float )
	{
		destValue = value;
	}
	
	final function GetValue() : float
	{
		return currValue;
	}
	
	final function Update( dt : float )
	{
		currValue = currValue + dt * dampFactor * ( destValue - currValue );
	}
	
	final function UpdateAndGet( dt : float, value : float ) : float
	{
		SetValue( value );
		Update( dt );
		return GetValue();
	}
}
