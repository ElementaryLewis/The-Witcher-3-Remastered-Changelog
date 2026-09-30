/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3UIContext extends CObject
{
	
	protected var m_inputBindings : array<SKeyBinding>;	
	
	protected var m_contextBindings : array<SKeyBinding>;
	protected var m_managerRef    : W3ContextManager;

	
	public function HandleUserFeedback(keyName:string) {}	
	public function UpdateContext() {}
	
	public function Deactivate() 
	{
		m_inputBindings.Clear();
		m_contextBindings.Clear();
		m_managerRef.updateInputFeedback();
	}
	
	public function Init(ownerManager:W3ContextManager) 
	{
		m_managerRef = ownerManager;
	}
	
	public function GetButtonsList(out externalList : array<SKeyBinding> )
	{
		var i : int;
		for( i =0; i < m_inputBindings.Size(); i += 1 )
		{
			externalList.PushBack(m_inputBindings[i]);
		}
	}
	
	protected function AddInputBinding(label:string, padNavCode:string, optional keyboardNavCode:int, optional useInContextMenu:bool, optional IsLocalized:bool, optional IsHold:bool)
	{
		var bindingDef:SKeyBinding;
		bindingDef.Gamepad_NavCode = padNavCode;
		bindingDef.Keyboard_KeyCode = keyboardNavCode;
		bindingDef.LocalizationKey = label;
		bindingDef.IsLocalized = IsLocalized;
		bindingDef.IsHold = IsHold;
		m_inputBindings.PushBack(bindingDef);
		if (useInContextMenu)
		{
			m_contextBindings.PushBack(bindingDef);
		}
	}
	
	protected function IsPadBindingExist(padNavCode:string):bool
	{
		var i, len : int;
		
		len = m_contextBindings.Size();
		for (i = 0; i < len; i += 1)
		{
			if (m_contextBindings[i].Gamepad_NavCode == padNavCode)
			{
				return true;
			}
		}
		return false;
	}	
}



class W3ContextManager extends CObject
{
	protected var m_currentContext : W3UIContext;
	protected var m_commonMenuRef  : CR4CommonMenu;

	public function Init(targetCommonMenu : CR4CommonMenu):void
	{
		m_commonMenuRef	= targetCommonMenu;
	}
	
	public function ActivateContext(targetContext:W3UIContext):void
	{
		m_currentContext = targetContext;
		m_currentContext.Init(this);
		updateInputFeedback();
	}
	
	public function HandleUserInput(navCode:string, actionId:int):void
	{
		if (m_currentContext)
		{
			m_currentContext.HandleUserFeedback(navCode); 
		}
	}
	
	public function updateInputFeedback()
	{
		var bindingsList:array<SKeyBinding>;
		
		if (m_commonMenuRef && m_currentContext)
		{
			m_currentContext.GetButtonsList(bindingsList);
			m_commonMenuRef.UpdateContextButtons(bindingsList, true);
		}
	}
}