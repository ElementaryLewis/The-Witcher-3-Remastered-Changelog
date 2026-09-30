/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum ExplorationInteractionType
{
	EIT_Ladder	= 0,
	EIT_Boat	= 1,
	EIT_Ledge	= 2,
};



class CExplorationStateInteraction extends CExplorationStateAbstract
{	
	private				var	explorationType			: ExplorationInteractionType;
	
	public	editable	var	autointeract			: bool;			default	autointeract			= false;
	private editable	var	safetyTimeToExit		: float;		default safetyTimeToExit		= 0.15f;
	private	editable	var	useAutomaticExploration	: bool;			default	useAutomaticExploration	= false;
	private	editable	var	allowOnDiving			: bool;			default	allowOnDiving			= true;
	
	
	private	editable	var	timeBeforeExploring		: float;		default	timeBeforeExploring		= 1.5f;
	
	
	private	editable	var	ladderCheckSides		: bool;			default	ladderCheckSides		= false;
	private	editable	var	ladderImpulseBack		: float;		default	ladderImpulseBack		= 1.0f;
	private	editable	var	ladderRangeFreeOfNPCs	: float;		default	ladderRangeFreeOfNPCs	= 1.5f;
	
	
	protected editable inlined	var	cameraSetClimb	: CCameraParametersSet;	
	private editable	var	cameraOffsetBack		: float;		default	cameraOffsetBack		= 0.25f;
	private editable	var	cameraOffsetUp			: float;		default	cameraOffsetUp			= 0.0f;
	private editable	var	cameraPichInput			: float;		default	cameraPichInput			= 30.0f;
	private editable	var	cameraBlendSpeedTrans	: float;		default	cameraBlendSpeedTrans	= 0.75f;
	private editable	var	cameraBlendSpeedYaw		: float;		default	cameraBlendSpeedYaw		= 3.0f;
	private editable	var	cameraBlendSpeedPitch	: float;		default	cameraBlendSpeedPitch	= 2.0f;
	
	private 			var	camPosOriginal			: Vector;
	private 			var	camInitialized			: bool;
	
	
	
	
	
	
	private				var cachedWeapon			: EPlayerWeapon;
	private  saved		var restoreUsableItemLAtEnd : bool;
	
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'Interaction';
		}
		
		m_StateTypeE		= EST_Locked;
		m_InputContextE		= EGCI_JumpClimb; 
		m_HolsterIsFastB	= true;
		
		
		
		SetCanSave( false );
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{
	}

	
	function StateWantsToEnter() : bool
	{
		var stateTime				: float;
		var stateName				: name;
		var tryingToInteractClimb	: bool;
		var tryingToInteractLadder	: bool;
		
		
		tryingToInteractClimb	= m_ExplorationO.m_InputO.IsExplorationJustPressed();
		tryingToInteractLadder	= m_ExplorationO.m_InputO.IsInteractionJustPressed();
		
		
		if( WantsToExploreStatics( tryingToInteractClimb, tryingToInteractLadder ) )
		{
			return true;
		}
		
		if( WantsToExploreBoat( tryingToInteractClimb ) )
		{
			return true;
		}
		
		return false;
	}
	
	
	function StateCanEnter( curStateName : name ) : bool
	{	
		if( !thePlayer.IsActionAllowed( EIAB_Explorations ) )
		{
			return false;
		}
		else if( !thePlayer.IsActionAllowed( EIAB_Movement ) )
		{
			return false;
		}
		else
		{
			return true;
		}
		
	}
	
	
	private function StateEnterSpecific( prevStateName : name )	
	{
		thePlayer.OnRangedForceHolster( true, true, false );
	
		if( m_ExplorationO.m_SharedDataO.GetCurentExplorationType() == ET_Ladder )
		{
			explorationType	= EIT_Ladder;
		}
		else if( m_ExplorationO.m_SharedDataO.GetCurentExplorationType() == ET_Boat_Enter_From_Beach )
		{
			explorationType	= EIT_Boat;
		}
		else
		{
			explorationType	= EIT_Ledge;
		}
		
		
		m_ExplorationO.m_OwnerMAC.GetMovementAdjustor().CancelByName( 'turnOnJump' );
		
		if( !m_ExplorationO.m_SharedDataO.HasValidExploration() )
		{
			LogExplorationToken( "We entered exploration without a valid token" );
		}
		StartExploring( m_ExplorationO.m_SharedDataO.GetLastExploration() );
		
		camInitialized	= false;
		
		
		thePlayer.RemoveTimer( 'DelayedSheathSword' );
		
		
		if ( thePlayer.IsHoldingItemInLHand() )
		{			
			thePlayer.OnUseSelectedItem ( true );
			restoreUsableItemLAtEnd	= true;		
		}
		else
		{
			thePlayer.OnHolsterLeftHandItem();
		}
		cachedWeapon = thePlayer.GetCurrentMeleeWeaponType();
		
		
		thePlayer.EnableRunCamera( false );
		
		
		AddActionsToBlock();
		BlockActions();
		
		
		m_ExplorationO.m_OwnerMAC.SetEnabledFeetIK( false );
		
		
		thePlayer.AbortSign();		
	}	
	
	
	protected function AddActionsToBlock()
	{
		super.AddActionsToBlock();
		AddActionToBlock( EIAB_RunAndSprint );
		AddActionToBlock( EIAB_DrawWeapon );
		if ( explorationType == EIT_Boat )
		{
			AddActionToBlock( EIAB_CallHorse );
		}
	}
	
	
	private function AddAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( 'AnimEndAUX', 'OnAnimEvent_SubstateManager' );
	}
	
	
	private function StartExploring( exploration : SExplorationQueryToken )
	{
		
		
		
		if( exploration.usesHands )
		{
			thePlayer.OnRangedForceHolster();
		}
		
		if( m_ExplorationO.m_IsDebugModeB )
		{			
			LogExplorationToken( "Token sent to cpp. " + m_ExplorationO.m_SharedDataO.GetExplorationTokenDescription( exploration ) );
		}
		
		
		((CPlayerStateTraverseExploration)thePlayer.GetState('TraverseExploration')).SetExploration( exploration );
		thePlayer.GotoState('TraverseExploration');
	}
	
	
	function StateChangePrecheck( )	: name
	{	
		
		
		
		if( m_ExplorationO.GetStateTimeF() > safetyTimeToExit && thePlayer.GetCurrentStateName() != 'TraverseExploration' )
		{
			return 'Idle';
		}
		
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{
		if( explorationType == EIT_Ladder )
		{			
			theGame.GetGameCamera().SetCollisionOffset( m_ExplorationO.m_OwnerE.GetWorldUp() );
			thePlayer.OnMeleeForceHolster(true);
		}
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{		
		thePlayer.ActionCancelAll();
		thePlayer.SetBIsCombatActionAllowed( true );
		thePlayer.OnCombatActionEndComplete();
		
		if ( !thePlayer.IsActionAllowed(EIAB_DrawWeapon) && thePlayer.IsActionAllowed(EIAB_SwordAttack) )
		{
			if ( cachedWeapon == PW_Steel || cachedWeapon == PW_Silver )
				thePlayer.OnEquipMeleeWeapon( cachedWeapon, true );
		}
		
		if( explorationType	== EIT_Ladder ) 
		{
			m_ExplorationO.m_MoverO.SetVelocity( -m_ExplorationO.m_OwnerE.GetWorldForward() * ladderImpulseBack );			
			m_ExplorationO.m_SharedDataO.m_CanFallSetVelocityB	= false;
			
			theGame.GetGameCamera().ResetCollisionOffset();
		}
		if ( restoreUsableItemLAtEnd )
		{
			restoreUsableItemLAtEnd = false;
			thePlayer.OnUseSelectedItem ();
		}
		
		
		m_ExplorationO.m_OwnerMAC.SetEnabledFeetIK( true, 0.1f );
		thePlayer.ReapplyCriticalBuff();
	}
	
	
	private function RemoveAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( 'AnimEndAUX' );
	}
	
	
	function ReactToLoseGround() : bool
	{
		return true;
	}
	
	
	function ReactToBeingHit( optional damageAction : W3DamageAction ) : bool
	{
		var curHealth : float;
		var maxHealth : float;

		
		if( GetParent() == (CObject)thePlayer )
		{
			curHealth = thePlayer.GetHealth();
			maxHealth = thePlayer.GetMaxHealth();
			if( maxHealth != -1 && curHealth / maxHealth <= 0.025f )
			{
				SetReadyToChangeTo( 'StartFalling' );
				return false;
			}
		}
		
		
		if( !( damageAction && (W3Effect_Toxicity)damageAction.causer ) )
		{				
			SetReadyToChangeTo( 'StartFalling' );
		}
		
		return false;
	}
	
	
	function CanInteract( ) :bool
	{		
		return false;
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventName == 'AnimEndAUX' )
		{		
			SetReadyToChangeTo( 'Idle' );
		}
	}
	
	
	public function GetCameraSet( out cameraSet : CCameraParametersSet) : bool
	{
		if( explorationType == EIT_Boat || explorationType == EIT_Ledge )
		{
			cameraSet	= cameraSetClimb;
			
			return true;
		}
		
		return super.GetCameraSet( cameraSet );
	}
	
	
	public function CameraChangesRotationController() : bool
	{
		if( explorationType == EIT_Boat || explorationType == EIT_Ledge  )
		{
			if( IsNameValid( cameraSetClimb.pivotRotationController ) )
			{
				if( cameraSetClimb.pivotRotationController != m_ExplorationO.m_DefaultCameraSetS.pivotRotationController )
				{
					return true;
				}
			}
		}
		return super.CameraChangesRotationController();
	}
	
	
	private function WantsToExploreStatics( tryingToInteractClimb, tryingToInteractLadder : bool ) : bool
	{
		var exploration				: SExplorationQueryToken;
		var queryContext			: SExplorationQueryContext;
		var	inputVector				: Vector;
		var potentialTarget			: Vector;
		var	interactionComponent	: CInteractionComponent;
		var ladderInteraction		: W3LadderInteraction;
		
		
		
		if( !autointeract && !tryingToInteractClimb && !tryingToInteractLadder )
		{
			return false;
		}		
		
		
		if( !allowOnDiving && thePlayer.IsDiving() )
		{
			return false;
		}
		
		
		if( !autointeract && !tryingToInteractLadder && m_ExplorationO.GetStateCur() != 'Swim' )
		{
			return false;
		}
		
		
		interactionComponent	= theGame.GetInteractionsManager().GetActiveInteraction();
		if( interactionComponent )
		{
			ladderInteraction	= ( W3LadderInteraction ) interactionComponent.GetParent();
			if ( !ladderInteraction )
			{
				tryingToInteractLadder	= false;
			}
		}
		
		
		inputVector		= m_ExplorationO.m_InputO.GetMovementOnPlaneV();
		if( tryingToInteractClimb  || tryingToInteractLadder )
		{
			queryContext.maxAngleToCheck	= m_ExplorationO.m_SharedDataO.m_AngleToExploreManualF;		
		}
		else
		{
			queryContext.maxAngleToCheck	= m_ExplorationO.m_SharedDataO.m_AngleToExploreAutoF;
		}
		
		
		
		if( !tryingToInteractClimb && !tryingToInteractLadder )
		{
			
			queryContext.forAutoTraverseSmall	= false; 
			
			
			queryContext.forAutoTraverseBig		= thePlayer.GetIsRunning(); 
			if( queryContext.forAutoTraverseBig )
			{
				if( !m_ExplorationO.m_InputO.IsModuleConsiderable() )
				{
					inputVector	= m_ExplorationO.m_OwnerE.GetWorldForward();
				}
			}
		}
		
		
		
		if( tryingToInteractClimb || tryingToInteractLadder || queryContext.forAutoTraverseSmall || queryContext.forAutoTraverseBig )
		{			
			if( m_ExplorationO.m_InputO.IsModuleConsiderable() || queryContext.forAutoTraverseSmall || queryContext.forAutoTraverseBig  )
			{				
				queryContext.inputDirectionInWorldSpace	= inputVector;
				queryContext.laddersOnly	= false;
			}
			
			
			if( !tryingToInteractClimb )
			{
				queryContext.laddersOnly	= true;
			}
			
			
			exploration = theGame.QueryExplorationSync( m_ExplorationO.m_OwnerE, queryContext );
			if ( exploration.valid )
			{
				
				if( exploration.type == ET_Ladder )
				{
					if( !autointeract && !tryingToInteractLadder )
					{
						return false;
					}
					
					
					if( !tryingToInteractLadder && !queryContext.forAutoTraverseSmall && !queryContext.forAutoTraverseBig )
					{
						return false;
					}
					
					
					if( IsLadderInUse( exploration ) )
					{
						return false;
					}
				}
				else if( !autointeract && !tryingToInteractClimb )
				{
					return false;
				}
				
				if( ( exploration.type == ET_Boat_B ) || ( exploration.type == ET_Boat_P ) || ( exploration.type == ET_Boat_Passenger_B ) )
				{
					return false;
				}
				
				m_ExplorationO.m_SharedDataO.SetExplorationToken( exploration, GetStateName() );
				return true;
			}
		}
		
		return false;
	}
	
	
	private function WantsToExploreBoat( tryingToInteractClimb : bool ) : bool
	{
		var exploration 		: SExplorationQueryToken;
		var	vehicleComponent	: CVehicleComponent;
		var vehicleEntity		: CEntity;
		var success 			: bool = true;		
		var direction			: Vector;		
		var	inputVector			: Vector;
		
		
		if( !autointeract && !tryingToInteractClimb )
		{
			return false;
		}
		
		
		if( m_ExplorationO.GetStateCur() != 'Swim' )
		{
			return false;
		}
		
		inputVector			= m_ExplorationO.m_InputO.GetMovementOnPlaneV();
		
		
		vehicleComponent	= thePlayer.FindTheNearestVehicle( 3.0f, false );
		if( !vehicleComponent )
		{
			return false;
		}
		
		
		
		if( !vehicleComponent.CanUseBoardingExploration() )
		{
			return false;
		}
		
		vehicleEntity		= ( CEntity ) vehicleComponent.GetParent();		
		if( !vehicleEntity )
		{
			return false;
		}
		
		exploration			= theGame.QueryExplorationFromObjectSync( thePlayer, vehicleEntity );		
		if( !exploration.valid )
		{		
			return false;
		}
		
		
		if( exploration.type != ET_Boat_Enter_From_Beach && exploration.type != ET_Ledge )
		{
			return false;
		}
		
		
		if( VecDistanceSquared2D( exploration.pointOnEdge, m_ExplorationO.m_OwnerE.GetWorldPosition() ) >= 1.0f )
		{
			return false;
		}
		
		
		direction		= exploration.pointOnEdge - m_ExplorationO.m_OwnerE.GetWorldPosition();
		inputVector		= m_ExplorationO.m_InputO.GetMovementOnPlaneNormalizedV();
		
		if( tryingToInteractClimb || VecDot( direction, inputVector ) > 0.0f )
		{
			m_ExplorationO.m_SharedDataO.SetExplorationToken( exploration, GetStateName() );
			
			return true;
		}
		
		return false;
	}
	
	
	
	private function IsLadderInUse( exploration : SExplorationQueryToken ) : bool
	{
		var npcsArround	: array<CActor>;
		var i			: int;
		var type 		: EExplorationType;
		
		npcsArround	= GetActorsInRange( thePlayer, ladderRangeFreeOfNPCs );
		for( i = 0; i < npcsArround.Size(); i += 1 )
		{
			if( npcsArround[i].GetTraverser().GetExplorationType( type ) )
			{
				if( type == ET_Ladder )
				{
					return true;
				}
			}
		}
		
		return false;
	}
}
