/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_IsItemEquipped_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_IsItemEquipped;
	
	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name )
	{
		if ( condition )
		{
			condition.EvaluateImpl();
		}	
	}
}

class W3QuestCond_IsItemEquipped extends CQuestScriptedCondition
{
	editable var itemName 		: name;
	editable var categoryName 	: name;
	editable var inverted		: bool;

	var isFulfilled				: bool;
	var listener				: W3QuestCond_IsItemEquipped_Listener;

	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_IsItemEquipped_Listener in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListener( GetGlobalEventCategory( SEC_OnItemEquipped ), listener );
			EvaluateImpl();
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListener( GetGlobalEventCategory( SEC_OnItemEquipped ), listener );
			delete listener;
			listener = NULL;		
		}
	}	
	
	function Activate()
	{
		EvaluateImpl();
		if ( !isFulfilled )
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
		if ( !isFulfilled && !listener )
		{
			RegisterListener( true );
		}
		return isFulfilled;
	}
		
	function EvaluateImpl()
	{
		var player : W3PlayerWitcher;
		var itemEquipped : bool;
		var equippedItems : array<SItemUniqueId>;
		var inv : CInventoryComponent;
		var i : int;
		
		player = GetWitcherPlayer();
		if ( player )
		{
			if ( IsNameValid( itemName ) )
			{			
				itemEquipped = player.IsItemEquippedByName( itemName );
				if(!itemEquipped)
				{
					inv = player.GetInventory();
					if(inv)
					{
						equippedItems = player.GetEquippedItems();
						for(i = 0; i < equippedItems.Size(); i+=1)
						{
							if(inv.GetItemTemplateOverride(equippedItems[i]) == itemName)
							{
								itemEquipped = true;
								break;
							}
						}
					}
				}

			}
			else if ( IsNameValid( categoryName ) )
			{
				itemEquipped = player.IsItemEquippedByCategoryName( categoryName );
			}
			
			if( inverted )
			{
				isFulfilled = !itemEquipped;
			}
			else
			{
				isFulfilled = itemEquipped;
			}
		}
	}
}