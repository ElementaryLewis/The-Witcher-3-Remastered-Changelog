/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskCondReactionEvent extends IBehTreeTask
{
	var reactionEventName	: name;
	var eventReceived		: bool;
	
	
	function IsAvailable() : bool
	{
		if ( eventReceived )
		{
			return true;
		}
		return false;
	}
	
	function OnDeactivate()
	{
		eventReceived = false;
	}
	
	function OnListenedGameplayEvent( _EventName : name ) : bool
	{
		eventReceived = true;
		return true;
	}
};

class CBTTaskCondReactionEventDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskCondReactionEvent';

	editable var reactionEventName	: name;
	
	function OnSpawn( taskGen : IBehTreeTask )
	{
		var task : CBTTaskCondReactionEvent;
		task = (CBTTaskCondReactionEvent) taskGen;
		if ( IsNameValid( task.reactionEventName ) )
		{
			ListenToGameplayEvent( task.reactionEventName );
		}
	}
};
