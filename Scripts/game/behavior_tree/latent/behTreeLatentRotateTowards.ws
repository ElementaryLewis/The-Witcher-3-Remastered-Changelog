/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ActorLatentActionRotateTo extends IPresetActorLatentAction
{
	default resName = "resdef:ai\scripted_actions/rotate_towards";
	
	editable var targetTag : CName;
	
	function ConvertToActionTree( parentObj : IScriptable ) : IAIActionTree
	{
		var action : CAIRotateToAction;
		
		action = new CAIRotateToAction in parentObj;
		action.OnCreated();
		
		action.targetTag = targetTag;
		
		return action;
	}
}
