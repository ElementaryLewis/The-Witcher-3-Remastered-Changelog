/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CVolumePathManager extends IGameSystem
{
	import function GetPath( start : Vector, end : Vector, out resultPath : array<Vector>, optional maxHeight : float ) : bool;
	import function GetPointAlongPath( start : Vector, end : Vector, distAlongPath : float, optional maxHeight : float ) : Vector;
	import function IsPathfindingNeeded( start : Vector, end : Vector ) : bool;
};