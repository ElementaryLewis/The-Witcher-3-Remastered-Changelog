/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ActorLatentActionMoveTo extends IPresetActorLatentAction
{
	default resName = "resdef:ai\scripted_actions/move_to";
	
	editable var maxDistance : float;
	editable var moveSpeed : float;
	editable var moveType : EMoveType;
	editable var targetTag : CName;
	editable var rotateAfterwards : bool;
	
	default maxDistance = 1.0;
	default moveSpeed = 1.0;
	default moveType = MT_Walk;
	default rotateAfterwards = true;
	
	function ConvertToActionTree( parentObj : IScriptable ) : IAIActionTree
	{
		var action : CAIMoveToAction;
		
		action = new CAIMoveToAction in parentObj;
		action.OnCreated();
		
		action.params.maxDistance = maxDistance;
		action.params.moveSpeed = moveSpeed;
		action.params.moveType = moveType;
		action.params.targetTag = targetTag;
		action.params.rotateAfterwards = rotateAfterwards;
		
		return action;
	}
}
