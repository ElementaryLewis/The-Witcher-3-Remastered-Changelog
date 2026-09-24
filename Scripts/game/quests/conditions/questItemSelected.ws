/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_ItemSelected extends CQuestScriptedCondition
{
	editable var itemName : name;
	
	function Evaluate() : bool
	{
		var id : SItemUniqueId;
		
		id = thePlayer.GetSelectedItemId();
		
		
		if(itemName == '')
		{			
			return thePlayer.inv.IsIdValid(id);
		}
		else
		{
			return itemName == thePlayer.inv.GetItemName(id);
		}
	}
}