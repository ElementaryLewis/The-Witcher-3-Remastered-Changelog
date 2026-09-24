/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskPullObjectsFromGroundAndShoot extends IBehTreeTask
{
	
	
	
	
	public var createEntityResourceName			: name;
	public var numberToSpawn					: int;
	public var numberOfCircles					: int;
	public var spawnPositionPattern				: ESpawnPositionPattern;
	public var spawnRotation					: ESpawnRotation;
	public var spawnInTargetDirection			: bool;
	public var zAxisSpawnOffset					: float;
	public var raiseObjectsToCapsuleHeightRatio	: float;
	public var raiseObjectsHeightNoise			: float;
	public var spawnObjectsInConeAngle			: float;
	public var randomnessInCircles				: float;
	public var useRandomSpaceBetweenSpawns		: bool;
	public var spawnRadiusMin					: float;
	public var spawnRadiusMax					: float;
	public var spawnInRandomOrder				: bool;
	public var delayBetweenSpawn				: float;
	public var activateOnAnimEvent				: name;
	public var activateAfter					: float;
	public var calculateSpeedFromPullDuration	: float;
	public var drawSpeedLimit					: float;
	public var drawEntityRotationSpeed			: float;
	public var completeTaskAfterShooting		: bool;
	public var shootEntitiesInRandomOrder		: bool;
	public var shootAtLookatTarget				: bool;
	public var shootInAllDirections				: bool;
	public var shootDirectionNoise				: float;
	public var shootEntityOnAnimEvent			: name;
	public var shootEntityAfter					: float;
	public var shootEntitiesInterval			: float;
	public var playEffectOnEntityCreation		: name;
	public var stopEffectOnDeactivate			: name;
	
	
	private var m_Npc							: CNewNPC;
	private var m_CreateEntityTemplate			: CEntityTemplate;
	private var m_CreatedEntities				: array<CEntity>;
	private var m_entitiesToPull				: array<CEntity>;
	private var m_entitiesToShoot				: array<CEntity>;
	private var m_activateEventReceived			: bool;
	private var m_shootEntityEventReceived		: bool;
	private var m_aardHitEventReceived			: bool;
	private var m_initialPosArray				: array<Vector>;
	private var m_finalPosArray					: array<Vector>;
	private var m_prevSpeed						: float;
	private var m_lastShootTime					: float;
	private var m_collisionGroups 				: array<name>;
	
	private var couldntLoadResource : bool;
	
	
	
	function IsAvailable() : bool
	{
		if ( couldntLoadResource )
		{
			return false;
		}
		
		return true;
	}
	
	
	
	function OnActivate() : EBTNodeStatus
	{
		m_Npc = GetNPC();
		
		
		m_collisionGroups.PushBack('Ragdoll');
		m_collisionGroups.PushBack('Terrain');
		m_collisionGroups.PushBack('Static');
		m_collisionGroups.PushBack('Water');
		
		return BTNS_Active;
	}
	
	
	
	
	latent function Main() : EBTNodeStatus
	{
		var l_lastLocalTime : float;
		var l_timeStamp		: float;
		var l_deltaTime		: float;
		
		if ( !m_CreateEntityTemplate && IsNameValid( createEntityResourceName ) )
		{
			m_CreateEntityTemplate = ( ( CEntityTemplate ) LoadResourceAsync( createEntityResourceName ) );
		}
		
		if ( !m_CreateEntityTemplate )
		{
			couldntLoadResource = true;
			return BTNS_Failed;
		}
		
		l_timeStamp = GetLocalTime();
		
		if ( IsNameValid( activateOnAnimEvent ) )
		{
			while ( !m_activateEventReceived )
			{
				SleepOneFrame();
			}
		}
		else if ( activateAfter > 0 )
		{
			while ( l_timeStamp + activateAfter > GetLocalTime() )
			{
				SleepOneFrame();
			}
		}
		
		LatentSpawnEntity();
		m_entitiesToShoot = m_CreatedEntities;
		m_entitiesToPull = m_CreatedEntities;
		SetProjectilesPullPositions();
		
		while ( m_entitiesToShoot.Size() > 0 && !m_aardHitEventReceived )
		{
			l_lastLocalTime = GetLocalTime();
			SleepOneFrame();
			l_deltaTime = GetLocalTime() - l_lastLocalTime;
			
			PullObjectsFromGround( l_deltaTime );
			
			if ( IsNameValid( shootEntityOnAnimEvent ) && m_shootEntityEventReceived )
			{
				ProcessShootEntities( shootInAllDirections );
			}
			else if ( shootEntityAfter > 0 )
			{
				if ( l_timeStamp + shootEntityAfter - ClampF( activateAfter, 0, 999 ) < GetLocalTime() )
				{
					ProcessShootEntities( shootInAllDirections );
				}
			}
		}
		
		if ( completeTaskAfterShooting )
			return BTNS_Completed;
		else
			return BTNS_Active;
	}
	
	
	
	
	function OnDeactivate()
	{
		var i : int;
		
		
		if ( m_entitiesToShoot.Size() > 0 )
		{
			for ( i = m_entitiesToShoot.Size() - 1 ; i >= 0 ; i -= 1 ) 
			{
				ShootProjectile( m_entitiesToShoot[i], false, true );
			}
		}
		
		m_initialPosArray.Clear();
		m_CreatedEntities.Clear();
		m_finalPosArray.Clear();
		m_collisionGroups.Clear();
		m_entitiesToPull.Clear();
		m_entitiesToShoot.Clear();
		m_activateEventReceived = false;
		m_shootEntityEventReceived = false;
		m_aardHitEventReceived = false;
	}
	
	
	
	
	private latent function PullObjectsFromGround( _DeltaTime : float )     
	{
		var l_speed						: float;
		var l_speedModifier				: float;
		var l_entityToFinalPosDist		: float;
		var l_initialToFinalPosDist		: float;
		var l_desiredAffectedEntityPos	: Vector;
		var l_projPos					: Vector;
		var l_projRot					: EulerAngles;
		var l_rotationSpeedNoise		: float;
		var l_CreatedEntities			: array<CEntity>;
		var i 							: int;
		
		
		if ( m_entitiesToPull.Size() > 0 )
		{
			for ( i = m_entitiesToPull.Size() - 1 ; i >= 0 ; i -= 1 )
			{
				l_projPos = m_entitiesToPull[i].GetWorldPosition();
				l_entityToFinalPosDist = VecDistance( l_projPos, m_finalPosArray[i] );
				
				
				if ( drawEntityRotationSpeed > 0 )
				{
					l_rotationSpeedNoise = RandRangeF( 1, -1 );
				}
				
				l_initialToFinalPosDist = VecDistance( m_finalPosArray[i], m_initialPosArray[i] );
				
				
				if ( calculateSpeedFromPullDuration > 0 )
				{
					l_speedModifier = l_initialToFinalPosDist / calculateSpeedFromPullDuration;
					m_prevSpeed = l_speedModifier;
				}
				else
				{
					l_speedModifier = drawSpeedLimit;
					m_prevSpeed = drawSpeedLimit;
				}
				
				
				
				
				l_speed = m_prevSpeed - ( l_speedModifier * _DeltaTime );
				
				if ( l_speed > drawSpeedLimit )
				{
					l_speed = drawSpeedLimit;
				}
				else if ( l_speed < 0 )
				{
					l_speed = 0;
				}
				
				m_prevSpeed = l_speed;
				
				l_desiredAffectedEntityPos = l_projPos + VecNormalize( m_finalPosArray[i] - l_projPos  ) * l_speed * _DeltaTime;
				l_projRot = m_entitiesToPull[i].GetWorldRotation();
				l_projRot.Pitch += drawEntityRotationSpeed + l_rotationSpeedNoise;
				l_projRot.Yaw += drawEntityRotationSpeed + l_rotationSpeedNoise;
				if ( VecDistance( l_projPos, l_desiredAffectedEntityPos ) < l_entityToFinalPosDist )
				{
					m_entitiesToPull[i].TeleportWithRotation( l_desiredAffectedEntityPos, l_projRot );
				}
				else
				{
					m_entitiesToPull[i].TeleportWithRotation( l_projPos, l_projRot );
				}
			}
		}
	}
	
	
	
	private function SetProjectilesPullPositions()
	{
		var l_owner		: CNewNPC = GetNPC();
		var l_finalPos 	: Vector;
		var min, max	: float;
		var i			: int;
		
		
		if ( m_CreatedEntities.Size() > 0 )
		{
			for ( i = 0 ; i < m_CreatedEntities.Size() ; i += 1 )
			{
				l_finalPos = m_CreatedEntities[i].GetWorldPosition();
				min = raiseObjectsToCapsuleHeightRatio * ( 1 - raiseObjectsHeightNoise );
				max = raiseObjectsToCapsuleHeightRatio * ( 1 + raiseObjectsHeightNoise );
				l_finalPos.Z += ((CMovingPhysicalAgentComponent)l_owner.GetMovingAgentComponent()).GetCapsuleHeight() * RandRangeF( max, min );
				m_finalPosArray.PushBack( l_finalPos );
			}
		}
	}
	
	
	
	latent function LatentSpawnEntity()
	{
		var l_spawnCenter			: Vector;
		var l_spawnPos 				: Vector;
		var l_entity 				: CEntity;
		var l_coneAngle				: float;
		var l_coneWidth				: float;
		var l_randomVector			: Vector;
		var l_normal				: Vector;
		var l_rotation				: EulerAngles;
		var l_npc					: CNewNPC = GetNPC();
		var l_npcPos				: Vector;
		var l_targetPos				: Vector;
		var l_currentCircle 		: float;
		var l_numPerCircle			: int;
		var l_numberInCurrentCircle : int;
		var l_currentCone			: int;
		var l_circleRadiusMin		: float;
		var l_circleRadiusMax		: float;
		var l_positionArray			: array<Vector>;
		var l_rotationArray			: array<EulerAngles>;
		var l_npcToTargetAngle		: float;
		var i 						: int;
		
		switch ( spawnPositionPattern )
		{
			case ESPP_AroundTarget:
				l_spawnCenter = GetCombatTarget().GetWorldPosition();
				break;
			case ESPP_AroundSpawner:
				l_spawnCenter = GetNPC().GetWorldPosition();
				break;
			case ESPP_AroundBoth:
				l_spawnCenter = GetNPC().GetWorldPosition();
				l_spawnCenter += GetCombatTarget().GetWorldPosition();
				l_spawnCenter /= 2;
				break;
		}
		
		
		numberOfCircles = Max( 1, numberOfCircles );
		
		l_numPerCircle 	= FloorF( ( float ) numberToSpawn / ( float ) numberOfCircles );
		l_coneAngle 	= spawnObjectsInConeAngle / ( float ) l_numPerCircle;		
		
		l_npcPos 		= l_npc.GetWorldPosition();
		l_targetPos		= GetCombatTarget().GetWorldPosition();
		
		l_coneWidth = 0.5f;
		if( useRandomSpaceBetweenSpawns )
		{
			l_coneWidth = l_coneAngle;
		}
		
		l_positionArray.Clear();
		l_rotationArray.Clear();
		
		for	( i = 0; i < numberToSpawn  ; i += 1 )
		{
			l_circleRadiusMin = spawnRadiusMin + ( l_currentCircle / (float) numberOfCircles ) * ( spawnRadiusMax - spawnRadiusMin) ;
			l_circleRadiusMax = spawnRadiusMax - ( l_currentCircle / (float) numberOfCircles ) * ( spawnRadiusMax - spawnRadiusMin) ;
			
			if( numberOfCircles > 1 )
			{
				l_circleRadiusMax = MinF( l_circleRadiusMin + randomnessInCircles, spawnRadiusMax );
			}
			
			
			if ( spawnInTargetDirection )
			{
				l_npcToTargetAngle = NodeToNodeAngleDistance( GetCombatTarget(), m_Npc );
				l_randomVector = VecConeRand( AngleNormalize180( m_Npc.GetHeading() - l_npcToTargetAngle ) - ( spawnObjectsInConeAngle * 0.5 ) + ( l_coneAngle * l_currentCone ), l_coneWidth, l_circleRadiusMin, l_circleRadiusMax );			
			}
			else
				l_randomVector = VecConeRand( l_npc.GetHeading() - ( spawnObjectsInConeAngle * 0.5 ) + ( l_coneAngle * l_currentCone ), l_coneWidth, l_circleRadiusMin, l_circleRadiusMax );			
			l_spawnPos = l_spawnCenter + l_randomVector;
			
			
			theGame.GetWorld().StaticTrace( l_spawnPos + Vector(0,0,5), l_spawnPos - Vector(0,0,5), l_spawnPos, l_normal );
			
			switch( spawnRotation )
			{
				case ESR_BackAtSpawner:
					l_rotation = VecToRotation( l_spawnPos  - l_npc.GetWorldPosition());
					break;
				case ESR_TowardsSpawner:
					l_rotation = VecToRotation( l_npc.GetWorldPosition() - l_spawnPos);
					break;
				case ESR_TowardsTarget:
					l_rotation = VecToRotation( l_targetPos - l_spawnPos );
					break;
				case ESR_SameAsSpawner:
					l_rotation = GetActor().GetWorldRotation();
					break;
				case ESR_OppositeOfSpawner:
					l_rotation = VecToRotation( l_npc.GetWorldForward() * -1 );
					break;
			}
			
			
			l_positionArray.PushBack( l_spawnPos );
			l_rotationArray.PushBack( l_rotation );
			
			l_currentCone += 1;
			l_numberInCurrentCircle += 1;
			
			if( l_numberInCurrentCircle >= l_numPerCircle )
			{
				l_numberInCurrentCircle = 0;
				l_currentCircle += 1;
				l_currentCone = 0;
			}
		}
		
		if( delayBetweenSpawn <= 0 ) spawnInRandomOrder = false;
		
		while ( l_positionArray.Size() > 0 )
		{
			i = 0;
			if( spawnInRandomOrder )
			{
				i = RandRange( l_positionArray.Size(), 0 );
			}
			
			l_spawnPos = l_positionArray[i];
			l_rotation = l_rotationArray[i];
			l_positionArray.Erase( i );
			l_rotationArray.Erase( i );
			
			l_entity = CreateEntity( l_spawnPos, l_rotation );
			
			if( delayBetweenSpawn > 0 )
			{
				Sleep( delayBetweenSpawn );
			}
		}
	}
	
	
	
	function CreateEntity( _SpawnPos : Vector, _Rotation : EulerAngles ) : CEntity
	{		
		var l_spawnedEntity 			: CEntity;
		var l_summonedEntityComponent	: W3SummonedEntityComponent;
		var l_normal					: Vector;
		
		theGame.GetWorld().StaticTrace( _SpawnPos + Vector(0,0,5), _SpawnPos - Vector(0,0,5), _SpawnPos, l_normal );
		
		_SpawnPos.Z += zAxisSpawnOffset;
		
		l_spawnedEntity = theGame.CreateEntity( m_CreateEntityTemplate, _SpawnPos, _Rotation );
		
		if ( IsNameValid( playEffectOnEntityCreation ) )
		{
			l_spawnedEntity.PlayEffect( playEffectOnEntityCreation );
		}
		
		m_initialPosArray.PushBack( l_spawnedEntity.GetWorldPosition() );
		m_CreatedEntities.PushBack( l_spawnedEntity );
		
		l_summonedEntityComponent = (W3SummonedEntityComponent) l_spawnedEntity.GetComponentByClassName('W3SummonedEntityComponent');
		if( l_summonedEntityComponent )
		{
			l_summonedEntityComponent.Init( m_Npc );
		}
		
		return l_spawnedEntity;
	}
	
	
	
	function ProcessShootEntities( b : bool )
	{
		var i 		: int;
		var rand 	: int;
		
		if ( GetLocalTime() - m_lastShootTime > shootEntitiesInterval )
		{
			if ( shootEntitiesInRandomOrder )
			{
				rand = RandRange( m_entitiesToShoot.Size() - 1 );
				ShootProjectile( m_entitiesToShoot[rand], b );
				m_lastShootTime = GetLocalTime();
				m_entitiesToShoot.Erase(rand);
				m_entitiesToPull.Erase(rand);
				m_finalPosArray.Erase(rand);
			}                                  
			else
			{
				for ( i = m_entitiesToShoot.Size() - 1 ; i >= 0 ; i -= 1 ) 
				{
					ShootProjectile( m_entitiesToShoot[i], b );
					m_lastShootTime = GetLocalTime();
					m_entitiesToShoot.Erase(i);
					m_entitiesToPull.Erase(i);
					m_finalPosArray.Erase(i);
					break;
				}
			}
		}
	}
	
	
	
	function ShootProjectile( projectile : CEntity, optional allDirections : bool, optional deactivate : bool )
	{
		var target 						: CActor = GetCombatTarget();
		var npcPos						: Vector;
		var combatTargetPos 			: Vector;
		var targetPos					: Vector;
		var proj						: W3AdvancedProjectile;
		var range 						: float;
		var distToTarget 				: float;
		var l_heightFromTarget			: float;
		var l_3DdistanceToTarget		: float;
		var l_projectileFlightTime		: float;
		var l_npcToProjectileAngle		: float;
		var l_targetToProjectileAngle	: float;
		var l_npcToTargetAngle			: float;
		
		
		combatTargetPos = target.GetWorldPosition();
		proj = (W3AdvancedProjectile)projectile;
		proj.Init( m_Npc );
		
		if ( IsNameValid( stopEffectOnDeactivate ) )
		{
			proj.StopEffect( stopEffectOnDeactivate );
		}
		
		distToTarget = VecDistance2D( combatTargetPos, m_Npc.GetWorldPosition() );
		
		if ( deactivate && !m_aardHitEventReceived )
			range = RandRangeF( 1, 0 );
		else
			range = 100;
		
		if ( m_aardHitEventReceived )
		{
			l_targetToProjectileAngle = NodeToNodeAngleDistance( projectile, thePlayer );
			targetPos = projectile.GetWorldPosition() + VecFromHeading( AngleNormalize180( thePlayer.GetHeading() + l_targetToProjectileAngle ) ) * range;
			proj.Init( thePlayer );
		}
		else if ( allDirections )
		{
			l_npcToProjectileAngle = NodeToNodeAngleDistance( projectile, m_Npc );
			targetPos = projectile.GetWorldPosition() + VecFromHeading( AngleNormalize180( m_Npc.GetHeading() - l_npcToProjectileAngle ) ) * distToTarget;
			targetPos.Z = combatTargetPos.Z;
		}
		else if ( deactivate )
		{
			targetPos = projectile.GetWorldPosition() + projectile.GetHeadingVector() * range;
		}
		else if ( shootAtLookatTarget )
		{
			targetPos = m_Npc.GetBehaviorVectorVariable('lookAtTarget');
		}
		else if ( spawnInTargetDirection )
		{
			l_npcToTargetAngle = NodeToNodeAngleDistance( target, m_Npc );
			targetPos = projectile.GetWorldPosition() + VecFromHeading( AngleNormalize180( m_Npc.GetHeading() - l_npcToTargetAngle + RandRangeF( shootDirectionNoise, -shootDirectionNoise ) ) ) * distToTarget;
			targetPos.Z = combatTargetPos.Z;
		}
		else
		{
			targetPos = projectile.GetWorldPosition() + VecFromHeading ( AngleNormalize180( m_Npc.GetBehaviorVariable( 'requestedFacingDirection' ) + RandRangeF( shootDirectionNoise, -shootDirectionNoise ) ) ) * distToTarget;
			targetPos.Z = combatTargetPos.Z;
		}
		
		if ( !deactivate )
		{
			targetPos.Z = combatTargetPos.Z + 1.5;
		}
		
		
		if ( deactivate && !m_aardHitEventReceived )
		{
			proj.ShootProjectileAtPosition( proj.projAngle, 5, targetPos, range, m_collisionGroups );
		}
		else
		{
			proj.ShootProjectileAtPosition( proj.projAngle, proj.projSpeed, targetPos, range, m_collisionGroups );
		}
		
		
		l_3DdistanceToTarget = VecDistance( m_Npc.GetWorldPosition(), combatTargetPos );		
		l_projectileFlightTime = l_3DdistanceToTarget / drawSpeedLimit;
		target.SignalGameplayEventParamFloat( 'Time2DodgeProjectile', l_projectileFlightTime );
	}
	
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( IsNameValid( activateOnAnimEvent ) && animEventName == activateOnAnimEvent )
		{
			m_activateEventReceived = true;
		}
		
		if ( IsNameValid( shootEntityOnAnimEvent ) && animEventName == shootEntityOnAnimEvent )
		{
			m_shootEntityEventReceived = true;
		}
		
		return false;
	}
	
	
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'AardHitReceived' )
		{
			m_aardHitEventReceived = true;
			return true;
		}
		
		return false;
	}
};



class BTTaskPullObjectsFromGroundAndShootDef extends IBehTreeTaskDefinition
{
	
	
	
	private editable var createEntityResourceName			: name;
	private editable var zAxisSpawnOffset					: float;
	private editable var raiseObjectsToCapsuleHeightRatio	: float;
	private editable var raiseObjectsHeightNoise			: float;
	private editable var numberToSpawn						: int;
	private editable var numberOfCircles					: int;
	private editable var spawnPositionPattern				: ESpawnPositionPattern;
	private editable var spawnRotation						: ESpawnRotation;
	private editable var spawnInTargetDirection				: bool;
	private editable var spawnObjectsInConeAngle			: float;
	private editable var randomnessInCircles				: float;
	private editable var useRandomSpaceBetweenSpawns		: bool;
	private editable var spawnRadiusMin						: float;
	private editable var spawnRadiusMax						: float;
	private editable var spawnInRandomOrder					: bool;
	private editable var delayBetweenSpawn					: float;
	private editable var activateOnAnimEvent				: name;
	private editable var activateAfter						: float;
	private editable var shootEntityOnAnimEvent				: name;
	private editable var shootEntityAfter					: float;
	private editable var drawSpeedLimit						: float;
	private editable var calculateSpeedFromPullDuration		: float;
	private editable var drawEntityRotationSpeed			: float;
	private editable var shootAtLookatTarget				: bool;
	private editable var shootEntitiesInRandomOrder			: bool;
	private editable var shootInAllDirections				: bool;
	private editable var completeTaskAfterShooting			: bool;
	private editable var shootDirectionNoise				: float;
	private editable var shootEntitiesInterval				: float;
	private editable var playEffectOnEntityCreation			: name;
	private editable var stopEffectOnDeactivate				: name;
	
	
	default createEntityResourceName						= 'troll_stone_proj';
	default zAxisSpawnOffset								= -0.3f;
	default raiseObjectsHeightNoise							= 0.1;
	default spawnObjectsInConeAngle							= 180;
	default numberToSpawn									= 5;
	default numberOfCircles									= 1;
	default spawnRadiusMin									= 2;
	default spawnRadiusMax									= 5;
	default delayBetweenSpawn  								= -1;
	default drawEntityRotationSpeed							= -1;
	default calculateSpeedFromPullDuration					= -1;
	default shootEntityAfter								= -1;
	default activateAfter									= -1;
	default activateOnAnimEvent 							= 'Spawn';
	default shootEntityOnAnimEvent 							= 'Shoot';
	default drawSpeedLimit 									= 5;
	default shootDirectionNoise								= 3;
	default shootAtLookatTarget								= true;
	
	hint raiseObjectsToCapsuleHeightRatio = "multiplier of owner capsule height to which level objects will be raised";
	
	default instanceClass = 'BTTaskPullObjectsFromGroundAndShoot';
};
