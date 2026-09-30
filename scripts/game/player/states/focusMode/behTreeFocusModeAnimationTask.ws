/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBehTreeFocusModeAnimationTask extends IBehTreeTask
{
	var isReady : bool;
	var hitAnimation : name;
	
	default isReady = false;
	
	function IsAvailable() : bool
	{
		return isReady;
	}
	
	function OnDeactivate()
	{
		isReady = false;
		hitAnimation = 'None';
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC;
		var position, direction : Vector;
		var heading : float;
		var ass : SAnimatedSlideSettings;
		var ret : bool;
		
		npc = GetNPC();
		
		position = Vector( 0.f, 0.f, 0.f );
		direction = VecNormalize( thePlayer.GetWorldPosition() - npc.GetWorldPosition() );
		heading = VecHeading( direction );
		
		
		
		
		
		
		ResetAnimatedSlideSettings( ass );
		ass.animation = hitAnimation;
		ass.slotName = 'GAMEPLAY_SLOT';
		ass.useRotationDeltaPolicy = true;
		ass.blendIn = 0.2f;
		ass.blendOut = 0.2f;
		
		ret = npc.ActionAnimatedSlideToStatic( ass, position, heading, false, true );
		
		
		if ( !ret )
		{
			LogChannel( 'FM', "ERROR - CBehTreeFocusModeAnimationTask::Main" );
		}
		
		return BTNS_Completed;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var npc : CNewNPC;
		
		if ( animEventName == 'ApplyEffect' )
		{
			npc = GetNPC();		
			
			npc.GetRootAnimatedComponent().FreezePose();
			npc.Kill( 'Combat Focus Mode' );
			return true;
		}
		return false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{	
		if ( eventName == 'CombatFocusModeHitAnimation' )
		{
			hitAnimation = GetEventParamCName( 'None' );
			
			isReady = true;
			
			return true;
		}
		
		return false;
	}
};

class CBehTreeFocusModeAnimationTaskDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeFocusModeAnimationTask';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'CombatFocusModeHitAnimation' );
	}
}



class CBehTreeTaskFocusModeHandler extends IBehTreeTask
{
	private var activate : bool;
	
	default activate = false;
	
	function IsAvailable() : bool
	{
		return activate;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		GetNPC().ActionCancelAll();
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		if( !GetNPC().RaiseForceEvent( 'ForceIdle' ) )
		{
			return BTNS_Failed;
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		activate = false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var owner : CNewNPC = GetNPC();
		if ( eventName == 'CombatFocusMode' )
		{
			activate = true;
			return true;
		} 
		if ( eventName == 'CombatFocusModeEnd' )
		{
			Complete(true);
		}
		return false;
	}
};

class CBehTreeTaskFocusModeHandlerDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeTaskFocusModeHandler';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'CombatFocusMode' );
	}
}