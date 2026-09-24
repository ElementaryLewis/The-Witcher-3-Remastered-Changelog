/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskOpenDoors extends IBehTreeTask
{
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var doorsEnt		: CEntity;
		var doorsCmp		: CDoorComponent;		
		
		if ( eventName == 'AI_DoorTriggerEntered' )
		{
			doorsEnt = (CEntity)GetEventParamObject();			
			doorsCmp = ( CDoorComponent )doorsEnt.GetComponentByClassName( 'CDoorComponent' );
			if( doorsCmp && doorsCmp.IsInteractive() )
			{
				doorsCmp.Open( false, false );
			}
		}
		
		return false;
	}
}

class CBTTaskOpenDoorsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskOpenDoors';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'AI_DoorTriggerEntered' );
	}
}