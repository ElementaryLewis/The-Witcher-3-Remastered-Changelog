/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3EnchantmentManager
{
	protected var schematics : array<SEnchantmentSchematic>;
	protected var craftMasterComp : W3CraftsmanComponent;
	private var schematicsNames : array<name>;
	
	
	public function Init( masterComp : W3CraftsmanComponent )
	{
		craftMasterComp = masterComp;
		
		if (craftMasterComp)
		{
			schematicsNames = craftMasterComp.GetEnchanterItems(true, true);
		}
		else
		{
			schematicsNames = GetAllRunewordSchematics();
		}
		LoadSchematicsXMLData( schematicsNames );
	}
	
	public function GetSchematic(s : name, out ret : SEnchantmentSchematic) : bool
	{
		var i : int;
		
		for(i=0; i<schematics.Size(); i+=1)
		{
			if(schematics[i].schemName == s)
			{
				ret = schematics[i];
				return true;
			}
		}
		
		return false;
	}
	
	
	protected function LoadSchematicsXMLData( schematicsNames : array<name> ) : void
	{
		var dm : CDefinitionsManagerAccessor;
		var main, ingredients : SCustomNode;
		var tmpName : name;
		var tmpString : string;
		var tmpInt : int;
		var schem : SEnchantmentSchematic;
		var i,j,k : int;
		var ing : SItemParts;
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('crafting_schematics');
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName);
			
			for(j=0; j<schematicsNames.Size(); j+=1)
			{
				if(tmpName == schematicsNames[j])
				{
					if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'localisation_key_name', tmpName))
						schem.localizedName = tmpName;
					if(dm.GetCustomNodeAttributeValueString(main.subNodes[i], 'localisation_key_description', tmpString))
						schem.localizedDescriptionName = tmpString;
					if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'price', tmpInt))
						schem.baseCraftingPrice = tmpInt;	
					if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'level', tmpInt))
						schem.level = tmpInt;	
						
					
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
					
					schem.schemName = schematicsNames[j];
					
					schematics.PushBack(schem);		
					
					
					schem.baseCraftingPrice = -1;
					schem.ingredients.Clear();
					schem.schemName = '';
					break;
				}
			}
		}
	}
}

function getEnchantmentSchematicFromName(schematicName : name):SEnchantmentSchematic
{
	var dm : CDefinitionsManagerAccessor;
	var main, ingredients : SCustomNode;
	var tmpName : name;
	var tmpString : string;
	var tmpInt : int;
	var schem : SEnchantmentSchematic;
	var i,j,k : int;
	var ing : SItemParts;
	
	dm = theGame.GetDefinitionsManager();
	main = dm.GetCustomDefinition('crafting_schematics');
	
	for(i=0; i<main.subNodes.Size(); i+=1)
	{
		dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName);
		if(tmpName == schematicName)
		{
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'localisation_key_name', tmpName))
				schem.localizedName = tmpName;
			if(dm.GetCustomNodeAttributeValueString(main.subNodes[i], 'localisation_key_description', tmpString))
				schem.localizedDescriptionName = tmpString;
			if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'price', tmpInt))
				schem.baseCraftingPrice = tmpInt;	
			if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'level', tmpInt))
				schem.level = tmpInt;	
			
			
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
			
			schem.schemName = schematicName;
			
			
			break;
		}
	}
		
	return schem;
}