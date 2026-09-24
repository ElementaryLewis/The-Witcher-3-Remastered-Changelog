/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskDespawn extends IBehTreeTask
{
	var callFromQuest 			: bool;
	var destroyCooldown 		: float;
	var despawn					: bool;
	var disappearfxName 		: name;
	var emptyName 				: name;
	var despawnEventName 		: name;
	var raiseEventName			: name;
	
	default despawnEventName = 'Vanish';
	default emptyName = '';
	default despawn = false;

	function IsAvailable() : bool
	{
		if ( callFromQuest )
		{
			return true;
		}
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		npc.DisableHitAnimFor( 2.0 );
		npc.RaiseForceEvent( raiseEventName );
		
		if( disappearfxName != emptyName )
		{
			
			npc.PlayEffect( disappearfxName );
		}
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		while ( !despawn )
		{
			Sleep( 0.01 );
		}
		npc.SetVisibility( false );
		npc.EnablePhysicalMovement( false );
		
		Sleep( destroyCooldown );
		
		return BTNS_Completed;
	}
	
	function OnDeactivate()
	{
		GetActor().Destroy();
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == despawnEventName )
		{
			despawn = true;
			return true;
		}
		return false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'Despawn' )
		{
			callFromQuest = true;
			return true;
		}
		return false;
	}
};

class CBTTaskDespawnDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskDespawn';

			 var callFromQuest : bool;
	editable var despawnEventName : name;
	editable var disappearfxName : name;
	editable var raiseEventName : name;
	editable var destroyCooldown : float;
	
	default despawnEventName = 'Vanish';
	default raiseEventName = 'Despawn';
	default destroyCooldown = 10;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'Despawn' );
	}
};