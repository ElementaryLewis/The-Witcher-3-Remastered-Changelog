/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EPushSide
{
	EPIS_Front	,
	EPIS_Left	,
	EPIS_Back	,
	EPIS_Right	,
}



class CExplorationStatePushed extends CExplorationStateAbstract
{
	public	editable	var	enabled				: bool;			default	enabled			= true;
	
	private 			var	pushDirection		: Vector;
	private 			var	pushDirectionOther	: Vector;
	private 			var	pushSide			: EPushSide;
	private 			var	pushAngle			: float;
	private editable	var	extraTurnAngle		: float;		default	extraTurnAngle	=	45.0f;
	
	
	private editable	var	behCanEnd			: name;			default	behCanEnd		= 'CanEnd';
	private editable	var	behSide				: name;			default	behSide			= 'PushSide';
	
	private editable	var	safetyEndTimeMax	: float;		default	safetyEndTimeMax= 1.64f;
	private				var	safetyEndTimeCur	: float;
	private editable	var	recheckTimeMin		: float;		default	recheckTimeMin	= 0.58f;
	private 			var	recheckTimeCur		: float;
	
	
	private				var ticket 				: SMovementAdjustmentRequestTicket;
	private				var	rotatedToCollider	: bool;
	
	private				var movedLeft			: bool;

	
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'Pushed';
		}
		
		m_StateTypeE	= EST_Idle;
	}

	
	private function AddDefaultStateChangesSpecific()
	{
		AddStateToTheDefaultChangeList('Climb');
		AddStateToTheDefaultChangeList('Interaction');
		AddStateToTheDefaultChangeList('Jump');
		AddStateToTheDefaultChangeList('CombatExploration');
	}
	
	
	function StateWantsToEnter() : bool
	{
		var strength		: float;
		var direction		: Vector; 
		var otherSpeed		: float;
		var otherPushDir	: Vector;
		
		
		if( thePlayer.GetIsWalking() )
		{
			return false;
		}
		
		m_ExplorationO.m_CollisionManagerO.GetPushData( strength, direction, otherSpeed, otherPushDir );
		if( strength >= 0.0f && otherSpeed > 0.0f )
		{
			pushDirection		= direction;
			pushDirectionOther	= otherPushDir;
			
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
		var angle		: float;
		
		
		
		angle		= ComputeAngleToMove();		
		
		
		pushSide	= ComputeSide( angle );
		
		
		StartStep( angle, pushSide );
	}
	
	
	private function AddAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behCanEnd, 'OnAnimEvent_SubstateManager' );
	}
	
	
	function StateChangePrecheck( )	: name
	{		
		if( safetyEndTimeCur <= 0.0f )
		{
			return 'Idle';
		}	
		else if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			return 'Idle';
		}
		
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{		
		var angle		: float;
		var angleDif	: float;
		var side		: EPushSide;
		
		
		recheckTimeCur		-= _Dt;
		safetyEndTimeCur	-= _Dt;
		
		if( !rotatedToCollider && recheckTimeCur < 0.0f )
		{				
			RotateToCollider();
		}
		
		
		if( StateWantsToEnter() )
		{	
			
			if( recheckTimeCur <= 0.0f )
			{
				
				angle	= ComputeAngleToMove();	
				
				
				side	= ComputeSide( angle );
				if( side != pushSide )
				{
					LogExplorationPushed( " Interrupted by another step" );
					
					
					StartStep( angle, side );
				}
			}
			
		}
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{		
		var movementAdjustor	: CMovementAdjustor;
		
		movementAdjustor.CancelByName( 'Pushed_from_idle' );
		movementAdjustor.CancelByName( 'Pushed_from_idle_reorient' );
	}
	
	
	private function RemoveAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behCanEnd );
	}
	
	
	function ReactToLoseGround() : bool
	{
		SetReadyToChangeTo( 'StartFalling' );
		return true;
	}
	
	function ReactToBeingHit( optional damageAction : W3DamageAction ) : bool
	{
		return true;
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventName == behCanEnd )
		{
			SetReadyToChangeTo( 'Idle' );
		}
	}
	
	
	function CanInteract() :bool
	{		
		return false;
	}
	
	
	private function LogExplorationPushed( text : string )
	{
		LogChannel( 'ExplorationState'		, "Pushed: " + text );
		LogChannel( 'ExplorationStatePushed', text );
	}
	
	
	private function StartStep( angle : float, side : EPushSide )
	{	
		LogExplorationPushed( " Using other movement direction angle " + angle );	
		LogExplorationPushed( " Resulted in side " + side );
		
		
		pushSide	= side;
		pushAngle	= angle;
		
		
		PrepareRotation( angle );
		
		
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behSide, ( float ) ( int ) side ); 
		
		
		recheckTimeCur		= recheckTimeMin;
		safetyEndTimeCur	= safetyEndTimeMax;
		rotatedToCollider	= false;
	}
	
	
	private function ComputeAngleToMove( ) : float
	{
		var angle			: float;
		var angleother		: float;	
		
		angleother	= VecHeading( pushDirectionOther );
		
		
		movedLeft	= AngleDistance( angleother, VecHeading( pushDirection ) ) >= 0.0f;
		
		
		if( movedLeft )
		{
			angle	= AngleNormalize180( angleother - extraTurnAngle ); 
		}
		else
		{
			angle	= AngleNormalize180( angleother + extraTurnAngle );
		}
		
		
		angle	= AngleDistance( m_ExplorationO.m_OwnerE.GetHeading(), angle );
		angle	= AngleNormalize180( angle );
		
		return angle;
	}
	
	
	private function ComputeSide( angle : float ) : EPushSide
	{
		var side	: EPushSide;
		
		
		if( AbsF( angle ) < 45.0f )
		{
			side	= EPIS_Front;
		}
		else if( AbsF( angle ) > 135.0f )
		{
			side	= EPIS_Back;
		}
		else if( angle > 0.0f )
		{
			side	= EPIS_Right;
		}
		else
		{
			side	= EPIS_Left;
		}
		
		return side;
	}

	
	private function PrepareRotation( angle : float )
	{
		var movementAdjustor	: CMovementAdjustor;
		var rotateAngle			: float;
		
		
		
		switch( pushSide )
		{
			case EPIS_Front:
				rotateAngle	= angle;
				break;
			case EPIS_Back:
				rotateAngle	= AngleNormalize180( angle - 180.0f );
				break;
			case EPIS_Left:
				rotateAngle	= AngleNormalize180( angle + 90.0f );
				break;
			case EPIS_Right:
				rotateAngle	= AngleNormalize180( angle - 90.0f );
				break;
			default :
				return;
		}
		
		movementAdjustor	= m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		ticket				= movementAdjustor.CreateNewRequest( 'Pushed_from_idle' );
		
		movementAdjustor.AdjustmentDuration( ticket, 0.15f );
		movementAdjustor.RotateBy( ticket, rotateAngle );
		
		LogExplorationPushed( "AngleAdjusted by: " + rotateAngle );
	}

	
	private function RotateToCollider()
	{
		var rotateAngle			: float;
		var movementAdjustor	: CMovementAdjustor;
		
		
		rotateAngle				= VecHeading( -pushDirection );
		
		if( AbsF( AngleDistance( rotateAngle, m_ExplorationO.m_OwnerE.GetHeading() ) ) < 85.0f )
		{
			movementAdjustor	= m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
			ticket				= movementAdjustor.CreateNewRequest( 'Pushed_from_idle_reorient' );
			
			movementAdjustor.AdjustmentDuration( ticket, 0.27f );
			movementAdjustor.RotateTo( ticket, rotateAngle );
		}
		
		rotatedToCollider	= true;
	}
	
	
	private function ModifyRotation( angle : float )
	{
		var rotateAngle			: float;
		var movementAdjustor	: CMovementAdjustor;
		
		
		switch( pushSide )
		{
			case EPIS_Front:
				rotateAngle	= angle;
				break;
			case EPIS_Back:
				rotateAngle	= AngleNormalize180( angle - 180.0f );
				break;
			case EPIS_Left:
				rotateAngle	= AngleNormalize180( angle + 90.0f );
				break;
			case EPIS_Right:
				rotateAngle	= AngleNormalize180( angle - 90.0f );
				break;
			default :
				return;
		}
		
		movementAdjustor	= m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		
		movementAdjustor.AdjustmentDuration( ticket, 0.2f );
		movementAdjustor.RotateBy( ticket, angle );
	}
}