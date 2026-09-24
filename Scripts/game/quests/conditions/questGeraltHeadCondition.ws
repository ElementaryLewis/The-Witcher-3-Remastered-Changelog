/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_PlayerHead extends CQuestScriptedCondition
{
	editable var headItemName : name;
	editable var inverted : bool;
	
	function Evaluate() : bool
	{
		var currentHeadName : name;
		var headsMatch : bool;
		var ids : array<SItemUniqueId>;
		var inv : CInventoryComponent;
		var i: int;
		
		inv = thePlayer.GetInventory();
		ids = inv.GetItemsByCategory( 'head' );
		
		for( i=0; i < ids.Size(); i +=  1 )
		{
			if( inv.IsItemMounted( ids[i] ) )
			{
				currentHeadName = inv.GetItemName( ids[i] );
			}
		}
		
		if( currentHeadName == headItemName  )
			headsMatch = true;
		else
			headsMatch = false;
		
		if ( !inverted )
		{
			return headsMatch;
		}
		else
		{
			return !headsMatch;
		}
	}
}

class W3QuestCond_IsGeraltShaved extends CQuestScriptedCondition
{
	editable var inverted : bool;
	
	function Evaluate() : bool
	{
		var currentHeadName : name;
		var headsMatch : bool;
		var ids : array<SItemUniqueId>;
		var inv : CInventoryComponent;
		var i: int;
		
		inv = thePlayer.GetInventory();
		ids = inv.GetItemsByCategory( 'head' );
		
		for( i=0; i < ids.Size(); i +=  1 )
		{
			if( inv.IsItemMounted( ids[i] ) )
			{
				currentHeadName = inv.GetItemName( ids[i] );
			}
		}
		
		if( currentHeadName == 'head_0' || currentHeadName == 'head_0_tattoo' )
			headsMatch = true;
		else
			headsMatch = false;
		
		if ( !inverted )
		{
			return headsMatch;
		}
		else
		{
			return !headsMatch;
		}
	}
}