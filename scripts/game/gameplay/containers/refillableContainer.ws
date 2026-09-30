/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3RefillableContainer extends W3Container 
{
	private saved var isEmpty : bool;
	private saved var checkedForBonusHerbs : bool;
	
		default skipInventoryPanel = true;
		default isEmpty = false;
	
	protected function IsEmpty() : bool			{return isEmpty;}
	
	event OnSpawned( spawnData : SEntitySpawnData ) 
	{
		var tmpName : name;
		var i : int;
		var inv : CInventoryComponent;
		
		super.OnSpawned(spawnData);

		
		lockedByKey = false;
		
		if(spawnData.restored && isEmpty)
		{
			AddTimer( 'Refill', 20, true );
		}
		
		
		inv = GetInventory();
		if( inv && !inv.IsEmpty() )
		{
			SetFocusModeVisibility( FMV_Interactive );					
		}
	}
		
	
	protected function TakeAllItems() 
	{
		var inv : CInventoryComponent;
		
		if ( isEmpty )
		{
			return;
		}
		inv = GetInventory();
		if ( inv )
		{
			
			super.TakeAllItems();
		}
		isEmpty = true;
		
		SetFocusModeVisibility( FMV_None );							
		Enable( false );
	}
	
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		var null : array<SItemUniqueId>;
		var null2 : array<int>;
		var herbBonusChance : float;

		super.OnInteractionActivated(interactionComponentName, activator);

		if(activator == thePlayer && !checkedForBonusHerbs)
		{
			herbBonusChance = CalculateAttributeValue(thePlayer.GetAttributeValue('bonus_herb_chance'));
			if(herbBonusChance > 0)
				CheckForBonusHerbs(null, null2, herbBonusChance);
		}
	}	
	
	
	timer function Refill(td : float, id : int)
	{
		var inv : CInventoryComponent;
		var oldMoney, i : int;
		var oldItems : array<SItemUniqueId>;
		var oldItemsCounts : array<int>;
		var herbBonusChance : float;
		
		inv = GetInventory();
		if ( inv && inv.IsLootRenewable() )
		{
			if( inv.IsReadyToRenew() )
			{
				PreRefillContainer();
			}
			
			
			if(isPlayerInActivationRange)
			{
				oldMoney = inv.GetMoney();
				herbBonusChance = CalculateAttributeValue(thePlayer.GetAttributeValue('bonus_herb_chance'));
				
				if(herbBonusChance > 0)
				{
					inv.GetAllItems(oldItems);
					oldItemsCounts.Resize(oldItems.Size());
					for(i=0; i<oldItems.Size(); i+=1)
						oldItemsCounts[i] = inv.GetItemQuantity(oldItems[i]);
				}
			}
			
			inv.UpdateLoot();
			checkedForBonusMoney = false;
			checkedForBonusHerbs = false;
			
			
			if(isPlayerInActivationRange)
			{
				checkedForBonusMoney = true;
				checkedForBonusHerbs = true;
				CheckForBonusMoney(oldMoney);
				
				if(herbBonusChance > 0)
					CheckForBonusHerbs(oldItems, oldItemsCounts, herbBonusChance);
			}
					
			if ( !inv.IsEmpty() )
			{
				isEmpty = false;
				
				SetFocusModeVisibility( FMV_Interactive );			
				ApplyAppearance( "1_full" );
				Enable( true );
				RemoveTimer( 'Refill' );
			}
		}
		else
		{
			RemoveTimer( 'Refill' );
		}
	}
	
	
	private function CheckForBonusHerbs(oldItems : array<SItemUniqueId>, oldItemsQuantities : array<int>, bonusChance : float)
	{
		var oldHerbNames, newHerbNames : array<name>;
		var oldHerbQuantities, newHerbQuantities, newItemsCounts : array<int>;
		var newItems : array<SItemUniqueId>;
		var i, ind : int;
		var dm : CDefinitionsManagerAccessor;
		
		GetHerbsData(oldItems, oldItemsQuantities, oldHerbNames, oldHerbQuantities);
		
		if( inv )
		{
			inv.GetAllItems(newItems);
		}
		
		newItemsCounts.Resize(newItems.Size());
		for(i=0; i<newItems.Size(); i+=1)
		{
			newItemsCounts[i] = inv.GetItemQuantity(newItems[i]);
		}
			
		GetHerbsData(newItems, newItemsCounts, newHerbNames, newHerbQuantities);
		
		
		for(i=0; i<newHerbNames.Size(); i+=1)
		{
			ind = oldHerbNames.FindFirst(newHerbNames[i]);
			if(ind == -1)
				continue;
				
			newHerbQuantities[i] -= oldHerbQuantities[ind];
		}
		
		if( inv )
		{
			dm = theGame.GetDefinitionsManager();
			
			for(i=0; i<newHerbNames.Size(); i+=1)
			{
				
				if(newHerbQuantities[i] <= 0)
					continue;
					
				
				if(dm.ItemHasTag(newHerbNames[i], 'Quest'))
					continue;
					
				
				if(RandF() > bonusChance)
					continue;
					
				
				inv.AddAnItem(newHerbNames[i], 1, true, true);
			}
		}
	}
	
	
	private function GetHerbsData(items : array<SItemUniqueId>, itemsQuantities : array<int>, out herbNames : array<name>, out herbQuantities : array<int>)
	{
		var i, ind : int;
		var herbName : name;
		
		if( !inv )
		{
			return;
		}
		
		for(i=0; i<items.Size(); i+=1)
		{
			if(inv.ItemHasTag(items[i], 'HerbGameplay'))
			{
				herbName = inv.GetItemName(items[i]);
				ind = herbNames.FindFirst(herbName);
				if(ind == -1)
				{
					herbNames.PushBack(herbName);
					herbQuantities.PushBack(inv.GetItemQuantity(items[i]));
				}
				else
				{
					herbQuantities[ind] += inv.GetItemQuantity(items[i]);
				}				
			}
		}
	}
	
	protected function PreRefillContainer()
	{
	}
}