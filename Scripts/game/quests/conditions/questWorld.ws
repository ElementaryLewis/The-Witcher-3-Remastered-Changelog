/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_World extends CQuestScriptedCondition
{
	
	editable var currentArea : EAreaName;		default currentArea = AN_Undefined;
	
	editable var currentAreaName : name;		default currentAreaName = '';
	
	function Evaluate() : bool
	{
		var areaName : name = theGame.GetCommonMapManager().GetCurrentArea();

		
		if ( currentAreaName != '' )
		{
			return currentAreaName == areaName;
		}
		else
		{
			
			return theGame.GetCommonMapManager().GetDeprecatedAreaName( (int)currentArea ) == areaName;
		}			
	}
}

class W3QuestCond_Area extends CQuestScriptedCondition
{
	editable var currentAreaName : name;		default currentAreaName = '';
	
	function Evaluate() : bool
	{
		var currentArea : CName;

		theGame.GetCommonMapManager().GetCurrentJournalArea( currentArea );
		return currentAreaName == currentArea;
	}
}