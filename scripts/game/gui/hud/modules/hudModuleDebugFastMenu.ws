/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4HudModuleDebugFastMenu extends CR4HudModuleBase 
{
	var bOpened : bool;
	var m_flashValueStorage : CScriptedFlashValueStorage;	
	default bOpened = false;

	event  OnConfigUI()
	{
		m_anchorName = "ScaleOnly";
		m_flashValueStorage = GetModuleFlashValueStorage();
		super.OnConfigUI();
        
		
		
		UpdateFastMenuEntries();
	}
	
	function UpdateFastMenuEntries()
	{
		var l_FlashArray			: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;


		l_FlashArray = m_flashValueStorage.CreateTempFlashArray();
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject(); 
		l_DataFlashObject.SetMemberFlashString(  "label", StrUpper("DEBUG OPEN MAIN MENU") );	
		l_DataFlashObject.SetMemberFlashUInt(  "menuName", NameToFlashUInt( 'MainMenu') );		
		l_FlashArray.PushBackFlashObject(l_DataFlashObject);	
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_inventory") );		
		l_DataFlashObject.SetMemberFlashUInt(  "menuName", NameToFlashUInt( 'InventoryMenu') );		
		l_FlashArray.PushBackFlashObject(l_DataFlashObject);
				
		
		
		
		
				
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_title_journal") );
		l_DataFlashObject.SetMemberFlashUInt(  "menuName", NameToFlashUInt( 'JournalQuestMenu') );				
		l_FlashArray.PushBackFlashObject(l_DataFlashObject);
				

				
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_title_alchemy") );	
		l_DataFlashObject.SetMemberFlashUInt(  "menuName", NameToFlashUInt( 'AlchemyMenu') );		
		l_FlashArray.PushBackFlashObject(l_DataFlashObject);
				
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_title_glossary") );	
		l_DataFlashObject.SetMemberFlashUInt(  "menuName", NameToFlashUInt( 'GlossaryBestiaryMenu') );		
		l_FlashArray.PushBackFlashObject(l_DataFlashObject);
				
		 l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject(); 
		l_DataFlashObject.SetMemberFlashString(  "label", StrUpper(GetLocStringByKeyExt("panel_button_common_quittomainmenu")) );	
		l_DataFlashObject.SetMemberFlashUInt(  "menuName", NameToFlashUInt( 'Quit') );		
		l_FlashArray.PushBackFlashObject(l_DataFlashObject);	
		
		if( IsDebugPagesAvailable() )            
		{
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
			l_DataFlashObject.SetMemberFlashString(  "label", "DEBUG PAGES" );	
			l_DataFlashObject.SetMemberFlashUInt(  "menuName", NameToFlashUInt( 'Debug') );
			l_FlashArray.PushBackFlashObject(l_DataFlashObject);
		}
		
		m_flashValueStorage.SetFlashArray( "hud.fastmenu.entries", l_FlashArray );
	}
	
	function IsDebugPagesAvailable() : bool
	{
		var sum : int;
		if ( FactsDoesExist("DebugPagesOff") )
		{
			sum = FactsQuerySum("DebugPagesOff");

			if ( sum >= 1 )
				return false;
			else
				return true;
		}
		
		return true;
	}
	
	event OnFastMenu( action : SInputAction )
	{
		
		
		if( action.value > 0.7f && thePlayer.IsActionAllowed( EIAB_OpenFastMenu ) )
		{
			bOpened = !bOpened;
			UpdateFastMenuEntries();
			OnShowFastMenu(bOpened);
		}
	}

	event  OnShowFastMenu( opened : bool )
	{
		LogChannel( 'DEBUGFASTMENU', "ShowFastMenu " + opened );
		if ( opened )
		{
			theGame.Pause( "FastMenu" );
			theInput.StoreContext( 'FastMenu' );			
			
		}
		else
		{
			theGame.Unpause( "FastMenu" );
			theInput.RestoreContext( 'FastMenu', false );
		}
		
		
		bOpened = opened;
	}

	event  OnItemChosen( choosenPanelId : name )
	{		
		LogChannel( 'DEBUGFASTMENU', "OnItemChosen " + choosenPanelId );
		switch(choosenPanelId)
		{
			case 'InventoryMenu':
				if(thePlayer.IsActionAllowed(EIAB_OpenInventory))
				{
					theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
				}
				break;
			case 'CharacterMenu':
				if(thePlayer.IsActionAllowed(EIAB_OpenCharacterPanel))
				{
					
					theGame.RequestMenu( 'CharacterMenu' ); 
				}
				break;
			case 'JournalQuestMenu':
				if(thePlayer.IsActionAllowed(EIAB_OpenJournal))
				{
					theGame.RequestMenuWithBackground( 'JournalQuestMenu', 'CommonMenu' ); 
				}
				break;
			case 'MapMenu': 
				if(thePlayer.IsActionAllowed(EIAB_OpenMap))
				{				
					theGame.RequestMenuWithBackground( 'MapMenu', 'CommonMenu' );
				}
				break;
 			case 'AlchemyMenu':
				if(thePlayer.IsActionAllowed(EIAB_OpenAlchemy))
				{
					theGame.RequestMenuWithBackground( 'AlchemyMenu', 'CommonMenu' );
				}
				break; 	 	
			case 'GlossaryBestiaryMenu':
				if(thePlayer.IsActionAllowed(EIAB_OpenGlossary))
				{
					theGame.RequestMenuWithBackground( 'GlossaryBestiaryMenu', 'CommonMenu' );
				}
				break; 			
			case 'MainMenu':
				theGame.SetMenuToOpen( '' );
				theGame.RequestMenu('CommonMainMenu');
				break; 		
			case 'Quit':
				theGame.RequestEndGame();
				break;
			case 'Debug':
				OpenDebugWindows();
				break;

		}
		OnShowFastMenu( false );
	}
}