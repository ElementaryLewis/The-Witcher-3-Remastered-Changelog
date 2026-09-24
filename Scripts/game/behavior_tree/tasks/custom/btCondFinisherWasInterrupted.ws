/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondFinisherWasInterrupted extends IBehTreeTask
{
	
	
	function IsAvailable() : bool
	{
		var l_availability	: bool;
		l_availability = GetNPC().WasFinisherAnimInterrupted();
		return l_availability;
	}
	
	
	function OnDeactivate()
	{
		GetNPC().ResetFinisherAnimInterruptionState();
	}
}


class BTCondFinisherWasInterruptedDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondFinisherWasInterrupted';
};