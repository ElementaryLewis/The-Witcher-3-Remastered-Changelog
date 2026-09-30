/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EAimType
{
	AT_Bolt,
	AT_Bomb,
}

statemachine class PlayerAiming
{
	protected var owner			: CR4Player;
	protected var throwable		: CThrowable;
	protected var aimType		: EAimType;
	protected var throwPos		: Vector;
	protected var sweptFriendly	: CEntity;
	protected var sweptActors 	: array<CActor>;
	protected var tracePosFrom 	: Vector;
	public var thrownBombImpactRadius : float;
	protected var aimedTarget 	: CActor;
	
	protected var collisionGroupsNames 	: array<name>;			
	
	public function Initialize( p : CR4Player )
	{
		owner = p;
		
		
		collisionGroupsNames.PushBack( 'RigidBody' );
		collisionGroupsNames.PushBack( 'Character' );		
		collisionGroupsNames.PushBack( 'Static' );
		collisionGroupsNames.PushBack( 'Debris' );	
		collisionGroupsNames.PushBack( 'Ragdoll' );
		collisionGroupsNames.PushBack( 'Destructible' );	
		collisionGroupsNames.PushBack( 'Terrain' );
		collisionGroupsNames.PushBack( 'Phantom' );		
		collisionGroupsNames.PushBack( 'Dangles' );
		collisionGroupsNames.PushBack( 'Weapon' );	
		collisionGroupsNames.PushBack( 'Water' );
		collisionGroupsNames.PushBack( 'Foliage' );	
		collisionGroupsNames.PushBack( 'CommunityCollidables' );
		collisionGroupsNames.PushBack( 'Boat' );		
		collisionGroupsNames.PushBack( 'Door' );
		collisionGroupsNames.PushBack( 'Platforms' );	
		collisionGroupsNames.PushBack( 'Corpse' );			
		
		theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_ThrowingAim) );
		
		GotoState( 'Waiting' );
	}
	
	public function StartAiming( t : CThrowable )
	{
		var bomb : W3Petard;
		
		bomb = (W3Petard)t;
		if(bomb)
		{
			thrownBombImpactRadius = bomb.GetImpactRange();
			
			
			if(thrownBombImpactRadius == 0)
			{
				thrownBombImpactRadius = bomb.GetAoERange();
			}
		}
		else
		{
			thrownBombImpactRadius = 0;
		}
		
		OnStartAiming( t );
	}
	
	public function StopAiming()
	{
		OnStopAiming();
	}
	
	public function RemoveAimingSloMo()
	{
		OnRemoveAimingSloMo();
	}
	
	public function GetThrowPosition() : Vector
	{
		return throwPos;
	}

	public function GetSweptFriendly() : CEntity
	{
		return sweptFriendly;
	}
	
	public function GetSweptActors() : array<CActor>
	{
		return sweptActors;
	}
	
	public function GetThrowStartPosition() : Vector
	{
		return tracePosFrom;
	}	
	
	public function GetAimedTarget() : CActor
	{
		return aimedTarget;
	}		

	event OnStartAiming( t : CThrowable ){}
	event OnStopAiming(){}
	event OnAddAimingSloMo(){}
	event OnRemoveAimingSloMo(){}
}

state Waiting in PlayerAiming
{
	event OnStartAiming( t : CThrowable )
	{
		parent.throwable = t;
		
		if ( (W3BoltProjectile)( parent.throwable ) )
			parent.aimType = AT_Bolt;
		else
			parent.aimType = AT_Bomb;
			
		parent.GotoState( 'Aiming' );
	}
}

state Aiming in PlayerAiming
{
	protected const var SLOWMO_SPEED : float;
	private var AIM_ENTITY_DISPLACEMENT : float;			
	
	default SLOWMO_SPEED = 0.6;
	default AIM_ENTITY_DISPLACEMENT = 0.035f;	

	var aimEntity 				: CEntity;	
	var radiusEntity			: CEntity;	
	var stopAiming 				: bool;
	var startTime				: float;
	var traceManager 			: CScriptBatchQueryAccessor;

	event OnEnterState( prevStateName : name )
	{	
		stopAiming = false;
		traceManager = theGame.GetWorld().GetTraceManager();
	
		if ( parent.owner )
		{		
			parent.owner.HardLockToTarget( false );

			if ( parent.aimType == AT_Bolt )
			{
				ShowCrosshair(true);
			}
			else if ( parent.aimType == AT_Bomb )
			{


				
				
				
					ShowCrosshair( true );


				
			}
			
			startTime = theGame.GetEngineTimeAsSeconds();
			Aim();
		}		
	}
	
	function ShowCrosshair( value : bool )
	{
		var hud : CR4ScriptedHud;
		var module : CR4HudModuleCrosshair;
		var moduleItemInfo : CR4HudModuleItemInfo;

		hud = (CR4ScriptedHud)theGame.GetHud();
		module = (CR4HudModuleCrosshair)hud.GetHudModule("CrosshairModule");
		moduleItemInfo = (CR4HudModuleItemInfo)hud.GetHudModule("ItemInfoModule");
		module.ShowElement( value, false );
		moduleItemInfo.ShowElementIgnoreState(value,false);
	}	
	
	entry function Aim()
	{
		parent.SetCleanupFunction( 'AimCleanup' );	
		
		while( true )
		{
			if ( parent.aimType == AT_Bolt )
				UpdateThrowPositionBolt();
			else
			{
				UpdateThrowPosition();
			}
			
			SetRadiusEntityScale();
		
			Sleep( 0.0001f );
			
			if( theGame.GetEngineTimeAsSeconds() >= startTime + 0.5 )
				break;
		}
		
		SloMo();
		
		while( !stopAiming )
		{
			if ( parent.aimType == AT_Bolt )
				UpdateThrowPositionBolt();
			else
			{
				UpdateThrowPosition();
			}
			
			SetRadiusEntityScale();
		
			Sleep( 0.0001f );
		}

		AimCleanup();
		parent.ClearCleanupFunction();
		parent.GotoState( 'Waiting' );
	}

	event OnStopAiming()
	{
		stopAiming = true;
	}
	
	event OnRemoveAimingSloMo()
	{
		RemoveSloMo();
	}
	
	var cachedCamDirection 	: Vector;
	var cachedCamPosition	: Vector;
	var cachedOwnerPosition	: Vector;
	var sweepId				: SScriptSweepId;

	function UpdateThrowPositionBolt()
	{
		var camToPlayerVector 		: Vector;
		var camToCamPlayerAngleDiff	: float;
		var camToTracePosFromDist	: float;
		var throwPosNormal 			: Vector;

		var camera 					: CCustomCamera;

		var maxRangePos				: Vector;
		var actor					: CActor;
		var i, size					: int;
		var batchQueryState			: EBatchQueryState;
		var hasResult				: bool;
		var traceResultDists		: array<float>;
		
		var tracePosFromInitial		: Vector;
		var aimDisplacementVec		: Vector;

		var rayCastResult 			: SRaycastHitResult;
		var rayCastResults 			: array<SRaycastHitResult>;	
		
		var tempSweptFriendly		: CEntity;
		var aimEnt					: CEntity;
		var aimActor				: CActor;
		
		if ( thePlayer.rangedWeapon.GetCurrentStateName() != 'State_WeaponShoot' )
		{
			cachedCamDirection = theCamera.GetCameraDirection();
			cachedCamPosition = theCamera.GetCameraPosition();
			cachedOwnerPosition = parent.owner.GetWorldPosition();
		}
			
		if ( parent.owner.IsUsingVehicle() )
			tracePosFromInitial = 2.7f * VecNormalize( cachedCamDirection ) + cachedCamPosition;
		else
			tracePosFromInitial = 0.5f * VecNormalize( cachedCamDirection ) + cachedCamPosition;
			
		maxRangePos = VecNormalize( cachedCamDirection ) * theGame.params.MAX_THROW_RANGE + tracePosFromInitial;
		
		parent.owner.GetVisualDebug().AddSphere( 'UpdateThrowPositionBolt_Start', 0.1f, tracePosFromInitial, true, Color( 100, 100, 100 ), 0.2f );
		parent.owner.GetVisualDebug().AddSphere( 'UpdateThrowPositionBolt', 0.1f, parent.throwPos, true, Color( 100, 0, 100 ), 0.2f );
		
		
		FindActorsAtLine( tracePosFromInitial, maxRangePos, 0.2f, rayCastResults, parent.collisionGroupsNames );
		size = rayCastResults.Size();

		for ( i = 0; i < size; i += 1 )
		{
			if ( !rayCastResults[i].component || ShouldExcludeFromFriendlySweep( rayCastResults[i].component.GetEntity() ) )
			{
				rayCastResults.Erase(i);
				i -= 1;
				size -= 1;
			}
			else
				traceResultDists.PushBack( rayCastResults[i].distance );
		}
		
		size =  rayCastResults.Size();
		if ( size > 0 )
		{		 
			rayCastResult = rayCastResults[ ArrayFindMinF( traceResultDists ) ];
			hasResult = true;
		}
		
		if  ( hasResult )
		{
			if ( rayCastResult.component )
				tempSweptFriendly = rayCastResult.component.GetEntity();
			else
				tempSweptFriendly = NULL;	
		}
		else
			tempSweptFriendly = NULL;				
		
		
		CalculateAimPosition( tracePosFromInitial, maxRangePos, throwPosInitial, throwPosNormal, aimEnt );
		
		aimActor = (CActor)aimEnt;
		if ( parent.owner.IsCombatMusicEnabled() )
		{
			if ( aimActor && parent.owner.IsThreat( aimActor ) )
				parent.aimedTarget = aimActor;
			else
				parent.aimedTarget = NULL;
		}
		else if ( aimActor )
			parent.aimedTarget = aimActor;
		else
			parent.aimedTarget = NULL;
		
		parent.tracePosFrom = parent.owner.GetWorldPosition();
		
		if ( parent.owner.IsUsingHorse() )
			parent.tracePosFrom.Z += 3.1;
		else
			parent.tracePosFrom.Z += 1.6f; 
		
		
		CalculateAimPosition( parent.tracePosFrom, throwPosInitial, parent.throwPos, throwPosNormal, aimEnt );
		
		if ( !tempSweptFriendly )
		{
			if ( aimEnt && !ShouldExcludeFromFriendlySweep( aimEnt ) )
				parent.sweptFriendly = aimEnt;
			else
				parent.sweptFriendly = NULL;
		}
		else
			parent.sweptFriendly = tempSweptFriendly;
	}
	
	function ShouldExcludeFromFriendlySweep( ent : CEntity ) : bool
	{
		var b 			: bool;
		var actor 		: CActor;
		var parentEnt	: CEntity;
		
		if ( !ent )
			return true;
		
		parentEnt = ( (CItemEntity)ent ).GetParentEntity();
		
		if ( parentEnt && parentEnt != parent.owner )
			ent = parentEnt;
		
		actor = (CActor)ent;
		
		
		b = ( actor && actor != parent.owner && actor.IsHuman() && actor.IsAlive() && !parent.owner.IsThreat( actor ) );
		b = b || ( ent && ent == parent.owner.GetUsedVehicle() );

		return !b;
	}	

	var throwPosInitial	: Vector;
	function UpdateThrowPosition()
	{
		var petard			: W3Petard;
		
		var actor					: CActor;
		var i, size					: int;
		var batchQueryState			: EBatchQueryState;
		var hasResult				: bool;
		var traceResultDists		: array<float>;
		var ent						: CEntity;
	
		var playerPosNoFailsafe, maxRangePos, cameraDir, throwPosNormal : Vector;
		
		var camToPlayerVector		: Vector;
		var camToPlayerAngleDiff	: float;
		var camToPlayerAdjacentDist	: float;
		var camHeading				: float;
		
		var rayCastResult 			: SRaycastHitResult;
		var rayCastResults 			: array<SRaycastHitResult>;

		var tracePosFromInitial		: Vector;
		var aimDisplacementVec		: Vector;
		var aimEnt					: CEntity;
		var aimActor				: CActor;
	
		playerPosNoFailsafe = parent.owner.GetWorldPosition();
		playerPosNoFailsafe.Z += 2.0f;
		
		cameraDir = theCamera.GetCameraDirection();
		cameraDir.Z = 0.f;
		
		
		
		
		
		camHeading = VecHeading( theCamera.GetCameraDirection() );
		camToPlayerVector = parent.owner.GetWorldPosition() - theCamera.GetCameraPosition();
		camToPlayerAngleDiff = AngleDistance( camHeading, VecHeading( camToPlayerVector ) );
		camToPlayerAdjacentDist = CosF( Deg2Rad ( camToPlayerAngleDiff ) ) * VecLength( camToPlayerVector );		
		tracePosFromInitial = camToPlayerAdjacentDist * VecNormalize( theCamera.GetCameraDirection() ) +  theCamera.GetCameraPosition();	
		maxRangePos = VecNormalize( theCamera.GetCameraDirection() ) * theGame.params.MAX_THROW_RANGE + tracePosFromInitial;		

		
		CalculateAimPosition( tracePosFromInitial, maxRangePos, throwPosInitial, throwPosNormal, aimEnt );
		
		parent.tracePosFrom = parent.owner.GetWorldPosition();
		
		if ( parent.owner.IsUsingHorse() )
			parent.tracePosFrom.Z += 3.1f;
		else
			parent.tracePosFrom.Z += 1.6f; 
		
		
		CalculateAimPosition( parent.tracePosFrom, throwPosInitial, parent.throwPos, throwPosNormal, aimEnt );
		
		aimActor = (CActor)aimEnt;
		if ( parent.owner.IsCombatMusicEnabled() )
		{
			if ( aimActor && parent.owner.IsThreat( aimActor ) )
				parent.aimedTarget = aimActor;
			else
				parent.aimedTarget = NULL;
		}
		else if ( aimActor )
			parent.aimedTarget = aimActor;
		else
			parent.aimedTarget = NULL;
	
		
		
		parent.owner.GetVisualDebug().AddSphere( 'UpdateThrowPosition2', 0.1f, parent.throwPos, true, Color( 100, 0, 100 ), 0.2f );

		aimEntity.TeleportWithRotation( parent.throwPos + throwPosNormal * AIM_ENTITY_DISPLACEMENT, parent.owner.GetWorldRotation() );	
		
		if(radiusEntity)
		{
			radiusEntity.TeleportWithRotation(parent.throwPos, parent.owner.GetWorldRotation() );
		}
		
		
		petard = (W3Petard)( parent.owner.GetThrownEntity() );

		FindActorsAtLine( parent.throwPos + Vector(0, 0, 5), parent.throwPos + Vector(0, 0, -5), petard.GetImpactRange(), rayCastResults, parent.collisionGroupsNames );
		size =  rayCastResults.Size();
		parent.sweptActors.Clear();
		
		if ( size > 0 )
		{
			for ( i = 0; i < rayCastResults.Size(); i += 1 )
			{
				ent = rayCastResults[i].component.GetEntity();
				actor = (CActor)( rayCastResults[i].component.GetEntity() );
				if ( actor && !parent.sweptActors.Contains( actor ) )
				{
					parent.sweptActors.PushBack( actor );
				}
				if ( ( ( !actor || !actor.IsHuman() ) && ent != parent.owner.GetUsedVehicle() )
					|| parent.owner.IsThreat( actor ) 
					|| actor == parent.owner 
					|| ent == parent.owner.rangedWeapon )
				{
					rayCastResults.Erase(i);
					i -= 1;
				}
				else
					traceResultDists.PushBack( rayCastResults[i].distance );
			}
		}
		
		size =  rayCastResults.Size();
		if ( size > 0 )
		{		 
			rayCastResult = rayCastResults[ ArrayFindMinF( traceResultDists ) ];
			hasResult = true;
		}
		
		if  ( hasResult )
		{
			if ( rayCastResult.component )
				parent.sweptFriendly = rayCastResult.component.GetEntity();
			else
				parent.sweptFriendly = NULL;	
		}
		else
			parent.sweptFriendly = NULL;				
	}
	
	private function CalculateAimPosition( rayCastStartPos, rayCastEndPos : Vector, out aimPos : Vector, out aimPosNormal : Vector, out aimEnt : CEntity  )
	{
		var i, size					: int;
		var hasResult				: bool;
		var traceResultDists		: array<float>;
		var rayCastResult 			: SRaycastHitResult;
		var rayCastResults 			: array<SRaycastHitResult>;	
		var ent						: CEntity;
		var actor					: CActor;
		var thrownEntity			: CThrowable;
		var parentEnt				: CEntity;
		var res						: bool;		
		var isVehicleBoat			: bool;
	
		if ( traceManager.RayCastSync( rayCastStartPos, rayCastEndPos, rayCastResults, parent.collisionGroupsNames ) )		
		{		
			size =  rayCastResults.Size();
			if ( size > 0 )
			{	
				thrownEntity = (CThrowable)EntityHandleGet( parent.owner.thrownEntityHandle );
				
				if ( parent.owner.IsUsingVehicle() )
					isVehicleBoat = (W3Boat)( parent.owner.GetUsedVehicle() );
					
				for ( i = 0; i < rayCastResults.Size(); i += 1 )
				{
					ent = rayCastResults[i].component.GetEntity();
					actor = (CActor)ent;
					parentEnt = ( (CItemEntity)ent ).GetParentEntity();
						
					if ( ( parentEnt && parentEnt == parent.owner )
						|| ( ent && ( ent == parent.owner || ent == parent.owner.rangedWeapon || ent == thrownEntity || ( parent.owner.IsUsingVehicle() && ent == parent.owner.GetUsedVehicle() && isVehicleBoat ) ) )
						|| ( actor && ( !actor.IsAlive() || actor.IsKnockedUnconscious() ) ) ) 
					{
						rayCastResults.Erase(i);
						i -= 1;
					}
					else
						traceResultDists.PushBack( rayCastResults[i].distance );
				}
			}
				
			size =  rayCastResults.Size();
			if ( size > 0 )
			{		 
				rayCastResult = rayCastResults[ ArrayFindMinF( traceResultDists ) ];
				hasResult = true;
			}
				
			if  ( hasResult )
			{
				aimPos = rayCastResult.position;
				aimPosNormal = rayCastResult.normal;
				aimEnt = rayCastResult.component.GetEntity();
			}
			else
			{
				
				aimPos = rayCastEndPos;
				aimPosNormal = Vector( 0.f, 0.f, 1.f );
				aimEnt = NULL;					
			}
		}
	}
	
	var cachedTime : float;
	function SetRadiusEntityScale()
	{
		var meshComponent : CMeshComponent;
		
		if ( theGame.GetEngineTimeAsSeconds() > cachedTime + 0.1f )
		{
			cachedTime = theGame.GetEngineTimeAsSeconds();
			
			meshComponent = ( CMeshComponent )radiusEntity.GetComponentByClassName( 'CMeshComponent' );
			
			if( meshComponent )
			{
				meshComponent.SetScale(Vector(parent.thrownBombImpactRadius, parent.thrownBombImpactRadius, parent.thrownBombImpactRadius));
			}
		}
	}
	
	var speedMultCasuserId	: int;
	function SloMo()
	{
		var speed : float;
		
		if (!(parent.owner))
			return;
	
		speed = SLOWMO_SPEED;
		
		RemoveSloMo();
		
		if (parent.aimType == AT_Bolt && parent.owner.CanUseSkill(S_Sword_s13) )
			speed -= CalculateAttributeValue( ((CR4Player)parent.owner).GetSkillAttributeValue(S_Sword_s13, 'slowdown_mod', false, true) ) * parent.owner.GetSkillLevel(S_Sword_s13);
		else if (parent.aimType == AT_Bomb && parent.owner.CanUseSkill(S_Alchemy_s09) )
			speed -= CalculateAttributeValue( ((CR4Player)parent.owner).GetSkillAttributeValue(S_Alchemy_s09, 'slowdown_mod', false, true) ) * parent.owner.GetSkillLevel(S_Alchemy_s09);
		
		
			theSound.SoundEvent( "gui_slowmo_start" );
	
		theGame.SetTimeScale(speed, theGame.GetTimescaleSource(ETS_ThrowingAim), theGame.GetTimescalePriority(ETS_ThrowingAim), false );
		speedMultCasuserId = parent.owner.SetAnimationSpeedMultiplier( 1/speed * 0.5 );		
	}
	
	function RemoveSloMo()
	{
		theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_ThrowingAim) );
		parent.owner.ResetAnimationSpeedMultiplier( speedMultCasuserId );
		
			theSound.SoundEvent( "gui_slowmo_end" );
	}
	
	cleanup function AimCleanup()
	{
		RemoveSloMo();
		ShowCrosshair(false);
		aimEntity.Destroy();
		
		if(radiusEntity)
			radiusEntity.Destroy();
			
		
	}
		
	event OnAddAimingSloMo()
	{
		SloMo();
	}		
}