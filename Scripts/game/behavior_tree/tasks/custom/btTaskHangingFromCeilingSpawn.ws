/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskHangingFromCeilingSpawn extends CBTTaskPlayAnimationEventDecorator
{
	private var availableOnBehVarName 		: name;
	private var availableOnBehVarValue 		: float;
	private var spawnOnHit 					: bool;
	private var spawnOnDistanceToHostile 	: float;
	private var spawnOnGameplayEventName 	: name;
	private var spawnOnAnimEventName 		: name;
	private var traceToCeiling 				: bool;
	private var verticalAdjustment 			: bool;
	private var horizontalAdjustment 		: bool;
	private var manageGravity 				: bool;
	private var manageCollision 			: bool;
	private var reenableCollisionAfter 		: float;
	private var setCustomMovement 			: bool;
	private var raiseEvent 					: name;
	private var timeOfInitialPosCorrection 	: float;
	private var reuseInitialSpawnPosition 	: bool;
	
	
	private var activated 					: bool;
	private var raisedEvent 				: bool;
	private var slideEventReceived 			: bool;
	private var actorPos 					: Vector;
	private var initialPos 					: Vector;
	private var animInfoCache 				: SAnimationEventAnimInfo;
	private var collisionGroups 			: array<name>;
	
	
	function Initialize()
	{
		collisionGroups.PushBack('Terrain');
		collisionGroups.PushBack('Static');
		collisionGroups.PushBack('Destructible');
	}
	
	function IsAvailable() 	: bool
	{
		if ( IsNameValid( availableOnBehVarName ) )
		{
			if ( availableOnBehVarValue == GetActor().GetBehaviorVariable( availableOnBehVarName ) )
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else
		{
			return true;
		}
		
		return super.IsAvailable();
	}
	
	function OnActivate() : EBTNodeStatus
	{
		activated = false;
		raisedEvent= false;
		slideEventReceived = false;
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var actor 				: CActor = GetActor();
		var normal 				: Vector;
		var testInt 			: int;
		var heading 			: float;
		var ticketS, ticketR 	: SMovementAdjustmentRequestTicket;
		var movementAdjustor	: CMovementAdjustor;
		var entities 			: array<CGameplayEntity>;
		var timeStamp 			: float;
		
		
		if ( manageGravity )
		{
			SwitchGravity( false );
		}
		if ( manageCollision )
		{
			actor.EnableCharacterCollisions( false );
			actor.EnableCollisions( false );
		}
		
		if ( traceToCeiling )
		{
			if ( reuseInitialSpawnPosition && initialPos != Vector( 0,0,0 ) )
			{
				actorPos = initialPos;
				actor.TeleportWithRotation( actorPos, actor.GetWorldRotation() );
			}
			else
			{
				actorPos = actor.GetWorldPosition();
				theGame.GetWorld().StaticTrace( actorPos + Vector(0,0,3.0), actorPos + Vector(0,0,50), actorPos, normal, collisionGroups );
				
				actor.TeleportWithRotation( actorPos, actor.GetWorldRotation() );
				initialPos = actorPos;
			}
		}
		
		while ( !activated )
		{
			if ( spawnOnDistanceToHostile > 0 )
			{
				FindGameplayEntitiesInRange( entities, actor, spawnOnDistanceToHostile, 999, , FLAG_OnlyAliveActors | FLAG_Attitude_Hostile, actor );
				if ( entities.Size() > 0 )
				{
					activated = true;
				}
			}
			SleepOneFrame();
		}
		
		if ( verticalAdjustment || horizontalAdjustment )
		{
			
			testInt = 1;
			while ( !NavTest( testInt ) )
			{
				testInt += 1;
				SleepOneFrame();
			}
			
			if ( IsNameValid( raiseEvent ) )
			{
				actor.RaiseEvent( raiseEvent );
				timeStamp = GetLocalTime();
				raisedEvent = true;
				
				if ( timeOfInitialPosCorrection > 0 )
				{
					while ( !slideEventReceived && GetLocalTime() < timeStamp + timeOfInitialPosCorrection )
					{
						actor.TeleportWithRotation( initialPos, actor.GetWorldRotation() );
						SleepOneFrame();
					}
				}
			}
			
			while ( !slideEventReceived )
			{
				SleepOneFrame();
			}
			
			actor.GetVisualDebug().AddSphere( 'SpawnPosition', 0.5, actorPos, true, Color( 0,0,255 ), 5.0f );
			movementAdjustor = GetNPC().GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelByName( 'SlideToTarget' );
			movementAdjustor.CancelByName( 'SpawnSlide' );
			movementAdjustor.CancelByName( 'SpawnRotate' );
			
			ticketS = movementAdjustor.CreateNewRequest( 'SpawnSlide' );
			movementAdjustor.MaxLocationAdjustmentSpeed( ticketS, 9999 );
			movementAdjustor.AdjustLocationVertically( ticketS, verticalAdjustment );
			movementAdjustor.BindToEventAnimInfo( ticketS, animInfoCache );
			movementAdjustor.ScaleAnimation( ticketS );
			movementAdjustor.BlendIn( ticketS, 0.25 );
			movementAdjustor.SlideTo( ticketS, actorPos );
			
			ticketR = movementAdjustor.CreateNewRequest( 'SpawnRotate' );
			if ( useCombatTargetForRotation )
			{
				heading = VecHeading( GetCombatTarget().GetWorldPosition() - actor.GetWorldPosition() );
			}
			else
			{
				heading = VecHeading( GetActionTarget().GetWorldPosition() - actor.GetWorldPosition() );
			}
			movementAdjustor.MaxLocationAdjustmentSpeed( ticketR, 9999 );
			movementAdjustor.BindToEventAnimInfo( ticketR, animInfoCache );
			movementAdjustor.ScaleAnimation( ticketR );
			movementAdjustor.RotateTo( ticketR, heading );
			
			if ( manageCollision && reenableCollisionAfter > 0 )
			{
				Sleep( reenableCollisionAfter );
				actor.EnableCharacterCollisions( true );
				actor.EnableCollisions( true );
			}
		}
		else if ( IsNameValid( raiseEvent ) )
		{
			actor.RaiseEvent( raiseEvent );
			timeStamp = GetLocalTime();
			raisedEvent = true;
			
			if ( timeOfInitialPosCorrection > 0 )
			{
				while ( GetLocalTime() < timeStamp + timeOfInitialPosCorrection )
				{
					actor.TeleportWithRotation( initialPos, actor.GetWorldRotation() );
					SleepOneFrame();
				}
			}
		}
		
		if ( raisedEvent )
		{
			while( GetLocalTime() < timeStamp + 5.0f )
			{
				SleepOneFrame();
			}
		}
		
		return BTNS_Completed;
	}

	function OnDeactivate()
	{
		activated = false;
		raisedEvent= false;
		slideEventReceived = false;
		if ( manageGravity )
		{
			SwitchGravity( true );
		}
		if ( manageCollision )
		{
			GetActor().EnableCharacterCollisions( true );
			GetActor().EnableCollisions( true );
		}
		
		super.OnDeactivate();
	}
	
	private final function NavTest( test : int ) : bool
	{
		var actor 		: CActor = GetActor();
		var normal 		: Vector;
		var actorRadius : float;
		var z 			: float;
		
		
		actorPos = actor.GetWorldPosition();
		
		actorRadius = actor.GetRadius();
		theGame.GetWorld().StaticTrace( actorPos - Vector(0,0,3), actorPos - Vector(0,0,50), actorPos, normal, collisionGroups );
		theGame.GetWorld().NavigationComputeZ( actorPos, actorPos.Z - 50, actorPos.Z + 3, z );
		actorPos.Z = z;
		
		if ( !theGame.GetWorld().NavigationFindSafeSpot( actorPos, actorRadius, actorRadius * test, actorPos ) )
		{
			if ( theGame.GetWorld().NavigationComputeZ( actorPos, actorPos.Z - 50, actorPos.Z, z ) )
			{
				actorPos.Z = z;
				if ( !theGame.GetWorld().NavigationFindSafeSpot( actorPos, actorRadius, actorRadius * test, actorPos ) )
				{
					return false;
				}
			}
		}
		return true;
	}
	
	private final function SwitchGravity( on : bool ) 
	{
		var npc 		: CNewNPC = GetNPC();
		var component 	: CMovingPhysicalAgentComponent;
		
		component = ( CMovingPhysicalAgentComponent )npc.GetMovingAgentComponent();
		if( on )
		{
			npc.EnablePhysicalMovement( false );
			if ( setCustomMovement )
			{
				component.SetAnimatedMovement( false );		
			}
			component.SnapToNavigableSpace( true );
			component.SetGravity( true );
		}
		else
		{		
			npc.EnablePhysicalMovement( true );
			if ( setCustomMovement )
			{
				component.SetAnimatedMovement( true );
			}
			component.SnapToNavigableSpace( false );
			component.SetGravity( false );
		}
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( IsNameValid( spawnOnGameplayEventName ) && eventName == spawnOnGameplayEventName )
		{
			activated = true;
			return true;
		}
		else if ( spawnOnHit && ( eventName == 'AardHitReceived' || eventName == 'IgniHitReceived' || eventName == 'AxiiHitReceived' || eventName == 'DamageTaken' ) )
		{
			activated = true;
			return true;
		}
		
		return super.OnGameplayEvent( eventName );
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var actor : CActor;
		
		if ( IsNameValid( spawnOnAnimEventName ) && animEventName == spawnOnAnimEventName )
		{
			activated = true;
			return true;
		}
		else if ( animEventName == 'SlideToTarget' )
		{
			if ( animEventType == AET_DurationEnd )
			{
				actor = GetActor();
				if ( manageGravity )
				{
					SwitchGravity( true );
				}
				if ( manageCollision )
				{
					actor.EnableCharacterCollisions( true );
					actor.EnableCollisions( true );
				}
			}
			animInfoCache = animInfo;
			slideEventReceived = true;
			return true;
		}
		
		return super.OnAnimEvent( animEventName, animEventType ,animInfo );
	}
};

class CBTTaskHangingFromCeilingSpawnDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskHangingFromCeilingSpawn';
	
	editable var availableOnBehVarName 		: name;
	editable var availableOnBehVarValue 	: float;
	editable var spawnOnHit 				: bool;
	editable var spawnOnDistanceToHostile 	: float;
	editable var spawnOnGameplayEventName 	: name;
	editable var spawnOnAnimEventName 		: name;
	editable var traceToCeiling 			: bool;
	editable var verticalAdjustment 		: bool;
	editable var horizontalAdjustment 		: bool;
	editable var manageGravity 				: bool;
	editable var manageCollision 			: bool;
	editable var reenableCollisionAfter 	: float;
	editable var setCustomMovement 			: bool;
	editable var raiseEvent 				: name;
	editable var timeOfInitialPosCorrection : float;
	editable var reuseInitialSpawnPosition 	: bool;
	
	default availableOnBehVarName 			= 'ForcedSpawnAnim';
	default availableOnBehVarValue 			= 3;
	default spawnOnHit 						= true;
	default spawnOnDistanceToHostile 		= 7;
	default manageCollision 				= true;
	default reenableCollisionAfter 			= 0.5;
	default traceToCeiling 					= true;
	default verticalAdjustment 				= true;
	default horizontalAdjustment 			= true;
	default manageGravity 					= true;
	default setCustomMovement 				= true;
	default raiseEvent 						= 'Spawn';
	default reuseInitialSpawnPosition 		= true;
};
