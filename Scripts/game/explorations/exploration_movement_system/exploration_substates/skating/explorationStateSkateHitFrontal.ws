/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CExplorationStateSkatingHitFrontal extends CExplorationInterceptorStateAbstract
{		
	private						var	skateGlobal		: CExplorationSkatingGlobal;
	
	protected editable			var behAnimEnd		: name;			default	behAnimEnd		= 'AnimEndAUX';
	protected editable			var timeMax			: float;		default	timeMax			= 0.5f;	
	protected editable			var dotCollToEnter	: float;		default	dotCollToEnter	= 0.75f;
	
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'SkateHitFrontal';
		}
		
		skateGlobal	= _Exploration.m_SharedDataO.m_SkateGlobalC;		
		
		
		m_InterceptStateN	= 'SkateHitLateral';
		
		
		m_StateTypeE	= EST_Skate;
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{
	}

	
	function StateWantsToEnter() : bool
	{	
		var collisionData	: SCollisionData;
		var collisionNum	: int;
		var collisionNormal : Vector;
		var i				: int;
		var direction		: Vector;
		
		direction	= m_ExplorationO.m_MoverO.GetMovementVelocityNormalized();
		
		
		collisionNum = m_ExplorationO.m_OwnerMAC.GetCollisionDataCount();
		for( i = 0; i < collisionNum; i += 1 )
		{
			collisionData	= m_ExplorationO.m_OwnerMAC.GetCollisionData( i );
			collisionNormal += collisionData.normal;
		}
		if ( collisionNum > 0 )
		{
			collisionNormal = VecNormalize( collisionNormal );
			if( VecDot( collisionNormal, direction ) < -dotCollToEnter )
			{
				return true;
			}
		}
		return false;
	}
	
	
	function StateCanEnter( curStateName : name ) : bool
	{	
		var collisionData	: SCollisionData;
		var collisionNum	: int;
		var collisionNormal : Vector;
		var i				: int;
		var direction		: Vector;
		
		direction	= m_ExplorationO.m_MoverO.GetMovementVelocityNormalized();
		
		
		collisionNum	= m_ExplorationO.m_OwnerMAC.GetCollisionDataCount();
		for( i = 0; i < collisionNum; i += 1 )
		{
			collisionData	= m_ExplorationO.m_OwnerMAC.GetCollisionData( i );
			collisionNormal += collisionData.normal;
		}
		if ( collisionNum > 0 )
		{
			collisionNormal = VecNormalize( collisionNormal );
			if( VecDot( collisionNormal, direction ) < -dotCollToEnter )
			{
				return true;
			}
		}
		return false;
	}
	
	
	private function StateEnterSpecific( prevStateName : name )	
	{		
		m_ExplorationO.m_MoverO.StopAllMovement();
	}
	
	
	function StateChangePrecheck( )	: name
	{
		if( m_ExplorationO.GetStateTimeF() > timeMax )
		{
			return 'SkateIdle';
		}
		
		
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{		
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{		
	}	
	
	
	
	
	

	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventName	== behAnimEnd )
		{		
			SetReadyToChangeTo( 'SkateIdle' );
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