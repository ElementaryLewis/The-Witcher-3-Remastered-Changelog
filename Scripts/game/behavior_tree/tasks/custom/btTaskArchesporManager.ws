/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskArchesporManager extends IBehTreeTask
{
	protected var data : CArchesporeAICombatStorage;
	
	protected var npc : CNewNPC;
	protected var allBaseEntities : array<CGameplayEntity>;
	protected var usedPos : array<Vector>;
	protected var entityTemplate : CEntityTemplate;
	protected var anchorPos : Vector;
	protected var privateBulb : W3ArchesporBulb;
	protected var guardArea : CAreaComponent;
	protected var losTestCollisionGroups : array<name>;
	
	
	
	protected var baseEntitiesSearchingRange : float;
	protected var baseEntityTag : name;
	protected var resourceName : string;
	protected var baseEntitiesToSpawnCount : int;
	protected var minDistFromOwner : float;
	protected var maxDistFromOwner : float;
	protected var minDistFromEachOther : float;
	protected var maxDistFromAnchor : float;
	protected var spawnEntitiesAroundPlayer : bool;
	
	
	
	default baseEntitiesSearchingRange = 100.0;
	default baseEntityTag = 'archespor_base';
	default baseEntitiesToSpawnCount = 3;
	default minDistFromOwner = 3;
	default maxDistFromOwner = 10;
	default minDistFromEachOther = 3;
	default maxDistFromAnchor = 30.0;
	default spawnEntitiesAroundPlayer = false;
	
	function OnActivate() : EBTNodeStatus
	{
		Init();
		
		if( !data.wasInitialized )
		{
			InitArchespor();
		}
		else
		{
			baseEntitiesToSpawnCount = 0;
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var currentPlayerStateName : name;
		currentPlayerStateName = thePlayer.GetCurrentStateName();
		
		if( currentPlayerStateName == 'Meditation' || currentPlayerStateName == 'MeditationWaiting' )
		{
			Cleanup();
		}
	}

	protected function Init()
	{
		npc = GetNPC();
		anchorPos = npc.GetWorldPosition();
		guardArea = npc.GetGuardArea();
		
		
		data = (CArchesporeAICombatStorage)InitializeCombatStorage();
		
		InitArchesporType();
	}
			
	latent function Main() : EBTNodeStatus
	{
		Init();
		
		while( true )
		{	
			if( baseEntitiesToSpawnCount )
			{
				SpawnBaseEntities( baseEntitiesToSpawnCount );
			}
			
			SleepOneFrame();
		}
		
		return BTNS_Active;
	}
	
	protected function AddToMyBaseEntities( baseEntity : CGameplayEntity )
	{	
		if( !data.myBaseEntities.Contains( baseEntity ) )
		{
			data.myBaseEntities.PushBack( baseEntity );
			npc.SetBehaviorVariable( 'bulbCount', data.myBaseEntities.Size() );
		}	
	}
	
	private function RemoveFromMyBaseEntities( baseEntity : CGameplayEntity )
	{
		var i : int;
		
		for( i = 0; i < data.myBaseEntities.Size(); i+= 1 )
		{
			if( data.myBaseEntities[ i ] == baseEntity )
			{
				break;
			}
		}
		
		data.myBaseEntities.EraseFast( i );
		npc.SetBehaviorVariable( 'bulbCount', data.myBaseEntities.Size() );
	}

	protected function UpdateUsedPositions()
	{
		var i : int;
	
		usedPos.Clear();
		allBaseEntities.Clear();
		FindGameplayEntitiesInRange( allBaseEntities, npc, baseEntitiesSearchingRange, 100, baseEntityTag );
		
		for( i = 0; i < allBaseEntities.Size(); i += 1 )
		{
			usedPos.PushBack( allBaseEntities[ i ].GetWorldPosition() );
		}
	}
	
	private latent function SpawnBaseEntities( count : int, optional sleepTimeAfterSpawn : float )
	{
		var pos : Vector;
		var i : int;
		
		if( !entityTemplate )
		{
			entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName, true );
		}
		
		for( i = 0; i < count; i += 1 )
		{
			pos = FindPosition( spawnEntitiesAroundPlayer );
			
			while( !IsPositionValid( pos ) )
			{
				SleepOneFrame();
				pos = FindPosition( spawnEntitiesAroundPlayer );
			}
			
			if( !IsTurret() )
			{
				ShootSFXProjectile( pos );
				Sleep( 0.5 );
			}
			
			Spawn( pos );
		}
		
		if( sleepTimeAfterSpawn )
		{
			Sleep( sleepTimeAfterSpawn );
		}

		baseEntitiesToSpawnCount = 0;
		spawnEntitiesAroundPlayer = false;
	}
	
	protected function FindPosition( aroundPlayer : bool ) : Vector
	{
		var randVec : Vector = Vector( 0.f, 0.f, 0.f );
		var basePos : Vector;
		var outPos : Vector;
		
		if( IsTurret() )
		{
			return npc.GetWorldPosition();
		}
		
		if( aroundPlayer )
		{
			basePos = thePlayer.GetWorldPosition();
			randVec = VecRingRand( 0.5, 3.0 );
		}
		else
		{
			basePos = npc.GetWorldPosition();
			randVec = VecRingRand( minDistFromOwner, maxDistFromOwner );
		}
		
		outPos = basePos + randVec;
		
		return outPos;
	}
	
	protected function IsPositionValid( out whereTo : Vector ) : bool
	{
		var newPos, tempStartPos, tempEndPos, tempPos1, tempPos2 : Vector;
		var radius : float;
		var z : float;
		var i : int;
		
		UpdateUsedPositions();
		
		radius = 0.1;
		
		if( IsTurret() )
		{
			return true;
		}
		
		if( !theGame.GetWorld().NavigationFindSafeSpot( whereTo, radius, radius*10, newPos ) )
		{
			if( theGame.GetWorld().NavigationComputeZ( whereTo, whereTo.Z - 5.0, whereTo.Z + 5.0, z ) )
			{
				whereTo.Z = z;
				if( !theGame.GetWorld().NavigationFindSafeSpot( whereTo, radius, radius*10, newPos ) )
				{
					
					return false;
				}
			}
			else
			{
				
				return false;
			}
		}
		
		if( VecDistance2D( newPos, anchorPos ) > maxDistFromAnchor )
		{
			
			return false;
		}
		
		if( guardArea )
		{
			if( !guardArea.TestPointOverlap( newPos ) )
			{
				
				return false;
			}
		}
		
		
		if( data.noBulbAreas.Size() && !spawnEntitiesAroundPlayer )
		{
			for( i = 0; i < data.noBulbAreas.Size(); i += 1 )
			{
				if( data.noBulbAreas[ i ].TestPointOverlap( newPos ) )
				{
					
					return false;
				}
			}
		}

		for( i = 0; i < usedPos.Size(); i += 1 )
		{
			if( spawnEntitiesAroundPlayer )
			{
				if( VecDistance2D( newPos, usedPos[i] ) < 2.0 )
				{
					
					return false;
				}
			}
			else
			{
				if( VecDistance2D( newPos, usedPos[i] ) < minDistFromEachOther )
				{
					
					return false;
				}
			}
		}
		
		
		tempStartPos = npc.GetWorldPosition();
		tempStartPos.Z += 2.0;
		tempEndPos = newPos;
		tempEndPos.Z += 1.0;
		if( theGame.GetWorld().SweepTest( tempStartPos, tempEndPos, 0.1, tempPos1, tempPos2, losTestCollisionGroups ) )
		{
			
			return false;
		}
		
		whereTo = newPos;
		
		return true;
	}
	
	protected function Spawn( position : Vector )
	{
		var entity : CEntity;
		var randYaw : float;
		var rotation : EulerAngles;
		var bulb : W3ArchesporBulb;
		
		if( entityTemplate )
		{
			randYaw = RandRangeF( 180.0, -180.0 );
			rotation.Yaw = randYaw;
			entity = theGame.CreateEntity( entityTemplate, position, rotation );
		}
		
		bulb = (W3ArchesporBulb)entity;
		
		if( bulb )
		{
			usedPos.PushBack( position );
			
			if( spawnEntitiesAroundPlayer )
			{
				bulb.AddTag( 'suicideBulb' );
			}
			else
			{
				if( IsTurret() )
				{
					privateBulb = bulb;
					bulb.AddTag( 'currentlyUsedBase' );
				}
				
				bulb.SetParentEntity( npc );
				AddToMyBaseEntities( bulb );
				
				if( npc.IsInCombat() )
				{
					
				}	
			}
		}
	}
	
	private function TeleportUnderBaseEntity( baseEntity : CGameplayEntity )
	{
		var position : Vector;
		var rotation : EulerAngles;
		
		position = baseEntity.GetWorldPosition();
		rotation = VecToRotation( thePlayer.GetWorldPosition() - position );
		rotation.Pitch = 0.0;
		rotation.Roll = 0.0;
		
		npc.TeleportWithRotation( position, rotation );
		SetCurrentlyUsedBaseEntity( baseEntity );
	}
	
	protected function SetCurrentlyUsedBaseEntity( baseEntity : CGameplayEntity )
	{
		if( baseEntity )
		{
			baseEntity.AddTag( 'currentlyUsedBase' );
			ToggleBaseEntityCollision( baseEntity, false );
			((CActor)baseEntity).SetTatgetableByPlayer( false );
		}
		
		data.currentlyUsedBase.RemoveTag( 'currentlyUsedBase' );
		((CActor)data.currentlyUsedBase).SetTatgetableByPlayer( true );
		ToggleBaseEntityCollision( data.currentlyUsedBase, true );
		
		data.currentlyUsedBase = baseEntity;
	}
	
	protected function ToggleBaseEntityCollision( baseEntity : CGameplayEntity, val : bool )
	{
		if( val )
		{
			((CActor)baseEntity).EnableCollisions( true );
			((CActor)baseEntity).EnableCharacterCollisions( true );
		}
		else
		{	
			((CActor)baseEntity).EnableCollisions( false );
			((CActor)baseEntity).EnableCharacterCollisions( false );
		}
	}
	
	protected function OpenBaseEntity( entity : CGameplayEntity )
	{
		entity.RaiseEvent( 'Open' );
		entity.SetBehaviorVariable( 'isOverground', 1.0 );
	}
	
	protected function CloseBaseEntity( entity : CGameplayEntity, resetUsedBase : bool )
	{
		if( data.currentlyUsedBase )
		{
			entity.RaiseEvent( 'Close' );
			entity.SetBehaviorVariable( 'isOverground', 0.0 );
			
			if( resetUsedBase )
			{
				SetCurrentlyUsedBaseEntity( NULL );
			}
		}
	}
	
	private function ExplodeBaseEntity( entity : CGameplayEntity )
	{
		entity.RaiseEvent( 'CloseAndExplode' );
		entity.AddTag( 'cantBeDestroyed' );
		entity.RemoveTag( 'archespor_base' );
		entity.DestroyAfter( 20.0 );
		
		SetCurrentlyUsedBaseEntity( NULL );
		
		RemoveFromMyBaseEntities( entity );
		thePlayer.OnBecomeUnawareOrCannotAttack( (CActor)entity );
	}
	
	private function GetFarthestBaseEntity() : CGameplayEntity
	{
		var i : int;
		var dist, maxDist : float;
		var farthestBaseEntityId : int;
		
		if( IsTurret() && privateBulb )
		{
			return privateBulb;
		}

		for( i = 0; i < data.myBaseEntities.Size(); i += 1 )
		{
			dist = VecDistance2D( GetCombatTarget().GetWorldPosition(), data.myBaseEntities[i].GetWorldPosition() );
			
			if( dist > maxDist && data.myBaseEntities[i] != data.currentlyUsedBase )
			{
				maxDist = dist;
				farthestBaseEntityId = i;
			}
		}
		
		return data.myBaseEntities[farthestBaseEntityId];
	}
	
	protected function ShootSFXProjectile( position : Vector )
	{
		var startPos : Vector;
		var startRot : EulerAngles;
		var projectileEntity : CEntityTemplate;
		var projectile : W3AdvancedProjectile;
		var maxRange : float;
		var collGroups : array< name >;
		
		collGroups.PushBack( 'Door' );
		
		startPos = npc.GetWorldPosition();
		startRot = npc.GetWorldRotation();
		
		maxRange = VecDistance2D( startPos, position );
		
		projectileEntity = (CEntityTemplate)LoadResource( "archespor_sfx_projectile" );
		projectile = (W3AdvancedProjectile)theGame.CreateEntity( projectileEntity, startPos, startRot );
		
		if( projectile )
		{
			projectile.ShootProjectileAtPosition( projectile.projAngle, projectile.projSpeed, position, maxRange, collGroups );
		}
	}
	
	protected function InitArchespor()
	{
		npc.ToggleIsOverground( false );
		InitCollisionGroups();
		InitArchesporBulbsCount();
		GatherNoBulbAreas();
		
		data.wasInitialized = true;
	}
	
	private function InitCollisionGroups()
	{
		losTestCollisionGroups.PushBack( 'Static' );
		losTestCollisionGroups.PushBack( 'Destructible' );
		losTestCollisionGroups.PushBack( 'Terrain' );
		losTestCollisionGroups.PushBack( 'Foliage' );
		losTestCollisionGroups.PushBack( 'Door' );
	}
	
	protected function InitArchesporType()
	{
		if( npc.HasAbility( 'ArchesporHard' ) )
		{
			npc.SetBehaviorVariable( 'echinopsHard', 1.0 );
			resourceName = "dlc\bob\data\characters\npc_entities\monsters\echinops_base_hard.w2ent";
		}
		else if( npc.HasAbility( 'ArchesporNormal' ) )
		{
			resourceName = "dlc\bob\data\characters\npc_entities\monsters\echinops_base_normal.w2ent";
		}
		else if( npc.HasAbility( 'ArchesporNormal_LW' ) )
		{
			resourceName = "dlc\bob\data\characters\npc_entities\monsters\echinops_base_normal_lw.w2ent";
		}
		else if( IsTurret() )
		{
			resourceName = "dlc\bob\data\characters\npc_entities\monsters\echinops_base_turret.w2ent";
		}
	}
	
	protected function InitArchesporBulbsCount()
	{
		if( npc.HasAbility( 'ArchesporHard' ) )
		{
			baseEntitiesToSpawnCount = 5;
		}
		else if( npc.HasAbility( 'ArchesporNormal' ) )
		{
			baseEntitiesToSpawnCount = 3;
		}
		else if( npc.HasAbility( 'ArchesporNormal_LW' ) )
		{
			baseEntitiesToSpawnCount = 3;
		}
		else if( IsTurret() )
		{
			baseEntitiesToSpawnCount = 1;
		}
	}

	protected function IsTurret() : bool
	{
		return npc.HasAbility( 'ArchesporTurret' );
	}
	
	private function GatherNoBulbAreas()
	{
		var gameplayEntities : array<CGameplayEntity>;
		var tempNoBulbArea : CArchesporeNoBulbArea;
		var tempAreaComp : CAreaComponent;
		var i : int;
		
		FindGameplayEntitiesInRange( gameplayEntities, npc, 40.0, 100, 'noBulbArea' );
		
		for( i = 0; i < gameplayEntities.Size(); i += 1 )
		{
			tempNoBulbArea = (CArchesporeNoBulbArea)gameplayEntities[ i ];
			
			if( tempNoBulbArea )
			{
				tempAreaComp = (CAreaComponent)tempNoBulbArea.GetComponentByClassName( 'CAreaComponent' );
				
				if( tempAreaComp )
				{
					data.noBulbAreas.PushBack( tempAreaComp );
				}
			}
		}
	}
	
	
	
	




	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var bulb : CGameplayEntity;
		var i : int;
		
		if( !isActive )
			return false;
		
		if( eventName == 'CloseAndResetBulb' )
		{
			CloseBaseEntity( data.currentlyUsedBase, true );
		}
		else if( eventName == 'CloseBulb' )
		{
			CloseBaseEntity( data.currentlyUsedBase, false );
		}
		else if( eventName == 'RepositionToFarthest' )
		{
			bulb = GetFarthestBaseEntity();
			
			if( bulb )
			{
				TeleportUnderBaseEntity( bulb );
				OpenBaseEntity( bulb );
			}
		}
		else if( eventName == 'CloseQ803' )
		{
			bulb = GetFarthestBaseEntity();
			
			if( bulb )
			{
				TeleportUnderBaseEntity( bulb );
			}
		}
		else if( eventName == 'RefreshBaseEntitiesList' )
		{
			if( !data.manualBulbCleanup )
			{
				bulb = (CGameplayEntity)GetEventParamObject();
			
				if( bulb )
				{
					RemoveFromMyBaseEntities( bulb );
				}
			}		
		}
		else if( eventName == 'OnMonsterCombatStart' )
		{
			for( i = 0; i < data.myBaseEntities.Size(); i += 1 )
			{
				thePlayer.OnBecomeAwareAndCanAttack( (CActor)data.myBaseEntities[ i ] );
			}
		}
		else if( eventName == 'EmergencyCreateBulb' )
		{
			ExplodeBaseEntity( data.currentlyUsedBase );
			Spawn( npc.GetWorldPosition() );
		}
		else if( eventName == 'CombatCleanup' )
		{
			Cleanup();
		}
		
		return true;
	}
	
	protected function Cleanup()
	{
		var i : int;
		
		data.manualBulbCleanup = true;
		
		SetCurrentlyUsedBaseEntity( NULL );
		
		for( i = 0; i < data.myBaseEntities.Size(); i += 1 )
		{
			
			thePlayer.OnBecomeUnawareOrCannotAttack( (CActor)data.myBaseEntities[ i ] );
			
			
			((W3ArchesporBulb)data.myBaseEntities[ i ]).ExplodeGlobal();
		}
		
		allBaseEntities.Clear();
		usedPos.Clear();
		spawnEntitiesAroundPlayer = false;
		
		
		data.myBaseEntities.Clear();
		data.noBulbAreas.Clear();
		npc.SetBehaviorVariable( 'bulbCount', 0.0 );
		data.wasInitialized = false;
		
		data.manualBulbCleanup = false;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{	
		if( animEventName == 'CloseAndResetBulb' )
		{
			CloseBaseEntity( data.currentlyUsedBase, true );
		}
		else if( animEventName == 'CloseBulb' )
		{
			CloseBaseEntity( data.currentlyUsedBase, false );
		}
		else if( animEventName == 'OpenBulb' )
		{
			OpenBaseEntity( data.currentlyUsedBase );
		}
		else if( animEventName == 'ExplodeBulb' )
		{
			ExplodeBaseEntity( data.currentlyUsedBase );
		}
		else if( animEventName == 'SpawnBulb' )
		{
			baseEntitiesToSpawnCount = 1;
		}
		else if( animEventName == 'SpawnBulbAroundPlayer' )
		{
			spawnEntitiesAroundPlayer = true;
			baseEntitiesToSpawnCount = 1;
		}
		
		return true;
	}
}




class BTTaskArchesporManagerDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskArchesporManager';

	function InitializeEvents() 
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'CloseAndResetBulb' );
		listenToGameplayEvents.PushBack( 'CloseBulb' );
		listenToGameplayEvents.PushBack( 'RepositionToFarthest' );
		listenToGameplayEvents.PushBack( 'CloseQ803' );
		listenToGameplayEvents.PushBack( 'RefreshBaseEntitiesList' );
		listenToGameplayEvents.PushBack( 'OnMonsterCombatStart' );
		listenToGameplayEvents.PushBack( 'EmergencyCreateBulb' );
		listenToGameplayEvents.PushBack( 'CombatCleanup' );
	}
}