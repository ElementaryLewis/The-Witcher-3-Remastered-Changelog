/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4GlossaryEncyclopediaMenu extends CR4ListBaseMenu
{	
	private	var m_fxUpdateEntryInfo		: CScriptedFlashFunction;
	private var m_fxUpdateEntryImage	: CScriptedFlashFunction;
	private var m_fxSetMovieData 		: CScriptedFlashFunction;

	event  OnConfigUI()
	{	
		var flashModule : CScriptedFlashSprite;
		
		super.OnConfigUI();
		
		
		flashModule = GetMenuFlash();
		
		m_fxUpdateEntryInfo = flashModule.GetMemberFlashFunction( "setEntryText" );
		m_fxUpdateEntryImage = flashModule.GetMemberFlashFunction( "setEntryImg" );
		m_fxSetMovieData = m_flashModule.GetMemberFlashFunction( "setMovieData" );
		
		ShowRenderToTexture("");
		
		PopulateData();
	}
	
	event  OnClosingMenu()
	{
		
		super.OnClosingMenu();
	}
	
	event  OnCloseMenu()
	{	
		super.OnCloseMenu();
		
		if( m_parentMenu )
		{
			m_parentMenu.ChildRequestCloseMenu();
		}
	}
	
	private function PopulateData():void
	{
		var flashArray : CScriptedFlashArray;
		
		flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		PopulateDataCharacters(flashArray);
		
		
		
		m_flashValueStorage.SetFlashArray( "glossary.encyclopedia.list", flashArray );
		if( flashArray.GetLength() > 0 )
		{			
			m_fxShowSecondaryModulesSFF.InvokeSelfOneArg(FlashArgBool(true));
		}
		else
		{
			m_fxShowSecondaryModulesSFF.InvokeSelfOneArg(FlashArgBool(false));
		}
	}
	
	
	
	
	private function PopulateDataCharacters(flashArray:CScriptedFlashArray):void
	{
		var i:int;
		var tempCharacters				: array<CJournalBase>;
		var characterTemp				: CJournalCharacter;
		var status						: EJournalStatus;
		
		m_journalManager.GetActivatedOfType( 'CJournalCharacter', tempCharacters );
		
		for( i = 0; i < tempCharacters.Size(); i += 1 )
		{
			characterTemp = (CJournalCharacter)tempCharacters[i];
			if (characterTemp)
			{
				status = m_journalManager.GetEntryStatus( characterTemp );
				
				if (status == JS_Active)
				{
					AddCharacterJournalEntryToArray(characterTemp, flashArray);
				}
			}
		}
	}
	
	private function AddCharacterJournalEntryToArray(journalCharacter:CJournalCharacter, flashArray:CScriptedFlashArray):void
	{
		var l_DataFlashObject 		: CScriptedFlashObject;
		var i, length				: int;
		var l_Title					: string;
		var l_Tag					: name;
		var l_IconPath				: string;
		var l_GroupTag				: name;
		var l_IsNew					: bool;
		
		l_GroupTag = 'panel_title_glossary_characters';
		
		l_Tag = journalCharacter.GetUniqueScriptTag();
		l_Title = GetLocStringById( journalCharacter.GetNameStringId() );	
		l_IconPath = thePlayer.ProcessGlossaryImageOverride( journalCharacter.GetImagePath(), l_Tag );
		l_IsNew	= m_journalManager.IsEntryUnread( journalCharacter );

		
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
		
		flashArray.PushBackFlashObject(l_DataFlashObject);
	}
	
	function GetCharacterDescription( currentCharacter : CJournalCharacter ) : string 
	{
		var i : int;
		var str : string;
		var locStrId : int;
		var description : CJournalCharacterDescription;
		
		var currentIndex:int;
		var placedString : bool;
		var currentJournalDescriptionText : JournalDescriptionText;
		var journalDescriptionArray : array<JournalDescriptionText>;

		str = "";
		for( i = 0; i < currentCharacter.GetNumChildren(); i += 1 )
		{
			description = (CJournalCharacterDescription)(currentCharacter.GetChild(i));
			if( m_journalManager.GetEntryStatus(description) == JS_Active )
			{
			
			currentJournalDescriptionText.stringKey = description.GetDescriptionStringId();
			currentJournalDescriptionText.order = description.GetOrder();
			currentJournalDescriptionText.groupOrder = 1;
				
			if (journalDescriptionArray.Size() == 0)
			{
				journalDescriptionArray.PushBack(currentJournalDescriptionText);
			}
			else
			{
				placedString = false;
				
				for (currentIndex = 0; currentIndex < journalDescriptionArray.Size(); currentIndex += 1)
				{
					if (journalDescriptionArray[currentIndex].groupOrder > currentJournalDescriptionText.groupOrder ||
						(journalDescriptionArray[currentIndex].groupOrder <= currentJournalDescriptionText.groupOrder && 
						 journalDescriptionArray[currentIndex].order > currentJournalDescriptionText.order))
					{
						journalDescriptionArray.Insert(Max(0, currentIndex), currentJournalDescriptionText);
						placedString = true;
						break;
					}
				}
				
				if (!placedString)
				{
					journalDescriptionArray.PushBack(currentJournalDescriptionText);
				}
			}
			}
		}
		for ( i = 0; i < journalDescriptionArray.Size(); i += 1 )
		{
			str += GetLocStringById(journalDescriptionArray[i].stringKey) + "<br>";
		}

		if( str == "" || str == "<br>" )
		{
			str = GetLocStringByKeyExt("panel_journal_quest_empty_description");
		}
		
		return str;
	}
	
	function getCharacterImage( character : CJournalCharacter ) : string
	{
		var entityFilename : string;
		entityFilename = character.GetEntityTemplateFilename();
		
		
			return "img://textures/journal/characters/" + thePlayer.ProcessGlossaryImageOverride( character.GetImagePath(), character.GetUniqueScriptTag() );
		
	}
	
	
	
	
	
	private function PopulateDataLocations(flashArray:CScriptedFlashArray):void
	{
		var i							: int;
		var tempEntries					: array<CJournalBase>;
		var entryTemp					: CJournalPlaceGroup;
		var status						: EJournalStatus;
		
		m_journalManager.GetActivatedOfType( 'CJournalPlaceGroup', tempEntries );
		
		for( i = 0; i < tempEntries.Size(); i += 1 )
		{
			entryTemp = (CJournalPlaceGroup)tempEntries[i];
			
			if (entryTemp)
			{
				status = m_journalManager.GetEntryStatus( tempEntries[i] );
				
				if (status == JS_Active)
				{
					AddLocationJournalEntryToArray(entryTemp, flashArray);
				}
			}
		}
	}
	
	private function AddLocationJournalEntryToArray(journalEntry:CJournalPlaceGroup, flashArray:CScriptedFlashArray):void
	{
		var l_DataFlashObject 		: CScriptedFlashObject;
		var j						: int;
		var l_entry					: CJournalPlace;
		var l_tempEntries			: array<CJournalBase>;
		
		var l_Title					: string;
		var l_Tag					: name;
		var l_IconPath				: string;
		var l_GroupTitle			: string;
		var l_GroupTag				: name;
		var l_IsNew					: bool;
		
		l_GroupTitle = GetLocStringByKeyExt("panel_title_glossary_places");
		l_GroupTag = journalEntry.GetUniqueScriptTag();
		m_journalManager.GetActivatedChildren(journalEntry, l_tempEntries);
		
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
			l_DataFlashObject.SetMemberFlashBool(  "dropDownOpened", IsCategoryOpened(l_GroupTag) );
			l_DataFlashObject.SetMemberFlashString(  "dropDownIcon", journalEntry.GetImage() );
			
			l_DataFlashObject.SetMemberFlashBool( "isNew", l_IsNew );
			l_DataFlashObject.SetMemberFlashBool( "selected", (l_Tag == currentTag) );			
			l_DataFlashObject.SetMemberFlashString(  "label", l_Title );
			l_DataFlashObject.SetMemberFlashString(  "iconPath", "icons/tutorials/"+l_IconPath );
				
			flashArray.PushBackFlashObject(l_DataFlashObject);
		}
	}
	
	function GetPlaceDescription( currentEntry : CJournalPlace ) : string
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
	
	function getPlaceImage( place : CJournalPlace ) : string
	{
		return "img://textures/journal/places/" + place.GetImage();
	}
	
	
	
	
	
	private function PopulateDataEvents(flashArray:CScriptedFlashArray):void
	{
		var i:int;
		var tempEntries	: array<CJournalBase>;
		var entryTemp	: CJournalGlossaryGroup;
		var status		: EJournalStatus;
		
		m_journalManager.GetActivatedOfType( 'CJournalGlossaryGroup', tempEntries );
		
		for( i = 0; i < tempEntries.Size(); i += 1 )
		{
			entryTemp = (CJournalGlossaryGroup)tempEntries[i];
			if (entryTemp)
			{
				status = m_journalManager.GetEntryStatus( entryTemp );
				
				if (status == JS_Active)
				{
					AddEventJournalEntryToArray(entryTemp, flashArray);
				}
			}
		}
	}
	
	private function AddEventJournalEntryToArray(journalEntry:CJournalGlossaryGroup, flashArray:CScriptedFlashArray):void
	{
		var i 					: int;
		var l_tempEntries 		: array<CJournalBase>;
		var l_entry 			: CJournalGlossary;
		var l_DataFlashObject	: CScriptedFlashObject;
		
		var l_Title				: string;
		var l_Tag				: name;
		var l_IconPath			: string;
		var l_GroupTitle		: string;
		var l_IsNew				: bool;
		
		l_GroupTitle = GetLocStringByKeyExt("panel_title_glossary_dictionary");
		m_journalManager.GetActivatedChildren(journalEntry, l_tempEntries);
		
		for( i = 0; i < l_tempEntries.Size(); i += 1 )
		{
			l_entry = (CJournalGlossary)l_tempEntries[i];
			if( m_journalManager.GetEntryStatus(l_entry) < JS_Active ) 
			{	
				continue;
			}
			l_Title = GetLocStringById( l_entry.GetTitleStringId() );	
			l_IconPath = l_entry.GetImagePath();
			l_IsNew	= m_journalManager.IsEntryUnread( l_entry );
			l_Tag = l_entry.GetUniqueScriptTag();

			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
				
			l_DataFlashObject.SetMemberFlashUInt(  "tag", NameToFlashUInt(l_Tag) );
			l_DataFlashObject.SetMemberFlashString(  "dropDownLabel", l_GroupTitle );
			l_DataFlashObject.SetMemberFlashString(  "dropDownIcon", "icons/monsters/ICO_MonsterDefault.png" ); 
								
			l_DataFlashObject.SetMemberFlashBool( "isNew", l_IsNew );
			l_DataFlashObject.SetMemberFlashBool( "selected", (currentTag == l_Tag) );			
			l_DataFlashObject.SetMemberFlashString( "label", l_Title );
			l_DataFlashObject.SetMemberFlashString( "iconPath", "icons/tutorials/"+l_IconPath );
				
			flashArray.PushBackFlashObject(l_DataFlashObject);
		}
	}
	
	function GetEventsDescription( currentEntry : CJournalGlossary ) : string
	{
		var i : int;
		var str : string;
		var locStrId : int;
		var description : CJournalGlossaryDescription;
		
		str = "";
		for( i = 0; i < currentEntry.GetNumChildren(); i += 1 )
		{
			description = (CJournalGlossaryDescription)(currentEntry.GetChild(i));
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
	
	function getEventImage( jEvent : CJournalGlossary ) : string
	{
		return "img://textures/journal/events/" + jEvent.GetImagePath();
	}
	
	
	
	private function GetGlossaryLocalizedStringById( id : int ) : string
	{
		return "";
	}
	
	function UpdateDescription( entryName : name )
	{
		var journalEntry:CJournalBase;
		var characterEntry:CJournalCharacter;
		var placeEntry:CJournalPlace;
		var eventEntry:CJournalGlossary;
		var titleText:string;
		var descText:string;
		
		titleText = "";
		descText = "";
		
		journalEntry = m_journalManager.GetEntryByTag( entryName );
		
		characterEntry = (CJournalCharacter)journalEntry;
		if (characterEntry)
		{
			descText = GetCharacterDescription(characterEntry);
			titleText = GetLocStringById( characterEntry.GetNameStringId());
		}
		
		placeEntry = (CJournalPlace)journalEntry;
		if (placeEntry)
		{
			descText = GetPlaceDescription(placeEntry);
			titleText = GetLocStringById( placeEntry.GetNameStringId());	
		}
		
		eventEntry = (CJournalGlossary)journalEntry;
		if (eventEntry)
		{
			descText = GetEventsDescription(eventEntry);
			titleText = GetLocStringById( eventEntry.GetTitleStringId());	
		}
		
		m_fxUpdateEntryInfo.InvokeSelfTwoArgs(FlashArgString(titleText), FlashArgString(descText));
	}
	
	function UpdateImage( tag : name )
	{
		var journalEntry:CJournalBase;
		var characterEntry:CJournalCharacter;
		var placeEntry:CJournalPlace;
		var eventEntry:CJournalGlossary;
		var imgLoc:string;
		
		imgLoc = "";
		
		journalEntry = m_journalManager.GetEntryByTag( tag );
		
		characterEntry = (CJournalCharacter)journalEntry;
		if (characterEntry)
		{
			imgLoc = getCharacterImage(characterEntry);
		}
		
		placeEntry = (CJournalPlace)journalEntry;
		if (placeEntry)
		{
			imgLoc = getPlaceImage(placeEntry);
		}
		
		eventEntry = (CJournalGlossary)journalEntry;
		if (eventEntry)
		{
			imgLoc = getEventImage(eventEntry);
		}
		
		
		if (imgLoc != "")
		{
			m_flashValueStorage.SetFlashBool( "render.to.texture.texture.visible", false);
		}
		
		m_fxUpdateEntryImage.InvokeSelfOneArg(FlashArgString(imgLoc));
	}
	
	function PlayOpenSoundEvent()
	{
		
		
	}
}


exec function r4glossaryencyclopedia()
{
	theGame.RequestMenu( 'GlossaryEncyclopediaMenu' );
}
