/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
statemachine class W3DogNPC extends CNewNPC
{
	editable var wildDog : bool;
	editable var shouldLie : bool;
	var isInIdle : bool;
	var isInLie : bool;
	
	default wildDog = false;
	default shouldLie = false;
	var InteractionComponent 	: CInteractionComponent;
		
	var pettingState				:  W3DogNPCStateDogPettingIdleState;
	
	
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		
		InteractionComponent = (CInteractionComponent) this.GetComponentByClassName('CInteractionComponent');
		isInIdle = true;
		
		AddAnimEventCallback( 'EndPetting',		'OnAnimEvent_EndPetting' );
		AddAnimEventCallback( 'PettingDogVoiceSet',		'OnAnimEvent_PettingDogVoiceSet' );
		
		if(shouldLie)
		{
			this.RaiseEvent('Lie');
		}
		
	}
	
	event OnLieStart()
	{
		isInLie = true;		
	}
	
	event OnLieEnd()
	{
		isInLie = false;	
	}


	
	event OnAnimEvent_EndPetting( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		ResetInteraction();
	}

	event OnInteraction( actionName : string, activator : CEntity )
	{
		if(super.OnInteraction(actionName, activator) == false)
		{
			if ( actionName == "PetDog")
			{
				InteractWith(true);
			}
		}
		
		
	}
	
	public function ResetInteraction()
	{
		this.RemoveTimer('PettingFailSafe');
		pettingState = ((W3DogNPCStateDogPettingIdleState)this.GetState('DogPettingIdleState'));
		pettingState.ForceLeave();
	}
	
	public function InteractWith( on : bool)
	{
		var inteactionState				: W3PlayerWitcherStateApproachInteractionState;
		var vecToObject 				: Vector;
		var heading						: float;
		
		this.GotoState('DogPettingIdleState');
		
		
		
		this.AddTimer( 'PettingFailSafe', 10.f );
	
		vecToObject = this.GetWorldPosition() - thePlayer.GetWorldPosition();
		heading = VecHeading( vecToObject );
		inteactionState = ( W3PlayerWitcherStateApproachInteractionState )thePlayer.GetState( 'ApproachInteractionState' );
		inteactionState.SetObjectPointHeading( heading, this );
		inteactionState.SetApproachTimeout(10.0f);
		inteactionState.SetShouldApproachWithHeading(true);
		
		
		if(wildDog)
		{
			inteactionState.SetSyncPettingDogAnimation(3);
		}
		else
		{
			if(isInLie)
			{
				inteactionState.SetSyncPettingDogAnimation(2);
			}
			else
			{
				inteactionState.SetSyncPettingDogAnimation(1);
			}
		}
		
		
		
		
		thePlayer.OnMeleeForceHolster(true);
		
		thePlayer.HideUsableItem(true);
		
		
		thePlayer.OnEquipMeleeWeapon( PW_None, true );
		
		
		if(thePlayer.IsAnyWeaponHeld() || thePlayer.IsCurrentlyUsingItemL())
		{
			thePlayer.OnMeleeForceHolster(true);
			
			thePlayer.HideUsableItem(true);
			
			
			thePlayer.OnEquipMeleeWeapon( PW_None, true );
			this.AddTimer( 'ApproachInteractionDelay', 0.5f );
		}
		else
		{
			thePlayer.GotoState( 'ApproachInteractionState' );
		}
		
		
		

	}
	
	private timer function ApproachInteractionDelay(delta : float , id : int)
	{
		thePlayer.GotoState( 'ApproachInteractionState' );
	}
	
	private timer function PettingFailSafe(delta : float , id : int)
	{
		pettingState = ((W3DogNPCStateDogPettingIdleState)this.GetState('DogPettingIdleState'));
		this.GotoState(pettingState.prevState);
	}

}

state DogPettingIdleState in W3DogNPC
{
	var forceBehaviorId 			: int;
	var prevState	: name;
	var shouldForceExit : bool;
	event OnEnterState( prevStateName : name )
	{
		shouldForceExit = false;
		ForceBehavior(parent);
		prevState = prevStateName;
		super.OnEnterState( prevStateName );
		
	}

	event OnLeaveState( nextStateName : name )
	{ 
		if(shouldForceExit)
		{
			parent.RaiseEvent('ForceIdle');
		}
		shouldForceExit = false;
		parent.CancelAIBehavior(forceBehaviorId);
		super.OnLeaveState( nextStateName );
	}
	
	public function ForceLeave()
	{
		shouldForceExit = true;
		parent.GotoState(prevState);
	}
	
	function ForceBehavior(l_Entity : CEntity)
	{
		var l_summon 			: CNewNPC;
		var l_spawnTree 		: IAIActionTree;
		
		l_summon = ( CNewNPC ) l_Entity;
		
		l_spawnTree = new CAIDoNothingAction in l_Entity;
		l_spawnTree.OnCreated();
		forceBehaviorId = l_summon.ForceAIBehavior( l_spawnTree, BTAP_AboveCombat );
	}
	
}