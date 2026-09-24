/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CExplorationStateSwim extends CExplorationStateAbstract
{	
	private editable	var	solveCollisionsForward	: bool;		default	solveCollisionsForward	= false;
	private editable	var	smoothPenetration		: bool;		default	smoothPenetration		= true;
	private editable	var collisionUpOffset		: float;	default	collisionUpOffset		= 0.8f;
	private editable	var collisionDistance		: float;	default	collisionDistance		= 0.45f; 
	private editable	var collisionRadius			: float;	default	collisionRadius			= 0.4f;
	private editable	var	collisionPenetrationMax	: float;	default	collisionPenetrationMax	= 1.5f;
	private editable	var	collisionPenetration	: Vector;
	private editable	var	smoothSpeed				: float;	default	smoothSpeed				= 10.0f;
	private				var	zeroVec					: Vector;
	
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{		
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'Swim';
		}
		
		
		
		
		m_StateTypeE			= EST_Unchanged;
		m_InputContextE			= EGCI_Swimming; 
		
		zeroVec					= Vector( 0.0f, 0.0f, 0.0f );
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{
		AddStateToTheDefaultChangeList('Interaction');
		
	}

	
	function StateWantsToEnter() : bool
	{
		if ( m_ExplorationO.GetSuperStateName() == 'Swimming' )
			return true;
		return false;
	}
	
	
	function StateCanEnter( curStateName : name ) : bool
	{		
		return true;
	}
	
	
	private function StateEnterSpecific( prevStateName : name )	
	{
		
		collisionPenetration	= zeroVec;		
		
		
		thePlayer.AbortSign();	
	}
	
	
	function StateChangePrecheck( )	: name
	{	
		
		
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{
		
		if( solveCollisionsForward )
		{	
			UpdateCollisionSolving( _Dt );
		}
		
		
		if( m_ExplorationO.m_SharedDataO.m_JumpSwimRotationF != 0.0f )
		{
			m_ExplorationO.m_SharedDataO.m_JumpSwimRotationF	= MinF( 0.0f, m_ExplorationO.m_SharedDataO.m_JumpSwimRotationF + _Dt * 150.0f );
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( 'Slide_Inclination', m_ExplorationO.m_SharedDataO.m_JumpSwimRotationF );
		}
		
		
		
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{
		return;
	}	
	
	
	private function UpdateCollisionSolving( _Dt : float )
	{
		var distance	: float;
		var normal		: Vector;
		
		
		
		if( !GetPenetrationDistanceAndNormal( distance, normal ) )
		{
			collisionPenetration	= zeroVec;
			return;
		}
		
		
		if( smoothPenetration )
		{
			collisionPenetration	= LerpV( collisionPenetration, distance * normal, smoothSpeed * _Dt );
		}
		
		
		m_ExplorationO.m_MoverO.Translate( collisionPenetration ); 
	}
		
	
	private function GetPenetrationDistanceAndNormal( out penetration : float, out normal : Vector ) : bool
	{
		var world 			: CWorld;
		var posCurrent		: Vector;
		var posTarget		: Vector;
		var	collisionPoint	: Vector;
		var penetrationMax	: float;
		var	vectorAux		: Vector;
		
		
		
		world	= theGame.GetWorld();
		if( !world )
		{
			return false;
		}
		
		
		posCurrent		= m_ExplorationO.m_OwnerE.GetWorldPosition() + m_ExplorationO.m_OwnerE.GetWorldUp() * collisionUpOffset;
		
		vectorAux		= m_ExplorationO.m_OwnerE.GetBoneWorldPositionByIndex( thePlayer.GetHeadBoneIndex() ) - posCurrent;
		penetrationMax	= VecDot( m_ExplorationO.m_OwnerE.GetWorldForward(), vectorAux  );
		
		
			penetrationMax	+= collisionDistance;
		
		
		penetrationMax	= MinF( penetrationMax, collisionPenetrationMax );
		posTarget		= posCurrent + m_ExplorationO.m_OwnerE.GetWorldUp() * collisionUpOffset;
		posTarget		+=  m_ExplorationO.m_OwnerE.GetWorldForward() * penetrationMax;
		
		
		if( world.SweepTest( posCurrent, posTarget, collisionRadius, collisionPoint, normal ) )
		{
			penetration	= VecDot( m_ExplorationO.m_OwnerE.GetWorldForward(), collisionPoint - posCurrent  );
			penetration	= ClampF( penetrationMax - penetration, 0.0f, penetrationMax );
			
			return true;
		}
		
		return false;
	}
	
	
	function ReactToLoseGround() : bool
	{
		return true;
	}	
	
	
	function ReactToBeingHit( optional damageAction : W3DamageAction ) : bool
	{		
		return true;
	}
	
	
	function CanInteract( ) : bool
	{
		return true;
	}
}
