/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskRotateNPCbyMovementAdjustor extends IBehTreeTask
{
	var npc						: CNewNPC;
	var target 					: CActor;
	var active 	 				: bool; 
	var onAnimEvent 			: bool; 
	var eventName 				: name; 
	var finishTaskOnAllowBlend	: bool;
	
	
	function IsAvailable() : bool
	{
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		npc = GetNPC();
		target = GetCombatTarget();
		if( !onAnimEvent )
		{
			active = true;
		}
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		while( active )
		{
			RotateNPC();
			SleepOneFrame();
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		active = false;
	}
	
	function RotateNPC()
	{
		var ticket 				: SMovementAdjustmentRequestTicket;
		var movementAdjustor	: CMovementAdjustor;
			
		movementAdjustor = GetNPC().GetMovingAgentComponent().GetMovementAdjustor();
		movementAdjustor.CancelByName( 'RotateNPC' );
		ticket = movementAdjustor.CreateNewRequest( 'RotateNPC' );
		movementAdjustor.RotateTowards( ticket, target );
	}
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var ticket 				: SMovementAdjustmentRequestTicket;
		var movementAdjustor	: CMovementAdjustor;
		
		if( animEventName == eventName && animEventType == AET_DurationStart )
		{
			movementAdjustor = GetNPC().GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelByName( 'RotateNPC' );
			ticket = movementAdjustor.CreateNewRequest( 'RotateNPC' );
			movementAdjustor.BindToEventAnimInfo( ticket, animInfo );
			movementAdjustor.RotateTowards( ticket, target );
			return true;
		}
		else if( animEventName == 'AllowBlend' && animEventType == AET_DurationStart )
		{
			Complete(true);
		}
		return false;
	}
}

class CBTTaskRotateNPCbyMovementAdjustorDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskRotateNPCbyMovementAdjustor';
		
	var npc								: CNewNPC;
	var target							: CActor;
	var active							: bool;
	editable var onAnimEvent 			: bool; 
	editable var eventName 				: name; 
	editable var finishTaskOnAllowBlend	: bool;
}