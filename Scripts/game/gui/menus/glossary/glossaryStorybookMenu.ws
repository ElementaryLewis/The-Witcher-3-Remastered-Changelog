/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4GlossaryStorybookMenu extends CR4ListBaseMenu
{	
	default DATA_BINDING_NAME 		= "glossary.storybook.list";
	default DATA_BINDING_NAME_SUBLIST	= "glossary.storybook.sublist.items";
	default DATA_BINDING_NAME_DESCRIPTION	= "glossary.storybook.description";
	
	var allEntries					: array<CJournalStoryBookChapter>;
	private var guiManager 			: CR4GuiManager;
	var bMovieIsPlaying 			: bool;
	private var m_fxSetTitle		: CScriptedFlashFunction;
	private var m_fxSetText			: CScriptedFlashFunction;
	private var m_fxShowModules		: CScriptedFlashFunction;
	
	event  OnConfigUI()
	{	
		var i							: int;
		var tempEntries					: array<CJournalBase>;
		var entryTemp					: CJournalStoryBookChapter;
		var status						: EJournalStatus;
		super.OnConfigUI();
		
		guiManager = theGame.GetGuiManager();
		m_flashModule = GetMenuFlash();
		m_fxSetTitle = m_flashModule.GetMemberFlashFunction("setTitle");
		m_fxSetText = m_flashModule.GetMemberFlashFunction("setText");
		m_fxShowModules = m_flashModule.GetMemberFlashFunction("showModules");
		
		m_journalManager.GetActivatedOfType( 'CJournalStoryBookChapter', tempEntries );
		
		for( i = 0; i < tempEntries.Size(); i += 1 )
		{
			status = m_journalManager.GetEntryStatus( tempEntries[i] );
			if( status == JS_Active )
			{
				entryTemp = (CJournalStoryBookChapter)tempEntries[i];
				if( entryTemp )
				{
					allEntries.PushBack(entryTemp); 
				}
			}
		}
		
		PopulateData();
		SelectCurrentModule();
	}
	
	event  OnCloseMenu()
	{
		if( bMovieIsPlaying )
		{
			OnVideoStopped();
		}
		else
		{
			super.OnCloseMenu();
			if( m_parentMenu )
			{
				m_parentMenu.ChildRequestCloseMenu();
			}
		}
	}
	
	function UpdateImage( tag : name )
	{
	}	
		
	event OnEntryPress( tag : name )
	{
		var pageEntry : CJournalStoryBookPage;
		var descEntry : CJournalStoryBookPageDescription;
		var descEntries : array< CJournalBase >;
		var str : string;
		var menuSprite : CScriptedFlashSprite;
		var i : int;
		
		pageEntry = (CJournalStoryBookPage)m_journalManager.GetEntryByTag( tag );
		if ( pageEntry )
		{
			m_journalManager.GetActivatedChildren( pageEntry, descEntries );
		
			for ( i = descEntries.Size() - 1; i >= 0; i -= 1 )
			{
				descEntry = ( CJournalStoryBookPageDescription )descEntries[ i ];
				if ( descEntry )
				{
					str = "storybook/" + descEntry.GetVideoFilename();
					break;
				}
			}
		}
		guiManager.PlayFlashbackVideoAsync(str);
		
		menuSprite = m_parentMenu.GetMenuFlash();
		menuSprite.SetVisible(false);
		
		m_fxShowModules.InvokeSelfOneArg(FlashArgBool(false));
		
		
		

		bMovieIsPlaying = true;
	}
	
	event OnVideoStopped()
	{
		var guiManager : CR4GuiManager;
		guiManager = theGame.GetGuiManager();
		guiManager.CancelFlashbackVideo();
	}
	
		
	function ShowMenuAgain()
	{
		m_fxShowModules.InvokeSelfOneArg(FlashArgBool(true));
		
		
		
	}
		
	function SetMovieIsPlaying( value : bool )
	{
		bMovieIsPlaying = value;
	}
	
	private function PopulateData()
	{
		var l_DataFlashArray		: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		
		var i,j, length				: int;
		var l_groupEntry			: CJournalStoryBookChapter;
		var l_entry					: CJournalStoryBookPage;
		var l_tempEntries			: array<CJournalBase>;
		
		var l_Title					: string;
		var l_Tag					: name;
		var l_IconPath				: string;
		var l_GroupTitle			: string;
		var l_GroupTag				: name;
		var l_IsNew					: bool;

		l_DataFlashArray = m_flashValueStorage.CreateTempFlashArray();
		length = allEntries.Size();
		
		for( i = 0; i < length; i+= 1 )
		{	
			l_groupEntry = allEntries[i];
			
			l_GroupTitle = GetLocStringById(l_groupEntry.GetTitleStringId());
			l_GroupTag = l_groupEntry.GetUniqueScriptTag();
			l_tempEntries.Clear();
			m_journalManager.GetActivatedChildren(l_groupEntry,l_tempEntries);
			
			for( j = 0; j < l_tempEntries.Size(); j += 1 )
			{
				l_entry = (CJournalStoryBookPage)l_tempEntries[j];
				if( m_journalManager.GetEntryStatus(l_entry) < JS_Active ) 
				{	
					continue;
				}
				l_Title = GetLocStringById( l_entry.GetTitleStringId() );	
				l_IconPath = "";
				l_IsNew	= m_journalManager.IsEntryUnread( l_entry );
				l_Tag = l_entry.GetUniqueScriptTag();
				
				l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
				
				l_DataFlashObject.SetMemberFlashUInt(  "tag", NameToFlashUInt(l_Tag) );				
				l_DataFlashObject.SetMemberFlashBool( "isNew", l_IsNew );
				l_DataFlashObject.SetMemberFlashBool( "selected", (l_Tag == currentTag) );			
				l_DataFlashObject.SetMemberFlashString(  "label", l_Title );
				l_DataFlashObject.SetMemberFlashString(  "iconPath", "icons/tutorials/"+l_IconPath );
					
				l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			}
		}
		
		if( l_DataFlashArray.GetLength() > 0 )
		{
			m_flashValueStorage.SetFlashArray( DATA_BINDING_NAME, l_DataFlashArray );
			m_fxShowSecondaryModulesSFF.InvokeSelfOneArg(FlashArgBool(true));
		}
		else
		{
			m_fxShowSecondaryModulesSFF.InvokeSelfOneArg(FlashArgBool(false));
		}
	}
	
	function UpdateDescription( entryName : name )
	{	
		var l_entry : CJournalStoryBookPage;
		var l_description : CJournalStoryBookPageDescription;
		var description : string;
		var title : string;
		
		l_entry = (CJournalStoryBookPage)m_journalManager.GetEntryByTag( entryName );
		description = GetDescription( l_entry );
		title = GetLocStringById( l_entry.GetTitleStringId());	
		
		m_fxSetTitle.InvokeSelfOneArg(FlashArgString(title));
		m_fxSetText.InvokeSelfOneArg(FlashArgString(description));
	}	
	
	function GetDescription( currentStorybookPage : CJournalStoryBookPage ) : string
	{
		var i : int;
		var str : string;
		var locStrId : int;
		var description : CJournalStoryBookPageDescription;
		
		str = "";
		for( i = 0; i < currentStorybookPage.GetNumChildren(); i += 1 )
		{
			description = (CJournalStoryBookPageDescription)currentStorybookPage.GetChild(i);
			if( m_journalManager.GetEntryStatus(description) == JS_Active )
			{
				locStrId = description.GetDescriptionStringId();
				str += GetLocStringById(locStrId)+"<br>";
			}
		}
		if( str == "" || str == "<br>" )
		{
			str = GetLocStringByKeyExt("panel_journal_quest_empty_description");
		}
		
		return str;
	}

	function UpdateItems( tag : name )
	{
	}
}
