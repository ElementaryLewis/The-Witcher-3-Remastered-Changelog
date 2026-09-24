/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_A_closerToTargetThan_B_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_A_closerToTargetThan_B;
	
	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name )
	{
		if ( condition && condition.ContainsTag( eventParam ) )
		{
			condition.FindEntities();
		}	
	}
}

class W3QuestCond_A_closerToTargetThan_B extends CQuestScriptedCondition
{
	editable var object_A_tag 	: name;
	editable var object_B_tag 	: name;
	editable var targetTag 	  	: name;
	
	var listener				: W3QuestCond_A_closerToTargetThan_B_Listener;
	
	var object_A				: CNode;
	var object_B				: CNode;
	var target					: CNode;
		
	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_A_closerToTargetThan_B_Listener in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListenerFilterName( GEC_Tag, listener, object_A_tag );
			theGame.GetGlobalEventsManager().AddListenerFilterName( GEC_Tag, listener, object_B_tag );
			theGame.GetGlobalEventsManager().AddListenerFilterName( GEC_Tag, listener, targetTag );
			FindEntities();
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListenerFilterName( GEC_Tag, listener, object_A_tag );
			theGame.GetGlobalEventsManager().RemoveListenerFilterName( GEC_Tag, listener, object_B_tag );
			theGame.GetGlobalEventsManager().RemoveListenerFilterName( GEC_Tag, listener, targetTag );
			delete listener;
			listener = NULL;		
		}
	}

	function Activate()
	{
		FindEntities();
		if ( !object_A || !object_B || !target )
		{
			RegisterListener( true );
		}		
	}
	
	function Deactivate()
	{
		if ( listener )
		{
			RegisterListener( false );
		}
	}
	
	function ContainsTag( tag : name ) : bool
	{
		return ( tag == object_A_tag || tag == object_B_tag || tag == targetTag );	
	}
	
	function FindEntities()
	{
		if ( !object_A )
		{
			object_A = theGame.GetNodeByTag ( object_A_tag );
		}
		if ( !object_B )
		{
			object_B = theGame.GetNodeByTag ( object_B_tag );
		}
		if ( !target )
		{
			target = theGame.GetNodeByTag ( targetTag );
		}
		if ( listener && object_A && object_B && target )
		{
			RegisterListener( false );
		}
	}
	
	function Evaluate() : bool
	{
		var object_A_pos 		: Vector;
		var object_B_pos 		: Vector;
		var targetPos 	 		: Vector;
		var object_A_distance 	: float;
		var object_B_distance 	: float;
		
		if ( object_A && object_B && target )
		{
			object_A_pos = object_A.GetWorldPosition();
			object_B_pos = object_B.GetWorldPosition();
			targetPos = target.GetWorldPosition();
			object_A_distance = VecDistanceSquared2D ( object_A_pos, targetPos );
			object_B_distance = VecDistanceSquared2D ( object_B_pos, targetPos );
			
			return object_A_distance <= object_B_distance;
		}
		else if ( !listener )
		{
			RegisterListener( true );			
		}
		
		return false;
	}
}