/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskManageGravity extends IBehTreeTask
{
	var manageGravity 		: EManageGravity;
	var onActivate			: bool;
	var onDeactivate		: bool;
	var onEvent				: bool;
	var setCustomMovement	: bool;
	default manageGravity = EMG_DisableGravity;
	

	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		if ( onActivate )	Execute();
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		
		if ( onDeactivate )	Execute();
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if( !onEvent)
		{
			return false;
		}
		
		if ( animEventName == 'EnableGravity' )
		{
			SwitchGravity( true );
			return true;
		}
		else if ( animEventName == 'DisableGravity' )
		{
			SwitchGravity( false );
			return true;
		}
		
		return false;
	}
	
	private final function Execute() 
	{
		if ( manageGravity == EMG_DisableGravity )
		{
			SwitchGravity( false );
		}
		else if ( manageGravity == EMG_EnableGravity )
		{
			SwitchGravity( true );
		}
		else
		{
			if ( GetNPC().GetDistanceFromGround( 2 ) > 1.5f )
			{
				SwitchGravity( true );
			}
			else
			{
				SwitchGravity( false );
			}
		}
	
	}
	
	private final function SwitchGravity( on : bool ) 
	{
		var npc : CNewNPC = GetNPC();
		if( on )
		{
			npc.EnablePhysicalMovement( false );
			if ( setCustomMovement )
			{
				((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SetAnimatedMovement( false );		
			}
			((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SnapToNavigableSpace( true );
			((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SetGravity( true );
		}
		else
		{		
			npc.EnablePhysicalMovement( true );
			if ( setCustomMovement )
			{
				((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SetAnimatedMovement( true );
			}
			((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SnapToNavigableSpace( false );
			((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SetGravity( false );
		}
	}
};

class CBTTaskManageGravityDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskManageGravity';

	editable var manageGravity 		: EManageGravity;
	editable var onActivate			: bool;
	editable var onDeactivate		: bool;
	editable var onEvent			: bool;
	editable var setCustomMovement	: bool;

	default manageGravity 		= EMG_DisableGravity;
	default setCustomMovement 	= true;
	default onActivate 			= false;
	default onDeactivate 		= true;
	
	hint onEvent = "On 'EnableGravity' or 'DisableGravity' events";
};
