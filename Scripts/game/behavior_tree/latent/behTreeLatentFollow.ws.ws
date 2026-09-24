/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ActorLatentActionFollowPlayer extends IPresetActorLatentAction
{
	default resName = "resdef:ai\scripted_actions/follow";
	
	editable var moveType				: EMoveType;
	editable var keepDistance			: bool;
	editable var followDistance			: float;
	editable var moveSpeed				: float;
	editable var teleportToCatchup		: bool;
	editable var cachupDistance			: float;
	
	default moveType					= MT_Walk;
	default moveSpeed					= 1.0;
	default followDistance				= 2.0;
	default keepDistance				= true;
	default teleportToCatchup			= false;
	default cachupDistance				= 75.0;
	
		
	
	function ConvertToActionTree( parentObj : IScriptable ) : IAIActionTree
	{
		var action : CAIFollowAction;
		
		action = new CAIFollowAction in parentObj;
		action.OnCreated();
		
		action.params.targetTag = 'PLAYER';
		action.params.moveType = moveType;
		action.params.keepDistance = keepDistance;
		action.params.followDistance = followDistance;
		action.params.moveSpeed = moveSpeed;
		action.params.teleportToCatchup = teleportToCatchup;
		action.params.cachupDistance = cachupDistance;
		
		return action;
	}
}


class W3ActorLatentActionFollow extends W3ActorLatentActionFollowPlayer
{
	editable var targetTag : CName;
	
	function ConvertToActionTree( parentObj : IScriptable ) : IAIActionTree
	{
		var action : CAIFollowAction;
		
		action = (CAIFollowAction)super.ConvertToActionTree( parentObj );
		action.params.targetTag = targetTag;
		
		return action;
	}
};

