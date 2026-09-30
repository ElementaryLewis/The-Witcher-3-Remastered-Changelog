/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import function t_Identity(  a : EngineQsTransform );
import function t_SetIdentity() : EngineQsTransform;

import function t_BuiltTrans( move : Vector ) : EngineQsTransform;
import function t_BuiltRotQuat( quat : Vector ) : EngineQsTransform;
import function t_BuiltRotAngles( x : float, y : float, z : float ) : EngineQsTransform;
import function t_BuiltScale( scale : Vector ) : EngineQsTransform;

import function t_Trans(  a : EngineQsTransform, move : Vector );
import function t_RotQuat(  a : EngineQsTransform, quat : Vector );
import function t_Scale(  a : EngineQsTransform, scale : Vector );

import function t_SetTrans( a : EngineQsTransform, move : Vector ) : EngineQsTransform;
import function t_SetRotQuat( a : EngineQsTransform, quat : Vector ) : EngineQsTransform;
import function t_SetScale( a : EngineQsTransform, scale : Vector ) : EngineQsTransform;

import function t_GetTrans( a : EngineQsTransform ) : Vector;
import function t_GetRotQuat( a : EngineQsTransform ) : Vector;
import function t_GetScale( a : EngineQsTransform ) : Vector;

import function t_SetMul( a : EngineQsTransform, b : EngineQsTransform ) : EngineQsTransform;
import function t_SetMulMulInv( a : EngineQsTransform, b : EngineQsTransform ) : EngineQsTransform;
import function t_SetMulInvMul( a : EngineQsTransform, b : EngineQsTransform ) : EngineQsTransform;

import function t_SetInterpolate( a : EngineQsTransform, b: EngineQsTransform, w : float ) : EngineQsTransform;
import function t_IsEqual( a : EngineQsTransform, b : EngineQsTransform ) : bool;

import function t_Inv(  a : EngineQsTransform );
import function t_SetInv( a : EngineQsTransform ) : EngineQsTransform;

import function t_NormalizeQuat(  a : EngineQsTransform );
import function t_BlendNormalize(  a : EngineQsTransform, w : float );
import function t_IsOk( a : EngineQsTransform ) : bool;






import function q_SetIdentity() : Vector;
import function q_Identity(  a : Vector );

import function q_SetInv( a : Vector ) : Vector;
import function q_Inv(  a : Vector );

import function q_SetNormalize( a : Vector ) : Vector;
import function q_Normalize(  a : Vector );

import function q_SetMul( a : Vector, b : Vector ) : Vector;
import function q_SetMulMulInv( a : Vector, b : Vector ) : Vector;
import function q_SetMulInvMul( a : Vector, b : Vector ) : Vector;

import function q_SetShortestRotation( from : Vector, to : Vector ) : Vector;
import function q_SetShortestRotationDamped( from : Vector, to : Vector, w : float ) : Vector;

import function q_SetAxisAngle( axis : Vector, angle : float ) : Vector;
import function q_RemoveAxisComponent(  quat : Vector, axis : Vector );
import function q_DecomposeAxis( quat : Vector, axis : Vector ) : float;

import function q_SetSlerp( a : Vector, b : Vector, w : float ) : Vector;

import function q_GetAngle( a : Vector ) : float;
import function q_GetAxis( a : Vector ) : Vector;






import function v_SetInterpolate( a : Vector, b : Vector, w : float ) : Vector;
import function v_SetRotatedDir( quat : Vector, dir : Vector ) : Vector;
import function v_SetTransformedPos( trans : EngineQsTransform, vec : Vector ) : Vector;
import function v_ZeroElement(  a : Vector , i : int );



function EPSILON() : float
{
	return 0.0001f; 
}






function GetRangePct_F( minVal : float, maxVal : float, value : float ) : float 
{
	return (value - minVal) / (maxVal - minVal);
}


function GetRangePct_V( range : Vector, value : float) : float
{
	if(range.X != range.Y)
	{
		return ((value - range.X) / (range.Y - range.X));
	}
	else
	{
		return range.X;
	}
}


function GetRangeVal_F( minVal : float, maxVal : float, pct : float ) : float 
{
	return ( minVal + (maxVal - minVal) * pct );
}


function GetRangeVal_V( range : Vector, pct : float ) : float
{
	return ( range.X + (range.Y - range.X) * pct );
}


function GetMappedRangeValue( inRange : Vector, outRange : Vector, value : float ) : float
{
	var clampedPct : float;
	
	clampedPct = ClampF(GetRangePct_V(inRange, value), 0.f, 1.f);
	
	return	GetRangeVal_V(outRange, clampedPct);
}


function InterpTo_F( current : float, desired : float, deltaTime : float, interpSpeed : float ) : float
{
	var dist, delta : float;


	if( interpSpeed <= 0.f )
	{
		return desired;
	}
	
	dist = desired - current;
	
	if( AbsF(dist) < EPSILON() )
	{
		return desired;
	}
	
	delta = dist * ClampF(deltaTime * interpSpeed, 0, 1.f);

	return current + delta;
}


function InterpConstTo_F( current : float, desired : float, deltaTime : float, interpSpeed : float ) : float
{
	var dist, step : float;


	if( interpSpeed <= 0.f )
	{
		return desired;
	}
	
	dist = desired - current;
	
	if( AbsF( dist ) < EPSILON() )
	{
		return desired;
	}
	
	step = deltaTime * interpSpeed;
	
	return current + ClampF(dist, -step, step);
}


function InterpEaseIn_F( a : float, b : float, alpha : float, exp : float ) : float
{
	return LerpF(PowF(alpha, exp), a, b);
}


function InterpEaseOut_F( a : float, b : float, alpha : float, exp : float ) : float
{
	return LerpF(PowF(alpha, 1/exp), a, b);
}


function InterpEaseInOut_F( a : float, b : float, alpha : float, exp : float ) : float
{
	var alphaMod : float;
	
	if( alpha < 0.5f )
	{
		alphaMod = 0.5f * PowF(2.f * alpha, exp);
	}
	else
	{
		alphaMod = 1.f - 0.5f * PowF(2.f * (1.f - alpha), exp);
	}

	return LerpF(alphaMod, a, b);
}


function CubicInterp_F( p0 : float, t0 : float, p1 : float, t1 : float, a : float ) : float
{
	var a2 : float = a * a;
	var a3 : float = a2 * a;

	return( p0 * (2*a3 - 3*a2 + 1) +
			p1 * (-2*a3 + 3*a2) +
			t0 * (a3 - 2*a2 + a) +
			t1 * (a3 - a2) );
}






function GetVectComponent( v : Vector, inComp : int ) : float
{
	switch(inComp)
	{
		case 0: return v.X; break;
		case 1: return v.Y; break;
		case 2: return v.Z; break;
		case 3: return v.W; break;
		default: break;
	}
	
	return 0.f;
}


function LerpV( a : Vector, b : Vector, alpha : float ) : Vector
{
	var dist, delta : Vector;
	
	dist = b - a;
	
	if( VecLength(dist) < EPSILON() )
	{
		return b;
	}
	
	delta = dist * ClampF(alpha, 0.f, 1.f);

	return a + delta;	
}


function InterpTo_V( current : Vector, desired : Vector, deltaTime : float, interpSpeed : float ) : Vector
{
	var dist, delta : Vector;


	if( interpSpeed <= 0.f )
	{
		return desired;
	}
	
	dist = desired - current;
	
	if( VecLength(dist) < EPSILON() )
	{
		return desired;
	}
	
	delta = dist * ClampF(deltaTime * interpSpeed, 0.f, 1.f);

	return current + delta;
}


function CubicInterp_V( p0 : Vector, t0 : Vector, p1 : Vector, t1 : Vector, a : float ) : Vector
{
	var a2 : float = a * a;
	var a3 : float = a2 * a;

	return( p0 * (2*a3 - 3*a2 + 1) +
			p1 * (-2*a3 + 3*a2) +
			t0 * (a3 - 2*a2 + a) +
			t1 * (a3 - a2) );
}


function InterpEaseIn_V( a : Vector, b : Vector, alpha : float, exp : float ) : Vector
{
	return LerpV( a, b, PowF(alpha, exp));
}


function InterpEaseOut_V( a : Vector, b : Vector, alpha : float, exp : float ) : Vector
{
	return LerpV(a, b, PowF(alpha, 1/exp));
}


function InterpEaseInOut_V( a : Vector, b : Vector, alpha : float, exp : float ) : Vector
{
	var alphaMod : float;
	
	if( alpha < 0.5f )
	{
		alphaMod = 0.5f * PowF(2.f * alpha, exp);
	}
	else
	{
		alphaMod = 1.f - 0.5f * PowF(2.f * (1.f - alpha), exp);
	}

	return LerpV(a, b, alphaMod);
}



function VecReduceTowardsZero( source : Vector, ammount : float ) : Vector
{
	var length	: float;
	
	length		= VecLength( source );
	if( length > 0.0f )
	{
		return	source * MaxF( 0.0f, length - ammount ) / length;
	}
	
	return source;
}
	


function VecReduceNotExceedingV( _VectorV : Vector, _ReductionAmmountF :float, _MinLengthF : float ) :Vector
{
	var l_LengthF : float	= VecLengthSquared( _VectorV );
	
	
	if(l_LengthF <= _MinLengthF * _MinLengthF )
	{
		return _VectorV;
	}
	
	
	l_LengthF	= SqrtF( l_LengthF );
	
	
	if(l_LengthF - _ReductionAmmountF	<=  _MinLengthF)
	{
		_VectorV	*= _MinLengthF / l_LengthF;
	}
	
	else
	{
		_VectorV	*= ( 1.0f - _ReductionAmmountF / l_LengthF );
	}

	return _VectorV;
}



function VecAddNotExceedingV( _VectorV : Vector, _AdditionV : Vector, _MaxLengthF : float ) : Vector
{
	var l_LengthPreviousF	: float	= VecLength( _VectorV );
	var l_LenghtNewF		: float;
	var l_LenghtMaxF		: float;
	
	
	_VectorV	+= _AdditionV;
	
	
	l_LenghtNewF	= VecLength( _VectorV );
	
	l_LenghtMaxF	= MaxF( _MaxLengthF, l_LengthPreviousF );
	
	if( l_LenghtNewF > l_LenghtMaxF )
	{
		_VectorV	*= l_LenghtMaxF / l_LenghtNewF;
	}
	
	return _VectorV;
}



function VecSetZeros(out vector  : Vector)
{
	vector.X = 0.0;
	vector.Y = 0.0;
	vector.Z = 0.0;
	vector.W = 0.0;
} 



function EulerSetZeros( out eulerAngles : EulerAngles )
{
	eulerAngles.Yaw		= 0.0f;
	eulerAngles.Pitch	= 0.0f;
	eulerAngles.Roll	= 0.0f;
}



function LogVector(vectorName : string, vector  : Vector)
{
	Log(vectorName + ": " + vector.X + " " + vector.Y + " " + vector.Z + " " + vector.W);
}



function MapF(val, minOrig, maxOrig, minDest, maxDest : float) : float
{
	return minDest + ((val - minOrig) / (maxOrig - minOrig) * (maxDest - minDest));
}
	


function BlendLinearF(value, target, speed : float) : float
{
	if(value < target)
	{
		value = MinF(value + speed, target);
	}
	else if(value > target)
	{
		value = MaxF(value - speed, target);
	}
	
	return value;
}
	

function BlendF(origin, end, coef : float) : float
{
	return origin * (1.0f - coef) + end * coef;
} 



function SignF( value : float )	: float
{
	if( value >= 0.0f )
	{
		return 1.0f;
	}
	return -1.0f;
}



function SignOrZeroF( value : float )	: float
{
	if( value > 0.0f )
	{
		return 1.0f;
	}
	else if( value < 0.0f )
	{
		return -1.0f;
	}
	
	return 0.0f;
}