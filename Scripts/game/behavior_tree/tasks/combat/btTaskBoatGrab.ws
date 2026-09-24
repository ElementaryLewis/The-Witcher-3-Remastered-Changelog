/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskBoatGrab extends IBehTreeTask
{
	
	
	
	private var m_Collided		 		: bool;
	private var m_TargetBoat 			: CEntity;	
	private var m_ClosestSlot			: name;
	
	
	
	function OnActivate() : EBTNodeStatus
	{
		m_TargetBoat = NULL;
		return BTNS_Active;
	}
	
	
	function OnGameplayEvent( _EventName : name ) : bool
	{	
		var l_slotFound			: bool;
		var l_destructionComp 	: CBoatDestructionComponent;
		var l_boatComponent 	: CBoatComponent;
		var l_targetLocation	: Vector;
		var l_targetHeading		: float;
		var l_boatHasDrowned	: bool;
		
		if ( !m_Collided && _EventName == 'CollisionWithBoat'  )
		{			
			m_Collided 			= true;
			l_destructionComp 	= (CBoatDestructionComponent) GetBoat().GetComponentByClassName('CBoatDestructionComponent');
			
			l_slotFound 		= l_destructionComp.GetClosestFreeGrabSlotInfo( GetNPC().GetWorldPosition(), GetNPC().GetHeading(), m_ClosestSlot, l_targetLocation, l_targetHeading );
			
			l_boatComponent 	= (CBoatComponent) GetBoat().GetComponentByClassName('CBoatComponent');
			
			l_boatHasDrowned = l_boatComponent.GetBoatEntity().HasDrowned();
			
			if( !l_slotFound || l_boatHasDrowned )
			{ 
				m_Collided 		= false;
				m_ClosestSlot =	'';
				Complete ( false );
				return false;
			}
			
			GetNPC().SignalGameplayEventParamCName( 'LockSlot', m_ClosestSlot );
			GetNPC().SignalGameplayEvent( 'StartGrab' );
			
			l_destructionComp.LockGrabSlot( m_ClosestSlot );
			l_destructionComp.AttachSiren( GetNPC() );
		}
		
		return false;
	}
	
	
	function OnDeactivate()
	{
		var l_destructionComp 	: CBoatDestructionComponent;
		
		m_Collided = false;		
		if( GetNPC().GetBehaviorVariable( 'IsOnBoat' ) == 0 && IsNameValid( m_ClosestSlot ) )
		{
			l_destructionComp 	= (CBoatDestructionComponent) GetBoat().GetComponentByClassName('CBoatDestructionComponent');
			l_destructionComp.FreeGrabSlot( m_ClosestSlot );
			l_destructionComp.DetachSiren( GetNPC() );
		}
		m_ClosestSlot =	'';
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var l_npc				: CNewNPC;
		var l_res 				: bool;
		var l_movementAdjustor 	: CMovementAdjustor;
		var l_ticket 			: SMovementAdjustmentRequestTicket;
		var l_targetLocation	: Vector;
		var l_targetHeading		: float;
		var l_slotMatrix		: Matrix;		
		
		if ( animEventName == 'GrabBoat' && animEventType == AET_DurationStart )
		{	
			l_npc = GetNPC();
			
			((CMovingPhysicalAgentComponent)l_npc.GetMovingAgentComponent()).SetDiving( false );
			((CMovingPhysicalAgentComponent)l_npc.GetMovingAgentComponent()).SetSwimming( false );
			l_npc.SetIsSwimming(false);
			
			
			GetBoat().CalcEntitySlotMatrix( m_ClosestSlot, l_slotMatrix );				
			l_npc.GetMovingAgentComponent().SetAdditionalOffsetToConsumePointWS( l_slotMatrix, 0.5f );				
			l_npc.CreateAttachment( GetBoat(), m_ClosestSlot );			
		}
		
		return l_res;
	}
	
	
	private final function GetBoat() : CEntity
	{
		if( !m_TargetBoat )
		{
			m_TargetBoat = thePlayer.GetUsedVehicle();
		}
		
		return m_TargetBoat;
	}
}


class CBTTaskBoatGrabDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskBoatGrab';
	
	
	
}