/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4GlossaryCharacterMenu extends CR4ListBaseMenu
{	
	default DATA_BINDING_NAME 		= "glossary.characters.list";
	default DATA_BINDING_NAME_SUBLIST	= "glossary.characters.sublist.items";
	default DATA_BINDING_NAME_DESCRIPTION	= "glossary.characters.description";
	
	var allCharacters					: array<CJournalCharacter>;
	
	event  OnConfigUI()
	{	
		var i							: int;
		var tempCharacters				: array<CJournalBase>;
		var characterTemp				: CJournalCharacter;
		var status						: EJournalStatus;
		super.OnConfigUI();
		
		m_journalManager.GetActivatedOfType( 'CJournalCharacter', tempCharacters );
		
		for( i = 0; i < tempCharacters.Size(); i += 1 )
		{
			status = m_journalManager.GetEntryStatus( tempCharacters[i] );
			if( status == JS_Active )
			{
				characterTemp = (CJournalCharacter)tempCharacters[i];
				if( characterTemp )
				{
					allCharacters.PushBack(characterTemp); 
				}
			}
		}
		PopulateData();
		SelectCurrentModule();
	}
	
	function UpdateImage( tag : name )
	{
		var l_character : CJournalCharacter;
		var str : string;
		
		l_character = (CJournalCharacter)m_journalManager.GetEntryByTag( tag );
		str = thePlayer.ProcessGlossaryImageOverride( l_character.GetImagePath(), tag );
		if( str == "" )
		{
			m_flashValueStorage.SetFlashString("glossary.characters.sublist.image","empty_texture.PNG");
		}
		else
		{
			m_flashValueStorage.SetFlashString("glossary.characters.sublist.image",str);
		}
	}

	private function PopulateData()
	{
		var l_DataFlashArray		: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		
		var i, length				: int;
		var l_character				: CJournalCharacter;
		
		var l_Title					: string;
		var l_Tag					: name;
		var l_IconPath				: string;
		var l_GroupTag				: name;
		var l_IsNew					: bool;
		
		l_DataFlashArray = m_flashValueStorage.CreateTempFlashArray();
		length = allCharacters.Size();
		
		for( i = 0; i < length; i+= 1 )
		{	
			l_character = allCharacters[i];
			l_GroupTag = GetCharacterImportanceLocKey(l_character);
			
			l_Tag = l_character.GetUniqueScriptTag();
			l_Title = GetLocStringById( l_character.GetNameStringId() );	
			l_IconPath = thePlayer.ProcessGlossaryImageOverride( l_character.GetImagePath(), l_Tag );
			l_IsNew	= m_journalManager.IsEntryUnread( l_character );

			
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
			
			l_DataFlashObject.SetMemberFlashUInt(  "tag", NameToFlashUInt(l_Tag) );
			l_DataFlashObject.SetMemberFlashString(  "dropDownLabel", GetLocStringByKeyExt(l_GroupTag) );
			l_DataFlashObject.SetMemberFlashUInt(  "dropDownTag",  NameToFlashUInt(l_GroupTag) );
			l_DataFlashObject.SetMemberFlashBool(  "dropDownOpened", IsCategoryOpened( l_GroupTag ) );
			l_DataFlashObject.SetMemberFlashString(  "dropDownIcon", "icons/monsters/ICO_MonsterDefault.png" );
			
			l_DataFlashObject.SetMemberFlashBool( "isNew", l_IsNew );
			l_DataFlashObject.SetMemberFlashBool( "selected", (currentTag == l_Tag) );			
			l_DataFlashObject.SetMemberFlashString(  "label", l_Title );
			l_DataFlashObject.SetMemberFlashString(  "iconPath", "icons/characters/"+l_IconPath );
			
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
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

	function GetDescription( currentCharacter : CJournalCharacter ) : string 
	{
		var i : int;
		var str : string;
		var locStrId : int;
		
		var description : CJournalCharacterDescription;
		
		str = "";
		for( i = 0; i < currentCharacter.GetNumChildren(); i += 1 )
		{
			description = (CJournalCharacterDescription)(currentCharacter.GetChild(i));
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
		var l_character : CJournalCharacter;
		var description : string;
		var title : string;
		
		
		l_character = (CJournalCharacter)m_journalManager.GetEntryByTag( entryName );
		description = GetDescription( l_character );
		title = GetLocStringById( l_character.GetNameStringId());	
		
		m_flashValueStorage.SetFlashString(DATA_BINDING_NAME_DESCRIPTION+".title",title);
		m_flashValueStorage.SetFlashString(DATA_BINDING_NAME_DESCRIPTION+".text",description);	
	}	

	function UpdateItems( tag : name )
	{
	}
	
	function PlayOpenSoundEvent()
	{
		
		
	}
	
	function GetCharacterImportanceLocKey( character : CJournalCharacter ) : name
	{
		var importance : ECharacterImportance; 
		importance = character.GetCharacterImportance();
		switch( importance )
		{
			case 0:
				return 'panel_glossary_character_importance_main';
			case 1:
				return 'panel_glossary_character_importance_secondary';
		}
	}
}
