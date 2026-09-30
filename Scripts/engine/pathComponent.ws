/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CPathComponent extends CComponent
{
	
	import final function FindClosestEdge( point : Vector ) : int;

	import final function GetAlphaOnEdge( point : Vector, edgeIdx : int, optional epsilon : float  ) : float;

	import final function GetClosestPointOnPath   ( point : Vector, optional epsilon : float  ) : Vector;
	import final function GetClosestPointOnPathExt( point : Vector, out edgeIdx : int, out edgeAlpha : float,
													optional epsilon : float  ) : Vector;

	import final function GetFirstPointOnPathInRangeExt( point : Vector, range : float, out edgeIdx : int, out edgeAlpha : float, out outDir : Vector, optional epsilon : float  ) : Vector;

	import final function GetDistanceToPath( point : Vector, optional epsilon : float  ) : float;

	import final function GetNextPointOnPath( point : Vector, distance : float, out isEndOfPath : bool, optional epsilon : float  ) : Vector;
	import final function GetNextPointOnPathExt( out edgeIdx : int, out edgeAlpha : float, distance : float, out isEndOfPath : bool, optional epsilon : float  ) : Vector;
	
	import final function GetPathTimePoint(currentTime : float): Vector;
	
	import final function GetPointsCount() : int;
	import final function GetWorldPoint( index : int ) : Vector;
}