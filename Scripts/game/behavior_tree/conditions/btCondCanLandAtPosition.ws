/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondCanLandAtPosition extends IBehTreeTask
{
	
	
	
	public var localOffset 				: Vector;
	public var checkLineOfSight			: bool;
	public var maxDistanceFromGround	: float;
	public var landOnlyInGuardArea		: bool;
	
	private var m_CollisionGroupNames : array<name>;
	private var m_ObstaclesGroupNames : array<name>;
	
	
	function Initialize()
	{
		m_CollisionGroupNames.PushBack('Terrain');
		m_CollisionGroupNames.PushBack('Foliage');
		m_CollisionGroupNames.PushBack('Static');
		
		m_ObstaclesGroupNames.PushBack('Foliage');
		m_ObstaclesGroupNames.PushBack('Static');
	}
	
	
	function IsAvailable() : bool
	{
		var l_npc 			: CNewNPC = GetNPC();
		var l_matrix		: Matrix;
		var l_pos			: Vector;
		var l_posToTest 	: Vector;
		var l_worldOffset	: Vector;
		var l_groudLevel	: float;
		var l_ground 		: Vector;
		var l_npcRadius		: float;
		var l_landRadius	: float;
		var l_rotation		: EulerAngles;
		var l_temp1, l_temp2: Vector;
		var l_waterDepth	: float;
		var l_guardArea		: CAreaComponent;
		
		l_matrix 		= l_npc.GetLocalToWorld();
		l_worldOffset 	= VecTransform( l_matrix, localOffset);
		
		l_pos 			= l_npc.GetWorldPosition();
		l_posToTest 	= l_worldOffset;
		l_posToTest.Z	= l_pos.Z;		
		
		l_waterDepth = theGame.GetWorld().GetWaterDepth( l_posToTest );		
		if( l_waterDepth > 0.5f )
		{
			return false;
		}
		
		
		if ( !theGame.GetWorld().NavigationComputeZ( l_posToTest, l_posToTest.Z - maxDistanceFromGround, l_posToTest.Z, l_groudLevel ) )
		{
			return false;
		}
		
		l_ground 	= l_posToTest;
		l_ground.Z 	= l_groudLevel;
		
		if( landOnlyInGuardArea )
		{
			l_guardArea = l_npc.GetGuardArea();
			if( l_guardArea && !l_guardArea.TestPointOverlap( l_ground ) )
			{
				return false;
			}
		}
		
		l_npcRadius	 = l_npc.GetRadius();
		l_landRadius = l_npcRadius * 2.0f;
		
		
		l_rotation = l_npc.GetWorldRotation();
		
		
		if ( checkLineOfSight && theGame.GetWorld().SweepTest( l_pos , l_ground + Vector(0,0,1), l_landRadius, l_temp1, l_temp2, m_ObstaclesGroupNames ) )
		{
			l_npc.GetVisualDebug().AddText('landingAreaText', "Obstacle To landing", l_temp1, true, 14 );
			l_npc.GetVisualDebug().AddBox( 'landingArea', Vector( l_landRadius, l_landRadius, l_landRadius), l_temp1, l_rotation, true, Color(255,0,0), 10 );
			return false;
		}
		
		
		if( !theGame.GetWorld().NavigationCircleTest( l_ground, l_landRadius ) )
		{
			
			l_npc.GetVisualDebug().AddText('landingAreaText', "Cannot Land here", l_ground, true, 14 );
			l_npc.GetVisualDebug().AddBox( 'landingArea', Vector( l_landRadius, l_landRadius, 20), l_ground - Vector( l_landRadius * 0.5f, l_landRadius * 0.5f, 0 ) , l_rotation, true, Color(255,0,0), 10 );
			return false;
		}
		l_npc.GetVisualDebug().AddText('landingAreaText', "Landing Area", l_ground, true, 14 );
		l_npc.GetVisualDebug().AddBox( 'landingArea', Vector( l_landRadius, l_landRadius, 20), l_ground - Vector( l_landRadius * 0.5f, l_landRadius * 0.5f, 0 ) , l_rotation, true, Color(255,119,160), 10 );
		
		return true;
	}
	
}


class BTCondCanLandAtPositionDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondCanLandAtPosition';

	
	
	
	editable var localOffset 			: Vector;
	editable var checkLineOfSight		: bool;
	editable var maxDistanceFromGround	: CBehTreeValFloat;
	editable var landOnlyInGuardArea	: bool;
	
	default checkLineOfSight 		= true;
	default maxDistanceFromGround 	= 7;
	
	hint localOffset 				= "Offset from me (in local). x is right, y is forward, the z value is not taken into consideration";
	hint maxDistanceFromGround 		= "max distance between my current height and the ground height at the localOffset location to be able to land";
	
	
}
