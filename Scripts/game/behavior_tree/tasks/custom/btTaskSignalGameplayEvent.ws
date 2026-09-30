/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSignalGameplayEvent extends IBehTreeTask
{
	var onActivate 			: bool;
	var onDeactivate		: bool;
	var onSuccess 			: bool;
	var onTaggedEntity		: bool;
	var tagToFind			: name;
	var onMultipleEntities	: bool;
	
	var eventName 			: name;
	var npc					: array<CNewNPC>;
	var i					: int;
	
	function IsAvailable() : bool
	{
		if (eventName)
			return true;
			
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		if ( onActivate && !onTaggedEntity )
		{
			GetNPC().SignalGameplayEvent(eventName);
		}
		else if( onActivate && onTaggedEntity )
		{
			if (onMultipleEntities)
			{
				SignalMultipleEntitiesByTag();
			}
			else
			{
				theGame.GetNPCByTag(tagToFind).SignalGameplayEvent( eventName );
			}
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( onDeactivate && !onTaggedEntity )
		{
			GetNPC().SignalGameplayEvent(eventName);
		}
		else if( onDeactivate && onTaggedEntity )
		{
			if (onMultipleEntities)
			{
				SignalMultipleEntitiesByTag();
			}
			else
			{
				theGame.GetNPCByTag(tagToFind).SignalGameplayEvent( eventName );
			}
		}
	}
	
	function OnCompletion( success : bool )
	{
		if ( onSuccess && success && !onTaggedEntity )
		{
			GetNPC().SignalGameplayEvent(eventName);
		}
		else if( onSuccess && success && onTaggedEntity )
		{
			if (onMultipleEntities)
			{
				SignalMultipleEntitiesByTag();
			}
			else
			{
				theGame.GetNPCByTag(tagToFind).SignalGameplayEvent( eventName );
			}
		}
	}
	
	function SignalMultipleEntitiesByTag()
	{
		theGame.GetNPCsByTag( tagToFind, npc );
		
		for (i = 0; i<npc.Size(); i+=1)
		{
			npc[i].SignalGameplayEvent( eventName );
		}
	}
	
}

class CBTTaskSignalGameplayEventDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSignalGameplayEvent';

	editable var eventName			: name;
	editable var onActivate 		: bool;
	editable var onDeactivate 		: bool;
	editable var onSuccess 			: bool;
	editable var onTaggedEntity		: bool;
	editable var tagToFind			: name;
	editable var onMultipleEntities	: bool;
}