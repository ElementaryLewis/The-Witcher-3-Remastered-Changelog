/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskManageSwimming extends IBehTreeTask
{
	public var onActivate 			: bool;
	public var isSwimmingValue		: bool;
	
	private var m_isInWater			: bool;
	private var m_isWaitingForWater	: bool;
	
	
	
	function Initialize()
	{
		var l_npc : CNewNPC = GetNPC();
		var l_pos : Vector;
		var l_waterLevel 		: float;
		var l_submersionLevel 	: float;
		
		l_pos 				= l_npc.GetWorldPosition();
		
		l_waterLevel 		= theGame.GetWorld().GetWaterLevel ( l_pos, true );		
		l_submersionLevel 	= l_waterLevel - l_pos.Z;
		
		if( l_submersionLevel > -1 )
		{
			m_isInWater = true;
		}
	}
	
	function OnActivate() : EBTNodeStatus
	{
		if ( onActivate )
		{			
			if( !m_isInWater && isSwimmingValue == true )
			{
				m_isWaitingForWater = true;
			}
			else
			{
				Execute( isSwimmingValue );
			}
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( !onActivate )
		{
			Execute( isSwimmingValue );
		}
		
		m_isWaitingForWater = false;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		switch( eventName )
		{
			case 'EnterWater':
				m_isInWater = true;
				if( m_isWaitingForWater )
				{
					Execute( true );
				}				
			break;
			case 'LeaveWater':
				m_isInWater = false;
			break;
		}
		return true;
	}
	
	private final function Execute( _IsSwimming : bool )
	{
		var owner : CActor = GetActor();
		
		if( !m_isInWater && _IsSwimming == true ) 
			return;
		
		if( _IsSwimming == true )
		{
			((CMovingPhysicalAgentComponent)owner.GetMovingAgentComponent()).SetGravity( false );
			((CMovingPhysicalAgentComponent)owner.GetMovingAgentComponent()).SetAnimatedMovement( false );	
			((CMovingPhysicalAgentComponent)owner.GetMovingAgentComponent()).SnapToNavigableSpace( false );
		}
		((CMovingPhysicalAgentComponent)owner.GetMovingAgentComponent()).SetSwimming( _IsSwimming );
		((CMovingPhysicalAgentComponent)owner.GetMovingAgentComponent()).SetDiving( _IsSwimming );
		owner.SetIsSwimming( _IsSwimming );
		owner.EnablePhysicalMovement( _IsSwimming );
	}
};

class CBTTaskManageSwimmingDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskManageSwimming';

	editable var onActivate 		: bool;
	editable var isSwimmingValue	: bool;
	
	default onActivate 		= true;
	default isSwimmingValue = true;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'EnterWater' );
		listenToGameplayEvents.PushBack( 'LeaveWater' );
	}
};
