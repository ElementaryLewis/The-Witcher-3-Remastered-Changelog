/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4TransmogMenu extends CR4MenuBase
{
	private var m_player 			: CEntity;
	protected var _fixerNpc 	  : CNewNPC;

	protected var m_isArmorsmith	: bool;
	protected var m_isWeaponsmith	: bool;

	protected var _inv 		      	: CInventoryComponent;
	protected var _fakeInv 			: CInventoryComponent;

	protected var _fixerInventory 	: CInventoryComponent;

	private var _playerGuiInv    	     : W3GuiTransmogInventoryComponent;

	protected var _tooltipDataProviderItems	: W3TooltipComponent;

	private var m_sectionsList			: CScriptedFlashArray;
	private var m_fxConfirmAction		: CScriptedFlashFunction;
	private var m_fxSetPlayerMoney		: CScriptedFlashFunction;

	private var InitDataConfirmation 	: TransmogPriceConfirmationPopupData;
	private var _savedTransmogItemId  	:  SItemUniqueId;
	private var m_transmogData : map<name, name>; 
	
	private var _transmogPriceBase 	: float ; default _transmogPriceBase = 100.0f;
	private var _lastSelectedTab : int;

	event  OnConfigUI()
	{	
		var l_fixerEntity			: CGameplayEntity;	
		var l_initData				: W3InventoryInitData;
		var l_obj		 			: IScriptable;		

		super.OnConfigUI();

		_inv = thePlayer.GetInventory();		

		m_flashValueStorage = GetMenuFlashValueStorage();
		m_flashModule = GetMenuFlash();

		
		theGame.GetGuiManager().SetBackgroundTexture( LoadResource( "inventory_background" ) );

		l_obj = GetMenuInitData();

		l_initData = (W3InventoryInitData)l_obj;

		if( l_initData )
		{
			l_fixerEntity = l_initData.containerNPC;
		}
		else
		{
			l_fixerEntity = (CGameplayEntity)l_obj;
		}

		if( l_fixerEntity )
		{
			_fixerNpc = (CNewNPC)l_fixerEntity;
			_fixerInventory = l_fixerEntity.GetInventory();
			m_isArmorsmith = l_fixerEntity.HasTag('Armorer');
			m_isWeaponsmith = l_fixerEntity.HasTag('Blacksmith');
		}	

		_playerGuiInv = new W3GuiTransmogInventoryComponent in this;
		_playerGuiInv.Initialize( _inv );		
				
		_tooltipDataProviderItems = new W3TooltipComponent in this;
		_tooltipDataProviderItems.initialize(_inv, m_flashValueStorage);
		_tooltipDataProviderItems.setCurrentInventory(_inv);

		m_fxSetTooltipState.InvokeSelfTwoArgs( FlashArgBool( thePlayer.upscaledTooltipState ), FlashArgBool( true ) );
		
		m_fxConfirmAction = m_flashModule.GetMemberFlashFunction( "confirmAction" );
		m_fxSetPlayerMoney = m_flashModule.GetMemberFlashFunction( "setPlayerMoney" );

		m_flashValueStorage.SetFlashString("repair.grid.player.name","REFORGE");

		InitEntityTemplate();
		UpdateData();		
	}

	event  OnGlobalUpdate()
	{
		UpdateData();
	}

	function SendTabData()
	{
		var slots : array<EEquipmentSlots>;
		var tempArray : CScriptedFlashArray;
		var tempObject : CScriptedFlashObject;
		var iconId : string;
		var i : int;

		tempArray = m_flashValueStorage.CreateTempFlashArray();

		GetAvailableEquipmentSlots(slots);
		for(i = 0; i < slots.Size(); i+=1)
		{
			tempObject = m_flashValueStorage.CreateTempFlashObject();

			switch(slots[i])
			{
				case EES_SteelSword: iconId = "STEEL"; break;
				case EES_SilverSword: iconId = "SILVER"; break;
				case EES_RangedWeapon: iconId = "RANGED"; break;
				case EES_Armor: iconId = "CHEST"; break;
				case EES_Boots: iconId = "BOOTS"; break;
				case EES_Pants: iconId = "TROUSERS"; break;
				case EES_Gloves: iconId = "GLOVES"; break;
			}
			tempObject.SetMemberFlashString("icon", iconId);
			tempObject.SetMemberFlashBool("enabled", true);

			tempArray.PushBackFlashObject(tempObject);
		}
		m_flashValueStorage.SetFlashArray("transmog.create.tabs",tempArray);
	}
	
	function UpdateData()
	{
		UpdateMerchantData();
		m_fxSetPlayerMoney.InvokeSelfOneArg( FlashArgInt( thePlayer.GetMoney() ) );

		UpdatePlayerMoney();

		SetTransmogSectionDataList();
		UpdateEntityTemplate();
		ShowTransmogableItems();
		SendTabData();
	}

	
	event  OnCharacterRendererClicked()
	{
		RandomAnim();
		
	}

	
	private function RandomAnim():void
	{
		var ret : array<name>;
		var index:int;
		var randomCategory:name;
		var guiSceneController : CR4GuiSceneController;

		ret.PushBack('armor');
		ret.PushBack('gloves');
		ret.PushBack('pants');
		ret.PushBack('boots');
		ret.PushBack('steelsword');
		ret.PushBack('silversword');
		ret.PushBack('crossbow');		

		index = RandRange(ret.Size());

		randomCategory = ret[index];
		PlayPaperdollAnimation(randomCategory);	
		
		
		
		
	}

	event  OnGuiSceneEntitySpawned(entity : CEntity)
	{
		var arr : array< name >;
		
		Event_OnGuiSceneEntitySpawned();
		m_player = entity;
		arr.PushBack( 'Inventory' );
		m_player.ActivateBehaviorsSync( arr );
		
		((CActor)m_player).SetBehaviorMimicVariable( 'gameplayMimicsMode', (float)(int)PGMM_Inventory );

		
	}

	private function InitEntityTemplate():void
	{
		var templateFilename : string;
		var appearance : name;
		var environmentFilename : string;
		var environmentSunRotation : EulerAngles;
		var cameraLookAt : Vector;
		var cameraRotation : EulerAngles;
		var cameraDistance : float;
		var updateItems : bool;
		var fov : float;
		
		var guiSceneController : CR4GuiSceneController;

		guiSceneController = theGame.GetGuiManager().GetSceneController();
		if ( !guiSceneController )
		{	
			return;
		}
		
		templateFilename             = "GeraltForUI";
		appearance                   = '';
		environmentSunRotation.Yaw   = 0;
		environmentSunRotation.Pitch = 0;
		cameraLookAt.Z               = 0.92;
		cameraRotation.Yaw           = 190.71; 
		cameraRotation.Pitch         = 5;
		cameraDistance               = 3.2;
		fov							 = 35.0f;
		updateItems                  = true;
				
		
		guiSceneController.SetEntityTemplate( templateFilename );
		guiSceneController.SetCamera( cameraLookAt, cameraRotation, cameraDistance, fov );
		guiSceneController.SetEnvironmentAndSunRotation( "DefaultEnvironmentForUI", environmentSunRotation );
		
		guiSceneController.SetEntityAppearance( appearance );
		guiSceneController.SetEntityItems( updateItems );
	}

	private function UpdateEntityTemplate() : void
	{
		var transmogArray : array<SGuiTransmogInfo>;
		var transmogData : SGuiTransmogInfo;
		var transmogItemIdList : array<SItemUniqueId>;
		var i : int;
		var itemName : name;
		var guiSceneController : CR4GuiSceneController;

		guiSceneController = theGame.GetGuiManager().GetSceneController();

		GetTransmogableItemList(transmogItemIdList);
		for(i = 0; i < transmogItemIdList.Size(); i+=1)
		{
			itemName = _inv.GetItemName(transmogItemIdList[i]);
			if(m_transmogData.Contains(itemName))
			{
				transmogData.transmogAppearanceName = m_transmogData[itemName];
				transmogData.originalName = itemName;
				transmogArray.PushBack(transmogData);
			}
		}
		guiSceneController.SetEntityItems( true );
		theGame.GetGuiManager().UpdateSceneEntityTransmogs( transmogArray );
	}	

	function UpdateMerchantData() : void
	{	
		var l_merchantData			: CScriptedFlashObject;

		if(_fixerNpc)
		{	
			l_merchantData = m_flashValueStorage.CreateTempFlashObject();
			GetNpcInfo((CGameplayEntity)_fixerNpc, l_merchantData);
			m_flashValueStorage.SetFlashObject("blacksmith.merchant.info", l_merchantData);
		}
		else
		{
			Log("DebugTransmog no _fixerNpc");
		}		
	}	

	function UpdatePlayerMoney(): void
	{	
		var commonMenu 			: CR4CommonMenu;

		commonMenu = (CR4CommonMenu)m_parentMenu;
		if( commonMenu )
		{
			commonMenu.UpdatePlayerOrens();
		}
		else
		{
			Log("DebugTransmog UpdatePlayerMoney No common menu FIX");
		}
	}
	

	private function PlayPaperdollAnimation( category : name ):void
	{
		if (m_player)
		{
			((CActor)m_player).SetBehaviorMimicVariable( 'gameplayMimicsMode', (float)(int)PGMM_Inventory );
			
			switch (category)
			{
				case 'armor':
					m_player.RaiseEvent('ShowArmor_Inv');
					break;
				case 'gloves':
					m_player.RaiseEvent('ShowGlove_Inv');
					break;
				case 'pants':
					m_player.RaiseEvent('ShowPants_Inv');
					break;
				case 'boots':
					m_player.RaiseEvent('ShowBoots_Inv');
					break; 
				case 'steelsword':
					m_player.RaiseEvent('DrawSteelSword_Inv');
					break;
				case 'silversword':
					m_player.RaiseEvent('DrawSilverSword_Inv');
					break;
				case 'crossbow':
					m_player.RaiseEvent('DrawCrossbow_Inv');
					break;
				default:
					break;
			}
		}
	}

	function GetAvailableEquipmentSlots(out slots : array<EEquipmentSlots>):void
	{
		if (m_isWeaponsmith)
		{
			if(GetWitcherPlayer().IsAnyItemEquippedOnSlot(EES_SteelSword))
				slots.PushBack(EES_SteelSword);
			if(GetWitcherPlayer().IsAnyItemEquippedOnSlot(EES_SilverSword))
				slots.PushBack(EES_SilverSword);
			if(GetWitcherPlayer().IsAnyItemEquippedOnSlot(EES_RangedWeapon))
				slots.PushBack(EES_RangedWeapon);
		}
		else if (m_isArmorsmith)
		{
			if(GetWitcherPlayer().IsAnyItemEquippedOnSlot(EES_Armor))
				slots.PushBack(EES_Armor);
			if(GetWitcherPlayer().IsAnyItemEquippedOnSlot(EES_Boots))
				slots.PushBack(EES_Boots);
			if(GetWitcherPlayer().IsAnyItemEquippedOnSlot(EES_Pants))
				slots.PushBack(EES_Pants);
			if(GetWitcherPlayer().IsAnyItemEquippedOnSlot(EES_Gloves))
				slots.PushBack(EES_Gloves);
		}
	}
	
	function GetTransmogableItemList(out transmogItemIdList : array<SItemUniqueId>):void
	{
		var itemOnSlot : SItemUniqueId;

		var slots : array<EEquipmentSlots>;
		var i : int;

		GetAvailableEquipmentSlots(slots);
	
		for(i = 0; i < slots.Size(); i += 1)
		{
			GetWitcherPlayer().GetItemEquippedOnSlot(slots[i], itemOnSlot);

			if(_inv.IsIdValid(itemOnSlot))
			{
				transmogItemIdList.PushBack(itemOnSlot);
			}
		}
	}

	function ShowTransmogableItems()
	{
		var transmogItemIdList : array<SItemUniqueId>;

		GetTransmogableItemList(transmogItemIdList);

		UpdateInventoryItems(transmogItemIdList);		
	}

	event  OnTransmogItemSelectedByTabIndex(tabId:int) : void
	{	
		var transmogItemIdList : array<SItemUniqueId>;
		var itemId : SItemUniqueId;
		GetTransmogableItemList(transmogItemIdList);
		itemId = transmogItemIdList[tabId];

		if(_inv.IsIdValid(itemId))
		{
			AddTransmogSkinsForSelectedItem(itemId);	
		}
		else
		{
			Log("DebugTransmog OnTransmogItemSelected INVALID ID ");	
		}

		_savedTransmogItemId = itemId;
		PlayPaperdollAnimation(_inv.GetItemCategory(_savedTransmogItemId));
			
		

		UpdateEntityTemplate();
		_lastSelectedTab = tabId;
	}

	event  OnTransmogAppearSelected(itemName:name) : void
	{	
		var transmogSkinNames : array<name>;

		GetWitcherPlayer().GetUnlockedAppearances(transmogSkinNames);

		
		if(!transmogSkinNames.Contains(itemName))
			return false;

		m_transmogData[_inv.GetItemName(_savedTransmogItemId)] = itemName;
		PlayPaperdollAnimation(_inv.GetItemCategory(_savedTransmogItemId));

		TransmogPriceUpdate();

		UpdateEntityTemplate();
		PlayItemEquipSound(_inv.GetItemCategory(_savedTransmogItemId));
		ShowTransmogableItems();
	}

	public function GetTransmogPriceForItem(itemId : SItemUniqueId, appear : name) : int
	{
		var price : int = 0;	
		var overrideName : name;
		var isDefaultApperance : bool = false;
		var min, max : int;
		var itemCategory : string;

		if(_inv.IsIdValid(itemId))
		{
			overrideName = _inv.GetItemTemplateOverride(itemId);
			if (_inv.GetItemName(itemId) == appear && overrideName != appear && overrideName != 'None')
			{
				itemCategory = _inv.GetItemCategory(itemId);
				_inv.GetItemQualityFromName(appear, min, max);
				min = Max(min, 1); 
				price = (int)((GetPriceModifierForItemCategoryAndRarity(itemCategory, min, max) * _transmogPriceBase) / 10);
				isDefaultApperance = true;
			}
			else if(overrideName == appear || _inv.GetItemName(itemId) == appear)
			{
				price = 0;
				isDefaultApperance = true;
			}
			else
			{
				itemCategory = _inv.GetItemCategory(itemId);
				_inv.GetItemQualityFromName(appear, min, max);
				min = Max(min, 1); 
				price = (int)(GetPriceModifierForItemCategoryAndRarity(itemCategory, min, max) * _transmogPriceBase);
			}
		}

		return price;
	}

	public function GetPriceModifierForItemCategoryAndRarity(itemCategory : string, itemRarityMin : float, itemRarityMax : float) : float
	{
		var categoryModifier : float = 1.f;
		var rarityModifier : float = 0.7f;

		switch (itemCategory)
		{
			case 'armor':
			categoryModifier = 1.0f;
			break;
			case 'boots':
			categoryModifier = 0.7f;
			break;
			case 'gloves':
			categoryModifier = 0.8f;
			break;
			case 'pants':
			categoryModifier = 0.9f;
			break;
			case 'silversword':
			categoryModifier = 1.2f;
			break;
			case 'steelsword':
			categoryModifier = 1.1f;
			break;
			case 'crossbow':
			categoryModifier = 0.6f;
			break;
			default:
			break;
		}

		rarityModifier = 0.7 + ((itemRarityMin + itemRarityMax) / 10);

		return categoryModifier * rarityModifier;
	}

	public function GetTotalTransmogPrice():int
	{
		var transmogItemIdList : array<SItemUniqueId>;
		var totalPrice : int;
		var price : int;
		var i : int;
		var itemName : name;
		var appear : name;

		GetTransmogableItemList(transmogItemIdList);

		for(i = 0; i < transmogItemIdList.Size(); i+=1)
		{
			itemName = _inv.GetItemName(transmogItemIdList[i]);
			if(m_transmogData.Contains(itemName))
			{
				price = GetTransmogPriceForItem(transmogItemIdList[i], m_transmogData[itemName]);
				totalPrice += price;
			}

		}
		return totalPrice;
	}

	public function TransmogPriceUpdate()
	{
		var totalPrice : int = GetTotalTransmogPrice();
		m_flashValueStorage.SetFlashInt("transmog.appear.price.update" , totalPrice);
	}

	function IsRealAppearance(itemName : name) : bool
	{
		
		switch(itemName)
		{
			case 'Ciri armor 01': return false;
			case 'Wild Hunt armor 01': return false;
			case 'Ciri pants 01': return false;
			case 'Wild Hunt pants 01': return false;
			case 'q705_bond': return false;
			case 'ma': return false;
			case 'Wild Hunt gloves 01': return false;
			case 'q203 Ghost Sword': return false;
			case 'q203 Ghost Human Sword': return false;
			case 'maw': return false;
			case 'axe_test': return false;
			case 'mace_test': return false;
			case 'dwarven_hammer_test': return false;
			case 'NPC Scoiatael sword 2': return false;
			case 'Damien sword': return false;
			case 'NPC Knights steel sword 1': return false;
			case 'Laundry stick': return false;
			default: return true;
		}

		return true;
	}

	function GetAllUnusedAppearances(itemid : SItemUniqueId, transmogSkinNames : array<name> ):array<name>
	{
		var unusedList : array<name>;
		var allItems : array<name>;
		var dm : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var neededCategory : name = _inv.GetItemCategory(itemid);
		var i : int = 0;
		var itemName : name;

		if(m_isArmorsmith)
			allItems = dm.GetItemsWithTag('Armor');
		else
			allItems = dm.GetItemsWithTag('Weapon');

		for(i = 0; i < allItems.Size(); i+= 1)
		{
			itemName = allItems[i];
			if(dm.GetItemCategory(itemName) == neededCategory && !transmogSkinNames.Contains(itemName) && IsRealAppearance(itemName) && GetLocStringByKeyExt(_inv.GetItemLocalizedNameByName(itemName)) != "")
			{
				unusedList.PushBack(itemName);
			}
		}

		RemoveDuplicateAppearances(unusedList);
		return unusedList;
	}

	function RemoveDuplicateAppearances(out skinNames : array<name>):void
	{
		var i : int = 0;
		var j : int = 0;
		var itemTemplate : string;
		var itemTemplateComp : string;

		for(i = 0; i < skinNames.Size(); i+=1)
		{
			itemTemplate = _inv.GetItemTemplateByName(skinNames[i]);
			for(j = skinNames.Size() - 1; j > i; j-= 1)
			{
				itemTemplateComp = _inv.GetItemTemplateByName(skinNames[j]);
				if(itemTemplate == itemTemplateComp)
					skinNames.Erase(j);
			}
		}
	}

	function GetUnlockedAppearances(itemId : SItemUniqueId):array<name>
	{
		var transmogSkinNames : array<name>;
		var i, selectedItemIndex : int;
		var category, currentItem, overrideName : name;
		var dm : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();

		GetWitcherPlayer().GetUnlockedAppearances(transmogSkinNames);

		category = _inv.GetItemCategory(itemId);	

		
		i = 0;
		while(i < transmogSkinNames.Size())
		{
			if (dm.GetItemCategory(transmogSkinNames[i]) == category && GetLocStringByKeyExt(_inv.GetItemLocalizedNameByName(transmogSkinNames[i])) != "")
			{
				i+=1;
			}
			else
			{
				transmogSkinNames.EraseFast(i);
			}
		}

		selectedItemIndex = -1;
		for(i = 0; i < transmogSkinNames.Size(); i+=1)
		{
			if(transmogSkinNames[i] == _inv.GetItemName(itemId))
			{
				selectedItemIndex = i;
				break;
			}
		}

		
		if(selectedItemIndex > -1)
		{
			currentItem = transmogSkinNames[0];
			transmogSkinNames[0] = transmogSkinNames[selectedItemIndex];
			transmogSkinNames[selectedItemIndex] = currentItem;
		}

		RemoveDuplicateAppearances(transmogSkinNames);

		return transmogSkinNames;
	}

	function AddTransmogSkinsForSelectedItem(itemid: SItemUniqueId)
	{
		var transmogSkinNames : array<name>;
		var transmogSkinNamesLocked : array<name>;
		var ids : array<SItemUniqueId>;
		var category, currentItem, overrideName : name;
		var i, selectedItemIndex : int;
		var min, otherMin ,max : SAbilityAttributeValue;

		var dm : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var currentAppearIndex : int;

		transmogSkinNames = GetUnlockedAppearances(itemid);
		transmogSkinNamesLocked = GetAllUnusedAppearances(itemid, transmogSkinNames);

		
		
		category = _inv.GetItemCategory(itemid);	
		
		overrideName = _inv.GetItemTemplateOverride(itemid);
		if(overrideName == '')
		{
			overrideName=_inv.GetItemName(itemid);
		}
		for(i = 0; i < transmogSkinNames.Size(); i+=1)
		{
			if(transmogSkinNames[i] == overrideName)
			{				
				currentAppearIndex = i+1;
				break;
			}			
		}
		UpdateInventoryAppears(itemid, transmogSkinNames, transmogSkinNamesLocked);

		
		m_flashValueStorage.SetFlashInt("transmog.appear.index" , currentAppearIndex);	
	}

	function IsItemBeingTransmogModified(item : SItemUniqueId):bool
	{
		var itemName 			: name;
		var itemTemplateOverride: name;

		itemName = _inv.GetItemName(item);
		itemTemplateOverride = _inv.GetItemTemplateOverride(item);

		if(m_transmogData.Contains(itemName))
		{
			
			if(itemTemplateOverride == '' && itemName != m_transmogData[itemName])
				return true;
			else if (itemTemplateOverride != '' && itemTemplateOverride != m_transmogData[itemName])
				return true;
		}
		return false;
	}
	
	function UpdateInventoryItems( itemsList : array<SItemUniqueId>)
	{
		var i					: int;
		var itemTemplateOverride: name;
		var itemName 			: name;

		for ( i = 0; i < itemsList.Size(); i += 1 )
		{
			itemName = _inv.GetItemName(itemsList[i]);
			itemTemplateOverride = _inv.GetItemTemplateOverride(itemsList[i]);

			if(!m_transmogData.Contains(itemName))
			{
				if(itemTemplateOverride != '')
					m_transmogData[itemName] = itemTemplateOverride;
				else
					m_transmogData[itemName] = itemName;
			}
		}

		UpdateTransmogVis();
	}	

	function UpdateInventoryAppears(itemid:SItemUniqueId, itemsList : array<name>, itemsListLocked : array<name>)
	{
		var i					: int;
		var tempFlashObject		: CScriptedFlashObject;
		var itemDataObject		: CScriptedFlashObject;
		var itemsDataList		: CScriptedFlashArray;
		var dm : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		
		itemsDataList = m_flashValueStorage.CreateTempFlashArray();
		tempFlashObject = m_flashValueStorage.CreateTempFlashObject();

		for ( i = 0; i < itemsList.Size(); i += 1 )
		{
			itemDataObject = tempFlashObject.CreateFlashObject("red.game.witcher3.menus.common.ItemDataStub");			
			_playerGuiInv.SetInventoryFlashObjectForAppear(itemid, itemsList[i], false, itemDataObject);
			if(!_inv.HasTransmogAppearance(itemid) && itemsList[i] != _inv.GetItemName(itemid))
			{
				itemDataObject.SetMemberFlashBool( "transmog", false );
			}
			else if(_inv.GetItemTemplateOverride(itemid) != '' && (_inv.GetItemName(itemid) != itemsList[i] && _inv.GetItemTemplateOverride(itemid) != itemsList[i]))
			{
				itemDataObject.SetMemberFlashBool( "transmog", false );
			}

			if(!dm.CanItemBeColoredByName(itemsList[i]))
			{
				itemDataObject.SetMemberFlashString( "itemColor", "" );
			}
			else if( _inv.IsItemColored( itemid ) )
			{
				itemDataObject.SetMemberFlashString( "itemColor", NameToString( _inv.GetItemColor( itemid ) ) );
			}

			itemsDataList.PushBackFlashObject(itemDataObject);
		}

		for ( i = 0; i < itemsListLocked.Size(); i += 1 )
		{
			itemDataObject = tempFlashObject.CreateFlashObject("red.game.witcher3.menus.common.ItemDataStub");			
			_playerGuiInv.SetInventoryFlashObjectForAppear(itemid, itemsListLocked[i], false, itemDataObject);
			itemDataObject.SetMemberFlashBool( "locked", true );
			itemDataObject.SetMemberFlashBool( "transmog", false );
			itemDataObject.SetMemberFlashBool( "reset", false );
			
			if(!dm.CanItemBeColoredByName(itemsListLocked[i]))
			{
				itemDataObject.SetMemberFlashString( "itemColor", "" );
			}
			else if( _inv.IsItemColored( itemid ) )
			{
				itemDataObject.SetMemberFlashString( "itemColor", NameToString( _inv.GetItemColor( itemid ) ) );
			}

			itemsDataList.PushBackFlashObject(itemDataObject);
		}

		m_flashValueStorage.SetFlashArray( "transmog.appear.list.update", itemsDataList );
	}	
	
	event  OnGetItemData(item : SItemUniqueId, compareItemType : int)
	{
		ShowItemTooltip(item, compareItemType);
	}	

	event  OnGetItemDataTransmog(item : SItemUniqueId, itemName : name, compareItemType : int, transmogPreview : int)
	{
		ShowItemTooltipTransmog(item, itemName, compareItemType, transmogPreview == 1);
	}	

	public function ShowItemTooltipTransmog(item : SItemUniqueId, originalItemName : name, compareItemType : int, transmogPreview : bool)
	{	
		var tooltipData : CScriptedFlashObject;
		var itemLocalizedName : string;
		var itemLabel : string;
		var itemType : string;
		var itemRarity : string;
		var min, max : int;

		if(_inv.IsIdValid(item))
		{
			tooltipData = _tooltipDataProviderItems.GetTooltipData(item, true, true);

			
			_inv.GetItemQualityFromName(originalItemName, min, max);
			min = Max(min, 1); 
			itemLocalizedName = _inv.GetItemLocalizedNameByName(originalItemName);
			itemLabel = GetLocStringByKeyExt(itemLocalizedName);
			itemType = ResolveItemTypeFromName(originalItemName);
			itemRarity = GetItemRarityDescriptionFromInt(min);

			if (transmogPreview)
			{
				tooltipData.SetMemberFlashString("TransmogText", originalItemName != _inv.GetItemName(item) ? _tooltipDataProviderItems.GetTransmogItemLabel(itemLocalizedName) : "");
			}
			else
			{
				

				tooltipData.SetMemberFlashString("ItemType", itemType);
				tooltipData.SetMemberFlashString("ItemRarity", itemRarity);
				tooltipData.SetMemberFlashString("ItemName", GetItemRarityColorFromInt(min) + itemLabel + "</font>");
				tooltipData.SetMemberFlashInt("ItemRarityIdx", min);

				

				tooltipData.SetMemberFlashString("TransmogText", "");

				tooltipData.SetMemberFlashArray("SocketsList", m_flashValueStorage.CreateTempFlashArray());
				tooltipData.SetMemberFlashArray("StatsList", m_flashValueStorage.CreateTempFlashArray());
				tooltipData.SetMemberFlashArray("PropertiesList", m_flashValueStorage.CreateTempFlashArray());
				tooltipData.SetMemberFlashArray("SetStatsList", m_flashValueStorage.CreateTempFlashArray());
				tooltipData.SetMemberFlashString("RequiredLevel", "");

				tooltipData.SetMemberFlashString("PrimaryStatLabel", "");
				tooltipData.SetMemberFlashString("PrimaryStatDiff", "");
				tooltipData.SetMemberFlashString("PrimaryStatDiffStr", "");
				tooltipData.SetMemberFlashNumber("PrimaryStatValue", 0);
				tooltipData.SetMemberFlashNumber("PrimaryStatDurabilityPenalty", 0);
				tooltipData.SetMemberFlashBool("CanBeCompared", false);
				tooltipData.SetMemberFlashString("appliedEnchantmentInfo", "");

				tooltipData.SetMemberFlashString("SetCounter", "");

				tooltipData.SetMemberFlashString("itemColor", "" );
			}

			m_flashValueStorage.SetFlashObject("context.tooltip.data", tooltipData);
		}
	}

	public function ShowItemTooltip(item : SItemUniqueId, compareItemType : int)
	{	
		var tooltipData : CScriptedFlashObject;

		if(_inv.IsIdValid(item))
		{
			tooltipData = _tooltipDataProviderItems.GetTooltipData(item, true, true);
			m_flashValueStorage.SetFlashObject("context.tooltip.data", tooltipData);
		}

	}

	
	
	private function ResolveItemTypeFromName(itemName : name) : string
	{
		var dm : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var itemCategory : name = dm.GetItemCategory(itemName);
		var itemType : string;
		var armorEnumType : EArmorType;

		if (itemCategory == 'armor'|| itemCategory == 'pants' || itemCategory == 'boots' || itemCategory == 'gloves')
		{
			if(dm.ItemHasTag(itemName, 'LightArmor'))
				itemType = GetLocStringByKeyExt("item_type_light_armor");
			else if(dm.ItemHasTag(itemName, 'MediumArmor'))
				itemType = GetLocStringByKeyExt("item_type_medium_armor");
			else if(dm.ItemHasTag(itemName, 'HeavyArmor'))
				itemType = GetLocStringByKeyExt("item_type_heavy_armor");
		}
		else if (dm.ItemHasTag(itemName, 'SecondaryWeapon'))
		{
			itemType = GetLocStringByKeyExt("item_category_secondary");
		}
		else
		{
			itemType = GetLocStringByKeyExt("item_category_" + itemCategory);
		}

		return itemType;
	}
	
	function GetCurrentInventory():CInventoryComponent
	{
		return _inv;
	}

	protected function SetTransmogSectionDataList() : void
	{
		var curDataObject : CScriptedFlashObject;

		
		m_sectionsList = m_flashValueStorage.CreateTempFlashArray();
		curDataObject = CreateSectionsData( 0, 0, 8, "");		
		m_sectionsList.PushBackFlashObject( curDataObject );
		m_flashValueStorage.SetFlashArray( "transmog.appear.grid.section", m_sectionsList );		
	}
	
	protected function CreateSectionsData( id : int, start : int, end : int, label : string ) : CScriptedFlashObject
	{
		var resData : CScriptedFlashObject;
		
		resData = m_flashValueStorage.CreateTempFlashObject( "red.game.witcher3.menus.inventory_menu.ItemSectionData" );
		resData.SetMemberFlashInt( "id", id );
		resData.SetMemberFlashInt( "start", start );
		resData.SetMemberFlashInt( "end", end );
		resData.SetMemberFlashString( "label", label );
		
		return resData;
	}

	private function UpdateGuiSceneEntityItems()
	{
		var guiSceneController : CR4GuiSceneController;
		
		guiSceneController = theGame.GetGuiManager().GetSceneController();
		if ( !guiSceneController )
		{
			return;
		}
		guiSceneController.SetEntityItems( true );
	}

	public function HandleTransmogConfirmation(value:bool):void
	{	
		var price : int = GetTotalTransmogPrice();
		var transmogItemIdList : array<SItemUniqueId>;
		var i : int;
		var itemName : name;
		var appear : name;

		m_fxConfirmAction.InvokeSelfOneArg(FlashArgBool(value));

		if(value)
		{	
			_fixerInventory.AddMoney(price);
			UpdateMerchantData();

			_inv.RemoveMoney(price);
			UpdatePlayerMoney();
			m_fxSetPlayerMoney.InvokeSelfOneArg( FlashArgInt( thePlayer.GetMoney() ) );

			OnPlaySoundEvent("gui_enchanting_runeword_remove");	
			GetTransmogableItemList(transmogItemIdList);

			for(i = 0; i < transmogItemIdList.Size(); i+=1)
			{
				itemName = _inv.GetItemName(transmogItemIdList[i]);
				if(m_transmogData.Contains(itemName) && IsItemBeingTransmogModified(transmogItemIdList[i]))
				{
					appear = m_transmogData[itemName];
					GetWitcherPlayer().UnequipItemFromSlot(_inv.GetSlotForItemId(transmogItemIdList[i]));
					_inv.SetItemTemplateOverride(transmogItemIdList[i], appear == itemName ? 'None' : appear);
					GetWitcherPlayer().EquipItem(transmogItemIdList[i]);
				}
			}

			

			
			ShowTransmogableItems();
			UpdateGuiSceneEntityItems(); 
			OnTransmogItemSelectedByTabIndex(_lastSelectedTab);
		}
		else
		{			
			OnPlaySoundEvent("gui_global_denied");
		}
	}

	private function IsValidTransmog():bool
	{
		var dm : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var transmogItemIdList : array<SItemUniqueId>;
		var i : int;
		var itemName : name;
		var appear : name;

		GetTransmogableItemList(transmogItemIdList);

		for(i = 0; i < transmogItemIdList.Size(); i+=1)
		{
			itemName = _inv.GetItemName(transmogItemIdList[i]);
			if(m_transmogData.Contains(itemName) && m_transmogData[itemName] != '')
			{
				if(_inv.GetItemCategory(transmogItemIdList[i]) != dm.GetItemCategory(m_transmogData[itemName]))
					return false;
			}

		}

		return true;
	}

	private function IsAllSameTransmog():bool
	{
		var transmogItemIdList : array<SItemUniqueId>;
		var i : int;
		var itemName : name;
		var appear : name;

		GetTransmogableItemList(transmogItemIdList);

		for(i = 0; i < transmogItemIdList.Size(); i+=1)
		{
			itemName = _inv.GetItemName(transmogItemIdList[i]);
			if(m_transmogData.Contains(itemName) && m_transmogData[itemName] != '')
			{
				appear = _inv.GetItemTemplateOverride(transmogItemIdList[i]);
				if(appear != '' && _inv.GetItemTemplateOverride(transmogItemIdList[i]) != m_transmogData[itemName])
					return false;
				else if (appear == '' && itemName != m_transmogData[itemName])
					return false;
			}

		}

		return true;
	}

	private function HasNotUnlockedTransmog():bool
	{
		var transmogItemIdList : array<SItemUniqueId>;
		var transmogAvailableList : array<name>;
		var i : int;
		var itemName : name;
		var appear : name;

		GetTransmogableItemList(transmogItemIdList);
		GetWitcherPlayer().GetUnlockedAppearances(transmogAvailableList);

		for(i = 0; i < transmogItemIdList.Size(); i+=1)
		{
			itemName = _inv.GetItemName(transmogItemIdList[i]);
			if(m_transmogData.Contains(itemName) && m_transmogData[itemName] != '')
			{
				appear = m_transmogData[itemName];
				if(!transmogAvailableList.Contains(appear))
					return true;
			}

		}

		return false;
	}

	event  OnRequestConfirmation( ): void
	{			
		var price : int = GetTotalTransmogPrice();
		var playerMoney	 		: int;
		var dm : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var validTransmog : bool = IsValidTransmog();

		playerMoney = _inv.GetMoney();
		if(!validTransmog)
		{	
			Log("DebugTransmog ShowConfirmationPopup INVALID TRANSMOG TYPE");
			showNotification( "DEBUG Develport fail" );
			HandleTransmogConfirmation(false);	
		}
		else if(IsAllSameTransmog())
		{
			showNotification( GetLocStringByKeyExt( "panel_shop_notification_apply_same_transmog" ) );
			HandleTransmogConfirmation(false);		
		}
		else if (HasNotUnlockedTransmog())
		{
			showNotification( GetLocStringByKeyExt( "panel_shop_notification_apply_not_unlocked" ) );
			HandleTransmogConfirmation(false);		
		}
		else if(playerMoney < price)
		{
			showNotification( GetLocStringByKeyExt( "panel_shop_notification_not_enough_money" ) );
			HandleTransmogConfirmation(false);	
		}
		else
		{
			ShowConfirmationPopup( price );
		}		
	}

	public function ShowConfirmationPopup( price : int)
	{
		var confirmationTitle 	: string;
		var confirmationText  	: string;
		var costRepairPoint   	: int;

		confirmationText = "panel_confirmation_text_reforge";
		confirmationTitle = "panel_confirmation_title_reforge";		
		
		InitDataConfirmation = new TransmogPriceConfirmationPopupData in this;
		InitDataConfirmation.SetPrice(price);
		InitDataConfirmation.menuRef = this;
		InitDataConfirmation.BlurBackground = true;
				
		if ( confirmationText != "" )
		{
			InitDataConfirmation.SetMessageText( GetLocStringByKeyExt( confirmationText ) );
		}
				
		if ( confirmationTitle != "" )
		{
			InitDataConfirmation.SetMessageTitle( GetLocStringByKeyExt( confirmationTitle ) );
		}

		RequestSubMenu( 'PopupMenu', InitDataConfirmation );
	}

	event  OnCloseMenu()
	{
		CloseMenu();
		
		if( m_parentMenu )
		{
			m_parentMenu.ChildRequestCloseMenu();
		}

		
		
	}

	private function UpdateTransmogVis():void
	{
		var itemsList : array<SItemUniqueId>;
		var i : int;
		var itemTemplateOverride : name;
		var itemDataMainObject : CScriptedFlashObject;
		var itemDataObject : CScriptedFlashObject;
		var itemsDataList : CScriptedFlashArray;
		var itemName : name;
		var itemAppearanceToChange : name;

		var allUnlockedAppearances : array<name>;

		var dm : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();

		
		GetTransmogableItemList(itemsList);
		GetWitcherPlayer().GetUnlockedAppearances(allUnlockedAppearances);

		itemDataMainObject = m_flashValueStorage.CreateTempFlashObject();
		itemsDataList = m_flashValueStorage.CreateTempFlashArray();
		for ( i = 0; i < itemsList.Size(); i += 1 )
		{
			itemDataObject = m_flashValueStorage.CreateTempFlashObject("red.game.witcher3.menus.common.ItemDataStub");
			_playerGuiInv.SetInventoryFlashObjectForItem(itemsList[i], itemDataObject);

			itemTemplateOverride = _inv.GetItemTemplateOverride(itemsList[i]);

			if(IsItemBeingTransmogModified(itemsList[i]))
			{
				itemDataObject.SetMemberFlashBool( "transmog", _inv.HasTransmogAppearance(itemsList[i]) );
				
			}
			else if (itemTemplateOverride != '')
			{
				itemDataObject.SetMemberFlashBool( "transmog", true );
			}

			if(!dm.CanItemBeColoredByName(itemTemplateOverride))
			{
				itemDataObject.SetMemberFlashString( "itemColor", "" );
			}
			else if( _inv.IsItemColored( itemsList[i] ) )
			{
				itemDataObject.SetMemberFlashString( "itemColor", NameToString( _inv.GetItemColor( itemsList[i] ) ) );
			}

			itemsDataList.PushBackFlashObject(itemDataObject);
		}
		itemDataMainObject.SetMemberFlashArray("equipped", itemsDataList);

		itemsDataList = m_flashValueStorage.CreateTempFlashArray();
		
		for ( i = 0; i < itemsList.Size(); i += 1 )
		{
			itemName = _inv.GetItemName(itemsList[i]);
			itemAppearanceToChange = m_transmogData[itemName];
			itemDataObject = m_flashValueStorage.CreateTempFlashObject("red.game.witcher3.menus.common.ItemDataStub");			
			_playerGuiInv.SetInventoryFlashObjectForAppear(itemsList[i], itemAppearanceToChange, IsItemBeingTransmogModified(itemsList[i]), itemDataObject);
			if(IsItemBeingTransmogModified(itemsList[i]))
				itemDataObject.SetMemberFlashBool("modified", true);
			else
				itemDataObject.SetMemberFlashBool("modified", false);

			if(!allUnlockedAppearances.Contains(itemAppearanceToChange))
				itemDataObject.SetMemberFlashBool("locked", true);
			else
				itemDataObject.SetMemberFlashBool("locked", false);

			if(!dm.CanItemBeColoredByName(itemAppearanceToChange))
			{
				itemDataObject.SetMemberFlashString( "itemColor", "" );
			}
			else if( _inv.IsItemColored( itemsList[i] ) )
			{
				itemDataObject.SetMemberFlashString( "itemColor", NameToString( _inv.GetItemColor( itemsList[i] ) ) );
			}

			itemsDataList.PushBackFlashObject(itemDataObject);
		}
		itemDataMainObject.SetMemberFlashArray("appear", itemsDataList);

		
		m_flashValueStorage.SetFlashObject( "transmog.vis.update", itemDataMainObject );		
	}
}

class TransmogPriceConfirmationPopupData extends ConfirmationPopupData
{
	private var m_Price : float;
	
	public var menuRef : CR4TransmogMenu; 

	public  function GetGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject
	{
		var l_flashObject : CScriptedFlashObject;
		
		l_flashObject = parentFlashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("ContentRef", GetContentRef());
		l_flashObject.SetMemberFlashString("TextContent", m_TextContent);
		l_flashObject.SetMemberFlashString("TextTitle", m_TextTitle);
		l_flashObject.SetMemberFlashNumber("ItempPrice", m_Price);
		return l_flashObject;
	}
	
	public function SetPrice( value : float ) : void
	{
		m_Price = value;
	}
	
	protected function GetContentRef() : string
	{
		return "PriceConfirmationPopupRef";
	}
	
	protected function OnUserAccept() : void
	{
		menuRef.HandleTransmogConfirmation(true);
		ClosePopup();
	}
	
	protected function OnUserDecline() : void
	{
		menuRef.HandleTransmogConfirmation(false);
		ClosePopup();
	}
}