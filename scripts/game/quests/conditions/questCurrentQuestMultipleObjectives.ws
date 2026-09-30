/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_CurrentQuestMultipleObjectives extends CQuestScriptedCondition
{
	editable var tutorialScriptTag : name;
		
	function Evaluate() : bool
	{
		var objectives : array< SJournalQuestObjectiveData >;
		var i : int;
		var count : int;

		theGame.GetJournalManager().GetTrackedQuestObjectivesData( objectives );

		for ( i = 0; i < objectives.Size(); i += 1 )
		{
			if ( objectives[ i ].status == JS_Active )
			{
				count += 1;
				if(count > 1)
					break;
			}
		}
			
		return count > 1;
	}
}