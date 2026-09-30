/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskEnterDrinkingMinigame extends IBehTreeTask
{
	var Event : name;
	var OffEvent : name;
	var available : bool;
	default available = false;
	
	function IsAvailable() : bool
	{
		if ( isActive )
		{
			return true;
		}
		
		if (available)
		{
			return true;
		}
		
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		GetNPC().ActionCancelAll();
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		available = false;
	}
			
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == Event )
		{
			available = true;
			return true;
		}
		
		if ( eventName == OffEvent )
		{
			available = false;
			Complete( true );
			return true;
		}
		
		return false;
	}
}

class CBTTaskEnterDrinkingMinigameDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskEnterDrinkingMinigame';

	editable var Event : name;
	editable var OffEvent : name;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		
		if ( IsNameValid( Event ) )
		{
			listenToGameplayEvents.PushBack( Event );
		}
		if ( IsNameValid( OffEvent ) )
		{
			listenToGameplayEvents.PushBack( OffEvent );
		}
	}
}

