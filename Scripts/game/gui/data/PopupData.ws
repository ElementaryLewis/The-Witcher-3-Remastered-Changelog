/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EQuantityTransferFunction
{
	QTF_Sell,
	QTF_Buy,
	QTF_Give,
	QTF_Take,
	QTF_Drop,
	QTF_Dismantle,
	QTF_MoveToStash
};


class W3PopupData extends CObject
{
	protected var ButtonsDef  : array <SKeyBinding>;
	protected var PopupRef 	  : CR4MenuPopup;
	public var ScreenPosX     : float;
	public var ScreenPosY     : float;
	public var BlurBackground : bool;
	public var PauseGame	  : bool;
	public var HideTutorial   : bool;
	
	public function OnUserFeedback( KeyCode:string ) : void 
	{
		
	}
	
	public function GetGFxButtons(parentFlashValueStorage : CScriptedFlashValueStorage ) : CScriptedFlashArray
	{
		var resFlashArray   : CScriptedFlashArray;
		var tempFlashObject	: CScriptedFlashObject;
		var bindingGFxData  : CScriptedFlashObject;
		var curBinding	    : SKeyBinding;
		var bindingsCount   : int;
		var i			    : int;
		
		resFlashArray = parentFlashValueStorage.CreateTempFlashArray();
		DefineDefaultButtons();
		bindingsCount = ButtonsDef.Size();
		for( i =0; i < bindingsCount; i += 1 )
		{
			curBinding = ButtonsDef[i];
			tempFlashObject = parentFlashValueStorage.CreateTempFlashObject();
			bindingGFxData = tempFlashObject.CreateFlashObject("red.game.witcher3.data.KeyBindingData");
			bindingGFxData.SetMemberFlashString("gamepad_navEquivalent", curBinding.Gamepad_NavCode );
			bindingGFxData.SetMemberFlashInt("keyboard_keyCode", curBinding.Keyboard_KeyCode );
			bindingGFxData.SetMemberFlashString("label", GetLocStringByKeyExt(curBinding.LocalizationKey) );
			resFlashArray.PushBackFlashObject(bindingGFxData);
		}
		return resFlashArray;
	}
	
	public function SetupOverlayRef(target : CR4MenuPopup) : void
	{
		PopupRef = target;
	}
	
	public function forceClose():void
	{
		
	}
	
	public function ClosePopupOverlay():void
	{
		ClosePopup();
	}
	
	public function GetGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject 
	{ 
		return NULL; 
	}
	
	protected function GetContentRef() : string 
	{
		return ""; 
	}
	
	protected function AddButtonDef(label:string, padNavCode:string, optional keyboardNavCode:int)
	{
		var bindingDef:SKeyBinding;
		
		bindingDef.Gamepad_NavCode = padNavCode;
		bindingDef.Keyboard_KeyCode = keyboardNavCode;
		bindingDef.LocalizationKey = label;
		
		ButtonsDef.PushBack(bindingDef);
	}
	
	protected function DefineDefaultButtons() : void
	{
		
	}
	
	protected function ClosePopup():void
	{
		PopupRef.RequestClose();
	}
	
	public function OnClosing():void
	{
		var tut : STutorialMessage;

		if( ( BookPopupFeedback ) this )
		{
			
			if( ShouldProcessTutorial( 'TutorialBooksOpenCommonMenu' ) )
			{
				
				tut.type = ETMT_Hint;
				tut.tutorialScriptTag = 'TutorialBooksOpenCommonMenu';
				tut.hintPositionType = ETHPT_DefaultGlobal;
				tut.hintDurationType = ETHDT_Long;
				tut.canBeShownInMenus = false;
				tut.disableHorizontalResize = true;
				tut.forceToQueueFront = true;	
				tut.markAsSeenOnShow = true;

				theGame.GetTutorialSystem().DisplayTutorial( tut );
			}		
		}
		LogChannel('UI', "W3PopupData::OnClosing");
	}
	
	public function OnShown():void
	{
		var tut : STutorialMessage;
		var highlight : STutorialHighlight;
		
		if( ( BookPopupFeedback ) this )
		{
			
			if( ShouldProcessTutorial( 'TutorialBooksReadingMultiple' ) )
			{
				
				tut.type = ETMT_Hint;
				tut.tutorialScriptTag = 'TutorialBooksReadingMultiple';
				tut.journalEntryName = 'TutorialJournalBooks';
				tut.hintPositionType = ETHPT_Custom;
				tut.hintPosX = 0.05f;
				tut.hintPosY = 0.55f;
				tut.hintDurationType = ETHDT_Input;
				tut.canBeShownInMenus = true;
				tut.enableAcceptButton = true;
				tut.disableHorizontalResize = true;
				tut.forceToQueueFront = true;	
				tut.markAsSeenOnShow = true;
				
				highlight.x = .3f;
				highlight.y = .1f;
				highlight.width = .4f;
				highlight.height = .15f;
				tut.highlightAreas.PushBack( highlight );
				
				theGame.GetTutorialSystem().DisplayTutorial( tut );
				
				
				theGame.GetTutorialSystem().uiHandler.AddNewBooksTutorial();
			}
		}
		LogChannel('UI', "W3PopupData::OnShown");
	}
}



class W3ContextMenu extends W3PopupData
{
	public var positionX:float;
	public var positionY:float;
	public var contextRef:W3UIContext;
	public var actionsList:array<SKeyBinding>;
	public var curActionNavCode:string;
	
	public  function GetGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject
	{
		var l_flashArray        : CScriptedFlashArray;
		var l_flashObject       : CScriptedFlashObject;
		var l_flashResultObject : CScriptedFlashObject;
		var bindingsCount       : int;
		var i			        : int;
		
		l_flashArray = parentFlashValueStorage.CreateTempFlashArray();
		bindingsCount = actionsList.Size();
		
		for( i =0; i < bindingsCount; i += 1 )
		{
			l_flashObject = parentFlashValueStorage.CreateTempFlashObject();
			l_flashObject.SetMemberFlashString("label", GetLocStringByKeyExt(actionsList[i].LocalizationKey));
			l_flashObject.SetMemberFlashString("NavCode", actionsList[i].Gamepad_NavCode);
			l_flashObject.SetMemberFlashInt("ActionId", i); 
			l_flashArray.PushBackFlashObject(l_flashObject);
		}
		
		l_flashResultObject = parentFlashValueStorage.CreateTempFlashObject();
		l_flashResultObject.SetMemberFlashArray("ActionsList", l_flashArray);
		l_flashResultObject.SetMemberFlashNumber("positionX", positionX);
		l_flashResultObject.SetMemberFlashNumber("positionY", positionY);
		l_flashResultObject.SetMemberFlashString("ContentRef", GetContentRef());
		return l_flashResultObject;
	}
	
	public function OnUserFeedback( KeyCode:string ) : void 
	{
		LogChannel('GFX ',"[W3ContextMenu] OnUserFeedback  " + KeyCode);
		
		if (KeyCode == "escape-gamepad_B")
		{
			ClosePopup();
		}
		else
		if (KeyCode == "enter-gamepad_A")
		{
			contextRef.HandleUserFeedback(curActionNavCode);
			ClosePopup();
		}
	}
	
	protected  function DefineDefaultButtons():void
	{
		AddButtonDef("panel_button_common_accept", "enter-gamepad_A", IK_Enter);
		AddButtonDef("panel_button_common_exit", "escape-gamepad_B", IK_Escape);
	}
	
	protected  function GetContentRef() : string
	{
		return "ContextMenuRef";
	}

}


class TextPopupData extends W3PopupData
{
	protected var m_TextContent : string;
	protected var m_TextTitle   : string;
	protected var m_ImagePath   : string;
	public var m_DisplayGreyBackground : bool;
	default m_DisplayGreyBackground = true;
	
	public function SetMessageText(value : string) : void
	{
		m_TextContent = value;
	}
	
	public function SetMessageTitle(value : string) : void
	{
		m_TextTitle = value;
	}
	
	public function SetImagePath(value : string) : void
	{
		m_ImagePath = value;
	}
	
	public  function GetGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject
	{
		var l_flashObject : CScriptedFlashObject;
		
		l_flashObject = parentFlashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("ContentRef", GetContentRef());
		l_flashObject.SetMemberFlashString("TextContent", m_TextContent);
		l_flashObject.SetMemberFlashString("TextTitle", m_TextTitle);
		l_flashObject.SetMemberFlashString("ImagePath", m_ImagePath);
		
		l_flashObject.SetMemberFlashBool("backgroundVisible", m_DisplayGreyBackground);
		return l_flashObject;
	}
	
	protected  function DefineDefaultButtons():void
	{
		AddButtonDef("panel_button_common_exit", "escape-gamepad_B", IK_Escape);
	}
	
	protected  function GetContentRef() : string
	{
		return "TextPopupRef";
	}
	
	public function  OnUserFeedback( KeyCode:string ) : void
	{
		LogChannel('GFX ',"OnUserFeedback  "+KeyCode);
		if (KeyCode == "escape-gamepad_B")
		{
			ClosePopup();
		}
	}
}


class SliderPopupData extends TextPopupData
{
	public var minValue:int;
	public var maxValue:int;
	public var currentValue:int;
	
	protected  function GetContentRef() : string 
	{
		return "QuantityPopupRef";
	}
	
	public  function GetGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject
	{
		var l_flashObject : CScriptedFlashObject;
		l_flashObject = super.GetGFxData(parentFlashValueStorage);
		l_flashObject.SetMemberFlashInt("minValue", minValue);
		l_flashObject.SetMemberFlashInt("maxValue", maxValue);
		l_flashObject.SetMemberFlashInt("currentValue", currentValue);
		return l_flashObject;
	}
}

class QuantityPopupData extends SliderPopupData
{
	public var itemId:SItemUniqueId;
	public var itemCost:float;
	public var showPrice:bool;
	public var actionType:EQuantityTransferFunction;
	public var inventoryRef:CR4InventoryMenu;
	public var blacksmithRef:CR4BlacksmithMenu;
	public var craftingRef:CR4CraftingMenu;
	
	protected function GetPopupTitle():string
	{
		var titleText:string;
		
		switch(actionType)
		{
			case QTF_Sell:
				titleText = "panel_inventory_quantity_popup_sell";
				break; 
			case QTF_Buy:
				titleText = "panel_inventory_quantity_popup_buy";
				break;
			case QTF_Give:
			case QTF_MoveToStash:
			case QTF_Take:
				titleText = "panel_inventory_quantity_popup_transfer";
				break;
			case QTF_Drop:
				titleText = "panel_inventory_quantity_popup_drop";
				break;
			case QTF_Dismantle:
				titleText = "panel_title_blacksmith_disassamble";
				break;
			default:
				titleText = "";
		}
		return titleText;
	}
	
	protected  function GetContentRef() : string 
	{
		return "QuantityPopupRef";
	}
	
	protected  function DefineDefaultButtons():void
	{
		AddButtonDef("panel_button_common_accept", "enter-gamepad_A", IK_E);
		AddButtonDef("panel_button_common_exit", "escape-gamepad_B", IK_Escape);
		AddButtonDef("panel_button_common_adjust", "gamepad_L3");
	}
	
	public  function GetGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject
	{
		var l_flashObject : CScriptedFlashObject;
		l_flashObject = super.GetGFxData(parentFlashValueStorage);
		l_flashObject.SetMemberFlashNumber("ItempPrice", itemCost);
		l_flashObject.SetMemberFlashBool("ShowPrice", showPrice);
		l_flashObject.SetMemberFlashString("TextTitle", GetLocStringByKeyExt(GetPopupTitle()));
		return l_flashObject;
	}
	
	public function  OnUserFeedback( KeyCode:string ) : void
	{
		var newItemId    : SItemUniqueId;
		var curInventory : CInventoryComponent;
		var updateInfiniteBolts : bool;
		var isItemEquipped : bool;
		
		updateInfiniteBolts = false;
	 
		if (KeyCode == "escape-gamepad_B")
		{
			if (actionType == QTF_Dismantle && blacksmithRef)
			{
				blacksmithRef.HandleActionConfirmation(false);
			}
			ClosePopup();
		}
		else
		if (KeyCode == "enter-gamepad_A" && craftingRef)
		{
			craftingRef.BuyIngredient(itemId, currentValue, false);
		}
		if (KeyCode == "enter-gamepad_A")
		{
			switch(actionType)
			{
				case QTF_MoveToStash:
				
					inventoryRef.handleMoveToStashQuantity(itemId, currentValue);
					break;
					
				case QTF_Sell:
					
					newItemId = inventoryRef.SellItem(itemId, currentValue);
					
					curInventory = inventoryRef.getShopInventory();
					
					if (curInventory && curInventory.IsIdValid(newItemId))
					{
						if (currentValue == maxValue)
						{
							inventoryRef.InventoryRemoveItem(itemId);
						}
						else
						{
							inventoryRef.InventoryUpdateItem(itemId);
						}
						inventoryRef.ShopUpdateItem(newItemId);
						inventoryRef.UpdatePlayerMoney();
						inventoryRef.UpdateMerchantData();
					}
					break;
					
				case QTF_Buy:
					
					inventoryRef.BuyItem(itemId, currentValue);
					
					inventoryRef.UpdatePlayerMoney();
					inventoryRef.UpdateMerchantData();
					
					break;
				case QTF_Give:
					
					inventoryRef.GiveItem(itemId, currentValue);
					inventoryRef.UpdateData();
					
					break;
				case QTF_Take:
					
					inventoryRef.TakeItem(itemId, currentValue);
					inventoryRef.UpdateData();
					
					break;
				case QTF_Drop:
					
					curInventory = inventoryRef.GetCurrentInventory(itemId);
					
					isItemEquipped = GetWitcherPlayer().IsItemEquipped(itemId);
					
					if (curInventory.IsItemBolt(itemId) && !curInventory.ItemHasTag(itemId, theGame.params.TAG_INFINITE_AMMO))
					{
						updateInfiniteBolts = true;
					}
					
					inventoryRef.FinalDropItem(itemId, currentValue);
					
					if (currentValue == maxValue)
					{
						if (updateInfiniteBolts)
						{
							inventoryRef.PaperdollUpdateAll();
						}
						else
						{
							inventoryRef.PaperdollRemoveItem(itemId);
						}
						inventoryRef.InventoryRemoveItem(itemId);
					}
					else
					{
						inventoryRef.InventoryUpdateItem(itemId);
					}
					
					break;
				case QTF_Dismantle:
					if (blacksmithRef)
					{
						blacksmithRef.OnDisassembleStack(itemId, (int)(itemCost) * currentValue, currentValue);
					}
					break;
				default:
					break;
			}
			
			inventoryRef.UpdateAllItemData();
			
			
			
			
			
			ClosePopup();
		}
	}
}

class W3DestroyItemConfPopup extends ConfirmationPopupData
{
	public var menuRef : CR4InventoryMenu;
	public var item : SItemUniqueId;
	public var quantity : int;
	
	protected function OnUserAccept() : void
	{
		menuRef.DropItem(item, quantity);
		ClosePopup();
	}
		
	protected function OnUserDecline() : void
	{
		ClosePopup();
	}
}



class BookPopupFeedback extends TextPopupData
{
	public var bookItemId     : SItemUniqueId;
	public var inventoryRef   : CR4InventoryMenu;
	public var singleBookMode : bool;
	public var curInventory   : CInventoryComponent;

	public  function GetGFxData( parentFlashValueStorage : CScriptedFlashValueStorage ) : CScriptedFlashObject
	{	
		var objResult     : CScriptedFlashObject;	
		var objBookInfo   : CScriptedFlashObject;
		var arrayBookList : CScriptedFlashArray;
		
		var itemList      : array< SItemUniqueId >;		
		var i, count      : int;
		var curItemId     : SItemUniqueId;
		var itemCategory  : name;		
		var isItemRecipe  : bool;
		

		objResult = super.GetGFxData( parentFlashValueStorage );
		
		if( curInventory.IsIdValid( bookItemId ) )
		{
			setItemProperty(bookItemId, objResult);
			
			objResult.SetMemberFlashString( "TextTitle", m_TextTitle );
			objResult.SetMemberFlashString( "TextContent", m_TextContent );
		}
		
		if( !singleBookMode )
		{
			arrayBookList = parentFlashValueStorage.CreateTempFlashArray();
			curInventory.GetAllItems( itemList );		
			count = itemList.Size();
			
			
			
			for( i = 0; i < count; i += 1 )
			{
				curItemId = itemList[i];
				
				if( !curInventory.IsIdValid( bookItemId ) || bookItemId != curItemId )
				{
					itemCategory = curInventory.GetItemCategory( curItemId );
					isItemRecipe = itemCategory == 'crafting_schematic' || itemCategory == 'alchemy_recipe';
					
					
					
					if( !isItemRecipe && curInventory.ItemHasTag( curItemId, 'ReadableItem' ) && !curInventory.ItemHasTag( curItemId, 'NoShow' ) && !curInventory.IsBookRead( curItemId ) )
					{
						objBookInfo = parentFlashValueStorage.CreateTempFlashObject();
						
						setItemProperty( curItemId, objBookInfo );
						objBookInfo.SetMemberFlashString( "TextTitle", GetLocStringByKeyExt( curInventory.GetItemLocalizedNameByUniqueID( curItemId ) ) );
						objBookInfo.SetMemberFlashString( "TextContent", curInventory.GetBookText( curItemId ) );
						
						arrayBookList.PushBackFlashObject( objBookInfo );
					}
				}
			}
		}
		
		objResult.SetMemberFlashArray("newBooksList", arrayBookList);
		
		return objResult;
	}
	
	private function setItemProperty(item: SItemUniqueId , out objResult: CScriptedFlashObject)
	{
		var l_questTag						: string;
		var l_isQuest	 					: bool;
		
		l_questTag = "";
		l_isQuest = false;
		
		if(curInventory.ItemHasTag(item, 'Quest'))
		{
			l_questTag = "Quest";
			l_isQuest = true;
		}
		
		if (curInventory.ItemHasTag(item, 'QuestEP1'))
		{
			l_questTag = "QuestEP1";
			l_isQuest = true;
		}
		
		if (curInventory.ItemHasTag(item, 'QuestEP2'))
		{
			l_questTag = "QuestEP2";
			l_isQuest = true;
		}
		
		objResult.SetMemberFlashString( "iconPath",  "img://" + curInventory.GetItemIconPathByUniqueID( item ) );
		objResult.SetMemberFlashUInt( "itemId", ItemToFlashUInt( item ) );
		objResult.SetMemberFlashBool( "isQuestItem", l_isQuest );
		objResult.SetMemberFlashString ( "questTag", l_questTag );		
		objResult.SetMemberFlashBool( "isNewItem", true );
	}
	
	public function UpdateAfterBookRead( bookItemId : SItemUniqueId ):void
	{
		if( inventoryRef )
		{
			inventoryRef.InventoryUpdateItem( bookItemId );
		}
	}
	
	protected function  ClosePopup():void
	{
		super.ClosePopup();
	}
	
	protected  function GetContentRef() : string 
	{
		return "BookPopupRef";
	}
}



class TutorialListData extends TextPopupData
{
	public  function GetGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject
	{
		var l_flashObject  : CScriptedFlashObject;
		var l_tutorialList : CScriptedFlashArray;
		
		l_tutorialList = parentFlashValueStorage.CreateTempFlashArray();
		l_flashObject = parentFlashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("ContentRef", GetContentRef());
		GetTutorialList(l_tutorialList, parentFlashValueStorage);
		l_flashObject.SetMemberFlashArray("tutorialList", l_tutorialList);
		return l_flashObject;
	}
	
	
	protected function GetTutorialList(out tutorialList:CScriptedFlashArray, parentFlashValueStorage : CScriptedFlashValueStorage):void
	{
		var l_DataFlashArray		: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		
		var i,j, length				: int;
		var l_groupEntry			: CJournalTutorialGroup;
		var l_entry					: CJournalTutorial;
		var l_tempEntries			: array<CJournalBase>;
		
		var l_Description			: string;
		var l_Title					: string;
		var l_Tag					: name;
		var l_IconPath				: string;
		var l_GroupTitle			: string;
		var l_IsNew					: bool;
		var l_IsUsingGamepad		: bool;
		
		var tempEntries				: array<CJournalBase>;
		var entryTemp				: CJournalTutorialGroup;
		var status					: EJournalStatus;
		var m_journalManager		: CWitcherJournalManager;	
		var allEntries				: array<CJournalTutorialGroup>;
		
		m_journalManager = theGame.GetJournalManager();
		m_journalManager.GetActivatedOfType( 'CJournalTutorialGroup', tempEntries );
		for( i = 0; i < tempEntries.Size(); i += 1 )
		{
			status = m_journalManager.GetEntryStatus( tempEntries[i] );
			entryTemp = (CJournalTutorialGroup)tempEntries[i];
			if( entryTemp )
			{
				allEntries.PushBack(entryTemp); 
			}
		}
		l_DataFlashArray = parentFlashValueStorage.CreateTempFlashArray();
		length = allEntries.Size();
		l_IsUsingGamepad = theInput.LastUsedGamepad();		
		for( i = 0; i < length; i+= 1 )
		{	
			l_groupEntry = allEntries[i];
			l_GroupTitle = GetLocStringById(l_groupEntry.GetNameStringId());
			l_tempEntries.Clear();
			m_journalManager.GetActivatedChildren(l_groupEntry,l_tempEntries);
			for( j = l_tempEntries.Size() - 1; j > -1 ; j -= 1 )
			{
				l_Tag = l_tempEntries[j].GetUniqueScriptTag();
				if( StrFindFirst( NameToString(l_Tag), "_pad") > -1 )
				{
					l_tempEntries.Erase(j);
				}
			}
			for( j = 0; j < l_tempEntries.Size(); j += 1 )
			{
				l_entry = (CJournalTutorial)l_tempEntries[j];
				if( l_IsUsingGamepad )
				{
					l_Tag = l_entry.GetUniqueScriptTag();
					l_entry = (CJournalTutorial)m_journalManager.GetEntryByString( l_Tag+"_pad");
				}
				if (!l_entry)
				{
					l_entry = (CJournalTutorial)m_journalManager.GetEntryByString( l_Tag );
				}
				if( m_journalManager.GetEntryStatus(l_entry) == JS_Inactive || m_journalManager.GetEntryStatus(l_entry) == JS_Failed ) 
				{
					continue;
				}
				l_Title = GetLocStringById( l_entry.GetNameStringId() );	
				l_IconPath = l_entry.GetImagePath();
				l_IsNew	= m_journalManager.IsEntryUnread( l_entry );
				l_Tag = l_entry.GetUniqueScriptTag();
				l_DataFlashObject = parentFlashValueStorage.CreateTempFlashObject();
				l_Description = ReplaceTagsToIcons(GetLocStringById( l_entry.GetDescriptionStringId()));	
				
				l_DataFlashObject.SetMemberFlashUInt("tag", NameToFlashUInt(l_Tag));
				l_DataFlashObject.SetMemberFlashString("description", l_Description);
				l_DataFlashObject.SetMemberFlashString("label", l_Title );
				l_DataFlashObject.SetMemberFlashString("title", l_Title );
				l_DataFlashObject.SetMemberFlashString("iconPath", "icons/tutorials/" + l_IconPath );
				tutorialList.PushBackFlashObject(l_DataFlashObject);
			}
		}
	}
	
	public function  OnUserFeedback( KeyCode:string ) : void
	{
		if (KeyCode == "start" || KeyCode == "escape-gamepad_B")
		{
			ClosePopup();
		}
	}
	
	protected  function DefineDefaultButtons():void
	{
		AddButtonDef("panel_button_common_exit", "start", IK_Escape);
		AddButtonDef("panel_button_common_change_selection", "gamepad_L3");
	}
	
	protected  function GetContentRef() : string 
	{
		return "TutorialsListRef";
	}
}



class TutorialBlockerData extends TextPopupData
{
	public var m_title       : string;
	public var m_description : string;
	public var m_imagepath	 : string;
	
	public var scriptTag:name;
	public var managerRef : CR4TutorialSystem;
	
	public  function GetGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject
	{
		var l_flashObject : CScriptedFlashObject;
		l_flashObject = parentFlashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("ContentRef", GetContentRef());
		l_flashObject.SetMemberFlashString("title", m_title);
		l_flashObject.SetMemberFlashString("description", m_description);
		l_flashObject.SetMemberFlashString("imagePath", m_imagepath);
		return l_flashObject;
	}
	
	public function  OnUserFeedback( KeyCode:string ) : void
	{
		if (KeyCode == "enter-gamepad_A")
		{
			ClosePopup();
		}
	}
	
	public  function forceClose():void
	{
		if (managerRef)
		{
			managerRef.HandleTutorialMessageHidden(scriptTag, true);
		}
	}
	
	protected  function ClosePopup() : void
	{
		if (managerRef)
		{
			managerRef.HandleTutorialMessageHidden(scriptTag, false);
		}
		PopupRef.RequestClose();
	}
	
	protected  function DefineDefaultButtons():void
	{
		AddButtonDef("panel_button_common_accept", "enter-gamepad_A", IK_Enter);
	}
	
	protected  function GetContentRef() : string 
	{
		return "TutorialBlockerRef";
	}
}


class ConfirmationPopupData extends TextPopupData
{
	protected  function DefineDefaultButtons():void
	{
		AddButtonDef(GetAcceptText(), "enter-gamepad_A", IK_E);
		AddButtonDef(GetDeclineText(), "escape-gamepad_B", IK_Escape);
	}
	
	protected  function GetContentRef() : string 
	{
		return "ConfirmationPopupRef";
	}
	
	public function  OnUserFeedback( KeyCode:string ) : void
	{
		LogChannel('GFX ',"OnUserFeedback  "+KeyCode);
		if (KeyCode == "enter-gamepad_A") 
		{								  
			OnUserAccept();				  
			ClosePopup();
		}
		else if (KeyCode == "escape-gamepad_B") 
		{
			OnUserDecline();
			ClosePopup();
		}
	}
	
	protected function OnUserAccept() : void
	{
		
	}
	
	protected function OnUserDecline() : void
	{
		
	}
	
	protected function GetAcceptText() : string
	{
		return "panel_button_common_accept";
	}
	
	protected function GetDeclineText() : string
	{
		return "panel_button_common_exit";
	}
}



class ItemInfoPopupData extends TextPopupData
{
	public var invRef  		: CInventoryComponent;
	public var itemId  		: SItemUniqueId;	
	public var inventoryRef : CR4InventoryMenu;
	
	
	protected var invComponent : CInventoryComponent;

	public  function GetGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject
	{
		var flashDataObject  : CScriptedFlashObject;
		var tooltipComponent : W3TooltipComponent;
		
		invComponent= thePlayer.GetInventory();
		tooltipComponent = new W3TooltipComponent in this;
		tooltipComponent.initialize(invComponent, parentFlashValueStorage);
		tooltipComponent.setCurrentInventory(invRef);
		
		flashDataObject = tooltipComponent.GetExItemData(itemId);
		flashDataObject.SetMemberFlashString("ContentRef", GetContentRef());
		
		return flashDataObject;
	}
	
	public function  SetupOverlayRef(target : CR4MenuPopup) : void
	{
		var defMgr 		  : CDefinitionsManagerAccessor;
		var templateName  : string;
		var itemCategory  : name;
		
		super.SetupOverlayRef(target);
		defMgr = theGame.GetDefinitionsManager();
		templateName = defMgr.GetItemEquipTemplate(invRef.GetItemName(itemId));
		itemCategory = invRef.GetItemCategory(itemId);
		
		
		
		
		
	}
	
	protected function  ClosePopup():void
	{
		inventoryRef.OnItemPopupClosed();
		PopupRef.RequestClose();
	}
	
	public function  OnUserFeedback( KeyCode:string ) : void
	{
		if (KeyCode == "escape-gamepad_B")
		{
			ClosePopup();
		}
	}
	
	protected  function DefineDefaultButtons():void
	{
		AddButtonDef("panel_button_common_exit", "escape-gamepad_B", IK_Escape);
		
	}
	
	protected  function GetContentRef() : string 
	{
		return "ItemInfoPopupRef";
	}
}

class W3PortalConfirmationPopupData extends ConfirmationPopupData 
{
	protected function OnUserAccept() : void
	{
		theGame.GetGuiManager().SetUsePortal(true,true);
	}
	
	protected function OnUserDecline() : void
	{
		theGame.GetGuiManager().SetUsePortal(false,true);
	}
	
	protected function GetAcceptText() : string
	{
		return "panel_button_common_accept";
	}
	
	protected function GetDeclineText() : string
	{
		return "panel_button_common_exit";
	}
}

class PaintingPopup extends TextPopupData
{	
	protected  function GetContentRef() : string 
	{
		return "PaintingPopupRef";
	}
}

