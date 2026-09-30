/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CWorld extends CResource
{
	
	import final function ShowLayerGroup( layerGroupName : string );

	
	import final function HideLayerGroup( layerGroupName : string );
	
	
	import final function PointProjectionTest( point : Vector, normal : EulerAngles, range : float ) : bool; 
	
	
	import final function StaticTrace( pointA, pointB : Vector, out position : Vector, out normal : Vector, optional collisionGroupsNames : array<name> ) : bool;
	
	import final function StaticTraceWithAdditionalInfo( pointA, pointB : Vector, out position : Vector, out normal : Vector, out material : name, out component : CComponent, optional collisionGroupsNames : array<name> ) : bool;

	
	
	import final function SweepTest( pointA, pointB : Vector, radius : float, out position, normal : Vector, optional collisionGroupsNames : array<name> ) : bool;

	
	import final function SphereOverlapTest( out entities : array< CEntity > ,position : Vector, radius : float, optional collisionGroupsNames : array< name > ) : int;	
	
	
	import final function GetWaterLevel( point : Vector, optional dontUseApproximation : bool ) : float;
	
	
	import final function GetWaterDepth( point : Vector, optional dontUseApproximation : bool ) : float;
	
	
	import final function GetWaterTangent( point : Vector, direction : Vector, optional resolution : float  ) : Vector;
	
	import final function ForceUpdateWaterOnPause( force : bool );

	
	
	
	import final function NavigationLineTest( pos1 : Vector, pos2 : Vector, radius : float, optional ignoreObstacles : bool , optional noEndpointZ : bool  ) : bool;
	
	
	
	import final function NavigationCircleTest( position : Vector, radius : float, optional ignoreObstacles : bool  ) : bool;
	
	
	
	
	
	
	
	import final function NavigationClosestObstacleToLine( pos1 : Vector, pos2 : Vector, radius : float, out closestPointOnLine : Vector, out closestPointOnGeometry : Vector, optional ignoreObstacles : bool  ) : float;
	
	
	
	
	
	
	import final function NavigationClosestObstacleToCircle( position : Vector, radius : float, out closestPointOnGeometry : Vector, optional ignoreObstacles : bool  ) : float;
	
	
	
	import final function NavigationClearLineInDirection(  pos1 : Vector, pos2 : Vector, radius : float, out closestPointOnLine : Vector ) : bool;
	
	
	
	import final function NavigationFindSafeSpot( position : Vector, personalSpace : float, searchRadius : float, out outSafeSpot : Vector ) : bool;
	
	
	
	import final function NavigationComputeZ( position : Vector, zMin : float, zMax : float, out z : float ) : bool;
	
	
	
	import final function PhysicsCorrectZ( position : Vector, out z : float ) : bool;

	import final function GetDepotPath() : string;
	
	
	import final function ForceGraphicalLOD( lodLevel : int );	
	
	
	import final function GetTerrainParameters( out terrainSize : float, out tilesCount : int ) : bool;
	
	
	import final function GetTraceManager() : CScriptBatchQueryAccessor;	
	
	import final function GetCameraDirector() : CCameraDirector;
	
	
	event OnWeatherChange()
	{
		if(thePlayer)
			thePlayer.OnWeatherChanged();
	}	
	
};
