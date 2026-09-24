/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SCookingSchematic
{
	var cookedItemName			: name;					
	var cookedItemQuantity		: int;					
	var ingredients				: array<SItemParts>;	
	var schemName				: name;					
};

abstract class W3CookingPlace extends W3Container
{

	editable var cookingTime : float;
	
	private var schematics : array<SCookingSchematic>;
	
	protected var isActive : bool;
	
	protected var cookingStarted : bool;
	protected var cookingCompleted : bool;
	
	protected autobind secondaryLootInteractionComponent : CInteractionComponent = "Loot2";
	
	default cookingTime = 1.0;
	
	event OnSpawned( spawnData : SEntitySpawnData ) 
	{
		super.OnSpawned(spawnData);
		LoadXMLData();
		
		if ( schematics.Size() <= 0 )
			LogChannel('CookingPlace', "No cooking schematics was loaded from the XML! for: " + this);
		
		isActive = true;
		cookingCompleted = false;
		cookingStarted = false;
	}
	
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		var hud : CR4ScriptedHud;
		if ( activator != thePlayer || isInteractionBlocked)
			return false;
		
		if(actionName != "Container")
			return false;		
		
		if(cookingCompleted)
		{
			TakeAllItems();
			OnContainerClosed();
			cookingCompleted = false;
			if( lootInteractionComponent && secondaryLootInteractionComponent )
			{
				lootInteractionComponent.SetEnabled(true);
				secondaryLootInteractionComponent.SetEnabled(false);
			}
		}
		else
		{
			theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu', this );
		}
		
		return true;
	}
	
	public function OnContainerClosed()
	{
		super.OnContainerClosed();
		
		if ( !IsEmpty() && this.isActive )
		{
			if ( Cook() )
			{
				CookingStarted();
			}
		}
	}
	
	
	
	
	
	
	
	private function LoadXMLData()
	{
		var dm : CDefinitionsManagerAccessor;
		var main, ingredients : SCustomNode;
		var tmpName : name;
		var tmpInt : int;
		var schem : SCookingSchematic;
		var i,j,k : int;
		var ing : SItemParts;
						
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('cooking_recipes');
		
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			if( dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName) )
				schem.schemName = tmpName;
			
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'cookedItem_name', tmpName))
				schem.cookedItemName = tmpName;
				
			if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'cookedItemQuantity', tmpInt))
				schem.cookedItemQuantity = tmpInt;
			
			
			ingredients = dm.GetCustomDefinitionSubNode(main.subNodes[i],'ingredients');					
			for(k=0; k<ingredients.subNodes.Size(); k+=1)
			{		
				ing.itemName = '';
				ing.quantity = -1;
			
				if(dm.GetCustomNodeAttributeValueName(ingredients.subNodes[k], 'item_name', tmpName))						
					ing.itemName = tmpName;
				if(dm.GetCustomNodeAttributeValueInt(ingredients.subNodes[k], 'quantity', tmpInt))
					ing.quantity = tmpInt;
					
				schem.ingredients.PushBack(ing);						
			}
			
			schematics.PushBack(schem);		
			
			
			schem.cookedItemName = '';
			schem.ingredients.Clear();
			schem.schemName = '';
		}
	}
	
	
	
	protected function CookingStarted()
	{
		cookingStarted = true;
		
		if( lootInteractionComponent )
		{
			lootInteractionComponent.SetEnabled(false);
		}
		
		AddTimer('Cooking',cookingTime,false, , , true);
	}
	
	protected function CookingDone()
	{
		cookingStarted = false;
		if ( !this.IsEmpty() )
		{
			cookingCompleted = true;
			
			if( lootInteractionComponent && secondaryLootInteractionComponent )
			{
				lootInteractionComponent.SetEnabled(false);
				secondaryLootInteractionComponent.SetEnabled(true);
			}
		}
		else
		{
			cookingCompleted = false;
			
			if( lootInteractionComponent && secondaryLootInteractionComponent )
			{
				lootInteractionComponent.SetEnabled(true);
				secondaryLootInteractionComponent.SetEnabled(false);
			}
		}
	}
	
	private timer function Cooking( dt : float , id : int)
	{
		CookingDone();
	}
	
	
	protected function Cook() : bool
	{
		var allItems			: array< SItemUniqueId >;
		var ingredients 		: array< SItemParts >;
		var matchedIngredients	: array< SItemParts >;
		var tmpItems			: array<SItemUniqueId>;
		var tmpIngredient 		:	SItemParts;
		var tmpSchematicsIterator : int;
		var tmpSchematic 		: SCookingSchematic;
		var i, tmpQuantity, quantity : int;
		
		if( inv )
		{
			inv.GetAllItems( allItems );
		}
		
		if ( allItems.Size() == 0 )
			return false;
		
		
		for(i=0; i<allItems.Size(); i+=1)
		{
			tmpIngredient.itemName = inv.GetItemName(allItems[i]);
			tmpIngredient.quantity = inv.GetItemQuantity(allItems[i]);
			
			ingredients.PushBack(tmpIngredient);
			
		}
		
		
		tmpSchematicsIterator = FindSchematicForIngredients( ingredients, matchedIngredients );
		
		if ( tmpSchematicsIterator != -1 )
		{
			tmpSchematic = schematics[tmpSchematicsIterator];
			
			for ( i=0 ; i<matchedIngredients.Size() ; i+=1 )
			{
				
				tmpQuantity = FloorF( matchedIngredients[i].quantity/tmpSchematic.ingredients[i].quantity );
				if ( i==0 || tmpQuantity <= quantity )
					quantity = tmpQuantity;
			}
			
			UseSchematic(schematics[tmpSchematicsIterator], quantity);
			
			for ( i=0 ; i<matchedIngredients.Size() ; i+=1 )
			{
				matchedIngredients[i].quantity *= quantity;
			}
			
			UseIngredients(matchedIngredients);
			
			return true;
		}
		
		if( allItems.Size() > 1 )
			return false;
		
		
		if (tmpIngredient.quantity > 1 )
			tmpSchematicsIterator = FindSchematicByIngredientName(tmpIngredient.itemName);
		else
			return false;
			
		if ( tmpSchematicsIterator != -1 )
		{
			tmpSchematic = schematics[tmpSchematicsIterator];
			if (tmpSchematic.ingredients.Size() == 1 )
			{
				tmpIngredient = tmpSchematic.ingredients[0];
				
				if( !inv )
				{
					quantity = 0;
				}
				else
				{
					quantity = FloorF(inv.GetItemQuantity(allItems[0])/tmpIngredient.quantity);
				}
				
				tmpIngredient.quantity *= quantity;
				
				UseSchematic(tmpSchematic, quantity);
				
				matchedIngredients.Clear();
				matchedIngredients.PushBack(tmpIngredient);
				
				UseIngredients(matchedIngredients);
				
				return true;
			}
		}
		
		return false;
	}
	
	private function UseSchematic( schematic : SCookingSchematic, optional quantity : int )
	{
		var i : int;
		
		if ( !quantity )
			quantity = 1;
		
		LogChannel('CookingPlace', "Used Schematic: " + schematic.schemName);
		
		
		for ( i=0 ; i < quantity ; i+=1 )
		{
			if( schematic.cookedItemQuantity >= 1 )
			{
				LogChannel('CookingPlace', "Adding: " + schematic.cookedItemName + " to the inventory");
				if( inv )
				{
					inv.AddAnItem(schematic.cookedItemName, schematic.cookedItemQuantity);
				}
			}
		}
		
		switch ( schematic.schemName )
		{
			case 'Voodoo doll Curse' 		: VoodooDollCurse(); 				break;
			case 'Treasure Nekker' 			: TreasureNekker(); 				break;
			case 'Spawn Random Enemies'		: SpawnRandomEnemies(); 			break;
			case 'Master of Puppets'		:  	break;
			default: break;
		}
	}
	
	private function UseIngredients( items : array< SItemParts >)
	{
		var i,j : int;
		var itemIds : array<SItemUniqueId>;
		
		if( !inv )
		{
			return;
		}
		
		for ( i=0 ; i<items.Size() ; i+=1 )
		{
			itemIds = inv.GetItemsIds(items[i].itemName);
			for ( j=0 ; j<itemIds.Size() ; j+=1 )
			{
				if(!inv.ItemHasTag(itemIds[j], 'Quest') && inv.GetItemName(itemIds[j]) != 'Philosophers Stone' )
				{
					
					inv.RemoveItem(itemIds[j],items[i].quantity);
				}
			}
		}
	}
	
	
	protected function FindSchematicForIngredients( ingredients : array<SItemParts>, out matchedIngredients : array<SItemParts> ) : int
	{
		var i,j,k : int;
		var outIngredient : SItemParts;
		
		
		
		for ( i=0 ; i<schematics.Size() ; i+=1 )
		{
			matchedIngredients.Clear();
			for ( j=0 ; j<schematics[i].ingredients.Size() ; j+=1 )
			{
				for ( k=0 ; k<ingredients.Size() ; k+=1)
				{
					if ( schematics[i].ingredients[j].itemName == ingredients[k].itemName )
					{
						if ( schematics[i].ingredients[j].quantity <= ingredients[k].quantity )
							matchedIngredients.PushBack(ingredients[k]);
					}
				}
			}
			if ( matchedIngredients.Size() == schematics[i].ingredients.Size() )
			{
				return i;
			}
		}
		
		return -1;
	}
	
	protected function FindSchematicByIngredientName( ingredientName : name ) : int
	{
		var i,j : int;
		
		for ( i=0 ; i<schematics.Size() ; i+=1 )
		{
			for ( j=0 ; j<schematics[i].ingredients.Size() ; j+=1 )
			{
				if ( schematics[i].ingredients[j].itemName == ingredientName )
				{
					return i;
				}
			}
		}
		
		return -1;
	}
	
	
	protected function VoodooDollCurse();
	
	protected function TreasureNekker(){}
	
	protected function SpawnRandomEnemies(){}
	
}

class W3CampfirePlace extends W3CookingPlace
{
	protected var victims : array<CActor>;
	var bombs : array<SItemUniqueId> ;
	
	protected function CookingStarted()
	{
		super.CookingStarted();
		PlayEffect('fire_big');
	}
	
	protected function CookingDone()
	{
		StopEffect('fire_big');
		ExplodeBombs();
		bombs.Clear();
		super.CookingDone();
	}
	
	event OnFireHit(source : CGameplayEntity)
	{
		super.OnFireHit(source);
		if ( !isActive )
		{
			isActive = true;
			PlayEffect('fire_01');
			OnContainerClosed();
		}
	}
	event OnAardHit( sign : W3AardProjectile )
	{
		super.OnAardHit( sign );
		if ( isActive )
		{
			isActive = false;
			StopEffect('fire_01');
		}
		
	}
	
	
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		var victim : CActor;
		
		if ( interactionComponentName == "DamageArea" )
		{
			victim = (CActor)activator;
			if ( victim && isActive )
			{
				victims.PushBack(victim);
				if ( victims.Size() == 1 )
					AddTimer( 'ApplyBurning', 0.1, true );
			}
		}
		else
			super.OnInteractionActivated(interactionComponentName, activator);
	}
		
	
	event OnInteractionDeactivated( interactionComponentName : string, activator : CEntity )
	{
		var victim : CActor;
		if ( interactionComponentName == "DamageArea" )
		{
			victim = (CActor)activator;
			if ( victims.Contains(victim) )
			{
				victims.Remove(victim);
				if ( victims.Size() == 0 )
					RemoveTimer( 'ApplyBurning' );
			}
		}
		super.OnInteractionDeactivated(interactionComponentName, activator);	
	}
	
	timer function ApplyBurning( dt : float , id : int)
	{
		var i : int;
		
		for ( i=0; i<victims.Size(); i+=1 )
			victims[i].AddEffectDefault( EET_Burning, this, this.GetName() );
	}
	
	function OnContainerClosed()
	{
		var allItems : array< SItemUniqueId >;
		var i : int;
		
		bombs.Clear();
		
		if ( inv && !IsEmpty() && isActive )
		{
			inv.GetAllItems( allItems );
			
			for ( i=0; i < allItems.Size() ; i+=1)
			{
				if ( inv.IsItemBomb(allItems[i]) )
					bombs.PushBack(allItems[i]);
			}
			
		}
		
		super.OnContainerClosed();
		
		if ( !cookingStarted && bombs.Size() >= 1 )
			CookingStarted();
			
	}
	
	function ExplodeBombs()
	{
		var i : int;
		var bombEntity : W3Petard;
		
		if( !inv )
		{
			return;
		}
		
		for ( i=0; i < bombs.Size() ; i+=1)
		{
			bombEntity = (W3Petard)inv.GetDeploymentItemEntity( bombs[i], this.GetWorldPosition() );
			if ( bombEntity )
			{
				inv.RemoveItem(bombs[i],inv.GetItemQuantity(bombs[i]));
				bombEntity.Initialize(NULL);
				bombEntity.ProcessEffect();
			}
		}
	}
	
	protected function VoodooDollCurse()
	{
		var params : SCustomEffectParams;
		
		params.effectType = EET_Burning;
		params.creator = this;
		params.duration = 30;
		
		thePlayer.AddEffectCustom(params);
	}
}
