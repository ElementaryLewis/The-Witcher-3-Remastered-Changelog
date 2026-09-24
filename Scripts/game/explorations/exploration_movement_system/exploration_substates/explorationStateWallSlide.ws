/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CExplorationStateWallSlide extends CExplorationStateSlide
{	
	private	var	wallSlideGenericCoef	: float;	default	wallSlideGenericCoef	= 0.7f;
	
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'WallSlide';
		}
		
		
		updateMaterials				= false;
		useWideTerrainCheckToEnter	= false;
		
		
		m_ExplorationO.m_OwnerMAC.SetSliding( false );
		
		m_StateTypeE	= EST_Idle;
		
		SetCanSave( false );
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{
		
	}
	
	
	function StateWantsToEnter() : bool
	{	
		var coef	: float;
		
		
		
		if( !m_ExplorationO.IsOnGround() )
		{
			return false;
		}
		
		
		coef	= m_ExplorationO.m_MoverO.GetRawSlideCoef( true );
		
		
		if( coef > wallSlideGenericCoef )
		{ 
			return true;
		}
		
		return false;
	}	
	
	
	function StateCanEnter( curStateName : name ) : bool
	{	
		return false;
	}
	
	
	function StateChangePrecheck( )	: name
	{
		if( !StateWantsToEnter() )
		{
			
			if( m_ExplorationO.StateWantsAndCanEnter( 'Slide' ) )
			{
				return 'Slide';
			}
			
			if( !m_ExplorationO.IsOnGround() )
			{
				if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'StartFalling' ) )
				{
					return 'StartFalling';
				}
			}
			
			else if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'Land' ) )
			{
				return 'Land';
			}
		}
		
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{
		super.StateUpdateSpecific( _Dt );
		
		
		m_ExplorationO.m_SharedDataO.UpdateFallHeight();
	}
	
	
	protected  function CheckLandingDamage()
	{
		
		return;
	}
}