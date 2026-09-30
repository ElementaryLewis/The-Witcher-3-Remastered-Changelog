/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct Runeword
{
	var wordName : name;
	var runes : array<name>;
	var abilities : array<name>;
}

class W3RunewordManager
{
	protected saved var runewords : array<Runeword>;

	function Init()
	{
		LoadXMLData();
	}
	
	function LoadXMLData()
	{
		var runeword : Runeword;
		var i,j : int;
		var tmpName : name;
		var dm : CDefinitionsManagerAccessor;
		var runewordsNode, runesNode, baseAbilitiesNode: SCustomNode;
			
		dm = theGame.GetDefinitionsManager();
		runewordsNode = dm.GetCustomDefinition('runewords');
				
		for(i=0; i<runewordsNode.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueName(runewordsNode.subNodes[i], 'name_name', tmpName);
			runeword.wordName = tmpName;
			
			runesNode = dm.GetCustomDefinitionSubNode(runewordsNode.subNodes[i], 'runes');
			
			for(j=0; j<runesNode.subNodes.Size(); j+=1)
			{	
				tmpName = runesNode.subNodes[j].values[0];
				runeword.runes.PushBack(tmpName);
			}
			
			baseAbilitiesNode = dm.GetCustomDefinitionSubNode(runewordsNode.subNodes[i], 'base_abilities');
			
			for(j=0; j<baseAbilitiesNode.subNodes.Size(); j+=1)
			{	
				tmpName = baseAbilitiesNode.subNodes[j].values[0];
				runeword.abilities.PushBack(tmpName);
			}
			runewords.PushBack(runeword);
		}
	}
	
	function GetRuneword( runes : array<name>, out oRuneword : Runeword ) : bool
	{
		var i, j, size : int;
		var runeword : Runeword;
		
		for (i = 0; i <= runewords.Size(); i+=1)
		{
			runeword = runewords[i];
			if (runeword.runes.Size() !=  runes.Size())
			{
				continue;
			}
			
			size = runes.Size();
			for (j = 0; j < size; j+=1)
			{
				if (runeword.runes[j] != runes[j])
				{
					continue;
				}
			}
			oRuneword = runeword;
			return true;
		}
		return false;
	}
	
}