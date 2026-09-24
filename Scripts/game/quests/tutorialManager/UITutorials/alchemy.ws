/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state Alchemy in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var INGREDIENTS, COOKED_ITEM_DESC, CATEGORIES, SELECT_SOMETHING, SELECT_THUNDERBOLT, COOK, POTIONS, PREPARATION_GO_TO : name;	
	private const var RECIPE_THUNDERBOLT : name;
	private const var POTIONS_JOURNAL : name;	
	private var isClosing : bool;
	private var isForcedTunderbolt : bool;		
	private var currentlySelectedRecipe, requiredRecipeName, selectRecipe : name;
	
		default INGREDIENTS 		= 'TutorialAlchemyIngredients';
		default COOKED_ITEM_DESC 	= 'TutorialAlchemyCookedItem';
		default CATEGORIES 			= 'TutorialAlchemyCathegories';
		default SELECT_SOMETHING 	= 'TutorialAlchemySelectRecipe';
		default SELECT_THUNDERBOLT  = 'TutorialAlchemySelectRecipeThunderbolt';
		default COOK 				= 'TutorialAlchemyCook';
		default POTIONS				= 'TutorialPotionCooked';
		default POTIONS_JOURNAL		= 'TutorialJournalPotions';
		default PREPARATION_GO_TO	= 'TutorialInventoryGoTo'; 
		default RECIPE_THUNDERBOLT  = 'Recipe for Thunderbolt 1';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		isForcedTunderbolt = (FactsQuerySum("tut_forced_preparation") > 0);
		currentlySelectedRecipe = '';
		
		if(isForcedTunderbolt)
		{
			requiredRecipeName = RECIPE_THUNDERBOLT;
			selectRecipe = SELECT_THUNDERBOLT;
			
			
			theGame.GetTutorialSystem().uiHandler.LockLeaveMenu(true);
			
			
			AddThunderBoltIngredients();
			
			theGame.GetTutorialSystem().UnmarkMessageAsSeen(INGREDIENTS);
			theGame.GetTutorialSystem().UnmarkMessageAsSeen(COOKED_ITEM_DESC);
			theGame.GetTutorialSystem().UnmarkMessageAsSeen(CATEGORIES);
			theGame.GetTutorialSystem().UnmarkMessageAsSeen(SELECT_THUNDERBOLT);
			theGame.GetTutorialSystem().UnmarkMessageAsSeen(COOK);
			theGame.GetTutorialSystem().UnmarkMessageAsSeen(POTIONS);
			theGame.GetTutorialSystem().UnmarkMessageAsSeen(PREPARATION_GO_TO);
		}
		else
		{
			selectRecipe = SELECT_SOMETHING;
		}
		
		ShowHint( INGREDIENTS, POS_ALCHEMY_X, POS_ALCHEMY_Y, , GetHighlightAlchemyIngredients() );
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(INGREDIENTS);
		CloseStateHint(COOKED_ITEM_DESC);
		CloseStateHint(CATEGORIES);
		CloseStateHint(selectRecipe);
		CloseStateHint(COOK);
		CloseStateHint(POTIONS);
		CloseStateHint(PREPARATION_GO_TO);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(INGREDIENTS);
		
		if(isForcedTunderbolt)
		{			
			
			theGame.GetTutorialSystem().uiHandler.UnregisterUIState('Alchemy');
			theGame.GetTutorialSystem().uiHandler.UnregisterUIState('Alchemy');
		}
		else
		{
			FactsRemove("tutorial_alch_has_ings");
		}
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		var menu : CR4AlchemyMenu;
		
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == INGREDIENTS)
		{
			ShowHint( COOKED_ITEM_DESC, POS_ALCHEMY_X, POS_ALCHEMY_Y, , GetHighlightAlchemyItemDesc() );
		}
		else if(hintName == COOKED_ITEM_DESC)
		{
			ShowHint( CATEGORIES, POS_ALCHEMY_X, POS_ALCHEMY_Y, , GetHighlightAlchemyList() );
		}
		else if(hintName == CATEGORIES)
		{
			if(currentlySelectedRecipe == requiredRecipeName)
				ShowHint(COOK, POS_ALCHEMY_X, POS_ALCHEMY_Y, ETHDT_Infinite);
			else
				ShowHint(selectRecipe, POS_ALCHEMY_X, POS_ALCHEMY_Y, ETHDT_Infinite);
		}
		else if(hintName == POTIONS)
		{		
			if(isForcedTunderbolt)
			{
				ShowHint(PREPARATION_GO_TO, POS_ALCHEMY_X, POS_ALCHEMY_Y, ETHDT_Infinite);
			
				
				thePlayer.UnblockAction(EIAB_OpenInventory, 'tut_forced_preparation');
			}
			else
			{
				menu = (CR4AlchemyMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild();
				if( menu && !menu.IsInShop() )
				{
					ShowHint(PREPARATION_GO_TO, POS_ALCHEMY_X, POS_ALCHEMY_Y, ETHDT_Infinite);
				}
			}
		}
	}
	
	public final function SelectedRecipe(recipeName : name, canCook : bool)
	{
		currentlySelectedRecipe = recipeName;
		
		if(IsCurrentHint(selectRecipe) && IsRecipeOk(recipeName, canCook))
		{
			CloseStateHint(selectRecipe);
			ShowHint(COOK, POS_ALCHEMY_X, POS_ALCHEMY_Y, ETHDT_Infinite);
		}		
		else if(IsCurrentHint(COOK) && !IsRecipeOk(recipeName, canCook))
		{
			
			CloseStateHint(COOK);
			ShowHint(selectRecipe, POS_ALCHEMY_X, POS_ALCHEMY_Y, ETHDT_Infinite);
		}
	}
	
	private final function IsRecipeOk(recipeName : name, canCook : bool) : bool
	{
		if(isForcedTunderbolt)
		{
			return recipeName == requiredRecipeName;
		}
		else
		{
			return canCook;
		}
	}
	
	public final function CookedItem(recipeName : name)
	{
		if(isForcedTunderbolt && recipeName != requiredRecipeName)
		{
			
			AddThunderBoltIngredients();
		}
		else 
		{
			isClosing = true;	
			CloseStateHint(INGREDIENTS);
			CloseStateHint(COOKED_ITEM_DESC);
			CloseStateHint(CATEGORIES);
			CloseStateHint(selectRecipe);
			CloseStateHint(COOK);
			isClosing = false;
		
			ShowHint(POTIONS, POS_ALCHEMY_X, POS_ALCHEMY_Y);
			theGame.GetTutorialSystem().ActivateJournalEntry(POTIONS_JOURNAL);
		}

	}
	
	
	private final function AddThunderBoltIngredients()
	{
		var i, k, currQuantity, addQuantity, tmpInt : int;
		var tmpName : name;
		var witcher : W3PlayerWitcher;
		var dm : CDefinitionsManagerAccessor;
		var main, ingredients : SCustomNode;
		var memoryWaste : array<name>;
		
		witcher = GetWitcherPlayer();
		memoryWaste = witcher.GetAlchemyRecipes();
		
		if(!memoryWaste.Contains(RECIPE_THUNDERBOLT))
			witcher.AddAlchemyRecipe(RECIPE_THUNDERBOLT);
			
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('alchemy_recipes');		
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName);
			if(tmpName == RECIPE_THUNDERBOLT)
			{
				ingredients = dm.GetCustomDefinitionSubNode(main.subNodes[i],'ingredients');					
				for(k=0; k<ingredients.subNodes.Size(); k+=1)
				{		
					dm.GetCustomNodeAttributeValueName(ingredients.subNodes[k], 'item_name', tmpName);
					dm.GetCustomNodeAttributeValueInt(ingredients.subNodes[k], 'quantity', tmpInt);
					
					currQuantity = witcher.inv.GetItemQuantityByName(tmpName);
					addQuantity = tmpInt - currQuantity;
					if(addQuantity > 0)
					{
						witcher.inv.AddAnItem(tmpName, addQuantity);
					}
				}
				
				break;
			}
		}
	}
}

exec function tut_alch()
{
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	TutorialScript('alchemy', '');
}
