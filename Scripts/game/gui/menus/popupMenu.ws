/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4MenuPopup extends CR4OverlayMenu
{
	var m_DataObject : W3PopupData;
	
	private var m_initialized		: bool;
	private var m_HideTutorial 		: bool;
	private var m_fxSetBarValueSFF	: CScriptedFlashFunction;

	event  OnConfigUI()
	{
		m_initialized = false;
		
		MakeModal(true);
		m_flashModule = GetMenuFlash();
		m_flashValueStorage = GetMenuFlashValueStorage();
		m_forceHideTutorial = false;
		m_hideTutorial = true;
		
		super.OnConfigUI();
		
		m_fxSetBarValueSFF = m_flashModule.GetMemberFlashFunction( "setBarValue" );
		m_DataObject = (W3PopupData)GetMenuInitData();
		
		if (!m_DataObject)
		{
			CloseMenu();
		}
		else
		{
			m_DataObject.OnShown();
			m_DataObject.SetupOverlayRef(this);
			m_BlurBackground = m_DataObject.BlurBackground;
			m_PauseGame = m_DataObject.PauseGame;		
			m_HideTutorial = m_DataObject.HideTutorial;
			CreatePopupInstance(m_DataObject);
		}
		
		if (m_BlurBackground)
		{
			BlurBackground(this, true);
		}
		if (m_PauseGame)
		{
			theGame.Pause( "Popup" );
		}
		if (m_HideTutorial)
		{
			theGame.GetGuiManager().HideTutorial( true, true );
		}
		
		theInput.StoreContext( 'EMPTY_CONTEXT' );
		
		theGame.GetGuiManager().RequestMouseCursor(true);
		theGame.ForceUIAnalog(true);
		
		m_initialized = true;
	}
	
	
	function  SetButtons(){}
	
	event  OnSetQuantity(QuantityValue : int) 
	{
		var quantityData : SliderPopupData;
		
		quantityData = (SliderPopupData) m_DataObject;
		if (quantityData)
		{
			if( QuantityValue > quantityData.currentValue )
				theSound.SoundEvent("gui_global_slider_up");
			else if( QuantityValue < quantityData.currentValue )
				theSound.SoundEvent("gui_global_slider_down");
			else
				theSound.SoundEvent("gui_global_slider_none");

			quantityData.currentValue = QuantityValue;
		}
	}

	event  OnContextActionChange(navCode:string, autoExec:bool)
	{
		var contextMenuData : W3ContextMenu;
		
		contextMenuData = (W3ContextMenu) m_DataObject;
		if (contextMenuData)
		{
			contextMenuData.curActionNavCode = navCode;
			if (autoExec)
			{
				contextMenuData.OnUserFeedback("enter-gamepad_A"); 
			}
		}
	}
	
	event  OnInputHandled(NavCode:string, KeyCode:int, ActionId:int)
	{
		m_DataObject.OnUserFeedback(NavCode);
	}
	
	event  OnBookRead( bookItemId : SItemUniqueId )
	{
		var popupData : BookPopupFeedback;
		var uiData    : SInventoryItemUIData;
		
		thePlayer.inv.ReadBook( bookItemId );
		
		if (thePlayer.inv.IsIdValid( bookItemId ) && !thePlayer.inv.ItemHasTag( bookItemId, 'Quest' ) )
		{
			
			uiData = thePlayer.inv.GetInventoryItemUIData( bookItemId );
			uiData.isNew = false;
			thePlayer.inv.SetInventoryItemUIData( bookItemId, uiData );
			
			popupData = (BookPopupFeedback)GetMenuInitData();
			
			if( popupData )
			{
				popupData.UpdateAfterBookRead( bookItemId );
			}
		}
	}
	
	event  OnClosingMenu()
	{
		var commonMenuRef : CR4CommonMenu;
		commonMenuRef = theGame.GetGuiManager().GetCommonMenu();
		
		if (m_DataObject)
		{
			m_DataObject.OnClosing();
		}
		
		if (commonMenuRef)
		{
			commonMenuRef.UpdateInputFeedback();			
		}		
		
		if (m_initialized)
		{
			if (m_HideTutorial)
			{
				theGame.GetGuiManager().HideTutorial( false, true );
			}
			if (m_PauseGame)
			{
				theGame.Unpause( "Popup" );
			}
			theInput.RestoreContext( 'EMPTY_CONTEXT', false );
			theGame.GetGuiManager().RequestMouseCursor(false);
			theGame.ForceUIAnalog(false);
		}
		
		super.OnClosingMenu();
	}
	
	public function RequestClose():void
	{
		if ( m_DataObject )
		{
			m_DataObject.OnClosing();
			delete m_DataObject;
		}
		super.RequestClose();
	}
	
	protected function CreatePopupInstance(PopupDataObject : W3PopupData) : void
	{
		var GFxDataObject  : CScriptedFlashObject;
		var GFxButtonsListData : CScriptedFlashArray;
		
		m_DataObject = PopupDataObject;
		GFxDataObject = m_DataObject.GetGFxData(m_flashValueStorage);
		GFxButtonsListData = m_DataObject.GetGFxButtons(m_flashValueStorage);
		GFxDataObject.SetMemberFlashArray("ButtonsList", GFxButtonsListData);
		GFxDataObject.SetMemberFlashNumber("ScreenPosX", m_DataObject.ScreenPosX);
		GFxDataObject.SetMemberFlashNumber("ScreenPosY", m_DataObject.ScreenPosY);
		
		m_flashValueStorage.SetFlashObject("popup.data", GFxDataObject);
	}

	public function UpdatePopupInstance(PopupDataObject : W3PopupData ) : void
	{
		CreatePopupInstance( PopupDataObject );
	}
	
	protected function BlurBackground(firstLayer : CR4MenuBase, value : bool) : void
	{
		if (firstLayer.m_parentMenu)
		{
			BlurBackground(firstLayer.m_parentMenu, value);
			firstLayer.m_parentMenu.BlurLayer(value);
		}
	}	
	
	public function SetBarValue( value : float ) : void
	{
		m_fxSetBarValueSFF.InvokeSelfOneArg(FlashArgNumber(value));
	}
	
	
	
	
	private var rttItemLoaded : bool;
	private var itemRotation  : EulerAngles;
	private var itemPosition  : Vector;
	private var itemScale	  : Vector;
	private var itemCat 	  : name;
	
	public function ShowItemRTT(templateName:string, itemCategory:name):void
	{
		rttItemLoaded = false;
		itemCat = itemCategory;
		ShowRenderToTexture(templateName);
	}
	
	public function HideItemRTT():void
	{
		m_flashValueStorage.SetFlashBool( "render.to.texture.texture.visible", false);
	}
	
	protected  function UpdateSceneEntityFromCreatureDataComponent( entity : CEntity )
	{
		super.UpdateSceneEntityFromCreatureDataComponent(entity);
		
		UpdateItemScale();
		m_flashValueStorage.SetFlashBool( "render.to.texture.texture.visible", true);
		m_flashValueStorage.SetFlashBool( "render.to.texture.loading", false );
		
		rttItemLoaded = true;
	}
	
	private function UpdateItemScale()
	{
		var guiSceneController : CR4GuiSceneController;
		var itemScaleKoeff : float;
		
		itemScaleKoeff = 2;
		itemPosition.X = 0;
		itemPosition.Y = 0;
		itemPosition.Z = 0;
		switch (itemCat)
		{
			case 'bolt':
			case 'secondary':
			case 'steelsword':
				itemScaleKoeff = 2;
				break;	
			case 'silversword':
				break;
			case 'crossbow':
				itemScaleKoeff = 3;
				break;
			case 'armor':
				itemScaleKoeff = 1.3;
				break;
			case 'pants':
				itemScaleKoeff = 2;
				break;
			case 'gloves':
				itemScaleKoeff = 1.3;
				break;
			case 'boots':
				itemScaleKoeff = 3;
				break;
				return;
				break;
			default:
				break;
		}
		itemScale.X = itemScaleKoeff;
		itemScale.Y = itemScaleKoeff;
		itemScale.Z = itemScaleKoeff;
		
		guiSceneController.SetEntityTransform(itemPosition, itemRotation, itemScale);
	}
	
	event  OnGuiSceneEntitySpawned(entity : CEntity)
	{		
		UpdateItemScale();
		UpdateSceneEntityFromCreatureDataComponent( entity );
		Event_OnGuiSceneEntitySpawned();
	}
	
	event  OnRotateItemRight()
	{
		RotateItem(-10);
	}
	
	event  OnRotateItemLeft()
	{
		RotateItem(10);
	}
	
	private function RotateItem(delta : float):void
	{
		var guiSceneController : CR4GuiSceneController;
		if (rttItemLoaded)
		{
			guiSceneController = theGame.GetGuiManager().GetSceneController();
			if ( guiSceneController )
			{
				itemRotation.Yaw += delta;
				guiSceneController.SetEntityTransform(itemPosition, itemRotation, itemScale);
			}
		}
	}
}