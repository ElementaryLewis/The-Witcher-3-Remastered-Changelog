/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CExplorationStateSkatingHitLateral extends CExplorationStateAbstract
{		
	private						var	skateGlobal			: CExplorationSkatingGlobal;
	
	protected editable			var behAnimEnd			: name;			default	behAnimEnd			= 'AnimEndAUX';
	protected editable			var timeMax				: float;		default	timeMax				= 0.75f;
	
	protected editable			var speedMinToEnter		: float;		default	speedMinToEnter		= 1.0f;	
	protected editable			var speedReductionPerc	: float;		default	speedReductionPerc	= 0.3f;	
	protected editable			var extraAngle			: float;		default	extraAngle			= 15.0f;	
	
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'SkateHitLateral';
		}
		
		skateGlobal	= _Exploration.m_SharedDataO.m_SkateGlobalC;		
		
		
		speedReductionPerc	= ClampF( speedReductionPerc, 0.0f, 1.0f );
		
		
		m_StateTypeE	= EST_Skate;
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{
	}

	
	function StateWantsToEnter() : bool
	{	
		if( m_ExplorationO.m_MoverO.GetMovementSpeedF() < speedMinToEnter )
		{
			return false;
		}
		
		
		if( m_ExplorationO.m_OwnerMAC.GetCollisionDataCount() > 1 )
		{
			return true;
		}
		
		return false;
	}
	
	
	function StateCanEnter( curStateName : name ) : bool
	{	
		return true;
	}
	
	
	private function StateEnterSpecific( prevStateName : name )	
	{		
		var yawTarget		: float;
		
		
		
		yawTarget	= GetCollisionAngle();
		
		
		m_ExplorationO.SetBehaviorParamBool( 'Skate_HitLeft', yawTarget > 0.0f );	
		
		
		ReduceSpeed();
		
		
		SetOrientation( yawTarget );
	}
	
	
	function StateChangePrecheck( )	: name
	{
		if( m_ExplorationO.GetStateTimeF() > timeMax )
		{
			return 'SkateRun';
		}
		
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{		
		var accel	: float;
		var turn	: float;
		var braking	: bool;
		
		
		
		skateGlobal.UpdateRandomAttack();
		
		
		m_ExplorationO.m_MoverO.UpdateSkatingMovement( _Dt, accel, turn, braking );
		
		
		skateGlobal.SetBehParams( accel, braking, turn );		
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{				
		
		m_ExplorationO.m_OwnerMAC.GetMovementAdjustor().CancelByName( 'turnForSkateHit' );
	}	
	
	
	private function GetCollisionAngle() : float
	{
		var collisionData	: SCollisionData;
		var collisionNum	: int;
		var i				: int;
		var resultingColl	: Vector;
		var yawTarget		: float;
		
		
		
		collisionNum	= m_ExplorationO.m_OwnerMAC.GetCollisionDataCount();
		for( i = 0; i < collisionNum; i += 1 )
		{
			collisionData	= m_ExplorationO.m_OwnerMAC.GetCollisionData( i );
			if( collisionData.normal.Z < 0.5f )
			{
				resultingColl	+= collisionData.normal;
			}
		}
		
		
		resultingColl	= VecNormalize( resultingColl );
		
		yawTarget		= VecHeading( resultingColl );
		if( VecDot( resultingColl, m_ExplorationO.m_OwnerE.GetWorldRight() ) < 0.0f )
		{
			yawTarget	-= 90.0f - extraAngle;
		}
		else
		{
			yawTarget	+= 90.0f - extraAngle;
		}
		
		return yawTarget;
	}
	
	
	private function SetOrientation( yawTarget : float )
	{
		var movAdj 			: CMovementAdjustor;
		var ticket 			: SMovementAdjustmentRequestTicket;
		
		
		
		movAdj = m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		ticket = movAdj.CreateNewRequest( 'turnForSkateHit' );
		
		movAdj.AdjustmentDuration( ticket, 0.3f );
		movAdj.RotateTo( ticket, yawTarget );
		movAdj.LockMovementInDirection( ticket, yawTarget );
	}
	
	
	private function ReduceSpeed()
	{
		var newVelocity	: Vector;
		
		newVelocity	= m_ExplorationO.m_MoverO.GetMovementVelocity();
		
		newVelocity	*= ( 1.0f - speedReductionPerc );
		
		m_ExplorationO.m_MoverO.SetVelocity( newVelocity );
	}
	
	
	
	
	

	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventName	== behAnimEnd )
		{		
			SetReadyToChangeTo( 'SkateRun' );
		}
	}
	
	
	
	
	
	
	function ReactToLoseGround() : bool
	{
		SetReadyToChangeTo( 'StartFalling' );
		
		return true;
	}
	
	
	function ReactToHitGround() : bool
	{		
		return true;
	}		
	
	
	function CanInteract( ) : bool
	{		
		return false;
	}
}