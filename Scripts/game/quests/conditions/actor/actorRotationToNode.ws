/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_ActorRotationToNode_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_ActorRotationToNode;
	
	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name )
	{
		if ( condition && eventParam == condition.targetTag )
		{
			condition.FindTarget();	
		}	
	}	
}

class W3QuestCond_ActorRotationToNode extends CQCActorScriptedCondition
{
	editable var condition 	: ECompareOp;
	editable var degrees 	: float;
	editable var targetTag	: name;
	
	default condition = CO_Lesser;

	var targetNode			: CNode;
	var listener			: W3QuestCond_ActorRotationToNode_Listener;

	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_ActorRotationToNode_Listener in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListenerFilterName( GEC_Tag, listener, targetTag );
			FindTarget();
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListenerFilterName( GEC_Tag, listener, targetTag );
			delete listener;
			listener = NULL;
		}
	}

	function OnActivate( actor : CActor ) : bool
	{	
		FindTarget();
		if ( !targetNode )
		{
			RegisterListener( true );
		}
		return true;
	}

	function OnDeactivate( actor : CActor ) : bool
	{	
		if ( listener )
		{
			RegisterListener( false );
		}
		return true;
	}

	function Evaluate( act : CActor ) : bool
	{		
		var l_currentAngle 	: float;
		
		if ( targetNode )
		{
			l_currentAngle 	= NodeToNodeAngleDistance( targetNode, act );
			l_currentAngle 	= AbsF ( l_currentAngle );
			return ProcessCompare( condition, l_currentAngle, degrees );
		}
		else if ( !listener )
		{
			RegisterListener( true );		
		}
		return false;						
	}
	
	function FindTarget()
	{
		if ( targetNode )
		{
			return;
		}
		targetNode = theGame.GetNodeByTag( targetTag );
		if ( targetNode && listener )
		{
			RegisterListener( false );
		}
	}	
}