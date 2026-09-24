/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondActorInIdleTrigger extends IBehTreeTask
{
	var inIdleTrigger : bool;

	function IsAvailable() : bool
	{
		if ( inIdleTrigger )
		{
			return true;
		}
		return false;
	}
	
	function OnListenedGameplayEvent( eventName : CName ) : bool
	{
		if ( eventName == 'InIdleTrigger' )
		{
			inIdleTrigger = true;
			return true;
		}
		if ( eventName == 'LeftIdleTrigger' )
		{
			inIdleTrigger = false;
			return true;
		}
		return false;
	}
};

class CBTCondActorInIdleTriggerDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondActorInIdleTrigger';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'InIdleTrigger' );
		listenToGameplayEvents.PushBack( 'LeftIdleTrigger' );
	}
};