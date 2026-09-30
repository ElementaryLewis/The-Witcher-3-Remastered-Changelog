/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum ESpawnPositionPattern
{
	ESPP_AroundTarget,
	ESPP_AroundSpawner,
	ESPP_AroundBoth
}
enum ESpawnRotation
{
	ESR_BackAtSpawner,
	ESR_TowardsSpawner,
	ESR_TowardsTarget,
	ESR_SameAsSpawner,
	ESR_OppositeOfSpawner
	
}

class CBTTaskSpawnMultipleEntitiesAttack extends CBTTaskSpawnEntityAttack
{
	
	
	
	var		numberToSpawn				: int;
	var		numberOfCircles				: int;
	var		randomnessInCircles			: float;
	var		useRandomSpaceBetweenSpawns	: bool;
	var		spawnRadiusMin				: float;
	var		spawnRadiusMax				: float;
	var		spawnEntityRadius			: float;
	var		spawnPositionPattern		: ESpawnPositionPattern;
	var		spawnRotation				: ESpawnRotation;
	var		leaveOpenSpaceForDodge		: bool;
	var		spawnInRandomOrder			: bool;
	var		delayBetweenSpawn			: float;
	var		spawnOnGround				: bool;
	
	
	var m_dodgeDistance			: float;
	var m_dodgeSafeAreaRadius	: float;
	var m_shouldSpawn			: bool;
	var m_entitiesSpawned		: int;
	var m_canComplete			: bool;
	
	default m_dodgeDistance = 1;
	default m_dodgeSafeAreaRadius = 2.0f;
	
	
	
	latent function Main() : EBTNodeStatus
	{
		if ( !entityTemplate )
		{
			entityTemplate = ( CEntityTemplate ) LoadResourceAsync( ressourceName );
		}
		
		if ( !entityTemplate )
		{
			return BTNS_Failed;
		}
		
		while( !m_shouldSpawn )
		{
			SleepOneFrame();
		}
		
		LatentSpawnEntity();
		
		while( !m_canComplete )
		{
			SleepOneFrame();
		}
		
		if( m_entitiesSpawned >= numberToSpawn )
		{
			return BTNS_Completed;
		}
		
		return BTNS_Active;
			
	}	
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		finishTaskOnAllowBlend = false;
		if ( animEventName == 'AllowBlend' && animEventType == AET_DurationStart )
		{
			m_canComplete = true;
		}
		
		return super.OnAnimEvent( animEventName, animEventType, animInfo );
		
	}
	
	
	function SpawnEntity()
	{
		m_shouldSpawn = true;
	}
	
	
	latent function LatentSpawnEntity()
	{
		var i 						: int;
		var l_spawnCenter			: Vector;
		var l_spawnPos 				: Vector;
		var l_entity 				: CEntity;
		
		var l_coneAngle				: float;
		var l_coneWidth				: float;
		var l_randomVector			: Vector;
		var l_normal				: Vector;
		var l_rotation				: EulerAngles;
		var l_npc					: CNewNPC		= GetNPC();
		var l_npcPos				: Vector;
		var l_targetPos				: Vector;
		var l_dodgePos				: Vector;
		var l_currentCircle 		: float;
		var l_numPerCircle			: int;
		var l_numberInCurrentCircle : int;
		var l_currentCone			: int;
		var l_circleRadiusMin		: float;
		var l_circleRadiusMax		: float;
		
		var l_positionArray			: array<Vector>;
		var l_rotationArray			: array<EulerAngles>;
		
		switch ( spawnPositionPattern )
		{
			case ESPP_AroundTarget:
			if ( !useCombatTarget )
				l_spawnCenter = GetActionTarget().GetWorldPosition();
			else
				l_spawnCenter = GetCombatTarget().GetWorldPosition();
			break;
			case ESPP_AroundSpawner:
			l_spawnCenter = GetNPC().GetWorldPosition();
			break;
			case ESPP_AroundBoth:
			l_spawnCenter = GetNPC().GetWorldPosition();
			if ( !useCombatTarget )
				l_spawnCenter += GetActionTarget().GetWorldPosition();
			else
				l_spawnCenter += GetCombatTarget().GetWorldPosition();
			l_spawnCenter /= 2;
			break;
		}
		
		
		numberOfCircles = Max( 1, numberOfCircles );
		
		l_numPerCircle 	= FloorF( ( float ) numberToSpawn / ( float ) numberOfCircles );
		l_coneAngle 	= 360 / ( float ) l_numPerCircle;		
		
		l_npcPos 		= l_npc.GetWorldPosition();
		if ( !useCombatTarget )
			l_targetPos = GetActionTarget().GetWorldPosition();
		else
			l_targetPos = GetCombatTarget().GetWorldPosition();
		
		if( leaveOpenSpaceForDodge )
		{
			l_dodgePos = l_targetPos + ( VecRand2D() * m_dodgeDistance );
		}
		
		l_coneWidth = 0.5f;
		if( useRandomSpaceBetweenSpawns )
		{
			l_coneWidth = l_coneAngle;
		}
		
		l_positionArray.Clear();
		l_rotationArray.Clear();
		
		for	( i = 0; i < numberToSpawn  ; i += 1 )
		{
			l_circleRadiusMin = spawnRadiusMin + ( l_currentCircle / (float) numberOfCircles )  * ( spawnRadiusMax - spawnRadiusMin) ;
			l_circleRadiusMax = spawnRadiusMax - ( l_currentCircle / (float) numberOfCircles )  * ( spawnRadiusMax - spawnRadiusMin) ;
			
			if( numberOfCircles > 1 )
			{
				l_circleRadiusMax = MinF( l_circleRadiusMin + randomnessInCircles, spawnRadiusMax );
			}
			
			l_randomVector = VecConeRand( l_currentCone * l_coneAngle , l_coneWidth, l_circleRadiusMin, l_circleRadiusMax );			
			l_spawnPos = l_spawnCenter + l_randomVector + offsetVector;
			
			
			if( leaveOpenSpaceForDodge && VecDistance( l_spawnPos, l_dodgePos ) < m_dodgeSafeAreaRadius)
			{	
				m_entitiesSpawned += 1;
				continue;
			}
			
			if( spawnOnGround )
			{
				theGame.GetWorld().StaticTrace( l_spawnPos + Vector(0,0,5), l_spawnPos - Vector(0,0,5), l_spawnPos, l_normal );
			}
			
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
			
		while	( l_positionArray.Size() > 0 )
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
			
			
			m_entitiesSpawned += 1;
			if( delayBetweenSpawn > 0 )
			{
				Sleep( delayBetweenSpawn );
			}
		}
	}
	
	
	function CreateEntity( _SpawnPos : Vector, _Rotation : EulerAngles ) : CEntity
	{
		var	l_npc						: CNewNPC = GetNPC();
		var l_entity 					: CEntity;
		var l_damageAreaEntity 			: CDamageAreaEntity;
		var l_summonedEntityComponent 	: W3SummonedEntityComponent;
		var l_newPos					: Vector;
		
		if ( !theGame.GetWorld().NavigationFindSafeSpot( _SpawnPos, spawnEntityRadius, spawnEntityRadius*3, l_newPos ) )
		{
			Log("Not enough space to spawn FX entity from TaskSpawnMultipleEntitiesAttack.");
			return NULL;
		}
		
		l_entity = theGame.CreateEntity( entityTemplate, l_newPos, _Rotation );
		
		if( m_summonerComponent )
		{
			m_summonerComponent.AddEntity( l_entity );
		}
		
		l_summonedEntityComponent = (W3SummonedEntityComponent) l_entity.GetComponentByClassName('W3SummonedEntityComponent');
		if( l_summonedEntityComponent )
		{
			l_summonedEntityComponent.Init( l_npc );
		}
		
		l_damageAreaEntity = (CDamageAreaEntity)l_entity;
		if ( l_damageAreaEntity )
		{
			l_damageAreaEntity.owner = GetActor();
		}
		
		return l_entity;
	}
	
	
	function OnDeactivate()
	{
		m_shouldSpawn = false;
		m_canComplete = false;
		m_entitiesSpawned = 0;
	}
}



class CBTTaskSpawnMultipleEntitiesAttackDef extends CBTTaskSpawnEntityAttackDef
{
	default instanceClass = 'CBTTaskSpawnMultipleEntitiesAttack';
	
	
	
	editable var		numberToSpawn					: int;
	editable var		numberOfCircles					: int;
	editable var		spawnPositionPattern			: ESpawnPositionPattern;
	editable var		randomnessInCircles				: float;
	editable var		useRandomSpaceBetweenSpawns		: bool;
	editable var		spawnRadiusMin					: float;
	editable var		spawnRadiusMax					: float;
	editable var		spawnEntityRadius				: float;
	editable var		spawnRotation					: ESpawnRotation;
	editable var		leaveOpenSpaceForDodge			: bool;
	editable var		delayBetweenSpawn				: float;
	editable var		spawnInRandomOrder				: bool;
	editable var		spawnOnGround					: bool;
	
	
	default numberToSpawn		= 2;
	default numberOfCircles		= 1;
	default randomnessInCircles	= 0;
	default spawnEntityRadius	= 1;
	default spawnRadiusMin		= 3;
	default spawnRadiusMax		= 6;
	default delayBetweenSpawn  	= 0;
	default spawnOnGround		= true;
	default useCombatTarget 	= true;
	
	hint randomnessInCircles	= "if using more than one circle, what is the position randomness max in each circle";
	hint numberOfCircles = "How many concentric circles should the entities form when spawn";
	hint spawnEntityRadius = "Free space needed for the FX entity to spawn.";
	hint leaveOpenSpaceForDodge = "If entities are spawn close to the target, leave a space without spawns at a dodge distance";
	hint useRandomSpaceBetweenSpawns = "Should the angle between each spawn be fix or random";
};





class CBTTaskSpawnMultipleEntities3StateAttack extends CBTTaskSpawnMultipleEntitiesAttack
{
	
	
	
	var		delayActivationTime						: float;
	var		loopTime								: float;
	var		endTime									: float;
	var		localTime								: float;
	var		spawnInterval							: float;
	var		decreaseLoopTimePerFailedCreateEntity	: float;
	var		spawnAdditionalEntityOnTargetPos		: bool;

	
	
	
	
	function OnActivate() : EBTNodeStatus
	{
		
		GetNPC().SetBehaviorVariable( 'AttackEnd', 0, true );
		
		return super.OnActivate();
	}	
	
	latent function Main() : EBTNodeStatus
	{
		if ( !entityTemplate )
		{
			entityTemplate = ( CEntityTemplate ) LoadResourceAsync( ressourceName );
		}
		
		if ( !entityTemplate )
		{
			return BTNS_Failed;
		}
		
		while( !m_shouldSpawn )
		{
			SleepOneFrame();
		}
		
		if( delayActivationTime > 0 )
		{
			Sleep( delayActivationTime );
		}
		
		localTime = GetLocalTime();
		endTime = localTime + loopTime;
		
		while ( GetLocalTime() <= endTime && !m_canComplete )
		{
			LatentSpawnEntity();
			SleepOneFrame();
			if( spawnInterval > 0 )
			{
				Sleep( spawnInterval );
			}
			
		}
		
		
		GetNPC().SetBehaviorVariable( 'AttackEnd', 1, true );
		
		if( m_entitiesSpawned >= numberToSpawn )
		{
			return BTNS_Completed;
		}
		
		return BTNS_Active;
	}	
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == 'AllowBlend' && animEventType == AET_DurationStart )
		{
			
			GetNPC().SetBehaviorVariable( 'AttackEnd', 1, true );
			m_canComplete = true;
		}
		
		return super.OnAnimEvent( animEventName, animEventType, animInfo );
	}
	
	
	function SpawnEntity()
	{
		m_shouldSpawn = true;
	}
	
	
	latent function LatentSpawnEntity()
	{
		var i 						: int;
		var l_spawnCenter			: Vector;
		var l_spawnPos 				: Vector;
		var l_entity 				: CEntity;
		var l_damageAreaEntity 		: CDamageAreaEntity;
		var l_coneAngle				: float;
		var l_coneWidth				: float;
		var l_randomVector			: Vector;
		var l_normal				: Vector;
		var l_rotation				: EulerAngles;
		var l_npc					: CNewNPC		= GetNPC();
		var l_npcPos				: Vector;
		var l_targetPos				: Vector;
		var l_dodgePos				: Vector;
		var l_currentCircle 		: float;
		var l_numPerCircle			: int;
		var l_numberInCurrentCircle : int;
		var l_currentCone			: int;
		var l_circleRadiusMin		: float;
		var l_circleRadiusMax		: float;

		var l_positionArray			: array<Vector>;
		var l_rotationArray			: array<EulerAngles>;
		
		var l_summonedEntityComponent : W3SummonedEntityComponent;
		
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
		l_coneAngle 	= 360 / ( float ) l_numPerCircle;		
		
		l_npcPos 		= l_npc.GetWorldPosition();
		l_targetPos		= GetCombatTarget().GetWorldPosition();
		
		if( leaveOpenSpaceForDodge )
		{
			l_dodgePos = l_targetPos + ( VecRand2D() * m_dodgeDistance );
		}
		
		l_coneWidth = 0.5f;
		if( useRandomSpaceBetweenSpawns )
		{
			l_coneWidth = l_coneAngle;
		}
		
		l_positionArray.Clear();
		l_rotationArray.Clear();
		
		for	( i = 0; i < numberToSpawn  ; i += 1 )
		{
			l_circleRadiusMin = spawnRadiusMin + ( l_currentCircle / (float) numberOfCircles )  * ( spawnRadiusMax - spawnRadiusMin) ;
			l_circleRadiusMax = spawnRadiusMax - ( l_currentCircle / (float) numberOfCircles )  * ( spawnRadiusMax - spawnRadiusMin) ;
			
			if( numberOfCircles > 1 )
			{
				l_circleRadiusMax = MinF( l_circleRadiusMin + randomnessInCircles, spawnRadiusMax );
			}
			
			l_randomVector = VecConeRand( l_currentCone * l_coneAngle , l_coneWidth, l_circleRadiusMin, l_circleRadiusMax );			
			l_spawnPos = l_spawnCenter + l_randomVector + offsetVector;
			
			
			if( leaveOpenSpaceForDodge && VecDistance( l_spawnPos, l_dodgePos ) < m_dodgeSafeAreaRadius)
			{	
				m_entitiesSpawned += 1;
				continue;
			}
			
			if( spawnOnGround )
			{
				theGame.GetWorld().StaticTrace( l_spawnPos + Vector(0,0,5), l_spawnPos - Vector(0,0,5), l_spawnPos, l_normal );
			}
			
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
		
		if ( spawnAdditionalEntityOnTargetPos )
		{
			l_entity = CreateEntity( l_targetPos, l_rotation );
		}
		
		while	( l_positionArray.Size() > 0 )
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
			
			l_summonedEntityComponent = (W3SummonedEntityComponent) l_entity.GetComponentByClassName('W3SummonedEntityComponent');
			if( l_summonedEntityComponent )
			{
				l_summonedEntityComponent.Init( l_npc );
			}
			
			l_damageAreaEntity = (CDamageAreaEntity)l_entity;
			if ( l_damageAreaEntity )
			{
				GCameraShake( 10, true, thePlayer.GetWorldPosition(), 30.0f ); 
				
				l_damageAreaEntity.owner = GetActor();
			}
			m_entitiesSpawned += 1;
			if( delayBetweenSpawn > 0 )
			{
				Sleep( delayBetweenSpawn );
			}
		}
	}
	
	
	function CreateEntity( _SpawnPos : Vector, _Rotation : EulerAngles ) : CEntity
	{
		var l_entity 	: CEntity;
		var l_newPos	: Vector;
		var l_loopTime 	: float;
		
		if ( !theGame.GetWorld().NavigationFindSafeSpot( _SpawnPos, spawnEntityRadius, spawnEntityRadius*3, l_newPos ) )
		{
			if ( decreaseLoopTimePerFailedCreateEntity > 0 )
			{
				endTime -= decreaseLoopTimePerFailedCreateEntity;
			}
			Log("Not enough space to spawn FX entity from TaskSpawnMultipleEntitiesAttack.");
			return NULL;
		}
		
		l_entity = theGame.CreateEntity( entityTemplate, l_newPos, _Rotation );
		
		return l_entity;
	}
	
	
	function OnDeactivate()
	{
		
		GetNPC().SetBehaviorVariable( 'AttackEnd', 1, true );
		m_shouldSpawn = false;
		m_canComplete = false;
		m_entitiesSpawned = 0;
	}
}



class CBTTaskSpawnMultipleEntities3StateAttackDef extends CBTTaskSpawnMultipleEntitiesAttackDef
{
	default instanceClass = 'CBTTaskSpawnMultipleEntities3StateAttack';
	
	
	
	editable var		delayActivationTime						: float;
	editable var		loopTime								: float;
	editable var		spawnInterval							: float;
	editable var		decreaseLoopTimePerFailedCreateEntity	: float;
	editable var		spawnAdditionalEntityOnTargetPos		: bool;
	
	default loopTime							= 8.34;
	default spawnInterval						= 1.667;
};