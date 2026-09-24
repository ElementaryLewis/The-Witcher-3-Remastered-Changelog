/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskChangePriority extends IBehTreeTask
{
	var priorityWhileActive : int;
	var defaultPriority : int;
		
	function Evaluate() : int
	{
		
		if ( isActive )
		{
			return priorityWhileActive;
		}
		
		return defaultPriority;
		
	}
}

class CBTTaskChangePriorityDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskChangePriority';

	editable var priorityWhileActive : int;
	editable var defaultPriority : int;

	default priorityWhileActive = 95;
	default defaultPriority = 50;
}

class CBTTaskChangePriorityTillAnimEvent extends IBehTreeTask
{
	var highPriority : int;
	var defaultPriority : int;
	var animEventName : name;
	
	var allowBlend : bool;
		
	function Evaluate() : int
	{
		
		if ( isActive && !allowBlend )
		{
			return highPriority;
		}
		
		return defaultPriority;
		
	}
	
	function OnDeactivate()
	{
		allowBlend = false;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if (animEventName == animEventName && !allowBlend )
		{
			allowBlend = true;
			return true;
		}
		return false;
	}
}

class CBTTaskChangePriorityTillAnimEventDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskChangePriorityTillAnimEvent';

	editable var highPriority : int;
	editable var defaultPriority : int;
	editable var animEventName : name;

	default highPriority = 95;
	default defaultPriority = 50;
}
