/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4GlossaryPlacesMenu extends CR4ListBaseMenu
{	
	default DATA_BINDING_NAME 		= "glossary.places.list";
	default DATA_BINDING_NAME_SUBLIST	= "glossary.places.sublist.items";
	default DATA_BINDING_NAME_DESCRIPTION	= "glossary.places.description";
	
	var allEntries						: array<CJournalPlaceGroup>;
	
	event  OnConfigUI()
	{	
		var i							: int;
		var tempEntries					: array<CJournalBase>;
		var entryTemp					: CJournalPlaceGroup;
		var status						: EJournalStatus;
		super.OnConfigUI();
		
		m_journalManager.GetActivatedOfType( 'CJournalPlaceGroup', tempEntries );
		
		for( i = 0; i < tempEntries.Size(); i += 1 )
		{
			status = m_journalManager.GetEntryStatus( tempEntries[i] );
			if( status == JS_Active )
			{
				entryTemp = (CJournalPlaceGroup)tempEntries[i];
				if( entryTemp )
				{
					allEntries.PushBack(entryTemp); 
				}
			}
		}

		PopulateData();
		SelectCurrentModule();
	}
	
	function UpdateImage( tag : name )
	{
		var l_entry : CJournalPlace;
		var str : string;
		
		l_entry = (CJournalPlace)m_journalManager.GetEntryByTag( tag );
		str = l_entry.GetImage();
		if( str == "" )
		{
			m_flashValueStorage.SetFlashString("glossary.places.sublist.image","empty_texture.PNG");
		}
		else
		{
			m_flashValueStorage.SetFlashString("glossary.places.sublist.image",str);
		}
	}

	private function PopulateData()
	{
		var l_DataFlashArray		: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		
		var i, j, length			: int;
		var l_groupEntry			: CJournalPlaceGroup;
		var l_entry					: CJournalPlace;
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
			l_tempEntries.Clear();
			
			l_GroupTitle = GetLocStringById(l_groupEntry.GetNameStringId());
			l_GroupTag = l_groupEntry.GetUniqueScriptTag();
			m_journalManager.GetActivatedChildren(l_groupEntry,l_tempEntries);
			
			for( j = 0; j < l_tempEntries.Size(); j += 1 )
			{
				l_entry = (CJournalPlace)l_tempEntries[j];
				if( m_journalManager.GetEntryStatus(l_entry) < JS_Active ) 
				{	
					continue;
				}
				l_Title = GetLocStringById( l_entry.GetNameStringId() );	
				
				l_IconPath = l_entry.GetImage();
				l_IsNew	= m_journalManager.IsEntryUnread( l_entry );
				l_Tag = l_entry.GetUniqueScriptTag();
				
				l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
				
				l_DataFlashObject.SetMemberFlashUInt(  "tag", NameToFlashUInt(l_Tag) );
				l_DataFlashObject.SetMemberFlashString(  "dropDownLabel", l_GroupTitle );
				l_DataFlashObject.SetMemberFlashUInt(  "dropDownTag",  NameToFlashUInt(l_GroupTag) );
				l_DataFlashObject.SetMemberFlashBool(  "dropDownOpened", IsCategoryOpened( l_GroupTag ) );
				l_DataFlashObject.SetMemberFlashString(  "dropDownIcon", l_groupEntry.GetImage() );
				
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

	function GetDescription( currentEntry : CJournalPlace ) : string
	{
		var i : int;
		var str : string;
		var locStrId : int;
		var description : CJournalPlaceDescription;
		
		str = "";
		for( i = 0; i < currentEntry.GetNumChildren(); i += 1 )
		{
			description = (CJournalPlaceDescription)(currentEntry.GetChild(i));
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
	
	function UpdateDescription( entryName : name )
	{
		var l_entry : CJournalPlace;
		var description : string;
		var title : string;
		
		
		l_entry = (CJournalPlace)m_journalManager.GetEntryByTag( entryName );
		description = GetDescription( l_entry );
		title = GetLocStringById( l_entry.GetNameStringId());	
		
		m_flashValueStorage.SetFlashString(DATA_BINDING_NAME_DESCRIPTION+".title",title);
		m_flashValueStorage.SetFlashString(DATA_BINDING_NAME_DESCRIPTION+".text",description);	
	}	

	function UpdateItems( tag : name )
	{
	}
}
