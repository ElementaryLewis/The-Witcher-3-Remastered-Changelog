/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state Crafting in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var SCHEMATICS, ITEM_DESCRIPTION, COMPONENTS, PRICE, CRAFTSMEN, DISMANTLING : name;
	private var isClosing : bool;
	
		default SCHEMATICS 			= 'TutorialCraftingSchematicsList';
		default ITEM_DESCRIPTION 	= 'TutorialCraftingItemDescription';
		default COMPONENTS 			= 'TutorialCraftingComponents';
		default PRICE 				= 'TutorialCraftingPrice';
		default CRAFTSMEN 			= 'TutorialCraftingCraftsmen';
		default DISMANTLING			= 'TutorialCraftingDismantling';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
			
		ShowHint( SCHEMATICS, POS_ALCHEMY_X, POS_ALCHEMY_Y - 0.1f, ETHDT_Input, GetHighlightCraftingList(), , , true );
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(SCHEMATICS);
		CloseStateHint(ITEM_DESCRIPTION);
		CloseStateHint(COMPONENTS);
		CloseStateHint(PRICE);
		CloseStateHint(CRAFTSMEN);
		CloseStateHint(DISMANTLING);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(SCHEMATICS);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if(closedByParentMenu || isClosing)
			return true;

		QuitState();
			
		if(hintName == SCHEMATICS)
		{
			
		}
		else if(hintName == ITEM_DESCRIPTION)
		{
			
		}
		else if(hintName == COMPONENTS)
		{
			
		}
		else if(hintName == PRICE)
		{
			
		}
		else if(hintName == CRAFTSMEN)
		{
			
		}
		else if(hintName == DISMANTLING)
		{
			
		}
	}
}

exec function tut_craft()
{
	GetWitcherPlayer().AddCraftingSchematic('No Mans Land sword 3 schematic');
	thePlayer.inv.AddAnItem('Steel ingot', 6);
	thePlayer.inv.AddAnItem('Leather straps', 8);
	thePlayer.inv.AddAnItem('Timber', 10);
	thePlayer.inv.AddAnItem('Oil', 10);
	thePlayer.inv.AddAnItem('Hardened timber', 5);
	thePlayer.AddMoney(45);
}