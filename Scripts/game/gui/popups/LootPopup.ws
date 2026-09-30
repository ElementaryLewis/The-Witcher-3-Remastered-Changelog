/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3LootPopupData extends CObject
{
	var targetContainer : W3Container;
}

struct SLootPopupInventoryQuantityPair
{
	var m_container : W3Container;
	var m_uniqueId 	: SItemUniqueId; 
	var m_quantity  : int;
}

class CLootPopupItemData extends CObject
{
	var m_name				: name;
	var m_owningContainers 	: array< SLootPopupInventoryQuantityPair >;

	var m_isSingleton		: bool;

	
	var m_id 				: int;
	var m_label 			: string;
	var m_quantity 			: int;
	var m_iconPath 			: string;
	var m_quality 			: int;
	var m_isRead 			: bool;
	var m_isQuestItem 		: bool;
	var m_questTag 			: string;

	var m_itemType 			: string;
	
	
	

	public function AddNewOwner( container : W3Container, item : SItemUniqueId )
	{
		var l_containerData : SLootPopupInventoryQuantityPair;
		var l_inventory		: CInventoryComponent;

		l_inventory = container.GetInventory();
		l_containerData.m_container = container;
		l_containerData.m_uniqueId = item;
		
		if( m_isSingleton )
		{
			l_containerData.m_quantity = 1;
		}
		else
		{
			l_containerData.m_quantity = Max(l_inventory.GetItemQuantity( item ), 1);
		}

		

		m_owningContainers.PushBack( l_containerData );
		
		m_quantity += l_containerData.m_quantity;
		
	}

	function GetItemRarityDescription( tooltipInv : CInventoryComponent, item : SItemUniqueId ) : string
	{
		var itemQuality : int;
		
		itemQuality = tooltipInv.GetItemQuality(item);
		return GetItemRarityDescriptionFromInt(itemQuality);
	}

	public function Init( container : W3Container, item : SItemUniqueId )
	{
		var l_itemQuantity	: int;
		var l_isSingleton 	: bool;

		var l_inventory		: CInventoryComponent;

		l_inventory = container.GetInventory();
		if( item == GetInvalidUniqueId() )
		{
			return;
		}

		m_id = ItemToFlashUInt(item);
		m_name = l_inventory.GetItemName(item);
		m_label = l_inventory.GetItemLocalizedNameByUniqueID(item);
		m_label = GetLocStringByKeyExt(m_label);
		if ( m_label == "" )
		{
			m_label = " ";
		}

		m_iconPath	= l_inventory.GetItemIconPathByUniqueID( item );

		
		m_questTag = "";
		m_isQuestItem = false;
		if(l_inventory.ItemHasTag(item, 'Quest'))
		{
			m_questTag = "Quest";
			m_isQuestItem = true;
		}
		else if (l_inventory.ItemHasTag(item, 'QuestEP1'))
		{
			m_questTag = "QuestEP1";
			m_isQuestItem = true;
		}
		else if (l_inventory.ItemHasTag(item, 'QuestEP2'))
		{
			m_questTag = "QuestEP2";
			m_isQuestItem = true;
		}

		
		m_isSingleton = l_inventory.IsItemSingletonItem(item);

		m_owningContainers.Clear();
		AddNewOwner( container, item );
		
		
		m_isRead = l_inventory.IsBookReadByName(m_name);

		
		if( l_inventory.IsItemWeapon( item ) || l_inventory.IsItemAnyArmor( item ) )
		{
			m_itemType = GetItemRarityDescription( l_inventory, item );
		}

		
		m_quality = l_inventory.GetItemQuality( item );
		

		
		
		
		
	}	
}

class CR4LootPopup extends CR4PopupBase
{
	private const var KEY_LOOT_ITEM_LIST :string; default KEY_LOOT_ITEM_LIST = "LootItemList";
	
	private var _container 				: W3Container;
	private var m_mergedContainers		: array< W3Container >;
	private var m_cachedItems			: array< CLootPopupItemData >;
	private var m_fxSetWindowTitle 		: CScriptedFlashFunction;
	private var m_fxSetSelectionIndex	: CScriptedFlashFunction;
	private var m_fxSetWindowScale		: CScriptedFlashFunction;
	private var m_fxResizeBackground	:CScriptedFlashFunction;
	private var m_indexToSelect			: int; 							default m_indexToSelect = 0;
	private var safeLock 				: int;							default safeLock = -1;
	private var inputContextSet			: bool; 						default inputContextSet = false;
	
	protected var _tooltipDataProvider	: W3TooltipComponent;
	
	event  OnConfigUI()
	{
		var lootPopupData : W3LootPopupData;
		var targetSize : float;
		
		super.OnConfigUI();
		
		setupFunctions();
		
		lootPopupData = (W3LootPopupData)GetPopupInitData();
		
		theGame.ForceUIAnalog(true);
		theGame.GetGuiManager().RequestMouseCursor(true);
		
		_tooltipDataProvider = new W3TooltipComponent in this;
		
		if (lootPopupData && lootPopupData.targetContainer && !theGame.IsDialogOrCutscenePlaying() && !theGame.GetGuiManager().IsAnyMenu())
		{
			theInput.StoreContext( 'EMPTY_CONTEXT' );
			inputContextSet = true;
			
			
			
			theSound.SoundEvent("gui_loot_popup_open");
			
			_container = lootPopupData.targetContainer;

			_tooltipDataProvider.initialize(thePlayer.GetInventory(), m_flashValueStorage);
			
			PopulateData();
			
			SignalLootingReactionEvent();
			
			if (StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('Hud', 'HudSize'), 0) == 0)
			{
				targetSize = 0.85;
				if (theInput.IsMousePresent())
				{
					theGame.MoveMouseTo(0.4, 0.63);
				}
			}
			else
			{
				targetSize = 1;
				if (theInput.IsMousePresent())
				{
					theGame.MoveMouseTo(0.4, 0.58);
				}
			}
			
			m_fxSetWindowScale.InvokeSelfOneArg(FlashArgNumber(targetSize));
		}
		else
		{
			ClosePopup();
		}
	}
	
	private function setupFunctions():void
	{
		m_fxSetWindowTitle = m_flashModule.GetMemberFlashFunction( "SetWindowTitle" );
		m_fxSetSelectionIndex = m_flashModule.GetMemberFlashFunction( "SetSelectionIndex" );
		m_fxSetWindowScale = m_flashModule.GetMemberFlashFunction( "SetWindowScale" );
		m_fxResizeBackground = m_flashModule.GetMemberFlashFunction( "resizeBackground" );
		
	}
	
	event  OnClosingPopup()
	{
		var i : int;

		theSound.SoundEvent("gui_loot_popup_close");
		super.OnClosingPopup();
		if (theInput.GetContext() == 'EMPTY_CONTEXT' && inputContextSet)
		{
			theInput.RestoreContext( 'EMPTY_CONTEXT', false );
		}
		
		theGame.GetGuiManager().RequestMouseCursor(false);
		theGame.ForceUIAnalog(false);

		SignalContainerClosedEvent();
		
		
		if(ShouldProcessTutorial('TutorialLootWindow'))
		{
			FactsAdd("tutorial_container_close", 1, 1 );	
		}
		if( _container )
		{
			_container.OnContainerClosed();
		}

		for(i = 0; i <m_mergedContainers.Size(); i+=1)
		{
			if(m_mergedContainers[ i ])
			{
				m_mergedContainers[ i ].OnContainerClosed();
			}
		}
		
		if (_tooltipDataProvider)
		{
			delete _tooltipDataProvider;
		}
	}
	
	public function UpdateInputContext():void
	{
		var currentContext : name;
		
		currentContext = theInput.GetContext();
		if (inputContextSet && currentContext != 'EMPTY_CONTEXT')
		{
			theInput.RestoreContext(currentContext, true);
			if (theInput.GetContext() == 'EMPTY_CONTEXT') 
			{
				theInput.RestoreContext('EMPTY_CONTEXT', true);
			}
			
			theInput.StoreContext(currentContext);
			
			ClosePopup();
		}
	}

	function ShouldShowItem( containerInv : CInventoryComponent, item : SItemUniqueId ) : bool
	{
		return !containerInv.ItemHasTag(item, theGame.params.TAG_DONT_SHOW ) || containerInv.ItemHasTag(item, 'Lootable' );
	}

	function BuildCache(rootContainer : W3Container, range : float, containerClass : name )
	{
		var i, j							: int;
		var l_containerIndex				: int;
		var l_addNewEntry					: bool;
		var l_itemWasAdded					: bool;

		var l_items							: array<SItemUniqueId>;
		var l_item 							: SItemUniqueId;

		var l_mergedContainerEntities 		: array<CGameplayEntity>;
		var l_itemData 						: CLootPopupItemData;

		var l_currentContainer				: W3Container;
		var l_containerInv 					: CInventoryComponent = rootContainer.GetInventory();

		l_containerInv.GetAllItems( l_items );

		for(i = 0; i < l_items.Size(); i+=1)
		{
			l_item = l_items[i];
			if( ShouldShowItem( l_containerInv, l_item) )
			{
				l_itemData = new CLootPopupItemData in this;
				l_itemData.Init( rootContainer, l_item );
				m_cachedItems.PushBack( l_itemData );
			}
		}

		if( range <= 0.f || containerClass == '')
		{
			return;
		}

		FindGameplayEntitiesInRange(l_mergedContainerEntities, _container, range, 100, '', 0, NULL, containerClass);
		for	( l_containerIndex = 0 ; l_containerIndex < l_mergedContainerEntities.Size(); l_containerIndex+=1 )
		{
			
			if( !l_mergedContainerEntities[ l_containerIndex ] || l_mergedContainerEntities[ l_containerIndex ].HasTag('lootbag') )
			{
				continue;
			}

			l_currentContainer = (W3Container)l_mergedContainerEntities[ l_containerIndex ];
			if( !l_currentContainer || l_currentContainer == rootContainer )
			{
				continue;
			}

			l_containerInv = l_currentContainer.GetInventory();
			l_containerInv.GetAllItems(l_items); 

			l_itemWasAdded = false;
			for(i = 0; i < l_items.Size(); i+=1)
			{
				l_item = l_items[i];

				if( !ShouldShowItem( l_containerInv, l_item) )
				{
					continue;
				}
				
				l_addNewEntry = true;
				l_itemWasAdded = true;

				if( !l_containerInv.IsItemSingletonItem( l_item ))
				{
					for( j = 0; j < m_cachedItems.Size(); j+=1 )
					{
						l_itemData = m_cachedItems[ j ];

						if( l_containerInv.GetItemName( l_item ) == l_itemData.m_name )
						{
							l_itemData.AddNewOwner( l_currentContainer, l_item );
							l_addNewEntry = false;
						}
					}
				}

				if(l_addNewEntry)
				{
					l_itemData = new CLootPopupItemData in this;
					l_itemData.Init(l_currentContainer, l_item);
					m_cachedItems.PushBack(l_itemData);
				}
			}

			if(l_itemWasAdded)
			{
				m_mergedContainers.PushBack( l_currentContainer );
			}
		}			
	}

	function PopulateData()
	{
		var l_mergeLoot : bool = ((bool)theGame.GetInGameConfigWrapper().GetVarValue('Gameplay', 'LootMergeEnabled')) == true;
						
		
		if( (W3ActorRemains)_container && l_mergeLoot && !_container.HasTag('lootbag') )
		{
			BuildCache(_container, 15.f, 'W3ActorRemains' );
		}
		else
		{
			BuildCache(_container, -1.f, '' );
		}
		
		UpdateFlashObjects();	
	}

	function UpdateFlashObjects()
	{
		var i, length						: int;
		var l_lootItemsFlashArray			: CScriptedFlashArray;
		var l_lootItemsDataFlashObject 		: CScriptedFlashObject;
		
		var l_cachedItemData 				: CLootPopupItemData;

		length	= m_cachedItems.Size();
		if(length > 4)
		{
			m_fxResizeBackground.InvokeSelfOneArg(FlashArgBool(true));
		}
		else
		{
			m_fxResizeBackground.InvokeSelfOneArg(FlashArgBool(false));
		}
	
		l_lootItemsFlashArray = m_flashValueStorage.CreateTempFlashArray();
		l_lootItemsFlashArray.SetLength( length );

		for(i = 0; i < length; i+=1)
		{
			l_cachedItemData = m_cachedItems[ i ];
			if(!l_cachedItemData || l_cachedItemData.m_owningContainers.Size() == 0)
			{
				continue;
			}

			if( !l_cachedItemData.m_owningContainers[0].m_container )
			{
				continue;
			} 

			l_lootItemsDataFlashObject = m_flashValueStorage.CreateTempFlashObject();

			l_lootItemsDataFlashObject.SetMemberFlashString	( "id", l_cachedItemData.m_id );
			l_lootItemsDataFlashObject.SetMemberFlashString	( "label", l_cachedItemData.m_label );
			l_lootItemsDataFlashObject.SetMemberFlashInt	( "quantity", l_cachedItemData.m_quantity );
			l_lootItemsDataFlashObject.SetMemberFlashString ( "iconPath", l_cachedItemData.m_iconPath );
			l_lootItemsDataFlashObject.SetMemberFlashInt	( "quality", l_cachedItemData.m_quality );
			l_lootItemsDataFlashObject.SetMemberFlashBool	( "isRead", l_cachedItemData.m_isRead );
			l_lootItemsDataFlashObject.SetMemberFlashBool   ( "isQuestItem", l_cachedItemData.m_isQuestItem );
			l_lootItemsDataFlashObject.SetMemberFlashString ( "questTag", l_cachedItemData.m_questTag );
			l_lootItemsDataFlashObject.SetMemberFlashInt 	( "cacheIndex", i );

			l_lootItemsFlashArray.SetElementFlashObject( i, l_lootItemsDataFlashObject );
		}

		m_flashValueStorage.SetFlashArray( KEY_LOOT_ITEM_LIST, l_lootItemsFlashArray );
		m_fxSetWindowTitle.InvokeSelfOneArg( FlashArgString( _container.GetDisplayName() ) );	
	}
	
	function GetItemRarityDescription( item : SItemUniqueId, tooltipInv : CInventoryComponent ) : string
	{
		var itemQuality : int;
		
		itemQuality = tooltipInv.GetItemQuality(item);
		return GetItemRarityDescriptionFromInt(itemQuality);
	}
	
	event  OnPopupTakeAllItems( ) : void
	{
		GetWitcherPlayer().StartInvUpdateTransaction();
		SignalStealingReactionEvent();
		TakeAllAction();
		GetWitcherPlayer().FinishInvUpdateTransaction();
		
		OnCloseLootWindow();
	}
	
	event  OnPopupTakeItem( Id : int ) : void
	{
		var cachedItemData 		: CLootPopupItemData;
		var containerInv 		: CInventoryComponent;
		var playerInv 			: CInventoryComponent;
		var item 				: SItemUniqueId;
		var invalidatedItems 	: array< SItemUniqueId >;
		var itemName 			: name;
		var itemQuantity, i		: int;
		var category			: name;
		
		SignalStealingReactionEvent();
		
		m_indexToSelect = Id;

		playerInv 		= GetWitcherPlayer().inv;

		cachedItemData = m_cachedItems[ Id ];

		containerInv = cachedItemData.m_owningContainers[ 0 ].m_container.GetInventory();

		item = cachedItemData.m_owningContainers[ 0 ].m_uniqueId;
		itemName = containerInv.GetItemName(item);
		if( containerInv.ItemHasTag(item, 'HerbGameplay') )
		{
			category 	= 'herb';
		}
		else
		{
			category	= containerInv.GetItemCategory(item);
		}

		for(i = 0; i < cachedItemData.m_owningContainers.Size(); i+=1)
		{
			if( !cachedItemData.m_owningContainers[ i ].m_container )
			{
				continue;
			}

			containerInv = cachedItemData.m_owningContainers[ i ].m_container.GetInventory();
			item = cachedItemData.m_owningContainers[ i ].m_uniqueId;

			itemQuantity 	= containerInv.GetItemQuantity(item);

			containerInv.NotifyItemLooted( item );
			containerInv.GiveItemTo( playerInv, item, itemQuantity, true, false, true );

			cachedItemData.m_owningContainers[ i ].m_container.InformClueStash();
		}		

		m_cachedItems.Erase(Id);
		PlayItemEquipSound( category );
		
		if( m_cachedItems.Size() == 0)
		{
			OnCloseLootWindow();
		}
		else
		{
			m_fxSetSelectionIndex.InvokeSelfOneArg( FlashArgInt( m_indexToSelect ) );
			UpdateFlashObjects();
		}
	}
	
	event  OnCloseLootWindow()
	{
		ClosePopup();
	}
	
	
	function TakeAllAction() : void
	{
		var i : int;
	
		_container.TakeAllItems();

		for	( i = 0 ; i < m_mergedContainers.Size(); i+=1 )
		{
			if( m_mergedContainers[i] )
			{
				m_mergedContainers[i].TakeAllItems();
			}
		}
	}
	
	protected function SignalLootingReactionEvent()
	{
		if ( _container.disableStealing )
			return;
		if ( _container.HasQuestItem() )
			return;
		if ( (W3Herb)_container )
			return;
		if ( (W3ActorRemains)_container )
			return;
			
		theGame.CreateNoSaveLock("Stealing",safeLock,true);
		
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'LootingAction', -1, 10.0f, -1.f, -1, true); 
	}
	
	protected function SignalStealingReactionEvent()
	{
		if ( _container.disableStealing || _container.HasQuestItem() || (W3Herb)_container || (W3ActorRemains)_container )
			return;
		
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'StealingAction', -1, 10.0f, -1.f, -1, true); 
	}
	
	protected function SignalContainerClosedEvent()
	{
		theGame.ReleaseNoSaveLock(safeLock);
		
		if ( _container.disableStealing || _container.HasQuestItem() || (W3Herb)_container || (W3ActorRemains)_container )
			return;
			
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'ContainerClosed', 10, 15.0f, -1.f, -1, true); 
	}

	event OnGetItemData(item : SItemUniqueId, compareItemType : int, cacheIndex : int) 
	{
		ShowItemTooltip(item, compareItemType, cacheIndex);
	}
	
	event OnGetItemDataForMouse(item : SItemUniqueId, compareItemType : int, cacheIndex : int) 
	{
		ShowItemMouseTooltip(item, compareItemType, cacheIndex);
	}

	public function ShowItemTooltip(item : SItemUniqueId, compareItemType : int, cacheIndex : int) : void
	{
		var tooltipData : CScriptedFlashObject;
		var cachedItem : CLootPopupItemData;
		
		if(m_cachedItems.Size() > cacheIndex && cacheIndex >= 0)
		{
			cachedItem = m_cachedItems[cacheIndex];

			if(cachedItem.m_owningContainers.Size() > 0 && cachedItem.m_owningContainers[0].m_container)
			{
				_tooltipDataProvider.setCurrentInventory(cachedItem.m_owningContainers[0].m_container.GetInventory());
				tooltipData = _tooltipDataProvider.GetTooltipData(item, false, true);
				m_flashValueStorage.SetFlashObject("context.tooltip.data", tooltipData);
			}
		}
	}
	
	public function ShowItemMouseTooltip(item : SItemUniqueId, compareItemType : int, cacheIndex : int) : void
	{
		var tooltipData : CScriptedFlashObject;
		var cachedItem : CLootPopupItemData;
		
		if(m_cachedItems.Size() > cacheIndex && cacheIndex >= 0)
		{
			cachedItem = m_cachedItems[cacheIndex];
			if(cachedItem.m_owningContainers.Size() > 0 && cachedItem.m_owningContainers[0].m_container)
			{
				_tooltipDataProvider.setCurrentInventory(cachedItem.m_owningContainers[0].m_container.GetInventory());
				tooltipData = _tooltipDataProvider.GetTooltipData(item, false, true);
				m_flashValueStorage.SetFlashObject("context.tooltip.data", tooltipData);
			}
		}
	}
}

exec function CloseLootPopup()
{
	theGame.ClosePopup('LootPopup');
}