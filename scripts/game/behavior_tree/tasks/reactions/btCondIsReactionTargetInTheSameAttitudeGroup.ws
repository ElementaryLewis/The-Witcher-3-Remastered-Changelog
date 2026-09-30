/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondIsReactionTargetInTheSameAttitudeGroup extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		var reactionTargetAttitudeGroup	: name;
		var ownerAttitudeGroup			: name;
		var reactionTarget 				: CActor;
		
		reactionTarget = (CActor)GetNamedTarget('ReactionTarget');
		
		if ( !reactionTarget )
			return false;
		
		ownerAttitudeGroup = GetActor().GetAttitudeGroup();
		reactionTargetAttitudeGroup = reactionTarget.GetAttitudeGroup();
		
		return ownerAttitudeGroup == reactionTargetAttitudeGroup;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTCondIsReactionTargetInTheSameAttitudeGroupDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTCondIsReactionTargetInTheSameAttitudeGroup';
}