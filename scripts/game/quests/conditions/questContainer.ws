/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_Container_GlobalListener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_Container;
	
	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name )
	{
		if ( condition && eventParam == condition.containerTag )
		{
			condition.FindInventory();	
		}
	}
}

class W3QuestCond_Container_InventoryListener extends IInventoryScriptedListener
{
	public var condition : W3QuestCond_Container;
	
	event OnInventoryScriptedEvent( eventType : EInventoryEventType, itemId : SItemUniqueId, quantity : int, fromAssociatedInventory : bool )
	{
		if ( condition )
		{
			condition.EvaluateImpl();
		}
	}
}

enum EContainerMode
{
	ECM_Empty,
	ECM_NotEmpty
}

class W3QuestCond_Container extends CQuestScriptedCondition
{
	editable var containerTag : name;
	editable var contents : EContainerMode;
		default contents = ECM_Empty;
	
	var inventory			: CInventoryComponent;
	saved var isFulfilled	: bool;
	var globalListener		: W3QuestCond_Container_GlobalListener;
	var inventoryListener	: W3QuestCond_Container_InventoryListener;
	
	function RegisterGlobalListener( flag : bool )
	{
		if (globalListener && flag)
			return;
	
		if (!globalListener && !flag)
			return;
		
		if ( flag )
		{
			globalListener = new W3QuestCond_Container_GlobalListener in this;
			globalListener.condition = this;
			theGame.GetGlobalEventsManager().AddListenerFilterName( GEC_Tag, globalListener, containerTag );
			FindInventory();
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListenerFilterName( GEC_Tag, globalListener, containerTag );
			delete globalListener;
			globalListener = NULL;		
		}
	}
	
	function RegisterInventoryListener( flag : bool )
	{
		if (inventoryListener && flag)
			return;
	
		if (!inventoryListener && !flag)
			return;
		
		if ( flag )
		{
			inventoryListener = new W3QuestCond_Container_InventoryListener in this;
			inventoryListener.condition = this;
			inventory.AddListener( inventoryListener );		
		}
		else
		{
			inventory.RemoveListener( inventoryListener );
			delete inventoryListener;
			inventoryListener = NULL;
		}
	}
	
	function Activate()
	{	
		isFulfilled = false;
		inventory = NULL;
		FindInventory();
		if ( !inventory )
		{
			RegisterGlobalListener( true );
		}
		else
		{
			EvaluateImpl();
			if ( !isFulfilled )
			{
				RegisterInventoryListener( true );
			}
		}
	}
	
	function Deactivate()
	{
		if ( globalListener )
		{
			RegisterGlobalListener( false );
		}
		if ( inventory && inventoryListener )
		{
			RegisterInventoryListener( false );
		}
		else if ( inventoryListener )
		{
			delete inventoryListener;
			inventoryListener = NULL;
		}
		inventory = NULL;
	}
	
	function Evaluate() : bool
	{
		if ( !isFulfilled && !inventory && !globalListener )
		{
			RegisterGlobalListener( true );
		}
		return isFulfilled;
	}
	
	function EvaluateImpl()
	{
		var isEmpty : bool;
		
		if ( isFulfilled )
		{
			return;
		}
		
		if ( inventory )
		{
			isEmpty = ( inventory.GetItemCount( true ) == 0 );			
			if ( ( isEmpty && ( contents == ECM_Empty ) ) || ( !isEmpty && ( contents == ECM_NotEmpty ) ) )
			{
				isFulfilled = true;
			}
		}
		else if ( !globalListener )
		{
			LogQuest( "W3QuestCond_IsItemQuantityMet: iventory can't be NULL inside EvaluateImpl" );
		}
		
		if ( isFulfilled && inventory && inventoryListener )
		{
			RegisterInventoryListener( false );
		}		
	}
	
	function FindInventory()
	{
		var entities : array< CNode >;
		var entity : CGameplayEntity;
		var i : int;

		if ( inventory )
		{
			return;
		}

		
		theGame.GetNodesByTag( containerTag, entities );
		
		if ( entities.Size() == 0 )
		{
			return;
		}
		
		for( i = 0; i < entities.Size(); i+=1 )
		{
			entity = (CGameplayEntity)entities[i];
			if ( entity )
			{		
				inventory = entity.GetInventory();
				if ( inventory )
				{
					break;
				}
			}
			else
			{
				LogQuest("W3QuestCond_Container: found node <<" + entities[i] + ">> which is not a gameplay entity and therefore cannot have inventory. Isn't this a bug?");
			}
		}
		
		if ( inventory )
		{
			if ( globalListener )
			{
				RegisterGlobalListener( false );
			}
			EvaluateImpl();
			if ( !isFulfilled )
			{
				RegisterInventoryListener( true );				
			}
		}
	}
}