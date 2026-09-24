/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EPlayerReplacerType
{
	EPRT_Undefined,
	EPRT_Geralt,
	EPRT_Ciri,
}


class W3QuestCond_ReplacerCondition extends CQuestScriptedCondition
{
	editable var replacerType : EPlayerReplacerType;
	editable var inverted : bool;
	
	function Evaluate() : bool
	{
		var match : bool;
		
		if(replacerType == EPRT_Undefined)
			return false;
			
		if(!thePlayer)
			return false;
			
		if(replacerType == EPRT_Geralt)
		{
			match = (W3PlayerWitcher)thePlayer;
		}
		else if(replacerType == EPRT_Ciri)
		{
			match = (W3ReplacerCiri)thePlayer;
		}
		
		if(inverted)
			return !match;
			
		return match;
	}
}