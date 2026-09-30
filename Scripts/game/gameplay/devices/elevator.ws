/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ElevatorMechanism extends CEntity
{
	editable var radius 			: float;
	editable var clockwiseRotation 	: bool;
	
	var rotationSpeed 				: float;
	var forwardDirection 			: bool;
	var transformMatrix 			: Matrix;
	var localRotation 				: EulerAngles;
	
	default clockwiseRotation = true;
	default radius = 1.0;
	
	
	public function SetRotationSpeed( linearSpeed : float )
	{
		rotationSpeed = linearSpeed / radius;
	}
	
	public function StartWorking( forward : bool )
	{
		forwardDirection = forward;
		AddTimer( 'TimerMechanismWorking', 0.01, true, , , true );
	}
	
	timer function TimerMechanismWorking( timeDelta : float , id : int)
	{
		localRotation = this.GetWorldRotation();
		
		if( forwardDirection && !clockwiseRotation || clockwiseRotation && !forwardDirection)
		{
			localRotation.Roll -= rotationSpeed;
		}
		else
		{
			localRotation.Roll += rotationSpeed;
		}
		
		TeleportWithRotation(this.GetWorldPosition(), localRotation);
	}
	
	public function StopWorking()
	{
		RemoveTimer( 'TimerMechanismWorking' );
	}
}

enum EElevatorSwitchType
{
	DownSwitch,
	UpSwitch
};

class W3ElevatorSwitch extends W3InteractionSwitch
{
	editable var elevator 					: EntityHandle;
	public editable var switchType 			: EElevatorSwitchType;	
	private autobind interactionComponent 	: CInteractionComponent = "Unlocked";
	private var switchRegistered			: bool;
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var elevatorInteractive : W3ElevatorInteractive;
		
		super.OnSpawned( spawnData );
		
		switchRegistered = false;
		elevatorInteractive = (W3ElevatorInteractive)EntityHandleGet( elevator );
		
		if( elevatorInteractive )
		{
			if( !elevatorInteractive.activated )
			{
				elevatorInteractive.CheckInitialVariables();
				elevatorInteractive.activated = true;
			}
			
			elevatorInteractive.RegisterSwitch( this );
			SetSwitch(elevatorInteractive);
			switchRegistered = true;
		}
	}
	
	final function SetSwitch( elevator : W3ElevatorInteractive )
	{
		var onTop : bool;
		
		if(elevator && interactionComponent)
		{
			onTop = elevator.IsOnTop();
			if(switchType == DownSwitch)
			{
				if( interactionComponent )
					interactionComponent.SetEnabled( onTop );
			}
			else
			{
				if( interactionComponent )
					interactionComponent.SetEnabled( !onTop );
			}
		}
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		var elevatorInteractive : W3ElevatorInteractive;
		
		if( activator == thePlayer )
		{
			if( actionName == "UseDevice" )
			{
				elevatorInteractive = (W3ElevatorInteractive)EntityHandleGet( elevator );
				if( !elevatorInteractive.activated )
				{
					elevatorInteractive.CheckInitialVariables();
					elevatorInteractive.activated = true;
				}
				
				super.OnInteraction( actionName, activator );
			}
		}
	}
	
	event OnSyncAnimEnd()
	{
		var elevatorInteractive : W3ElevatorInteractive;
		
		elevatorInteractive = (W3ElevatorInteractive)EntityHandleGet( elevator );
		elevatorInteractive.GotoState( 'Moving' );
		
		super.OnSyncAnimEnd();
	}
	
	event OnInteractionActivationTest( interactionComponentName : string, activator : CEntity )
	{
		if ( thePlayer.IsCombatMusicEnabled() )
		{
			return false;
		}
		
		return super.OnInteractionActivationTest( interactionComponentName, activator );
	}
	
	public final function SetICEnabled( enabled : bool )
	{
		if( interactionComponent )
		{
			interactionComponent.SetEnabled( enabled );
		}
	}
}

class W3ElevatorInteractive extends W3Elevator
{
	editable var initialPosOnTop 			: bool;
	editable var targetObject 				: EntityHandle;
	editable var maxHeight 					: float;
	editable var mechanismEntityHandle 		: EntityHandle;
	
	private autobind interactionComponent 	: CInteractionComponent = "Unlocked";
	
	var activated 							: bool;
	var explorationComponents 				: array<CComponent>;
	var switches 							: array<W3ElevatorSwitch>;
	var i, size 							: int;
	var elevatorSaveLockInt 				: int;
	
	default maxHeight = 5;
	
	public final function RegisterSwitch( elevatorSwitch : W3ElevatorSwitch )
	{
		if( elevatorSwitch && !switches.Contains(elevatorSwitch))
		{
			switches.PushBack( elevatorSwitch );
		}
	}
	
	final function DisableSwitches()
	{
		var i, size : int;
		
		size = switches.Size();
		
		for(i = 0; i < size; i += 1)
		{
			if( switches[i] )
			{
				switches[i].SetICEnabled( false );
			}
		}
	}
	
	final function EnableOrDisableSwitches( onTop : bool )
	{
		var i, size : int;
		
		size = switches.Size();
		
		for(i = 0; i < size; i += 1)
		{
			if( switches[i] )
			{
				if(switches[i].switchType == DownSwitch)
				{
					switches[i].SetICEnabled( isOnTop );
				}
				else
				{
					switches[i].SetICEnabled( !isOnTop );
				}
			}
		}	
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		if ( explorationComponents.Size() == 0 )
		{
			explorationComponents = GetComponentsByClassName( 'CExplorationComponent' );
		}
		
		if( activator == thePlayer )
		{
			if( actionName == "UseDevice" )
			{
				if ( !activated )
				{
					this.CheckInitialVariables();
					activated = true;
				}
				
				theGame.CreateNoSaveLock( "moving_elevator", elevatorSaveLockInt );
				this.GotoState( 'Moving' );
			}
		}
	}
	
	final function OnEndMovement()
	{
		var mechanism : W3ElevatorMechanism;
		
		if( movementStarted )
		{
			movementStarted = false;
			
			mechanism = (W3ElevatorMechanism)EntityHandleGet( mechanismEntityHandle );			
			if( mechanism )
			{
				mechanism.SetRotationSpeed( 0 );
				mechanism.StopWorking();
				mechanism.SoundEvent( "global_machines_lift_wood1_mechanism_stop" );
			}
			
			SoundEvent( "global_machines_lift_wood1_platform_stop" );
			
			
			
			GCameraShake(0.1, this, this.GetWorldPosition(), 6.0);
		}
		
		if( interactionComponent ) 
		{
			interactionComponent.SetEnabled( true );
		}
		
		size = explorationComponents.Size();
		
		if( isOnTop )
		{
			ApplyAppearance( appearanceOnTop );
		}
		
		for( i = 0; i < size; i += 1 )
		{
			explorationComponents[i].SetEnabled( true );
		}
		
		EnableOrDisableSwitches( isOnTop );
		theGame.ReleaseNoSaveLock( elevatorSaveLockInt );
		
		super.OnEndMovement();
	}
	
	final function OnStartMovement()
	{
		var mechanism : W3ElevatorMechanism;
		
		DisableSwitches();
		
		mechanism = (W3ElevatorMechanism)EntityHandleGet( mechanismEntityHandle );
		if( mechanism )
		{
			mechanism.SetRotationSpeed( speed );
			mechanism.StartWorking( !isOnTop );
			mechanism.SoundEvent( "global_machines_lift_wood1_mechanism_start" );
		}
		
		GCameraShake(0.1, true, this.GetWorldPosition(), 6.0);
		
		
		SoundEvent( "global_machines_lift_wood1_platform_start" );
		ApplyAppearance( appearanceOnGround );
		
		if( interactionComponent ) 
		{
			interactionComponent.SetEnabled( false );
		}
		
		size = explorationComponents.Size();
		
		for( i = 0; i < size; i += 1 )
		{
			explorationComponents[i].SetEnabled( false );
		}
		movementStarted = true;
		super.OnStartMovement();
	}
	
	function CheckInitialVariables()
	{
		var targetNode 				: CNode;
		var targetPos 				: Vector;
		var currentHeightDifference : float;
		
		pos = GetWorldPosition();
		if ( currentHeight != 0 )
		{
			pos.Z = currentHeight;
			Teleport( pos );
		}
		else
		{
			initialHeight = pos.Z;
		}
		
		targetNode = (CNode)EntityHandleGet( targetObject );
		
		if( targetNode )
		{
			targetPos = targetNode.GetWorldPosition();
			targetNodeHeight = targetPos.Z;
			heightDifference = targetNodeHeight - initialHeight;
			currentHeightDifference = targetNodeHeight - pos.Z;
		}
		else
		{
			heightDifference = maxHeight;
		}
		
		
		
		
		if( currentHeightDifference > -2 ) 
		{
			ApplyAppearance( appearanceOnGround );
			goingUp = true;
			initialSpeed = speed;
			isOnTop = false;
		}
		else
		{
			ApplyAppearance( appearanceOnTop );
			goingUp = false;
			initialSpeed = speed * -1;
			isOnTop = true;
		}
		
		if ( isOnTop && !onTopPosChecked )
		{
			onTopPos = GetWorldPosition();
			onTopPosChecked = true;
		}
		
		this.GotoState( 'OnStartPos' );
	}
	
	event OnInteractionActivationTest( interactionComponentName : string, activator : CEntity )
	{
		if ( thePlayer.IsCombatMusicEnabled() )
		{
			return false;
		}
		
		if( activator == thePlayer )
		{
			if( interactionComponent.IsEnabled() )
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
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
		
		actor = (CActor)activator.GetEntity();
		if((CPlayer)actor)
		{
			playerOnElevator = true;
		}	
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
		
		actor = (CActor)activator.GetEntity();
		if((CPlayer)actor)
		{
			playerOnElevator = false;
		}	
	}
	
	event OnPhantomComponentCollision( object : CObject, physicalActorindex : int, shapeIndex : int   )
	{
		var entity 		: CEntity;
		var component 	: CComponent;
		var action 		: W3DamageAction;
		
		component = (CComponent) object;
		if( !component )
		{
			return false;
		}
		
		entity = component.GetEntity();
		if ( (CPlayer)entity && currentSpeed < 0 )
		{
			action = new W3DamageAction in this;
			
			action.Initialize( this, (CPlayer)entity, this, this.GetName(), EHRT_Light, CPS_AttackPower, false, false, false, true);
			action.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, ((CPlayer)entity).GetStat( BCS_Vitality ) + 1 );
			theGame.damageMgr.ProcessAction( action );
		}
	}
}

statemachine class W3Elevator extends CGameplayEntity
{
	editable var appearanceOnTop 		: string;
	editable var appearanceOnGround 	: string;
	editable var speed 					: float;
	
	saved var currentHeight 			: float;
	saved var targetNodeHeight			: float;
	saved var currentSpeed 				: float;
	saved var initialSpeed 				: float;
	saved var isOnTop 					: bool;
	saved var movementStarted 			: bool;
	saved var onTopPosChecked			: bool;
	
	saved var initialHeight 			: float;
	saved var pos 						: Vector;
	saved var onTopPos					: Vector;
	
	
	var heightDifference 				: float;
	var goingUp 						: bool;
	var playerOnElevator				: bool;
	var playerAttached					: bool;
	var deniedAreaCreated				: bool;
	
	var blockedActions					: array<EInputActionBlock>;
	var entityTemplate 					: CEntityTemplate;
	var deniedArea1, deniedArea2, deniedArea3	: CEntity;
	
	default currentHeight 				= 0.f;
	default initialHeight 				= 0.f;
	default speed 						= 1.f;
	default currentSpeed 				= 0.f;
	
	hint targetObject = "The object on level to which height elevator can travel (both up and down)";
	hint maxHeight = "How high the elevator can go up (used only if no targetObject is specified)";
	hint speed = "Speed in m/s";
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		pos = GetWorldPosition();
		if ( currentHeight != 0 )
		{
			pos.Z = currentHeight;
			Teleport( pos );
		}
		
		blockedActions.PushBack(EIAB_CallHorse);
		blockedActions.PushBack(EIAB_Movement);
		blockedActions.PushBack(EIAB_Fists);
		blockedActions.PushBack(EIAB_Jump);
		blockedActions.PushBack(EIAB_RunAndSprint);
		blockedActions.PushBack(EIAB_UsableItem);
		blockedActions.PushBack(EIAB_Dodge);
		blockedActions.PushBack(EIAB_Roll);
		blockedActions.PushBack(EIAB_SwordAttack);
		blockedActions.PushBack(EIAB_Sprint);
		blockedActions.PushBack(EIAB_Explorations);
		blockedActions.PushBack(EIAB_Counter);
		blockedActions.PushBack(EIAB_LightAttacks);
		blockedActions.PushBack(EIAB_HeavyAttacks);
		blockedActions.PushBack(EIAB_SpecialAttackLight);
		blockedActions.PushBack(EIAB_SpecialAttackHeavy);
		blockedActions.PushBack(EIAB_MeditationWaiting);
	}
	
	public latent function ProcessAttachement()
	{
		var entMatrix 			: Matrix;
		var createEntityHelper	: CCreateEntityHelper;
		var offsetPos			: Vector;
		
		if ( !entityTemplate )
		{
			entityTemplate = ( CEntityTemplate ) LoadResourceAsync( "denied_area" );
		}
		
		if ( playerOnElevator && thePlayer.IsAlive() )
		{
			if ( !playerAttached )
			{
				
				if ( currentSpeed < 0 )
				{
					this.CalcEntitySlotMatrix( 'goDownSlot', entMatrix );
					thePlayer.GetMovingAgentComponent().SetAdditionalOffsetToConsumePointWS( entMatrix, 0.6f );
					thePlayer.CreateAttachment( this, 'goDownSlot' );
				}
				else
				{
					this.CalcEntitySlotMatrix( 'goUpSlot', entMatrix );
					thePlayer.GetMovingAgentComponent().SetAdditionalOffsetToConsumePointWS( entMatrix, 0.6f );
					thePlayer.CreateAttachment( this, 'goUpSlot' );
				}
				
				thePlayer.GetMovingAgentComponent().SetEnabledFeetIK( false );
				BlockActions( true );
				playerAttached = true;
			}
			if ( deniedAreaCreated )
			{
				deniedArea1.Destroy();
				deniedArea2.Destroy();
				deniedArea3.Destroy();
				deniedAreaCreated = false;
			}
		}
		else
		{
			if ( playerAttached )
			{
				thePlayer.BreakAttachment();
				thePlayer.GetMovingAgentComponent().SetEnabledFeetIK( true );
				BlockActions( false );
				playerAttached = false;
			}
			if ( isOnTop && !deniedAreaCreated )
			{
				if ( !createEntityHelper )
				{
					createEntityHelper = new CCreateEntityHelper in this;
				}
				theGame.CreateEntityAsync( createEntityHelper, entityTemplate, onTopPos, this.GetWorldRotation() );
				while ( createEntityHelper.IsCreating() )
				{
					SleepOneFrame();
				}
				deniedArea1 = createEntityHelper.GetCreatedEntity();
				
				offsetPos = onTopPos;
				offsetPos.Z += 2.5f;
				theGame.CreateEntityAsync( createEntityHelper, entityTemplate, offsetPos, this.GetWorldRotation() );
				while ( createEntityHelper.IsCreating() )
				{
					SleepOneFrame();
				}
				deniedArea2 = createEntityHelper.GetCreatedEntity();
				offsetPos.Z += 2.f;
				theGame.CreateEntityAsync( createEntityHelper, entityTemplate, offsetPos, this.GetWorldRotation() );
				while ( createEntityHelper.IsCreating() )
				{
					SleepOneFrame();
				}
				deniedArea3 = createEntityHelper.GetCreatedEntity();
				deniedArea1.RemoveTag( 'climb' );
				deniedArea1.AddTag( 'no_climb' );
				deniedArea2.RemoveTag( 'climb' );
				deniedArea2.AddTag( 'no_climb' );
				deniedArea3.RemoveTag( 'climb' );
				deniedArea3.AddTag( 'no_climb' );
				
				deniedAreaCreated = true;
			}
		}
	}
	
	public function BlockActions( block : bool )
	{
		var i : int;
		
		if ( blockedActions.Size() > 0 )
		{
			for ( i = 0 ; i < blockedActions.Size() ; i += 1 )
			{
				if ( block )
				{
					thePlayer.BlockAction( blockedActions[i], 'Elevator' );
				}
				else
				{
					thePlayer.UnblockAction( blockedActions[i], 'Elevator' );
				}
			}
		}
	}
	
	public function IsOnTop() : bool
	{
		return isOnTop;
	}
	
	function OnEndMovement()
	{
		if ( playerAttached )
		{
			thePlayer.BreakAttachment();
			thePlayer.GetMovingAgentComponent().SetEnabledFeetIK( true );
			BlockActions( false );
			playerAttached = false;
		}
		if ( isOnTop && deniedAreaCreated )
		{
			deniedArea1.Destroy();
			deniedArea2.Destroy();
			deniedArea3.Destroy();
			deniedAreaCreated = false;
		}
		
		Log("ended");
	}
	function OnStartMovement()
	{
		Log("started");
	}
};


state OnStartPos in W3Elevator
{
	event OnEnterState( prevStateName : name )
	{
		parent.RemoveTimer( 'MovingLoop' );
		super.OnEnterState( prevStateName );
		OnStartPosInit();
	}
	
	entry function OnStartPosInit()
	{
		parent.pos = parent.GetWorldPosition();
		if ( parent.currentHeight == 0 )
		{
			parent.currentHeight = parent.initialHeight;
		}
		parent.pos.Z = parent.currentHeight;
		parent.currentSpeed = 0.f;
		parent.Teleport( parent.pos );
		virtual_parent.OnEndMovement();
	}
}

state OnEndPos in W3Elevator
{
	event OnEnterState( prevStateName : name )
	{
		parent.RemoveTimer( 'MovingLoop' );
		super.OnEnterState( prevStateName );
		OnEndPosInit();
	}
	
	entry function OnEndPosInit()
	{
		parent.pos = parent.GetWorldPosition();
		if ( parent.currentHeight == 0 )
		{
			parent.currentHeight = parent.initialHeight;
		}
		parent.pos.Z = parent.currentHeight;
		parent.currentSpeed = 0.f;
		parent.Teleport( parent.pos );
		virtual_parent.OnEndMovement();
	}
}

state Moving in W3Elevator
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		if ( prevStateName == 'OnStartPos' )
		{
			parent.currentSpeed = parent.initialSpeed * 1.f;
		}
		else if ( prevStateName == 'OnEndPos' )
		{
			parent.currentSpeed = parent.initialSpeed * -1.f;
		}
		MovingInit();
	}
	
	entry function MovingInit()
	{
		virtual_parent.OnStartMovement();
		parent.ProcessAttachement();
		parent.AddTimer( 'MovingLoop', 0.01f, true, false, TICK_PrePhysics, true );
	}
	
	timer function MovingLoop( timeDelta : float , id : int)
	{
		parent.pos = parent.GetWorldPosition();
		parent.currentHeight += ( parent.currentSpeed * timeDelta );
		parent.pos.Z = parent.currentHeight;
		
		if( parent.goingUp )
		{
			if ( parent.pos.Z >= parent.initialHeight && parent.currentSpeed > 0 )
			{
				parent.isOnTop = true;
				if ( parent.isOnTop && !parent.onTopPosChecked )
				{
					parent.onTopPos = parent.GetWorldPosition();
					parent.onTopPosChecked = true;
				}
				parent.GotoState( 'OnEndPos' );
				return;
			}
			else if ( parent.pos.Z <= parent.targetNodeHeight && parent.currentSpeed < 0 )
			{
				parent.isOnTop = false;
				parent.GotoState( 'OnStartPos' );
				return;
			}
		}
		else
		{
			if ( parent.pos.Z <= parent.targetNodeHeight && parent.currentSpeed < 0 )
			{
				parent.isOnTop = false;
				parent.GotoState( 'OnEndPos' );
				return;
			}
			else if ( parent.pos.Z >= parent.initialHeight && parent.currentSpeed > 0 )
			{
				parent.isOnTop = true;
				if ( parent.isOnTop && !parent.onTopPosChecked )
				{
					parent.onTopPos = parent.GetWorldPosition();
					parent.onTopPosChecked = true;
				}
				parent.GotoState( 'OnStartPos' );
				return;
			}
		}
		
		parent.Teleport( parent.pos );
	}
}