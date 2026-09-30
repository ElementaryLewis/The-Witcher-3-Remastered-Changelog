/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskHasVoiceSet extends IBehTreeTask
{
	public var voiceSet 					: string;
	
	function IsAvailable() : bool
	{
		var hasVoicesetResult : EAsyncCheckResult;
		hasVoicesetResult = GetActor().HasVoiceset(voiceSet);
		return hasVoicesetResult == ASR_ReadyTrue;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTTaskHasVoiceSetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskHasVoiceSet';

	editable var voiceSet 					: CBehTreeValString;
}