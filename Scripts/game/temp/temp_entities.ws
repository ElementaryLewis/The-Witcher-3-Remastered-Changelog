/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SBackgroundEntityData
{
	editable var entityTemplate 		: CEntityTemplate;
	editable var spawnSlotName			: name;
	editable var workAnimationEvent		: EBackgroundNPCWork_Single;
	editable var appearanceName			: name;
}

class W3BackgroundAnimatedEntity extends CGameplayEntity
{
	editable var backgroundEntityData 	: array<SBackgroundEntityData>;
	editable var parentEntity 			: CEntityTemplate;
	
	editable var maxSpeed				: float;
	editable var acceleration 			: float;
	editable var maxAngleSpeed			: float;
	editable var waypointDistance		: float; 
	editable var waypoints				: array<EntityHandle>;
	editable var loopMotion				: bool;
	editable var startAtSpawn			: bool;
	
	editable var maxAngleSpeedThreshold	: float;
	default maxAngleSpeedThreshold = 90;
	hint maxAngleSpeedThreshold = "At this angle the turning speed is set to maxAngleSpeed. If the angle is smaller the turning speed is smaller also";
	
	editable var angleAcceleration		: float;
	default angleAcceleration = 1.0;
	hint angleAcceleration = "The amount of degress per second the entity can change it's angle speed";
	
	editable var stoppingDistance		: float;
	default stoppingDistance = 20.0;
	hint stoppingDistance = "If the movement is not looped, drakkar will start slowing down at this distance from the end node";

	editable var endPositionError		: float;
	hint stoppingDistance = "In this position from the end node the drakkar will stop moving";
	default endPositionError = 1.0;	
	
	var angleSpeed						: float;
	
	var speedScale						: float;
	
	var previousAngleDistance			: float;
	
	var nodes							: array<CNode>;
	var i, size, currTargetIndex		: int;
	var canMove							: bool;
	var entity, entityToAttach 			: CEntity;
	var currTarget						: CNode;
	
	var position, targetPos, currPosition, direction, toTarget		: Vector;
	var angleDistancePlus, angleDistanceMinus, angleDistance, distanceToTarget	: float;
	var rotation, desiredRotation : EulerAngles;
	var speed : float;
	var shouldStop : bool;
	
	var maxCurrentAngleSpeed 			: float;
	var maxCurrentSpeed					: float;
	
	function SetupNodes() : bool
	{
		size = waypoints.Size();
		
		nodes.Resize(size);
		
		for( i = 0; i < size; i += 1 )
		{
			nodes[i] = EntityHandleGet( waypoints[i] );
		}
		
		size = nodes.Size();
		
		canMove = true;
		
		for( i = 0; i < size; i += 1)
		{
			if( !nodes[i] )
			{
				canMove = false;
			}
		}
		
		return canMove;
	}
	
	function MoveBetweenWaypoints( timeDelta : float )
	{
		var absAngleDistance : float;
		var clampedDistanceToTarget : float;
		var traceVector : Vector;
		var traceNormal : Vector;
		var zSpeed : float;
		
		if(canMove)
		{
			direction = entity.GetHeadingVector();
			
			direction.Z = 0;
			
			direction = VecNormalize(direction);
			
			rotation = entity.GetWorldRotation();
			
			currPosition = entity.GetWorldPosition();
			
			currPosition.Z = 0;
			
			currTarget = nodes[currTargetIndex];
			
			if(shouldStop)
			{
				clampedDistanceToTarget = distanceToTarget;
				if( clampedDistanceToTarget > stoppingDistance )
				{
					clampedDistanceToTarget = stoppingDistance;
				}
				
				if( clampedDistanceToTarget < endPositionError )
				{
					entity.StopEffect( 'water_trail' );
					canMove = false;
					entity.SoundEvent( "qu_sk_drakkar_singing_end" );
				}
				else
				{
					speed = (clampedDistanceToTarget*maxCurrentSpeed) / stoppingDistance;
				}
			}
			else 
			{
				speed = speed + acceleration*timeDelta;
				if(speed > maxSpeed)
				{
					speed = maxSpeed;
				}
				maxCurrentSpeed = speed;
			}
			
			if( currTarget )
			{
				targetPos = currTarget.GetWorldPosition();
				
				targetPos.Z = 0;
			
				toTarget = targetPos - position;
				
				desiredRotation = VecToRotation( toTarget );
				
				angleDistance = desiredRotation.Yaw - rotation.Yaw;
				
				if(angleDistance < -180 )
				{
					angleDistance += 360;
				}
				else if( angleDistance > 180)
				{
					angleDistance -= 360;
				}
				
				absAngleDistance = AbsF(angleDistance);
				
				distanceToTarget = VecDistance2D(targetPos, currPosition);
				
				if( distanceToTarget <= waypointDistance )
				{
					if( currTargetIndex < size - 1)
					{
						if( !loopMotion )
						{
							shouldStop = true;
						}
						currTargetIndex += 1;
					}
					else if( loopMotion )
					{
						currTargetIndex = 0;
					}

				}
				
				if( absAngleDistance > 0.1 )
				{
					if( absAngleDistance < maxAngleSpeedThreshold && previousAngleDistance > absAngleDistance )
					{
						if( maxCurrentAngleSpeed <= 0 )
						{
							maxCurrentAngleSpeed = maxAngleSpeed;
						}
						angleSpeed = (maxCurrentAngleSpeed*absAngleDistance)/maxAngleSpeedThreshold;
					}
					else
					{
						if( angleSpeed < maxAngleSpeed ) 
						{
							angleSpeed += angleAcceleration*timeDelta;
						}
						else 
						{
							angleSpeed = maxAngleSpeed;
						}
						maxCurrentAngleSpeed = angleSpeed;
					}
					
					if(angleDistance < 0)
					{
						angleDistance = -1*angleSpeed;
					}
					else
					{
						angleDistance = angleSpeed;
					}
					
				}
				else
				{
					angleSpeed = 0;
				}
			}
	
			rotation.Yaw += angleDistance*timeDelta;
			
			position = entity.GetWorldPosition();
			
			position += speed*direction*timeDelta;
			
			
			
				
				
			
				
			
			
			
			entity.TeleportWithRotation(position, rotation);
			
			
			
			
			
			
			
			
			
			
			
			previousAngleDistance = absAngleDistance;
		}
	}
	
	function SpawnBackgroundEntities( attachement : CEntity )
	{
		var slotName : name;
		
		var j, backgroundSize : int;
		
		backgroundSize = backgroundEntityData.Size();
		
		for( j = 0; j < backgroundSize; j += 1 )
		{
			if( backgroundEntityData[j].entityTemplate )
			{
				entityToAttach = theGame.CreateEntity( backgroundEntityData[j].entityTemplate, this.GetWorldPosition(), this.GetWorldRotation() );
				
				if( entityToAttach && backgroundEntityData[j].spawnSlotName != '' && backgroundEntityData[j].spawnSlotName != 'None' )
				{
					entityToAttach.CreateAttachment( attachement, backgroundEntityData[j].spawnSlotName );
					
					if( backgroundEntityData[j].appearanceName != '' && backgroundEntityData[j].appearanceName != 'None' )
					{
						entityToAttach.ApplyAppearance( backgroundEntityData[j].appearanceName );
					}
					entityToAttach.SetBehaviorVariable( 'WorkTypeEnum_Single', (int)backgroundEntityData[j].workAnimationEvent);
				}
			}
		}
	}
	
	public function StartMoving()
	{
		entity.PlayEffect( 'water_trail' );
		RemoveTimer( 'TimerMove' );
		AddTimer( 'TimerMove', 0.01, true );
		entity.SoundEvent( "qu_sk_drakkar_singing" );
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		entity = theGame.CreateEntity(parentEntity, this.GetWorldPosition(), this.GetWorldRotation());
		
		if( entity )
		{
			SetupNodes();
			SpawnBackgroundEntities( entity );
		
			if( startAtSpawn )
			{
				StartMoving();
			}
		}
	}
	
	timer function TimerMove( td : float , id : int)
	{
		MoveBetweenWaypoints( td );
	}
}

class W3BackgroundAnimatedEntityTrigger extends CGameplayEntity
{
	editable var movingEntitySpawnerHandle : EntityHandle;
	var movingEntitySpawner : W3BackgroundAnimatedEntity;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( activator.GetEntity() == thePlayer )
		{
			movingEntitySpawner = (W3BackgroundAnimatedEntity)EntityHandleGet( movingEntitySpawnerHandle );
			
			if( movingEntitySpawner )
			{
				movingEntitySpawner.StartMoving();
			}
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
	}
}



class W3ChangeCombatStageTrigger extends CGameplayEntity
{
	var npc : CNewNPC;
	
	function GiantCombatStage( npcTag : name, stage : ENPCFightStage )
	{
		var npc : CNewNPC;
		
		npc = theGame.GetNPCByTag( npcTag );
		
		npc.ChangeFightStage( stage );
	}
	function GiantChangeAp( npcTag : name, appearanceName : name )
	{
		var npc : CNewNPC;
		
		npc = theGame.GetNPCByTag( npcTag );
		
		npc.SetAppearance( appearanceName );
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( activator.GetEntity() == thePlayer )
		{
			GiantChangeAp('giant', 'ice_giant_anchor');
			GiantCombatStage('giant', NFS_Stage2);
		}
	}

}


class W3ShepherdGreetingTrigger extends CGameplayEntity
{
	var greeted : bool;
	var actors : array< CActor >;
	
	default greeted = false;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( activator.GetEntity() == thePlayer && !greeted )
		{
			actors = GetActorsInRange(activator, 40, 1, 'shepherd');
			if ( actors.Size() > 0 )
			{
				((CNewNPC)actors[0]).PlayVoiceset(100,"greeting_geralt");
				greeted = true;
			}
		}
	}
}

class W3DestructionTrigger extends CGameplayEntity
{
	editable var destructionEntityTag : name;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var destructionComponents : array<CComponent>;
		var destructionComponent : CDestructionSystemComponent;
		var destructionNodes : array<CNode>;
		var destructionEntity : CEntity;
		var i, size, j, size2 : int;
		
		if( activator.GetEntity() == thePlayer )
		{
			theGame.GetNodesByTag( destructionEntityTag, destructionNodes );
			
			size = destructionNodes.Size();
			
			for( i = 0; i < size; i += 1 )
			{
				destructionEntity = (CEntity)destructionNodes[i];
				
				if( destructionEntity )
				{
					destructionComponents = destructionEntity.GetComponentsByClassName( 'CDestructionSystemComponent' );
					
					size2 = destructionComponents.Size();
					for( j = 0; j < size2; j += 1 )
					{
						destructionComponent = (CDestructionSystemComponent)destructionComponents[i];
						
						if( destructionComponent )
						{
							destructionComponent.SetEnabled(true);
						}
					}
				}
				
			}
		}
		
		
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
	}
}



statemachine class W3FoodDispenser extends CGameplayEntity
{
	editable var foodEntity : CEntityTemplate;
	editable var maxSpawnedFood : int;
	
	var spawnedFood : array< CEntity >;
	
	default maxSpawnedFood = 3;
	default autoState = 'Inactive';
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		GotoStateAuto();
		
		if( IsPlayerNear() )
		{
			ActivateFoodDispenser( true );
		}
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		ActivateFoodDispenser( true );		
	}
	
	event OnAreaExtit( area : CTriggerAreaComponent, activator : CComponent )
	{
		ActivateFoodDispenser( false );
	}
	
	function GetEntitySpawnPos() : Vector
	{
		var local2world : Matrix;
		var offset : Vector;
		var entSpawnPos : Vector;
		
		local2world = this.GetLocalToWorld();
		offset = Vector( RandRangeF( 1.5f, -1.5f ), RandRangeF( 1.5f, -1.5f ), 0.f );
		
		entSpawnPos = VecTransform( local2world, offset );
		return entSpawnPos;
	}
	
	timer function SpawnFood( deltaTime : float , id : int)
	{
		var i : int;
		var spawnedFoodEntity : CEntity;
		
		if( spawnedFood.Size() <= maxSpawnedFood )
		{
			for( i = spawnedFood.Size(); i < maxSpawnedFood; i += 1 )
			{
				spawnedFoodEntity = theGame.CreateEntity( foodEntity, GetEntitySpawnPos() );
				spawnedFood.PushBack( spawnedFoodEntity );
			}
		}	
		AddTimer( 'DespawnFood', 20.f, false );
	}
	
	timer function DespawnFood( deltaTime : float , id : int)
	{
		
		
		
		spawnedFood.Clear();
	}
	
	function IsPlayerNear() : bool
	{
		var dispenserArea : CAreaComponent;
		
		dispenserArea = (CAreaComponent)this.GetComponentByClassName( 'CTriggerAreaComponent' );
		
		return dispenserArea.TestEntityOverlap( (CEntity)thePlayer );
	}
	
	function ActivateFoodDispenser( isOn : bool )
	{
		if( isOn )
		{
			PushState( 'Active' );
		}
		else
		{
			PopState( true );
		}
	}
}

state Active in W3FoodDispenser
{
	event OnEnterState( prevStateName : name )
	{
		ActivationInit();
	}
	
	entry function ActivationInit()
	{
		parent.AddTimer( 'SpawnFood', 40.f, true );
	}
}

state Inactive in W3FoodDispenser
{
	event OnEnterState( prevStateName : name )
	{
		DeactivationInit();
	}
	
	entry function DeactivationInit()
	{
		parent.RemoveTimer( 'SpawnFood' );
	}
}


