/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskCompleteOnGameplayEvent extends IBehTreeTask
{
	editable var gameplayEvent		: name;
	editable var sucess				: bool;
	
	function OnGameplayEvent( eventName : name ) : bool
	{	
		if ( eventName == gameplayEvent )
		{
			Complete( sucess );
		}		
		return true;
	}
}

class BTTaskCompleteOnGameplayEventDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskCompleteOnGameplayEvent';

	editable var gameplayEvent		: name;
	editable var sucess				: bool;
	
	default sucess = true;
	
	hint success = "Should the task report success or fail?";
}