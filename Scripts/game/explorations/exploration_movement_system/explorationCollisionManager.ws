/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum ESideSelected
{
	SS_SelectedNone		,
	SS_SelectedLeft		,
	SS_SelectedRight	,
	SS_SelectedCenter	,
};

enum EPlayerCollisionStance
{
	GCS_Idle	,
	GCS_Walk	,
	GCS_Run		,
	GCS_Sprint	,
	GCS_Combat	,
};

	

class CExplorationCollisionManager
{
	
	private 			var m_ExplorationO						: CExplorationStateManager;
	
	
	
	private	editable	var	m_CollideWithNPCEventCenter			: name;		default	m_CollideWithNPCEventCenter			= 'CollideCenter';
	private	editable	var	m_CollideWithNPCEventLeft			: name;		default	m_CollideWithNPCEventLeft			= 'CollideLeft';
	private	editable	var	m_CollideWithNPCEventRight			: name;		default	m_CollideWithNPCEventRight			= 'CollideRight';
	private editable	var m_CollideNameS						: name;		default	m_CollideNameS						= 'Colliding';
	private editable	var m_CollideBehGraphSideNameS			: name;		default	m_CollideBehGraphSideNameS			= 'CollidingSide';
	private editable	var m_CollideBehGraphStanceNameS		: name;		default	m_CollideBehGraphStanceNameS		= 'CollisionStance';
	private editable	var m_CollideAngleNameS					: name;		default	m_CollideAngleNameS					= 'PlayerCollisionAngle';
	private editable	var m_CollideBehGraphStrengthRelNameS	: name;		default	m_CollideBehGraphStrengthRelNameS	= 'PlayerCollisionRelStrength';
	private editable	var m_CollideBehGraphHeightN			: name;		default	m_CollideBehGraphHeightN			= 'PlayerCollisionHeight';
	
	
	private	editable	var	m_CanCollideWithStaticaB			: bool;		default	m_CanCollideWithStaticaB		= false;
	private	editable	var	m_VisualReactionToPushB				: bool;		default	m_VisualReactionToPushB			= false;
	private	editable	var	m_SpeedToCollideWihNPCsF			: float;	default	m_SpeedToCollideWihNPCsF		= 0.1f;
	private editable	var m_TimeCollidingToStopF				: float;	default	m_TimeCollidingToStopF			= 0.2f;
	private				var m_TimeCollidingCurF					: float;
	private editable	var m_AcceptableZToBumpF				: float;	default	m_AcceptableZToBumpF			= 0.4f;
	private editable	var playerHandHeightRange				: float;	default	playerHandHeightRange			= 0.5f;
	
	
	private				var	m_LandWaterMinDepthF				: float;	default	m_LandWaterMinDepthF			= 1.9f;
	private 			var m_CollisionGroupsNamesNArr			: array<name>;
	private 			var m_CollisionSightNArr				: array<name>;
	public	 			var m_CollisionObstaclesNArr			: array<name>;
	
	
	private				var m_CollidingB						: bool;
	private				var	m_IsThereAnyCollisionB				: bool;
	private				var m_CollidingWithNpcB					: bool;
	private				var m_CollidingWithStaticsB				: bool;
	private editable 	var m_AngleToSideF						: float;	default	m_AngleToSideF					= 22.0f;
	private				var m_CollidingAngleF					: float;
	private editable	var m_CollideCenterIfBothSidesB			: bool;		default	m_CollideCenterIfBothSidesB		= true;
	private				var	m_CollidingSideE					: ESideSelected;
	private				var	m_CollidingSideLastE				: ESideSelected;
	private				var	m_CollidingSideCooldownF			: float;
	public				var	forceFallEnabled					: bool;		default	forceFallEnabled				= false;
	public				var	forceFallRequireCenter				: bool;		default	forceFallRequireCenter			= false;
	public				var	forceFallRunning					: bool;		default	forceFallRunning				= false;
	
	public				var	m_CollidingStrengthOtherF			: float;
	public				var	m_CollidingStrengthRelativeF		: float;
	public				var	m_CollidingDirOtherV				: Vector;
	public				var	m_CollidingSpeedOtherV				: Vector;
	private editable	var m_CollidingStrengthFadeSpeedF		: float;	default	m_CollidingStrengthFadeSpeedF	= 20.0f;
	
	public				var	m_CollidingIsLowB					: bool;
	public editable		var	m_CollidingLowMinHeightF			: float;	default	m_CollidingLowMinHeightF		= 1.7f;
	
	
	public	editable	var	debugEnabled						: bool;		default	debugEnabled					= true;
	
	
	private 			var m_UpV								: Vector;
	private 			var m_ZeroV								: Vector;
	public 				var lastWaterCheckPoint					: Vector;
	
	
	
	public function Initialize( explorationManager : CExplorationStateManager )
	{
		m_ExplorationO					= explorationManager;
		m_TimeCollidingCurF				= 0.0f;
		
		m_UpV							= Vector( 0.0f, 0.0f, 1.0f );
		m_ZeroV							= Vector( 0.0f, 0.0f, 0.0f );
		
		m_CollidingStrengthOtherF		= -1.0f;
		m_CollidingStrengthRelativeF	= -1.0f;
		
		m_CollidingDirOtherV			= m_ZeroV;
		m_CollidingSideLastE			= SS_SelectedNone;
		m_CollidingSideCooldownF		= 0.0f;
		
		m_CollidingB				= false;
		m_CollidingWithStaticsB		= false;
		m_CollidingWithNpcB			= false;
		m_CollidingAngleF			= 0.0f;
		m_CollidingSideE			= SS_SelectedNone;
		
		
		
		m_CollisionSightNArr.PushBack( 'Terrain' );
		m_CollisionSightNArr.PushBack( 'Static' );
		m_CollisionSightNArr.PushBack( 'Destructible' );
		
		m_CollisionObstaclesNArr.PushBack( 'Terrain' );
		m_CollisionObstaclesNArr.PushBack( 'Static' );
		m_CollisionObstaclesNArr.PushBack( 'Foliage' );
		m_CollisionObstaclesNArr.PushBack( 'Dynamic' );
		m_CollisionObstaclesNArr.PushBack( 'Destructible' );
		m_CollisionObstaclesNArr.PushBack( 'RigidBody' );
		m_CollisionObstaclesNArr.PushBack( 'Platforms' );
		m_CollisionObstaclesNArr.PushBack( 'Boat' );
		m_CollisionObstaclesNArr.PushBack( 'BoatDocking' );
	}
	
	
	public function Update( _Dt : float )
	{
		var isThereAnyCollision			: bool;
		var canPlayerReactToCollisions	: bool;
		var canPlayerReactToPushes		: bool;
		var canNpcsReactToCollisions	: bool;
		
		
		if( m_CollidingStrengthFadeSpeedF <= 0.0f )
		{
			m_CollidingStrengthRelativeF	= -1.0f;
		}
		else
		{
			m_CollidingStrengthRelativeF	= MaxF( -1.0f, m_CollidingStrengthRelativeF - _Dt * m_CollidingStrengthFadeSpeedF );
		}
		
		isThereAnyCollision			= m_ExplorationO.m_OwnerMAC.GetCollisionCharacterDataCount() > 0;
		if( m_CanCollideWithStaticaB && !isThereAnyCollision )
		{
			isThereAnyCollision		= m_ExplorationO.m_OwnerMAC.GetCollisionDataCount() > 0;
		}
		
		if( isThereAnyCollision || isThereAnyCollision != m_IsThereAnyCollisionB )
		{			
			
			m_CollidingB				= false;
			m_CollidingWithStaticsB		= false;
			m_CollidingWithNpcB			= false;
			m_CollidingAngleF			= 0.0f;
			m_CollidingSideE			= SS_SelectedNone;
			m_CollidingStrengthOtherF	= -1.0f;
		}
		m_IsThereAnyCollisionB	= isThereAnyCollision;
		
		if( m_IsThereAnyCollisionB )
		{		
			canPlayerReactToCollisions	= CanPlayerCollide();
			
			
			if( m_CanCollideWithStaticaB && canPlayerReactToCollisions )
			{
				UpdateCollisionsWithStatics();
			}
			
			
			if( !m_CollidingWithStaticsB && m_ExplorationO.m_OwnerMAC.GetCollisionCharacterDataCount() > 0 )
			{
				
				canPlayerReactToPushes		= CanPlayerBePushed();
				canNpcsReactToCollisions	= CanNPCsCollide();
				
				if( canPlayerReactToCollisions || canPlayerReactToPushes || canNpcsReactToCollisions )
				{
					UpdateCollisionWithNPCs( canPlayerReactToCollisions, canPlayerReactToPushes, canNpcsReactToCollisions );
				}
			}
		}
		
		
		SetPlayerCollisionBehaviorData();
		
		
		UpdateCollidingSideEvent( _Dt );		
	}
	
	
	private function UpdateCollisionWithNPCs( canPlayerReactToCollisions, canPlayerReactToPushes : bool, canNpcsReactToCollisions : bool )
	{
		var collisionData	: SCollisionData;
		var npc				: CNewNPC;
		var collisionNum	: int;
		var i				: int;
		var playerPos		: Vector;
		var playerHandHeight: float;
		
		
		playerPos			= m_ExplorationO.m_OwnerE.GetWorldPosition();
		playerHandHeight	= playerPos.Z + 1.2f;
		
		collisionNum		= m_ExplorationO.m_OwnerMAC.GetCollisionCharacterDataCount();			
		for( i = 0; i < collisionNum; i += 1 )
		{
			collisionData	= m_ExplorationO.m_OwnerMAC.GetCollisionCharacterData( i );
			
			npc	= ( CNewNPC ) collisionData.entity;
			if( !npc )
			{
				continue; 
			}
			
			
			
			
			
			
			if( !CanThisNpcCollide( npc ) )
			{
				continue;
			}
			
			
			if( canNpcsReactToCollisions )
			{
				m_CollidingB		= true;
				m_CollidingWithNpcB	= true;
				
				
				MakeNPCCollide( npc );
			}
			
			
			if( canPlayerReactToCollisions )
			{
				if( CanPlayerReactToThisNPC( npc ) )
				{
					UpdatePlayerCollidingSide( npc.GetWorldPosition(), 0.0f );
					UpdatePlayerCollidingHeight( npc );
				}
			}
			
			
			if( canPlayerReactToPushes )
			{
				UpdatePlayerCollidingStrength( npc.GetWorldPosition(), npc.GetMovingAgentComponent().GetVelocityBasedOnRequestedMovement() );
			}
		}
	}
	
	
	
	private function UpdateCollisionsWithStatics()
	{
		if( m_ExplorationO.m_MovementCorrectorO.GetIsCollisionCorrected() )
		{
			m_CollidingWithStaticsB	= true;
			m_CollidingB			= true;
			m_CollidingSideE 		= SS_SelectedCenter;
		}
		
		
		
		
		
	}
	
	
	public function IsCollidingWithStatics() : bool
	{
		return m_ExplorationO.m_OwnerMAC.GetCollisionDataCount() > 0; 
	}
	
	
	public function GetAngleBlockedByStatics( out min : float, out max : float, angleBlocked : float ) : bool
	{
		var collisionData	: SCollisionData;
		var collisionNum	: int;
		var i				: int;
		var collisionAngle	: float;
		var collided		: bool;
		
		
		
		min					= 360.0f;
		max					= -360.0f;
		collided			= false;
		
		collisionNum		= m_ExplorationO.m_OwnerMAC.GetCollisionDataCount();			
		for( i = 0; i < collisionNum; i += 1 )
		{
			collisionData	= m_ExplorationO.m_OwnerMAC.GetCollisionData( i );
			
			if( AbsF( collisionData.normal.Z ) > 0.45f )
			{
				continue;
			}
			
			collisionAngle	= VecHeading( -collisionData.normal );
			min				= MinF( min, collisionAngle - angleBlocked );
			max				= MaxF( max, collisionAngle + angleBlocked );
			collided		= true;
		}
		
		min	= AngleNormalize180( min );
		max	= AngleNormalize180( max );
		
		return collided;
	}
	
	
	public function IsAngleBlockedByStatics( angle : float, angleNeeded : float ) : bool
	{
		var collisionData	: SCollisionData;
		var collisionNum	: int;
		var i				: int;
		var playerPos		: Vector;
		var	collisionAngle	: float;
		
		
		playerPos		= m_ExplorationO.m_OwnerE.GetWorldPosition();
		
		collisionNum	= m_ExplorationO.m_OwnerMAC.GetCollisionDataCount();			
		for( i = 0; i < collisionNum; i += 1 )
		{
			collisionData	= m_ExplorationO.m_OwnerMAC.GetCollisionData( i );
			
			if( AbsF( collisionData.normal.Z ) > 0.45f )
			{
				continue;
			}
			
			collisionAngle	= VecHeading( collisionData.point - playerPos );
			if( AbsF( AngleDistance( angle, collisionAngle ) ) > angleNeeded )
			{
				return true;
			}
		}
		
		return false;
	}
	
	
	private function UpdateCollisionTime( _Dt : float )
	{
		if( m_CollidingB )
		{
			m_TimeCollidingCurF += _Dt;
		}
		else
		{
			m_TimeCollidingCurF	= 0.0f;
		}
	}
	
	
	private function CanPlayerCollide() : bool
	{
		if( ( m_ExplorationO.GetStateCur() == 'Idle' || m_ExplorationO.GetStateCur() == 'Pushed' )
			&& ( !thePlayer.rangedWeapon || thePlayer.rangedWeapon.GetCurrentStateName() == 'State_WeaponWait' ) )
		{
			return true;
		}
		
		return false;
	}
	
	
	private function CanPlayerBePushed() : bool
	{
		if( m_ExplorationO.GetStateCur() == 'CombatExploration' )
		{
			return true;
		}
		
		if( m_ExplorationO.GetStateCur() == 'Idle'  || m_ExplorationO.GetStateCur() == 'Pushed' ) 
		{
			return true;
		}
		
		return false;
	}
	
	
	private function CanPlayerReactToThisNPC( npc :CNewNPC ) : bool
	{
		
		if( npc.GetComponentByClassName('CVehicleComponent') )
		{
			return false;
		}
		
		return true;
	}
	
	
	private function CanNPCsCollide() : bool
	{
		
		if( m_ExplorationO.GetStateCur() != 'Idle' && VecLengthSquared( m_ExplorationO.m_OwnerMAC.GetVelocity() ) >= m_SpeedToCollideWihNPCsF * m_SpeedToCollideWihNPCsF )
		{
			return true;
		}
		if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			return true;
		}
		
		return false;
	}
	
	
	private  function CanThisNpcCollide( npc : CNewNPC ) : bool
	{
		var actor		: CActor;
		var cantPush	: int	= 0;
		
		
		if( !npc.IsAlive() || npc.IsInAgony())
		{
			return false;
		}
		else if( npc.IsAnimal())
		{
			return false;
		}
		
		
		
		return true;
	}
	
	
	private function MakeNPCCollide( npc : CNewNPC )
	{
		
		npc.SignalGameplayEventParamObject( 'CollideWithPlayer', m_ExplorationO.m_OwnerE ); 
		theGame.GetBehTreeReactionManager().CreateReactionEvent( npc, 'BumpAction', 1, 1, 1, 1, false );
	}
	
	
	private function UpdatePlayerCollidingSide( pointToConsider : Vector, normalZ : float )
	{
		var newAngle	: float;
		var auxAngle	: float;	
		
		
		
		if( m_CollidingSideE != SS_SelectedNone && ( !m_CollideCenterIfBothSidesB || m_CollidingSideE == SS_SelectedCenter ) )
		{
			return;
		}
		
		
		if( normalZ > m_AcceptableZToBumpF )
		{
			return;
		}	
		
		
		m_CollidingB	= true;
		
		auxAngle		= VecHeading( pointToConsider - m_ExplorationO.m_OwnerMAC.GetWorldPosition() );
		newAngle		= AngleDistance( m_ExplorationO.m_OwnerMAC.GetHeading(), auxAngle );
		newAngle		= AngleNormalize180( newAngle );
		
		if( newAngle <= -m_AngleToSideF )
		{
			if( m_CollidingSideE == SS_SelectedNone )
			{
				m_CollidingSideE = SS_SelectedLeft;
			}
			else if( m_CollideCenterIfBothSidesB && m_CollidingSideE == SS_SelectedRight )
			{
				newAngle	= 0.0f;
				m_CollidingSideE = SS_SelectedCenter;
			}
		}
		else if( newAngle < m_AngleToSideF )
		{
			m_CollidingSideE = SS_SelectedCenter;
		}
		else if( newAngle >= m_AngleToSideF )
		{
			if( m_CollidingSideE == SS_SelectedNone )
			{
				m_CollidingSideE = SS_SelectedRight;
			}
			else if( m_CollideCenterIfBothSidesB && m_CollidingSideE == SS_SelectedLeft )
			{
				newAngle			= 0.0f;
				m_CollidingSideE	= SS_SelectedCenter;
			}
		}
		
		m_CollidingAngleF	= newAngle;
	}
	
	
	private function UpdatePlayerCollidingHeight( npc : CNewNPC )
	{
		var mac				: CMovingAgentComponent;
		var mpac			: CMovingPhysicalAgentComponent;
		var height			: float;
		var positionOwner	: Vector;
		var positionNpc		: Vector;
		
		
		mac					= npc.GetMovingAgentComponent();
		mpac				= ( CMovingPhysicalAgentComponent ) mac;
		if( !mpac )
		{
			m_CollidingIsLowB	= true;
			
			return;
		}
		
		height				= mpac.GetCapsuleHeight();
		positionOwner		= m_ExplorationO.m_OwnerE.GetWorldPosition();
		positionNpc			= npc.GetWorldPosition();
		
		m_CollidingIsLowB	= positionOwner.Z + m_CollidingLowMinHeightF > positionNpc.Z + height;
	}
	
	
	private function UpdatePlayerCollidingStrength( otherPosition : Vector, otherSpeed : Vector )
	{	
		m_CollidingDirOtherV			= VecNormalize2D( m_ExplorationO.m_OwnerE.GetWorldPosition() - otherPosition );
		m_CollidingStrengthRelativeF	= VecDot2D( m_CollidingDirOtherV, otherSpeed );
		
		
		if( m_CollidingStrengthRelativeF < 0.0f)
		{
			m_CollidingStrengthOtherF	= 0.0f;
		}
		else
		{
			m_CollidingSpeedOtherV		= otherSpeed;
			m_CollidingStrengthOtherF	= VecLength2D( otherSpeed );
		}
	}
	
	
	public function GetPushData( out strength : float, out direction : Vector, out otherSpeed : float, out otherVelocity : Vector )
	{
		strength		= m_CollidingStrengthRelativeF;
		direction		= m_CollidingDirOtherV;
		otherSpeed		= m_CollidingStrengthOtherF;
		otherVelocity	= m_CollidingSpeedOtherV;
	}

	
	private function SetPlayerCollisionBehaviorData()
	{
		var desiredStance		: EPlayerCollisionStance;
		
		
		
		desiredStance	= GetDesiredStance();		
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( m_CollideBehGraphStanceNameS, ( float ) ( int )desiredStance );
		
		
		if( m_CollidingSideLastE != m_CollidingSideE )
		{
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( m_CollideBehGraphSideNameS, ( float ) ( int )m_CollidingSideE );
		}
		
		
		m_ExplorationO.SetBehaviorParamBool( m_CollideBehGraphHeightN, m_CollidingIsLowB );
		
		
		if( m_VisualReactionToPushB )
		{
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( m_CollideBehGraphStrengthRelNameS, m_CollidingStrengthRelativeF );
			
		}
	}
	
	
	private function UpdateCollidingSideEvent( _Dt : float )
	{
		if( m_CollidingSideLastE != m_CollidingSideE )
		{
			switch( m_CollidingSideE )
			{
				case SS_SelectedNone	:
					
					m_CollidingSideCooldownF	-= _Dt;
					if( m_CollidingSideCooldownF > 0.0f )
					{
						return;
					}
					
					m_ExplorationO.m_OwnerE.RaiseEvent( 'CollideStop' );
					break;
				case SS_SelectedLeft	:
					m_ExplorationO.m_OwnerE.RaiseEvent( 'CollideLeft' );
					m_CollidingSideCooldownF	= 0.0f;
					break;
				case SS_SelectedRight	:
					m_ExplorationO.m_OwnerE.RaiseEvent( 'CollideRight' );
					m_CollidingSideCooldownF	= 0.0f;
					break;
				case SS_SelectedCenter	:
					m_ExplorationO.m_OwnerE.RaiseEvent( 'CollideCenter' );
					m_CollidingSideCooldownF	= 0.3f;
					break;
			}
			
			m_CollidingSideLastE		= m_CollidingSideE;
		}
	}
	
	
	private function GetDesiredStance() : EPlayerCollisionStance
	{
		
		if( m_CollidingWithStaticsB )
		{
			return GCS_Walk;
		}
		
		if( thePlayer.GetIsSprinting() )
		{
			
			if( m_CollidingWithNpcB )
			{
				return GCS_Sprint;
			}
		}
		else if( thePlayer.IsInCombat() )
		{
			return GCS_Combat;
		}
		else if( thePlayer.GetIsRunning() )
		{
			return GCS_Run;
		}
		else if( thePlayer.IsMoving() )
		{
			return GCS_Walk;
		}
		
		return GCS_Idle;
	}
	
	
	public function IsThereWaterAndIsItDeepEnough( point : Vector, height : float, radius : float ) : bool
	{
		var world 			: CWorld;
		var waterLevel 		: float;
		var res 			: bool;
		var posOrigin		: Vector;
		var posEnd			: Vector;
		var posMid			: Vector;
		var posCollided		: Vector;
		var normalCollided	: Vector;
		var waterDepth		: float;
		var tempPlayerpos	: Vector;
		
		
		
		world		= theGame.GetWorld();
		if( !world )
		{
			return false;
		}
		
		
		posEnd		= point;
		posEnd.Z	= height;
		posOrigin	= point;
		
		waterLevel	= world.GetWaterLevel( point );
		
		
		if( height >= waterLevel )
		{
			return false;
		}
		
		
		point.Z = waterLevel + 0.2f;
		waterDepth = world.GetWaterDepth( point, true );
		
		
		if( waterDepth < m_LandWaterMinDepthF )
		{
			return false;
		}
		
		
		posEnd.Z	= waterLevel - 0.2f; 
		
		res = world.StaticTrace( posOrigin, posEnd, posCollided, normalCollided, m_CollisionObstaclesNArr );
		if( res )
		{
			return false;
		}
		
		return true;
	}
	
	
	public function CheckLandBelow( distance : float, optional offset : Vector, optional useDefaultCollisionObstacles : bool  ) : bool
	{
		return CheckSwipeInDir( -m_UpV, distance, 0.2f, offset, useDefaultCollisionObstacles );
	}
	
	
	public function CheckCollisionsForwardInHands( distance : float ) : bool
	{
		return CheckSwipeInDir( m_ExplorationO.m_OwnerE.GetWorldForward(), distance, 0.3f, m_UpV );
	}
	
	
	public function CheckCollisionsToNoStepOnInputDir( distForward, heightToStep : float ) : bool
	{
		var direction : Vector;
		if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			direction	= m_ExplorationO.m_InputO.GetMovementOnPlaneNormalizedV();
		}
		else
		{
			direction	= m_ExplorationO.m_OwnerE.GetWorldForward();
		}
		return CheckSwipeInDir( direction, distForward + 0.4f, 0.3f, m_UpV * ( heightToStep + 0.3f ), true );
	}
	
	
	public function CheckCollisionsInJumpTrajectory( height : float, distance : float ) : bool
	{
		return CheckSwipeInDir( m_ExplorationO.m_OwnerE.GetWorldForward(), distance, 0.3f, m_UpV * ( height + 0.3f ) );
	}
	
	
	public function EnableVerticalSliding( enable : bool )
	{		
		m_ExplorationO.m_OwnerMAC.EnableAdditionalVerticalSlidingIteration( enable );
	}
	
	
	public function TeleportPlayerToHisGroundIfNeeded( tolerance : float )
	{
		var world 			: CWorld;
		var waterLevel 		: float;
		var res 			: bool;
		var posOrigin		: Vector;
		var posEnd			: Vector;
		var posCollided		: Vector;
		var normalCollided	: Vector;
		var ticket			: SMovementAdjustmentRequestTicket;
		var movementAdjustor: CMovementAdjustor;
		
		
		
		world		= theGame.GetWorld();
		if( !world )
		{
			return;
		}
		
		posOrigin	= m_ExplorationO.m_OwnerE.GetWorldPosition();
		
		
		waterLevel	= world.GetWaterLevel( posOrigin );
		if( waterLevel >= posOrigin.Z )
		{
			return;
		}
		
		
		posEnd		= posOrigin;
		posOrigin.Z	+= 1.8f;
		posEnd.Z	-= 30.0f;
		res	= world.SweepTest( posOrigin, posEnd, 0.4f, posCollided, normalCollided, m_CollisionObstaclesNArr );
		
		
		if( res && AbsF( posOrigin.Z - posCollided.Z ) > tolerance || AbsF( posOrigin.Z - posCollided.Z ) < 1.0f )
		{
			
			if( waterLevel >= posCollided.Z )
			{
				posOrigin.Z	= waterLevel;
			}
			
			else
			{
				posOrigin.Z	= posCollided.Z;
			}
			
			movementAdjustor	= m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
			ticket				= movementAdjustor.CreateNewRequest( 'teleported_moveDown' );
			
			thePlayer.Teleport( posOrigin );
			
			movementAdjustor.AdjustmentDuration( ticket, 0.1f );
			movementAdjustor.SlideBy( ticket, Vector( 0, 0, -0.3f ) );		
		}		
	}
	
	
	public function CheckSwipeInDir( directionNormalized : Vector, distance : float, radius : float, optional vecOffset : Vector, optional useDefaultCollisionObstacles : bool ) : bool
	{
		var world 			: CWorld;
		var posCurrent		: Vector;
		var posPredicted	: Vector;
		var posCollided		: Vector;
		var normalCollided	: Vector;
		var res				: bool;
		
		
		world	= theGame.GetWorld();
		if( !world )
		{
			return false;
		}
		
		
		posCurrent		= m_ExplorationO.m_OwnerE.GetWorldPosition() + vecOffset;
		posPredicted	= posCurrent;
		posPredicted	+= directionNormalized * distance;
		
		
		if( useDefaultCollisionObstacles )
		{
			res	= world.SweepTest( posCurrent, posPredicted, radius, posCollided, normalCollided, m_CollisionObstaclesNArr );
		}
		else
		{
			res	= world.SweepTest( posCurrent, posPredicted, radius, posCollided, normalCollided );
		}
		if( !res )
		{
			return false;
		}
		
		
		if( VecDot( normalCollided, -directionNormalized ) < 0.75f )
		{
			return false;
		}
		
		return true;
	}
	
	
	public function CheckLineOfSightHorizontal( point : Vector ) : bool
	{
		var world 			: CWorld;
		var posOrigin		: Vector;
		var direction		: Vector;
		var distance		: float;
		var posCollided		: Vector;
		var normalCollided	: Vector;
		var res				: bool;
		
		
		
		world		= theGame.GetWorld();
		if( !world )
		{
			return true;
		}
		
		
		posOrigin	= m_ExplorationO.m_OwnerE.GetWorldPosition() + m_ExplorationO.m_OwnerE.GetWorldUp();
		point.Z		= posOrigin.Z;
		direction	= point - posOrigin;
		distance	= VecLength( direction );
		
		if( distance < 0.5f )
		{
			return true;
		}
		
		point		-= direction * 0.3f / distance;
		
		
		res = world.StaticTrace( posOrigin, point, posCollided, normalCollided, m_CollisionGroupsNamesNArr );
		if( res )
		{
			return false;
		}
		
		return true;
	}
	
	
	public function HasGroundCollisions() : bool
	{
		var mac				: CMovingPhysicalAgentComponent;
		
		
		mac				= ( CMovingPhysicalAgentComponent ) m_ExplorationO.m_OwnerMAC;
		
		if( 	mac.GetGroundGridCollisionOn( CS_CENTER ) 
			||	mac.GetGroundGridCollisionOn( CS_FRONT )
			||	mac.GetGroundGridCollisionOn( CS_FRONT_LEFT ) 
			||	mac.GetGroundGridCollisionOn( CS_FRONT_RIGHT ) 
			||	mac.GetGroundGridCollisionOn( CS_LEFT ) 
			||	mac.GetGroundGridCollisionOn( CS_RIGHT ) 
			||	mac.GetGroundGridCollisionOn( CS_BACK ) 
			||	mac.GetGroundGridCollisionOn( CS_BACK_LEFT ) 
			||	mac.GetGroundGridCollisionOn( CS_BACK_RIGHT )  )
		{
			return true;
		}
		
		return false;
	}
	
	
	public function GetHasToFallInDirection( out direction: float ) : bool
	{
		var mac				: CMovingPhysicalAgentComponent;
		var hasCenterGround	: bool;
		var front			: bool;
		var left			: bool;
		var right			: bool;
		var back			: bool;
		
		
		if( !forceFallEnabled )
		{
			return false;
		}
		
		if( m_ExplorationO.GetStateCur() != 'Idle' && m_ExplorationO.GetStateCur() != 'CombatExploration' ) 
		{
			return false;
		}
		
		mac				= ( CMovingPhysicalAgentComponent ) m_ExplorationO.m_OwnerMAC;
		hasCenterGround	= mac.GetGroundGridCollisionOn( CS_CENTER );
		
		if( forceFallRequireCenter && hasCenterGround )
		{
			return false;
		}
		
		if( !forceFallRunning && thePlayer.GetIsRunning() )
		{
			return false;
		}
		
		
		direction	= 0.0f;
		
		
		
		front	= !mac.GetGroundGridCollisionOn( CS_FRONT ) && !mac.GetGroundGridCollisionOn( CS_FRONT_LEFT ) && !mac.GetGroundGridCollisionOn( CS_FRONT_RIGHT );
		left	= !mac.GetGroundGridCollisionOn( CS_LEFT ) && !mac.GetGroundGridCollisionOn( CS_FRONT_LEFT ) && !mac.GetGroundGridCollisionOn( CS_BACK_LEFT );
		right	= !mac.GetGroundGridCollisionOn( CS_RIGHT ) && !mac.GetGroundGridCollisionOn( CS_BACK_RIGHT ) && !mac.GetGroundGridCollisionOn( CS_FRONT_RIGHT );
		
		back	= !mac.GetGroundGridCollisionOn( CS_BACK ) && !mac.GetGroundGridCollisionOn( CS_BACK_RIGHT ) && !mac.GetGroundGridCollisionOn( CS_BACK_LEFT ) && !mac.GetGroundGridCollisionOn( CS_LEFT ) && !mac.GetGroundGridCollisionOn( CS_RIGHT );
		
		
		if( front && left && right && back )
		{
			return false;
		}
		
		
		else if( front  && left && right )
		{
			direction	= 0.0f;
		}
		else if( front && right && back )
		{
			direction	= 0.5f;
		}
		else if( front && left && back )
		{
			direction	= -0.5f;
		}
		else if( front || back )
		{
			if( left )
			{
				direction	= -0.25f;
			}
			else if( right )
			{
				direction	= 0.25f;
			}
			else if( front )
			{
				direction	= 0.0f;
			}
			else 
			{
				direction	= -1.0f;
			}
		}
		else if( left )
		{
			direction	= -0.5f;
		}
		else if( right )
		{
			direction	= 0.5f;
		}
		
		
		if( front || right || left || back )
		{
			if( !front && !right && !left && m_ExplorationO.GetStateCur() != 'Idle' )
			{
				return false;
			}
			
			if( IsAngleBlockedByStatics( direction + m_ExplorationO.m_OwnerE.GetHeading(), 45.0f ) )
			{
				return false;
			}
			
			if( !IsDirectionToFallFree( direction + m_ExplorationO.m_OwnerE.GetHeading() ) )
			{
				return false;
			}
			
			return true;
		}
		
		return false;
	}
	
	
	public function IsInSolidGround() : bool
	{
		var mac	: CMovingPhysicalAgentComponent;
		
		mac		= ( CMovingPhysicalAgentComponent ) m_ExplorationO.m_OwnerMAC;
		if( !mac.GetGroundGridCollisionOn( CS_CENTER )
			|| !mac.GetGroundGridCollisionOn( CS_FRONT ) || !mac.GetGroundGridCollisionOn( CS_FRONT_LEFT ) || !mac.GetGroundGridCollisionOn( CS_FRONT_RIGHT ) 
			|| !mac.GetGroundGridCollisionOn( CS_LEFT ) || !mac.GetGroundGridCollisionOn( CS_RIGHT ) 
			|| !mac.GetGroundGridCollisionOn( CS_BACK ) || !mac.GetGroundGridCollisionOn( CS_BACK_LEFT ) || !mac.GetGroundGridCollisionOn( CS_BACK_RIGHT ) )
		{
			return false;
		}
		else
		{
			return true;
		}		
	}
	
	
	public function IsDirectionToFallFree( headingLocal : float ) : bool
	{
		var direction	: Vector;
		
		
		
		
		
		direction	= VecFromHeading( headingLocal + m_ExplorationO.m_OwnerE.GetHeading() );
		
		
		if( CheckSwipeInDir( direction, 0.6f, 0.4f, m_ExplorationO.m_OwnerE.GetWorldUp(), true ) )
		{
			return false;
		}
		
		
		
		
		return true;
	}

	
	public function GetLandGoesToFall( ) : bool
	{
		var mac				: CMovingPhysicalAgentComponent;
		var hasCenterGround	: bool;
		var front			: bool;
		var restOfCollisions: bool;
		
		
		mac					= ( CMovingPhysicalAgentComponent ) m_ExplorationO.m_OwnerMAC;
		
		
		restOfCollisions	= !mac.GetGroundGridCollisionOn( CS_CENTER ) && !mac.GetGroundGridCollisionOn( CS_BACK ) && !mac.GetGroundGridCollisionOn( CS_BACK_LEFT ) && !mac.GetGroundGridCollisionOn( CS_BACK_RIGHT );
		if( restOfCollisions )
		{
			return false;
		}
		
		
		front	= !mac.GetGroundGridCollisionOn( CS_FRONT ) && !mac.GetGroundGridCollisionOn( CS_FRONT_LEFT ) && !mac.GetGroundGridCollisionOn( CS_FRONT_RIGHT );
		
		return front;
	}
	
	
	
	public function IsGoingDownSlopeInstant( _AutoRollSlopeCoefF : float ) : bool
	{
		var world 			: CWorld;
		var posOrigin		: Vector;
		var posEnd			: Vector;
		var posCollided1	: Vector;
		var posCollided2	: Vector;
		var normalCollided1	: Vector;
		var normalCollided2	: Vector;
		var direction		: Vector;
		var res				: bool;
		
		var	slideCoef		: float;
		
		
		
		world		= theGame.GetWorld();
		if( !world )
		{
			return false;
		}
		
		
		
		posOrigin	= m_ExplorationO.m_OwnerE.GetWorldPosition();
		direction	= m_ExplorationO.m_OwnerE.GetWorldForward() * 0.4f;
		
		posOrigin	-= direction;
		posEnd		= posOrigin;
		posEnd.Z	-= 0.75f;		
		posOrigin.Z	+= 0.75f;	
		
		
		res = world.SweepTest( posOrigin, posEnd,0.2f, posCollided1, normalCollided1 );
		if( !res )
		{
			return false;
		}
		
		posOrigin	+= 2.0f * direction;
		posEnd		+= 2.0f * direction;
		
		
		res = world.SweepTest( posOrigin, posEnd,0.2f, posCollided2, normalCollided2 );
		if( !res )
		{
			return false;
		}
		
		
		
		direction	= VecNormalize( posCollided2 - posCollided1 ); 
		
		
		if( VecDot( direction, Vector( 0.0f, 0.0f, -1.0f ) ) > 0.0f )
		{
			slideCoef	= direction.Z;
			
			if( slideCoef < -_AutoRollSlopeCoefF )
			{
				return true;
			}
		}
		
		return false;
	}
	
	
	public function IsGoingUpSlope( direction : Vector, optional upCoef : float, optional frontCoef : float ) : bool
	{	
		var slopeDir 	: Vector;
		var slopeNormal	: Vector;
		var slopeDot	: float;
		
		
		
		if( upCoef == 0.0f )
		{
			upCoef	= 0.75;
		}
		
		
		
		m_ExplorationO.m_MoverO.GetSlideDirAndNormal( slopeDir, slopeNormal );
		if( slopeNormal.Z < upCoef )
		{
			slopeDot	= VecDot( -slopeDir, direction ); 
			if( slopeDot > frontCoef )
			{
				return true;
			}
		}
		
		return false;
	}
	
	
	public function IsGoingUpSlopeInInputDir( optional upCoef : float, optional frontCoef : float ) : bool
	{	
		if( !m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			return IsGoingUpSlope( m_ExplorationO.m_OwnerE.GetWorldForward(), upCoef, frontCoef );
		}
		
		return IsGoingUpSlope( m_ExplorationO.m_InputO.GetMovementOnPlaneNormalizedV(), upCoef, frontCoef );
		
		return false;
	}
	
	
	public function GetJumpGoesToWater() : bool
	{
		var	inputVector			: Vector;
		var origin				: Vector;
		var end					: Vector;
		var midPoint			: Vector;
		var normal				: Vector;
		var collisionPoint		: Vector;
		var endUpPoint			: Vector;
		var	wallFound			: bool;
		var jumpDistance		: float		= 3.8f; 
		var jumpRadius			: float		= 0.6f;
		var jumpHeight			: float		= 0.5f;
		var jumpMaxFallHeight	: float		= 250.0f;
		
		
		
		if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			inputVector	= m_ExplorationO.m_InputO.GetMovementOnPlaneV();
		}
		else
		{
			inputVector	= m_ExplorationO.m_OwnerE.GetWorldForward();
		}
		m_ExplorationO.m_SharedDataO.m_JumpDirectionForcedV = inputVector;
		
		
		if( thePlayer.IsOnBoat() )
		{
			if( !GetJumpGoesToWaterFromBoat( inputVector ) )
			{
				return false;
			}
		}
		
		
		if( !theGame.GetWorld() )
		{
			return false;
		}
		
		
		origin		= m_ExplorationO.m_OwnerE.GetWorldPosition() + m_ExplorationO.m_OwnerE.GetWorldUp() * ( jumpHeight + jumpRadius ) + m_ExplorationO.m_OwnerE.GetWorldForward() * 0.4f;
		end			= origin + inputVector * jumpDistance;
		midPoint	= origin + inputVector * jumpDistance * 0.5f;
		
		
		wallFound		= theGame.GetWorld().SweepTest( origin, midPoint, jumpRadius, collisionPoint, normal, m_CollisionObstaclesNArr );
		if( wallFound )
		{			
			lastWaterCheckPoint	= collisionPoint;
			return false;
		}
		wallFound		= theGame.GetWorld().SweepTest( midPoint, end, jumpRadius, collisionPoint, normal, m_CollisionObstaclesNArr );
		if( wallFound )
		{			
			lastWaterCheckPoint	= collisionPoint;
			return false;
		}
		
		
		endUpPoint			= end;
		endUpPoint.Z		= origin.Z;
		lastWaterCheckPoint	= endUpPoint;
		return IsThereWaterAndIsItDeepEnough( endUpPoint, end.Z - jumpMaxFallHeight, jumpRadius );		
	}
	
	
	private function GetJumpGoesToWaterFromBoat( inputVector : Vector ) : bool
	{
		var	vehicleComponent	: CVehicleComponent;
		var vehicleEntity		: CEntity;	
		var direction			: Vector;
		
		var	dot					: float;
		var	dot2				: float;
		var	angle				: float;
		
		
		vehicleComponent		= thePlayer.FindTheNearestVehicle( 6.0f, false );
		if( vehicleComponent )
		{
			vehicleEntity		= ( CEntity ) vehicleComponent.GetParent();		
			if( vehicleEntity )
			{
				
				dot				= VecDot( inputVector, vehicleEntity.GetWorldForward() );
				dot				= AbsF( dot );
				if( dot < 0.5f )
				{
					
					direction	= m_ExplorationO.m_OwnerE.GetWorldPosition() - vehicleEntity.GetWorldPosition();
					dot			= VecDot( direction, vehicleEntity.GetWorldRight() );
					dot2		= VecDot( inputVector, vehicleEntity.GetWorldRight() );
					if( dot * dot2 > 0.0f )
					{
						return true;
					}
				} 
			}
		}
		
		return false;
	}

	
	public function GetJumpGoesOutOfBoat() : bool
	{
		var	vehicleComponent	: CVehicleComponent;
		var vehicleEntity		: CEntity;	
		var direction			: Vector;
		
		var	dot					: float;
		var	dot2				: float;
		var	angle				: float;
		var	inputVector			: Vector;
		
		
		
		if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			inputVector	= m_ExplorationO.m_InputO.GetMovementOnPlaneV();
		}
		else
		{
			inputVector	= m_ExplorationO.m_OwnerE.GetWorldForward();
		}
		
		
		vehicleComponent		= thePlayer.FindTheNearestVehicle( 6.0f, false );
		if( vehicleComponent )
		{
			vehicleEntity		= ( CEntity ) vehicleComponent.GetParent();		
			if( vehicleEntity )
			{
				
				dot				= VecDot( inputVector, vehicleEntity.GetWorldForward() );
				dot				= AbsF( dot );
				return dot < 0.6f;
			}
		}
		
		return false;
	}
	
	
	public function UpdateDebugInfo()
	{
		var auxString		: string;
		var textColor		: Color		= Color( 255,255,0 );
		var width			: int		= 200;
		var height			: int		= 10;
		var heightCur		: int;
		var heightInit		: int		= 100;
		var heightInactive	: int		= 300;
		var heightOffset	: int		= 15;
		var heightOffsetBig	: int		= 25;
		var left			: int		= 850;
		var center			: int		= 950;
		var right			: int		= 1050;
		var i				: int;
		var mac				: CMovingPhysicalAgentComponent;
		
		
		mac			= ( CMovingPhysicalAgentComponent ) m_ExplorationO.m_OwnerMAC;
		
		heightCur	= heightInit;
		thePlayer.GetVisualDebug().AddBar( 'GroundCollisionFail', left, heightCur, width, height, 0.0f, textColor, "Ground collisions", 0.0f );
		
		
		heightCur	+= heightOffset;
		auxString	= "" + mac.GetGroundGridCollisionOn( CS_FRONT_LEFT );
		thePlayer.GetVisualDebug().AddBar( 'CS_FRONT_LEFT', left, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );	
		
		auxString	= "" + mac.GetGroundGridCollisionOn( CS_FRONT );
		thePlayer.GetVisualDebug().AddBar( 'CS_FRONT', center, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );	
		
		auxString	= "" + mac.GetGroundGridCollisionOn( CS_FRONT_RIGHT );
		thePlayer.GetVisualDebug().AddBar( 'CS_FRONT_RIGHT', right, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );
		
		
		
		heightCur	+= heightOffset;
		auxString	= "" + mac.GetGroundGridCollisionOn( CS_LEFT );
		thePlayer.GetVisualDebug().AddBar( 'CS_LEFT', left, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );	
		
		auxString	= "" + mac.GetGroundGridCollisionOn( CS_CENTER );
		thePlayer.GetVisualDebug().AddBar( 'CS_CENTER', center, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );	
		
		auxString	= "" + mac.GetGroundGridCollisionOn( CS_RIGHT );
		thePlayer.GetVisualDebug().AddBar( 'CS_RIGHT', right, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );
		
		
		
		heightCur	+= heightOffset;
		auxString	= "" + mac.GetGroundGridCollisionOn( CS_BACK_LEFT );
		thePlayer.GetVisualDebug().AddBar( 'CS_BACK_LEFT', left, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );	
		
		auxString	= "" + mac.GetGroundGridCollisionOn( CS_BACK );
		thePlayer.GetVisualDebug().AddBar( 'CS_BACK', center, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );	
		
		auxString	= "" + mac.GetGroundGridCollisionOn( CS_BACK_RIGHT );
		thePlayer.GetVisualDebug().AddBar( 'CS_BACK_RIGHT', right, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );		
	}	

	
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags )
	{
		var vectorUp	: Vector;
		var destination	: Vector;
		
		if( !debugEnabled )
		{
			return true;
		}
		
		
		
		frame.DrawSphere( lastWaterCheckPoint, 0.3f, Color( 0, 255, 0 ) );
		frame.DrawText( "Water ", lastWaterCheckPoint, Color( 0, 255, 0 ) );
		
		
		return true;
	}
}
