/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4JournalTreasureHuntingMenu extends CR4JournalQuestMenu
{	
	default DATA_BINDING_NAME 		= "journal.treasure.list";
	default DATA_BINDING_NAME_SUBLIST	= "journal.treasure.objectives.list";
	default DATA_BINDING_NAME_DESCRIPTION	= "journal.treasurequest.description";
	
	function GetQuests()
	{
		var tempQuests					: array<CJournalBase>;
		var questTemp					: CJournalQuest;
		var i							: int;
		var questType					: eQuestType;
		
		m_journalManager.GetActivatedOfType( 'CJournalQuest', tempQuests );
		
		initialTrackedQuest = m_journalManager.GetTrackedQuest();
		
		for( i = 0; i < tempQuests.Size(); i += 1 )
		{
			questTemp = (CJournalQuest)tempQuests[i];
			if( questTemp )
			{
				if( questTemp.GetType() == TreasureHunt  )
				{
					allQuests.PushBack(questTemp);
				}
			}
		}
	}
	
	
}