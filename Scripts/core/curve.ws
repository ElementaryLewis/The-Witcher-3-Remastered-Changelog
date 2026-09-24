/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CCurve extends CObject
{
	import function GetValue( time : float ) : float;
	import function GetDuration() : float;
}







enum EInterpMethodType
{
	IMT_UseNewAutoTangents,
	IMT_UseFixedTangentEval,
	IMT_UseBrokenTangentEval
};



class InterpCurve
{
	var interpMethod : EInterpMethodType;	
}


class InterpCurveF extends InterpCurve
{
	var points : array<InterpCurvePointF>;
	
	
	function AddPoint( inVal : float, outVal : float ) : int
	{
		var keyPoint : InterpCurvePointF = new InterpCurvePointF in this;
		var numPoints : int = points.Size();
		var i : int;
		
		
		keyPoint.inVal = inVal;
		keyPoint.outVal = outVal;
		keyPoint.interpMode = CIM_Linear;
		
		for( i = 0; i < numPoints && points[i].inVal < inVal; i = i + 1 );
		points.Insert( i, keyPoint );
		
		return i;
	}
	
	
	private function ComputeCurveTangent( prevTime : float, prevPoint : float,
								currTime : float, currPoint : float,
								nextTime : float, nextPoint : float,
								tension : float,
								out outTangent : float )
	{
		var timeDiff : float;
	
		AutoCalcTangent( prevPoint, currPoint, nextPoint, tension, outTangent );

		timeDiff = MaxF( EPSILON(), nextTime - prevTime );
		outTangent /= timeDiff;
	}
	
	
	private function AutoCalcTangent( prevP : float, p : float, nextP : float, tension : float, out outTan : float )
	{
		outTan = (1.f - tension) * ( (p - prevP) + (nextP - p) );
	}
	
	
	private function AutoCalcClampTngent( prevP : float, p : float, nextP : float, tension : float, out outTan : float ){}
	
	
	function AutoSetTangents( optional tension : float )
	{
		var numPoints : int = points.Size();
		var ptIdx : int;
		var arriveTangent, leaveTangent : float;
		
		
		for( ptIdx = 0; ptIdx < numPoints; ptIdx = ptIdx + 1 )
		{
			arriveTangent = points[ptIdx].arriveTangent;
			leaveTangent = points[ptIdx].leaveTangent;
			
			if(ptIdx == 0)
			{
				if(ptIdx < numPoints - 1) 
				{
					if( points[ptIdx].interpMode == CIM_CurveAuto )
					{
						leaveTangent = 0;
					}
				}
				else 
				{
					leaveTangent = 0;
				}			
			}
			else
			{
				if(ptIdx < numPoints - 1) 
				{
					if( points[ptIdx].interpMode == CIM_CurveAuto )
					{
						if( points[ptIdx - 1].IsCurveKey()
							&& points[ptIdx].IsCurveKey() )
						{
							if( interpMethod == IMT_UseNewAutoTangents )
							{
								ComputeCurveTangent(points[ptIdx - 1].inVal, points[ptIdx - 1].outVal, 
													points[ptIdx].inVal, points[ptIdx].outVal,
													points[ptIdx + 1].inVal, points[ptIdx + 1].outVal,
													tension, arriveTangent );
							}
							else
							{
								AutoCalcTangent( points[ptIdx-1].outVal, points[ptIdx].outVal, points[ptIdx+1].outVal, tension, arriveTangent );
							}
							
							leaveTangent = arriveTangent;
						}
						else if( points[ptIdx-1].interpMode == CIM_Constant || points[ptIdx].interpMode == CIM_Constant )
						{
							arriveTangent = 0;
							leaveTangent = 0;
						}
					}
				}
				else 
				{
					if( points[ptIdx].interpMode == CIM_CurveAuto )
					{
						arriveTangent = 0;
					}				
				}
			}
		
			points[ptIdx].arriveTangent = arriveTangent;
			points[ptIdx].leaveTangent = leaveTangent;
		}
	}

	
	
	function Eval(inVal : float, defaultVal : float, optional out ptIdx : int) : float
	{
		var numPoints : int = points.Size();
		var diff : float;
		var i : int;
		var alpha : float;
	
		
		if( numPoints == 0 )
		{
			ptIdx = -1;
			return defaultVal;
		}
		
		
		if( numPoints < 2 || inVal <= points[0].inVal )
		{
			ptIdx = 0;
			return points[0].outVal;
		}
		
		
		if( inVal >= points[numPoints-1].inVal )
		{
			ptIdx = numPoints - 1;
			return points[numPoints-1].outVal;
		}
		
		
		for( i = 1; i < numPoints; i = i + 1 )
		{
			if( inVal < points[i].inVal )
			{
				diff = points[i].inVal - points[i-1].inVal;

				if( diff > 0.f )
				{
					alpha = (inVal - points[i-1].inVal) / diff;
					ptIdx = i - 1;
					
					switch( points[i-1].interpMode )
					{
						case CIM_Constant:						
							return points[numPoints-1].outVal;
							break;
							
						case CIM_Linear:						
							return LerpF( alpha, points[i-1].outVal, points[i].outVal );
							break;
							
						default:						
							switch( interpMethod )
							{
								case IMT_UseBrokenTangentEval:
								
									return CubicInterp_F(points[i-1].outVal, points[i-1].leaveTangent, points[i].outVal, points[i].arriveTangent, alpha);
									break;
									
								default:
									return CubicInterp_F(points[i-1].outVal, points[i-1].leaveTangent * diff, points[i].outVal, points[i].arriveTangent * diff, alpha);
									break;
							}
						
							break;
					}
				}
			}
		}
		
		
		ptIdx = numPoints - 1;
		return points[numPoints-1].outVal;
	}
}


class InterpCurveV extends InterpCurve
{
	var points : array<InterpCurvePointV>;


	function AddPoint( inVal : float, outVal : Vector ) : int
	{
		var keyPoint : InterpCurvePointV = new InterpCurvePointV in this;
		var numPoints : int = points.Size();
		var i : int;
		
		
		keyPoint.inVal = inVal;
		keyPoint.outVal = outVal;
		keyPoint.interpMode = CIM_Linear;
		
		for( i = 0; i < numPoints && points[i].inVal < inVal; i = i + 1 );
		points.Insert( i, keyPoint);

		return i;
	}

	
	private function ComputeCurveTangent( prevTime : float, prevPoint : Vector,
								currTime : float, currPoint : Vector,
								nextTime : float, nextPoint : Vector,
								tension : float,
								out outTangent : Vector )
	{
		var timeDiff : float;
	
		AutoCalcTangent( prevPoint, currPoint, nextPoint, tension, outTangent );

		timeDiff = MaxF( EPSILON(), nextTime - prevTime );
		outTangent /= timeDiff;
	}
	
	
	private function AutoCalcTangent( prevP : Vector, p : Vector, nextP : Vector, tension : float, out outTan : Vector )
	{
		outTan = (1.f - tension) * ( (p - prevP) + (nextP - p) );
	}
	
	
	private function AutoCalcClampTngent( prevP : float, p : float, nextP : float, tension : float, out outTan : float ){}
	
	
	function AutoSetTangents( optional tension : float )
	{
		var numPoints : int = points.Size();
		var ptIdx : int;
		var arriveTangent, leaveTangent : Vector;
		
		
		for( ptIdx = 0; ptIdx < numPoints; ptIdx = ptIdx + 1 )
		{
			arriveTangent = points[ptIdx].arriveTangent;
			leaveTangent = points[ptIdx].leaveTangent;
			
			if(ptIdx == 0)
			{
				if(ptIdx < numPoints - 1) 
				{
					if( points[ptIdx].interpMode == CIM_CurveAuto )
					{
						leaveTangent = Vector( 0.f, 0.f, 0.f, 0.f );
					}
				}
				else 
				{
					leaveTangent = Vector( 0.f, 0.f, 0.f, 0.f );
				}			
			}
			else
			{
				if(ptIdx < numPoints - 1) 
				{
					if( points[ptIdx].interpMode == CIM_CurveAuto )
					{
						if( points[ptIdx - 1].IsCurveKey()
							&& points[ptIdx].IsCurveKey() )
						{
							if( interpMethod == IMT_UseNewAutoTangents )
							{
								ComputeCurveTangent(points[ptIdx - 1].inVal, points[ptIdx - 1].outVal, 
													points[ptIdx].inVal, points[ptIdx].outVal,
													points[ptIdx + 1].inVal, points[ptIdx + 1].outVal,
													tension, arriveTangent );
							}
							else
							{
								AutoCalcTangent( points[ptIdx-1].outVal, points[ptIdx].outVal, points[ptIdx+1].outVal, tension, arriveTangent );
							}
							
							leaveTangent = arriveTangent;
						}
						else if( points[ptIdx-1].interpMode == CIM_Constant || points[ptIdx].interpMode == CIM_Constant )
						{
							arriveTangent = Vector( 0.f, 0.f, 0.f, 0.f );
							leaveTangent = Vector( 0.f, 0.f, 0.f, 0.f );
						}
					}
				}
				else 
				{
					if( points[ptIdx].interpMode == CIM_CurveAuto )
					{
						arriveTangent = Vector( 0.f, 0.f, 0.f, 0.f );
					}				
				}
			}
		
			points[ptIdx].arriveTangent = arriveTangent;
			points[ptIdx].leaveTangent = leaveTangent;
		}
	}

	
	
	function Eval(inVal : float, defaultVal : Vector, optional out ptIdx : int) : Vector
	{
		var numPoints : int = points.Size();
		var diff : float;
		var i : int;
		var alpha : float;
	
		
		if( numPoints == 0 )
		{
			ptIdx = -1;
			return defaultVal;
		}
		
		
		if( numPoints < 2 || inVal <= points[0].inVal )
		{
			ptIdx = 0;
			return points[0].outVal;
		}
		
		
		if( inVal >= points[numPoints-1].inVal )
		{
			ptIdx = numPoints - 1;
			return points[numPoints-1].outVal;
		}
		
		
		for( i = 1; i < numPoints; i = i + 1 )
		{
			if( inVal < points[i].inVal )
			{
				diff = points[i].inVal - points[i-1].inVal;

				if( diff > 0.f )
				{
					alpha = (inVal - points[i-1].inVal) / diff;
					ptIdx = i - 1;
					
					switch( points[i-1].interpMode )
					{
						case CIM_Constant:						
							return points[numPoints-1].outVal;
							break;
							
						case CIM_Linear:						
							return LerpV( points[i-1].outVal, points[i].outVal, alpha );
							break;
							
						default:						
							switch( interpMethod )
							{
								case IMT_UseBrokenTangentEval:
								
									return CubicInterp_V(points[i-1].outVal, points[i-1].leaveTangent, points[i].outVal, points[i].arriveTangent, alpha);
									break;
									
								default:
									return CubicInterp_V(points[i-1].outVal, points[i-1].leaveTangent * diff, points[i].outVal, points[i].arriveTangent * diff, alpha);
									break;
							}
						
							break;
					}
				}
			}
		}
		
		
		ptIdx = numPoints - 1;
		return points[numPoints-1].outVal;
	}	
}