/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EAirCollisionSide
{
	EACS_Left	= 0,
	EACS_Center	= 1,
	EACS_Right	= 2,
}



class CExplorationStateAirCollision extends CExplorationStateAbstract
{
	editable			var	enabled						: bool;			default	enabled						= true;
	
	
	editable			var	speedMinToCollide			: float;		default	speedMinToCollide			= 0.0f;
	editable			var	heightMinToCollide			: float;		default	heightMinToCollide			= 0.12f;
	private editable	var	heightMaxToStop				: float;		default	heightMaxToStop				= 3.0f;
	private editable	var	dotToHardHit				: float;		default	dotToHardHit				= 0.75f;
	
	private				var collisionAngle				: float;
	private				var	collisionSide				: EAirCollisionSide;
	
	public				var	m_NormalMaxZToHitF			: float;		default	m_NormalMaxZToHitF			= 0.85f;
	public				var angleMinToCollide			: float;		default	angleMinToCollide			= 90.0f;
	public				var angleMinToCollideFront		: float;		default	angleMinToCollideFront		= 45.5f;
	
	
	public	editable	var	swipeDistance				: float;		default	swipeDistance				= 0.3f;
	public	editable	var	swipeRadius					: float;		default	swipeRadius					= 0.6f;
	public	editable	var	swipeHeightRequired			: float;		default	swipeHeightRequired			= 0.4f;
	
	
	
	private editable	var	timeStopped					: float;		default	timeStopped					= 1.5f;
	private editable	var	timeToRotate				: float;		default	timeToRotate				= 0.15f;
	private	editable	var	timeToCheckClimb			: float;		default	timeToCheckClimb			= 1.5f;
	private	editable	var	timeToCheckLand				: float;		default	timeToCheckLand				= 1.5f;
	
	
	private editable	var	exitAngleLeft				: float;		default	exitAngleLeft				= 45.0f;
	private editable	var	exitAngleRight				: float;		default	exitAngleRight				= 45.0f;
	private editable	var	exitAngleExtra				: float;		default	exitAngleExtra				= 20.0f;
	private editable	var	orientingSpeed				: float;		default	orientingSpeed				= 1000.0f;
	private 			var	targetYaw					: float;
	private editable	var	verticalSpeedConserveCoef	: float;		default	verticalSpeedConserveCoef	= 0.25f;
	private editable	var	verticalMovementParams		: SVerticalMovementParams;
	private editable	var	impulseForwardCenter		: float;		default	impulseForwardCenter		= -3.0f;
	private editable	var	impulseDownCenter			: float;		default	impulseDownCenter			= 8.0f;
	private editable	var	impulseForwardSide			: float;		default	impulseForwardSide			= 15.0f;
	private editable	var	impulseDownSide				: float;		default	impulseDownSide				= 7.0f;
	
	
	protected editable	var	interactAlways				: bool;			default	interactAlways				= true;
	private	editable	var	interactionTimeMin			: float;		default	interactionTimeMin			= 0.2f;
	private	editable	var	interactionMaxHeight		: float;		default	interactionMaxHeight		= 2.8f;
	
	
	editable			var	timeToHitToLand				: float;		default	timeToHitToLand				= 0.1f;
	editable			var	behEventHitToLand			: name;			default	behEventHitToLand			= 'HitWall_ToLand';
	editable			var	behVarSide					: name;			default	behVarSide					= 'AirCollisionSide';
	editable			var	behVarHands					: name;			default	behVarHands					= 'AirCollisionHands';
	private editable	var	behAnimCanFall				: name;			default	behAnimCanFall				= 'CanFall';
	
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'AirCollision';
		}
		
		m_StateTypeE		= EST_OnAir;
		m_InputContextE		= EGCI_JumpClimb; 
		
		
		
		SetCanSave( false );
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{
		AddStateToTheDefaultChangeList('Climb');
	}

	
	function StateWantsToEnter() : bool
	{
		var velocity		: Vector;
		var collisionData	: SCollisionData;
		var collisionNum	: int;
		var collisionNormal : Vector;
		var i				: int;
		var forwardestDot	: float;
		var currentDot		: float;
		
		
		
		if( m_ExplorationO.m_SharedDataO.GetFallingHeight() > heightMaxToStop )
		{
			return false;
		}
		
		
		velocity	= m_ExplorationO.m_OwnerMAC.GetVelocity();
		velocity.Z	= 0.0f;
		if( VecLengthSquared( velocity ) < speedMinToCollide * speedMinToCollide )
		{
			return false;
		}
		
		
		collisionNum	= m_ExplorationO.m_OwnerMAC.GetCollisionDataCount();
		if( collisionNum <= 0 )
		{
			return false;
		}
		
		
		forwardestDot	= -1.0f;
		for( i = 0; i < collisionNum; i += 1 )
		{
			collisionData	= m_ExplorationO.m_OwnerMAC.GetCollisionData( i );
			
			if( AbsF( collisionData.normal.Z ) <= m_NormalMaxZToHitF )
			{
				currentDot		= VecDot( -collisionData.normal, m_ExplorationO.m_OwnerE.GetWorldForward() );
				if( currentDot > forwardestDot )
				{
					collisionNormal = -collisionData.normal;
					currentDot		= forwardestDot;
				}
			}
		}
		
		
		collisionAngle		= AngleNormalize180( AngleDistance( VecHeading( collisionNormal ), m_ExplorationO.m_OwnerE.GetHeading() ) );
		if( AbsF( collisionAngle ) > angleMinToCollide )
		{
			return false;
		}
		if( !m_ExplorationO.m_SharedDataO.m_AirCollisionSideEnabledB && AbsF( collisionAngle ) > angleMinToCollideFront )
		{
			return false;
		}
		
		LogExploration( GetStateName() + " " + "angle " + collisionAngle );
		
		
		if( false ) 
		{
			return false;
		}
		
		
		collisionNormal.Z	= 0.0f;
		collisionNormal		= VecNormalize( collisionNormal );		
		if( !m_ExplorationO.m_CollisionManagerO.CheckSwipeInDir( -collisionNormal, swipeDistance + 0.4f, swipeRadius, Vector( 0.f, 0.f, swipeRadius + swipeHeightRequired ) , true ) )
		{
			return false;
		}
		
		return true;
	}

	
	function StateCanEnter( curStateName : name ) : bool
	{	
		return enabled;
	}
	
	
	private function StateEnterSpecific( prevStateName : name )	
	{
		var collisionDirectionDot	: float;
		var collisionData			: SCollisionData;
		var collisionNum			: int;
		var i						: int;
		var resultingNormal			: Vector;
		var tooMuchHeight			: bool;
		
		var movAdj 					: CMovementAdjustor;
		var ticket 					: SMovementAdjustmentRequestTicket;
		var extraAngle				: float;
		
		
		
		m_ExplorationO.m_MoverO.SetManualMovement( true );
		
		tooMuchHeight	= m_ExplorationO.m_SharedDataO.GetFallingHeight() > heightMaxToStop;
		
		
		if( !tooMuchHeight && timeStopped > 0.0f )
		{
			m_ExplorationO.m_MoverO.SetVerticalSpeed( 0.0f );
		}
		else
		{
			if( tooMuchHeight )
			{
				LogExploration( GetStateName() + ": Can't stop cause of too much height fallen" );
			}
			
			m_ExplorationO.m_MoverO.SetVerticalSpeed( m_ExplorationO.m_MoverO.GetMovementVerticalSpeedF() * verticalSpeedConserveCoef );
		}
		
		m_ExplorationO.m_MoverO.SetVerticalMovementParams( verticalMovementParams );
		
		
		if( AbsF( collisionAngle ) < angleMinToCollideFront )
		{
			collisionSide	= EACS_Center;
			extraAngle		= 0.0f;
		}
		else if( collisionAngle > 0.0f )
		{
			collisionSide	= EACS_Left;
			extraAngle		= -exitAngleLeft - exitAngleExtra;
		}
		else
		{
			collisionSide	= EACS_Right;
			extraAngle		= exitAngleRight + exitAngleExtra;
		}
		m_ExplorationO.m_SharedDataO.m_AirCollisionIsFrontal	= collisionSide == EACS_Center;
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVarSide, ( float ) ( int ) collisionSide );
		
		
		
		
		if( m_ExplorationO.m_CollisionManagerO.CheckCollisionsForwardInHands( 0.2f ) )
		{
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVarHands, 1.0f );
		}
		else
		{
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVarHands, 0.0f );
		}
		
		
		m_ExplorationO.m_SharedDataO.SetFotForward( true );
		
		
		movAdj = m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		ticket = movAdj.CreateNewRequest( 'HitWall' );
		movAdj.AdjustmentDuration( ticket, timeToRotate );
		movAdj.RotateTo( ticket, m_ExplorationO.m_OwnerE.GetHeading() + collisionAngle + extraAngle );
	}
	
	
	private function AddAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behAnimCanFall, 'OnAnimEvent_SubstateManager' );
	}
	
	
	function StateChangePrecheck( )	: name
	{	
		
		if( m_ExplorationO.GetStateTimeF() >= timeToCheckClimb && InputWantsToClimb() )
		{
			if( m_ExplorationO.StateWantsAndCanEnter( 'Climb' ) )
			{
				return 'Climb';
			}
		}
		
		
		
		if( m_ExplorationO.GetStateTimeF() >= timeToCheckLand && m_ExplorationO.m_CollisionManagerO.CheckLandBelow( 0.01f ) )
		{
			if( m_ExplorationO.GetStateTimeF() >= timeToHitToLand )
			{
				
				m_ExplorationO.m_SharedDataO.m_JumpTypeE = EJT_Hit;
				m_ExplorationO.SendAnimEvent( behEventHitToLand );
				
				return 'Land';
			}
		}
		
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{
		
		if( m_ExplorationO.GetStateTimeF() >= timeStopped )
		{
			m_ExplorationO.m_MoverO.UpdatePerfectMovementVertical( _Dt );
		}
		
		
		
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{
		
		m_ExplorationO.m_MoverO.SetManualMovement( false );
		
		
		m_ExplorationO.m_OwnerMAC.GetMovementAdjustor().CancelByName( 'HitWall' );
		
		
		if( nextStateName == 'Jump' )
		{	
			PrepareImpulseToJump();
		}
	}
	
	
	private function RemoveAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behAnimCanFall );
	}
	
	
	private function PrepareImpulseToJump()
	{
		var impulse			: Vector;
		var verticalImpulse	: float;
		
		if( collisionSide == EACS_Center )
		{
			impulse	= m_ExplorationO.m_OwnerE.GetWorldForward() * impulseForwardCenter;
			verticalImpulse	= impulseDownCenter;
		}
		else
		{
			impulse	= m_ExplorationO.m_OwnerE.GetWorldForward() * impulseForwardSide;
			verticalImpulse	= impulseDownSide;
		}
		
		m_ExplorationO.m_MoverO.SetVelocity( impulse );
		m_ExplorationO.m_MoverO.SetVerticalSpeed( -verticalImpulse );
	}
	
	
	private function InputWantsToClimb() : bool
	{
		
		if( !interactAlways )
		{
			return false;
		}
		
		
		if( m_ExplorationO.GetStateTimeF() < interactionTimeMin )
		{
			return false;
		}
		
		
		if( !m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			return false;
		}
		
		return true;
	}
	
	
	private function WantsToInteractWithExploration() : bool
	{
		var exploration					: SExplorationQueryToken;
		var queryContext				: SExplorationQueryContext;
		
		
		if( m_ExplorationO.m_SharedDataO.m_UseClimbB )
		{
			return false;
		}
		
		
		queryContext.inputDirectionInWorldSpace	= m_ExplorationO.m_InputO.GetMovementOnPlaneV();
		
		
		queryContext.forJumping = true;
		
		
		queryContext.dontDoZAndDistChecks = true;
		
		
		exploration = theGame.QueryExplorationSync( m_ExplorationO.m_OwnerE, queryContext );
		
		
		if ( !exploration.valid )
		{
			return false;
		}
		
		
		if( VecDistanceSquared( exploration.pointOnEdge, m_ExplorationO.m_OwnerE.GetWorldPosition() ) > interactionMaxHeight * interactionMaxHeight )
		{
			return false;
		}
		
		
		m_ExplorationO.m_SharedDataO.SetExplorationToken( exploration, GetStateName() );
		
		return true;
	}
	
	
	
	
	
	
	function ReactToLoseGround() : bool
	{
		return true;
	}
	
	
	function ReactToHitGround() : bool
	{	
		
		return true;
	}
	
	
	public function GetDebugText() : string
	{
		var text	: string;
		
		text = " Side: " + collisionSide + ", Angle: " + collisionAngle;
		
		return text;
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{		
		if( animEventName == behAnimCanFall )
		{
			SetReadyToChangeTo( 'Jump' );
		}
	}
	
	
	function UpdateCameraIfNeeded( out moveData : SCameraMovementData, dt : float ) : bool
	{
		return true;
	}
	
	
	function CanInteract( ) :bool
	{		
		return false;
	}
}
