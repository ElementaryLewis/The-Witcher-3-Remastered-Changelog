/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4GlossaryBestiaryMenu extends CR4ListBaseMenu
{	
	default DATA_BINDING_NAME 		= "glossary.bestiary.list";
	default DATA_BINDING_NAME_SUBLIST	= "glossary.bestiary.sublist.items";
	default DATA_BINDING_NAME_DESCRIPTION	= "glossary.bestiary.description";
	
	var allCreatures					: array<CJournalCreature>;
	
	private var m_fxHideContent	 		: CScriptedFlashFunction;	
	private var m_fxSetTitle			: CScriptedFlashFunction;
	private var m_fxSetText				: CScriptedFlashFunction;
	private var m_fxSetImage			: CScriptedFlashFunction;
	
	event  OnConfigUI()
	{	
		var i							: int;
		var tempCreatures				: array<CJournalBase>;
		var creatureTemp				: CJournalCreature;
		var status						: EJournalStatus;
		super.OnConfigUI();
		
		m_initialSelectionsToIgnore = 2;
		
		m_journalManager.GetActivatedOfType( 'CJournalCreature', tempCreatures );
		
		for( i = 0; i < tempCreatures.Size(); i += 1 )
		{
			status = m_journalManager.GetEntryStatus( tempCreatures[i] );
			if( status == JS_Active )
			{
				creatureTemp = (CJournalCreature)tempCreatures[i];
				if( creatureTemp )
				{
					allCreatures.PushBack(creatureTemp); 
				}
			}
		}
		
		m_fxHideContent = m_flashModule.GetMemberFlashFunction("hideContent");
		
		m_fxSetTitle = m_flashModule.GetMemberFlashFunction("setTitle");
		m_fxSetText = m_flashModule.GetMemberFlashFunction("setText");
		m_fxSetImage = m_flashModule.GetMemberFlashFunction("setImage");
		
		ShowRenderToTexture("");
		m_flashValueStorage.SetFlashBool("journal.rewards.panel.visible",false);
		
		PopulateData();
		SelectCurrentModule();
		
		m_fxSetTooltipState.InvokeSelfTwoArgs( FlashArgBool( thePlayer.upscaledTooltipState ), FlashArgBool( true ) );
	}
	
	event  OnGuiSceneEntitySpawned(entity : CEntity)
	{
		UpdateSceneEntityFromCreatureDataComponent( entity );

		Event_OnGuiSceneEntitySpawned();
		
		UpdateItemsFromEntity(entity);
	}
	
	event  OnGuiSceneEntityDestroyed()
	{
		Event_OnGuiSceneEntityDestroyed();
	}
	
	event   OnEntrySelected( tag : name ) 
	{
		if (tag != '')
		{
			m_fxHideContent.InvokeSelfOneArg(FlashArgBool(true));
			super.OnEntrySelected(tag);			
		}
		else
		{		
			lastSentTag = '';
			currentTag = '';
			m_fxHideContent.InvokeSelfOneArg(FlashArgBool(false));
		}
	}
	
	event OnCategoryOpened( categoryName : name, opened : bool )
	{
		var player : W3PlayerWitcher;

		player = GetWitcherPlayer();
		if ( !player )
		{
			return false;
		}
		if ( opened )
		{
			player.AddExpandedBestiaryCategory( categoryName );
		}
		else
		{
			player.RemoveExpandedBestiaryCategory( categoryName );
		}

		
		super.OnCategoryOpened( categoryName, opened );
	}
	
	function UpdateImage( entryName : name )
	{
		var creature : CJournalCreature;
		var templatepath : string;
		
		
		creature = (CJournalCreature)m_journalManager.GetEntryByTag( entryName );
		
		if(creature)
		{
			templatepath = creature.GetEntityTemplateFilename();
			
			
				ShowRenderToTexture("");
				templatepath = thePlayer.ProcessGlossaryImageOverride( creature.GetImage(), entryName );
				m_fxSetImage.InvokeSelfOneArg(FlashArgString(templatepath));
			
			
			
			
			
		}
		else
		{
			ShowRenderToTexture("");
			m_fxSetImage.InvokeSelfOneArg(FlashArgString(""));
		}
	}

	private function PopulateData()
	{
		var l_DataFlashArray		: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		
		var i, length				: int;
		var l_creature 				: CJournalCreature;
		var l_creatureGroup			: CJournalCreatureGroup;

		
		var l_Title					: string;
		var l_Tag					: name;
		var l_CategoryTag			: name;
		var l_IconPath				: string;
		var l_GroupTitle			: string;
		var l_IsNew					: bool;
		
		var expandedBestiaryCategories : array< name >;
		
		expandedBestiaryCategories = GetWitcherPlayer().GetExpandedBestiaryCategories();
		
		l_DataFlashArray = m_flashValueStorage.CreateTempFlashArray();
		length = allCreatures.Size();
		
		for( i = 0; i < length; i+= 1 )
		{	
			l_creature = allCreatures[i];
			
			l_creatureGroup = (CJournalCreatureGroup)m_journalManager.GetEntryByGuid( l_creature.GetLinkedParentGUID() );
			l_GroupTitle = GetLocStringById( l_creatureGroup.GetNameStringId() );	
			l_CategoryTag = l_creatureGroup.GetUniqueScriptTag();
			
			l_Title = GetLocStringById( l_creature.GetNameStringId() );
			l_Tag = l_creature.GetUniqueScriptTag();
			l_IconPath = thePlayer.ProcessGlossaryImageOverride( l_creature.GetImage(), l_Tag );
			l_IsNew	= m_journalManager.IsEntryUnread( l_creature );
			
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
				
			l_DataFlashObject.SetMemberFlashUInt(  "tag", NameToFlashUInt(l_Tag) );
			l_DataFlashObject.SetMemberFlashString(  "dropDownLabel", l_GroupTitle );
			l_DataFlashObject.SetMemberFlashUInt(  "dropDownTag",  NameToFlashUInt(l_CategoryTag) );
			l_DataFlashObject.SetMemberFlashBool(  "dropDownOpened", expandedBestiaryCategories.Contains( l_CategoryTag ) );
			l_DataFlashObject.SetMemberFlashString(  "dropDownIcon", "icons/monsters/ICO_MonsterDefault.png" );
			
			l_DataFlashObject.SetMemberFlashBool( "isNew", l_IsNew );
			l_DataFlashObject.SetMemberFlashBool( "selected", ( l_Tag == currentTag ) );			
			l_DataFlashObject.SetMemberFlashString(  "label", l_Title );
			l_DataFlashObject.SetMemberFlashString(  "iconPath", "icons/monsters/"+l_IconPath );
			
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
		}
		
		if( l_DataFlashArray.GetLength() > 0 )
		{
			m_flashValueStorage.SetFlashArray( DATA_BINDING_NAME, l_DataFlashArray );
			m_fxShowSecondaryModulesSFF.InvokeSelfOneArg(FlashArgBool(true));
		}
		else
		{
			m_fxShowSecondaryModulesSFF.InvokeSelfOneArg(FlashArgBool(false));
		}
	}

    
	function GetDescription( currentCreature : CJournalCreature ) : string 
	{
		var i : int;
		var currentIndex:int;
		var str : string;
		var locStrId : int;
		var descriptionsGroup, tmpGroup : CJournalCreatureDescriptionGroup;
		var description : CJournalCreatureDescriptionEntry;
		
		var placedString : bool;
		var currentJournalDescriptionText : JournalDescriptionText;
		var journalDescriptionArray : array<JournalDescriptionText>;
		
		str = "";
		for( i = 0; i < currentCreature.GetNumChildren(); i += 1 )
		{
			tmpGroup = (CJournalCreatureDescriptionGroup)(currentCreature.GetChild(i));
			if( tmpGroup )
			{
				descriptionsGroup = tmpGroup;
				break;
			}
		}
		for ( i = 0; i < descriptionsGroup.GetNumChildren(); i += 1 )
		{
			description = (CJournalCreatureDescriptionEntry)descriptionsGroup.GetChild(i);
			if( m_journalManager.GetEntryStatus(description) == JS_Active )
			{
				
				currentJournalDescriptionText.stringKey = description.GetDescriptionStringId();
				currentJournalDescriptionText.order = description.GetOrder();
				currentJournalDescriptionText.groupOrder = descriptionsGroup.GetOrder();
				
				if (journalDescriptionArray.Size() == 0)
				{
					journalDescriptionArray.PushBack(currentJournalDescriptionText);
				}
				else
				{
					placedString = false;
					
					for (currentIndex = 0; currentIndex < journalDescriptionArray.Size(); currentIndex += 1)
					{
						if (journalDescriptionArray[currentIndex].groupOrder > currentJournalDescriptionText.groupOrder ||
							(journalDescriptionArray[currentIndex].groupOrder <= currentJournalDescriptionText.groupOrder && 
							 journalDescriptionArray[currentIndex].order > currentJournalDescriptionText.order))
						{
							journalDescriptionArray.Insert(Max(0, currentIndex), currentJournalDescriptionText);
							placedString = true;
							break;
						}
					}
					
					if (!placedString)
					{
						journalDescriptionArray.PushBack(currentJournalDescriptionText);
					}
				}
			}
		}
		
		for ( i = 0; i < journalDescriptionArray.Size(); i += 1 )
		{
			str += GetLocStringById(journalDescriptionArray[i].stringKey) + "<br>";
		}
		
		if( str == "" || str == "<br>" )
		{
			str = GetLocStringByKeyExt("panel_journal_quest_empty_description");
		}
		
		return str;
	}
	
	function UpdateDescription( entryName : name )
	{
		var l_creature : CJournalCreature;
		var description : string;
		var title : string;
		
		
		l_creature = (CJournalCreature)m_journalManager.GetEntryByTag( entryName );
		description = GetDescription( l_creature );
		title = GetLocStringById( l_creature.GetNameStringId());	
		
		m_fxSetTitle.InvokeSelfOneArg(FlashArgString(title));
		m_fxSetText.InvokeSelfOneArg(FlashArgString(description));
	}	

	function UpdateItems( tag : name )
	{
		var itemsFlashArray			: CScriptedFlashArray;
		var l_creature : CJournalCreature;
		var l_creatureParams : SJournalCreatureParams;
		var l_creatureEntityTemplateFilename : string;
		
		
		
		l_creature = (CJournalCreature)m_journalManager.GetEntryByTag( tag );
		
		itemsNames = l_creature.GetItemsUsedAgainstCreature();
		itemsFlashArray = CreateItems(itemsNames);

		if( itemsFlashArray && itemsFlashArray.GetLength() > 0 )
		{
			m_flashValueStorage.SetFlashBool("journal.rewards.panel.visible",true);
			m_flashValueStorage.SetFlashArray(DATA_BINDING_NAME_SUBLIST, itemsFlashArray );
		}
		else
		{
			m_flashValueStorage.SetFlashBool("journal.rewards.panel.visible", false);
		}
	}
	
	function UpdateItemsFromEntity( entity : CEntity ) : void
	{
		var l_creature 				: CJournalCreature;
		var creatureDataComponent	: CCreatureDataComponent;
		var itemsFlashArray			: CScriptedFlashArray;
		
		l_creature = (CJournalCreature)m_journalManager.GetEntryByTag( currentTag );
		
		if (l_creature && m_journalManager.GetEntryHasAdvancedInfo(l_creature))
		{
			creatureDataComponent = (CCreatureDataComponent)(entity.GetComponentByClassName('CCreatureDataComponent'));
			
			if (creatureDataComponent)
			{
				itemsFlashArray = CreateItems(creatureDataComponent.GetItemsUsedAgainstCreature());
			}
		}
		
		if( itemsFlashArray )
		{
			m_flashValueStorage.SetFlashBool("journal.rewards.panel.visible",true);
			m_flashValueStorage.SetFlashArray(DATA_BINDING_NAME_SUBLIST, itemsFlashArray );
		}
		else
		{
			m_flashValueStorage.SetFlashBool("journal.rewards.panel.visible",false);
		}
	}
	
	private function CreateItems( itemsNames : array< name > ) : CScriptedFlashArray
	{
		var l_flashArray				: CScriptedFlashArray;
		var l_flashObject				: CScriptedFlashObject;
		var i 							: int;
		var dm 							: CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var curName						: name;
		var curLocName					: string;
		var curIconPath					: string;
		
		if( itemsNames.Size() < 1 )
		{
			return NULL;
		}
		
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		for( i = 0; i < itemsNames.Size(); i += 1 )
		{
			curName = itemsNames[i];


			
			TryGetSignData(curName, curLocName, curIconPath);
			if (curLocName == "")
			{
				curIconPath = dm.GetItemIconPath( curName );
			}
			l_flashObject = m_flashValueStorage.CreateTempFlashObject("red.game.witcher3.menus.common.ItemDataStub");
			l_flashObject.SetMemberFlashInt( "id", i + 1 ); 
			l_flashObject.SetMemberFlashInt( "quantity", 1 );
			l_flashObject.SetMemberFlashString( "iconPath",  curIconPath);
			l_flashObject.SetMemberFlashInt( "gridPosition", i );
			l_flashObject.SetMemberFlashInt( "gridSize", 1 );
			l_flashObject.SetMemberFlashInt( "slotType", 1 );	
			l_flashObject.SetMemberFlashBool( "isNew", false );
			l_flashObject.SetMemberFlashBool( "needRepair", false );
			l_flashObject.SetMemberFlashInt( "actionType", IAT_None );
			l_flashObject.SetMemberFlashInt( "price", 0 ); 		
			l_flashObject.SetMemberFlashString( "userData", "");
			l_flashObject.SetMemberFlashString( "category", "" );
			l_flashObject.SetMemberFlashString("itemName", NameToString(curName));
			l_flashArray.PushBackFlashObject(l_flashObject);
		}
		
		return l_flashArray;
	}
	
	private function TryGetSignData(signName : name, out localizationKey : string, out iconPath : string):void
	{
		switch (signName)
		{
			case 'Yrden':
				localizationKey = "Yrden";
				iconPath = "hud/radialmenu/mcYrden.png";
				break;
			case 'Quen':
				localizationKey = "Quen";
				iconPath = "hud/radialmenu/mcQuen.png";
				break;
			case 'Igni':
				localizationKey = "Igni";
				iconPath = "hud/radialmenu/mcIgni.png";
				break;
			case 'Axii':
				localizationKey = "Axii";
				iconPath = "hud/radialmenu/mcAxii.png";
				break;
			case 'Aard':
				localizationKey = "Aard";
				iconPath = "hud/radialmenu/mcAard.png";
				break;
			default:
				localizationKey = "";
				iconPath = "";
		}
	}
	
	event OnGetItemData(item : int, compareItemType : int) 
	{
		
		
		var itemName 			: string;
		var category			: name;
		var typeStr				: string;
		var weight 				: float;
		var iconPath			: string;
		
		var resultData 			: CScriptedFlashObject;
		var statsList			: CScriptedFlashArray;		
		var dm 					: CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		
		item = item - 1;
		itemName = itemsNames[item];
		resultData = m_flashValueStorage.CreateTempFlashObject();
		statsList = m_flashValueStorage.CreateTempFlashArray();
		
		TryGetSignData(itemsNames[item], itemName, iconPath);
		if (itemName == "")
		{
			iconPath = dm.GetItemIconPath( itemsNames[item] );
			itemName = dm.GetItemLocalisationKeyName( itemsNames[item] );
			category = dm.GetItemCategory(itemsNames[item]);
			typeStr = GetItemCategoryLocalisedString( category );
		}
		else
		{
			typeStr = GetLocStringByKeyExt( "panel_character_skill_signs" );
		}
		
		itemName = GetLocStringByKeyExt(itemName);
		resultData.SetMemberFlashString("ItemName", itemName);
		
		resultData.SetMemberFlashString("PriceValue", dm.GetItemPrice(itemsNames[item]));
		
		resultData.SetMemberFlashString("ItemRarity", "" );
		
		resultData.SetMemberFlashString("ItemType", typeStr );
		
		resultData.SetMemberFlashString("DurabilityValue", "");

		resultData.SetMemberFlashString("IconPath", iconPath );
		resultData.SetMemberFlashString("ItemCategory", category);
		m_flashValueStorage.SetFlashObject("context.tooltip.data", resultData);
	}
	
	function PlayOpenSoundEvent()
	{
		
		
	}

	event  OnCloseMenu()
	{
		var commonMenu : CR4CommonMenu;
		var glossaryMainMenu : CR4GlossaryMainMenu;
		
		commonMenu = (CR4CommonMenu)m_parentMenu;
		glossaryMainMenu = (CR4GlossaryMainMenu)m_parentMenu;
		
		if( commonMenu )
		{
			commonMenu.ChildRequestCloseMenu();
		}
		if(glossaryMainMenu)
		{
			glossaryMainMenu.ChildRequestCloseMenu();
		}
		
		theSound.SoundEvent( 'gui_global_quit' );
		
		CloseMenu();
	}
}

exec function testbes()
{
	var manager : CWitcherJournalManager;
	
	manager = theGame.GetJournalManager();
	
	activateJournalBestiaryEntryWithAlias("BestiaryArmoredArachas", manager);
}