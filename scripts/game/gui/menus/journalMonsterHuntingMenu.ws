/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4JournalMonsterHuntingMenu extends CR4JournalQuestMenu
{	
	default DATA_BINDING_NAME 		= "journal.monsterhunting.list";
	default DATA_BINDING_NAME_SUBLIST	= "journal.monsterhunting.objectives.list";
	default DATA_BINDING_NAME_DESCRIPTION	= "journal.monsterhunting.description";
	
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
				if( questTemp.GetType() == MonsterHunt  )
				{
					allQuests.PushBack(questTemp);
				}
			}
		}
		
		ShowRenderToTexture("");
	}
	
	event  OnGuiSceneEntitySpawned(entity : CEntity)
	{
		UpdateSceneEntityFromCreatureDataComponent( entity );

		Event_OnGuiSceneEntitySpawned();
	}
	
	event  OnGuiSceneEntityDestroyed()
	{
		Event_OnGuiSceneEntityDestroyed();
	}
	
	function UpdateImage( entryName : name ) 
	{
		var creature : CJournalCreature;
		var questTemp : CJournalQuest;
		var monsterTag : name;
		var monsterStr : string;
		var templatepath : string;
		questTemp = (CJournalQuest)m_journalManager.GetEntryByTag(entryName);
		monsterTag = questTemp.GetHuntingQuestCreatureTag();
		creature = (CJournalCreature)m_journalManager.GetEntryByTag(monsterTag);
		
		if (m_journalManager.GetQuestHasMonsterKnown(questTemp))
		{
			if(creature)
			{
				templatepath = creature.GetEntityTemplateFilename();
				if (templatepath == "")
				{
					ShowRenderToTexture("characters\npc_entities\monsters\wraith_lvl1.w2ent");
				}
				else
				{
					ShowRenderToTexture(templatepath);
				}
			}
			else
			{
				ShowRenderToTexture("");
			}
		}
	}
	
	
}