/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CurveDamper
{
	protected var curve : CCurve;
	
	protected var time : float;
	protected var duration : float;
	
	protected var startValue : float;
	protected var currValue : float;
	protected var destValue : float;
	
	default time = 0.f;
	default startValue = 0.f;
	default currValue = 0.f;
	default destValue = 0.f;
	default duration = 1.f;
	
	public final function IsValid() : bool
	{
		return curve;
	}
	
	public final function SetCurve( c : CCurve )
	{
		curve = c;
		duration = curve.GetDuration();
		
		if ( duration <= 0.f )
		{
			curve = NULL;
		}
	}
	
	public final function Reset()
	{
		time = 0.f;
		currValue = 0.f;
		startValue = 0.f;
		destValue = 0.f;
		currValue = CalcValue();
	}
	
	public final function Init( curr : float, dest : float )
	{
		currValue = curr;
		startValue = curr;
		destValue = dest;
		time = 0.f;
	}
	
	public final function SetValue( value : float )
	{
		destValue = value;
		time = 0.f;
	}
	
	public final function ResetValue( value : float )
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
	
	public function Update( dt : float )
	{
		if ( time + dt < duration )
		{
			time += dt;
		}
		else
		{
			time = duration;
		}
		
		currValue = CalcValue();
	}
	
	public final function UpdateAndGet( dt : float ) : float
	{
		Update( dt );
		return GetValue();
	}
	
	private function CalcValue() : float
	{
		var progress : float;
		
		if ( curve )
		{
			progress = curve.GetValue( time );
			
			return InterpolateValue( progress, startValue, destValue ); 
		}
		
		return -1;
	}
	
	protected function InterpolateValue( progress : float, a : float, b : float ) : float
	{
		return LerpF( progress, a, b, false );
	}
	
	public final function IsRunning() : bool
	{
		return time < duration;
	}
	
	public final function GetProgress() : float
	{
		if ( duration > 0.f )
		{
			return time / duration;
		}
		else
		{
			return 0.f;
		}
	}
}



class AngleCurveDamper extends CurveDamper
{
	protected function InterpolateValue( progress : float, a : float, b : float ) : float
	{
		return LerpAngleF( progress, a, b);
	}
}



class CurveDamper3d
{
	protected var damperX : CurveDamper;
	protected var damperY : CurveDamper;
	protected var damperZ : CurveDamper;
	
	public final function IsValid() : bool
	{
		return damperX.IsValid() && damperY.IsValid() && damperZ.IsValid();
	}
	
	public final function SetCurve( c : CCurve )
	{
		if ( !damperX )
		{
			damperX = new CurveDamper in this;
			damperY = new CurveDamper in this;
			damperZ = new CurveDamper in this;
		}
		
		damperX.SetCurve( c );
		damperY.SetCurve( c );
		damperZ.SetCurve( c );
	}
	
	public final function Reset()
	{
		damperX.Reset();
		damperY.Reset();
		damperZ.Reset();
	}
	
	public final function Init( curr : Vector, dest : Vector )
	{
		damperX.Init( curr.X, dest.X );
		damperY.Init( curr.Y, dest.Y );
		damperZ.Init( curr.Z, dest.Z );
	}
	
	public final function SetValue( value : Vector )
	{
		damperX.SetValue( value.X );
		damperY.SetValue( value.Y );
		damperZ.SetValue( value.Z );
	}
	
	public final function ResetValue( value : Vector )
	{
		damperX.ResetValue( value.X );
		damperY.ResetValue( value.Y );
		damperZ.ResetValue( value.Z );
	}
	
	public final function GetValue() : Vector
	{
		var ret : Vector;
		
		ret.X = damperX.GetValue();
		ret.Y = damperY.GetValue();
		ret.Z = damperZ.GetValue();
		
		return ret;
	}
	
	public final function GetDestValue() : Vector
	{
		var ret : Vector;
		
		ret.X = damperX.GetDestValue();
		ret.Y = damperY.GetDestValue();
		ret.Z = damperZ.GetDestValue();
		
		return ret;
	}
	
	public function Update( dt : float )
	{
		damperX.Update( dt );
		damperY.Update( dt );
		damperZ.Update( dt );
	}
	
	public final function UpdateAndGet( dt : float ) : Vector
	{
		var ret : Vector;
		
		damperX.Update( dt );
		damperY.Update( dt );
		damperZ.Update( dt );
		
		ret.X = damperX.GetValue();
		ret.Y = damperY.GetValue();
		ret.Z = damperZ.GetValue();
		
		return ret;
	}
	
	public final function IsRunning() : bool
	{
		return damperX.IsRunning() || damperY.IsRunning() || damperZ.IsRunning();
	}
}