/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CClimbProbe
{	
	
	private				var	valid					: bool;
	private				var	setupReady				: bool;
	private				var	exploratorPosition		: Vector;
	private				var	directionChecking		: Vector;
	private				var directionRequiresInput	: bool;
	
	
	
	private 			var	distForwardToCheck		: float;
	private				var distanceCheckType 		: EClimbDistanceType;
	private editable	var	distForwardToCheckClose	: float;				default	distForwardToCheckClose		= 0.25f;
	private editable	var	distForwardToCheckMedium: float;				default	distForwardToCheckMedium	= 0.5f;
	private editable	var	maxAttempts				: int;					default	maxAttempts					= 4;
	private editable	var	distForwardToCheckLong	: float;				default	distForwardToCheckLong		= 0.6f;
	private editable	var	characterRadius			: float;				default	characterRadius				= 0.4f;
	private				var	heightTotalMin			: float;
	private				var	heightTotalMax			: float;
	
	
	
	private editable	var	ceilingDoubleCheck		: bool;					default	ceilingDoubleCheck		= true;
	private editable	var	ceilingCheckingClose	: bool;
	private editable	var	ceilingBackOffsetClose	: float;				default	ceilingBackOffsetClose	= 0.2f;
	private editable	var	ceilingBackOffsetFar	: float;				default	ceilingBackOffsetFar	= 0.9f;
	private editable	var	ceilingHeightNeeded		: float;				default	ceilingHeightNeeded		= 1.8f;
	private editable	var	ceilingRadius			: float;				default	ceilingRadius			= 0.3f;
	private				var ceilingFound			: bool;
	private				var	ceilingPoint			: Vector;
	private				var	ceilingHeightFree		: float;
	private				var ceilingCheckFrom		: Vector;
	private				var ceilingCheckTo			: Vector;

	
	
	private editable	var	groundRadiusToCheck		: float;				default	groundRadiusToCheck		= 0.5f;
	private editable	var	groundNormalMinZ		: float;				default	groundNormalMinZ		= 0.4f;
	private				var groundFound				: bool;
	private				var groundEndPoint			: Vector;
	private				var groundEndNormal			: Vector;
	private				var heightTarget			: float;
	private				var heightAdded				: float;
	private				var groundCheckFrom			: Vector;
	private				var groundCheckTo			: Vector;
	
	
	
	private editable	var	groundRefineEnabled		: bool;					default	groundRefineEnabled		= true;
	private editable	var	groundRefineDistCheck	: float;				default	groundRefineDistCheck	= 0.2f;
	private editable	var	groundRefineHeightCheck	: float;				default	groundRefineHeightCheck	= 0.5f;
	private editable	var	groundRefineRadius		: float;				default	groundRefineRadius		= 0.2f;
	private 			var	groundRefined			: bool;
	
	
	private				var climbableFound			: bool;
	private				var climbableObjName		: string;
	private				var	climbableObjTagOnLayer	: bool;
	private				var	climbableObjForceAllow	: bool;
	private				var climbablePoint			: Vector;
	private editable	var	climbableRadius			: float;				default	climbableRadius			= 0.2f;
	private editable	var	climbableLockTag		: name;					default	climbableLockTag		= 'no_climb';
	private editable	var	climbableUnLockTag		: name;					default	climbableUnLockTag		= 'climb';
	
	
	
	private editable	var	holeForwardNeeded		: float;				default	holeForwardNeeded		= 0.2f;
	private				var	holeIsBlocked			: bool;
	private				var holeCollision			: Vector;
	private				var holeCheckFrom			: Vector;
	private				var holeCheckTo				: Vector;
	
	
	
	private editable	var	wallRadiusToCheck		: float;				default	wallRadiusToCheck		= 0.35f;
	private editable	var	wallNormalCheckBackExtra: float;				default	wallNormalCheckBackExtra= 0.360f;
	private editable	var	wallSideSeparation		: float;				default	wallSideSeparation		= 0.2f;
	private				var wallFound				: bool;
	private				var wallNormalOrigin		: Vector; 
	private				var wallNormalDirection		: Vector; 
	private				var wallCheckFromL			: Vector;
	private				var wallCheckToL			: Vector;
	private				var wallCheckFromR			: Vector;
	private				var wallCheckToR			: Vector;
	private				var wallCollL				: Vector;
	private				var wallCollR				: Vector;
	
	
	
	private editable	var	slopeAngleMax			: float;				default	slopeAngleMax			= 45.0f;
	private				var slopeNormalZMax			: float;
	private editable	var slopeForwardDistance	: float;				default	slopeForwardDistance	= 0.3f;
	private editable	var slopeLeftDistance		: float;				default	slopeLeftDistance		= 0.25f;
	
	
	
	private editable	var	horizHeightRdius		: float;				default	horizHeightRdius		= 0.1f;
	private editable	var	horizHeightSeparation	: float;				default	horizHeightSeparation	= 0.35f;
	private editable	var	horizHeightAngleMin		: float;				default	horizHeightAngleMin		= -60.0f;
	private editable	var	horizHeightAngleMax		: float;				default	horizHeightAngleMax		= 60.0f;
	
	private				var	horizFoundLeft			: bool;
	private				var	horizFoundRight			: bool;
	private				var horizHeightAngleCur		: float;
	private				var horizPointLeft			: Vector;
	private				var horizPointRight			: Vector;
	
	
	
	private				var	horizCorrectSideCoef	: float;				default	horizCorrectSideCoef	= 0.8f;
	
	
	
	private	editable	var	vertSlopeAngleOffset	: float;				default	vertSlopeAngleOffset	= 0.5f;
	private	editable	var	vertSlopeAngleMax		: float;				default	vertSlopeAngleMax		= 45.0f;
	private				var	vertSlopeAngleCur		: float;
	private				var	vertSlopeAngleFrom		: Vector;
	private				var	vertSlopeAngleTo		: Vector;
	private				var	vertSlopeAnglePoint		: Vector;
	
	private	editable	var	vertSlopeAngleLowOffset	: float;				default	vertSlopeAngleLowOffset	= 0.25f;
	private	editable	var	vertSlopeLowAngleMax	: float;				default	vertSlopeLowAngleMax	= 35.0f;
	private				var	vertSlopeLowAngleCur	: float;
	private				var	vertSlopeLowAngleFrom	: Vector;
	private				var	vertSlopeLowAngleTo		: Vector;
	private				var	vertSlopeLowAnglePoint	: Vector;
	
	
	
	private	editable	var	vertFreeHeightEnable	: bool;					default vertFreeHeightEnable	= false;
	private	editable	var	vertFreeHorOffset		: float;				default	vertFreeHorOffset		= 0.3f;
	private	editable	var	vertFreeHorMin			: float;				default	vertFreeHorMin			= 0.3f;
	private	editable	var	vertFreeHeightMin		: float;				default	vertFreeHeightMin		= 1.0f;
	private	editable	var	vertFreeHeightGrndMax	: float;				default	vertFreeHeightGrndMax	= 0.5f;
	private	editable	var	vertFreeHeightCur		: float;
	private				var	vertFreeFrom			: Vector;
	private				var	vertFreeTo				: Vector;
	private				var	vertFreeCollPoint		: Vector;
	
	
	
	private editable	var	vaultHeight				: float;				default	vaultHeight				= 0.5f;
	private editable	var	vaultHeightOffset		: float;				default	vaultHeightOffset		= 0.25f;
	private editable	var	vaultDistance			: float;				default	vaultDistance			= 0.55f;
	private editable	var	vaultRadius				: float;				default	vaultRadius				= 0.4f;
	private editable	var	heightOffsetToEndFall	: float;				default	heightOffsetToEndFall	= 0.2f;
	private editable	var	heighAbsToEndFall		: float;				default	heighAbsToEndFall		= 1.5f;
	
	private				var	vaultingFound			: EClimbRequirementVault;
	private				var	vaultCollision			: Vector;	
	private				var	vaultEndsFalling		: bool;
	private				var vaultCheckFrom			: Vector;
	private				var vaultCheckTo			: Vector;
	
	
	
	private				var	platformFound			: EClimbRequirementPlatform;
	private				var	platformFrom			: Vector;
	private				var	platformTo				: Vector;
	private				var	platformCollision		: Vector;
	private editable	var	platformHeightDown		: float;				default	platformHeightDown		= 0.75f;
	private editable	var	platformRadius			: float;				default	platformRadius			= 0.3f;
	private editable	var	platformDeep			: float;				default	platformDeep			= 0.5f;
	private 			var	platformMinToCheck		: float;
	
	
	
	private 			var collisionClimbableNames	: array<name>;
	private 			var collisionObstaclesNames	: array<name>;
	private 			var collisionForceAllowNames: array<name>;
	private 			var collisionLockNames		: array<name>;
	
	
	
	private				var	debugPrefix				: string;
	private				var	debugIsTop				: string;
	private				var	debugColorDiv			: int;
	private				var	debugLogFails			: bool;
	private				var	onlyDebugPoint			: Vector;
	private				var debugLastErrorMessage	: string;
	private				var	debugLastErrorPosition	: Vector;
	
	
	
	private				var	debugDrawGraphics		: bool;						default	debugDrawGraphics	= true;
	private				var	debugCeiling			: bool;						default	debugCeiling		= true;
	private				var	debugGround				: bool;						default	debugGround			= true;
	private				var	debugWall				: bool;						default	debugWall			= true;
	private				var	debugHole				: bool;						default	debugHole			= true;
	private				var	debugVault				: bool;						default	debugVault			= true;
	private				var	debugVertSlope			: bool;						default	debugVertSlope		= true;
	private				var	debugVertFree			: bool;						default	debugVertFree		= true;
	private				var	debugHorSlope			: bool;						default	debugHorSlope		= true;
	private				var	debugPlatform			: bool;						default	debugPlatform		= true;
	
	
	
	private				var	vectorUp				: Vector;
	private				var	vectorZero				: Vector;
	
	
	
	public function Initialize( heightMin : float, heightMax : float, platformHeihtMin : float, radius : float, colorDivide : int, isTop : bool )
	{
		
		debugColorDiv	= colorDivide;
		debugIsTop		= isTop;
		if( debugIsTop )
		{
			debugPrefix	= "Top";
		}
		else
		{
			debugPrefix	= "Bottom";
		}
		
		
		heightTotalMin	= heightMin;
		heightTotalMax	= heightMax;
		
		
		characterRadius	= radius;
		
		
		platformMinToCheck	= platformHeihtMin;
		
		
		collisionClimbableNames.PushBack( 'Terrain' );
		collisionClimbableNames.PushBack( 'Static' );
		collisionClimbableNames.PushBack( 'Destructible' );
		collisionClimbableNames.PushBack( 'Platforms' );
		collisionClimbableNames.PushBack( 'Fence' );
		collisionClimbableNames.PushBack( 'Boat' );
		collisionClimbableNames.PushBack( 'BoatDocking' );
		
		collisionObstaclesNames.PushBack( 'Terrain' );
		collisionObstaclesNames.PushBack( 'Static' );
		collisionObstaclesNames.PushBack( 'Platforms' );
		collisionObstaclesNames.PushBack( 'Fence' );
		collisionObstaclesNames.PushBack( 'Boat' );
		collisionObstaclesNames.PushBack( 'BoatDocking' );
		
		collisionObstaclesNames.PushBack( 'Foliage' );
		collisionObstaclesNames.PushBack( 'Dynamic' );
		collisionObstaclesNames.PushBack( 'Destructible' );
		collisionObstaclesNames.PushBack( 'RigidBody' );
		
		collisionForceAllowNames.PushBack( 'UnlockClimb' );
		collisionLockNames.PushBack( 'LockClimb' );
		
		
		slopeNormalZMax	= CosF( Deg2Rad( slopeAngleMax ) );
		
		
		vectorUp		= Vector( 0.0f,0.0f, 1.0f );
		vectorZero		= Vector( 0.0f,0.0f, 0.0f );
	}
	
	
	public function PreUpdate( position : Vector, direction : Vector, requireInputDir : bool, distanceType : EClimbDistanceType,  logFails : bool )
	{
		PrepareDebugPositions();
		
		debugLogFails			= logFails;
		exploratorPosition		= position;
		directionChecking		= direction;
		directionRequiresInput	= requireInputDir;
		distanceCheckType		= distanceType;
		
		if( distanceCheckType	== ECDT_Close )
		{
			distForwardToCheck	= distForwardToCheckClose;
		}
		else
		{
			distForwardToCheck	= distForwardToCheckMedium;
		}
		
		valid		= false;
		setupReady	= false;
	}
	
	
	public function ComputeStartup()
	{		
		var i			: int;
		
		
		ComputeCeiling();	
		
		valid		= ComputeCurCeilingStartup();
		
		
		if( distanceCheckType	== ECDT_Far )
		{
			i	= 0;
			while( !valid && i < maxAttempts )
			{
				exploratorPosition	+= directionChecking * distForwardToCheckLong;
				
				ComputeCeiling();	
				valid	= ComputeCurCeilingStartup();
				i		+= 1;
			}
		}
		
		setupReady	= valid;
	}
	
	
	public function ComputeStartupFromThisPoint( manualPoint : Vector )
	{
		ComputeFakeCeiling( manualPoint );
		
		valid		= ComputeCurCeilingStartup();
		setupReady	= valid;
	}
	
	
	private function ComputeCurCeilingStartup() : bool
	{
		if( !DoWeHaveAValidCeiling() )
		{
			return false;
		}
		
		
		ComputeGround();
		
		if( !DoWeHaveGroundStartUp() )
		
		{			
			return false;
		}
		
		return true;
	}
	
	
	public function ComputeClimbDetails() : bool
	{		
		if( !valid )
		{
			return false;
		}
		
		
		if( !DoWeHaveGround() )						
		{
			return false;
		}
		
		
		
		ComputeClimbableGroundPhysics();
		
		if( !DoWeHaveAClimbableGround() )
		{			
			return false;
		}
		
		
		if( !DoWeHaveSpaceBetweenGroundAndCeiling() )	
		{
			return false;
		}
		
		
		RecomputeDirectionWithGroundPoint();			
		
		
		
		ComputeNormalOfWallDetailed();				
		
		
		if( !DoWeHaveAWall() )						
		{
			return false;
		}
		
		
		RefineGroundBasedOnWall();					
		
		
		ComputeSpaceToEnter();						
		
		
		if( !DoWeHaveEnoughSpace() ) 				
		{
			return false;
		}
		
		
		ComputeVaultMode();							
		
		
		if( vaultingFound == ECRV_NoVault )
		{
			
			
			
			
			ComputeVerticalSlope();					
			if( !DoWeHaveProperVerticalSlope() )
			{
				return false;
			}
			
			
			if( platformFound == ECRV_NoPlatform )
			{
				ComputeVerticalLowSlope();
				if( !DoWeHaveProperVerticalSlopeLow() )
				{
					return false;
				}
			}
			
			
			if( vertFreeHeightEnable )
			{
				ComputeVerticalFreeDistanceInFront();	
				if( !DoWeHaveEnoughVerticalFreeDistance() )
				{
					return false;
				}
			}
		}
		
		
		ComputePlatformMode();
		
		
		
		ComputeHorizontalHeightDiff();				
		
		
		
		if( !DoWeHaveProperHorizontalDiff() )  		
		{
			return false;
		}
		
		
		ComputeClimbAproximation();
		
		return true;
	}
	
	
	public function IsSetupValid() : bool
	{
		return setupReady;
	}
	
	
	public function IsValid() : bool
	{
		return valid;
	}
	
	
	public function GetClimbData( out height : float, out vault : EClimbRequirementVault, out vaultFalls : bool, out platform : EClimbRequirementPlatform, out climbPoint : Vector, out wallNormal : Vector ) : bool
	{
		if( !valid )
		{
			return false;
		}
		
		height			= heightTarget;
		vault			= vaultingFound;
		vaultFalls		= vaultEndsFalling;
		platform		= platformFound;
		climbPoint		= wallNormalOrigin;
		climbPoint.Z	= groundEndPoint.Z;
		wallNormal		= wallNormalDirection;
		
		return true;
	}
	
	
	public function GetGroundPoint() : Vector
	{
		if( !setupReady ) 
		{
			return exploratorPosition;
		}
		
		return groundEndPoint;
	}
	
	
	
	private function ComputeCeiling()
	{
		var position	: Vector;
		var point		: Vector;
		var pointC		: Vector;
		var pointF		: Vector;
		var normal		: Vector;
		var heightFree	: float;
		
		
		
		position				= exploratorPosition - directionChecking * ceilingBackOffsetClose;
		ceilingCheckFrom		= position + vectorUp * ( heightTotalMin + ceilingHeightNeeded );
		ceilingCheckTo			= position + vectorUp * ( heightTotalMax + ceilingHeightNeeded );
		
		
		ceilingCheckingClose	= true;
		ceilingFound			= theGame.GetWorld().SweepTest( ceilingCheckFrom, ceilingCheckTo, ceilingRadius, pointC, normal, collisionObstaclesNames );
		point					= pointC;
		
		
		if( ceilingFound  && ceilingDoubleCheck )
		{
			position			= exploratorPosition - directionChecking * ceilingBackOffsetFar;
			ceilingCheckFrom	= position + vectorUp * ceilingHeightNeeded;
			ceilingCheckTo		= position + vectorUp * ( heightTotalMax + ceilingHeightNeeded );
			ceilingFound		= theGame.GetWorld().SweepTest( ceilingCheckFrom, ceilingCheckTo, ceilingRadius, pointF, normal, collisionObstaclesNames );
			
			
			if( pointF.Z > pointC.Z )
			{
				point					= pointF;
				ceilingCheckingClose	= false;
			}
		}
		
		if( !ceilingFound )
		{	
			heightFree	= heightTotalMax + ceilingHeightNeeded;
			SetCeilingData( ceilingCheckFrom, heightFree );
			
			return;
		}
		
		heightFree	= point.Z - position.Z;
		
		
		SetCeilingData( point, heightFree );
	}
	
	
	
	private function ComputeFakeCeiling( manualPoint : Vector )
	{
		var heightFree	: float;
		
		
		ceilingFound 	= true;
		heightFree		= manualPoint.Z - exploratorPosition.Z;
		
		
		SetCeilingData( manualPoint, heightFree);
	}
	
	
	private function SetCeilingData( point : Vector, heightFree : float )
	{
		ceilingPoint		= point;
		ceilingHeightFree	= heightFree;
	}
	
	
	
	private function ComputeGround()
	{
		var position	: Vector;
		var	point 		: Vector;
		var normal		: Vector;
		var	dot			: float;
		var rayOrig		: Vector;
		var rayEnd		: Vector;
		
		
		
		position			= exploratorPosition;
		groundCheckFrom		= position + directionChecking * distForwardToCheck;
		groundCheckTo		= groundCheckFrom + vectorUp * heightTotalMin;
		groundCheckFrom		= groundCheckFrom + vectorUp * ( ceilingHeightFree - ceilingHeightNeeded + groundRadiusToCheck );
		
		groundFound			= theGame.GetWorld().SweepTest( groundCheckFrom, groundCheckTo, groundRadiusToCheck, point, normal, collisionClimbableNames );
		
		
		if( groundFound && directionRequiresInput )
		{
			if( !IsGroundPointCloseToDirection( point ) )
			{
				groundFound	= false;
			}
		}
		
		
		if( groundFound )
		{		
			
			
			
			groundEndPoint	= point;
			groundEndNormal	= normal;
			heightTarget	= point.Z - position.Z;
		}
	}
	
	
	private function IsGroundPointCloseToDirection( point : Vector ) : bool
	{
		
		
		var dirFound	: Vector;
		
		dirFound		= point - exploratorPosition;
		dirFound.Z		= 0.0f;
		dirFound		= VecNormalize( dirFound );
		
		return VecDot( dirFound, directionChecking ) > 0.5f;
	}
	
	
	private function RecomputeDirectionWithGroundPoint()
	{
		directionChecking	= groundEndPoint - exploratorPosition;
		directionChecking.Z	= 0.0f;
		directionChecking	= VecNormalize( directionChecking );
	}
	
	
	
	private function ComputeClimbableGround()
	{
		var i				: int;
		var	totalEntities	: int;
		var entities		: array< CEntity >;
		var locked			: bool;
		
		
		climbableFound			= true;
		locked					= false;
		climbableObjForceAllow	= false;
		
		theGame.GetWorld().SphereOverlapTest( entities, groundEndPoint, climbableRadius, collisionClimbableNames );
		totalEntities	= entities.Size();
		for( i = 0; i < totalEntities; i+= 1 )
		{
			
			if( entities[i].HasTag( climbableUnLockTag )  )
			{
				climbableObjForceAllow	= true;
				climbableObjTagOnLayer	= false;
			}
			else if( entities[i].HasTagInLayer( climbableUnLockTag ) )
			{
				climbableObjForceAllow	= true;
				climbableObjTagOnLayer	= true;
			}
			if( climbableObjForceAllow )
			{
				climbableObjName		= entities[i].GetName();
				climbablePoint			= groundEndPoint;
				climbableFound			= true;
				
				
				return;
			}
			
			
			if( !locked )
			{
				if( entities[i].HasTag( climbableLockTag ) )
				{
					locked					= true;
					climbableObjTagOnLayer	= false;
				}
				else if( entities[i].HasTagInLayer( climbableLockTag ) )
				{
					locked					= true;
					climbableObjTagOnLayer	= true;
				}
				if( locked )
				{
					climbableObjName	= entities[i].GetName();
					climbablePoint		= groundEndPoint;
					climbableFound		= false;
				}
			}
		}
	}

	
	
	private function ComputeClimbableGroundPhysics()
	{
		var origin	: Vector;
		var end		: Vector;
		var point	: Vector;
		var normal	: Vector;
		
		
		origin			= groundEndPoint;
		origin.Z		+= 0.1f;
		end				= groundEndPoint;
		end.Z			-= 0.1f;
		climbablePoint	= groundEndPoint;
		
		
		
		if( theGame.GetWorld().SweepTest( origin, end, climbableRadius, point, normal, collisionForceAllowNames ) ) 
		{
			climbableFound			= true;
			climbableObjForceAllow	= true;
		}
		
		else if( theGame.GetWorld().SweepTest( origin, end, climbableRadius, point, normal, collisionLockNames ) ) 
		{
			climbableFound			= false;
			climbableObjForceAllow	= false;
		}
		
		else
		{
			climbableFound			= true;
			climbableObjForceAllow	= false;
		}
	}
	
	
	
	private function ComputeNormalOfWall()
	{
		var direction	: Vector;
		var position	: Vector;
		var normal		: Vector;
		var distBack	: float;
		
		
		
		if( ceilingCheckingClose )
		{
			distBack	= groundRadiusToCheck + ceilingBackOffsetClose;
		}
		else
		{
			distBack	= groundRadiusToCheck + ceilingBackOffsetFar;
		}
		distBack		+= wallNormalCheckBackExtra;
		
		
		
		
		position		= groundEndPoint;
		wallCheckFromL	= position - directionChecking * distBack;
		wallCheckToL	= position + directionChecking * ( distForwardToCheck + 2.0f * groundRadiusToCheck );
		
		wallFound		= theGame.GetWorld().SweepTest( wallCheckFromL, wallCheckToR, wallRadiusToCheck, wallCollL, normal, collisionClimbableNames );
		if( !wallFound )
		{			
			return;
		}
		
		
		wallNormalOrigin		= wallCollL;
		wallNormalDirection		= normal;
		wallNormalDirection.Z	= 0.0f;
		wallNormalDirection		= VecNormalize( wallNormalDirection );
	}
	
	
	
	private function ComputeNormalOfWallDetailed()
	{
		var direction	: Vector;
		var position	: Vector;
		var distBack	: float;
		var normalL		: Vector;
		var normalR		: Vector;
		var foundL		: bool;
		var foundR		: bool;
		
		
		
		if( ceilingCheckingClose )
		{
			distBack	= groundRadiusToCheck + ceilingBackOffsetClose;
		}
		else
		{
			distBack	= groundRadiusToCheck + ceilingBackOffsetFar;
		}		
		distBack		+= wallNormalCheckBackExtra;
		
		direction		= VecCross( directionChecking, vectorUp );
		
		
		position		= groundCheckFrom - direction * wallSideSeparation;
		position.Z		= groundEndPoint.Z - wallRadiusToCheck * 0.3f;
		wallCheckFromL	= position - directionChecking * distBack;
		wallCheckToL	= position + directionChecking * ( distForwardToCheck + groundRadiusToCheck );	
		foundL			= theGame.GetWorld().SweepTest( wallCheckFromL, wallCheckToL, wallRadiusToCheck, wallCollL, normalL, collisionClimbableNames );
		
		wallCheckFromR	= wallCheckFromL + direction * wallSideSeparation * 2.0f;
		wallCheckToR	= wallCheckToL	+ direction * wallSideSeparation * 2.0f;
		foundR			= theGame.GetWorld().SweepTest( wallCheckFromR, wallCheckToR, wallRadiusToCheck, wallCollR, normalR, collisionClimbableNames );
		
		wallFound		= true;
		if( !foundL && !foundR )
		{			
			wallFound	= false;
			
			return;
		}
		else if( foundL && foundR )
		{
			wallNormalOrigin		= ( wallCollL + wallCollR ) * 0.5f;
			wallNormalDirection		= VecCross( VecNormalize( wallCollR - wallCollL ), vectorUp );
		}
		else if( foundL )
		{
			wallNormalOrigin		= wallCollL;
			wallNormalDirection		= normalL;
		}
		else
		{
			wallNormalOrigin		= wallCollR;
			wallNormalDirection		= normalR;
		}
		
		
		wallNormalDirection.Z	= 0.0f;
		wallNormalDirection		= VecNormalize( wallNormalDirection );
	}
	
	
	
	private function RefineGroundBasedOnWall()
	{
		var refinedGround	: Vector;
		var	from 			: Vector;
		var to				: Vector;
		var normal			: Vector;
		var distance		: float;
		var wallNormalModif	: float;
		
		
		
		groundRefined	= false;
		
		
		if( !groundRefineEnabled )
		{
			return;
		}
		
		
		if( VecDot2D( wallNormalOrigin - groundEndPoint, directionChecking ) >= 0.0f )
		{
			return;
		}
		
		
		distance	= VecDistance2D( groundEndPoint, wallNormalOrigin );
		if( distance > groundRefineDistCheck )
		{
			
			from			= wallNormalOrigin;
			to				= from;
			from.Z			= groundEndPoint.Z + groundRefineHeightCheck;
			to.Z			= groundEndPoint.Z - groundRefineHeightCheck;
			groundRefined	= theGame.GetWorld().SweepTest( from, to, groundRefineRadius, refinedGround, normal, collisionClimbableNames );
			
			
			if( groundRefined )
			{
				
				if( VecDot2D( refinedGround - wallNormalOrigin, directionChecking ) > 0.0f )
				{
					groundEndPoint		= wallNormalOrigin;
					groundEndPoint.Z	= refinedGround.Z;
				} 
				
				else
				{
					groundEndPoint	= refinedGround;
				}
				
				
				
				
				
				
				heightTarget		= groundEndPoint.Z - exploratorPosition.Z;
			}
		}
	}
	
	
	
	private function ComputeSpaceToEnter()
	{
		var	point 		: Vector;
		var normal		: Vector;
		
		
		
		holeCheckFrom		= wallNormalOrigin;
		holeCheckFrom.Z		= groundEndPoint.Z + ceilingHeightNeeded * 0.5f;
		holeCheckTo			= holeCheckFrom - wallNormalDirection * ( holeForwardNeeded );
		holeCheckFrom		+= wallNormalDirection * characterRadius; 
		
		holeIsBlocked		= theGame.GetWorld().SweepTest( holeCheckFrom, holeCheckTo, characterRadius, point, normal, collisionObstaclesNames );
		if( holeIsBlocked )
		{
			holeCollision	= point;
		}
	}
	
	
	
	private function ComputeHorizontalHeightDiff()
	{
		var position	: Vector;
		var direction	: Vector;
		var from		: Vector;
		var to			: Vector;
		var normalL		: Vector;
		var normalR		: Vector;
		var slope		: Vector;
		var	angle		: float;
		var pointL		: Vector;
		var pointR		: Vector;
		
		
		
		position	= groundEndPoint + vectorUp;
		direction	= VecCross( wallNormalDirection, vectorUp );
		
		
		
		from			= position + direction * horizHeightSeparation;
		to				= from - vectorUp * 2.0f;
		horizFoundLeft	= theGame.GetWorld().SweepTest( from, to, horizHeightRdius, pointL, normalL, collisionClimbableNames );
		
		
		from			= position - direction * horizHeightSeparation;
		to				= from - vectorUp * 2.0f;
		horizFoundRight	= theGame.GetWorld().SweepTest( from, to, horizHeightRdius, pointR, normalR, collisionClimbableNames );
		
		
		if( !horizFoundLeft && !horizFoundRight )
		{
			horizHeightAngleCur	= 180.0f;
			
			return;
		}
		
		
		if( !horizFoundLeft )
		{
			slope			= VecCross( normalR, wallNormalDirection );
			horizPointRight	= pointR;
		}
		if( !horizFoundRight )
		{
			slope			= VecCross( normalL, wallNormalDirection );
			horizPointLeft	= pointL;
		}
		
		else
		{
			horizPointLeft	= pointL;
			horizPointRight	= pointR;
			
			
			slope			= VecNormalize( horizPointLeft - horizPointRight );
		}
		
		
		angle			= AngleNormalize180( VecGetAngleBetween ( slope, direction ) );
		if( slope.Z < 0.0f )
		{
			angle *= -1.0f;
		}
		horizHeightAngleCur	= angle;
	}
	
	
	private function ComputeClimbAproximation()
	{
		if( !horizFoundRight )
		{
			groundEndPoint	= groundEndPoint * ( 1.0f - horizCorrectSideCoef ) + horizPointLeft * horizCorrectSideCoef;
		}
		else if( !horizFoundLeft )
		{
			groundEndPoint	= groundEndPoint * ( 1.0f - horizCorrectSideCoef ) + horizPointRight * horizCorrectSideCoef;
		}
	}
	
	
	
	private function ComputeVaultMode()
	{
		var point		: Vector;
		var normal		: Vector;
		var direction	: Vector;
		var height		: float;
		var collided	: bool;
		
		
		
		vaultEndsFalling		= false;
		
		
		direction	= -wallNormalDirection;
		direction.Z	= 0.0f;
		direction	= VecNormalize( direction );
		point		= wallNormalOrigin;
		
		
		point.Z			= groundEndPoint.Z + vaultHeightOffset + vaultRadius;
		vaultCheckFrom	= point + direction * ( vaultDistance + vaultRadius );
		vaultCheckTo	= vaultCheckFrom - vectorUp * heightTotalMax;
		
		
		collided		= theGame.GetWorld().SweepTest( vaultCheckFrom, vaultCheckTo, vaultRadius, point, normal, collisionObstaclesNames );
		if( !collided )
		{
			vaultingFound	= ECRV_Vault;
		}
		else
		{
			vaultCollision	= point;
			height			= groundEndPoint.Z - vaultCollision.Z;
			if( height > vaultHeight )
			{
				vaultingFound	= ECRV_Vault;
				if( height >= heightTarget + heightOffsetToEndFall || height > heighAbsToEndFall )
				{
					vaultEndsFalling	= true;
				}
			}
			else
			{
				vaultingFound	= ECRV_NoVault;
			}
		}
	}
	
	
	private function ComputePlatformMode()
	{
		var position	: Vector;
		var normal		: Vector;
		
		
		
		if( heightTarget < platformMinToCheck )
		{
			platformFound	= ECRV_NoPlatform;
			
			return;
		}
		
		position		= wallNormalOrigin;
		position.Z		= groundEndPoint.Z - platformHeightDown - platformRadius;
		
		
		platformFrom	= position + wallNormalDirection * characterRadius;
		platformTo		= position - wallNormalDirection * platformDeep;
		
		if( theGame.GetWorld().SweepTest( platformFrom, platformTo, platformRadius, platformCollision, normal, collisionClimbableNames ) )
		{
			platformFound	= ECRV_NoPlatform;
		}
		else
		{
			platformFound	= ECRV_Platform;
		}
	}
	
	
	private function ComputeVerticalSlope()
	{
		var position	: Vector;
		var point		: Vector;
		var normal		: Vector;
		
		
		position	= wallNormalOrigin;
		position.Z	= groundEndPoint.Z ;
		
		
		vertSlopeAngleFrom	= holeCheckTo; 
		vertSlopeAngleTo	= position - vectorUp - vertSlopeAngleOffset * wallNormalDirection;
		if( !theGame.GetWorld().SweepTest( vertSlopeAngleFrom, vertSlopeAngleTo, horizHeightRdius, point, normal, collisionClimbableNames ) )
		{
			vertSlopeAngleCur	= -180.0f;
			vertSlopeAnglePoint	= vertSlopeAngleTo;
			
			return;
		}
		vertSlopeAnglePoint	= point;
		
		
		vertSlopeAngleCur	= GetVerticalAngle( point, groundEndPoint );
	}
	
	
	private function ComputeVerticalLowSlope()
	{
		var position		: Vector;
		var point			: Vector;
		var normal			: Vector;
		var heightToCheck	: float;
		
		
		heightToCheck			= MaxF( exploratorPosition.Z + horizHeightRdius * 1.1f, wallCheckFromL.Z - vertSlopeAngleLowOffset );
		
		vertSlopeLowAngleFrom	= ( wallCheckFromL + wallCheckFromR ) * 0.5f;
		vertSlopeLowAngleTo		= ( wallCheckToL + wallCheckToR ) * 0.5f;
		vertSlopeLowAngleFrom.Z	= heightToCheck;
		vertSlopeLowAngleTo.Z	= heightToCheck;
		
		if( !theGame.GetWorld().SweepTest( vertSlopeLowAngleFrom, vertSlopeLowAngleTo, horizHeightRdius, point, normal, collisionClimbableNames ) )
		{
			vertSlopeLowAngleCur	= -180.0f;
			vertSlopeLowAnglePoint	= vertSlopeLowAngleTo;
			
			return;
		}
		vertSlopeLowAnglePoint	= point;
		
		
		vertSlopeLowAngleCur	= AngleNormalize180( VecGetAngleBetween( wallNormalOrigin - point, vectorUp ) );
		if( VecDot( wallNormalOrigin - point, wallNormalDirection ) > 0.0f )
		{
			vertSlopeLowAngleCur	*= -1.0f;
		}
	}
	
	
	private function ComputeVerticalFreeDistanceInFront()
	{	
		var position		: Vector;
		var point			: Vector;
		var normal			: Vector;
		var slope			: Vector;
		var heightNeeded	: float;
		
		
		
		if( heightTarget <= vertFreeHeightGrndMax )
		{
			vertFreeHeightCur	= vertFreeHeightMin;
			
			return;
		}
		
		
		
		position	= wallNormalOrigin + ( vertFreeHorOffset + vertFreeHorMin * 2.0f ) * wallNormalDirection;
		position.Z	= groundEndPoint.Z ;
		
		heightNeeded	= MinF( heightTarget - vertFreeHeightGrndMax, vertFreeHeightMin );
		heightNeeded	= MaxF( 0.0f, heightNeeded );
		vertFreeFrom	= position + vectorUp;
		vertFreeTo		= position - vectorUp * heightNeeded;
		if( !theGame.GetWorld().SweepTest( vertFreeFrom, vertFreeTo, vertFreeHorMin, point, normal, collisionObstaclesNames ) )
		{
			vertFreeHeightCur	= vertFreeHeightMin;
			
			return;
		}
		else
		{
			vertFreeHeightCur	= position.Z - point.Z;
			vertFreeCollPoint	= point;
		}
	}
	
	
	private function DoWeHaveAValidCeiling() : bool
	{
		if( ceilingFound && ceilingHeightFree < ceilingHeightNeeded )
		{
			FailedClimbCheckBecause( "Real ceiling is too low: " );
			
			return false;
		}
		
		return true;
	}
	
	
	private function DoWeHaveHeightForBottomGround() : bool
	{
		var exploratorPosition : Vector;
		
		
		exploratorPosition	= exploratorPosition;
		if( groundEndPoint.Z < exploratorPosition.Z + heightTotalMin + ceilingHeightNeeded )
		{
			
			return false;
		}
		
		return true;
	}
	
	
	private function DoWeHaveGroundStartUp() : bool
	{
		if( !groundFound )
		{
			FailedClimbCheckBecause( "No ground found: " );
			
			return false;
		}
		else if( heightTarget < heightTotalMin )
		{
			FailedClimbCheckBecause( "Ground too low: " + heightTarget + " < heightTotalMin: " + heightTotalMin );
			
			return false;
		}
		else if( groundEndNormal.Z <= groundNormalMinZ )
		{
			FailedClimbCheckBecause( "Ground normal Z: " + groundEndNormal.Z  + " <= groundNormalMinZ: " + groundNormalMinZ );
			
			return false;
		}
		
		return true;
	}
	
	
	private function DoWeHaveGround() : bool
	{
		if( !groundFound )
		{
			FailedClimbCheckBecause( "No ground found: " );
			
			return false;
		}
		else if( heightTarget < heightTotalMin )
		{
			FailedClimbCheckBecause( "Ground too low: " + heightTarget + " < heightTotalMin: " + heightTotalMin );
			
			return false;
		}
		else if( heightTarget > heightTotalMax )
		{
			FailedClimbCheckBecause( "Ground too high: " + heightTarget  + " > heightTotalMax: " + heightTotalMax );
			
			return false;
		}
		else if( groundEndNormal.Z <= groundNormalMinZ )
		{
			FailedClimbCheckBecause( "Ground normal Z: " + groundEndNormal.Z  + " <= groundNormalMinZ: " + groundNormalMinZ );
			
			return false;
		}
		
		return true;
	}
	
	
	private function DoWeHaveAClimbableGround() : bool
	{
		if( !climbableFound )
		{
			if( climbableObjTagOnLayer )
			{
				FailedClimbCheckBecause( "Found an object on a non climbable layer in range: " + climbableObjName );
			}
			else
			{
				FailedClimbCheckBecause( "Found an object not climbableFound in range: " + climbableObjName );
			}
			return false;
		}
		
		return true;
	}
	
	
	private function DoWeHaveAWall() : bool
	{
		if( !wallFound )
		{
			FailedClimbCheckBecause( "No wall or edge found: " );
			
			return false;
		}
		
		return true;
	}
	
	
	private function DoWeHaveSpaceBetweenGroundAndCeiling() : bool
	{
		var freeSpace	: float;
		
		
		if( ceilingFound )
		{
			freeSpace	= ceilingPoint.Z - groundEndPoint.Z;
			if( freeSpace < ceilingHeightNeeded )
			{
				FailedClimbCheckBecause( "Space between ground and ceiling is too small: " + ceilingHeightFree );
				
				return false;
			}
		}
		
		return true;	
	}
	
	
	private function DoWeHaveEnoughSpace() : bool
	{
		if( holeIsBlocked )
		{
			FailedClimbCheckBecause( "The hole not existing or not being big enough" );
			
			return false;
		}
		
		return true;
	}
	
	
	private function DoWeHaveProperHorizontalDiff() : bool
	{		
		if( vaultingFound == ECRV_Vault )
		{
			if( horizHeightAngleCur < horizHeightAngleMin || horizHeightAngleCur > horizHeightAngleMax )
			{
				FailedClimbCheckBecause( "Horizontal height difference angle is too big : " + horizHeightAngleCur + ", " + horizHeightAngleMin + "' " + horizHeightAngleMax );	
				
				return false;
			}
		}
		else if( !horizFoundLeft && !horizFoundRight )
		{
			FailedClimbCheckBecause( "Horizontal space is not wide enough " );	
			
			return false;
		}
		return true;	
	}
	
	
	private function DoWeHaveProperSlope() : bool
	{
		var	dot	: float;
		
		dot	= VecDot( groundEndNormal, vectorUp );
		
		
		if(  dot < slopeNormalZMax )
		{		
			FailedClimbCheckBecause( "The slope Z found is too big for a climb: " + groundEndNormal.Z );	
			
			return false;
		}
		
		return true;	
	}
	
	
	private function DoWeHaveProperVerticalSlope() : bool
	{
		if( AbsF( vertSlopeAngleCur ) > vertSlopeAngleMax )
		{
			FailedClimbCheckBecause( "Vertical slope is too much: AbsF( " + vertSlopeAngleCur + " ) > " + vertSlopeAngleMax );
			
			return false;
		}
		
		return true;
	}
	
	
	private function DoWeHaveProperVerticalSlopeLow() : bool
	{
		if( vertSlopeLowAngleCur > vertSlopeLowAngleMax ) 
		{
			FailedClimbCheckBecause( "Vertical LOW slope is too much: " + vertSlopeLowAngleCur + " > " + vertSlopeLowAngleMax );
			
			return false;
		}
		
		return true;
	}
	
	
	private function DoWeHaveEnoughVerticalFreeDistance() : bool
	{
		if( vertFreeHeightCur < vertFreeHeightMin )
		{
			FailedClimbCheckBecause( "Not enough free vert space in front of the wall " + vertFreeHeightCur + " < " + vertFreeHeightMin );
			
			return false;
		}
		return true;
	}
	
	
	private function FailedClimbCheckBecause( failExplanation : string )
	{
		valid	= false;
		
		if( debugLogFails )
		{
			debugLastErrorMessage	= debugPrefix + " climb probe failed because " + failExplanation;
			if( debugIsTop )
			{
				debugLastErrorPosition	= thePlayer.GetWorldPosition() + vectorUp * 2.0f;
			}
			else
			{
				debugLastErrorPosition	= thePlayer.GetWorldPosition() + vectorUp * 1.0f;
			}
			LogExplorationClimb( debugLastErrorMessage );		 
		}
	}
	
	
	
	private function GetVerticalAngle( from, to : Vector) : float
	{
		var slopeFlat	: Vector;
		var slope		: Vector;
		var angle		: float;
		
		
		slope		= VecNormalize( from - to );
		slopeFlat	= slope;
		slopeFlat.Z	= 0.0f;
		slopeFlat	= VecNormalize( slopeFlat );
		angle		= AngleNormalize180( VecGetAngleBetween ( slope, slopeFlat ) );
		if( slope.Z < 0.0f )
		{
			angle *= -1.0f;
		}
		
		return angle;
	}
	
	
	public function GetDebugText() : string
	{
		var text	: string;
		
		text	= "";
		
		
		if( climbableObjForceAllow )
		{
			if( climbableObjTagOnLayer )
			{
				text	+= "Force unlocked by layer of object ";
			}
			else
			{
				text	+= "Force unlocked by object ";
			}
			text	+= climbableObjName + ", ";
		}
		
		
		text += "Height: " + heightTarget + ", Ceiling height free: " + ceilingHeightFree 
			+ ",  Horizontal diff: " + horizHeightAngleCur 
			+ " SlopeVertUp: " + vertSlopeAngleCur  + " SlopeVertDown: " + vertSlopeLowAngleCur
			;
		
		return text;
	}
	
	
	private function PrepareDebugPositions()
	{
		if( !debugDrawGraphics )
		{
			return;
		}
		
		climbablePoint 	= vectorZero;
		
		
		if( debugCeiling )
		{
			ceilingCheckFrom	= vectorZero;
			ceilingPoint		= vectorZero;
		}
		
		
		if( debugGround )
		{
			groundEndPoint		= vectorZero;
			groundCheckFrom		= vectorZero;
			groundCheckTo		= vectorZero;
		}
		
		
		if( debugWall )
		{
			wallNormalOrigin	= vectorZero;
			wallCheckFromL		= vectorZero;
			wallCheckToL		= vectorZero;
			wallCollL			= vectorZero;
			wallCollR			= vectorZero;
		}
		
		
		if( debugHole )
		{
			holeCollision		= vectorZero;
			holeCheckFrom		= vectorZero;
			holeCheckTo			= vectorZero;
		}
		
		
		if( debugVault )
		{
			vaultCheckFrom		= vectorZero;
			vaultCheckTo		= vectorZero;
			vaultCollision		= vectorZero;
		}
		
		
		if( debugHorSlope )
		{
			horizPointLeft		= vectorZero;
			horizPointRight		= vectorZero;
		}
		
		
		if( debugVertSlope )
		{
			vertSlopeAngleFrom	= vectorZero;
			vertSlopeAngleTo	= vectorZero;
			vertSlopeAnglePoint	= vectorZero;
		}
		
		
		if( debugVertFree )
		{
			vertFreeFrom		= vectorZero;
			vertFreeTo			= vectorZero;
			vertFreeCollPoint	= vectorZero;
		}
		
		
		if( debugPlatform )
		{
			platformCollision	= vectorZero;
			platformFrom		= vectorZero;
			platformTo			= vectorZero;
		}
	}
	
	
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags, active : bool )
	{
		var vecAux			: Vector;
		var colorAux		: Color;
		var textAux			: string;
		var smallRadius		: float	= 0.2f;
		var verySmallRadius	: float	= 0.05f;
		var heightText		: float	= 0.1f;
		
		
		if( !debugDrawGraphics )
		{
			return true;
		}
		
		
		if( debugCeiling )
		{
			colorAux	= Color( 255 / debugColorDiv, 0, 0 );
			vecAux		= ceilingCheckFrom;
			vecAux.Z	= ceilingPoint.Z;
			frame.DrawLine( ceilingCheckFrom, ceilingCheckTo, colorAux );		
			frame.DrawSphere( vecAux, ceilingRadius, colorAux );
			frame.DrawText( "C", ceilingPoint, colorAux );
			frame.DrawText( "" + ceilingHeightFree, ceilingPoint - vectorUp * heightText, colorAux );
		}
		
		
		if( debugGround )
		{
			colorAux	= Color( 0, 255 / debugColorDiv, 0 );
			frame.DrawLine( groundEndPoint, groundEndPoint + groundEndNormal, colorAux );
			frame.DrawLine( groundCheckFrom, groundCheckTo, colorAux );
			frame.DrawSphere( groundEndPoint, smallRadius, colorAux );
			if( groundRefined )
			{
				frame.DrawText( "G-R", groundEndPoint, colorAux );
			}
			else
			{
				frame.DrawText( "G", groundEndPoint, colorAux );
			}
			frame.DrawText( "" + heightTarget, groundEndPoint - vectorUp * heightText, colorAux );
		}
		
		
		if( debugWall )
		{
			colorAux	= Color( 0, 0, 255 / debugColorDiv );
			frame.DrawLine( wallNormalOrigin, wallNormalOrigin + wallNormalDirection, colorAux );
			frame.DrawLine( wallCheckFromL, wallCheckToL, colorAux );
			frame.DrawLine( wallCheckFromR, wallCheckToR, colorAux );
			frame.DrawSphere( wallCollL, wallRadiusToCheck, colorAux );
			frame.DrawSphere( wallCollR, wallRadiusToCheck, colorAux );
			frame.DrawSphere( wallNormalOrigin, verySmallRadius, colorAux );
			frame.DrawText( "W", wallNormalOrigin, colorAux );
			frame.DrawText( "WL", wallCollL, colorAux );
			frame.DrawText( "WR", wallCollR, colorAux );
		}
		
		
		if( debugHole )
		{
			colorAux	= Color( 255 / debugColorDiv, 0, 255 / debugColorDiv );
			vecAux		= holeCollision;
			vecAux.Z	= holeCheckFrom.Z;		
			frame.DrawLine( holeCheckFrom, holeCheckTo, colorAux );
			frame.DrawSphere( vecAux, characterRadius, colorAux );
			frame.DrawText( "HF", holeCheckFrom, colorAux );
			frame.DrawText( "HT", holeCheckTo, colorAux );
			frame.DrawText( "H", holeCollision, colorAux );
		}
		
		
		if( debugVault )
		{
			colorAux	= Color( 0, 255 / debugColorDiv, 255 / debugColorDiv );
			frame.DrawLine( vaultCheckFrom, vaultCheckTo, colorAux );
			vecAux		= vaultCheckFrom;
			vecAux.Z	= vaultCollision.Z;
			frame.DrawSphere( vaultCheckFrom - vectorUp * vaultHeightOffset, vaultRadius, colorAux );
			frame.DrawText( "V", vaultCollision, colorAux );
			frame.DrawText( "" + vaultHeight, vaultCollision - vectorUp *heightText, colorAux );
		}
		
		
		if( debugHorSlope )
		{
			colorAux	= Color( 255 / debugColorDiv, 0, 255 / debugColorDiv );
			frame.DrawSphere( horizPointLeft, horizHeightRdius, colorAux );
			frame.DrawSphere( horizPointRight, horizHeightRdius, colorAux );
			frame.DrawText( "l", horizPointLeft, colorAux );
			frame.DrawText( "r", horizPointRight, colorAux );
			frame.DrawText( "" + horizHeightAngleCur, horizPointLeft - vectorUp * heightText, colorAux );
		}
		
		
		if( debugVertSlope )
		{
			colorAux	= Color( 255 / debugColorDiv, 0, 0 );		
			frame.DrawLine( vertSlopeAngleFrom, vertSlopeAngleTo, colorAux );
			frame.DrawSphere( vertSlopeAnglePoint, horizHeightRdius, colorAux );
			frame.DrawText( "A", vertSlopeAnglePoint, colorAux );
			frame.DrawText( "" + vertSlopeAngleCur, vertSlopeAnglePoint - vectorUp * heightText, colorAux );
			
			frame.DrawLine( vertSlopeLowAngleFrom, vertSlopeLowAngleTo, colorAux );
			frame.DrawSphere( vertSlopeLowAnglePoint, horizHeightRdius, colorAux );
			frame.DrawText( "AL", vertSlopeLowAnglePoint, colorAux );
			frame.DrawText( "" + vertSlopeLowAngleCur, vertSlopeLowAnglePoint - vectorUp * heightText, colorAux );
		}
		
		
		if( debugVertFree )
		{
			colorAux	= Color( 255 / debugColorDiv, 0, 0 );		
			frame.DrawLine( vertFreeFrom, vertFreeTo, colorAux );
			frame.DrawSphere( vertFreeCollPoint, vertFreeHorMin, colorAux );
			frame.DrawText( "Ff", vertFreeFrom, colorAux );
			frame.DrawText( "Ft", vertFreeTo, colorAux );
			frame.DrawText( "F", vertFreeCollPoint, colorAux );
		}
		
		
		if( debugPlatform )
		{
			colorAux	= Color( 255 / debugColorDiv, 255 / debugColorDiv, 0 );	
			frame.DrawSphere( platformCollision, platformRadius, colorAux );
			frame.DrawLine( platformFrom, platformTo, colorAux );
			frame.DrawText( "" + platformFound, platformFrom, colorAux );
			frame.DrawText( "P", platformTo, colorAux );
		}
		
		
		if( !climbableFound )
		{
			colorAux	= Color( 255 / debugColorDiv, 0, 0 );
			
			textAux		= "Lock Climb: " + climbableObjName;
			if( climbableObjTagOnLayer )
			{
				textAux	+= " Locked by layer";
			}
			frame.DrawText( textAux, climbablePoint + vectorUp * 0.5f, colorAux );
		}
		
		
		colorAux	= Color( 255 / debugColorDiv, 0, 0 );
		frame.DrawText( debugLastErrorMessage, debugLastErrorPosition, colorAux );
		
		return true;
	}
}
