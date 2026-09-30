/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4GlossaryTutorialsMenu extends CR4ListBaseMenu
{	
	default DATA_BINDING_NAME 		= "glossary.tutorials.list";
	default DATA_BINDING_NAME_SUBLIST	= "glossary.tutorials.sublist.items";
	default DATA_BINDING_NAME_DESCRIPTION	= "glossary.tutorials.description";
	
	var allEntries						: array<CJournalTutorialGroup>;
	
	private var m_fxSetTitle			: CScriptedFlashFunction;
	private var m_fxSetText				: CScriptedFlashFunction;
	private var m_fxSetImage			: CScriptedFlashFunction;
	
	private var resetSelection : bool;
	
	event  OnConfigUI()
	{	
		var i							: int;
		var tempEntries					: array<CJournalBase>;
		var entryTemp					: CJournalTutorialGroup;
		var status						: EJournalStatus;
		super.OnConfigUI();
		
		m_initialSelectionsToIgnore = 2;
		
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
		
		m_fxSetTitle = m_flashModule.GetMemberFlashFunction("setTitle");
		m_fxSetText = m_flashModule.GetMemberFlashFunction("setText");
		m_fxSetImage = m_flashModule.GetMemberFlashFunction("setImage");
		
		PopulateData();
		SelectCurrentModule();
	}
	
	event  OnUpdateTutorials():void
	{
		resetSelection = true;
		PopulateData();
		OnEntrySelected(currentTag);
		resetSelection = false;
	}
	
	function UpdateImage( tag : name )
	{
		var l_entry : CJournalTutorial;
		var str : string;
		l_entry = (CJournalTutorial)m_journalManager.GetEntryByTag( tag );
		str = l_entry.GetImagePath();
		if( str == "" )
		{
			m_fxSetImage.InvokeSelfOneArg(FlashArgString("empty_texture.PNG"));
		}
		else
		{
			m_fxSetImage.InvokeSelfOneArg(FlashArgString(str));
		}
	}
	
	private function PopulateData()
	{
		var l_DataFlashArray		: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		
		var i,j, length				: int;
		var l_groupEntry			: CJournalTutorialGroup;
		var l_entry					: CJournalTutorial;
		var l_entryPad				: CJournalTutorial;
		var l_tempEntries			: array<CJournalBase>;
		
		var l_Title					: string;
		var l_Tag					: name;
		var l_IconPath				: string;
		var l_GroupTitle			: string;
		var l_GroupTag				: name;
		var l_IsNew					: bool;
		var l_IsUsingGamepad		: bool;

		l_DataFlashArray = m_flashValueStorage.CreateTempFlashArray();
		length = allEntries.Size();

		l_IsUsingGamepad = theInput.LastUsedGamepad();
		
		for( i = 0; i < length; i+= 1 )
		{	
			l_groupEntry = allEntries[i];
			
			l_GroupTitle = GetLocStringById(l_groupEntry.GetNameStringId());
			l_GroupTag = l_groupEntry.GetUniqueScriptTag();
			if ( l_GroupTitle == "" )
			{
				l_GroupTitle = "biuzm";
			}
			
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
					l_entryPad = (CJournalTutorial)m_journalManager.GetEntryByString( l_Tag+"_pad");
					if( l_entryPad )
					{
						l_entry = l_entryPad;
					}
				}
				
				if( m_journalManager.GetEntryStatus(l_entry) == JS_Inactive || m_journalManager.GetEntryStatus(l_entry) == JS_Failed ) 
				{	
					continue;
				}
				
				if (l_entry.GetDLCLock() != '')
				{
					if (!theGame.GetDLCManager().IsDLCEnabled(l_entry.GetDLCLock()))
					{
						continue;
					}
				}
				
				l_Title = GetLocStringById( l_entry.GetNameStringId() );	
				l_IconPath = l_entry.GetImagePath();
				l_IsNew	= m_journalManager.IsEntryUnread( l_entry );
				l_Tag = l_entry.GetUniqueScriptTag();
				
				l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
				
				l_DataFlashObject.SetMemberFlashUInt(  "tag", NameToFlashUInt(l_Tag) );
				l_DataFlashObject.SetMemberFlashString(  "dropDownLabel", l_GroupTitle );
				l_DataFlashObject.SetMemberFlashUInt(  "dropDownTag",  NameToFlashUInt(l_GroupTag) );
				l_DataFlashObject.SetMemberFlashBool(  "dropDownOpened", IsCategoryOpened( l_GroupTag ) );
				l_DataFlashObject.SetMemberFlashString(  "dropDownIcon", "icons/monsters/ICO_MonsterDefault.png" );
				
				l_DataFlashObject.SetMemberFlashBool( "isNew", l_IsNew );
				if (resetSelection)
				{					
					l_DataFlashObject.SetMemberFlashBool( "selected", false );
				}
				else
				{
					l_DataFlashObject.SetMemberFlashBool( "selected", (l_Tag == currentTag) );
				}
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
		var l_entry : CJournalTutorial;
		var description : string;
		var title : string;
		
		
		l_entry = (CJournalTutorial)m_journalManager.GetEntryByTag( entryName );
		description = ReplaceTagsToIcons(GetLocStringById( l_entry.GetDescriptionStringId()));	
		title = GetLocStringById( l_entry.GetNameStringId());	
		
		m_fxSetTitle.InvokeSelfOneArg(FlashArgString(title));
		m_fxSetText.InvokeSelfOneArg(FlashArgString(description));
	}	

	function UpdateItems( tag : name )
	{
	}
	
	function PlayOpenSoundEvent()
	{
		
		
	}
}
