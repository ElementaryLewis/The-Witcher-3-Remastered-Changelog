/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskAddRemoveAbility extends IBehTreeTask
{
	
	
	
	public var abilityName					: name;
	public var allowMultiple				: bool;
	public var removeAbility				: bool;
	public var delayUntilInCameraFrame 		: bool;
	public var onDeactivate					: bool;
	public var onAnimEventName				: name;
	
	private var eventReceived 				: bool;
	
	
	
	
	function OnActivate() : EBTNodeStatus
	{
		if( !onDeactivate && !delayUntilInCameraFrame ) Execute();
		return BTNS_Active;
	}
	
	
	
	
	latent function Main() : EBTNodeStatus
	{
		var res 	: bool;
		var actor 	: CActor = GetActor();
		
		if ( delayUntilInCameraFrame )
		{
			while ( !res )
			{
				if ( thePlayer.WasVisibleInScaledFrame( actor, 1.f, 1.f ) )
				{
					if ( IsNameValid( onAnimEventName ) && eventReceived )
					{
						Execute();
						res = true;
					}
					else
					{
						Execute();
						res = true;
					}
				}
				Sleep( 0.25f );
			}
		}
		
		return BTNS_Active;
	}
	
	
	
	
	function OnDeactivate()
	{
		if( onDeactivate ) Execute();
	}
	
	
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( IsNameValid( onAnimEventName ) && animEventName == onAnimEventName )
		{
			eventReceived = true;
			if ( !delayUntilInCameraFrame )
			{
				Execute();
			}
			return true;
		}
		return false;
	}
	
	
	private function Execute()
	{
		var l_npc : CNewNPC = GetNPC();
		
		if( removeAbility )
		{
			l_npc.RemoveAbility( abilityName );
		}
		else
		{
			l_npc.AddAbility( abilityName, allowMultiple );
		}
	}

}


class BTTaskAddRemoveAbilityDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskAddRemoveAbility';
	
	
	
	editable var abilityName				: name;
	editable var allowMultiple				: bool;
	editable var removeAbility				: bool;
	editable var delayUntilInCameraFrame 	: bool;
	editable var onDeactivate				: bool;
	editable var onAnimEventName			: name;
	
	default allowMultiple = true;
	
	hint onDeactivate = "Execute on deactivate instead on on Activate";
}
