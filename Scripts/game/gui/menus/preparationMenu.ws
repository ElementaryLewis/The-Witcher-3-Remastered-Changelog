/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum PreparationTrackType
{
	PrepTrackType_None = 0,
	PrepTrackType_Journal = 1,
	PrepTrackType_Environment = 2
};

enum PreparationMenuTabIndexes
{
	PreparationMenuTab_Bombs = 0,
	PreparationMenuTab_Potion = 1,
	PreparationMenuTab_Oils = 2,
	PreparationMenuTab_Mutagens = 3
};


class CR4PreparationMenu extends CR4MenuBase
{
	protected var _gridInv 	 : W3GuiPreparationInventoryComponent;
	protected var _inv       : CInventoryComponent;
	
	event  OnConfigUI()
	{
		initMeditationState();
		m_flashModule = GetMenuFlash();
		m_flashValueStorage = GetMenuFlashValueStorage();
		
		super.OnConfigUI();
		
		_inv = thePlayer.GetInventory();
		_gridInv = new W3GuiPreparationInventoryComponent in this;
		_gridInv.Initialize( _inv );
		
		ShowRenderToTexture("");
		m_flashValueStorage.SetFlashBool("journal.rewards.panel.visible", false);
		
		setMenuMode();
		updateSlotsItems();
		
		UpdateOilSlotLocks();
		
		sendTrackedMonsterInfo();
	}
	
	event  OnCloseMenu()
	{
		var medd : W3PlayerWitcherStateMeditation;
		var waitt : W3PlayerWitcherStateMeditationWaiting;
		
		theSound.SoundEvent( 'gui_global_quit' ); 
		CloseMenu();
		if( m_parentMenu )
		{
			m_parentMenu.ChildRequestCloseMenu();
		}
		
		if (_gridInv)
		{
			delete _gridInv;
		}
		
		if(thePlayer.GetCurrentStateName() == 'MeditationWaiting')
		{
			waitt = (W3PlayerWitcherStateMeditationWaiting)thePlayer.GetCurrentState();
			if(waitt)
			{
				waitt.StopRequested();
			}
		}
		else
		{
			medd = (W3PlayerWitcherStateMeditation)GetWitcherPlayer().GetCurrentState();
			if(medd)
			{
				medd.StopRequested();
			}
		}
	}
	
	event  OnGuiSceneEntitySpawned(entity : CEntity)
	{
		Event_OnGuiSceneEntitySpawned();

		UpdateItemsFromEntity(entity);
	}
	
	event  OnGuiSceneEntityDestroyed()
	{
		Event_OnGuiSceneEntityDestroyed();
	}
	
	function UpdateItemsFromEntity( entity : CEntity ) : void
	{
		var l_creature 				: CJournalCreature;
		var hasCreature				: bool;
		var trackType				: PreparationTrackType;
		var creatureDataComponent	: CCreatureDataComponent;
		var itemsFlashArray			: CScriptedFlashArray;
		var journalManager 			: CWitcherJournalManager;
		
		journalManager = theGame.GetJournalManager();
		
		hasCreature = getCurrentTrackedCreatureTag(l_creature, trackType);
		
		if (hasCreature && l_creature && journalManager.GetEntryHasAdvancedInfo(l_creature))
		{
			creatureDataComponent = (CCreatureDataComponent)(entity.GetComponentByClassName('CCreatureDataComponent'));
			
			if (creatureDataComponent)
			{
				itemsFlashArray = CreateItems(creatureDataComponent.GetItemsUsedAgainstCreature());
			}
		}
		
		if( itemsFlashArray && itemsFlashArray.GetLength() > 0 )
		{
			m_flashValueStorage.SetFlashBool("journal.rewards.panel.visible",true);
			m_flashValueStorage.SetFlashArray("tracked.monster.recommended.items", itemsFlashArray );
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
		
		if( itemsNames.Size() < 1 )
		{
			return NULL;
		}
		
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
			
		for( i = 0; i < itemsNames.Size(); i += 1 )
		{
			l_flashObject = m_flashValueStorage.CreateTempFlashObject("red.game.witcher3.menus.common.ItemDataStub");
			l_flashObject.SetMemberFlashInt( "id", i + 1 ); 
			l_flashObject.SetMemberFlashInt( "quantity", 1 );
			l_flashObject.SetMemberFlashString( "iconPath",  dm.GetItemIconPath( itemsNames[i] ) );
			l_flashObject.SetMemberFlashInt( "gridPosition", i );
			l_flashObject.SetMemberFlashInt( "gridSize", 1 );
			l_flashObject.SetMemberFlashInt( "slotType", 1 );	
			l_flashObject.SetMemberFlashBool( "isNew", false );
			l_flashObject.SetMemberFlashBool( "needRepair", false );
			l_flashObject.SetMemberFlashInt( "actionType", IAT_None );
			l_flashObject.SetMemberFlashInt( "price", 0 ); 		
			l_flashObject.SetMemberFlashString( "userData", "");
			l_flashObject.SetMemberFlashString( "category", "" );
			l_flashArray.PushBackFlashObject(l_flashObject);
		}
		
		return l_flashArray;
	}
	
	public function getCurrentTrackedCreatureTag(out journalCreature:CJournalCreature, out trackedType : PreparationTrackType) : bool
	{
		var journalManager 				: CWitcherJournalManager;
		var currentlyTrackedCreature 	: CJournalCreature;
		var currentlyTrackedCreatureName: name;
		var currentlyTrackedQuest 		: CJournalQuest;
		
		journalManager = theGame.GetJournalManager();
		currentlyTrackedQuest = journalManager.GetTrackedQuest();
		
		if (currentlyTrackedQuest.GetType() == MonsterHunt) 
		{
			currentlyTrackedCreatureName = currentlyTrackedQuest.GetHuntingQuestCreatureTag();
			currentlyTrackedCreature = (CJournalCreature)journalManager.GetEntryByTag(currentlyTrackedCreatureName);
			
			if (currentlyTrackedCreature)
			{
				trackedType = PrepTrackType_Journal;
				journalCreature = currentlyTrackedCreature;
				return true;
			}
		}
		
		currentlyTrackedCreature = journalManager.GetCurrentlyBuffedCreature();
		
		if (currentlyTrackedCreature)
		{
			trackedType = PrepTrackType_Environment;
			journalCreature = currentlyTrackedCreature;
			return true;
		}
		
		return false;
	}
	
	function SetButtons()
	{
		
		AddInputBinding("panel_button_common_navigation", "gamepad_L3");		
		super.SetButtons();
	}
	
	public function UpdateOilSlotLocks()
	{
		m_flashValueStorage.SetFlashBool("preparation.slot.silversword.locked", !_inv.IsThereItemOnSlot(EES_SilverSword));
		m_flashValueStorage.SetFlashBool("preparation.slot.steelsword.locked", !_inv.IsThereItemOnSlot(EES_SteelSword));
	}
	
	function UpdateToxicityBar()
	{
		var curToxicity 	: float = thePlayer.GetStat( BCS_Toxicity );
		var curMaxToxicity 	: float = thePlayer.GetStatMax( BCS_Toxicity );
		
		m_flashValueStorage.SetFlashNumber( "preparation.toxicity.bar.max", curMaxToxicity, -1 );
		m_flashValueStorage.SetFlashNumber( "preparation.toxicity.bar.value", curToxicity, -1 );
	}
	
	private function sendTrackedMonsterInfo()
	{
		var monsterData					: CScriptedFlashObject;
		var trackType					: PreparationTrackType;
		var foundCreature				: bool;
		var currentlyTrackedCreature 	: CJournalCreature;
		var itemsFlashArray				: CScriptedFlashArray;
		
		monsterData = m_flashValueStorage.CreateTempFlashObject();
		
		foundCreature = getCurrentTrackedCreatureTag(currentlyTrackedCreature, trackType);
		
		if (foundCreature)
		{ 
			monsterData.SetMemberFlashInt("trackType", trackType);
			if (trackType == PrepTrackType_Journal)
			{
				monsterData.SetMemberFlashString("trackTypeStr", GetLocStringByKeyExt("panel_preparation_quest_tracked_monster"));
			}
			else
			{
				monsterData.SetMemberFlashString("trackTypeStr", GetLocStringByKeyExt("panel_preparation_quest_buffed_monster"));
			}
			
			monsterData.SetMemberFlashString("monsterIconPath", "icons/monsters/" + currentlyTrackedCreature.GetImage());
			monsterData.SetMemberFlashString("monsterName", GetLocStringById( currentlyTrackedCreature.GetNameStringId() ) );
			monsterData.SetMemberFlashString("bgImgPath", currentlyTrackedCreature.GetImage()); 
			monsterData.SetMemberFlashString("txtDesc", GetDescription(currentlyTrackedCreature));
			
			itemsFlashArray = CreateItems(currentlyTrackedCreature.GetItemsUsedAgainstCreature());
			
			if( itemsFlashArray && itemsFlashArray.GetLength() > 0 )
			{
				m_flashValueStorage.SetFlashBool("journal.rewards.panel.visible",true);
				m_flashValueStorage.SetFlashArray("tracked.monster.recommended.items", itemsFlashArray );
			}
			else
			{
				m_flashValueStorage.SetFlashBool("journal.rewards.panel.visible", false);
			}
			
			ShowRenderToTexture("");
		}
		else
		{
			m_flashValueStorage.SetFlashBool("journal.rewards.panel.visible", false);
			monsterData.SetMemberFlashInt("trackType", PrepTrackType_None); 
			monsterData.SetMemberFlashString("trackTypeStr", GetLocStringByKeyExt("panel_preparation_no_tracked_monster"));
			monsterData.SetMemberFlashString("monsterIconPath", "icons/monsters/ICO_NoMonster.png");
		}
		
		m_flashValueStorage.SetFlashObject("preparation.tracked.monster.info", monsterData);
	}
	
	function GetDescription( currentCreature : CJournalCreature ) : string 
    {
		var journalManager : CWitcherJournalManager;
		var i : int;
		var str : string;
		var locStrId : int;
		var descriptionsGroup, tmpGroup : CJournalCreatureDescriptionGroup;
		var description : CJournalCreatureDescriptionEntry;
		
		journalManager = theGame.GetJournalManager();
		
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
			if( journalManager.GetEntryStatus(description) == JS_Active )
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

	
	private function initMeditationState()
	{
		var medState : W3PlayerWitcherStateMeditation;
		medState = (W3PlayerWitcherStateMeditation)GetMenuInitData();
		
	}
	
	protected function equipTypeToTabIndex(equipId:int):PreparationMenuTabIndexes
	{
		switch (equipId)
		{
			case EES_Petard1:
			case EES_Petard2:
				return PreparationMenuTab_Bombs;
			case EES_Potion1:
			case EES_Potion2:
			case EES_Potion3:
			case EES_Potion4:
				return PreparationMenuTab_Potion;
			case EES_SilverSword:
			case EES_SteelSword:
				return PreparationMenuTab_Oils;
			case EES_PotionMutagen1:
			case EES_PotionMutagen2:
			case EES_PotionMutagen3:
			case EES_PotionMutagen4:
				return PreparationMenuTab_Mutagens;
		}
		
		return PreparationMenuTab_Bombs;
	}
	
	protected function tabIndexToItemType(tabIndex:int):EPreporationItemType
	{
		switch(tabIndex)
		{
			case PreparationMenuTab_Bombs:
				return PIT_Bomb;
			case PreparationMenuTab_Potion:
				return PIT_Potion;
			case PreparationMenuTab_Oils:
				return PIT_Oil;
			case PreparationMenuTab_Mutagens:
				return PIT_Mutagen;
			default:
				return PIT_Undefined;
		}
		
		return PIT_Undefined;
	}
	
	event  OnTabDataRequested(tabIndex : int )
	{
		PopulateTabData(tabIndex);
	}
	
	public function PopulateTabData(tabIndex:int) : void
	{
		var l_flashObject  : CScriptedFlashObject;
		var l_flashArray   : CScriptedFlashArray;
		
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		switch (tabIndex)
		{
		case PreparationMenuTab_Bombs:
			_gridInv.GetContainerItems(l_flashArray, l_flashObject, PIT_Bomb);
			break;
		case PreparationMenuTab_Potion:
			_gridInv.GetContainerItems(l_flashArray, l_flashObject, PIT_Potion);
			break;
		case PreparationMenuTab_Oils:
			_gridInv.GetContainerItems(l_flashArray, l_flashObject, PIT_Oil);
			break;
		case PreparationMenuTab_Mutagens:
			_gridInv.GetContainerItems(l_flashArray, l_flashObject, PIT_Mutagen);
			break;
		}
		
		PopulateDataForTab(tabIndex, l_flashArray);
	}
	
	private function PopulateDataForTab(tabIndex:int, entriesArray:CScriptedFlashArray):void
	{
		var l_flashObject : CScriptedFlashObject;
		
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashInt("tabIndex", tabIndex);
		l_flashObject.SetMemberFlashArray("tabData", entriesArray);
		
		m_flashValueStorage.SetFlashObject( "preparations.items.tab.data" + tabIndex, l_flashObject );
	}
	
	private function updateSlotsItems()
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		_gridInv.GetSlotsItems(l_flashArray,l_flashObject);
		
		m_flashValueStorage.SetFlashArray( "preparations.slots.list", l_flashArray );
		
		UpdateToxicityBar();
	}
	
	private function setMenuMode()
	{
		var RootMenu : CR4CommonMenu;
		
		RootMenu = (CR4CommonMenu)GetRootMenu();
		if ( RootMenu )
		{
			
			
		}
	}
	
	event  OnSelectInventoryItem(itemId:SItemUniqueId, slot:int) : void
	{
		if (_inv.IsIdValid(itemId))
		{
			_gridInv.ClearItemIsNewFlag(itemId);
		}
	}
	
	event  OnEquipItemPrep( item : SItemUniqueId, equipID : int)
	{
		var itemOnSlot : SItemUniqueId;
		var weaponId : SItemUniqueId;		
				
		
		if (equipID == EES_SilverSword)
		{
			if (_inv.IsIdValid(item) && _inv.GetItemEquippedOnSlot(EES_SilverSword, weaponId))
			{
				GetWitcherPlayer().ApplyOil(item, weaponId);
			}
		}
		else if (equipID == EES_SteelSword)
		{
			if (_inv.IsIdValid(item) && _inv.GetItemEquippedOnSlot(EES_SteelSword, weaponId))
			{
				GetWitcherPlayer().ApplyOil(item, weaponId);
			}
		}
		else
		{
			GetWitcherPlayer().GetItemEquippedOnSlot(equipID, itemOnSlot);
			
			
			if (_inv.IsIdValid(itemOnSlot))
			{
				_gridInv.UnequipItem(itemOnSlot);
			}
			
			_gridInv.EquipItemInGivenSlot(item, equipID);			
		}
				
		updateSlotsItems();
		PopulateTabData(equipTypeToTabIndex(equipID));
		UpdateToxicityBar();
	}
	
	event  OnUnequipItemPrep( equipID : int )
	{
		var itemOnSlot : SItemUniqueId;
	
		GetWitcherPlayer().GetItemEquippedOnSlot(equipID, itemOnSlot);
		
		if (_inv.IsIdValid(itemOnSlot) && equipID != EES_SilverSword && equipID != EES_SteelSword)
		{
			LogChannel('PREPARATION'," OnUnequipItem");
			GetWitcherPlayer().UnequipItemFromSlot( equipID, false );
			
			
			
			PopulateTabData(equipTypeToTabIndex(equipID));
			updateSlotsItems();
		}
	}
	
	
	
	
	
	
	private function GetLocItemOilCategory(item : SItemUniqueId) : string
	{
		var typeStr				: string;
		var itemTags			: array<name>;
		var i					: int;
		var silverOil			: bool;
		var steelOil			: bool;
		
		typeStr = GetLocStringByKeyExt("item_category_" + _inv.GetItemCategory(item) );
		
		if (_gridInv.isOilItem(item) && _inv.GetItemTags(item, itemTags))
		{
			silverOil = false;
			steelOil = false;
			
			for( i = 0; i < itemTags.Size(); i += 1 )
			{
				if (itemTags[i] == 'SteelOil')
				{
					steelOil = true;
				}
				else if (itemTags[i] == 'SilverOil')
				{
					silverOil = true;
				}
			}
			
			
			if (steelOil && !silverOil)
			{
				typeStr = GetLocStringByKeyExt("panel_inventory_paperdoll_slotname_steel_oil");
			}
			else if (silverOil && !steelOil)
			{
				typeStr = GetLocStringByKeyExt("panel_inventory_paperdoll_slotname_silver_oil");
			}
		}
			
		return typeStr;
	}
	
	event OnGetItemData(item : SItemUniqueId, compareItemType : int)
	{
		var compareItem 		: SItemUniqueId;
		var itemUIData			: SInventoryItemUIData;
		var itemWeight			: SAbilityAttributeValue;
		var compareItemStats	: array<SAttributeTooltip>;
		var itemStats 			: array<SAttributeTooltip>;
		var itemName 			: string;
		var category			: string;
		var typeStr				: string;
		var weight 				: float;
		
		var primaryStatLabel    : string;
		var primaryStatValue    : float;
		
		var resultData 			: CScriptedFlashObject;
		var statsList			: CScriptedFlashArray;
		
		GetWitcherPlayer().GetItemEquippedOnSlot(compareItemType, compareItem);
		itemName = _inv.GetItemName(item);
		resultData = m_flashValueStorage.CreateTempFlashObject();
		statsList = m_flashValueStorage.CreateTempFlashArray();
		
		if( !_inv.IsIdValid(item) )
		{
			
			return false;
		}
		
		_inv.GetItemPrimaryStat(item, primaryStatLabel, primaryStatValue);
		
		itemName = _inv.GetItemLocalizedNameByUniqueID(item);
		itemName = GetLocStringByKeyExt(itemName);
		resultData.SetMemberFlashString("ItemName", itemName);
		
		if( _inv.GetItemName(item) != _inv.GetItemName(compareItem) ) 
		{
			_inv.GetItemStats(compareItem, compareItemStats);
		}
		_inv.GetItemStats(item, itemStats);
		CompareItemsStats(itemStats, compareItemStats, statsList);
		
		resultData.SetMemberFlashArray("StatsList", statsList);
		resultData.SetMemberFlashString("PriceValue", _inv.GetItemPrice(item));
		
		if( _inv.ItemHasTag(item, 'Quest') || _inv.IsItemIngredient(item) || _inv.IsItemAlchemyItem(item) ) 
		{
			weight = 0;
		}
		else
		{
			itemWeight = _inv.GetItemAttributeValue(item, 'weight');
			weight = itemWeight.valueBase;
		}
		
		resultData.SetMemberFlashString("WeightValue", NoTrailZeros(weight));
		resultData.SetMemberFlashString("ItemRarity", GetItemRarityDescription(item, _inv) );
		
		category = GetItemCategoryLocalisedString( _inv.GetItemCategory(item) );
		
		if (_gridInv.isOilItem(item))
		{
			typeStr = GetLocItemOilCategory(item);
		}
		else
		{
			typeStr = GetLocStringByKeyExt("item_category_" + _inv.GetItemCategory(item) );
		}
		
		resultData.SetMemberFlashString("ItemType", typeStr );
		resultData.SetMemberFlashString("UniqueDescription", GetLocStringByKeyExt(_inv.GetItemLocalizedDescriptionByUniqueID(item)));
		
		if(_inv.HasItemDurability(item))
		{
			resultData.SetMemberFlashString("DurabilityValue", NoTrailZeros(_inv.GetItemDurability(item)/_inv.GetItemMaxDurability(item) * 100));
		}
		else
		{
			resultData.SetMemberFlashString("DurabilityValue", "");
		}
		resultData.SetMemberFlashString("PrimaryStatLabel", primaryStatLabel);
		resultData.SetMemberFlashNumber("PrimaryStatValue", primaryStatValue);
		if( theGame.IsPadConnected() )
		{
			resultData.SetMemberFlashString("IconPath", _inv.GetItemIconPathByUniqueID(item) );
			resultData.SetMemberFlashString("ItemCategory", category);
		}
		m_flashValueStorage.SetFlashObject("context.tooltip.data", resultData);
	}
	
	
	event  OnGetEmptyPaperdollTooltip(equipID:int, isLocked:bool) : void
	{
		var statsList			: CScriptedFlashArray;
		var resultData 			: CScriptedFlashObject;
		
		statsList = m_flashValueStorage.CreateTempFlashArray();
		resultData = m_flashValueStorage.CreateTempFlashObject();
		
		if (isLocked)
		{
			resultData.SetMemberFlashString("ItemName", GetLocStringByKeyExt("panel_inventory_tooltip_locked_slot"));
		}
		else
		{
			resultData.SetMemberFlashString("ItemName", GetLocStringByKeyExt("panel_inventory_tooltip_empty_slot"));
		}
		resultData.SetMemberFlashArray("StatsList", statsList);
		resultData.SetMemberFlashString("PriceValue", 0);
		resultData.SetMemberFlashString("WeightValue", 0);
		resultData.SetMemberFlashString("ItemRarity", "");
		
		
		if (equipID == EES_SilverSword || equipID == EES_SteelSword)
		{
			resultData.SetMemberFlashString("ItemType", GetLocStringByKeyExt("panel_inventory_paperdoll_slotname_oils") );
		}
		else
		{
			resultData.SetMemberFlashString("ItemType", GetLocStringByKeyExt(GetLocNameFromEquipSlot(equipID)) );
		}
		
		resultData.SetMemberFlashString("DurabilityValue", "");
		resultData.SetMemberFlashString("PrimaryStatLabel", "");
		resultData.SetMemberFlashNumber("PrimaryStatValue", 0);
		resultData.SetMemberFlashString("IconPath", "" );
		resultData.SetMemberFlashString("ItemCategory", "");
		
		m_flashValueStorage.SetFlashObject("context.tooltip.data", resultData);
	}
	
	event  OnGetAppliedOilTooltip(equipID:int) : void
	{
		var oilName 		: name;
		var statsList		: CScriptedFlashArray;
		var resultData 		: CScriptedFlashObject;
		var buff 			: W3Effect_Oil;
		var id				: SItemUniqueId;
		
		if( !GetWitcherPlayer().GetItemEquippedOnSlot( equipID, id ) )
		{
			return false;
		}
		
		buff = _inv.GetOldestOilAppliedOnItem( id, false );
		if( !buff )
		{
			return false;
		}
		
		oilName = buff.GetOilItemName();
		if( oilName == '' )
		{
			return false;
		}
		
		statsList = m_flashValueStorage.CreateTempFlashArray();
		resultData = m_flashValueStorage.CreateTempFlashObject();
		
		resultData.SetMemberFlashString("ItemName", GetLocStringByKeyExt(_inv.GetItemLocalizedNameByName(oilName)));
		resultData.SetMemberFlashArray("StatsList", statsList); 
		resultData.SetMemberFlashString("PriceValue", 0);
		resultData.SetMemberFlashString("WeightValue", 0);
		resultData.SetMemberFlashString("ItemRarity", "");
		
		
		if (equipID == EES_SilverSword)
		{
			resultData.SetMemberFlashString("ItemType", GetLocStringByKeyExt("panel_inventory_paperdoll_slotname_silver_oil") );
		}
		else if (equipID == EES_SteelSword)
		{
			resultData.SetMemberFlashString("ItemType", GetLocStringByKeyExt("panel_inventory_paperdoll_slotname_steel_oil") );
		}
		
		resultData.SetMemberFlashString("DurabilityValue", "");
		resultData.SetMemberFlashString("PrimaryStatLabel", "");
		resultData.SetMemberFlashNumber("PrimaryStatValue", 0);
		resultData.SetMemberFlashString("IconPath", _inv.GetItemIconPathByName(oilName) );
		resultData.SetMemberFlashString("ItemCategory", "");
		resultData.SetMemberFlashString("UniqueDescription", GetLocStringByKeyExt(_inv.GetItemLocalizedDescriptionByName(oilName)));
		
		m_flashValueStorage.SetFlashObject("context.tooltip.data", resultData);
	}
	
	function CompareItemsStats(itemStats : array<SAttributeTooltip>, compareItemStats : array<SAttributeTooltip>, out compResult : CScriptedFlashArray)
	{
		var l_flashObject	: CScriptedFlashObject;
		var attributeVal 	: SAbilityAttributeValue;
		var strDifference 	: string;		
		var percentDiff 	: float;
		var nDifference 	: float;
		var i, j, price 	: int;
		
		strDifference = "none";
		for( i = 0; i < itemStats.Size(); i += 1 ) 
		{
			l_flashObject = m_flashValueStorage.CreateTempFlashObject();
			l_flashObject.SetMemberFlashString("name",itemStats[i].attributeName);
			l_flashObject.SetMemberFlashString("color",itemStats[i].attributeColor);
			
			
			for( j = 0; j < compareItemStats.Size(); j += 1 )
			{
				if( itemStats[j].attributeName == compareItemStats[i].attributeName )
				{
					nDifference = itemStats[j].value - compareItemStats[i].value;
					percentDiff = AbsF(nDifference/itemStats[j].value);
					
					
					if(nDifference > 0)
					{
						if(percentDiff < 0.25) 
							strDifference = "better";
						else if(percentDiff > 0.75) 
							strDifference = "wayBetter";
						else						
							strDifference = "reallyBetter";
					}
					
					else if(nDifference < 0)
					{
						if(percentDiff < 0.25) 
							strDifference = "worse";
						else if(percentDiff > 0.75) 
							strDifference = "wayWorse";
						else						
							strDifference = "reallyWorse";					
					}
					break;					
				}
			}
			l_flashObject.SetMemberFlashString("icon", strDifference);
			
			if( itemStats[i].percentageValue )
			{
				l_flashObject.SetMemberFlashString("value",NoTrailZeros(itemStats[i].value * 100 ) +" %");
			}
			else
			{
				if(itemStats[i].value < 0)
					l_flashObject.SetMemberFlashString("value",NoTrailZeros(itemStats[i].value));
				else
					l_flashObject.SetMemberFlashString("value","+" + NoTrailZeros(itemStats[i].value));				
			}
			compResult.PushBackFlashObject(l_flashObject);
		}	
	}
	
	function GetItemRarityDescription( item : SItemUniqueId, tooltipInv : CInventoryComponent ) : string
	{
		var itemQuality : int;
		
		itemQuality = tooltipInv.GetItemQuality(item);
		return GetItemRarityDescriptionFromInt(itemQuality);
	}
	
	
	

}