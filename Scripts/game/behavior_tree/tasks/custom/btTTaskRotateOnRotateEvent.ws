/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskRotateOnRotateEvent extends IBehTreeTask
{
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'RotateEventStart')
		{
			GetNPC().SetRotationAdjustmentRotateTo( GetActionTarget() );
			return true;
		}
		if ( eventName == 'RotateAwayEventStart')
		{
			GetNPC().SetRotationAdjustmentRotateTo( GetActionTarget(), 180.0 );
			return true;
		}
		
		return false;
	}
}

class BTTaskRotateOnRotateEventDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskRotateOnRotateEvent';
}