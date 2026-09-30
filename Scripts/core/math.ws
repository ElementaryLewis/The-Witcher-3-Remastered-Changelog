/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct Vector
{
	import var X,Y,Z,W : float;
}


import struct EulerAngles
{
	import var Pitch, Yaw, Roll : float;
}


import struct Matrix
{
	import var X,Y,Z,W : Vector;
}


import struct Box
{
	import var Min, Max : Vector;		
}


import struct Color
{
 	import var Red, Green, Blue, Alpha : byte;
};


import struct Sphere
{
	import var CenterRadius2 : Vector;
}


struct SRange
{
	editable var min : int;
	editable var max : int;
}
struct SRangeF
{
	editable var min : float;
	editable var max : float;
}






function Pi() : float
{
	return 3.14159265;
}


import function RandRange( max : int, optional min : int ) : int;


import function RandDifferent( lastValue : int, optional range : int ) : int;


import function RandF() : float;


import function RandRangeF( max : float, optional min : float ) : float;


import function RandNoiseF( seed : int, max : float, optional min : float ) : float;


import function Abs( a : int ) : int;


import function Min( a,b : int ) : int;


import function Max( a,b : int ) : int;


import function Clamp( v, min, max : int ) : int;


import function Deg2Rad( deg : float ) : float;


import function Rad2Deg( rad : float ) : float;


import function AbsF( a : float ) : float;

function SgnF( a : float ) : float
{
	if( a > 0 ) 
	{
		return 1.f;
	}
	return -1.f;
}


function ModF(a : float, b : float) : float
{
	if(b <= 0 || a <= 0)
		return 0;

	return a - FloorF(a / b) * b;
}


import function SinF( a : float ) : float;


import function AsinF( a : float ) : float;


import function CosF( a : float ) : float;


import function AcosF( a : float ) : float;


import function TanF( a : float ) : float;


import function AtanF( a,b : float ) : float;


import function ExpF( a : float ) : float;


import function PowF( a,x : float ) : float;


import function LogF( a : float ) : float;
 

import function SqrtF( a : float ) : float;


import function SqrF( a : float ) : float;


import function CalcSeed( object : IScriptable ) : int;


import function MinF( a,b : float ) : float;


import function MaxF( a,b : float ) : float;


import function ClampF( v, min, max : float ) : float;


import function LerpF( alpha, a, b : float, optional clamp : bool ) : float;


import function CeilF( a : float ) : int;


import function FloorF( a : float ) : int;


import function RoundF( a : float ) : int;

	
function RoundMath(f : float) : int
{
	if(f==0)
	{
		return (int)f;
	}
	else if(f>0)
	{
		if(f-FloorF(f) >= 0.5)
			return CeilF(f);
		return FloorF(f);
	}
	else
	{
		if(f+FloorF(f) >= -0.5)
			return CeilF(f);
		return FloorF(f);
	}
}



function RoundTo(f : float, decimal : int) : float
{
	var i, digit : int;
	var ret : float;
	var isNeg : bool;

	if(decimal < 0)
		decimal = 0;

	ret = FloorF(AbsF(f));
	isNeg = false;
	if(f<0)
	{
		isNeg = true;		
		f *= -1;
	}
	f -= ret;
	
	for(i=0; i<decimal; i+=1)
	{
		f *= 10;
		digit = FloorF(f);
		ret += digit / PowF(10,i+1);
		f -= digit;
	}
	
	if(isNeg)
		ret *= -1;
		
	return ret;
}


import function ReinterpretIntAsFloat( a : int ) : float;






import function AngleNormalize( a : float ) : float;


function AngleNormalize180( a : float ) : float
{
	if( a >= -180 && a <= 180 )
	{
		return a;
	}
	else if( a < -360 || a > 360 )
	{
		a = AngleNormalize( a );
	}
	if ( a > 180.f )
	{
		a -= 360.f;
	}
	else if ( a < -180.f )
	{
		a += 360.f;
	}
	return a;
}


function LerpAngleF( alpha, a, b : float ) : float
{
	return a + AngleDistance( b, a ) * alpha;
}


import function AngleDistance( target, current : float ) : float;


import function AngleApproach( target, cur, step : float ) : float;


function NodeToNodeAngleDistance( target, current : CNode ) : float
{
	return -AngleDistance( VecHeading(  target.GetWorldPosition() - current.GetWorldPosition() ), current.GetHeading() );
}






import function VecDot2D( a, b : Vector ) : float;


import function VecDot( a, b : Vector ) : float;


import function VecCross( a, b : Vector ) : Vector;


import function VecLength2D( a : Vector ) : float;


import function VecLengthSquared( a : Vector ) : float;


import function VecLength( a : Vector ) : float;


import function VecNormalize2D( a : Vector ) : Vector;


import function VecNormalize( a : Vector ) : Vector;


import function VecRand2D() : Vector;


import function VecRand() : Vector;


function VecRingRand( minRadius, maxRadius : float ) : Vector
{	
	var r, angle : float;	
	r = RandRangeF( maxRadius, minRadius );
	angle = RandRangeF( 6.28318530 );	
	return Vector( r*CosF( angle ), r*SinF( angle ), 0.0, 1.0 );
}


function VecConeRand( coneDir, coneAngle, minRadius, maxRadius : float ) : Vector
{	
	var r, angle, angleMin, angleMax : float;
	r = RandRangeF( maxRadius, minRadius );
	angleMin = Deg2Rad( coneDir - ( coneAngle * 0.5 ) + 90 );
	angleMax = Deg2Rad( coneDir + ( coneAngle * 0.5 ) + 90 );
	angle = RandRangeF( angleMax, angleMin );
	return Vector( r*CosF( angle ), r*SinF( angle ), 0.0, 1.0 );
}


function VecRingRandStatic( seed : int, minRadius, maxRadius : float ) : Vector
{	
	var r, angle : float;	
	r = RandNoiseF( seed, maxRadius, minRadius );
	angle = RandNoiseF( seed, 6.28318530 );
	return Vector( r*CosF( angle ), r*SinF( angle ), 0.0, 1.0 );
}


import function VecMirror( dir, normal : Vector ) : Vector;


import function VecDistance( from, to : Vector ) : float;


import function VecDistanceSquared( from, to : Vector ) : float;


import function VecDistance2D( from, to : Vector ) : float;


import function VecDistanceSquared2D( from, to : Vector ) : float;


import function VecDistanceToEdge( point, a, b : Vector ) : float;


import function VecNearestPointOnEdge( point, a, b : Vector ) : Vector;


import function VecToRotation( dir : Vector ) : EulerAngles;


import function VecHeading( dir : Vector ) : float;


import function VecFromHeading( heading : float ) : Vector;


import function VecTransform( m : Matrix, point : Vector ) : Vector;


import function VecTransformDir( m : Matrix, point : Vector ) : Vector;


import function VecTransformH( m : Matrix, point : Vector ) : Vector;


import function VecGetAngleBetween( from : Vector, to : Vector ) : float;


import function VecGetAngleDegAroundAxis( dirA : Vector, dirB : Vector, axis : Vector ) : float;


import function VecProjectPointToPlane( p1 : Vector, p2 : Vector, p3 : Vector, toProject : Vector ) : Vector;


import function VecRotateAxis( vector : Vector, axis : Vector, angle : float ) : Vector;

function VecRotByAngleXY(vec : Vector, angleDeg : float) : Vector
{
	var ret : Vector;
	var angle : float;
	
	angle = Deg2Rad(angleDeg);
	ret = vec;
	ret.X 	= 	vec.X*CosF( -angle ) - vec.Y*SinF( -angle );
	ret.Y 	= 	vec.X*SinF( -angle ) + vec.Y*CosF( -angle );
	
	return ret;
}

function VecInterpolate( v1, v2 : Vector, ratio : float ) : Vector
{
	var dir : Vector;
	
	dir = v2 - v1;
	
	return v1 + dir * ratio;
}


function VecToString( vec : Vector ) : string
{
	return vec.X + " " + vec.Y + " " + vec.Z + " " + vec.W;
}

function VecToStringPrec( vec : Vector, precision : int ) : string
{
	return FloatToStringPrec( vec.X, precision ) + " " + FloatToStringPrec( vec.Y, precision ) + " " + FloatToStringPrec( vec.Z, precision ) + " " + FloatToStringPrec( vec.W, precision );
}









import function RotX( rotation : EulerAngles ) : Vector;


import function RotY( rotation : EulerAngles ) : Vector;


import function RotZ( rotation : EulerAngles ) : Vector;


import function RotForward( rotation : EulerAngles ) : Vector;


import function RotRight( rotation : EulerAngles ) : Vector;


import function RotUp( rotation : EulerAngles ) : Vector;


import function RotToMatrix( rotation : EulerAngles ) : Matrix;


import function RotAxes( rotation : EulerAngles, out foward, right, up : Vector );


import function RotDot( a, b : EulerAngles );


import function RotRand( min, max : float ) : EulerAngles;


function GetOppositeRotation180(rot : EulerAngles) : EulerAngles
{
	var ret : EulerAngles;
	
	ret.Pitch = AngleNormalize180(rot.Pitch + 180);
	ret.Yaw = AngleNormalize180(rot.Yaw + 180);
	ret.Roll = AngleNormalize180(rot.Roll + 180);
	
	return ret;	
}





import function MatrixIdentity() : Matrix;


import function MatrixBuiltTranslation( move : Vector ) : Matrix;


import function MatrixBuiltRotation( rot : EulerAngles ) : Matrix;


import function MatrixBuiltScale( scale : Vector ) : Matrix;


import function MatrixBuiltPreScale( scale : Vector ) : Matrix;


import function MatrixBuiltTRS( optional translation : Vector, optional rotation : EulerAngles, optional scale : Vector ) : Matrix;


import function MatrixBuiltRTS( optional rotation : EulerAngles, optional translation : Vector, optional scale : Vector ) : Matrix;


import function MatrixBuildFromDirectionVector( dirVec : Vector ) : Matrix;


import function MatrixGetTranslation( m : Matrix  ) : Vector;


import function MatrixGetRotation( m : Matrix ) : EulerAngles;


import function MatrixGetScale( m : Matrix ) : Vector;


import function MatrixGetAxisX( m : Matrix ) : Vector;


import function MatrixGetAxisY( m : Matrix ) : Vector;


import function MatrixGetAxisZ( m : Matrix ) : Vector;


import function MatrixGetDirectionVector( m : Matrix ) : Vector;



import function MatrixGetInverted( m : Matrix  ) : Matrix;





function GetBoxSize( box : Box ) : Vector
{
	return box.Max - box.Min;
}

function GetBoxExtents( box : Box ) : Vector
{
	return ( box.Max - box.Min ) * 0.5f;
}

function GetBoxRange( box : Box ) : float
{
	var size : Vector;
	size = GetBoxExtents( box );
	if ( size.X > size.Y )
	{
		if ( size.X > size.Z )
		{
			return size.X;
		}
	}
	else
	{
		if ( size.Y > size.Z )
		{
			return size.Y;
		}
	}
	return size.Z;
}






import function SphereIntersectRay( sphere : Sphere, orign : Vector, direction : Vector, out enterPoint : Vector, out exitPoint : Vector ) : int;


import function SphereIntersectEdge( sphere : Sphere, a : Vector, b : Vector, out intersectionPoint0 : Vector, out intersectionPoint1 : Vector ) : int;




import function Int8ToInt( i : Int8 ) : int;
import function IntToInt8( i : int ) : Int8;

import function IntToUint64( i : int ) : Uint64;
import function Uint64ToInt( i : Uint64 ) : int;