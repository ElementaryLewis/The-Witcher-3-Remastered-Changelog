/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskGameplayEventListener extends IBehTreeTask
{
	public var validFor 		: float;
	public var activeFor 		: float;
	
	private var activate  		: bool;
	private var eventTime 		: float;
	private var eventNam 		: name;
	private var activationTime 	: float;
	
	private var clearOnEvent 	: name;
	
	default activate = false;
	
	function IsAvailable() : bool
	{
		if ( activeFor > 0 && isActive )
		{
			if ( activate && activationTime + activeFor > GetLocalTime() )
			{
				return true;
			}
		}
		else if ( isActive )
		{
			return true;
		}
		else if ( validFor < 0 || eventTime + validFor >= GetLocalTime() )
		{
			return activate;
		}
		
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		eventTime = 0.f;
		activationTime = GetLocalTime();
		activate = false;
		
		return BTNS_Active;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		
		if ( eventName == clearOnEvent )
		{
			eventTime = 0.f;
			activate = false;
			return false;
		}
		
		
		if ( this.isActive )
			return false;
			
		activate = true;
		eventTime = GetLocalTime();
		eventNam = eventName;
		return true;
	}
}

class BTTaskGameplayEventListenerDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskGameplayEventListener';

	editable var gameplayEventName	: CBehTreeValCName;
	editable var validFor			: float;
	editable var activeFor 			: float;
	editable var clearOnEvent		: name;
	
	default validFor = -1.0;
	default activeFor = -1.0;
	
	hint activeFor = "how long this task will be active after receving event. (if -1 then always)";
	hint validFor = "how long event will be valid. (if -1 then always)";
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		
		if ( IsNameValid( clearOnEvent ) )
		{
			listenToGameplayEvents.PushBack( clearOnEvent );
		}
	}
	
	function OnSpawn( taskGen : IBehTreeTask )
	{
		var eventName : name;
		var task : BTTaskGameplayEventListener;
		task = (BTTaskGameplayEventListener) taskGen;
		eventName = GetValCName(gameplayEventName);
		if ( eventName )
		{
			ListenToGameplayEvent(eventName);
		}
	}
}

class BTTaskMultipleGameplayEventListener extends BTTaskGameplayEventListener
{
}

class BTTaskMultipleGameplayEventListenerDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskGameplayEventListener';
	
	editable var gameplayEventsArray	: array<name>;
	editable var validFor				: float;
	editable var activeFor 				: float;
	
	default validFor = -1.0;
	default activeFor = -1.0;
	
	hint activeFor = "how long this task will be active after receving event. (if -1 then always)";
	hint validFor = "how long event will be valid. (if -1 then always)";
	
	function InitializeEvents()
	{
		var i : int;
		
		super.InitializeEvents();
		
		for ( i = 0 ; i < gameplayEventsArray.Size() ; i+=1 )
		{
			if ( IsNameValid( gameplayEventsArray[i] ) )
			{
				listenToGameplayEvents.PushBack( gameplayEventsArray[i] );
			}
		}
	}
}

