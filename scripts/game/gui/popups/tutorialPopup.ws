/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct TutorialHighlightedArea
{
	var x:float;
	var y:float;
	var width:float;
	var height:float;
}




class CR4TutorialPopup extends CR4PopupBase
{
	var m_DataObject  		  : W3TutorialPopupData;
	var timeRemains	  		  : float;
	var removeOnTimer 		  : bool;
	var enableGlossaryLink    : bool;
	var hideCounter			  : int;
	var forcedhideCounter	  : int;
	var isVisible			  : bool;
	
	var m_fxPlayFeedbackAnim    : CScriptedFlashFunction;
	var m_fxResetInput          : CScriptedFlashFunction;
	
	private var m_contextStored : bool;
	
	event  OnConfigUI()
	{
		var initData      : W3TutorialPopupData;
		var isHidden 	  : bool;
		var isForceHidden : bool;
		
		super.OnConfigUI();
		
		m_contextStored = false;
		
		m_fxResetInput = m_flashModule.GetMemberFlashFunction( "resetInput" );
		m_fxPlayFeedbackAnim = m_flashModule.GetMemberFlashFunction( "playFeedbackAnimation" );
		initData = (W3TutorialPopupData)GetPopupInitData();
		
		if (!initData || initData.closeRequested)
		{
			m_DataObject = initData;
			ClosePopup();
		}
		
		UpdateData(initData, true);
		isVisible = true;
		
		theGame.GetGuiManager().GetTutorialVisibility(isHidden, isForceHidden);
		if (isHidden)
		{
			SetInvisible(isHidden, isForceHidden);
		}
	}
	
	public function UpdateInputDevice():void
	{
		var isGamepad:bool = theInput.LastUsedGamepad();
		
		SetControllerType(isGamepad);
	}
	
	public function UpdateData(TutData : W3TutorialPopupData, optional showAnimation : bool) : void
	{
		var commonMenuRef : CR4CommonMenu;
		
		if (!TutData)
		{
			return;
		}
		
		m_DataObject = TutData;
		
		hideCounter = 0;
		forcedhideCounter = 0;
		removeOnTimer = true;
		if (m_DataObject)
		{
			timeRemains = m_DataObject.duration;
			m_DataObject.menuRef = this;
			if (m_DataObject.enableGlossoryLink)
			{
				enableGlossaryLink = CanEnableGlossaryLink();
			}
			else			
			{
				enableGlossaryLink = false;
			}
			if (enableGlossaryLink)
			{
				EnableGlossaryLink(true);
			}
			if (m_DataObject.blockInput || m_DataObject.fullscreen)
			{
				theInput.StoreContext( 'EMPTY_CONTEXT' );
				m_contextStored = true;
				
				MakeModal(true);
				m_guiManager.ForceHideMouseCursor(true);
				commonMenuRef = theGame.GetGuiManager().GetCommonMenu();
				if (commonMenuRef)
				{
					commonMenuRef.SetInputFeedbackVisibility(false);
				}
			}
			if (m_DataObject.pauseGame || m_DataObject.fullscreen)
			{
				theGame.Pause("tutorial");
			}
			CreateTutorialHint(showAnimation);
		}
	}
	
	public function SetInvisible( value : bool, forced : bool ) : void
	{
		var canBeShownInMenus:bool = m_DataObject && m_DataObject.canBeShownInMenus;
		
		if (isVisible != value)
		{
			return;
		}
		
		if ( value )
		{
			if (!canBeShownInMenus || forced)
			{
				if (m_DataObject && (m_DataObject.blockInput || m_DataObject.fullscreen))
				{
					MakeModal(false);
					theInput.RestoreContext( 'EMPTY_CONTEXT', false );
					m_contextStored = false;
				}
				if (m_DataObject && (m_DataObject.pauseGame || m_DataObject.fullscreen))
				{
					theGame.Unpause("tutorial");
				}
				
				m_flashModule.SetVisible( false );
				isVisible = false;
			}
		}
		else
		{
			if (m_DataObject && (m_DataObject.blockInput || m_DataObject.fullscreen))
			{
				MakeModal(true);
				theInput.StoreContext( 'EMPTY_CONTEXT' );
				m_contextStored = true;
			}
			if (m_DataObject && (m_DataObject.pauseGame || m_DataObject.fullscreen))
			{
				theGame.Pause("tutorial");
			}
			
			m_flashModule.SetVisible( true );
			m_fxResetInput.InvokeSelf();
			isVisible = true;
		}
	}
	
	event  OnStartHiding()
	{
		RequestUnpause();
	}
	
	event  OnHideTimer()
	{
		RequestClose();
	}
	
	event  OnGotoGlossary()
	{
		if (isVisible)
		{
			theGame.RequestMenuWithBackground( 'GlossaryTutorialsMenu', 'CommonMenu' );
			
			if ( m_DataObject.fullscreen )
			{
				ClosePopup();
			}
		}
	}
	
	event  OnCloseByUser()
	{
		if ( m_DataObject )
		{
			if ( m_DataObject.fullscreen)
			{
				return false;
			}
		}		
		RequestClose(true);
	}
	
	event  OnClosingPopup()
	{
		var scriptTag : name;
		var commonMenuRef : CR4CommonMenu;
		
		if ( m_DataObject )
		{
			if (m_DataObject.pauseGame || m_DataObject.fullscreen)
			{				
				theGame.Unpause("tutorial");
			}
			if (m_DataObject.blockInput || m_DataObject.fullscreen)
			{
				if (theInput.GetContext() == 'EMPTY_CONTEXT' && m_contextStored)
				{
					theInput.RestoreContext( 'EMPTY_CONTEXT', true );
					m_contextStored = false;
				}
				m_guiManager.ForceHideMouseCursor(false);
				MakeModal(false);
				commonMenuRef = theGame.GetGuiManager().GetCommonMenu();
				if (commonMenuRef)
				{
					commonMenuRef.SetInputFeedbackVisibility(true);
				}
			}
			scriptTag = m_DataObject.scriptTag;
			m_DataObject.CloseCallback(true, false);
			delete m_DataObject;
			theGame.GetTutorialSystem().OnTutorialHintClosed(scriptTag, true, true);
		}
		if (enableGlossaryLink)
		{
			EnableGlossaryLink(false);
		}
	}
	
	
	private function CanEnableGlossaryLink():bool
	{
		var tempEntries				: array<CJournalBase>;
		var entryTemp				: CJournalTutorialGroup;
		var status					: EJournalStatus;
		var m_journalManager		: CWitcherJournalManager;	
		var allEntries				: array<CJournalTutorialGroup>;
		var i,j, length				: int;
		var l_groupEntry			: CJournalTutorialGroup;
		var l_entry					: CJournalTutorial;
		var l_tempEntries			: array<CJournalBase>;
		
		m_journalManager = theGame.GetJournalManager();
		m_journalManager.GetActivatedOfType( 'CJournalTutorialGroup', tempEntries );
		for( i = 0; i < tempEntries.Size(); i += 1 )
		{
			entryTemp = (CJournalTutorialGroup)tempEntries[i];
			if( entryTemp )
			{
				allEntries.PushBack(entryTemp); 
			}
		}
		length = allEntries.Size();
		for( i = 0; i < length; i+= 1 )
		{	
			l_groupEntry = allEntries[i];
			l_tempEntries.Clear();
			m_journalManager.GetActivatedChildren(l_groupEntry,l_tempEntries);
			for( j = 0; j < l_tempEntries.Size(); j += 1 )
			{
				l_entry = (CJournalTutorial)l_tempEntries[j];
				if( m_journalManager.GetEntryStatus(l_entry) != JS_Inactive && m_journalManager.GetEntryStatus(l_entry) != JS_Failed )
				{
					return true;
				}
			}
		}
		return false;
	}
	
	public function ShowTutorialHint(hintData:W3TutorialPopupData):void
	{
		m_DataObject = hintData;
		CreateTutorialHint();
	}
	
	public function PlayFeedbackAnim(isCorrect:bool):void
	{
		m_fxPlayFeedbackAnim.InvokeSelfOneArg(FlashArgBool(isCorrect));
	}
	
	public function RequestUnpause()
	{
		if ( m_DataObject )
		{
			if (m_DataObject.pauseGame || m_DataObject.fullscreen)
			{
				theGame.Unpause("tutorial");
			}
			if ((m_DataObject.blockInput || m_DataObject.fullscreen))
			{
				if (theInput.GetContext() == 'EMPTY_CONTEXT' && m_contextStored)
				{
					theInput.RestoreContext( 'EMPTY_CONTEXT', true );
					m_contextStored = false;
				}
				MakeModal(false);
				m_guiManager.ForceHideMouseCursor(false);
			}
		}
	}
	
	public function RequestClose(optional byUser : bool, optional willBeCloned : bool ) : void
	{
		var scriptTag : name;
		var commonMenuRef : CR4CommonMenu;
		
		
		if ( m_DataObject )
		{
			if (m_DataObject.pauseGame || m_DataObject.fullscreen)
			{
				theGame.Unpause("tutorial");
			}
			if (m_DataObject.blockInput || m_DataObject.fullscreen )
			{
				if (theInput.GetContext() == 'EMPTY_CONTEXT' && m_contextStored)
				{
					theInput.RestoreContext( 'EMPTY_CONTEXT', true );
					m_contextStored = false;
				}
				m_guiManager.ForceHideMouseCursor(false);
				MakeModal(false);
				commonMenuRef = theGame.GetGuiManager().GetCommonMenu();
				if (commonMenuRef)
				{
					commonMenuRef.SetInputFeedbackVisibility(true);
				}
			}
			scriptTag = m_DataObject.scriptTag;
			m_DataObject.CloseCallback(false, byUser, willBeCloned);
			delete m_DataObject;
		}
		ClosePopup();
		if (scriptTag != '')
		{
			theGame.GetTutorialSystem().OnTutorialHintClosed( scriptTag, false, !willBeCloned );
		}
	}
	
	protected function EnableGlossaryLink(value:bool):void
	{
		
	}
	
	public function setArabicAligmentMode() : void
	{
		super.setArabicAligmentMode();
	}
	
	protected function CreateTutorialHint(optional showAnimation : bool):void
	{
		var GFxHintObject    : CScriptedFlashObject;
		var GFxAreaObject    : CScriptedFlashObject;
		var GFxAreaList      : CScriptedFlashArray;
		var areasList        : array<TutorialHighlightedArea>;
		var curArea			 : TutorialHighlightedArea;
		var idx, len	     : int;
		
		GFxHintObject = m_flashValueStorage.CreateTempFlashObject();
		GFxHintObject.SetMemberFlashNumber("posX", m_DataObject.posX);
		GFxHintObject.SetMemberFlashNumber("posY", m_DataObject.posY);
		GFxHintObject.SetMemberFlashNumber("duration", m_DataObject.duration);
		GFxHintObject.SetMemberFlashString("messageText", m_DataObject.messageText);
		GFxHintObject.SetMemberFlashString("messageTitle", m_DataObject.messageTitle);
		GFxHintObject.SetMemberFlashString("imagePath", m_DataObject.imagePath);
		GFxHintObject.SetMemberFlashBool("enableGlossaryLink", enableGlossaryLink);
		GFxHintObject.SetMemberFlashBool("enableAcceptButton", m_DataObject.enableAcceptButton);
		GFxHintObject.SetMemberFlashBool("autosize", m_DataObject.autosize);
		GFxHintObject.SetMemberFlashBool("fullscreen", m_DataObject.fullscreen);
		GFxHintObject.SetMemberFlashBool("showAnimation", showAnimation);
		GFxHintObject.SetMemberFlashBool("isUiTutorial", m_DataObject.canBeShownInMenus);
		
		GFxAreaList = m_flashValueStorage.CreateTempFlashArray();
		areasList = m_DataObject.GetHighlightedAreas();
		len = areasList.Size();
		if (len > 0)
		{
			for (idx = 0; idx < len; idx+=1)
			{
				curArea = areasList[idx];
				GFxAreaObject = m_flashValueStorage.CreateTempFlashObject();
				GFxAreaObject.SetMemberFlashNumber("x", curArea.x);
				GFxAreaObject.SetMemberFlashNumber("y", curArea.y);
				GFxAreaObject.SetMemberFlashNumber("width", curArea.width);
				GFxAreaObject.SetMemberFlashNumber("height", curArea.height);
				GFxAreaList.PushBackFlashObject(GFxAreaObject);
			}
			m_flashValueStorage.SetFlashArray("tutorial.area.highlight", GFxAreaList);
		}
		m_flashValueStorage.SetFlashObject("tutorial.hint.data", GFxHintObject);
	}
}




class W3TutorialPopupData extends CObject
{
	public var posX:float;
	public var posY:float;
	public var messageTitle:string;
	public var messageText:string;
	public var imagePath:string;
	public var fadeBackground:bool; 
	public var autosize:bool;
	public var enableGlossoryLink:bool;
	public var enableAcceptButton:bool;
	public var canBeShownInMenus:bool;
	
	public var blockInput:bool;
	public var pauseGame:bool;
	public var fullscreen:bool;
	
	public var duration:float;
	public var scriptTag:name;
	public var menuRef:CR4TutorialPopup;
	public var managerRef : CR4TutorialSystem;
	
	public var closeRequested:bool;
	
	private var highlightedAreas:array<TutorialHighlightedArea>;
	
	public function AddHighlightedArea(x:float, y:float, width:float, height:float):void
	{
		var newArea:TutorialHighlightedArea;
		
		newArea.x = x; 
		newArea.y = y; 
		newArea.width = width; 
		newArea.height = height; 
		
		
		highlightedAreas.PushBack(newArea);
	}
	
	public function PlayFeedbackAnim(isCorrect:bool):void
	{
		if (menuRef)
		{
			menuRef.PlayFeedbackAnim(isCorrect);
		}
	}
	
	public function GetHighlightedAreas():array<TutorialHighlightedArea>
	{
		return highlightedAreas;
	}
	
	public function CloseTutorialPopup(optional willBeCloned : bool):void
	{
		if (menuRef)
		{
			menuRef.RequestClose(, willBeCloned);
		}
		else
		{
			closeRequested = true;
			
		}
	}
	
	public function CloseCallback(optional forceClose:bool, optional closedByUser:bool, optional willBeCloned : bool)
	{
		if (managerRef)
		{
			managerRef.OnTutorialHintClosing(scriptTag, forceClose, closedByUser, willBeCloned);
		}
	}
}