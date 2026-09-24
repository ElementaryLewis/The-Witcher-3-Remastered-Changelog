/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
quest function EntityComponentQuest( tag : name, componentName : name, bEnable : bool )
{
	var nodes : array<CNode>;
	var comp	: CComponent;
	var i : int;
	var entity : CEntity;
	var gameplayEntity : CGameplayEntity;
	var npc : CNewNPC;
	
	theGame.GetNodesByTag( tag, nodes );
	
	for(i=0; i<nodes.Size(); i+=1)
	{
		entity = (CEntity)nodes[i];
		if ( entity )
		{
			comp = entity.GetComponent( componentName );
			if ( comp )
			{
				comp.SetEnabled( bEnable );
				comp.SetShouldSave( true );
			}
			if ( componentName == 'talk' )
			{
				npc = (CNewNPC)entity;
				if ( npc )
				{
					npc.DisableTalking( !bEnable );
				}
			}
		}	
		else
		{
			LogQuest("EntityComponentQuest: found node <<" + nodes[i] + ">> which isn't a CEntity so it cannot have component. Will skip this but isn't that a bug?");
		}
	}
}



class W3QuestCond_EntityComponentEnabled_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_EntityComponentEnabled;
	
	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name )
	{
		if ( condition && eventParam == condition.tag )
		{
			condition.FindEntity();
		}	
	}
}

class W3QuestCond_EntityComponentEnabled extends CQuestScriptedCondition
{
	editable var tag			: name;
	editable var componentName	: name;
	editable var inverted		: bool;
	
	var entity					: CEntity;
	var component				: CComponent;
	var listener				: W3QuestCond_EntityComponentEnabled_Listener;
	
	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_EntityComponentEnabled_Listener in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListenerFilterName( GEC_Tag, listener, tag );
			FindEntity();
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListenerFilterName( GEC_Tag, listener, tag );
			delete listener;
			listener = NULL;		
		}
	}
	
	function Activate()
	{
		FindEntity();
		if ( !entity )
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
	
	function Evaluate() : bool
	{
		if ( entity )
		{
			if ( !component )
			{
				component = entity.GetComponent( componentName );
			}
			if ( component )
			{
				if( inverted )
				{
					return !component.IsEnabled();
				}
				else
				{
					return component.IsEnabled();
				}
			}
		}
		else if ( !listener )
		{
			RegisterListener( true );
		}		
		return false;
	}

	function FindEntity()
	{
		if ( entity )
		{
			return;
		}
		entity = theGame.GetEntityByTag( tag );
		if ( entity && listener )
		{
			RegisterListener( false );
		}
	}
}



class W3QuestCond_EntityComponentExists_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_EntityComponentExists;
	
	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name )
	{
		if ( condition && eventParam == condition.tag )
		{
			condition.FindEntity();
		}	
	}
}

class W3QuestCond_EntityComponentExists extends CQuestScriptedCondition
{
	editable var tag			: name;
	editable var componentName	: name;
	
	var entity					: CEntity;
	var component				: CComponent;
	var listener				: W3QuestCond_EntityComponentExists_Listener;
	
	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_EntityComponentExists_Listener in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListenerFilterName( GEC_Tag, listener, tag );
			FindEntity();
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListenerFilterName( GEC_Tag, listener, tag );
			delete listener;
			listener = NULL;		
		}
	}
	
	function Activate()
	{
		FindEntity();
		if ( !entity )
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
	
	function Evaluate() : bool
	{
		if ( entity )
		{		
			return entity.GetComponent( componentName );
		}
		else if ( !listener )
		{
			RegisterListener( true );
		}		
		return false;
	}

	function FindEntity()
	{
		if ( entity )
		{
			return;
		}
		entity = theGame.GetEntityByTag( tag );
		if ( entity && listener )
		{
			RegisterListener( false );
		}
	}
}
