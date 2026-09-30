/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ActorLatentActionPlayVoiceSet extends IPresetActorLatentAction
{
	default resName = "resdef:ai\scripted_actions/play_voice_set";
	
	editable var voiceSet : string;
	editable var priority : int;
	
	function ConvertToActionTree( parentObj : IScriptable ) : IAIActionTree
	{
		var action : CAIPlayVoiceSetAction;
		
		action = new CAIPlayVoiceSetAction in parentObj;
		action.OnCreated();
		
		action.voiceSet = voiceSet;
		action.priority = priority;
		
		return action;
	}
}
