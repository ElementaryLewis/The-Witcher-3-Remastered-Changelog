/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
statemachine class W3SmartObject extends CR4MapPinEntity
{
	editable var startAnim 	: name;
	editable var loopAnims	: array<name>;
	editable var stopAnim	: name;
	
	editable var canBeInterruptedByInput : bool;
	
	default canBeInterruptedByInput = true;
	
	private var m_currentUser	: CActor;
	
	protected var m_saveLockID	: int;

	default focusModeVisibility = FMV_Interactive;
	default autoState = 'Null';
	
	private var possibleItemSlots : array<name>;
	
	public function GetCurrentUser() : CActor
	{
		return m_currentUser;
	}
	
	public function IsBeingUsed() : bool
	{
		return m_currentUser;
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var mapManager : CCommonMapManager = theGame.GetCommonMapManager();

		if( activator.GetEntity() == GetWitcherPlayer() )
		{
			mapManager.SetEntityMapPinDiscoveredScript( false, entityName, true );
		}
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		var l_movingAgentComponent		: CMovingPhysicalAgentComponent;
		
		l_movingAgentComponent = (CMovingPhysicalAgentComponent)((CActor)activator).GetMovingAgentComponent();
		
		if( activator == thePlayer && !IsBeingUsed() && l_movingAgentComponent.IsOnGround() )
		{
			m_currentUser = (CActor)activator;
			OnStartInteracting();
			GotoState( 'Approach' );
		}
	}
	
	
	event OnStartInteracting()
	{
		var l_movAdj 				: CMovementAdjustor; 
		var l_ticket 				: SMovementAdjustmentRequestTicket;
		var l_node					: CNode;
		var l_component				: CComponent;
		var l_HACKmovementCorrector	: CExplorationMovementCorrector;
		var l_buffsHud				: CR4HudModuleBuffs;
		
		
		theGame.CreateNoSaveLock( "W3SmartObject", m_saveLockID , true );
		
		possibleItemSlots.Clear();
		possibleItemSlots.Resize(4);
		possibleItemSlots.PushBack( 'r_weapon' );
		possibleItemSlots.PushBack( 'l_weapon' );
		possibleItemSlots.PushBack( 'r_hand' );
		possibleItemSlots.PushBack( 'l_hand' );
		
		if( m_currentUser == thePlayer )
		{
			
			l_HACKmovementCorrector = thePlayer.substateManager.m_MovementCorrectorO;
			l_HACKmovementCorrector.disallowRotWhenGoingToSleep = true;
			
			
			
			
			thePlayer.OnMeleeForceHolster( false );
			
			if( thePlayer.IsCurrentlyUsingItemL() )
			{
				thePlayer.OnUseSelectedItem();
			}
			
			thePlayer.AddBuffImmunity_AllCritical( 'W3SmartObject', true );
			thePlayer.AddBuffImmunity_AllNegative( 'W3SmartObject', true );
			
			thePlayer.BlockAllActions( 'W3SmartObject', true,,,,,false );
		}
		
		
		l_component = GetComponentByClassName( 'CInteractionComponent' );
		l_component.SetEnabled( false );
		
		EnableCollision( false );
	}
	
	event OnStopInteracting()
	{
		var l_component				: CComponent;
		var l_HACKmovementCorrector	: CExplorationMovementCorrector;
		
		m_currentUser.ActionCancelAll();
		
		l_component = GetComponentByClassName( 'CInteractionComponent' );
		l_component.SetEnabled( true );
		
		if( m_currentUser == thePlayer )
		{
			l_HACKmovementCorrector = thePlayer.substateManager.m_MovementCorrectorO;
			l_HACKmovementCorrector.disallowRotWhenGoingToSleep = false;
			
			thePlayer.RemoveBuffImmunity_AllCritical( 'W3SmartObject' );
			thePlayer.RemoveBuffImmunity_AllNegative( 'W3SmartObject' );
			
			thePlayer.BlockAllActions( 'W3SmartObject', false );
		}
		
		DestroyNotWantedItems();
		
		m_currentUser = NULL;
		
		theGame.ReleaseNoSaveLock( m_saveLockID );
		
		this.RemoveTimer( 'InterruptMonitor' );
	}
	
	private function DestroyNotWantedItems()
	{
		var itemID : SItemUniqueId;
		var inv : CInventoryComponent;
		var i 	: int;
		
		inv = m_currentUser.GetInventory();
		
		if( inv )
		{
			for( i = 0; i < possibleItemSlots.Size(); i += 1 )
			{
				itemID = inv.GetItemFromSlot( possibleItemSlots[i] );
				if( inv.IsIdValid( itemID ) )
				{
					inv.UnmountItem( itemID, true );
				}
			}
		}
	}	
	
	protected function EnableCollision( enable : bool )
	{
		var l_component				: CRigidMeshComponent;
		l_component = (CRigidMeshComponent)GetComponent( "collision" );
		l_component.SetEnabled( enable );
	}
	
	timer function InterruptMonitor( dt : float , id : int )
	{
		if( theInput.IsActionJustPressed( 'Use' ) || theInput.IsActionJustPressed( 'Jump' ) )
		{
			GotoState( 'StopUse' );
		}
	}
	
	event OnStartUseEnd()
	{
		var dupa : bool;
		
		dupa = true;
	}
	
	timer function ApproachFailsafe( dt : float , id : int )
	{
		if( this.GetCurrentStateName() == 'Approach' )
		{
			GotoState( 'Null' );
		}
	}
}

state Null in W3SmartObject
{
	event OnEnterState( prevStateName : name )
	{
		parent.OnStopInteracting();
	}
}

state Approach in W3SmartObject
{
	event OnEnterState( prevStateName : name )
	{		
		Approach();
		
	}
	
	event OnLeaveState( nextStateName : name )
	{
	}
	
	entry function Approach()
	{
		var l_movAdj 				: CMovementAdjustor; 
		var l_ticket 				: SMovementAdjustmentRequestTicket;
		var l_node					: CNode;
		var result 					: bool;
		
		l_node = parent.GetComponent( "approachPoint" );
		
		parent.AddTimer( 'ApproachFailsafe', 5.0f, false );
		result = parent.GetCurrentUser().ActionMoveToNodeWithHeading( l_node, MT_Walk, 1.f, 0.4f );
		
		if( result )
		{
			
			l_movAdj = parent.GetCurrentUser().GetMovingAgentComponent().GetMovementAdjustor();
			
			l_movAdj.CancelAll();
			l_ticket = l_movAdj.CreateNewRequest( 'InteractionEntity' );
			l_movAdj.AdjustmentDuration( l_ticket, 0.75f );
			
			l_movAdj.SlideTowards( l_ticket, l_node );	
			l_movAdj.RotateTo( l_ticket, l_node.GetHeading() );
			
			Sleep( 0.75f );
			
			
			
			
			parent.GotoState( 'StartUse' );
		}
		else
		{
			parent.GotoState( 'Null' );
		}
	}
}

state StartUse in W3SmartObject
{
	event OnEnterState( prevStateName : name )
	{
		PlayStartAnimation();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		virtual_parent.OnStartUseEnd();
	}
	
	entry function PlayStartAnimation()
	{
		var l_movAdj 				: CMovementAdjustor; 
		var l_ticket 				: SMovementAdjustmentRequestTicket;
		var l_node					: CNode;
		
		l_node = parent.GetComponent( "startPoint" );
		
		if( l_node )
		{
			
			l_movAdj = parent.GetCurrentUser().GetMovingAgentComponent().GetMovementAdjustor();
			
			l_movAdj.CancelByName( 'InteractionEntity' );
			l_ticket = l_movAdj.CreateNewRequest( 'InteractionEntity' );
			
			l_movAdj.BindToEvent( l_ticket, 'RotateToInteraction' );
			
			l_movAdj.RotateTo( l_ticket, l_node.GetHeading() );
		}
		
		parent.GetCurrentUser().ActionPlaySlotAnimation( 'PLAYER_SLOT', parent.startAnim );
		
		parent.GotoState( 'LoopUse' );
	}
}

state LoopUse in W3SmartObject
{
	event OnEnterState( prevStateName : name )
	{
		if( parent.canBeInterruptedByInput )
		{
			parent.AddTimer( 'InterruptMonitor', 0, true );
		}
		
		PlayLoopAnimation();
	}
	
	event OnLeaveState( nextStateName : name )
	{
	}
	
	entry function PlayLoopAnimation()
	{
		var i : int;
		
		for( i = 0; i < parent.loopAnims.Size(); i += 1 )
		{
			parent.GetCurrentUser().ActionPlaySlotAnimation( 'PLAYER_SLOT', parent.loopAnims[i] );
		}
		
		parent.GotoState( 'StopUse' );
	}
}

state StopUse in W3SmartObject
{
	event OnEnterState( prevStateName : name )
	{
		parent.RemoveTimer( 'InterruptMonitor' );
		PlayStopAnimation();
	}
	
	event OnLeaveState( nextStateName : name )
	{
	}
	
	entry function PlayStopAnimation()
	{
		parent.GetCurrentUser().ActionPlaySlotAnimation( 'PLAYER_SLOT', parent.stopAnim );
		
		parent.GotoState( 'Null' );
	}
}