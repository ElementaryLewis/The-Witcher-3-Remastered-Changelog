/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskCheckDelaySinceLastMeal extends IBehTreeTask
{
	
	
	
	public var value 	: float;
	public var operator : EOperator;
	
	
	function IsAvailable() : bool
	{
		var lastMeal	: float = GetNPC().lastMealTime;
		var oppNo 		: float = GetLocalTime() - lastMeal;
		
		if ( lastMeal < 0 ) return true;
		
		switch ( operator )
		{
			case EO_Equal:			return oppNo == value;
			case EO_NotEqual:		return oppNo != value;
			case EO_Less:			return oppNo < value;
			case EO_LessEqual:		return oppNo <= value;
			case EO_Greater:		return oppNo > value;
			case EO_GreaterEqual:	return oppNo >= value;
			default : 				return false;
		}
	}
}


class BTTaskCheckDelaySinceLastMealDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskCheckDelaySinceLastMeal';
	
	
	private editable var value : float;
	private editable var operator : EOperator;
}









class BTTaskResetLastMealDelay extends IBehTreeTask
{	
	
	
	private function OnDeactivate()
	{
		var l_npc : CNewNPC = GetNPC();
		l_npc.lastMealTime = GetLocalTime();
	}
}


class BTTaskResetLastMealDelayDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskResetLastMealDelay';
}