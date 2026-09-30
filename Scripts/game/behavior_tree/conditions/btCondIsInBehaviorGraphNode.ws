/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondIsInBehaviorGraphNode extends IBehTreeTask
{
	
	
	
	public var activationScriptEvent 			: name;
	public var deactivateScriptEvent 			: name;
	
	private var m_availability					: bool;
	
	
	function Initialize()
	{
		GetNPC().ActivateSignalBehaviorGraphNotification( activationScriptEvent );		
		GetNPC().ActivateSignalBehaviorGraphNotification( deactivateScriptEvent );		
	}
	
	
	function IsAvailable() : bool
	{
		return m_availability;
	}
	
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if( eventName == activationScriptEvent )
		{
			m_availability = true;
		}
		if( eventName == deactivateScriptEvent )
		{
			m_availability = false;
		}
		
		return true;
	}	
}


class BTCondIsInBehaviorGraphNodeDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIsInBehaviorGraphNode';
	
	
	
	editable var activationScriptEvent 			: name;
	editable var deactivateScriptEvent 			: name;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		if ( IsNameValid( activationScriptEvent ) )
		{
			listenToGameplayEvents.PushBack( activationScriptEvent );
		}
		if ( IsNameValid( deactivateScriptEvent ) )
		{
			listenToGameplayEvents.PushBack( deactivateScriptEvent );
		}
	}
}
