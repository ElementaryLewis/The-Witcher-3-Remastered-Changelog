/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskRaiseEventOnDeactivate extends IBehTreeTask
{
	public var eventName : name;
	
	function OnDeactivate()
	{	
		GetActor().RaiseEvent(eventName);
	}
}

class BTTaskRaiseEventOnDeactivateDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskRaiseEventOnDeactivate';

	editable var eventName : CBehTreeValCName;
}
