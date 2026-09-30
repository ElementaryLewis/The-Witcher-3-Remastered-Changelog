/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3MutagenDismantlingTable extends W3AlchemyTable
{
	event OnInteraction( actionName : string, activator : CEntity )
	{
		var l_initDataObject			: W3StandaloneDismantleInitData = new W3StandaloneDismantleInitData in theGame.GetGuiManager();
		
		var l_tempName					: name;
		var l_requiredIngredients		: array<name>;
		var l_tempNodes					: array<SCustomNode>;
		var l_i, l_k, l_m				: int;
		var l_dm						: CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var l_definitions				: SCustomNode = l_dm.GetCustomDefinition('alchemy_recipes');	
		
		super.OnInteraction( actionName, activator );
		
		if( actionName == "Use" )
		{
			for( l_i = 0 ; l_i < l_definitions.subNodes.Size() ; l_i += 1 )
			{
				l_dm.GetCustomNodeAttributeValueName( l_definitions.subNodes[ l_i ], 'name_name', l_tempName );
				
				if( l_dm.IsRecipeForMutagenPotion( l_tempName ) )
				{
					l_dm.GetCustomNodeAttributeValueName( l_definitions.subNodes[ l_i ], 'cookedItem_name', l_tempName );
					
					if ( thePlayer.inv.HasItem( l_tempName ) || GetWitcherPlayer().GetHorseManager().GetInventoryComponent().HasItem( l_tempName ) )
					{
						continue;
					}				
					
					l_tempNodes = l_definitions.subNodes[ l_i ].subNodes;
					
					for( l_k = 0 ; l_tempNodes.Size() > l_k ; l_k += 1 )
					{
						if( l_tempNodes[ l_k ].nodeName == 'ingredients' )
						{
							for( l_m = 0 ; l_tempNodes[ l_k ].subNodes.Size() >l_m ; l_m += 1 )
							{
								l_dm.GetCustomNodeAttributeValueName( l_tempNodes[ l_k ].subNodes[ l_m ], 'item_name', l_tempName );
								
								if( !l_requiredIngredients.Contains( l_tempName ) )
								{
									l_requiredIngredients.PushBack( l_tempName );
								}
							}
						}
					}
				}
			}
			
			l_initDataObject.setDefaultState( 'Disassemble' );
			l_initDataObject.unlockCraftingMenu = true;
			l_initDataObject.SetBlockOtherPanels( true );
			
			l_initDataObject.m_ingredientsForMissingDecoctions = l_requiredIngredients;
			
			theGame.RequestMenuWithBackground( 'BlacksmithMenu', 'CommonMenu', l_initDataObject );
		}
	}	
}