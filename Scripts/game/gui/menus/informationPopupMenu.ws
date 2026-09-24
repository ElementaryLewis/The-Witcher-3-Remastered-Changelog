/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4InformationPopupMenu extends CR4MenuBase
{	

	event  OnConfigUI() 
	{	
		super.OnConfigUI();

		SetPopupText("Default text: please check CR4InformationPopupMenu::OnConfigUI");
	}

	public function SetPopupText(value:string) : void
	{
		m_flashValueStorage.SetFlashString("popup.info.text", value);	
	}
	

	
	public function SetFirstButton(buttonIcon:string, buttonLabel:string) : void 
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;

		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();

		l_flashObject.SetMemberFlashString("icon", buttonIcon);
		l_flashArray.PushBackFlashObject(l_flashObject);

		l_flashObject.SetMemberFlashString("label", buttonLabel);
		l_flashArray.PushBackFlashObject(l_flashObject);

		m_flashValueStorage.SetFlashArray("popup.info.button1", l_flashArray);
	}
	public function SetSecondButton(buttonIcon:string, buttonLabel:string) : void
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;

		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();

		l_flashObject.SetMemberFlashString("icon", buttonIcon);
		l_flashArray.PushBackFlashObject(l_flashObject);

		l_flashObject.SetMemberFlashString("label", buttonLabel);
		l_flashArray.PushBackFlashObject(l_flashObject);

		m_flashValueStorage.SetFlashArray("popup.info.button2", l_flashArray);
	}
	

	event  OnFirstButtonPress()
	{
		CloseMenu();		
	}

	event  OnSecondButtonPress()
	{
		CloseMenu();		
	}
}

