/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum ECollisionTrajecoryStatus
{
	CTS_AllClear		= 0 ,
	CTS_LandLow			= 1 ,
	CTS_LandOK			= 2 ,
	CTS_LandHigh		= 3 ,
	CTS_LandBlocked		= 4 ,
}


enum ECollisionTrajecoryExplorationStatus
{
	CTES_None			,
	CTES_Jump			,
	CTES_Explore		,
}



enum ECollisionTrajectoryPart
{
	ECTP_Start			, 
	ECTP_Up				,
	ECTP_Peak			,
	ECTP_Down			,
	ECTP_Fall			,
	ECTP_FallLow		,
	ECTP_GroundClose	,
	ECTP_GroundFar		,
	ECTP_GroundFarAfter	,
	ECTP_None			,
}



enum ECollisionTrajectoryToWaterState
{
	ECTTWS_NoWater		,
	ECTTWS_ToWaterClose	,
	ECTTWS_ToWaterFar	,
}




class CollisionTrajectory extends CGameplayEntity
{
	public	var stateManager					: CExplorationStateManager;
	private var collisionSegmentsArr			: array<CollisionTrajectoryPart>;
	
	private	var	firstSegmentCollision			: ECollisionTrajectoryPart;
	private var trajectoryStatusLastChecked		: ECollisionTrajecoryStatus;
	private var trajecoryExpStatusLastChecked 	: ECollisionTrajecoryExplorationStatus;
	private var goingToWaterLastState			: ECollisionTrajectoryToWaterState;
	private var	computedCollisionState			: bool;
	private var	computedGoingToWater			: bool;
	
	
	
	public function Initialize( exploration : CExplorationStateManager )
	{
		var	components	: array<CComponent>;
		var part		: CollisionTrajectoryPart;
		var i			: int;
		
		
		
		this.CreateAttachment( exploration.GetEntity(), 'None' );
		stateManager	= exploration;
		
		
		components	= GetComponentsByClassName('CollisionTrajectoryPart');	
		
		
		for( i = 0; i < components.Size(); i += 1 )
		{
			part	= ( CollisionTrajectoryPart ) components[i];
			if( part )
			{
				part.Initialize( this );
				collisionSegmentsArr.PushBack( part );
			}
			else
			{
				LogCollisionTrajectory( "Wrong CollisionTrajectoryPart: " + components[i].GetName() );
			}
		}
		
		
		SortParts();
	}
	
	
	private function SortParts()
	{	
		SortPart( ECTP_Start );
		SortPart( ECTP_Up );
		SortPart( ECTP_Peak );
		SortPart( ECTP_Down );
		SortPart( ECTP_Fall );
		SortPart( ECTP_FallLow );
		SortPart( ECTP_GroundClose );
		SortPart( ECTP_GroundFar );
		SortPart( ECTP_GroundFarAfter );
	}
	
	
	private function SortPart( part : ECollisionTrajectoryPart )
	{
		var i				: int;
		var partChecking	: int;
		var partFound		: int;
		
		
		partChecking	= ( int ) part;		
		partFound		= FindPart( part );
		
		
		if( partFound != partChecking )
		{
			SwapParts( partFound, partChecking );
		}
	}
	
	
	private function FindPart( part : ECollisionTrajectoryPart ) :int
	{
		var i	: int;		
		
		
		for( i = 0; i < collisionSegmentsArr.Size(); i += 1 )
		{
			if( collisionSegmentsArr[i].part == part )
			{
				return i;
			}
		}
		
		LogCollisionTrajectory( "Missing CollisionTrajectoryPart: " + part );
		
		return 0;
	}
	
	
	private function SwapParts( i, j : int )
	{
		var partAux		: CollisionTrajectoryPart;
		
		partAux	= collisionSegmentsArr[i];
		
		collisionSegmentsArr[i] = collisionSegmentsArr[j];
		collisionSegmentsArr[j] = partAux;
	}
	
	
	public function PreUpdate()
	{
		computedCollisionState	= false;
		computedGoingToWater	= false;
	}
	
	
	private function ComputeCollisionStateIfNeeded()
	{
		if( computedCollisionState )
		{
			return;
		}
		
		if( collisionSegmentsArr[ ECTP_Start ].HasCollisions() )
		{
			trajectoryStatusLastChecked	= CTS_LandBlocked;
			firstSegmentCollision		= ECTP_Start;
		}
		else if( collisionSegmentsArr[ ECTP_Up ].HasCollisions() ) 
		{
			trajectoryStatusLastChecked	= CTS_LandBlocked;
			firstSegmentCollision		= ECTP_Up;
		}
		else if( collisionSegmentsArr[ ECTP_Peak ].HasCollisions() ) 
		{
			trajectoryStatusLastChecked	= CTS_LandBlocked;
			firstSegmentCollision		= ECTP_Peak;
		}
		else if( collisionSegmentsArr[ ECTP_Down ].HasCollisions() ) 
		{
			trajectoryStatusLastChecked	= CTS_LandHigh;
			firstSegmentCollision		= ECTP_Down;
		}
		else if( collisionSegmentsArr[ ECTP_Fall ].HasCollisions() ) 
		{
			trajectoryStatusLastChecked	= CTS_LandOK;
			firstSegmentCollision		= ECTP_Fall;
		}
		else if( collisionSegmentsArr[ ECTP_FallLow ].HasCollisions() )
		{
			trajectoryStatusLastChecked	= CTS_LandLow;
			firstSegmentCollision		= ECTP_FallLow;
		}
		else
		{
			trajectoryStatusLastChecked	= CTS_AllClear;
			firstSegmentCollision		= ECTP_None;
		}
		
		computedCollisionState	= true;
	}
	
	
	public function GetCollisionState() : ECollisionTrajecoryStatus
	{
		ComputeCollisionStateIfNeeded();
		
		return trajectoryStatusLastChecked;
	}
	
	
	public function IsPotentialObstacleToUseExploration() : bool
	{
		ComputeCollisionStateIfNeeded();
		
		if( trajectoryStatusLastChecked >= CTS_LandBlocked )
		{
			return false;
		}
		
		if( collisionSegmentsArr[ ECTP_GroundClose ].HasCollisions() )
		{
			return false;
		}
		
		if( !collisionSegmentsArr[ ECTP_GroundFar ].HasCollisions() )
		{
			return false;
		}
		
		return true;
	}
	
	
	public function IsPotentialObstacleToJump() : bool
	{	
		ComputeCollisionStateIfNeeded();
		
		if( trajectoryStatusLastChecked >= CTS_LandHigh )
		{
			return false;
		}
		
		
		
		
		
		
		
		if( collisionSegmentsArr[ ECTP_GroundFar ].HasCollisions() )
		{
			return true;
		}
		
		if( collisionSegmentsArr[ ECTP_GroundFarAfter ].HasCollisions() && trajectoryStatusLastChecked >= CTS_LandLow )
		{
			return true;
		}
		
		return false;
	}
	
	
	public function GetRefinedObstacleToJumpPosition( out position : Vector ) : bool
	{		
		var world 			: CWorld;
		var normalCollided	: Vector;
		var posEnd 			: Vector;
		var resultPosition	: Vector;
		var radius 			: float;
		radius = 0.4f;
		
		
		world		= theGame.GetWorld();
		if( !world )
		{
			return false;
		}
		
		
		position	= collisionSegmentsArr[ ECTP_GroundFar ].GetWorldPosition() + Vector( 0, 0, 1.0f );
		posEnd		= position + Vector( 0, 0, -2.0f );
		
		
		if( !world.SweepTest( position, posEnd, radius, resultPosition, normalCollided ) )
		{
			return false;
		}
		
		position	= resultPosition;
		
		
		
		
		return true;
		
	}
	
	
	private function ComputeGoingToWaterIfNeeded()
	{	
		if( computedGoingToWater )
		{
			return;
		}
		
		ComputeCollisionStateIfNeeded();		
		
		
		
		if( trajectoryStatusLastChecked != CTS_AllClear && trajectoryStatusLastChecked != CTS_LandLow && trajectoryStatusLastChecked != CTS_LandOK )
		{
			goingToWaterLastState	= ECTTWS_NoWater;
		}
		
		
		else if( collisionSegmentsArr[ ECTP_Fall ].IsGoingToWater() ) 
		{
			goingToWaterLastState	= ECTTWS_ToWaterClose;
		}
		else if( collisionSegmentsArr[ ECTP_FallLow ].IsGoingToWater() )
		{
			goingToWaterLastState	= ECTTWS_ToWaterFar;
		}
		else
		{
			goingToWaterLastState	= ECTTWS_NoWater;
		}
		
		computedGoingToWater		= true;
	}
	
	
	public function IsGoingToWater() : ECollisionTrajectoryToWaterState
	{
		ComputeGoingToWaterIfNeeded();
		
		return goingToWaterLastState;
	}
	
	
	public function DrawDebugText( horizontalPos, verticalPos, heightStep, width, height : int, textColor : Color ) : int
	{
		var text	: string;
		var i		: int;
		
		
		
		ComputeGoingToWaterIfNeeded();
		
		
		
		text	= " Prediction state: ";
		if( IsPotentialObstacleToJump() )
		{
			text	+= "ObstacleToJump.";
		}
		else if( IsPotentialObstacleToUseExploration() )
		{
			text	+= "ObstacleToExplore.";
		}
		else
		{
			text	+= "No prediction.";
		}
		text	+= "   Trajectory obstruction: " + trajectoryStatusLastChecked;
		
		text += " Going to water: " + IsGoingToWater();
		
		thePlayer.GetVisualDebug().AddBar( 'JumpTrajectory', horizontalPos, verticalPos, width, height, 0.0f, textColor, text, 0.0f );
		verticalPos	+= heightStep;
		
		
		text	= " Parts: ";
		for( i = 0; i < collisionSegmentsArr.Size(); i += 1 )
		{
			text += collisionSegmentsArr[i].GetDebugText();
		}
		thePlayer.GetVisualDebug().AddBar( 'JumpTrajectoryPart', horizontalPos, verticalPos, width, height, 0.0f, textColor, text, 0.0f );
		verticalPos	+= heightStep;
		
		return verticalPos;
	}
}



function LogCollisionTrajectory( text : string )
{
	LogChannel( 'CollisionTrajectory', text );
}
