/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskNervousState extends IBehTreeTask
{
	public var dangerRadius, rearingChance, kickChance : float;
	public var callFromQuestOnly : bool;
	public var force : bool;
	public var called : bool;
	private var dangerNode : CNode;
	
	default callFromQuestOnly = false;
	
	function IsAvailable() : bool
	{
		var owner : CActor = GetActor();
		
		if ( callFromQuestOnly )
		{
			if ( called )
			{
				return true;
			}
		}
		else if (  !force )
		{
			return true;
		}
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var owner : CActor = GetActor();
		
		if(  callFromQuestOnly || force )
		{
			owner.ActionCancelAll();
		}
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var owner : CActor = GetActor();
		
		
		if( true )
		{
			Complete(false);
			return BTNS_Failed;
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var owner : CActor = GetActor();
		owner.ActionCancelAll();
		callFromQuestOnly = false;
	}

	
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'AnimalNervous' )
		{
			called = true;
			return true;
		}
		if ( eventName == 'CalmDown' )
		{
			GetActor().RaiseForceEvent('ForceIdle');
			Complete(true);
		}
		return false;
	}
};

class CBTTaskNervousStateDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskNervousState';

	editable var callFromQuestOnly : bool;
	editable var dangerRadius : float;
	editable var rearingChance : float;
	editable var kickChance : float;
	
	default callFromQuestOnly = false;
	default dangerRadius = 4.0;
	default rearingChance = 0.5;
	default kickChance = 0.5;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'AnimalNervous' );
		listenToGameplayEvents.PushBack( 'CalmDown' );
	}
};