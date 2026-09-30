/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ActorLatentActionPlayAnimation extends IPresetActorLatentAction
{
	default resName = "resdef:ai\scripted_actions/play_animation";
	
	editable var eventStateName: CName;
	
	function ConvertToActionTree( parentObj : IScriptable ) : IAIActionTree
	{
		var action : CAIPlayAnimationStateAction;
		
		action = new CAIPlayAnimationStateAction in parentObj;
		action.OnCreated();
		
		action.eventStateName = eventStateName;
		
		return action;
	}
}

class W3ActorLatentActionSlotAnimation extends IPresetActorLatentAction
{
	default resName = "resdef:ai\scripted_actions/play_animation_slot";
	
	editable var animName: CName;
	editable var slotName: CName;
	
	default slotName = 'NPC_ANIM_SLOT';
	
	function ConvertToActionTree( parentObj : IScriptable ) : IAIActionTree
	{
		var action : CAIPlayAnimationSlotAction;
		
		action = new CAIPlayAnimationSlotAction in parentObj;
		action.OnCreated();
		
		action.animName = animName;
		action.slotName = slotName;
		
		return action;
	}
}

class W3ActorLatentActionBreakAnimations extends IPresetActorLatentAction
{		
	default resName = "resdef:ai\scripted_actions/break_slot_animations";
	
	function ConvertToActionTree( parentObj : IScriptable ) : IAIActionTree
	{
		var action : CAIBreakAnimationsAction;
		
		action = new CAIBreakAnimationsAction in parentObj;
		action.OnCreated();
		
		return action;
	}
};