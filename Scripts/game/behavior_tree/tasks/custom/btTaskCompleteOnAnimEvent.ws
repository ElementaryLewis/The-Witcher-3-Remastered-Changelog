/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskCompleteOnAnimEvent extends IBehTreeTask
{
	
	
	
	editable var animEvent			: name;
	editable var sucess				: bool;
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{	
		if ( animEventName == animEvent )
		{
			Complete( sucess );
		}		
		return true;
	}
}


class BTTaskCompleteOnAnimEventDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskCompleteOnAnimEvent';
	
	
	
	editable var animEvent			: name;
	editable var sucess				: bool;
	
	default sucess = true;
	
	hint success = "Should the task report success or fail?";
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		
		if ( IsNameValid( animEvent ) )
		{
			listenToAnimEvents.PushBack( animEvent );
		}
	}
}