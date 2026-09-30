/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3AnimatedContainer extends W3Container
{
	
	
	
	editable var animationForAllInteractions 	: bool;							default animationForAllInteractions = true;
	editable var interactionName				: string;						default interactionName = "Container";
	editable var holsterWeaponAtTheBeginning	: bool;							default holsterWeaponAtTheBeginning = true;
	editable var interactionAnim				: EPlayerExplorationAction;		default interactionAnim	= PEA_None;
	editable var slotAnimName 					: name;							default slotAnimName = '';
	editable var interactionAnimTime			: float;						default interactionAnimTime	= 4.0f;
	
	
	editable var desiredPlayerToEntityDistance	: float;						default desiredPlayerToEntityDistance = -1;
	editable var matchPlayerHeadingWithHeadingOfTheEntity	: bool;				default matchPlayerHeadingWithHeadingOfTheEntity = true;
	
	editable var attachThisObjectOnAnimEvent	: bool;							default attachThisObjectOnAnimEvent = false;
	editable var attachSlotName					: name; 						default attachSlotName = 'r_weapon';
	editable var attachAnimName 				: name; 						default attachAnimName = 'attach_item';
	editable var detachAnimName 				: name; 						default detachAnimName = 'detach_item';
	
	
	
	hint interactionAnim = "Name of the animation played on interaction.";
	hint interactionAnimTime = "Duration of the animation played on interaction.";
	hint animationForAllInteractions = "Should the animation be played only for interaction with Examine action assigned.";
	hint attachThisObjectOnAnimEvent = "";
	hint desiredPlayerToEntityDistance = "if set to < 0 palyer will stay in position where interaction was pressed";
	
	event OnDetaching()
	{
		if ( isPlayingInteractionAnim )
		{
			OnPlayerActionEnd();
		}		
	}	
	
	event OnInteraction( actionName : string, activator : CEntity  )
	{
		super.OnInteraction( actionName, activator );
		
		if ( activator == thePlayer && thePlayer.IsActionAllowed( EIAB_InteractionAction ) && thePlayer.CanPerformPlayerAction(true))
		{
			if( ( animationForAllInteractions == true || actionName == interactionName ) && !lockedByKey )
			{
				PlayInteractionAnimation();
			}
		}
		
	}
	
	function ProcessLoot ()
	{
	
	}
	
	event OnStreamIn()
	{
		super.OnStreamIn();
	}	
	
	public function OnContainerClosed()
	{
		var effectName : name;

		if ( !HasQuestItem() )
		{
			StopEffect( 'quest_highlight_fx' );	
		}

		if ( isPlayingInteractionAnim )
		{
			thePlayer.PlayerStopAction( interactionAnim );	
		}
		
		effectName = this.GetAutoEffect();
		if ( effectName != '' )
		{
			this.StopEffect( effectName );
		}

		super.OnContainerClosed();
	}
	
	
	function PlayInteractionAnimation()
	{
		if ( interactionAnim == PEA_SlotAnimation && !IsNameValid(slotAnimName) )
		{
			super.ProcessLoot();
				
			return;
		}
		
		if ( interactionAnim != PEA_None )
		{
			if ( this.attachThisObjectOnAnimEvent )
			{
				thePlayer.AddAnimEventChildCallback(this,attachAnimName,'OnAnimEvent_Custom');
				thePlayer.AddAnimEventChildCallback(this,detachAnimName,'OnAnimEvent_Custom');
			}
				
			thePlayer.RegisterForPlayerAction(this, false);
			
			if ( ShouldBlockGameplayActionsOnInteraction() )
			{
				BlockGameplayActions(true);
			}
			
			if ( !GetToPointAndStartAction() )
				OnPlayerActionEnd();
			
			isPlayingInteractionAnim = true;
			
			if ( interactionAnim == PEA_SlotAnimation )
				return;
			
			if ( interactionAnimTime < 1.0f )
			{
				interactionAnimTime = 1.0f;
			}
			if(skipInventoryPanel)
			{
				AddTimer( 'TimerDeactivateAnimation', interactionAnimTime, false );			
			}
			
		}
		else
		{
			super.ProcessLoot();
		}
	}
	
	function BlockGameplayActions( lock : bool )
	{
		var exceptions : array< EInputActionBlock >;		
		exceptions.PushBack( EIAB_ExplorationFocus );
	
		if ( lock && holsterWeaponAtTheBeginning )
			thePlayer.OnEquipMeleeWeapon(PW_None,true);
			
		if ( lock )
			thePlayer.BlockAllActions('W3AnimationInteractionEntity', true, exceptions);
		else
			thePlayer.BlockAllActions('W3AnimationInteractionEntity', false);
	}
	
	function ShouldBlockGameplayActionsOnInteraction() : bool
	{
		return true;
	}
	
	function GetToPointAndStartAction() : bool
	{
		var movementAdjustor 				: CMovementAdjustor = thePlayer.GetMovingAgentComponent().GetMovementAdjustor();
		var ticket 							: SMovementAdjustmentRequestTicket = movementAdjustor.CreateNewRequest( 'InteractionEntity' );
		
		movementAdjustor.AdjustmentDuration( ticket, 0.5 );
		
		if ( matchPlayerHeadingWithHeadingOfTheEntity )
			movementAdjustor.RotateTowards( ticket, this );
		if ( desiredPlayerToEntityDistance >= 0 )
			movementAdjustor.SlideTowards( ticket, this, desiredPlayerToEntityDistance );
		
		return thePlayer.PlayerStartAction( interactionAnim, slotAnimName );
	}
	
	private var objectAttached : bool;
	private var objectCachedPos : Vector;
	private var objectCachedRot	: EulerAngles;
	
	private function AttachObject()
	{
		if ( objectAttached )
			return;
			
		objectCachedPos = this.GetWorldPosition();
		objectCachedRot = this.GetWorldRotation();
		this.CreateAttachment(thePlayer,attachSlotName);
		objectAttached = true;
	}
	
	private function DetachObject()
	{
		if ( !objectAttached )
			return;
			
		this.BreakAttachment();
		this.TeleportWithRotation(objectCachedPos,objectCachedRot);
		objectAttached = false;
	}
	
	
	
	
	event OnPlayerActionStartFinished()
	{
		if ( !skipInventoryPanel )
		{
			ShowLoot();
		}
	}
	
	
	event OnPlayerActionEnd()
	{
		isPlayingInteractionAnim = false;
		thePlayer.UnregisterForPlayerAction(this, false);
		
		thePlayer.RemoveAnimEventChildCallback(this,attachAnimName);
		thePlayer.RemoveAnimEventChildCallback(this,detachAnimName);
		
		if ( ShouldBlockGameplayActionsOnInteraction() )
		{
			BlockGameplayActions(false);
		}
		DetachObject();
	}
	
	event OnAnimEvent_Custom( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventName == attachAnimName && attachThisObjectOnAnimEvent )
		{
			AttachObject();
		}
		else if ( animEventName == detachAnimName )
		{
			DetachObject();
		}
	}
	
	
	
	
	timer function TimerDeactivateAnimation( td : float , id : int)
	{
		TakeAllItems();
		OnContainerClosed();		
	}
}