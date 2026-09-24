/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class CBTTaskBaseDuration extends IBehTreeTask
{
	public var duration : float;
	public var chance : int;
	public var endWithFailure : bool;

	latent function Main() : EBTNodeStatus
	{
		if( duration < 0 )
			return BTNS_Active;
		do
		{
			Sleep( duration );
		} while( !Roll() ) 
		
		if( endWithFailure )
		{
			return BTNS_Failed;
		}
		
		return BTNS_Completed;
	}
	
	function Roll() : bool
	{
		if( RandRange( 100 ) < chance )
		{
			return true;
		}
		
		return false;
	}
}





class CBTTaskDuration extends CBTTaskBaseDuration
{
}

class CBTTaskDurationDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskDuration';

	editable var duration : float;
	editable var chance : int;
	editable var endWithFailure : bool;

	default duration = 10.0;
	default chance = 100;
	default endWithFailure = false;
}





class CBTTaskXMLBasedDuration extends CBTTaskBaseDuration
{
	public var xmlStatName : name;
	
	function OnActivate() : EBTNodeStatus
	{
		GetStats();
		return BTNS_Active;
	}
	
	private function GetStats()
	{
		duration = CalculateAttributeValue(GetActor().GetAttributeValue(xmlStatName));
	}
}

class CBTTaskXMLBasedDurationDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskXMLBasedDuration';

	editable var xmlStatName : name;
	editable var chance : int;
	editable var endWithFailure : bool;

	default chance = 100;
	default endWithFailure = false;
}





class CBTTaskEventBasedDuration extends CBTTaskDuration
{
	function OnListenedGameplayEvent( eventName : CName ) : bool
	{
		var tempDuration : float;
		
		tempDuration = GetEventParamFloat( -0.1337f );
		if( tempDuration != -0.1337f )
			duration = tempDuration;
			
		return true;
	}
}

class CBTTaskEventBasedDurationDef extends CBTTaskDurationDef
{
	default instanceClass = 'CBTTaskEventBasedDuration';
	
	editable var eventName : name;
	
	default duration = 20.0;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		
		if( IsNameValid( eventName ) )
		{
			listenToGameplayEvents.PushBack( eventName );
		}
	}
}