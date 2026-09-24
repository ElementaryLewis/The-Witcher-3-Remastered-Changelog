/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskChangeInteractionPriority extends IBehTreeTask
{
	private var previousInteractionPriority : EInteractionPriority;
	
	private var priorityChanged : bool;
	
	function OnActivate() : EBTNodeStatus
	{
		var owner : CActor = GetActor();
		
		if ( GetActionTarget() == thePlayer )
		{
			previousInteractionPriority = owner.GetInteractionPriority();
			
			owner.SetOriginalInteractionPriority(IP_Prio_3);
			owner.RestoreOriginalInteractionPriority();
			priorityChanged = true;
		}
		else
		{
			priorityChanged = false;
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var owner : CActor = GetActor();
		
		if ( priorityChanged )
		{
			owner.SetOriginalInteractionPriority(previousInteractionPriority);
			owner.RestoreOriginalInteractionPriority();
		}
	}
}

class CBTTaskChangeInteractionPriorityDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskChangeInteractionPriority';
}
