/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CExplorationStateSkatingPrepareJump extends CExplorationInterceptorStateAbstract
{		
	private						var	skateGlobal		: CExplorationSkatingGlobal;
	
	protected editable			var behAnimEnd		: name;			default	behAnimEnd		= 'AnimEndAUX';
	protected editable			var timeMax			: float;		default	timeMax			= 0.5f;	
	
	
	private editable			var flowImpulse		: float;		default	flowImpulse		= 1.0f;
	
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'SkatePrepareJump';
		}
		
		skateGlobal	= _Exploration.m_SharedDataO.m_SkateGlobalC;		
		
		
		m_InterceptStateN	= 'SkateJump';
		
		
		m_StateTypeE	= EST_Skate;
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{
	}

	
	function StateWantsToEnter() : bool
	{	
		return false;
	}
	
	
	function StateCanEnter( curStateName : name ) : bool
	{	
		return true;
	}
	
	
	private function StateEnterSpecific( prevStateName : name )	
	{						
		if( skateGlobal.CheckIfIsInFlowGapAndConsume() )
		{
			skateGlobal.ImpulseToNextSpeedLevel( flowImpulse );	
		}
	}
	
	
	function StateChangePrecheck( )	: name
	{
		if( m_ExplorationO.GetStateTimeF() > timeMax )
		{
			return 'SkateJump';
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
	}	
	
	
	
	
	

	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventName	== behAnimEnd )
		{		
			SetReadyToChangeTo( 'SkateJump' );
		}
	}
	
	
	
	
	
	
	function ReactToLoseGround() : bool
	{
		
		
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