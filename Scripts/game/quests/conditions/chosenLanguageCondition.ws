/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum ELanguageCheckType
{
	LCT_Text,
	LCT_Speech,
	LCT_TextAndSpeech,
}

enum ECheckedLanguage
{	
	TL_None,
	TL_English,
	TL_Polish,
	TL_German,
	TL_Italian,
	TL_French,
	TL_Czech,
	TL_Spanish,
	TL_Chinese,
	TL_Russian,
	TL_Hungarian,
	TL_Japanese,
	TL_Turkish,	
	TL_Korean,
	TL_Brazilian_Portuguese,
	TL_Latin_American_Spanish,
	TL_Arabic,
	TL_Debug,
	TL_Ukranian,
	TL_Chinese_Simplified,
}

function ConvertLanguageNameToEnum( languageName : string ) : ECheckedLanguage
{
	if( languageName == "PL" )return TL_Polish;
	if( languageName == "EN" )return TL_English;
	if( languageName == "DE" )return TL_German;
	if( languageName == "IT" )return TL_Italian;
	if( languageName == "FR" )return TL_French;	
	if( languageName == "CZ" )return TL_Czech;	
	if( languageName == "ES" )return TL_Spanish;
	if( languageName == "ZH" )return TL_Chinese;	
	if( languageName == "RU" )return TL_Russian;
	if( languageName == "HU" )return TL_Hungarian;
	if( languageName == "JP" )return TL_Japanese;
	if( languageName == "TR" )return TL_Turkish;
	if( languageName == "KR" )return TL_Korean;
	if( languageName == "BR" )return TL_Brazilian_Portuguese;
	if( languageName == "ESMX" )return TL_Latin_American_Spanish;
	if( languageName == "AR" )return TL_Arabic;	
	if( languageName == "DEBUG" )return TL_Debug;
	if( languageName == "UA" )return TL_Ukranian;
	if( languageName == "CN" )return TL_Chinese_Simplified;
	
	return 	TL_None;
}

class W3QuestCond_chosenLanguage extends CQuestScriptedCondition
{
	editable var ChoosenTextLanguage : ECheckedLanguage;
	editable var ChoosenSpeechLanguage : ECheckedLanguage;

	editable var checkFor : ELanguageCheckType;	
	
	default checkFor              = LCT_TextAndSpeech;
	default ChoosenTextLanguage   = TL_English;	
	default ChoosenSpeechLanguage = TL_English;
	
	function Evaluate() : bool 
	{
		var selectedSpeech : string;
		var selectedText   : string;
		var conditionsMet  : bool;
		
		theGame.GetGameLanguageName( selectedSpeech, selectedText);
		
		LogQuest("Selected Audio index: " + selectedSpeech );
		LogQuest("Selected Text index: " + selectedText );		
		
		conditionsMet = false;
		
		if( checkFor == LCT_TextAndSpeech )
		{
			if( ConvertLanguageNameToEnum(selectedSpeech) == ChoosenSpeechLanguage 
				&& ConvertLanguageNameToEnum(selectedText) == ChoosenTextLanguage )
			{
				conditionsMet = true;
			}
		}
		else if( checkFor == LCT_Text )
		{
			if( ConvertLanguageNameToEnum(selectedText) == ChoosenTextLanguage )
			{
				conditionsMet = true;
			}
		}
		else if( checkFor == LCT_Speech )
		{
			if( ConvertLanguageNameToEnum(selectedSpeech) == ChoosenSpeechLanguage )
			{
				conditionsMet = true;
			}
		}
		return conditionsMet;
	}
}