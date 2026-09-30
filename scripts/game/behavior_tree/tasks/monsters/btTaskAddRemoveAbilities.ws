/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskAddRemoveAbilities extends IBehTreeTask
{
	public var abilitiesName				: array<name>;
	public var removeAbilities				: bool;
	public var onActivate					: bool;
	public var onDeactivate					: bool;
	public var onAnimEventAdd				: name;
	public var onAnimEventRemove			: name;
	public var onGameplayEventAdd			: name;
	public var onGameplayEventRemove		: name;
	
	private var i							: int;
	private var npc							: CNewNPC;
	private var eventReceived 				: bool;

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
		
		if ( onActivate )
		{
			for (i = 0; i < abilitiesName.Size(); i += 1)
			{
				if( IsNameValid( abilitiesName[i] ) && !removeAbilities )
				{
					npc.AddAbility( abilitiesName[i] );
				}
				else if ( IsNameValid ( abilitiesName[i] ) && removeAbilities )
				{
					npc.RemoveAbility( abilitiesName[i] );
				}
			}
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		Init();
		
		if ( onDeactivate )
		{
			for (i = 0; i < abilitiesName.Size(); i += 1)
			{
				if( IsNameValid( abilitiesName[i] ) && !removeAbilities )
				{
					npc.AddAbility( abilitiesName[i] );
				}
				else if ( IsNameValid ( abilitiesName[i] ) && removeAbilities )
				{
					npc.RemoveAbility( abilitiesName[i] );
				}
			}
		}
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{		
		Init();
		
		if( !isActive )
		{
			return false;
		}
		
		if( animEventName == onAnimEventAdd && IsNameValid(onAnimEventAdd) && onAnimEventAdd != 'None' && !onActivate )
		{
			for (i = 0; i < abilitiesName.Size(); i += 1)
			{
				if( IsNameValid( abilitiesName[i] ) )
				{
					npc.AddAbility( abilitiesName[i] );
				}
			}
			
			return true;
		}
		else if( animEventName == onAnimEventRemove && IsNameValid(onAnimEventRemove) && onAnimEventRemove != 'None' && !onDeactivate)
		{
			for (i = 0; i < abilitiesName.Size(); i += 1)
			{
				if( IsNameValid( abilitiesName[i] ) )
				{
					npc.RemoveAbility( abilitiesName[i] );
				}
			}
			
			return true;
		}
		
		return false;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		Init();
		
		if( !isActive )
		{
			return false;
		}
		
		if( eventName == onGameplayEventAdd && IsNameValid(onGameplayEventAdd) && onGameplayEventAdd != 'None' && !onActivate)
		{
			for (i = 0; i < abilitiesName.Size(); i += 1)
			{
				if( IsNameValid( abilitiesName[i] ) )
				{
					npc.AddAbility( abilitiesName[i] );
				}
			}
			
			return true;
		}
		else if( eventName == onGameplayEventRemove && IsNameValid(onGameplayEventRemove) && onGameplayEventRemove != 'None' && !onDeactivate)
		{
			for (i = 0; i < abilitiesName.Size(); i += 1)
			{
				if( IsNameValid( abilitiesName[i] ) )
				{
					npc.RemoveAbility( abilitiesName[i] );
				}
			}
			
			return true;
		}
		
		return false;
	}
}

class BTTaskAddRemoveAbilitiesDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskAddRemoveAbilities';

	editable var abilitiesName				: array<name>;
	editable var removeAbilities			: bool;
	editable var onActivate					: bool;
	editable var onDeactivate				: bool;
	editable var onAnimEventAdd				: name;
	editable var onAnimEventRemove			: name;
	editable var onGameplayEventAdd			: name;
	editable var onGameplayEventRemove		: name;
	
	default removeAbilities					= false;
	default onActivate						= true;
	default onDeactivate					= false;
	default onAnimEventAdd					= 'AddSelectedAbilities';
	default onAnimEventRemove				= 'RemoveSelectedAbilities';
	default onGameplayEventAdd				= 'AddSelectedAbilities';
	default onGameplayEventRemove			= 'RemoveSelectedAbilities';
	
	hint onAnimEventAdd = "Won't work unless 'onActivate' is false. 'removeAbilities' is ignored";
	hint onAnimEventRemove = "Won't work unless 'onDeactivate' is false. 'removeAbilities' is ignored";
	hint onGameplayEventAdd = "Won't work unless 'onActivate' is false. 'removeAbilities' is ignored";
	hint onGameplayEventRemove = "Won't work unless 'onDeactivate' is false. 'removeAbilities' is ignored";
}