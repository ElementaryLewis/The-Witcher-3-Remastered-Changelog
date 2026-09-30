/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskManageBuffImmunityOnEvent extends IBehTreeTask
{
	var effects 							: array<EEffectType>;
	var onActivate 							: bool;
	var onDeactivate 						: bool;
	var i									: int;
	var npc									: CNewNPC;
	
	public var startGameplayEvent 			: name;
	public var endGameplayEvent	   	   		: name;
	public var startAnimEvent	 			: name;
	public var endAnimEvent 				: name;
	
	function IsAvailable() : bool
	{
		return true;
	}
	
	private function Init()
	{
		npc = GetNPC();
	}

	function OnActivate() : EBTNodeStatus
	{
		Init();
		
		if( onActivate )
		{
			for ( i = 0; i < effects.Size(); i += 1 )
			{
				npc.AddBuffImmunity( effects[i], 'CBTTaskManageBuffImmunityOnEvent', true );
			}
		}

		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( onDeactivate )
		{
			for ( i = 0; i < effects.Size(); i += 1 )
			{
				npc.RemoveBuffImmunity( effects[i], 'CBTTaskManageBuffImmunityOnEvent' );
			}
		}
	}

	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if( !isActive )
		{
			return false;
		}
		
		if( eventName == startAnimEvent && IsNameValid(startAnimEvent) && startAnimEvent != 'None' && !onActivate)
		{
			for ( i = 0; i < effects.Size(); i += 1 )
			{
				npc.AddBuffImmunity( effects[i], 'CBTTaskManageBuffImmunityOnEvent', true );
			}
			
			return true;
		}
		else if( eventName == endAnimEvent && IsNameValid(endAnimEvent) && endAnimEvent != 'None' && !onDeactivate)
		{
			for ( i = 0; i < effects.Size(); i += 1 )
			{
				npc.RemoveBuffImmunity( effects[i], 'CBTTaskManageBuffImmunityOnEvent' );
			}
			
			return true;
		}
		
		return false;
	}
		
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{		
		if( !isActive )
		{
			return false;
		}
		
		if( animEventName == startAnimEvent && IsNameValid(startAnimEvent) && startAnimEvent != 'None' && !onActivate)
		{
			for ( i = 0; i < effects.Size(); i += 1 )
			{
				npc.AddBuffImmunity( effects[i], 'CBTTaskManageBuffImmunityOnEvent', true );
			}
			
			return true;
		}
		else if( animEventName == endAnimEvent && IsNameValid(endAnimEvent) && endAnimEvent != 'None' && !onDeactivate)
		{
			for ( i = 0; i < effects.Size(); i += 1 )
			{
				npc.RemoveBuffImmunity( effects[i], 'CBTTaskManageBuffImmunityOnEvent' );
			}
			
			return true;
		}
		
		return false;
	}
	
}

class CBTTaskManageBuffImmunityOnEventDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskManageBuffImmunityOnEvent';
	
	editable var effects 					: array<EEffectType>;
	editable var onActivate 				: bool;
	editable var onDeactivate 				: bool;
	
	editable var startGameplayEvent	   	    : name;
	editable var endGameplayEvent	   	   	: name;
	editable var startAnimEvent 			: name;
	editable var endAnimEvent 				: name;
	
	default onActivate = true;
	default startGameplayEvent = 'StartImmunity';
	default endGameplayEvent = 'StopImmunity';
	default startAnimEvent = 'StartImmunity';
	default endAnimEvent = 'StopImmunity';

	hint startGameplayEvent = "Won't work unless onActivate is false.";
	hint endGameplayEvent = "Won't work unless onDeactivate is false.";
	hint startAnimEvent = "Won't work unless onActivate is false.";
	hint endAnimEvent = "Won't work unless onDeactivate is false.";
	
}