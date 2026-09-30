/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SJournalUpdate
{
	var text		  : string;
	var title		  : string;
	var status		  : EJournalStatus;
	var journalEntry  : CJournalBase;
	var iconPath	  : string;
	var panelName	  : name; 
	var entryTag	  : name; 
	var soundEvent	  : string;
	var isQuestUpdate : bool;	
	var displayTime   : float;
	var itemId 	      : SItemUniqueId; 
	var isItemUpdate  : bool;
	var tag			  : name;
	var existTime	  : float; default existTime = 0;
	
	default title = "";
};

class CR4HudModuleJournalUpdate extends CR4HudModuleBase
{	
	private var _bDuringDisplay : bool;		default _bDuringDisplay = false;
	
	private var m_fxShowJournalUpdateSFF			: CScriptedFlashFunction;
	private var m_fxSetJournalUpdateStatusSFF		: CScriptedFlashFunction;
	private var m_fxSetJournalUpdateStatusTextSFF	: CScriptedFlashFunction;
	private var m_fxClearJournalUpdateSFF			: CScriptedFlashFunction;	
	private var m_fxSetIconSFF			    		: CScriptedFlashFunction;
	private var m_fxHideItemInfo					: CScriptedFlashFunction;
	private var m_fxPauseShowTimer					: CScriptedFlashFunction;
	
	private var questsUpdates	: array< CJournalQuest>;
	private var journalUpdates	: array< SJournalUpdate>;
	private var manager : CWitcherJournalManager;
	private var m_guiManager : CR4GuiManager;	
	private var m_flashValueStorage : CScriptedFlashValueStorage;
	private var m_defaultInputBindings : array<SKeyBinding>;
	private var m_bookItemId : SItemUniqueId;
	private var m_bookPopupData : BookPopupFeedback;
	private var m_paintingPopupData  : PaintingPopup;
	
	private var bShowTimerStopped : bool;
	private var bWasRemoved : bool;
	private var defaultDisplayTime : float;
	private var defaultBookInfoDisplayTime : float;
	private var defaultTrackableDisplayTime : float;

	private var minExistTime : float; default minExistTime = 0.5;
	private var maxQuestTimeRange : float; default maxQuestTimeRange = 0.5;
	
	default defaultDisplayTime = 3000; 
	default defaultBookInfoDisplayTime = 6000;
	default defaultTrackableDisplayTime = 6000;
	default bWasRemoved = true;
	default bShowTimerStopped = false;
	
	event  OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		m_anchorName = "mcAnchorJournalUpdate";
		super.OnConfigUI();
	
		flashModule = GetModuleFlash();
		m_flashValueStorage = GetModuleFlashValueStorage();
		m_fxShowJournalUpdateSFF = flashModule.GetMemberFlashFunction( "ShowJournalUpdate" );
		m_fxSetJournalUpdateStatusSFF = flashModule.GetMemberFlashFunction( "SetJournalUpdateStatus" );
		m_fxClearJournalUpdateSFF = flashModule.GetMemberFlashFunction( "ClearJournalUpdate" );
		m_fxSetIconSFF = flashModule.GetMemberFlashFunction( "SetIcon" );
		m_fxHideItemInfo = flashModule.GetMemberFlashFunction( "hideItemInfo" );
		m_fxPauseShowTimer = flashModule.GetMemberFlashFunction( "PauseShowTimer" );
		
		manager = theGame.GetJournalManager();
		m_guiManager = theGame.GetGuiManager();
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		
		
		
		
		
	}

	private function TickUpdateTimes(timeDelta : float):void
	{
		var i : int;

		for(i = 0; i < journalUpdates.Size(); i+=1)
		{
			journalUpdates[i].existTime += timeDelta;
		}
	}

	event OnTick( timeDelta : float )
	{
		var currentContext : name;		
		
		if( !theGame.IsPausedForReason( "Popup" ) )
		{
			TickUpdateTimes(timeDelta);
			if( !_bDuringDisplay )
			{
				if( CheckPending() )
				{
					DisplayPending();
				}
			}
			else if(journalUpdates.Size() > 0)
			{
				if( !CheckSceneAndCutsceneDisplay(journalUpdates[0].status,journalUpdates[0].isQuestUpdate) )
				{
					m_fxClearJournalUpdateSFF.InvokeSelf();
					OnRemoveUpdate();
					OnShowUpdateEnd();
				}
			}
		}
		
		if( theGame.IsPaused() )
		{
			if ( !bShowTimerStopped )
			{
				bShowTimerStopped = true;
				m_fxPauseShowTimer.InvokeSelfOneArg( FlashArgBool( true ) );
			}
		}
		else
		{
			if ( bShowTimerStopped )
			{
				bShowTimerStopped = false;
				m_fxPauseShowTimer.InvokeSelfOneArg( FlashArgBool( false ) );
			}
		}
		
		
		
		currentContext = theInput.GetContext();
		
		if ( thePlayer.inv.IsIdValid( m_bookItemId ) && currentContext == 'Scene')
		{
			m_bookItemId = GetInvalidUniqueId();
			m_fxHideItemInfo.InvokeSelf();
		}
		
		if( m_bookPopupData && currentContext == 'Scene' )
		{
			m_bookPopupData.ClosePopupOverlay();
			delete m_bookPopupData;
		}
	}
	
	public function isBookInfoShown():bool
	{
		return thePlayer.inv.IsIdValid( m_bookItemId ) || m_bookPopupData;
	}

	event OnInputHandled(NavCode:string, KeyCode:int, ActionId:int)
	{
		
	}

	private function IsQuestEndingLogicDoable():bool
	{
		return journalUpdates[0].existTime > maxQuestTimeRange;
	}

	private function IsJournalUpdateQuestSubType(currentUpdate : SJournalUpdate):bool
	{
		return currentUpdate.tag == 'item' || currentUpdate.tag == 'alchemy' || currentUpdate.tag == 'crafting' || currentUpdate.tag == 'mappin' ||currentUpdate.tag == 'bestiary' || currentUpdate.tag == 'glossary' || currentUpdate.tag == 'character';
	}

	private function GetCategoryItemPath( itemName : name ) : string
	{
		var itemId : SItemUniqueId;
		var itemTags : array<name>;
		var category : name;

		itemId = thePlayer.inv.GetItemId(itemName);
		category = thePlayer.inv.GetItemCategory(itemId);
		thePlayer.inv.GetItemTags( itemId, itemTags );

		if(itemName == 'Crowns')
		{
			return "icons\hud\quest\icon_coins.png";
		}
		else if(itemTags.Contains('Quest'))
		{
			return "icons\hud\quest\icon_quest_item.png";
		}
		else if(itemTags.Contains('Upgrade') || itemTags.Contains('WeaponUpgrade') || itemTags.Contains('ArmorUpgrade'))
		{
			return "icons\hud\quest\icon_weapon_armor.png";
		}
		else if(category == 'steelsword' || category == 'silversword' || category == 'armor' || category == 'gloves' || category == 'pants' || category == 'boots' || category == 'crossbow')
		{
			return "icons\hud\quest\icon_weapon_armor.png";
		}
		else if(itemTags.Contains('mod_alchemy') || itemTags.Contains('Potion') || category == 'oil')
		{
			return "icons\hud\quest\icon_potions.png";
		}
		else if(itemTags.Contains('ReadableItem'))
		{
			return "icons\hud\quest\icon_books.png";
		}

		
		
		
		
		return "icons\hud\quest\icon_default_sack.png";
	}

	private function DoQuestEndingLogic(doable : bool):void
	{
		var items : array<SJournalUpdate>;
		var currentUpdate : SJournalUpdate;
		var i : int;
		var gfxDataObj : CScriptedFlashObject;
		var gfxDataSubArray : CScriptedFlashArray;
		var gfxDataSubObj : CScriptedFlashObject;
		var questUpdate : SJournalUpdate;


		if(!doable)
		{
			
			return;
		}

		gfxDataObj = m_flashValueStorage.CreateTempFlashObject();

		gfxDataSubArray = m_flashValueStorage.CreateTempFlashArray();

		m_fxSetJournalUpdateStatusSFF.InvokeSelfOneArg(FlashArgInt(8));
		ShowElement(true);

		
		gfxDataObj.SetMemberFlashNumber("minOnlineTime", 3.5);
		gfxDataObj.SetMemberFlashNumber("itemRendererLifeTime", 3);
		gfxDataObj.SetMemberFlashNumber("itemRendererFadeInTime", 0.6);
		gfxDataObj.SetMemberFlashNumber("itemRendererFadeOutTime", 0.5);
		gfxDataObj.SetMemberFlashNumber("itemRendererSpawnDelay", 0.5);
		gfxDataObj.SetMemberFlashNumber("itemRendererMoveTime", 0.4);

		for(i = 0; i < journalUpdates.Size(); i+=1)
		{
			currentUpdate = journalUpdates[i];

			if(currentUpdate.journalEntry && currentUpdate.tag == 'quest' && questUpdate.journalEntry && currentUpdate.journalEntry != questUpdate.journalEntry) 
			{
				continue;
			}
			if(currentUpdate.journalEntry && currentUpdate.tag == 'quest')
			{
				journalUpdates[i].tag = 'questShown';
				gfxDataObj.SetMemberFlashString("title", currentUpdate.title);
				gfxDataObj.SetMemberFlashString("text", currentUpdate.text);
				gfxDataObj.SetMemberFlashString("crest", GetAreaName((CJournalQuest)(currentUpdate.journalEntry))); 
				gfxDataObj.SetMemberFlashInt("colorId", currentUpdate.status);
				questUpdate = currentUpdate;
				OnPlaySoundEvent( currentUpdate.soundEvent );

				
				continue;
			}
			else if (currentUpdate.tag == 'exp')
			{
				if(items.Size() > 0)
					items.Insert(0, currentUpdate);
				else
					items.PushBack(currentUpdate);
			}
			else if (IsJournalUpdateQuestSubType(currentUpdate))
			{
				if(currentUpdate.iconPath == "")
					currentUpdate.iconPath = GetEntryIconPath(currentUpdate.journalEntry);
				items.PushBack(currentUpdate);
			}
			else if(currentUpdate.existTime - questUpdate.existTime > maxQuestTimeRange)
			{
				break; 
			}
			else 
			{
				continue;
			}

			journalUpdates.Erase(i);
			i-=1;
		}

		for(i = 0; i < items.Size(); i+=1)
		{
			gfxDataSubObj = m_flashValueStorage.CreateTempFlashObject();
			if(items[i].tag == 'mappin')
				gfxDataSubObj.SetMemberFlashString("mappinType", items[i].entryTag);
			else if (items[i].tag == 'item')
			{
				items[i].iconPath = GetCategoryItemPath(items[i].entryTag);
			}
			gfxDataSubObj.SetMemberFlashString("text", items[i].text);
			gfxDataSubObj.SetMemberFlashString("iconPath", items[i].iconPath);
			gfxDataSubArray.PushBackFlashObject(gfxDataSubObj);
		}
		gfxDataObj.SetMemberFlashArray("items",gfxDataSubArray);
		m_flashValueStorage.SetFlashObject("hud.journal.update.quest.finished", gfxDataObj);
		_bDuringDisplay = true;

		m_defaultInputBindings.Clear();
		if( ( theInput.GetContext() != 'Scene' ) && ( questUpdate.journalEntry || IsNameValid( questUpdate.entryTag ) && !thePlayer.IsCiri() ) )
		{			
			if( IsTrackableQuest() )
			{			
				RegisterKeyBindings("panel_button_journal_track");
				
				if( ShouldProcessTutorial( 'TutorialNotTrackedQuestUpdate' ) )
				{
					FactsAdd( 'tut_not_tracked_quest_updates' );
				}
			}
		}

		UpdateInputFeedback();
	}

	function EliminateNonprioUpdates():void
	{
		var i : int;
		var bFound : bool;
		var currentEntry : CJournalBase;
		var currentUpdate : SJournalUpdate;
		var lastPosition : int;
		var lastStatus : int;

		lastPosition = journalUpdates.Size();

		while(true)
		{
			bFound = false;

			for(i = lastPosition - 1; i >= 0; i-= 1)
			{
				currentUpdate = journalUpdates[i];

				if(!bFound && currentUpdate.journalEntry)
				{
					currentEntry = currentUpdate.journalEntry;
					bFound = true;
					lastPosition = i;
					lastStatus = currentUpdate.status;
					continue;
				}

				if(bFound && currentUpdate.journalEntry == currentEntry && currentUpdate.status <= lastStatus) 
				{
 					journalUpdates.Erase(i);
					lastPosition -=1;
				}
			}

			if(!bFound)
				break;
		}
	}

	
	function RepositionQuestUpdates():void
	{
		var i : int;
		var currentUpdate : SJournalUpdate;
		var inactiveCount : int = 0;
		var activeCount : int = 0;
		var successCount : int = 0;
		var failedCount : int = 0;
		var localCount : int = 0;

		for(i = 0; i < journalUpdates.Size(); i+=1)
		{
			currentUpdate = journalUpdates[i];
			if(currentUpdate.tag == 'quest')
			{
				journalUpdates.Erase(i);

				switch(currentUpdate.status)
				{
					case JS_Inactive:
						localCount = inactiveCount + activeCount + successCount + failedCount;
						inactiveCount+=1;
						break;
					case JS_Active:
						localCount = activeCount + successCount + failedCount;
						activeCount+=1;
						break;
					case JS_Success:
						localCount = successCount + failedCount;
						successCount+=1;
						break;
					case JS_Failed:
						localCount = failedCount;
						failedCount+=1;
						break;
				}
				journalUpdates.Insert(localCount, currentUpdate);
			}
		}
	}

	function CheckPending() : bool
	{	
		if( GetPendingSize() > 0 && journalUpdates[0].existTime > minExistTime && theInput.GetContext() != 'RadialMenu' && theInput.GetContext() != 'Death' )
		{
			return true;
		}
		return false;
	}

	function DisplayPending()
	{
		var title : string;
		var offset : int;
		var isTrackableQuest : bool;
		var isCutscene : bool;
		var itemId : SItemUniqueId;
		var lootPopup : CR4LootPopup;
		
		if ( theGame.IsBlackscreen() || theGame.IsFading() )
		{
			return;
		}
		if(journalUpdates.Size() > 1)
		{
			EliminateNonprioUpdates();
			RepositionQuestUpdates();
		}

		
 		if(journalUpdates[0].tag == 'quest')
		{
			DoQuestEndingLogic(IsQuestEndingLogicDoable());
			return;
		}

		_bDuringDisplay = true;
		isCutscene = theInput.GetContext() == 'Scene';
		
		
		
		lootPopup = (CR4LootPopup)theGame.GetGuiManager().GetPopup('LootPopup');
		itemId = journalUpdates[0].itemId;
		if (thePlayer.inv.IsIdValid(itemId) && !isCutscene )
		{
			if (lootPopup)
			{
				
				_bDuringDisplay = false;
				return;
			}
			
			m_fxSetJournalUpdateStatusSFF.InvokeSelfOneArg(FlashArgInt(1));
			ShowElement(true);
			ShowItemInfo(itemId);
			journalUpdates.Erase(0);
			return;
		}
		
		
		
		
		
		if( (CJournalQuest)journalUpdates[0].journalEntry )
		{
			if( !CheckSceneAndCutsceneDisplay(journalUpdates[0].status,journalUpdates[0].isQuestUpdate) )
			{
				if( journalUpdates.Size() > 0 )
				{
					journalUpdates.Erase(0);
				}
				_bDuringDisplay = false;
				return;
			}
		}
		
		title =  journalUpdates[0].title;
		offset = 1;
		if(	journalUpdates[0].iconPath != "" )
		{
			offset += 4;
		}
		
		m_fxSetJournalUpdateStatusSFF.InvokeSelfOneArg(FlashArgInt(journalUpdates[0].status + offset));
		
		isTrackableQuest = IsTrackableQuest();
		if( journalUpdates[0].displayTime == 0 )
		{
			if (isTrackableQuest)
			{
				journalUpdates[0].displayTime = defaultTrackableDisplayTime;
			}
			else
			{
				journalUpdates[0].displayTime = defaultDisplayTime;
			}
		}
		
		m_fxShowJournalUpdateSFF.InvokeSelfThreeArgs( FlashArgString(journalUpdates[0].text), FlashArgString(title), FlashArgNumber(journalUpdates[0].displayTime) );
		m_fxSetIconSFF.InvokeSelfOneArg(FlashArgString(journalUpdates[0].iconPath));
		ShowElement(true);
		
		
		if ( journalUpdates[0].soundEvent == "" )
			journalUpdates[0].soundEvent = "gui_ingame_quest_active";
		
		if( journalUpdates[0].soundEvent != "" && bWasRemoved )
		{
			if( !( theGame.IsBlackscreen() || theGame.IsFading() ) )
			{
				OnPlaySoundEvent( journalUpdates[0].soundEvent );
			}
		}
		
		m_defaultInputBindings.Clear();
		if( ( theInput.GetContext() != 'Scene' ) && ( journalUpdates[0].journalEntry || IsNameValid( journalUpdates[0].entryTag ) && !thePlayer.IsCiri() ) )
		{			
			if( isTrackableQuest )
			{			
				RegisterKeyBindings("panel_button_journal_track");
				
				if( ShouldProcessTutorial( 'TutorialNotTrackedQuestUpdate' ) )
				{
					FactsAdd( 'tut_not_tracked_quest_updates' );
				}
			}
		}
		UpdateInputFeedback();
		bWasRemoved = false;
	}	
	
	private function ShowItemInfo(itemId : SItemUniqueId):void
	{
		var outKeysPC 	 : array< EInputKey >;
		var itemInfoData : CScriptedFlashObject;
		var playerInv    : CInventoryComponent;
		var itemName     : string;
		var iconPath     : string;
		
		playerInv = thePlayer.inv;
		itemName = GetLocStringByKeyExt( playerInv.GetItemLocalizedNameByUniqueID( itemId ) );
		iconPath = playerInv.GetItemIconPathByUniqueID( itemId );
		m_bookItemId = itemId;
		
		outKeysPC.Clear();
		theInput.GetPCKeysForAction( 'TrackQuest' ,outKeysPC );
		
		theInput.RegisterListener( this, 'OnTrackQuest', 'TrackQuest' );
		
		
		itemInfoData = m_flashValueStorage.CreateTempFlashObject();
		itemInfoData.SetMemberFlashNumber("showTime", defaultBookInfoDisplayTime);
		itemInfoData.SetMemberFlashString("itemName", itemName);
		itemInfoData.SetMemberFlashString("iconPath", "img://" + iconPath);
		itemInfoData.SetMemberFlashString("buttonLabel", GetLocStringByKeyExt("panel_button_inventory_read"));
		itemInfoData.SetMemberFlashString("gpadCode", "gamepad_R_Hold");
		
		if (outKeysPC.Size() > 0)
		{
			itemInfoData.SetMemberFlashInt("keyCode", outKeysPC[0]);
		}
		else
		{
			itemInfoData.SetMemberFlashInt("keyCode", -1);
		}
		
		
		m_flashValueStorage.SetFlashObject("hud.journalupdate.bookinfo", itemInfoData);	
	}
	
	private function ShowItemInfoPopup( itemId : SItemUniqueId )
	{
		var uiData : SInventoryItemUIData;
		var playerInv    : CInventoryComponent;
		var itemName     : name;
		
		playerInv = thePlayer.inv;
		
		if (m_bookPopupData)
		{
			delete m_bookPopupData;
		}
		
		if (m_paintingPopupData)
		{
			delete m_paintingPopupData;
		}
		
		if( playerInv.ItemHasTag( itemId, 'Painting' ) )
		{
			itemName = playerInv.GetItemName( itemId );
			
			m_paintingPopupData = new PaintingPopup in this;
			m_paintingPopupData.SetMessageTitle( GetLocStringByKeyExt( playerInv.GetItemLocalizedNameByUniqueID( itemId ) ) );
			m_paintingPopupData.SetImagePath("img://icons/inventory/paintings/" + itemName + ".png");
			m_paintingPopupData.PauseGame = true;
			
			theGame.RequestMenu('PopupMenu', m_paintingPopupData);
		}
		else
		{
			m_bookPopupData = new BookPopupFeedback in this;
			m_bookPopupData.SetMessageTitle( GetLocStringByKeyExt(playerInv.GetItemLocalizedNameByUniqueID(itemId)) );
			m_bookPopupData.SetMessageText( playerInv.GetBookText(itemId) );
			m_bookPopupData.curInventory = thePlayer.GetInventory();
			m_bookPopupData.PauseGame = true;
			m_bookPopupData.bookItemId = itemId;
			
			theGame.RequestMenu('PopupMenu', m_bookPopupData);
		}
		
		m_fxHideItemInfo.InvokeSelf();
		playerInv.ReadBook( itemId );
		
		
	}
	
	private function RegisterKeyBindings(label : string):void
	{
		var outKeys 				: array< EInputKey >;
		var outKeysPC 				: array< EInputKey >;
		
		outKeys.Clear();
		outKeysPC.Clear();
		
		theInput.GetPadKeysForAction( 'TrackQuest' ,outKeys );
		theInput.GetPCKeysForAction( 'TrackQuest' ,outKeysPC );
		theInput.RegisterListener( this, 'OnTrackQuest', 'TrackQuest' );
		
		if( outKeys.Size() + outKeysPC.Size() > 0 )
		{
			if (outKeysPC.Size() > 0)
			{
				AddInputBinding(label, "gamepad_R_Hold", outKeysPC[0]);
			}
			else
			{
				AddInputBinding(label, "gamepad_R_Hold", -1);
			}
		}
	}
	
	function IsTrackableQuest() : bool
	{
		var curUpdatedQuest : CJournalQuest;
		var curTrackedQuest : CJournalQuest;
		
		curUpdatedQuest = (CJournalQuest)manager.GetEntryByGuid(journalUpdates[0].journalEntry.guid);
		
		if (!curUpdatedQuest)
		{
			curUpdatedQuest = (CJournalQuest)journalUpdates[0].journalEntry;
		}
		
		curTrackedQuest = theGame.GetJournalManager().GetTrackedQuest();
		if(curUpdatedQuest && curUpdatedQuest != curTrackedQuest && journalUpdates[0].status < 2 && manager.GetEntryStatus(curUpdatedQuest) < 2)
		{
			return true;
		}
		return false;
	}

	function GetQuestStatusTitle( status : EJournalStatus, questType : eQuestType ) : string
	{
		var str : string;
		if( questType == MonsterHunt )
		{
			switch(status)
			{
				case JS_Active :
					str = "panel_journal_monstercontract_update_active";
					break;	
				case JS_Success :
					str = "panel_journal_monstercontract_update_success";
					break;
				case JS_Failed :
					str = "panel_journal_monstercontract_update_failed";
					break;		
				case JS_Inactive : 
					str = "panel_journal_monstercontract_update_new";
					break;
			}
		}
		else
		{
			switch(status)
			{
				case JS_Active :
					str = "panel_journal_quest_update_active";
					break;	
				case JS_Success :
					str = "panel_journal_quest_update_success";
					break;
				case JS_Failed :
					str = "panel_journal_quest_update_failed";
					break;		
				case JS_Inactive : 
					str = "panel_journal_quest_update_new";
					break;
			}
		}
		
		return GetLocStringByKeyExt(str);
	}	
	
	function GetPendingSize() : int
	{
		return journalUpdates.Size();
	}	

	function AddNewJournalUpdate(newJournalUpdate : SJournalUpdate):void
	{
		journalUpdates.PushBack(newJournalUpdate);
	}

	function AddQuestUpdate(journalQuest : CJournalQuest, isQuestUpdate : bool ) : void 
	{
		var newJournalUpdate : SJournalUpdate;
		var status : EJournalStatus;
		
		newJournalUpdate.journalEntry = journalQuest;
		newJournalUpdate.text = GetLocStringById( journalQuest.GetTitleStringId() );
		newJournalUpdate.isQuestUpdate = isQuestUpdate;
		newJournalUpdate.tag = 'quest';
		status = manager.GetEntryStatus(journalQuest);
		
		if( thePlayer.IsNewQuest( newJournalUpdate.journalEntry.guid ) && status == JS_Active )
		{
			newJournalUpdate.status = JS_Inactive; 
			newJournalUpdate.soundEvent = "gui_ingame_quest_active"; 
		}
		else
		{
			newJournalUpdate.status = status;
			switch( status )
			{
				case JS_Active : 
					newJournalUpdate.soundEvent = "gui_ingame_new_journal"; 
					break;		
				case JS_Success : 
					newJournalUpdate.soundEvent = "gui_ingame_quest_success"; 
					break;		
				case JS_Failed : 
					newJournalUpdate.soundEvent = "gui_ingame_quest_fail"; 
					break;
			}
		}
		newJournalUpdate.title = GetQuestStatusTitle(newJournalUpdate.status,journalQuest.GetType());
		
		if( !HasQuestPendingUpdate( journalQuest, newJournalUpdate.status ) )
		{
 			AddNewJournalUpdate(newJournalUpdate);
		}
	}
	
	function CheckSceneAndCutsceneDisplay( status : EJournalStatus, isQuestUpdate : bool ) : bool
	{
		if( theInput.GetContext() == 'Scene' && journalUpdates[0].iconPath == "" )
		{
			if( isQuestUpdate )
			{
				if( status == JS_Success || status == JS_Failed )
				{
					return true;
				}
				else
				{
					return false;
				}
			}
			else
			{
				return false;
			}
		}
		return true;
	}

	function AddCraftingSchematicUpdate( schematicName : name ) : void 
	{
		var newJournalUpdate : SJournalUpdate;	
		var m_definitionsManager	: CDefinitionsManagerAccessor;
		
		
		
			m_definitionsManager = theGame.GetDefinitionsManager();
			newJournalUpdate.text = GetLocStringByKeyExt( m_definitionsManager.GetItemLocalisationKeyName( schematicName ));
			
			newJournalUpdate.status = JS_Inactive;
			newJournalUpdate.iconPath = m_definitionsManager.GetItemIconPath( schematicName );
			newJournalUpdate.panelName = 'CraftingMenu';
			newJournalUpdate.entryTag = schematicName;
			newJournalUpdate.soundEvent = "gui_ingame_new_journal"; 
			newJournalUpdate.tag = 'crafting';
			
			newJournalUpdate.title = GetLocStringByKeyExt("panel_hud_craftingschematic_update_new_entry");
			AddNewJournalUpdate(newJournalUpdate);
		
	}		

	function AddAlchemySchematicUpdate( schematicName : name ) : void 
	{
		var newJournalUpdate : SJournalUpdate;	
		var m_definitionsManager	: CDefinitionsManagerAccessor;
		
		
		
			m_definitionsManager = theGame.GetDefinitionsManager();
			newJournalUpdate.text = GetLocStringByKeyExt( m_definitionsManager.GetItemLocalisationKeyName( schematicName ));
			
			newJournalUpdate.status = JS_Inactive;
			newJournalUpdate.iconPath = m_definitionsManager.GetItemIconPath( schematicName );
			newJournalUpdate.panelName = 'AlchemyMenu';
			newJournalUpdate.entryTag = schematicName;
			newJournalUpdate.soundEvent = "gui_ingame_new_journal"; 
			newJournalUpdate.tag = 'alchemy';
			
			newJournalUpdate.title = GetLocStringByKeyExt("panel_hud_alchemyschematic_update_new_entry");
			AddNewJournalUpdate(newJournalUpdate);
		
	}
	
	function AddQuestBookInfo( itemId : SItemUniqueId ):void
	{
		var newJournalUpdate : SJournalUpdate;
		
		if ( !thePlayer.inv.IsIdValid(itemId) )
		{
			return;
		}
		
		if (HasJournalPendingItemInfo() || m_paintingPopupData)
		{
			
		}
		else
		{
			newJournalUpdate.itemId = itemId;
			newJournalUpdate.isItemUpdate = true;
			AddNewJournalUpdate(newJournalUpdate);

			
			theGame.GetTutorialSystem().uiHandler.AddNewBooksTutorial();
		}
	}

	function AddJournalUpdate( journalEntry : CJournalBase, isDescription : bool ) : void 
	{
		var newJournalUpdate : SJournalUpdate;		
		
		if( !HasJournalPendingUpdate(journalEntry) )
		{
			newJournalUpdate.text = GetEntryText(journalEntry);
			newJournalUpdate.journalEntry = journalEntry;
			newJournalUpdate.status = JS_Active;
			newJournalUpdate.soundEvent = "gui_ingame_new_journal"; 
			
			newJournalUpdate.tag = GetEntryTag(journalEntry);
			
			newJournalUpdate.title = GetEntryTitle(journalEntry, isDescription);
			AddNewJournalUpdate(newJournalUpdate);
		}
	}
	
	function GetEntryText( journalEntry : CJournalBase ) : string
	{
		var str : string;
		var creatureEntry : CJournalCreature;
		var glossaryEntry : CJournalGlossary;
		var characterEntry : CJournalCharacter;
		
		creatureEntry = (CJournalCreature)journalEntry;
		glossaryEntry = (CJournalGlossary)journalEntry;
		characterEntry = (CJournalCharacter)journalEntry;
		
		if( creatureEntry )
		{
			str = GetLocStringById( creatureEntry.GetNameStringId() );
		}
		else if( glossaryEntry )
		{
			str = GetLocStringById( glossaryEntry.GetTitleStringId() );
		}	
		else if( characterEntry )
		{
			str = GetLocStringById( characterEntry.GetNameStringId() );
		}
		
		return str;
	}

	function GetEntryIconPath( journalEntry : CJournalBase ) : string
	{
		var str : string;
		var creatureEntry : CJournalCreature;
		var glossaryEntry : CJournalGlossary;
		var characterEntry : CJournalCharacter;
		
		creatureEntry = (CJournalCreature)journalEntry;
		glossaryEntry = (CJournalGlossary)journalEntry;
		characterEntry = (CJournalCharacter)journalEntry;
		
		if( creatureEntry )
		{
			str = "icons\hud\quest\icon_bestiary_hud.png";
		}
		else if( glossaryEntry )
		{
			str = "icons\hud\quest\icon_glossary_hud.png";
		}	
		else if( characterEntry )
		{
			str = "icons\hud\quest\icon_character_hud.png";
		}
		
		return str;
	}

	function GetEntryTag( journalEntry : CJournalBase ) : name
	{
		var creatureEntry : CJournalCreature;
		var glossaryEntry : CJournalGlossary;
		var characterEntry : CJournalCharacter;
		
		creatureEntry = (CJournalCreature)journalEntry;
		glossaryEntry = (CJournalGlossary)journalEntry;
		characterEntry = (CJournalCharacter)journalEntry;
		
		if( creatureEntry )
		{
			return 'bestiary';
		}
		else if( glossaryEntry )
		{
			return 'glossary';
		}	
		else if( characterEntry )
		{
			return 'character';
		}
		
		return '';
	}

	function GetEntryTitle( journalEntry : CJournalBase, isDescription : bool ) : string
	{
		var str : string;
		var creatureEntry : CJournalCreature;
		var glossaryEntry : CJournalGlossary;
		var characterEntry : CJournalCharacter;
		
		creatureEntry = (CJournalCreature)journalEntry;
		glossaryEntry = (CJournalGlossary)journalEntry;
		characterEntry = (CJournalCharacter)journalEntry;
		
		if( creatureEntry )
		{
			str = "panel_hud_journal_entry_bestiary";
		}
		else if( glossaryEntry )
		{
			str = "panel_hud_journal_entry_glossary";
		}	
		else if( characterEntry )
		{
			str = "panel_hud_journal_entry_character";
		}
		if( isDescription )
		{
			str += "_update";
		}
		else
		{
			str += "_new";
		}
		
		return GetLocStringByKeyExt(str);
	}

	function AddLevelUpUpdate( level : int ) : void 
	{
		var newJournalUpdate : SJournalUpdate;
		var arrInt : array<int>;
		
		newJournalUpdate.soundEvent = "gui_ingame_level_up"; 
		
		newJournalUpdate.text = GetLocStringByKeyExt("panel_character_availablepoints") + ": " + GetWitcherPlayer().levelManager.GetPointsFree(ESkillPoint);
		newJournalUpdate.status = JS_Active;
		newJournalUpdate.iconPath = "icons\skills\level_gained.png";
		
		newJournalUpdate.displayTime = 7000;
		
		arrInt.PushBack(level);			
		newJournalUpdate.title = GetLocStringByKeyExtWithParams("panel_hud_level_update_level_reached",arrInt);
		
		AddNewJournalUpdate(newJournalUpdate);
	}	

	function AddExperienceUpdate( exp : int ) : void 
	{
		var newJournalUpdate : SJournalUpdate;
		var arrInt : array<int>;
	
		if(exp <= 0)
		{
			return;
		}
		
		newJournalUpdate.soundEvent = ""; 
		arrInt.PushBack(exp);
		newJournalUpdate.text = GetLocStringByKeyExtWithParams("hud_combat_log_gained_experience", arrInt);
		newJournalUpdate.status = JS_Active + 1; 
		newJournalUpdate.iconPath = "icons\hud\quest\icon_exp.png";
		newJournalUpdate.title = GetLocStringByKey("panel_hud_item_update_recived_experience");
		newJournalUpdate.tag = 'exp';
		AddNewJournalUpdate(newJournalUpdate);
	}	

	function AddMapPinUpdate( mapPinName : name, mapPinType : name ) : void 
	{
		var newJournalUpdate : SJournalUpdate;
		newJournalUpdate.text = GetLocStringByKeyExt( StrLower("map_location_"+mapPinName) );
		newJournalUpdate.status = JS_Inactive;
		newJournalUpdate.soundEvent = "gui_ingame_new_mappin"; 
		newJournalUpdate.title = GetLocStringByKeyExt("panel_hud_map_update_new_entry");
		
		newJournalUpdate.tag = 'mappin';
		newJournalUpdate.entryTag = mapPinType; 
		AddNewJournalUpdate(newJournalUpdate);
	}

	function AddItemRecivedDuringSceneUpdate( itemName : name, optional quantity : int ) : void 
	{
		var newJournalUpdate : SJournalUpdate;
		var inv : CInventoryComponent;
		inv = GetWitcherPlayer().GetInventory();
		
		newJournalUpdate.text = GetLocStringByKeyExt( inv.GetItemLocalizedNameByName( itemName ));
		newJournalUpdate.status = JS_Inactive;
		newJournalUpdate.iconPath = inv.GetItemIconPathByName( itemName );
		
		if( itemName == 'experience' )
		{
			newJournalUpdate.title = GetLocStringByKeyExt("panel_hud_item_update_recived_experience");
		}
		else
		{
			newJournalUpdate.title = GetLocStringByKeyExt("panel_hud_item_update_recived");
			newJournalUpdate.soundEvent = "gui_ingame_new_reward_item"; 
		}
		if( quantity > 1 )
		{
			newJournalUpdate.text += " x "+quantity;
		}
		newJournalUpdate.tag = 'item';
		newJournalUpdate.entryTag = itemName;
		AddNewJournalUpdate(newJournalUpdate);
	}
	
	function HasQuestPendingUpdate( journalQuest : CJournalQuest, status : EJournalStatus ) : bool
	{
		var i : int;
		
		if( status == JS_Active )
		{
			for( i = 0; i < journalUpdates.Size(); i += 1 )
			{
				if( journalUpdates[i].status != JS_Failed && journalUpdates[i].status != JS_Success )
				{
					if( journalUpdates[i].journalEntry.guid == journalQuest.guid )
					{
						return true;
					}
				}
			}
		}
		else if( status == JS_Success )
		{
			for( i = 0; i < journalUpdates.Size(); i += 1 )
			{
				if( journalUpdates[i].status == status )
				{
					if( journalUpdates[i].journalEntry.guid == journalQuest.guid )
					{
						return true;
					}
				}
			}
		}

		return false;
	}
	
	function HasJournalPendingUpdate( journalBase : CJournalBase ) : bool
	{
		var i : int;
		
		for( i = 0; i < journalUpdates.Size(); i += 1 )
		{
			if( journalUpdates[i].journalEntry.guid == journalBase.guid )
			{
				return true;
			}
		}
		return false;
	}
	
	function HasJournalPendingItemInfo() : bool
	{
		var i : int;
		
		for( i = 0; i < journalUpdates.Size(); i += 1 )
		{
			if( journalUpdates[i].isItemUpdate )
			{
				return true;
			}
		}
		return false;
	}
	
	function ForceAddJournalUpdateInfo(locKeyText : string, locKeyTitle : string ) : void
	{
		var newJournalUpdate : SJournalUpdate;
		var status : EJournalStatus;
		
		
		
		if( locKeyText == "" || locKeyText == " ")
		{
			newJournalUpdate.text = GetTrackedQuestName();
		}
		else
		{
			newJournalUpdate.text = GetLocStringByKeyExt( locKeyText );
		}
		newJournalUpdate.status = JS_Active; 
		if( locKeyTitle == "" || locKeyTitle == " ")
		{
			newJournalUpdate.title = GetQuestStatusTitle(newJournalUpdate.status,0);
		}
		else
		{
			newJournalUpdate.title = GetLocStringByKeyExt( locKeyTitle );
		}
		AddNewJournalUpdate(newJournalUpdate);
	}
	
	function GetTrackedQuestName() : string
	{
		var trackedQuests	: CJournalQuest;
		trackedQuests = manager.GetTrackedQuest();
		return GetLocStringById(trackedQuests.GetTitleStringId());
	}
	
	event  OnRemoveUpdate()	
	{
		if( journalUpdates.Size() > 0 )
		{
			journalUpdates.Erase(0);
		}
		bWasRemoved = true;
	}
	
	event  OnShowUpdateEnd()
	{
		theInput.UnregisterListener( this, 'OnShowEntryInPanel' );
		thePlayer.UnblockAction( EIAB_OpenFastMenu, 'JournalUpdate' );
		
		if(journalUpdates.Size() > 0 && (CJournalQuest)journalUpdates[0].journalEntry )
		{
			theInput.UnregisterListener( this, 'OnTrackQuest' );
			if(journalUpdates[0].tag == 'questShown')
				journalUpdates.Erase(0);
			
		}
		
		m_bookItemId = GetInvalidUniqueId();
		
		_bDuringDisplay = false;
		LogChannel('JOURNALUPDATE',"OnShowUpdateEnd "+journalUpdates.Size());
	}
	
	event OnShowEntryInPanel( action : SInputAction )
	{
		if( IsReleased(action) && !thePlayer.IsCiri() )
		{
			LogChannel('JOURNALUPDATE',"OnShowEntryInPanel "+journalUpdates[0].journalEntry.baseName);
			OpenEntryInPanel();
		}
	}
	
	event OnTrackQuest( action : SInputAction )
	{
		var l_quest	: CJournalBase;
		var l_questStatus : EJournalStatus;
		var walkToggleAction : SInputAction;
		
		l_quest = journalUpdates[0].journalEntry;
		walkToggleAction = theInput.GetAction('WalkToggle');
		
		if ( IsReleased(action) && walkToggleAction.lastFrameValue < 0.7 && walkToggleAction.value < 0.7  && !thePlayer.IsCiri() )
		{
			if ( thePlayer.inv.IsIdValid(m_bookItemId) )
			{
				if ( !theGame.IsBlackscreen() && !theGame.IsFading() )
				{
					ShowItemInfoPopup(m_bookItemId);
					m_bookItemId = GetInvalidUniqueId();
				}
			}
			else
			if (l_quest)
			{
				l_questStatus = manager.GetEntryStatus( l_quest );
				
				if( l_questStatus == JS_Active )
				{
					manager.SetTrackedQuest( l_quest );
				}
			}
		}
	}
	
	function OpenEntryInPanel()
	{
		if( (CJournalQuest)journalUpdates[0].journalEntry )
		{
			OpenQuestPanel();
		}	
		else if( (CJournalCreature)journalUpdates[0].journalEntry )
		{
			OpenGlossaryPanel('GlossaryBestiaryMenu');
		}
		else if( (CJournalCharacter)journalUpdates[0].journalEntry )
		{
			OpenGlossaryPanel('GlossaryEncyclopediaMenu');
		}
		else if( (CJournalGlossary)journalUpdates[0].journalEntry )
		{
			OpenGlossaryPanel('GlossaryEncyclopediaMenu');
		}
		else if( journalUpdates[0].entryTag )
		{
			OpenSchematicPanel();
		}
	}
	
	function OpenGlossaryPanel( panelName : name )
	{
		var uiSavedData : SUISavedData;
		var journalEntry : CJournalBase;
		
		if( thePlayer.IsActionAllowed(EIAB_OpenGlossary) )
		{
			journalEntry = journalUpdates[0].journalEntry;
			uiSavedData = m_guiManager.GetUISavedData(panelName);
			uiSavedData.selectedTag = journalEntry.GetUniqueScriptTag();
			uiSavedData.panelName = panelName;
			m_guiManager.UpdateUISavedData( panelName , uiSavedData.openedCategories, uiSavedData.selectedTag, uiSavedData.selectedModule );
			
			uiSavedData = m_guiManager.GetUISavedData('GlossaryParent');
			uiSavedData.selectedTag = panelName;
			uiSavedData.panelName = 'GlossaryParent';
			m_guiManager.UpdateUISavedData( 'GlossaryParent' , uiSavedData.openedCategories, uiSavedData.selectedTag, uiSavedData.selectedModule );
			theGame.RequestMenuWithBackground( panelName, 'CommonMenu' );
		}	
	}	

	function OpenSchematicPanel()
	{
		var uiSavedData : SUISavedData;
		
		if( thePlayer.IsActionAllowed(EIAB_OpenGlossary) )
		{
			uiSavedData = m_guiManager.GetUISavedData(journalUpdates[0].panelName);
			uiSavedData.selectedTag = journalUpdates[0].entryTag;
			uiSavedData.panelName = journalUpdates[0].panelName;
			m_guiManager.UpdateUISavedData( journalUpdates[0].panelName , uiSavedData.openedCategories, uiSavedData.selectedTag, uiSavedData.selectedModule );
			
			uiSavedData = m_guiManager.GetUISavedData('GlossaryParent');
			uiSavedData.selectedTag = journalUpdates[0].panelName;
			uiSavedData.panelName = 'GlossaryParent';
			m_guiManager.UpdateUISavedData( 'GlossaryParent' , uiSavedData.openedCategories, uiSavedData.selectedTag, uiSavedData.selectedModule );
			theGame.RequestMenuWithBackground( journalUpdates[0].panelName, 'CommonMenu' );
		}	
	}
	
	function OpenQuestPanel()
	{
		var uiSavedData : SUISavedData;
		var questEntry : CJournalQuest;
		var panelName : name;
		
		if( thePlayer.IsActionAllowed(EIAB_OpenJournal) )
		{
			questEntry = (CJournalQuest)journalUpdates[0].journalEntry;
			
				panelName = 'JournalQuestMenu';
			
			
			uiSavedData = m_guiManager.GetUISavedData(panelName);
			uiSavedData.selectedTag = questEntry.GetUniqueScriptTag();
			uiSavedData.panelName = panelName;
			m_guiManager.UpdateUISavedData( panelName , uiSavedData.openedCategories, questEntry.GetUniqueScriptTag(), uiSavedData.selectedModule );
			
			uiSavedData = m_guiManager.GetUISavedData('JournalParent');
			uiSavedData.selectedTag = panelName;
			uiSavedData.panelName = 'JournalParent';
			m_guiManager.UpdateUISavedData( 'JournalParent' , uiSavedData.openedCategories, uiSavedData.selectedTag, uiSavedData.selectedModule );
			theGame.RequestMenuWithBackground( panelName, 'CommonMenu' );
		}		
	}
	
	protected function GatherBindersArray(out resultArray : CScriptedFlashArray, bindersList : array<SKeyBinding>, optional isContextBinding:bool)
	{
		var tempFlashObject	: CScriptedFlashObject;
		var bindingGFxData  : CScriptedFlashObject;
		var curBinding	    : SKeyBinding;
		var bindingsCount   : int;
		var i			    : int;
		
		bindingsCount = bindersList.Size();
		for( i =0; i < bindingsCount; i += 1 )
		{
			curBinding = bindersList[i];
			tempFlashObject = m_flashValueStorage.CreateTempFlashObject();
			bindingGFxData = tempFlashObject.CreateFlashObject("red.game.witcher3.data.KeyBindingData");
			bindingGFxData.SetMemberFlashString("gamepad_navEquivalent", curBinding.Gamepad_NavCode );
			bindingGFxData.SetMemberFlashInt("keyboard_keyCode", curBinding.Keyboard_KeyCode );
			bindingGFxData.SetMemberFlashString("label", GetLocStringByKeyExt(curBinding.LocalizationKey) );
			bindingGFxData.SetMemberFlashString("isContextBinding", isContextBinding);
			resultArray.PushBackFlashObject(bindingGFxData);
		}
	}
	
	protected function UpdateInputFeedback():void
	{
		var gfxDataList	: CScriptedFlashArray;
		gfxDataList = m_flashValueStorage.CreateTempFlashArray();
		GatherBindersArray(gfxDataList, m_defaultInputBindings);
		m_flashValueStorage.SetFlashArray("hud.journalupdate.buttons.setup", gfxDataList);
	}
	
	protected function AddInputBinding(label:string, padNavCode:string, optional keyboardKeyCode:int)
	{
		var bindingDef:SKeyBinding;
		bindingDef.Gamepad_NavCode = padNavCode;
		bindingDef.Keyboard_KeyCode = keyboardKeyCode;
		bindingDef.LocalizationKey = label;
		m_defaultInputBindings.PushBack(bindingDef);
	}
}