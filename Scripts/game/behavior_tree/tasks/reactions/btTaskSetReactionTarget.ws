/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSetReactionTarget extends IBehTreeTask
{
	var useCombatTarget : bool;
	function OnActivate() : EBTNodeStatus
	{
		if ( !useCombatTarget )
			this.SetActionTarget( GetActionTarget() );
		else
			this.SetActionTarget( GetCombatTarget() );
		return BTNS_Completed;
	}
}

class CBTTaskSetReactionTargetDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskSetReactionTarget';

	editable var useCombatTarget : bool;
}

class CBTTaskSetActionTargetFromGameplayEvent extends IBehTreeTask
{
	private var sender : CActor;
	
	function OnActivate() : EBTNodeStatus
	{
		if ( sender )
			SetActionTarget(sender);
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		sender = NULL;
	}
	
	function OnListenedGameplayEvent( eventName : CName ) : bool
	{
		var tempSender : CActor;
		
		tempSender = (CActor)GetEventParamObject();
		if ( tempSender )
		{
			sender = tempSender;
			return true;
		}
			
		return false;
	}
}

class CBTTaskSetActionTargetFromGameplayEventDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskSetActionTargetFromGameplayEvent';

	editable var gameplayEventName : CBehTreeValCName;
	
	function OnSpawn( taskGen : IBehTreeTask )
	{
		var task : CBTTaskSetActionTargetFromGameplayEvent;
		var eventName : name;
		eventName = GetValCName( gameplayEventName );
		task = (CBTTaskSetActionTargetFromGameplayEvent) taskGen;
		if ( IsNameValid( eventName ) )
		{
			ListenToGameplayEvent( eventName );
		}
	}
}