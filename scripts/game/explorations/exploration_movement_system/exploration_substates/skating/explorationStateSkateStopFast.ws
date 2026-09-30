/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CExplorationStateSkateStopFast extends CExplorationStateSkatingDrift
{		
	
	private editable			var inputRangeToEnter		: float;		default inputRangeToEnter	= 15.0f;
	private editable			var duration				: float;		default duration			= 0.75f;
	private editable inlined	var speedStopCurve			: CCurve;
	
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'SkateStopFast';
		}
		
		skateGlobal	= _Exploration.m_SharedDataO.m_SkateGlobalC;
		
		
		m_StateTypeE	= EST_Skate;
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{		
		AddStateToTheDefaultChangeList( 'SkateDashAttack' );
		AddStateToTheDefaultChangeList( 'SkateDash' );
		AddStateToTheDefaultChangeList( 'SkateJump' );
	}

	
	function StateWantsToEnter() : bool
	{	
		var inputHeadingAbs	: float;
		
		if( skateGlobal.ShouldStop( true ) )
		{
			return false;
		}
		
		inputHeadingAbs	= m_ExplorationO.m_InputO.GetHeadingOnPadF();
		inputHeadingAbs	= AngleDistance( 180.0f, inputHeadingAbs );
		inputHeadingAbs	= AbsF( inputHeadingAbs );
		
		if( !m_ExplorationO.m_InputO.IsModuleConsiderable() || inputHeadingAbs < inputRangeToEnter )
		{
			return m_ExplorationO.m_InputO.IsDriftPressed();
		}
		
		return false;
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{		
		var newVelocity	: Vector;
		var coef		: float;
		
		
		
		skateGlobal.UpdateRandomAttack();
		
		
		if( m_ExplorationO.GetStateTimeF() >= duration )
		{
			m_ExplorationO.m_MoverO.SetVelocity( Vector( 0,0,0 ) );
			SetReadyToChangeTo( 'SkateIdle' );
		}
		else
		{
			newVelocity	= m_ExplorationO.m_MoverO.GetMovementVelocity();
			coef	= m_ExplorationO.GetStateTimeF() / duration;
			if( speedStopCurve )
			{
				coef	= speedStopCurve.GetValue( coef );
			}
			
			newVelocity	= LerpV( newVelocity, Vector( 0,0,0 ), coef );
			
			m_ExplorationO.m_MoverO.UpdateMovementLinear( newVelocity, _Dt );
		}
	}
}