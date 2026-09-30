/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3InteractionSwitch extends W3PhysicalSwitch
{
	protected var isActivatedByPlayer		: bool;			
	editable var focusModeHighlight			: EFocusModeVisibility;
	
	default isActivatedByPlayer				= false;
	default focusModeHighlight 				= FMV_None;
	
	editable var interactionActiveInState 	: ESwitchState;
	default interactionActiveInState		= SS_Undefined;	
	hint interactionActiveInState = "State for which interaction is possible. If set to SS_Undefined, there's no restriction.";
		
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		UpdateInteractionComponent( GetComponent( "Unlocked" ) );
		UpdateFocusModeHighlight();
		
		AddAnimEventCallback('SwitchOnEvent',	'OnAnimEvent_SwitchOnEvent');
		AddAnimEventCallback('SwitchOffEvent',	'OnAnimEvent_SwitchOffEvent');
	}

	public function Enable( enable : bool )
	{
		super.Enable( enable );
		
		UpdateInteractionComponent( GetComponent( "Unlocked" ) );
		UpdateFocusModeHighlight();		
	}
	
	public function Lock( lock : bool )
	{
		var hud : CR4ScriptedHud;
		
		super.Lock( lock );
		
		if ( isActivatedByPlayer )
		{
			
			hud = (CR4ScriptedHud)theGame.GetHud();
			if ( hud )
			{
				hud.ForceInteractionUpdate();
			}
		}
	}
	
	public function InteractWith( on : bool, switchType : PhysicalSwitchAnimationType )
	{
		var inteactionState				: W3PlayerWitcherStateApproachInteractionState;
		var vecToObject 				: Vector;
		var heading						: float;
		
		
		
		vecToObject = this.GetWorldPosition() - thePlayer.GetWorldPosition();
		heading = VecHeading( vecToObject );
		inteactionState = ( W3PlayerWitcherStateApproachInteractionState )thePlayer.GetState( 'ApproachInteractionState' );
		inteactionState.SetObjectPointHeading( heading, this );
		inteactionState.SetSyncInteractionAnimation( on, switchType );
		
			
		if (thePlayer.IsHoldingItemInLHand())
		{
			thePlayer.HideUsableItem(true);
			restoreUsableItemL = true;
		}
		
		thePlayer.GotoState( 'ApproachInteractionState' );
	}
	
	function UpdateInteractionComponent( optional component : CComponent )
	{
		if ( !component )
		{
			component = GetComponent( 'CInteractionComponent' );
		}
		if ( component )
		{
			component.SetEnabled( enabled );
		}
	}
	
	event OnInteractionAttached( interaction : CInteractionComponent )
	{
		UpdateInteractionComponent( interaction );
	}
	
	function UpdateFocusModeHighlight()
	{
		if ( enabled )
		{
			SetFocusModeVisibility( focusModeHighlight );
		}
		else
		{
			SetFocusModeVisibility( FMV_None );
		}	
	}

	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		if ( activator == thePlayer )
		{
			isActivatedByPlayer = true;
		}
	}
	
	event OnInteractionDeactivated( interactionComponentName : string, activator : CEntity )
	{
		if ( activator == thePlayer )
		{
			isActivatedByPlayer = false;
		}
	}
	
	event OnInteraction( interactionComponentName : string, activator : CEntity )
	{
		var switchEntity : CEntity;
		var toSwitchEntity : Vector;
		
		if ( IsLocked() )
		{
			GetWitcherPlayer().DisplayHudMessage("panel_hud_message_just_locked");
		}
		else 
		{
			if ( IsOn() )
			{
				if ( switchOffAnimationType == PSAT_Undefined )
				{
					Toggle( (CActor)activator, false, false );
				}
				else
				{
					InteractWith( true, switchOffAnimationType );
					
					
					EntityHandleSet( lastActivatorHandle, thePlayer );
				}
			}
			else if ( IsOff() )
			{
				if ( switchOffAnimationType == PSAT_Undefined )
				{
					Toggle( (CActor)activator, false, false );
				}
				else
				{
					InteractWith( false, switchOffAnimationType );
					
					
					EntityHandleSet( lastActivatorHandle, thePlayer );
				}
			}
		}
		
		
			
	}
	
	event OnInteractionActivationTest( interactionComponentName : string, activator : CEntity )
	{
		if ( interactionActiveInState != SS_Undefined && interactionActiveInState != currentState )
		{
			return false;
		}
		
		if( activator == thePlayer )
		{
			if( IsEnabled() )
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		return false;
	}
	
	event OnAnimEvent_SwitchOnEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetBehaviorVariable( 'SwitchState', BEH_ON_FROM_OFF );
	}
	event OnAnimEvent_SwitchOffEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetBehaviorVariable( 'SwitchState', BEH_OFF_FROM_ON );
	}
};
