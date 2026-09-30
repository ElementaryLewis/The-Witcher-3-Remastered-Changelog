/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskManageObjectsInPhantomComponentSlots extends IBehTreeTask
{
	
	
	
	
	public var checkDistanceOnIsAvailable		: bool;
	public var createEntityResourceNames		: array<name>;
	public var attachSlotNames					: array<name>;
	public var activateOnAnimEvent				: name;
	public var drawEntitiesFromArea				: bool;
	public var drawEntitiesRadius				: float;
	public var drawEntitiesTag					: name;
	public var drawSpeedLimit					: float;
	public var snapDrawnEntityToGround			: bool;
	public var shootAtLookatTarget				: bool;
	public var destroyEntityOnAnimEvent			: name;
	public var shootEntityOnAnimEvent			: name;
	public var shootAllDrawnEntitiesAtOnce		: bool;
	public var disperseObjectsOnAnimEvent		: name;
	public var playEffectOnEntityPull			: name;
	public var playEffectOnEntityAttach			: name;
	public var playEffectOnDestroyEntity		: name;
	public var playEffectOnDisperseObjects		: name;
	
	
	private var m_Npc							: CNewNPC;
	private var m_CreateEntityTemplates			: array<CEntityTemplate>;
	private var m_EntitiesDrawnFromArea			: array<CEntity>;
	private var m_CurveComponents				: array<CComponent>;
	private var m_activateEventReceived			: bool;
	private var m_destroyEntityEventReceived	: bool;
	private var m_disperceObjectsEventReceived	: bool;
	private var m_shootEntityEventReceived		: bool;
	private var m_entityResourceNameFilled		: bool;
	private var m_prevDesiredAffectedEntityPos	: Vector;
	private var m_prevSpeed						: float;
	private var m_ClosestSlot					: name;
	private var m_attachEntitiesArray			: array<CEntity>;
	private var m_collisionGroups 				: array<name>;
	private var m_drawnEntities					: int;
	private var m_checkedForEntities			: bool;
	
	
	
	
	function Initialize()
	{
		var i : int;
		
		m_Npc = GetNPC();
		
		if ( createEntityResourceNames.Size() > 0 )
		{
			for( i = 0; i < createEntityResourceNames.Size() ; i += 1 )
			{
				if ( IsNameValid( createEntityResourceNames[i] ) )
				{
					m_entityResourceNameFilled = true;
					m_CreateEntityTemplates.PushBack( ( CEntityTemplate ) LoadResource( createEntityResourceNames[i] ) );
				}
			}
		}
		
		m_collisionGroups.PushBack('Ragdoll');
		m_collisionGroups.PushBack('Terrain');
		m_collisionGroups.PushBack('Static');
		m_collisionGroups.PushBack('Water');
	}
	
	
	
	function IsAvailable() : bool
	{
		var entityToActorDist			: float;
		var i							: int;
		
		if ( !m_checkedForEntities && drawEntitiesFromArea && IsNameValid( drawEntitiesTag ) )
		{
			theGame.GetEntitiesByTag( drawEntitiesTag, m_EntitiesDrawnFromArea );
			m_checkedForEntities = true;
		}
		
		if ( checkDistanceOnIsAvailable )
		{
			if ( m_EntitiesDrawnFromArea.Size() < 1 )
			{
				return false;
			}
			
			for ( i = 0 ; i < m_EntitiesDrawnFromArea.Size() ; i += 1 )
			{
				entityToActorDist = VecDistance( m_EntitiesDrawnFromArea[i].GetWorldPosition(), m_Npc.GetWorldPosition() );
				
				if ( entityToActorDist < drawEntitiesRadius )
				{
					return true;
				}
			}
			
			return false;
		}
		
		return true;
	}
	
	
	
	function OnActivate() : EBTNodeStatus
	{
		m_CurveComponents = m_Npc.GetComponentsByClassName( 'W3ApplyEffectPhantomComponent' );
		
		if ( !checkDistanceOnIsAvailable )
		{
			if ( m_EntitiesDrawnFromArea.Size() < 1 )
			{
				return BTNS_Failed;
			}
		}
		
		if ( m_CurveComponents.Size() < 1 )
		{
			Log( "no curve components found in " + this + " ai task for " + m_Npc );
			return BTNS_Failed;
		}
		
		return BTNS_Active;
	}
	
	
	
	latent function Main() : EBTNodeStatus
	{
		var l_lastLocalTime : float;
		var l_deltaTime		: float;
		
		while ( true )
		{
			l_lastLocalTime = GetLocalTime();
			SleepOneFrame();
			l_deltaTime = GetLocalTime() - l_lastLocalTime;
			
			if ( !IsNameValid( activateOnAnimEvent ) )
			{
				AttachObjects( l_deltaTime );
			}
			else if ( m_activateEventReceived )
			{
				AttachObjects( l_deltaTime );
				if ( m_destroyEntityEventReceived || m_disperceObjectsEventReceived || m_shootEntityEventReceived )
				{
					m_activateEventReceived = false;
				}
			}
			
			if ( m_shootEntityEventReceived && m_drawnEntities > 0 )
			{
				DetachEntity( m_shootEntityEventReceived );
				if ( !shootAllDrawnEntitiesAtOnce )
				{
					m_shootEntityEventReceived = false;
				}
				else
				{
					if ( m_drawnEntities == 0 )
					{
						m_shootEntityEventReceived = false;
					}
				}
			}
			else if ( m_destroyEntityEventReceived )
			{
				DetachEntity( false);
				m_destroyEntityEventReceived = false;
			}
			else if ( m_disperceObjectsEventReceived )
			{
				DisperseEntities();
				m_disperceObjectsEventReceived = false;
			}
		}
		
		return BTNS_Completed;
	}
	
	
	
	function OnDeactivate()
	{
		DisperseEntities( true );
		m_activateEventReceived = false;
		m_shootEntityEventReceived = false;
		m_disperceObjectsEventReceived = false;
	}
	
	
	
	private latent function AttachObjects( _DeltaTime : float )     
	{
		var i							: int;
		var componentPos				: Vector;
		var componentRot				: EulerAngles;
		var entityRot					: EulerAngles;
		var affectedEntityRot			: EulerAngles;
		var slotPos						: Vector;
		var slotHeading					: float;
		var createdEntity				: CEntity;
		var actorPos					: Vector;
		var affectedEntityPos			: Vector;
		var desiredAffectedEntityPos	: Vector;
		var normal						: Vector;
		var entityToActorDist			: float;
		var entityToComponentDist		: float;
		var speed						: float;
		
		actorPos = m_Npc.GetWorldPosition();
		speed = m_prevSpeed + ( drawSpeedLimit * _DeltaTime );
		if ( speed > drawSpeedLimit )
		{
			speed = drawSpeedLimit;
		}
		
		m_prevSpeed = speed;
		
		if ( m_EntitiesDrawnFromArea.Size() > 0 )
		{	
			for ( i = 0 ; i < m_EntitiesDrawnFromArea.Size() ; i += 1 )
			{
				if ( m_attachEntitiesArray.Size() < m_CurveComponents.Size() )
				{
					entityToActorDist = VecDistance( m_EntitiesDrawnFromArea[i].GetWorldPosition(), m_Npc.GetWorldPosition() );
					if ( entityToActorDist < drawEntitiesRadius )
					{
						m_drawnEntities += 1;
						m_attachEntitiesArray.PushBack( m_EntitiesDrawnFromArea[i] );
						if ( IsNameValid( playEffectOnEntityPull ))
							m_EntitiesDrawnFromArea[i].PlayEffect( playEffectOnEntityPull );
					}
				}
			}
		}
		
		for ( i = 0 ; i < m_CurveComponents.Size() ; i += 1 )
		{
			if ( !( (W3ApplyEffectPhantomComponent)m_CurveComponents[i] ).IsObjectAttached() )
			{
				componentPos = m_CurveComponents[i].GetWorldPosition();
				componentRot = m_CurveComponents[i].GetWorldRotation();
				
				if ( m_entityResourceNameFilled && i <= createEntityResourceNames.Size() )
				{
					createdEntity = CreateEntity( i, componentPos, componentRot );
					
					((W3ApplyEffectPhantomComponent)m_CurveComponents[i]).GetClosestFreeSlotInfo( attachSlotNames, createdEntity.GetWorldPosition(), createdEntity.GetHeading(), m_ClosestSlot, slotPos, slotHeading );
					if ( createdEntity.CreateAttachment( m_Npc, m_ClosestSlot ) )
					{
						if ( IsNameValid( playEffectOnEntityAttach ) )
						{
							m_Npc.PlayEffect( playEffectOnEntityAttach );
						}
						((W3ApplyEffectPhantomComponent)m_CurveComponents[i]).SetObjectAttached( true );
					}
				}
				else if ( m_attachEntitiesArray.Size() > 0 )
				{
					affectedEntityPos = m_attachEntitiesArray[i].GetWorldPosition();
					entityToComponentDist = VecDistance( affectedEntityPos, componentPos );
					
					
					
					if ( entityToComponentDist > 0.2f )
					{
						desiredAffectedEntityPos = affectedEntityPos + VecNormalize( componentPos - affectedEntityPos  ) * speed * _DeltaTime;
						m_prevDesiredAffectedEntityPos = desiredAffectedEntityPos;
						
						if ( snapDrawnEntityToGround )
						{
							theGame.GetWorld().StaticTrace( desiredAffectedEntityPos + Vector(0,0,3), desiredAffectedEntityPos - Vector(0,0,3), desiredAffectedEntityPos, normal );
						}
						
						entityRot = m_attachEntitiesArray[i].GetWorldRotation();
						m_attachEntitiesArray[i].TeleportWithRotation( desiredAffectedEntityPos, entityRot );
					}
					else
					{
						affectedEntityRot = VecToRotation( affectedEntityPos );
						
						desiredAffectedEntityPos = InterpTo_V( affectedEntityPos, componentPos, _DeltaTime, speed );
						entityRot = m_attachEntitiesArray[i].GetWorldRotation();
						entityRot.Pitch += 4;
						entityRot.Yaw += 4;
						
						if ( snapDrawnEntityToGround )
						{
							theGame.GetWorld().StaticTrace( desiredAffectedEntityPos + Vector(0,0,3), desiredAffectedEntityPos - Vector(0,0,3), desiredAffectedEntityPos, normal );
						}
						
						m_attachEntitiesArray[i].TeleportWithRotation( InterpTo_V( desiredAffectedEntityPos, affectedEntityPos, 0.05f, 0.5f ), entityRot );
					}
					
				}
			}
		}
	}
	
	
	
	private function DetachEntity( shootProjectile : bool )
	{
		var i							: int;
		var attachedEntity				: CEntity;
		var target						: CEntity;
		var entityPos					: Vector;
		var targetPos					: Vector;
		var entityToTargetDist			: float;
		var entityToTargetDistArray		: array<float>;
		var traceEffect, normal 		: Vector;
		
		for ( i = 0 ; i < m_CurveComponents.Size() ; i += 1 )
		{
			target = GetCombatTarget();
			targetPos = target.GetWorldPosition();
			entityPos = m_attachEntitiesArray[i].GetWorldPosition();
			entityToTargetDist = VecDistance( entityPos, targetPos );
			entityToTargetDistArray.PushBack( entityToTargetDist );
		}
		
		i = ArrayFindMinF( entityToTargetDistArray );
		
		entityToTargetDistArray.Clear();
		
		attachedEntity = m_attachEntitiesArray[i];
		
		if ( shootProjectile )
		{
			entityPos = attachedEntity.GetWorldPosition();
			entityPos.Z += 0.75;
			if ( (CActor)GetCombatTarget() )
				targetPos.Z += ((CMovingPhysicalAgentComponent)((CActor)target).GetMovingAgentComponent()).GetCapsuleHeight() * 0.75;
			
			if( theGame.GetWorld().StaticTrace( entityPos, targetPos, traceEffect, normal ) )
			{
				return;
			}
		}
		
		attachedEntity.BreakAttachment();
		m_attachEntitiesArray.Erase(i);
		m_drawnEntities -= 1;
		if ( ( (W3ApplyEffectPhantomComponent)m_CurveComponents[i] ).IsObjectAttached() )
		{
			((W3ApplyEffectPhantomComponent)m_CurveComponents[i]).SetObjectAttached( false );
		}
		
		if ( m_destroyEntityEventReceived )
		{
			if ( IsNameValid( playEffectOnDestroyEntity ) )
			{
				m_Npc.PlayEffect( playEffectOnDestroyEntity );
			}
			attachedEntity.Destroy();
		}
		else if ( m_shootEntityEventReceived )
		{
			ShootProjectile( attachedEntity );
		}
	}
	
	
	
	private function DisperseEntities( optional deactivate : bool )
	{
		var i							: int;
		var attachedEntity				: CEntity;
		var entityPos					: Vector;
		var targetPos					: Vector;
		var entityToTargetDist			: float;
		var entityToTargetDistArray		: array<float>;
		
		for ( i = 0 ; i < m_CurveComponents.Size() ; i += 1 )
		{
			if ( ( (W3ApplyEffectPhantomComponent)m_CurveComponents[i] ).IsObjectAttached() )
			{
				attachedEntity = m_attachEntitiesArray[i];
				attachedEntity.BreakAttachment();
				((W3ApplyEffectPhantomComponent)m_CurveComponents[i]).SetObjectAttached( false );
				m_drawnEntities -= 1;
			}
		}
		
		if ( IsNameValid( playEffectOnDisperseObjects ) )
		{
			m_Npc.PlayEffect( playEffectOnDisperseObjects );
		}
		
		for ( i = 0 ; i < m_attachEntitiesArray.Size() ; i += 1 )
		{
			ShootProjectile( m_attachEntitiesArray[i], true );
		}
		
		m_disperceObjectsEventReceived = false;
		m_attachEntitiesArray.Clear();
	}
	
	
	
	function ShootProjectile( projectile : CEntity, optional allDirections : bool, optional deactivate : bool )
	{
		var target 					: CActor = GetCombatTarget();
		var npcPos					: Vector;
		var combatTargetPos 		: Vector;
		var targetPos				: Vector;
		var proj					: W3AdvancedProjectile;
		var range 					: float;
		var distToTarget 			: float;
		var l_heightFromTarget		: float;
		var l_3DdistanceToTarget	: float;
		var l_projectileFlightTime	: float;
		var l_npcToProjectileAngle	: float;
		
		
		combatTargetPos = GetCombatTarget().GetWorldPosition();
		proj = (W3AdvancedProjectile)projectile;
		
		distToTarget = VecDistance2D( combatTargetPos, m_Npc.GetWorldPosition() );
		
		if ( deactivate )
			range = 1.5;
		else
			range = 100;
		
		if ( deactivate )
		{
			targetPos = projectile.GetWorldPosition() + projectile.GetHeadingVector()* range;
		}
		if ( allDirections )
		{
			l_npcToProjectileAngle = NodeToNodeAngleDistance( projectile, m_Npc );
			targetPos = projectile.GetWorldPosition() + VecFromHeading( l_npcToProjectileAngle )* range;
		}
		else if ( shootAtLookatTarget )
		{
			targetPos = m_Npc.GetBehaviorVectorVariable('lookAtTarget');
		}
		else
			targetPos = projectile.GetWorldPosition() +  m_Npc.GetHeadingVector()* distToTarget;
		
		if ( !deactivate )
		{
			targetPos.Z = combatTargetPos.Z + 1.5;
		}
		
		proj.Init( m_Npc );
		proj.ShootProjectileAtPosition( proj.projAngle, proj.projSpeed, targetPos, range, m_collisionGroups );
		
		l_3DdistanceToTarget = VecDistance( m_Npc.GetWorldPosition(), combatTargetPos );		
		
		
		l_projectileFlightTime = l_3DdistanceToTarget / drawSpeedLimit;
		target.SignalGameplayEventParamFloat( 'Time2DodgeProjectile', l_projectileFlightTime );
	}
	
	
	
	function CreateEntity( i : int, _SpawnPos : Vector, _Rotation : EulerAngles ) : CEntity
	{		
		var l_spawnedEntity 			: CEntity;
		var l_summonedEntityComponent	: W3SummonedEntityComponent;
		var l_normal					: Vector;
		var l_entityToSpawn				: CEntityTemplate;
		var l_randValue					: int;
		
		theGame.GetWorld().StaticTrace( _SpawnPos + Vector(0,0,5), _SpawnPos - Vector(0,0,5), _SpawnPos, l_normal );
		
		l_entityToSpawn = m_CreateEntityTemplates[i];
		
		l_spawnedEntity = theGame.CreateEntity( l_entityToSpawn, _SpawnPos, _Rotation );
		
		l_summonedEntityComponent = (W3SummonedEntityComponent) l_spawnedEntity.GetComponentByClassName('W3SummonedEntityComponent');
		if( l_summonedEntityComponent )
		{
			l_summonedEntityComponent.Init( m_Npc );
		}
		
		return l_spawnedEntity;
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
		
		if ( IsNameValid( destroyEntityOnAnimEvent ) && animEventName == destroyEntityOnAnimEvent )
		{
			m_destroyEntityEventReceived = true;
		}
		
		if ( IsNameValid( disperseObjectsOnAnimEvent ) && animEventName == disperseObjectsOnAnimEvent )
		{
			m_disperceObjectsEventReceived = true;
		}
		
		return false;
	}
};



class BTTaskManageObjectsInPhantomComponentSlotsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskManageObjectsInPhantomComponentSlots';

	
	
	
	private editable var checkDistanceOnIsAvailable			: bool;
	private editable var createEntityResourceNames			: array<name>;
	private editable var attachSlotNames					: array<name>;
	private editable var activateOnAnimEvent				: name;
	private editable var drawEntitiesFromArea				: bool;
	private editable var snapDrawnEntityToGround			: bool;
	private editable var shootAtLookatTarget				: bool;
	private editable var shootAllDrawnEntitiesAtOnce		: bool;
	private editable var drawEntitiesRadius					: float;
	private editable var drawEntitiesTag					: name;
	private editable var drawSpeedLimit						: float;
	private editable var destroyEntityOnAnimEvent			: name;
	private editable var shootEntityOnAnimEvent				: name;
	private editable var disperseObjectsOnAnimEvent			: name;
	private editable var playEffectOnEntityPull				: name;
	private editable var playEffectOnEntityAttach			: name;
	private editable var playEffectOnDestroyEntity			: name;
	private editable var playEffectOnDisperseObjects		: name;
	
	default checkDistanceOnIsAvailable						= true;
	default activateOnAnimEvent 							= 'DrawEntitiesToComponents';
	default drawEntitiesTag 								= 'drawToComponents';
	default shootEntityOnAnimEvent 							= 'ShootEntitiesFromComponents';
	default drawSpeedLimit 									= 20;
	default drawEntitiesRadius 								= 20;
	default drawEntitiesFromArea							= true;
	default shootAtLookatTarget								= true;
};
