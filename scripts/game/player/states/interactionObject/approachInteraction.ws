/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state ApproachInteractionState in W3PlayerWitcher extends ExtendedMovable
{
	private var objectPointHeading 		: float;		
	private var approachTimeout 		: float;		
	private var ShouldApproachWithHeading		: bool;		
	private var objectHeadingSet 		: bool;			
	private var stopRequested 			: bool;			
	private var objectEntity			: CEntity;
	private var switchOn				: bool;
	private var switchAnimationType		: PhysicalSwitchAnimationType;
	
	
	
	private var pettingDogType				: int;
	var blockedActions					: array<EInputActionBlock>;
	var prevStateNamePet : name;
	default pettingDogType = 0;
	
	
	
	default approachTimeout = 4.0f;
	default ShouldApproachWithHeading = false;
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		
		
		
		thePlayer.OnRangedForceHolster( true );
		parent.BlockAction( EIAB_DrawWeapon, 'Interaction', false );
		
		
		
		
		
		parent.AddTimer( 'InputCheckDelay', 0.5f, true, false, TICK_PrePhysics );
		parent.AddTimer( 'ApproachTimeout', approachTimeout );
		
		
		if(pettingDogType > 0)
		{		
			prevStateNamePet = prevStateName;
			parent.AddTimer( 'ApproachInteractionDelay', 0.2f );
		}
		else
		{
			InitStateApproachInteraction(prevStateName);
		}
	
		
	}
	
	event OnLeaveState( nextStateName : name )
	{
		
		parent.RemoveTimer( 'InputCheck', TICK_PrePhysics );
		
		
		parent.UnblockAction( EIAB_DrawWeapon, 'Interaction' );
		super.OnLeaveState(nextStateName);
	}
	
	private timer function ApproachInteractionDelay(delta : float , id : int)
	{
		InitStateApproachPettingInteraction(prevStateNamePet);
	}
	
	entry function InitStateApproachPettingInteraction( prevStateName : name )
	{
		var ticket 				: SMovementAdjustmentRequestTicket;
		var movementAdjustor	: CMovementAdjustor;
		var toObjectEntity		: Vector;
		var moveToPosition		: Vector;
		var moveToRotation		: EulerAngles;
		var parentPosition		: Vector;
		var parentRadius		: float;
		
		
		parent.LockEntryFunction( true );
		
		
		if(objectEntity)
		{
			parentPosition 	= parent.GetWorldPosition();
			parentRadius 	= parent.GetRadius();
			toObjectEntity 	= parentPosition - objectEntity.GetWorldPosition();
			
			
			if ( VecLength2D( toObjectEntity ) > 0.81341f || ShouldApproachWithHeading )
			{
				moveToRotation = objectEntity.GetWorldRotation();
				
				
					
				if(pettingDogType == 1)
				{
					moveToPosition = objectEntity.GetWorldPosition() - 1.2f * VecNormalize( VecFromHeading( moveToRotation.Yaw +180 )) + 0.1f * VecNormalize( VecFromHeading( moveToRotation.Yaw + 90 ));
				}
				else if(pettingDogType == 2)
				{
					moveToPosition = objectEntity.GetWorldPosition() - 1.2f * VecNormalize( VecFromHeading( moveToRotation.Yaw +180 )) + 0.1f * VecNormalize( VecFromHeading( moveToRotation.Yaw + 90 ));
				}
				else if(pettingDogType == 3)
				{
					moveToPosition = objectEntity.GetWorldPosition() - 1.5f * VecNormalize( VecFromHeading( moveToRotation.Yaw +180 )) - 0.0f * VecNormalize( VecFromHeading( moveToRotation.Yaw + 90 ));
				}
				
				
				parent.GetVisualDebug().AddSphere( 'approachInteractionPos', parentRadius, moveToPosition, true, Color( 255, 0, 0 ), 3.f );
				
				if ( theGame.GetWorld().NavigationLineTest( parentPosition, moveToPosition, parentRadius ) && 
					 theGame.GetWorld().NavigationCircleTest( moveToPosition, parentRadius ))
				{
					
					
					
					
					if(ShouldApproachWithHeading)
					{
						parent.ActionMoveToWithHeading( moveToPosition, moveToRotation.Yaw, MT_Run, 2.0f, 0.3f );
					}
					else
					{
						parent.ActionMoveTo( moveToPosition, MT_Run, 2.0f, 0.3f );
					}
					
					
				}
				else
				{
					parent.LockEntryFunction( false );
					parent.DisplayHudMessage(GetLocStringByKeyExt( "menu_cannot_perform_action_here" ));
					StopApproach();
					return;
				}
			}
			
		}
		
		
		PlaySyncInteractionAnimation();
		
		parent.LockEntryFunction( false );
		StopApproach();
	}
	
	entry function InitStateApproachInteraction( prevStateName : name )
	{
		var ticket 				: SMovementAdjustmentRequestTicket;
		var movementAdjustor	: CMovementAdjustor;
		var toObjectEntity		: Vector;
		var moveToPosition		: Vector;
		var moveToRotation		: EulerAngles;
		var parentPosition		: Vector;
		var parentRadius		: float;
		
		
		parent.LockEntryFunction( true );
		
		
		if(objectEntity)
		{
			parentPosition 	= parent.GetWorldPosition();
			parentRadius 	= parent.GetRadius();
			toObjectEntity 	= parentPosition - objectEntity.GetWorldPosition();
			
			
			if ( VecLength2D( toObjectEntity ) > 0.81341f || ShouldApproachWithHeading )
			{
				moveToRotation = objectEntity.GetWorldRotation();
				
				moveToPosition = objectEntity.GetWorldPosition() - 1.12f * VecNormalize( VecFromHeading( moveToRotation.Yaw +180 )) + 0.25f * VecNormalize( VecFromHeading( moveToRotation.Yaw + 90 ));
				
				
				
				parent.GetVisualDebug().AddSphere( 'approachInteractionPos', parentRadius, moveToPosition, true, Color( 255, 0, 0 ), 3.f );
				
				if ( theGame.GetWorld().NavigationLineTest( parentPosition, moveToPosition, parentRadius ) && 
					 theGame.GetWorld().NavigationCircleTest( moveToPosition, parentRadius ))
				{
					
					
					
					
					if(ShouldApproachWithHeading)
					{
						parent.ActionMoveToWithHeading( moveToPosition,moveToRotation.Yaw, MT_Walk, 0.001, 0.2f );
					}
					else
					{
						parent.ActionMoveTo( moveToPosition, MT_Walk, 0.001, 0.3 );
					}
				}
			}
			
		}
		
		
		PlaySyncInteractionAnimation();
		
		parent.LockEntryFunction( false );
		StopApproach();
	}
	
	public function SetObjectPointHeading(head : float, obj : CEntity )
	{
		objectPointHeading 	= head;
		objectEntity 		= obj;
	}
	
	public function SetApproachTimeout( timeout : float )
	{
		approachTimeout = timeout;
	}
	
	public function SetShouldApproachWithHeading( b_ShouldApproachWithHeading : bool )
	{
		ShouldApproachWithHeading = b_ShouldApproachWithHeading;
	}
	
	public function SetSyncInteractionAnimation( on : bool, switchType : PhysicalSwitchAnimationType )
	{
		switchOn 			= on;
		switchAnimationType = switchType;
	}
	
	public function SetSyncPettingDogAnimation(on : int)
	{
		pettingDogType = on;
	}
	
	public function PlaySyncInteractionAnimation()
	{
		if(pettingDogType == 1)
		{
			theGame.GetSyncAnimManager().SetupSimpleSyncAnim2( 'PetDog', thePlayer, objectEntity );
			pettingDogType = 0;
			return;
		}
		if(pettingDogType == 2)
		{
			theGame.GetSyncAnimManager().SetupSimpleSyncAnim2( 'PetDogLie', thePlayer, objectEntity );
			pettingDogType = 0;
			return;
		}
		if(pettingDogType == 3)
		{
			theGame.GetSyncAnimManager().SetupSimpleSyncAnim2( 'PetWildDog', thePlayer, objectEntity );
			pettingDogType = 0;
			return;
		}
		
		switch( switchAnimationType )
		{
			case PSAT_Lever:
			
			if ( switchOn )
				theGame.GetSyncAnimManager().SetupSimpleSyncAnim( 'SwitchLeverOff', thePlayer, objectEntity );
			else
				theGame.GetSyncAnimManager().SetupSimpleSyncAnim( 'SwitchLeverOn', thePlayer, objectEntity );
			break;
				
			case PSAT_Button:	
			
			if ( switchOn )
				theGame.GetSyncAnimManager().SetupSimpleSyncAnim( 'SwitchButtonOff', thePlayer, objectEntity );
			else
				theGame.GetSyncAnimManager().SetupSimpleSyncAnim( 'SwitchButtonOn', thePlayer, objectEntity );
			break;
		}
	}
	
	event OnReactToBeingHit( damageAction : W3DamageAction )
	{
		var ret : bool;
		
		ret = virtual_parent.OnReactToBeingHit( damageAction );
		parent.LockEntryFunction( false );
		StopApproach();
		return ret;
	}
	
	private function SetInteractionComponent( b : bool )
	{
		var component : CComponent;
		
		if ( objectEntity )
			component = objectEntity.GetComponentByClassName( 'CInteractionComponent' );
			
		if ( component )
			component.SetEnabled( b );
	}
	
	
	private function StopApproach()
	{
		parent.PopState(true);		
	}
	
	
	
	
	
	
	timer function InputCheckDelay( timeDelta : float, id : int )
	{
		parent.AddTimer( 'InputCheck', 0.001, true, false, TICK_PrePhysics );
	}
	
	
	timer function InputCheck( timeDelta : float, id : int )
	{
		var action : EActorActionType;
		
		
		if ( parent.GetIsMovable() )
		{
			action = parent.GetCurrentActionType();
			
			if ( action != ActorAction_None )
			{
				if( theInput.GetActionValue( 'GI_AxisLeftX' ) != 0 || theInput.GetActionValue( 'GI_AxisLeftY') != 0 )
				{
					
					parent.LockEntryFunction( false );
					StopApproach();
				}
			}
		}
	}
	
	timer function ApproachTimeout( timeDelta : float, id : int )
	{
		
		PlaySyncInteractionAnimation();
		parent.LockEntryFunction( false );
		StopApproach();
	}
};