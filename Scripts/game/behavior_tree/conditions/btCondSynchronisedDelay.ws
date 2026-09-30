/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondSynchronisedDelay extends IBehTreeTask
{
	
	
	
	public var syncEventName				: name;
	public var delay 						: float;
	public var skipInvoker					: bool;
	public var triggerEventOnActivate		: bool;
	public var triggerEventOnDeactivate		: bool;
	public var triggerEventOnSuccess		: bool;
	public var triggerEventOnFailed			: bool;
	public var isAvailableUntilFirstEvent	: bool;
	public var personalSync					: bool;
	
	
	private saved var m_eventReceivedTime	: float;
	
	
	
	function IsAvailable() : bool
	{
		if( isAvailableUntilFirstEvent && m_eventReceivedTime == 0 )
		{
			return true;
		}
		
		if( m_eventReceivedTime + delay < GetLocalTime() )
		{
			return true;
		}
		
		return false;
	}
	
	
	function OnActivate() : EBTNodeStatus
	{
		if( triggerEventOnActivate )
			TriggerEvent();	
		
		return BTNS_Active;
	}
	
	
	function OnDeactivate()
	{		
		if( triggerEventOnDeactivate )
			TriggerEvent();
	}
	
	
	function OnCompletion( _Success : bool )
	{
		if( _Success && triggerEventOnSuccess )
		{
			TriggerEvent();
		}
		if ( !_Success && triggerEventOnFailed )
		{
			TriggerEvent();
		}
	}
	
	
	
	function OnListenedGameplayEvent( _EventName : name ) : bool
	{
		var npc : CNewNPC = GetNPC();
		m_eventReceivedTime = GetLocalTime();
		isAvailableUntilFirstEvent = false;
		return false;
	}
	
	
	
	function TriggerEvent()
	{
		var l_actor : CActor = GetActor();
		if( personalSync )
		{
			l_actor.SignalGameplayEvent( syncEventName );
		}
		else if ( IsNameValid( syncEventName ) )
		{
			theGame.GetBehTreeReactionManager().CreateReactionEvent( l_actor, syncEventName, 1, 100, -1, -1, skipInvoker );
		}
	}
}


class BTCondSynchronisedDelayDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondSynchronisedDelay';
	
	
	editable var delay 						: float;
	editable var syncEventName 				: CBehTreeValCName;
	editable var skipInvoker				: bool;
	editable var triggerEventOnActivate		: bool;
	editable var triggerEventOnDeactivate	: bool;
	editable var triggerEventOnSuccess		: bool;
	editable var triggerEventOnFailed		: bool;	
	editable var isAvailableUntilFirstEvent	: bool;
	editable var personalSync				: bool;
	
	hint syncEventName 		= "Event used to sync the delay";
	hint delay 				= "Delay after syncEvent was trigger";
	hint skipInvoker		= "Signal invoker doesn't receive the event";
	hint personalSync		= "Only me will receive the synchronisation event";
	
	
	
	function OnSpawn( taskGen : IBehTreeTask )
	{
		var task : BTCondSynchronisedDelay;
		task = (BTCondSynchronisedDelay) taskGen;
		if ( IsNameValid( task.syncEventName ) )
		{
			ListenToGameplayEvent( task.syncEventName );
		}
	}
}
