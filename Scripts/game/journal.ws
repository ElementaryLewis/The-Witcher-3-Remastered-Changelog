/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CJournalBase extends CObject
{
	import public const var guid : CGUID;
	
	
	import public const var baseName : string;
	
	import final function GetUniqueScriptTag() : name;
	import final function GetOrder() : int;
}

import class CJournalChildBase extends CJournalBase
{
	import public function GetLinkedParentGUID() : CGUID;
}

import class CJournalContainerEntry extends CJournalChildBase
{
}

import class CJournalContainer extends CJournalContainerEntry
{
	import final function GetChild( index : int ) : CJournalBase;
	import final function GetNumChildren() : int;
}




import class CJournalQuestObjective extends CJournalContainer
{
	import final function GetTitleStringId() : int;
	import final function GetWorld() : int;
	import final function GetCount() : int;
	import final function GetCounterType() : eQuestObjectiveType;
	import final function IsMutuallyExclusive() : bool;
	import final function GetBookShortcut() : name;
	import final function GetItemShortcut() : name;
	import final function GetRecipeShortcut() : name;
	import final function GetMonsterShortcut() : CJournalBase;
	import final function GetParentQuest() : CJournalQuest;
}

import class CJournalQuestMapPin extends CJournalContainerEntry
{
	import final function GetMapPinID() : name;
	import final function GetRadius() : float;
}

import class CJournalQuestPhase extends CJournalContainer
{
}

import class CJournalQuest extends CJournalContainer
{
	import final function GetTitleStringId() : int;
	import final function GetType() : eQuestType;
	import final function GetContentType() : EJournalContentType;
	import final function GetWorld() : int;
	import final function GetHuntingQuestCreatureTag() : name;
}

import class CJournalQuestDescriptionGroup extends CJournalContainer
{	
}

import class CJournalQuestDescriptionEntry extends CJournalContainerEntry
{
	import final function GetDescriptionStringId() : int;
}

import class CJournalQuestGroup extends CJournalBase
{
	import final function GetTitleStringId() : int;
}


import class CJournalCreatureGroup extends CJournalBase
{
	import final function GetNameStringId() : int;
	import final function GetImage() : string;
}

import class CJournalCreature extends CJournalContainer
{
	import final function GetNameStringId() : int;
	import final function GetImage() : string;
	import final function GetEntityTemplateFilename() : string;
	import final function GetItemsUsedAgainstCreature() : array< name >;
}

import class CJournalCreatureDescriptionGroup extends CJournalContainer
{
}

import class CJournalCreatureDescriptionEntry extends CJournalContainerEntry
{
	import final function GetDescriptionStringId() : int;
}

import class CJournalCreatureHuntingClueGroup extends CJournalContainer
{
}

import class CJournalCreatureHuntingClue extends CJournalContainerEntry
{
	
	import public const var category : name;
	
	
	import public const var clue : int;
}

import class CJournalCreatureVitalSpotEntry extends CJournalContainerEntry
{
	import final function GetTitleStringId() : int;
	
	import final function GetDescriptionStringId() : int;
	import final function GetCreatureEntry() : CJournalCreature;
}

import class CJournalCharacterGroup extends CJournalBase
{
}

import class CJournalCharacter extends CJournalContainer
{
	import final function GetNameStringId() : int;
	import final function GetImagePath() : string;
	import final function GetCharacterImportance() : ECharacterImportance;
	import final function GetEntityTemplateFilename() : string;
}

import class CJournalCharacterDescription extends CJournalContainerEntry
{
	import final function GetDescriptionStringId() : int;
}

import class CJournalGlossaryGroup extends CJournalBase
{
}

import class CJournalGlossary extends CJournalContainer
{
	import final function GetTitleStringId() : int;
	import final function GetImagePath() : string;
}

import class CJournalGlossaryDescription extends CJournalContainerEntry
{
	import final function GetDescriptionStringId() : int;
}

import class CJournalTutorialGroup extends CJournalBase
{
    import final function GetNameStringId() : int;
    import final function GetImage() : string;
}

import class CJournalTutorial extends CJournalChildBase
{
	import final function GetDescriptionStringId() : int;
	import final function GetNameStringId() : int;
	import final function GetImagePath() : string;
	import final function GetVideoPath() : string;
	import final function GetDLCLock() : name;
}

import class CJournalStoryBookChapter extends CJournalBase
{
	import final function GetTitleStringId() : int;
	import final function GetImage() : string;
}

import class CJournalStoryBookPage extends CJournalContainer
{
	import final function GetTitleStringId() : int;
}

import class CJournalStoryBookPageDescription extends CJournalContainerEntry
{
	import final function GetVideoFilename() : string;
	import final function GetDescriptionStringId() : int;
}



import class CJournalPlaceGroup extends CJournalBase
{
	import final function GetNameStringId() : int;
	import final function GetImage() : string;
}

import class CJournalPlace extends CJournalContainer
{
	import final function GetNameStringId() : int;
	import final function GetImage() : string;
}

import class CJournalPlaceDescription extends CJournalContainerEntry
{
	import final function GetDescriptionStringId() : int;
}


import class CJournalManager extends IGameSystem
{
	import final function ActivateEntry			(	journalEntry : CJournalBase, optional status : EJournalStatus, optional showInfoOnScreen : bool, optional activateParents : bool );
	import final function GetEntryStatus		(	journalEntry : CJournalBase ) : EJournalStatus;
	import final function GetEntryIndex			(	journalEntry : CJournalBase ) : int;
	
	import final function IsEntryUnread			(	journalEntry : CJournalBase ) : bool;
	import final function SetEntryUnread		(	journalEntry : CJournalBase, isUnread : bool );

	
	import final function GetNumberOfActivatedOfType( type : name ) : int;
	
	import final function GetActivatedOfType	( type : name, out entries : array< CJournalBase > );
	import final function GetNumberOfActivatedChildren( parentEntry : CJournalBase ) : int;
	import final function GetActivatedChildren( parentEntry : CJournalBase, out entries : array< CJournalBase > );
	
	import final function GetNumberOfAllChildren( parentEntry : CJournalBase ) : int;
	import final function GetAllChildren( parentEntry : CJournalBase, out entries : array< CJournalBase > );
	
	import final function GetEntryByTag			( tag : name ) : CJournalBase;
	import final function GetEntryByString		( str : string ) : CJournalBase;
	import final function GetEntryByGuid		( guid : CGUID ) : CJournalBase;
	
	final function ActivateEntryByScriptTag(scriptTag : name, optional status : EJournalStatus, optional showInfoOnScreen : bool, optional activateParents : bool )
	{
		var ent : CJournalBase;
		
		ent = ((CJournalResource)LoadResource(scriptTag)).GetEntry();
		ActivateEntry(ent, status, showInfoOnScreen, activateParents);
	}
}

import struct SJournalCreatureParams
{
	import var abilities			: array< name >;
	import var autoEffects			: array< name >;
	import var buffImmunity			: CBuffImmunity;
	import var monsterCategory		: int;
	import var isTeleporting		: bool;
	import var droppedItems			: array< name >;
};

import struct SJournalQuestObjectiveData
{
	import var status : EJournalStatus;
	import const var objectiveEntry : CJournalQuestObjective;
};


import class CWitcherJournalManager extends CJournalManager
{	
	function GetCurrentlyBuffedCreature():CJournalCreature
	{
		var foundCreature : CJournalCreature;
		var monsterName : name;
		
		monsterName = GetCurrentlyBuffedCreatureName();
		
		if (monsterName)
		{
			foundCreature = (CJournalCreature)GetEntryByTag(monsterName);
		}
		
		return foundCreature;
	}
	
	
	function GetCurrentlyBuffedCreatureName():name
	{
		var curGameTime : GameTime;
		var currentDayPart:EDayPart;
		var currentWeatherEffect:EWeatherEffect;
		var currentMoonState:EMoonState;
		var monsterTag:name;
		
		monsterTag = '';
		curGameTime = theGame.GetGameTime();
		currentDayPart = GetDayPart(curGameTime);
		currentWeatherEffect = GetCurWeather();
		currentMoonState = GetCurMoonState();
		
		
		if (currentWeatherEffect == EWE_Clear || currentWeatherEffect == EWE_None)
		{
			switch (currentDayPart)
			{
			case EDP_Undefined:
			case EDP_Dawn:
				monsterTag = 'Baba cmentarna'; 
				break;
			case EDP_Noon:
				monsterTag = 'bestiary_noonwright'; 
				break;
			case EDP_Dusk:
				monsterTag = 'bestiary_alghoul'; 
				break;
			case EDP_Midnight:
				if (currentMoonState == EMS_Red)
				{
					monsterTag = 'Ogar Dzikiego Gonu'; 
				}
				else if (currentMoonState == EMS_Full)
				{
					monsterTag = 'bestiary_werewolf'; 
				}
				else 
				{
					monsterTag = 'bestiary_moonwright'; 
				}
				break;
			}
		}
		else if (currentWeatherEffect == EWE_Snow)
		{
			switch (currentDayPart)
			{
			case EDP_Undefined:
			case EDP_Dawn:
				monsterTag = 'bestiary_icegiant'; 
				break;
			case EDP_Noon:
				monsterTag = 'Troll lodowy'; 
				break;
			case EDP_Dusk:
				monsterTag = 'bestiary_icegiant';
				break;
			case EDP_Midnight:
				if (currentMoonState == EMS_Red)
				{
					monsterTag = 'Ogar Dzikiego Gonu'; 
				}
				else if (currentMoonState == EMS_Full)
				{
					monsterTag = 'bestiary_werewolf'; 
				}
				else 
				{
					monsterTag = 'bestiary_wraith'; 
				}
				break;
			}
		}
		else if (currentWeatherEffect == EWE_Rain || currentWeatherEffect == EWE_Storm)
		{
			switch (currentDayPart)
			{
			case EDP_Undefined:
			case EDP_Dawn:
				monsterTag = 'Baba wodna'; 
				break;
			case EDP_Noon:
				monsterTag = 'Baba wodna'; 
				break;
			case EDP_Dusk:
				monsterTag = 'Utopiec'; 
				break;
			case EDP_Midnight:
				if (currentMoonState == EMS_Red)
				{
					monsterTag = 'Ogar Dzikiego Gonu'; 
				}
				else if (currentMoonState == EMS_Full)
				{
					monsterTag = 'bestiary_werewolf'; 
				}
				else 
				{
					monsterTag = 'bestiary_greater_rotfiend'; 
				}
				break;
			}
		}
		
		return monsterTag;
	}

	import final function SetTrackedQuest					( journalEntry : CJournalBase );
	import final function GetTrackedQuest					() : CJournalQuest;
	import final function GetHighlightedQuest				() : CJournalQuest;
	import final function GetHighlightedObjective			() : CJournalQuestObjective;
	import final function SetHighlightedObjective			( journalEntry : CJournalBase ) : bool;
	import final function SetPrevNextHighlightedObjective	( optional next : bool ) : bool;
	
	import final function GetCreaturesWithHuntingQuestClue	( categoryName : name, clueIndex : int,	out creatures : array< CJournalCreature > );
	import final function GetNumberOfCluesFoundForQuest		( huntingQuest : CJournalQuest ) : int;
	import final function GetAllCluesFoundForQuest			( huntingQuest : CJournalQuest, out creatures : array< CJournalCreatureHuntingClue > );
	import final function SetHuntingClueFoundForQuest		( huntingQuest : CJournalQuest, huntingClue : CJournalCreatureHuntingClue );

	import final function GetTrackedQuestObjectivesData		( out objectives : array< SJournalQuestObjectiveData > );
	
	import final function GetQuestHasMonsterKnown			( journalEntry : CJournalBase ) : bool;
	import final function SetQuestHasMonsterKnown			( journalEntry : CJournalBase, isKnown : bool );
	
	import final function GetEntryHasAdvancedInfo			( journalEntry : CJournalBase ) : bool;
	import final function SetEntryHasAdvancedInfo			( journalEntry : CJournalBase, isKnown : bool );
	
	import final function GetQuestObjectiveCount	( questGuid : CGUID ) : int;
	import final function SetQuestObjectiveCount	( questGuid : CGUID, newCount : int );
	
	import final function GetCreatureParams( entityFilename : string, out params : SJournalCreatureParams ) : bool;

	import final function ToggleDebugInfo( debugInfo : int );
	import final function ShowLoadingScreenVideo( debugVideo : bool );

	import final function GetQuestRewards( journalQuest : CJournalQuest ) : array< name >;
	import final function GetRegularQuestCount() : int;
	import final function GetMonsterHuntQuestCount() : int;
	import final function GetTreasureHuntQuestCount() : int;
	import final function GetQuestProgress() : int;
	
	import final function GetJournalAreasWithQuests() : array< int >;
	
	import final function ForceSettingLoadingScreenVideoForWorld( area : int );
	import final function ForceSettingLoadingScreenContextNameForWorld( contextName : name );
	
	import final function ForceUntrackingQuestForEP1Savegame();
}

import class CJournalResource extends CResource
{
    import final function GetEntry() : CJournalBase;
}


exec function toggleqt()
{
	theGame.GetJournalManager().ToggleDebugInfo( 1 );
}

exec function togglejdbg()
{
	theGame.GetJournalManager().ToggleDebugInfo( 2 );
}

exec function showQuestGroups()
{
	theGame.GetJournalManager().ToggleDebugInfo( 3 );
}

exec function showLoadingScreenVideo( show : bool )
{
	theGame.GetJournalManager().ShowLoadingScreenVideo( show );
}

exec function testMonsterFind()
{
	var manager : CWitcherJournalManager;
	var resource : CJournalResource;
	var entryBase : CJournalBase;
	
	manager = theGame.GetJournalManager();
	
	resource = (CJournalResource)LoadResource( "gameplay\journal\quests\dbgjasonmonster.journal", true );
	
	if (resource)
	{
		entryBase = resource.GetEntry();
		if ( entryBase )
		{
			manager.SetQuestHasMonsterKnown(entryBase, true);
		}
	}
}

exec function testMonsterAdvanced()
{
	var manager : CWitcherJournalManager;
	var resource : CJournalResource;
	var entryBase : CJournalBase;
	
	manager = theGame.GetJournalManager();
	
	resource = (CJournalResource)LoadResource( "BestiaryHim" );
	
	if (resource)
	{
		entryBase = resource.GetEntry();
		if ( entryBase )
		{
			manager.SetEntryHasAdvancedInfo(entryBase, true);
		}
	}
}




function activateJournalBestiaryEntryWithAlias(entryAlias:string, journalManager:CWitcherJournalManager):void
{
	var i, j : int;
	var resource : CJournalResource;
	var entryBase : CJournalBase;
	var childGroups : array<CJournalBase>;
	var childEntries : array<CJournalBase>;
	var descriptionGroup : CJournalCreatureDescriptionGroup;
	var descriptionEntry : CJournalCreatureDescriptionEntry;
	
	resource = (CJournalResource)LoadResource( entryAlias );
	if ( resource )
	{
		entryBase = resource.GetEntry();
		if ( entryBase )
		{
			journalManager.ActivateEntry( entryBase, JS_Active );
			
			journalManager.SetEntryHasAdvancedInfo( entryBase, true );
			
			
			journalManager.GetAllChildren( entryBase, childGroups );
			for ( i = 0; i < childGroups.Size(); i += 1 )
			{
				descriptionGroup = ( CJournalCreatureDescriptionGroup )childGroups[ i ];
				if ( descriptionGroup )
				{
					journalManager.GetAllChildren( descriptionGroup, childEntries );
					for ( j = 0; j < childEntries.Size(); j += 1 )
					{
						descriptionEntry = ( CJournalCreatureDescriptionEntry )childEntries[ j ];
						if ( descriptionEntry )
						{
							journalManager.ActivateEntry( descriptionEntry, JS_Active );
						}
					}
					return;
				}
			}
		}
	}
}

function activateJournalGlossaryGroupWithAlias(entryAlias:string, journalManager:CWitcherJournalManager):void
{
	var i, j : int;
	var resource : CJournalResource;
	var entryBase : CJournalBase;
	var childEntries : array<CJournalBase>;
	var descriptionEntry : CJournalGlossaryDescription;
	
	resource = (CJournalResource)LoadResource( entryAlias );
	if ( resource )
	{
		entryBase = resource.GetEntry();
		if ( entryBase )
		{
			journalManager.ActivateEntry( entryBase, JS_Active );
			
			
			journalManager.GetAllChildren( entryBase, childEntries );
			for ( i = 0; i < childEntries.Size(); i += 1 )
			{
				descriptionEntry = ( CJournalGlossaryDescription )childEntries[ i ];
				if ( descriptionEntry )
				{
					journalManager.ActivateEntry( descriptionEntry, JS_Active );
				}
			}
		}
	}
}

function activateJournalStoryBookPageEntryWithAlias(entryAlias:string, journalManager:CWitcherJournalManager):void
{
	var i, j : int;
	var resource : CJournalResource;
	var entryBase : CJournalBase;
	var childEntries : array<CJournalBase>;
	var descriptionEntry : CJournalStoryBookPageDescription;
	
	resource = (CJournalResource)LoadResource( entryAlias );
	if ( resource )
	{
		entryBase = resource.GetEntry();
		if ( entryBase )
		{
			journalManager.ActivateEntry( entryBase, JS_Active );
			
			
			journalManager.GetAllChildren( entryBase, childEntries );
			for ( i = 0; i < childEntries.Size(); i += 1 )
			{
				descriptionEntry = ( CJournalStoryBookPageDescription )childEntries[ i ];
				if ( descriptionEntry )
				{
					journalManager.ActivateEntry( descriptionEntry, JS_Active );
				}
			}
		}
	}
}

function activateJournalCharacterEntryWithAlias(entryAlias:string, journalManager:CWitcherJournalManager):void
{
	var i, j : int;
	var resource : CJournalResource;
	var entryBase : CJournalBase;
	var childEntries : array<CJournalBase>;
	var descriptionEntry : CJournalCharacterDescription;
	
	resource = (CJournalResource)LoadResource( entryAlias );
	
	if ( resource )
	{
		entryBase = resource.GetEntry();
		if ( entryBase )
		{
			journalManager.ActivateEntry( entryBase, JS_Active );
			
			
			journalManager.GetAllChildren( entryBase, childEntries );
			for ( i = 0; i < childEntries.Size(); i += 1 )
			{
				descriptionEntry = ( CJournalCharacterDescription )childEntries[ i ];
				if ( descriptionEntry )
				{
					journalManager.ActivateEntry( descriptionEntry, JS_Active );
				}
			}
		}
	}
}

function activateBaseBestiaryEntryWithAlias(entryAlias:string, journalManager:CWitcherJournalManager):void
{
	var i, j : int;
	var resource : CJournalResource;
	var entryBase : CJournalBase;
	var childGroups : array<CJournalBase>;
	var childEntries : array<CJournalBase>;
	var descriptionGroup : CJournalCreatureDescriptionGroup;
	var descriptionEntry : CJournalCreatureDescriptionEntry;
	var childJournal : CJournalBase;
	var minOrder : int;
	var minOrderIndex : int;
	
	resource = (CJournalResource)LoadResource( entryAlias );
	
	if ( resource )
	{
		entryBase = resource.GetEntry();
		if ( entryBase )
		{
			journalManager.ActivateEntry( entryBase, JS_Active );
			
			journalManager.SetEntryHasAdvancedInfo( entryBase, true );
			
			
			journalManager.GetAllChildren( entryBase, childGroups );
			for ( i = 0; i < childGroups.Size(); i += 1 )
			{
				descriptionGroup = ( CJournalCreatureDescriptionGroup )childGroups[ i ];
				childJournal = childGroups[ i ];
				if ( descriptionGroup )
				{
					journalManager.GetAllChildren( descriptionGroup, childEntries );
					
					
					minOrderIndex = -1;
					for ( j = 0; j < childEntries.Size(); j += 1 )
					{
						descriptionEntry = ( CJournalCreatureDescriptionEntry )childEntries[ j ];
						if ( descriptionEntry )
						{
							if ( j == 0 )
							{
								minOrder = descriptionEntry.GetOrder();
								minOrderIndex = j;
							}
							else
							{
								if ( minOrder > descriptionEntry.GetOrder() )
								{
									minOrder = descriptionEntry.GetOrder();
									minOrderIndex = j;
								}
							}
						}
					}
					if ( minOrderIndex > -1 )
					{
						journalManager.ActivateEntry( childEntries[ minOrderIndex ], JS_Active );
					}
					return;
				}
				else if ( childJournal )
				{
					journalManager.ActivateEntry( childJournal, JS_Active );
				}
			}
		}
	}
}
