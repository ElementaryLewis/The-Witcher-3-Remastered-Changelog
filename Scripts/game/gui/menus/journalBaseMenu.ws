/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4JournalBaseMenu extends CR4Menu 
{	
	private const var REWARDS_SIZE		:int; 			
	default REWARDS_SIZE 			= 4;
	
	private var m_journalManager		: CWitcherJournalManager;	
	private var m_flashValueStorage 	: CScriptedFlashValueStorage;
	var allQuests						: array<CJournalBase>;
	var _currentQuestID					: int;
	
	event  OnConfigUI()
	{	
		var tempQuests	: array<CJournalBase>;
		var tempQuest	: CJournalQuest;
		var i			: int;
		m_flashValueStorage = GetMenuFlashValueStorage();
		
		m_journalManager = theGame.GetJournalManager();
		m_journalManager.GetActivatedOfType( 'CJournalQuest', tempQuests );
	}

	event OnCloseMenu()
	{
		CloseMenu();
	}

	event OnQuestRead( _QuestID : int )
	{
		m_journalManager.SetEntryUnread( allQuests[_QuestID], false );
	}
	
	event OnActivateQuest( _QuestID : int )
	{
		m_journalManager.SetTrackedQuest( allQuests[ _QuestID ] );
	}		

	event OnQuestSelected( _QuestID : int )
	{
		LogChannel('JournalQuest',"_QuestID "+_QuestID);
		UpdateDescription(_QuestID);
		_currentQuestID = _QuestID;
		UpdateRewards();
	}
	
	
	event OnJournalTabSelected( ID : int )
	{
		LogChannel('JournalQuest',"OnJournalTabSelected "+ID);
	}	

	event  OnUpdateTooltipCompareData( item : SItemUniqueId, compareItemType : int, tooltipName : string )
	{
		var itemName : string;
		var compareItem : SItemUniqueId;
		var tooltipInv : CInventoryComponent;
		
		itemName = GetWitcherPlayer().GetInventory().GetItemName(item);
		if( tooltipName == "" ) 
		{
			tooltipName= "tooltip";
		}
		tooltipInv = GetWitcherPlayer().GetInventory();
		
		UpdateTooltipCompareData(item,compareItem,tooltipInv,tooltipName);
	}	
	
	
	private function PopulateData()
	{
		var l_questsFlashArray				: CScriptedFlashArray;
		var l_questsDataFlashObject 		: CScriptedFlashObject;
		
		var i, length				: int;
		var l_quest 						: CJournalQuest;
		
		var l_questTitle					: string;
		var l_questArea						: string;
		var l_questIsTracked				: bool;
		var l_questIsNew					: bool;
		var l_questIsStory					: bool;

		l_questsFlashArray = m_flashValueStorage.CreateTempFlashArray();
		length = allQuests.Size();
		
		for( i = 0; i < length; i+= 1 )
		{	
			l_quest = (CJournalQuest ) allQuests[i];
			
			l_questTitle 			= GetLocStringById( l_quest.GetTitleStringId()  );			
			l_questIsTracked 		= ( m_journalManager.GetTrackedQuest().guid == l_quest.guid );
			l_questIsStory			= (l_quest.GetType() == 0);	
			l_questIsNew			= m_journalManager.IsEntryUnread( l_quest );
			
			l_questArea				= " ";
			l_questArea				= GetAreaName(l_quest);

			l_questsDataFlashObject = m_flashValueStorage.CreateTempFlashObject();
			
			l_questsDataFlashObject.SetMemberFlashInt(  "id", i );
			l_questsDataFlashObject.SetMemberFlashString(  "dropdownLabel", l_questArea);
			l_questsDataFlashObject.SetMemberFlashString(  "area", l_questArea );
			l_questsDataFlashObject.SetMemberFlashString(  "title", l_questTitle );
			l_questsDataFlashObject.SetMemberFlashBool( "isStory", l_questIsStory );					
			l_questsDataFlashObject.SetMemberFlashBool( "isNew", l_questIsNew );
			l_questsDataFlashObject.SetMemberFlashBool( "isActive", l_questIsTracked );
			l_questsFlashArray.PushBackFlashObject(l_questsDataFlashObject);
		}
		
		
	}
	
	function UpdateRewards()
	{
		
	}
	
	function UpdateTooltipCompareData( item : SItemUniqueId, compareItem : SItemUniqueId, tooltipInv : CInventoryComponent , tooltipName : string )
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		
		var compareItemStats : array<SAttributeTooltip>;
		var itemStats : array<SAttributeTooltip>;
		var i,j, price : int;
		var nam, descript, fluff, category : string;
		var itemName : string;
		var itemWeight : float;
		
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		if( tooltipInv.IsIdValid( item ) )
		{
			itemName = tooltipInv.GetItemLocalizedNameByUniqueID(item);
			itemName = GetLocStringByKeyExt(itemName);
			m_flashValueStorage.SetFlashString(tooltipName+".title", itemName, -1 );
		}
		else
		{
			m_flashValueStorage.SetFlashString(tooltipName+".title", "", -1 );
			m_flashValueStorage.SetFlashString(tooltipName+".price", "", -1 );
			m_flashValueStorage.SetFlashString(tooltipName+".weight", "", -1 );
			m_flashValueStorage.SetFlashArray( tooltipName+".stats", l_flashArray );
			m_flashValueStorage.SetFlashString(tooltipName+".description", "", -1 );
			if( theGame.IsPadConnected() )
			{
				m_flashValueStorage.SetFlashString(tooltipName+".icon", "", -1 );
				m_flashValueStorage.SetFlashString(tooltipName+".category", "", -1 );
			}
			return;
		}

		tooltipInv.GetTooltipData(item, nam, descript, price, category, itemStats, fluff);

		itemName = "none";
		for( i = 0; i < itemStats.Size(); i += 1 ) 
		{
			l_flashObject = m_flashValueStorage.CreateTempFlashObject();
			l_flashObject.SetMemberFlashString("name",itemStats[i].attributeName);

			for( j = 0; j < compareItemStats.Size(); j += 1 )
			{
				itemName = "positive";
				if( itemStats[j].attributeName == compareItemStats[i].attributeName )
				{
					if( itemStats[j].value < compareItemStats[i].value )
					{
						itemName = "negative";
					}
					else if( itemStats[j].value == compareItemStats[i].value )
					{
						itemName = "neutral";
					}	
					break;
				}
			}
			l_flashObject.SetMemberFlashString("icon",itemName);
			
			if( itemStats[i].percentageValue )
			{
				l_flashObject.SetMemberFlashString("value",NoTrailZeros(itemStats[i].value * 100 ) +" %");
			}
			else
			{
				l_flashObject.SetMemberFlashString("value","+"+(int)NoTrailZeros(itemStats[i].value));
			}
			l_flashArray.PushBackFlashObject(l_flashObject);
		}	
		
		m_flashValueStorage.SetFlashArray( tooltipName+".stats", l_flashArray );
		m_flashValueStorage.SetFlashString(tooltipName+".price", tooltipInv.GetItemPriceModified( item, false ), -1 );
							
		itemWeight = GetWitcherPlayer().GetInventory().GetItemWeight( item );

		m_flashValueStorage.SetFlashString(tooltipName+".weight", itemWeight, -1  );
		m_flashValueStorage.SetFlashString(tooltipName+".description", GetLocStringByKeyExt("panel_inventory_tooltip_description_selected"), -1 ); 
		m_flashValueStorage.SetFlashBool(tooltipName+".display", true, -1 );
		if( theGame.IsPadConnected() )
		{
			m_flashValueStorage.SetFlashString(tooltipName+".icon", tooltipInv.GetItemIconPathByUniqueID(item), -1 );
			m_flashValueStorage.SetFlashString(tooltipName+".category", tooltipInv.GetItemCategory( item ), -1 );
		}
	}
	
	function GetAreaName( questEntry : CJournalQuest ) : string
	{
		var l_questArea						: string;
		switch ( questEntry.GetWorld() )
		{
			case 'AN_NMLandNovigrad':
				l_questArea = GetLocStringByKeyExt("panel_journal_filters_area_no_mans_land");
				break;
			case 'AN_Skellige_ArdSkellig':
				l_questArea = GetLocStringByKeyExt("panel_journal_filters_area_skellige");
				break;
			case 'AN_Kaer_Morhen':
				l_questArea = GetLocStringByKeyExt("panel_journal_filters_area_kaer_morhen");
				break;
			case 'AN_Prologue_Village':
				l_questArea = GetLocStringByKeyExt("panel_journal_filters_area_prolgue_village");
				break;

			
			case 'AN_Wyzima':
				break;
			case 'AN_Island_of_Myst':
				break;
			case 'AN_Spiral':
				break;
			case 'AN_Prologue_Village_Winter':
				break;
			case 'AN_Velen':
				break;
			default:
				l_questArea = GetLocStringByKeyExt("panel_journal_filters_area_any");
				break;
		}
		return l_questArea;
	}
	
	function GetDescription( currentQuest : CJournalQuest ) : string
	{
		var i : int;
		var str : string;
		var locStrId : int;
		var descriptionsGroup, tmpGroup : CJournalQuestDescriptionGroup;
		var description : CJournalQuestDescriptionEntry;
		
		for( i = 0; i < currentQuest.GetNumChildren(); i += 1 )
		{
			tmpGroup = (CJournalQuestDescriptionGroup)(currentQuest.GetChild(i));
			if( tmpGroup )
			{
				descriptionsGroup = tmpGroup;
				break;
			}
		}
		for( i = 0; i < descriptionsGroup.GetNumChildren(); i += 1 )
		{
			description = (CJournalQuestDescriptionEntry)descriptionsGroup.GetChild(i);
			if( m_journalManager.GetEntryStatus(description) == JS_Active )
			{
				locStrId = description.GetDescriptionStringId();
				str += GetLocStringById(locStrId)+"<br>";
			}
		}
		if( str == "" || str == "<br>" )
		{
			str = GetLocStringByKeyExt("panel_journal_quest_empty_description");
		}
		
		return str;
	}
	
	function UpdateDescription( currentQuestID : int )
	{
		var l_quest : CJournalQuest;
		var description : string;
		var title : string;
		
		l_quest = (CJournalQuest ) allQuests[currentQuestID];
		description = GetDescription( l_quest );
		title = GetLocStringByKeyExt("panel_journal_quest_description");
		
		m_flashValueStorage.SetFlashString("journal.quest.description.title",title,-1);
		m_flashValueStorage.SetFlashString("journal.quest.description.text",description,-1);	
	}
}