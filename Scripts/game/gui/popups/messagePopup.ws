/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EUserMessageAction
{
	UMA_Ok,
	UMA_Cancel,
	UMA_Abort,
	UMA_Yes,
	UMA_No
}

enum EUserMessageProgressType
{
	UMPT_None,
	UMPT_Content,
	UMPT_GraphicsRefresh
}

struct UserMessageActionData
{
	var actionId : EUserMessageAction;
	var label    : string;
}

class W3MessagePopupData extends CObject
{
	public var actionsList : array <UserMessageActionData>;
	public var titleText   : string;
	public var messageText : string;
	public var messageId   : int;
	public var autoLocalize : bool;
	public var messageType : EUserDialogButtons;
	public var priority    : int;
	public var progress	   : float;	
	public var progressType : EUserMessageProgressType;
	public var progressTag : name;
	default progress = -1;
	
	public function setActionsByType(msgType : EUserDialogButtons):void
	{
		var curUserActionData:UserMessageActionData;
		
		messageType = msgType;
		switch (messageType)
		{
			case UDB_Ok:
				curUserActionData.actionId = UMA_Ok;
				curUserActionData.label = GetLocStringByKeyExt("panel_common_ok");
				actionsList.PushBack(curUserActionData);
				break;
				
			case UDB_OkCancel:
				curUserActionData.actionId = UMA_Ok;
				curUserActionData.label = GetLocStringByKeyExt("panel_common_ok");
				actionsList.PushBack(curUserActionData);
				curUserActionData.actionId = UMA_Cancel;
				curUserActionData.label = GetLocStringByKeyExt("panel_common_cancel");
				actionsList.PushBack(curUserActionData);
				break;
				
			case UDB_YesNo:
				curUserActionData.actionId = UMA_Yes;
				curUserActionData.label = GetLocStringByKeyExt("panel_common_yes");
				actionsList.PushBack(curUserActionData);
				curUserActionData.actionId = UMA_No;
				curUserActionData.label = GetLocStringByKeyExt("panel_common_no");
				actionsList.PushBack(curUserActionData);
				break;
				
			case UDB_None:
			default:
				break;
		}
	}
}

class CR4MessagePopup extends CR4PopupBase
{
	private var m_messagesQueue		   : array<W3MessagePopupData>;
	private var m_isMessageShown	   : bool;
	
	private var m_fxHideMessage		   : CScriptedFlashFunction;
	private var m_fxPrepareMessageShow : CScriptedFlashFunction;
	private var m_fxDisplayProgressBar : CScriptedFlashFunction;	
	
	event  OnConfigUI()
	{
		var initDataObject : W3MessagePopupData;
		
		super.OnConfigUI();
		
		m_fxHideMessage = m_flashModule.GetMemberFlashFunction( "hideMessage" );
		m_fxDisplayProgressBar = m_flashModule.GetMemberFlashFunction( "showProgressBar" );
		m_fxPrepareMessageShow = m_flashModule.GetMemberFlashFunction( "prepareMessageShowing" );
		
		initDataObject = (W3MessagePopupData)GetPopupInitData();
		
		if (!initDataObject)
		{
			initDataObject = theGame.GetGuiManager().lastMessageData;
		}
		
		if (!initDataObject || (theGame.GetGuiManager().GetHideMessageRequestId() == initDataObject.messageId))
		{
			ClosePopup();
		}
		else
		{
			ShowMessage(initDataObject);
			
			theInput.StoreContext( 'EMPTY_CONTEXT' );
		}
		
		MakeModal(true);
		m_guiManager.ForceHideMouseCursor(true);
		theGame.ForceUIAnalog(true);
	}
	
	event  OnClosingPopup()
	{
		super.OnClosingPopup();
		theInput.RestoreContext( 'EMPTY_CONTEXT', true );
		theGame.ForceUIAnalog(false);
		m_guiManager.ForceHideMouseCursor(false);
	}
	
	event  OnAllMessagesShown()
	{
		ClosePopup();
	}
	
	event  OnUserAction(messageId:int, actionId : int)
	{
		theGame.GetGuiManager().UserDialogCallback(messageId, actionId);
	}
	
	protected function AddMessageToQueue(messageData : W3MessagePopupData):int
	{
		var iterator:int;
		var messageListSize:int;
		var curMessage:W3MessagePopupData;
		var targetIndex:int;
		
		targetIndex = -1;
		
		messageListSize = m_messagesQueue.Size();
		for (iterator = 0; iterator < messageListSize; iterator += 1)
		{
			curMessage = m_messagesQueue[iterator];
			if (curMessage.priority < messageData.priority)
			{
				targetIndex = iterator;
				break;
			}
		}
		
		if (targetIndex == -1 || targetIndex >= messageListSize)
		{
			targetIndex = messageListSize;
			m_messagesQueue.PushBack(messageData);
		}
		else
		{
			m_messagesQueue.Insert(targetIndex, messageData);
		}
		
		return targetIndex;
	}
	
	public function ShowMessage(messageData : W3MessagePopupData):void
	{
		var queueIndex:int;
		
		queueIndex = AddMessageToQueue(messageData);
		
		if (queueIndex == 0)
		{
			SendMessageToAS(messageData);
		}
	}
	
	public function GetCurrentMessageData():W3MessagePopupData
	{
		if (m_messagesQueue.Size() > 0)
		{
			return m_messagesQueue[0];
		}
		
		return NULL;
	}
	
	public function GetCurrentMsgId():int
	{
		if (m_messagesQueue.Size() > 0)
		{
			return m_messagesQueue[0].messageId;
		}
		
		return -1;
	}
	
	protected function SendMessageToAS(messageData : W3MessagePopupData)
	{
		var tempGfxObject : CScriptedFlashObject;
		var gfxDataObject : CScriptedFlashObject;
		var gfxActionData : CScriptedFlashObject;
		var gfxActionList : CScriptedFlashArray;
		var actionsList	  : array<UserMessageActionData>;
		var i, len		  : int;
		var msgText  	  : string;
		var currentMsgId  : int;
		
		m_fxPrepareMessageShow.InvokeSelfOneArg( FlashArgInt(messageData.messageId) );
		
		currentMsgId = messageData.messageId;
		tempGfxObject = m_flashValueStorage.CreateTempFlashObject();
		gfxDataObject = tempGfxObject.CreateFlashObject("red.game.witcher3.data.SysMessageData");
		gfxDataObject.SetMemberFlashInt ("id",  currentMsgId);
		gfxDataObject.SetMemberFlashInt ("type",  messageData.messageType);
		gfxDataObject.SetMemberFlashInt ("priority", messageData.priority );
		if (!messageData.autoLocalize)
		{
			msgText = messageData.messageText;
		}
		else
		{
			msgText = ReplaceTagsToIcons(GetLocStringByKeyExt(messageData.messageText));
		}
		
		gfxDataObject.SetMemberFlashString("messageText", msgText ); 
		
		if (messageData.titleText == "")
		{
			gfxDataObject.SetMemberFlashString("titleText", "" );
		}
		else
		{
			gfxDataObject.SetMemberFlashString("titleText", ReplaceTagsToIcons(GetLocStringByKeyExt(messageData.titleText)) );
		}
		
		DisplayProgressBar(messageData.progress, messageData.progressType);
		
		actionsList = messageData.actionsList;
		len = actionsList.Size();
		gfxActionList = m_flashValueStorage.CreateTempFlashArray();
		for (i = 0; i < len; i += 1)
		{
			gfxActionData = m_flashValueStorage.CreateTempFlashObject();
			gfxActionData.SetMemberFlashInt("id", actionsList[i].actionId );
			gfxActionData.SetMemberFlashString("label", actionsList[i].label );
			gfxActionList.PushBackFlashObject(gfxActionData);
		}
		gfxDataObject.SetMemberFlashArray("buttonList", gfxActionList);
		m_flashValueStorage.SetFlashObject("message.show", gfxDataObject);
	}
	
	public function HideMessage(messageId : int):void
	{
		ProcessAndEraseMessage( messageId );
		
		
		m_fxHideMessage.InvokeSelfOneArg( FlashArgInt(messageId) );
	}
	
	event  OnMessageHidden( messageId : int ):void
	{
		ProcessAndEraseMessage( messageId );
		
		if (m_messagesQueue.Size() > 0)
		{
			SendMessageToAS(m_messagesQueue[0]);
		}
		else
		{
			ClosePopup();
		}
	}
	
	private function ProcessAndEraseMessage( messageId : int )
	{
		var i, size : int;
		var curMessage : W3MessagePopupData;
		
		
		size = m_messagesQueue.Size();
		for ( i = 0; i < size; i += 1)
		{
			if ( m_messagesQueue[ i ].messageId == messageId )
			{
				theGame.GetGuiManager().OnMessageHiding( messageId );
				m_messagesQueue.Erase( i );
				break;
			}
		}
	}
	
	
	public function DisplayProgressBar(progressValue:float, progressType : EUserMessageProgressType):void
	{
		var refreshRate:float;
		var displayString:string;
		
		displayString = "";
		
		switch (progressType)
		{
		case UMPT_Content:
			refreshRate = 2000;
			displayString = "_SHOW_PERC_"; 
			break;
		case UMPT_GraphicsRefresh:
			refreshRate = 200;
			break;
		default:
			refreshRate = -1;
			break;
		}
		
		
		
			m_fxDisplayProgressBar.InvokeSelfThreeArgs( FlashArgNumber(progressValue), FlashArgNumber(refreshRate), FlashArgString(displayString) );
		
	}
	
	event  OnProgressUpdateRequested():void 
	{
		var progressValue : float;
		var progressValueInt : int = 0;
		var currentMessageData : W3MessagePopupData;
		
		currentMessageData = GetCurrentMessageData();
		
		if (currentMessageData)
		{
			progressValue = currentMessageData.progress;
			
			switch (currentMessageData.progressType)
			{
			case UMPT_Content:
				progressValueInt = theGame.ProgressToContentAvailable(currentMessageData.progressTag);
				progressValue = progressValueInt;
				break;
			case UMPT_GraphicsRefresh:
				progressValue = currentMessageData.progress - 2;
				currentMessageData.progress = progressValue;
				if (progressValue <= 0)
				{
					HideMessage(currentMessageData.messageId);
					return true;
				}
				break;
			}
			
			if (progressValueInt == 100 && currentMessageData.progressTag == 'RequiredForSave')
			{
				
				HideMessage(currentMessageData.messageId);
			}
			else
			{
				DisplayProgressBar(progressValue, currentMessageData.progressType);
			}
		}
	}
}